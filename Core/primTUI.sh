#!/bin/bash

# PRIM Terminal UI (TUI) - Professional Refined Edition
# Structured output with Morandi harmonic palette

# Colors (Morandi palette)
BORDER='\033[38;5;244m'
HEADER='\033[38;5;179m'
STATUS='\033[38;5;180m'
TEXT='\033[38;5;252m'
P='\033[38;5;167m'
NC='\033[0m'
BOLD='\033[1m'

BASE_DIR="$HOME/Prim3IA"
ORCHESTRATOR="$BASE_DIR/Core/orchestrator.sh"

clear_screen() { printf "\033[H\033[J"; }

draw_header() {
    echo -e "${BORDER}┌──────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BORDER}│${NC}  ${P}${BOLD}🐉 PRIM ORCHESTRATOR v1.6${NC}                           ${BORDER}│${NC}"
    echo -e "${BORDER}├──────────────────────────────────────────────────────────┤${NC}"
}

draw_progress() {
    local label=$1
    local progress=$2
    local bar=""
    for ((i=0; i<10; i++)); do
        [ $i -lt $progress ] && bar="${bar}${P}▌${NC}" || bar="${bar}${BORDER}░${NC}"
    done
    printf "${BORDER}│${NC} %-15s [${bar}] %-30s ${BORDER}│${NC}\n" "$label" "$3"
}

run_mission() {
    local mission="$1"
    local start_time=$(date +%s.%N)
    
    # 1. RESET: Clear any previous mission data
    local log_file=""
    rm -f /tmp/prim_run.txt
    
    clear_screen
    draw_header
    echo -e "${BORDER}│${NC} ${HEADER}MISSION:${NC} ${TEXT}$mission${NC}"
    echo -e "${BORDER}│${NC} ${STATUS}STATUS :${NC} ${BOLD}⟳ Internal Analysis...${NC}"
    echo -e "${BORDER}├──────────────────────────────────────────────────────────┤${NC}"
    draw_progress "Thinking" 4 "Integrating 3 Perspectives"
    echo -e "${BORDER}└──────────────────────────────────────────────────────────┘${NC}"
    
    # 2. ACT: Run Orchestrator and capture EXACT log path
    "$ORCHESTRATOR" "$mission" > /tmp/prim_run.txt 2>&1 &
    local orch_pid=$!
    
    while kill -0 $orch_pid 2>/dev/null; do
        sleep 1
        [ -z "$log_file" ] && log_file=$(grep "LOG_PATH:" /tmp/prim_run.txt | cut -d' ' -f2)
    done

    # 3. DISPLAY: Show ONLY the fresh result
    clear_screen
    draw_header
    echo -e "${BORDER}│${NC} ${HEADER}MISSION:${NC} ${TEXT}$mission${NC}"
    echo -e "${BORDER}│${NC} ${STATUS}STATUS :${NC} ${TEXT}✅ Complete${NC}"
    echo -e "${BORDER}├──────────────────────────────────────────────────────────┤${NC}"
    draw_progress "Ready" 10 "Analysis Finalized"
    echo -e "${BORDER}└──────────────────────────────────────────────────────────┘${NC}"
    
    echo -e "\n  ${BOLD}UNIFIED RESPONSE${NC}"
    echo -e "  ${BORDER}------------------------------------------------${NC}"
    
    if [ ! -z "$log_file" ] && [ -f "$log_file" ]; then
        # Extraction propre: on prend tout ce qui est entre les lignes de séparation du log frais
        sed -n '/------------------------------------------/,/------------------------------------------/p' "$log_file" | sed '1d;$d' | sed 's/^/  /'
    else
        echo -e "  ${P}Error: Log file not found or empty.${NC}"
    fi
    
    local end_time=$(date +%s.%N)
    local elapsed=$(echo "$end_time - $start_time" | bc)
    echo -e "${BORDER}└──────────────────────────────────────────────────────────┘${NC}"
    printf "  ${BORDER}time [${HEADER}%.2fs${NC}${BORDER}] | log: %s${NC}\n" "$elapsed" "$(basename "$log_file")"
    
    echo -e "\n${HEADER}Press enter to continue...${NC}"
    read
}

# Main Loop
while true; do
    clear_screen
    draw_header
    echo -e "${BORDER}│${NC} ${STATUS}COMMANDS:${NC} mission \"desc\" | exit                    ${BORDER}│${NC}"
    echo -e "${BORDER}└──────────────────────────────────────────────────────────┘${NC}"
    echo -n -e "${P}prim> ${NC}"
    read input
    case $input in
        exit) exit 0 ;;
        *) [ ! -z "$input" ] && run_mission "$input" ;;
    esac
done
