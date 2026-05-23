


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE OR REPLACE FUNCTION "public"."accept_chat"("p_room_id" "uuid", "p_admin_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  v_updated INT;
  v_uid uuid;
BEGIN
  v_uid := coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
  )::uuid;

  IF NOT EXISTS (SELECT 1 FROM admins WHERE admins.id = v_uid) THEN
    RAISE EXCEPTION 'Access denied: caller is not an admin';
  END IF;

  UPDATE chat_rooms
  SET status = 'ACTIVE'
  WHERE id = p_room_id AND status = 'WAITING';

  GET DIAGNOSTICS v_updated = ROW_COUNT;

  IF v_updated = 0 THEN
    RETURN FALSE;
  END IF;

  INSERT INTO chat_room_members (room_id, user_id, role)
  VALUES (p_room_id, p_admin_id, 'ADMIN')
  ON CONFLICT (room_id, user_id) DO NOTHING;

  RETURN TRUE;
END;
$$;


ALTER FUNCTION "public"."accept_chat"("p_room_id" "uuid", "p_admin_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."cancel_order"("p_order_id" bigint) RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_current_status text;
  v_item           record;
begin
  -- 1) 주문 존재 여부 및 현재 상태 확인 (FOR UPDATE: 동시 취소 요청 직렬화)
  select status
    into v_current_status
    from public.orders
   where id = p_order_id
     for update;

  if not found then
    raise exception 'ORDER_NOT_FOUND: 주문(%)을 찾을 수 없습니다.', p_order_id;
  end if;

  if v_current_status in ('completed', 'cancelled') then
    raise exception 'ORDER_NOT_CANCELLABLE: 이미 완료되었거나 취소된 주문입니다.';
  end if;

  -- 2) 주문 상태 → cancelled
  update public.orders
     set status = 'cancelled'
   where id = p_order_id;

  -- 3) 주문 상품의 재고 원상복구
  for v_item in
    select product_id, quantity
      from public.order_items
     where order_id = p_order_id
  loop
    update public.products
       set stock = stock + v_item.quantity
     where id = v_item.product_id;
  end loop;

  return true;

exception
  when others then
    -- 에러 발생 시 모든 변경이 자동 롤백됩니다.
    raise;
end;
$$;


ALTER FUNCTION "public"."cancel_order"("p_order_id" bigint) OWNER TO "postgres";


COMMENT ON FUNCTION "public"."cancel_order"("p_order_id" bigint) IS '주문 취소(status → cancelled) 및 재고 복원을 단일 트랜잭션으로 처리';



CREATE OR REPLACE FUNCTION "public"."confirm_payment"("p_order_id" bigint) RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_current_status text;
begin
  -- 1) 주문 존재 여부 및 현재 상태 확인 (FOR UPDATE: 동시 요청 직렬화)
  select status
    into v_current_status
    from public.orders
   where id = p_order_id
     for update;

  if not found then
    raise exception 'ORDER_NOT_FOUND: 주문(%)을 찾을 수 없습니다.', p_order_id;
  end if;

  if v_current_status != 'pending' then
    raise exception 'ORDER_NOT_PAYABLE: 결제 대기 상태의 주문만 입금 확인이 가능합니다.';
  end if;

  -- 2) 주문 상태 → paid
  update public.orders
     set status = 'paid'
   where id = p_order_id;

  return true;

exception
  when others then
    -- 에러 발생 시 모든 변경이 자동 롤백됩니다.
    raise;
end;
$$;


ALTER FUNCTION "public"."confirm_payment"("p_order_id" bigint) OWNER TO "postgres";


COMMENT ON FUNCTION "public"."confirm_payment"("p_order_id" bigint) IS '입금 확인(status → paid)을 단일 트랜잭션으로 처리';



CREATE OR REPLACE FUNCTION "public"."create_order_with_stock_check"("p_customer_name" "text", "p_customer_phone" "text", "p_shipping_address" "text", "p_total_amount" bigint, "p_items" "jsonb") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_order_id bigint;
  v_item jsonb;
  v_product_id bigint;
  v_quantity bigint;
  v_unit_price bigint;
  v_current_stock bigint;
begin
  if p_customer_name is null or btrim(p_customer_name) = '' then
    raise exception 'INVALID_CUSTOMER_NAME: 주문자 이름이 필요합니다.';
  end if;

  if p_customer_phone is null or btrim(p_customer_phone) = '' then
    raise exception 'INVALID_CUSTOMER_PHONE: 주문자 연락처가 필요합니다.';
  end if;

  if p_shipping_address is null or btrim(p_shipping_address) = '' then
    raise exception 'INVALID_SHIPPING_ADDRESS: 배송지가 필요합니다.';
  end if;

  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'EMPTY_CART: 장바구니가 비어 있습니다.';
  end if;

  -- 1) 재고 확인 (FOR UPDATE로 동시성 잠금)
  for v_item in select * from jsonb_array_elements(p_items)
  loop
    v_product_id := (v_item->>'product_id')::bigint;
    v_quantity := (v_item->>'quantity')::integer;

    if v_product_id is null or v_quantity is null or v_quantity <= 0 then
      raise exception 'INVALID_ITEM: 잘못된 주문 항목입니다.';
    end if;

    select stock
      into v_current_stock
      from public.products
     where id = v_product_id
     for update;

    if not found then
      raise exception 'PRODUCT_NOT_FOUND: 상품(%)을 찾을 수 없습니다.', v_product_id;
    end if;

    if v_current_stock < v_quantity then
      raise exception
        'INSUFFICIENT_STOCK: 상품(%) 재고 부족 (재고 %, 요청 %)',
        v_product_id,
        v_current_stock,
        v_quantity;
    end if;
  end loop;

  -- 2) 주문 생성
  insert into public.orders (
    customer_name,
    customer_phone,
    shipping_address,
    total_amount,
    status
  )
  values (
    p_customer_name,
    p_customer_phone,
    p_shipping_address,
    p_total_amount,
    'pending'
  )
  returning id into v_order_id;

  -- 3) 주문 상세 생성 + 4) 재고 차감
  for v_item in select * from jsonb_array_elements(p_items)
  loop
    v_product_id := (v_item->>'product_id')::bigint;
    v_quantity := (v_item->>'quantity')::integer;
    v_unit_price := (v_item->>'unit_price')::integer;

    insert into public.order_items (
      order_id,
      product_id,
      quantity,
      unit_price
    )
    values (
      v_order_id,
      v_product_id,
      v_quantity,
      coalesce(v_unit_price, 0)
    );

    update public.products
       set stock = stock - v_quantity
     where id = v_product_id;
  end loop;

  return true;
exception
  when others then
    -- 에러 발생 시 함수 호출 전체가 롤백됩니다.
    raise;
end;
$$;


ALTER FUNCTION "public"."create_order_with_stock_check"("p_customer_name" "text", "p_customer_phone" "text", "p_shipping_address" "text", "p_total_amount" bigint, "p_items" "jsonb") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."create_order_with_stock_check"("p_customer_name" "text", "p_customer_phone" "text", "p_shipping_address" "text", "p_total_amount" bigint, "p_items" "jsonb") IS '주문 생성, 주문 상세 생성, 재고 차감을 단일 트랜잭션으로 처리';



CREATE OR REPLACE FUNCTION "public"."get_all_chat_rooms"() RETURNS TABLE("id" "uuid", "status" "text", "created_at" timestamp with time zone, "customer_id" "uuid", "customer_name" "text", "last_message" "text", "last_message_at" timestamp with time zone)
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  SELECT
    cr.id,
    cr.status,
    cr.created_at,
    crm.user_id AS customer_id,
    u.name      AS customer_name,
    lm.message  AS last_message,
    lm.created_at AS last_message_at
  FROM chat_rooms cr
  JOIN chat_room_members crm ON crm.room_id = cr.id AND crm.role = 'CUSTOMER'
  JOIN users u ON u.id = crm.user_id
  LEFT JOIN LATERAL (
    SELECT message, created_at
    FROM chat_messages
    WHERE room_id = cr.id
    ORDER BY created_at DESC
    LIMIT 1
  ) lm ON TRUE
  ORDER BY cr.created_at DESC;
$$;


ALTER FUNCTION "public"."get_all_chat_rooms"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_chat_rooms"() RETURNS TABLE("id" "uuid", "status" "text", "created_at" timestamp with time zone, "customer_id" "uuid", "customer_name" "text", "last_message" "text", "last_message_at" timestamp with time zone)
    LANGUAGE "sql" STABLE
    SET "search_path" TO 'public'
    AS $$
  SELECT
    cr.id,
    cr.status,
    cr.created_at,
    crm.user_id AS customer_id,
    u.name AS customer_name,
    lm.message AS last_message,
    lm.created_at AS last_message_at
  FROM chat_rooms cr
  JOIN chat_room_members crm ON crm.room_id = cr.id AND crm.role = 'CUSTOMER'
  JOIN users u ON u.id = crm.user_id
  LEFT JOIN LATERAL (
    SELECT message, created_at
    FROM chat_messages
    WHERE room_id = cr.id
    ORDER BY created_at DESC
    LIMIT 1
  ) lm ON TRUE
  WHERE cr.status IN ('WAITING', 'ACTIVE')
  ORDER BY cr.created_at DESC;
$$;


ALTER FUNCTION "public"."get_chat_rooms"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_or_create_chat_room"() RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  v_uid uuid;
  v_room_id uuid;
BEGIN
  v_uid := coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
  )::uuid;

  IF v_uid IS NULL THEN
    RAISE EXCEPTION '로그인이 필요합니다.';
  END IF;

  -- 기존 WAITING/ACTIVE 방 조회
  SELECT cr.id INTO v_room_id
  FROM chat_rooms cr
  JOIN chat_room_members crm ON crm.room_id = cr.id
  WHERE crm.user_id = v_uid
    AND crm.role = 'CUSTOMER'
    AND cr.status IN ('WAITING', 'ACTIVE')
  ORDER BY cr.created_at DESC
  LIMIT 1;

  IF v_room_id IS NOT NULL THEN
    RETURN v_room_id;
  END IF;

  -- 새 방 생성 + 멤버 추가 (원자적)
  INSERT INTO chat_rooms (status)
  VALUES ('WAITING')
  RETURNING id INTO v_room_id;

  INSERT INTO chat_room_members (room_id, user_id, role)
  VALUES (v_room_id, v_uid, 'CUSTOMER');

  RETURN v_room_id;
END;
$$;


ALTER FUNCTION "public"."get_or_create_chat_room"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
BEGIN
  INSERT INTO public.users (id, email, name, phone_number, address)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'name', ''),
    COALESCE(NEW.raw_user_meta_data->>'phone', ''),
    NEW.raw_user_meta_data->>'address'
  )
  ON CONFLICT (id) DO UPDATE SET
    email        = EXCLUDED.email,
    name         = COALESCE(NULLIF(EXCLUDED.name, ''), public.users.name),
    phone_number = COALESCE(NULLIF(EXCLUDED.phone_number, ''), public.users.phone_number),
    address      = COALESCE(EXCLUDED.address, public.users.address),
    updated_at   = timezone('utc', now());
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."log_orders_history"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
begin
  if tg_op = 'INSERT' then
    insert into public.orders_history (order_id, action, old_data, new_data)
    values (new.id, 'INSERT', null, to_jsonb(new));
    return new;
  elsif tg_op = 'UPDATE' then
    insert into public.orders_history (order_id, action, old_data, new_data)
    values (new.id, 'UPDATE', to_jsonb(old), to_jsonb(new));
    return new;
  elsif tg_op = 'DELETE' then
    insert into public.orders_history (order_id, action, old_data, new_data)
    values (old.id, 'DELETE', to_jsonb(old), null);
    return old;
  end if;

  return null;
end;
$$;


ALTER FUNCTION "public"."log_orders_history"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."log_products_history"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
begin
  if tg_op = 'INSERT' then
    insert into public.products_history (product_id, action, old_data, new_data)
    values (new.id, 'INSERT', null, to_jsonb(new));
    return new;
  elsif tg_op = 'UPDATE' then
    insert into public.products_history (product_id, action, old_data, new_data)
    values (new.id, 'UPDATE', to_jsonb(old), to_jsonb(new));
    return new;
  elsif tg_op = 'DELETE' then
    insert into public.products_history (product_id, action, old_data, new_data)
    values (old.id, 'DELETE', to_jsonb(old), null);
    return old;
  end if;

  return null;
end;
$$;


ALTER FUNCTION "public"."log_products_history"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."log_users_history"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
begin
  if tg_op = 'INSERT' then
    insert into public.users_history (user_id, action, old_data, new_data)
    values (new.id, 'INSERT', null, to_jsonb(new));
    return new;
  elsif tg_op = 'UPDATE' then
    insert into public.users_history (user_id, action, old_data, new_data)
    values (new.id, 'UPDATE', to_jsonb(old), to_jsonb(new));
    return new;
  elsif tg_op = 'DELETE' then
    insert into public.users_history (user_id, action, old_data, new_data)
    values (old.id, 'DELETE', to_jsonb(old), null);
    return old;
  end if;

  return null;
end;
$$;


ALTER FUNCTION "public"."log_users_history"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."rls_auto_enable"() RETURNS "event_trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'pg_catalog'
    AS $$
DECLARE
  cmd record;
BEGIN
  FOR cmd IN
    SELECT *
    FROM pg_event_trigger_ddl_commands()
    WHERE command_tag IN ('CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO')
      AND object_type IN ('table','partitioned table')
  LOOP
     IF cmd.schema_name IS NOT NULL AND cmd.schema_name IN ('public') AND cmd.schema_name NOT IN ('pg_catalog','information_schema') AND cmd.schema_name NOT LIKE 'pg_toast%' AND cmd.schema_name NOT LIKE 'pg_temp%' THEN
      BEGIN
        EXECUTE format('alter table if exists %s enable row level security', cmd.object_identity);
        RAISE LOG 'rls_auto_enable: enabled RLS on %', cmd.object_identity;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE LOG 'rls_auto_enable: failed to enable RLS on %', cmd.object_identity;
      END;
     ELSE
        RAISE LOG 'rls_auto_enable: skip % (either system schema or not in enforced list: %.)', cmd.object_identity, cmd.schema_name;
     END IF;
  END LOOP;
END;
$$;


ALTER FUNCTION "public"."rls_auto_enable"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$
BEGIN
  NEW.updated_at = timezone('utc', now());
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."set_updated_at"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."admins" (
    "id" "uuid" NOT NULL,
    "name" "text",
    "role" "text" DEFAULT 'admin'::"text"
);


ALTER TABLE "public"."admins" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."chat_messages" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "room_id" "uuid" NOT NULL,
    "sender_id" "uuid" NOT NULL,
    "message" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "image_url" "text"
);


ALTER TABLE "public"."chat_messages" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."chat_room_members" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "room_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "role" "text" NOT NULL,
    "joined_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "chat_room_members_role_check" CHECK (("role" = ANY (ARRAY['CUSTOMER'::"text", 'ADMIN'::"text"])))
);


ALTER TABLE "public"."chat_room_members" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."chat_rooms" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "status" "text" DEFAULT 'WAITING'::"text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "chat_rooms_status_check" CHECK (("status" = ANY (ARRAY['WAITING'::"text", 'ACTIVE'::"text", 'COMPLETED'::"text"])))
);


ALTER TABLE "public"."chat_rooms" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."order_items" (
    "id" bigint NOT NULL,
    "order_id" bigint,
    "product_id" bigint,
    "quantity" bigint NOT NULL,
    "unit_price" bigint NOT NULL
);


ALTER TABLE "public"."order_items" OWNER TO "postgres";


ALTER TABLE "public"."order_items" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."order_items_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."orders" (
    "id" bigint NOT NULL,
    "customer_name" "text" NOT NULL,
    "customer_phone" "text" NOT NULL,
    "shipping_address" "text" NOT NULL,
    "total_amount" bigint NOT NULL,
    "status" "text" DEFAULT 'pending'::"text",
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()),
    "user_id" "uuid"
);


ALTER TABLE "public"."orders" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."orders_history" (
    "id" bigint NOT NULL,
    "order_id" bigint NOT NULL,
    "action" "text" NOT NULL,
    "old_data" "jsonb",
    "new_data" "jsonb",
    "changed_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "orders_history_action_check" CHECK (("action" = ANY (ARRAY['INSERT'::"text", 'UPDATE'::"text", 'DELETE'::"text"])))
);


ALTER TABLE "public"."orders_history" OWNER TO "postgres";


COMMENT ON TABLE "public"."orders_history" IS 'public.orders 테이블 INSERT/UPDATE/DELETE 변경 이력';



COMMENT ON COLUMN "public"."orders_history"."order_id" IS '변경된 orders.id';



COMMENT ON COLUMN "public"."orders_history"."action" IS 'INSERT, UPDATE, DELETE';



COMMENT ON COLUMN "public"."orders_history"."old_data" IS '변경 전 전체 row (JSONB)';



COMMENT ON COLUMN "public"."orders_history"."new_data" IS '변경 후 전체 row (JSONB)';



ALTER TABLE "public"."orders_history" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."orders_history_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



ALTER TABLE "public"."orders" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."orders_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."product_images" (
    "id" bigint NOT NULL,
    "product_id" bigint,
    "image_url" "text" NOT NULL,
    "display_order" integer DEFAULT 0,
    "is_main" boolean DEFAULT false
);


ALTER TABLE "public"."product_images" OWNER TO "postgres";


ALTER TABLE "public"."product_images" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."product_images_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."products" (
    "id" bigint NOT NULL,
    "name" "text" NOT NULL,
    "price" bigint NOT NULL,
    "stock" bigint DEFAULT 0,
    "description" "text",
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()),
    "is_best_seller" boolean DEFAULT false,
    "is_deleted" boolean DEFAULT false NOT NULL
);


ALTER TABLE "public"."products" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."products_history" (
    "id" bigint NOT NULL,
    "product_id" bigint NOT NULL,
    "action" "text" NOT NULL,
    "old_data" "jsonb",
    "new_data" "jsonb",
    "changed_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "products_history_action_check" CHECK (("action" = ANY (ARRAY['INSERT'::"text", 'UPDATE'::"text", 'DELETE'::"text"])))
);


ALTER TABLE "public"."products_history" OWNER TO "postgres";


COMMENT ON TABLE "public"."products_history" IS 'public.products 테이블 INSERT/UPDATE/DELETE 변경 이력';



COMMENT ON COLUMN "public"."products_history"."product_id" IS '변경된 products.id';



COMMENT ON COLUMN "public"."products_history"."action" IS 'INSERT, UPDATE, DELETE';



COMMENT ON COLUMN "public"."products_history"."old_data" IS '변경 전 전체 row (JSONB)';



COMMENT ON COLUMN "public"."products_history"."new_data" IS '변경 후 전체 row (JSONB)';



ALTER TABLE "public"."products_history" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."products_history_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



ALTER TABLE "public"."products" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."products_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."users" (
    "id" "uuid" NOT NULL,
    "email" "text" NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "phone_number" "text" DEFAULT ''::"text" NOT NULL,
    "address" "text",
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL
);


ALTER TABLE "public"."users" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."users_history" (
    "id" bigint NOT NULL,
    "user_id" "uuid" NOT NULL,
    "action" "text" NOT NULL,
    "old_data" "jsonb",
    "new_data" "jsonb",
    "changed_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "users_history_action_check" CHECK (("action" = ANY (ARRAY['INSERT'::"text", 'UPDATE'::"text", 'DELETE'::"text"])))
);


ALTER TABLE "public"."users_history" OWNER TO "postgres";


COMMENT ON TABLE "public"."users_history" IS 'public.users 테이블 INSERT/UPDATE/DELETE 변경 이력';



COMMENT ON COLUMN "public"."users_history"."user_id" IS '변경된 users.id';



COMMENT ON COLUMN "public"."users_history"."action" IS 'INSERT, UPDATE, DELETE';



COMMENT ON COLUMN "public"."users_history"."old_data" IS '변경 전 전체 row (JSONB)';



COMMENT ON COLUMN "public"."users_history"."new_data" IS '변경 후 전체 row (JSONB)';



ALTER TABLE "public"."users_history" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."users_history_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."wishlists" (
    "id" bigint NOT NULL,
    "user_id" "uuid" NOT NULL,
    "product_id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."wishlists" OWNER TO "postgres";


ALTER TABLE "public"."wishlists" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."wishlists_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



ALTER TABLE ONLY "public"."admins"
    ADD CONSTRAINT "admins_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."chat_messages"
    ADD CONSTRAINT "chat_messages_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."chat_room_members"
    ADD CONSTRAINT "chat_room_members_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."chat_room_members"
    ADD CONSTRAINT "chat_room_members_room_id_user_id_key" UNIQUE ("room_id", "user_id");



ALTER TABLE ONLY "public"."chat_rooms"
    ADD CONSTRAINT "chat_rooms_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."order_items"
    ADD CONSTRAINT "order_items_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."orders_history"
    ADD CONSTRAINT "orders_history_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."orders"
    ADD CONSTRAINT "orders_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."product_images"
    ADD CONSTRAINT "product_images_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."products_history"
    ADD CONSTRAINT "products_history_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."products"
    ADD CONSTRAINT "products_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_email_key" UNIQUE ("email");



ALTER TABLE ONLY "public"."users_history"
    ADD CONSTRAINT "users_history_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."wishlists"
    ADD CONSTRAINT "wishlists_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."wishlists"
    ADD CONSTRAINT "wishlists_user_id_product_id_key" UNIQUE ("user_id", "product_id");



CREATE INDEX "idx_chat_messages_room_id" ON "public"."chat_messages" USING "btree" ("room_id", "created_at");



CREATE INDEX "idx_chat_room_members_room_id" ON "public"."chat_room_members" USING "btree" ("room_id");



CREATE INDEX "idx_chat_room_members_user_id" ON "public"."chat_room_members" USING "btree" ("user_id");



CREATE INDEX "orders_history_changed_at_idx" ON "public"."orders_history" USING "btree" ("changed_at" DESC);



CREATE INDEX "orders_history_order_id_idx" ON "public"."orders_history" USING "btree" ("order_id");



CREATE INDEX "orders_user_id_idx" ON "public"."orders" USING "btree" ("user_id");



CREATE INDEX "products_history_changed_at_idx" ON "public"."products_history" USING "btree" ("changed_at" DESC);



CREATE INDEX "products_history_product_id_idx" ON "public"."products_history" USING "btree" ("product_id");



CREATE INDEX "users_history_changed_at_idx" ON "public"."users_history" USING "btree" ("changed_at" DESC);



CREATE INDEX "users_history_user_id_idx" ON "public"."users_history" USING "btree" ("user_id");



CREATE INDEX "wishlists_product_id_idx" ON "public"."wishlists" USING "btree" ("product_id");



CREATE INDEX "wishlists_user_id_idx" ON "public"."wishlists" USING "btree" ("user_id");



CREATE OR REPLACE TRIGGER "orders_history_trigger" AFTER INSERT OR DELETE OR UPDATE ON "public"."orders" FOR EACH ROW EXECUTE FUNCTION "public"."log_orders_history"();



CREATE OR REPLACE TRIGGER "products_history_trigger" AFTER INSERT OR DELETE OR UPDATE ON "public"."products" FOR EACH ROW EXECUTE FUNCTION "public"."log_products_history"();



CREATE OR REPLACE TRIGGER "users_history_trigger" AFTER INSERT OR DELETE OR UPDATE ON "public"."users" FOR EACH ROW EXECUTE FUNCTION "public"."log_users_history"();



CREATE OR REPLACE TRIGGER "users_set_updated_at" BEFORE UPDATE ON "public"."users" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();



ALTER TABLE ONLY "public"."admins"
    ADD CONSTRAINT "admins_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."chat_messages"
    ADD CONSTRAINT "chat_messages_room_id_fkey" FOREIGN KEY ("room_id") REFERENCES "public"."chat_rooms"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."chat_room_members"
    ADD CONSTRAINT "chat_room_members_room_id_fkey" FOREIGN KEY ("room_id") REFERENCES "public"."chat_rooms"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."chat_room_members"
    ADD CONSTRAINT "chat_room_members_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."order_items"
    ADD CONSTRAINT "order_items_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "public"."orders"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."order_items"
    ADD CONSTRAINT "order_items_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id");



ALTER TABLE ONLY "public"."orders"
    ADD CONSTRAINT "orders_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."product_images"
    ADD CONSTRAINT "product_images_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."wishlists"
    ADD CONSTRAINT "wishlists_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."wishlists"
    ADD CONSTRAINT "wishlists_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



CREATE POLICY "Admin can manage images" ON "public"."product_images" TO "authenticated" USING (("auth"."uid"() = '3c597199-32aa-4ab7-b383-dae3b8fdebf5'::"uuid")) WITH CHECK (("auth"."uid"() = '3c597199-32aa-4ab7-b383-dae3b8fdebf5'::"uuid"));



CREATE POLICY "Admin can manage products" ON "public"."products" TO "authenticated" USING (("auth"."uid"() = '3c597199-32aa-4ab7-b383-dae3b8fdebf5'::"uuid")) WITH CHECK (("auth"."uid"() = '3c597199-32aa-4ab7-b383-dae3b8fdebf5'::"uuid"));



CREATE POLICY "Admin can read/update order items" ON "public"."order_items" TO "authenticated" USING (("auth"."uid"() = '3c597199-32aa-4ab7-b383-dae3b8fdebf5'::"uuid")) WITH CHECK (("auth"."uid"() = '3c597199-32aa-4ab7-b383-dae3b8fdebf5'::"uuid"));



CREATE POLICY "Admin can read/update orders" ON "public"."orders" TO "authenticated" USING (("auth"."uid"() = '3c597199-32aa-4ab7-b383-dae3b8fdebf5'::"uuid")) WITH CHECK (("auth"."uid"() = '3c597199-32aa-4ab7-b383-dae3b8fdebf5'::"uuid"));



CREATE POLICY "Only admins can view admin list" ON "public"."admins" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "id"));



CREATE POLICY "Public can create order items" ON "public"."order_items" FOR INSERT WITH CHECK (true);



CREATE POLICY "Public can create orders" ON "public"."orders" FOR INSERT WITH CHECK (true);



CREATE POLICY "Public can view images" ON "public"."product_images" FOR SELECT USING (true);



CREATE POLICY "Public can view products" ON "public"."products" FOR SELECT USING (true);



ALTER TABLE "public"."admins" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."chat_messages" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "chat_messages_insert" ON "public"."chat_messages" FOR INSERT TO "authenticated" WITH CHECK ((("sender_id" = "auth"."uid"()) AND ((EXISTS ( SELECT 1
   FROM "public"."chat_room_members"
  WHERE (("chat_room_members"."room_id" = "chat_messages"."room_id") AND ("chat_room_members"."user_id" = "auth"."uid"())))) OR (EXISTS ( SELECT 1
   FROM "public"."admins"
  WHERE ("admins"."id" = "auth"."uid"()))))));



CREATE POLICY "chat_messages_select" ON "public"."chat_messages" FOR SELECT TO "authenticated" USING (((EXISTS ( SELECT 1
   FROM "public"."chat_room_members"
  WHERE (("chat_room_members"."room_id" = "chat_messages"."room_id") AND ("chat_room_members"."user_id" = "auth"."uid"())))) OR (EXISTS ( SELECT 1
   FROM "public"."admins"
  WHERE ("admins"."id" = "auth"."uid"())))));



ALTER TABLE "public"."chat_room_members" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "chat_room_members_insert" ON "public"."chat_room_members" FOR INSERT TO "authenticated" WITH CHECK ((("user_id" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM "public"."admins"
  WHERE ("admins"."id" = "auth"."uid"())))));



CREATE POLICY "chat_room_members_select" ON "public"."chat_room_members" FOR SELECT USING ((("user_id" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM "public"."admins"
  WHERE ("admins"."id" = "auth"."uid"())))));



ALTER TABLE "public"."chat_rooms" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "chat_rooms_insert" ON "public"."chat_rooms" FOR INSERT TO "authenticated" WITH CHECK (true);



CREATE POLICY "chat_rooms_select" ON "public"."chat_rooms" FOR SELECT TO "authenticated" USING (((EXISTS ( SELECT 1
   FROM "public"."admins"
  WHERE ("admins"."id" = "auth"."uid"()))) OR (EXISTS ( SELECT 1
   FROM "public"."chat_room_members"
  WHERE (("chat_room_members"."room_id" = "chat_rooms"."id") AND ("chat_room_members"."user_id" = "auth"."uid"()))))));



CREATE POLICY "chat_rooms_update" ON "public"."chat_rooms" FOR UPDATE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."admins"
  WHERE ("admins"."id" = "auth"."uid"()))));



ALTER TABLE "public"."order_items" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."orders" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."orders_history" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "orders_history_select_for_admin" ON "public"."orders_history" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."admins"
  WHERE ("admins"."id" = "auth"."uid"()))));



CREATE POLICY "orders_select_own" ON "public"."orders" FOR SELECT USING (((( SELECT "auth"."uid"() AS "uid") = "user_id") OR ("user_id" IS NULL)));



CREATE POLICY "orders_update_own" ON "public"."orders" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") = "user_id")) WITH CHECK ((( SELECT "auth"."uid"() AS "uid") = "user_id"));



ALTER TABLE "public"."product_images" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."products" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."products_history" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "products_history_select_for_admin" ON "public"."products_history" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."admins"
  WHERE ("admins"."id" = "auth"."uid"()))));



ALTER TABLE "public"."users" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."users_history" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "users_history_select_for_admin" ON "public"."users_history" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."admins"
  WHERE ("admins"."id" = "auth"."uid"()))));



CREATE POLICY "users_select_for_admin" ON "public"."users" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."admins"
  WHERE ("admins"."id" = "auth"."uid"()))));



CREATE POLICY "users_select_own" ON "public"."users" FOR SELECT USING ((( SELECT "auth"."uid"() AS "uid") = "id"));



CREATE POLICY "users_update_own" ON "public"."users" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") = "id")) WITH CHECK ((( SELECT "auth"."uid"() AS "uid") = "id"));



ALTER TABLE "public"."wishlists" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "위시리스트 - 본인만 삭제" ON "public"."wishlists" FOR DELETE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "위시리스트 - 본인만 조회" ON "public"."wishlists" FOR SELECT USING (("auth"."uid"() = "user_id"));



CREATE POLICY "위시리스트 - 본인만 추가" ON "public"."wishlists" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));





ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";






ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."chat_messages";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."chat_room_members";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."chat_rooms";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."orders";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."product_images";



ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."products";



GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";






















































































































































REVOKE ALL ON FUNCTION "public"."accept_chat"("p_room_id" "uuid", "p_admin_id" "uuid") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."accept_chat"("p_room_id" "uuid", "p_admin_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."accept_chat"("p_room_id" "uuid", "p_admin_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."accept_chat"("p_room_id" "uuid", "p_admin_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."cancel_order"("p_order_id" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."cancel_order"("p_order_id" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."cancel_order"("p_order_id" bigint) TO "service_role";



GRANT ALL ON FUNCTION "public"."confirm_payment"("p_order_id" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."confirm_payment"("p_order_id" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."confirm_payment"("p_order_id" bigint) TO "service_role";



GRANT ALL ON FUNCTION "public"."create_order_with_stock_check"("p_customer_name" "text", "p_customer_phone" "text", "p_shipping_address" "text", "p_total_amount" bigint, "p_items" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."create_order_with_stock_check"("p_customer_name" "text", "p_customer_phone" "text", "p_shipping_address" "text", "p_total_amount" bigint, "p_items" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_order_with_stock_check"("p_customer_name" "text", "p_customer_phone" "text", "p_shipping_address" "text", "p_total_amount" bigint, "p_items" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_all_chat_rooms"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_all_chat_rooms"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_all_chat_rooms"() TO "service_role";



REVOKE ALL ON FUNCTION "public"."get_chat_rooms"() FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."get_chat_rooms"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_chat_rooms"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_chat_rooms"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_or_create_chat_room"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_or_create_chat_room"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_or_create_chat_room"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";



GRANT ALL ON FUNCTION "public"."log_orders_history"() TO "anon";
GRANT ALL ON FUNCTION "public"."log_orders_history"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."log_orders_history"() TO "service_role";



GRANT ALL ON FUNCTION "public"."log_products_history"() TO "anon";
GRANT ALL ON FUNCTION "public"."log_products_history"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."log_products_history"() TO "service_role";



GRANT ALL ON FUNCTION "public"."log_users_history"() TO "anon";
GRANT ALL ON FUNCTION "public"."log_users_history"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."log_users_history"() TO "service_role";



GRANT ALL ON FUNCTION "public"."rls_auto_enable"() TO "anon";
GRANT ALL ON FUNCTION "public"."rls_auto_enable"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."rls_auto_enable"() TO "service_role";



GRANT ALL ON FUNCTION "public"."set_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."set_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_updated_at"() TO "service_role";


















GRANT ALL ON TABLE "public"."admins" TO "anon";
GRANT ALL ON TABLE "public"."admins" TO "authenticated";
GRANT ALL ON TABLE "public"."admins" TO "service_role";



GRANT ALL ON TABLE "public"."chat_messages" TO "anon";
GRANT ALL ON TABLE "public"."chat_messages" TO "authenticated";
GRANT ALL ON TABLE "public"."chat_messages" TO "service_role";



GRANT ALL ON TABLE "public"."chat_room_members" TO "anon";
GRANT ALL ON TABLE "public"."chat_room_members" TO "authenticated";
GRANT ALL ON TABLE "public"."chat_room_members" TO "service_role";



GRANT ALL ON TABLE "public"."chat_rooms" TO "anon";
GRANT ALL ON TABLE "public"."chat_rooms" TO "authenticated";
GRANT ALL ON TABLE "public"."chat_rooms" TO "service_role";



GRANT ALL ON TABLE "public"."order_items" TO "anon";
GRANT ALL ON TABLE "public"."order_items" TO "authenticated";
GRANT ALL ON TABLE "public"."order_items" TO "service_role";



GRANT ALL ON SEQUENCE "public"."order_items_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."order_items_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."order_items_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."orders" TO "anon";
GRANT ALL ON TABLE "public"."orders" TO "authenticated";
GRANT ALL ON TABLE "public"."orders" TO "service_role";



GRANT ALL ON TABLE "public"."orders_history" TO "anon";
GRANT ALL ON TABLE "public"."orders_history" TO "authenticated";
GRANT ALL ON TABLE "public"."orders_history" TO "service_role";



GRANT ALL ON SEQUENCE "public"."orders_history_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."orders_history_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."orders_history_id_seq" TO "service_role";



GRANT ALL ON SEQUENCE "public"."orders_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."orders_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."orders_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."product_images" TO "anon";
GRANT ALL ON TABLE "public"."product_images" TO "authenticated";
GRANT ALL ON TABLE "public"."product_images" TO "service_role";



GRANT ALL ON SEQUENCE "public"."product_images_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."product_images_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."product_images_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."products" TO "anon";
GRANT ALL ON TABLE "public"."products" TO "authenticated";
GRANT ALL ON TABLE "public"."products" TO "service_role";



GRANT ALL ON TABLE "public"."products_history" TO "anon";
GRANT ALL ON TABLE "public"."products_history" TO "authenticated";
GRANT ALL ON TABLE "public"."products_history" TO "service_role";



GRANT ALL ON SEQUENCE "public"."products_history_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."products_history_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."products_history_id_seq" TO "service_role";



GRANT ALL ON SEQUENCE "public"."products_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."products_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."products_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."users" TO "anon";
GRANT ALL ON TABLE "public"."users" TO "authenticated";
GRANT ALL ON TABLE "public"."users" TO "service_role";



GRANT ALL ON TABLE "public"."users_history" TO "anon";
GRANT ALL ON TABLE "public"."users_history" TO "authenticated";
GRANT ALL ON TABLE "public"."users_history" TO "service_role";



GRANT ALL ON SEQUENCE "public"."users_history_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."users_history_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."users_history_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."wishlists" TO "anon";
GRANT ALL ON TABLE "public"."wishlists" TO "authenticated";
GRANT ALL ON TABLE "public"."wishlists" TO "service_role";



GRANT ALL ON SEQUENCE "public"."wishlists_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."wishlists_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."wishlists_id_seq" TO "service_role";









ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";































