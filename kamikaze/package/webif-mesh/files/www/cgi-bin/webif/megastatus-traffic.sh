#!/usr/bin/webif-page
<? 
. /usr/lib/webif/webif.sh
eval $(/usr/bin/megaparam)

header "MegaStatus" "Traffic" "Traffic counters"

if [ ".$mn_enable" = ".1" ]; then

echo "<PRE>"
iptables -nv -t mangle -L
echo "</PRE>"

else
	echo "<P>You must enable Meganetwork.org; go to MegaNetwork-->Intro page first.</P>"
fi

 footer ?>
<!--
##WEBIF:name:MegaStatus:5:Traffic
-->