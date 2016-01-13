 		section text

slots:		equ	32





init_sprites:	movem.l	d0-d2/a0-a3,-(sp)


		; initialise the LUTs. This could be hardcoded
		; if we didn't have a fixed slot count.
		lea	sprite_lut,a0
	
		move.l	#sprites,d0

		; TODO - see if we can get the devpac3 repeat
		; index to use in here...

		REPT	slots

		move.l	d0,(a0)+		; write addresses
		add.l	#s_size,d0		; increment totals

		ENDR

		; ship sprite at slot 1 (4)
		moveq.l	#0,d0
		movea.l	(sprite_lut,d0),a0
		move.l	#ship,s_data(a0)

		REPT	slots-1

		add.l	#4,d0
		movea.l	(sprite_lut,d0),a0
		move.l	#ship,s_data(a0)

		ENDR

		movem.l	(sp)+,d0-d2/a0-a3
		rts




move_sprite:	movem.l	a0,-(sp)

		movea.l	(sprite_lut,d0),a0

		move.l	s_x1(a0),s_x2(a0)	; update old pos
		move.l	s_y1(a0),s_y2(a0)

		move.l	s_x(a0),s_x1(a0)
		move.l	s_y(a0),s_y1(a0)

		move.l	d1,s_x(a0)
		move.l	d2,s_y(a0)

		movem.l	(sp)+,a0
		rts




clear_sprite:	movem.l	d0-d1/a0-a2,-(sp)	; d0 is sprite index

		movea.l	screen_adr,a0
 		lea	background,a1
						
		movea.l	(sprite_lut,d0),a2
		move.l	s_x2(a2),d1

		lsl.l	#1,d1			; double x coord 2bpp
		adda.l	d1,a0
		adda.l	d1,a1

	
		; should be able to use a LUT to 
		; avoid the multiplication below

		move.l	s_y2(a2),d1
		mulu.l	#v_scr_w*2,d1		; y-offset
		adda.l	d1,a0
		adda.l	d1,a1
		
		jsr	shipclear
		movem.l	(sp)+,d0-d1/a0-a2
		rts		

cs1:

		REPT	16			; 16 lines of bg

		move.l	(a2)+,(a1)+
		move.l	(a2)+,(a1)+
		move.l	(a2)+,(a1)+
		move.l	(a2)+,(a1)+
		move.l	(a2)+,(a1)+
		move.l	(a2)+,(a1)+
		move.l	(a2)+,(a1)+
		move.l	(a2)+,(a1)+
		
		move.l	#v_scr_w*2-32,d1
		adda.l	d1,a1			; next line
		adda.l	d1,a2			

		ENDR		

		movem.l	(sp)+,d0-d1/a0-a2
		rts




; usually handled by draw_sprite but at the start we need to save
; the buffer without drawing

DISABLE_STORE:	equ	1
	IFEQ	DISABLE_STORE		

store_bg:	movem.l	d0-d1/a0-a1,-(sp)

		movea.l	screen_adr,a1

		movea.l	(sprite_lut,d0),a0
		
		move.l	s_x2(a0),d1

		lsl.l	#1,d1			; double x coord 2bpp
		adda.l	d1,a1

		move.l	s_y2(a0),d1
		mulu.l	#v_scr_w*2,d1		; y-offset
		adda.l	d1,a1


		movea.l	(sprite_store_lut,d0),a0; offset to the store

		btst.l	#0,d7			; use correct half of store
		beq	sbg1			; d7 is ticks
		adda.l	#16*16*2,a0

sbg1:

		REPT	16

		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+

		adda.l	#v_scr_w*2-32,a1	; next line
	
		ENDR

		movem.l	(sp)+,d0-d1/a0-a1
		rts


	ENDC

; draw sprite index in d0

draw_sprite:	movem.l	d0-a6,-(sp)
			
		movea.l	screen_adr,a6
		movea.l	(sprite_lut,d0),a0	; sprite data
		
		move.l	s_x(a0),d1
		lsl.l	#1,d1			; double x coord 2bpp
		adda.l	d1,a6

	
		; should be able to use a LUT to 
		; avoid the multiplication below

		move.l	s_y(a0),d1
		mulu.l	#v_scr_w*2,d1		; y-offset
		adda.l	d1,a6

;		movea.l	(sprite_store_lut,d0),a1
;		btst.l	#0,d7			; use correct half of store
;		beq	ds1			; d7 is ticks
;		adda.l	#16*16*2,a1

ds1:		; move.l	s_data(a0),a0		; actual sprite bitmap
		


;		jsr	s_data(a0)
		move.l	a6,a0
		jsr	ship
	
		movem.l	(sp)+,d0-a6
		rts



		adda.l	#16*16*2,a0		; offset to start of mask

; now save bg and mask the sprite


		REPT	16			; 16 lines of sprite

		movem.l	(a0)+,d0-d7		; sprite mask
			
		and.l	d0,(a6)+
		and.l	d1,(a6)+
		and.l	d2,(a6)+
		and.l	d3,(a6)+
		and.l	d4,(a6)+
		and.l	d5,(a6)+
		and.l	d6,(a6)+
		and.l	d7,(a6)+

		adda.l	#v_scr_w*2-32,a6

 		ENDR

; now render the sprite

		suba.l	#v_scr_w*2*16,a6	; reset target address
		suba.l	#16*16*2*2,a0		; back to sprite
	
		REPT	16			; sprite data

		movem.l	(a0)+,d0-d7
		
		or.l	d0,(a6)+
		or.l	d1,(a6)+
		or.l	d2,(a6)+
		or.l	d3,(a6)+
		or.l	d4,(a6)+
		or.l	d5,(a6)+
		or.l	d6,(a6)+
		or.l	d7,(a6)+
	

		adda.l	#v_scr_w*2-32,a6
 		ENDR	
		
		movem.l	(sp)+,d0-a6
		rts


ships:		incbin	"data\ship.spr"		
;colours:	incbin	"data\colours.bin"
;colours2:	incbin	"data\colours2.bin"
;colours3:	incbin	"data\colours3.bin"




		section bss


; sprite structure - size: 32 bytes
		rsreset

s_data:		rs.l	1	; bitmap
s_frames:	rs.w	1	; frame count
s_current:	rs.w	1	; current frame
s_x:		rs.l	1	; positions for this and
s_y:		rs.l	1	; and two previos game frames
s_x1:		rs.l	1
s_y1:		rs.l	1
s_x2:		rs.l	1
s_y2:		rs.l	1

s_size:		equ	32



; look up tables for quick indexing

sprite_lut	ds.l	slots

; sprite array
sprites		ds.b	s_size*slots
 