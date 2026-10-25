# Society Handover Tracker

Responsive tracker for 24 flats (101–604) and common areas. Includes bulk entry (one issue per line), pending/done status, dashboard totals, search/filtering, and CSV export.

## Access model: no login

This version is configured so residents do not need an email or password. Anyone with the website link can view all entries, add work items, and change any item's status. This is convenient for a society handover tracker, but **the link is not private access control**: anyone who gets it can change the shared data. Share it only with the intended group and export a CSV backup periodically.

## Configure shared data with Supabase

1. Create a project at https://supabase.com/.
2. Open the project's SQL Editor and run the full `supabase-schema.sql` file.
3. Copy the Supabase Project URL and the publishable key (or legacy anon public key) from Project Settings / API Keys.
4. Open `index.html` in a code editor and set the two constants near the start of the script:
   ```js
   const SUPABASE_URL = "https://YOUR-PROJECT.supabase.co";
   const SUPABASE_ANON_KEY = "YOUR-PUBLISHABLE-OR-ANON-KEY";
   ```
   Use only the publishable/anon public key in browser code. **Never put a service_role or secret key in `index.html`.**
5. Upload `index.html` to the root of a GitHub repository. You may also include this SQL and README for reference.
6. In the repository, open Settings → Pages, choose Deploy from a branch, select `main` and `/ (root)`, and save. Wait for GitHub Pages to publish the site.
7. Open the published page on two devices and test: add an issue on one device and verify it appears on the other; change its status and verify that change syncs too.

## Notes

- Without Supabase URL/key, the page is in demo mode and saves data only in the current browser.
- Realtime updates are subscribed to `handover_tasks`. If changes do not appear automatically, check Supabase Database → Replication/Realtime and enable the table.
- This is intentionally open access. Public users can also change statuses, so there is no builder-only restriction in this option.
- Export CSV regularly as a backup. Avoid collecting sensitive personal information in issue descriptions.
