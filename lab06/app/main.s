;* ------------------------------------------------------------------
;* --  _____       ______  _____                                    -
;* -- |_   _|     |  ____|/ ____|                                   -
;* --   | |  _ __ | |__  | (___    Institute of Embedded Systems    -
;* --   | | | '_ \|  __|  \___ \   Zurich University of             -
;* --  _| |_| | | | |____ ____) |  Applied Sciences                 -
;* -- |_____|_| |_|______|_____/   8401 Winterthur, Switzerland     -
;* ------------------------------------------------------------------
;* --
;* -- Project     : CT1 - Lab 7
;* -- Description : Control structures
;* -- 
;* -- $Id: main.s 3748 2016-10-31 13:26:44Z kesr $
;* ------------------------------------------------------------------


; -------------------------------------------------------------------
; -- Constants
; -------------------------------------------------------------------
    
                AREA myCode, CODE, READONLY
                    
                THUMB

ADDR_LED_7_0            EQU     0x60000100
ADDR_LED_15_8           EQU     0x60000101
ADDR_LED_31_16          EQU     0x60000102
ADDR_7_SEG_BIN_DS1_0    EQU     0x60000114
ADDR_DIP_SWITCH_7_0     EQU     0x60000200
ADDR_DIP_SWITCH_15_8    EQU     0x60000201
ADDR_HEX_SWITCH         EQU     0x60000211
	
MASK_BIT_CLEAR			EQU		0xf0

NR_CASES        		EQU     0xB

jump_table      ; ordered table containing the labels of all cases
                ; STUDENTS: To be programmed 
				DCD case_0 ; darkmode
				DCD case_1 ; add
				DCD case_2 ; diff
				DCD case_3 ; mul
				DCD case_4 ; div / AND
				DCD case_5 ; OR
				DCD case_6 ; XOR
				DCD case_7 ; NOT
				DCD case_8 ; NAND
				DCD case_9 ; NOR
				DCD case_a ; XNOR
				DCD case_default ; lightmode
                ; END: To be programmed
    

; -------------------------------------------------------------------
; -- Main
; -------------------------------------------------------------------   
                        
main            PROC
                EXPORT main
                
read_dipsw      ; Read operands into R0 and R1 and display on LEDs
                ; STUDENTS: To be programmed
				; Operand A
				LDR R0, =ADDR_DIP_SWITCH_15_8
				; Get value from switches
				LDRB R0, [R0]
				; display
				MOV R2, R0
				LDR R3, =ADDR_LED_15_8
				STR R2, [R3]
				; ---------------------------------
				; Operand B
				LDR R1, =ADDR_DIP_SWITCH_7_0
				; Get value from switches
				LDRB R1, [R1]
				; display
				MOV R2, R1
				LDR R3, =ADDR_LED_7_0
				STR R2, [R3]
                ; END: To be programmed
                    
read_hexsw      ; Read operation into R2 and display on 7seg.
                ; STUDENTS: To be programmed
				LDR 	R7, =MASK_BIT_CLEAR ; 0xF0
				
				LDR 	R2, =ADDR_HEX_SWITCH
				LDRB 	R2, [R2]
				BICS 	R2, R2, R7 ; clear 4 bits
				
				LDR R3, =ADDR_7_SEG_BIN_DS1_0
				STR R2, [R3]

                ; END: To be programmed
                
case_switch     ; Implement switch statement as shown on lecture slide
                ; STUDENTS: To be programmed
				CMP R2, #NR_CASES
				BHS case_default
				LSLS R2, #2 ; * 4
				LDR R7, =jump_table
				LDR R7, [R7, R2]
				BX R7
                ; END: To be programmed


; Add the code for the individual cases below
; - operand 1 in R0
; - operand 2 in R1
; - result in R0

case_0       
                LDR  R0, =0
                B    display_result  

case_1        
                ADDS R0, R0, R1
                B    display_result
				

; STUDENTS: To be programmed

case_2

case_3

case_4

case_5

case_6

case_7

case_8

case_9

case_a

case_default


; END: To be programmed


display_result  ; Display result on LEDs
                ; STUDENTS: To be programmed
				LDR R3, =ADDR_LED_31_16
				STR R0, [R3]
                ; END: To be programmed

                B    read_dipsw
                
                ALIGN
                ENDP

; -------------------------------------------------------------------
; -- End of file
; -------------------------------------------------------------------                      
                END

