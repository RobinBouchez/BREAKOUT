IDEAL
P386
MODEL FLAT, C
ASSUME cs:_TEXT,ds:FLAT,es:FLAT,fs:FLAT,gs:FLAT

;
; compile-time constants (with macros)
;
BALL_SIZE EQU 3

BLOCK_WIDTH EQU 20
BLOCK_HEIGHT EQU 6

DATASEG
    _blue dw BLOCK_WIDTH , BLOCK_HEIGHT
            db 1 , 1 , 1 , 1 , 1 , 1 , 1 , 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
            db 1 , 1 , 1 , 1 , 1 , 1 , 1 , 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
            db 1 , 1 , 1 , 1 , 1 , 1 , 1 , 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
            db 1 , 1 , 1 , 1 , 1 , 1 , 1 , 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
            db 1 , 1 , 1 , 1 , 1 , 1 , 1 , 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
            db 1 , 1 , 1 , 1 , 1 , 1 , 1 , 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
    
    _orange dw BLOCK_WIDTH, BLOCK_HEIGHT
            db 6 , 6 , 6 , 6 , 6 , 6 , 6 , 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
            db 6 , 6 , 6 , 6 , 6 , 6 , 6 , 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
            db 6 , 6 , 6 , 6 , 6 , 6 , 6 , 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
            db 6 , 6 , 6 , 6 , 6 , 6 , 6 , 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
            db 6 , 6 , 6 , 6 , 6 , 6 , 6 , 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
            db 6 , 6 , 6 , 6 , 6 , 6 , 6 , 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
            
    _green dw BLOCK_WIDTH, BLOCK_HEIGHT
            db 2 , 2 , 2 , 2 , 2 , 2 , 2 , 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
            db 2 , 2 , 2 , 2 , 2 , 2 , 2 , 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
            db 2 , 2 , 2 , 2 , 2 , 2 , 2 , 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
            db 2 , 2 , 2 , 2 , 2 , 2 , 2 , 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
            db 2 , 2 , 2 , 2 , 2 , 2 , 2 , 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
            db 2 , 2 , 2 , 2 , 2 , 2 , 2 , 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
    
    _red dw BLOCK_WIDTH, BLOCK_HEIGHT
            db 4 , 4 , 4 , 4 , 4 , 4 , 4 , 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4
            db 4 , 4 , 4 , 4 , 4 , 4 , 4 , 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4
            db 4 , 4 , 4 , 4 , 4 , 4 , 4 , 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4
            db 4 , 4 , 4 , 4 , 4 , 4 , 4 , 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4
            db 4 , 4 , 4 , 4 , 4 , 4 , 4 , 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4
            db 4 , 4 , 4 , 4 , 4 , 4 , 4 , 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4
    
    _yellow dw BLOCK_WIDTH, BLOCK_HEIGHT
            db 14 , 14 , 14 , 14 , 14 , 14 , 14 , 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14            
            db 14 , 14 , 14 , 14 , 14 , 14 , 14 , 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14
            db 14 , 14 , 14 , 14 , 14 , 14 , 14 , 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14
            db 14 , 14 , 14 , 14 , 14 , 14 , 14 , 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14
            db 14 , 14 , 14 , 14 , 14 , 14 , 14 , 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14
            db 14 , 14 , 14 , 14 , 14 , 14 , 14 , 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14
            
    _ball dw BALL_SIZE, BALL_SIZE
            db 0fh, 0fh, 0fh
            db 0fh, 0fh, 0fh
            db 0fh, 0fh, 0fh

    _padle dw 34 , 3
            db 9,9,9,9,9,9,9,9,9,9, 9,9,9,9,9,9,9,9,9,9, 9,9,9,9,9,9,9,9,9,9, 9,9,9,9
            db 9,9,9,9,9,9,9,9,9,9, 9,9,9,9,9,9,9,9,9,9, 9,9,9,9,9,9,9,9,9,9, 9,9,9,9
            db 9,9,9,9,9,9,9,9,9,9, 9,9,9,9,9,9,9,9,9,9, 9,9,9,9,9,9,9,9,9,9, 9,9,9,9
  
        
    _heart dw 9, 9
           db 0,0,4,0,0,0,4,0,0
           db 0,4,4,4,0,4,4,4,0
           db 4,4,4,4,4,4,4,4,4
           db 4,4,4,4,4,4,4,4,4
           db 4,4,4,4,4,4,4,4,4
           db 0,4,4,4,4,4,4,4,0
           db 0,0,4,4,4,4,4,0,0
           db 0,0,0,4,4,4,0,0,0
           db 0,0,0,0,4,0,0,0,0
           
   background_file db "IMAGEDP.bin", 0  
   start_file db "INTRO.bin", 0
