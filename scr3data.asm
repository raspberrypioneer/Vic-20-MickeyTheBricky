;screen locations for ladders, barrels, etc
data_for_screen_3_setup
!if USE_8k_MEMORY_LAYOUT = 1 {

; platform
!byte $15,$E2,$11
!byte $13,$8F,$11
!byte $07,$3B,$11
!byte $07,$E7,$10
!byte $0D,$93,$10
!byte $0A,$44,$10
!byte $03,$F7,$10
!byte $09,$45,$11

; 9x ladders
!byte $F2,$0F
!byte $F3,$0F
!byte $95,$10
!byte $ED,$10
!byte $3D,$11
!byte $96,$11
!byte $4B,$10
!byte $F9,$10
!byte $4B,$11

!byte $00,$00
!byte $33,$10  ;barrel
!byte $20,$00
!byte $00,$D6
!byte $10,$20  ;barrel
!byte $00,$00
!byte $7E,$11  ;barrel
!byte $20,$00
!byte $00,$00
!byte $BA,$11  ;mickey
!byte $14,$14

} else {

; platform
!byte $15,$E2,$1F
!byte $13,$8F,$1F
!byte $07,$3B,$1F
!byte $07,$E7,$1E
!byte $0D,$93,$1E
!byte $0A,$44,$1E
!byte $03,$F7,$1E
!byte $09,$45,$1F

; 9x ladders
!byte $F2,$1D
!byte $F3,$1D
!byte $95,$1E
!byte $ED,$1E
!byte $3D,$1F
!byte $96,$1F
!byte $4B,$1E
!byte $F9,$1E
!byte $4B,$1F

!byte $00,$00
!byte $33,$1E  ;barrel
!byte $20,$00
!byte $00,$D6
!byte $1E,$20  ;barrel
!byte $00,$00
!byte $7E,$1F  ;barrel
!byte $20,$00
!byte $00,$00
!byte $BA,$1F  ;mickey
!byte $14,$14

}