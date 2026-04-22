#!/bin/bash

# PRIM Orchestrator - Real Ollama Integration
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

echo -e "${PURPLE}🐉 PRIM ORCHESTRATOR - REAL MISSION${NC}" | tee -a "$LOG_FILE"
echo -e "Mission : $MISSION" | tee -a "$LOG_FILE"
echo -e "Time    : $TIMESTAMP" | tee -a "$LOG_FILE"
echo "------------------------------------------" | tee -a "$LOG_FILE"

execute_agent() {
    local id=$1
    local name=$2
    local model=$3
    local prompt_file="$BASE_DIR/Config/AgentPrompts/${id}Prompt.md"
    
    echo -e "${PURPLE}[PRIM]${NC} Calling Agent ${GREEN}$name${NC} ($model)..." | tee -a "$LOG_FILE"
    
    # Read System Prompt
    local system_prompt=$(cat "$prompt_file")
    
    # Call Ollama API
    local response=$(curl -s -X POST http://localhost:11434/api/generate \
        -d "{
            \"model\": \"$model\",
            \"system\": \"$(echo "$system_prompt" | sed 's/"/\\"/g' | tr -d '\n')\",
            \"prompt\": \"$MISSION\",
            \"stream\": false
        }")
    
    local text=$(echo "$response" | jq -r '.response' 2>/dev/null || echo "Error: No response")
    
    echo -e "${CYAN}[$name Response]:${NC}\n$text" | tee -a "$LOG_FILE"
    echo "------------------------------------------" | tee -a "$LOG_FILE"
}

# Run the Trinity with Real Models
execute_agent "eu" "EU" "mistral:latest"
execute_agent "us" "US" "mistral:latest"
execute_agent "cn" "CN" "deepseek-coder:latest"

echo -e "${PURPLE}[PRIM]${NC} ${GREEN}First Real Mission Complete.${NC}" | tee -a "$LOG_FILE"
echo -e "Log saved to: $LOG_FILE"
