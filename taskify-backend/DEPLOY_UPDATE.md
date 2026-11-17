# TaskNest — Live Update Runbook (v10 → v14)

Use this when replacing a running production install with a newer build.
Branch: `testing_0.0.4` · commits: `3624580` + deploys.

---

## 0. What this release actually needs

### Database migrations (the only hard requirement)

| File | What it adds | Needed for |
|---|---|---|
| `migration_v10_projects.sql` | `projects`, `project_departments`, `project_members`, `project_observers`, `project_tasks`, `project_task_comments`, `project_task_logs` | Projects module |
| `migration_v11_project_tickets.sql` | `tickets.project_id` + index | Tickets on project board |
| `migration_v12_ticket_members.sql` | `ticket_members` table | Multi-assignee tasks |
| `migration_v13_ticket_archived.sql` | `tickets.archived_at` + partial index | Archive card |
| `migration_v14_task_number.sql` | `task_number_seq` + **renumbers existing project tickets** | ❌ never run on live |
| `migration_v14_task_number_sequence_only.sql` | `task_number_seq` only — **no ticket numbers touched** | ✅ run this on live |
| `migration_v7..v9` | outbox / disputes / catch-up columns | Only if never applied |

There is **no new migration for the “last moved by” work** — it reads
`project_task_logs`, which v10 already creates.

All of `v10→v13` are additive and re-runnable (`IF NOT EXISTS` / guarded
`UPDATE`).

> **Live ticket numbers are frozen.** Do **not** run
> `migration_v14_task_number.sql` on production — it rewrites
> `tickets.ticket_number` for every project-linked ticket to `UMP-TA-###`.
> Run `migration_v14_task_number_sequence_only.sql` instead: it only creates
> the `task_number_seq` sequence the API needs for *new* project tasks, sets it
> past the highest existing `UMP-TA-###` value, and leaves every existing
> ticket number untouched.

### Verify what is missing before touching anything (read-only)

```bash
cd taskify-backend

# Linux/macOS (loads .env.production for this process only)
NODE_ENV=production DOTENV_CONFIG_PATH=.env.production \
  node -r dotenv/config database/check_schema.js

# Windows PowerShell
$env:NODE_ENV='production'; $env:DOTENV_CONFIG_PATH='.env.production'
node -r dotenv/config database/check_schema.js
```

Output is `OK` / `MISSING` per table, column, sequence, index, plus the exact
migration command for anything missing. Or with psql:

```bash
psql "$DATABASE_URL" -f database/preflight_check.sql
```

> Gotcha: `database/db.js` only reads `.env`. If the server has
> `.env.production` but no `.env`, the preload above (`-r dotenv/config` with
> `DOTENV_CONFIG_PATH`) is required, otherwise the check connects to the wrong
> database.

---

## 1. Backup (do not skip)

```bash
pg_dump -Fc -h <host> -U <user> <db> > taskify_$(date +%Y%m%d_%H%M).dump
```

Their Windows helper: `taskify-backend/database/backup.ps1`.
Also copy the current server `taskify-backend/` folder and web root to a
`_backup_<date>` directory for rollback.

---

## 2. Apply migrations, in order

```bash
cd taskify-backend

# safer: one transaction per file, stop on first error
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 --single-transaction -f database/migration_v10_projects.sql
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 --single-transaction -f database/migration_v11_project_tickets.sql
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 --single-transaction -f database/migration_v12_ticket_members.sql
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 --single-transaction -f database/migration_v13_ticket_archived.sql
# live-safe: creates the sequence only, never touches existing ticket numbers
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 --single-transaction -f database/migration_v14_task_number_sequence_only.sql
```

Or the project runner (no implicit transaction — run one file at a time and
watch for errors):

```bash
node database/run_migration.js database/migration_v10_projects.sql
```

Re-run `check_schema.js` afterwards; it must print `✓ Schema complete`.

---

## 3. Deploy backend

1. Stop or keep the old process running until the new folder is ready.
2. Copy the backend **source**, but **not** `node_modules`, `logs`, `.env`,
   `.env.production`, `.env.development` (keep the server's own secrets).
3. Install dependencies on the server (OS-specific binaries: `bcrypt`,
   `ioredis`, etc.):

   ```bash
   npm ci --omit=dev
   ```

4. Restart with PM2:

   ```bash
   pm2 reload ecosystem.config.js --env production   # zero-downtime
   pm2 save
   pm2 status
   ```

5. Set `WORKERS` correctly (see “Known issues” — outbox duplication).

---

## 4. Deploy the Flutter web build — **check this first**

`lib/env.dart` currently has:

```dart
static bool isLive = false;   // -> http://localhost:5050/api/
```

`false` makes the **browser** call `localhost:5050`, i.e. the user's own PC.
The build in `build/web` (generated 2026-11-17) contains `localhost:5050`.
Before shipping a build, verify:

```bash
grep -c "localhost:5050" build/web/main.dart.js   # should be 0
```

If it is not 0, set `isLive = true`, rebuild, then copy:

```bash
flutter build web --release
# copy build/web/* to the web root (nginx/IIS/Firebase)
```

With `isLive = true`:
- API base = `/api/`
- Socket URL = `window.location.origin`

So the web server **must** reverse-proxy:

| Path | Target |
|---|---|
| `/api/*` | `http://127.0.0.1:5050` |
| `/socket.io/*` | `http://127.0.0.1:5050` **with WebSocket upgrade** |

nginx example:

```nginx
location /api/ {
    proxy_pass http://127.0.0.1:5050;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}

location /socket.io/ {
    proxy_pass http://127.0.0.1:5050;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $host;
    proxy_read_timeout 3600s;
}

location = /flutter_service_worker.js {
    add_header Cache-Control "no-cache, no-store, must-revalidate";
}
```

Users with the old build cached may need a hard refresh (or bump the build so
the service worker updates).

---

## 5. Environment checklist on the server

- `.env` **wins over** `.env.production` when both exist (dotenv does not
  override already-set vars, and `app.js` loads `.env` first). Keep only what
  you intend.
- Required: `DB_*`, `JWT_SECRET`, `PORT`, `NODE_ENV=production`.
- Optional but recommended: `REDIS_HOST`/`REDIS_PORT` (cache + BullMQ; without
  it the app falls back to in-memory, which is fine but per-worker).
- `RATE_LIMIT_MAX` (default 300/min).
- Do not reduce `DB_POOL_MAX` below workers × expected concurrency.

---

## 6. Post-deploy smoke tests

1. `GET /health` and `/api/health` return `ok` (from the public host).
2. Login with email + code users; verify token works.
3. Open two browsers (two departments), both sockets connected (`[Socket] User X connected` in logs).
4. Create a ticket → other department sees it live, notification row created.
5. Create a project, add member + observer:
   - member can drag a card, observer cannot;
   - card shows “Last moved by …”, timeline shows the actor.
6. Verify `/api/notifications` unread count and mark-as-read.
7. Check `event_outbox` drain:
   ```sql
   SELECT count(*) FROM event_outbox WHERE processed_at IS NULL;
   ```
   should stay near zero and *not* produce duplicate notification rows.
8. `pm2 logs tasknest-api --lines 100` — no migration/`JWT_SECRET` errors.

Rollback: restore the DB dump, put the previous backend folder back,
`pm2 reload`, restore the previous web root.

---

## 7. Known issues in this build (fix before/right after deploy)

These are not deployment blockers but are in the code being shipped:

1. **Duplicate outbox processing in cluster mode.** `socket.js:96` starts the
   outbox processor in every worker, and `getUnprocessedOutbox` has no
   `FOR UPDATE SKIP LOCKED` / claim step. With `WORKERS > 1`, the same outbox
   row can create duplicate notifications/toasts. Short-term: run with
   `WORKERS=1`; proper fix: atomic claim or start the processor in one process
   only.
2. **“Last moved by” shows the oldest log.** `projects.repository.js`
   `updateTask` takes `latest[0]` from `getTaskLogs`, which orders ascending.
   Query `ORDER BY created_at DESC LIMIT 1`.
3. **Project-linked ticket moves can 403.** `ProjectTaskBoard` moves tickets
   while ticket-module `_assertProjectTaskManager` / `isProjectTeamMember`
   still enforce ticket rules; align project-context authorization.
4. **No native Chrome notification is created.** Only in-app toasts exist;
   add `html.Notification(...)` on qualifying assigned/department events
   (and project-task events need notification rows + `notificationId`).
5. **Rate limiting behind a proxy.** `app.js` never sets `trust proxy`, so
   express-rate-limit sees the nginx/IIS IP and applies one shared bucket —
   add `app.set('trust proxy', 1)` when behind a reverse proxy.
