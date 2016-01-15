
		section text
		
rand:		movem.l	d1-d2/a0-a2,-(sp)
		move.w	#17,-(sp)		; 17 is rand
		trap	#14			; call XBIOS
		addq.l	#2,sp
		movem.l	(sp)+,d1-d2/a0-a2
		rts
		