
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

BALL_SIZE EQU 3

CONTROLLER_HEIGHT EQU 3
CONTROLLER_WIDTH EQU 34
CONTROLLER_COLOR EQU 9



; -------------------------------------------------------------------
; CODE
; -------------------------------------------------------------------
CODESEG

PROC draw_rectangle
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
ENDP draw_rectangle

PROC draw_controller
    ARG @@x0, @@y0

    call draw_rectangle, [@@x0], [@@y0], CONTROLLER_WIDTH, CONTROLLER_HEIGHT, CONTROLLER_COLOR
    ret
ENDP draw_controller

PROC move_controller
    ARG @@x0

    push edx

    mov     al, [__keyb_rawScanCode]; last pressed key
	cmp     al, 1eh ; is a key pressed?
    jne @@return
    @@move_controller_right:
    mov edx, [@@x0]
    add edx, 1
    mov [@@x0], edx
    
    @@return:
    pop edx

    ret
ENDP move_controller


PROC balraakt
	ARG @@arrayptr:dword 
    uses ebx, ecx
	
	mov ebx, [@@arrayptr]	; store pointer in ebx
	mov ecx, [ebx]			; get length counter in ecx
	
	@@zoek_x:
	add ebx, 4

	mov edx, [dword ptr ebx]
	cmp [ball_x], edx
	jle @@x_gevonden
	loop @@zoek_x
	jmp @@niet_gevonden
	
	
	@@x_gevonden:
	sub ebx, 4
	mov eax, [dword ptr ebx]
	push eax
	mov [ebx], 1
	
	mov ebx, [@@arrayptr]	; store pointer in ebx
	mov ecx, [ebx]			; get length counter in ecx
	
	add ebx, 32
	
	@@zoek_y:
	add ebx, 4
	
	
	mov edx, [dword ptr ebx]
	cmp [ball_y], edx
	jle @@y_gevonden
	loop @@zoek_y
	
	@@niet_gevonden:
	mov eax, 1
	push eax
	jmp @@stop
	
	@@y_gevonden:
	sub ebx, 4
	mov edx, [dword ptr ebx]
	mov [ebx], 1
	

	@@stop:
	pop eax
	ret 
ENDP balraakt

; Set the video mode
PROC set_video_mode
    ARG     @@VM:byte
    USES     eax

    movzx ax,[@@VM]
    int 10h

    ret
ENDP set_video_mode

PROC process_user_input
    USES eax, ebx, ecx	
    mov ecx, KEYCNT

    @@loopkeys:
    movzx ebx, [byte ptr offset keybscancodes + ecx - 1]	; get scancode
	mov bl, [offset __keyb_keyboardState + ebx]	; obtain corresponding key state
	xor ax, ax
	sub ax, bx	; if key is pressed, AX = FFFF, otherwise AX = 0000
	loop @@loopkeys
    call move_controller, [controller_x]

    ret
ENDP process_user_input

PROC draw_world
    USES ecx, ebx, edx
    mov ecx, 14
    mov edx, 20
    ;mov ebx, 14

@@outer:
   ; @@inner:
        call draw_rectangle, edx,[brick_y], BRICK_WIDTH, BRICK_HEIGHT, 2
        call draw_rectangle, edx,20, BRICK_WIDTH, BRICK_HEIGHT, 2
        call draw_rectangle, edx,30,BRICK_WIDTH, BRICK_HEIGHT, 4
        call draw_rectangle, edx,40,BRICK_WIDTH, BRICK_HEIGHT, 4
        call draw_rectangle, edx,50,BRICK_WIDTH, BRICK_HEIGHT, 32
        call draw_rectangle, edx,60,BRICK_WIDTH, BRICK_HEIGHT, 32

        call draw_rectangle, edx,70,BRICK_WIDTH, BRICK_HEIGHT, 14
        ;call draw_rectangle, edx,brick_y,BRICK_WIDTH, BRICK_HEIGHT, 14
        add edx, 18
;        dec ebx
 ;       jnz @@inner
;    add [brick_y], 10
    loop @@outer

    call draw_controller,[controller_x], [controller_y]
    call draw_rectangle, SCREEN_WIDTH / 2, SCREEN_HEIGHT - 50, 4, 2, 0fh  ;    ball
    
	ret
ENDP draw_world

PROC update_world

    ret
ENDP update_world

PROC clearScreenBuffer
	push	eax
	push	ecx
	push	edi
	push	es
	
	cld
	mov		eax, seg _screenBuffer
	mov		es, eax
	mov		edi, offset _screenBuffer
	mov		ecx, 64000 / 2
	xor		eax, eax
	rep		stosw
    
	pop		es
	pop		edi
	pop		ecx
	pop		eax
	ret
ENDP clearScreenBuffer 

; Terminate the program.
PROC terminate_process  
    USES eax
    call set_video_mode, 03h
    mov    eax,04C00h
    int 21h
    ret
ENDP terminate_process

PROC main
     sti            ; set The Interrupt Flag => enable interrupts
     cld            ; clear The Direction Flag
    
    push ds
    pop  es
    
    call    set_video_mode, 13h
    call __keyb_installKeyboardHandler		

@@main_loop:
    ;call clearScreenBuffer
    call process_user_input
    mov     al, [__keyb_rawScanCode]; last pressed key
	cmp     al, 29h
    je @@end_of_loop
    call update_world
    call draw_world
    jmp @@main_loop
    @@end_of_loop:

    call __keyb_uninstallKeyboardHandler

    ; Wait for keystroke and read character.
    mov ah,00h
    int 16h
    
    call    terminate_process
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
	
	block_length dd 8
	block_x dd 0, 16, 32, 48, 64, 80, 96, 112
    block_y dd 0, 8, 16, 24, 32, 40, 48, 56
    

    controller_x dd 140
    controller_y dd 180

    paddle_pos	dw	140	
	paddle_speed dw	0	
    
    brick_y dd 10
    
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
