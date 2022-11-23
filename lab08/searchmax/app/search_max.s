;* ------------------------------------------------------------------
;* --  _____       ______  _____                                    -
;* -- |_   _|     |  ____|/ ____|                                   -
;* --   | |  _ __ | |__  | (___    Institute of Embedded Systems    -
;* --   | | | '_ \|  __|  \___ \   Zurich University of             -
;* --  _| |_| | | | |____ ____) |  Applied Sciences                 -
;* -- |_____|_| |_|______|_____/   8401 Winterthur, Switzerland     -
;* ------------------------------------------------------------------
;* --
;* -- Project     : CT1 - Lab 10
;* -- Description : Search Max
;* -- 
;* -- $Id: search_max.s 879 2014-10-24 09:00:00Z muln $
;* ------------------------------------------------------------------


; -------------------------------------------------------------------
; -- Constants
; -------------------------------------------------------------------
                AREA myCode, CODE, READONLY
                THUMB
                    
; STUDENTS: To be programmed




; END: To be programmed
; -------------------------------------------------------------------                    
; Searchmax
; - tableaddress in R0
; - table length in R1
; - result returned in R0
; -------------------------------------------------------------------   
search_max      PROC
                EXPORT search_max
                ; STUDENTS: To be programmed
				
                PUSH 	{R4-R7,LR}
                
				MOVS 	R4, R0 			; copy table address
                LDR 	R0, =0x80000000 ; default return
				CMP 	R1, #0x0
                BEQ 	return 			; return if table_length is 0
				
				MOVS 	R5, #0x0		; offset
				LDR 	R0, [R4, R5]	; max_value = first element
                MOVS 	R7, #0x0 		; i = 0

loop
				LDR 	R6, [R4, R5] 	; load table value
                CMP 	R1, R7
                BEQ 	return 			; i < table_length
                
                ADDS 	R5, #4 			; increment offset (32bit signed words)
                ADDS 	R7, #1 			; i++

                CMP 	R6, R0
                BLE 	loop 			; R6 < R0
                
                MOVS 	R0, R6 			; set new max_value
				B 		loop

return
				POP 	{R4-R7,PC}
				BX 		LR
				
                ; END: To be programmed
                ALIGN
                ENDP
; -------------------------------------------------------------------
; -- End of file
; -------------------------------------------------------------------                      
                END

