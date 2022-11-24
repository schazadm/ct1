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
;* -- Description : Multiplication 32 bit unsigned
;* -- 
;* -- $Id: $
;* ------------------------------------------------------------------



NR_OF_TESTS     EQU     8
    
; -------------------------------------------------------------------
; -- Code
; -------------------------------------------------------------------
    
                AREA myCode, CODE, READONLY
                    
                THUMB

; -------------------------------------------------------------------
; -- Test
; -------------------------------------------------------------------   
                        
mul_u32         PROC
                EXPORT mul_u32
                IMPORT display_title
                IMPORT tests_32x32
                PUSH {R1-R3,LR}

				LDR  R0,=title
				BL   display_title

				LDR  R3,=result_table
				LDR  R2,=values
				LDR  R1,=NR_OF_TESTS
				LDR  R0,=operation
				BL   tests_32x32

				POP  {R1-R3,PC}
				ENDP
                    
; -------------------------------------------------------------------
; 32 bit multiplication
; - multiplier in R0
; - multiplicand in R1
; - 64 bit result in R1:R0 (upper:lower)
; -------------------------------------------------------------------
operation       PROC
				PUSH {R4-R7,LR}

				; Instruction: do not use high registers in your code, 
				; or make sure they contain thier original values
				; when the function returns

                ; STUDENTS: To be programmed                        


                ; END: To be programmed

                POP  {R4-R7,PC}            ; return R0
				ENDP

				ALIGN

; -------------------------------------------------------------------
; -- Constants
; -------------------------------------------------------------------
                AREA myConstants, DATA, READONLY

values          DCD             0x00000001
				DCD             0xffffffff
				DCQ     0x00000000ffffffff

				DCD             0x00001717
				DCD             0x00004a4a
				DCQ     0x0000000006b352a6

				DCD             0x00001717
				DCD             0xffffffff
				DCQ     0x00001716FFFFE8E9

				DCD             0x73a473a4
				DCD             0x4c284c28
				DCQ     0x2267066da5a6c1a0

				DCD             0x43f887cc
				DCD             0xc33e6abf
				DCQ     0x33d6e1f8e60fc934

				DCD             0xe372e372
				DCD             0x00340234
				DCQ     0x002e354b4c451728

				DCD             0x22dddd22
				DCD             0xbcccddde
				DCQ     0x19b6d568f3641d7c

				DCD             0x7fffffff
				DCD             0x7fffffff
				DCQ     0x3fffffff00000001

title           DCB "mul_u32", 0

				ALIGN
; -------------------------------------------------------------------
; -- Variables
; -------------------------------------------------------------------
                AREA myVars, DATA, READWRITE
                    
result_table    SPACE   NR_OF_TESTS*8


; -------------------------------------------------------------------
; -- End of file
; -------------------------------------------------------------------                      
                END

