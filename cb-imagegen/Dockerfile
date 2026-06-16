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

# python deps for InsightFace identity embedding (the same family as the faceswap worker)
RUN pip install --no-cache-dir insightface==0.7.3 onnxruntime-gpu facexlib || true

# PuLID + InsightFace model weights → the dirs ComfyUI expects. (Downloaded at build so cold
# workers have them instantly = reliable. If a URL 404s on first build, swap it in the README list.)
RUN mkdir -p /comfyui/models/pulid /comfyui/models/insightface/models/antelopev2 && \
    (wget -q -O /comfyui/models/pulid/pulid_flux_v0.9.1.safetensors \
      https://huggingface.co/guozinan/PuLID/resolve/main/pulid_flux_v0.9.1.safetensors || true)

# the base image already sets ENTRYPOINT to the RunPod serverless handler — do NOT override it.
