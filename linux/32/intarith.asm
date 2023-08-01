; intarith.asm    show some simple C code and corresponding nasm code
;                 the nasm code is one sample, not unique
;
; compile:	nasm -f elf -l intarith.lst  intarith.asm
; link:		gcc -o intarith  intarith.o
; run:		intarith
;
; the output from running intarith.asm and intarith.c is:	
; c=5  , a=3, b=4, c=5
; c=a+b, a=3, b=4, c=7
; c=a-b, a=3, b=4, c=-1
; c=a*b, a=3, b=4, c=12
; c=c/a, a=3, b=4, c=4
;
;The file  intarith.c  is:
;  /* intarith.c */
;  #include <stdio.h>
;  int main()
;  { 
;    int a=3, b=4, c;
;
;    c=5;
;    printf("%s, a=%d, b=%d, c=%d\n","c=5  ", a, b, c);
;    c=a+b;
;    printf("%s, a=%d, b=%d, c=%d\n","c=a+b", a, b, c);
;    c=a-b;
;    printf("%s, a=%d, b=%d, c=%d\n","c=a-b", a, b, c);
;    c=a*b;
;    printf("%s, a=%d, b=%d, c=%d\n","c=a*b", a, b, c);
;    c=c/a;
;    printf("%s, a=%d, b=%d, c=%d\n","c=c/a", a, b, c);
;    return 0;
; }

        extern printf		; the C function to be called

%macro	pabc 1			; a "simple" print macro
	section .data
.str	db	%1,0		; %1 is first actual in macro call
	section .text
				; push onto stack backwards 
	push	dword [c]	; int c
	push	dword [b]	; int b 
	push	dword [a]	; int a
	push	dword .str 	; users string
        push    dword fmt       ; address of format string
        call    printf          ; Call C function
        add     esp,20          ; pop stack 5*4 bytes
%endmacro
	
	section .data  		; preset constants, writeable
a:	dd	3		; 32-bit variable a initialized to 3
b:	dd	4		; 32-bit variable b initializes to 4
fmt:    db "%s, a=%d, b=%d, c=%d",10,0	; format string for printf
	
	section .bss 		; unitialized space
c:	resd	1		; reserve a 32-bit word

	section .text		; instructions, code segment
	global	 main		; for gcc standard linking
main:				; label
	
lit5:				; c=5;
	mov	eax,5	 	; 5 is a literal constant
	mov	[c],eax		; store into c
	pabc	"c=5  "		; invoke the print macro
	
addb:				; c=a+b;
	mov	eax,[a]	 	; load a
	add	eax,[b]		; add b
	mov	[c],eax		; store into c
	pabc	"c=a+b"		; invoke the print macro
	
subb:				; c=a-b;
	mov	eax,[a]	 	; load a
	sub	eax,[b]		; subtract b
	mov	[c],eax		; store into c
	pabc	"c=a-b"		; invoke the print macro
	
mulb:				; c=a*b;
	mov	eax,[a]	 	; load a (must be eax for multiply)
	imul	dword [b]	; signed integer multiply by b
	mov	[c],eax		; store bottom half of product into c
	pabc	"c=a*b"		; invoke the print macro
	
diva:				; c=c/a;
	mov	eax,[c]	 	; load c
	mov	edx,0		; load upper half of dividend with zero
	idiv	dword [a]	; divide double register edx eax by a
	mov	[c],eax		; store quotient into c
	pabc	"c=c/a"		; invoke the print macro

        mov     eax,0           ; exit code, 0=normal
	ret			; main return to operating system

