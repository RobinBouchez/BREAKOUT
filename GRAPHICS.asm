IDEAL
P386
MODEL FLAT, C
ASSUME cs:_TEXT,ds:FLAT,es:FLAT,fs:FLAT,gs:FLAT

; -------------------------------------------------------------------
; CODE
; -------------------------------------------------------------------
CODESEG
; Set the video mode
PROC set_video_mode
    ARG     @@VM:byte
    USES     eax

    movzx ax,[@@VM]
    int 10h

    ret
ENDP set_video_mode

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

PROC drawSprite
    ARG @@spritePtr: dword, \
        @@dstPtr: dword, \
        @@x: dword, \
        @@y: dword
    LOCAL @@w: dword, @@h: dword
    USES eax, ebx, ecx, edx, esi , edi

    mov esi , [@@spritePtr]
    xor eax, eax
    lodsw ; read width in AX
    mov [@@w], eax
    lodsw ; read height in AX
    mov [@@h], eax

    mov edi, [@@dstPtr]
    mov eax, [@@y]
    mov ebx, SCREEN_WIDTH
    mul ebx
    add edi, eax
    add edi, [@@x]  
    mov ecx, [@@h]

@@drawLine :
    push ecx
    mov ecx, [@@w]
    rep movsb

    add edi , SCREEN_WIDTH
    sub edi, [@@w] ; edi now points to the next line in dst

    pop ecx
    dec ecx
    jnz @@drawLine
    ret
ENDP drawSprite

PROC displayString
    ARG @@row:DWORD, @@column:DWORD, @@offset:DWORD
    USES EAX, EBX, EDX
    
    MOV EDX, [@@row] ; row in EDX
    MOV EBX, [@@column] ; column in EBX
    MOV AH, 02H ; set cursor position
    SHL EDX, 08H ; row in DH (00H is top)
    MOV DL, BL ; column in DL (00H is left)
    MOV BH, 0 ; page number in BH
    INT 10H ; raise interrupt
    MOV AH, 09H ; write string to standard output
    MOV EDX, [@@offset] ; offset of ’$’-terminated string in EDX
    INT 21H ; raise interrupt
    RET
ENDP displayString

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
