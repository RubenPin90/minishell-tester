#!/bin/bash

RESET="\e[0m"
RED="\e[0;31m"
GREEN="\e[0;32m"
YELLOW="\e[0;33m"
BLUE="\e[0;34m"
PINK="\e[0;35m"
CYAN="\e[0;36m"
GREY="\e[0;90m"
BOLD="\u001b[1m"

OK="✓"
KO="✗"

if [ $# -gt 0 ]; then
    if [ "$1" == 'help' ]; then
	    echo -e $CYAN "__MINISHELL TESTER USAGE MANUAL__" $RESET;
	    echo -e "\nAccepted Arguments:\n";
	    echo -e "no args\t\tDefault mode";
	    echo -e "'m'\t\tShow minishell and bash output\n";
        exit 0
    elif [ "$1" == 'm' ]; then
        SHOW_OUTPUT=true
    else
        echo -e $BOLD
	    echo -e "#***********************************************************#"
        echo -e "#\t\tMINISHELL TESTER wrong argument\t\t    #"
	    echo -e "#\t     run with $YELLOW'help'$RESET$BOLD to show usage manual\t    #"
        echo -e "#***********************************************************#"
	    exit 1
    fi
fi

echo -e $YELLOW
echo "    *     (        )  (    (        )       (     (                  (                (     "
echo " (  \`    )\ )  ( /(  )\ ) )\ )  ( /(       )\ )  )\ )    *   )      )\ )  *   )      )\ )   "
echo " )\\))(  (()/(  )\\())(()/((()/(  )\\()) (   (()/( (()/(  \` )  /( (   (()/(\` )  /( (   (()/(   "
echo "((_)()\  /(_))((_)\  /(_))/(_))((_)\  )\   /(_)) /(_))  ( )(_)))\   /(_))( )(_)))\   /(_))  "
echo "(_()((_)(_))   _((_)(_)) (_))   _((_)((_) (_))  (_))   (_(_())((_) (_)) (_(_())((_) (_))    "
echo -e $RED"|  \/  ||_ _| | \| ||_ _|/ __| | || || __|| |   | |    |_   _|| __|/ __||_   _|| __|| _ \   "
echo "| |\/| | | |  | .\` | | | \__ \ | __ || _| | |__ | |__    | |  | _| \__ \  | |  | _| |   /   "
echo -e "|_|  |_||___| |_|\_||___||___/ |_||_||___||____||____|   |_|  |___||___/  |_|  |___||_|_\   "$RESET
echo -e $GREY
echo -e " ____________________________________________________________________________\n"
echo -e  "   Version: 1.0.0"
echo -e  "   Description: May the Hell be with you"
echo -e  "   Author: rubeninette"
echo -e  "   License: Open Source (https://github.com/RubenPin90/minishell-tester.git)"
echo -e  "   Copyright © 2023"
echo -e " ____________________________________________________________________________\n"$RESET
echo -e "\n\t\t Use $PINK'.tester.sh help'$RESET for more information\n\n" 

sleep 1

MINISHELL="../minishell/minishell"
# Create PROMPT variable by running MINISHELL with empty input
PROMPT=$(echo "" | $MINISHELL 2>&1 | head -n 1 | awk '{print $1}')
SUP_FILE="../minishell/rl_leaks.supp"
[ -e $SUP_FILE ] || touch $SUP_FILE  # Create SUP_FILE if it doesn't exist
IFS=  # Set IFS to an empty string to preserve leading/trailing spaces when using read
EXEC_MINI="valgrind --leak-check=full --tool=memcheck --track-origins=yes --show-leak-kinds=all --suppressions=$SUP_FILE --track-fds=yes $MINISHELL"
test_list=("builtins_cd" "builtins_echo" "builtins_exit" "builtins_export" "builtins_pwd" "builtins_unset" "expander" "pipes" "redirects" "extras")

execute_and_evaluate() {
    local command="$1"
	local i="$2"

    MINISHELL_OUTPUT=$("$MINISHELL" << EOF 2>/dev/null
$command
EOF
    ) 
    MINISHELL_EXCODE=$?
    MINISHELL_OUTPUT=$(echo $MINISHELL_OUTPUT | awk -v prompt="$PROMPT" '$1 != prompt')

    BASH_OUTPUT=$(bash << EOF  2>/dev/null
$command
EOF
    )
    BASH_EXCODE=$?
    
    OUTPUT=
    if [[ "$MINISHELL_OUTPUT" == "$BASH_OUTPUT" ]]; then
        OUTPUT="$GREEN $OK $RESET"
    else
        OUTPUT="$RED $KO $RESET"
    fi

    EXCODE=
    if [[ "$MINISHELL_EXCODE" -eq "$BASH_EXCODE" ]]; then
        EXCODE="$GREEN $OK $RESET"
    else
        EXCODE="$RED $KO $RESET"
    fi

    if echo "$MINISHELL_OUTPUT" | grep -q "HEAP SUMMARY.*[^0] bytes in [^0] blocks"; then
        LEAKS="$RED $KO $RESET"
    else
        LEAKS="$GREEN $OK $RESET"
    fi

    command="${command//$'\n'/$'\0'}"
	printf "%b\n" $CYAN"\nTEST$i: $GREY$command$RESET OUTPUT: $OUTPUT EXIT_STATUS: $EXCODE LEAKS: $LEAKS"
    if [ "$SHOW_OUTPUT" == true ]; then
        echo -e $GREY"minishell "$MINISHELL_OUTPUT $MINISHELL_EXCODE $RESET
        echo -e $GREY"bash "$BASH_OUTPUT $BASH_EXCODE $RESET
    fi
}

for testfile in ${test_list[*]}; do

	echo -e $BLUE "\n____________"$testfile"___________"$RESET
	i=0
	while read -r line; do
		if [ -z "$line" ]; then
			if [ -n "$command" ]; then
				((i++))
				execute_and_evaluate "$command" "$i"
				command=
			fi
		else
			command+="$line"$'\n'
		fi
	done < $testfile

	if [ -n "$command" ]; then
    	((i++))
		execute_and_evaluate "$command" "$i"
        command=
    fi
done

rm -f "$SUP_FILE"
