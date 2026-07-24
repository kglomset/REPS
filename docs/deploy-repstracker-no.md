# Deploying REPS at repstracker.no (home-lab Docker + host nginx)

The app is served at `https://repstracker.no`, API at `https://repstracker.no/api`
(same origin, no CORS). Your existing **host nginx** terminates TLS and reverse-
proxies to the containers; your existing cron renews the cert. A small `ddns`
container keeps the apex `A` record synced with your home IP via Domeneshop.

TLS + routing = nginx (already yours). DNS + DDNS = Domeneshop. No Caddy needed.

## 1. Domeneshop API token (for DDNS)

Domeneshop control panel -> API (https://www.domeneshop.no/admin?view=api) ->
create a token. Put the token/secret in `.env` (gitignored):

```
DOMENESHOP_TOKEN=xxxx
DOMENESHOP_SECRET=xxxx
DDNS_HOSTNAME=repstracker.no
```

If your home IP is static, skip this and just don't pass `--profile ddns`.

## 2. DNS records (Domeneshop -> DNS)

| Type  | Host | Value              | Note                              |
|-------|------|--------------------|-----------------------------------|
| A     | @    | <your public IPv4> | seed value; ddns keeps it current |
| CNAME | www  | repstracker.no.    | redirected to apex by nginx      |

## 3. TLS certificate for the new domain

Add `repstracker.no` (and `www.`) to your renewal script / certbot so the cert
covers it, e.g. with certbot:

```bash
certbot certonly --webroot -w /var/www/certbot -d repstracker.no -d www.repstracker.no
```

Point the `ssl_certificate*` paths in the nginx config at whatever your script
writes.

## 4. nginx server block

Install `deploy/repstracker.no.nginx.conf`:

```bash
sudo cp deploy/repstracker.no.nginx.conf /etc/nginx/sites-available/repstracker.no
sudo ln -s /etc/nginx/sites-available/repstracker.no /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
```

It proxies `/api/*` to `127.0.0.1:8080` (Spring context-path `/api`) and
everything else to `127.0.0.1:3000` (the frontend container).

## 5. Rebuild + start the containers

```bash
cd REPS
docker compose --profile ddns up -d --build      # include ddns (dynamic IP)
# or, if your IP is static:
docker compose up -d --build
```

`--build` matters: `EXPO_PUBLIC_API_URL` (set in `.env`) is compiled into the
web bundle. The `--profile ddns` flag is what starts the DDNS updater; omit it
to leave it out.

## 6. Verify

```bash
docker compose logs -f ddns                       # "ddns ok -> <ip>"
curl -I https://repstracker.no                    # cert OK, 200
curl https://repstracker.no/api/actuator/health   # {"status":"UP"}
```

Open https://repstracker.no, log in, and confirm the Network tab shows calls to
`repstracker.no/api`.

> Note: everything is one `docker-compose.yml` now — the old
> `docker-compose.prod.yml` and `deploy/Caddyfile` drafts are unused; delete them.
