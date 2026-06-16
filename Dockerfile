# ── ROOT Dockerfile = the live endpoint build (cb-imagegen, all-in-one FLUX checkpoint). ──
# Per-engine repos now exist (cb-imagegen, qwen-image); this monorepo stays only as the source the
# existing warm endpoint builds from until it's repointed. Identical to cb-imagegen/Dockerfile.

# cb-imagegen — ContentBug styled-image engine (FLUX + face-lock), RunPod serverless.
#
# Built on the BASE ComfyUI worker, with the ALL-IN-ONE FLUX checkpoint baked in. The single
# flux1-dev-fp8 checkpoint bundles UNET + CLIP + T5 + VAE in ONE file, loaded by CheckpointLoaderSimple
# — this avoids the split-file model-layout mismatch that the *-flux1-dev-fp8 base image caused
# (empty clip dir / 'pixel_space' vae). Model ships in the image = cold workers are instant = reliable.
# We add the face-lock custom nodes (PuLID-Flux + InsightFace + IP-Adapter) to lock a client's face.
FROM runpod/worker-comfyui:5.8.5-base

# face-lock + identity custom nodes
RUN cd /comfyui/custom_nodes && \
    git clone --depth 1 https://github.com/balazik/ComfyUI-PuLID-Flux-Enhanced.git || true && \
    git clone --depth 1 https://github.com/cubiq/ComfyUI_InstantID.git || true && \
    git clone --depth 1 https://github.com/cubiq/ComfyUI_IPAdapter_plus.git || true

RUN pip install --no-cache-dir insightface==0.7.3 onnxruntime-gpu facexlib || true

# ALL-IN-ONE FLUX.1-dev fp8 checkpoint (unet+clip+t5+vae) → models/checkpoints. Verified URL (200 OK).
RUN mkdir -p /comfyui/models/checkpoints && \
    wget -q -O /comfyui/models/checkpoints/flux1-dev-fp8.safetensors \
      https://huggingface.co/Comfy-Org/flux1-dev/resolve/main/flux1-dev-fp8.safetensors

# PuLID + InsightFace weights for face-lock (optional — plain FLUX still works if these fail).
RUN mkdir -p /comfyui/models/pulid /comfyui/models/insightface/models/antelopev2 && \
    (wget -q -O /comfyui/models/pulid/pulid_flux_v0.9.1.safetensors \
      https://huggingface.co/guozinan/PuLID/resolve/main/pulid_flux_v0.9.1.safetensors || true)

# the base image already sets ENTRYPOINT to the RunPod serverless handler — do NOT override it.
