-- orders 테이블 변경 이력(orders_history) 및 자동 기록 트리거

create table if not exists public.orders_history (
  id bigint generated always as identity primary key,
  order_id bigint not null,
  action text not null check (action in ('INSERT', 'UPDATE', 'DELETE')),
  old_data jsonb,
  new_data jsonb,
  changed_at timestamptz not null default now()
);

create index if not exists orders_history_order_id_idx
  on public.orders_history (order_id);

create index if not exists orders_history_changed_at_idx
  on public.orders_history (changed_at desc);

comment on table public.orders_history is 'public.orders 테이블 INSERT/UPDATE/DELETE 변경 이력';
comment on column public.orders_history.order_id is '변경된 orders.id';
comment on column public.orders_history.action is 'INSERT, UPDATE, DELETE';
comment on column public.orders_history.old_data is '변경 전 전체 row (JSONB)';
comment on column public.orders_history.new_data is '변경 후 전체 row (JSONB)';

create or replace function public.log_orders_history()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
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

drop trigger if exists orders_history_trigger on public.orders;

create trigger orders_history_trigger
  after insert or update or delete on public.orders
  for each row
  execute function public.log_orders_history();

alter table public.orders_history enable row level security;

drop policy if exists orders_history_select_for_admin on public.orders_history;

create policy orders_history_select_for_admin
  on public.orders_history
  for select
  to authenticated
  using (
    exists (
      select 1
      from public.admins
      where admins.id = auth.uid()
    )
  );
