.include "m328Pdef.inc" 
.include "C:\Users\parfi\Desktop\Free\MACRO.asm"

.cseg
.include "C:\Users\parfi\Desktop\Free\test\testVectors.asm"
.equ DefPowerDC = 1500		;50% of power

Reset:
ldi r16, high(RAMEND) // ????????????? ?????
out SPH, r16
ldi r16, low(RAMEND)
out SPL, r16

;init---------------------------------------------------
.include "C:\Users\parfi\Desktop\Free\test\testInit.asm"
;-------------------------------------------------------
call DMP_init
clr r16
sts CountBuff, r16
;---------------------------------------------------------
I2C_Write adrMPU, 116, 1, 0x01	
I2C_Write adrMPU, 117, 1, 0x02
I2C_Write adrMPU, 118, 1, 0x03
I2C_Write adrMPU, 119, 1, 0x04
I2C_Write adrMPU, 120, 1, 0x05
I2C_Write adrMPU, 121, 1, 0x06	
I2C_Write adrMPU, 122, 1, 0x07	
I2C_Write adrMPU, 123, 1, 0x08	
I2C_Write adrMPU, 124, 1, 0x09	
I2C_Write adrMPU, 125, 1, 0x0A	

I2C_Write adrMPU, 126, 1, 0x0B
I2C_Write adrMPU, 127, 1, 0x0C	
I2C_Write adrMPU, 128, 1, 0x0D	
I2C_Write adrMPU, 129, 1, 0x0E	
I2C_Write adrMPU, 130, 1, 0x0F	
I2C_Write adrMPU, 131, 1, 0x10	
I2C_Write adrMPU, 132, 1, 0x12	
I2C_Write adrMPU, 114, 1, 0x2A
I2C_Write adrMPU, 115, 1, 0x00

I2C_Read adrMPU, 116, 17, FifoBuff
nop
nop
nop
nop
;---------------------------------------------------------
Outer:
lds r19, IN_PF
cpi r19, 2	
brne Loop

rcall EHO
;-----------------------------------------------------

ldi r16, 0xD6
ldi r17, 0x06
ST_CH K0, r16, r17
ldi r16, 0x3A
ldi r17, 0x07
ST_CH K1, r16, r17
ldi r16, 0x9E
ldi r17, 0x07
ST_CH K2, r16, r17
ldi r16, 0xE2
ldi r17, 0x04
ST_CH K3, r16, r17
;----------------------------------------------------
rcall Need
;call Real
Loop:
call EulerAngles	
rcall Inter
rjmp Outer

Default:			; ????? ?????? - ?????? ?????? ? ???????? "? ?????? ?????? ???? ?????? ???????? - ?????? ?????????"
;ldi K0, DefPowerDC(50%)	;????? ?????? ??????????? ???????? ?????????? ??? ????????? ??????
ldi r17, high(DefPowerDC)
ldi r16, low (DefPowerDC)
ldi ZH, high(K0)
ldi ZL, low (K0)
st Z+, r16
st Z, r17
;ldi K1, 0			; ?????? ???? (roll, pitch, yaw) ? 0 degree - ?? ?????????
clr r16
ldi ZH, high(K1)
ldi ZL, low (K1)
st Z+, r16
st Z, r16
;ldi K2, 0
ldi ZH, high(K2)
ldi ZL, low (K2)
st Z+, r16
st Z, r16
;ldi K3, 0
ldi ZH, high(K3)
ldi ZL, low (K3)
st Z+, r16
st Z, r16

;rcall Real			;????? ? ??????? ????? i2c ??????????? ? ?????
call EulerAngles	;????????? ??????????? ? ???? ??????(???????)
call Inter	
ret

;tasks-------------------------------------------------
.include "C:\Users\parfi\Desktop\Free\incTest_UART.asm"
.include "C:\Users\parfi\Desktop\Free\incTest_PWM.asm"
.include "C:\Users\parfi\Desktop\Free\test\incTest_MPU.asm"
.include "C:\Users\parfi\Desktop\Free\PID.asm"
.include "C:\Users\parfi\Desktop\Free\algoritmes.asm"