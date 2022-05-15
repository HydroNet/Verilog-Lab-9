# Verilog-Lab-9
 Introduction
Liquid Crystal Displays (LCDs) provide an effective way for processors to
communicate with the outside world. The LPC2148 board used in the lab is equipped with
a 2 ൈ 16 character LCD. In this lab, you will develop assembly programs to write a
message string to the LCD module on the Education Board. The objectives include:
 to learn programming LCDs
 to practice on writing and calling subroutines
 to earn more familiarity of programming GPIOs
2 Lab Preparation
Please prepare the lab (e.g., read this section, write the needed subroutines,
assemble them to eliminate any syntax error) before you come to the laboratory. If
possible, you may run your code with RealView Microcontroller Development Kit (RMDK)
simulator.  This will help you to complete the required task on time.  
Table 1. Pin assignment of LCD module.  
Pin
number Symbol I/O Function
1 GND ‐ Power supply (GND)
2 VCC ‐ Power supply (+5V)
3 VLCD ‐ Contrast adjust
4 RS Input 0 = Command input; 1 = Data input
5 R/W Input 0 = Write to LCD; 1 = Read from LCD  
6 E Input Enable signal  
7 D0 Input/Output Data bus line 0 (LSB)
8 D1 Input/Output Data bus line 1
9 D2 Input/Output Data bus line 2
10 D3 Input/Output Data bus line 3
11 D4 Input/Output Data bus line 4
12 D5 Input/Output Data bus line 5
13 D6 Input/Output Data bus line 6
14 D7 Input/Output Data bus line 7 (MSB)
2.1 LCD PIN ASSIGNMENT AND PIN CONFIGURATION
The LCD residing on the board comes with a standard KS0070B or equivalent
controller, which is a very well‐known interface for smaller character based LCDs. Users
California State University, Northridge ECE425L
ECE Department By: Xiaojun Geng
2 
may select to use a 4‐bit or an 8‐bit interface. If an 8‐bit data interface is chosen, 11 pins
are needed: 8 data bits (D0 – D7), 1 address bit (RS), and 1 read/write bit (R/W), and one
control signal (E). Table 1 shows the pin assignment for such LCD‐modules as an industrial
standard.
Figure 1 illustrates the LCD part of the design on the Education Board and shows
which pins are used for the interface. All pins can be disconnected from the interface if
needed, via jumpers J31 – J42. The LCD is powered from the ൅3.3ܸ power supply. The
display contrast adjustment (VLCD) via ܴ86 is not mounted, therefore, no adjustment is
needed for programmers. A LED (LED_C) is connected to the port pin P0.30 to provide the
backlight to the LCD if needed.  
Figure 1. LPC 2148 Education Board Schematic: LCD.  
According to Figure 1, the following port pins are used in the LCD interface and need
to be configured as GPIO pins:  
(1) Port 0 pins: P0.22 and P0.30
(2) Port 1 pins: P1.16 – P1.25
To configure Port 0 pins as GPIO pins, we use the following two control registers:  
(1) Pin Function Select register 0 (PINSEL0 , read/write through address 0xE002 C000)
(2) Pin Function Select register 1 (PINSEL1 , read/write through address 0xE002 C004)
California State University, Northridge ECE425L
ECE Department By: Xiaojun Geng
3 
The PINSEL0 register controls the functions of the lower 16 pins P0.15 – P0.0; To
configure P0.݊ as a GPIO pin, we write 00 to bit locations [2݊ ൅ 1 ∶ 		2݊] of PINSEL0,
where ݊ ൌ 0, 1, … , 15.  For example, to set P0.15 as a GPIO pin, we can write
LDR   r1, =PINSEL0
LDR   r0, [r1]     ;read the current contents of PINSEL0
BIC    r0, r0, #0xC000 0000 ;modify the contents by clearing bits [31:30]   
STR   r0, [r1]     ;write the value back to PINSEL0
The PINSEL1 register controls the functions of the upper 16 pins P0.31 – P0.16; To
configure P0.݊ as a GPIO pin, we write 00 to bit locations [2݉ ൅ 1 ∶ 		2݉] of PINSEL0,
where ݊ ൌ 16, 17, … , 31 and ݉ ൌ ݊ െ 16.   
To configure Port 1 pins as GPIO pins, we use the control register PINSEL2, with
assigned address 0xE002 C014. For the LCD interface, pins P1.25 – P1.16 are used as GPIO
pins; bit 3 of PINSEL2 needs to be cleared for this pin configuration.  WARNING  : Must
use read‐modify‐write operation when accessing PINSEL2 register. Accidental write of 0
to other bits may cause an incorrect code execution!
After programming the pins for GPIO function, we need to configure the signal direction
of each pin. For this lab experiment, set each of these pins as output pins. The control
registers used to set up data direction of port 0 and port 1 are:  
Port 0:   IO0DIR ‐‐ 0xE002 8008
Port 1:   IO1DIR ‐‐ 0xE002 8018
Along with the data direction registers, you may need to configure the following registers:  
Port 0:   IO0SET ‐ 0xE002 8004
IO0CLR ‐ 0xE002 800C  
Port 1:   IO1SET ‐ 0xE002 8014
IO1CLR ‐ 0xE002 801C
Write Assembly code to do the above configurations and group the code as a subroutine.
You may name the subroutine as LCD_pins, or something similar.
Programming Tips: Define the bit locations of port pins as meaningful names to
increase readability as well as simplicity for programming and debugging. An example is
shown below.  
LCD_DATA EQU 0x00FF0000   ; P1.16 ‐ P1.23
LCD_RS    EQU 0x01000000   ; p1.24
LCD_E    EQU 0x02000000    ; p1.25
LCD_RW    EQU 0x00400000    ; P0.22
LCD_LIGHT EQU 0x40000000   ; P0.30
California State University, Northridge ECE425L
ECE Department By: Xiaojun Geng
4 
2.1 LCD CONTROL LINES  
The LCD standard requires 3 control lines as well as either 4 or 8 I/O lines for the data
bus. The user may select whether the LCD is to operate with a 4‐bit data bus or an 8‐bit
data bus. The three control lines are referred to as E, RS, and R/W.  
The E line is called "Enable". This control line is used to tell the LCD that you are
sending it data, where the data here could be a character for display or a LCD command.
To send data to the LCD, your program should first set this line high (1) and then set the
other two control lines and put data on the data bus. When the other lines are
completely ready, bring EN low (0) again. The 1‐0 transition tells the LCD processor to
take the data currently found on the data bus.  
The RS line is the "Register Select" line. There are two registers available for the LCD
processor: text register and command register. When RS is low (0), the data are to be
treated as a command or special instruction (such as clear screen, position cursor, etc.).
When RS is high (1), the data being sent are text which should be displayed on the screen.
For example, to display the letter "T" on the screen you would set RS high.  
The R/W line is the "Read/Write" control line. When RW is low (0), the information
on the data bus is being written to the LCD. When RW is high (1), the program is
effectively querying (or reading) the LCD. Only one instruction ("Get LCD status") is a read
command. All others are write commands – so R/W will almost always be low. For this
lab, we will write to the LCD only.  
Finally, the data bus consists of 4 or 8 lines (depending on the mode of operation
selected by the user). In this lab, we are using 8‐bit data bus; the lines are referred to as
D0 (LSB), D1, D2, D3, D4, D5, D6, and D7 (MSB).  
Based on the above introduction, write the following two subroutines to send a
command and a character to LCD, respectively. You may name the subroutines LCD_cmd
and LCD_char.   
(A) Write a subroutine which sends a command to LCD, by following the steps below:
(1) D[7:0] = command (passed from the calling program).
(2) RS = 0, R/W = 0, and E = 0 ; and wait for at least 6µݏ.
(3) E = 1 ; and wait for at least 6µݏ.
(4) E = 0; and wait for at least 40µݏ.
(B) Write a subroutine which sends a character to LCD, by following the steps below:
(1) D[7:0] = character (passed from the calling program).
(2) RS = 1, R/W = 0, and E = 0; and wait for at least 6µݏ.
(3) E = 1 ; and wait for at least 6µݏ.
(4) E = 0; and wait for at least 40µݏ.
California State University, Northridge ECE425L
ECE Department By: Xiaojun Geng
5 
Programming Tip: Note that all the delays are minimum time required for the
operations. You may insert longer delays. Therefore, you may call a short delay
subroutine which takes an argument to generate multiples of 1µݏ or 10µݏ delay.
2.2 LCD INITIALIZATION  
Before you may really use the LCD, you must initialize and configure it. This is
accomplished by sending a number of initialization commands to the LCD.  
The first instruction that we send is a LCD command 0x30, which wakes up the LCD
module. This command needs to be sent three times to the LCD with proper delays in
between.  
After waking up the LCD module, we send the next command 0x38 for function
select. This command is really the sum of three option bits: 0x20, 0x10, and 0x80. The
instruction itself is 0x20 for “Function set”. The value 0x10 indicates an 8‐bit data bus,
and 0x80 selects a two‐line display. We also select a 5x7 dot character font with this
command. The details about this command can be found in the  
Appendix: LCD Instruction Set
The third byte of the initialization sequence is the command 0x0C. The command
0x0C is really the instruction 0x08 (“Display On/Off control”) plus 0x04 to turn the LCD on.  
The next byte we need to send is 0x01. The instruction (“Clear display”) is to
configure LCD to clear screen and make cursor home.  
The last byte we need to send is used to configure additional operational parameters
of the LCD. We must send the value 0x06. The command 0x06 is really the instruction
0x04 (“Entry mode set”) plus 0x02 to configure the LCD such that every time we send it a
character, the cursor position automatically moves to the right.  
Having executed this code the LCD will be fully initialized and ready for us to send
display data to it. Proper waiting periods need to be inserted after a command is sent out.
Sending a command to the LCD can be implemented by calling the subroutine suggested
in the end of Section 2.1. The initialization procedure for 8 bit interface is summarized
below, for which the code can be written as a subroutine LCD_init:
(1) E = RS = RW = 0, and wait for at least 15ms.
(2) Send command 0x30 to the pins D[7:0] of the LCD, and wait for at least 4.1ms.
(3) Send command 0x30 and wait for at least 100µs.
(4) Send command 0x30 and wait for at least 4.1ms.
(5) Send command 0x38 to the LCD.
(6) Send command 0x0C to the LCD.
(7) Send command 0x01 to the LCD.
California State University, Northridge ECE425L
ECE Department By: Xiaojun Geng
6 
(8) Send command 0x06 to the LCD.
2.3 CURSOR POSITIONING
The LCD module contains a certain amount of memory which is assigned to the
display. All the text we write to the LCD module is stored in this memory, and the LCD
module subsequently reads this memory to display the text on the LCD itself. This
memory can be represented with the "memory map" in Figure 2.
Figure 2. 2x16 LCD memory map.
In this memory map, the area shaded in blue is the visible display. As you can see, it
measures 16 characters per line by 2 lines. The numbers in each box is the memory
address that corresponds to that screen position.  
Thus, the first character in the upper left‐hand corner is at address 0x00. The
following character position (character #2 on the first line) is address 0x01, etc. This
continues until we reach the 16th character of the first line which is at address 0x0F.  
However, the first character of line 2, as shown in the memory map, is at address
0x40. This means if we write a character to the last position of the first line and then write
a second character, the second character will NOT appear on the second line. That is
because the second character will effectively be written to address 0x10 ‐‐ but the second
line begins at address 0x40.  
Thus we need to send a command to the LCD that tells it to position the cursor on
the second line. The "Set Cursor Position" instruction is 0x80. To place the cursor at a
certain location, we must add the address of the location to the command 0x80. For
example, if we want to display a letter on the first character position of the first line, we
need to send command 0x80 (i.e., 0x80 + 0x00) to the LCD. To place cursor at the first
character position of the second line, we send command 0xC0. To place cursor at the
second character position of the second line, we send command 0xC1, and so on.  
Write a subroutine which displays a character string starting from a certain location
on the LCD. There should be two arguments for this subroutine: the character to display
and the location to display. This subroutine should follow the sequence below:
(1) Send LCD command to place the cursor for the first character. (Note that the
cursor moves right by one location automatically.)
(2) Call the subroutine LCD_char to send one character.
(3) Repeat (2) until a null character is fetched.
California State University, Northridge ECE425L
ECE Department By: Xiaojun Geng
7 
3 Lab Tasks
For the tasks below, complete the following requirements:
 Create at least 3 subroutines in ARM assembly listed in the task 1 BEFORE coming
to the lab.
 Simulate your code and verify the result with the debugger to make sure that the
program sends the correct data to the control registers and port pins.
 Download the machine code in HEX file to the LPC2148 microcontroller, and verity
the result after execution.
 Demonstrate the results to the lab instructor before you leave the lab.
Task 1:    Write the following subroutines for LCD display and group them in one program
file named as lcd_subs.s:   
 Wait_10µs or Wait_1µs which can produce multiples of 10µs (or 1µs) time delay.
 LCD_pins which configures all port pins of the LPC2148 for LCD interface
 LCD_init which follows the initialization sequence to wake up LCD and configure
its functions
 LCD_cmd which sends a command to the LCD
 LCD_char which sends a character to the LCD
 LCD_string which display a string starting from a certain location on the LCD.
 LCD_clear which clears the display and set cursor home.
Task 2:   Write a program code to display two character strings on the first and second
line of the LCD, respectively, by calling the subroutines written in lcd_subs.s. Note that
the strings to display need to be stored in the memory.  
Task 3:   Generate a rotating display on the first line of the LCD; more specifically,
continually rotate a character string from right to left, and the first character will appear
from the right again and continue rotating from right to left.  
Hint: Read the details about the instruction “Cursor/display shift” listed in the  
Appendix: LCD Instruction Set
and the file about LCD commands.  
4 Requirements:
A. This is a two‐week lab experiment. Pre‐lab work will be checked in the beginning
of the first week. It is very important to complete your pre‐lab, which is the
completion of 3 subroutines.
B. Lab report is DUE one week after the two‐week lab period. The report should
include your names, experiment objectives, experiment problems, the print‐out of
your work, explanation and discussion, and conclusion.
C. Demonstrate your results to the instructor before you leave. Failure to do so will
result in zero point for performance.
California State University, Northridge ECE425L
ECE Department By: Xiaojun Geng
8 
Appendix: LCD Instruction Set
LCD instruction set
Instruction
Code
Description
Execution
RS R/W D7 D6 D5 D4 D3 D2 D1 D0 time**
Clear display 0 0 0 0 0 0 0 0 0 1 Clears display and returns cursor to
the home position (address 0). 1.64mS
Cursor home 0 0 0 0 0 0 0 0 1 *
Returns cursor to home position
(address 0). Also returns display being
shifted to the original position.
DDRAM contents remains unchanged.
1.64mS
Entry mode
set
0 0 0 0 0 0 0 1 I/D S
Sets cursor move direction (I/D),
specifies to shift the display (S). These
operations are performed during data
read/write.
40µS
Display On/Off
control 0 0 0 0 0 0 1 D C B
Sets On/Off of all display (D), cursor
On/Off (C) and blink of cursor position
character (B).
40µS
Cursor/display
shift 0 0 0 0 0 1 S/C R/L * *
Sets cursor‐move or display‐shift
(S/C), shift direction (R/L). DDRAM
contents remains unchanged.
40µS
Function set 0 0 0 0 1 DL N F * *
Sets interface data length (DL),
number of display line (N) and
character font(F).
40µS
Set CGRAM
address 0 0 0 1 CGRAM address
Sets the CGRAM address. CGRAM
data is sent or received after this
setting.
40µS
Set DDRAM
address 0 0 1 DDRAM address
Sets the DDRAM address. DDRAM
data is sent or received after this
setting.
40µS
Read busy‐flag
and address
counter
0 1 BF DDRAM address
Reads Busy‐flag (BF) indicating
internal operation is being performed
and reads address counter contents.
0µS
Write to
CGRAM or
DDRAM
1 0 write data Writes data to CGRAM or DDRAM. 40µS
Read from
CGRAM or
DDRAM
1 1 read data Reads data from CGRAM or DDRAM. 40µS
Notes:  
 DDRAM = Display Data RAM.
 CGRAM = Character Generator RAM.
 DDRAM address corresponds to cursor position.
California State University, Northridge ECE425L
ECE Department By: Xiaojun Geng
9 
 Address Counter is used for both DDRAM and CGRAM.
 * = Don't care.
 ** = Based on Fosc = 250KHz.
Bit names
Bit Settings
I/D 0 = Decrement cursor position 1 = Increment cursor position
S 0 = No display shift 1 = Display shift
D 0 = Display off 1 = Display on
C 0 = Cursor off 1 = Cursor on
B 0 = Cursor blink off 1 = Cursor blink on
S/C 0 = Move cursor 1 = Shift display
R/L 0 = Shift left 1 = Shift right
DL 0 = 4‐bit interface 1 = 8‐bit interface
N 0 = 1/8 or 1/11 Duty (1 line) 1 = 1/16 Duty (2 lines)
F 0 = 5x7 dots 1 = 5x10 dots
BF 0 = Can accept instruction 1 = Internal operation in progress
1
 LCD Commands 
LCD instruction set
Instruction
Code
Description
Execution
time** RS R/W D7 D6 D5 D4 D3 D2 D1 D0
Clear display 0 0 0 0 0 0 0 0 0 1 Clears display and returns cursor to the
home position (address 0).
1.64mS
Cursor home 0 0 0 0 0 0 0 0 1 * Returns cursor to home position (address
0). Also returns display being shifted to
1.64mS
Entry mode
set
0 0 0 0 0 0 0 1 I/D S Sets cursor move direction (I/D), specifies
to shift the display (S). These operations
40µS
Display On/Off
control
0 0 0 0 0 0 1 D C B Sets On/Off of all display (D), cursor
On/Off (C) and blink of cursor position
40µS
Cursor/display
shift
0 0 0 0 0 1 S/C R/L * * Sets cursor‐move or display‐shift (S/C),
shift direction (R/L). DDRAM contents
40µS
Function set 0 0 0 0 1 DL N F * * Sets interface data length (DL), number of
display line (N) and character font(F).
40µS
Set CGRAM
address
0 0 0 1 CGRAM address Sets the CGRAM address. CGRAM data is
sent or received after this setting.
40µS
Set DDRAM
address
0 0 1 DDRAM address Sets the DDRAM address. DDRAM data is
sent or received after this setting.
40µS
Read busy‐flag
and address
0 1 BF DDRAM address Reads Busy‐flag (BF) indicating internal
operation is being performed and reads
0µS
Write to
CGRAM or
DDRAM
1 0 write data Writes data to CGRAM or DDRAM. 40µS
Read from
CGRAM or
DDRAM
1 1 read data Reads data from CGRAM or DDRAM. 40µS
Notes: 
 DDRAM = Display Data RAM.
 CGRAM = Character Generator RAM.
 DDRAM address corresponds to cursor position.
 Address Counter is used for both DDRAM and CGRAM.
 * = Don't care.
 ** = Based on Fosc = 250KHz.
2
Bit names
Bit Settings
I/D 0 = Decrement cursor position 1 = Increment cursor position
S 0 = No display shift 1 = Display shift
D 0 = Display off 1 = Display on
C 0 = Cursor off 1 = Cursor on
B 0 = Cursor blink off 1 = Cursor blink on
S/C 0 = Move cursor 1 = Shift display
R/L 0 = Shift left 1 = Shift right
DL 0 = 4‐bit interface 1 = 8‐bit interface
N 0 = 1/8 or 1/11 Duty (1 line) 1 = 1/16 Duty (2 lines)
F 0 = 5x7 dots 1 = 5x10 dots
BF 0 = Can accept instruction 1 = Internal operation in progress
Clear Display 
RS R/W DB7 DB6 DB5 DB4 DB3 DB2 DB1 DB0 
=== === === === === === === === === === 
 0 0 0 0 0 0 0 0 0 1 
Clears all display and returns the cursor to the home position (Address 0).  
Details 
Writes space code (20h) into all DD RAM addresses. Sets address counter to DD RAM location 0. Returns display 
to its original state if it was shifted. In other words, the display disappears and the cursor or blink goes to the left 
edge of the display (the first line if 2 lines are displayed). Sets entry mode I/D to 1 (Increment Mode). Entry mode 
shift (S) bit remains unchanged. 
Execution Time = 82µs‐1.64ms / 120µs‐4.9ms  
Cursor Home 
RS R/W DB7 DB6 DB5 DB4 DB3 DB2 DB1 DB0 
 0 0 0 0 0 0 0 0 1 * 
Returns the cursor to the home position (Address 0). Returns display to its original state if it was shifted.  
Details 
Sets the address counter to DD RAM location 0 in the address counter. Returns display to its original state if it was 
3
shifted. DD RAM contents remain unchanged. The cursor or blink goes to the left edge of the display (the first line 
if 2 lines are displayed). 
Execution Time = 40µs‐1.6ms / 120µs‐4.8ms  
Entry Mode Set 
RS R/W DB7 DB6 DB5 DB4 DB3 DB2 DB1 DB0 
=== === === === === === === === === === 
 0 0 0 0 0 0 0 1 I/D S 
Sets the effect of subsequent DD RAM read or write operations. Sets the cursor move direction and specifies or not 
to shift the display. These operations are performed during data read and write. 
Details 
Specifies whether to increment (I/D = 1) or decrement (I/D = 0) the address counter after subsequent DD RAM read 
or write operations. 
If S = 1 the display will be shifted to the left (if I/D = 1) or right (if I/D = 0) on subsequent DD RAM write 
operations. This makes it looks as if the cursor stands still and the display moves when each character is written to 
the DD RAM. if S = 0 the display will not shift on subsequent DD RAM write operations. 
Execution Time = 40µs / 120µs  
Display ON/OFF 
RS R/W DB7 DB6 DB5 DB4 DB3 DB2 DB1 DB0 
=== === === === === === === === === === 
 0 0 0 0 0 0 1 D C B 
Controls display of characters and cursor. 
Details 
D: The display is ON when D = 1 and OFF when D = 0. The DD RAM contents remain unchanged. 
C: The cursor is displayed when C = 1 and is not displayed when C = 0. 
The cursor is displayed as 5 dots in the 8th line when the 5 x 7 dot character font is selected and as 5 dots in the 11th 
line when the 5 x 10 dot character font is selected. 
B: The character at the cursor position blinks when B = 1. 
Blinking is performed by switching between all blank dots and the display character every 409.6 ms. 
Execution Time = 40µs / 120µs  
Cursor and Display Shift 
RS R/W DB7 DB6 DB5 DB4 DB3 DB2 DB1 DB0 
=== === === === === === === === === === 
 0 0 0 0 0 1 S/C R/L * * 
4
Moves the cursor and shifts the display without changing DD RAM contents  
Details 
Shifts cursor position or display to the right or left without writing or reading display data. This function is used to 
correct or search for the display. In a 2-line display, the cursor moves to the 2nd line when it passes the 40th digit of 
the 1st line. Notice that the 1st and 2nd line displays will shift at the same time. When the displayed data is shifted 
repeatedly each line only moves horizontally. The 2nd line of the display does not shift into the 1st line position. 
S/C R/L
=== ===
 0 0 Shifts the cursor position to the left 
(Address Counter is decremented by 1) 
 0 1 Shifts the cursor position to the right 
(Address Counter is incremented by 1) 
 1 0 Shifts the entire display to the left 
The cursor follows the display shift 
 1 1 Shifts the entire display to the right 
The cursor follows the display shift 
Execution Time = 40µs / 120µs  
Function Set 
RS R/W DB7 DB6 DB5 DB4 DB3 DB2 DB1 DB0 
=== === === === === === === === === === 
 0 0 0 0 1 DL N F * * 
Sets interface data length (DL), number of display lines (N) and character font (F)  
Details 
This command should be issued only after automatic power-on initialization has occurred, or as part of the module 
initialization sequence. 
DL: Sets interface data length 
Data sent or received in 8 bit lengths (DB7‐DB0) when DL = 1  
Data sent or received in 4 bit lengths (DB7-DB4) when DL = 0 
When the 4 bit length is selected, data must be sent or received in pairs of 4-bits each. The most-significant 
4 bits are sent or received first. 
N: Sets number of display lines  
F: Sets character font 
 display Character Duty
N F lines Font Factor Remarks
=== ======= ========= ====== =======
0 0 1 5x 7 dots 1/8 -
0 1 1 5x10 dots 1/11 -
1 * 2 5x 7 dots 1/16 Cannot display 2 lines with 
5x10 dot character font 
5
Note that a 1 line x 16 character display is treated as a 2 line x 8 character display. The first `line' is the left eight 
character positions on the display and the second `line' is the right eight character positions. This also means that the 
16 characters on the display do not occupy 16 sequential DD RAM locations. 
Execution Time = 40µs / 120µs  
Set CG RAM Address 
RS R/W DB7 DB6 DB5 DB4 DB3 DB2 DB1 DB0 
=== === === === === === === === === === 
 0 0 0 1 A A A A A A 
Sets the CG RAM address. Subsequent read or write operations refer to the CG RAM. 
Details 
Sets the specified value (AAAAAA) into the address counter. Subsequent read or write operations transfer data from, 
or to, the character generator RAM. 
Execution Time = 40µs / 120µs  
Set DDRAM Address 
RS R/W DB7 DB6 DB5 DB4 DB3 DB2 DB1 DB0 
=== === === === === === === === === === 
 0 0 1 A A A A A A A 
Sets the DD RAM address. Subsequent read or writes refer to the DD RAM. 
Details 
Sets the specified value (AAAAAAA) into the address counter. Subsequent read or write operations transfer data 
from, or to, the display RAM. Note: Adjacent display RAM locations do not necessarily refer to adjacent display 
positions. 
Execution Time = 40µs / 120µs  
Read busy flag and address counter 
RS R/W DB7 DB6 DB5 DB4 DB3 DB2 DB1 DB0 
=== === === === === === === === === === 
 0 1 BF A A A A A A A 
Reads the state of the busy flag (BF) and the contents of the address counter. 
Details 
Reads the busy flag (BF) that indicates the state of the LCD module. BF = 1 indicates that the module is busy 
processing the previous command. BF = 0 indicates that the module is ready to perform another command. 
The value of the address counter is also returned. The same address counter is used for both CG and DD RAM 
transfers. 
6
This command can be issued at any time. It is the only command which the LCD module will accept while a 
previous command is still being processed. 
Execution Time = 1µs  
Write data to CG or DD RAM 
RS R/W DB7 DB6 DB5 DB4 DB3 DB2 DB1 DB0 
=== === === === === === === === === === 
 1 0 D D D D D D D D 
Writes data into DD RAM or CG RAM  
Details 
Writes a byte (DDDDDDDD) to the CG or the DD RAM. The destination (CG RAM or DD RAM) is determined by 
the most recent `Set RAM Address' command. The location to which the byte will be written is the current value of 
the address counter. After the byte is written the address counter is automatically incremented or decremented 
according to the entry mode. The entry mode also determines whether or not the display will shift. 
Execution Time = 40µs / 120µs  
Read data from CG or DD RAM 
RS R/W DB7 DB6 DB5 DB4 DB3 DB2 DB1 DB0 
=== === === === === === === === === === 
 1 1 D D D D D D D D 
Reads data from DD RAM or CG RAM.  
Details 
Reads a byte (DDDDDDDD) from the CG or DD RAM. The source (CG RAM or DD RAM) is determined by the 
most recent `Set RAM Address' command. The location from which the byte will be read is the current value of the 
address counter. After the byte is read the address counter is automatically incremented or decremented according to 
the entry mode. 
Execution Time = 40µs / 120µs
