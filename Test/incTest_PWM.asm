
.dseg
Flags:		.byte 1

.cseg

Inter:

ldi ZH, high(Flags)			;????????? ???? Flags ? r27
ldi ZL, low (Flags)
ld r27, Z

ma1:
push r27 
	call PID_ROLL					; ???????? ??? ??????????
	pop r27
movw r4, r22
clr r20
cp r22, r20
cpc r23, r20
	breq Bit_r
	cbr r27, 0b10000000				;flags=r27
	
a:	push r27
	call PID_PITCH
	pop r27
movw r6, r22
clr r20
cp r22, r20
cpc r23, r20
	breq Bit_p
	cbr r27, 0b01000000				;flags=r27

bb:	push r27
	call PID_YAW
	pop r27
movw r8, r22
clr r20
cp r22, r20
cpc r23, r20
	breq Bit_y
	cbr r27, 0b00100000				;flags=r27
c:
rcall Regul				;??????????? ???????? ??? ??????? ?? ???????? ?????, ?????? ???????? ?? ??????
	
cpi r27, 0					;flags=r27 
breq Main_OUT
;rjmp ma1					;???????? ??? ??? ?? ????? ????? 0, ???????? ? Main????????????????????????????
rjmp Main_OUT

Bit_r:	sbr r27, 0b10000000		;set ???
		rjmp a
		
Bit_p:	sbr r27, 0b01000000		;set ???
		rjmp bb
		
Bit_y:	sbr r27, 0b00100000		;set ???
		rjmp c
		
Main_OUT:	
	ldi ZH, high(Flags)
	ldi ZL, low (Flags)
	st Z, r27

ret

Need:
ldi r20, 0xF4		;0x01F4=500
ldi r21, 0x01
ldi r22, 0xE8
ldi r23, 0x03
ldi ZH, high(Flags)
ldi ZL, low (Flags)
ld r29, Z
;=======================Need degree of Roll======================
N_Roll:
	LD_CH K1, r18, r19			;?????? ?? ?1
	sub r18, r22
	sbc r19, r23
	cp r18, r20					;cpi K2, 500
	cpc r19, r21
	brlo Left_R					;if < {jmp Left_R}

Right_R:
	sub r18, r20
	sbc r19, r21
	rcall to_dgr
	ST_CH K1, r24, r25
	sbr r29, 0b00000001			; ?????????? ??? in flags
rjmp N_Pitch

Left_R:
	rcall to_dgr
	ST_CH K1, r24, r25
;========================Need degree of Pitch==================

N_Pitch:
	LD_CH K2, r18, r19			; ?????? ?? ?2
	sub r18, r22
	sbc r19, r23
	cp r18, r20
	cpc r19, r21
	brlo Back_P

Front_P:
	sub r18, r20
	sbc r19, r21
	rcall to_dgr
	ST_CH K2, r24, r25
	sbr r29, 0b00000010
rjmp N_Yaw

Back_P:
	rcall to_dgr
	ST_CH K2, r24, r25

;================================= Need degree of Yaw ==================
N_Yaw:
	LD_CH K3, r18, r19					; ?????? ?? ?3
	sub r18, r22
	sbc r19, r23
	cp r18, r20
	cpc r19, r21
	brlo Left_Y

Right_Y:
	sub r18, r20
	sbc r19, r21
	rcall to_dgr
	ST_CH K3, r24, r25
	sbr r29, 0b00000100
rjmp End_Y

Left_Y:
	rcall to_dgr
	ST_CH K3, r24, r25
	
End_Y:
ldi ZH, high(Flags)
ldi ZL, low (Flags)
st Z, r29
ret

;---------------------------------------------------------------------------------
to_dgr:	
	ldi r16, 18
	clr r17
	muls16_16 r24, r25, r26, r27		;18* r18:r19 => 90/500 = ?/r18:r19 
	ldi r16, 0x64
	clr r17
	div16_16 r24, r25, r16, r17
ret
;========================================================================================================================================

;=========================== Trottle +\- force ==========================================================================================
Regul:
LD_CH K0, r20, r21			; TROTTLE from memmory
subi r20, 0xE8
sbci r21, 0x03						;2000-1000 = r20:r21
clr r17
ldi r16, 10							;1000/100 = r20:r21/? => ?=r20:r21/20
div16_16 r20, r21, r16, r17
movw r2, r20

mov r28, r27			;sys - r28
andi r28, 0b11100000
cpi r28, 0b11100000				;if pitch&roll&yaw = 0 (set bits 7,6,5)
brne ro1
	rcall Trottle			;????? ???? ??? ? 0
rjmp Regul_OUT

ro1:	movw r20, r4
	ldi r16, 10
	mul r20, r16
	ldi r16, 9
	clr r17
	movw r20, r0
	div16_16 r20, r21, r16, r17	
	mov r4, r20
	
	sbrs r27, 0			;?????????? ???? ??? ? ???????? ??????????
	rjmp Roll_Left
	rjmp Roll_Right
pi1:
rcall Delay2_24ms
	movw r20, r6
	ldi r16, 10
	mul r20, r16
	ldi r16, 9
	clr r17
	movw r20, r0
	div16_16 r20, r21, r16, r17		
	mov r6, r20

	sbrs r27, 1			;?????????? ???? ??? ? ???????? ??????????
	rjmp Pitch_Back
	rjmp Pitch_Front
ya1:
rcall Delay2_24ms
	movw r20, r8
	ldi r16, 10
	mul r20, r16
	ldi r16, 9
	clr r17
	movw r20, r0
	div16_16 r20, r21, r16, r17		
	mov r8, r20

	sbrs r27, 2			;?????????? ???? ??? ? ???????? ??????????
	rjmp Yaw_Left
	rjmp Yaw_Right

Regul_OUT:
rcall Delay2_05ms

clr r16
sts OCR1AH, r16
sts OCR1AL, r16
sts OCR2B, r16
sts OCR2A, r16
sts OCR1BH, r16
sts OCR1BL, r16

;PWM1_OFF
;PWM2_OFF
;PWM1_ON
;PWM2_ON

nop
ret
;============================ ROLL ==============================================
Roll_Right:
mov r18, r2
add r18, r4			;????? (???????? ? ??????) ????????? trottle + force (%+%)
;------------
cpi r18, 100
brlo ch_ro1
ldi r18, 100
ch_ro1:
;------------
clr r19
rcall OCRx
sts OCR2B, r20			;OC2B Timer2
lsl r20
rol r19
sts OCR1AH, r19
sts OCR1AL, r20			;OC1A Timer1

mov r18, r2
sub r18, r4			; ?????? ????????? trottle - force
;-------------
brcc ch_ro2
ldi r18, 10
ch_ro2:
;-------------
clr r19
rcall OCRx
sts OCR2A, r20			;OC2A Timer2	
lsl r20
rol r19	
sts OCR1BH, r19
sts OCR1BL, r20			;OC1B Timer1

cbr r27, 0b00000001		; ???????? ???
rjmp pi1
;-------------------------------------------------------------------------------
Roll_Left:
mov r18, r2
add r18, r4			;?????? ????????? trottle + force (%+%)
;--------------
cpi r18, 100
brlo ch_ro3
ldi r18, 100
ch_ro3:
;--------------
clr r19
rcall OCRx
sts OCR2A, r20			;OC2A Timer2 
lsl r20
rol r19
sts OCR1BH, r19
sts OCR1BL, r20			;OC1B Timer1

mov r18, r2
sub r18, r4			;????? ????????? trottle - force
;-----------
brcc ch_ro4
ldi r18, 10
ch_ro4:
;----------
clr r19
rcall OCRx						
sts OCR2B, r20			;OC2B Timer2
lsl r20
rol r19		
sts OCR1AH, r19
sts OCR1AL, r20			;OC1A Timer1

rjmp pi1
;============================= PITCH ===================================
Pitch_Front:
mov r18, r2
add r18, r6			;?????? ????????? trottle + force (%+%)
;-----------
cpi r18, 100
brlo ch_pi1
ldi r18, 100
ch_pi1:
;-----------
clr r19
rcall OCRx
lsl r20
rol r19
sts OCR1BH, r19
sts OCR1BL, r20			;OC1B Timer1
sts OCR1AH, r19
sts OCR1AL, r20			;OC1A Timer1

mov r18, r2
sub r18, r6			;???????? ????????? trottle - force
;------------
brcc ch_pi2
ldi r18, 10
ch_pi2:
;------------
clr r19
rcall OCRx
sts OCR2A, r20			; OC2A Timer2		
sts OCR2B, r20			;OC2B Timer2

cbr r27, 0b00000010			;???????? ???
rjmp ya1
;--------------------------------------------------------------------------
Pitch_Back:
mov r18, r2
add r18, r6			;???????? ????????? trottle + force (%+%)
;--------------
cpi r18, 100
brlo ch_pi3
ldi r18, 100
ch_pi3:
;--------------
clr r19
rcall OCRx
sts OCR2A, r20			;OC2A Timer2
sts OCR2B, r20			;OC2B Timer2

mov r18, r2
sub r18, r6			;?????? ????????? trottle - force
;---------------
brcc ch_pi4
ldi r18, 10
ch_pi4:
;---------------
clr r19
rcall OCRx
lsl r20
rol r19
sts OCR1BH, r19			
sts OCR1BL, r20			;OC1B Timer1
sts OCR1AH, r19
sts OCR1AL, r20			;OC1A Timer1

rjmp ya1
;================================== YAW ============================
Yaw_Right:
mov r18, r2
add r18, r8			;???????? ?????? + ?????? ????? trottle + force (%+%)
;------------
cpi r18, 100
brlo ch_ya1
ldi r18, 100
ch_ya1:
;------------
clr r19
rcall OCRx				
sts OCR2A, r20			;OC2A Timer2
lsl r20
rol r19
sts OCR1AH, r19
sts OCR1AL, r20			;OC1A Timer1

mov r18, r2
sub r18, r8			;???????? ????? + ?????? ?????? trottle - force
;----------------
brcc ch_ya2
ldi r18, 10
ch_ya2:
;----------------
clr r19
rcall OCRx
sts OCR2B, r20			; OC2B Timer2
lsl r20
rol r19		
sts OCR1BH, r19
sts OCR1BL, r20				;OC1B Timer1

cbr r27, 0b00000100			;???????? ???
rjmp Regul_OUT
;---------------------------------------------------------------------------------------
Yaw_Left:
mov r18, r2
add r18, r8			;???????? ????? + ?????? ?????? trottle + force (%+%)
;--------------
cpi r18, 100
brlo ch_ya3
ldi r18, 100
ch_ya3:
;--------------
clr r19
rcall OCRx
sts OCR2B, r20			;OC2B Timer2
lsl r20
rol r19
sts OCR1BH, r19
sts OCR1BL, r20			;OC1B Timer1

mov r18, r2
sub r18, r8			;???????? ?????? + ?????? ????? trottle - force
;-------------
brcc ch_ya4
ldi r18, 10
ch_ya4:
;---------------
clr r19
rcall OCRx				
sts OCR2A, r20			;OC2A Timer2
lsl r20
rol r19
sts OCR1AH, r19
sts OCR1AL, r20			;OC1A Timer1

rjmp Regul_OUT
;=============================================== Trottle ======================================
Trottle:
	movw r18, r20
	rcall OCRx

	sts OCR2A, r20
	sts OCR2B, r20
clr r19
lsl r20
rol r19
	sts OCR1BH, r19
	sts OCR1BL, r20

	sts OCR1AH, r19
	sts OCR1AL, r20
ret
;----------------------------------------------------------------------------------------------
OCRx:		
;IN-r18, r19	(%power of DC)
;OUT- r20 (OCRnx)
	ldi r16, 0xFF
	mul r16, r18
	ldi r16, 100
	clr r17
	movw r20, r0
	div16_16 r20, r21, r16, r17
ret

Delay2_24ms:			;delay = 0,00224 sec
ldi r16, 255
ldi r17, 35
;ldi r18, 2
delay224:				;----- 256 * 35 * 4  / 16 000 000
subi r16, 1			;----- r16 * r17 * r18 * ????? ?? ???? / CPU = sec
sbci r17, 0
;sbci r18, 0
brcc delay224
ret

Delay2_05ms:			;delay = 0,00205 sec
ldi r16, 255
ldi r17, 32
;ldi r18, 2
delay205:				;----- 256 * 35 * 4  / 16 000 000
subi r16, 1			;----- r16 * r17 * r18 * ????? ?? ???? / CPU = sec
sbci r17, 0
;sbci r18, 0
brcc delay205
ret

Delay100ms:			;delay = 0,1024 sec
ldi r16, 255
ldi r17, 255
ldi r18, 4
delay100:				;----- 256 * 256 * 5 * 5 / 16 000 000
subi r16, 1			;----- r16 * r17 * r18 * ????? ?? ???? / CPU = sec
sbci r17, 0
sbci r18, 0
brcc delay100
ret
			.eseg
			.cseg

