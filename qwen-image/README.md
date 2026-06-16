# cb-qwenimage — Qwen-Image styled-image engine (Apache-2.0, **sellable**)

Our second image engine. **Qwen-Image** (Alibaba) is **Apache-2.0**, so unlike FLUX.1-dev (non-commercial),
client work generated here is **legally sellable** — this is the commercial-safe image engine. It also has
the best text rendering of any open model (great for thumbnails with words). Runs the **8-step Lightning LoRA**
so GPU time is ~2.5× cheaper than full-step — better margins.

**Why baked-in models:** same reliability win as cb-imagegen — the Qwen-Image weights ship inside the image
(`FROM runpod/worker-comfyui:5.8.5-base` + model download at build), so cold workers never fail to load a model.

## Deploy (you do this — I'm walled off from creating RunPod infra)
1. The code is already in the `open-source` repo under `qwen-image/`.
2. RunPod → Serverless → **New Endpoint → Deploy from GitHub** → repo `open-source` → **set Dockerfile Path to `qwen-image/Dockerfile`**.
3. GPU **24GB (ADA_24)**, Min workers **0**, Max **3** → Create.
4. Paste me the **endpoint ID** → I wire it in as `RUNPOD_QWEN_ENDPOINT`.

## API (ComfyUI worker contract)
`POST /run` with `{"input":{"workflow": <workflows/qwen_txt2img.json with {prompt}/{width}/{height}/{seed} filled>}}`.
content-studio fills the template via `resolver.js` — the SAME prompt that drives previews + real assets.

## ⚠️ FIRST-BUILD VERIFICATION (honest — may need a tweak on first deploy)
1. **Model filenames** in `workflows/qwen_txt2img.json` (`qwen_image_fp8_e4m3fn`, `qwen_2.5_vl_7b_fp8_scaled`,
   `qwen_image_vae`) match the files downloaded by the Dockerfile. If ComfyUI says "model not found," list
   `/comfyui/models/**` and correct the names.
2. **Node names** match this ComfyUI version. Qwen-Image native nodes (`CLIPLoader type=qwen_image`,
   `ModelSamplingAuraFlow`, `EmptySD3LatentImage`) need a recent ComfyUI — `5.8.5-base` should have them.
   If a node is "unknown," check the official template: github.com/Comfy-Org/workflow_templates → `image_qwen_image`.
3. **Lightning LoRA** downloaded. If it 404'd at build, remove node `14` from the workflow and set node `13`
   to `steps: 20, cfg: 2.5` (full-step path still produces full quality, just slower/pricier).

**Phase 1 = plain Qwen-Image styled frames (reliable foundation). Phase 2 = add face-lock** (Qwen has its own
edit/identity path; or route face-lock work to cb-imagegen). Get the reliable foundation first.

Upstream pinned in `../ENGINE-LOCK.md` (QwenLM/Qwen-Image @ `6b5e1f5…`).
