
; These are not dynamic. Use just for legibility.

tile_w:		equ	16
tile_h:		equ	16

map_w:		equ	20
map_h:		equ	15


		section text
		even
		
chequer_map:	movem.l	d0-a6,-(sp)
		
		move.l	#255,d0			; need to init two tiles
		lea	tile_data,a0
		move.w	#$ffff,d1

chequer_l:	move.w	d1,(a0)+		; first tile is white
		dbf	d0,chequer_l

		move.l	#255,d0
chequer_l2:	move.w	#$1f,(a0)+		; second is blue
		dbf	d0,chequer_l2	


		moveq.w	#1,d2
		move.w	#map_h-1,d0		; loop over map		
		lea	tile_map,a0

chequer_l3:	move.w	#map_w-1,d1		
		
chequer_l4:	move.b	d2,(a0)+		; fill map with 0/1
		not.b	d2
		and.b	#1,d2
		
		dbf	d1,chequer_l4		; loop x
		
		not.b	d2
		and.b	#1,d2
		dbf	d0,chequer_l3		; loop y
		
		movem.l	(sp)+,d0-a6
		rts




draw_tile:	movem.l	d0-a6,-(sp)		; draw tile d0 at d1,d2
						; to a0. This is not fast		
		lea	tile_data,a1		

		mulu.l	#256*2,d0		; offset to tile
		adda.l	d0,a1

		mulu.l	#16*2,d1		; offset to x-position
		adda.l	d1,a0

		mulu.l	#16*16*map_w*2,d2	; offset to y-position
		adda.l	d2,a0

		move.w	#15,d1			; draw row at a time

draw_tile_l:	
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
		dbf	d1,draw_tile_l
		
		movem.l	(sp)+,d0-a6
		rts




draw_map_test:					; draws the top 3x2
		movem.l	d0-a6,-(sp)

		moveq.b	#0,d0
		moveq.w	#0,d1
		moveq.w	#0,d2
		bsr	draw_tile

		moveq.b	#1,d0
		moveq.w	#1,d1
		bsr	draw_tile

		moveq.b	#0,d0
		moveq.w	#2,d1
		bsr	draw_tile

		moveq.b	#1,d0
		moveq.w	#1,d2
		bsr	draw_tile

		moveq.b	#0,d0
		moveq.w	#1,d1
		bsr	draw_tile

		moveq.b	#1,d0
		moveq.w	#0,d1
		bsr	draw_tile		

		movem.l	(sp)+,d0-a6
		rts




draw_map:	movem.l	d0-a6,-(sp)
		moveq.l	#0,d0

		lea	tile_bg,a0
		lea	tile_map,a1

		move.l	#map_h-1,d2		; init the map loop

draw_map_l:	move.l	#map_w-1,d1
		
		
draw_map_l2:	move.b	(a1),d0			; get the tile number

		bsr	draw_tile		; draw it

		adda.l	#1,a1
		dbf	d1,draw_map_l2		; loop-x
		dbf	d2,draw_map_l		; loop-y

		movem.l	(sp)+,d0-a6
		rts




draw_tile_bg:	movem.l	d0/a0-a1,-(sp)
		
		lea	tile_bg,a0
		move.l	screen_adr,a1

		move.l	#scr_h,d0

dtbg1:		
	
		REPT	scr_w/32

		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+

		ENDR
		
		dbf	d0,dtbg1
		
		movem.l	(sp)+,d0/a0-a1
		rts


		section bss

		even

tile_map:	ds.b	map_w*map_h
tile_data:	ds.w	64*16*16		; only supporting 64
tile_bg:	ds.b	scr_w*scr_h*2