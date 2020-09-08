#!/bin/bash

# This is a script created to program nRF bluetooth chips. Specificially,
# the nRF52840. The register addresses are gotten from infocenter.nordicsemi.no.
# The script contains hard-coded paths to files that may need to changed if files are 
# moved.

# This prints some information if the nrfjprog command is used incorrectly.
read -d '' USAGE <<- EOF
This is a loose shell port of the nrfjprog.exe program, which
relies on JLinkExe to interface with the JLink hardware.

Usage for flash actions:
    nrfjprog.sh <action> [hexfile] [DEVICE]

Usage for other actions:
    nrfjprog.sh <action> [DEVICE]

Where action is one of
  --reset
  --pin-reset
  --erase-all
  --flash
  --flash-softdevice
  --rtt
  --gdbserver
  --recover
EOF

GREEN="\033[32m"
RED="\033[31m"
RESET="\033[0m"

STATUS_COLOR=$GREEN
SERIAL_NUMBER=0
HEX=0
DEVICE=0

# If flashing, get the hex file path and device
if [ "$1" = "--flash" ]; then
    HEX=$2
    DEVICE=$3
elif [ "$1" = "--flash-softdevice" ]; then
    HEX=$2
    DEVICE=$3
else
    DEVICE=$2
fi

# Select the correct serial number for the device you want to program
if [ "$DEVICE" = "WB1" ]; then
    echo -e "\n${GREEN}WB1 selected ${RESET}"
    SERIAL_NUMBER=683210617
elif [ "$DEVICE" = "WB2" ]; then
    echo -e "\n${GREEN}WB2 selected ${RESET}"
    SERIAL_NUMBER=683815900
elif [ "$DEVICE" = "HUB" ]; then
    echo -e "\n${GREEN}HUB selected ${RESET}"
    SERIAL_NUMBER=683425861
else
    echo -e "\n${RED}THE DEVICE YOU ARE TRYING TO REACH, ${DEVICE}, DOES NOT EXIST"
    echo -e "\n Available devices are WB1, WB2 and HUB ${RESET}\n"
    echo "$USAGE"
    exit 1
fi

TOOLCHAIN_PREFIX=arm-none-eabi
# Assume the tools are on the system path
TOOLCHAIN_PATH=
JLINK_OPTIONS="-device NRF52840_XXAA -USB $SERIAL_NUMBER -if swd -speed 1000"

JLINK="/home/ct/Downloads/JLink_Linux_V682c_arm/JLinkExe $JLINK_OPTIONS"
JLINKGDBSERVER="/home/ct/Downloads/JLink_Linux_V682c_arm/JLinkGDBServer $JLINK_OPTIONS"
GDB_PORT=2331

# Create a temporary script for JLink commands
TMPSCRIPT=/tmp/tmp_$$.jlink

# Fill the script with commands and run it. Except for the "--rtt" and "--gdb"
# option which correspondingly starts Real Time Transfer and gdb debugger.
if [ "$1" = "--reset" ]; then
    echo ""
    echo -e "${STATUS_COLOR}resetting...${RESET}"
    echo ""
    echo "r" > $TMPSCRIPT
    echo "g" >> $TMPSCRIPT
    echo "exit" >> $TMPSCRIPT
    $JLINK $TMPSCRIPT
    rm $TMPSCRIPT
elif [ "$1" = "--pin-reset" ]; then
    echo ""
    echo -e "${STATUS_COLOR}resetting with pin...${RESET}"
    echo ""
    echo "w4 40000544 1" > $TMPSCRIPT
    echo "r" >> $TMPSCRIPT
    echo "exit" >> $TMPSCRIPT
    $JLINK $TMPSCRIPT
    rm $TMPSCRIPT
elif [ "$1" = "--erase-all" ]; then
    echo ""
    echo -e "${STATUS_COLOR}perfoming full erase...${RESET}"
    echo ""
    echo "h" > $TMPSCRIPT
    echo "w4 4001e504 2" >> $TMPSCRIPT
    echo "w4 4001e50c 1" >> $TMPSCRIPT
    echo "sleep 100" >> $TMPSCRIPT
    echo "r" >> $TMPSCRIPT
    echo "exit" >> $TMPSCRIPT
    $JLINK $TMPSCRIPT
    rm $TMPSCRIPT
elif [ "$1" = "--flash" ]; then
    echo ""
    echo -e "${STATUS_COLOR}flashing ${HEX}...${RESET}"
    echo ""
    echo "r" > $TMPSCRIPT
    echo "h" >> $TMPSCRIPT
    echo "loadfile $HEX" >> $TMPSCRIPT
    echo "r" >> $TMPSCRIPT
    echo "g" >> $TMPSCRIPT
    echo "exit" >> $TMPSCRIPT
    $JLINK $TMPSCRIPT
    rm $TMPSCRIPT
elif [ "$1" = "--flash-softdevice" ]; then
    echo ""
    echo -e "${STATUS_COLOR}flashing softdevice ${HEX}...${RESET}"
    echo ""
    # Halt, write to NVMC to enable erase, do erase all, wait for completion. reset
    echo "h"  > $TMPSCRIPT
    echo "w4 4001e504 2" >> $TMPSCRIPT
    echo "w4 4001e50c 1" >> $TMPSCRIPT
    echo "sleep 100" >> $TMPSCRIPT
    echo "r" >> $TMPSCRIPT
    # Halt, write to NVMC to enable write. Write mainpart, write UICR. Assumes device is erased.
    echo "h" >> $TMPSCRIPT
    echo "w4 4001e504 1" >> $TMPSCRIPT
    echo "loadfile $HEX" >> $TMPSCRIPT
    echo "r" >> $TMPSCRIPT
    echo "g" >> $TMPSCRIPT
    echo "exit" >> $TMPSCRIPT
    $JLINK $TMPSCRIPT
    rm $TMPSCRIPT
elif [ "$1" = "--rtt" ]; then
    # trap the SIGINT signal so we can clean up if the user CTRL-C's out of the
    # RTT client
    trap ctrl_c INT
    function ctrl_c() {
        return
    }
    echo -e "${STATUS_COLOR}Starting RTT Server...${RESET}"
    JLinkExe -device NRF52840_XXAA -USB $SERIAL_NUMBER -if swd -speed 1000 &
    JLINK_PID=$!
    sleep 1
    echo -e "\n${STATUS_COLOR}Connecting to RTT Server...${RESET}"
    #telnet localhost 19021
    JLinkRTTClient
    echo -e "\n${STATUS_COLOR}Killing RTT server ($JLINK_PID)...${RESET}"
    kill $JLINK_PID
elif [ "$1" = "--gdbserver" ]; then
    $JLINKGDBSERVER -port $GDB_PORT
elif [ "$1" = "--recover" ]; then
    echo ""
    echo -e "${GREEN}recovering device. This can take about 3 minutes.${RESET}"
    echo ""
    echo "si 0"           > "$TMPSCRIPT"
    echo "t0"            >> "$TMPSCRIPT"
    echo "sleep 1"       >> "$TMPSCRIPT"
    echo "tck1"          >> "$TMPSCRIPT"
    echo "sleep 1"       >> "$TMPSCRIPT"
    echo "t1"            >> "$TMPSCRIPT"
    echo "sleep 2"       >> "$TMPSCRIPT"
    echo "t0"            >> "$TMPSCRIPT"
    echo "sleep 2"       >> "$TMPSCRIPT"
    echo "t1"            >> "$TMPSCRIPT"
    echo "sleep 2"       >> "$TMPSCRIPT"
    echo "t0"            >> "$TMPSCRIPT"
    echo "sleep 2"       >> "$TMPSCRIPT"
    echo "t1"            >> "$TMPSCRIPT"
    echo "sleep 2"       >> "$TMPSCRIPT"
    echo "t0"            >> "$TMPSCRIPT"
    echo "sleep 2"       >> "$TMPSCRIPT"
    echo "t1"            >> "$TMPSCRIPT"
    echo "sleep 2"       >> "$TMPSCRIPT"
    echo "t0"            >> "$TMPSCRIPT"
    echo "sleep 2"       >> "$TMPSCRIPT"
    echo "t1"            >> "$TMPSCRIPT"
    echo "sleep 2"       >> "$TMPSCRIPT"
    echo "t0"            >> "$TMPSCRIPT"
    echo "sleep 2"       >> "$TMPSCRIPT"
    echo "t1"            >> "$TMPSCRIPT"
    echo "sleep 2"       >> "$TMPSCRIPT"
    echo "t0"            >> "$TMPSCRIPT"
    echo "sleep 2"       >> "$TMPSCRIPT"
    echo "t1"            >> "$TMPSCRIPT"
    echo "sleep 2"       >> "$TMPSCRIPT"
    echo "tck0"          >> "$TMPSCRIPT"
    echo "sleep 100"     >> "$TMPSCRIPT"
    echo "si 1"          >> "$TMPSCRIPT"
    echo "r"             >> "$TMPSCRIPT"
    echo "exit"          >> "$TMPSCRIPT"
    $JLINK "$TMPSCRIPT"
    rm "$TMPSCRIPT"
else
    echo -e "\n${RED}Invalid action${RESET}\n"
    echo "$USAGE"
fi
