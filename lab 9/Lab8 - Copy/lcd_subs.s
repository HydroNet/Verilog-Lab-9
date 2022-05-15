	GLOBAL	subrts
	GLOBAL	LCD_PINS
	GLOBAL 	LCD_CHAR
	GLOBAL 	LCD_CMD
	GLOBAL  DELAY
	GLOBAL 	LCD_INIT
	GLOBAL 	LCD_STRING
	GLOBAL 	LCD_CLEAR
		
	AREA mycode, CODE, readonly
subrts

DELAY

loop_cntr EQU 15 ;wait 6us
loop_cntr2 EQU 100;wait 40us
	
			STMDA sp!, {r0,r1,r2}
			
			LDR r0,=loop_cntr
			mov r1, #0
			mov r2, #0
	
DELAY_LOOP1 	ADD r1,r1,#1;loop 6us
			CMP r1,r0
			BNE DELAY_LOOP1
		
DELAY_LOOP2 LDR r0, =loop_cntr2
			CMP r2,r3
			ADD r2,r2,#1;loop 40us
			CMP r1,r0
			BNE DELAY_LOOP2
			
			LDMIB sp!, {r0,r1,r2}
			
			BX lr
LCD_PINS
;LCD_PINS: This subroutine sets the pin selectors as GPIO

PINSEL0	EQU 0XE002C000
PINSEL1	EQU 0XE002C004
PINSEL2	EQU 0XE002C014
IO0PIN	EQU 0XE0028000
IO0SET	EQU 0XE0028004
IO0DIR	EQU 0XE0028008
IO1DIR	EQU 0XE0028018
IO0CLR	EQU 0XE002800C 
	
		STMDA SP!,{R0,R1,R2} ;load R0,R1,R2 INTO THE STACK
		;LDR R0,=PINSEL0
		;LDR R1,[R0]
		;LDR R2,=0XFF00
		;BIC R1,R1,R2
		;STR R1,[R0]

		LDR R0,=PINSEL1
		LDR R1,[R0]
		LDR R2,=0X30003000
		
		;BITS 13,14,28,29 ARE 0S TO SET PINS P0.22 & P0.30 AS GPIO
		BIC R1, R1, R2 
		STR R1,[R0]
		
		;SET P0.22 & P0.30 AS OUTPUT DIRECTION
		LDR R0,=IO0DIR 
		LDR R1,[R0]
		LDR R2,=0X4040FF00 ;LOADS MASK FOR PINS 22 AND 30, PINS 8-15
		ORR R1, R1, R2 ;LOADS RESULT OF ORR WITH INTO R1 WHICH HOLDS DIR ADDRESS
		STR R1,[R0] ;SETS THE DIRECTION OF 22 AND 30 AS OUTPUTS
		
		LDR R0,=IO0PIN
		LDR R1,[R0]
		ORR R1,R1,R2
		STR R1,[R0]

		LDR R0,=PINSEL2 ;LOADS PINSEL2 ADDRESS INTO R0
		LDR R2,=0XFFFFFFF7 ;BIT 3 SET TO 0 TO CONFIGURE PINS P1.16-25 AS GPIO
		STR R2,[R0]
		LDR R0,=IO1DIR 
		LDR R1,[R0]

		LDR R2,=0X3FF0000 ;DIRECTION IS SET AS OUTPUT
		ORR R1, R1, R2
		STR R1,[R0]
		LDMIB SP!,{R0,R1,R2}
		BX LR
		
LCD_CMD 
;;-This subroutine sends a command to the LCD.

LCD_DATA	EQU 0X00FF0000 ;P1.16-23
LCD_RS		EQU 0X01000000 ;P1.24
LCD_E		EQU 0X02000000 ;P1.25
LCD_RW		EQU 0X00400000 ;P0.22
LCD_LIGHT	EQU 0X40000000 ;P0.30
IO1PIN		EQU 0XE0028010 ;ALLOWS US TO OUTPUT 0/1 ON PORT 1 PINS

			;SAVE R0,R1,R2,LR INTO THE STACK
			STMDA SP!,{R0-R4,LR}
			LDR R4,=LCD_DATA
			LDR R0,=IO1PIN
			LDR R2,[R0]
			BIC R2,R2,R4
			ORR R2,R6,R2;WHERE R6 CONTAINS THE LCD COMMAND FROM THE CALLING PROGRAM
			LDR R1,=LCD_E ;SET ENABLE TO 0
			BIC R2,R2,R1

			LDR R1,=LCD_RS ;SET RS TO 0
			BIC R2,R2,R1
			STR R2,[R0]

			LDR R0,=IO0PIN
			LDR R2,[R0]
			LDR R1,=LCD_RW ;SET RW TO 0
			BIC R2,R2,R1
			STR R2,[R0]

			BL DELAY_LOOP1 ;WAITING AT LEAST 6US

			LDR R0,=IO1PIN
			LDR R1,=LCD_E ;SET ENABLE TO 1
			LDR R2,[R0]
			ORR R2,R2,R1
			STR R2,[R0]
			
			BL DELAY_LOOP1 ;WAITING AT LEAST 6US

			LDR R0,=IO1PIN
			LDR R1,=LCD_E ;SET ENABLE TO 0
			LDR R2,[R0]
			BIC R2,R2,R1
			STR R2,[R0]
			
			MOV R3,#200
			BL DELAY_LOOP2 ;WAITING AT LEAST 40US

			;TURN ON LED 9
			LDR R0,=IO0PIN
			LDR R1,=0X200
			LDR R2,[R0]
			BIC R2,R2,R1
			STR R2,[R0]
			LDMIB SP!,{R0-R4,LR}
			BX LR

LCD_CHAR
			
			;SAVE R0,R1,R2,LR INTO THE STACK
			STMDA SP!,{R0-R4,LR}
			LDR R4,=LCD_DATA
			LDR R0,=IO1PIN
			LDR R2,[R0]
			BIC R2,R2,R4
			ORR R2,R6,R2;WHERE R6 CONTAINS THE LCD COMMAND FROM THE CALLING PROGRAM
			LDR R1,=LCD_E ;SET ENABLE TO 0
			BIC R2,R2,R1

			LDR R1,=LCD_RS ;SET RS TO 1
			AND R2,R2,R1
			STR R2,[R0]

			LDR R0,=IO0PIN
			LDR R2,[R0]
			LDR R1,=LCD_RW ;SET RW TO 0
			BIC R2,R2,R1
			STR R2,[R0]

			BL DELAY_LOOP1 ;WAITING AT LEAST 6US

			LDR R0,=IO1PIN
			LDR R1,=LCD_E ;SET ENABLE TO 1
			LDR R2,[R0]
			ORR R2,R2,R1
			STR R2,[R0]
			
			BL DELAY_LOOP1 ;WAITING AT LEAST 6US

			LDR R0,=IO1PIN
			LDR R1,=LCD_E ;SET ENABLE TO 0
			LDR R2,[R0]
			BIC R2,R2,R1
			STR R2,[R0]
			
			MOV R3,#200
			BL DELAY_LOOP2 ;WAITING AT LEAST 40US

			;TURN ON LED 9
			LDR R0,=IO0PIN
			LDR R1,=0X200
			LDR R2,[R0]
			BIC R2,R2,R1
			STR R2,[R0]
			LDMIB SP!,{R0-R4,LR}
			BX LR
			
LCD_INIT
			STMDA SP!,{R0,R1,R2,LR}
			LDR R0, =IO0PIN
			LDR R2,[R0]
			LDR R1,=LCD_E
			BIC R2,R2,R1
			LDR R1, =LCD_RS
			BIC R2,R2,R1
			STR R2,[R0]
			
			LDR R0, =IO0PIN
			LDR R1, =LCD_RW
			LDR R2,[R0]
			BIC R2,R2,R1
			STR R2,[R0]
			
			LDR R3,=100000
			BL DELAY_LOOP1
			
			MOV R6, #0X300000
			BL LCD_CMD
			LDR R0,=IO1PIN
			LDR R2,[R0]
			AND R2,R2,R8
			ORR R2,R2,R7
			STR R2,[R0]
			
			LDR R3,=10000
			BL DELAY_LOOP1
			
			MOV R6, #0X300000
			BL LCD_CMD
			LDR R0,=IO1PIN
			STR R2,[R0]
			
			LDR R3, =400
			BL DELAY_LOOP1
			
			mov r6,#0x300000
			bl LCD_CMD
			ldr r0,=IO1PIN
			str r2,[r0]
			ldr r3,=10000
			bl DELAY_LOOP2 ;DELAY for >4.1ms
			mov r6,#0x380000 ;function set(0x20),8-bit data bus(0x10),and two-line display(0x80) commands combined
			bl LCD_CMD
			ldr r8,=0xFF00FFFF
			ldr r0,=IO1PIN
			ldr r2,[r0]
			and r2,r2,r8
			orr r2,r2,r7
			str r2,[r0]
			ldr r3,=400
			bl DELAY_LOOP2 ;DELAY for >80us
			mov r6,#0x0C0000
			bl LCD_CMD
			mov r7,#0x0C0000 ;display on/off control and lcd on commands
			ldr r8,=0xFF00FFFF
			ldr r0,=IO1PIN
			ldr r2,[r0]
			and r2,r2,r8
			orr r2,r2,r7
			str r2,[r0]
			ldr r3,=400
			bl DELAY_LOOP2 ;DELAY for >80us
			mov r6,#0x010000 ;clears display
			bl LCD_CMD
			ldr r8,=0xFF00FFFF
			ldr r0,=IO1PIN
			ldr r2,[r0]
			and r2,r2,r8
			orr r2,r2,r7
			str r2,[r0]
			
			ldr r3,=40000
			bl DELAY_LOOP2 ;DELAY for >1.64ms
			mov r6,#0x060000 ;entry mode is set and lcd is configured
			bl LCD_CMD
			ldr r8,=0xFF00FFFF ;to automatically move the cursor position to the right
			ldr r0,=IO1PIN ;every time we send a character
			ldr r2,[r0]
			and r2,r2,r8
			orr r2,r2,r7
			str r2,[r0]
			;turn on LED on pin 8
			ldr r0,=IO0PIN
			ldr r1,=0x100
			ldr r2,[r0]
			bic r2,r2,r1
			str r2,[r0]
			;load saved registers from stack
			ldmib sp!,{r0,r1,r2,lr}
			bx lr
			
			LDMIB SP!,{R0,R1,R2,LR}
			
LCD_STRING
			STMDA SP!, {R7,LR}
			BL LCD_CMD
			
STRING_LOOP
			MOV R7,#0
			LDRB R7,[R8],#1
			CMP R7, #0
			BEQ EXIT_LOOP
			LSL R7, #16
			BL LCD_CHAR
			B STRING_LOOP
			
EXIT_LOOP	LDMIB SP!,{R7,LR}
			BX LR


LCD_CLEAR	
			STMDA SP!,{R6, LR}
			MOV R6, #0X010000;CLEAR DISPLAY
			BL LCD_CMD
			LDMIB SP!,{R6, LR}
			BX LR


stop b stop
	END
		
	