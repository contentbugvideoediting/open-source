# ENGINE-LOCK — pinned open-source sources

Every engine is built from an OPEN-SOURCE upstream, pinned to an exact commit so it never drifts.
Weights are pulled at RunPod build time from HuggingFace — **never stored in this repo**.
Local source-of-truth checkouts live in `CONTENT STUDIO/framelab-engines/vendor/`.

| Engine source | Upstream repo | Pinned commit | License | Commercial-safe? |
|---|---|---|---|---|
| FLUX (image)        | github.com/black-forest-labs/flux          | `802fb4713906133fcbd0d8dc5351620ca4773036` | schnell Apache / dev non-comm | schnell ✅ / dev ⚠️ |
| Qwen-Image (image)  | github.com/QwenLM/Qwen-Image               | `6b5e1f5cec987d404be5ac6657db3b9aacb56a89` | Apache 2.0 | ✅ |
| Wan2.2 (video)      | github.com/Wan-Video/Wan2.2               | `42bf4cfaa384bc21833865abc2f9e6c0e67233dc` | Apache 2.0 | ✅ |
| Open-Sora (video)   | github.com/hpcaitech/Open-Sora            | `7ad6a96a135feb81f755c84fb391818718f6beb2` | Apache 2.0* | ✅* |
| HunyuanVideo-1.5    | github.com/Tencent-Hunyuan/HunyuanVideo-1.5 | `60783e704160023913bee78f0b47036d393d4dfa` | Tencent community | regional ⚠️ |
| LTX-Video (video)   | github.com/Lightricks/LTX-Video           | `4b2d053057623ddd4d0a1d3e9cd28890e9ef487f` | LTX open | ✅ |

\* confirm Open-Sora's exact license clause at deploy.

## To bump a version
Re-clone upstream, update the commit hash above, rebuild the RunPod endpoint. That's the whole lock/bump loop.
