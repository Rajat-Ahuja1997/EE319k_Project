; Print.s
; Student names: change this to your names or look very silly
; Last modification date: change this to the last modification date or look very silly
; Runs on LM4F120 or TM4C123
; EE319K lab 7 device driver for any LCD
;
; As part of Lab 7, students need to implement these LCD_OutDec and LCD_OutFix
; This driver assumes two low-level LCD functions
; ST7735_OutChar   outputs a single 8-bit ASCII character
; ST7735_OutString outputs a null-terminated string 

    IMPORT   ST7735_OutChar
    IMPORT   ST7735_OutString
    EXPORT   LCD_OutDec
    EXPORT   LCD_OutFix

    AREA    |.text|, CODE, READONLY, ALIGN=2
    THUMB

  

;-----------------------LCD_OutDec-----------------------
; Output a 32-bit number in unsigned decimal format
; Input: R0 (call by value) 32-bit unsigned number
; Output: none
; Invariables: This function must not permanently modify registers R4 to R11
LCD_OutDec
Num EQU 0	
; allocation
	PUSH{R0,R4,R5,LR}
; initialization
	LDR R3,=1000000000
	MOV R4,#10
; access
loop
	LDR R1,[SP,#Num]	; 4294967295 ... 34 ... 7 ... 0	
	UDIV R2,R1,R3 	; 4294967295/1000000000=4 ... 34/1000000000=0,34/10=3 ... 7/1000000000=0,7/1=7... 0/1000000000=0	
	CMP R2,#0
	BNE OutDigit
	UDIV R3,R3,R4
	CMP R3,#0
	BNE loop

LastDigit
	MOV R0,R2
	ADD R0,#0x30
	BL ST7735_OutChar
	B finish
	
OutDigit
	MOV R0,R2
	ADD R0,#0x30
	
	PUSH{R0-R5}
	BL ST7735_OutChar
	POP{R0-R5}
; next digit
	MUL R2,R2,R3	; 4*1000000000=4000000000 ... 3*10=30 ... 7*1=7
	SUB	R2,R1,R2	; 4294967295-4000000000=294967295 ... 34-30=4 ... 7-7=0
	STR R2,[SP,#Num]
	UDIV R3,R3,R4	; 1000000000/10=100000000 ... 10/10=1 ... 1/10=0
	CMP R3,#1
	BEQ LastDigit
	BLO finish
	LDR R1,[SP,#Num]	; 294967295 
	UDIV R2,R1,R3		; 294967295/100000000=2 
	B OutDigit
finish 
	POP{R0,R4,R5,LR}


      BX  LR
;* * * * * * * * End of LCD_OutDec * * * * * * * *

; -----------------------LCD _OutFix----------------------
; Output characters to LCD display in fixed-point format
; unsigned decimal, resolution 0.001, range 0.000 to 9.999
; Inputs:  R0 is an unsigned 32-bit number
; Outputs: none
; E.g., R0=0,    then output "0.000 "
;       R0=3,    then output "0.003 "
;       R0=89,   then output "0.089 "
;       R0=123,  then output "0.123 "
;       R0=9999, then output "9.999 "
;       R0>9999, then output "*.*** "
; Invariables: This function must not permanently modify registers R4 to R11
LCD_OutFix
; allocation
	PUSH{R0,R4,R5,LR}
; initialization
	LDR R3,=1000
	MOV R4,#10
	LDR R5,=9999
; access

	LDR R1,[SP,#Num]	; 4294967295 ... 34 ... 7 ... 0	
	CMP R1,R5		
	BHI Overflow	; > 9999
	UDIV R2,R1,R3 	; 9999/1000=9 ... 34/1000=0 ... 7/1000=0... 0/1000=0	
	MOV R0,R2
	ADD R0,#0x30
	PUSH{R0-R5}
	BL ST7735_OutChar	; first digit
	MOV R0,#0x2E		
	BL ST7735_OutChar	; .
	POP{R0-R5}
	
NextDigit
	MUL R2,R2,R3	;  9*1000=9000 ... 0*1000=0 
	SUB	R2,R1,R2	; 9999-9000=999 ... 34-0=34 ... 0-0=0
	STR R2,[SP,#Num]
	UDIV R3,R3,R4	; 1000/10=100 ... 10/10=1 ... 1/10=0
	CMP R3,#0
	BEQ finish2
	LDR R1,[SP,#Num]	; 999 ... 34 ... 0 
	UDIV R2,R1,R3		; 999/100=9 ... 34/100=0
	MOV R0,R2
	ADD R0,#0x30
	PUSH{R0-R5}
	BL ST7735_OutChar
	POP{R0-R5}	
	B NextDigit

Overflow 
	MOV R0, #0x2A		; *
	BL ST7735_OutChar
	MOV R0, #0x2E		; .
	BL ST7735_OutChar
	MOV R0, #0x2A
	BL ST7735_OutChar
	MOV R0, #0x2A
	BL ST7735_OutChar
	MOV R0, #0x2A
	BL ST7735_OutChar
finish2 
	POP{R0,R4,R5,LR}
	BX LR



     BX   LR
 
     ALIGN
;* * * * * * * * End of LCD_OutFix * * * * * * * *

     ALIGN                           ; make sure the end of this section is aligned
     END                             ; end of file
