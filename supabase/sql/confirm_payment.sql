-- 입금 확인(status → paid)을 단일 트랜잭션으로 처리하는 RPC
-- Supabase SQL Editor에서 그대로 실행 가능합니다.

create or replace function public.confirm_payment(p_order_id bigint)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
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

comment on function public.confirm_payment(bigint)
is '입금 확인(status → paid)을 단일 트랜잭션으로 처리';
