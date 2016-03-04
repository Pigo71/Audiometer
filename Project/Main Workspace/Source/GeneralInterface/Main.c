#include "Header.h"

void main () {
	
	// The order matters here. 
	CINT_init(); // initialize clock interface
	TINT_init(); // initialize tone interface
	HINT_init(); // initialize hardware interface
	SINT_init(); // initialize software interface
	
	while (1) {
		SINT_update();
		HINT_update();
	}
	
}
