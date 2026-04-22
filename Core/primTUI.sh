#!/bin/bash

# PRIM Terminal UI (TUI)
# A refined monitoring interface for the Trinity Intelligence System

# Colors & Styles
P='\033[1;35m' # Purple (PRIM)
G='\033[1;32m' # Green (Success)
Y='\033[1;33m' # Yellow (Warning)
B='\033[1;34m' # Blue (Info)
R='\033[1;31m' # Red (Error)
NC='\033[0m'   # No Color
BOLD='\033[1m'

# Assets
BOX_TOP="┌──────────────────────────────────────────────────────────┐"
BOX_MID="├──────────────────────────────────────────────────────────┤"
BOX_BOT="└──────────────────────────────────────────────────────────┘"

BASE_DIR="$HOME/Prim3IA"
ORCHESTRATOR="$BASE_DIR/Core/orchestrator.sh"

clear_screen() { printf "\033[H\033[J"; }

draw_header() {
    echo -e "${P}${BOX_TOP}${NC}"
    echo -e "${P}│${NC}  ${BOLD}🐉 PRIM ORCHESTRATOR v1.0${NC}                           ${P}│${NC}"
    echo -e "${P}${BOX_MID}${NC}"
}

draw_progress() {
    local label=$1
    local progress=$2 # 0 to 10
    local color=$3
    local bar=""
    for ((i=0; i<10; i++)); do
        [ $i -lt $progress ] && bar="${bar}▌" || bar="${bar}░"
    done
    printf "${P}│${NC} %-10s [%-10s] %s %-12s ${P}│${NC}\n" "$label" "$bar" "$color" "$4"
}

run_mission() {
    local mission="$1"
    local start_time=$(date +%s.%N)
    clear_screen
    draw_header
    
    echo -e "${P}│${NC} ${B}MISSION:${NC} $mission"
    echo -e "${P}│${NC} ${B}STATUS :${NC} ⟳ Running..."
    echo -e "${P}${BOX_MID}${NC}"

    # Agents status initialization
    draw_progress "Agent EU" 3 "${Y}" "⟳ Thinking"
    draw_progress "Agent US" 0 "${NC}" "░ Pending"
    draw_progress "Agent CN" 0 "${NC}" "░ Pending"
    echo -e "${P}${BOX_MID}${NC}"
    
    # Run Orchestrator and capture output
    # Note: We use the existing orchestrator logic but stream it here
    local log_file=$("$ORCHESTRATOR" "$mission" | grep "Log saved to:" | awk '{print $NF}')
    
    # Update UI based on completion
    clear_screen
    draw_header
    echo -e "${P}│${NC} ${B}MISSION:${NC} $mission"
    echo -e "${P}│${NC} ${G}STATUS :${NC} ✅ Complete"
    echo -e "${P}${BOX_MID}${NC}"
    draw_progress "Agent EU" 10 "${G}" "✅ Ready"
    draw_progress "Agent US" 10 "${G}" "✅ Ready"
    draw_progress "Agent CN" 10 "${G}" "✅ Ready"
    echo -e "${P}${BOX_MID}${NC}"
    
    # Live Output Section
    echo -e "${BOLD}  LIVE FEED:${NC}"
    if [ -f "$log_file" ]; then
        tail -n 20 "$log_file" | grep -E "\[.* Response\]|Mission Genesis Complete" -A 5 | sed "s/^/  /"
    fi
    
    local end_time=$(date +%s.%N)
    local elapsed=$(echo "$end_time - $start_time" | bc)
    echo -e "${P}${BOX_BOT}${NC}"
    printf "  execution time [${G}%.2fs${NC}] | log: %s\n\n" "$elapsed" "$(basename $log_file)"
}

# Main Loop
if [ ! -z "$1" ]; then
    run_mission "$1"
else
    while true; do
        clear_screen
        draw_header
        echo -e "${P}│${NC} ${B}COMMANDS:${NC} mission \"desc\" | help | exit             ${P}│${NC}"
        echo -e "${P}${BOX_BOT}${NC}"
        echo -n "prim> "
        read input
        
        case $input in
            mission\ *)
                mission_desc=$(echo $input | cut -d' ' -f2-)
                run_mission "$mission_desc"
                echo -n "Press enter to return..."
                read
                ;;
            exit)
                echo "Goodbye, Orchestrator."
                exit 0
                ;;
            *)
                echo -e "${Y}Invalid command.${NC} Try: mission \"your mission\""
                sleep 1
                ;;
        esac
    done
fi
