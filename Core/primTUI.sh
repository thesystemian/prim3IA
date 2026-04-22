#!/bin/bash

# PRIM Terminal UI (TUI) - Morandi Edition
# A harmonic, watercolor-style monitoring interface

# Morandi Color Palette (ANSI 256 colors)
P='\033[38;5;131m'   # Terracotta (PRIM Title)
A='\033[38;5;66m'    # Blue-Gray (Agents)
PB='\033[38;5;137m'  # Yellow Ocre (Progress Bar)
S='\033[38;5;188m'   # Soft Beige (Success/Text)
B='\033[38;5;60m'    # Muted Blue (Info)
Y='\033[38;5;137m'   # Ocre (Warning)
NC='\033[0m'         # No Color
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
    echo -e "${P}│${NC}  ${BOLD}🐉 PRIM ORCHESTRATOR v1.1${NC}                           ${P}│${NC}"
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
    printf "${P}│${NC} ${A}%-10s${NC} ${PB}[%-10s]${NC} %s %-12s ${P}│${NC}\n" "$label" "$bar" "$color" "$4"
}

run_mission() {
    local mission="$1"
    local start_time=$(date +%s.%N)
    clear_screen
    draw_header
    
    echo -e "${P}│${NC} ${B}MISSION:${NC} ${S}$mission${NC}"
    echo -e "${P}│${NC} ${B}STATUS :${NC} ${Y}⟳ Running...${NC}"
    echo -e "${P}${BOX_MID}${NC}"

    # Agents status initialization
    draw_progress "Agent EU" 3 "${Y}" "⟳ Thinking"
    draw_progress "Agent US" 0 "${NC}" "░ Pending"
    draw_progress "Agent CN" 0 "${NC}" "░ Pending"
    echo -e "${P}${BOX_MID}${NC}"
    
    # Run Orchestrator and capture output
    local log_file=$("$ORCHESTRATOR" "$mission" | grep "Log saved to:" | awk '{print $NF}')
    
    # Update UI based on completion
    clear_screen
    draw_header
    echo -e "${P}│${NC} ${B}MISSION:${NC} ${S}$mission${NC}"
    echo -e "${P}│${NC} ${S}STATUS :${NC} ${S}✅ Complete${NC}"
    echo -e "${P}${BOX_MID}${NC}"
    draw_progress "Agent EU" 10 "${S}" "✅ Ready"
    draw_progress "Agent US" 10 "${S}" "✅ Ready"
    draw_progress "Agent CN" 10 "${S}" "✅ Ready"
    echo -e "${P}${BOX_MID}${NC}"
    
    # Live Output Section
    echo -e "  ${A}${BOLD}LIVE FEED:${NC}"
    if [ -f "$log_file" ]; then
        # Muted text for live feed
        tail -n 20 "$log_file" | grep -E "\[.* Response\]|Mission Genesis Complete" -A 5 | sed "s/^/  /" | sed "s/Response/${S}Response${NC}/g"
    fi
    
    local end_time=$(date +%s.%N)
    local elapsed=$(echo "$end_time - $start_time" | bc)
    echo -e "${P}${BOX_BOT}${NC}"
    printf "  ${A}execution time [${S}%.2fs${NC}${A}] | log: %s${NC}\n\n" "$elapsed" "$(basename $log_file)"
}

# Main Loop
if [ ! -z "$1" ]; then
    run_mission "$1"
else
    while true; do
        clear_screen
        draw_header
        echo -e "${P}│${NC} ${B}COMMANDS:${NC} ${A}mission \"desc\" | help | exit${NC}             ${P}│${NC}"
        echo -e "${P}${BOX_BOT}${NC}"
        echo -n -e "${P}prim> ${NC}"
        read input
        
        case $input in
            mission\ *)
                mission_desc=$(echo $input | cut -d' ' -f2-)
                run_mission "$mission_desc"
                echo -n -e "${A}Press enter to return...${NC}"
                read
                ;;
            exit)
                echo -e "${A}Goodbye, Orchestrator.${NC}"
                exit 0
                ;;
            *)
                echo -e "${Y}Invalid command.${NC} Try: mission \"your mission\""
                sleep 1
                ;;
        esac
    done
fi
