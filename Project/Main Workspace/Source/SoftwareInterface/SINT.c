#include "Header.h"

extern Record records [];
extern int nextrecord;

void SINT_init () {
	USB_init();
}

void SINT_update () {

	unsigned char *string;
	int i;

	USB_update();
	if ((string = USB_getString()) != 0) {
		if (string[0] == 1) {
			for (i = 0; i < string[2]; i++) {
				HINT_simulateButtonPress(1, string[1]-1, CINT_time);
				HINT_simulateButtonPress(0, string[1]-1, CINT_time);
			}
		} else if (string[0] == 2) {
			HINT_simulateButtonPress(1, string[1]-1, CINT_time);
		} else if (string[0] == 3) {
			HINT_simulateButtonPress(0, string[1]-1, CINT_time);
		} else if (string[0] == 4) {
			HINT_simulateRotaryTurn(string[1], string[2]);
		} else if (string[0] == 5) {
			HINT_simulateDelay(
				(((int) string[1]) << 24) + 
				(((int) string[2]) << 16) + 
				(((int) string[3]) <<  8) + 
				(((int) string[4]) <<  0)
			);
		} else if (string[0] == 6) {
			USB_putChar(nextrecord);
			for (i = 0; i < nextrecord; i++) {
				USB_putChar(records[i].intensity);
				USB_putChar((records[i].frequency & 0x0000FF00) >> 8);
				USB_putChar((records[i].frequency & 0x000000FF) >> 0);
			}
		}
	}

}
