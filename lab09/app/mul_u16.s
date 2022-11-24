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
;* -- Description : Multiplication 16 bit unsigned
;* -- 
;* -- $Id: $
;* ------------------------------------------------------------------


NR_OF_TESTS     EQU     8
    
; -------------------------------------------------------------------
; -- Code
; -------------------------------------------------------------------
                AREA myCode, CODE, READONLY
                THUMB

mul_u16         PROC
                EXPORT mul_u16
                IMPORT display_title
				IMPORT tests_16x16

                PUSH {R1-R3,LR}

				LDR  R0,=title
				BL   display_title

				LDR  R3,=result_table
				LDR  R2,=values
				LDR  R1,=NR_OF_TESTS
				LDR  R0,=operation
				BL   tests_16x16

				POP  {R1-R3,PC}
				ENDP
                    
; -------------------------------------------------------------------
; 16 bit multiplication
; - multiplier in R0
; - multiplicand in R1
; - 32 bit result in R0
; -------------------------------------------------------------------
operation       PROC

				PUSH {R4-R7,LR}
				; Instruction: do not use high registers in your code, 
				; or make sure they contain thier original values
				; when the function returns

                ; STUDENTS: To be programmed                        
				
				MOVS 	R4, R0 		; copy multiplier
				MOVS 	R0, #0x0	; prepare return value
loop
				CMP		R4, #0x0	; R4 - 0
				BEQ 	return		; R4 > 0
				MOVS	R5, #0x1	; prepare mask for LSB
				ANDS	R5, R4, R5	; get LSB
				CMP		R5, #0x0	; R5 - 0
				BEQ		jmp			; R5 > 0
				ADDS	R0, R1
jmp
				LSLS	R1, #0x1
				LSRS	R4, #0x1
				B		loop
return
                ; END: To be programmed

                POP  {R4-R7,PC}	; return R0
                ENDP
					
				ALIGN

; -------------------------------------------------------------------
; -- Constants
; -------------------------------------------------------------------
                AREA myConstants, DATA, READONLY

values          DCW         0x0001
				DCW         0xffff
				DCD     0x0000ffff
					
				DCW         0x0017
				DCW         0x004a
				DCD     0x000006a6
					
				DCW         0xffff
				DCW         0xffff
				DCD     0xfffe0001
					
				DCW         0x73a4
				DCW         0x4c28
				DCD     0x2266c1a0
					
				DCW         0x43cc
				DCW         0xc3bf
				DCD     0x33d6f934
					
				DCW         0xe372
				DCW         0x0234
				DCD     0x01f51728
					
				DCW         0xdd22
				DCW         0xbcde
				DCD     0xa324bb7c
					
				DCW         0x7fff
				DCW         0x7fff
				DCD     0x3fff0001

title           DCB "mul_u16", 0

				ALIGN

; -------------------------------------------------------------------
; -- Variables
; -------------------------------------------------------------------
                AREA myVars, DATA, READWRITE
                    
result_table    SPACE   NR_OF_TESTS*4
	
				ALIGN

; -------------------------------------------------------------------
; -- End of file
; -------------------------------------------------------------------                      
                END
