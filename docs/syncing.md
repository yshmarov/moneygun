# Syncing with Parent Repository

This project is forked from the main [Moneygun](https://github.com/yshmarov/moneygun) repository.

## Setup Upstream Remote (One-time)

If you haven't set up the upstream remote yet:

```bash
git remote add upstream https://github.com/yshmarov/moneygun.git
```

## How to Sync Changes

1. **Fetch latest changes from parent repo:**

   ```bash
   git fetch upstream
   ```

2. **Merge changes into your current branch:**

   ```bash
   git merge upstream/main
   ```

3. **Push merged changes to your fork:**
   ```bash
   git push origin main
   ```

## Git Remotes

- `upstream` - Parent repository (yshmarov/moneygun)
- `origin` - Your fork (superails/moneygun-audioclub)
- `heroku` - Deployment target

## Quick Sync Command

```bash
git fetch upstream && git merge upstream/main && git push origin main
```
