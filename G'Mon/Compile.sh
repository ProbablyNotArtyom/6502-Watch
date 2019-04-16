java -jar "../KickAss.jar" Configuration.asm -afo -binfile :STATE=0 -o ROM.bin		# Compile without EhBasic

file="tmp"								# Get the path to the tmp file
BAddrs=$(cat "$file")

cd ehbasic								# Change to the ehbasic directory
sed -i '3d' symon.config				# Delete the line of the config declaring the start of EhBasic
sed -i '3i'"$BAddrs"'' symon.config		# Put the new line with the new origin point int

./ca65 --listing ehbasic.lst -o ehbasic.o min_mon.asm					# Compile EhBasic
./ld65 -C symon.config -vm -m ehbasic.map -o ehbasic.bin ehbasic.o

cp ehbasic.bin ../						# Copy the EhBasic binary to the main code directory (1 up)
cd ..

java -jar "../KickAss.jar" Configuration.asm -afo -binfile :STATE=1 -o ROM.bin		# Compule with EhBasic
