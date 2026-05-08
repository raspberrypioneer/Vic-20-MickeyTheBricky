;screen locations for ladders, barrels, etc
data_for_screen_4_setup
!if USE_8k_MEMORY_LAYOUT = 1 {

; 11x ladders
!byte $4E,$10
!byte $96,$10
!byte $EE,$10
!byte $3E,$11
!byte $91,$11
!byte $9E,$10
!byte $F8,$10
!byte $48,$11
!byte $A0,$11
!byte $F2,$0F
!byte $F3,$0F

!byte $00,$00
!byte $35,$10  ;barrel
!byte $20,$00
!byte $00,$DE
!byte $10,$20  ;barrel
!byte $00,$00
!byte $86,$11  ;barrel
!byte $20,$00
!byte $00,$00
!byte $BA,$11  ;mickey
!byte $14,$14

} else {

; 11x ladders
!byte $4E,$1E
!byte $96,$1E
!byte $EE,$1E
!byte $3E,$1F
!byte $91,$1F
!byte $9E,$1E
!byte $F8,$1E
!byte $48,$1F
!byte $A0,$1F
!byte $F2,$1D
!byte $F3,$1D

!byte $00,$00
!byte $35,$1E  ;barrel
!byte $20,$00
!byte $00,$DE
!byte $1E,$20  ;barrel
!byte $00,$00
!byte $86,$1F  ;barrel
!byte $20,$00
!byte $00,$00
!byte $BA,$1F  ;mickey
!byte $14,$14

}