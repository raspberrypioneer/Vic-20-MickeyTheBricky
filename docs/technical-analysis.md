# Mickey the Bricky technical analysis

Mickey the Bricky is a character-based platform game for the unexpanded Commodore VIC-20. Mickey
climbs four construction-site screens, avoids three continuously moving barrels, collects tools and
reaches the top before the bonus expires. This source can also build an 8K+ version which relocates
the program and display while preserving the original game logic.

This document describes the program architecture, memory layouts, game systems and original
anomalies which must remain intact for a byte-identical unexpanded build.

## Program structure

The BASIC stub enters `start_of_program`, which clears the stored score and high score. `start_game`
then configures the VIC, initialises the game state, installs the music interrupt and draws the first
screen. The title message scrolls along the bottom platform until fire or Return is pressed.

```text
BASIC SYS stub
    |
    v
start_of_program
    -> clear current and displayed high score
    |
    v
start_game
    -> configure VIC and VIA registers
    -> initialise lives, screen number, sound and IRQ vector
    -> draw_screen_1
    -> scroll_message_and_wait_to_start
    |
    v
prepare_mickey_start
    -> draw Mickey at the level start position
    |
    v
draw_move_barrels
    -> move all three barrels
    -> apply the barrel-speed busy wait
    -> player_actions
       -> continue a jump, or read movement/jump input
       -> erase Mickey and restore underlying characters
       -> update his screen address
       -> draw Mickey and detect collisions
       -> collect treasure or check for screen completion
       -> draw_move_barrels
```

There is no conventional frame interrupt or raster synchronisation. The main loop alternates one
movement opportunity for each barrel with one player-input/action pass. A nested busy wait controlled
by `frame_delay` regulates the overall speed. The IRQ routine independently animates Mickey's legs,
plays the tune and reduces the displayed bonus.

Death draws a headstone and plays a descending tone with interrupts disabled. If a life remains, the
current screen is reconstructed from its drawing routine and setup table. Otherwise the score is
compared with the high score and the game returns to its initial title state.

## Memory maps

The VIC-20 changes its BASIC and screen-memory arrangement when RAM is installed in block 1. The two
builds therefore place the loader, code and screen at different addresses. The custom character set
remains fixed at `$1c00`.

| Purpose | Unexpanded | 8K+ expanded |
|---|---:|---:|
| PRG load address / BASIC stub | `$1001-$100d` | `$1201-$120d` |
| Machine-code entry | `$100e` (`SYS 4110`) | `$120e` (`SYS 4622`) |
| `code1.asm` code/data | `$100e-$196a` | `$120e-$1b6a` |
| Layout padding | — | `$1b6b-$1bff` |
| Custom characters | `$1c00-$1dff` | `$1c00-$1dff` |
| `code2.asm` code/data | `$196b-$1bff` | `$1e00-$2094` |
| Screen RAM | `$1e00-$1fff` | `$1000-$11ff` |
| Colour RAM | `$9600-$97ff` | `$9400-$95ff` |

In the unexpanded build, `code1.asm` and `code2.asm` are assembled consecutively below `$1c00`, then
`spr.asm` supplies the character bitmaps at `$1c00`. In the expanded build, `code1.asm` is followed by
the bitmaps at `$1c00`, after which `code2.asm` continues at `$1e00`. Labels allow calls and data
references to cross this source-level split without runtime relocation.

The expanded program requires RAM in the VIC-20 `$1000-$1fff` expansion block. “8K+” does not mean
that any independently addressed 8K cartridge configuration will work.

### VIC memory selection

At startup, `data_vic_register_values` supplies all 16 registers at `$9000-$900f`. Register `$9002`
sets the 21-column display width and contributes one screen-address bit; `$9005` selects screen and
character memory.

| Build | `$9002` | `$9005` | Result |
|---|---:|---:|---|
| Unexpanded | `$95` | `$ff` | screen `$1e00`, colour `$9600`, characters `$1c00` |
| 8K+ | `$15` | `$cf` | screen `$1000`, colour `$9400`, characters `$1c00` |

The screen has 21 columns and 24 rows, so 504 of the 512 screen bytes are visible. Clearing and
platform-colouring deliberately process the full 512-byte area.

### Low-memory state

The program uses zero page and parts of BASIC/KERNAL workspace as compact game storage.

| Address | Purpose |
|---:|---|
| `$00-$06` | Temporary barrel record and derived colour-RAM pointer |
| `$0f-$24` | Screen-specific object state, including three five-byte barrel records and Mickey's pointer/history |
| `$20` | Jump-in-progress flag; also part of the copied screen setup block |
| `$21-$22` | Mickey screen pointer; reused as the ladder drawing pointer during setup |
| `$23-$24` | Characters formerly beneath Mickey's head and body |
| `$27` | Horizontal component of a jump, encoded as screen delta 20, 21 or 22 |
| `$28` | Collision/death flag set by a barrel |
| `$30` | Screen-state value initialised to 27; its precise wider purpose is not established |
| `$40-$41` | Remaining-lives value and screen number |
| `$50-$61` | Contextual counters, saved registers and temporary colour pointers |
| `$54` | Music-disable flag |
| `$56` | Main-loop/barrel delay |
| `$fd-$ff` | Music delays and sound-table index |
| `$0200-$0201` | Indirect destination used to dispatch a screen drawing routine |
| `$033c-$0341` | Six screen-code digits holding the player's score |

Several locations are intentionally reused. In particular, the screen setup records are copied into
`$10-$24`, while short routines also use nearby locations as scratch storage. Labels should describe
the meaning within a routine rather than imply that every byte has one permanent global role.

## Character display and graphics

The VIC-20 has no hardware sprites. The names “sprite” in the source refer to redefined character
glyphs. `spr.asm` provides 64 eight-byte characters at `$1c00`:

- character 0 is the barrel;
- characters 1-26 are letters for the title message;
- characters 27-35 are tools, scenery and platforms;
- characters 36-46 are Mickey's standing, walking and climbing frames;
- characters 47-57 include spacing and decimal digits;
- the remaining characters are blank or retained unidentified data.

Mickey occupies two vertically adjacent cells. His pointer addresses his head and offset 21 addresses
his body. Before moving him, `restore_mickey_and_check_collision` restores the characters which were
underneath those two cells. After movement, `draw_mickey_and_check_collision` saves the new underlying
characters and writes the new head/body pair. Walking animation is obtained by toggling the low bit
of the body character from the IRQ routine.

The display itself is also the collision map. There is no separate logical playfield: character zero
identifies a barrel, characters 27-29 identify collectible tools, 31 is a wall, 32 is open space, 33
and 34 are ladder sections, and 35 is a platform brick. Movement code examines the cells around
Mickey before modifying his screen pointer.

## Screen construction and setup data

Each of the four screens has a specialised drawing routine. This saves the memory that a complete
504-byte map for each level would require. The routines clear the display, draw repeated platform
runs, construct ladders until they meet a non-space character, place the three treasures and finally
draw the common score, bonus, lives and screen-number fields.

The corresponding `scr1data.asm` through `scr4data.asm` files contain:

- addresses from which ladders are grown downwards;
- initial screen pointers and movement state for three barrels;
- Mickey's initial screen pointer;
- initial characters to restore beneath Mickey.

Every stored high byte is expressed relative to `_SCREEN_HIGH`. The same data therefore points into
the `$1e00` screen in the unexpanded build and the `$1000` screen in the expanded build.
Each runtime block has a `screen_N_runtime_state` label, and the assembly derives the preceding ladder
data length from that label instead of repeating numeric offsets. Named barrel-record fields at
`$10-$1e` document where the indexed setup copy places each byte.

Screen dispatch is performed by loading an address from `data_screen_start_addresses` into `$0200`
and jumping indirectly. The caller manually places a return address on the processor stack. It pushes
the address of a deliberate `NOP`; because `RTS` increments the pulled address, execution resumes
immediately after that `NOP`. The table includes an unused screen-zero entry duplicating screen one,
allowing the one-based screen number to be doubled directly into a byte offset.

## Barrels

Each barrel uses a five-byte state record:

| Offset | Meaning |
|---:|---|
| 0 | movement mode: right, down or left |
| 1-2 | current screen address |
| 3 | character formerly beneath the barrel |
| 4 | horizontal direction to resume after descending |

`draw_move_barrels` copies each persistent record into `$00-$04`, calls the common movement routine,
then copies it back. A barrel restores its previous cell, adjusts its pointer and saves the character
at the destination before drawing character zero there.

Barrels reverse only through the level geometry encoded in the screen. Encountering a top-of-ladder
character changes the movement mode to down; hitting the platform below changes it back to the saved
horizontal direction. A left-moving barrel which reaches a wall is reset to screen offset 48 near the
top of the level. Its colour is changed to yellow while the old cell is restored and to green at its
new position.

Because both barrels and Mickey temporarily replace background characters, each stores what was under
it. Their collision routines treat character codes 0 and 1 as fatal object overlap. The ordering of
erase, move, save and draw operations is therefore part of gameplay and should not be rearranged even
if a refactor appears logically equivalent.

## Player movement, collision and treasure

Joystick directions are read from VIA registers `$9111` and `$9120`; keyboard matrix bits provide
parallel controls. Fire or Return begins a jump. Horizontal movement checks the body-side cell and
may move Mickey diagonally down one row when the next supporting cell is empty. If no nearby support
exists, `mickey_falls_off_platform` animates a longer fall and kills the player on landing.

A jump is a two-pass state machine. The first pass moves the two-cell character up-left, straight up
or up-right and records the inverse delta. The next visit to `player_actions` applies that inverse as
the downward half. `jump_in_progress` records which half of this two-pass action is active.

Moving onto character 27, 28 or 29 collects the hammer, bag or saw, awards 100 points and replaces
the remembered background character with space. Jumping over a barrel awards 50 points when the cell
two rows below Mickey contains character zero.

Mickey completes a screen when his head pointer is in the first screen page and has a low byte below
42. Three displayed bonus digits are converted back to numeric values and added to the score. Screen
five wraps to screen one and attempts to reduce `frame_delay` for the next circuit.

## Score, bonus and lives

Scores are stored as six character codes rather than binary or packed BCD. `update_score` begins at
the tens digit, adds a value, carries at character code 58 and redraws all six digits. Consequently an
argument of 5 awards 50 points and an argument of 10 awards 100 points.

The title message contains another six-character score field. At game over, `update_player_score`
compares the player score with this field from most significant to least significant digit and copies
it when the player score is larger. Both score fields are cleared at program startup, so the high
score does not survive reloading or resetting the program.

The bonus starts at 995. Every music update subtracts five from its least-significant displayed digit,
borrowing through the other two digits. Reaching zero sets `player_death_pending`, causing the next
main-loop collision pass to enter the death sequence.

`player_lives` starts at five and is shown directly. Death decrements it and continues while the
signed result is non-negative, so the player receives attempts labelled 5, 4, 3, 2, 1 and 0 before
game over. This is consistent with treating the displayed number as spare lives rather than total
attempts, but it can look like an off-by-one error.

## Interrupt-driven music and timing

The game replaces the IRQ vector at `$0314-$0315` with `interrupt_actions`, then chains to the normal
KERNAL continuation at `$eabf`. The system IRQ entry has already preserved the registers needed by
the handler.

When music is enabled, two software dividers pace the routine. On an update it:

1. toggles Mickey's body animation if the saved background/body state is suitable;
2. subtracts five from the three-digit bonus;
3. advances through a 32-byte frequency table;
4. alternates the soprano voice between silence and the next note.

Death, falling and level-transition effects temporarily disable interrupts and drive one or two VIC
voices directly. The game does not restore the previous IRQ vector or VIC/VIA state because it has no
clean exit back to BASIC.

## Preserved anomalies and implementation quirks

The following observations describe assembled original behaviour. They should remain unchanged in
the reproduction build unless an explicitly separate patched edition is introduced.

- `draw_screen_1` enters its ladder-data loop without initialising `X`. Later screen-redraw paths
  happen to arrive with `X = 0`, while the first call relies on the register state inherited from the
  BASIC `SYS` path. Explicit `LDX #0` would be safer but would change the original bytes and could
  move all following code.
- After completing screen four, the speed update executes `CLC` before `SBC #8`. On a 6502 this
  subtracts nine, not eight. Starting from 128 gives delays 128, 119, 110 and so on; it reaches 2 and
  then wraps to 249 rather than reaching zero. The game therefore becomes abruptly slow again after
  enough four-screen circuits.
- The pause test reads an entire keyboard-column bit without selecting a single key. As its source
  comment notes, several keys can trigger it. The pause loop leaves IRQs enabled, so music and the
  bonus countdown continue while play is paused.
- Screen drawing uses a synthetic subroutine return: it pushes a label rather than the conventional
  label-minus-one and relies on `RTS` skipping a `NOP` at that label.
- Several pointer carry/borrow updates use branches such as `BCC *+4` and `BNE *+4`. These save labels
  and bytes but depend on the skipped instruction remaining exactly two bytes long.
- Level setup copies bytes into `$10-$24` with an indexed loop which deliberately skips `$0f`. The
  first byte of each associated state block is therefore not copied.
- Four `LDY #4` instructions immediately before `draw_basic_screen` have no effect on that routine,
  which reloads `Y` with five. They are retained original instructions.
- Two blocks of 255 and 65 unidentified bytes are preserved among the executable sections. They look
  like packed or residual binary data but have no identified runtime references.
- Custom characters 61-63 contain apparent fragments of text rather than meaningful game glyphs and
  are retained without assigning a speculative purpose.
- Clearing and platform colouring touch all 512 bytes of the selected screen and colour pages even
  though only 504 cells are displayed. This is harmless within the selected regions.

## Improvements compatible with binary reproduction

The source now uses contextual aliases for the temporary barrel record and other formerly raw
zero-page operands. Misleading state names have also been clarified. The build has compile-time
assertions for important layout boundaries, generates PRG headers directly and invokes a standalone
verifier which fails on either binary mismatch.

Further safe improvements are documentary and tooling changes which do not alter emitted bytes:

- add more contextual aliases where the same scratch byte has several unrelated local meanings;
- correct comments and spelling without changing instructions or data.

The compact `*+4` branches remain in the source by design. Their comments explicitly state whether
carry, borrow or low-byte wrapping controls the skipped high-byte update.

Actual gameplay fixes—initialising `X`, changing the speed subtraction carry, stopping the bonus while
paused, or tightening keyboard selection—would necessarily break byte identity. If desired, they
should be controlled by a separate build option or maintained as a distinct patched edition, never
silently incorporated into the reproduction target.

## Source layout and verification

`main.asm` defines hardware addresses, game-state aliases, character codes and the conditional memory
layout. `code1.asm` contains startup, barrels, input, player movement, collision, score, IRQ handling
and screens one and four. `code2.asm` contains screens two and three plus shared screen drawing
routines. The four `scr?data.asm` files hold relocatable level setup records, and `spr.asm` contains
the custom character set.

`mtb_build.bat` assembles both layouts with ACME, generates the appropriate two-byte PRG load address,
invokes `mtb_verify.bat` and then creates a disk image. The verifier may also be run independently to
check existing PRGs without rebuilding them. The batch files anchor relative paths to the project
directory, and the build stops if assembly, PRG generation, verification or D64 creation fails. At
the time of this analysis, the
unexpanded payload is 3,583 bytes and exactly matches `Mickey the Bricky original.prg`; the expanded
payload is 3,732 bytes and exactly matches `mickey bricky 8k tested.prg`.

These comparisons are essential after any source edit. Labels and comments normally preserve output,
but changes to branch spelling, source ordering, BASIC text, unidentified bytes or the placement of
the `$1c00` character set can alter the binary or invalidate embedded addresses.
