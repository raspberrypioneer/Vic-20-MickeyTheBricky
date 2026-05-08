   ldy #5
clear_player_score
   lda #zero_char  ;zero character
   sta data_scroll_message+12, y
   sta player_score, y
   dey
   bpl clear_player_score

start_game
   lda #$80
   sta $56
   ldy #15

.set_vic_chip_registers_x16
   lda data_vic_register_values, y
   sta $9000, y  ;$9000 is the vic chip register
   dey
   bpl .set_vic_chip_registers_x16
   lda #5
   sta player_lives

;TODO: reset
   ldy #1
;   ldy #4

   sty screen_number
   dey
   sty player_is_alive
   sty $9122  ;needed for keyboard input
   dey
   sty $9123  ;needed for keyboard input
   lda #0
   sta $ff
   lda #6
   sta $fd
   sta $fe
   sei
   lda #<interrupt_actions
   sta $0314
   lda #>interrupt_actions
   sta $0315
   cli
   jsr draw_screen_1
   lda #1
   sta music_on_off
   jsr draw_scroll_message
   jsr clear_score

prepare_mickey_start
   ldx #head_look_right  ;head look right character
   jsr todo_common_sub2
   lda #0
   sta music_on_off
   jmp draw_move_barrels

clear_score
   ldy #5

.clear_score_char
   lda #zero_char  ;zero character
   sta player_score, y
   sta screen_ram, y
   dey
   bpl .clear_score_char
   rts

data_vic_register_values
!byte $0C,$26,screen_ptr1,$30,$69,screen_ptr2,$00,$00
!byte $00,$00,$00,$00,$00,$00,$7F,$0E

do_barrel_move
   clc
   ldy #0
   lda $01  ;screen position low byte
   sta $05  ;colour map low byte
   lda $02  ;screen position high byte
   adc #screen_to_colour_high
   sta $06  ;colour map high byte
   lda #7  ;barrel colour yellow (reset back)
   sta ( $05 ), y
   ldy $00
   beq label_1099
   dey
   beq label_10bf
   bne label_10e4

label_1099
   lda $03
   sta ( $01 ), y
   inc $01
   bne label_10a3
   inc $02

label_10a3
   lda ( $01 ), y
   sta $03
   tya
   sta ( $01 ), y
   ldy #21
   lda ( $01 ), y
   cmp #topladder  ;top of ladder character
   beq .is_on_topladder1
   cmp #$2e  ;TODO: head climb ladder?
   bne set_barrel_green_colour

.is_on_topladder1
   ldy #1
   sty $00
   iny
   sty $04
   bpl set_barrel_green_colour

label_10bf
   lda $03
   sta ( $01 ), y
   clc
   lda $01
   adc #21  ;add 21 to get to next line
   sta $01
   bcc label_10ce
   inc $02

label_10ce
   lda ( $01 ), y
   sta $03
   tya
   sta ( $01 ), y
   ldy #21
   lda ( $01 ), y
   cmp #brick  ;platform brick character
   bne set_barrel_green_colour
   ldy $04
   sty $00
   jmp set_barrel_green_colour

label_10e4
   ldy #0
   lda $03
   sta ( $01 ), y
   dec $01
   bne label_10f0
   dec $02

label_10f0
   lda ( $01 ), y
   cmp #wall  ;wall character
   beq label_1111
   sta $03
   tya
   sta ( $01 ), y
   ldy #21
   lda ( $01 ), y
   cmp #$2e  ;TODO: head climb ladder?
   beq label_1107
   cmp #topladder  ;top of ladder character
   bne set_barrel_green_colour

label_1107
   ldy #1
   sty $00
   dey
   sty $04
   jmp set_barrel_green_colour

label_1111
   lda #0
   tay
   sta $00
   lda #zero_char  ;zero character
   sta $01
   lda #screen_high
   sta $02
   lda ( $01 ), y
   sta $03

set_barrel_green_colour
   ldy #0
   clc
   lda $01  ;screen position low byte
   sta $05  ;colour map low byte
   lda $02  ;screen position high byte
   adc #screen_to_colour_high
   sta $06  ;colour map high byte
   lda #5  ;barrel colour green
   sta ( $05 ), y
   rts

setup_barrel_move
   lda #4
   sta $50

.setup_barrel_address
   lda $00, x
   sta $0000, y
   inx
   iny
   dec $50
   bpl .setup_barrel_address
   rts

draw_move_barrels
   ;move top barrel
   ldx #16
   ldy #0
   jsr setup_barrel_move
   jsr do_barrel_move
   ldx #0
   ldy #16
   jsr setup_barrel_move

   ;move middle barrel
   ldx #21
   ldy #0
   jsr setup_barrel_move
   jsr do_barrel_move
   ldx #0
   ldy #21
   jsr setup_barrel_move
   
   ;move bottom barrel
   ldx #$1a
   ldy #0
   jsr setup_barrel_move
   jsr do_barrel_move
   ldx #0
   ldy #$1a
   jsr setup_barrel_move
   ldx $56

.delay_barrel_move
   dey
   bne .delay_barrel_move
   dex
   bne .delay_barrel_move
   jmp player_actions

draw_scroll_message
   ldx #0
   ldy #21
   lda #1  ;colour white

.colour_scroll_message
   sta colour_ram+483, y
   dey
   bpl .colour_scroll_message

.scroll_message
   ldy #1

.draw_scroll_char
   lda screen_ram+483, y
   dey
   sta screen_ram+483, y
   iny
   iny
   cpy #21
   bcc .draw_scroll_char
   lda #20
   sta $51
   lda data_scroll_message, x
   and #$3f
   sta screen_ram+503
   inx
   cpx #$82  ;length of scrolling message
   bne .wait_for_start_input
   ldx #0

.wait_for_start_input
   lda joystick_addr  ;Read joystick address
   and #32  ;Fire button
   beq .clear_scroll_message  ;Fire pressed, go to start game
   lda keyboard_addr  ;Read keyboard address
   and #2  ;Enter key
   beq .clear_scroll_message  ;Enter pressed, go to start game
   dec $50
   bne .wait_for_start_input
   dec $51
   bne .wait_for_start_input
   beq .scroll_message

.clear_scroll_message
   ldy #21

.clear_scroll_message_char
   lda #brick  ;platform brick character
   sta screen_ram+483, y
   lda #2  ;brown colour
   sta colour_ram+483, y  ;$97e3
   dey
   bpl .clear_scroll_message_char
   rts

data_scroll_message
!byte $20,$48,$49,$47,$48,$20,$53,$43  ;  HIGH SC
!byte $4F,$52,$45,$20,$30,$31,$31,$39  ; ORE 0119  High score is saved in scroll_message+12
!byte $30,$30,$20,$23,$23,$23,$23,$23  ; 00 #####
!byte $23,$23,$23,$23,$23,$23,$23,$23  ; ########
!byte $23,$23,$23,$23,$23,$23,$23,$23  ; ########
!byte $20,$46,$49,$52,$45,$42,$49,$52  ;  FIREBIR
!byte $44,$20,$53,$4F,$46,$54,$57,$41  ; D SOFTWA
!byte $52,$45,$20,$50,$52,$45,$53,$45  ; RE PRESE
!byte $4E,$54,$53,$20,$26,$20,$4D,$49  ; NTS ? MI  ? is Micky's head looking right
!byte $43,$4B,$45,$59,$20,$2A,$20,$54  ; CKEY ? T  ? is Micky's head looking left
!byte $48,$45,$20,$42,$52,$49,$43,$4B  ; HE BRICK
!byte $59,$20,$42,$59,$20,$44,$41,$56  ; Y BY DAV
!byte $45,$20,$54,$4F,$4E,$47,$20,$27  ; E TONG ?  ? is copyright circle
!byte $20,$31,$39,$38,$34,$20,$23,$23  ;  1984 ##
!byte $23,$23,$23,$23,$23,$23,$23,$23  ; ########
!byte $23,$23,$23,$23,$23,$23,$23,$23  ; ########
!byte $23,$23                          ; ##

   nop
interrupt_actions
   lda music_on_off
   bne .jump_interrupt
   dec $fe
   bne .jump_interrupt
   lda $fd
   sta $fe
   lda music_speaker3
   beq .play_sound_track_update_bonus
   lda #0
   sta music_speaker3
.jump_interrupt
   jmp $eabf  ;hardware interrupt vector
.play_sound_track_update_bonus
   lda #1
   ldy #21
   eor ($21),y
   cmp #brick
   bmi .l128a
   sta ($21),y
.l128a
   ldx #3
   lda screen_ram+58,x
   sec
   sbc #5  ;subtract 5 from the bonus countdown value
   cmp #zero_char
   bpl .update_bonus_score
.l1296
   adc #10
   sta screen_ram+58,x
   lda #$2f
   dex
   beq .run_out_of_time
   dec screen_ram+58,x
   cmp screen_ram+58,x
   bmi .l12b4
   clc
   bcc .l1296
.run_out_of_time
   lda #1  ;Run out of time, set player not alive
   sta player_is_alive
   bne .l12b4
.update_bonus_score
   sta screen_ram+58,x
.l12b4
   ldy $ff
   iny
   lda data_for_sound,y
   sta music_speaker3
   cpy #$1f
   bmi .sound_end
   ldy #0
.sound_end
   sty $ff
   clc
   bcc .jump_interrupt

data_for_sound
!byte $00,$BE,$AF,$AF,$AF,$BE,$AF,$AF
!byte $AF,$C3,$C3,$BE,$BE,$B8,$94,$94
!byte $94,$C3,$C3,$BE,$BE,$B8,$B8,$CF
!byte $CF,$CA,$C3,$BE,$B8,$AF,$01,$01

update_score
   ldy #4

.start_update_score
   clc
   adc player_score, y
   cmp #$3a  ;check value after #$39 with character number nine
   bpl .update_player_score_next_digits
   sta player_score, y
   ldy #5

.update_player_score_digits
   lda player_score, y
   sta screen_ram, y
   dey
   bpl .update_player_score_digits

.end_update_score
   rts

.update_player_score_next_digits
   sbc #10
   sta player_score, y
   dey
   bmi .end_update_score
   lda #1
   bne .start_update_score

save_y_and_update_score
   sty $50
   jsr .start_update_score
   ldy $50
   rts

label_1315
   tya
   pha
   jsr todo_common_sub1
   pla
   cmp #head_look_left  ;head look left character
   beq label_1336
   cmp #body_walk_left  ;body walk left character
   bne label_1327
   lda #22
   bne label_1329

label_1327
   lda #20

label_1329
   sta $50
   sec
   lda $21
   sbc $50
   sta $21
   bcs label_1336
   dec $22

label_1336
   sei
   lda #$f0
   sta music_speaker3

label_133c
   clc
   lda $21
   adc #21  ;add 21 to get to next line
   sta $21
   bcc label_1347
   inc $22

label_1347
   ldy #0
   lda #space  ;space character
   sta ( $21 ), y
   ldy #21
   lda $55
   sta ( $21 ), y
   ldy #head_look_left  ;head look left character
   sec
   sbc #2
   sta ( $21 ), y
   ldx #0

.delay_loop1
   dey
   bne .delay_loop1
   dex
   bne .delay_loop1
   dec music_speaker3
   ldy #$3f
   lda ( $21 ), y
   tax
   sec
   lda #20
   cpx #space  ;space character
   beq label_133c
   clc
   lda $21
   adc #21  ;add 21 to get to next line
   sta $21
   bcc player_dies_jmp1
   inc $22

player_dies_jmp1
   jmp player_dies

player_dies
   ldy #0
   sty player_is_alive  ;reset alive indicator for next time
   lda #space  ;space character
   sta ( $21 ), y
   ldy #21
   lda #headstone  ;headstone character
   sta ( $21 ), y
   ldy #$fe
   lda #$80
   sei
   sty music_speaker3

.sound_loop_end_life_start
   ldx #6

.sound_delay_end_life
   dey
   bne .sound_delay_end_life
   dex
   bne .sound_delay_end_life
   dec music_speaker3
   cmp music_speaker3
   bmi .sound_loop_end_life_start
   dec player_lives
   bpl draw_screen_using_screen_number
   cli
   jsr update_player_score
   jmp start_game

draw_screen_using_screen_number
   lda screen_number
   clc
   adc screen_number
   tay
   lda data_screen_start_addresses, y
   sta $0200
   iny
   lda data_screen_start_addresses, y
   sta $0201
   lda #>.return_from_jmp
   pha
   lda #<.return_from_jmp
   pha
   jmp ( $0200 )  ;goto screen draw routine
.return_from_jmp
   nop
   sei
   ldy #4
   sty music_speaker3

.sound_loop_2_speakers
   dex
   bne .sound_loop_2_speakers
   dec music_speaker2
   bne .sound_loop_2_speakers
   dey
   bne .sound_loop_2_speakers
   cli
   jmp prepare_mickey_start

data_screen_start_addresses
!byte <draw_screen_1, >draw_screen_1
!byte <draw_screen_1, >draw_screen_1
!byte <draw_screen_2, >draw_screen_2
!byte <draw_screen_3, >draw_screen_3
!byte <draw_screen_4, >draw_screen_4

update_player_score
   ldy #0
   stx $58
   ldx #5

.check_player_score
   lda player_score, y
   cmp data_scroll_message+12, y
   bmi .no_player_score_update
   bne .change_player_score
   iny
   dex
   bpl .check_player_score
   bmi .no_player_score_update

.change_player_score
   ldy #5

.change_player_score_char
   lda player_score, y
   sta data_scroll_message+12, y
   dey
   bpl .change_player_score_char

.no_player_score_update
   ldx $58
   rts

player_actions
   lda $20  ;TODO: $20 might hold an indicator to allow below or not
   beq check_jump_action
   jsr todo_common_sub1
   bcc label_141c

label_1419
   jmp player_dies

label_141c
   ldy #head_look_left  ;head look left character
   lda ( $21 ), y
   bne label_1427
   lda #5
   jsr update_score

label_1427
   lda $21
   adc $27
   sta $21
   bcc label_1431
   inc $22

label_1431
   ldx $55
   jsr todo_common_sub2
   bcs label_1419
   dec $20
   ldy #head_look_left  ;head look left character
   lda ( $21 ), y
   cmp #space  ;space character
   bne label_1445
   jmp label_1315

label_1445
   jmp draw_move_barrels

check_jump_action
   lda joystick_addr  ;Read joystick address
   and #32  ;Fire button
   beq .jump_action
   lda keyboard_addr  ;Read keyboard address
   and #2  ;Enter key
   beq .jump_action
   jmp check_up_direction

.jump_action
   ldy #head_look_left  ;head look left character
   lda ( $21 ), y
   cmp #brick  ;platform brick character
   beq .jump_action_ok
   jmp check_up_direction

.jump_action_ok
   ldy #21
   ldx $55
;TODO: I think this is checking for right direction key press
   lda keyboard_addr  ;Read keyboard address
   and #$80
   beq label_1476
   lda keyboard_addr  ;Read keyboard address
   and #8
   bne check_left_direction

label_1476
   ldx #head_look_right  ;head look right character
   dey

check_left_direction
   lda joystick_addr  ;Read joystick address
   and #16  ;Left direction
   beq .left_direction_ok
   lda keyboard_addr  ;Read keyboard address
   and #16
   bne label_148a

.left_direction_ok
   ldx #head_look_left  ;head look left character
   iny

label_148a
   sty $27
   lda #1
   sta $20
   jsr todo_common_sub1
   bcs label_1419
   sec
   lda $21
   sbc $27
   sta $21
   bcs label_14a0
   dec $22

label_14a0
   lda $27
   tay
   cmp #20
   bne label_14a9
   ldy #22

label_14a9
   cmp #22
   bne label_14af
   ldy #20

label_14af
   sty $27
   jsr todo_common_sub2
   bcc label_14b9
   jmp player_dies

label_14b9
   ldy #head_look_left  ;head look left character
   lda ( $21 ), y
   bne label_14c4
   lda #5
   jsr update_score

label_14c4
   cmp #brick  ;platform brick character
   bne label_14cc
   lda #0
   sta $20

label_14cc
   jmp draw_move_barrels

check_up_direction
   lda joystick_addr  ;Read joystick address
   and #4  ;Up direction
   beq .check_on_ladder
   lda keyboard_addr  ;Read keyboard address
   and #$40
   bne check_down_direction

.check_on_ladder
   lda $24
   cmp #ladder  ;ladder character
   beq .is_on_ladder1
   cmp #topladder  ;top of ladder character
   bne check_down_direction

.is_on_ladder1
   jsr todo_common_sub1
   bcc label_14ef

label_14ec
   jmp player_dies

label_14ef
   sec
   lda $21
   sbc #21  ;subtract 21 to get to line above
   sta $21
   bcs .continue60
   dec $22

.continue60
   ldx #$2e
   jsr todo_common_sub2
   bcs label_14ec
   jmp draw_move_barrels

check_down_direction
   lda joystick_addr  ;Read joystick address
   and #8  ;Down direction
   beq label_1512
   lda keyboard_addr  ;Read keyboard address
   and #32
   bne check_right_direction

label_1512
   ldy #head_look_left  ;head look left character
   lda ( $21 ), y
   cmp #ladder  ;ladder character
   beq .is_on_ladder2
   cmp #topladder  ;top of ladder character
   bne check_right_direction

.is_on_ladder2
   jsr todo_common_sub1
   bcs label_14ec
   clc
   lda $21
   adc #21  ;add 21 to get to next line
   sta $21
   bcc label_152e
   inc $22

label_152e
   ldx #$2e
   jsr todo_common_sub2
   bcs label_14ec

check_right_direction
   lda joystick_addr  ;Read joystick address
;TODO: Why is this the same as left direction? I think this is checking left again!
   and #16  ;Right direction
   beq label_1543
   lda keyboard_addr  ;Read keyboard address
   and #16
   bne label_159d

label_1543
   ldy #20
   lda ( $21 ), y
   cmp #space  ;space character
   beq label_1570
   cmp #ladder  ;ladder character
   beq label_1570
   cmp #hammer  ;hammer character
   bmi label_159d
   cmp #headstone  ;headstone character
   bpl label_159d
   ldy #body_walk_left  ;body walk left character
   lda ( $21 ), y
   cmp #space  ;space character
   bne label_1570
   ldy #$3e
   lda ( $21 ), y
   cmp #space  ;space character
   bne label_1570
   lda #head_look_left  ;head look left character
   sta $55
   ldy #body_walk_left  ;body walk left character
   jmp label_1315

label_1570
   jsr todo_common_sub1
   bcc label_1578
   jmp player_dies

label_1578
   ldy $21
   bne .continue40
   dec $22

.continue40
   dec $21
   ldy #head_look_left  ;head look left character
   lda ( $21 ), y
   cmp #space  ;space character
   bne .continue50
   clc
   lda $21
   adc #21  ;add 21 to get to next line
   sta $21
   bcc .continue50
   inc $22

.continue50
   ldx #head_look_left  ;head look left character
   jsr todo_common_sub2
   bcc label_159d
   jmp player_dies

label_159d
;TODO: I think this is checking for right direction key press
   lda keyboard_addr  ;Read keyboard address
   and #$80
   beq label_15ab
   lda keyboard_addr  ;Read keyboard address
   and #8
   bne label_15ff

label_15ab
   ldy #22
   lda ( $21 ), y
   cmp #space  ;space character
   beq label_15bf
   cmp #ladder  ;ladder character
   beq label_15bf
   cmp #hammer  ;hammer character
   bmi label_15ff
   cmp #headstone  ;headstone character
   bpl label_15ff

label_15bf
   ldy #$2b
   lda ( $21 ), y
   cmp #space  ;space character
   bne label_15d4
   ldy #$40
   lda ( $21 ), y
   cmp #space  ;space character
   bne label_15d4
   ldy #$2b
   jmp label_1315

label_15d4
   jsr todo_common_sub1
   bcc .update_player_address
   jmp player_dies

.update_player_address
   inc $21
   bne .continue10
   inc $22

.continue10
   ldy #head_look_left  ;head look left character
   lda ( $21 ), y
   cmp #space  ;space character
   bne .continue20
   clc
   lda $21
   adc #21  ;add 21 to get to next line
   sta $21
   bcc .continue20
   inc $22

.continue20
   ldx #head_look_right  ;head look right character
   jsr todo_common_sub2
   bcc label_15ff

player_dies_jmp2
   jmp player_dies

label_15ff
   ldy player_is_alive
   bne player_dies_jmp2
   lda ( $21 ), y
   cmp #2
   bmi player_dies_jmp2
   ldy #21
   lda ( $21 ), y
   cmp #2
   bmi player_dies_jmp2
   ldy #head_look_left  ;head look left character
   lda ( $21 ), y
   cmp #space  ;space character
   bne check_got_treasure
   ldy #$3f
   lda ( $21 ), y
   cmp #space  ;space character
   beq label_1631
   jsr todo_common_sub1
   lda $21
   adc #21  ;add 21 to get to next line
   sta $21
   bcc .continue30
   inc $22

.continue30
   jsr todo_common_sub2

label_1631
   ldy #head_look_left  ;head look left character
   jmp label_1315

check_got_treasure
   lda $24
   cmp #hammer  ;hammer character
   bmi .check_reached_end_row
   cmp #headstone  ;headstone character
   bpl .check_reached_end_row
   ;got treasure (hammer, bag, saw) here
   lda #$f5
   sta music_speaker3
   lda #16
   sta $fe
   lda #space  ;space character
   sta $24
   clc
   lda $21  ;screen position low byte
   sta $60  ;colour map low byte
   lda $22  ;screen position high byte
   adc #screen_to_colour_high
   sta $61  ;colour map high byte
   lda #7  ;colour yellow
   ldy #21
   sta ( $60 ), y
   lda #10
   jsr update_score

.check_reached_end_row
   lda $22
   cmp #screen_high
   bne not_at_end_row_so_continue
   lda $21
   cmp #$2a
   bcs not_at_end_row_so_continue
   ldx #3
   ldy #5

increment_score_at_end
   lda screen_ram+56, y
   and #15
   jsr save_y_and_update_score
   dey
   dex
   bne increment_score_at_end
   ldy screen_number
   iny  ;increment screen number for the next screen
   cpy #5
   bne .draw_screen
   clc
   ldy #1  ;reset the screen number back to 1 if all 4 screens completed
   lda $56
   beq .draw_screen
   sbc #8
   sta $56

.draw_screen
   sty screen_number
   jmp draw_screen_using_screen_number

not_at_end_row_so_continue
   jsr label_169c
   jmp draw_move_barrels

label_169c
   lda keyboard_addr  ;Read keyboard address
   and #1
   beq label_16a4
   rts

label_16a4
   lda keyboard_addr  ;Read keyboard address
   and #1
   beq label_16a4

label_16ab
   lda keyboard_addr  ;Read keyboard address
   and #1
   bne label_16ab

label_16b2
   lda keyboard_addr  ;Read keyboard address
   and #1
   beq label_16b2
   rts

todo_common_sub1
   ldy #0
   lda ( $21 ), y
   cmp #2
   bmi label_16d4
   lda $23
   sta ( $21 ), y
   ldy #21
   lda ( $21 ), y
   cmp #2
   bmi label_16d4
   lda $24
   sta ( $21 ), y
   clc
   rts

label_16d4
   sec
   rts

todo_common_sub2
   stx $55
   ldy #0
   lda ( $21 ), y
   sta $23
   txa
   sta ( $21 ), y
   ldy #21
   lda ( $21 ), y
   sta $24
   dex
   txa
   sta ( $21 ), y
   lda #2
   cmp $23
   bpl label_16d4
   cmp $24
   bpl label_16d4
   lda #wall  ;wall character
   cmp $23
   beq label_16d4
   cmp $24
   beq label_16d4
   clc
   rts

data_unknown_hex_1701_255_bytes
!byte $00,$11,$23,$62,$BB,$33,$23,$33
!byte $12,$33,$B1,$23,$A1,$33,$23,$CE
!byte $5D,$4C,$DC,$CF,$F1,$4D,$C5,$64
!byte $FC,$4C,$8C,$DD,$C8,$F9,$CC,$EC
!byte $08,$D8,$EC,$EE,$DE,$CC,$E8,$CC
!byte $5C,$4C,$18,$2C,$BC,$CE,$CE,$1E
!byte $3E,$3B,$19,$32,$33,$83,$15,$1B
!byte $32,$42,$02,$B3,$C6,$3B,$37,$3B
!byte $B3,$33,$18,$43,$22,$33,$B7,$D1
!byte $BB,$F1,$3B,$3B,$21,$13,$F3,$E4
!byte $7C,$C5,$5D,$CC,$CC,$EC,$D2,$E8
!byte $F4,$CC,$EE,$8D,$FE,$CC,$44,$D8
!byte $CD,$2C,$8C,$44,$CC,$A0,$8C,$5C
!byte $7C,$CE,$CD,$CC,$CC,$CC,$9C,$33
!byte $7B,$32,$B3,$32,$06,$E3,$B3,$73
!byte $B3,$33,$39,$B3,$AB,$B1,$BF,$01
!byte $3B,$13,$E6,$33,$37,$A3,$52,$91
!byte $72,$3B,$3B,$33,$3F,$7B,$F4,$C9
!byte $CC,$C4,$C5,$CC,$CC,$CD,$4B,$8E
!byte $BA,$4C,$8C,$A0,$CE,$CC,$54,$A5
!byte $84,$CD,$6C,$0F,$ED,$4D,$CD,$58
!byte $FC,$48,$CB,$DC,$4D,$CD,$7D,$23
!byte $E3,$A1,$F3,$37,$96,$B9,$6A,$5B
!byte $98,$3F,$33,$33,$31,$79,$60,$03
!byte $F3,$3B,$97,$22,$73,$33,$32,$33
!byte $E2,$50,$72,$33,$73,$17,$A3,$CD
!byte $AC,$84,$CE,$CE,$C6,$C9,$BD,$C9
!byte $C6,$89,$FC,$8C,$4E,$5F,$DD,$CC
!byte $CD,$47,$86,$8C,$E8,$26,$CC,$EC
!byte $CF,$D4,$E4,$44,$4E,$0C,$CC,$33
!byte $12,$72,$76,$33,$D3,$23,$31,$B9
!byte $23,$11,$33,$89,$B1,$13,$23

;################################################################################
draw_screen_4
  jsr clear_screen

  ldy #19
  lda #brick  ;platform brick character
.draw_platform_screen_4
  sta screen_ram+63,y
  sta screen_ram+147,y
  sta screen_ram+231,y
  sta screen_ram+315,y
  sta screen_ram+399,y
  sta screen_ram+482,y
  dey
  bne .draw_platform_screen_4

  lda #space  ;space character
  sta screen_ram+414
  sta screen_ram+326
  sta screen_ram+330
  sta screen_ram+153
  sta screen_ram+156
  sta screen_ram+160
  sta screen_ram+236
  sta screen_ram+240
  sta screen_ram+246
  sta screen_ram+320
  sta screen_ram+324
  sta screen_ram+405
  sta screen_ram+408

  ldx #0
.draw_all_ladders_screen_4
  lda data_for_screen_4_setup,x
  sta $21
  inx
  lda data_for_screen_4_setup,x
  sta $22
  jsr draw_single_ladder
  inx
  cpx #22
  bne .draw_all_ladders_screen_4

  jsr colour_in_platforms

  ldy #hammer  ;hammer character
  sty screen_ram+211
  iny  ;bag character
  sty screen_ram+313
  iny  ;saw character
  sty screen_ram+383
  ldy #3  ;colour cyan
  sty colour_ram+211
  iny  ;colour purple
  sty colour_ram+313
  iny  ;colour green
  sty colour_ram+383

  ldx #5
  jsr draw_player_score

  ldx #21
.get_screen_4_data
  lda data_for_screen_4_setup+22,x
  sta $0f,x
  dex
  bne .get_screen_4_data

  lda #0
  tay
  sta ($11),y
  sta ($16),y
  sta ($1b),y
  lda #$1b
  sta $30
  ldy #4
  jsr draw_basic_screen
  lda #0
  sta player_is_alive
  rts

!source "scr4data.asm"

;################################################################################
draw_screen_1
   jsr clear_screen

   ldy #18
.draw_platform_screen_1_x12
   lda #brick  ;platform brick character
   sta screen_ram+149, y
   sta screen_ram+230, y
   sta screen_ram+317, y
   sta screen_ram+398, y
   sta screen_ram+482, y
   dey
   bne .draw_platform_screen_1_x12
   ldy #9

.draw_platform_screen_1_x9
   lda #brick  ;platform brick character
   sta screen_ram+496, y
   sta screen_ram+68, y
   dey
   bne .draw_platform_screen_1_x9

.draw_all_ladders_screen_1
   lda data_for_screen_1_setup, x
   sta $21
   inx
   lda data_for_screen_1_setup, x
   sta $22
   jsr draw_single_ladder
   inx
   cpx #16
   bne .draw_all_ladders_screen_1
   jsr colour_in_platforms
   ldy #hammer  ;hammer character
   sty screen_ram+211
   iny  ;bag character
   sty screen_ram+313
   iny  ;saw character
   sty screen_ram+379
   ldy #3  ;colour cyan
   sty colour_ram+211
   iny  ;colour purple
   sty colour_ram+313
   iny  ;colour green
   sty colour_ram+379
   ldx #5
   jsr draw_player_score

   ldx #21
.get_screen_1_data
   lda data_for_screen_1_setup+16, x
   sta $0f, x
   dex
   bne .get_screen_1_data
   lda #0  ;barrel character
   tay
   sta ( $11 ), y  ;draw barrel character
   sta ( $16 ), y  ;draw barrel character
   sta ( $1b ), y  ;draw barrel character
   lda #$1b
   sta $30
   ldy #4
   jsr draw_basic_screen
   lda #0
   sta player_is_alive
   rts

!source "scr1data.asm"

end_code1