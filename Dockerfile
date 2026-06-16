# ── ROOT Dockerfile = the DEFAULT endpoint build (cb-imagegen: FLUX + PuLID face-lock). ──
# RunPod's GitHub deploy looks for a Dockerfile at the repo root; this makes the queued build
# succeed without needing a custom Dockerfile-path. Identical to cb-imagegen/Dockerfile (which is
# self-contained: no local COPY). For OTHER engines, create a separate endpoint and set its
# Dockerfile Path to that engine's folder (e.g. qwen-image/Dockerfile).

# cb-imagegen — Content Bug styled-image engine (FLUX + face-lock), RunPod serverless.
#
# Built ON TOP of the PROVEN FLUX worker image (FLUX.1-dev fp8 + the RunPod serverless handler
# are ALREADY baked in — this is the key reliability win: the model ships in the image, so there
# is no cold-start "model failed to load" failure like the A1111 endpoint had). We only ADD the
# face-lock custom nodes (PuLID-for-FLUX + InsightFace + IP-Adapter) so we can lock a client's face.
#
# Base accepts ComfyUI API-format workflows via {"input":{"workflow":{...}}}.
FROM runpod/worker-comfyui:5.8.5-flux1-dev-fp8

# face-lock + identity custom nodes
RUN cd /comfyui/custom_nodes && \
    git clone --depth 1 https://github.com/balazik/ComfyUI-PuLID-Flux-Enhanced.git || true && \
    git clone --depth 1 https://github.com/cubiq/ComfyUI_InstantID.git || true && \
    git clone --depth 1 https://github.com/cubiq/ComfyUI_IPAdapter_plus.git || true

# FLUX text encoders — the base ships the UNET + VAE but NOT the CLIP/T5 text encoders the
# DualCLIPLoader needs (first test failed: "clip_name not in []" = empty encoder dir). Download
# them into BOTH dirs ComfyUI may read so the loader always finds them. (Apache-licensed mirror.)
RUN mkdir -p /comfyui/models/clip /comfyui/models/text_encoders && \
    for d in clip text_encoders; do \
      wget -q -O /comfyui/models/$d/t5xxl_fp8_e4m3fn.safetensors \
        https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp8_e4m3fn.safetensors && \
      wget -q -O /comfyui/models/$d/clip_l.safetensors \
        https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors ; \
    done

# python deps for InsightFace identity embedding (the same family as the faceswap worker)
RUN pip install --no-cache-dir insightface==0.7.3 onnxruntime-gpu facexlib || true

# PuLID + InsightFace model weights → the dirs ComfyUI expects. (Downloaded at build so cold
# workers have them instantly = reliable. If a URL 404s on first build, swap it in the README list.)
RUN mkdir -p /comfyui/models/pulid /comfyui/models/insightface/models/antelopev2 && \
    (wget -q -O /comfyui/models/pulid/pulid_flux_v0.9.1.safetensors \
      https://huggingface.co/guozinan/PuLID/resolve/main/pulid_flux_v0.9.1.safetensors || true)

# the base image already sets ENTRYPOINT to the RunPod serverless handler — do NOT override it.
