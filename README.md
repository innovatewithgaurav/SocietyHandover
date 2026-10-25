# Society Handover Tracker

Responsive handover work tracker for 24 flats (101–604) and common areas. Supports adding multiple issues at once (one issue per line), pending/done status, dashboard totals, search/filtering, and CSV export.

## Demo mode
Open `index.html` in a browser. Without Supabase configuration, demo data is saved only in that browser on that device. It is not shared between residents.

## Enable shared use with Supabase
1. Create a project at https://supabase.com/.
2. In Supabase SQL Editor, run the entire `supabase-schema.sql` file.
3. Copy the project URL and publishable/anon public key from the Supabase project settings.
4. Open `index.html` in a code editor and find:
   ```js
   const SUPABASE_URL = "";
   const SUPABASE_ANON_KEY = "";
   ```
   Paste your project URL and publishable/anon public key into those values. Never use a `service_role` or secret key in browser code.
5. In Supabase Authentication URL configuration, set the final GitHub Pages URL as Site URL and add it to Redirect URLs.
6. Ensure Email sign-in is enabled in Authentication providers.
7. Publish all three files (`index.html`, `supabase-schema.sql`, and `README.md`) to the root of a GitHub repository. In Settings → Pages, choose Deploy from a branch, branch `main`, folder `/ (root)`, then Save.
8. Open the published site and sign in using the email sign-in link.

## Give builder access
1. Have the builder sign in once.
2. In Supabase → Authentication → Users, copy the builder's user UID.
3. In SQL Editor, run this query after replacing the placeholder with the real UID:
   ```sql
   update public.handover_profiles
   set role = 'builder'
   where id = 'PASTE-BUILDER-USER-UUID-HERE';
   ```
4. Have the builder refresh or sign in again. Builder role can update work status; resident role cannot.

## Before sharing
Test with two resident accounts and one builder account. Verify shared visibility, resident restrictions, builder status updates, and persistence after refresh. Keep the public key only; never publish a service-role/secret key.
