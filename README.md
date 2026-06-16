# cb-engines — ContentBug's open-source engine plugins (RunPod-deployable)

**OPEN-SOURCE ONLY.** No studio code, no client data, no secrets, no model weights. This repo holds the
engine workers we connect to RunPod via GitHub. Each engine is built from a pinned open upstream
(see `ENGINE-LOCK.md`); weights download at build time from HuggingFace. We pay GPU + storage only —
nothing rented, nothing per-call.

## Deploy status board

| Engine | What it does | Status | Endpoint |
|---|---|---|---|
| **Wan2.2 b-roll** | image→video b-roll | 🟢 **LIVE** on RunPod | `3wyawb8q3ewvwn` |
| **FLUX thumbs** | thumbnails/hero frames | 🟢 **LIVE** on RunPod | `yglc5ytmwvbbx2` |
| **cb-imagegen** | FLUX + **face-lock (PuLID)** styled hero frames | 🟡 **READY TO DEPLOY** (this repo) | — |
| Qwen-Image | Apache-2.0 image (sellable) | ⚪ needs handler+Dockerfile | — |
| Open-Sora | Sora-class open video | ⚪ needs handler+Dockerfile | — |
| HunyuanVideo-1.5 | light cinematic video | ⚪ needs handler+Dockerfile | — |
| LTX-Video | fast video | ⚪ needs handler+Dockerfile | — |

🟢 live · 🟡 one click from live · ⚪ source pinned, worker not written yet

## How to deploy an engine (GitHub → RunPod)
1. Push this repo to GitHub (engines-only — `.gitignore` blocks studio/secrets/weights).
2. RunPod → Serverless → **New Endpoint → Deploy from GitHub** → pick this repo → pick the engine folder.
3. RunPod reads that folder's `Dockerfile`, builds it, gives you an **endpoint ID**.
4. Paste the endpoint ID back → it gets wired into the studio's `~/.cb-env` (studio side, not here).

## What's the first deploy?
**cb-imagegen** — it adds PuLID **face-lock**, the missing piece that fixes the F-grade "blob face" problem.
Its `Dockerfile` builds on the proven `runpod/worker-comfyui:flux1-dev-fp8` base, so the model ships in the
image (no cold-start model-load failure). See `cb-imagegen/README.md` for first-build verification steps.

## Folders
- `cb-imagegen/` — deployable FLUX + face-lock worker (Dockerfile + ComfyUI workflow + .runpod hub config)
- `ogai-open-local/` — open model catalog + the `wan2gp→RunPod` routing pattern (MuAPI stripped)
- `ENGINE-LOCK.md` — pinned upstream commits + licenses
