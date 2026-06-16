# cb-qwenimage — ContentBug styled-image engine (Qwen-Image, Apache-2.0 = fully sellable).
#
# Built ON TOP of the proven RunPod ComfyUI worker base (serverless handler already wired). We add
# the Qwen-Image model files at BUILD time so cold workers have them instantly = reliable (the same
# reliability win as cb-imagegen — model ships in the image, no cold-start "model not found").
#
# Qwen-Image is Apache-2.0: unlike FLUX.1-dev (non-commercial), client work made here is legally
# sellable. This is the commercial-safe image engine.
#
# Base accepts ComfyUI API-format workflows via {"input":{"workflow":{...}}}.
FROM runpod/worker-comfyui:5.8.5-base

# ── Qwen-Image model files (canonical, from Comfy-Org/Qwen-Image_ComfyUI/split_files, Apache-2.0) ──
# Downloaded at build so cold workers are instant. If a filename/URL changed, fix per README list.
ARG HF=https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files
RUN mkdir -p /comfyui/models/diffusion_models /comfyui/models/text_encoders /comfyui/models/vae /comfyui/models/loras && \
    wget -q -O /comfyui/models/diffusion_models/qwen_image_fp8_e4m3fn.safetensors \
      "$HF/diffusion_models/qwen_image_fp8_e4m3fn.safetensors" && \
    wget -q -O /comfyui/models/text_encoders/qwen_2.5_vl_7b_fp8_scaled.safetensors \
      "$HF/text_encoders/qwen_2.5_vl_7b_fp8_scaled.safetensors" && \
    wget -q -O /comfyui/models/vae/qwen_image_vae.safetensors \
      "$HF/vae/qwen_image_vae.safetensors"

# ── 8-step Lightning LoRA (lightx2v) — cuts inference from ~20 steps to 8 = ~2.5x cheaper GPU time.
#    Optional: if this URL 404s the engine still works at full steps (raise KSampler steps to 20, cfg 2.5).
RUN wget -q -O /comfyui/models/loras/Qwen-Image-Lightning-8steps-V2.0.safetensors \
      "https://huggingface.co/lightx2v/Qwen-Image-Lightning/resolve/main/Qwen-Image-Lightning-8steps-V2.0.safetensors" || \
    echo "WARN: Lightning LoRA download failed — set steps=20, cfg=2.5, remove the LoRA node in the workflow."

# the base image already sets ENTRYPOINT to the RunPod serverless handler — do NOT override it.
