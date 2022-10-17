;===================== error = need - real		=======================
;===================== P = Kp * error			=======================
;===================== It = integral * time		=======================
;===================== I = Ki * It				=======================
;===================== eeo = error - error_old	======================= 
;===================== eeot = eeo/ time			=======================
;===================== D = Kd * eeot			=======================
;===================== PID = P + I + D			=======================
;===================== error_old = error 		=======================
.dseg	

r_roll:			.byte 4			
r_pitch:		.byte 4
r_yaw:			.byte 4

Kp:			.byte 2
Ki:			.byte 2
Kd:			.byte 2
time:		.byte 2

error_old_r: .byte 2
error_old_p: .byte 2
error_old_y: .byte 2

sum_err_r:	.byte 2
sum_err_p:	.byte 2
sum_err_y:	.byte 2


.cseg		
			
PID_ROLL:
LD_K1 r20, r21						;need
LD_ROLL r16, r17, r18, r19			;real

sub r20, r16
sbc r21, r17						;error

LD_SumErr_R r18, r19
add r18, r20
adc r19, r21
ST_SumErr_R r18, r19

LD_Kp r18, r19

movw r16, r20
muls16_16 r26, r27, r28, r29		; P= Kp*error

LD_Time r16, r17

LD_SumErr_R r18, r19
; It=sum_of_errors * time;!!! if time = 0,01 =>  sum_of_errors * 100 * time*100
muls16_16 r12, r13, r14, r15

LD_Ki r16, r17
						
		clr r22				;I = Ki * It
		clr r23
		ldi r30, 16
		clr r24
		clr r25
		clc
	plu: sbrs r16,0
		rjmp plu1
		add r22, r12
		adc r23, r13
		adc r24, r14
		adc r25, r15
	plu1:ror r25
		ror r24
		ror r23
		ror r22
		ror r17
		ror r16
	clc
	dec r30
	brne plu
	movw r24, r22
	movw r22, r16

add32_32 r22, r23, r24, r25, r26, r27, r28, r29		;P+I

LD_ErrorOld_R r18, r19
ST_ErrorOld_R r20, r21				;error_old = error 
sub r20, r18					;eeo = error - error_old
sbc r21, r19

movw r16, r20

ldi r18, 0x64
ldi r19, 0x00
muls16_16 r12, r13, r14, r15	;eeot = eeo/ time;!!! if time = 0,01 => eeo * 100

LD_Kd r18, r19

		clr r26			;D = Kd * eeot
		clr r27
		clr r28
		ldi r20, 16
		clr r29
		clc
	plus: sbrs r18,0
		rjmp plus1
		add r26, r12
		adc r27, r13
		adc r28, r14
		adc r29, r15
	plus1:ror r29
		ror r28
		ror r27
		ror r26
		ror r19
		ror r18
	clc
	dec r20
	brne plus
	movw r28, r26
	movw r26, r18
		
	
add32_32 r22, r23, r24, r25, r26, r27, r28, r29			;(P+I)+D

ldi r26, 0x10
ldi r27, 0x27
clr r28
clr r29
div32_32 r22, r23, r24, r25, r26, r27, r28, r29
ret
;----------------------------------------------------------------------------------------------
PID_PITCH:
LD_K2 r20, r21						;need
LD_PITCH r16, r17, r18, r19			;real

sub r20, r16						;error
sbc r21, r17

LD_SumErr_P r18, r19
add r18, r20
adc r19, r21
ST_SumErr_P r18, r19	
	
LD_Kp r18, r19	

movw r16, r20
muls16_16 r26, r27, r28, r29		;P= Kp*error

LD_Time r16, r17

LD_SumErr_P r18, r19
muls16_16 r12, r13, r14, r15		;It=sum_of_errors * time;!!! if time = 0,01 =>  sum_of_errors * 100 * time*100

LD_Ki r16, r17
		clr r22				;I = Ki * It
		clr r23
		ldi r30, 16
		clr r24
		clr r25
		clc
	plu2: sbrs r16,0
		rjmp plu3
		add r22, r12
		adc r23, r13
		adc r24, r14
		adc r25, r15
	plu3:ror r25
		ror r24
		ror r23
		ror r22
		ror r17
		ror r16
	clc
	dec r30
	brne plu2
	movw r24, r22
	movw r22, r16

add32_32 r22, r23, r24, r25, r26, r27, r28, r29		;P+I

LD_ErrorOld_P r18, r19
ST_ErrorOld_P r20, r21			;error_old = error
sub r20, r18				;eeo = error - error_old
sbc r21, r19

movw r16, r20
ldi r18, 0x64
ldi r19, 0x00
muls16_16 r12, r13, r14, r15			;eeot = eeo/ time;!!! if time = 0,01 => eeo * 100

LD_Kd r18, r19

		clr r26								;D = Kd * eeot
		clr r27
		clr r28
		clr r29
		ldi r20, 16
		clc
	plus2: sbrs r18, 0
		rjmp plus3
		add r26, r12
		adc r27, r13
		adc r28, r14
		adc r29, r15
	plus3: ror r29
		ror r28
		ror r27
		ror r26
		ror r19
		ror r18
	clc
	dec r20
	brne plus2
	movw r28, r26
	movw r26, r18

add32_32 r22, r23, r24, r25, r26, r27, r28, r29		;(P+I)+D

ldi r26, 0x10
ldi r27, 0x27
clr r28
clr r29
div32_32 r22, r23, r24, r25, r26, r27, r28, r29
ret
;-----------------------------------------------------------------------------------------------
PID_YAW:
LD_K3 r20, r21						;need
LD_YAW r16, r17, r18, r19			;real
LD_Kp r18, r19

sub r20, r16
sbc r21, r17						;error

LD_SumErr_Y r18, r19 
add r18, r20
adc r19, r20
ST_SumErr_Y r18, r19

LD_Kp r18, r19

movw r16, r20
muls16_16 r26, r27, r28, r29		;P=K*error

LD_Time r16, r17
LD_SumErr_Y r18, r19
; It=sum_of_errors * time;!!! if time = 0,01 =>  sum_of_errors * 100 * time*100
muls16_16 r12, r13, r14, r15

LD_Ki r16, r17
	
		clr r22				;I = Ki * It
		clr r23
		clr r24
		clr r25
		ldi r30, 16
		clc
	plu4: sbrs r16, 0
		rjmp plu5
		add r22, r12
		adc r23, r13
		adc r24, r14
		adc r25, r15
	plu5: ror r25
		ror r24
		ror r23
		ror r22
		ror r17
		ror r16
	clc
	dec r30
	brne plu4
	movw r24, r22
	movw r22, r16

add32_32 r22, r23, r24, r25, r26, r27, r28, r29		;P+I

LD_ErrorOld_Y r18, r19
ST_ErrorOld_Y r20, r21		;error_old = error

sub r20, r18				;eeo = error - error_old
sbc r21, r19

movw r16, r20
ldi r18, 0x64
ldi r19, 0x00
muls16_16 r12, r13, r14, r15		;eeot = eeo/ time;!!! if time = 0,01 => eeo * 100

LD_Kd r18, r19 

		clr r26
		clr r27
		clr r28
		clr r29
		ldi r20, 16
		clc 
	plus4: sbrs r18, 0
		rjmp plus5
		add r26, r12
		adc r27, r13
		adc r28, r14
		adc r29, r15
	plus5: ror r29
		ror r28
		ror r27
		ror r26
		ror r19
		ror r18
	clc
	dec r20
	brne plus4
	movw r28, r26
	movw r26, r18
	
add32_32 r22, r23, r24, r25, r26, r27, r28, r29

ldi r26, 0x10
ldi r27, 0x27
clr r28
clr r29
div32_32 r22, r23, r24, r25, r26, r27, r28, r29
ret

			.eseg
			.cseg