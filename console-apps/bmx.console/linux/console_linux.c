
#include <ctype.h>
#include <stdlib.h>
#include <termios.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <brl.mod/blitz.mod/blitz.h>

struct termios original;

/*
// LOCAL FLAGS

BBINT get_lflag() {
  struct termios raw;
  tcgetattr( STDIN_FILENO, &raw );
  return (BBINT)raw.c_lflag;
}

void set_lflag( BBINT value ) {
  struct termios raw;
  tcgetattr( STDIN_FILENO, &raw );
  raw.c_lflag = value;
  tcsetattr( STDIN_FILENO, TCSAFLUSH, &raw );
}

// INPUT FLAGS

BBINT get_iflag() {
  struct termios raw;
  tcgetattr( STDIN_FILENO, &raw );
  return (BBINT)raw.c_iflag;
}

void set_iflag( BBINT value ) {
  struct termios raw;
  tcgetattr( STDIN_FILENO, &raw );
  raw.c_iflag = value;
  tcsetattr( STDIN_FILENO, TCSAFLUSH, &raw );
}

// OUTPUT FLAGS

BBINT get_oflag() {
  struct termios raw;
  tcgetattr( STDIN_FILENO, &raw );
  return (BBINT)raw.c_oflag;
}

void set_oflag( BBINT value ) {
  struct termios raw;
  tcgetattr( STDIN_FILENO, &raw );
  raw.c_oflag = value;
  tcsetattr( STDIN_FILENO, TCSAFLUSH, &raw );
}

// CONTROL FLAGS

BBINT get_cflag() {
  struct termios raw;
  tcgetattr( STDIN_FILENO, &raw );
  return (BBINT)raw.c_cflag;
}

void set_cflag( BBINT value ) {
  struct termios raw;
  tcgetattr( STDIN_FILENO, &raw );
  raw.c_cflag = value;
  tcsetattr( STDIN_FILENO, TCSAFLUSH, &raw );
}
*/

/* Read a single byte from StdIN
*/
BBINT StdInRead() {
  char c = '\0';
  read( STDIN_FILENO, &c, 1 );
  //while (read(STDIN_FILENO, &c, 1) == 1);
  return c;
}

/* Write string to StdOUT
*/
void StdOutWrite( char *text, int size ) {
	//write( STDOUT_FILENO, "\x1b[2J", 4 );
	write( STDOUT_FILENO, text, size );
}

/* Restore Terminal to original structure
*/
BBINT disableRawMode() {
  return tcsetattr( STDIN_FILENO, TCSAFLUSH, &original );
}

/* Save Terminal settings, then modify as follows:

LOCAL FLAGS
	ECHO		Echo characters to terminal
	ICANON		Canonical mode (Press enter to submit)
	IEXTEN		Disable Ctrl-V (Ctrl-O on MAC)
	ISIG		SIGINT (Ctrl-C) and SIGTSTP (Ctrl-Z or Ctrl-Y on MAC)
INPUT FLAGS
	BRKINT		Break
	ICRNL		Carriage Return and Newline Translation of Ctrl-M
	INPCK		Parity Checking
	ISTRIP		Strip bit 8
	IXON		XON/XOFF Software flow control Ctrl-S and Ctrl-Q
OUTPUT FLAGS
	OPOST		Carriage Return and Newline Translation of \n
CONTROL FLAGS
	CS8			Character size 8 bit
	
*/
BBINT enableRawMode() {
  // Get flags
  if ( tcgetattr( STDIN_FILENO, &original) == -1 ) return -2;
  // Set auto-recover flags on exit
  //atexit( disableRawMode );
  // Take copy of original flags
  struct termios raw = original;
  // Update flags
  raw.c_cflag |= ( CS8 );
  raw.c_iflag &= ~( BRKINT | ICRNL | INPCK | ISTRIP | IXON );
  raw.c_oflag &= ~( OPOST );
  raw.c_lflag &= ~( ECHO | ICANON | IEXTEN | ISIG );
  // Set read timeout
  raw.c_cc[VMIN] = 0;
  raw.c_cc[VTIME] = 1;
  // Set flags
  return tcsetattr( STDIN_FILENO, TCSAFLUSH, &raw );
}

/* Get the window size using IOCTL
*/
BBINT getWindowSize( BBINT *rows, BBINT *cols) {
  struct winsize ws;
  if ( ioctl( STDOUT_FILENO, TIOCGWINSZ, &ws ) == -1 || ws.ws_col == 0 ) {
    return -1;
  } else {
    *cols = ws.ws_col;
    *rows = ws.ws_row;
    return 0;
  }
}
