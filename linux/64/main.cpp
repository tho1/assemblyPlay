
#include <iostream>

using namespace std;

extern "C" int GetValueFromASM();


int GetValueFromInline()
{
	/* AT&T syntax */
	/* inline assembler */
	asm("movl $254, %eax");
}

int main()
{
	cout<<"asm said "<<GetValueFromASM()<<endl;
	return 0;
}
