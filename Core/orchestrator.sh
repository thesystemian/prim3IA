#!/bin/bash

# PRIM Orchestrator - CLI-first - Pure Bash
# Usage: ./Core/orchestrator.sh "Mission Name"

MISSION="$1"
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
DATE_FILE=$(date +"%Y%m%d_%H%M%S")
LOG_DIR="$HOME/Prim3IA/Logs"
LOG_FILE="$LOG_DIR/mission_${DATE_FILE}.log"

# Colors
PURPLE='\033[0;35m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Ensure Logs directory exists
mkdir -p "$LOG_DIR"

if [ -z "$MISSION" ]; then
    echo -e "${PURPLE}[PRIM]${NC} Error: Mission argument required."
    exit 1
fi

# Header
echo -e "${PURPLE}🐉 PRIM ORCHESTRATOR${NC}" | tee -a "$LOG_FILE"
echo -e "Mission: $MISSION" | tee -a "$LOG_FILE"
echo -e "Time   : $TIMESTAMP" | tee -a "$LOG_FILE"
echo "------------------------------------------" | tee -a "$LOG_FILE"

# Agents Execution
execute_agent() {
    local name=$1
    local role=$2
    echo -e "${PURPLE}[PRIM]${NC} Calling Agent ${GREEN}$name${NC} ($role)..." | tee -a "$LOG_FILE"
    echo "[$TIMESTAMP] Agent $name started." >> "$LOG_FILE"
    
    # Simulate processing
    sleep 0.5
    
    echo -e "${GREEN}✓ Agent $name Success${NC}" | tee -a "$LOG_FILE"
    echo "------------------------------------------" >> "$LOG_FILE"
}

# Run the Trinity
execute_agent "EU" "Creative Strategy"
execute_agent "US" "Logic & Validation"
execute_agent "CN" "Technical Execution"

# Final Status
echo -e "${PURPLE}[PRIM]${NC} ${GREEN}Mission Genesis Complete.${NC}" | tee -a "$LOG_FILE"
echo -e "Log saved to: $LOG_FILE"
