
bg_init:	movem.l	d0/a0,-(sp)
		movem.l	(sp)+,d0/a0
		rts




bg_load_title:	movem.l	a0,-(sp)
		lea	background,a0
		move.l	#bg_title_file,filename.l
		move.l	#background,filebuffer.l
		jsr	loader
		movem.l	(sp)+,a0
		rts




bg_load_game:	movem.l	a0,-(sp)
		lea	background,a0
		move.l	#bg_game_file,filename.l
		move.l	#background,filebuffer.l
		jsr	loader
		movem.l	(sp)+,a0
		rts




bg_draw:	movem.l	a0-a1,-(sp)
		lea	background,a0
		movea.l	screen_adr,a1
		jsr	full_screen
		movem.l	(sp)+,a0-a1
		rts




bg_16x16:	; 100% UNTESTED!!!!!!!
		movem.l	d1/a0-a1,-(sp)		; draw 16x16 of bg at d0,d1
						; to screen

		lea	background,a1
		move.l	screen_adr,a0

		lsl.l	#1,d0			; double x coord 2bpp
		adda.l	d0,a0
		adda.l	d0,a1

	
		; should be able to use a LUT to 
		; avoid the multiplication below

		mulu.l	#v_scr_w*2,d1		; y-offset
		adda.l	d1,a0
		adda.l	d1,a1

		move.w	#15,d0			; draw row at a time

bg161:	
		move.w	(a1)+,(a0)+
		move.w	(a1)+,(a0)+
		move.w	(a1)+,(a0)+
		move.w	(a1)+,(a0)+
		move.w	(a1)+,(a0)+
		move.w	(a1)+,(a0)+
		move.w	(a1)+,(a0)+
		move.w	(a1)+,(a0)+
		move.w	(a1)+,(a0)+
		move.w	(a1)+,(a0)+
		move.w	(a1)+,(a0)+
		move.w	(a1)+,(a0)+
		move.w	(a1)+,(a0)+
		move.w	(a1)+,(a0)+
		move.w	(a1)+,(a0)+
		move.w	(a1)+,(a0)+

		adda.l	#v_scr_w*2-16*2,a0	; next row
		adda.l	#v_scr_w*2-16*2,a1
		dbf	d0,bg161
		
		movem.l	(sp)+,d1/a0-a1
		rts




		section bss
		even
background:	ds.b	scr_w*scr_h*2




		section data

bg_title_file	dc.b	'data\title.bin',0
bg_game_file	dc.b	'data\MARS.BIN',0
		even