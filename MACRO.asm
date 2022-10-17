
;============================================================== MATH ==========================================================================
.MACRO udiv8_8
push r16
	clr r16
di8:
	sub @0, @1
	inc r16
	brcc di8
	dec r16
	add @0, @1
	
	ror @1
	sub @0, @1
	brcs di8e
	inc r16
di8e:
	mov @0, r16
pop r16
.ENDMACRO

.MACRO div32_32
	push r0		; @1:@0 – частное
	push r1		; r3:r2:r1:r0 - целочисленный остаток
	push r2		; @3:@2:@1:@0 – делимое 
	push r3	
	push r4			; @7:@6:@5:@4– делитель
	push r15		; R15-счётчик, R28 – вспомогательный регистр
	push r28		; при выходе из подпрограммы в C находится признак ошибки
	rjmp strt
		
neg3:
	ldi r28, 1
	com @0
	com @1
	com @2
	com @3
	add @0, r28 ;subi @0, -1
	clr r28
	adc @1, r28	;а записываем со старшей
	adc @2, r28
	adc @3, r28
	ret
neg4:
	ldi r28, 1
	com @4
	com @5
	com @6
	com @7
	add @4, r28 ;subi @4, -1
	clr r28
	adc @5, r28	;а записываем со старшей
	adc @6, r28
	adc @7, r28
	ret
neg5: 
	ldi r28, 1
	com @0
	com @1
	add @0, r28 ;subi @0, -1
	clr r28
	adc @1, r28
	ret
	
strt:	eor @3, @7
		bst @3, 7
		eor @3, @7
	
fabs: 
	sbrc @7, 7
	rcall neg4
	sbrc @3, 7
	rcall neg3
	
	div32:
   ;была проверка				; если С = 0 – деление успешно выполнено 
	clr r0
	clr r1
	clr r2
	clr r3				;(т.е. R:27:@6:@5:@4 = 0), то выходим из
	clr r4				;подпрограммы с признаком ошибки C=1
	ldi r28, 32
	mov r15, r28
	clr r28
dv1:
	lsl @0
	rol @1
	rol @2
	rol @3
	rol r0
	rol r1
	rol r2
	rol r3
	sub r0, @4
	sbc r1, @5
	sbc r2, @6
	sbc r3, @7
	sbc r4, r28
	ori @0, 0x01
	brcc dv2
	add r0, @4
	adc r1, @5
	adc r2, @6
	adc r3, @7
	adc r4, r28
	andi @0, 0xFE
dv2:
	dec r15
	brne dv1
	clc

cp1:
	lsr @7
	ror @6
	ror @5
	ror @4
	sub r0, @4
	sbc r1, @5 
	sbc r2, @6
	sbc r3, @7
	 
	brcs revfabs
	ldi r28, 1
	add @0, r28
	clr r28
	adc @1, r28
revfabs:
	brtc nxt
	rcall neg5
nxt: 
	nop
	pop r28
	pop r15
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
.ENDMACRO

.MACRO div16_16
	push r0
	push r1		
	push r2
	push r28
	push r15	
	rjmp srt
	
	neg1: 
	ldi r28, 1
	com @0
	com @1
	add @0, r28
	clr r28
	adc @1, r28
	ret

neg2:
	ldi r28, 1
	com @2
	com @3
	add @2, r28
	clr r28
	adc @3, r28 
	ret
						;@0:@1	 – делимое			
srt:	eor @1, @3		;@2:@3	– делитель
		bst @1, 7		;@0		- частное		
		eor @1, @3		; r0,r1		- остаток
fabs: 				;R15-счётчик, R2,  R28 – вспомогательныe регистрЫ
	sbrc @3, 7
	rcall neg2
	sbrc @1, 7
	rcall neg1
	
div16:
	clr r0
	clr r1
	clr r2
	clr r28
	ldi r28, 16
	mov r15, r28
	clr r28
dv1:
	lsl @0
	rol @1
	rol r0
	rol r1
	rol r2
	
	sub r0, @2
	sbc r1, @3
	sbc r2, r28 		;r2-0
	ori @0, 0x01
	brcc dv2
	add r0, @2
	adc r1, @3
	adc r2, r28
	andi @0, 0xFE
dv2:
	dec r15
	brne dv1
	clc
	
	lsr @3
	ror @2
	sub r0, @2
	sbc r1, @3
	brcs rfabs
	subi @0, -1
rfabs:
	brtc nxt
	rcall neg1
nxt: nop
	pop r15
	pop r28
	pop r2
	pop r1
	pop r0
.ENDMACRO

.MACRO muls16_16		;@0:@1:@2:@3 = R17:R16 * R19:R18
push r0
push r1
	mul r16, r18	;находим XLU*YLU = r16*r18 и заносим его в
	movw @0, r0		;младшие байты произведения 
	muls r17, r19	;находим XHS*YHS = r17*r19 и заносим его в
	movw @2, r0		;старшие байты произведения 
	mulsu r17, r18	;находим XHs*YLU = r17*r18 и прибавляем его к
	clr r17
	sbci r17, 0
	add @1, r0		;байтам @1:@2:@3  произведения
	adc @2, r1
	adc @3, r17
	mulsu r19, r16	;находим YHS*XLU = r19*r16 и прибавляем его к
	clr r17
	sbci r17, 0
	add @1, r0		;байтам @1:@2:@3 произведения 
	adc @2, r1
	adc @3, r17
pop r1
pop r0
.ENDMACRO

.MACRO	mul16_16		;вносим множители
  push @0
  push @1
  push @2
  push @3
  push r30
	clr r30
	mul @0, @2			;находим XLU*YLU = R16*R16 и заносим его в
	movw r18, r0			;младшие байты произведения r18:r19:r20:r21 
	mul @1, @3			;находим XHS*YHS = R17*R17 и заносим его в
	movw r20, r0			;старшие байты произведения 
	mul @1, @2			;находим XHs*YLU = R29*R30 и прибавляем его к
	add r19, r0				;байтам R19:R18:R17 произведения
	adc r20, r1			
	adc r21, r30
	
	mul @3, @0	;находим YHS*XLU = R31*R28 и прибавляем его к
	add r19, r0		;байтам @1:@2:@3 произведения 
	adc r20, r1
	adc r21, r30
  pop r30
  pop @3
  pop @2
  pop @1
  pop @0
.ENDMACRO

.MACRO add32_32 	;!!! можеет быть переполнение
	add @0, @4
	adc @1, @5
	adc @2, @6
	adc @3, @7
.ENDMACRO

.MACRO sub32_32
	sub @0, @4
	sbc @1, @5
	sbc @2, @6
	sbc @3, @7
.ENDMACRO

.MACRO sub16_16
	sub @0, @2
	sbc @1, @3
.ENDMACRO
;======================================================================================================================================
;=================================================== X\Y ==============================================================================
.MACRO ST_Y 
	push r30
	push r31
	ldi ZH, high (sinr_cosp)		; сохраняеем y в ОЗУ
	ldi ZL, low(sinr_cosp)
	st Z+, @0
	st Z+, @1
	st Z+, @2
	st Z, @3
	pop r31
	pop r30
.ENDMACRO

.MACRO FABS_Y
	push r30
	push r31
	ldi ZH, high (fab_y)			; сохраняеем |y| в ОЗУ
	ldi ZL, low (fab_y)
	st Z+, @0
	st Z+, @1
	st Z+, @2
	st Z, @3
	pop r31
	pop r30
.ENDMACRO

.MACRO ST_X
	push r30
	push r31
	ldi ZH, high (cosr_cosp)		; сохраняеем x в ОЗУ
	ldi ZL, low(cosr_cosp)
	st Z+, @0
	st Z+, @1
	st Z+, @2
	st Z, @3
	pop r31
	pop r30
.ENDMACRO

.MACRO LD_X
	push r30
	push r31
	ldi ZH, high (cosr_cosp)		; записываем x из ОЗУ
	ldi ZL, low(cosr_cosp)
	ld @0, Z+
	ld @1, Z+
	ld @2, Z+
	ld @3, Z
	pop r31
	pop r30
.ENDMACRO

.MACRO LD_Y
	push r30
	push r31
	ldi ZH, high (sinr_cosp)		; записываем y из ОЗУ
	ldi ZL, low(sinr_cosp)
	ld @0, Z+
	ld @1, Z+
	ld @2, Z+
	ld @3, Z
	pop r31
	pop r30
.ENDMACRO

.MACRO FABL_Y						;записываем |y| из ОЗУ
	push r30
	push r31
	ldi ZH, high (fab_y)
	ldi ZL, low (fab_y)
	ld @0, Z+
	ld @1, Z+
	ld @2, Z+
	ld @3, Z
	pop r31
	pop r30
.ENDMACRO
;=================================================================================================================
;================================================== PID ==========================================================
.MACRO LD_Time
push r30
push r31
	ldi ZH, high (time)
	ldi ZL, low (time)
	ld @0, Z+
	ld @1, Z
pop r31
pop r30
.ENDMACRO

.MACRO ST_Time
push r30
push r31
	ldi ZH, high (time)
	ldi ZL, low (time)
	st Z+, @0
	st Z, @1
pop r31
pop r30
.ENDMACRO

.MACRO ST_Kp
push r30
push r31
	ldi ZH, high (Kp)
	ldi ZL, low (Kp)
	st Z+, @0
	st Z, @1
pop r31
pop r30
.ENDMACRO

.MACRO ST_Ki
push r30
push r31
	ldi ZH, high (Ki)
	ldi ZL, low (Ki)
	st Z+, @0
	st Z, @1
pop r31
pop r30
.ENDMACRO

.MACRO ST_Kd
push r30
push r31
	ldi ZH, high (Kd)
	ldi ZL, low (Kd)
	st Z+, @0
	st Z, @1
pop r31
pop r30
.ENDMACRO

.MACRO LD_Kp
push r30
push r31
	ldi ZH, high (Kp)
	ldi ZL, low (Kp)
	ld @0, Z+
	ld @1, Z
pop r31
pop r30
.ENDMACRO

.MACRO LD_Ki
push r30
push r31
	ldi ZH, high (Ki)
	ldi ZL, low (Ki)
	ld @0, Z+
	ld @1, Z
pop r31
pop r30
.ENDMACRO

.MACRO LD_Kd
push r30
push r31
	ldi ZH, high (Kd)
	ldi ZL, low (Kd)
	ld @0, Z+
	ld @1, Z
pop r31
pop r30
.ENDMACRO

.MACRO LD_SumErr_R
push r30
push r31
	ldi ZH, high (sum_err_r)
	ldi ZL, low (sum_err_r)
	ld @0, Z+
	ld @1, Z
pop r31
pop r30
.ENDMACRO

.MACRO ST_SumErr_R
push r30
push r31
	ldi ZH, high (sum_err_r)
	ldi ZL, low (sum_err_r)
	st Z+, @0
	st Z, @1
pop r31
pop r30
.ENDMACRO

.MACRO LD_SumErr_P
push r30
push r31
	ldi ZH, high (sum_err_p)
	ldi ZL, low (sum_err_p)
	ld @0, Z+
	ld @1, Z
pop r31
pop r30
.ENDMACRO

.MACRO ST_SumErr_P
push r30
push r31
	ldi ZH, high (sum_err_p)
	ldi ZL, low (sum_err_p)
	st Z+, @0
	st Z, @1
pop r31
pop r30
.ENDMACRO

.MACRO LD_SumErr_Y
push r30
push r31
	ldi ZH, high (sum_err_y)
	ldi ZL, low (sum_err_y)
	ld @0, Z+
	ld @1, Z
pop r31
pop r30
.ENDMACRO

.MACRO ST_SumErr_Y
push r30
push r31
	ldi ZH, high (sum_err_y)
	ldi ZL, low (sum_err_y)
	st Z+, @0
	st Z, @1
pop r31
pop r30
.ENDMACRO

.MACRO LD_ErrorOld_R
push r30
push r31
	ldi ZH, high (error_old_r)
	ldi ZL, low (error_old_r)
	ld @0, Z+
	ld @1, Z
pop r31
pop r30
.ENDMACRO

.MACRO ST_ErrorOld_R
push r30
push r31
	ldi ZH, high (error_old_r)
	ldi ZL, low (error_old_r)
	st Z+, @0
	st Z, @1
pop r31
pop r30
.ENDMACRO

.MACRO LD_ErrorOld_P
push r30
push r31
	ldi ZH, high (error_old_p)
	ldi ZL, low (error_old_p)
	ld @0, Z+
	ld @1, Z
pop r31
pop r30
.ENDMACRO

.MACRO ST_ErrorOld_P
push r30
push r31
	ldi ZH, high (error_old_p)
	ldi ZL, low (error_old_p)
	st Z+, @0
	st Z, @1
pop r31
pop r30
.ENDMACRO

.MACRO LD_ErrorOld_Y
push r30
push r31
	ldi ZH, high (error_old_y)
	ldi ZL, low (error_old_y)
	ld @0, Z+
	ld @1, Z
pop r31
pop r30
.ENDMACRO

.MACRO ST_ErrorOld_Y
push r30
push r31
	ldi ZH, high (error_old_y)
	ldi ZL, low (error_old_y)
	st Z+, @0
	st Z, @1
pop r31
pop r30
.ENDMACRO
;======================================================================================================================================
;=================================================== ROLL\PITCH\YAW ===================================================================

.MACRO ST_K1
push r30
push r31
	ldi ZH, high (K1)
	ldi ZL, low (K1)
	st Z+, @0
	st Z, @1
pop r31
pop r30
.ENDMACRO

.MACRO ST_K2
push r30
push r31
		ldi ZH, high (K2)
		ldi ZL, low (K2)
		st Z+, @0
		st Z, @1
pop r31
pop r30
.ENDMACRO

.MACRO ST_K3
push r30
push r31
	ldi ZH, high (K3)
	ldi ZL, low (K3)
	st Z+, @0
	st Z, @1
pop r31
pop r30
.ENDMACRO

.MACRO LD_K1
push r30
push r31
	ldi ZH, high (K1)
	ldi ZL, low (K1)
	ld @0, Z+
	ld @1, Z
pop r31
pop r30
.ENDMACRO

.MACRO LD_K2
push r30
push r31
	ldi ZH, high (K2)
	ldi ZL, low (K2)
	ld @0, Z+
	ld @1, Z
pop r31
pop r30
.ENDMACRO

.MACRO LD_K3
push r30
push r31
	ldi ZH, high (K3)
	ldi ZL, low (K3)
	ld @0, Z+
	ld @1, Z
pop r31
pop r30
.ENDMACRO

.MACRO LD_ROLL
	push r30
	push r31
	ldi ZH, high (r_roll)
	ldi ZL, low(r_roll)
	ld @0, Z+
	ld @1, Z+
	ld @2, Z+
	ld @3, Z
	pop r31
	pop r30
.ENDMACRO

.MACRO LD_PITCH
	push r30
	push r31
	ldi ZH, high (r_pitch)
	ldi ZL, low(r_pitch)
	ld @0, Z+
	ld @1, Z+
	ld @2, Z+
	ld @3, Z
	pop r31
	pop r30
.ENDMACRO

.MACRO LD_YAW
	push r30
	push r31
	ldi ZH, high (r_yaw)
	ldi ZL, low(r_yaw)
	ld @0, Z+
	ld @1, Z+
	ld @2, Z+
	ld @3, Z
	pop r31
	pop r30
.ENDMACRO

.MACRO ST_ROLL
	push r30
	push r31
	ldi ZH, high (r_roll)		;записываем roll в ОЗУ
	ldi ZL, low(r_roll)
	st Z+, @0
	st Z+, @1
	st Z+, @2
	st Z, @3
	pop r31
	pop r30
.ENDMACRO

.MACRO ST_PITCH
	push r30
	push r31
	ldi ZH, high (r_pitch)
	ldi ZL, low(r_pitch)
	st Z+, @0
	st Z+, @1
	st Z+, @2
	st Z, @3
	pop r31
	pop r30
.ENDMACRO

.MACRO ST_YAW
	push r30
	push r31
	ldi ZH, high (r_yaw)
	ldi ZL, low (r_yaw)
	st Z+, @0
	st Z+, @1
	st Z+, @2
	st Z, @3
	pop r31
	pop r30
.ENDMACRO 

;========================================  STACK 1 = 4 byte ===============================================================	
	.MACRO FINIT			;инициализация работы со стеком => сохр значение sp
	in r16, spl
	in r17, sph
	sts STACk+1, r17
	sts STACk, r16	
.ENDM

.MACRO FREC					;восстанавливаем указатель стека до инициализации
	lds r16, STACk
	lds r17, STACk+1
	out spl, r16
	out sph, r17
.ENDM

.MACRO FLD						;записываем на вершину стека
mov r16, @0
mov r17, @1
mov r18, @2
mov r19, @3
	push r19
	push r18
	push r17
	push r16	
.ENDM
	
.MACRO FSTS0					; сохраняем вершину в ОЗУ
	pop r16
	pop r17
	pop r18
	pop r19
	st @4,  r16
	st @4+1, r17
	st @4+2, r18
	st @4+3, r19
	mov r16, spl
	mov r17, sph
	subi r16, 4
	clr sph
	adc r17, sph
	out sph, r17
	out spl, r16	
.ENDM

.MACRO FLDI							;копируем элемент по индексу в регистры
	ldi r19, @0
	ldi r18, 4
	mul r18, r19
	movw r18, r0
	clr r16
	clr r17
	in r16, 0x3d
	in r17, 0x3e
	movw r0, r16
	add r16, r18
	adc r17, r19
	out sph, r17
	out spl, r16
	pop @1
	pop @2
	pop @3
	pop @4
	out sph, r1
	out spl, r0
.ENDM

.MACRO FSTI						;перезаписываем элемент по индексу
	ldi r19, @0
	ldi r18, 4
	mul r18, r19
	movw r18, r0
	subi r18, -4
	clr r16
	clr r17
	in r16, 0x3d
	in r17, 0x3e
	movw r0, r16
	add r16, r18
	adc r17, r19
	out sph, r17
	out spl, r16
	push @4
	push @3
	push @2
	push @1
	out sph, r1
	out spl, r0
.ENDM

.MACRO FP						;выталкивает (смещает вершину стека) на указанное кол-во элементов 
	ldi r18, @0
	ldi r19, 4
	mul r18, r19
	in r16, 0x3d
	in r17, 0x3e
	
	add r16, r0
	adc r17, r1
	out sph, r17
	out spl, r16
.ENDM
;========================================================================================================================
;============================================== SREG ====================================================================
.MACRO PUSHF 
	push r16
	lds r16, SREG
	push r16
	
.ENDMACRO

.MACRO POPF
	pop r16
	sts SREG, r16
	pop r16
.ENDMACRO
;=================================================================================================================
;============================================== SBUS ======================================================
.MACRO MLSR
	push r31
	clr r31
mls:	cpi r31, @2
		breq mnxt
		lsr @1
		ror @0
		inc r31
		rjmp mls
	mnxt:
	pop r31
.ENDMACRO

.MACRO MLSL
	push r31
	clr r31
slm:	cpi r31, @2
		breq nxtm
		lsl @0
		rol @1
		inc r31
		rjmp slm
	nxtm:
	pop r31
.ENDMACRO

.MACRO MOR
	or @0, @2
	or @1, @3
.ENDMACRO

.MACRO MANDI
	andi @0, @2
	andi @1, @3
.ENDMACRO

.MACRO ST_CH
	push r30
	push r31
		ldi ZH, high(@0)
		ldi ZL, low (@0)
		st Z+, @1
		st Z, @2
	pop r31
	pop r30
.ENDMACRO

.MACRO LD_CH
push r30
push r31
	ldi ZH, high(@0)
	ldi ZL, low (@0)
	ld @1, Z+
	ld @2, Z
pop r31
pop r30
.ENDMACRO
;=================================================================================================================
;=================================================== TWI(I2C) ========================================================
.MACRO I2C_Write
				pushf
				push r17
				push r18
				push r19
				push r20
				push r21
				push r22
				push r30
				push r31
ldi r16, low (@3)
ldi r17, high(@3)

ldi ZH, high(BuffTwiOut)
ldi ZL, low (BuffTwiOut)
st Z+, r16
st Z, r17
ldi ZH, high(BuffTwiOut)
ldi ZL, low (BuffTwiOut)

clr r17
ldi r21, @0					; adr of device
ldi r20, @1					; adr of register
ldi r19, high(@2)
ldi r18, low (@2)				; ??????????? ????, ??????? ????? ?????????

sei
call TWI_Start
op: nop
cpi r17, 1
brne op
cpi r17, 1
brne op
cpi r17, 1
brne op
				pop r31
				pop r30
				pop r22
				pop r21
				pop r20
				pop r19
				pop r18
				pop r17
				popf
.ENDMACRO

.MACRO I2C_WriteP			;load packets => грузим в любой буфер и указываем его как @3
				pushf
				push r17
				push r18
				push r19
				push r20
				push r21
				push r22
				push r30
				push r31
ldi ZH, high(@3)			; @2- счётчик кол-ва загружаемых байт
ldi ZL, low (@3)			; @0- adr of device; @1- adr of register

clr r17
ldi r21, @0					; adr of device
ldi r20, @1					; adr of register
ldi r19, high(@2)
ldi r18, low (@2)				; ??????????? ????, ??????? ????? ?????????

sei
call TWI_Start
op2: nop
cpi r17, 1
brne op2
cpi r17, 1
brne op2
cpi r17, 1
brne op2
				pop r31
				pop r30
				pop r22
				pop r21
				pop r20
				pop r19
				pop r18
				pop r17
				popf
.ENDMACRO

.MACRO I2C_Read
				pushf
				push r17
				push r18
				push r19
				push r20
				push r21
				push r22
				push r30
				push r31
ldi ZH, high(@3)
ldi ZL, low (@3)

clr r22
ldi r17, 1
ldi r21, @0				; adr of device
ldi r20, @1				; adr of register
ldi r19, high(@2)
ldi r18, low (@2)		; count of bytes

R_S:
subi r18, 1
sbci r19, 0

sei
call TWI_Start
op1: nop
cpi r22, 1
brne op1
cpi r22, 1
brne op1
cpi r22, 1
brne op1
				pop r31
				pop r30
				pop r22
				pop r21
				pop r20
				pop r19
				pop r18
				pop r17
				popf
.ENDMACRO
;----------------------------------------------------------------------------
;=================================================================================================================
;=================================================== HLAM ========================================================

.MACRO neg32
push r28
ldi r28, 1
	com @0				;младшие 8-бит
	com @1	
	com @2					;старшие 8-бит
	com @3
	add @0, r28	;начинаем читать с младшей части
	clr r28
	adc @1, r28	;а записываем со старшей
	adc @2, r28
	adc @3, r28
pop r28
.ENDMACRO

.MACRO neg16
push r28
ldi r28, 1
	com @0
	com @1
	add @0, r28
	clr r28
	adc @1, r28
pop r28
.ENDMACRO

.MACRO cpi_8
	cpi @0, 0
	brne ext
	cpi @1, 0
	brne ext
	cpi @2, 0
	brne ext
	cpi @3, 0
	brne ext
	cpi @4, 0
	brne ext
	cpi @5, 0
	brne ext
	cpi @6, 0
	brne ext
	cpi @7, 0
	brne ext
	ldi r16, 1
	ext:
	nop
.ENDMACRO

.MACRO cpi_4
	cpi @0, 0
	brne ext
	cpi @1, 0
	brne ext
	cpi @2, 0
	brne ext
	cpi @3, 0
	brne ext
	ldi r15, 1
	ext:
	nop
.ENDMACRO
;=====================================================================TIMERS======================================
.MACRO	PWM2_OFF
	push r16
		lds r16, TCCR2A
		andi r16, 0b11111100
		sts TCCR2A, r16
		lds r16, TCCR2B
		andi r16, 0b11110111
		sts TCCR2B, r16
	pop r16
.ENDMACRO

.MACRO	PWM1_OFF
	push r16
		lds r16, TCCR1A
		andi r16, 0b11111100
		sts TCCR1A, r16
		lds r16, TCCR1B
		andi r16, 0b11100111
		sts TCCR1B, r16
	pop r16
.ENDMACRO

.MACRO PWM2_ON
	push r16
		lds r16, TCCR2A
		ori r16, 0b00000011
		sts TCCR2A, r16
		lds r16, TCCR2B
		andi r16, 0b11110111
		sts TCCR2B, r16
	pop r16
.ENDMACRO

.MACRO PWM1_ON
	push r16
		lds r16, TCCR1A
		ori r16, 0b00000010
		sts TCCR1A, r16
		lds r16, TCCR1B
		ori r16, 0b00001000
		sts TCCR1B, r16
	pop r16
.ENDMACRO