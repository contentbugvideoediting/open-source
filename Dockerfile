# ── ROOT Dockerfile = live endpoint build (cb-imagegen: FLUX + PuLID face-lock). ──

# cb-imagegen — ContentBug styled-image engine (FLUX + face-lock), RunPod serverless.
#
# Built on the BASE ComfyUI worker, with the ALL-IN-ONE FLUX checkpoint baked in. The single
# flux1-dev-fp8 checkpoint bundles UNET + CLIP + T5 + VAE in ONE file, loaded by CheckpointLoaderSimple
# — this avoids the split-file model-layout mismatch that the *-flux1-dev-fp8 base image caused
# (empty clip dir / 'pixel_space' vae). Model ships in the image = cold workers are instant = reliable.
# We add the face-lock custom nodes (PuLID-Flux + InsightFace + IP-Adapter) to lock a client's face.
FROM runpod/worker-comfyui:5.8.5-base

# build tools — so any dep that compiles (insightface) can't silently fail the build.
RUN apt-get update && apt-get install -y --no-install-recommends build-essential cmake git && rm -rf /var/lib/apt/lists/*

# face-lock custom node — sipie800's PuLID-Flux-Enhanced.
RUN cd /comfyui/custom_nodes && \
    git clone --depth 1 https://github.com/sipie800/ComfyUI-PuLID-Flux-Enhanced.git

# node deps — install onnxruntime-GPU only (the node's requirements.txt lists BOTH onnxruntime +
# onnxruntime-gpu, which collide). No '|| true' — if a dep fails, the build FAILS loudly.
RUN pip install --no-cache-dir facexlib insightface ftfy timm onnxruntime-gpu

# BUILD-TIME SMOKE TEST — verify the node's deps actually import. If broken, the build fails HERE
# (loud) instead of silently shipping an image where the node won't register.
RUN python -c "import facexlib, insightface, onnxruntime, ftfy, timm; print('PuLID deps import OK')"

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
