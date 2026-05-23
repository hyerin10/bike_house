-- users 테이블 변경 이력(users_history) 및 자동 기록 트리거

create table if not exists public.users_history (
  id bigint generated always as identity primary key,
  user_id uuid not null,
  action text not null check (action in ('INSERT', 'UPDATE', 'DELETE')),
  old_data jsonb,
  new_data jsonb,
  changed_at timestamptz not null default now()
);

create index if not exists users_history_user_id_idx
  on public.users_history (user_id);

create index if not exists users_history_changed_at_idx
  on public.users_history (changed_at desc);

comment on table public.users_history is 'public.users 테이블 INSERT/UPDATE/DELETE 변경 이력';
comment on column public.users_history.user_id is '변경된 users.id';
comment on column public.users_history.action is 'INSERT, UPDATE, DELETE';
comment on column public.users_history.old_data is '변경 전 전체 row (JSONB)';
comment on column public.users_history.new_data is '변경 후 전체 row (JSONB)';

create or replace function public.log_users_history()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
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

drop trigger if exists users_history_trigger on public.users;

create trigger users_history_trigger
  after insert or update or delete on public.users
  for each row
  execute function public.log_users_history();

alter table public.users_history enable row level security;

drop policy if exists users_history_select_for_admin on public.users_history;

create policy users_history_select_for_admin
  on public.users_history
  for select
  to authenticated
  using (
    exists (
      select 1
      from public.admins
      where admins.id = auth.uid()
    )
  );
