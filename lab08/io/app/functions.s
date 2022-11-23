;Directives
        PRESERVE8
        THUMB

; ------------------------------------------------------------------
; -- myCode
; ------------------------------------------------------------------
        AREA myCode, CODE, READONLY

        EXPORT out_word
        EXPORT in_word

out_word        PROC
        PUSH 	{R4-R7,LR}

		; R0: value
		; R1: output address
        STR 	R0, [R1]	; write value to output

        POP 	{R4-R7,PC}
        BX 		LR

        ALIGN
        ENDP

in_word         PROC
        PUSH 	{R4-R7,LR}

        LDR 	R0, [R0] 	; load value of address into R0

		POP 	{R4-R7,PC}
        BX 		LR

        ALIGN
        ENDP

; ------------------------------------------------------------------
; End of code
; ------------------------------------------------------------------
        END