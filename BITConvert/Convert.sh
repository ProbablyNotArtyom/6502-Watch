
Input=$1
cp $Input INPUT.bin
java -jar "./KickAss.jar" Convert.asm -afo -binfile -o ROM.ROM		
./run6502 -l 8000 ROM.ROM -R 8100
rm ROM.ROM
rm INPUT.bin
