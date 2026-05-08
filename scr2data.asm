;screen locations for ladders, barrels, etc
data_for_screen_2_setup
!if USE_8k_MEMORY_LAYOUT = 1 {

; 11x ladders
!byte $95,$10
!byte $EA,$10
!byte $3D,$11
!byte $92,$11
!byte $B1,$11
!byte $9A,$10
!byte $23,$11
!byte $4C,$10
!byte $DE,$10
!byte $F2,$0F
!byte $F3,$0F

!byte $00,$00
!byte $34,$10  ;barrel
!byte $20,$00
!byte $02,$CB
!byte $10,$20  ;barrel
!byte $00,$00
!byte $9A,$11  ;barrel
!byte $20,$00
!byte $00,$00
!byte $BA,$11  ;mickey
!byte $14,$14

} else {

; 11x ladders
!byte $95,$1E
!byte $EA,$1E
!byte $3D,$1F
!byte $92,$1F
!byte $B1,$1F
!byte $9A,$1E
!byte $23,$1F
!byte $4C,$1E
!byte $DE,$1E
!byte $F2,$1D
!byte $F3,$1D

!byte $00,$00
!byte $34,$1E  ;barrel
!byte $20,$00
!byte $02,$CB
!byte $1E,$20  ;barrel
!byte $00,$00
!byte $9A,$1F  ;barrel
!byte $20,$00
!byte $00,$00
!byte $BA,$1F  ;mickey
!byte $14,$14

}