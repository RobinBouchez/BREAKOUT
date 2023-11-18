
IDEAL
P386
MODEL FLAT, C
ASSUME cs:_TEXT,ds:FLAT,es:FLAT,fs:FLAT,gs:FLAT

INCLUDE "keyb.inc"

; compile-time constants (with macros)

KEYCNT EQU 89		; number of keys to track
BRICK_WIDTH EQU 16
BRICK_HEIGHT EQU 8    
SCREEN_HEIGHT equ 200
SCREEN_WIDTH EQU 320
VMEMADR EQU 0A0000h


; -------------------------------------------------------------------
; CODE
; -------------------------------------------------------------------
CODESEG

; Set the video mode
PROC setVideoMode
    ARG     @@VM:byte
    USES     eax

    movzx ax,[@@VM]
    int 10h

    ret
ENDP setVideoMode

PROC processUserInput
    USES eax, ebx, ecx	
    mov ecx, KEYCNT

    @@loopkeys:
    movzx ebx, [byte ptr offset keybscancodes + ecx - 1]	; get scancode
	mov bl, [offset __keyb_keyboardState + ebx]	; obtain corresponding key state
	xor ax, ax
	sub ax, bx	; if key is pressed, AX = FFFF, otherwise AX = 0000
	loop @@loopkeys

    ret
ENDP processUserInput

PROC drawRectangle
    ARG     @@x0:word, @@y0:word, @@w:word, @@h:word, @@col: byte
    USES     eax, ecx, edx, edi

    movzx eax, [@@y0]
    mov edx, SCREEN_WIDTH
    mul edx
    add ax, [@@x0]


	; Compute top left corner address
	mov edi, VMEMADR
	add edi, eax
	
	; Plot the top horizontal edge.
	movzx edx, [@@w]	; store width in edx for later reuse
	mov	ecx, edx
	mov	al,[@@col]
	rep stosb
	sub edi, edx		; reset edi to left-top corner
	
	; plot both vertical edges
	movzx ecx,[@@h]
	@@vertLoop:
		mov	[edi],al		; left edge
		mov	[edi+edx-1],al	; right edge
		add	edi, SCREEN_WIDTH
		loop @@vertLoop
	; edi should point at the bottom-left corner now
	sub edi, SCREEN_WIDTH

	; Plot the bottom horizontal edge.
	mov	ecx, edx
	rep stosb

	ret
ENDP drawRectangle

PROC drawWorld
    mov ecx, 14
    mov edx, 20

@@outer:
    ;mov ebx, 14
    @@inner:
        call drawRectangle, edx, [brick_y],BRICK_WIDTH, BRICK_HEIGHT, 2
        call drawRectangle, edx, [brick_y],BRICK_WIDTH, BRICK_HEIGHT, 2
        ;call drawRectangle, edx,brick_y,BRICK_WIDTH, BRICK_HEIGHT, 4
        ;call drawRectangle, edx,brick_y,BRICK_WIDTH, BRICK_HEIGHT, 4

        ;call drawRectangle, edx,brick_y,BRICK_WIDTH, BRICK_HEIGHT, 32
        ;call drawRectangle, edx,brick_y,BRICK_WIDTH, BRICK_HEIGHT, 32
    
        ;call drawRectangle, edx,brick_y,BRICK_WIDTH, BRICK_HEIGHT, 14
        ;call drawRectangle, edx,brick_y,BRICK_WIDTH, BRICK_HEIGHT, 14
        add edx, 18
        ;dec ebx
        ;jnz @@inner

    ;add [brick_y], 10
    loop @@outer


    call drawRectangle, [controller_x], [controller_y], 34, 3, 9  ;pallette 9
    call drawRectangle, SCREEN_WIDTH / 2, SCREEN_HEIGHT - 50, 4, 2, 0fh  ;    ball
    
	ret
ENDP drawWorld

; Terminate the program.
PROC terminateProcess  
    USES eax
    call setVideoMode, 03h
    mov    ax,04C00h
    int 21h
    ret
ENDP terminateProcess

PROC main
     sti            ; set The Interrupt Flag => enable interrupts
     cld            ; clear The Direction Flag
    
    push ds
    pop  es
    
    call    setVideoMode, 13h
    call __keyb_installKeyboardHandler		

@@mainloop:
    call drawWorld
    call processUserInput
    mov     al, [__keyb_rawScanCode] ; last pressed key
	cmp     al, 01h
    jne @@mainloop
    ;call updateWorld
    ;jmp @@mainloop
    ;@@endofloop:

    call __keyb_uninstallKeyboardHandler

    ; Wait for keystroke and read character.
    mov ah,00h
    int 16h
    
    call    terminateProcess
 ENDP main
	

; -------------------------------------------------------------------
; DATA
; -------------------------------------------------------------------
DATASEG
    _screenBuffer db 64000 dup(?)
    _paletteArray db 0, 0, 0, 60, 0, 0, 60, 30, 0, 60, 60, 0, 0, 60, 0, 0, 0, 60, 63, 63, 63
    
    ball_x dd 100
    ball_y dd 100
    ball_width dd 100
    ball_height dd 100

    controller_x dd 140
    controller_y dd 180
    
    brick_y dd 10
    
    _plus dw 8, 8 ; W = 8, h = 8
    db 0, 0, 0, 1, 1, 0, 0, 0
    db 0, 0, 0, 1, 1, 0, 0, 0
    db 0, 0, 0, 1, 1, 0, 0, 0
    db 1, 1, 1, 1, 1, 1, 1, 1
    db 1, 1, 1, 1, 1, 1, 1, 1
    db 0, 0, 0, 1, 1, 0, 0, 0
    db 0, 0, 0, 1, 1, 0, 0, 0
    db 0, 0, 0, 1, 1, 0, 0, 0

    ; scancode values				
	keybscancodes 	db 29h, 02h, 03h, 04h, 05h, 06h, 07h, 08h, 09h, 0Ah, 0Bh, 0Ch, 0Dh, 0Eh, 	52h, 47h, 49h, 	45h, 35h, 00h, 4Ah
					db 0Fh, 10h, 11h, 12h, 13h, 14h, 15h, 16h, 17h, 18h, 19h, 1Ah, 1Bh, 		53h, 4Fh, 51h, 	47h, 48h, 49h, 		1Ch, 4Eh
					db 3Ah, 1Eh, 1Fh, 20h, 21h, 22h, 23h, 24h, 25h, 26h, 27h, 28h, 2Bh,    						4Bh, 4Ch, 4Dh
					db 2Ah, 00h, 2Ch, 2Dh, 2Eh, 2Fh, 30h, 31h, 32h, 33h, 34h, 35h, 36h,  			 48h, 		4Fh, 50h, 51h,  1Ch
					db 1Dh, 0h, 38h,  				39h,  				0h, 0h, 0h, 1Dh,  		4Bh, 50h, 4Dh,  52h, 53h


    
; -------------------------------------------------------------------
; STACK
; -------------------------------------------------------------------
STACK 100h

END main
