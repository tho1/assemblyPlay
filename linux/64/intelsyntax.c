#include <stdio.h>

/** 
 * gcc intel.c -o intel -masm=intel
 *
 * calling intel syntax in gcc
 */
int get_random( void )
{
	asm(".intel_syntax noprefix\n"
		"mov eax, 42			\n");
}

int main (void)
{	
	return printf("The answer is %d.\n", get_random());
}
