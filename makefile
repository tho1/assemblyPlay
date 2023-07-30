runme: main.cpp	asm.o
		g++ main.cpp asm.o -o runme

asm.o: asm.asm
		nasm -f elf64 asm.asm -o asm.o
