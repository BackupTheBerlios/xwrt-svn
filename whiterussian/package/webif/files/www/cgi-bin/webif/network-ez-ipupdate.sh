#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh

ezipupdate_name="ez-ipupdate"
ddns_dir="/etc/$ezipupdate_name"
ddns_msg="$ddns_dir/${ezipupdate_name}.msg"

header "Network" "DynDNS" "@TR<<DynDNS Settings>>" '' "$SCRIPT_NAME"
has_pkgs ez-ipupdate

load_settings "ezipupdate"

# test for broken ez-ipupdate package as found in OpenWrt's official repository
# if found, give an option to install proper one from X-Wrt repository.
[ ! -f "/etc/hotplug.d/iface/20-ez-ipupdate" ] && {
	echo "<div class=\"warning\">@TR<<broken_ezip|You have a partially broken ez-ipupdate package, as found in OpenWrt's official repository. To install a fixed copy of the package from X-Wrt's repository, press the button below>>.</div>"
	display_form <<EOF
start_form
submit|reinstall_ez| @TR<<Reinstall EZ-IPUPDATE>> 
end_form
EOF
}
! empty "$FORM_reinstall_ez" && {
	echo "@TR<<Please wait>> ...<br />"
	install_package "http://ftp.berlios.de/pub/xwrt/packages/ez-ipupdate_3.0.11b8-3_mipsel.ipk"
}

# todo add javascript /enable/disable for mx and wildcard / connection type
#ezip            { "server", "user", "address", "wildcard", "mx", "url", "host", NULL };
#pgpow           { "server", "host", NULL };
#dhs             { "server", "user", "address", "wildcard", "mx", "url", "host", NULL };
#dyndns          { "server", "user", "address", "wildcard", "mx", "host", NULL };
#dyndns-static, dyndns-custom { "server", "user", "address", "wildcard", "mx", "host", NULL };
#ods             { "server", "host", "address", NULL };
#tzo             { "server", "user", "address", "host", "connection-type", NULL };
#easydns         { "server", "user", "address", "wildcard", "mx", "host", NULL };
#easydns-partner { "server", "partner", "user", "address", "wildcard", "host", NULL };
#gnudip          { "server", "user", "host", "address", NULL };
#justlinux       { "server", "user", "host", NULL };
#dyns            { "server", "user", "host", NULL };
#hn              { "server", "user", "address", NULL };
#zoneedit        { "server", "user", "address", "mx", "host", NULL };
#heipv6tb        { "server", "user", NULL };

[ -z $FORM_submit ] && {

	FORM_ddns_enable=${ddns_enable:-$(nvram get ddns_enable)}
	FORM_ddns_enable=${FORM_ddns_enable:-'0'}

	FORM_ddns_service_type=${ddns_service_type:-$(nvram get ddns_service_type)}
	FORM_ddns_service_type=${FORM_ddns_service_type:-"dyndns"}

	FORM_ddns_username=${ddns_username:-$(nvram get ddns_username)}
	FORM_ddns_passwd=${ddns_passwd:-$(nvram get ddns_passwd)}
	FORM_ddns_hostname=${ddns_hostname:-$(nvram get ddns_hostname)}

	FORM_ddns_wildcard=${ddns_wildcard:-$(nvram get ddns_wildcard)}
	FORM_ddns_wildcard=${FORM_ddns_wildcard:-'0'}

	FORM_ddns_server=${ddns_server:-$(nvram get ddns_server)}

	FORM_ddns_max_interval=${ddns_max_interval:-$(nvram get ddns_max_interval)}
	FORM_ddns_max_interval=${FORM_ddns_max_interval:-'86400'}

#    FORM_ddns_tzo_ctype=${ddns_tzo_ctype:-$(nvram get ddns_tzo_ctype)}
#    FORM_ddns_tzo_ctype=${FORM_ddns_tzo_ctype:-"1"}

} || {
	SAVED=1

	#int|FORM_ddns_tzo_ctype|Connection Type||$FORM_ddns_tzo_ctype

	validate "
string|FORM_ddns_service_type|Service Type|required|$FORM_ddns_service_type
string|FORM_ddns_username|User Name|required|$FORM_ddns_username
string|FORM_ddns_passwd|Password|required|$FORM_ddns_passwd
string|FORM_ddns_hostname|Host Name||$FORM_ddns_hostname
hostname|FORM_ddns_server|Server Name||$FORM_ddns_server
int|FORM_ddns_max_interval|Max Interval (sec)|min=86400 max=2937600|$FORM_ddns_max_interval
" && {
	save_setting "ezipupdate" ddns_enable $FORM_ddns_enable
	save_setting "ezipupdate" ddns_service_type $FORM_ddns_service_type
	save_setting "ezipupdate" ddns_username $FORM_ddns_username
	save_setting "ezipupdate" ddns_passwd $FORM_ddns_passwd
	save_setting "ezipupdate" ddns_hostname $FORM_ddns_hostname
	save_setting "ezipupdate" ddns_wildcard $FORM_ddns_wildcard
	#save_setting "ezipupdate" ddns_tzo_ctype $FORM_ddns_tzo_ctype
	save_setting "ezipupdate" ddns_server $FORM_ddns_server
	save_setting "ezipupdate" ddns_max_interval $FORM_ddns_max_interval
	}
}

#show message from last update
#field|Connection Type (only for TZO)
#text|ddns_tzo_ctype|$FORM_ddns_tzo_ctype

display_form "start_form|@TR<<DynDNS>>
field|@TR<<DynDNS>>
radio|ddns_enable|$FORM_ddns_enable|1|Enable
radio|ddns_enable|$FORM_ddns_enable|0|Disable
field|@TR<<DynDNS Service>>
select|ddns_service_type|$FORM_ddns_service_type
option|ezip|ez-ip
option|dyndns|dyndns
option|ods|ods
option|tzo|tzo
option|easydns|easydns
option|gnudip|gnudip
option|pgpow|justlinux v1.0 (penguinpowered)
option|justlinux|justlinux v2.0 (penguinpowered)
option|dyns|dyns
option|hn|hammer node
option|zoneedit|zoneedit
option|heipv6tb|heipv6tb
option|dyndns-static|dyndns-static
option|dyndns-custom|dyndns-custom
option|easydns-partner|easydns-partner
option|dnsexit|dnsexit
option|dhs|dhs
field|@TR<<User Name>>
text|ddns_username|$FORM_ddns_username
field|Password
password|ddns_passwd|$FORM_ddns_passwd
field|@TR<<Host Name>>
text|ddns_hostname|$FORM_ddns_hostname
field|Wildcard
radio|ddns_wildcard|$FORM_ddns_wildcard|1|Enable
radio|ddns_wildcard|$FORM_ddns_wildcard|0|Disable
field|@TR<<Server Name>>
text|ddns_server|$FORM_ddns_server
field|@TR<<Max Interval (sec)>>
text|ddns_max_interval|$FORM_ddns_max_interval
string|<br /><a href="network-logread-ez-ipupdate.sh">@TR<<View DynDNS Syslog>></a>
end_form"
?>
<?if [ -f $ddns_msg ] ?>
<br/>@TR<<Last update>>: <? cat $ddns_msg ?><br/><br/>
<?fi?>
<? footer ?>
<!--
##WEBIF:name:Network:651:DynDNS
-->
