		
		section text
		
font_load:	move.l	#font_file,filename.l
		move.l	#font_data,filebuffer.l
		jsr	loader

		rts
		
		
		
		
font_print:	movem.l	d0/a1,-(sp)

font_pr_loop:	move.l	#0,d0
		move.b	(a1)+,d0
		cmp.b	#0,d0
		beq	font_pr_done
		
		sub.b	#32,d0
		jsr	font_char
		adda.l	#16,a0
		jmp	font_pr_loop
		

font_pr_done:	movem.l	(sp)+,d0/a1
		rts




font_char:	movem.l	d0/a0-a1,-(sp)
		
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