
IDEAL
P386
MODEL FLAT, C
ASSUME cs:_TEXT,ds:FLAT,es:FLAT,fs:FLAT,gs:FLAT

INCLUDE "keyb.inc"

; compile-time constants (with macros)

KEYCNT EQU 89        ; number of keys to track
BRICK_WIDTH EQU 16
BRICK_HEIGHT EQU 8
SCREEN_HEIGHT equ 200
SCREEN_WIDTH EQU 320
VMEMADR EQU 0A0000h

BALL_SIZE EQU 3

CONTROLLER_HEIGHT EQU 3
CONTROLLER_WIDTH EQU 35
CONTROLLER_COLOR EQU 9

DATASIZE EQU 320*200 ;bytes of data in file

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
    movzx edx, [@@w]    ; store width in edx for later reuse
    mov    ecx, edx
    mov    al,[@@col]
    rep stosb
    sub edi, edx        ; reset edi to left-top corner
    
    ; plot both vertical edges
    movzx ecx,[@@h]
    @@vertLoop:
        mov    [edi],al        ; left edge
        mov    [edi+edx-1],al    ; right edge
        add    edi, SCREEN_WIDTH
        loop @@vertLoop
    ; edi should point at the bottom-left corner now
    sub edi, SCREEN_WIDTH

    ; Plot the bottom horizontal edge.
    mov    ecx, edx
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
    
    mov ebx, [@@arrayptr]    ; store pointer in ebx
    mov ecx, [ebx]            ; get length counter in ecx
    
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
    
    mov ebx, [@@arrayptr]    ; store pointer in ebx
    mov ecx, [ebx]            ; get length counter in ecx
    
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

PROC balraaktcontroller
	USES eax, ebx, ecx
	
	mov eax, [controller_y]
	cmp [ball_y], eax
	jne @@stop
	mov eax, [ball_x]
	mov ecx, 35

	@@loop:
	cmp eax, [controller_x]
	je @@gelijk
	sub eax, 1
	loop @@loop
	jmp @@stop

	@@gelijk:
    cmp ecx, 5
    jle @@bigleft
    cmp ecx, 15
    jle @@left
    cmp ecx, 25
    jle @@recht
    cmp ecx, 30
    jle @@right 

    @@bigright:
    mov [bal_speed_x], 2
    mov [bal_speed_y], 1
    mov [bal_beweeg_var], 0
    jmp @@stop

    @@recht:
    mov [bal_speed_x], 0
    mov [bal_speed_y], 1
	cmp [bal_beweeg_var], 3
    je @@normal
    mov [bal_beweeg_var], 1
    jmp @@stop

    @@right:
    mov [bal_speed_x], 1
    mov [bal_speed_y], 1
    mov [bal_beweeg_var], 0
    jmp @@stop
    
    @@left:
    mov [bal_speed_x], 1
    mov [bal_speed_y], 1
    mov [bal_beweeg_var], 1
    jmp @@stop
    
    @@bigleft:
    mov [bal_speed_x], 2
    mov [bal_speed_y], 1
    mov [bal_beweeg_var], 1
    jmp @@stop
    
    @@normal:
    call change_bal_direction
	
	@@stop:
	ret
ENDP balraaktcontroller

; Set the video mode
PROC set_video_mode
    ARG     @@VM:byte
    USES     eax

    movzx ax,[@@VM]
    int 10h

    ret
ENDP set_video_mode

PROC process_user_input
    USES ebx, ecx
    mov ecx, KEYCNT

    @@loopkeys:
    movzx ebx, [byte ptr offset keybscancodes + ecx - 1]    ; get scancode
    mov bl, [offset __keyb_keyboardState + ebx]    ; obtain corresponding key state
    xor ax, ax
    sub ax, bx    ; if key is pressed, AX = FFFF, otherwise AX = 0000
    loop @@loopkeys
    
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
    call draw_rectangle, [ball_x], [ball_y], BALL_SIZE, BALL_SIZE, 0fh  ;    ball
    
    ret
ENDP draw_world

PROC printnewline
    USES eax, edx
    MOV dl, 10
    MOV ah, 02h
    INT 21h
    ret
ENDP printnewline

PROC printUnsignedInteger
    ARG    @@printval:dword    ; input argument
    USES eax, ebx, ecx, edx

    mov eax, [@@printval]
    mov    ebx, 10        ; divider
    xor ecx, ecx    ; counter for digits to be printed

    ; Store digits on stack
@@getNextDigit:
    inc    ecx         ; increase digit counter
    xor edx, edx
    div    ebx           ; divide by 10
    push dx            ; store remainder on stack
    test eax, eax    ; check whether zero?
    jnz    @@getNextDigit

    ; Write all digits to the standard output
    mov    ah, 2h         ; Function for printing single characters.
@@printDigits:
    pop dx
    add    dl,'0'          ; Add 30h => code for a digit in the ASCII table, ...
    int    21h                ; Print the digit to the screen, ...
    loop @@printDigits    ; Until digit counter = 0.
    
    call printnewline
    ret
ENDP printUnsignedInteger

PROC delay
    USES eax, ecx, edx
    mov     CX, 00h
    mov    DX, 1FFh
    mov    AH, 86h
    int    15h
    ret
ENDP delay

PROC move_bal
    USES eax

    cmp [bal_beweeg_var], 0
    je @@null
    cmp [bal_beweeg_var], 1
    je @@one
    cmp [bal_beweeg_var], 2
    je @@twee
    jmp @@drie


    @@null:
    mov eax, [ball_x]
    sub eax, [bal_speed_x]
    mov [ball_x], eax
    mov eax, [ball_y]
    sub eax, [bal_speed_y]
    mov [ball_y], eax
    jmp @@stop


    @@one:
    mov eax, [ball_x]
    add eax, [bal_speed_x]
    mov [ball_x], eax
    mov eax, [ball_y]
    sub eax, [bal_speed_y]
    mov [ball_y], eax
    jmp @@stop
    

    @@twee:
    mov eax, [ball_x]
    add eax, [bal_speed_x]
    mov [ball_x], eax
    mov eax, [ball_y]
    add eax, [bal_speed_y]
    mov [ball_y], eax
    jmp @@stop
    
    @@drie:
    mov eax, [ball_x]
    sub eax, [bal_speed_x]
    mov [ball_x], eax
    mov eax, [ball_y]
    add eax, [bal_speed_y]
    mov [ball_y], eax
    jmp @@stop
    
    @@stop:
    ret
ENDP move_bal

PROC change_bal_direction
    USES eax, ebx
    
    mov eax, [bal_beweeg_var]
    cmp eax, 3
    je @@drie
    add eax, 1
    mov [bal_beweeg_var], eax
    jmp @@stop
    
    @@drie:
    mov [bal_beweeg_var], 0

    @@stop:
    ret
ENDP change_bal_direction

PROC balraaktrand
    USES eax
    
    mov eax, [ball_x]
    cmp eax, 20
    jle @@verander_x1
    cmp eax, 297
    jge @@verander_x2
    @@check_y:
    mov eax, [ball_y]
    cmp eax, 40
    jle @@verander_y
    jmp @@stop
    
    
    @@verander_x1:
    cmp [bal_beweeg_var], 0
    je @@normal
    mov [bal_beweeg_var], 2
    jmp @@check_y
    
    @@verander_x2:
    cmp [bal_beweeg_var], 2
    je @@normal
    mov [bal_beweeg_var], 0
    jmp @@stop
    

    @@verander_y:
    cmp [bal_beweeg_var], 1
    je @@normal
    mov [bal_beweeg_var], 3
    jmp @@stop
    
    @@normal:
    call change_bal_direction
    
    @@stop:
    ret
ENDP balraaktrand
    

PROC update_world
    USES ebx
    
    cmp ax, 0
    je @@beweeg_bal

    cmp eax, 4bh
    je @@move_cont_left
    cmp eax, 4dh
    je @@move_cont_right
    jmp @@beweeg_bal
    
    @@move_cont_left:
    mov eax, [controller_x]
    sub eax, 5
    cmp eax, 0
    je @@beweeg_bal
    mov [controller_x], eax
    jmp @@beweeg_bal
    
    @@move_cont_right:
    mov eax, [controller_x]
    add eax, 5
    cmp eax, 290
    je @@beweeg_bal
    mov [controller_x], eax
    

    @@beweeg_bal:
    call move_bal
    call balraaktrand
	call balraaktcontroller
    ;call balraakt, offset block_length
    
    @@return:
    ret
ENDP update_world

PROC clearScreenBuffer
    push    eax
    push    ecx
    push    edi
    push    es
    
    cld
    mov        eax, seg _screenBuffer
    mov        es, eax
    mov        edi, offset _screenBuffer
    mov        ecx, 64000 / 2
    xor        eax, eax
    rep        stosw
    
    pop        es
    pop        edi
    pop        ecx
    pop        eax
    ret
ENDP clearScreenBuffer

PROC ReadFile
    ARG     @@filepathptr: dword,@@dataptr: dword,@@noofbytes: dword
    USES eax, ebx, ecx, edx, esi, edi

    ; open file, get filehandle in AX
    mov al, 0 ; read only
    mov edx, [@@filepathptr]
    mov ah, 3dh
    int 21h

    mov  edx, offset openErrorMsg
    jc @@print_error ; carry flag is set if error occurs

    ; read file data
    mov bx, ax ; move filehandle to bx
    mov ecx, [@@noofbytes]
    mov edx, [@@dataptr]
    mov ah, 3fh
    int 21h

    mov  edx, offset readErrorMsg
    jc @@print_error

    ; close file
    mov ah, 3Eh
    int 21h

    mov  edx, offset closeErrorMsg
    jc @@print_error

    ret
@@print_error:
    call set_video_mode, 03h
    mov  ah, 09h
    int  21h

    mov    ah,00h
    int    16h
    
    call    terminate_process
ENDP ReadFile

; Terminate the program.
PROC terminate_process
    USES eax
    call set_video_mode, 03h
    mov    eax,04C00h
    int 21h
    ret
ENDP terminate_process

PROC DrawBG
    ARG     @@dataptr: dword
    USES esi,edi,ecx
    mov esi, [@@dataptr]
    mov edi, VMEMADR
    mov ecx, DATASIZE
    rep movsb
    ret
ENDP DrawBG

; wait for @@framecount frames
proc wait_VBLANK
    ARG @@framecount: word
    USES eax, ecx, edx
    mov dx, 03dah                     ; Wait for screen refresh
    movzx ecx, [@@framecount]

        @@VBlank_phase1:
        in al, dx
        and al, 8
        jnz @@VBlank_phase1
        @@VBlank_phase2:
        in al, dx
        and al, 8
        jz @@VBlank_phase2
    loop @@VBlank_phase1

    ret
endp wait_VBLANK

PROC main
     sti            ; set The Interrupt Flag => enable interrupts
     cld            ; clear The Direction Flag
    
    push ds
    pop  es
    
    call    set_video_mode, 13h
    call __keyb_installKeyboardHandler
    call ReadFile, offset background_file, offset dataread_bg,DATASIZE
    
@@main_loop:
    call clearScreenBuffer
    call process_user_input
    mov     al, [__keyb_rawScanCode]; last pressed key
    cmp     al, 01h
    je @@end_of_loop
    call DrawBG, offset dataread_bg
    call update_world 
    call draw_world
    ;call delay
    xor eax, eax
    call wait_VBLANK, 3
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
    
    ball_x dd 155
    ball_y dd 180
    ball_width dd 100
    ball_height dd 100
    
    block_length dd 8
    block_x dd 0, 16, 32, 48, 64, 80, 96, 112
    block_y dd 0, 8, 16, 24, 32, 40, 48, 56
    
    bal_beweeg_var dd 0
    bal_speed_x dd 1
    bal_speed_y dd 1

    controller_x dd 140
    controller_y dd 180

    paddle_pos    dw    140
    paddle_speed dw    0
    
    brick_y dd 10
    
    background_file db "IMAGEDP.bin", 0
    
    ; scancode values
    keybscancodes     db 29h, 02h, 03h, 04h, 05h, 06h, 07h, 08h, 09h, 0Ah, 0Bh, 0Ch, 0Dh, 0Eh,     52h, 47h, 49h,     45h, 35h, 00h, 4Ah
                    db 0Fh, 10h, 11h, 12h, 13h, 14h, 15h, 16h, 17h, 18h, 19h, 1Ah, 1Bh,         53h, 4Fh, 51h,     47h, 48h, 49h,         1Ch, 4Eh
                    db 3Ah, 1Eh, 1Fh, 20h, 21h, 22h, 23h, 24h, 25h, 26h, 27h, 28h, 2Bh,                            4Bh, 4Ch, 4Dh
                    db 2Ah, 00h, 2Ch, 2Dh, 2Eh, 2Fh, 30h, 31h, 32h, 33h, 34h, 35h, 36h,               48h,         4Fh, 50h, 51h,  1Ch
                    db 1Dh, 0h, 38h,                  39h,                  0h, 0h, 0h, 1Dh,          4Bh, 50h, 4Dh,  52h, 53h


    openErrorMsg db "could not open file", 13, 10, '$'
    readErrorMsg db "could not read data", 13, 10, '$'
    closeErrorMsg db "error during file closing", 13, 10, '$'
    
; -------------------------------------------------------------------
UDATASEG
    dataread_bg db DATASIZE dup (?)
    
; -------------------------------------------------------------------
; STACK
; -------------------------------------------------------------------
STACK 100h

END main
