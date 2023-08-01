; printf2.asm  use "C" printf on char, string, int, double
; 
; Assemble:	nasm -f elf -l printf2.lst  printf2.asm
; Link:		gcc -o printf2  printf2.o
; Run:		printf2
; Output:	
;Hello world: a string of length 7 1234567 6789ABCD 5.327000e-30 -1.234568E+302
; 
; A similar "C" program
; #include <stdio.h>
; int main()
; {
;   char   char1='a';         /* sample character */
;   char   str1[]="string";   /* sample string */
;   int    int1=1234567;      /* sample integer */
;   int    hex1=0x6789ABCD;   /* sample hexadecimal */
;   float  flt1=5.327e-30;    /* sample float */
;   double flt2=-123.4e300;   /* sample double */
; 
;   printf("Hello world: %c %s %d %X %e %E \n", /* format string for printf */
;          char1, str1, int1, hex1, flt1, flt2);
;   return 0;
; }


        extern printf                   ; the C function to be called

        SECTION .data                   ; Data section

msg:    db "Hello world: %c %s of length %d %d %X %e %E",10,0
					; format string for printf
char1:	db	'a'			; a character 
str1:	db	"string",0	        ; a C string, "string" needs 0
len:	equ	$-str1			; len has value, not an address
inta1:	dd	1234567		        ; integer 1234567
hex1:	dd	0x6789ABCD	        ; hex constant 
flt1:	dd	5.327e-30		; 32-bit floating point
flt2:	dq	-123.456789e300	        ; 64-bit floating point

	SECTION .bss
		
flttmp:	resq 1			        ; 64-bit temporary for printing flt1
	
        SECTION .text                   ; Code section.

        global	main		        ; "C" main program 
main:				        ; label, start of main program
	 
	fld	dword [flt1]	        ; need to convert 32-bit to 64-bit
	fstp	qword [flttmp]          ; floating load makes 80-bit,
	                                ; store as 64-bit
	                                ; push last argument first
	push	dword [flt2+4]	        ; 64 bit floating point (bottom)
	push	dword [flt2]	        ; 64 bit floating point (top)
	push	dword [flttmp+4]        ; 64 bit floating point (bottom)
	push	dword [flttmp]	        ; 64 bit floating point (top)
	push	dword [hex1]	        ; hex constant
	push	dword [inta1]	        ; integer data pass by value
	push	dword len	        ; constant pass by value
	push	dword str1		; "string" pass by reference 
        push    dword [char1]		; 'a'
        push    dword msg		; address of format string
        call    printf			; Call C function
        add     esp, 40			; pop stack 10*4 bytes

        mov     eax, 0			; exit code, 0=normal
        ret				; main returns to operating system
