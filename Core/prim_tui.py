#!/usr/bin/env python3
import sys
import time
import json
import requests
import os
from datetime import datetime
from rich.console import Console
from rich.panel import Panel
from rich.live import Live
from rich.progress import Progress, SpinnerColumn, BarColumn, TextColumn
from rich.layout import Layout
from rich.markdown import Markdown
from rich.theme import Theme

# Morandi Palette Theme
MORANDI_THEME = Theme({
    "prim.title": "#A0523D",       # Terracotta
    "prim.border": "#8E8E8E",      # Soft Gray
    "prim.header": "#D4A574",      # Warm Ocre
    "prim.text": "#E8DCC8",        # Soft Beige
    "prim.agent_eu": "#A0523D",
    "prim.agent_us": "#5A7C8C",
    "prim.agent_cn": "#D4A574",
})

console = Console(theme=MORANDI_THEME)

BASE_DIR = os.path.expanduser("~/Prim3IA")
LOG_DIR = os.path.join(BASE_DIR, "Logs")

class PrimOrchestrator:
    def __init__(self):
        self.session_file = os.path.join(LOG_DIR, "session_current.txt")
        if not os.path.exists(LOG_DIR):
            os.makedirs(LOG_DIR)

    def execute_mission(self, mission):
        start_time = time.time()
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        date_file = datetime.now().strftime("%Y%m%d_%H%M%S")
        log_file = os.path.join(LOG_DIR, f"mission_{date_file}.log")

        # System Prompt
        system_prompt = """You are PRIM, an intelligent orchestration system created by Dax @thesystemian.
Analyze the mission through THREE integrated perspectives (EU-Creative, US-Logical, CN-Pragmatic).
Always respond in FRENCH. Use Markdown for formatting.
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
            task = progress.add_task("🧠 PRIM réfléchit via la Trinité...", total=None)
            
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
            except Exception as e:
                result = f"❌ Erreur de connexion à Ollama : {str(e)}"

        elapsed = time.time() - start_time
        
        # Sauvegarde Log
        with open(log_file, "w") as f:
            f.write(f"MISSION: {mission}\nTIME: {timestamp}\n{'-'*40}\n{result}")

        return result, elapsed, log_file

def display_tui():
    orchestrator = PrimOrchestrator()
    
    # Header
    console.print(Panel(
        "[bold prim.title]🐉 PRIM ORCHESTRATOR v2.0[/]\n[prim.border]Intelligent Multi-Agent System[/]",
        border_style="prim.border",
        expand=False
    ))

    if len(sys.argv) > 1:
        mission = " ".join(sys.argv[1:])
    else:
        mission = console.input("[bold prim.header]prim> [/]")

    if mission.lower() in ["exit", "quit"]:
        return

    result, elapsed, log_path = orchestrator.execute_mission(mission)

    # Result Display
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
        console.print("\n[prim.agent_eu]Arrêt de PRIM. À bientôt.[/]")
