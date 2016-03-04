void SINT_init ();

void USB_init ();
int USB_getChar (char *c);
void USB_putChar (char c);
void USB_update ();
char* USB_getString ();
void USB_putString (char *string);

void CINT_init ();

#define BTQ_SIZE 16
typedef struct ButtonPress {
	int pressed	:1;
	int button	:7;
	int time	:24;
} ButtonPress;
typedef struct ButtonQueue {
	struct ButtonPress buttonPress[BTQ_SIZE];
	int first;
	int last;
	int empty;
} ButtonQueue;
void BTQ_init ();
void BTQ_add (int pressed, int button, int time);
ButtonPress BTQ_get ();
int BTQ_isEmpty ();

#define dash 10
#define space 11

extern int ROT_value;
extern int ROT_on;
extern unsigned int CINT_time;

typedef struct Record {
	int frequency;
	int intensity;
} Record;
