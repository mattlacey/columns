		
		section text
		
font_load:	move.l	#font_file,filename.l
		move.l	#font_data,filebuffer.l
		jsr	loader

		rts
		
		
		
		
font_print:	movem.l	d0/a1,-(sp)		; a1 should point to a null
						; terminated string
font_pr_loop:	move.l	#0,d0			; a0 should hold screen adr
		move.b	(a1)+,d0
		cmp.b	#0,d0
		beq	font_pr_done
		
		sub.b	#32,d0
		jsr	font_char
		adda.l	#16,a0
		jmp	font_pr_loop		

font_pr_done:	movem.l	(sp)+,d0/a1
		rts
		
		
		

font_print_l:	movem.l	d0-d3/a0-a1,-(sp)	; d0 should hold length
		move.l	d0,d2			
		cmp.l	#0,d1			; d1 should hold char offset
		beq	font_prl_loop

		moveq.l	#8,d3
		sub.l	d1,d3			; remaining width of char
	
		move.l	#0,d0			; need to clip first char
		move.b	(a1)+,d0		; so handle it first
		cmp.b	#0,d0
		beq	font_prl_done
		
		sub.b	#32,d0			
		jsr	font_char_lc
		adda.l	d3,a0
		adda.l	d3,a0			; add correct offset to screen addr 
		
		cmp.l	#0,d2			; check length after clip
		beq	font_prl_done
		subq.l	#1,d2

font_prl_loop:	move.l	#0,d0			; a0 should hold screen adr
		move.b	(a1)+,d0		; a1 is the current char
		cmp.b	#0,d0
		beq	font_prl_done
		
		sub.b	#32,d0
		jsr	font_char
		adda.l	#16,a0
		dbf	d2,font_prl_loop

font_prl_done:	movem.l	(sp)+,d0-d3/a0-a1

		rts
		
		
		
				
font_bcd:	movem.l	d0/a1,-(sp)		; a0 should hold screen adr
						; a1 should point to 32bit bcd
		move.l	#0,d0
		
		REPT	4
		
		move.b	(a1),d0			; print top nibble
		lsr.b	#4,d0
		jsr	font_digit
		adda.l	#16,a0
		
		move.b	(a1)+,d0		; print bottom nibble
		and.b	#$0f,d0
		jsr	font_digit
		adda.l	#16,a0
		
		ENDR
		
		
		movem.l	(sp)+,d0/a1
		rts




font_char:	movem.l	d0/a0-a1,-(sp)
		
		lea	font_data,a1		; get offset of char
		lsl	#7,d0			; address of char in d0
		lea	(a1,d0.l),a1		; and load address into a1
		
		REPT	8
		
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		adda.l	#scr_w*2-16,a0
		
		ENDR	

		movem.l	(sp)+,d0/a0-a1
		rts		
		
		
			

		; left clip char (i.e. skip pixels)
font_char_lc:	movem.l	d0-d4/a0-a1,-(sp)
		
		lea	font_data,a1		; get offset of char
		lsl	#7,d0			; index in d0
		lea	(a1,d0.l),a1		; and load address into a1
		
		moveq.l	#7,d2
		moveq.l	#7,d4
fclc1:		sub.l	d1,d2
		move.l	d2,d3
		
		add.l	d1,d1
		adda.l	d1,a1			; offset into char
				
font_clc_1:	move.w	(a1)+,(a0)+
		dbf	d2,font_clc_1

		adda.l	#scr_w*2-16,a0		; next line on screen
		adda.l	d1,a0
		adda.l	d1,a1
		
		move.l	d3,d2
		dbf	d4,font_clc_1

		movem.l	(sp)+,d0-d4/a0-a1
		
		rts
		
		
		
				
font_digit:	movem.l	d0/a0-a1,-(sp)
		
		or.b	#$10,d0			; index into digits
		lea	font_data,a1		; get offset of char
		lsl	#7,d0			; index in d0
		lea	(a1,d0.l),a1		; and load address into a1
		
		REPT	8
		
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		adda.l	#scr_w*2-16,a0
		
		ENDR	

		movem.l	(sp)+,d0/a0-a1
		rts
		
		
		
						
		section	data
		even
font_file	dc.b	'data\font.bin',0
		
		
		section bss
		even	
font_data	ds.w	8*8*59	; space to Z ASCII