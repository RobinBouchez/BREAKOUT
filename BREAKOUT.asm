
IDEAL
P386
MODEL FLAT, C
ASSUME cs:_TEXT,ds:FLAT,es:FLAT,fs:FLAT,gs:FLAT

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
    
    call    setVideoMode,13h

    mov ecx, 7
    mov edx, 30
drawwall:
    call drawRectangle, edx,30,30,10, 32
    add edx, ebx
    loop drawwall
    
    call drawRectangle, SCREEN_WIDTH / 2, SCREEN_HEIGHT - 20, 30, 1, 2
    
    
    
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
    
    SCREEN_HEIGHT equ 200
    SCREEN_WIDTH EQU 320
    VMEMADR EQU 0A0000h
    
    _plus dw 8, 8 ; W = 8, h = 8
    db 0, 0, 0, 1, 1, 0, 0, 0
    db 0, 0, 0, 1, 1, 0, 0, 0
    db 0, 0, 0, 1, 1, 0, 0, 0
    db 1, 1, 1, 1, 1, 1, 1, 1
    db 1, 1, 1, 1, 1, 1, 1, 1
    db 0, 0, 0, 1, 1, 0, 0, 0
    db 0, 0, 0, 1, 1, 0, 0, 0
    db 0, 0, 0, 1, 1, 0, 0, 0
    
; -------------------------------------------------------------------
; STACK
; -------------------------------------------------------------------
STACK 100h

END main
