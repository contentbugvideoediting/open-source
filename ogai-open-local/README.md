# ogai-open-local — the GENUINELY-OPEN parts lifted out of "Open Generative AI"

The OGAI desktop app (Anil-matcha/SamurAIGPT) is mostly a **paid MuAPI client** — 200+ "models"
that route to `api.muapi.ai` and bill per call. We threw all of that away. What's in this folder is
the ONLY genuinely open, self-hostable code from it: a local-inference engine + an open-model catalog.
**Zero MuAPI. No API keys. No per-call billing.**

## What we kept (and why)
- **`lib/modelCatalog.js` + `lib/localModels.frontend.js`** — ⭐ the real value. A curated catalog of
  **publicly-downloadable open models** with exact HuggingFace URLs + correct inference params
  (steps, guidance, sampler, scheduler, aspect ratios): Z-Image Turbo (6B), Dreamshaper-8 (SD1.5),
  FLUX VAE, Qwen3-4B text encoder, etc. Reusable intelligence regardless of the engine.
- **`lib/wan2gpProvider.js` + `wan2gpModelAvailability.js`** — ⭐ the routing pattern you wanted.
  An HTTP provider that points at a **user-run Wan2GP Gradio server** (github.com/deepbeepmeep/Wan2GP)
  — "we never bundle Python or weights." This is the "route to OUR GPU, not theirs" hook.
- **`lib/localInference.js` (+Assets/Paths/Runtime)** — a local generator built on **`sd.cpp`**
  (stable-diffusion.cpp, open C++ inference). Downloads the GGUF, runs on-device, returns an image.

## How this routes to OUR RunPod (the point)
`sd.cpp` is **laptop-tier** (small GGUF models, CPU/Metal). Our premium path is BETTER — FLUX + Wan2.2
full weights on RunPod GPU. So the play is NOT "ship sd.cpp." It's:
1. **Use the catalog** to know which open models + exact params to load on our RunPod ComfyUI/Wan workers.
2. **Repoint `wan2gpProvider`** from a localhost Gradio server → our **RunPod Wan2GP/ComfyUI endpoint**
   (swap the base URL for `RUNPOD_WAN_ENDPOINT`). Same provider shape, our GPU on the other end.
3. sd.cpp stays as an optional **offline/laptop fallback** tier only.

## Provenance
Extracted 2026-06-16 from `Open-Generative-AI-main` (v2.0.0). MuAPI catalog (`packages/studio/src/models.js`,
10.6k lines) and all `app/api/*` MuAPI routes were intentionally NOT copied. See [[opensource-engine-stack]].
