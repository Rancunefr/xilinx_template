set bitfile [lindex $::argv 0]
set binfile [lindex $::argv 1]

# Creates a .bin file via write_cfgmem
write_cfgmem \
	-format bin \
	-interface spix4 \
  	-loadbit "up 0 $bitfile" \
	-size 16 \
	-force \
	-file $binfile

exit
