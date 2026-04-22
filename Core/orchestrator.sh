#!/bin/bash

# PRIM Orchestrator - Unified Single-Agent Architecture
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
NC='\033[0m'

mkdir -p "$LOG_DIR"

if [ -z "$MISSION" ]; then
    echo -e "${PURPLE}[PRIM]${NC} Error: Mission argument required."
    exit 1
fi

echo "LOG_PATH: $LOG_FILE"
echo -e "${PURPLE}🐉 PRIM ORCHESTRATOR - UNIFIED RESPONSE${NC}" | tee -a "$LOG_FILE"
echo -e "Mission : $MISSION" | tee -a "$LOG_FILE"
echo "------------------------------------------" | tee -a "$LOG_FILE"

# Unified System Prompt
SYSTEM_PROMPT="You are PRIM, an intelligent orchestration system created by Dax @thesystemian.
When given a mission, you analyze it through THREE integrated perspectives:

1. CREATIVE (EU Lens): Rare insight, unique angle, cultural/creative depth.
2. LOGICAL (US Lens): Validate the approach, identify risks, contradictions, check feasibility.
3. PRAGMATIC (CN Lens): 3-5 concrete execution steps, realistic timeline.

OUTPUT FORMAT:
[Creative Insight]
└─ [1 sentence: rare angle]

[Validation]
└─ [1-2 sentences: assessment + risks]

[Execution Plan]
└─ [3 concrete steps, numbered]

[Final Recommendation]
└─ [What to do next]

Always respond in FRENCH. Keep output crisp and actionable. No verbosity."

# Unified Call to Ollama
json_payload=$(jq -n \
    --arg model "mistral:latest" \
    --arg system "$SYSTEM_PROMPT" \
    --arg prompt "$MISSION" \
    '{model: $model, system: $system, prompt: $prompt, stream: false}')

response=$(curl -s -X POST http://localhost:11434/api/generate -d "$json_payload")
text=$(echo "$response" | jq -r '.response' 2>/dev/null || echo "Error: No response")

# Write to Log
echo "$text" >> "$LOG_FILE"
echo "------------------------------------------" >> "$LOG_FILE"

echo -e "${PURPLE}[PRIM]${NC} ${GREEN}Mission Complete.${NC}" | tee -a "$LOG_FILE"
