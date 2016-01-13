		section text

custom_exit:
		move.w	#$01,-(sp)
		move.w	#$80,-(sp)
		move.w	#1,-(sp)		; command length - 1
		move.w	#25,-(sp)		; XBIOS 25 = send to ikbd		
		trap	#13			; call XBIOS
		addq.l	#8,sp			; restore pointer

		rts