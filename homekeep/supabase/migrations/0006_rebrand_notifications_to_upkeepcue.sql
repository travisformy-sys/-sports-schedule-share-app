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
      case when due_date=local_today then 'This UpkeepCue task is due today.'
           when due_date>local_today then 'This UpkeepCue task is due in '||(due_date-local_today)||' day'||case when (due_date-local_today)=1 then '' else 's' end||'.'
           else 'This UpkeepCue task is '||(local_today-due_date)||' day'||case when (local_today-due_date)=1 then '' else 's' end||' overdue.' end body,
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

update public.notifications
set body = replace(body, 'HomeKeep', 'UpkeepCue')
where body like '%HomeKeep%';

revoke all on function public.generate_homekeep_notifications() from public, anon, authenticated;
grant execute on function public.generate_homekeep_notifications() to service_role;
