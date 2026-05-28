;screen locations for ladders, barrels, etc
data_for_screen_1_setup

; 8x ladders
!byte $f3, _SCREEN_HIGH-1
!byte $f4, _SCREEN_HIGH-1
!byte $3f, _SCREEN_HIGH+1
!byte $9f, _SCREEN_HIGH+1
!byte $46, _SCREEN_HIGH
!byte $4c, _SCREEN_HIGH
!byte $97, _SCREEN_HIGH
!byte $f7, _SCREEN_HIGH

!byte $00, $00  ;in zero page $0f, $10
!byte $35, _SCREEN_HIGH  ;barrel, in zero page $11, $12
!byte $20, $00, $00  ;in zero page $13, $14, $15
!byte $de, _SCREEN_HIGH  ;barrel, in zero page $16, $17
!byte $20, $00, $00  ;in zero page $18, $19, $1a
!byte $84, _SCREEN_HIGH+1  ;barrel, in zero page $1b, $1c
!byte $20, $00, $00, $00  ;in zero page $1d, $1e, $1f, $20
!byte $ba, _SCREEN_HIGH+1  ;mickey, in zero page $21, $22
!byte $14, $14  ;in zero page $23, $24
