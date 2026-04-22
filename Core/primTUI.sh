#!/bin/bash

# PRIM Terminal UI (TUI) - Unified Edition
# Harmonic palette with high readability contrast

BORDER='\033[38;5;244m'
HEADER='\033[38;5;179m'
STATUS='\033[38;5;180m'
TEXT='\033[38;5;252m'
P='\033[38;5;167m'
BAR_FG='\033[38;5;224m'
NC='\033[0m'
BOLD='\033[1m'

BASE_DIR="$HOME/Prim3IA"
ORCHESTRATOR="$BASE_DIR/Core/orchestrator.sh"
MODE="summary"

clear_screen() { printf "\033[H\033[J"; }

draw_header() {
    echo -e "${BORDER}┌──────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BORDER}│${NC}  ${P}${BOLD}🐉 PRIM ORCHESTRATOR v1.4${NC}                           ${BORDER}│${NC}"
    echo -e "${BORDER}├──────────────────────────────────────────────────────────┤${NC}"
}

draw_progress() {
    local label=$1
    local progress=$2
    local bar=""
    for ((i=0; i<10; i++)); do
        [ $i -lt $progress ] && bar="${bar}${BAR_FG}▌${NC}" || bar="${bar}${BORDER}░${NC}"
    done
    printf "${BORDER}│${NC} ${P}%-15s${NC} [${bar}] %-30s ${BORDER}│${NC}\n" "$label" "$3"
}

run_mission() {
    local mission="$1"
    local start_time=$(date +%s.%N)
    clear_screen
    draw_header
    
    echo -e "${BORDER}│${NC} ${HEADER}MISSION:${NC} ${TEXT}$mission${NC}"
    echo -e "${BORDER}│${NC} ${STATUS}STATUS :${NC} ${BOLD}⟳ Internal Analysis...${NC}"
    echo -e "${BORDER}├──────────────────────────────────────────────────────────┤${NC}"
    draw_progress "Thinking" 4 "Processing 3 Lenses"
    echo -e "${BORDER}└──────────────────────────────────────────────────────────┘${NC}"
    
    # Run Orchestrator
    local log_file=""
    "$ORCHESTRATOR" "$mission" > /tmp/prim_run.txt 2>&1 &
    local orch_pid=$!
    
    while kill -0 $orch_pid 2>/dev/null; do
        sleep 2
        [ -z "$log_file" ] && log_file=$(grep "LOG_PATH:" /tmp/prim_run.txt | cut -d' ' -f2)
    done

    clear_screen
    draw_header
    echo -e "${BORDER}│${NC} ${HEADER}MISSION:${NC} ${TEXT}$mission${NC}"
    echo -e "${BORDER}│${NC} ${STATUS}STATUS :${NC} ${TEXT}✅ Complete${NC}"
    echo -e "${BORDER}├──────────────────────────────────────────────────────────┤${NC}"
    draw_progress "Ready" 10 "All Perspectives Integrated"
    echo -e "${BORDER}└──────────────────────────────────────────────────────────┘${NC}"
    
    [ -z "$log_file" ] && log_file=$(grep "LOG_PATH:" /tmp/prim_run.txt | cut -d' ' -f2)
    
    echo -e "\n  ${BOLD}INTEGRATED RESPONSE${NC}"
    echo -e "  ${BORDER}------------------------------------------------${NC}"
    if [ -f "$log_file" ]; then
        # On affiche tout car l'agent est déjà concis
        sed -n '/------------------------------------------/,/------------------------------------------/p' "$log_file" | sed '1d;$d' | sed 's/^/  /'
    fi
    
    local end_time=$(date +%s.%N)
    local elapsed=$(echo "$end_time - $start_time" | bc)
    echo -e "${BORDER}└──────────────────────────────────────────────────────────┘${NC}"
    printf "  ${BORDER}time [${HEADER}%.2fs${NC}${BORDER}] | log: %s${NC}\n\n" "$elapsed" "$(basename "$log_file")"
}

if [ ! -z "$1" ]; then
    run_mission "$1"
else
    while true; do
        clear_screen
        draw_header
        echo -e "${BORDER}│${NC} ${STATUS}COMMANDS:${NC} mission \"desc\" | exit                    ${BORDER}│${NC}"
        echo -e "${BORDER}└──────────────────────────────────────────────────────────┘${NC}"
        echo -n -e "${P}prim> ${NC}"
        read input
        case $input in
            exit) exit 0 ;;
            *) [ ! -z "$input" ] && run_mission "$input" && read ;;
        esac
    done
fi
