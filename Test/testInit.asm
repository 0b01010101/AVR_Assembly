;================================================= INT0 INIT ========================================
ldi r16, 0b00000001		;ISC01:ISC0 = 01 - любое изменение уровня на входе INT1
sts EICRA, r16
out EIMSK, r16			;Бит INT0 (0) разрешает внешние прерывания INT0 при записи в него 1

;================================================= UART INIT ========================================
Uart_init:

.equ Bitrate = 9600 
.equ BAUD_UART = 1000000 / (16 * Bitrate) - 1	;16000000 / (16 * Bitrate) - 1 !!!!  1??? -?????????? RC, 16??? -??????? ?????????

ldi r16, high(BAUD_UART)
sts UBRR0H, r16
ldi r16, low(BAUD_UART)
sts UBRR0L, r16

clr r16
sts UCSR0A, r16
ldi r16, 0b11011000	;(1<<RXEN0)| (1<<TXEN0)| (1<<RXCIE0)| (1<<TXCIE0)| (0<<UDRIE0)
sts UCSR0B, r16
ldi r16, 0b00000110		;(0<<UMSEL01)| (1<<UCSZ00)| (1<<UCSZ01)| (0<<UCPOL0) 
sts UCSR0C, r16 

clr r16
sts IN_PS,R16				
sts IN_PE,R16
sts IN_PF, r16

;====================================================  PWM INIT ===================================
; режим ШИМ FastPWM
;Частота = Частота_мк / (Предделитель * Верхний_предел)
; счётчик TIMER "TCNT" весь переод ШИМ будет 488 Hz = 2.08 ms = 100% мощность двигателя
; OCRx - счётчик сравнения ШИМ (ставим в 255 (timer_2) и 511 (timer_1) , если двигатель на 100%), будем как-то заносить проценты мощности двигателя(ответ-подпрограмма OCRx)
PWM_init:
ldi r16, 0b01101000
out DDRD, r16
ldi r16, 0b00001110
out DDRB, r16

;//-----------------------FastPWM
;Timer1-mode6,presc=64 | Timer2-mode3, presc=128 => Freq = 490 Hg

clr r16
sts TCCR2A, r16
sts TCCR2B, r16
sts TCNT2, r16

sts TCCR1A, r16
sts TCCR1B, r16
sts TCNT1H, r16
sts TCNT1L, r16

ldi r16, 0b10100011	;(1 << WGM00) | (1 << WGM01) | (1 << COM0A1) | (1 << COM0B1)
;out TCCR0A, r16
sts TCCR2A, r16		;(1 << WGM20) | (1 << WGM21) | (1 << COM2A1) | (1 << COM2B1) 

ldi r16, 0b10100010
sts TCCR1A, r16		;(1 << WGM11) | (1 << COM1A1) | (1 << COM1B1)

ldi r16, 0b00001100	;(1 << CS02) | (1 << WGM02) 
;out TCCR0B, r16
ldi r16, 0b00000101	;(0 << WGM22) | (1 << CS22)|(1 << CS20)
sts TCCR2B, r16

ldi r16, 0b00001011	;(1 << WGM12) | (1 << CS11) | (1 << CS10)
sts TCCR1B, r16

;================================================ I2C INIT =====================================================
I2C_init:
			.equ FREQ = 16000000		;??????? ?????? ????
			.equ FreqSCL = 400000	; max ??????? ?????? TWI
			.equ FreqTWBR = ((FREQ/FreqSCL)-16)/2	; registr TWPS == 0
			.equ adrMPU = 0b10101110 ;AD0=0
			.equ LC64 = 0b10100000
			
ldi r16, FreqTWBR
sts TWBR, r16

;============================================== PID INIT =========================================================
			.equ P = 0x0019
			.equ I = 0x0010
			.equ D = 0x0032
			.equ per_reg = 100 ;from 0.01 sec to 1 sec

ldi r17, high(per_reg)
ldi r16, low (per_reg)
ST_Time r16, r17			

ldi r17, high(Kp)
ldi r16, low (Kp)
ST_Kp r16, r17

ldi r17, high(Ki)
ldi r17, low (Ki)
ST_Ki r16, r17

ldi r17, high(Kd)
ldi r16, low (Kd)
ST_Kd r16, r17

clr r16
clr  r17
ST_ErrorOld_R r16, r17
ST_ErrorOld_P r16, r17
ST_ErrorOld_Y r16, r17
ST_SumErr_P r16, r17
ST_SumErr_R r16, r17
ST_SumErr_Y r16, r17

;========================================================== TIMER0 INIT =================================
clr r16
out TCCR0A, r16
out TCCR0B, r16
out TCNT0, r16

ldi r16, 0b00000001		; 1 << OCIE0
sts TIMSK0, r16
ldi r16, 0b00000101		;(1 << CS02)|(1 << CS00)=> presc == 1024
sts TCCR0B, r16
;-----------------------------------------------------------------------------------------------------------------
sei