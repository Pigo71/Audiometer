#include "Header.h"

unsigned int CINT_time;

void CINT_init () {
	SystemInit();
	SystemCoreClockUpdate();
	STK_init();
}
