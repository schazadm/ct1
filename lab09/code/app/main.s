;* ------------------------------------------------------------------
;* --  _____       ______  _____                                    -
;* -- |_   _|     |  ____|/ ____|                                   -
;* --   | |  _ __ | |__  | (___    Institute of Embedded Systems    -
;* --   | | | '_ \|  __|  \___ \   Zurich University of             -
;* --  _| |_| | | | |____ ____) |  Applied Sciences                 -
;* -- |_____|_| |_|______|_____/   8401 Winterthur, Switzerland     -
;* ------------------------------------------------------------------
;* --
;* -- Project     : CT1 - Lab 9
;* -- Description : Multiplication and division
;* -- 
;* -- $Id: main.s 3775 2016-11-14 08:13:44Z kesr $
;* ------------------------------------------------------------------

ADDR_BUTTONS    EQU     0x60000210
ADDR_LCD_ASCII  EQU  	0x60000300
ADDR_7SEG       EQU     0x60000110
ADDR_LED        EQU     0x60000100

MSG_FAIL        EQU     0x8e88f9c7  ; 7 segment low-active bits of "FAIL"
MSG_PASS        EQU     0x8c889292  ; 7 segment low-active bits of "PASS"
MSG_CLEAR       EQU     0x7f7f7f7f  ; 7 segment low-active bits of dots only

; -------------------------------------------------------------------
; -- Constants
; -------------------------------------------------------------------
    
                AREA myCode, CODE, READONLY
                    
                THUMB
    
; -------------------------------------------------------------------
; -- Main
; -------------------------------------------------------------------   
                        
main            PROC
                EXPORT main
				IMPORT mul_u16
                IMPORT mul_s16
                IMPORT mul_u32
					
                BL    outcome_clear   
wait_for_button LDR   R0, =ADDR_BUTTONS         ; Read buttons
                LDRB  R1, [R0]
                LDR   R0, =mul_u16
                LSRS  R1, #1                    ; Test for T0
                BCS   load_proc                 ; and branch if pressed
                LDR   R0, =mul_s16
                LSRS  R1, #1                    ; Test for T1
                BCS   load_proc                 ; and branch if pressed
                LDR   R0, =mul_u32
                LSRS  R1, #1                    ; Test for T2
                BCC   next                      ; and branch if pressed
load_proc       BL    outcome_clear   
				BLX   R0
				BL    outcome
next            B     wait_for_button           ; Wait for next button
				
                ENDP

; -------------------------------------------------------------------
; -- tests_16x16
; R0 = operation (R0,R1) returning R0
; R1 = number of array elements
; R2 = array of {DCW arg1, DCW arg2, DCD expected_result} values
; R3 = actual results table
; returns R0 = error mask
; -------------------------------------------------------------------
tests_16x16     PROC
				EXPORT tests_16x16
                PUSH {R4-R7,LR}
				
				MOV  R8,R0  ; operation
				MOV  R9,R1  ; #tests
				MOV  R10,R2 ; values base
				MOV  R11,R3 ; results table

				; R0,R1 = operation arguments
				; R0    = return value
				; R2    = expected result
				; R3    = unused
				; R4    = table base address
				; R5    = table element offset
				; R6    = error mask
				; R7    = test index
				; R8    = number of tests

				MOVS R6,#0
				MOVS R7,#0
				B    check_end16

next_test16		; get operands and execute operation
				LSLS R5,R7,#3
				MOV  R4,R10
				ADDS R4,R5
				LDRH R0,[R4,#0] ; arg1
				LDRH R1,[R4,#2] ; arg2
				LDR  R4,[R4,#4] ; expected result
				BLX  R8
				MOV  R2,R4
				; store actual result
				LSLS R5,R7,#2
				MOV  R4,R11
				STR  R0,[R4,R5]
				; compare expected versus actual result and update error mask
				LSLS R6,#1
				CMP  R2,R0
				BEQ  passed16
				ADDS R6,#1
passed16		; next test
				ADDS R7,#1
check_end16		CMP  R7,R9
				BLO  next_test16
				
				; return error_mask
				MOVS R0,R6
                POP  {R4-R7,PC}
				ENDP

; -------------------------------------------------------------------
; -- tests_32x32
; R0 = operation (R0,R1) returning R0
; R1 = number of array elements
; R2 = array of {DCD arg1, DCD arg2, DCQ expected_result} values
; R3 = actual results table
; returns R0 = error mask
; -------------------------------------------------------------------
tests_32x32     PROC
				EXPORT tests_32x32
                PUSH {R4-R7,LR}
				
				MOV  R8,R0  ; operation
				MOV  R9,R1  ; #tests
				MOV  R10,R2 ; values base
				MOV  R11,R3 ; results table

				; R0,R1 = operation arguments
				; R1:R0 = return value
				; R3:R2 = expected result
				; R4    = table base address
				; R5    = table element offset
				; R6    = error mask
				; R7    = test index
				; R8    = number of tests

				MOVS R6,#0
				MOVS R7,#0
				B    check_end32

next_test32		; get operands and execute operation
				LSLS R5,R7,#4
				MOV  R4,R10
				ADDS R4,R5
				LDR  R0,[R4,#0]  ; arg1
				LDR  R1,[R4,#4]  ; arg2
				LDR  R5,[R4,#12] ; expected result R5:R4
				LDR  R4,[R4,#8]  ;
				BLX  R8
				MOV  R2,R4
				MOV  R3,R5
				; store actual result
				LSLS R5,R7,#3
				MOV  R4,R11
				ADDS R4,R5
				STR  R0,[R4,#0]
				STR  R1,[R4,#4]
				; compare expected versus actual result and update error mask
				LSLS R6,#1
				CMP  R2,R0
				BNE  failed32
				CMP  R3,R1
				BNE  failed32
				B    inc32
failed32        ADDS R6,#1
inc32			; next test
				ADDS R7,#1
check_end32		CMP  R7,R9
				BLO  next_test32
				
				; return error_mask
				MOVS R0,R6
                POP  {R4-R7,PC}
				ENDP

; -------------------------------------------------------------------
; -- void display_title(title)
; -------------------------------------------------------------------   
display_title   PROC
                EXPORT display_title
				PUSH {R5-R7,LR}
				LDR  R7,=ADDR_LCD_ASCII
				MOVS R6,#0  ; index to the title character
				B    check_eot
more_text		STRB R5,[R7,R6]
				ADDS R6,#1
check_eot		LDRB R5,[R0,R6]
				CMP  R5,#0
				BNE  more_text
				POP  {R5-R7,PC}
				ENDP

; -------------------------------------------------------------------
; -- void outcome_clear()
; -------------------------------------------------------------------   
outcome_clear   PROC
				PUSH {R0,R1,LR}
				
				MOVS R0,#0
				LDR  R1,=ADDR_LED
				STR  R0,[R1]

				LDR  R0,=MSG_CLEAR
				LDR  R1,=ADDR_7SEG
				STR  R0,[R1]
				
				POP  {R0,R1,PC}
				ENDP
; -------------------------------------------------------------------
; -- void outcome(uint32_t mask_of_failed_tests)
; -------------------------------------------------------------------   
outcome         PROC
				PUSH {R0,R1,LR}
				
				LDR  R1,=ADDR_LED
				STR  R0,[R1]
				
				CMP  R0,#0
				BNE  if_failed
				LDR  R0,=MSG_PASS
				B    endif_failed
if_failed		LDR  R0,=MSG_FAIL
endif_failed	LDR  R1,=ADDR_7SEG
				STR  R0,[R1]
				
				POP  {R0,R1,PC}
				ENDP

; -------------------------------------------------------------------
; -- End of file
; ------------------------------------------------------------------- 
				ALIGN
                END

