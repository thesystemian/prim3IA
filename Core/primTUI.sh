#!/bin/bash

# PRIM Terminal UI (TUI) - Professional Refined Edition
# Structured output with Morandi harmonic palette

# Colors (Morandi palette)
BORDER='\033[38;5;244m'
HEADER='\033[38;5;179m'
STATUS='\033[38;5;180m'
TEXT='\033[38;5;252m'
P='\033[38;5;167m'       # EU (Terracotta)
A_US='\033[38;5;109m'    # US (Blue-gray)
A_CN='\033[38;5;179m'    # CN (Ocre)
SYNTH='\033[37m'         # Synthesis (White)
BAR_FG='\033[38;5;224m'  # Beige
NC='\033[0m'
BOLD='\033[1m'

BASE_DIR="$HOME/Prim3IA"
ORCHESTRATOR="$BASE_DIR/Core/orchestrator.sh"
MODE="summary" # Default mode

clear_screen() { printf "\033[H\033[J"; }

draw_header() {
    echo -e "${BORDER}┌──────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BORDER}│${NC}  ${P}${BOLD}🐉 PRIM ORCHESTRATOR v1.3${NC}                           ${BORDER}│${NC}"
    echo -e "${BORDER}├──────────────────────────────────────────────────────────┤${NC}"
}

draw_progress() {
    local label=$1
    local progress=$2
    local color=$3
    local bar=""
    for ((i=0; i<10; i++)); do
        [ $i -lt $progress ] && bar="${bar}${BAR_FG}▌${NC}" || bar="${bar}${BORDER}░${NC}"
    done
    printf "${BORDER}│${NC} ${color}%-10s${NC} [${bar}] %-15s ${BORDER}│${NC}\n" "$label" "$4"
}

format_output() {
    local log=$1
    local mode=$2

    echo -e "\n  ${BOLD}MISSION RESULTS [MODE: ${mode^^}]${NC}"
    echo -e "  ${BORDER}------------------------------------------------${NC}"

    case $mode in
        summary)
            # EU Insight
            echo -e "  ${P}[EU Agent] Creative Insight${NC}"
            local eu_raw=$(sed -n '/\[EU Response\]:/,/---/p' "$log" | grep -vE "\[EU Response\]:|---" | head -n 4 | tr -d '\n')
            echo -e "  └─ ${TEXT}${eu_raw:0:150}...${NC}\n"

            # US Validation
            echo -e "  ${A_US}[US Agent] Validation${NC}"
            local us_raw=$(sed -n '/\[US Response\]:/,/---/p' "$log" | grep -vE "\[US Response\]:|---" | head -n 4 | tr -d '\n')
            echo -e "  └─ ${TEXT}${us_raw:0:150}...${NC}\n"

            # CN Plan
            echo -e "  ${A_CN}[CN Agent] Execution Plan${NC}"
            sed -n '/\[CN Response\]:/,/---/p' "$log" | grep -E "^-|^[0-9]\." | head -n 3 | sed "s/^/  /" | sed "s/^  /  └─ /"
            
            # Synthesis
            echo -e "\n  ${SYNTH}${BOLD}[PRIM Synthesis] Final Recommendation${NC}"
            echo -e "  └─ ${TEXT}La mission est cohérente. Procéder à l'exécution selon le plan CN.${NC}"
            ;;
        full)
            cat "$log" | sed "s/^/  /"
            ;;
        action)
            echo -e "  ${A_CN}${BOLD}NEXT STEPS ONLY:${NC}"
            sed -n '/\[CN Response\]:/,/---/p' "$log" | grep -E "^-|^[0-9]\." | sed "s/^/  /"
            ;;
    esac
}

run_mission() {
    local mission="$1"
    local start_time=$(date +%s.%N)
    clear_screen
    draw_header
    
    echo -e "${BORDER}│${NC} ${HEADER}MISSION:${NC} ${TEXT}$mission${NC}"
    echo -e "${BORDER}│${NC} ${STATUS}STATUS :${NC} ${BOLD}⟳ Running...${NC}"
    echo -e "${BORDER}├──────────────────────────────────────────────────────────┤${NC}"

    draw_progress "Agent EU" 3 "${P}" "⟳ Thinking"
    draw_progress "Agent US" 0 "${NC}" "░ Waiting"
    draw_progress "Agent CN" 3 "${A_CN}" "⟳ Thinking"
    echo -e "${BORDER}└──────────────────────────────────────────────────────────┘${NC}"
    
    # Run Orchestrator
    local log_file=""
    "$ORCHESTRATOR" "$mission" > /tmp/prim_run.txt 2>&1 &
    local orch_pid=$!
    
    while kill -0 $orch_pid 2>/dev/null; do
        sleep 2
        [ -z "$log_file" ] && log_file=$(grep "LOG_PATH:" /tmp/prim_run.txt | cut -d' ' -f2)
        [ ! -z "$log_file" ] && [ -f "$log_file" ] && echo -n "."
    done

    clear_screen
    draw_header
    echo -e "${BORDER}│${NC} ${HEADER}MISSION:${NC} ${TEXT}$mission${NC}"
    echo -e "${BORDER}│${NC} ${STATUS}STATUS :${NC} ${TEXT}✅ Complete${NC}"
    echo -e "${BORDER}├──────────────────────────────────────────────────────────┤${NC}"
    draw_progress "Agent EU" 10 "${P}" "✅ Ready"
    draw_progress "Agent US" 10 "${A_US}" "✅ Ready"
    draw_progress "Agent CN" 10 "${A_CN}" "✅ Ready"
    echo -e "${BORDER}└──────────────────────────────────────────────────────────┘${NC}"
    
    [ -z "$log_file" ] && log_file=$(grep "LOG_PATH:" /tmp/prim_run.txt | cut -d' ' -f2)
    format_output "$log_file" "$MODE"
    
    local end_time=$(date +%s.%N)
    local elapsed=$(echo "$end_time - $start_time" | bc)
    printf "\n  ${BORDER}time [${HEADER}%.2fs${NC}${BORDER}] | mode: ${MODE}${NC}\n" "$elapsed"
}

# Main Loop
if [ ! -z "$1" ]; then
    run_mission "$1"
else
    while true; do
        clear_screen
        draw_header
        echo -e "${BORDER}│${NC} ${STATUS}MODES   :${NC} summary | full | action                     ${BORDER}│${NC}"
        echo -e "${BORDER}│${NC} ${STATUS}COMMANDS:${NC} mission \"desc\" | exit | mode [m]          ${BORDER}│${NC}"
        echo -e "${BORDER}└──────────────────────────────────────────────────────────┘${NC}"
        echo -n -e "${P}prim [${MODE}]> ${NC}"
        read input
        case $input in
            exit) exit 0 ;;
            mode\ *) MODE=$(echo $input | awk '{print $2}') ;;
            mission\ *) run_mission "$(echo $input | cut -d' ' -f2-)" && read ;;
            *) [ ! -z "$input" ] && run_mission "$input" && read ;;
        esac
    done
fi
