
; PIC18F4550 Configuration Bit Settings

; Assembly source line config statements

#include "p18f4550.inc"

; CONFIG1L
  CONFIG  PLLDIV = 1            ; PLL Prescaler Selection bits (No prescale (4 MHz oscillator input drives PLL directly))
  CONFIG  CPUDIV = OSC1_PLL2    ; System Clock Postscaler Selection bits ([Primary Oscillator Src: /1][96 MHz PLL Src: /2])
  CONFIG  USBDIV = 1            ; USB Clock Selection bit (used in Full-Speed USB mode only; UCFG:FSEN = 1) (USB clock source comes directly from the primary oscillator block with no postscale)

; CONFIG1H
  CONFIG  FOSC = INTOSCIO_EC    ; Oscillator Selection bits (Internal oscillator, port function on RA6, EC used by USB (INTIO))
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enable bit (Fail-Safe Clock Monitor disabled)
  CONFIG  IESO = OFF            ; Internal/External Oscillator Switchover bit (Oscillator Switchover mode disabled)

; CONFIG2L
  CONFIG  PWRT = OFF            ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  BOR = ON              ; Brown-out Reset Enable bits (Brown-out Reset enabled in hardware only (SBOREN is disabled))
  CONFIG  BORV = 3              ; Brown-out Reset Voltage bits (Minimum setting 2.05V)
  CONFIG  VREGEN = OFF          ; USB Voltage Regulator Enable bit (USB voltage regulator disabled)

; CONFIG2H
  CONFIG  WDT = ON              ; Watchdog Timer Enable bit (WDT enabled)
  CONFIG  WDTPS = 32768         ; Watchdog Timer Postscale Select bits (1:32768)

; CONFIG3H
  CONFIG  CCP2MX = ON           ; CCP2 MUX bit (CCP2 input/output is multiplexed with RC1)
  CONFIG  PBADEN = ON           ; PORTB A/D Enable bit (PORTB<4:0> pins are configured as analog input channels on Reset)
  CONFIG  LPT1OSC = OFF         ; Low-Power Timer 1 Oscillator Enable bit (Timer1 configured for higher power operation)
  CONFIG  MCLRE = ON            ; MCLR Pin Enable bit (MCLR pin enabled; RE3 input pin disabled)

; CONFIG4L
  CONFIG  STVREN = ON           ; Stack Full/Underflow Reset Enable bit (Stack full/underflow will cause Reset)
  CONFIG  LVP = ON              ; Single-Supply ICSP Enable bit (Single-Supply ICSP enabled)
  CONFIG  ICPRT = OFF           ; Dedicated In-Circuit Debug/Programming Port (ICPORT) Enable bit (ICPORT disabled)
  CONFIG  XINST = OFF           ; Extended Instruction Set Enable bit (Instruction set extension and Indexed Addressing mode disabled (Legacy mode))

; CONFIG5L
  CONFIG  CP0 = OFF             ; Code Protection bit (Block 0 (000800-001FFFh) is not code-protected)
  CONFIG  CP1 = OFF             ; Code Protection bit (Block 1 (002000-003FFFh) is not code-protected)
  CONFIG  CP2 = OFF             ; Code Protection bit (Block 2 (004000-005FFFh) is not code-protected)
  CONFIG  CP3 = OFF             ; Code Protection bit (Block 3 (006000-007FFFh) is not code-protected)

; CONFIG5H
  CONFIG  CPB = OFF             ; Boot Block Code Protection bit (Boot block (000000-0007FFh) is not code-protected)
  CONFIG  CPD = OFF             ; Data EEPROM Code Protection bit (Data EEPROM is not code-protected)

; CONFIG6L
  CONFIG  WRT0 = OFF            ; Write Protection bit (Block 0 (000800-001FFFh) is not write-protected)
  CONFIG  WRT1 = OFF            ; Write Protection bit (Block 1 (002000-003FFFh) is not write-protected)
  CONFIG  WRT2 = OFF            ; Write Protection bit (Block 2 (004000-005FFFh) is not write-protected)
  CONFIG  WRT3 = OFF            ; Write Protection bit (Block 3 (006000-007FFFh) is not write-protected)

; CONFIG6H
  CONFIG  WRTC = OFF            ; Configuration Register Write Protection bit (Configuration registers (300000-3000FFh) are not write-protected)
  CONFIG  WRTB = OFF            ; Boot Block Write Protection bit (Boot block (000000-0007FFh) is not write-protected)
  CONFIG  WRTD = OFF            ; Data EEPROM Write Protection bit (Data EEPROM is not write-protected)

; CONFIG7L
  CONFIG  EBTR0 = OFF           ; Table Read Protection bit (Block 0 (000800-001FFFh) is not protected from table reads executed in other blocks)
  CONFIG  EBTR1 = OFF           ; Table Read Protection bit (Block 1 (002000-003FFFh) is not protected from table reads executed in other blocks)
  CONFIG  EBTR2 = OFF           ; Table Read Protection bit (Block 2 (004000-005FFFh) is not protected from table reads executed in other blocks)
  CONFIG  EBTR3 = OFF           ; Table Read Protection bit (Block 3 (006000-007FFFh) is not protected from table reads executed in other blocks)

; CONFIG7H
  CONFIG  EBTRB = OFF           ; Boot Block Table Read Protection bit (Boot block (000000-0007FFh) is not protected from table reads executed in other blocks)

;**************** Definitions*********************************
DATA_A EQU 0x01				;Reservar el espacio para el primer operando
DATA_B EQU 0x02				;Reservar el espacio para el segundo operando
TEMP EQU 0x03				;Reservar un registro temporal

CONSTANT MASK_LOWER = b'00001111'	;Declaración de la máscara para obtener los 4 bits menos significativos
CONSTANT MASK_UPPER = b'11110000'	;Declaración de la máscara para obtener los 4 bits más significativos
;*************************************************

    ORG 0x000				;vector de reset
    GOTO main				;goes to main program

init: 
    MOVLW	0x0F			;Puertos A, B y E pueden ser digitales (I/O) o analógicos (sólo I)
    MOVWF	ADCON1			;PORTA es analógico por default y estas dos líneas lo obligan a ser digital
    
    SETF	TRISB			;PORTC es entrada
    CLRF	TRISD			;PORTB es salida
    CLRF	PORTD			;Limpiar el puerto de salida
    return				;leaving initialization subroutine

main: call init				;Llamar a inicialización de puertos

loop:
    MOVF PORTB, W			;Mover la info del PORTB a WREG
    MOVWF TEMP				;Mover la info del WREG a TEMP
    
    ANDLW MASK_LOWER			;Operación AND entre la máscara de bits menos significativos y WREG
    MOVWF DATA_A			;Mover la info de WREG (resultado del AND) a DATA_A (primer operando)
    
    MOVF TEMP, W			;Mover la info del TEMP a WREG (original del PORTB)
    ANDLW MASK_UPPER			;Operación AND entre la máscara de bits más significativos y WREG
    MOVWF DATA_B			;Mover la info de WREG (resultado del AND) a DATA_B (segundo operando)
    SWAPF DATA_B, F			;Cambiar los nibbles de DATA_B (los 4 bits más significativos se vuelven los menos)
    
    MOVF DATA_A, W			;Mover la info del DATA_A a WREG
    ADDWF DATA_B, W			;Operación de suma entre DATA_A y DATA_B
    MOVWF TEMP				;Guardar el resultado de la suma en TEMP (ya que no se va a usar más la info de PORTB)
    
    BZ CASE0				;Si la suma es cero, brincar a esa etiqueta
       
    SUBLW 0x01				;Operación L-WREG (la literal 0x01 menos el resultado de la suma)
    BZ CASE1				;Si el resultado es cero, la suma es igual a la literal, entonces brinca a esa etiqueta
    
    MOVF TEMP, W			;Mover la info del TEMP (resultado de la suma A+B) a WREG
    SUBLW 0x02				;Operación L-WREG (la literal 0x02 menos el resultado de la suma)
    BZ CASE2				;Si el resultado es cero, la suma es igual a la literal, entonces brinca a esa etiqueta
    
    MOVF TEMP, W			;Mismo caso, hasta llegar a la literal 0x0F...
    SUBLW 0x03
    BZ CASE3
    
    MOVF TEMP, W
    SUBLW 0x04
    BZ CASE4
    
    MOVF TEMP, W
    SUBLW 0x05
    BZ CASE5
    
    MOVF TEMP, W
    SUBLW 0x06
    BZ CASE6
    
    MOVF TEMP, W
    SUBLW 0x07
    BZ CASE7
    
    MOVF TEMP, W
    SUBLW 0x08
    BZ CASE8
    
    MOVF TEMP, W
    SUBLW 0x09
    BZ CASE9
    
    MOVF TEMP, W
    SUBLW 0x0A
    BZ CASEA
    
    MOVF TEMP, W
    SUBLW 0x0B
    BZ CASEB
    
    MOVF TEMP, W
    SUBLW 0x0C
    BZ CASEC
    
    MOVF TEMP, W
    SUBLW 0x0D
    BZ CASED
    
    MOVF TEMP, W
    SUBLW 0x0E
    BZ CASEE
    
    MOVF TEMP, W
    SUBLW 0x0F
    BZ CASEF
    
    BRA DEFAULT				;Si no se cumple ninguna condición, quiere decir que el resultado de la suma no es un valor del 0 a F,
					; así que no se representará en el display de 7 segmentos y brinca incondicionalmente al caso default.
    
CASE0:					;Si el resultado es cero,
    MOVLW b'00111111'			;Se mueve a WREG una literal que represente el número en el display de 7 segmentos
    MOVWF PORTD				;Se mueve esta información a PORTD (puerto de salida al que estará conectado el display)
    GOTO loop				;Vuelve a realizar el programa desde la obtención de los operandos del PORTB (así el programa estará siempre activo)
    
CASE1:					;Si el resultado es 1,
    MOVLW b'00000110'			;Se mueve a WREG una literal que represente el número en el display de 7 segmentos
    MOVWF PORTD				; el orden de la salida y los segmentos debe ser: 'gfedcba', si se manda señal en ALTO, el segmento se enciende, en BAJO permanece apagado.
    GOTO loop				;Así se continua para todos los casos hasta F...
    
CASE2:
    MOVLW b'01011011'
    MOVWF PORTD
    GOTO loop
    
CASE3:
    MOVLW b'01001111'
    MOVWF PORTD
    GOTO loop
    
CASE4:
    MOVLW b'01100110'
    MOVWF PORTD
    GOTO loop
    
CASE5:
    MOVLW b'01101101'
    MOVWF PORTD
    GOTO loop
    
CASE6:
    MOVLW b'01111101'
    MOVWF PORTD
    GOTO loop
    
CASE7:
    MOVLW b'00000111'
    MOVWF PORTD
    GOTO loop
    
CASE8:
    MOVLW b'01111111'
    MOVWF PORTD
    GOTO loop
    
CASE9:
    MOVLW b'01101111'
    MOVWF PORTD
    GOTO loop
    
CASEA:
    MOVLW b'01110111'
    MOVWF PORTD
    GOTO loop
    
CASEB:
    MOVLW b'01111100'
    MOVWF PORTD
    GOTO loop
    
CASEC:
    MOVLW b'00111001'
    MOVWF PORTD
    GOTO loop
    
CASED:
    MOVLW b'01011110'
    MOVWF PORTD
    GOTO loop
    
CASEE:
    MOVLW b'01111001'
    MOVWF PORTD
    GOTO loop
    
CASEF:
    MOVLW b'01110001'
    MOVWF PORTD
    GOTO loop
    
DEFAULT:
    MOVLW b'01000000'			;El caso default dibuja un guión intermedio, indicando que la suma es mayor y no se puede representar en el display.
    MOVWF PORTD
    GOTO loop

    END					;El programa finaliza
