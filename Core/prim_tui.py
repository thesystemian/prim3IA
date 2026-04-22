#!/usr/bin/env python3
import sys
import time
import requests
import os
from datetime import datetime
from rich.console import Console
from rich.panel import Panel
from rich.progress import Progress, SpinnerColumn, BarColumn, TextColumn
from rich.markdown import Markdown
from rich.theme import Theme

MORANDI_THEME = Theme({
    "prim.title": "#A0523D",
    "prim.border": "#8E8E8E",
    "prim.header": "#D4A574",
    "prim.text": "#E8DCC8",
})

console = Console(theme=MORANDI_THEME)
BASE_DIR = os.path.expanduser("~/Prim3IA")
LOG_DIR = os.path.join(BASE_DIR, "Logs")
SESSION_FILE = os.path.join(LOG_DIR, "session_current.txt")

class PrimOrchestrator:
    def __init__(self):
        if not os.path.exists(LOG_DIR):
            os.makedirs(LOG_DIR)

    def execute_mission(self, mission):
        # 1. RESET: Fresh variables for every mission
        result = ""
        start_time = time.time()
        date_file = datetime.now().strftime("%Y%m%d_%H%M%S")
        log_file = os.path.join(LOG_DIR, f"mission_{date_file}.log")

        # Get history for prompt but NOT for display
        history = ""
        if os.path.exists(SESSION_FILE):
            with open(SESSION_FILE, "r") as f:
                history = "".join(f.readlines()[-20:])

        system_prompt = f"""You are PRIM, created by Dax @thesystemian.
Respond in FRENCH. Use Markdown. Integrate 3 perspectives (EU, US, CN).
MEMORY OF SESSION:
{history}
Do NOT repeat the history in your response. Focus ONLY on the new mission."""

        with Progress(
            SpinnerColumn(),
            TextColumn("[prim.header]{task.description}"),
            BarColumn(bar_width=20, pulse_style="prim.header"),
            console=console,
            transient=True,
        ) as progress:
            task = progress.add_task("🧠 PRIM réfléchit...", total=None)
            try:
                payload = {"model": "mistral:latest", "system": system_prompt, "prompt": mission, "stream": False}
                response = requests.post("http://localhost:11434/api/generate", json=payload, timeout=90)
                result = response.json().get("response", "Erreur: Pas de réponse")
                
                # Update Session Memory
                with open(SESSION_FILE, "a") as f:
                    f.write(f"Mission: {mission} | Result: {result[:100]}...\n")
            except Exception as e:
                result = f"❌ Erreur: {str(e)}"

        elapsed = time.time() - start_time
        with open(log_file, "w") as f:
            f.write(f"--- START ---\n{result}\n--- END ---")

        return result, elapsed, log_file

def run_loop():
    orchestrator = PrimOrchestrator()
    while True:
        console.clear()
        console.print(Panel("[bold prim.title]🐉 PRIM ORCHESTRATOR v2.2[/]", border_style="prim.border", expand=False))
        try:
            mission = console.input("[bold prim.header]prim> [/]")
        except: break

        if not mission or mission.lower() in ["exit", "quit"]: break

        result, elapsed, log_path = orchestrator.execute_mission(mission)
        console.print(Panel(Markdown(result), title=f"[prim.header]{mission}[/]", border_style="prim.border"))
        console.input(f"\n[prim.header]Time: {elapsed:.2f}s | Press Enter...[/]")

if __name__ == "__main__":
    run_loop()
