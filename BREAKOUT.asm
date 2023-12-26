IDEAL
P386
MODEL FLAT, C
ASSUME cs:_TEXT,ds:FLAT,es:FLAT,fs:FLAT,gs:FLAT

INCLUDE "keyb.inc"
INCLUDE "GRAPHICS.asm"
INCLUDE "SPRITES.asm"

; compile-time constants (with macros)

KEYCNT EQU 89        ; number of keys to track
SCREEN_HEIGHT equ 200
SCREEN_WIDTH EQU 320
VMEMADR EQU 0A0000h

CONTROLLER_HEIGHT EQU 3
CONTROLLER_WIDTH EQU 35
CONTROLLER_COLOR EQU 9

DATASIZE EQU 320*200 ;bytes of data in file

; -------------------------------------------------------------------
; CODE
; -------------------------------------------------------------------
CODESEG


PROC update_score
    ARG @@scoreptr:dword
    USES eax

    mov eax, [@@scoreptr]  ; Load the current value of 'score' into eax
    add eax, 1       ; Increment 'score' by 1
    mov [@@scoreptr], eax  ; Store the updated value back to 'score'
    xor eax, eax
    
    ret
ENDP update_score

PROC move_controller
    ARG @@x0
    USES edx, eax

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



PROC balraaktcontroller
	USES eax, ebx, ecx
	
	mov eax, [controller_y]
    sub eax, 2
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
    cmp ecx, 4
    jle @@bigleft
    cmp ecx, 10
    jle @@verhoog
    cmp ecx, 18
    jle @@recht
    cmp ecx, 28
    jle @@verhoog
    jmp @@bigright

    @@bigright:
    mov [bal_speed_x], 3
    mov [bal_speed_y], 1
    mov [bal_beweeg_var], 0
    jmp @@stop


    @@recht:
    mov eax, [bal_speed_x]
    cmp eax, 1
    jle @@sla_over
    sub eax, 1
    mov [bal_speed_x], eax
    @@sla_over:
	cmp [bal_beweeg_var], 3
    je @@normal
    mov [bal_beweeg_var], 1
    jmp @@stop

    
    @@verhoog:
    mov eax, [bal_speed_x]
    cmp eax, 3
    jge @@recht
    add eax, 1
    mov [bal_speed_x], eax
    mov [bal_speed_y], 2
    jmp @@recht

    
    @@bigleft:
    mov [bal_speed_x], 3
    mov [bal_speed_y], 1
    mov [bal_beweeg_var], 1
    jmp @@stop
    
    @@normal:
    call change_bal_direction
	
	@@stop:
	ret
ENDP balraaktcontroller

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
    ARG @@arrayptr:dword, @@arrayptr2:dword
    USES eax,ecx, ebx, edx
    mov ebx, [@@arrayptr]    ; store pointer in ebx
    mov ecx, [ebx]            ; get length counter in ecx
    mov edx, ebx
    add edx, 4
    mov eax, ebx
    add eax, 56

    mov ebx, [@@arrayptr2]

    @@outer:
    push eax
    cmp [dword ptr ebx], 1
    jne @@skip1
    call drawSprite, offset _red, VMEMADR, [dword ptr edx], [dword ptr eax]
    @@skip1:
    add ebx, 52
    add eax, 4
    cmp [dword ptr ebx], 1
    jne @@skip2
    call drawSprite, offset _orange, VMEMADR, [dword ptr edx], [dword ptr eax]
    @@skip2:
    add ebx, 52
    add eax, 4
    cmp [dword ptr ebx], 1
    jne @@skip3
    call drawSprite, offset _yellow, VMEMADR, [dword ptr edx], [dword ptr eax]
    @@skip3:
    add ebx, 52
    add eax, 4
    cmp [dword ptr ebx], 1
    jne @@skip4
    call drawSprite, offset _green, VMEMADR, [dword ptr edx], [dword ptr eax]
    @@skip4:
    add ebx, 52
    add eax, 4
    cmp [dword ptr ebx], 1
    jne @@skip5
    call drawSprite, offset _blue, VMEMADR, [dword ptr edx], [dword ptr eax]
    @@skip5:
    sub ebx, 204
    add edx, 4
    pop eax
    sub ecx, 1
    cmp ecx, 0
    jne @@outer

    call drawSprite, offset _padle, VMEMADR, [controller_x], [controller_y]
    call drawSprite, offset _ball, VMEMADR, [ball_x], [ball_y]
    
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
    jmp @@stop

    @@stop:
    ret
ENDP change_bal_direction

PROC check_block
    USES eax, ebx
    mov eax, 1
    ret
ENDP check_block

PROC balraaktrand
    USES eax
    
    mov eax, [ball_x]
    cmp eax, 17
    jle @@verander_x1
    cmp eax, 299
    jge @@verander_x2
    @@check_y:
    mov eax, [ball_y]
    cmp eax, 38
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

PROC balraakt
    ARG @@arrayptr:dword, @@arrayptr2:dword
    uses eax, ebx, ecx, edx

    mov eax, [ball_y]
    cmp eax, 75
    ja @@stop
    
    mov eax, [ball_x] ;;; check of bal binnen bounds is
    cmp eax, 300
    ja @@stop 
    
    mov ebx, [@@arrayptr]    ; store pointer in ebx
    mov ecx, [ebx]            ; get length counter in ecx
    add ebx, 4
    mov eax, 0

    @@zoek_x:
    mov edx, [dword ptr ebx]
    cmp [ball_x], edx
    jle @@x_gevonden
    add eax, 4
    add ebx, 4
    loop @@zoek_x
    sub eax, 4

    @@x_gevonden:
    mov ebx, [ball_x]
    cmp ebx, 40
    jle @@skip_sub
    sub eax, 4
    @@skip_sub:
    cmp ebx, edx
    je @@pone
    push 0
    jmp @@init_y
    @@pone:
    push 1
    
    @@init_y:
    push eax
    xor eax, eax
    xor ebx, ebx
    xor edx, edx
    mov ebx, [@@arrayptr]    ; store pointer in ebx
    add ebx, 56 ;; naar einde van y-list gaan
    mov ecx, 5
    mov eax, 0
    
    @@zoek_y:
    mov edx, [dword ptr ebx]
    add edx, 5
    cmp [ball_y], edx
    jle @@y_gevonden
    add ebx, 4
    add eax, 52
    loop @@zoek_y
    jmp @@stop

    @@y_gevonden:
    mov ebx, [@@arrayptr2]
    add ebx, eax

    pop eax
    add ebx, eax
    mov edx, [dword ptr ebx]
    cmp edx, 0
    je @@stop
    mov [dword ptr ebx], 0

    pop eax
    cmp eax, 1
    je @@rand

    mov eax, [bal_beweeg_var]
    cmp eax, 0
    je @@case1
    
    @@case0:
    mov [bal_beweeg_var], 2
    jmp @@stop
    
    @@case1:
    mov [bal_beweeg_var], 3
    jmp @@stop
    
    @@rand:
    mov eax, [bal_beweeg_var]
    cmp eax, 0
    je @@case3
    cmp eax, 2
    je @@case1
    cmp eax, 3
    je @@case0
    mov [bal_beweeg_var], 0
    jmp @@stop
    
    @@case3:
    mov [bal_beweeg_var], 1

    @@stop:
    ret
ENDP balraakt
    

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
    sub eax, 4
    cmp eax, 10
    jle @@beweeg_bal
    mov [controller_x], eax
    jmp @@beweeg_bal
    
    @@move_cont_right:
    mov eax, [controller_x]
    add eax, 4
    cmp eax, 280
    jge @@beweeg_bal
    mov [controller_x], eax
    

    @@beweeg_bal:
    call move_bal
    call balraaktrand
	call balraaktcontroller
    call balraakt, offset block_length, offset available_blocks
    
    @@return:
    ret
ENDP update_world

PROC main
     sti            ; set The Interrupt Flag => enable interrupts
     cld            ; clear The Direction Flag
    
    push ds
    pop  es
    @@go_restart:
    
    call    set_video_mode, 13h
    call __keyb_installKeyboardHandler
    call ReadFile, offset background_file, offset dataread_bg,DATASIZE
    
@@main_loop:
    call wait_VBLANK, 3
    call process_user_input
    mov     al, [__keyb_rawScanCode]; last pressed key
    cmp     al, 01h
    je @@end_of_loop
    cmp [ball_y], 185
    jge @@lost
    call DrawBG, offset dataread_bg
    call update_world 
    call draw_world, offset block_length , offset available_blocks
    xor eax, eax
    jmp @@main_loop

    @@lost:
    call DrawBG, offset dataread_bg
    mov ah, 09h
    mov edx, offset LostMsg
    int 21h

    @@lost_loop:
    call delay
    call wait_VBLANK, 3
    call process_user_input
    mov     al, [__keyb_rawScanCode]; last pressed key
    cmp     al, 01h
    je @@end_of_loop
    cmp     al, 39h
    je @@restart_main_loop
    call delay
    jmp @@lost_loop
    
    @@restart_main_loop:
    mov cx, 64
    mov ebx, 0
    @@fill_loop:
    mov [available_blocks +  ebx], 1
    add ebx,4
    loop @@fill_loop
    mov [ball_y], 155
    mov [ball_y], 177
    mov [bal_beweeg_var], 0
    mov [bal_speed_x], 1
    mov [bal_speed_y], 1
    mov [controller_x], 140
    jmp @@go_restart

    @@end_of_loop:

    call __keyb_uninstallKeyboardHandler
    
    call    terminate_process
 ENDP main
    

; -------------------------------------------------------------------
; DATA
; -------------------------------------------------------------------
DATASEG
    _screenBuffer db 64000 dup(?)
    
    ball_x dd 155
    ball_y dd 177
    
    block_length dd 13
    block_x dd 18,40,62,84,106,128,150,172,194,216,238,260,282
    block_y dd 35,43,51,59,67
    
    available_blocks dd 1,1,1,1,1,1,1,1,1,1,1,1,1
                     dd 1,1,1,1,1,1,1,1,1,1,1,1,1
                     dd 1,1,1,1,1,1,1,1,1,1,1,1,1
                     dd 1,1,1,1,1,1,1,1,1,1,1,1,1
                     dd 1,1,1,1,1,1,1,1,1,1,1,1,1
                     
    
    bal_beweeg_var dd 0
    bal_speed_x dd 1
    bal_speed_y dd 1
    
    score dd 0

    controller_x dd 140
    controller_y dd 180

    paddle_pos    dw    140
    paddle_speed dw    0
    
    ; scancode values
    keybscancodes     db 29h, 02h, 03h, 04h, 05h, 06h, 07h, 08h, 09h, 0Ah, 0Bh, 0Ch, 0Dh, 0Eh,     52h, 47h, 49h,     45h, 35h, 00h, 4Ah
                    db 0Fh, 10h, 11h, 12h, 13h, 14h, 15h, 16h, 17h, 18h, 19h, 1Ah, 1Bh,         53h, 4Fh, 51h,     47h, 48h, 49h,         1Ch, 4Eh
                    db 3Ah, 1Eh, 1Fh, 20h, 21h, 22h, 23h, 24h, 25h, 26h, 27h, 28h, 2Bh,                            4Bh, 4Ch, 4Dh
                    db 2Ah, 00h, 2Ch, 2Dh, 2Eh, 2Fh, 30h, 31h, 32h, 33h, 34h, 35h, 36h,               48h,         4Fh, 50h, 51h,  1Ch
                    db 1Dh, 0h, 38h,                  39h,                  0h, 0h, 0h, 1Dh,          4Bh, 50h, 4Dh,  52h, 53h


    openErrorMsg db "could not open file", 13, 10, '$'
    readErrorMsg db "could not read data", 13, 10, '$'
    closeErrorMsg db "error during file closing", 13, 10, '$'
    LostMsg db "You Lost...  Press esc to exit and space to restart!", 13, 10, '$'
    
; -------------------------------------------------------------------
UDATASEG
    dataread_bg db DATASIZE dup (?)
    
; -------------------------------------------------------------------
; STACK
; -------------------------------------------------------------------
STACK 100h

END main