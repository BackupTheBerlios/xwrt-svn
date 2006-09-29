# $1 = type
# $2 = form variable name
# $3 = form variable value
# $4 = (radio button) value of button
# $5 = string to append
# $6 = additional attributes 

BEGIN {
	FS="|"
	select_open = 0
	optgroup_open = 0
}

# trim leading whitespaces 
{
	gsub(/^[ \t]+/,"",$1)
}

$1 ~ /^onchange/ {
	onchange = $2
}

$1 ~ /^onclick/ {
	onclick = $2
}

($1 != "") && ($1 !~ /^option/) && (optgroup_open == 1) {
	optgroup_open = 0
	print "</optgroup>"
}
($1 != "") && ($1 !~ /^(option|optgroup)/) && (select_open == 1) {
	select_open = 0
	print "</select>"
}
$1 ~ /^start_form/ {
	if ($3 != "") field_opts=" id=\"" $3 "\""
	else field_opts=""
	if ($4 == "hidden") field_opts = field_opts " style=\"display: none\""
	start_form($2, field_opts);
	print "<table width=\"100%\" summary=\"Settings\">"
	form_help = "<div class=helpform>"
	form_help_link = ""
}
$1 ~ /^field/ {
	if (field_open == 1) print "</td></tr>"
	if ($3 != "") field_opts=" id=\"" $3 "\""
	else field_opts=""
	if ($4 == "hidden") field_opts = field_opts " style=\"display: none\""
	print "<tr" field_opts ">"
	if ($2 != "") print "<td width=\"50%\""
	if ($2 != "") print ">" $2 "</td><td width=\"50%\">"
	else print "<td colspan=\"2\">"

	field_open=1
}
$1 ~ /^checkbox/ {
	if ($3==$4) opts="checked=\"checked\" "
	else opts=""
	if (onchange != "") opts = opts " onchange=\"" onchange "(this)\""
	if (onclick != "") opts = opts " onclick=\"" onclick "(this)\""
	print "<input id=\"" $2 "_" $4 "\" type=\"checkbox\" name=\"" $2 "\" value=\"" $4 "\" " opts " />"
}
$1 ~ /^radio/ {
	if ($3==$4) opts="checked=\"checked\" "
	else opts=""
	if (onchange != "") opts = opts " onchange=\"" onchange "(this)\""
	if (onclick != "") opts = opts " onclick=\"" onclick "(this)\""
	print "<input type=\"radio\" name=\"" $2 "\" value=\"" $4 "\" " opts " />"
}
$1 ~ /^select/ {
	opts = ""
	if (onchange != "") opts = opts " onchange=\"" onchange "(this)\""
	if (onclick != "") opts = opts " onclick=\"" onclick "(this)\""
	print "<select id=\"" $2 "\" name=\"" $2 "\"" opts ">"
	select_id = $2
	select_open = 1
	select_default = $3
}
($1 ~ /^optgroup/) && (select_open == 1) {
	print "<optgroup label=\"" $2 "\">"
	optgroup_open = 1
}
($1 ~ /^option/) && (select_open == 1) {
	if ($2 == select_default) option_selected=" selected=\"selected\""
	else option_selected=""
	if ($3 != "") option_title = $3
	else option_title = $2
	print "<option " option_selected " value=\"" $2 "\">" option_title "&nbsp;&nbsp;</option>"
}
($1 ~ /^listedit/) {
	n = split($4 " ", items, " ")
	for (i = 1; i <= n; i++) {
		if (items[i] != "") print "<tr><td width=\"50%\">" items[i] "</td><td>&nbsp;<a href=\"" $3 $2 "remove=" items[i] "\">@TR<<Remove>></a></td></tr>"
	}
	print "<tr><td width=\"100%\" colspan=\"2\"><input type=\"text\" name=\"" $2 "add\" value=\"" $5 "\" /><input type=\"submit\" name=\"" $2 "submit\" value=\"@TR<<Add>>\" /></td></tr>"
}
$1 ~ /^caption/ { print "<b>" $2 "</b>" }
$1 ~ /^string/ { print $2 }
$1 ~ /^textarea/ {
	rows = ""
	if ($4 != "") rows = " rows=\"" $4 "\""
	cols = ""
	if ($5 != "") cols = " cols=\"" $5 "\""
	print "<textarea id=\"" $2 "\" name=\"" $2 "\"" rows cols ">"
	print $3
	print "</textarea>"
}
#####################################################
# progressbar|id|title|width_percent|percent_complete|filled_caption|unfilled_caption
# 
($1 ~ /^progressbar/) {
	uncomplete_area=100-$5;
	print "<div class=\"progressbar-title\">"
	print "<tr>"
	# show caption 	
	if ($3 != "" ) print "<td>"$3"</td>"
	# show progress bar
	print "<td width=\"" $4 "\">"
	print "<table class=\"progressbar-whole\" width=\"" $4 "\" id=\"" $2 "\"><tbody>"	
	print "<tr  width=\"" $4 "\">"
	print "<td class=\"progressbar-filled\" width=\"" $5 "%\">" $6 "</td>"	
	print "<td class=\"progressbar-unfilled\" width=\"" uncomplete_area "%\">" $7 "</td>"	
	print "</tr>"	
	print "</tbody></table></td></tr>"
	print "</div>"
}
$1 ~ /^text$/ { print "<input id=\"" $2 "\" type=\"text\" name=\"" $2 "\" value=\"" $3 "\" />" $4 }
$1 ~ /^password/ { print "<input id=\"" $2 "\" type=\"password\" name=\"" $2 "\" value=\"" $3 "\" />" $4 }
$1 ~ /^upload/ { print "<input id=\"" $2 "\" type=\"file\" name=\"" $2 "\"/>" }
$1 ~ /^submit/ { print "<input type=\"submit\" name=\"" $2 "\" value=\"" $3 "\" />" }
$1 ~ /^helpitem/ { form_help = form_help "<div class=\"helpitem\">@TR<<" $2 ">>:</div>" }
$1 ~ /^helptext/ { form_help = form_help "<div class=\"helptext\">@TR<<" $2 ">></div>" }
$1 ~ /^helplink/ { form_help_link = "<div class=\"more-help\"><a href=\"" $2 "\">@TR<<more...>></a></div>" }

($1 ~ /^checkbox/) || ($1 ~ /^radio/) {
	print $5
}

$1 ~ /^end_form/ {
	if (field_open == 1) print "</td></tr>"
	field_open = 0
	print "</table>"
	form_help = form_help "</div>"
	end_form(form_help, form_help_link);
	form_help = ""
	form_help_link = ""
}
