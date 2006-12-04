#!/usr/bin/webif-page
<?
. /usr/lib/webif/webif.sh

header "Status" "OpenVPN" "@TR<<OpenVPN Status>>"

equal "$(uci get openvpn.general.mode)" "client" && {

	case "$FORM_action" in
		start)
			ps | grep -q '[o]penvpn --client' || {
				echo -n "Starting OpenVPN ..."
				/etc/init.d/S50openvpn start
				echo " done."
			}
		;;
		stop)
			ps | grep -q '[o]penvpn --client' && {
				echo -n "Stopping OpenVPN ..."
				/etc/init.d/S50openvpn stop
				echo " done."
			}
		;;
	esac

	case "$(uci get openvpn.client.auth)" in
		cert)
			[ -f "/etc/openvpn/certificate.p12" ] ||
				ERROR="Error, certificate is missing!"
		;;
		psk)
			[ -f "/etc/openvpn/shared.key" ] ||
				ERROR="Error, keyfile is missing!"
		;;
		*)
			ERROR="error in OpenVPN configuration, unknown authtype"
		;;
	esac

	empty "$ERROR" && {
		DEVICES=$(egrep "(tun|tap)" /proc/net/dev | cut -d: -f1 | tr -d ' ')
		empty "$DEVICES" && {
			echo "no active tunnel found"
		} || {
			echo "found the following active tunnel:"
			echo "<pre>"
			for DEV in $DEVICES;do
				ifconfig $DEV
			done
			echo "</pre>"
		}
		echo "<br/>"

		ps | grep -q '[o]penvpn --client' && {
			echo 'OpenVPN process is running <a href="?action=stop">[stop now]</a>'
		} || {
			echo 'OpenVPN is not running <a href="?action=start">[start now]</a>'
		}
	} || {
		echo "$ERROR"
	}
} || {
	echo "<br />OpenVPN is disabled"
}

footer ?>
<!--
##WEBIF:name:Status:910:OpenVPN
-->
