screen_ram = $1000  ;4096
colour_ram = $9400  ;37888
screen_ptr1 = $15
screen_ptr2 = $cf
screen_high = $10
screen_to_colour_high = $84

* = $1201
 !byte $0b,$10,$01,$00,$9e,$34,$36,$32,$32,$00,$00,$00  ;sys4622 i.e. $120E
;Note                  sys   4   6   2   2            is sys4622
   brk

!source "code1.asm"
* = $1C00  ;7168
!source "spr.asm"
!source "code2.asm"  ;place code here for 8K+ memory
