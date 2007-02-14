# $1 = type
# $2 = variable name
# $3 = field name
# $4 = options
# $5 = value
BEGIN {
	FS="|"
	output=""
}

{ 
	valid_type = 0
	valid = 1
	# XXX: weird hack, but it works...
	n = split($0, param, "|")
	value = param[5]
	for (i = 6; i <= n; i++) value = value FS param[i]
	verr = ""
}

$1 == "int" {
	valid_type = 1
	if ((value != "") && (value !~ /^[[:digit:]]*$/)) { valid = 0; verr = "@TR<<Invalid value>>" }
}

# FIXME: add proper netmask validation
($1 == "ip") || ($1 == "netmask") {
	valid_type = 1
	if ((value != "") && (value !~ /^[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}$/)) valid = 0
	else {
		split(value, ipaddr, "\\.")
		for (i = 1; i <= 4; i++) {
			if ((ipaddr[i] < 0) || (ipaddr[i] > 255)) valid = 0
		}
	}
	if (valid == 0) verr = "@TR<<Invalid value>>"
}

$1 == "wep" {
	valid_type = 1
	if (value !~ /^[0-9A-Fa-f]*$/) {
		valid = 0
		verr = "@TR<<Invalid value>>"
	} else if ((length(value) != 0) && (length(value) != 10) && (length(value) != 26)) {
		valid = 0
		verr = "@TR<<Invalid key length>>"
	} else if (value ~ /0$/) {
		valid = 0
		verr = "@TR<<Key must not end with '0'>>"
	}
}

$1 == "hostname" {
	valid_type = 1
	if ((value != "") && (value !~ /^[0-9a-zA-Z\.\-]*$/)) {
		valid = 0
		verr = "@TR<<Invalid value>>"
	}
}

$1 == "string" {
	valid_type = 1
}

$1 == "mac" {
	valid_type = 1
	if ((value != "") && (value !~ /^[[:xdigit:]]{2,2}:[[:xdigit:]]{2,2}:[[:xdigit:]]{2,2}:[[:xdigit:]]{2,2}:[[:xdigit:]]{2,2}:[[:xdigit:]]{2,2}$/)) {
		valid = 0
		verr = "@TR<<Invalid value>>"
	}
}

$1 == "port" {
	valid_type = 1
	if ((value != "") && (value !~ /^[[:digit:]]{1,5}$/)) {
		valid = 0
		verr = "@TR<<Invalid value>>"
	}
}

$1 == "ports" {
	valid_type = 1
	if (value != "") {
		n = split(value, ports, ",")
		for (i = 1; i <= n; i++) {
			if ((ports[i] !~ /^[[:digit:]]{1,5}$/) && (ports[i] !~ /^[[:digit:]]{1,5}-[[:digit:]]{1,5}$/)) {
				valid = 0
				verr = "@TR<<Invalid value>>"
			}
		}
	}
}

$1 == "wpapsk" {
	valid_type = 1
	if (length(value) > 64) {
		valid = 0
		verr = "@TR<<String too long>>"
	}
	if ((length(value) != 0) && (length(value) < 8)) {
		valid = 0
		verr = "@TR<<String too short>>"
	}
	if ((length(value) == 64) && (value ~ /[^0-9a-fA-F]/)) {
		valid = 0
		verr = "@TR<<Invalid hex key>>"
	}
}

valid_type != 1 { valid = 0 }

valid == 1 {
	n = split($4, options, " ")
	for (i = 1; (valid == 1) && (i <= n); i++) {
		if (options[i] == "required") {
			if (value == "") { valid = 0; verr = "@TR<<No value entered>>" }
		} else if ((options[i] ~ /^min=/) && (value != "")) {
			min = options[i]
			sub(/^min=/, "", min)
			min = int(min)
			if ($1 == "int") {
				if (value < min) { valid = 0; verr = "@TR<<Value too small>> (@TR<<minimum>>: " min ")" }
			} else if ($1 == "string") {
				if (length(value) < min) { valid = 0; verr = "@TR<<String too short>> (@TR<<minimum length>>: " min ")"}
			}
		} else if ((options[i] ~ /^max=/) && (value != ""))  {
			max = options[i]
			sub(/^max=/, "", max)
			max = int(max)
			if ($1 == "int") {
				if (value > max) { valid = 0; verr = "@TR<<Value too large>> (@TR<<maximum>>: " max ")" }
			} else if ($1 == "string") {
				if (length(value) > max) { valid = 0; verr = "@TR<<String too long>> (@TR<<maximum length>>: " max ")" }
			}
		} else if ((options[i] == "nodots") && ($1 == "hostname")) {
			if (value ~ /\./) {
				valid = 0
				verr = "@TR<<Invalid value>>"
			}
		}
	}
}

valid_type == 1 {
	if (valid == 1) output = output $2 "=\"" value "\";\n"
	else error = error "Error in " $3 ": " verr "<br />"
}

END {
	print output "ERROR=\"" error "\";\n"
	if (error == "") print "return 0"
	else print "return 255"
}
