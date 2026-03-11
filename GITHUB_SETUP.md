# Push VivinoApp to GitHub: Prowein x Vivino 2026

Push **this folder** (VivinoApp only) to a new repo on your personal GitHub.

## 1. Create the new repo on GitHub

1. Go to [github.com/new](https://github.com/new).
2. **Repository name**: `prowein-vivino-2026` (or `Prowein-x-Vivino-2026`).
3. **Description** (optional): `Prowein 2026 × Vivino — iOS app`.
4. Choose **Private** or Public.
5. Do **not** add README, .gitignore, or license — this project already has them.
6. Click **Create repository**.

## 2. Initialize git and push (run from the VivinoApp folder)

In Terminal, run **each command separately** (the `-A` is only for `git add`, not `git init`):

```bash
cd "/Users/alexis/Vivino/Cursor Env/VivinoApp"
```

```bash
rm -rf .git
```

```bash
git init
```

```bash
git add .
```

```bash
git commit -m "Initial commit: Prowein x Vivino 2026"
```

```bash
git branch -M main
```

```bash
git remote add origin https://github.com/YOUR_USERNAME/prowein-vivino-2026.git
```

(Replace `YOUR_USERNAME` with your GitHub username.)

```bash
git push -u origin main
```

If you use SSH instead of HTTPS, use this for the remote (and run the two commands separately):

```bash
git remote add origin git@github.com:YOUR_USERNAME/prowein-vivino-2026.git
```

```bash
git push -u origin main
```

Done. Only the **VivinoApp** folder is in the repo.
