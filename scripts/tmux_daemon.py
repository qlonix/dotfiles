#!/usr/bin/env python3
import os
import socket
import subprocess
import sys
import threading
import time
import urllib.request

# Map weather emojis to safe, default-colorful versions that do not need Variation Selector-16 (U+FE0F)
EMOJI_MAPPING = {
    "☀️": "🌞",
    "☁️": "⛅",
    "🌫️": "🌁",
    "🌦️": "☔",
    "🌨️": "⛄",
    "🌧️": "☔",
    "⛈️": "⚡",
    "❄️": "⛄",
    "☀": "🌞",
    "☁": "⛅",
    "🌫": "🌁",
    "🌦": "☔",
    "🌨": "⛄",
    "🌧": "☔",
    "⛈": "⚡",
    "❄": "⛄"
}

def fetch_weather():
    try:
        # Fetch weather from wttr.in with location name (%l), emoji (%c) and temperature (%t)
        # User-Agent is set to curl to get the simple plain text response
        req = urllib.request.Request(
            "https://wttr.in/?format=%l:+%c+%t",
            headers={"User-Agent": "curl/7.79.1"}
        )
        with urllib.request.urlopen(req, timeout=5) as response:
            weather_data = response.read().decode('utf-8').strip()
            # Clean up extra whitespace/newlines
            weather_data = " ".join(weather_data.split())
            
            # Extract city name and weather parts
            parts = weather_data.split(":", 1)
            if len(parts) == 2:
                loc = parts[0].strip()
                rest = parts[1].strip()
                # Get the first part before the comma (e.g. "Tsu" from "Tsu, Mie, JP")
                city = loc.split(",")[0].strip()
                # Limit city name length to avoid status bar overflow
                if len(city) < 20:
                    weather_data = f"{city} {rest}"
            
            # Map emojis
            for old_emoji, new_emoji in EMOJI_MAPPING.items():
                weather_data = weather_data.replace(old_emoji, new_emoji)
            
            # Strip any remaining Variation Selector 16 (U+FE0F)
            weather_data = weather_data.replace("\ufe0f", "")
            
            if weather_data and "html" not in weather_data.lower() and len(weather_data) < 35:
                with open("/tmp/tmux_weather", "w") as f:
                    f.write(weather_data)
    except Exception:
        # Ignore errors to keep daemon running
        pass

def weather_loop():
    while True:
        fetch_weather()
        # Fetch every 15 minutes (900 seconds)
        time.sleep(900)

def notification_loop():
    # Clear any old notification file on startup
    if os.path.exists("/tmp/tmux_notification"):
        try:
            os.remove("/tmp/tmux_notification")
        except Exception:
            pass

    # Start dbus-monitor for notification interface method calls
    try:
        proc = subprocess.Popen(
            ["dbus-monitor", "type='method_call',interface='org.freedesktop.Notifications',member='Notify'"],
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            text=True
        )
    except Exception as e:
        sys.stderr.write(f"Failed to start dbus-monitor: {e}\n")
        return

    def clean_string(s):
        s = s.strip()
        if s.startswith('"') and s.endswith('"'):
            return s[1:-1]
        return s

    app_name = ""
    summary = ""
    body = ""
    state = 0  # 0: waiting, 1: got app_name, 2: got replaces_id, 3: got app_icon, 4: got summary, 5: got body

    # Read output of dbus-monitor line by line
    for line in proc.stdout:
        line = line.strip()
        if line.startswith("method call"):
            state = 1
            app_name = ""
            summary = ""
            body = ""
            continue
        
        if state == 1:
            if line.startswith("string"):
                app_name = clean_string(line[6:])
                state = 2
        elif state == 2:
            if line.startswith("uint32"):
                state = 3
        elif state == 3:
            if line.startswith("string"):
                state = 4
        elif state == 4:
            if line.startswith("string"):
                summary = clean_string(line[6:])
                state = 5
        elif state == 5:
            if line.startswith("string"):
                body = clean_string(line[6:])
                
                # Format notification text (exclude too long bodies)
                text = f"{app_name}: {summary}"
                if body:
                    text += f" - {body}"
                
                # Clean up whitespace and newlines
                text = " ".join(text.split())
                
                # Truncate text if too long for status bar
                if len(text) > 40:
                    text = text[:37] + "..."
                
                # Write to temp file with timestamp
                try:
                    with open("/tmp/tmux_notification", "w") as f:
                        f.write(f"{text}\n{int(time.time())}\n")
                except Exception:
                    pass
                
                state = 0

def main():
    # Use abstract namespace socket lock to prevent multiple instances
    global lock_socket
    try:
        lock_socket = socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM)
        lock_socket.bind('\0tmux_daemon_qlo_lock')
    except socket.error:
        # Already running, exit silently
        sys.exit(0)

    # Start weather fetch loop in background thread
    t = threading.Thread(target=weather_loop, daemon=True)
    t.start()
    
    # Run notification loop in the main thread
    notification_loop()

if __name__ == "__main__":
    main()
