;screen locations for ladders, barrels, etc
data_for_screen_3_setup

; platform
!byte $15, $e2, _SCREEN_HIGH+1
!byte $13, $8f, _SCREEN_HIGH+1
!byte $07, $3b, _SCREEN_HIGH+1
!byte $07, $e7, _SCREEN_HIGH
!byte $0d, $93, _SCREEN_HIGH
!byte $0a, $44, _SCREEN_HIGH
!byte $03, $f7, _SCREEN_HIGH
!byte $09, $45, _SCREEN_HIGH+1

; 9x ladders
screen_3_ladder_data
!byte $f2, _SCREEN_HIGH-1
!byte $f3, _SCREEN_HIGH-1
!byte $95, _SCREEN_HIGH
!byte $ed, _SCREEN_HIGH
!byte $3d, _SCREEN_HIGH+1
!byte $96, _SCREEN_HIGH+1
!byte $4b, _SCREEN_HIGH
!byte $f9, _SCREEN_HIGH
!byte $4b, _SCREEN_HIGH+1

screen_3_runtime_state
!byte $00  ;unused: indexed copy deliberately starts with the following byte
!byte barrel_direction_right
!byte $33, _SCREEN_HIGH  ;barrel 1 screen address
!byte space, barrel_direction_right
!byte barrel_direction_right
!byte $d6, _SCREEN_HIGH  ;barrel 2 screen address
!byte space, barrel_direction_right
!byte barrel_direction_right
!byte $7e, _SCREEN_HIGH+1  ;barrel 3 screen address
!byte space, barrel_direction_right
!byte $00, $00  ;unused state and jump-in-progress flag
!byte $ba, _SCREEN_HIGH+1  ;Mickey screen address
!byte $14, $14  ;characters initially underneath Mickey's head and body
