# **SayItOut** 🎙️  
*A System-Wide Context Menu for Text-to-Speech on macOS*

---

## **Overview**
🚀 **SayItOut** is a macOS application that adds a **system-wide right-click (context) menu** to enable **text-to-speech (TTS) functionality** in any application. Users can right-click on selected text and choose **"SayItOut" → "Start Speaking"** to convert the text into speech, or **"Stop Speaking"** to halt playback.  

This lightweight, background-running app integrates seamlessly into macOS, requiring no visible UI. It communicates with a **FastAPI backend** to process text-to-speech requests, fetches the generated audio, and plays it dynamically.

---

## **Features**
✅ **Global Context Menu Integration** – Works in any macOS app  
✅ **Instant Text-to-Speech** – Select text, right-click, and listen  
✅ **No UI, Runs in Background** – Minimal footprint, no windows required  
✅ **FastAPI Backend** – Processes text and returns high-quality audio  
✅ **Seamless Playback** – Plays audio without interruptions  

---

## **Architecture**
```
📂 SayItOut
│── 📂 Backend                # FastAPI server for TTS processing
│   │── server.py             # Handles TTS requests and audio generation
│── 📂 SayItOut               # macOS Swift application
│   │── SayItOutApp.swift     # Main app entry (background service)
│   │── 📂 Services
│   │   │── ContextMenuService.swift  # Handles macOS context menu
│   │   │── TTSManager.swift          # Manages API communication
│   │   │── AudioPlayerService.swift  # Controls audio playback
│   │── 📂 Extensions
│   │   │── TimeInterval+Formatting.swift  # Utility extensions
│   │── 📂 Components
│   │   │── PlaybackSlider.swift      # Audio playback UI (future use)
│   │── 📂 Models
│   │   │── AudioData.swift           # Audio metadata model
│── README.md                # This documentation
│── dumper.sh                # (Optional) Debugging script
```
---

## **Installation & Setup**
### **1️⃣ Clone the Repository**
```sh
git clone https://github.com/yourusername/SayItOut.git
cd SayItOut
```

### **2️⃣ Set Up the FastAPI Backend**
- Install dependencies:
```sh
pip install fastapi uvicorn numpy soundfile
```
- Run the backend server:
```sh
uvicorn Backend.server:app --host 127.0.0.1 --port 8000 --reload
```

### **3️⃣ Build & Run the macOS App**
- Open `SayItOut.xcodeproj` in **Xcode**.
- Run the project in **Release Mode**.
- The app will **run in the background** and add a **right-click menu**.

---

## **Usage**
1️⃣ Select any text in any macOS application.  
2️⃣ Right-click → **SayItOut → Start Speaking**.  
3️⃣ The selected text is converted into speech and played.  
4️⃣ To stop playback, **Right-click → SayItOut → Stop Speaking**.  

---

## **Debugging**
Extensive logs are available in **Console.app** or when running via Xcode. Logs follow this format:  
```
[INFO] ContextMenuService.startSpeaking :: Sending selected text: "Hello World"
[INFO] TTSManager.requestSpeech :: Received audio URL: http://127.0.0.1:8000/download/xyz
[INFO] AudioPlayerService.play :: Playing audio from URL
```

For backend debugging, run:
```sh
uvicorn Backend.server:app --host 127.0.0.1 --port 8000 --reload --log-level debug
```

---

## **Future Enhancements**
- ✅ **Improve speech quality** (support different voices/speeds)
- ✅ **Multi-language support** (extend backend TTS)
- ✅ **Custom voice selection from macOS settings**
- ✅ **Offline TTS support** (macOS built-in voices)

---

## **License**
📝 **MIT License** – Free to modify and distribute.

---

## **Contributing**
💡 Want to improve **SayItOut**? Feel free to submit **pull requests** or **report issues**!

---
🎤 **SayItOut – Because Every Text Deserves a Voice!** 🚀
