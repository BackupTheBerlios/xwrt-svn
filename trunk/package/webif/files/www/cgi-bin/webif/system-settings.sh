#!/usr/bin/webif-page
<? 
. "/usr/lib/webif/webif.sh"
###################################################################
# system configuration page
#
# Description:
#	Configures general system settings.
#
# Author(s) [in order of work date]: 
#   	Original webif developers -- todo
#	Markus Wigge <markus@freewrt.org> 
#   	Jeremy Collake <jeremy.collake@gmail.com>
#
# Major revisions:
#
# NVRAM variables referenced:
#	time_zone
#  	ntp_server
#
# Configuration files referenced: 
#   none
#

load_settings "system"
load_settings "webif" 

#####################################################################
# defaults
#
# Overclocking note:
#  we only handle 3302 0.8 since these are usually safer if they have
#  the same default CFE as found on Linksys WRT54G(S) v4+, as it
#  will handle invalid clock frequencies more gracefully and default
#  to a limit of 250mhz. It also has a fixed divider, so sbclock
#  frequencies are implied, and ignored if specified.
#		
OVERCLOCKING_DISABLED="0" # set to 1 to disble OC support

#####################################################################
header "System" "Settings" "@TR<<System Settings>>" ' onLoad="modechange()" ' "$SCRIPT_NAME"


#####################################################################
# todo: CPU_MODEL not actually used atm (except in building version)
equal "$OVERCLOCKING_DISABLED" "0" && {
	CPU_MODEL=$(sed -n "/cpu model/p" "/proc/cpuinfo")
	CPU_VERSION=$(echo "$CPU_MODEL" | sed -e "s/BCM3302//" -e "s/cpu model//" -e "s/://")
	#echo "debug.model: $CPU_MODEL <br />"
	#echo "debug.version: $CPU_VERSION <br />"
}	

#####################################################################
# install NTP client if asked
if ! empty "$FORM_install_ntpclient"; then
	tmpfile=$(mktemp "/tmp/.webif_ntp-XXXXXX")
	echo "Installing NTPCLIENT package ...<pre>"
	ipkg install ntpclient
	echo "</pre>"	
fi


#####################################################################
# initialize forms
if empty "$FORM_submit"; then
	# initialize all defaults
	FORM_hostname="${wan_hostname:-$(nvram get wan_hostname)}"	
	FORM_hostname="${FORM_hostname:-OpenWrt}"	
	FORM_language="${language:-$(nvram get language)}"
	FORM_language="${FORM_language:-default}"	
    	FORM_system_timezone="${FORM_system_timezone:-$(nvram get time_zone)}"
    	FORM_system_timezone="${FORM_system_timezone:-""}"
    	FORM_ntp_server="${ntp_server:-$(nvram get ntp_server)}"	
	FORM_boot_wait="${boot_wait:-$(nvram get boot_wait)}"
	FORM_boot_wait="${FORM_boot_wait:-off}"	
	FORM_wait_time="${wait_time:-$(nvram get wait_time)}"
	FORM_wait_time="${FORM_wait_time:-1}"	
	FORM_clkfreq="${clkfreq:-$(nvram get clkfreq)}";
   	FORM_clkfreq="${FORM_clkfreq:-200}"   	   	
else
#####################################################################
# save forms
	SAVED=1
	validate <<EOF
hostname|FORM_hostname|Hostname|nodots required|$FORM_hostname
EOF
	if equal "$?" 0 ; then		
		save_setting system wan_hostname "$FORM_hostname"
		save_setting webif language "$FORM_language"		
		save_setting system time_zone "$FORM_system_timezone"
		save_setting system ntp_server "$FORM_ntp_server"
		is_bcm947xx && {				  
			case "$FORM_boot_wait" in
				on|off) save_setting system boot_wait "$FORM_boot_wait";;
			esac				
			! empty "$FORM_wait_time" &&			
			{
				save_setting system wait_time "$FORM_wait_time"						
			}
			equal "$OVERCLOCKING_DISABLED" "0" && ! empty "$FORM_clkfreq" &&
			{
				save_setting nvram clkfreq "$FORM_clkfreq"		  		
			}
		  
		}
	else
		echo "<br /><div class=warning>Warning: Hostname failed validation. Can not be saved.</div><br />"	
	fi
fi

#####################################################################
# over/underclocking
#				
is_bcm947xx && {   		
	equal "$OVERCLOCKING_DISABLED" "0" && 
	{
	if [ $CPU_VERSION = "V0.8" ]; then				
		FORM_clkfreqs="$FORM_clkfreq
			option|184
			option|188
			option|197
			option|200
			option|207
			option|216
			option|217
			option|225
			option|234
			option|238
			option|240
			option|250"
		# special case for custom CFEs (like mine)
		if [ $(nvram get clkfreq) -gt 250 ]; then
			FORM_clkfreqs="$FORM_clkfreqs
				option|$(nvram get clkfreq)"
		fi				
	else
		# BCM3302 v0.7 or other..
		# in this case, we'll show it, but not have any options
		FORM_clkfreqs="$FORM_clkfreq
			option|$FORM_clkfreq"
	fi
	}
	
#####################################################################
# Initialize wait_time form			
	for wtime in $(seq 1 30); do	
		FORM_wait_time="$FORM_wait_time
			option|$wtime"		
	done
}

LANGUAGES="$(grep -H '^[\t ]*lang[\t ]*=>' /usr/lib/webif/lang/*/*.txt 2>/dev/null | awk -f /usr/lib/webif/languages.awk)"
is_bcm947xx && {
	bootwait_form="field|Boot Wait
	select|boot_wait|$FORM_boot_wait
	option|on|@TR<<Enabled>>
	option|off|@TR<<Disabled>>"

	waittime_form="field|Wait Time
	select|wait_time|$FORM_wait_time"

	equal "$OVERCLOCKING_DISABLED" "0" && 
	{ 
		clkfreq_form="field|CPU Clock Frequency
		select|clkfreq|$FORM_clkfreqs"
	}
}

#####################################################################
# check if ntpclient is installed and give user option to install if not
ipkg list_installed | grep ntpclient >> /dev/null
! equal "$?" "0" && 
{
	NTPCLIENT_INSTALL_FORM="string|<div class=warning>No NTP client is installed. For correct time support you need to install one:</div>
		submit|install_ntpclient| Install NTP Client |"
}


#####################################################################
# initialize time zones

TIMEZONE_OPTS=$(
	awk '
		BEGIN {
			FS="	"
			last_group=""
		}
		/^(#.*)?$/ {next}
		$1 != last_group {
			last_group=$1
			print "optgroup|" $1
		}
		{
			print "option|" $3 "|" $2
		}' < /usr/lib/webif/timezones.csv
				
)

#####################################################################s
cat <<EOF
<script type="text/javascript" src="/webif.js"></script>
<script type="text/javascript">

function modechange() 
{	
	if(isset('boot_wait','on'))
	{
		document.getElementById('wait_time').disabled = false;	
	}
	else
	{
		document.getElementById('wait_time').disabled = true;	
	}	
}
</script>
EOF

#####################################################################
# Show form		
display_form <<EOF
onchange|modechange
start_form|@TR<<System Settings>>
field|@TR<<Host Name>>
text|hostname|$FORM_hostname
$bootwait_form

helpitem|Boot Wait
helptext|HelpText Boot Wait#Boot wait causes the boot loader of some devices to wait a few seconds at bootup for a TFTP transfer of a new firmware image. This is a security risk to be left on.
$waittime_form

helpitem|Wait Time
helptext|HelpText Wait Time#Number of seconds the boot loader should wait for a TFTP transfer if Boot Wait is on.

field|@TR<<Language>>
select|language|$FORM_language
$LANGUAGES

$clkfreq_form
helpitem|Clock Frequency
helptext|HelpText Clock Frequency#Do not change with this unless you have a WRT54G(S)/L v4-v6. Only those are safe. You should see no options if you have a different device.
end_form

start_form|@TR<<Time Settings>>
field|@TR<<Timezone>>
select|system_timezone|$FORM_system_timezone
$TIMEZONE_OPTS

field|@TR<<NTP Server>>
text|ntp_server|$FORM_ntp_server
end_form

$NTPCLIENT_INSTALL_FORM

EOF
footer ?>

<!--
##WEBIF:name:System:10:Settings
-->
