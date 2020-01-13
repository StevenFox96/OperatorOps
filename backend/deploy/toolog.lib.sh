#
# Toolog, Shell-Script version
#

BLUE='\033[1;34m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m'

LOGNAME=$1
SPINNER_PID=false
LAST_USER_ANSWER=false

IS_SILENT=${2:-false}

# Make sure we clean up after ourselves
trap quit INT


# Loggers
function logbanner() {
    echo ""
    loginfo "+------------------------------------------------------------------------------+"
    loginfo "| $1"
    loginfo "+------------------------------------------------------------------------------+\n"
}

function loginfo()   {
    if [ $IS_SILENT = true ]
    then
        return
    fi

    echo "${NC}[${BLUE}$LOGNAME${NC}]: $1"
}

function logwarn()   {
    if [ $IS_SILENT = true ]
    then
        return
    fi

    echo "${NC}[${BLUE}$LOGNAME${NC}]: ${YELLOW}$1${NC}"
}

function logerror()  {
    if [ $IS_SILENT = true ]
    then
        return
    fi

    echo "${NC}[${BLUE}$LOGNAME${NC}]: ${RED}$1${NC}"
}

function logdone()   {
    if [ $IS_SILENT = true ]
    then
        return
    fi

    echo "${NC}[${BLUE}$LOGNAME${NC}]: ${GREEN}$1${NC}"
}

function logok() {
    logdone " -> ok\n"
}



# Prompts
function confirm() {
    if [ $IS_SILENT = true ]
    then
        return
    fi

    logwarn "$1 ${BLUE}[y/n]${NC}"
    read -s -n 1 LAST_USER_ANSWER
}

function get_last_answer() {
    if [ $IS_SILENT = true ]
    then
        return
    fi

    echo "$LAST_USER_ANSWER"
}


# Spinner
function spin() {
    if [ $IS_SILENT = true ]
    then
        return
    fi

    local i=1
    local sp='\|/-'

    while :
    do
        # Get the next spinner char
        local SPINNER_NEXT_CHAR=${sp:i++%${#sp}:1}

        # Compose the full spinner message
        local SPINNER_MSG="${NC}[${BLUE}$LOGNAME${NC}]:${YELLOW}  -> $1 [$SPINNER_NEXT_CHAR]${NC}"

        # Next, back-space all the way
        backup_cursor

        # Print it
        printf "$SPINNER_MSG"

        # Relax, have a beer
        sleep 0.15
    done
}

function backup_cursor() {
    if [ $IS_SILENT = true ]
    then
        return
    fi

    local terminal_width=$(tput cols)
    tput cub $terminal_width
}

function spinner_clear() {
    if [ $IS_SILENT = true ]
    then
        return
    fi

    tput el1
    tput el
    backup_cursor
}

function spinner_start() {
    if [ $IS_SILENT = true ]
    then
        return
    fi

    # Start the spinner in a background PID
    spin "$1" &

    # Save the PID (we'll use it later to stop the spinner)
    SPINNER_PID=$!

    # Release the spinner-background-process we just started
    disown
}

function spinner_stop() {
    if [ $IS_SILENT = true ]
    then
        return
    fi

    # Only need to stop if the spinner is running
    if [ ! $SPINNER_PID = false ]
    then
        # Stop the spinner-background-process
        kill $SPINNER_PID &>/dev/null

        # Clear the last spinner-message
        spinner_clear

        # Reset our spinner indicator
        SPINNER_PID=false
    fi

    # Log closing message
    logdone " -> $1"
}

function spinner_stop_error() {
    if [ $IS_SILENT = true ]
    then
        return
    fi

    # Only need to stop if the spinner is running
    if [ ! $SPINNER_PID = false ]
    then
        # Stop the spinner-background-process
        kill $SPINNER_PID &>/dev/null

        # Clear the last spinner-message
        spinner_clear

        # Reset our spinner indicator
        SPINNER_PID=false
    fi

    # Log closing message
    logerror " -> $1"
}

function quit() {
    if [ $IS_SILENT = true ]
    then
        return
    fi

    spinner_stop "${RED} -> Got user-interrupt (quitting)${NC}"
    exit 1
}