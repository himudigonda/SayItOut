from fastapi import FastAPI, HTTPException
from fastapi.responses import FileResponse
from kokoro import KPipeline
import soundfile as sf
import torch
import os
import uuid
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# CORS middleware to allow requests from the frontend (important!)
origins = [
    "http://localhost:3000",  # Or whatever port your frontend runs on
    "http://127.0.0.1:3000",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


pipeline = KPipeline(lang_code="a")  # English voice

TEMP_DIR = "temp"
os.makedirs(TEMP_DIR, exist_ok=True)

from pydantic import BaseModel


class TTSRequest(BaseModel):
    text: str


@app.post("/tts/")
async def generate_tts(request: TTSRequest):
    text = request.text
    print("[DEBUG] server.generate_tts :: Received text: {}".format(text))
    if not text.strip():
        print("[ERROR] server.generate_tts :: Text is empty")
        raise HTTPException(status_code=400, detail="Text cannot be empty")

    file_id = str(uuid.uuid4())[:8]  # Generate unique filename
    file_path = os.path.join(TEMP_DIR, f"{file_id}.wav")
    print(
        "[DEBUG] server.generate_tts :: Generating file with id: {}, path: {}".format(
            file_id, file_path
        )
    )

    # Generate speech
    try:
        generator = pipeline(text, voice="af_heart", speed=1)
        for _, _, audio in generator:
            sf.write(file_path, audio, 24000)  # Save generated .wav file
        print(
            "[DEBUG] server.generate_tts :: Successfully generated speech and saved to {}".format(
                file_path
            )
        )
    except Exception as e:
        print(
            "[ERROR] server.generate_tts :: Error during speech generation: {}".format(
                e
            )
        )
        raise HTTPException(status_code=500, detail=str(e))

    audio_url = f"http://127.0.0.1:8000/download/{file_id}"
    print("[DEBUG] server.generate_tts :: Returning audio_url: {}".format(audio_url))
    return {"audio_url": audio_url}  # IMPORTANT: Full URL


@app.get("/download/{file_id}")
async def download_audio(file_id: str):
    print(
        "[DEBUG] server.download_audio :: Attempting to download audio with file_id: {}".format(
            file_id
        )
    )
    file_path = os.path.join(TEMP_DIR, f"{file_id}.wav")
    if not os.path.exists(file_path):
        print("[ERROR] server.download_audio :: File not found: {}".format(file_path))
        raise HTTPException(status_code=404, detail="File not found")

    print(
        "[DEBUG] server.download_audio :: File found, returning FileResponse: {}".format(
            file_path
        )
    )
    return FileResponse(file_path, media_type="audio/wav")


# Run server: `uvicorn Backend/server.py:app --host 127.0.0.1 --port 8000 --reload`  (from the project root)
