-- Run this script in Supabase Dashboard > SQL Editor.
-- It creates the shared work register and basic resident/builder access rules.

create table if not exists public.handover_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  role text not null default 'owner' check (role in ('owner','builder')),
  display_name text,
  created_at timestamptz not null default now()
);

create table if not exists public.handover_tasks (
  id uuid primary key default gen_random_uuid(),
  area_type text not null check (area_type in ('flat','common')),
  flat_number text,
  location text not null,
  title text not null,
  details text,
  reported_by text not null,
  reporter_email text,
  status text not null default 'pending' check (status in ('pending','done')),
  created_by uuid not null default auth.uid() references auth.users(id),
  created_at timestamptz not null default now(),
  completed_at timestamptz,
  constraint flat_number_required check (
    (area_type = 'flat' and flat_number is not null and flat_number ~ '^[1-6]0[1-4]$')
    or (area_type = 'common' and flat_number is null)
  )
);

alter table public.handover_profiles enable row level security;
alter table public.handover_tasks enable row level security;

drop policy if exists "Users can read own profile" on public.handover_profiles;
create policy "Users can read own profile" on public.handover_profiles
for select to authenticated using (id = auth.uid());

drop policy if exists "Users can create own owner profile" on public.handover_profiles;
create policy "Users can create own owner profile" on public.handover_profiles
for insert to authenticated with check (id = auth.uid() and role = 'owner');

drop policy if exists "Authenticated users can read tasks" on public.handover_tasks;
create policy "Authenticated users can read tasks" on public.handover_tasks
for select to authenticated using (true);

drop policy if exists "Authenticated users can add tasks" on public.handover_tasks;
create policy "Authenticated users can add tasks" on public.handover_tasks
for insert to authenticated with check (created_by = auth.uid());

drop policy if exists "Builders can update task status" on public.handover_tasks;
create policy "Builders can update task status" on public.handover_tasks
for update to authenticated
using (exists (select 1 from public.handover_profiles p where p.id = auth.uid() and p.role = 'builder'))
with check (exists (select 1 from public.handover_profiles p where p.id = auth.uid() and p.role = 'builder'));

-- New users get an owner profile automatically.
create or replace function public.create_handover_profile()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.handover_profiles (id, role)
  values (new.id, 'owner')
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created_handover on auth.users;
create trigger on_auth_user_created_handover
after insert on auth.users
for each row execute procedure public.create_handover_profile();

grant usage on schema public to authenticated;
grant select, insert on public.handover_profiles to authenticated;
grant select, insert, update on public.handover_tasks to authenticated;
