set files [list {*}$argv]

foreach file $files {

    # Extraire l'extension
	
    if {[regexp {\.([^.]+)$} $file -> ext]} {
        switch -- $ext {
            "vhd" {
                puts "Ajout du fichier VHDL : $file"
                read_vhdl $file
            }
            "sv" {
                puts "Ajout du fichier SystemVerilog : $file"
				read_verilog --sv $file                	
                
            }
            "v" {
                puts "Ajout du fichier Verilog : $file"
				read_verilog $file
            }
            default {
                puts "Extension non gérée : $file"
            }
        }
    } else {
        puts "Pas d'extension pour le fichier : $file"
    }
}
