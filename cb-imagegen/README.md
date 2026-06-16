# cb-imagegen — Content Bug styled-image engine (FLUX + face-lock)

Our OWN RunPod serverless image engine. Generates premium **styled hero frames** (cinematic / 3D / cartoon / lifestyle / realistic / vlog…) from a prompt — optionally with a **client's face locked in** (PuLID). These hero frames feed the **image→video** b-roll pipeline.

**Why we built it:** the third-party A1111 Hub endpoint failed cold (`NoneType.lowvram` — model not loaded on new workers). This image **bakes FLUX into the container** (built on the proven `runpod/worker-comfyui:…-flux1-dev-fp8` base), so cold workers have the model instantly = **reliable**. We only add the face-lock nodes on top.

## Deploy (you do this — I'm walled off from creating RunPod infra)
1. Push this folder to a GitHub repo (e.g. `contentbugvideoediting/cb-imagegen`).
2. RunPod → Serverless → **link the repo** (same flow as HunyuanVideo-Avatar) → it builds the Dockerfile.
3. Select GPU **24GB (ADA_24)**, Min workers **0**, Max **3** → Create.
4. Paste me the **endpoint ID** → I wire it into content-studio as the image engine.

## API (ComfyUI worker contract)
`POST /run` with `{"input":{"workflow": <workflows/flux_txt2img.json with {prompt}/{width}/{height}/{seed} filled>}}` → returns the generated image(s). content-studio fills the template via `resolver.js` (the same prompt that drives previews + real assets).

## ⚠️ FIRST-BUILD VERIFICATION (honest — these may need a fix on the first deploy)
A from-scratch GPU image normally takes 1–3 iterations. On the **first** RunPod build, check the build/run logs for:
1. **Custom-node git clones** succeeded (PuLID-Flux, InstantID, IPAdapter). If a repo URL changed, update the Dockerfile.
2. **Model filenames** in `workflows/flux_txt2img.json` (`flux1-dev-fp8.safetensors`, `t5xxl_fp8_e4m3fn.safetensors`, `clip_l.safetensors`, `ae.safetensors`) **match the actual files** in the base image's `/comfyui/models`. If ComfyUI says "model not found," list `/comfyui/models/**` and correct the names.
3. **PuLID weight download** succeeded (else face-lock is disabled; plain FLUX still works).

**Phase 1 = plain FLUX styled images (reliable, the foundation). Phase 2 = add the PuLID face-lock workflow (`flux_pulid.json`) once FLUX is confirmed working.** Get the reliable foundation first, then layer face-lock.
