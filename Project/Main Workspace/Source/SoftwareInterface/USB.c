#include "Header.h"

#include "usb_core.h"
#include "usbd_desc.h"
#include "usbd_cdc_core.h"
#include "usbd_usr.h"
#include "stm32f4xx_exti.h"

USB_OTG_CORE_HANDLE USB_OTG_dev;

#define bufferSize 256
char stringBuffer [bufferSize];
int bufferIndex;
int stringEntered;
int numChars;

void USB_init () {
	stringBuffer[0] = '\0';
	bufferIndex = 0;
	stringEntered = 0;
	numChars = 0;
	USBD_Init(&USB_OTG_dev, USB_OTG_FS_CORE_ID, &USR_desc, &USBD_CDC_cb, &USR_cb);
}

int USB_getChar (char *c) {
	return VCP_get_char(c);
}

void USB_putChar (char c) {
	VCP_put_char((uint8_t) c);
}

void USB_update () {
	unsigned char c;
	if (stringEntered) return;
	if (USB_getChar((char*) &c)) {
		if (numChars == 0) {
			numChars = (int) c;
		} else {
			stringBuffer[bufferIndex++] = (char) c;
			if (bufferIndex == numChars) {
				bufferIndex = 0;
				stringEntered = 1;
				numChars = 0;
			}
		}
	}
}

char* USB_getString () {
	if (stringEntered) {
		stringEntered = 0;
		return stringBuffer;
	}
	return 0;
}

void USB_putString (char *string) {
	while (*string) USB_putChar(*(string++));
	USB_putChar(*(string++));
}

void OTG_FS_Handler () {
	USBD_OTG_ISR_Handler (&USB_OTG_dev);
}

void OTG_FS_WKUP_Handler () {
	if (USB_OTG_dev.cfg.low_power) {
		*(uint32_t *)(0xE000ED10) &= 0xFFFFFFF9 ;
		SystemInit();
		USB_OTG_UngateClock(&USB_OTG_dev);
	}
	EXTI_ClearITPendingBit(EXTI_Line18);
}
