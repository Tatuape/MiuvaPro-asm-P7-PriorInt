; ***********************************************************
;   INTESC electronics & embedded
;
;   Curso básico de microcontroladores en ensamblador	    
;
;   Práctica 7: Prioridades de interrupción
;   Objetivo: Conocer la configuración y uso de las interrupciones
;   y sus prioridades.
;   El ADC genera una interrupción de baja prioridad cada que 
;   la conversión está lista, y una interrupción de alta prioridad
;   es ejectuada cada segundo por el timer0 congelando el sistema
;   durante 1 segundo.
;
;   Fecha: 05/Jun/16
;   Creado por: Daniel Hernández Rodríguez
; ************************************************************

LIST    P = 18F87J50	;PIC a utilizar
INCLUDE <P18F87J50.INC>
    
;************************************************************
;Configuración de fusibles
CONFIG FOSC = HS    ;Oscilador de 8MHz
CONFIG  DEBUG = OFF
CONFIG  XINST = OFF
    
CBLOCK 0x000
    contador
    adc_result
    ret1
    ret2
    ret3
ENDC
    
ORG 0x0000
    goto    INICIO
    
ORG 0x0008
    goto    ISR_H
    
ORG 0x0018
    goto    ISR_L
    
    
   INICIO
   movlw    0x00
   movwf    TRISJ   ;Puerto B como salida
	;Configuración del timer0
   movlw    0x84
   movwf    T0CON   ;Configura timer0, prescaler, 16 bits
   bsf	    INTCON,7;Habilitar interrupciones de alta prioridad
   bsf	    INTCON,5;Habilitar interrupciones por desborde
   movlw    0x00
   movwf    adc_result	;Reinicio adc_result
   
   ;Inicialización del ADC
	movlw	0x00
	movwf	TRISF	;Puerto F como salida (Paso de MiuvaPro)
	movlw	0xFF
	movwf	TRISA	;Puerto A como entrada
	movlw	0xFE
	movwf	ANCON0	;Configuramos AN0 como analógico
	movlw	0xFF
	movwf	ANCON1	;Configuramos puertos digitales
	movlw	0x00
	movwf	ADCON0	;Configuración del ADC
	movlw	0x08
	movwf	ADCON1	;Configuración del ADC
	bsf		ADCON0,ADON	;ADC ENABLED
    ;INTERRUPCIONES DEL ADC
	bcf		PIR1,ADIF		;Bit bandera de AD
	bsf		PIE1,ADIE		;Bit de enable de AD
	bcf		IPR1,ADIP		;Bit de prioridad de AD
	bsf		INTCON,6		;Habilitar interrupciones baja prioridad
	bsf		ADCON0,GO_DONE
	bsf		RCON,IPEN		;Habilita niveles de prioridad en las interrupciones

    
   BUCLE
   goto BUCLE
    
    ISR_H
    call    RETARDO1s		;Congelo el sistema 1 segundo
    movff   adc_result,PORTJ	;Muestro en los leds el valor del ADC guardado
    bcf	    INTCON,TMR0IF	;Limpia la bandera del timer
    bsf	    INTCON,7		;Habilito interrupciones alta prioridad
    return			;Regreso
    
    ISR_L
    bcf	    PIR1,ADIF	    ;Limpia la bandera del ADC
    bsf	    INTCON,6	    ;Habilita interrupciones baja prioridad
    movff   ADRESH,adc_result	   ;Leo el valor del ADC
    movff   adc_result,PORTJ	;Muestro en el puerto J el valor del ADC
    bsf	    ADCON0,GO_DONE  ;Habilito conversión del ADC
    return
    
    
 RETARDO1s	;Se crea un retardo de 1 segundo
	movlw 	D'255'
	movwf 	ret1
	movlw 	D'255'
	movwf	ret2
	movlw	D'11'
	movwf	ret3
Ret1s
	decfsz	ret1, F
	goto	Ret1s
	decfsz	ret2, F
	goto	Ret1s
	decfsz	ret3, F
	goto	Ret1s
	return

    END