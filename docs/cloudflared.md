# Cloudflared Tunnels

Expose your localhost to the internet using Cloudflare tunnels.

## Installation

```bash
brew install cloudflared
```

## Quick Tunnel (Recommended for Development)

No setup required. Generates a temporary public URL instantly:

```bash
cloudflared tunnel --url http://localhost:3000
```

Output includes a URL like `https://random-words.trycloudflare.com` that tunnels to your local server.

## Named Tunnel (Persistent, Requires DNS)

For a permanent subdomain on a domain you own:

```bash
# One-time setup
cloudflared tunnel login                    # Authenticate with Cloudflare
cloudflared tunnel create mytunnel          # Create named tunnel

# Route to your domain (requires domain in Cloudflare)
cloudflared tunnel route dns mytunnel subdomain.yourdomain.com

# Run the tunnel
cloudflared tunnel run --url http://localhost:3000 mytunnel
cloudflared tunnel run --url http://localhost:3000 mytunnel
```

To delete a named tunnel:

```bash
cloudflared tunnel delete mytunnel
```

## Quick Tunnel vs Named Tunnel

| Feature  | Quick Tunnel       | Named Tunnel       |
| -------- | ------------------ | ------------------ |
| Setup    | None               | Login + DNS config |
| URL      | Random, temporary  | Your subdomain     |
| Use case | Local dev, testing | Staging, demos     |

**For local development, use quick tunnels.**

## Use Cases

- **Webhook testing** - Receive webhooks from external services (Stripe, GitHub, etc.)
- **Sharing work** - Share your local development with teammates or clients
- **Mobile testing** - Test your app on physical devices without deployment

## Stripe Webhook Testing

1. Start the tunnel:

   ```bash
   cloudflared tunnel --url http://localhost:3000
   ```

2. Copy the generated URL and configure it in Stripe Dashboard:
   - Go to Developers → Webhooks → Add endpoint
   - Enter: `https://your-tunnel-url.trycloudflare.com/webhooks/stripe`

3. Test webhook delivery from the Stripe Dashboard
