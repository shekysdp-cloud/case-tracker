# Case Tracker

A single-file dashboard for tracking legal matters, deadlines, clients, and related records. Front-end is plain HTML/JS (no build step). Data lives in Supabase (Postgres + Auth).

## Files in this repo

- `index.html` — the dashboard. Open it in a browser and it runs.
- `schema.sql` — database schema for Supabase. Run once in the SQL Editor.
- `README.md` — this file.

## Setup (once)

### 1. Create the Supabase database

1. In your Supabase project, go to **SQL Editor → New query**.
2. Paste the entire contents of `schema.sql`.
3. Click **Run**. You should see "Success. No rows returned."
4. Confirm in **Table Editor** that the 11 tables and 1 view have been created.

### 2. Point the dashboard at your project

Open `index.html` and find this block near the top (inside `<!-- CONFIG -->`):

```js
window.SUPABASE_URL  = "PASTE_YOUR_PROJECT_URL_HERE";
window.SUPABASE_ANON = "PASTE_YOUR_ANON_PUBLIC_KEY_HERE";
```

Get both values from Supabase → **Project Settings → API**:
- **Project URL** → paste as `SUPABASE_URL`
- **anon public key** → paste as `SUPABASE_ANON`

Never paste the `service_role` key here — it bypasses security.

### 3. Create your first user

1. In Supabase, go to **Authentication → Users → Add user → Create new user**.
2. Give yourself an email and password. Untick "Auto-confirm" if you want confirmation emails; ticking it lets you log in immediately.
3. Alternatively: open the dashboard, click "Create an account" on the login screen, and sign up.

### 4. Host it

Any of these work — the dashboard is static, so it deploys anywhere:

- **GitHub Pages**: repo → Settings → Pages → Deploy from branch (main, /root). Free.
- **Vercel**: import the GitHub repo, no config needed. Free tier is fine.
- **Cloudflare Pages**: same idea, free.
- **Local only**: open `index.html` directly in a browser. Works for personal use.

Whichever host you use, the Supabase URL and anon key are already baked into `index.html`, so no environment variables are needed at the host.

## Security notes

- **Authentication is real.** Supabase Auth is enforced by the database, not by front-end code.
- **Row Level Security is on.** The initial policy in `schema.sql` grants full access to any authenticated user. Once you know who your other users are, tighten policies (e.g. per-consultant, per-confidentiality). Section 15 of the spec doc has the reasoning.
- **The `anon` key is safe to commit.** It's meant to be public. RLS is what protects the data.
- **The `service_role` key must never appear in this file or the repo.** It bypasses RLS.

## Extending

- New dropdown values: add to the enum in `schema.sql` (`alter type ... add value ...`) *and* to the `OPTIONS` object in `index.html`.
- New fields: add the column in Supabase, add the field to the module's `fields` array in `index.html`, and to `columns` if you want it in the table view.
- Password-gated Excel export: needs a Supabase Edge Function that checks a password server-side and returns the file. Not built here — flag when ready to add.

## Modules

| Module | Table | Notes |
|---|---|---|
| Dashboard | (view only) | KPI cards + nearest deadlines + recent matters |
| Matters | `matters` | Core module; `confidentiality_level` field ready for future per-record access rules |
| Tasks | `tasks` | Feeds the calendar |
| Deadlines calendar | `tasks` | Month view, colour-coded by priority, overdue highlighted |
| Clients | `clients` | |
| Projects | `projects` | |
| Leads | `leads` | |
| Time & billing | `time_entries` | |
| Invoices | `invoices` | |
| Documents | `documents` | Conditional fields for legal-doc / policy types |
| Training & events | `training_events` | |
| Policy register | `policies` | |
| Legal documents | `legal_documents` | |
