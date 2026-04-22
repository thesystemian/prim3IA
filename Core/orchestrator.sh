#!/bin/bash

# PRIM Orchestrator - Reliable JSON + Session Memory
# Usage: ./Core/orchestrator.sh "Mission Name"

MISSION="$1"
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
DATE_FILE=$(date +"%Y%m%d_%H%M%S")
BASE_DIR="$HOME/Prim3IA"
LOG_DIR="$BASE_DIR/Logs"
LOG_FILE="$LOG_DIR/mission_${DATE_FILE}.log"
SESSION_FILE="$LOG_DIR/session_current.txt"

# Colors
PURPLE='\033[0;35m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

mkdir -p "$LOG_DIR"
[ ! -f "$SESSION_FILE" ] && touch "$SESSION_FILE"

if [ -z "$MISSION" ]; then
    echo -e "${PURPLE}[PRIM]${NC} Error: Mission argument required."
    exit 1
fi

echo "LOG_PATH: $LOG_FILE"
echo -e "${PURPLE}🐉 PRIM ORCHESTRATOR - INTELLIGENT PARALLEL${NC}" | tee -a "$LOG_FILE"
echo -e "Mission : $MISSION" | tee -a "$LOG_FILE"
echo "------------------------------------------" | tee -a "$LOG_FILE"

execute_agent() {
    local id=$1
    local name=$2
    local model=$3
    local prompt_file="$BASE_DIR/Config/AgentPrompts/${id}Prompt.md"
    
    # Construction du prompt avec mémoire
    local system_prompt=$(cat "$prompt_file")
    local history=$(tail -n 20 "$SESSION_FILE" 2>/dev/null) # 20 dernières lignes de mémoire
    
    local full_prompt="MISSION ACTUELLE: $MISSION\n\nCONTEXTE DE SESSION:\n$history"

    # Appel Ollama avec jq pour un JSON parfait
    local json_payload=$(jq -n \
        --arg model "$model" \
        --arg system "$system_prompt" \
        --arg prompt "$full_prompt" \
        '{model: $model, system: $system, prompt: $prompt, stream: false}')

    local response=$(curl -s -X POST http://localhost:11434/api/generate -d "$json_payload")
    local text=$(echo "$response" | jq -r '.response' 2>/dev/null || echo "Error: No response")
    
    {
        echo -e "${CYAN}[$name Response]:${NC}"
        echo "$text"
        echo "------------------------------------------"
    } >> "$LOG_FILE"
    
    # Update Session Memory (async-safe append)
    echo "Mission: $MISSION | Agent $name: ${text:0:100}..." >> "$SESSION_FILE"
}

# PHASE 1: EU & CN
execute_agent "eu" "EU" "mistral:latest" &
PID_EU=$!
execute_agent "cn" "CN" "deepseek-coder:latest" &
PID_CN=$!

wait $PID_EU $PID_CN

# PHASE 2: US
execute_agent "us" "US" "mistral:latest"

echo -e "${PURPLE}[PRIM]${NC} ${GREEN}Mission Complete.${NC}" | tee -a "$LOG_FILE"
