#include "Header.h"

ButtonQueue buttonQueue;

void BTQ_init () {
	buttonQueue.first = 0;
	buttonQueue.last = 0;
	buttonQueue.empty = 1;
}

void BTQ_add (int pressed, int button, int time) {
	int index;
	ButtonPress buttonPress;
	buttonPress.pressed = pressed;
	buttonPress.button = button;
	buttonPress.time = time;
	if (buttonQueue.empty) {
		buttonQueue.buttonPress[buttonQueue.last] = buttonPress;
		buttonQueue.empty = 0;
	} else {
		index = (buttonQueue.last + 1) % BTQ_SIZE;
		if (index == buttonQueue.first) return;
		buttonQueue.last = index;
		buttonQueue.buttonPress[buttonQueue.last] = buttonPress;
		buttonQueue.empty = 0;
	}
}

ButtonPress BTQ_get () {
	ButtonPress buttonPress = buttonQueue.buttonPress[buttonQueue.first];
	if (!buttonQueue.empty) {
		if (buttonQueue.first == buttonQueue.last) {
			buttonQueue.empty = 1;
		} else {
			buttonQueue.first = (buttonQueue.first + 1) % BTQ_SIZE;
		}
	}
	return buttonPress;
}

int BTQ_isEmpty () {
	return buttonQueue.empty;
}
