# Deploying REPS at repstracker.no (home-lab Docker + host nginx)

This is the setup that's actually live. The app is served at
`https://repstracker.no`, API at `https://repstracker.no/api` (same origin, no
CORS). The whole stack is one `docker-compose.yml`; **host nginx** (systemd,
not containerized) terminates TLS and reverse-proxies to the containers.

Division of labour:
- **Domeneshop** — DNS (name -> IP) and the DNS-01 cert challenge.
- **host nginx** — TLS termination + routing on the box.
- **certbot** — issues/renews the cert via the Domeneshop DNS-01 plugin.

> Why DNS-01 and not the usual webroot/HTTP-01: inbound **port 80 is not
> reachable** on this connection (router/ISP block), so HTTP-01 times out.
> DNS-01 proves ownership via a TXT record through the Domeneshop API and needs
> no inbound ports at all.

## 1. DNS records (Domeneshop -> DNS)

| Type  | Host | Value              | Note                              |
|-------|------|--------------------|-----------------------------------|
| A     | @    | <your public IPv4> | seed value; ddns keeps it current |
| CNAME | www  | repstracker.no.    | redirected to apex by nginx       |

If the home IP is dynamic, run the `ddns` profile (step 5) to keep the A record
synced via Domeneshop's DDNS API.

## 2. Install the Domeneshop DNS-01 plugin + credentials

```bash
sudo pip install certbot-dns-domeneshop --break-system-packages

sudo mkdir -p /etc/letsencrypt/secrets
sudo tee /etc/letsencrypt/secrets/domeneshop.ini >/dev/null <<'INI'
dns_domeneshop_client_token=YOUR_TOKEN
dns_domeneshop_client_secret=YOUR_SECRET
INI
sudo chmod 600 /etc/letsencrypt/secrets/domeneshop.ini
```

Token/secret come from the Domeneshop API panel
(https://www.domeneshop.no/admin?view=api). If issuance later returns
`401 authentication:failed`, test the creds directly:
`curl -s -o /dev/null -w "%{http_code}\n" -u "TOKEN:SECRET" https://api.domeneshop.no/v0/domains`
(200 = good). Check for a token IP-restriction that excludes this server.

## 3. Issue the certificate (DNS-01)

```bash
sudo certbot certonly \
  --authenticator dns-domeneshop \
  --dns-domeneshop-credentials /etc/letsencrypt/secrets/domeneshop.ini \
  --dns-domeneshop-propagation-seconds 120 \
  -d repstracker.no -d www.repstracker.no
```

Pauses ~120s for the TXT record to propagate, then validates. No nginx or
port-80 involvement.

## 4. Install the nginx site (two-phase, because of the cert bootstrap)

`deploy/repstracker.no.nginx.conf` ships with the two `443` server blocks
**commented out** so nginx can load before the cert exists. Since we issue the
cert in step 3 first, you can uncomment them immediately — but the order that
matters is: **cert must exist before any `ssl_certificate` line is active**, or
nginx fails with `[emerg] cannot load certificate`.

```bash
sudo cp deploy/repstracker.no.nginx.conf /etc/nginx/sites-available/repstracker.no
sudo ln -sf /etc/nginx/sites-available/repstracker.no /etc/nginx/sites-enabled/
# uncomment the two 443 server blocks in that file now that the cert exists
sudo nginx -t && sudo systemctl reload nginx
```

It proxies `/api/*` -> `127.0.0.1:8080` (Spring context-path `/api`, prefix kept)
and everything else -> `127.0.0.1:3000` (frontend container).

> Retiring an old domain (e.g. a previous DuckDNS host)? Delete its cert
> (`sudo certbot delete --cert-name <old>`) AND remove its nginx site from
> sites-enabled — otherwise nginx `[emerg]`s on the now-missing old cert, and
> `certbot renew` keeps trying to renew a cert whose HTTP-01 path is dead.

## 5. Build + start the stack

```bash
cd REPS
# set EXPO_PUBLIC_API_URL=https://repstracker.no/api (and Domeneshop creds) in .env
docker compose --profile ddns up -d --build      # dynamic IP: includes DDNS
# or, static IP:
docker compose up -d --build
```

`--build` matters: `EXPO_PUBLIC_API_URL` is compiled into the web bundle, so the
frontend image must be rebuilt for the new domain to take effect.

## 6. Auto-reload nginx on renewal (one-time)

`certbot renew` renews the cert but does NOT reload nginx, so add a deploy hook:

```bash
sudo mkdir -p /etc/letsencrypt/renewal-hooks/deploy
echo -e '#!/bin/sh\nsystemctl reload nginx' \
  | sudo tee /etc/letsencrypt/renewal-hooks/deploy/reload-nginx.sh
sudo chmod +x /etc/letsencrypt/renewal-hooks/deploy/reload-nginx.sh
```

Renewal itself is handled by the existing certbot cron; the DNS-01 method and
credentials path are recorded in the cert's renewal config.

## 7. Verify

```bash
sudo certbot certificates                          # repstracker.no present, dns-domeneshop
sudo certbot renew --dry-run                        # succeeds for repstracker.no
docker compose logs -f ddns                         # "ddns ok -> <ip>" (if using ddns)
curl -I https://repstracker.no                      # 200, valid cert
curl https://repstracker.no/api/actuator/health     # {"status":"UP"}
```

Then open https://repstracker.no, log in, and confirm the Network tab shows
calls to `repstracker.no/api`.
