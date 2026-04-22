#!/bin/bash

# PRIM Orchestrator - Optimized Parallel Integration
# Usage: ./Core/orchestrator.sh "Mission Name"

MISSION="$1"
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
DATE_FILE=$(date +"%Y%m%d_%H%M%S")
BASE_DIR="$HOME/Prim3IA"
LOG_DIR="$BASE_DIR/Logs"
LOG_FILE="$LOG_DIR/mission_${DATE_FILE}.log"

# Colors
PURPLE='\033[0;35m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

mkdir -p "$LOG_DIR"

if [ -z "$MISSION" ]; then
    echo -e "${PURPLE}[PRIM]${NC} Error: Mission argument required."
    exit 1
fi

# IMPORTANT: Print the log file path immediately for TUI to catch it
echo "LOG_PATH: $LOG_FILE"

echo -e "${PURPLE}🐉 PRIM ORCHESTRATOR - OPTIMIZED PARALLEL${NC}" | tee -a "$LOG_FILE"
echo -e "Mission : $MISSION" | tee -a "$LOG_FILE"
echo -e "Time    : $TIMESTAMP" | tee -a "$LOG_FILE"
echo "------------------------------------------" | tee -a "$LOG_FILE"

execute_agent() {
    local id=$1
    local name=$2
    local model=$3
    local prompt_file="$BASE_DIR/Config/AgentPrompts/${id}Prompt.md"
    local system_prompt=$(cat "$prompt_file")
    
    local response=$(curl -s -X POST http://localhost:11434/api/generate \
        -d "{
            \"model\": \"$model\",
            \"system\": \"$(echo "$system_prompt" | sed 's/"/\\"/g' | tr -d '\n')\",
            \"prompt\": \"$MISSION\",
            \"stream\": false
        }")
    
    local text=$(echo "$response" | jq -r '.response' 2>/dev/null || echo "Error: No response from Ollama")
    
    {
        echo -e "${CYAN}[$name Response]:${NC}"
        echo "$text"
        echo "------------------------------------------"
    } >> "$LOG_FILE"
}

# PHASE 1: EU (Creative) & CN (Technical) in parallel
execute_agent "eu" "EU" "mistral:latest" &
PID_EU=$!
execute_agent "cn" "CN" "deepseek-coder:latest" &
PID_CN=$!

wait $PID_EU $PID_CN

# PHASE 2: US (Logic/Validation) starts after receiving inputs
execute_agent "us" "US" "mistral:latest"

echo -e "${PURPLE}[PRIM]${NC} ${GREEN}Mission Complete.${NC}" | tee -a "$LOG_FILE"
