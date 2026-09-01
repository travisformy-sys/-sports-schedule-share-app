alter table public.maintenance_tasks
  add column if not exists last_completed_at timestamptz;

update public.maintenance_tasks
set last_completed_at = completed_at,
    completed_at = null
where completed_at is not null
  and last_completed_at is null;

create or replace function public.complete_maintenance_task(p_task_id uuid)
returns table(next_due_date date, completed_on timestamptz)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
  v_task public.maintenance_tasks%rowtype;
  v_completed timestamptz := now();
  v_next_due date;
begin
  if v_user_id is null then
    raise exception 'Not authenticated';
  end if;

  select * into v_task
  from public.maintenance_tasks
  where id = p_task_id and user_id = v_user_id
  for update;

  if not found then
    raise exception 'Task not found';
  end if;

  insert into public.maintenance_history(task_id, user_id, completed_at, notes)
  values (v_task.id, v_user_id, v_completed, v_task.notes);

  v_next_due := current_date + v_task.repeat_days;

  update public.maintenance_tasks
  set due_date = v_next_due,
      last_completed_at = v_completed,
      completed_at = null
  where id = v_task.id;

  update public.notifications
  set read_at = coalesce(read_at, v_completed)
  where task_id = v_task.id and user_id = v_user_id and read_at is null;

  return query select v_next_due, v_completed;
end;
$$;

revoke all on function public.complete_maintenance_task(uuid) from public, anon;
grant execute on function public.complete_maintenance_task(uuid) to authenticated;
