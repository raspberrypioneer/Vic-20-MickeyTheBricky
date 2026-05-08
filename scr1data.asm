;screen locations for ladders, barrels, etc
data_for_screen_1_setup
!if USE_8k_MEMORY_LAYOUT = 1 {

; 8x ladders
!byte $F3,$0F
!byte $F4,$0F
!byte $3F,$11
!byte $9F,$11
!byte $46,$10
!byte $4C,$10
!byte $97,$10
!byte $F7,$10

!byte $00,$00
!byte $35,$10  ;barrel
!byte $20,$00
!byte $00,$DE
!byte $10,$20  ;barrel
!byte $00,$00
!byte $84,$11  ;barrel
!byte $20,$00
!byte $00,$00
!byte $BA,$11  ;mickey
!byte $14,$14

} else {

; 8x ladders
!byte $F3,$1D
!byte $F4,$1D
!byte $3F,$1F
!byte $9F,$1F
!byte $46,$1E
!byte $4C,$1E
!byte $97,$1E
!byte $F7,$1E

!byte $00,$00  ;15 and 16
!byte $35,$1E  ;barrel
!byte $20,$00
!byte $00,$DE
!byte $1E,$20  ;barrel
!byte $00,$00
!byte $84,$1F  ;barrel
!byte $20,$00
!byte $00,$00
!byte $BA,$1F  ;mickey
!byte $14,$14  ;35 and 36

}
