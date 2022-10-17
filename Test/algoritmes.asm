.dseg
					 cosr_cosp:		.byte 4			;in macro
					 sinr_cosp:		.byte 4			;in macro
					 STACk:			.byte 2			;in macro
					 fab_y:			.byte 4			;in macro	
.cseg

sqrt:	
		push r31
		push r30
		clr r17
		clr r16
		clr r26
		clr r27
		clr r28
		clr r29
		;(ответ)ans- r16:r17						short sqrt(short x) {
		;tmp- r26:r27:r28:r29						short ans = 0;
		;(входноечисло)x- r22:r23:r24:r25			short tmp = 0;
		;(счётчик)i- r15							short local_mask = 0b11;
		;mask- r14									short mask = 0;
		;(0b11)local_mask- r30						for(int i = 3; i>=0; i--) {
		;ans*ans- r18:r19:r20:r21						mask |= local_mask << (2*i);
		;												tmp = x & mask;
		;												ans ^= 1 << i;
		;													if(tmp < ans*ans)
		;													ans ^= 1 << i     }
		;											return ans 							}
		
;---------------------------    ans=r17(4bit high); tmp=r29; x=r25		-----------------------------------------			
						
	t1: ldi r31, 7
		mov r14, r31
		ldi r31, 3
		mov r15, r31

	ta:	ldi r31, 2
		mov r1, r31
		mov r31, r15			;i=3
		mul r31, r1
		ldi r30, 0b11		;local_mask=0b11
	;ldi r30, r30 << 2*r15	;mask
		cpi r31, 0
		breq and1
 lsl1a:	lsl r30			
  		;ld r31, r0
  		;dec r31
		dec r0
		brne lsl1a
	;mask
and1:push r25
		and r25, r30		;	ld r29, r25 & r30
		eor r29, r25
	pop r25
		
 		ldi r31, 1			;ld r17, r17 ^ 1 << r14	; (high bit) ans ^= 1 << i
		mov r0, r14
lsl1b:	lsl r31		
		dec r0
		brne lsl1b
		eor r17, r31
		
		mul16_16 r16, r17, r16, r17		; ans*ans- 32 bit = r18, r19, r20, r21
	push r29
	clr r28
	clr r27
	clr r26
		sub32_32 r26, r27, r28, r29, r18, r19, r20, r21				;tmp-ans*ans
	pop r29													
		brcc cmp1												;Перейти если флаг переноса(C) очищен if(tmp > ans*ans)
		;ld r17, r17 ^ 1 << r14
 		ldi r31, 1	
		mov r0, r14		
lsl1c:	lsl r31											; else установленный бит, снова в 0
		dec r0
		brne lsl1c			
		eor r17, r31		;ans ^= 1 << i
		rjmp cmp1

	cmp1:						
		dec r15					
		dec r14
		mov r31, r15
		cpi r31, 0xFF
		breq t2				;else < 0
		rjmp ta
;-----------------------------------------   ans=r17(4bit low); tmp=r28; x=r24     --------------------------------------------		
	t2: ldi r31, 3				;!r28!
		mov r14, r31
		ldi r31, 3
		mov r15, r31

	tb:	ldi r31, 2
		mov r1, r31
		mov r31, r15
		mul r31, r1	
		ldi r30, 0b11					
;tb:	ldi r30, r30 << 2*r15

		cpi r31, 0
		breq and2
lsl2a:	lsl r30						
  		dec r0
		brne lsl2a
		;mask
and2:push r24	
		and r24, r30		;	ld r28, r24 & r30
		eor r28, r24
	pop r24	
		
		ldi r31, 1
		mov r18, r14
		cpi r18, 0
		breq eor2b		
		mov r0, r14		
lsl2b:	lsl r31
		dec r0
		brne lsl2b
eor2b:	eor r17, r31					;ld r17, r17 ^ 1 << r14
	clr r18
		mul16_16 r16, r17, r16, r17									; ans*ans r18:r19:r20:r21
	push r28
	push r29
	clr r27
	clr r26
		sub32_32 r26, r27, r28, r29, r18, r19, r20, r21						;tmp-ans*ans
	pop r29
	pop r28			;?????????? tmp -16bit ? ans*ans-16 bit
		brcc cmp2
								;Перейти если флаг переноса(C) очищен if(tmp > ans*ans)
		ldi r31, 1
		mov r18, r14	
		cpi r18, 0
		breq eor2c			; else установленный бит, снова в 0
		mov r0, r15		
lsl2c:	lsl r31
		dec r0
		brne lsl2c
eor2c:	eor r17, r31						;ld r17, r17 ^ 1 << r15 <- !!!
	clr r18
		rjmp cmp2
		
	cmp2:
		dec r15
		dec r14
		mov r31, r15
		cpi r31, 0xFF
		breq t3				;else < 0
		rjmp tb
;-----------------------------------------    ans=r16(4bit high); tmp=r27; x=r23    ----------------------------------
	t3: ldi r31, 7
		mov r14, r31
		ldi r31, 3
		mov r15, r31
		
	tc: ldi r31, 2
		mov r1, r31
		mov r31, r15
		mul r31, r1
		ldi r30, 0b11
;ldi r30, r30 << 2*r15
		
		cpi r31, 0
		breq and3
lsl3a:	lsl r30						
  		dec r0
		brne lsl3a
;ld r27, r23 & r30

and3:push r23	
		and r23, r30
		eor r27, r23
	pop r23
		ldi r31, 1			;ld r16, r16 ^ 1 << r14	
		mov r0, r14
lsl3b:	lsl r31
		dec r0
		brne lsl3b
		eor r16, r31
	
	mul16_16 r16, r17, r16, r17		; ans*ans r18:r19:r20:r21 
	
	push r27
	push r28
	push r29
	clr r26
		sub32_32 r26, r27, r28, r29, r18, r19, r20, r21		; tmp-ans*ans 
	pop r29
	pop r28
	pop r27	
		brcc cmp3				;Перейти если флаг переноса(C) очищен if(tmp > ans*ans)
							; else установленный бит, снова в 0
		ldi r31, 1			;ld r16, r16 ^ 1 << r14	
		mov r0, r14			;
lsl3c:	lsl r31
		dec r0
		brne lsl3c
		eor r16, r31
		rjmp cmp3							
		
	cmp3: 
		dec r15
		dec r14
		mov r31, r15
		cpi r31, 0xFF
		breq t4				;если < 0
		rjmp tc

;------------------------------------------    ans=r16(4bit low); tmp=r26; x=r22   -------------------------------------
	t4:	ldi r31, 3
		mov r14, r31
		ldi r31, 3
		mov r15, r31		

	td:	ldi r30, 0b11
		ldi r31, 2
		mov r1, r31
		mov r31, r15
		mul r31, r1
	;ldi r30, r30 << 2*r15
	
		cpi r31, 0
		breq and4
lsl4a:	lsl r30							
  		dec r0
		brne lsl4a										
;ld r26, r22 & r30
and4:push r22
		and r22, r30
		eor r26, r22
	pop r22

		ldi r31, 1			;ld r16, r16 ^ 1 << r14	
		mov r18, r14
		cpi r18, 0
		breq eor4b
		mov r0, r14
lsl4b:	lsl r31
		dec r0
		brne lsl4b
eor4b:	eor r16, r31
	clr r18								
		
		mul16_16 r16, r17, r16, r17		;ans*ans r18:r19:r20:r21
	push r26
	push r27
	push r28
	push r29
		sub32_32 r26, r27, r28, r29, r18, r19, r20, r21		; tmp-ans*ans
	pop r29
	pop r28
	pop r27
	pop r26	
		brcc cmp4								;Перейти если флаг переноса(C) очищен if(tmp > ans*ans)
										;else установленный бит, снова в 0
		ldi r31, 1			;ld r16, r16 ^ 1 << r15
		mov r18, r15
		cpi r18, 0				;!!!!!!!!!!!!!!!!!!!!!!!!
		breq eor4c
		mov r0, r15	
lsl4c:	lsl r31
		dec r0
		brne lsl4c
eor4c:	eor r16, r31
	clr r18
		rjmp cmp4
								
	cmp4: 
		dec r15
		dec r14
		mov r31, r15
		cpi r31, 0xFF
		breq ext			;если < 0
		rjmp td
	
	ext:
	pop r30
	pop r31
ret

;============================================= EULERANGLES =====================================================================================
EulerAngles:
;roll (x-axis rotation)
;sinr = 2 * (q.w * q.x + q.y * q.z)
sinr:
ldi r31, high(q_w)
ldi r30, low(q_w)
ldi r29, high(q_x)
ldi r28, low(q_x)
	ld r16, Z+
	ld r17, Z+
	ld r18, Y+
	ld r19, Y+
muls16_16 r20, r21, r22, r23			;произведение в r20:r21:r22:r23////// в функции данные используются из r28-r31

ldi r31, high(q_y)
ldi r30, low(q_y)
ldi r29, high(q_z)
ldi r28, low(q_z)
	ld r16, Z+
	ld r17, Z+
	ld r18, Y+
	ld r19, Y+
muls16_16 r28, r29, r30, r31			;произведение в R28:R29:R30:R31
add32_32 r20, r21, r22, r23, r28, r29, r30, r31			;r20:r21:r22:r23 + r28:r29:r30:r31 знаковое
;R23:R22:R21:R20 * 2
lsl r20
rol r21
rol r22
rol r23

;cosr = 1(1000 000) - 2 * (q.x * q.x + q.y * q.y)
cosr:
ldi r31, high(q_x)
ldi r30, low(q_x)
ldi r29, high(q_x)
ldi r28, low(q_x)
	ld r16, Y+
	ld r17, Y+
	ld r18, Z+
	ld r19, Z+
muls16_16 r24, r25, r26, r27			;произведение в r24:r25:r26:r27

ldi r31, high(q_y)
ldi r30, low(q_y)
ldi r29, high(q_y)
ldi r28, low(q_y)
	ld r16, Y+
	ld r17, Y+
	ld r18, Z+
	ld r19, Z+
muls16_16 r28, r29, r30, r31					;произведение в r28:r29:r30:r31
add32_32 r24, r25, r26, r27, r28, r29, r30, r31  ;r24:r25:r26:27 + r16:r17:r18:19 знаковое
;r24:r25:r26:r27 * 2 - один сдвиг влево = * на 2 ;aааа!!! может быть баг, переполнение
lsl r24
rol r25
rol r26
rol r27
;1000 000 - r24,r25,r26,r27 = - r24,r25,r26,r27 + 1000 000 :
neg32 r24, r25, r26, r27
subi r24, 0xC0
sbci r25, 0xBD
sbci r26, 0xF0
sbci r27, 0xFF
angle_roll:
;atan2 (sinr_cosp, cosr_cosp):
ST_Y r20, r21, r22, r23			;save y in sinr_cosp(memory) 
ST_X r24, r25, r26, r27			;save x in cosr_cosp(memory)

rcall atan2			;r20, r21, r22, r23 - sinr_cosp(1 arg), - cosr_cosp(2 arg)
ST_ROLL r20, r21, r22, r23 
;------------------------------------------------------------------
;pitch (y-axis rotation)
; sinp = 2 * (q.w * q.y - q.z * q.x)
sinp:
ldi r31, high(q_w)
ldi r30, low(q_w)
ldi r29, high(q_y)
ldi r28, low(q_y)
	ld r16, Z+
	ld r17, Z+
	ld r18, Y+
	ld r19, Y+
muls16_16 r20, r21, r22, r23			;произведение q.w * q.y в r20:r21:r22:r23

ldi r31, high(q_z)
ldi r30, low(q_z)
ldi r29, high(q_x)
ldi r28, low(q_x)
	ld r16, Z+
	ld r17, Z+
	ld r18, Y+
	ld r19, Y+
muls16_16 r28, r29, r30, r31			;произведение q.z * q.x в r16:r17:r18:r19

sub32_32 r20, r21, r22, r23, r28, r29, r30, r31		;(q.w * q.y - q.z * q.x)
;R23:R22:R21:R20 * 2
lsl r20
rol r21
rol r22
rol r23
ST_X r20, r21, r22, r23 	; save sinp in ROM 

sbrs r23, 7						;if (std::abs(sinp) >= 1)
rjmp hz
neg32 r20, r21, r22, r23
;ldi r31-r28, 1000 000
hz:	 
	ldi r28, 0x40
	ldi r29, 0x42
	ldi r30, 0x0F
	ldi r31, 0x00

sub32_32 r28, r29, r30, r31, r20, r21, r22, r23
brcc IFsinp			;если C очищен, т.е. 1000 000(1)> |sinp|

;angles.pitch = std::copysign(M_PI / 2, sinp); // use 90 degrees if out of range
LD_X r16, r17, r18, r19
	sbrc r19, 7
	rjmp ng
	ldi r16, 0x5A
	clr r17
	clr r18
	clr r19
	rjmp stpitch					;!!!!!!!!! ANGLE PITCH (max90 degr/3byte) in r16, r17, r18, r19

ng:
	ldi r16, 0xA6					;!!!!!!!!! ANGLE PITCH (max(-90) degr/3byte) in r16, r17, r18, r19
	ldi r17, 0xFF
	ldi r18, 0xFF
	ldi r19, 0xFF
	rjmp stpitch
	
IFsinp: 									;asin(sinp) = atan(sinp/sqrt(1-sinp*sinp))    
	LD_X r16, r17, r18, r19		; out sinp from ROM
	
		ldi r20, 0xE8
		ldi r21, 0x03
		clr r22
		clr r23
		div32_32 r16, r17, r18, r19, r20, r21, r22, r23
	movw r30, r16
	movw r18, r16
	muls16_16 r22, r23, r24, r25									;после перехода на IFsinp оно не может быть больше 1000 000(24 bit)
;-sinp*sinp+1 => (1 000 000-sinp*sinp)
	neg32 r22, r23, r24, r25
	;add32_32 r22, r23, r24, r25, r28, r29, r30, r31
	subi r22, 0xC0
	sbci r23, 0xBD
	sbci r24, 0xF0
	sbci r25, 0xFF
;sqrt r22: r23: r24: r25
	rcall sqrt												;IN - r22:r23:r24:r25\ OUT - r16:r17
	movw r24, r16
	clr r26
	clr r27
	
	ldi r18, 0x64
	clr r19
	movw r16, r30
	muls16_16 r20, r21, r22, r23
	
	div32_32 r20, r21, r22, r23, r24, r25, r26, r27				
	movw r30, r20											;делимое in r20:r21
	rcall atan									;IN- r30:r31\ OUT- r20:r21 !!!!!!!!! ANGLE PITCH 
	
	movw r16, r20							
	movw r18, r22
stpitch:
	ST_PITCH r16, r17, r18, r19
;------------------------------------------------------------------------------------
;yaw
;siny_cosp = 2 * (q.w * q.z + q.x * q.y);	
;cosy_cosp = 1 - 2 * (q.y * q.y + q.z * q.z);
;angles.yaw = std::atan2(siny_cosp, cosy_cosp);
angle_yaw:

siny:
ldi r31, high(q_w)
ldi r30, low(q_w)
ldi r29, high(q_z)
ldi r28, low(q_z)
	ld r16, Z+
	ld r17, Z+
	ld r18, Y+
	ld r19, Y+
muls16_16 r20, r21, r22, r23					;произведение в r20:r21:r22:r23////// в функции данные используются из r16-r19

ldi r31, high(q_x)
ldi r30, low(q_x)
ldi r29, high(q_y)
ldi r28, low(q_y)
	ld r16, Z+
	ld r17, Z+
	ld r18, Y+
	ld r19, Y+
muls16_16 r28, r29, r30, r31					;произведение в R28:R29:R30:R31
add32_32 r20, r21, r22, r23, r28, r29, r30, r31							;r20:r21:r22:r23 + r28:r29:r30:r31 знаковое
;R23:R22:R21:R20 * 2
lsl r20
rol r21
rol r22
rol r23

cosy:
ldi r31, high(q_y)
ldi r30, low(q_y)
ldi r29, high(q_y)
ldi r28, low(q_y)
	ld r16, Y+
	ld r17, Y+
	ld r18, Z+
	ld r19, Z+
muls16_16 r24, r25, r26, r27				;произведение в r24:r25:r26:r27


ldi r31, high(q_z)
ldi r30, low(q_z)
ldi r29, high(q_z)
ldi r28, low(q_z)
	ld r16, Y+
	ld r17, Y+
	ld r18, Z+
	ld r19, Z+
muls16_16 r28, r29, r30, r31								;произведение в r28:r29:r30:r31
add32_32 r24, r25, r26, r27, r28, r29, r30, r31					; r24:r25:r26:27 + r16:r17:r18:19 знаковое
;r24:r25:r26:r27 * 2 - один сдвиг влево = * на 2
lsl r24
rol r25
rol r26
rol r27

;1000 000 - r24,r25,r26,r27 = - r24,r25,r26,r27 + 1000 000 :
neg32 r24, r25, r26, r27			
subi r24, 0xC0						
sbci r25, 0xBD
sbci r26, 0xF0
sbci r27, 0xFF

;atan2 (siny_cosp, cosy_cosp):
ST_Y r20, r21, r22, r23
ST_X r24, r25, r26, r27
											; in atan2 r20:r21:r22:r23, r24:r25:r26:r27
rcall atan2				;atan2(siny_cosp, cosy_cosp)	 angle out - r20:r21:r22:r23
ST_YAW r20, r21, r22, r23
ret
;======================================================================================================================================
;========================================= ATAN	=======================================================================================
atan:								;arctg(x) = x - (x ^ 3) / 3 + (x ^ 5) / 5 - (x ^ 7) / 7 + ...

sbrs r31, 7					;проверяем знак				; если мы хоти arctan 0,127 тогда in r30 записываем 127!!!
rjmp a00					;если отрицательный			;IN - r30	;from 0 to 127 работает normal!
set							;то set flag T and			;OUT - r20, r21	- degrees 
neg16 r30, r31						;|x|

a00:						;;; сужаем диапазон значений поиска
ldi r16, 0x80
ldi r17, 0x00
cp r30, r16
cpc r31, r17
brsh a900
rjmp a127
;---------------				без вычислений сразу устанавливаем радианы (погрешность на выходе 5 градусов)
a900:
ldi r16, 0x84
ldi r17, 0x03
cp r30, r16
cpc r31, r17
brlo a600
ldi r20, 0x5E
ldi r21, 0x3A
ldi r22, 0x02
clr r23
rjmp endz1
;----------------------
a600:
ldi r16, 0x58
ldi r17, 0x02
cp r30, r16
cpc r31, r17
brlo a380
ldi r20, 0x14
ldi r21, 0x25
ldi r22, 0x02
clr r23
rjmp endz1
;---------------------------
a380:
ldi r16, 0x7C
ldi r17, 0x01
cp r30, r16
cpc r31, r17
brlo a280
ldi r20, 0x13
ldi r21, 0x01
ldi r22, 0x02
clr r23
rjmp endz1
;------------------------------
a280:
ldi r16, 0x18
ldi r17, 0x01
cp r30, r16 
cpc r31, r17 
brlo a220
ldi r20, 0x99
ldi r21, 0xDF
ldi r22, 0x01
clr r23
rjmp endz1
;---------------------------------
a220:
ldi r16, 0xDC
clr r17
cp r30, r16
cpc r31, r17
brlo a180
ldi r20, 0xF1
ldi r21, 0xBE
ldi r22, 0x01
clr r23
rjmp endz1
;------------------------------------
a180:	
ldi r16, 0xB4
clr r17							
cp r30, r16 
cpc r31, r17
brlo a143
ldi r20, 0xAB
ldi r21, 0x9D
ldi r22, 0x01
clr r23
rjmp endz1
;---------------------------------------
a143:
ldi r16, 0x8F
clr r17
cp r30, r16
cpc r31, r17
brlo a127
ldi r20, 0x36
ldi r21, 0x77
ldi r22, 0x01
clr r23
rjmp endz1
;---------------------------------------------
a127:
cpi r30, 90  						; если мы хоти arctan 0,127 тогда in r30 записываем 127!!!
brlo lo0							
ldi r25, 200							;IN - r30	;from 0 to 127 работает normal!
rjmp art							;OUT - r20, r21	- degrees 
		
lo0: cpi r30, 70
	brlo lo1
	ldi r25, 40
	rjmp art

lo1: ldi r25, 5

art: clr r16
	clr r17
	clr r18
	clr r19
FINIT
	fld r30, r31, r18, r19		;fld st0 ; ????: x
		ldi r16, 1
	fld r16, r19, r17, r18			;fld1 ; ????: 1.0, x
	
	fld r30, r31, r18, r19		;fld st0 ; ????: x, 1.0, x
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++	
	;movw r16, r30
	;movw r18, r30
	;muls16_16 r20, r21, r22, r23				на будущее...
	;	ldi r16, 0x00
	;	ldi r17, 0x00
	;	ldi r18, 0x01							если входное число - 2байта
	;	ldi r19, 0x00							и оно не обрабатывается выше,
	;	clc									т.е. x>90градусов IN OUT
;	cp  r16, r20
;	cpc r17, r21
;	cpc r18, r22
;	cpc r19, r23
;	brlo sok
;	rjmp go
; sok:	ldi r16, 0xE8
;		ldi r17, 0x03
;		ldi r18, 0x00
;		ldi r19, 0x00
;	div32_32 r20, r21, r22, r23, r16, r17, r18, r19
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
go:	mul r30, r30					; -x^2 то,
	movw r30, r0					; на что нужно на каждом шаге умножать
	neg16 r30, r31					; числитель дроби
									; инвариант цикла:
			; st0 - текущая сумма ряда
			; st1 - текущий знаменатель дроби
			; st2 - текущий числитель
	clr r15
	inc r15
	dec r25	; пусть один шаг цикла уже выполнен (текущая сумма - x)	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	step_more:
		fldi 1, r16, r17, r18, r19		;fld st1
		ldi r20, 2
		add r16, r20					;fadd dword [TWO]
		clr r20
		adc r17, r20
		adc r18, r20						
		adc r19, r20					; теперь на вершине стека хранится корректный знаменатель для данного шага
		fld r16, r17, r18, r19		; stack: cur_denom, sum, old_denom, old_num

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		fldi 3, r16, r17, r18, r19		;fld st3
		movw r18, r30
		muls16_16 r20, r21, r22, r23	;fmul dword [NUMERATOR_MUL] ; теперь на вершине стека хранится корректный числитель для данного шага
		
	di:	ldi r16, 0xE8
		ldi r17, 0x03
		clr r18
		clr r19
	
		div32_32 r20, r21, r22, r23, r16, r17, r18, r19
;
		cpi r22, 0				
		breq pr
		cpi r22, 0xFF
		breq pr1
		rjmp di
	pr:	cpi r23, 0
		breq cl
		rjmp di
	pr1:cpi r23, 0xFF
		breq cl
		rjmp di
						
	cl:	or r22, r23
		
		fld r20, r21, r22, r23		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	fsti 4, r20, r21, r22, r23					;fst st4 ; stack: cur_num, cur_denom, sum, old_denom, cur_num
		fldi 1, r16, r17, r18, r19							;fdiv st1 ; stack:
		div32_32 r20, r21, r22, r23, r16, r17, r18, r19		;cur_num / cur_denom, cur_denom, sum, old_denom, cur_num
		
		fldi 2, r16, r17, r18, r19
		add32_32 r20, r21, r22, r23, r16, r17, r18, r19		;add st2, st0
		fsti 2, r20, r21, r22, r23			; cur_num / cur_denom, cur_denom,   cur_sum, old_denom, cur_num
		fldi 1, r20, r21, r22, r23 
		fsti 3, r20, r21, r22, r23			;cur_num / cur_denom, cur_denom,    cur_sum, cur_denom, cur_num
		fp 2								;cur_sum, cur_denom, cur_num
		
		dec r25
		inc r15
		cpi r25, 0
		breq endz
		rjmp step_more
endz:
	fldi 0, r20, r21, r22, r23
	FREC
;--------------------------------------------------------------------------
endz1:	clr r16								;radians into deegres
		clr r17
		clr r18
		clr r19
		ldi r31, 8
		mov r15, r31
		ldi r31, 180
		clc
	ad1:sbrs r31, 0
		rjmp ad2
		add r16, r20
		adc r17, r21
		adc r18, r22
		adc r19, r23
	ad2:ror r19
		ror r18
		ror r17
		ror r16
		ror r31
	clc
	dec r15
	brne ad1
mov r20, r31
mov r21, r16
mov r22, r17
mov r23, r18 
		ldi r16, 0x2F
		ldi r17, 0xCB
		ldi r18, 0x04
		ldi r19, 0x00
	div32_32 r20, r21, r22, r23, r16, r17, r18, r19
;----------------------------------------------------
brtc aret
neg32 r20, r21, r22, r23						;восстанавливаем знак, если был
clt										;clr flag T
aret:
	ret
;========================================= ATAN2 ======================================================================================
atan2:
	push r16						;IN- r24:r25:r26:r27 - x
	push r17						;  - r20:r21:r22:r23 - y
	push r18						; OUT- r20:r21:r22:r23
	push r19						; делить на 10 000 до целой части радиан
	push r28
	push r29
	push r30
	push r31
	
	ldi YH, 0x1E		;pi/4"31464/4"=7854 - 2byte
	ldi YL, 0xA5
	
	ldi ZH, 0x5B		;7854 * 3 = 23 562 - 2byte
	ldi ZL, 0xEF
IF1:
	cpi_8 r20, r21, r22, r23, r24, r25, r26, r27
	cpi r16, 1							;flag in macro "cpi_8"
	brne no0_0
	sbrc r23, 7
	neg32 r20, r21, r22, r23										;float arctan2(float y, float x)
	ldi r20, 1			;+1e-10										;		{
	clt																;coeff_1 = pi/4;
																	;coeff_2 = 3*coeff_1;
no0_0:																;abs_y = fabs(y)+1e-10 // kludge to prevent 0/0 condition
	sbrs r23, 7														;if (x>=0) {
	rjmp fab_s														;r = (x - abs_y) / (x + abs_y);
	neg32 r20, r21, r22, r23										;angle = coeff_1 - coeff_1 * r; }
fab_s:	FABS_Y r20, r21, r22, r23									;else {r = (x + abs_y) / (abs_y - x);
		sbrc r27, 7													; angle = coeff_2 - coeff_1 * r; }
		rjmp ELSE1													;if (y < 0) return(-angle); // negate if in quad III or IV
																	;else return(angle);		}
	sub32_32 r24, r25, r26, r27, r20, r21, r22, r23		;(x - abs_y) 
	LD_X r16, r17, r18, r19					; читаем x из памяти 
	add32_32 r20, r21, r22, r23, r16, r17, r18, r19	;(abs_y + x)  
	
		clr r16
		clr r17
		clr r18
		clr r19
		ldi r31, 8
		mov r15, r31
		ldi r31, 10
		clc
	ml1: sbrs r31, 0
		rjmp ml2
		add r16, r24
		adc r17, r25
		adc r18, r26
		adc r19, r27
	ml2: ror r19
		ror r18
		ror r17
		ror r16
		ror r31
	clc
	dec r15
	brne ml1
	
mov r24, r31
mov r25, r16
mov r26, r17
mov r27, r18
	
	diw: div32_32 r24, r25, r26, r27, r20, r21, r22, r23		
mulsu0:
	; r24:r25 * p/4
	movw r18, r24
	movw r16, r28
	muls16_16 r20, r21, r22, r23  ;coeff_1 * r		
	; -(coeff_1 * r) + coeff_1
	neg32 r20, r21, r22, r23	;-(coeff_1 * r)
	ldi r16, 0x0A
	ldi r17, 0x00
	movw r18, r28
	muls16_16 r28, r29, r30, r31
	
	add r20, r28				;+ coeff_1*10
	adc r21, r29
	adc r22, r30
	adc r23, r31				;;;;;;;!!!!!!!!!!!!! ANGLE - ROLL
	rjmp IF2
	
ELSE1:
	add32_32 r20, r21, r22, r23, r24, r25, r26, r27		;(abs_y + x)
	FABL_Y r16, r17, r18, r19								; выгружаем y из ОЗУ 
	sub32_32 r16, r17, r18, r19, r24, r25, r26, r27		;(abs_y - x)
	
mul8_32: 
clr r25
clr r26
clr r27
		ldi r24, 8
		mov r15, r24
		ldi r24, 10
		mov r14, r24
		clr r24
		clc
	m1: sbrs r14, 0
		rjmp m2
		add r24, r20
		adc r25, r21
		adc r26, r22
		adc r27, r23
	m2: ror r27
		ror r26
		ror r25
		ror r24
		ror r14
	clc
	dec r15
	brne m1	

mov r27, r26
mov r26, r25
mov r25, r24
mov r24, r14

	div32_32 r24, r25, r26, r27, r16, r17, r18, r19		

mulsu1:
	movw r18, r24
	movw r16, r28
	muls16_16 r20, r21, r22, r23		;coeff_1 * r
	; -(coeff_1 * r) + coeff_2
	neg32 r20, r21, r22, r23			;-(coeff_1 * r)

	ldi r18, 0x0A
	ldi r19, 0x00
	movw r16, r30
	muls16_16 r28, r29, r30, r31

	add r20, r28						;+ coeff_2 * 10
	adc r21, r29
	adc	r22, r30
	adc r23, r31	;;;;;;;!!!!!!!!!!!!! ANGLE - ROLL


IF2:LD_Y r16, r17, r18, r19						
	sbrs r19, 7				 ;if (y < 0)sbrs r19, 7
	rjmp ELSE2
	neg32 r20, r21, r22, r23
ELSE2:
		clr r16
		clr r17
		clr r18
		clr r19
		ldi r31, 8
		mov r15, r31
		ldi r31, 180
		clc
	dgr1: sbrs r31, 0
		rjmp dgr2
		add r16, r20
		adc r17, r21
		adc r18, r22
		adc r19, r23
	dgr2: ror r19
		ror r18
		ror r17
		ror r16
		ror r31
	clc
	dec r15
	brne dgr1
	
mov r20, r31
mov r21, r16
mov r22, r17
mov r23, r18
ldi r24, 0x2F
ldi r25, 0xCB
ldi r26, 0x04
ldi r27, 0x00

div32_32 r20, r21, r22, r23, r24, r25, r26, r27
clr r22
clr r23
	
	pop r31
	pop r30
	pop r29
	pop r28
	pop r19
	pop r18
	pop r17
	pop r16
ret
