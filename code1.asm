start_of_program

;clear player score including in the scrolling message
   ldy #5
clear_player_score
   lda #zero_char  ;zero character
   sta data_scroll_message+12,y
   sta player_score,y
   dey
   bpl clear_player_score

start_game
   lda #128
   sta barrel_delay_x

   ldy #15
.set_vic_chip_registers_x16
   lda data_vic_register_values,y
   sta _VICCR0,y
   dey
   bpl .set_vic_chip_registers_x16

   lda #5
   sta player_lives

   ldy #1
   sty screen_number
   dey
   sty player_is_alive
   sty _DATADIR_B  ;needed for keyboard input
   dey
   sty _DATADIR_A  ;needed for keyboard input
   lda #0
   sta sound_pointer
   lda #6
   sta sound_delay1
   sta sound_delay2

   ;set interrupt
   sei
   lda #<interrupt_actions
   sta _IRQ_VECTOR_LOW
   lda #>interrupt_actions
   sta _IRQ_VECTOR_HIGH
   cli

   jsr draw_screen_1
   lda #1
   sta music_on_off
   jsr draw_scroll_message
   jsr clear_score

prepare_mickey_start
   ldx #head_look_right  ;head look right character
   jsr label_common_sub2
   lda #0
   sta music_on_off
   jmp draw_move_barrels

clear_score
   ldy #5
.clear_score_char
   lda #zero_char  ;zero character
   sta player_score,y
   sta _SCREEN_ADDR,y
   dey
   bpl .clear_score_char
   rts

data_vic_register_values
    !byte 12  ;_HORIZONTAL_ALIGNMENT = $9000  ;36864 bits 0-6 horizontal centering, bit 7 sets interlace scan
    !byte 38  ;_VERTICAL_ALIGNMENT = $9001  ;36865 vertical centering
    !byte _VICCR2_VALUE  ;_VICCR2 = $9002  ;36866 see comment below
    !byte 48  ;_VICCR3 = $9003  ;36867 means 48/2 = 24 rows on screen
    !byte 105  ;_VICCR4 = $9004  ;36868
    !byte _VICCR5_VALUE  ;_VICCR5 = $9005  ;36869 see comment below
    !byte 0  ;$9006
    !byte 0  ;$9007
    !byte 0  ;$9008
    !byte 0  ;_VICCR9 = $9009  ;36873
    !byte 0  ;_SOUND1 = $900a  ;36874
    !byte 0  ;_SOUND2 = $900b  ;36875
    !byte 0  ;_SOUND3 = $900c  ;36876
    !byte 0  ;_NOISE = $900d  ;36877
    !byte 127  ;_VOLUME = $900e  ;36878
    !byte 14  ;_BACKGROUND_BORDER_COLOUR = $900f  ;36879

;Location of screen, colour map and character set:
;_VICCR2 bit 7 used with _VICCR5 below (is 0 for 8k, 1 for unexpanded), bits 6-0 is $15 means 21 columns on screen
;_VICCR5 unexpanded ($ff)
;_VICCR5_VALUE = $ff  1111 1111
;7-4 = 1111 + _VICCR2 bit 7 (is 1) means screen is located at $1e00 (7680), and colour map at $9600 (38400)
;3-0 = 1111 means character map is located at $1c00 (7168)
;See MTV page 130
;_VICCR5 8k ($cf)
;7-4 = 1100 + _VICCR2 bit 7 (is 0) means screen is located at $1000 (4096), and colour map at $9400 (37888)
;3-0 = 1111 means character map is located at $1c00 (7168)

do_barrel_move
   clc
   ldy #0
   lda $01  ;screen position low byte
   sta $05  ;colour map low byte
   lda $02  ;screen position high byte
   adc #_OFFSET_TO_COLOUR_RAM
   sta $06  ;colour map high byte
   lda #yellow  ;barrel colour yellow (reset back)
   sta ($05),y  ;set barrel to yellow
   ldy $00
   beq .move_barrel_left_to_right
   dey
   beq .move_barrel_down
   bne .move_barrel_right_to_left

.move_barrel_left_to_right
   lda $03  ;previous value in $01
   sta ($01),y
   inc $01
   bne *+4  ;skip high byte update line below
   inc $02
   lda ($01),y
   sta $03  ;new value in $01 (incremented by 1)
   tya
   sta ($01),y
   ldy #21
   lda ($01),y
   cmp #topladder  ;top of ladder character
   beq .is_on_topladder1
   cmp #head_climb_ladder
   bne set_barrel_green_colour

.is_on_topladder1
   ldy #1
   sty $00
   iny
   sty $04
   bpl set_barrel_green_colour

.move_barrel_down
   lda $03  ;previous value in $01
   sta ($01),y
   clc
   lda $01
   adc #21  ;add 21 to get to next line
   sta $01
   bcc *+4  ;skip high byte update line below
   inc $02
   lda ($01),y
   sta $03  ;new value in $01 (incremented by 21)
   tya
   sta ($01),y
   ldy #21
   lda ($01),y
   cmp #brick  ;platform brick character
   bne set_barrel_green_colour
   ldy $04
   sty $00
   jmp set_barrel_green_colour

.move_barrel_right_to_left
   ldy #0
   lda $03  ;previous value in $01
   sta ($01),y
   dec $01
   bne *+4  ;skip high byte update line below
   dec $02
   lda ($01),y
   cmp #wall  ;wall character
   beq .reached_a_wall
   sta $03  ;new value in $01 (decremented by 1)
   tya
   sta ($01),y
   ldy #21
   lda ($01),y
   cmp #head_climb_ladder
   beq .is_on_topladder2
   cmp #topladder  ;top of ladder character
   bne set_barrel_green_colour

.is_on_topladder2
   ldy #1
   sty $00
   dey
   sty $04
   jmp set_barrel_green_colour

.reached_a_wall
   lda #0
   tay
   sta $00
   lda #48
   sta $01
   lda #_SCREEN_HIGH
   sta $02
   lda ($01),y
   sta $03  ;new value in $01 (#48)

set_barrel_green_colour
   ldy #0
   clc
   lda $01  ;screen position low byte
   sta $05  ;colour map low byte
   lda $02  ;screen position high byte
   adc #_OFFSET_TO_COLOUR_RAM
   sta $06  ;colour map high byte
   lda #green
   sta ($05),y  ;set barrel to green
   rts

setup_barrel_move
   lda #4
   sta $50
.setup_barrel_address_loop
   lda $00,x
   sta $0000,y
   inx
   iny
   dec $50
   bpl .setup_barrel_address_loop
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
   ldx #26
   ldy #0
   jsr setup_barrel_move
   jsr do_barrel_move
   ldx #0
   ldy #26
   jsr setup_barrel_move

   ldx barrel_delay_x
.delay_barrel_move
   dey
   bne .delay_barrel_move
   dex
   bne .delay_barrel_move
   jmp player_actions

draw_scroll_message
   ldx #0
   ldy #21
   lda #white
.colour_scroll_message_loop
   sta _COLOUR_SCREEN_ADDR+483,y
   dey
   bpl .colour_scroll_message_loop

.scroll_message
   ldy #1
.draw_scroll_char_loop
   lda _SCREEN_ADDR+483,y
   dey
   sta _SCREEN_ADDR+483,y
   iny
   iny
   cpy #21
   bcc .draw_scroll_char_loop

   lda #20
   sta $51
   lda data_scroll_message,x
   and #63
   sta _SCREEN_ADDR+503
   inx
   cpx #130  ;length of scrolling message
   bne .wait_for_start_input
   ldx #0

.wait_for_start_input
   lda _JOYSTICK  ;Read joystick address
   and #32  ;Fire button
   beq .clear_scroll_message  ;Fire pressed, go to start game
   lda _KEYB_COLS  ;Read keyboard address
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
   sta _SCREEN_ADDR+483,y
   lda #red
   sta _COLOUR_SCREEN_ADDR+483,y  ;$97e3
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
   dec sound_delay2
   bne .jump_interrupt
   lda sound_delay1
   sta sound_delay2
   lda _SOUND3
   beq .play_sound_track_update_bonus
   lda #0
   sta _SOUND3
.jump_interrupt
   jmp $eabf  ;hardware interrupt vector
.play_sound_track_update_bonus
   lda #1
   ldy #21
   eor (mickey_low),y
   cmp #brick
   bmi .not_character_byte
   sta (mickey_low),y
.not_character_byte
   ldx #3
   lda _SCREEN_ADDR+58,x
   sec
   sbc #5  ;subtract 5 from the bonus countdown value
   cmp #zero_char
   bpl .update_bonus_score
.update_score_digits_loop
   adc #10
   sta _SCREEN_ADDR+58,x
   lda #another_space  ;when 10 added above gives character 9
   dex
   beq .run_out_of_time
   dec _SCREEN_ADDR+58,x
   cmp _SCREEN_ADDR+58,x
   bmi .update_sound
   clc
   bcc .update_score_digits_loop  ;always branch (need to update score digit or run out of time to exit)
.run_out_of_time
   lda #1  ;Run out of time, set player not alive
   sta player_is_alive
   bne .update_sound
.update_bonus_score
   sta _SCREEN_ADDR+58,x
.update_sound
   ldy sound_pointer
   iny
   lda data_for_sound,y
   sta _SOUND3
   cpy #31
   bmi .sound_end
   ldy #0
.sound_end
   sty sound_pointer
   clc
   bcc .jump_interrupt

data_for_sound
!byte $00, $be, $af, $af, $af, $be, $af, $af
!byte $af, $c3, $c3, $be, $be, $b8, $94, $94
!byte $94, $c3, $c3, $be, $be, $b8, $b8, $cf
!byte $cf, $ca, $c3, $be, $b8, $af, $01, $01

update_score
   ldy #4
.start_update_score
   clc
   adc player_score,y
   cmp #58  ;check value after #57 with character number nine
   bpl .update_player_score_next_digits
   sta player_score,y

   ldy #5
.update_player_score_digits
   lda player_score,y
   sta _SCREEN_ADDR,y
   dey
   bpl .update_player_score_digits

.end_update_score
   rts

.update_player_score_next_digits
   sbc #10
   sta player_score,y
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
   jsr label_common_sub1
   pla
   cmp #42
   beq label_1336
   cmp #41
   bne label_1327
   lda #22
   bne label_1329

label_1327
   lda #20

label_1329
   sta $50
   sec
   lda mickey_low
   sbc $50
   sta mickey_low
   bcs *+4  ;skip high byte update line below
   dec mickey_high

label_1336
   sei
   lda #240
   sta _SOUND3

label_133c
   clc
   lda mickey_low
   adc #21  ;add 21 to get to next line
   sta mickey_low
   bcc *+4  ;skip high byte update line below
   inc mickey_high
   ldy #0
   lda #space  ;space character
   sta (mickey_low),y
   ldy #21
   lda $55
   sta (mickey_low),y
   ldy #42
   sec
   sbc #2
   sta (mickey_low),y
   ldx #0

.delay_loop1
   dey
   bne .delay_loop1
   dex
   bne .delay_loop1

   dec _SOUND3
   ldy #63
   lda (mickey_low),y
   tax
   sec
   lda #20
   cpx #space  ;space character
   beq label_133c
   clc
   lda mickey_low
   adc #21  ;add 21 to get to next line
   sta mickey_low
   bcc *+4  ;skip high byte update line below
   inc mickey_high
   jmp player_dies

player_dies
   ldy #0
   sty player_is_alive  ;reset alive indicator for next time
   lda #space  ;space character
   sta (mickey_low),y
   ldy #21
   lda #headstone  ;headstone character
   sta (mickey_low),y
   ldy #254
   lda #128
   sei
   sty _SOUND3

.sound_loop_end_life_start

   ldx #6
.sound_delay_end_life
   dey
   bne .sound_delay_end_life
   dex
   bne .sound_delay_end_life

   dec _SOUND3
   cmp _SOUND3
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
   lda data_screen_start_addresses,y
   sta $0200
   iny
   lda data_screen_start_addresses,y
   sta $0201
   lda #>.return_from_jmp
   pha
   lda #<.return_from_jmp
   pha
   jmp ($0200)  ;goto screen draw routine
.return_from_jmp
   nop
   sei
   ldy #4
   sty _SOUND3

.sound_loop_2_speakers
   dex
   bne .sound_loop_2_speakers
   dec _SOUND2
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
   lda player_score,y
   cmp data_scroll_message+12,y
   bmi .no_player_score_update
   bne .change_player_score
   iny
   dex
   bpl .check_player_score
   bmi .no_player_score_update

.change_player_score

   ldy #5
.change_player_score_char
   lda player_score,y
   sta data_scroll_message+12,y
   dey
   bpl .change_player_score_char

.no_player_score_update
   ldx $58
   rts

player_actions
   lda jump_allowed
   beq check_for_a_jump_action
   jsr label_common_sub1
   bcc .check_for_score_update  ;always branch

goto_player_dies
   jmp player_dies

.check_for_score_update
   ldy #42
   lda (mickey_low),y
   bne .skip_score_update
   lda #5
   jsr update_score  ;score updated by 50 for jumping barrel

.skip_score_update
   lda mickey_low
   adc $27
   sta mickey_low
   bcc *+4  ;skip high byte update line below
   inc mickey_high
   ldx $55
   jsr label_common_sub2
   bcs goto_player_dies
   dec jump_allowed
   ldy #42
   lda (mickey_low),y
   cmp #space  ;space character
   bne goto_move_barrels
   jmp label_1315

goto_move_barrels
   jmp draw_move_barrels

check_for_a_jump_action
   lda _JOYSTICK  ;Read joystick address
   and #32  ;Fire button
   beq .jump_action
   lda _KEYB_COLS  ;Read keyboard address
   and #2  ;Enter key
   beq .jump_action
   jmp check_up_direction

.jump_action
   ldy #42
   lda (mickey_low),y
   cmp #brick  ;platform brick character
   beq .jump_action_ok
   jmp check_up_direction

.jump_action_ok
   ldy #21
   ldx $55
   lda _KEYB_COLS  ;Read keyboard address
   and #128
   beq .jump_right_direction
   lda _KEYB_COLS  ;Read keyboard address
   and #8
   bne check_left_jump

.jump_right_direction
   ldx #head_look_right  ;head look right character
   dey

check_left_jump
   lda _JOYSTICK  ;Read joystick address
   and #16  ;Left direction
   beq .jump_left_direction
   lda _KEYB_COLS  ;Read keyboard address
   and #16
   bne .no_left_right_jump

.jump_left_direction
   ldx #head_look_left  ;head look left character
   iny

.no_left_right_jump
   sty $27
   lda #1
   sta jump_allowed  ;jump not allowed
   jsr label_common_sub1
   bcs goto_player_dies
   sec
   lda mickey_low
   sbc $27
   sta mickey_low
   bcs *+4  ;skip high byte update line below
   dec mickey_high
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
   jsr label_common_sub2
   bcc .check_for_score_update2
   jmp player_dies

.check_for_score_update2
   ldy #42
   lda (mickey_low),y
   bne .skip_score_update2
   lda #5
   jsr update_score  ;score updated by 50 for jumping barrel

.skip_score_update2
   cmp #brick  ;platform brick character
   bne goto_move_barrels2
   lda #0
   sta jump_allowed  ;jump is allowed

goto_move_barrels2
   jmp draw_move_barrels

check_up_direction
   lda _JOYSTICK  ;Read joystick address
   and #4  ;Up direction
   beq .check_on_ladder
   lda _KEYB_COLS  ;Read keyboard address
   and #64
   bne check_down_direction

.check_on_ladder
   lda $24
   cmp #ladder  ;ladder character
   beq .is_on_ladder1
   cmp #topladder  ;top of ladder character
   bne check_down_direction

.is_on_ladder1
   jsr label_common_sub1
   bcc .update_climbing_ladder

goto_player_dies2
   jmp player_dies

.update_climbing_ladder
   sec
   lda mickey_low
   sbc #21  ;subtract 21 to get to next row above
   sta mickey_low
   bcs *+4  ;skip high byte update line below
   dec mickey_high
   ldx #head_climb_ladder
   jsr label_common_sub2
   bcs goto_player_dies2
   jmp draw_move_barrels

check_down_direction
   lda _JOYSTICK  ;Read joystick address
   and #8  ;Down direction
   beq .move_down_direction
   lda _KEYB_COLS  ;Read keyboard address
   and #32
   bne .check_left_direction

.move_down_direction
   ldy #42
   lda (mickey_low),y
   cmp #ladder  ;ladder character
   beq .is_on_ladder2
   cmp #topladder  ;top of ladder character
   bne .check_left_direction

.is_on_ladder2
   jsr label_common_sub1
   bcs goto_player_dies2
   clc
   lda mickey_low
   adc #21  ;add 21 to get to next line
   sta mickey_low
   bcc *+4  ;skip high byte update line below
   inc mickey_high
   ldx #head_climb_ladder
   jsr label_common_sub2
   bcs goto_player_dies2

.check_left_direction
   lda _JOYSTICK  ;Read joystick address
   and #16  ;Right direction
   beq .joystick_left_direction
   lda _KEYB_COLS  ;Read keyboard address
   and #16
   bne .check_right_direction

.joystick_left_direction
   ldy #20
   lda (mickey_low),y
   cmp #space  ;space character
   beq label_1570
   cmp #ladder  ;ladder character
   beq label_1570
   cmp #hammer  ;hammer character
   bmi .check_right_direction
   cmp #headstone  ;headstone character
   bpl .check_right_direction
   ldy #41
   lda (mickey_low),y
   cmp #space  ;space character
   bne label_1570
   ldy #62
   lda (mickey_low),y
   cmp #space  ;space character
   bne label_1570
   lda #head_look_left  ;head look left character
   sta $55
   ldy #41
   jmp label_1315

label_1570
   jsr label_common_sub1
   bcc label_1578
   jmp player_dies

label_1578
   ldy mickey_low
   bne *+4  ;skip high byte update line below
   dec mickey_high
   dec mickey_low
   ldy #42
   lda (mickey_low),y
   cmp #space  ;space character
   bne .continue50
   clc
   lda mickey_low
   adc #21  ;add 21 to get to next line
   sta mickey_low
   bcc *+4  ;skip high byte update line below
   inc mickey_high

.continue50
   ldx #head_look_left  ;head look left character
   jsr label_common_sub2
   bcc .check_right_direction
   jmp player_dies

.check_right_direction
   lda _KEYB_COLS  ;Read keyboard address
   and #128
   beq .move_right_direction
   lda _KEYB_COLS  ;Read keyboard address
   and #8
   bne label_15ff

.move_right_direction
   ldy #22
   lda (mickey_low),y
   cmp #space  ;space character
   beq .move_along_or_next_to_ladder
   cmp #ladder  ;ladder character
   beq .move_along_or_next_to_ladder
   cmp #hammer  ;hammer character
   bmi label_15ff
   cmp #headstone  ;headstone character
   bpl label_15ff

.move_along_or_next_to_ladder
   ldy #43
   lda (mickey_low),y
   cmp #space  ;space character
   bne .not_a_space2
   ldy #64
   lda (mickey_low),y
   cmp #space  ;space character
   bne .not_a_space2
   ldy #43
   jmp label_1315

.not_a_space2
   jsr label_common_sub1
   bcc .update_player_address
   jmp player_dies

.update_player_address
   inc mickey_low
   bne *+4  ;skip high byte update line below
   inc mickey_high
   ldy #42
   lda (mickey_low),y
   cmp #space  ;space character
   bne .not_a_space
   clc
   lda mickey_low
   adc #21  ;add 21 to get to next line
   sta mickey_low
   bcc *+4  ;skip high byte update line below
   inc mickey_high

.not_a_space
   ldx #head_look_right  ;head look right character
   jsr label_common_sub2
   bcc label_15ff

goto_player_dies3
   jmp player_dies

label_15ff
   ldy player_is_alive
   bne goto_player_dies3
   lda (mickey_low),y
   cmp #2
   bmi goto_player_dies3
   ldy #21
   lda (mickey_low),y
   cmp #2
   bmi goto_player_dies3
   ldy #42
   lda (mickey_low),y
   cmp #space  ;space character
   bne check_got_treasure
   ldy #63
   lda (mickey_low),y
   cmp #space  ;space character
   beq .space_ahead_continue
   jsr label_common_sub1
   lda mickey_low
   adc #21  ;add 21 to get to next line
   sta mickey_low
   bcc *+4  ;skip high byte update line below
   inc mickey_high
   jsr label_common_sub2

.space_ahead_continue
   ldy #42
   jmp label_1315

check_got_treasure
   lda $24
   cmp #hammer  ;hammer character
   bmi .check_reached_end_row
   cmp #headstone  ;headstone character
   bpl .check_reached_end_row
   ;got treasure (hammer, bag, saw) here
   lda #245
   sta _SOUND3
   lda #16
   sta sound_delay2
   lda #space  ;space character
   sta $24
   clc
   lda mickey_low
   sta $60  ;colour map low byte
   lda mickey_high
   adc #_OFFSET_TO_COLOUR_RAM
   sta $61  ;colour map high byte
   lda #yellow
   ldy #21
   sta ($60),y  ;update map at Mickey colour map position + 21
   lda #10
   jsr update_score  ;score updated by 100 for treasure

.check_reached_end_row
   lda mickey_high
   cmp #_SCREEN_HIGH
   bne .not_at_end_row_so_continue
   lda mickey_low
   cmp #42
   bcs .not_at_end_row_so_continue
   ldx #3
   ldy #5

increment_score_at_end
   lda _SCREEN_ADDR+56,y
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
   lda barrel_delay_x
   beq .draw_screen
   sbc #8
   sta barrel_delay_x

.draw_screen
   sty screen_number
   jmp draw_screen_using_screen_number

.not_at_end_row_so_continue
   jsr label_169c
   jmp draw_move_barrels

;TODO: I think this might be a pause
label_169c
   lda _KEYB_COLS  ;Read keyboard address
   and #1
   beq label_16a4
   rts

label_16a4
   lda _KEYB_COLS  ;Read keyboard address
   and #1
   beq label_16a4

label_16ab
   lda _KEYB_COLS  ;Read keyboard address
   and #1
   bne label_16ab

label_16b2
   lda _KEYB_COLS  ;Read keyboard address
   and #1
   beq label_16b2
   rts

label_common_sub1
   ldy #0
   lda (mickey_low),y
   cmp #2
   bmi .set_carry_and_return
   lda $23
   sta (mickey_low),y
   ldy #21
   lda (mickey_low),y
   cmp #2
   bmi .set_carry_and_return
   lda $24
   sta (mickey_low),y
   clc
   rts

.set_carry_and_return
   sec
   rts

label_common_sub2
   stx $55  ;X is mickey head new value
   ldy #0
   lda (mickey_low),y
   sta $23  ;mickey head previous value
   txa
   sta (mickey_low),y  ;mickey head new value
   ldy #21  ;TODO line below?
   lda (mickey_low),y
   sta $24  ;mickey body previous value
   dex
   txa
   sta (mickey_low),y  ;mickey body new value

   lda #2
   cmp $23
   bpl .set_carry_and_return
   cmp $24
   bpl .set_carry_and_return
   lda #wall  ;wall character
   cmp $23
   beq .set_carry_and_return
   cmp $24
   beq .set_carry_and_return
   clc
   rts

data_junk_hex_1701_255_bytes
    !byte $00,$11,$23,$62,$bb,$33,$23,$33
    !byte $12,$33,$b1,$23,$a1,$33,$23,$ce
    !byte $5d,$4c,$dc,$cf,$f1,$4d,$c5,$64
    !byte $fc,$4c,$8c,$dd,$c8,$f9,$cc,$ec
    !byte $08,$d8,$ec,$ee,$de,$cc,$e8,$cc
    !byte $5c,$4c,$18,$2c,$bc,$ce,$ce,$1e
    !byte $3e,$3b,$19,$32,$33,$83,$15,$1b
    !byte $32,$42,$02,$b3,$c6,$3b,$37,$3b
    !byte $b3,$33,$18,$43,$22,$33,$b7,$d1
    !byte $bb,$f1,$3b,$3b,$21,$13,$f3,$e4
    !byte $7c,$c5,$5d,$cc,$cc,$ec,$d2,$e8
    !byte $f4,$cc,$ee,$8d,$fe,$cc,$44,$d8
    !byte $cd,$2c,$8c,$44,$cc,$a0,$8c,$5c
    !byte $7c,$ce,$cd,$cc,$cc,$cc,$9c,$33
    !byte $7b,$32,$b3,$32,$06,$e3,$b3,$73
    !byte $b3,$33,$39,$b3,$ab,$b1,$bf,$01
    !byte $3b,$13,$e6,$33,$37,$a3,$52,$91
    !byte $72,$3b,$3b,$33,$3f,$7b,$f4,$c9
    !byte $cc,$c4,$c5,$cc,$cc,$cd,$4b,$8e
    !byte $ba,$4c,$8c,$a0,$ce,$cc,$54,$a5
    !byte $84,$cd,$6c,$0f,$ed,$4d,$cd,$58
    !byte $fc,$48,$cb,$dc,$4d,$cd,$7d,$23
    !byte $e3,$a1,$f3,$37,$96,$b9,$6a,$5b
    !byte $98,$3f,$33,$33,$31,$79,$60,$03
    !byte $f3,$3b,$97,$22,$73,$33,$32,$33
    !byte $e2,$50,$72,$33,$73,$17,$a3,$cd
    !byte $ac,$84,$ce,$ce,$c6,$c9,$bd,$c9
    !byte $c6,$89,$fc,$8c,$4e,$5f,$dd,$cc
    !byte $cd,$47,$86,$8c,$e8,$26,$cc,$ec
    !byte $cf,$d4,$e4,$44,$4e,$0c,$cc,$33
    !byte $12,$72,$76,$33,$d3,$23,$31,$b9
    !byte $23,$11,$33,$89,$b1,$13,$23

;################################################################################
draw_screen_4
  jsr clear_screen

  ldy #19
  lda #brick  ;platform brick character
.draw_platform_screen_4
  sta _SCREEN_ADDR+63,y
  sta _SCREEN_ADDR+147,y
  sta _SCREEN_ADDR+231,y
  sta _SCREEN_ADDR+315,y
  sta _SCREEN_ADDR+399,y
  sta _SCREEN_ADDR+482,y
  dey
  bne .draw_platform_screen_4

  lda #space  ;space character
  sta _SCREEN_ADDR+414
  sta _SCREEN_ADDR+326
  sta _SCREEN_ADDR+330
  sta _SCREEN_ADDR+153
  sta _SCREEN_ADDR+156
  sta _SCREEN_ADDR+160
  sta _SCREEN_ADDR+236
  sta _SCREEN_ADDR+240
  sta _SCREEN_ADDR+246
  sta _SCREEN_ADDR+320
  sta _SCREEN_ADDR+324
  sta _SCREEN_ADDR+405
  sta _SCREEN_ADDR+408

  ldx #0
.draw_all_ladders_screen_4
  lda data_for_screen_4_setup,x
  sta mickey_low
  inx
  lda data_for_screen_4_setup,x
  sta mickey_high
  jsr draw_single_ladder
  inx
  cpx #22
  bne .draw_all_ladders_screen_4

  jsr colour_in_platforms

  ldy #hammer  ;hammer character
  sty _SCREEN_ADDR+211
  iny  ;bag character
  sty _SCREEN_ADDR+313
  iny  ;saw character
  sty _SCREEN_ADDR+383
  ldy #cyan
  sty _COLOUR_SCREEN_ADDR+211
  iny  ;colour purple
  sty _COLOUR_SCREEN_ADDR+313
  iny  ;colour green
  sty _COLOUR_SCREEN_ADDR+383

  ldx #5
  jsr draw_player_score

  ldx #21
.set_screen_4_zero_page_data
  lda data_for_screen_4_setup+22,x
  sta $0f,x
  dex
  bne .set_screen_4_zero_page_data

  lda #barrel
  tay
  sta (barrel1_low),y
  sta (barrel2_low),y
  sta (barrel3_low),y
  lda #27
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
   sta _SCREEN_ADDR+149,y
   sta _SCREEN_ADDR+230,y
   sta _SCREEN_ADDR+317,y
   sta _SCREEN_ADDR+398,y
   sta _SCREEN_ADDR+482,y
   dey
   bne .draw_platform_screen_1_x12

   ldy #9
.draw_platform_screen_1_x9
   lda #brick  ;platform brick character
   sta _SCREEN_ADDR+496,y
   sta _SCREEN_ADDR+68,y
   dey
   bne .draw_platform_screen_1_x9

.draw_all_ladders_screen_1
   lda data_for_screen_1_setup,x
   sta mickey_low
   inx
   lda data_for_screen_1_setup,x
   sta mickey_high
   jsr draw_single_ladder
   inx
   cpx #16
   bne .draw_all_ladders_screen_1
   jsr colour_in_platforms
   ldy #hammer  ;hammer character
   sty _SCREEN_ADDR+211
   iny  ;bag character
   sty _SCREEN_ADDR+313
   iny  ;saw character
   sty _SCREEN_ADDR+379
   ldy #cyan
   sty _COLOUR_SCREEN_ADDR+211
   iny  ;colour purple
   sty _COLOUR_SCREEN_ADDR+313
   iny  ;colour green
   sty _COLOUR_SCREEN_ADDR+379
   ldx #5
   jsr draw_player_score

   ldx #21
.set_screen_1_zero_page_data
   lda data_for_screen_1_setup+16,x
   sta $0f,x
   dex
   bne .set_screen_1_zero_page_data

   lda #barrel
   tay
   sta (barrel1_low),y  ;draw barrel character
   sta (barrel2_low),y  ;draw barrel character
   sta (barrel3_low),y  ;draw barrel character
   lda #27
   sta $30
   ldy #4
   jsr draw_basic_screen
   lda #0
   sta player_is_alive
   rts

!source "scr1data.asm"
