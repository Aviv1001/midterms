# status-dashboard

Small Flask service that shows a status page and a couple of API endpoints. Runs in Docker, reverse-proxied by nginx on the host.

## Prerequisites

You need Linux (Ubuntu works), Docker with your user in the `docker` group, nginx installed, and sudo.

## Install

From the repo root, run:

```bash
sudo API_KEY=<your API key here> ./install.sh
```

That builds the image, runs the container bound to 127.0.0.1:5000, drops the nginx site config in place, disables the default site, checks the config with `nginx -t`, enables nginx at boot, and reloads it. After it finishes you can hit the service at `http://<host-ip>/`.

You can re-run the script any time. It stops and replaces what was there before.

## Endpoints

* `GET /` returns the static dashboard page.
* `GET /api/status` and `/api/v1/status` return `{status, hostname, version}` as JSON.
* `GET /api/secret` and `/api/v1/secret` need an `X-API-Key` header. Without it (or with a wrong value) you get 401. With the right one you get a JSON message.

Both the short and the v1 paths return the same response. The rewrite happens inside nginx, so callers never see a redirect.

## Environment variables

* `API_KEY` is required. No default; the service refuses to start without it.
* `VERSION` defaults to `1.0.0`. Reported in the status JSON.
* `PORT` controls the in-container listen port. `install.sh` hardcodes `PORT=5000` to match the host mapping, so it is effectively fixed for users of `install.sh`. The Flask app itself reads `PORT` (default `5000`) if you run the container manually.
