import os, sys, threading, subprocess, re, webbrowser
from flask import Flask, request, jsonify, render_template
from pytubefix import YouTube

app = Flask(__name__)

#------------------------------ CARTELLE & UTIL

def get_cartella_default():
    desktop = os.path.join(os.path.expanduser("~"), "Desktop")
    base = os.path.join(desktop, "YT_Downloader")
    os.makedirs(os.path.join(base, "audio"), exist_ok=True)
    os.makedirs(os.path.join(base, "video"), exist_ok=True)
    return base

def trova_ffmpeg():
    here = os.path.dirname(os.path.abspath(__file__))
    for p in (os.path.join(here, "ffmpeg.exe"), os.path.join(here, "ffmpeg", "ffmpeg.exe")):
        if os.path.exists(p):
            return p
    return "ffmpeg"

def nome_compatibile(path):
    folder, name = os.path.dirname(path), os.path.basename(path)
    name = re.sub(r'[^A-Za-z0-9_\-\. ]+', '_', name)
    if len(name) > 64:
        root, ext = os.path.splitext(name)
        name = (root[:60] + ext) if len(root) > 60 else name
    return os.path.join(folder, name)

def converti_a_mp3_compat(infile, bitrate="192k"):
    ff = trova_ffmpeg()
    base, _ = os.path.splitext(infile)
    outfile = nome_compatibile(base + ".mp3")
    cmd = [ff, "-y", "-i", infile, "-vn",
           "-ar", "44100", "-ac", "2",
           "-codec:a", "libmp3lame", "-b:a", bitrate,
           "-id3v2_version", "3",
           outfile]

    startupinfo = None
    if sys.platform == "win32":
        startupinfo = subprocess.STARTUPINFO()
        startupinfo.dwFlags |= subprocess.STARTF_USESHOWWINDOW

    try:
        subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, startupinfo=startupinfo)
        return outfile, None
    except Exception as e:
        return None, str(e)

#------------------------------ STATO GLOBALE (per il polling)

stato_lock = threading.Lock()
stato = {"status": "In attesa...", "progress": 0, "done": True, "error": None}
ultimo_tipo = None

def set_stato(**kwargs):
    with stato_lock:
        stato.update(kwargs)

#------------------------------ FUNZIONI BACKEND (download)

def _on_progress(stream, chunk, bytes_remaining):
    try:
        total = stream.filesize or 1
        done = total - bytes_remaining
        perc = max(0.0, min(100.0, (done / total) * 100.0))
        set_stato(progress=perc)
    except Exception:
        pass

def scarica_video(link):
    if not link:
        raise ValueError("Inserisci un link valido.")
    yt = YouTube(link, on_progress_callback=_on_progress)
    stream = yt.streams.get_highest_resolution()
    set_stato(status=f"Scarico video: {yt.title}")
    video_dir = os.path.join(get_cartella_default(), "video")
    os.makedirs(video_dir, exist_ok=True)
    stream.download(output_path=video_dir)
    set_stato(status="Video scaricato!")

def scarica_audio_mp3(link):
    if not link:
        raise ValueError("Inserisci un link valido.")
    yt = YouTube(link, on_progress_callback=_on_progress)
    stream = yt.streams.filter(only_audio=True).first()
    set_stato(status=f"Scarico audio: {yt.title}")
    audio_dir = os.path.join(get_cartella_default(), "audio")
    os.makedirs(audio_dir, exist_ok=True)
    originale = stream.download(output_path=audio_dir)
    mp3_path, err = converti_a_mp3_compat(originale, bitrate="192k")
    if err:
        set_stato(status=f"Conversione fallita: {err}. Salvato formato originale.")
    else:
        try:
            os.remove(originale)
        except Exception:
            pass
        set_stato(status="Audio MP3 compatibile creato!")

def _esegui_download(link, tipo):
    global ultimo_tipo
    try:
        if tipo == "video":
            scarica_video(link)
        else:
            scarica_audio_mp3(link)
        ultimo_tipo = tipo
        set_stato(progress=100, done=True)
    except Exception as e:
        set_stato(status=f"Errore: {e}", error=str(e), done=True)

#------------------------------ ROUTE FLASK

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/download", methods=["POST"])
def download():
    data = request.get_json(force=True)
    link = (data.get("link") or "").strip()
    tipo = data.get("tipo")
    if tipo not in ("video", "audio"):
        return jsonify({"error": "Tipo non valido."}), 400

    with stato_lock:
        if not stato["done"]:
            return jsonify({"error": "Un download è già in corso."}), 409
        stato.update(status="Preparazione...", progress=0, done=False, error=None)

    threading.Thread(target=_esegui_download, args=(link, tipo), daemon=True).start()
    return jsonify({"ok": True})

@app.route("/status")
def status():
    with stato_lock:
        return jsonify(dict(stato))

@app.route("/apri-cartella", methods=["POST"])
def apri_cartella():
    base = get_cartella_default()
    if ultimo_tipo == "audio":
        path = os.path.join(base, "audio")
    elif ultimo_tipo == "video":
        path = os.path.join(base, "video")
    else:
        path = base
    try:
        os.startfile(path)
        return jsonify({"ok": True})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    threading.Timer(1.0, lambda: webbrowser.open("http://127.0.0.1:5000")).start()
    app.run(host="127.0.0.1", port=5000, debug=False)
