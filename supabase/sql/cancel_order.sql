-- 주문 취소 + 재고 복원을 단일 트랜잭션으로 처리하는 RPC
-- Supabase SQL Editor에서 그대로 실행 가능합니다.

create or replace function public.cancel_order(p_order_id bigint)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
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

comment on function public.cancel_order(bigint)
is '주문 취소(status → cancelled) 및 재고 복원을 단일 트랜잭션으로 처리';
