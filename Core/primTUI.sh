#!/bin/bash

# PRIM Terminal UI (TUI) - Morandi Refined Edition
# Harmonic palette with high readability contrast

# Morandi Refined Palette (ANSI 256 colors)
BORDER='\033[38;5;244m'  # Soft Gray
HEADER='\033[38;5;179m'  # Warm Yellow (MISSION)
STATUS='\033[38;5;180m'  # Soft Ocre (STATUS)
TEXT='\033[38;5;252m'    # Light Gray (Readable Text)
P='\033[38;5;167m'       # Soft Red Terracotta (PRIM/EU)
A_US='\033[38;5;109m'    # Soft Blue-Gray (US Agent)
A_CN='\033[38;5;179m'    # Warm Yellow-Ocre (CN Agent)
BAR_FG='\033[38;5;224m'  # Beige (Active Progress)
NC='\033[0m'             # No Color
BOLD='\033[1m'

# Assets
BOX_TOP="┌──────────────────────────────────────────────────────────┐"
BOX_MID="├──────────────────────────────────────────────────────────┤"
BOX_BOT="└──────────────────────────────────────────────────────────┘"

BASE_DIR="$HOME/Prim3IA"
ORCHESTRATOR="$BASE_DIR/Core/orchestrator.sh"

clear_screen() { printf "\033[H\033[J"; }

draw_header() {
    echo -e "${BORDER}${BOX_TOP}${NC}"
    echo -e "${BORDER}│${NC}  ${P}${BOLD}🐉 PRIM ORCHESTRATOR v1.2${NC}                           ${BORDER}│${NC}"
    echo -e "${BORDER}${BOX_MID}${NC}"
}

draw_progress() {
    local label=$1
    local progress=$2 # 0 to 10
    local color=$3
    local agent_color=$4
    local bar=""
    for ((i=0; i<10; i++)); do
        [ $i -lt $progress ] && bar="${bar}${BAR_FG}▌${NC}" || bar="${bar}${BORDER}░${NC}"
    done
    printf "${BORDER}│${NC} ${agent_color}%-10s${NC} [${bar}] ${color}%-12s${NC} ${BORDER}│${NC}\n" "$label" "$5"
}

run_mission() {
    local mission="$1"
    local start_time=$(date +%s.%N)
    clear_screen
    draw_header
    
    echo -e "${BORDER}│${NC} ${HEADER}MISSION:${NC} ${TEXT}$mission${NC}"
    echo -e "${BORDER}│${NC} ${STATUS}STATUS :${NC} ${BOLD}⟳ Running...${NC}"
    echo -e "${BORDER}${BOX_MID}${NC}"

    # Agents status initialization
    draw_progress "Agent EU" 3 "${P}" "${P}" "⟳ Thinking"
    draw_progress "Agent US" 0 "${NC}" "${A_US}" "░ Pending"
    draw_progress "Agent CN" 0 "${NC}" "${A_CN}" "░ Pending"
    echo -e "${BORDER}${BOX_MID}${NC}"
    
    # Run Orchestrator and capture output
    local log_file=$("$ORCHESTRATOR" "$mission" | grep "Log saved to:" | awk '{print $NF}')
    
    # Update UI based on completion
    clear_screen
    draw_header
    echo -e "${BORDER}│${NC} ${HEADER}MISSION:${NC} ${TEXT}$mission${NC}"
    echo -e "${BORDER}│${NC} ${STATUS}STATUS :${NC} ${TEXT}✅ Complete${NC}"
    echo -e "${BORDER}${BOX_MID}${NC}"
    draw_progress "Agent EU" 10 "${TEXT}" "${P}" "✅ Ready"
    draw_progress "Agent US" 10 "${TEXT}" "${A_US}" "✅ Ready"
    draw_progress "Agent CN" 10 "${TEXT}" "${A_CN}" "✅ Ready"
    echo -e "${BORDER}${BOX_MID}${NC}"
    
    # Live Output Section
    echo -e "  ${HEADER}${BOLD}LIVE FEED:${NC}"
    if [ -f "$log_file" ]; then
        tail -n 25 "$log_file" | grep -E "\[.* Response\]|Mission Genesis Complete" -A 5 | sed "s/^/  /" | sed "s/Response/${TEXT}Response${NC}/g"
    fi
    
    local end_time=$(date +%s.%N)
    local elapsed=$(echo "$end_time - $start_time" | bc)
    echo -e "${BORDER}${BOX_BOT}${NC}"
    printf "  ${BORDER}execution time [${HEADER}%.2fs${NC}${BORDER}] | log: %s${NC}\n\n" "$elapsed" "$(basename $log_file)"
}

# Main Loop
if [ ! -z "$1" ]; then
    run_mission "$1"
else
    while true; do
        clear_screen
        draw_header
        echo -e "${BORDER}│${NC} ${STATUS}COMMANDS:${NC} ${TEXT}mission \"desc\" | help | exit${NC}             ${BORDER}│${NC}"
        echo -e "${BORDER}${BOX_BOT}${NC}"
        echo -n -e "${P}prim> ${NC}"
        read input
        
        case $input in
            mission\ *)
                mission_desc=$(echo $input | cut -d' ' -f2-)
                run_mission "$mission_desc"
                echo -n -e "${TEXT}Press enter to return...${NC}"
                read
                ;;
            exit)
                echo -e "${TEXT}Goodbye, Orchestrator.${NC}"
                exit 0
                ;;
            *)
                echo -e "${STATUS}Invalid command.${NC} Try: mission \"your mission\""
                sleep 1
                ;;
        esac
    done
fi
