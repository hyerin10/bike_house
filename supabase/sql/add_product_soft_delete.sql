-- products 소프트 삭제용 컬럼 추가 (1회 실행)
alter table public.products
add column if not exists is_deleted boolean not null default false;
