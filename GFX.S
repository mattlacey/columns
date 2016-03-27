 
mask_r:		equ	%1111100000000000
mask_g:		equ	%0000011111100000
mask_b:		equ	%0000000000011111

shift_r:	equ	11
shift_g:	equ	5	

one_r:		equ	2048
one_g:		equ	32

		
		section text

clear_debug:	movem.l d0/a0,-(sp)
		move.l	screen_adr,a0
		
		move.l	#8*v_scr_w-1,d0
cd1:		move.w	#0,(a0)+
		dbf	d0,cd1

		move.l	#0,counter
		movem.l	(sp)+,d0/a0
		rts




debug_bars:	movem.l	d0-d1/a0,-(sp)
		move.l	screen_adr,a0
		move.l	counter,d1
		
		lsl.l	#2,d1
		adda.l	d1,a0
		and.l	#$1f,d1
		moveq.l	#7,d0

debug_r_loop:	
		cmp	#0,d1
		beq	blue
		
		move.w	#$f800,(a0)
		bra	debug_done

blue:		move.w	#$001f,(a0)

debug_done:	adda.l	#v_scr_w*2,a0
		dbf	d0,debug_r_loop
		
		addq.l	#1,counter

		movem.l (sp)+,d0-d1/a0
		rts




debug_blue:	movem.l	d7/a0,-(sp)
		move.l	screen_adr,a0
		lsl.l	#2,d7
		adda.l	d7,a0
		move.w	#$001f,(a0)+
;		move.w	#$001f,(a0)+
		movem.l (sp)+,d7/a0
		rts


inc_screen:
		move.l	screen_adr,a0
		move.l	#scr_h,d0
inc_screen_y:	move.l	#scr_w,d1
		move.w	d0,d2
		lsr.w	#3,d2
inc_screen_x:	move.w	d2,(a0)+
		dbf	d1,inc_screen_x
		dbf	d0,inc_screen_y
		rts

red_screen:	movem.l	d0/a0,-(sp)
		move.w	#$F800,d0
		movea.l	screen_adr,a0
		jsr	clear_scr
		movem.l	(sp)+,d0/a0
		rts

green_screen:	movem.l	d0/a0,-(sp)
		move.w	#$7E0,d0
		movea.l	screen_adr,a0
		jsr	clear_scr
		movem.l	(sp)+,d0/a0
		rts



clear_scr:	; clears the virtual screen to the colour in d0
		movem.l	d1/a0,-(sp)
		move.l	#v_scr_w*v_scr_h/4,d1	; dbf is 16-bit so loop
clear_scr_l:	move.w	d0,(a0)+		; quarter of the count
		move.w	d0,(a0)+		; as virtual screen can
		move.w	d0,(a0)+		; be 640x480
		move.w	d0,(a0)+		; do 4 moves each time
		dbf	d1,clear_scr_l
		movem.l	(sp)+,d1/a0
		rts




full_screen:	; blits an entire screen from a0 to a1
		movem.l	d0,-(sp)
		move.l	#v_scr_w*v_scr_h/4,d0

fs1:		move.w	(a0)+,(a1)+
		move.w	(a0)+,(a1)+
		move.w	(a0)+,(a1)+
		move.w	(a0)+,(a1)+

		dbf	d0,fs1
		movem.l	(sp)+,d0
		rts




fade_black:	
		move.b	work_flag,d1
		cmpi.b	#0,d1
		bne	fade_black_l
		move.b	#1,work_flag		; first pass, setup counter
		move.l	#5,d0
		move.l	d0,counter
fade_black_l:	
		move.l	counter,d0		; dec counter
		subq.l	#1,d0
		move.l	d0,counter
		cmpi.l	#0,d0			; done?
		blt	fade_black_l2

		;move.b	#0,work_flag		; yes, clear work flag
		rts		

fade_black_l2:	
		move.l	screen_adr,a0		; no, get screen adr
		move.l	mask_0,a1		; address of mask 1
		add.l	d0,a1			; point to the right mask
		move.l	#scr_w*scr_h,d0		; init loop
		
fade_black_l3:		
		move.w	(a0),d1

		and.l	(a1),d1			; apply the mask
		move.w	d1,(a0)+		; write the pixel back

		subq.l	#1,d0
		cmpi.l	#0,d0
		bne	fade_black_l3

		rts



blit_16x16:	movem.l	a0-a1,-(sp)

		REPT 16
					
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
		
		ENDR
		
		movem.l	(sp)+,a0-a1
		rts
		
		
		
		
		section data

debug_count:	dc.l	0
counter:	dc.l	0
work_flag:	dc.b	0

mask_0:		dc.w	0
mask_1:		dc.w	%0000100001100001
mask_2:		dc.w	%0001100011100011
mask_3:		dc.w	%0011100111100111
mask_4:		dc.w	%0111101111101111
