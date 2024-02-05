;-----------------------------------------------
; Universidad del Valle de Guatemala
; IE2023: Programacion de Microcontroladores
; Contador_Timer0.asm
; Autor: Ian Anleu Rivera
; Proyecto: Prelab 2
; Hardware: ATMEGA328P
; Creado: 04/02/2024
; Ultima modificacion: 05/02/2024
;-----------------------------------------------

.include "M328PDEF.INC" ; Nombres de Registros
.cseg

.org 0x00 ; Vector Reset

;-----------------------------------------------
; Stack Pointer

	LDI R16, LOW(RAMEND) ; Funcion LOW da la parte baja
	OUT SPL, R16
	LDI R16, HIGH(RAMEND) ; Funcion HIGH da la parte alta
	OUT SPH, R16

;-----------------------------------------------
; Configuracion

Setup:
	; Clock en 2MHz
	LDI R16, 0b1000_0000 
	STS CLKPR, R16 ; Habilitar prescaler
	LDI R16, 0b0000_0011
	STS CLKPR, R16  ; 0011 es Divisor entre 8 para 2MHz	
	
	; Timer0
	CALL Setup_Timer ; Llama a inicializar el Timer0

	; Entradas 

	; Salidas
	LDI R16, 0xFF
	OUT DDRD, R16 ; Configura PORTD a Salida
	LDI R16, 0x00 
	STS UCSR0B, R16 ; Deshabilita USART

	; Registros adicionales
	LDI R17, 0x00 ; R17 será el contador de 4 bits

;-----------------------------------------------
; LOOP de flash memory

Loop:
	; Incremento del contador con timer0
	IN R16, TIFR0 ; Cargar valor de Timer 
	CPI R16, (1<<TOV0) ; Se compara la posicion de bandera de overflow en el timer
	BRNE Loop 
	
	; Contador Binario 4 bits
	INC R17 ; Al momento en que cambia, incremento el contador R17
	ANDI R17, 0x0F ; Y limpio el nibble más alto
	OUT PORTD, R17 ; Despliego el contador en PORTD
	; Reset de Timer0
	CALL Res_Timer
	SBI TIFR0, TOV0 ; Para borrar bandera, set bandera en TIFR0
	
	RJMP Loop ; Vuelve a Loop

;-----------------------------------------------
; Subrutinas
;-----------------------------------------------

Setup_Timer:
	; Como se usa el modo normal, no se necesita configurar TCCR0A
	LDI R16, 0b0000_0101 ; Prescaler de timer0 en 1024
	OUT TCCR0B, R16
Res_Timer:
	LDI R16, 61 ; Desbordamiento (TCNT0) segun calculadora
	OUT TCNT0, R16 ; Aprox 99.84ms
	RET

;-----------------------------------------------
