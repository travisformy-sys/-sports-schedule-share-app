alter table public.home_profiles
  add column if not exists pets boolean not null default false;
