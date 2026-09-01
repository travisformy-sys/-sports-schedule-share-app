create table if not exists public.home_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  home_type text not null default 'House',
  home_age text not null default '2000–2019',
  hvac text not null default 'Central HVAC',
  foundation text not null default 'Slab',
  water text not null default 'Municipal',
  wastewater text not null default 'Sewer',
  garage boolean not null default true,
  gutters boolean not null default true,
  fireplace boolean not null default false,
  pool boolean not null default false,
  irrigation boolean not null default false,
  water_softener boolean not null default false,
  generator boolean not null default false,
  solar boolean not null default false,
  ev_charger boolean not null default false,
  updated_at timestamptz not null default now()
);

alter table public.home_profiles enable row level security;

create policy "home_profiles_select_own" on public.home_profiles
for select to authenticated
using ((select auth.uid()) = user_id);

create policy "home_profiles_insert_own" on public.home_profiles
for insert to authenticated
with check ((select auth.uid()) = user_id);

create policy "home_profiles_update_own" on public.home_profiles
for update to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

grant select, insert, update on public.home_profiles to authenticated;

create index if not exists home_profiles_updated_at_idx on public.home_profiles(updated_at);
