bits 32
%define bar_height		25
%define start_symbol	104
%define stop_symbol		106

global load_symbol
global _load_symbol
global draw_rect
global _draw_rect
global index_of_symbol
global _index_of_symbol
global draw_symbol
global _draw_symbol
global encode128
global _encode128

section .data
indices:		dd	5444, 5204, 1364, 9488, 5648, 5408, 8528, 4688, 4448, 8468, 4628, 4388, 6464, 6224, 2384, 5504, 5264, 1424, 404, 6164, 2324, 4484, 4244, 2120, 5384, 5144, 1304, 4424, 4184, 344, 9284, 1604, 1124, 9728, 9248, 1568, 8768, 8288, 608, 8708, 8228, 548, 10304, 2624, 2144, 9344, 1664, 1184, 1160, 2564, 2084, 8324, 644, 2180, 9224, 1544, 1064, 8264, 584, 104, 200, 788, 44, 13568, 5888, 13328, 1808, 5168, 1328, 12608, 4928, 12368, 848, 4208, 368, 308, 12308, 140, 4148, 224, 7424, 7184, 3344, 4544, 4304, 464, 4364, 4124, 284, 3140, 1220, 1100, 11264, 3584, 3104, 8384, 704, 8204, 524, 3200, 2240, 3080, 2060, 4868, 12548, 6404, 16548

section .text

; int load_symbol(int index);
%define symbol_idx 	[ebp+8]
load_symbol:
_load_symbol:
	push    ebp
	mov     ebp, esp
	mov		edx, symbol_idx
	shl		edx, 2
	mov		eax, [indices+edx]
	xor		edx, edx
	mov     esp, ebp
	pop		ebp
	ret
	
	
; void draw_rect(unsigned char *img, int x0, int y0, int x1, int y1);
%define img     	[ebp+8]
%define x0          [ebp+12] 
%define y0          [ebp+16]
%define x1          [ebp+20]
%define y1          [ebp+24]
%define x       	[ebp-4]
%define y       	[ebp-8]
draw_rect:
_draw_rect:
	push    ebp
	mov     ebp, esp
	sub		esp, 8
	; for y = y0;
	mov		eax, y0
	mov		y, eax
draw_for_y:
	; for x = x0;
	mov		eax, x0
	mov		x, eax
draw_for_x:
	; set pixel
	mov		eax, 1800
	xor		edx, edx
	imul	eax, y
	mov		ecx, x
	lea		ecx,  [ecx+ecx*2]
	add		eax, ecx
	add		eax, img
	mov		[eax], word 0x0000
	mov		[eax+2], byte 0x0000
	; x < x1; ++x
	mov		eax, x
	inc		eax
	mov		x, eax
	cmp		eax, x1
	jl		draw_for_x
	; y < y1; ++y
	mov		eax, y
	inc		eax
	mov		y, eax
	cmp		eax, y1
	jl		draw_for_y
	;
	mov     esp, ebp
	pop		ebp
	ret
	
;  int index_of_symbol(unsigned char symbol);
%define symbol     	[ebp+8]
index_of_symbol:
_index_of_symbol:
	push    ebp
	mov     ebp, esp
	;
	mov		eax, symbol
	cmp		eax, 32
	jl		index_of_symbol_invalid_symbol
	cmp		eax, 127
	jg		index_of_symbol_invalid_symbol
	sub		eax, 32
	;
index_of_symbol_ret:
	mov     esp, ebp
	pop		ebp
	ret
index_of_symbol_invalid_symbol:
	mov		eax, -1
	jmp		index_of_symbol_ret

; int draw_symbol(unsigned char *img, int bar_width, int index, int x, int y);
%define img     	[ebp+8]
%define bar_width   [ebp+12]
%define index       [ebp+16]
%define x           [ebp+20]
%define y           [ebp+24]
%define symbol      [ebp-4]
%define steps       [ebp-8]
%define sym_step  	[ebp-12]
%define sym_width   [ebp-16]
draw_symbol:
_draw_symbol:
    push    ebp
    mov     ebp, esp
    sub     esp, 16
    ; symbol = load_symbol(index)
    push	dword index
    call    load_symbol
	add		esp, 4
    mov     symbol, eax
	; steps = 6, or 7 if index == stop_symbol
    mov     dword steps, 6
    mov     eax, index
    cmp     eax, stop_symbol
    jne     draw_symbol_normal
    mov     dword steps, 7
draw_symbol_normal:
    mov     dword sym_step, 0
draw_symbol_loop:
    ; symbol >>= 2;
    mov     eax, symbol
    shr     eax, 2
    mov     symbol, eax
    ; int sym_width = ((symbol & 3) + 1) * bar_width;
	xor		edx, edx
    mov     eax, symbol
    and     eax, 3
    inc     eax
    mov		ecx, bar_width
	mul		ecx
    mov     sym_width, eax
    ; if (sym_step & 1) == 0, draw a bar
    mov     eax, sym_step
    and     eax, 1
    test	eax, eax
    jnz     skip_draw
    ; draw_rect(img, x, y, x + width, y + bar_height)
	mov		eax, y
	add		eax, bar_height
	push	eax
	mov		eax, x
	add		eax, sym_width
	push	eax
	push	dword y
	push	dword x
	push	dword img
    call    draw_rect
	add		esp, 20
skip_draw:
    ; x += width;
    mov     eax, x
    add     eax, sym_width
    mov     x, eax
	; ++i
    mov     eax, sym_step
    inc     eax
    mov     sym_step, eax
    cmp     eax, steps
    jl    	draw_symbol_loop
end_loop:
    ; Return x
    mov     eax, x
    mov     esp, ebp
    pop     ebp
    ret
	
; int encode128(unsigned char *img, int bar_width, unsigned char *text);
%define img     	[ebp+8]
%define bar_width   [ebp+12]
%define text       	[ebp+16]
%define checksum    [ebp-4]
%define strlen      [ebp-8]
%define pos_x      	[ebp-12]
%define pos_y       [ebp-16]
%define i  			[ebp-20]
%define index   	[ebp-24]
encode128:
_encode128:
    push    ebp
    mov     ebp, esp
	sub		esp, 24
	; strlen(text);
	mov		ecx, text
strlen_loop:
	mov		al, [ecx]
	test	al, al
	jz		strlen_loop_end
	inc		ecx
	jmp		strlen_loop
strlen_loop_end:
	sub		ecx, text
	mov		strlen, ecx
	; checksum = start_symbol
	mov		checksum, dword start_symbol
	; pos_y = 25 - (bar_height >> 1);
	mov		eax, bar_height
	shr		eax, 1
	mov		edx, 25
	sub		edx, eax
	mov		pos_y, edx
	; pos_x = 300 - ((bar_width * 35 + bar_width * 11 * strlen) >> 1);
	mov		eax, 11
	mov		ecx, strlen
	xor		edx, edx
	mul		ecx
	add		eax, 35
	mov		ecx, bar_width
	xor		edx, edx
	mul		ecx
	mov		ecx, 300
	shr		eax, 1
	sub		ecx, eax
	mov		pos_x, ecx
	; pos_x = draw_symbol(img, bar_width, start_symbol, pos_x, pos_y);
	push	dword pos_y
	push	dword pos_x
	push	dword start_symbol
	push	dword bar_width
	push	dword img
	call	draw_symbol
	add		esp, 20
	mov		pos_x, eax
	; for (int i = 0; ...)
	mov		i, dword 0
encode128_loop:
	; index = index_of_symbol(text[i]);
	mov		eax, text
	add		eax, i
	xor		edx, edx
	mov		dl, [eax]
	push	edx
	call	index_of_symbol
	add		esp, 4
	mov		index, eax
	; if index == -1 then return -1
	cmp		index, dword -1
	je		encode128_invalid_symbol
	; pos_x = draw_symbol(img, bar_width, index, pos_x, pos_y);
	push	dword pos_y
	push	dword pos_x
	push	dword index
	push	dword bar_width
	push	dword img
	call	draw_symbol
	add		esp, 20
	mov		pos_x, eax
	; checksum += index * ++i;
	mov		eax, i
	inc		eax
	mov		i, eax
	xor		edx, edx
	mov		ecx, index
	mul		ecx
	add		checksum, eax
	; i < strlen;
	mov		eax, i
	cmp		eax, strlen
	jl		encode128_loop
encode128_done:
	; pos_x = draw_symbol(img, bar_width, checksum % 103, pos_x, pos_y);
	push	dword pos_y
	push	dword pos_x
	mov		eax, checksum
	mov		ecx, 103
	xor		edx, edx
	div		ecx
	push	edx
	push	dword bar_width
	push	dword img
	call	draw_symbol
	add		esp, 20
	mov		pos_x, eax
	; pos_x = draw_symbol(img, bar_width, stop_symbol, pos_x, pos_y);
	push	dword pos_y
	push	dword pos_x
	push	dword stop_symbol
	push	dword bar_width
	push	dword img
	call	draw_symbol
	add		esp, 20
	mov		pos_x, eax
	;
	xor		eax, eax
invalid_symbol_return:
    mov     esp, ebp
    pop     ebp
    ret
encode128_invalid_symbol:
	mov		eax, -1
	jmp		invalid_symbol_return