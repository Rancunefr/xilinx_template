set part_name [lindex $argv 0]
set ip_name [lindex $argv 1] 

create_project -part $part_name -force -in_memory tmp_ip_list  

create_ip -name $ip_name -vendor xilinx.com -library ip -version "*" -module_name tmp_ip_inst

set ip_obj [get_ips tmp_ip_inst]
set props_str [report_property -all -return_string $ip_obj]

set fp [open "./ip/config_templates/$ip_name.txt" "w"]

puts $fp "$ip_name"

foreach line [split $props_str "\n"] {
    if {[regexp {^CONFIG\.} $line]} {
		set fields [split $line]
		set prop  [lindex $fields 0]
        set value [lindex $fields end]
        puts $fp "$prop : $value"
    }
}

close $fp
