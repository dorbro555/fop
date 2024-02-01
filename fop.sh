#!/bin/bash

ZYPPER_CMD="zypper"
USERDATA_FLAG="--userdata"
ZYPPER_LOG="/var/log/zypp/history"
FOP_FOLDER_PATH="/var/tmp/fop"
FOP_NOTES_PATH="$FOP_FOLDER_PATH/custom_notes.txt"
BRED='\033[1;31m'
BIRED='\033[1;91m'
BICYAN='\033[1;96m'
INFO_COLOR=$BICYAN
SUCCESS_COLOR=""
DANGER_COLOR=""
WARNING_COLOR=""
ON_CYAN='\033[106m'
SUCCESS_BG=""
DANGER_BG=""
WARNING_BG=""
INFO_BG=$ON_CYAN
NC='\033[0m' #No Color


# Function to get custom notes from zypper log
get_custom_notes() {
    # Extracting custom notes from zypper log using awk
    awk -F"|" '/command/ && /--userdata/ && /'"$1"'/ {print $NF}' $ZYPPER_LOG
    # echo "install $1: for testing zyppers custom notes"
}

# Check if the command is install or info
if [ "$1" == "install" ]; then
    # Extract package name
    PACKAGE="$2"
    
    # Check if --notes option is present
    if [ "$3" == "--notes" ]; then
        # Extract custom notes
        NOTES="$4"
	# Shift 4 so we remove all processed arguments
	shift 4
        # Run zypper command with --userdata flag
        $ZYPPER_CMD $USERDATA_FLAG "$NOTES" install $PACKAGE "$@"
    else
        # If --notes is not present, run zypper command without modification
        $ZYPPER_CMD "$@"
    fi
elif [ "$1" == "info" ]; then
    # Extract package name
    PACKAGE="$2"
    # Shift the arguments
    shift 2 
    # Get custom notes from zypper log
    CUSTOM_NOTES=$(get_custom_notes "$PACKAGE") 
    # Convert notes to a format that won't throw errors
    # SED_CUSTOM_NOTES=$(echo "$CUSTOM_NOTES" | tr -d '\\"')
    # Check if the folder exists
    if [ ! -d "$FOP_FOLDER_PATH" ]; then
	# If the folder doesn't exist, create it
	mkdir -p "$FOP_FOLDER_PATH"
    fi
    # Save the notes in a temp file
    echo -e "${INFO_COLOR}Notes          : ${NC}\n$CUSTOM_NOTES" | sed '2,$s/^'"/*   /" > $FOP_NOTES_PATH
    # Run zypper info command
    INFO_OUTPUT=$($ZYPPER_CMD info $PACKAGE "$@")
    # Insert the custom notes section after the Summary section
    UPDATED_OUTPUT=$(echo -e "$INFO_OUTPUT" | sed "/Summary/ r $FOP_NOTES_PATH" )
    # Print the modified output
    echo -e "$UPDATED_OUTPUT"
else
    # If the command is not recognized, pass it directly to zypper
    $ZYPPER_CMD $@
fi

