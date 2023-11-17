BITS 32

VGA_WIDTH equ 80
VGA_HEIGHT equ 25

VGA_COLOR_BLACK equ 0
VGA_COLOR_BLUE equ 1
VGA_COLOR_GREEN equ 2
VGA_COLOR_CYAN equ 3
VGA_COLOR_RED equ 4
VGA_COLOR_MAGENTA equ 5
VGA_COLOR_BROWN equ 6
VGA_COLOR_LIGHT_GREY equ 7
VGA_COLOR_DARK_GREY equ 8
VGA_COLOR_LIGHT_BLUE equ 9
VGA_COLOR_LIGHT_GREEN equ 10
VGA_COLOR_LIGHT_CYAN equ 11
VGA_COLOR_LIGHT_RED equ 12
VGA_COLOR_LIGHT_MAGENTA equ 13
VGA_COLOR_LIGHT_BROWN equ 14
VGA_COLOR_WHITE equ 15

global kernel_main
kernel_main:
	mov dh, VGA_COLOR_RED
	mov dl, VGA_COLOR_GREEN
	call terminal_set_color
	mov esi, hello_string
	call terminal_write_string
	;mov esi, hello_string
	;call terminal_write_string
	jmp $ ; $ is the address of the current instruction, so jmp $ is looping to to itself
; This is usually done for a fatal error


; IN = dl: y, dh: x
; OUT = dx: Index with offset 0xB8000 at VGA buffer
; Other registers preserved

terminal_getidx:
	push eax; preserve registers
	push ecx

	xor eax, eax
	xor ecx, ecx
	mov ecx, edx

	mov dl, dh
	mov dh, 0
	shl edx, 1

	mov eax, VGA_WIDTH
	mov ch, 0
	mul ecx

	shl ecx, 1
	add edx, eax

	pop ecx
	pop eax
	ret

; IN = dl: bg color, dh: fg color
; OUT = none
terminal_set_color:
	shl dl, 4

	or dl, dh
	mov [terminal_color], dl


	ret

; IN = dl: y, dh: x, al: ASCII char
; OUT = none
terminal_putentryat:
	pusha
	call terminal_getidx
	mov ebx, edx

	mov dl, [terminal_color]
	mov byte [0xB8000 + ebx], al
	mov byte [0xB8001 + ebx], dl


	popa
	ret

; IN = al: ASCII char
terminal_putchar:
	mov dx, [terminal_cursor_pos] ; This loads terminal_column at DH, and terminal_row at DL

	cmp al, 0xA
	je .new_line

	call terminal_putentryat

	inc dh
	cmp dh, VGA_WIDTH
	jne .cursor_moved

.new_line:
	mov dh, 0
	inc dl

	cmp dl, VGA_HEIGHT
	jne .cursor_moved

	mov dl, 0


.cursor_moved:
; Store new cursor position
	mov [terminal_cursor_pos], dx

	ret

; IN = cx: length of string, ESI: string location
; OUT = none
terminal_write:
	pusha
.loopy:

	mov al, [esi]

;	dec cx
	mov al, [esi]
	cmp al, 0
	je .done

	call terminal_putchar

	inc esi
	jmp .loopy


.done:
	popa
	ret

; IN = ESI: zero delimited string location
; OUT = ECX: length of string
;terminal_strlen:
;	push eax
;	push esi
;	mov ecx, 0 ; ecx = len
;.loopy:
;	mov al, [esi]
;	cmp al, 0
;	je .done
;
;	inc esi
;	inc ecx
;
;	jmp .loopy
;
;
;.done:
;	pop esi
;	pop eax
;	ret

; IN = ESI: string location
; OUT = none
terminal_write_string:
	pusha
;	call terminal_strlen
	call terminal_write
	popa
	ret

; Exercises:
; - Newline support
; - Terminal scrolling when screen is full
; Note: 
; - The string is looped through twice on printing. 

hello_string db "1", "2", "3", "4", 0xA, "5", 0xA, "6", 0
;hello_string db "1", 0xA, "2", 0xA, "3", 0xA, "4", 0xA, "5", 0xA, "6", 0
;"        ,--,               "
;"      ,--.'|       ,----,  ", 0xA,\
;"   ,--,  | :     .'   .' - ", 0xA,\
;",---.'|  : '   ,----,'    |", 0xA,\
;";   : |  | ;   |    :  .  ;", 0xA,\
;"|   | : _' |   ;    |.'  / ", 0xA,d
;":   : |.'  |   `----'/  ;  ", 0xA,\
;"|   ' '  ; :     /  ;  /   ", 0xA,\
;":   :  .'. |    ;  /  /-,  ", 0xA,\
;" `---`:  | '   /  /  /.`|  ", 0xA,\
;"      '  ; | ./__;      :  ", 0xA,\
;"      |  : ; |   :    .'   ", 0xA,\
;"      '  ,/  ;   | .'      ", 0xA,\
;"      '--'   `---'         ", 0xA,\
;"                           ", 0xA, 0


terminal_color db 0

terminal_cursor_pos:
terminal_column db 0
terminal_row db 0
