set part_name [lindex $argv 0]

create_project -part $part_name -force i-in_memory tmp_ip_list  

update_ip_catalog
set ip_list [get_ipdefs]

set fp [open "./ip/catalog.txt" "w"]

foreach ip $ip_list {
    set vlnv     [get_property VLNV $ip]
    set name     [get_property NAME $ip]
    set version  [get_property VERSION $ip]
    set vendor   [get_property VENDOR $ip]
    set description      [get_property DESCRIPTION $ip]
	set requires_license [get_property REQUIRES_LICENSE $ip]
    
	if { $requires_license eq "1" } {
		set license_status "(LICENSE)"
	} else {
		set license_status "(FREE)"
	}

	puts $fp ">>> $vlnv $license_status"
	puts $fp "$name"
	puts $fp "$description"
	puts $fp "\n"

}

close $fp

#DEBUG
#set ip [get_ipdefs xilinx.com:ip:clk_wiz:6.0]
#report_property $ip
