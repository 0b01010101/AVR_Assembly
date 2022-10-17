.dseg
.equ MAXBUFF_IN = 25

Buff_Buff:		.byte MAXBUFF_IN
IN_BUFF:		.byte MAXBUFF_IN
IN_PE:			.byte 1
IN_PS:			.byte 1
IN_PF:			.byte 1
Count:			.byte 1
CountBuff:		.byte 1
;====================================1K-16K=============
Adr:			.byte 2
K0:				.byte 2
K1:				.byte 2
K2:				.byte 2
K3:				.byte 2
K4:				.byte 2
K5:				.byte 2
K6:				.byte 2
K7:				.byte 2
K8:				.byte 2
K9:				.byte 2
K10:			.byte 2
K11:			.byte 2
K12:			.byte 2
K13:			.byte 2
K14:			.byte 2
K15:			.byte 2
FlagsSB:		.byte 1
EndByteSB:		.byte 1

.cseg

TX_OK:
cli
      pushf
      push r25
brv:
lds r16, UCSR0A
sbrs r17, 5
rjmp brv
      
lds r25, CountBuff
ldi ZH, high(K0)
ldi ZL, low (K0)
add ZL, r25
clr r16
adc ZH, r16

inc r25
cpi r25, 26
breq VixOut
ld r16, Z
sts UDR0, r16

VixOut:
sts CountBuff, r25
      pop r25
      popf
sei
reti

	
RX_OK:
cli			
			pushf
			push r30
			push r31
			push r17
		
		cpcp:	
			lds r17, UCSR0A
			sbrs r17, 7
			;sbrs UCSR0A, 7
			rjmp cpcp
		bgn:
			ldi ZL, low(IN_BUFF)		; ????? ????? ?????? ???????
			ldi ZH, high(IN_BUFF)
			lds r17, CountBuff
			
			add ZL, r17
			clr r16
			adc ZH, r16
			lds r16, UDR0					; ???????? ??????
			st Z, r16					; ????????? ?? ? ??????
			
			inc r17
			cpi r17, 25
			brne RX_End
			
			ldi r17, 2			;?????? ??? ??????????
			sts IN_PF, r17
			clr r17
RX_End:		
			sts CountBuff, r17
			
			pop r17
			pop r31
			pop r30
			popf
sei
reti

buff_pop:			ldi YL, low(Buff_Buff)	; ????? ????? ?????? ???????
				ldi YH, high(Buff_Buff)
				lds r16, IN_PE			; ????? ???????? ????? ??????
				lds r18, IN_PS			; ????? ???????? ????? ??????
				lds r19, IN_PF
				
				cpi r19, 2				; ???? ?????? ??????????, ?? ????????? ??????
				breq NeedPop			; ????? ????????? ?????. ??? ???? ??????.
				
				cp r18, r16				; ????????? ?????? ?????? ????????? ???????
				brne NeedPop			; ???! ?????? ?? ????. ???????? ??????
				
				ldi r19, 1				; ??? ?????? - ?????? ??????!
				sts IN_PF, r19			;??ff?? ??????
				rjmp RX_Exit			; ???????
				
NeedPop:			clr r19
				sts IN_PF, r19			; ?????????? ???? ????????????
				
				add YL, r18				; ????????? ?????? ?? ?????????
				clr r17					; ???????? ????? ????? ??????
				adc YH, r17		
				
				ld r17, Y				; ????? ???? ?? ???????
				
				inc r18					; ??????????? ???????? ????????? ??????
				
				cpi r18, MAXBUFF_IN		; ???????? ????? ???????
				brne RX_Exit			; ???? 
				clr r18					; ??? ??????????, ??????????? ?? 0
				
RX_Exit:		sts IN_PS, r18			; ????????? ?????????
ret	


EHO:
cli
ldi YH, high(Buff_Buff)
ldi YL, low (Buff_Buff)
ldi ZH, high(IN_BUFF)
ldi ZL, low (IN_BUFF)
clr r17
cop:
   ld r16, Z+
   st Y+, r16
   inc r17
   cpi r17, 25
   brne cop
sei
;===						;============== Adr ===============
rcall buff_pop				;1-byte in r17
ldi ZH, high(Adr)
ldi ZL, low (Adr)
st Z, r17			

;===						;============== 0K ================ sbus_ch[ 0] = ((int16_t)buf[ 2] >> 0 | ((int16_t)buf[ 3] << 8 )) & 0x07FF;
rcall buff_pop				;2-byte in r17
mov r22, r17				
clr r23

rcall buff_pop   ;- ?? 3-?? ??????????? ??????      3-byte
mov r20, r17
clr r18
mlsl r17, r18, 8
mor r22, r23, r17, r18
mandi r22, r23, 0xFF, 0x07

ST_CH K0, r22, r23

;===						;================ 1k ============== *** sbus_ch[ 1] = ((int16_t)buf[ 3] >> 3 | ((int16_t)buf[ 4] << 5 )) & 0x07FF;	
	clr r21					;2-byte (r20:r21)
	rcall buff_pop 				;3-byte in r17
	mov r22, r17
	clr r23
	
	movw r24, r22				;4-byte
	mlsr r20, r21, 3
	mlsl r22, r23, 5
	mor r20, r21, r22, r23
	mandi r20, r21, 0xFF, 0x07
	
	ST_CH K1, r20, r21

;===						;================== 2k ================ sbus_ch[ 2] = ((int16_t)buf[ 4] >> 6 | ((int16_t)buf[ 5] << 2 )  | (int16_t)buf[ 6] << 10 ) & 0x07FF;
	rcall buff_pop			;5-byte
	mov r20, r17
	clr r21
	rcall buff_pop			;6-byte
	mov r22, r17
	clr r23

	mlsr r24, r25, 6		;4-byte
	mlsl r20, r21, 2
	mor r20, r21, r24, r25
	
	movw r24, r22			;6-byte
	mlsl r22, r23, 10
	mor r20, r21, r22, r23
	mandi  r20, r21, 0xFF, 0x07
	
	ST_CH K2, r20, r21
	
;===						;==================== 3k ================= sbus_ch[ 3] = ((int16_t)buf[ 6] >> 1 | ((int16_t)buf[ 7] << 7 )) & 0x07FF;
	rcall buff_pop			;7-byte
	mov r22, r17
	clr r23
	
	movw r20, r22
	mlsr r24, r25, 1		;6-byte
	mlsl r22, r23, 7		;7-byte
	mor  r24, r25, r22, r23
	mandi r24, r25, 0xFF, 0x07

	ST_CH K3, r24, r25
	
;===						;==================== 4k ================= sbus_ch[ 4] = ((int16_t)buf[ 7] >> 4 | ((int16_t)buf[ 8] << 4 )) & 0x07FF;
	rcall buff_pop 
	mov r22, r17		;8-byte
	clr r23

	movw r24, r22
	mlsr r20, r21, 4	;7-byte
	mlsl r22, r23, 4
	mor r20, r21, r22, r23
	mandi r20, r21, 0xFF, 0x07

	ST_CH K4, r20, r21
	
;===						;==================== 5k ================= sbus_ch[ 5] = ((int16_t)buf[ 8] >> 7 | ((int16_t)buf[ 9] << 1 )  | (int16_t)buf[10] <<  9 ) & 0x07FF;
	rcall buff_pop
	mov r20, r17		;9-byte
	clr r21
	rcall buff_pop
	mov r22, r17		;10-byte
	clr r23		
	
	mlsr r24, r25, 7
	mlsl r20, r21, 1
	mor r20, r21, r24, r25
	
	movw r24, r22		;10-byte
	mlsl r22, r23, 9
	mor r20, r21, r22, r23
	mandi r20, r21, 0xFF, 0x07
	
	ST_CH K5, r20, r21
	
;===						;==================== 6k ================= sbus_ch[ 6] = ((int16_t)buf[10] >> 2 | ((int16_t)buf[11] << 6 )) & 0x07FF;
	rcall buff_pop
	mov r22, r17		;11-byte
	clr r23

	movw r20, r22		;11-byte
	mlsr r24, r25, 2
	mlsl r22, r23, 6
	mor r24, r25, r22, r23
	mandi r24, r25, 0xFF, 0x07

	ST_CH K6, r24, r25

;===						;==================== 7k ================= sbus_ch[ 7] = ((int16_t)buf[11] >> 5 | ((int16_t)buf[12] << 3 )) & 0x07FF;
	rcall buff_pop
	mov r24, r17	;12-byte
	clr r25

	mlsr r20, r21, 5	;11-byte
	mlsl r24, r25, 3	;12-byte
	mor r20, r21, r24, r25
	mandi r20, r21, 0xFF, 0x07

	ST_CH K7, r20, r21

;===						;==================== 8k ================= ????? ????? ??? ? 1k ?? 7k
	rcall buff_pop				;2-byte in r17
	mov r22, r17				
	clr r23

	rcall buff_pop   ;- ?? 3-?? ??????????? ??????      3-byte
	mov r20, r17
	clr r18
	mlsl r17, r18, 8
	mor r22, r23, r17, r18
	mandi r22, r23, 0xFF, 0x07

	ST_CH K8, r22, r23
	
;===						;==================== 9k =================
	clr r21					;2-byte (r20:r21)
	rcall buff_pop 				;3-byte in r17
	mov r22, r17
	clr r23
	
	movw r24, r22				;4-byte
	mlsr r20, r21, 3
	mlsl r22, r23, 5
	mor r20, r21, r22, r23
	mandi r20, r21, 0xFF, 0x07
	
	ST_CH K9, r20, r21

;===						;==================== 10k =================
	rcall buff_pop			;5-byte
	mov r20, r17
	clr r21
	rcall buff_pop			;6-byte
	mov r22, r17
	clr r23

	mlsr r24, r25, 6		;4-byte
	mlsl r20, r21, 2
	mor r20, r21, r24, r25
	
	movw r24, r22			;6-byte
	mlsl r22, r23, 10
	mor r20, r21, r22, r23
	mandi  r20, r21, 0xFF, 0x07
	
	ST_CH K10, r20, r21

;===						;==================== 11k =================
	rcall buff_pop			;7-byte
	mov r22, r17
	clr r23
	
	movw r20, r22
	mlsr r24, r25, 1		;6-byte
	mlsl r22, r23, 7		;7-byte
	mor  r24, r25, r22, r23
	mandi r24, r25, 0xFF, 0x07

	ST_CH K11, r24, r25

;===						;==================== 12k =================
	rcall buff_pop 
	mov r22, r17		;8-byte
	clr r23

	movw r24, r22
	mlsr r20, r21, 4	;7-byte
	mlsl r22, r23, 4
	mor r20, r21, r22, r23
	mandi r20, r21, 0xFF, 0x07

	ST_CH K12, r20, r21

;===						;==================== 13k =================
	rcall buff_pop
	mov r20, r17		;9-byte
	clr r21
	rcall buff_pop
	mov r22, r17		;10-byte
	clr r23		
	
	mlsr r24, r25, 7
	mlsl r20, r21, 1
	mor r20, r21, r24, r25
	
	movw r24, r22		;10-byte
	mlsl r22, r23, 9
	mor r20, r21, r22, r23
	mandi r20, r21, 0xFF, 0x07
	
	ST_CH K13, r20, r21

;===						;==================== 14k =================
	rcall buff_pop
	mov r22, r17		;11-byte
	clr r23

	movw r20, r22		;11-byte
	mlsr r24, r25, 2
	mlsl r22, r23, 6
	mor r24, r25, r22, r23
	mandi r24, r25, 0xFF, 0x07

	ST_CH K14, r24, r25

;===						;==================== 15k =================
	rcall buff_pop
	mov r24, r17		;12-byte
	clr r25

	mlsr r20, r21, 5	;11-byte
	mlsl r24, r25, 3	;12-byte
	mor r20, r21, r24, r25
	mandi r20, r21, 0xFF, 0x07

	ST_CH K15, r20, r21

;===						;====================== FlagsSB ===============
rcall buff_pop				
ldi ZH, high(FlagsSB)				;24-byte
ldi ZL, low (FlagsSB)
st Z, r17

;=== 						;====================== EndByteSB ==============
rcall buff_pop				
ldi ZH, high(EndByteSB)
ldi ZL, low(EndByteSB)
st Z, r17

ret

TX_Run0:
ldi r25, 1
sts CountBuff, r25
lds r16, K0
sts UDR0, r16
ret

TX_Run1:
ldi r25, 2
sts Count, r25
lds r16, K1
sts UDR0, r16
ret

TX_Run2:
ldi r25, 3
sts Count, r25
lds r16, K2
sts UDR0, r16
ret

TX_Run3:
ldi r25, 4
sts Count, r25
lds r16, K3
sts UDR0, r16
ret

TX_Run4:
ldi r25, 5
sts Count, r25
lds r16, K4
sts UDR0, r16
ret

TX_Run5:
ldi r25, 6
sts Count, r25
lds r16, K5
sts UDR0, r16
ret

TX_Run6:
ldi r25, 7
sts Count, r25
lds r16, K6
sts UDR0, r16
ret

			.eseg
			.cseg