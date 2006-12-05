#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh
header "Info" "System" "@TR<<System>>" '' ''

this_revision=$(cat "/www/.version")
revision_text=" r$this_revision "

version_url="http://ftp.berlios.de/pub/xwrt/"
version_file=".version-stable"
daily_checked=""
equal "$FORM_check_daily" "1" && {	
	version_file=".version"
	daily_checked="checked=\"checked\""
}

if [ -n "$FORM_update_check" ]; then
	echo "Please wait while checking for an update ...<br />"
	tmpfile=$(mktemp "/tmp/.webif.XXXXXX")	
	wget -q "$version_url$version_file" -O "$tmpfile" 2>&-
	! exists "$tmpfile" && echo "doesn't exist" > "$tmpfile"
	cat $tmpfile | grep -q "doesn't exist"
	if [ $? = 0 ]; then
		revision_text="<div id=\"update-error\">ERROR CHECKING FOR UPDATE</div>"
	else
		latest_revision=$(cat $tmpfile)
		if [ "$this_revision" -lt "$latest_revision" ]; then
			revision_text="<div id=\"update-available\">webif^2 update available: r$latest_revision - <a href=\"http://svn.berlios.de/wsvn/xwrt/trunk/package/webif/?op=log&amp;rev=0&amp;sc=0&amp;isdir=1\" target=\"_blank\">view changes</a></div>"
		else
			revision_text="<div id=\"update-unavailable\">You have the latest webif^2: r$this_revision</div>"
		fi
	fi
	rm -f "$tmpfile"
fi

if [ -n "$FORM_install_webif" ]; then
	echo "Please wait, installation may take a minute ... <br />"
	echo "<pre>"
	ipkg install http://ftp.berlios.de/pub/xwrt/webif_latest.ipk | uniq
	echo "</pre>"
	this_revision=$(cat "/www/.version")
fi

_version=$(nvram get firmware_version)
_kversion="$( uname -srv )"
_mac="$(/sbin/ifconfig eth0 | grep HWaddr | cut -b39-)"
board_type=$(cat /proc/cpuinfo | sed 2,20d | cut -c16-)
device_name=$(nvram get device_name)
empty "$device_name" && device_name="unidentified"
device_string=$(echo $device_name && ! empty $device_version && echo $device_version)
user_string=$REMOTE_USER
equal $user_string "" && user_string="not logged in"

echo "<pre>"
cat '/etc/banner'
echo "</pre><br />"

cat <<EOF
<table>
<tbody>
	<tr>
		<td><strong>@TR<<Firmware>></strong></td><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
		<td>$_firmware_name - $_firmware_subtitle $_version</td>
	</tr>
	<tr>
		<td><strong>@TR<<Webif>></strong></td><td>&nbsp;</td>
		<td><a href="http://www.x-wrt.org">X-Wrt</a> Webif<sup>2</sup></td>
<td colspan="2">
<form action="" enctype="multipart/form-data" method="post">
<input type="submit" value=" @TR<<Check_Upgrade|Check For Webif Update>> " name="update_check" />
<input type="submit" value=" @TR<<Upgrade_Webif#Update/Reinstall Webif>> "  name="install_webif" />
</td><tr><td></td><td></td><td>$revision_text</td><td>
<input type="checkbox" $daily_checked value="1" name="check_daily" id="field_check_daily" />Include Daily Builds in Check
</form>
</td>
</tr>
	<tr>
		<td><strong>@TR<<Kernel>></strong></td><td>&nbsp;</td>
		<td>$_kversion</td>
	</tr>
	<tr>
		<td><strong>@TR<<MAC>></strong></td><td>&nbsp;</td>
		<td>$_mac</td>
	</tr>
	<tr>
		<td><strong>@TR<<Device>></strong></td><td>&nbsp;</td><td> $device_string</td>
	</tr>
	<tr>
		<td><strong>@TR<<Board>></strong></td><td>&nbsp;</td><td> $board_type</td>
	</tr>
	<tr>
		<td><strong>@TR<<Username>></strong></td><td>&nbsp;</td>
		<td>$user_string</td>
	</tr>
	<tr><td><br /><br /></td></tr>
</tbody>
</table>
EOF

show_validated_logo
footer

?>
<!--
##WEBIF:name:Info:1:System
-->
