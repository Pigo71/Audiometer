#include "Header.h"

// so the order of the functions doesn't matter (some call others)
void reset ();
void startState0 ();
void startState1 ();
void startState2 ();
void updateState0 ();
void updateState1 ();
void updateState2 ();
void stopState0 ();
void stopState1 ();
void stopState2 ();

// preintensity stores the phase-steps, and is converted to intensity
// it's used because 2.5db/detent-stop develops error when truncating to integers
int frequency;
int intensity;
int preintensity;
int state;

// used to blink LED5 as a warning, when holding the RESET button
int warnfreq;
int warnon;
int warnstop;

// used to blink LED6 as an indicator that the tone is on
int toneon;
int toneledon;
int toneledstop;

// used to keep track of the time a button was pushed
ButtonPress lastButtonPress [13];

// used to store (frequency, intensity) when pressing the RECORD button (SW12)
#define NUM_RECORDS 5
Record records [NUM_RECORDS];
int nextrecord;
int disprecord;

void HINT_init () {
	
	BTN_init();
	BTQ_init();
	P24_init();
	DISP_init();
	LED_init();
	TIM7_init();
	ROT_init();

	reset();

}

void reset () {
	
	ButtonPress buttonPress;
	Record record;
	int i;

	DISP_setDigit(0, space);
	DISP_setDigit(1, space);
	DISP_setDigit(2, space);
	DISP_setDigit(3, space);

	LED_setOn(0, 0);
	LED_setOn(1, 0);
	LED_setOn(2, 0);
	LED_setOn(3, 0);
	LED_setOn(4, 0);
	LED_setOn(5, 0);

	frequency = 125;
	TINT_setFrequency(frequency);
	preintensity = -16;
	intensity = preintensity * 5 / 8;
	TINT_setIntensity(intensity);
	
	warnfreq = 0;
	warnon = 0;
	warnstop = 0;

	toneon = 0;
	toneledon = 0;
	toneledstop = 0;

	buttonPress.button = 0;
	buttonPress.pressed = 0;
	buttonPress.time = 0;
	for (i = 0; i < 13; i++) {
		lastButtonPress[i] = buttonPress;
	}

	ROT_setOn(0);

	nextrecord = 0;
	disprecord = 0;
	record.frequency = 0;
	record.intensity = 0;
	for (i = 0; i < NUM_RECORDS; i++) {
		records[i] = record;
	}

	startState0();

}

void startState0 () {
	state = 0;
	LED_setOn(0, 1);
	DISP_setInteger(frequency);
}

void startState1 () {
	state = 1;
	LED_setOn(1, 1);
	DISP_setInteger(intensity);
	ROT_setOn(1);
}

void startState2 () {
	state = 2;
	LED_setOn(2, 1);
	LED_setOn(4, 0); // in case the warning LED was left on after blinking
	if (nextrecord) DISP_setInteger(records[0].intensity);
	disprecord = 0;
}

void updateState0 () {
	int up, digit, i, temp, time;
	ButtonPress buttonPress;
	if (!BTQ_isEmpty()) {
		buttonPress = BTQ_get();
		if (buttonPress.pressed) {
			if (buttonPress.button < 8) {
				up = ((buttonPress.button % 2) == 0);
				digit = buttonPress.button / 2;
				switch (digit) {
					case 0: temp = 1000; break;
					case 1: temp =  100; break;
					case 2: temp =   10; break;
					case 3: temp =    1; break;
					default: break;
				}
				if (!up) temp = ~temp + 1;
				temp += frequency;
				if (temp < 125) temp = 125;
				if (temp > 8000) temp = 8000;
				frequency = temp;
				preintensity = -16;
				intensity = preintensity * 5 / 8;
				DISP_setInteger(frequency);
			} else if (buttonPress.button == 9) {
				stopState0();
				startState1();
			}
		} else {
			if (buttonPress.button == 10) {
				time = buttonPress.time - lastButtonPress[10].time;
				if (time > 1000 && time < 10000) {
					stopState0();
					startState2();
				}
			}
		}
		lastButtonPress[buttonPress.button] = buttonPress;
	}
}

void updateState1 () {
	int temp, time;
	ButtonPress buttonPress;
	if (ROT_value != 0) {
		temp = preintensity + ROT_value;
		ROT_value = 0;
		if (temp < -16) temp = -16;
		if (temp > 176) temp = 176;
		preintensity = temp;
		intensity = preintensity * 5 / 8;
		DISP_setInteger(intensity);
		TINT_setIntensity(intensity);
	}
	if (!BTQ_isEmpty()) {
		buttonPress = BTQ_get();
		if (buttonPress.pressed) {
			if (buttonPress.button == 8) {
				stopState1();
				startState0();
			} else if (buttonPress.button == 9) {
				toneon = !toneon;
				TINT_setOn(toneon);
				if (!toneon) LED_setOn(5, 0);
			} else if (buttonPress.button == 11) {
				if (nextrecord < NUM_RECORDS) {
					records[nextrecord].frequency = frequency;
					records[nextrecord].intensity = intensity;
					nextrecord++;
				}
			}
		} else {
			if (buttonPress.button == 10) {
				time = buttonPress.time - lastButtonPress[10].time;
				if (time < 1000) {
					if (nextrecord > 0) nextrecord--;
				} else if (time < 10000) {
					stopState1();
					startState2();
				}
			}
		}
		lastButtonPress[buttonPress.button] = buttonPress;
	}
}

void updateState2 () {
	ButtonPress buttonPress;
	if (!BTQ_isEmpty()) {
		buttonPress = BTQ_get();
		if (buttonPress.pressed) {
			if (buttonPress.button == 8) {
				if (disprecord < nextrecord) {
					DISP_setInteger(records[disprecord].frequency);
				}
			} else if (buttonPress.button == 9) {
				stopState2();
				startState1();
			} else if (buttonPress.button == 11) {
				if (disprecord < nextrecord) {
					disprecord++;
					if (disprecord == nextrecord) {
						DISP_setDigit(0, space);
						DISP_setDigit(1, space);
						DISP_setDigit(2, space);
						DISP_setDigit(3, space);
					} else if (lastButtonPress[8].pressed) {
						DISP_setInteger(records[disprecord].frequency);
					} else {
						DISP_setInteger(records[disprecord].intensity);
					}
				}
			}
		} else {
			if (buttonPress.button == 8) {
				if (disprecord < nextrecord) {
					DISP_setInteger(records[disprecord].intensity);
				}
			}
		}
		lastButtonPress[buttonPress.button] = buttonPress;
	}
}

void stopState0 () {

	LED_setOn(0, 0);
	
	DISP_setDigit(0, space);
	DISP_setDigit(1, space);
	DISP_setDigit(2, space);
	DISP_setDigit(3, space);

	TINT_setFrequency (frequency);

}

void stopState1 () {
	
	ROT_setOn(0);
	
	LED_setOn(1, 0);

	DISP_setDigit(0, space);
	DISP_setDigit(1, space);
	DISP_setDigit(2, space);
	DISP_setDigit(3, space);
	
	toneon = 0;
	toneledon = 0;
	LED_setOn(5, 0);
	toneledstop = 0;
	TINT_setOn(0);

}

void stopState2 () {

	LED_setOn(2, 0);

	DISP_setDigit(0, space);
	DISP_setDigit(1, space);
	DISP_setDigit(2, space);
	DISP_setDigit(3, space);

}

void HINT_simulateButtonPress (int pressed, int button, int time) {
	BTQ_add(pressed, button, time);
}

void HINT_simulateRotaryTurn (int cw, int numStops) {
	if (ROT_on) {
		if (cw) {
			ROT_value += 4 * numStops;
		} else {
			ROT_value -= 4 * numStops;
		}
	}
}

// delay in milliseconds
void HINT_simulateDelay (int delay) {
	
}

void HINT_update () {
	int time;
	if (toneon) {
		if (CINT_time > toneledstop) {
			toneledon = !toneledon;
			LED_setOn(5, toneledon);
			toneledstop = CINT_time + 166;
		}
	}
	if (lastButtonPress[10].pressed) {
		time = CINT_time - lastButtonPress[10].time;
		if (time > 10000) {
			LED_setOn(3, 1);
			STK_delay(2000);
			reset();
			return;
		} else if (time > 5000) {
			if (CINT_time > warnstop) {
				switch (time / 1000) {
					case 9: warnstop = CINT_time + 56;  break; 
					case 8: warnstop = CINT_time + 62;  break; 
					case 7: warnstop = CINT_time + 71;  break; 
					case 6: warnstop = CINT_time + 83;  break; 
					case 5: warnstop = CINT_time + 100; break; 
				}
				warnon = !warnon;
				LED_setOn(4, warnon);
			}
		}
	}
	switch (state) {
		case 0: updateState0(); break;
		case 1: updateState1(); break;
		case 2: updateState2(); break;
		default: break;
	}
}