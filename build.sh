nasm -f bin boot.asm -o boot.bin
nasm -f bin shell.asm -o shell.bin

mkdir -p iso_root

dd if=/dev/zero of=iso_root/floppy.img bs=512 count=2880

dd if=boot.bin of=iso_root/floppy.img conv=notrunc bs=512 seek=0
dd if=shell.bin of=iso_root/floppy.img conv=notrunc bs=512 seek=1

xorriso -as mkisofs -V "GUBGUBOS" -b floppy.img -hide floppy.img -o gubgubOS.iso iso_root/
