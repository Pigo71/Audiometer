#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <windows.h>

#define LINE_MAX_SIZE 256
#define PORT_NAME_MAX_SIZE 256
#define INPUT_FILE_NAME_MAX_SIZE 256
#define OUTPUT_FILE_NAME_MAX_SIZE 256

HANDLE gPortHandle = 0;
char gPortName [PORT_NAME_MAX_SIZE] = {0};
int gPortIsSet = 0;
char gInputFileName [INPUT_FILE_NAME_MAX_SIZE] = {0};
int gInputFileNameIsSet = 0;
char gOutputFileName [OUTPUT_FILE_NAME_MAX_SIZE] = {0};
int gOutputFileNameIsSet = 0;

int setPort (char *pPortName) {

	if (gPortHandle) CloseHandle(gPortHandle);

	gPortHandle = CreateFile(pPortName, GENERIC_READ | GENERIC_WRITE, 0, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);

	if (gPortHandle == INVALID_HANDLE_VALUE) {
		if (GetLastError() == ERROR_FILE_NOT_FOUND) {
			printf("Error: setPort: couldn't find serial port.\n");
			return 0;
		} else {
			printf("Error: setPort: couldn't create port handle.\n");
			return 0;
		}
	}

	DCB dcbSerialParams = {0};
	dcbSerialParams.DCBlength = sizeof(dcbSerialParams);
	if (!GetCommState(gPortHandle, &dcbSerialParams)) {
		printf("Error: setPort: couldn't get port state.\n");
		return 0;
	}
	dcbSerialParams.BaudRate = CBR_9600;
	dcbSerialParams.ByteSize = 8;
	dcbSerialParams.StopBits = ONESTOPBIT;
	dcbSerialParams.Parity = NOPARITY;
	if (!SetCommState(gPortHandle, &dcbSerialParams)) {
		printf("Error: setPort: couldn't set port state.\n");
		return 0;
	}

	COMMTIMEOUTS timeouts = {0};
	timeouts.ReadIntervalTimeout = 50;
	timeouts.ReadTotalTimeoutConstant = 50;
	timeouts.ReadTotalTimeoutMultiplier = 10;
	timeouts.WriteTotalTimeoutConstant = 50;
	timeouts.WriteTotalTimeoutMultiplier = 10;
	if (!SetCommTimeouts(gPortHandle, &timeouts)) {
		printf("Error: setPort: couldn't set timeouts.\n");
		return 0;
	}

	strcpy(gPortName, pPortName);
	gPortIsSet = 1;
	return 1;

}

// Returns a string containing a line from the file. It will either stop populating string when it detects a newline character (excluding the character from the string), or when the number of characters in the string reaches maxSize. 
char* getLine (char *string, int maxSize, FILE* file) {
	int size;
	string = fgets(string, maxSize, file);
	if (string) {
		size = strlen(string);
		if (string[size-1] == '\n') string[--size] = '\0';
	}
	return string;
}

// Same as getLine, but the file is stdin / the console. 
char* consoleGetLine (char *string, int maxSize) {
	return getLine(string, maxSize, stdin);
}

// Returns 1 if str begins with pre, otherwise, 0. 
int stringBeginsWith (const char *str, const char *pre) {
	unsigned int prelen = strlen(pre);
	if (prelen <= strlen(str) && strncmp(pre, str, prelen) == 0) return 1;
	else return 0;
}

// Writes a buffer to the USB port. Stops when the number of bytes sent equals size. NumBytes will be set to the number of bytes successfully sent (to help with error handling). 
void sendBuffer (char *buffer, int size, int *numBytes) {
	if (WriteFile(gPortHandle, buffer, size, (PDWORD) numBytes, NULL) == 0) {
		printf("Error: sendBuffer: couldn't write to port.\n");
	}
}

// Reads a buffer from the USB port. Stops when the number of bytes read equals size. NumBytes will be set to the number of bytes successfully read (to help with error handling). 
void getBuffer (char *buffer, int size, int *numBytes) {
	if (ReadFile(gPortHandle, buffer, size, (PDWORD) numBytes, NULL) == 0) {
		printf("Error: sendBuffer: couldn't write to port.\n");
	}
}

// Converts the script (given by gInputFileName) to USB protocol and shares it with the device using using sendBuffer and getBuffer. 
void sendScript () {

	char line [LINE_MAX_SIZE];
	FILE *file;
	unsigned int button, presses, cw, stops, delay;
	unsigned char buffer [8];
	int numBytes;

	if (gPortIsSet == 0 || gInputFileNameIsSet == 0) {
		printf("Error: sendScript: port and input file name are not set. \n");
		return;
	}
	file = fopen(gInputFileName, "r");
	if (!file) {
		printf("Error: sendScript: file could not be opened.\n");
		return;
	}

	while (getLine(line, LINE_MAX_SIZE, file) != 0) {
		if (stringBeginsWith(line, "// ")) {
			// do nothing, comment
		} else if (strcmp(line, "") == 0) {
			// do nothing, blank line
		} else if (sscanf(line, "press button %d %d\n", &button, &presses) == 2) {
			buffer[0] = 3;
			buffer[1] = 1;
			buffer[2] = button;
			buffer[3] = presses;
			sendBuffer((char*) buffer, 4, &numBytes);
		} else if (sscanf(line, "hold button %d\n", &button) == 1) {
			buffer[0] = 2;
			buffer[1] = 2;
			buffer[2] = button;
			sendBuffer((char*) buffer, 3, &numBytes);
		} else if (sscanf(line, "release button %d\n", &button) == 1) {
			buffer[0] = 2;
			buffer[1] = 3;
			buffer[2] = button;
			sendBuffer((char*) buffer, 3, &numBytes);
		} else if (sscanf(line, "turn rotary %d %d\n", &cw, &stops) == 2) {
			buffer[0] = 3;
			buffer[1] = 4;
			buffer[2] = cw;
			buffer[3] = stops;
			sendBuffer((char*) buffer, 4, &numBytes);
		} else if (sscanf(line, "wait %d\n", &delay) == 1) {
			// buffer[0] = 5;
			// buffer[1] = 5;
			// buffer[2] = (delay & 0xFF000000) >> 24;
			// buffer[3] = (delay & 0x00FF0000) >> 16;
			// buffer[4] = (delay & 0x0000FF00) >>  8;
			// buffer[5] = (delay & 0x000000FF) >>  0;
			// sendBuffer((char*) buffer, 6, &numBytes);
			// Sleep(delay * 9 / 10);
			// getBuffer((char*) buffer, 1, &numBytes);
			// while (numBytes == 0) {
			// 	Sleep(1);
			// 	getBuffer((char*) buffer, 1, &numBytes);
			// }
			Sleep(delay);
		} else {
			printf("Error: sendScript: unrecognized command.\n");
			printf(" > %s\n", line);
		}
	}

	fclose(file);

}

// Reads the user records from the device, printing them both to console and to the file given by gOutputFileName. 
void getRecords () {
	
	FILE *file;
	unsigned char buffer [8];
	int numBytes;
	int numRecords, i, intensity, frequency;

	if (gPortIsSet == 0 || gOutputFileNameIsSet == 0) {
		printf("Error: sendScript: port and output file name are not set. \n");
		return;
	}
	file = fopen(gOutputFileName, "w");
	if (!file) {
		printf("Error: sendScript: file could not be opened.\n");
		return;
	}

	printf("Frequency, Intensity\n");
	fprintf(file, "Frequency, Intensity\n");
	buffer[0] = 1;
	buffer[1] = 6;
	sendBuffer((char*) buffer, 2, &numBytes);
	getBuffer((char*) buffer, 1, &numBytes);
	numRecords = buffer[0];
	for (i = 0; i < numRecords; i++) {
		getBuffer((char*) buffer, 3, &numBytes);
		intensity = buffer[0];
		frequency = (((int) buffer[1]) <<  8) + (((int) buffer[2]) <<  0);
		printf("%d, %d\n", frequency, intensity);
		fprintf(file, "%d, %d\n", frequency, intensity);
	}

	fclose(file);

}

int main () {

	char line [LINE_MAX_SIZE];
	char portName [PORT_NAME_MAX_SIZE];

	// Set default file names for script and output files.
	strcpy(gInputFileName, "script.txt");
	gInputFileNameIsSet = 1;
	strcpy(gOutputFileName, "output.txt");
	gOutputFileNameIsSet = 1;

	while (1) {
		consoleGetLine(line, LINE_MAX_SIZE);
		if (strcmp(line, "set port") == 0) {
			printf("port: ");
			consoleGetLine(portName, PORT_NAME_MAX_SIZE);
			setPort(portName);
		} else if (strcmp(line, "set script") == 0) {
			printf("script name: ");
			consoleGetLine(gInputFileName, INPUT_FILE_NAME_MAX_SIZE);
			gInputFileNameIsSet = 1;
		} else if (strcmp(line, "set output") == 0) {
			printf("output name: ");
			consoleGetLine(gOutputFileName, OUTPUT_FILE_NAME_MAX_SIZE);
			gOutputFileNameIsSet = 1;
		} else if (strcmp(line, "send script") == 0) {
			sendScript();
		} else if (strcmp(line, "get records") == 0) {
			getRecords();
		} else if (strcmp(line, "quit") == 0) {
			break;
		} else {
			printf("Error: unrecognized command.\n");
		}
	}

	if (gPortHandle != 0) CloseHandle(gPortHandle);

    return 0;
}
