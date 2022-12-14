;* ----------------------------------------------------------------------------
;* --  _____       ______  _____                                              -
;* -- |_   _|     |  ____|/ ____|                                             -
;* --   | |  _ __ | |__  | (___    Institute of Embedded Systems              -
;* --   | | | '_ \|  __|  \___ \   Zurich University of                       -
;* --  _| |_| | | | |____ ____) |  Applied Sciences                           -
;* -- |_____|_| |_|______|_____/   8401 Winterthur, Switzerland               -
;* ----------------------------------------------------------------------------
;* --
;* -- Project     : CT1 - Lab 12
;* -- Description : Common procedures
;* -- 
;* -- $Id: utils.s 1244 2015-02-03 10:12:17Z ruan $
;* ----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; -- Constants
; -----------------------------------------------------------------------------
    
                AREA myCode, CODE, READONLY
                    
                THUMB
    

; -----------------------------------------------------------------------------
; Set bit of a register (SFR, word -> 32 bit)
; - Address of register in R6
; - Bits to be set in R7
; -----------------------------------------------------------------------------
set_sfr         PROC
                EXPORT set_sfr
                       
                PUSH {LR}
                
                LDR  R2, [R0]               ; Load register value to R0
                ORRS R2, R2, R1             ; Set bits
                STR  R2, [R0]               ; Store new register value

                POP  {PC}               ; Restore registers and return
                
                ENDP
                    
                    
; -----------------------------------------------------------------------------
; Clear all bits of a register (SFR, word -> 32 bit)
; - Address of register in R0
; - Bits to be cleared in R1
; -----------------------------------------------------------------------------
clear_sfr       PROC
                EXPORT clear_sfr
                    
                PUSH {LR}
                
                LDR  R2, [R0]               ; Load register value to R0
                BICS R2, R2, R1             ; Clear bits
                STR  R2, [R0]               ; Store new register value

                POP  {PC}           ; Restore registers and return

                ENDP


; -----------------------------------------------------------------------------
; -- End of file
; -----------------------------------------------------------------------------
                END

