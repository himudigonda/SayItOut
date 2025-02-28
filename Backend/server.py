from fastapi import FastAPI, HTTPException
from fastapi.responses import FileResponse
from kokoro import KPipeline
import soundfile as sf
import torch
import os
import uuid
from fastapi.middleware.cors import CORSMiddleware
import numpy as np
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
    text = request.text.strip()
    print("[DEBUG] server.generate_tts :: Received text: {}".format(text))

    if not text:
        print("[ERROR] server.generate_tts :: Text is empty")
        raise HTTPException(status_code=400, detail="Text cannot be empty")

    paragraphs = text.split("\n")  # Split text into paragraphs
    file_id = str(uuid.uuid4())[:8]  # Generate unique ID
    file_paths = []  # Store individual audio file paths

    try:
        for i, para in enumerate(paragraphs):
            if not para.strip():  # Skip empty paragraphs
                continue

            temp_file = os.path.join(
                TEMP_DIR, f"{file_id}_{i}.wav"
            )  # Unique filename per chunk
            generator = pipeline(para, voice="af_heart", speed=1)

            for _, _, audio in generator:
                sf.write(
                    temp_file, audio, 24000
                )  # Save each paragraph as a separate file
                file_paths.append(temp_file)
                break  # Only process first output per paragraph

            print(f"[DEBUG] server.generate_tts :: Generated {temp_file}")

        # Merge all generated audio files
        merged_audio_path = os.path.join(TEMP_DIR, f"{file_id}_final.wav")
        merge_audio_files(file_paths, merged_audio_path)

        print(
            f"[DEBUG] server.generate_tts :: Merged audio saved at {merged_audio_path}"
        )
    except Exception as e:
        print(f"[ERROR] server.generate_tts :: Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

    audio_url = f"http://127.0.0.1:8000/download/{file_id}_final"
    print("[DEBUG] server.generate_tts :: Returning audio_url: {}".format(audio_url))
    return {"audio_url": audio_url}


def merge_audio_files(input_files, output_file):
    """Merge multiple WAV files into a single WAV file."""
    combined_audio = []
    sample_rate = 24000  # Assuming all audio files are 24kHz

    for file in input_files:
        audio, sr = sf.read(file)
        if sr != sample_rate:
            raise ValueError(
                f"Sample rate mismatch: {file} has {sr} Hz, expected {sample_rate} Hz."
            )
        combined_audio.append(audio)

    # Concatenate all audio arrays
    merged_audio = np.concatenate(combined_audio, axis=0)
    sf.write(output_file, merged_audio, sample_rate)  # Save merged file

    # Cleanup individual temp files
    for file in input_files:
        os.remove(file)

    print(
        f"[DEBUG] merge_audio_files :: Merged {len(input_files)} files into {output_file}"
    )


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
