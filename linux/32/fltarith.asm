; fltarith.asm   show some simple C code and corresponding nasm code
;                the nasm code is one sample, not unique
;
; compile  nasm -f elf -l fltarith.lst  fltarith.asm
; link     gcc -o fltarith  fltarith.o
; run      fltarith
;
; the output from running fltarith and fltarithc is:	
; c=5.0, a=3.000000e+00, b=4.000000e+00, c=5.000000e+00
; c=a+b, a=3.000000e+00, b=4.000000e+00, c=7.000000e+00
; c=a-b, a=3.000000e+00, b=4.000000e+00, c=-1.000000e+00
; c=a*b, a=3.000000e+00, b=4.000000e+00, c=1.200000e+01
; c=c/a, a=3.000000e+00, b=4.000000e+00, c=4.000000e+00
;
;The file  fltarith.c  is:
;  #include <stdio.h>
;  int main()
;  { 
;    double a=3.0, b=4.0, c;
;
;    c=5.0;
;    printf("%s, a=%e, b=%e, c=%e\n","c=5.0", a, b, c);
;    c=a+b;
;    printf("%s, a=%e, b=%e, c=%e\n","c=a+b", a, b, c);
;    c=a-b;
;    printf("%s, a=%e, b=%e, c=%e\n","c=a-b", a, b, c);
;    c=a*b;
;    printf("%s, a=%e, b=%e, c=%e\n","c=a*b", a, b, c);
;    c=c/a;
;    printf("%s, a=%e, b=%e, c=%e\n","c=c/a", a, b, c);
;    return 0;
; }

        extern printf		; the C function to be called

%macro	pabc 1			; a "simple" print macro
	section	.data
.str	db	%1,0		; %1 is macro call first actual parameter
	section .text
				; push onto stack backwards 
	push	dword [c+4]	; double c (bottom)
	push	dword [c]	; double c
	push	dword [b+4]	; double b (bottom)
	push	dword [b]	; double b 
	push	dword [a+4]	; double a (bottom)
	push	dword [a]	; double a
	push	dword .str 	; users string
        push    dword fmt       ; address of format string
        call    printf          ; Call C function
        add     esp,32          ; pop stack 8*4 bytes
%endmacro
	
	section	.data  		; preset constants, writeable
a:	dq	3.333333333	; 64-bit variable a initialized to 3.0
b:	dq	4.444444444	; 64-bit variable b initializes to 4.0
five:	dq	5.0		; constant 5.0
fmt:    db "%s, a=%e, b=%e, c=%e",10,0	; format string for printf
	
	section .bss 		; unitialized space
c:	resq	1		; reserve a 64-bit word

	section .text		; instructions, code segment
	global	main		; for gcc standard linking
main:				; label
	
lit5:				; c=5.0;
	fld	qword [five]	; 5.0 constant
	fstp	qword [c]	; store into c
	pabc	"c=5.0"		; invoke the print macro
	
addb:				; c=a+b;
	fld	qword [a] 	; load a (pushed on flt pt stack, st0)
	fadd	qword [b]	; floating add b (to st0)
	fstp	qword [c]	; store into c (pop flt pt stack)
	pabc	"c=a+b"		; invoke the print macro
	
subb:				; c=a-b;
	fld	qword [a] 	; load a (pushed on flt pt stack, st0)
	fsub	qword [b]	; floating subtract b (to st0)
	fstp	qword [c]	; store into c (pop flt pt stack)
	pabc	"c=a-b"		; invoke the print macro
	
mulb:				; c=a*b;
	fld	qword [a]	; load a (pushed on flt pt stack, st0)
	fmul	qword [b]	; floating multiply by b (to st0)
	fstp	qword [c]	; store product into c (pop flt pt stack)
	pabc	"c=a*b"		; invoke the print macro
	
diva:				; c=c/a;
	fld	qword [c] 	; load c (pushed on flt pt stack, st0)
	fdiv	qword [a]	; floating divide by a (to st0)
	fstp	qword [c]	; store quotient into c (pop flt pt stack)
	pabc	"c=c/a"		; invoke the print macro

        mov     eax,0           ; exit code, 0=normal
	ret			; main returns to operating system


