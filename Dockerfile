# ── ROOT Dockerfile = the live endpoint build (cb-imagegen: FLUX + PuLID face-lock). ──
# Identical to cb-imagegen/Dockerfile. Per-engine repos exist; this monorepo feeds the live endpoint.

# cb-imagegen — ContentBug styled-image engine (FLUX + face-lock), RunPod serverless.
#
# Built on the BASE ComfyUI worker, with the ALL-IN-ONE FLUX checkpoint baked in. The single
# flux1-dev-fp8 checkpoint bundles UNET + CLIP + T5 + VAE in ONE file, loaded by CheckpointLoaderSimple
# — this avoids the split-file model-layout mismatch that the *-flux1-dev-fp8 base image caused
# (empty clip dir / 'pixel_space' vae). Model ships in the image = cold workers are instant = reliable.
# We add the face-lock custom nodes (PuLID-Flux + InsightFace + IP-Adapter) to lock a client's face.
FROM runpod/worker-comfyui:5.8.5-base

# face-lock custom node — sipie800's PuLID-Flux-Enhanced (verified repo; supports multi-image identity).
RUN cd /comfyui/custom_nodes && \
    git clone --depth 1 https://github.com/sipie800/ComfyUI-PuLID-Flux-Enhanced.git || true

RUN pip install --no-cache-dir insightface==0.7.3 onnxruntime-gpu facexlib timm || true

# ALL-IN-ONE FLUX.1-dev fp8 checkpoint (unet+clip+t5+vae) → models/checkpoints. Verified URL (200 OK).
RUN mkdir -p /comfyui/models/checkpoints && \
    wget -q -O /comfyui/models/checkpoints/flux1-dev-fp8.safetensors \
      https://huggingface.co/Comfy-Org/flux1-dev/resolve/main/flux1-dev-fp8.safetensors

# PuLID-Flux weights → models/pulid.
RUN mkdir -p /comfyui/models/pulid && \
    wget -q -O /comfyui/models/pulid/pulid_flux_v0.9.1.safetensors \
      https://huggingface.co/guozinan/PuLID/resolve/main/pulid_flux_v0.9.1.safetensors

# InsightFace AntelopeV2 face-recognition models (5 ONNX) → the dir the loader reads. Verified URLs (200).
RUN mkdir -p /comfyui/models/insightface/models/antelopev2 && cd /comfyui/models/insightface/models/antelopev2 && \
    for m in 1k3d68 2d106det genderage glintr100 scrfd_10g_bnkps ; do \
      wget -q -O $m.onnx "https://huggingface.co/DIAMONIK7777/antelopev2/resolve/main/$m.onnx" ; \
    done

# the base image already sets ENTRYPOINT to the RunPod serverless handler — do NOT override it.
