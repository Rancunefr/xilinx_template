set part_name [lindex $argv 0]
set cfg_file  [lindex $argv 1]
set inst_name [lindex $argv 2]

set_part $part_name

# Read config file
set f [open $cfg_file r]
set lines [split [read $f] "\n"]
close $f

set ip_name [string trim [lindex $lines 0]]

create_ip \
	-name $ip_name \
	-vendor xilinx.com \
	-library ip \
	-version "*" \
	-dir ./ip \
	-force \
	-module_name $inst_name 

# Apply configuration lines
foreach line [lrange $lines 1 end] {
    set line [string trim $line]
    if { $line eq "" } { continue }
    if {[regexp {^#} $line]} { continue }
    if {[regexp {^(.+?)\s*[:=]\s*(.*)$} $line _ prop val]} {
		puts "-> $prop \"$val\""
		set_property -dict [list $prop "$val" ] [get_ips $inst_name]
    }
}

generate_target -force all [get_ips $inst_name]
synth_ip [get_ips $inst_name] -force
write_ip_tcl -force -multiple_files [get_ips]

exit
