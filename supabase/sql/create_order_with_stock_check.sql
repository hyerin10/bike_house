-- 무통장 주문 생성 + 재고 차감을 단일 트랜잭션으로 처리하는 RPC
-- Supabase SQL Editor에서 그대로 실행 가능합니다.
-- 컬럼명이 프로젝트와 다르면 INSERT/UPDATE 구문의 컬럼명만 맞게 수정하세요.

create or replace function public.create_order_with_stock_check(
  p_customer_name text,
  p_customer_phone text,
  p_shipping_address text,
  p_total_amount bigint,
  p_items jsonb
)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
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

comment on function public.create_order_with_stock_check(text, text, text, bigint, jsonb)
is '주문 생성, 주문 상세 생성, 재고 차감을 단일 트랜잭션으로 처리';
