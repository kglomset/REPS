# Moving REPS to repstracker.no (home-lab Docker)

Goal: serve the app at `https://repstracker.no`, with the API reachable at
`https://repstracker.no/api` (same origin, so no CORS to manage). A Caddy
reverse proxy sits in front of the existing `frontend`, `backend`, and
`postgres` containers and terminates TLS with Let's Encrypt.

## 1. Point DNS at your home server (Norgesdomene)

Find your home connection's **public** IP: https://ifconfig.me

In the Norgesdomene control panel → **DNS** for `repstracker.no`, add these
records (click the edit/plus icon, pick the type, fill host + value, save):

| Type  | Host   | Value                | TTL  |
|-------|--------|----------------------|------|
| A     | @      | <your-public-IPv4>   | 3600 |
| CNAME | www    | repstracker.no.      | 3600 |
| AAAA  | @      | <your-public-IPv6>   | 3600 | (only if you have IPv6)

Notes:
- If your ISP gives you a **dynamic** IP, the A record will break when the IP
  changes. Norgesdomene has no documented Dynamic-DNS update API, so either use a
  third-party DDNS host (e.g. DuckDNS/DNSExit) as a CNAME target, or use a
  Cloudflare Tunnel (below), which sidesteps IP changes entirely.
- If you're behind **CGNAT** (common on mobile/fiber plans — your router's WAN IP
  differs from ifconfig.me), port-forwarding won't work. Use a Cloudflare Tunnel
  or Tailscale Funnel instead. Ask and I'll set that path up.

## 2. Forward ports on your router

Forward **TCP 80** and **TCP 443** from the router to the home-lab server's LAN IP.
Port 80 is required for Let's Encrypt's HTTP challenge; 443 serves the site.
Do **not** forward 8080, 3000, or 5432 — those stay LAN-only.

## 3. Deploy the reverse proxy

Two new files are in the repo:
- `deploy/Caddyfile` — routing + auto-TLS
- `docker-compose.prod.yml` — adds the Caddy service and bakes the API URL

Pull the latest and bring the stack up:

```bash
cd REPS
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build
```

The `--build` is important: `EXPO_PUBLIC_API_URL` is compiled into the web bundle,
so the frontend image must be rebuilt for the new domain to take effect.

## 4. Verify

```bash
# Cert issued + site loads
curl -I https://repstracker.no

# API reachable through the proxy
curl https://repstracker.no/api/actuator/health   # -> {"status":"UP"}
```

Then open https://repstracker.no in a browser, register/login, and confirm
network calls hit `repstracker.no/api` (DevTools → Network).

## Rollback

`docker compose -f docker-compose.yml -f docker-compose.prod.yml down` removes
Caddy; the old direct-port access still works. DNS/router changes are reversible
independently.
