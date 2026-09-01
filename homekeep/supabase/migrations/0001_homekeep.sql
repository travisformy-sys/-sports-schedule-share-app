create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  plan text not null default 'free' check (plan in ('free','plus')),
  created_at timestamptz not null default now()
);

create table if not exists public.households (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null default 'My Home',
  created_at timestamptz not null default now()
);

create table if not exists public.household_members (
  household_id uuid not null references public.households(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null default 'member' check (role in ('owner','member')),
  primary key (household_id,user_id)
);

create table if not exists public.maintenance_tasks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  household_id uuid references public.households(id) on delete cascade,
  name text not null check (char_length(name) between 1 and 100),
  category text not null default 'Other',
  due_date date not null,
  repeat_days integer not null default 90 check (repeat_days between 1 and 3650),
  completed_at timestamptz,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.maintenance_history (
  id uuid primary key default gen_random_uuid(),
  task_id uuid not null references public.maintenance_tasks(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  completed_at timestamptz not null default now(),
  notes text
);

create table if not exists public.subscriptions (
  user_id uuid primary key references auth.users(id) on delete cascade,
  provider text,
  provider_customer_id text,
  provider_subscription_id text,
  status text not null default 'inactive',
  current_period_end timestamptz,
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.households enable row level security;
alter table public.household_members enable row level security;
alter table public.maintenance_tasks enable row level security;
alter table public.maintenance_history enable row level security;
alter table public.subscriptions enable row level security;

create policy "profiles_select_own" on public.profiles for select to authenticated using ((select auth.uid()) = id);
create policy "profiles_update_own" on public.profiles for update to authenticated using ((select auth.uid()) = id) with check ((select auth.uid()) = id);
create policy "tasks_select_own" on public.maintenance_tasks for select to authenticated using ((select auth.uid()) = user_id);
create policy "tasks_insert_own" on public.maintenance_tasks for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "tasks_update_own" on public.maintenance_tasks for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "tasks_delete_own" on public.maintenance_tasks for delete to authenticated using ((select auth.uid()) = user_id);
create policy "history_select_own" on public.maintenance_history for select to authenticated using ((select auth.uid()) = user_id);
create policy "history_insert_own" on public.maintenance_history for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "subscriptions_select_own" on public.subscriptions for select to authenticated using ((select auth.uid()) = user_id);
create policy "households_owner_all" on public.households for all to authenticated using ((select auth.uid()) = owner_id) with check ((select auth.uid()) = owner_id);
create policy "members_select_related" on public.household_members for select to authenticated using ((select auth.uid()) = user_id);

grant usage on schema public to authenticated;
grant select, insert, update, delete on public.maintenance_tasks to authenticated;
grant select, insert on public.maintenance_history to authenticated;
grant select, update on public.profiles to authenticated;
grant select on public.subscriptions to authenticated;
grant select, insert, update, delete on public.households to authenticated;
grant select on public.household_members to authenticated;
