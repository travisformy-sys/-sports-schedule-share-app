create extension if not exists pgcrypto;

create schema if not exists private;

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  plan text not null default 'free' check (plan in ('free','plus')),
  created_at timestamptz not null default now()
);

create table public.households (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null default 'My Home' check (char_length(name) between 1 and 100),
  created_at timestamptz not null default now()
);

create table public.household_members (
  household_id uuid not null references public.households(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null default 'member' check (role in ('owner','member')),
  created_at timestamptz not null default now(),
  primary key (household_id,user_id)
);

create table public.maintenance_tasks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  household_id uuid references public.households(id) on delete cascade,
  name text not null check (char_length(name) between 1 and 100),
  category text not null default 'Other' check (char_length(category) between 1 and 50),
  due_date date not null,
  repeat_days integer not null default 90 check (repeat_days between 1 and 3650),
  completed_at timestamptz,
  notes text check (notes is null or char_length(notes) <= 2000),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.maintenance_history (
  id uuid primary key default gen_random_uuid(),
  task_id uuid not null references public.maintenance_tasks(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  completed_at timestamptz not null default now(),
  notes text check (notes is null or char_length(notes) <= 2000)
);

create table public.subscriptions (
  user_id uuid primary key references auth.users(id) on delete cascade,
  provider text,
  provider_customer_id text unique,
  provider_subscription_id text unique,
  status text not null default 'inactive',
  current_period_end timestamptz,
  updated_at timestamptz not null default now()
);

create index households_owner_id_idx on public.households(owner_id);
create index household_members_user_id_idx on public.household_members(user_id);
create index maintenance_tasks_user_id_idx on public.maintenance_tasks(user_id);
create index maintenance_tasks_household_id_idx on public.maintenance_tasks(household_id);
create index maintenance_tasks_due_date_idx on public.maintenance_tasks(due_date);
create index maintenance_history_user_id_idx on public.maintenance_history(user_id);
create index maintenance_history_task_id_idx on public.maintenance_history(task_id);

alter table public.profiles enable row level security;
alter table public.households enable row level security;
alter table public.household_members enable row level security;
alter table public.maintenance_tasks enable row level security;
alter table public.maintenance_history enable row level security;
alter table public.subscriptions enable row level security;

revoke all on table public.profiles from anon, authenticated;
revoke all on table public.households from anon, authenticated;
revoke all on table public.household_members from anon, authenticated;
revoke all on table public.maintenance_tasks from anon, authenticated;
revoke all on table public.maintenance_history from anon, authenticated;
revoke all on table public.subscriptions from anon, authenticated;

grant select on public.profiles to authenticated;
grant update(display_name) on public.profiles to authenticated;
grant select, insert, update, delete on public.households to authenticated;
grant select, insert, delete on public.household_members to authenticated;
grant select, insert, update, delete on public.maintenance_tasks to authenticated;
grant select, insert on public.maintenance_history to authenticated;
grant select on public.subscriptions to authenticated;

create policy profiles_select_own on public.profiles
for select to authenticated
using ((select auth.uid()) = id);

create policy profiles_update_own on public.profiles
for update to authenticated
using ((select auth.uid()) = id)
with check ((select auth.uid()) = id);

create policy households_owner_select on public.households
for select to authenticated
using ((select auth.uid()) = owner_id);
create policy households_owner_insert on public.households
for insert to authenticated
with check ((select auth.uid()) = owner_id);
create policy households_owner_update on public.households
for update to authenticated
using ((select auth.uid()) = owner_id)
with check ((select auth.uid()) = owner_id);
create policy households_owner_delete on public.households
for delete to authenticated
using ((select auth.uid()) = owner_id);

create policy household_members_select_self_or_owner on public.household_members
for select to authenticated
using (
  (select auth.uid()) = user_id
  or exists (
    select 1 from public.households h
    where h.id = household_id and h.owner_id = (select auth.uid())
  )
);
create policy household_members_owner_insert on public.household_members
for insert to authenticated
with check (
  exists (
    select 1 from public.households h
    where h.id = household_id and h.owner_id = (select auth.uid())
  )
);
create policy household_members_owner_delete on public.household_members
for delete to authenticated
using (
  role <> 'owner'
  and exists (
    select 1 from public.households h
    where h.id = household_id and h.owner_id = (select auth.uid())
  )
);

create policy tasks_select_own on public.maintenance_tasks
for select to authenticated
using ((select auth.uid()) = user_id);
create policy tasks_insert_own on public.maintenance_tasks
for insert to authenticated
with check ((select auth.uid()) = user_id);
create policy tasks_update_own on public.maintenance_tasks
for update to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);
create policy tasks_delete_own on public.maintenance_tasks
for delete to authenticated
using ((select auth.uid()) = user_id);

create policy history_select_own on public.maintenance_history
for select to authenticated
using ((select auth.uid()) = user_id);
create policy history_insert_own on public.maintenance_history
for insert to authenticated
with check (
  (select auth.uid()) = user_id
  and exists (
    select 1 from public.maintenance_tasks t
    where t.id = task_id and t.user_id = (select auth.uid())
  )
);

create policy subscriptions_select_own on public.subscriptions
for select to authenticated
using ((select auth.uid()) = user_id);

create or replace function private.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  new_household_id uuid;
begin
  insert into public.profiles(id) values(new.id);
  insert into public.households(owner_id, name)
  values(new.id, 'My Home')
  returning id into new_household_id;
  insert into public.household_members(household_id, user_id, role)
  values(new_household_id, new.id, 'owner');
  return new;
end;
$$;

revoke all on function private.handle_new_user() from public;

create or replace function private.touch_maintenance_updated_at()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

revoke all on function private.touch_maintenance_updated_at() from public;

create trigger maintenance_tasks_touch
before update on public.maintenance_tasks
for each row execute function private.touch_maintenance_updated_at();

create trigger on_auth_user_created
after insert on auth.users
for each row execute function private.handle_new_user();
