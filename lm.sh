#!/usr/bin/env bash

# define foreground colors
red="\033[0;31m"
green="\033[0;32m"
yellow="\033[0;33m"

# reset all text attributes
nc="\033[0m"

# clear line from current cursor position to end of line
cl="\033[0K"

# create a temp file
touch .templm

# define main function
mainfunc() {
	# count the lines for $file
	nr=$(cat $file | wc -l)

	# make a loop for every line from $file
	for ((i = 1 ; i <= $nr ; i++)); do
		# get names from $file
		name=$(awk -F',' 'NR=='$i' {print $1}' $file)

		# print progress info on same line
		echo -ne "${yellow}Getting Reddit members for $name $i/$nr${nc}${cl}\r"

		# get urls from $file
		url=$(awk -F',' 'NR=='$i' {print $2}' $file)

		# get Reddit members for every url from $file
		members=$(wget -q -O - $url | awk 'sub(/.*<div class="_3b9utyKN3e_kzVZ5ngPqAu">*/,""){f=1} f{if ( sub(/ *<.*/,"") ) f=0; print}')

		# save the output to .templm
		echo "$name,* $members" >> .templm
	done
	echo

	# print an empty line
	echo

	# sort the content by members in descending order
	cat .templm | column -t -s"," | sort -r -h -t "*" -k2 > .templms

	# print final output in terminal
	cat -n .templms

	# delete temporary files
	rm .templm
	rm .templms

	# print an empty line
	echo
}

# create a menu and reapeat the options until the user quits
while [ $? != "q" ]; do

	# display the menu options to user
	echo
	echo -e "${green}Get the Reddit members for:${nc}"
	echo
	echo -e "1 ${green}Distributions${nc}"
	echo -e "2 ${green}Desktop interfaces${nc}"
	echo

	# prompt user to enter command
	read -p "Please choose an option (q to quit) [1-2]: " option
	echo

	# switch case for menu commands
	case $option in
		1)
			# distributions
			file="distros.txt"
			mainfunc
			;;
		2)
			# desktop interfaces
			file="desktop-interfaces.txt"
			mainfunc
			;;
		q)
			# quit
			exit
			;;
		*)
			# invalid options
			echo -e "${red}Invalid option, choose again!${nc}"
			;;
	esac
done
