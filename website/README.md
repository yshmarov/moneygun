# Moneygun website

This is the main-domain marketing-site skeleton. The Rails application runs on an application subdomain.

## Local development

`bin/dev` starts both surfaces:

- Website: http://localhost:4000
- Rails application: http://localhost:3000

To run only the website:

```bash
cd website
hugo server --config hugo.yaml,hugo.dev.yaml --port 4000
```

## Customize

1. Replace the product copy in `content/_index.md`.
2. Set the production main domain in `hugo.yaml` under `baseURL`.
3. Set the Rails application origin in `hugo.yaml` under `params.app.url`.
4. Replace the logo, favicon, and social image in `static/`.
5. Add legal or content pages only when the product needs them; the starting website intentionally remains a one-pager.

Keep the two origins separate: `https://example.com` is the public website and `https://app.example.com` is the authenticated Rails application.

## Verify

```bash
cd website
bin/check
```

The check performs a production Hugo build and verifies the expected page, SEO, and application handoff artifacts.
