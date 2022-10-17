.include "m328Pdef.inc" 
.include "inc_MACRO.asm"

.cseg
.include "inc_Vectors.asm"
.equ DefPowerDC = 1500		;50% of power

Reset:
ldi r16, high(RAMEND) // ????????????? ?????
out SPH, r16
ldi r16, low(RAMEND)
out SPL, r16

;init---------------------------------------------------
.include "inc_Init.asm"
;-------------------------------------------------------
call DMP_init
clr r16
sts CountBuff, r16

Outer:
lds r19, IN_PF
cpi r19, 2	
brne Loop

rcall EHO
rcall Need

Loop:
call EulerAngles	
rcall Inter
rjmp Outer

;tasks-------------------------------------------------
.include "inc_UART.asm"
.include "inc_PWM.asm"
.include "inc_MPU.asm"
.include "inc_PID.asm"
.include "inc_algoritmes.asm"
.include "inc_modes.asm"