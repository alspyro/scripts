!!!!!!/COS_DWH/CDR/FILES/IPMS2/data/uncompress.sh!!!!!!!!!!

#!/bin/bash

# Debugging: Log the original input path
echo "Original file path: $1" >> /tmp/uncompress_debug.log

# Define the specific affected directory
AFFECTED_DIR="/COS_DWH/Applications/scheduler/logfiles"

# Check if the file path starts with the affected directory
if [[ "$1" == $AFFECTED_DIR//* ]]; then
    # Normalize only if it's in the affected directory
    FILE_PATH=$(echo "$1" | sed 's:/\{2,\}:/:g')
else
    # Use the path as is for any other case
    FILE_PATH="$1"
fi

# Debugging: Log the corrected file path (only if changed)
echo "Final file path used: $FILE_PATH" >> /tmp/uncompress_debug.log

# Run gunzip with the corrected file path
/bin/gunzip -cq "$FILE_PATH" 2>> /tmp/uncompress_error.log


#!/bin/bash
echo "Original file path: $1" >> /tmp/uncompress_debug.log

AFFECTED_DIR="/COS_DWH/Applications/scheduler/logfiles"

if [[ "$1" == $AFFECTED_DIR//* ]]; then
    
    FILE_PATH=$(echo "$1" | sed 's:/\{2,\}:/:g')
else
    
    FILE_PATH="$1"
fi

echo "Final file path used: $FILE_PATH" >> /tmp/uncompress_debug.log

/bin/gunzip -cdq "$FILE_PATH" 2>> /tmp/uncompress_error.log
