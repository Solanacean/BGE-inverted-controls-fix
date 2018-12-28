use32

format binary as 'exe'

include 'patching.inc'       ; Grom PE's FASM patching macros

; === Constants ===

text_physical_offset  = 00001000h
patch_physical_offset = 0076B000h
data_physical_offset  = 00752000h

IMAGE_BASE = 00400000h
PATCH_ORG  = 00D4F000h - patch_physical_offset
TEXT_ORG   = 00401000h - text_physical_offset
DATA_ORG   = 00B52000h - data_physical_offset

IMAGE_SIZE = 094F000h        ; Size of image of the original executable

; === Game specific constants ===

label dword_B7AD38 dword at 00B7AD38h
label sub_4A4FD0   dword at 004A4FD0h
label sub_494060   dword at 00494060h

; === Patching! ===

patchfile 'BGE.$$$'          ; Name of the original (unpatched) executable

;patchsection IMAGE_BASE      ; === PE header ===

;patchat 126h                 ; Increase number of sections
;  dw 5

;patchat 170h                 ; Increase size of image
;  dd IMAGE_SIZE+(patch_section_size+0FFFh)/1000h*1000h

;patchat 2B8h                 ; Create patch section:
;  dd '.pat','ch'             ; Name
;  dd patch_section_size      ; Virtual size
;  dd IMAGE_SIZE              ; RVA
;  dd patch_physical_size     ; Physical size
;  dd patch_physical_offset   ; Physical offset
;  dd 0,0,0                   ; Unused
;  dd 0E00000E0h              ; Attributes

; ******************************************************************************

patchsection TEXT_ORG      ; === .text section start ===

; ******************************************************************************

patchat 00024642h
    mov     [dword_B7AD38], pathway_walking_running  ; Walking/running
    
;patchat 0002466Bh
;    mov     [dword_B7AD38], pathway_picture_camera   ; Jade's photographic camera (we don't want to touch that)
    
;patchat 00024699h
;    mov     [dword_B7AD38], pathway_menu             ; Menu (we don't want to touch that)

patchat 000246C6h
    mov     [dword_B7AD38], pathway_boat             ; Boat

patchat 000246DCh
    mov     [dword_B7AD38], pathway_spaceship_beluga ; Spaceship Beluga

;patchat 000246F2h
;    mov     [dword_B7AD38], pathway_unknown          ; Unidentified

; ------------------------------------------------------------------------------

patchat 0015E082h ; jnz -> nop
    nop
    nop

patchat 002AFF60h ; jnz -> nop
    nop
    nop
    
patchat 0032A7DAh ; jnz -> nop ;-
    nop
    nop   

patchat 003D74A5h ; jnz -> nop
    nop
    nop
    
patchat 003D7538h ; jnz -> nop
    nop
    nop
    
patchat 003D842Bh ; jnz -> nop
    nop
    nop
    
patchat 003DA799h ; jnz -> nop
    nop
    nop
    
patchat 003DCDEBh ; jnz -> nop
    nop
    nop
    
; ------------------------------------------------------------------------------
; We have some nice extra space at the end of the .text section which we're 
; going to use. It will save us the trouble of having to create an additional 
; section to hold the code of the patch and as a bonus the patched executable 
; will be the same size as the original unpatched one.
; ------------------------------------------------------------------------------

patchat 00736C9Fh

pathway_walking_running:   ; Walking/running
    push    423220h        ; Push return address (the original address of the function being hooked) onto the stack 
    jmp     main_body
    
;pathway_picture_camera:    ; Jade's photographic camera (we don't want to touch that)
;    push    4235B0h        ; Push return address (the original address of the function being hooked) onto the stack 
;    jmp     main_body

;pathway_menu:              ; Menu (we don't want to touch that)
;    push    423EF0h        ; Push return address (the original address of the function being hooked) onto the stack 
;    jmp     main_body

pathway_boat:              ; Boat
    push    423850h        ; Push return address (the original address of the function being hooked) onto the stack 
    jmp     main_body

pathway_spaceship_beluga:  ; Spaceship Beluga
    push    423C60h        ; Push return address (the original address of the function being hooked) onto the stack
    jmp     main_body
    
;pathway_unknown:           ; *** Unknown, further investigation is required ***
;    push    424360h        ; Push return address (the original address of the function being hooked) onto the stack

main_body:
    push    ecx            ; ECX is required by the original function so we must preserve it
    push    edx            ; The same goes for EDX
    push    eax            ; Reserve space on stack for a local variable
    mov     ecx, 71003FF9h
    call    sub_4A4FD0    
    push    1DE8h
    mov     edx, eax
    lea     ecx, [esp+4]   ; ECX contains the effective address of the newly created local variable
    call    sub_494060     
    pop     ecx            ; Get pointer to the internal flags in ECX
    mov     eax, [ecx]     ; Load internal flags into EAX
    and     eax, 2         ; Isolate camera mode bit flag (0: normal, 1: reversed)
    shl     eax, 30        ; EAX = 80000000h if camera mode flag is set, otherwise EAX = 0    
    pop     edx            ; Restore EDX    
    pop     ecx            ; Restore ECX
    sub     [edx+4], eax   ; If camera mode = reversed, negate (= invert) the Y coord
    retn                   ; Return control to the original function
        
; ******************************************************************************

patchsection DATA_ORG      ; === .data section start ===

; ******************************************************************************

; ...
; ...
; ...

; ******************************************************************************

patchsection PATCH_ORG     ; === Patch section start ===

; ******************************************************************************

patchat patch_physical_offset
patch_section_start:

; ...
; ...
; ...

patch_section_end:
patch_physical_end:
patch_physical_size = patch_physical_end - patch_section_start
patch_section_size = patch_section_end - patch_section_start

patchend
