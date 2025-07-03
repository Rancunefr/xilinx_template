set part_name [lindex $argv 0]
set cfg_file  [lindex $argv 1]
set inst_name [lindex $argv 2]

puts "part : $part_name"
puts "cfg_file : $cfg_file"
puts "inst_name : $inst_name"

create_project -part $part_name -force -in_memory tmp_ip_proj

# Read config file
set f [open $cfg_file r]
set lines [split [read $f] "\n"]
close $f

set ip_name [string trim [lindex $lines 0]]

create_ip -name $ip_name \
	-vendor xilinx.com \
	-library ip \
	-version "*" \
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

generate_target all [get_ips $inst_name]

# write_ip -force [get_ips clocky]

export_ip_user_files \
	-ip_user_files_dir ./src_ip \
	-ipstatic_source_dir ./src_ip/$inst_name/static \
	-of_objects [get_ips clocky] \
	-force

close_project -delete
exit
