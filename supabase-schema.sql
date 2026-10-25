-- PUBLIC / NO-LOGIN configuration for the Society Handover Tracker.
-- Run this in Supabase Dashboard > SQL Editor.
-- WARNING: anyone who has the site URL can read, add, and update all work items.

create table if not exists public.handover_tasks (
  id uuid primary key default gen_random_uuid(),
  area_type text not null check (area_type in ('flat','common')),
  flat_number text,
  location text not null,
  title text not null check (length(trim(title)) > 0 and length(title) <= 2000),
  details text,
  reported_by text not null check (length(trim(reported_by)) > 0),
  reporter_email text,
  status text not null default 'pending' check (status in ('pending','done')),
  created_by uuid null,
  created_at timestamptz not null default now(),
  completed_at timestamptz,
  constraint flat_number_required check (
    (area_type = 'flat' and flat_number is not null and flat_number ~ '^[1-6]0[1-4]$')
    or (area_type = 'common' and flat_number is null)
  )
);

-- If this script is being applied to a table created by the previous login-based version:
alter table public.handover_tasks alter column created_by drop not null;
alter table public.handover_tasks alter column created_by drop default;

alter table public.handover_tasks enable row level security;

drop policy if exists "Authenticated users can read tasks" on public.handover_tasks;
drop policy if exists "Authenticated users can add tasks" on public.handover_tasks;
drop policy if exists "Builders can update task status" on public.handover_tasks;
drop policy if exists "Anyone can read handover tasks" on public.handover_tasks;
drop policy if exists "Anyone can add handover tasks" on public.handover_tasks;
drop policy if exists "Anyone can update handover tasks" on public.handover_tasks;

create policy "Anyone can read handover tasks"
on public.handover_tasks for select to anon, authenticated using (true);

create policy "Anyone can add handover tasks"
on public.handover_tasks for insert to anon, authenticated
with check (
  area_type in ('flat','common')
  and length(trim(reported_by)) > 0
  and length(trim(title)) > 0
  and status = 'pending'
);

create policy "Anyone can update handover tasks"
on public.handover_tasks for update to anon, authenticated
using (true)
with check (area_type in ('flat','common') and status in ('pending','done'));

grant usage on schema public to anon, authenticated;
grant select, insert, update on public.handover_tasks to anon, authenticated;

-- Enable Realtime so changes made by one visitor appear for other visitors.
-- If this reports that the table is already in the publication, you can ignore that notice.
do $$
begin
  alter publication supabase_realtime add table public.handover_tasks;
exception
  when duplicate_object then null;
  when undefined_object then raise notice 'supabase_realtime publication not found; enable Realtime for handover_tasks in the Supabase dashboard.';
end $$;
