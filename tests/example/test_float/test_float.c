#include <stdint.h>
#include "../include/utils.h"

typedef float float32_t;

int main()
{
	float result;
	
	float a = 1.5f;
	float b = 0.1f;
	float ans = -1.6f;
	float esp = 1e-5f;
	float test = a + b + ans;
	
	float *p = &test;
	float *p2 = &esp;
	if (((*(unsigned*)(void*)p) & 0x7fffffff) < (*(unsigned*)(void*)p2))
		set_test_pass();
	else 
		set_test_fail();
	
	return 0;
}
