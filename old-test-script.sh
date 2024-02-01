#!/bin/bash

ZYPPER_CMD="echo"
USERDATA_FLAG="--userdata"

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
        $ZYPPER_CMD $USERDATA_FLAG "\"$NOTES\"" install $PACKAGE "$@"
    else
        # If --notes is not present, run zypper command without modification
        $ZYPPER_CMD "$@"
    fi
elif [ "$1" == "info" ]; then
    # Extract package name
    PACKAGE="$2"
    # Shift the arguments
    shift 2 
    # Run zypper info command
    $ZYPPER_CMD info $PACKAGE "$@"
else
    # If the command is not recognized, pass it directly to zypper
    $ZYPPER_CMD $@
fi

