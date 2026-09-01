create table if not exists public.notification_settings (
  user_id uuid primary key references auth.users(id) on delete cascade,
  enabled boolean not null default true,
  days_before integer not null default 3 check (days_before between 0 and 30),
  remind_overdue boolean not null default true,
  timezone text not null default 'America/New_York',
  updated_at timestamptz not null default now()
);

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  task_id uuid references public.maintenance_tasks(id) on delete cascade,
  kind text not null check (kind in ('due_soon','due_today','overdue')),
  title text not null,
  body text not null,
  scheduled_for date not null,
  created_at timestamptz not null default now(),
  read_at timestamptz,
  unique(user_id, task_id, kind, scheduled_for)
);

create index if not exists notifications_user_unread_idx on public.notifications(user_id, read_at, scheduled_for desc);
create index if not exists notifications_task_idx on public.notifications(task_id);
alter table public.notification_settings enable row level security;
alter table public.notifications enable row level security;

create policy "users read own notification settings" on public.notification_settings for select to authenticated using ((select auth.uid()) = user_id);
create policy "users insert own notification settings" on public.notification_settings for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "users update own notification settings" on public.notification_settings for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "users read own notifications" on public.notifications for select to authenticated using ((select auth.uid()) = user_id);
create policy "users update own notifications" on public.notifications for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);

revoke insert, delete on public.notifications from authenticated;
grant select, update on public.notifications to authenticated;
grant select, insert, update on public.notification_settings to authenticated;

create or replace function public.generate_homekeep_notifications()
returns integer language plpgsql security definer set search_path = public as $$
declare inserted_count integer := 0;
begin
  insert into public.notification_settings(user_id)
  select distinct mt.user_id from public.maintenance_tasks mt where mt.user_id is not null
  on conflict (user_id) do nothing;

  with candidates as (
    select mt.id task_id, mt.user_id, mt.name, mt.due_date, ns.days_before, ns.remind_overdue, ns.timezone,
      ((now() at time zone ns.timezone)::date) local_today
    from public.maintenance_tasks mt join public.notification_settings ns on ns.user_id=mt.user_id
    where ns.enabled=true and mt.completed_at is null
  ), rows_to_add as (
    select user_id,task_id,
      case when due_date=local_today then 'due_today' when due_date>local_today then 'due_soon' else 'overdue' end kind,
      case when due_date=local_today then name||' is due today' when due_date>local_today then name||' is due soon' else name||' is overdue' end title,
      case when due_date=local_today then 'This HomeKeep task is due today.'
           when due_date>local_today then 'This HomeKeep task is due in '||(due_date-local_today)||' day'||case when (due_date-local_today)=1 then '' else 's' end||'.'
           else 'This HomeKeep task is '||(local_today-due_date)||' day'||case when (local_today-due_date)=1 then '' else 's' end||' overdue.' end body,
      local_today scheduled_for
    from candidates
    where due_date=local_today
       or (due_date>local_today and due_date<=local_today+days_before)
       or (remind_overdue and due_date<local_today and ((local_today-due_date) in (1,3,7,14) or (local_today-due_date)%7=0))
  )
  insert into public.notifications(user_id,task_id,kind,title,body,scheduled_for)
  select user_id,task_id,kind,title,body,scheduled_for from rows_to_add
  on conflict (user_id,task_id,kind,scheduled_for) do nothing;
  get diagnostics inserted_count=row_count;
  return inserted_count;
end;$$;

revoke all on function public.generate_homekeep_notifications() from public, anon, authenticated;
grant execute on function public.generate_homekeep_notifications() to service_role;
create extension if not exists pg_cron with schema extensions;
do $$ begin
  if not exists (select 1 from cron.job where jobname='homekeep-generate-reminders-hourly') then
    perform cron.schedule('homekeep-generate-reminders-hourly','15 * * * *','select public.generate_homekeep_notifications();');
  end if;
end $$;
