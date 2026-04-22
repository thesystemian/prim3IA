#!/usr/bin/env python3
import sys
import time
import json
import requests
import os
from datetime import datetime
from rich.console import Console
from rich.panel import Panel
from rich.progress import Progress, SpinnerColumn, BarColumn, TextColumn
from rich.markdown import Markdown
from rich.theme import Theme

# Morandi Palette Theme
MORANDI_THEME = Theme({
    "prim.title": "#A0523D",       # Terracotta
    "prim.border": "#8E8E8E",      # Soft Gray
    "prim.header": "#D4A574",      # Warm Ocre
    "prim.text": "#E8DCC8",        # Soft Beige
})

console = Console(theme=MORANDI_THEME)

BASE_DIR = os.path.expanduser("~/Prim3IA")
LOG_DIR = os.path.join(BASE_DIR, "Logs")
SESSION_FILE = os.path.join(LOG_DIR, "session_current.txt")

class PrimOrchestrator:
    def __init__(self):
        if not os.path.exists(LOG_DIR):
            os.makedirs(LOG_DIR)
        if not os.path.exists(SESSION_FILE):
            with open(SESSION_FILE, "w") as f: f.write("")

    def get_history(self):
        try:
            with open(SESSION_FILE, "r") as f:
                lines = f.readlines()
                return "".join(lines[-20:]) # 20 dernières lignes
        except: return ""

    def save_history(self, mission, response):
        with open(SESSION_FILE, "a") as f:
            f.write(f"Mission: {mission} | Result: {response[:100]}...\n")

    def execute_mission(self, mission):
        start_time = time.time()
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        date_file = datetime.now().strftime("%Y%m%d_%H%M%S")
        log_file = os.path.join(LOG_DIR, f"mission_{date_file}.log")

        history = self.get_history()

        system_prompt = f"""You are PRIM, an intelligent orchestration system created by Dax @thesystemian.
Dax is building: Vizu (Data Storytelling), VovoEditions (KDP), and Prim3IA (this system).

Analyze missions through EU (Creative), US (Logical), and CN (Pragmatic) lenses.
Always respond in FRENCH. Use Markdown.

MEMORY OF SESSION:
{history}

OUTPUT FORMAT:
# [Creative Insight]
> (1 sentence)
# [Validation]
> (1-2 sentences)
# [Execution Plan]
1. Step...
# [Final Recommendation]
..."""

        with Progress(
            SpinnerColumn(),
            TextColumn("[prim.header]{task.description}"),
            BarColumn(bar_width=20, pulse_style="prim.header"),
            console=console,
            transient=True,
        ) as progress:
            task = progress.add_task("🧠 PRIM consulte sa mémoire et la Trinité...", total=None)
            
            try:
                payload = {
                    "model": "mistral:latest",
                    "system": system_prompt,
                    "prompt": mission,
                    "stream": False
                }
                response = requests.post("http://localhost:11434/api/generate", json=payload, timeout=60)
                response.raise_for_status()
                result = response.json().get("response", "Erreur: Pas de réponse")
                self.save_history(mission, result)
            except Exception as e:
                result = f"❌ Erreur de connexion à Ollama : {str(e)}"

        elapsed = time.time() - start_time
        with open(log_file, "w") as f:
            f.write(f"MISSION: {mission}\nTIME: {timestamp}\n{'-'*40}\n{result}")

        return result, elapsed, log_file

def display_tui():
    orchestrator = PrimOrchestrator()
    console.print(Panel(
        "[bold prim.title]🐉 PRIM ORCHESTRATOR v2.1[/]\n[prim.border]Intelligent Multi-Agent System (Memory Active)[/]",
        border_style="prim.border", expand=False
    ))

    if len(sys.argv) > 1:
        mission = " ".join(sys.argv[1:])
    else:
        try:
            mission = console.input("[bold prim.header]prim> [/]")
        except EOFError: return

    if not mission or mission.lower() in ["exit", "quit"]: return

    result, elapsed, log_path = orchestrator.execute_mission(mission)

    console.print(Panel(
        Markdown(result),
        title=f"[prim.header]Mission: {mission}[/]",
        border_style="prim.border",
        subtitle=f"[prim.border]Time: {elapsed:.2f}s | Log: {os.path.basename(log_path)}[/]"
    ))

if __name__ == "__main__":
    try:
        display_tui()
    except KeyboardInterrupt:
        console.print("\n[prim.title]Arrêt de PRIM. À bientôt.[/]")
