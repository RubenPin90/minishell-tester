#!/bin/bash

RESET="\e[0m"
RED="\e[0;31m"
GREEN="\e[0;32m"
YELLOW="\e[0;33m"
BLUE="\e[0;34m"
PINK="\e[0;35m"

if [ $# -gt 0 ]; then
	echo -e $YELLOW "MINISHELL TESTER doesn't need any arguments ;)"$RESET;
	exit 1
fi

echo -e $YELLOW
echo "    *     (        )  (    (        )       (     (                  (                (     ";
echo " (  \`    )\ )  ( /(  )\ ) )\ )  ( /(       )\ )  )\ )    *   )      )\ )  *   )      )\ )   ";
echo " )\\))(  (()/(  )\\())(()/((()/(  )\\()) (   (()/( (()/(  \` )  /( (   (()/(\` )  /( (   (()/(   ";
echo "((_)()\  /(_))((_)\  /(_))/(_))((_)\  )\   /(_)) /(_))  ( )(_)))\   /(_))( )(_)))\   /(_))  ";
echo "(_()((_)(_))   _((_)(_)) (_))   _((_)((_) (_))  (_))   (_(_())((_) (_)) (_(_())((_) (_))    ";
echo -e $RED"|  \/  ||_ _| | \| ||_ _|/ __| | || || __|| |   | |    |_   _|| __|/ __||_   _|| __|| _ \   ";
echo "| |\/| | | |  | .\` | | | \__ \ | __ || _| | |__ | |__    | |  | _| \__ \  | |  | _| |   /   ";
echo "|_|  |_||___| |_|\_||___||___/ |_||_||___||____||____|   |_|  |___||___/  |_|  |___||_|_\   ";
echo -e $RESET

PROMPT="> ";
MINISHELL="valgrind --leak-check=full ../minishell/minishell"
test_list=("builtins" "pipes" "redirects" "syntax" "extras")

for testfile in ${test_list[*]}; do

	echo -e $BLUE "____________"$testfile"___________"$RESET;
	i=0
	while read line; do
		((i++))
		echo -e "test $i: $line"
		FIRST_TEST=$(echo -e "$line" | $MINISHELL | grep -vF $PROMPT)
		echo -e $PINK $FIRST_TEST $RESET;
	done < $testfile
done
