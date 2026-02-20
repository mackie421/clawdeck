# Deploy ClawDeck on Railway

This setup deploys a single shared ClawDeck instance on Railway so multiple users can access the same site URL.

## 1) Fork and connect repo
1. Fork this repository to your GitHub account/org.
2. In Railway, create a new project from that GitHub repo.

## 2) Add PostgreSQL
1. In the Railway project, add a PostgreSQL service.
2. In your web service Variables, set `DATABASE_URL` to `${{Postgres.DATABASE_URL}}`.

## 3) Set required variables
In the Railway web service, set:
- `RAILS_ENV=production`
- `RAILS_LOG_TO_STDOUT=true`
- `RAILS_SERVE_STATIC_FILES=true`
- `RAILS_MAX_THREADS=3`
- `WEB_CONCURRENCY=1`
- `DB_POOL=10`
- `RAILS_MASTER_KEY=<value from config/master.key>`
- `SECRET_KEY_BASE=<random 128+ char secret>`

Optional:
- `SOLID_QUEUE_IN_PUMA=1` (enable only after Solid Queue tables exist)
- `APP_HOST=<your domain or Railway public domain>`
- `ALLOWED_HOSTS=.up.railway.app`
- `GITHUB_CLIENT_ID=<oauth client id>`
- `GITHUB_CLIENT_SECRET=<oauth client secret>`

## 4) Domain
1. Generate a Railway domain (or add custom domain).
2. Set `APP_HOST` to that host (no trailing slash).

## 5) Deploy
Railway will build via Nixpacks and run:
- `bundle exec rails db:prepare db:migrate:cache db:migrate:queue db:migrate:cable && bundle exec puma -C config/puma.rb`

## 6) Invite collaborators
To let multiple people manage the deployment:
1. Project Settings -> Members
2. Invite teammates with the required role

## 7) Multi-user behavior note
ClawDeck supports many accounts on one deployment.
Current app behavior scopes boards/tasks per user account by default, so users do not automatically share the same board data.
