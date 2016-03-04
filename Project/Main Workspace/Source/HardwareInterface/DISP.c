#include "Header.h"

void DISP_setInteger (int integer) {
	int index, temp, numDigits = 0, negative = 0;
	if (integer < 0) {
		negative = 1;
		integer = ~integer + 1;
		numDigits++;
	}
	temp = integer;
	while (temp > 0) {
		temp /= 10;
		numDigits++;
	}
	if (integer == 0) numDigits++; // won't increment in the loop above
	if (numDigits > 4) {
		DISP_setDigit(0, dash);
		DISP_setDigit(1, dash);
		DISP_setDigit(2, dash);
		DISP_setDigit(3, dash);
		return;
	}
	for (index = 0; index <= (4 - numDigits); index++) {
		DISP_setDigit(index, space);
	}
	if (negative) DISP_setDigit(4 - numDigits--, dash);
	for (index = 1; index <= numDigits; index++) {
		DISP_setDigit(4 - index, integer % 10);
		integer = integer / 10;
	}
}
