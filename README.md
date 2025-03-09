# TMDM Encounter Client

The TMDM Encounter Client allows a raid leader to send display information and
trigger sounds across the raid group.

- [Usage](#usage)
- [V1 Format](#v1-format)
- [V2 Format](#v2-format)

## Usage

To use this client, make simple weakauras (or your own addons) that construct
and send addon messages to your party or raid members. The client will parse
these messages and display the delivered information on their screen.

Advantages of this approach:

- The raid leader is the only one with the assignment logic, making conflicting
  assignments impossible.
- Unique boss auras do not need to be downloaded or kept in sync for every
  member of your raid.

See
[this wiki page](https://wiki.tmdmguild.com/books/guild-raid-information/page/tmdm-encounter-client)
for an in-depth explanation of how we use this client to minimize aura-related
progression wipes.

## V1 Format

The `v1` addon message format allows simple `field=value` pairs to define
actions the encounter client should take. Each pair is separated by a semicolon.

    field=value;field=value;field=value

Each field type accepts different value formats specific to that field. Some
fields allow multiple displays using `,` as a separator. Fields that require
multiple input values use `:` as a separator. A example complex field value
would be:

    field=val1:val2:val3,val1:val2:val3,val1:val2:val3

The **entire message** must fit in a single call to
`C_ChatInfo.SendAddonMessage()`, therefore it cannot exceed 255 characters.

```lua
/script C_ChatInfo.SendAddonMessage("TMDMv1", "m=TEST", "WHISPER", UnitName("player"))
```

#### Remember!

- Only messages sent by yourself or the group leader will be processed.
  - Use `PARTY` or `RAID` to send commands to the entire raid at once.
  - Use `WHISPER` to send commands to individuals in the raid.
- Blizzard will rate limit addon messages if too many are sent in a short time
  period.
- The message is limited to 255 characters as no serializer is used to split and
  reconstruct the messages.

### Fields

| Field                        | Action                                          | Example                           |
| ---------------------------- | ----------------------------------------------- | --------------------------------- |
| [`b`](#special-resource-bar) | Track a unit resource as a special bar.         | `b=boss1:3:10`                    |
| [`c`](#chat-messages)        | Trigger a SAY, YELL, RAID or WHISPER message.   | `c=SAY:Something is on me...`     |
| [`d`](#display-duration)     | Duration for glows & messages (default: 5s)     | `d=10`, `d=6.5`                   |
| [`e`](#emote-messages)       | Add an emote to the default chat frame          | `e=I messed up!`                  |
| [`g`](#unit-frame-glows)     | Glow multiple player unit frames                | `g=player1,player2,player3`       |
| [`l`](#diagram-frame)        | Draw one or more lines in the diagram frame.    | `l=-50:-50:50:50`                 |
| [`m`](#banner-messages)      | Display a large message (also `m1`, `m2`, `m3`) | `m={skull} SOAK MECHANIC {skull}` |
| [`s`](#sound-notifications)  | Play a sound (FileDataID, sound name or path)   | `s=moan`, `s=569593`              |
| [`z`](#diagram-frame)        | Draw one or more shapes in the diagram frame.   | `z=c:-50,x:50`                    |

### Banner Messages

Banner messages are the most basic and critical display this addon utilizes.
These are sent using the `m`, `m1`, `m2` or `m3` fields. These messages appear
as large text at the top-center of the player's screen.

    m[1|2|3]=MESSAGE

- The three message lines are stacked on top of each other with `m1` on top and
  `m3` on bottom.
- The `m` shorthand field selects the middle `m2` line.
- Each message line has a separate display timer when activated.
- Target icons can be displayed using named `{circle}` or numbered `{rt1}`
  formats.
- Colored text can be displayed using the `|cAARRGGBB<text>|r` format.
- Uses the `d` field to control the display duration.

#### Examples

- `m=GO IN THE CAGE;d=10`
- `m=|cff00ff00COLOR TEST|r MESSAGE`
- `m=RUN TO {diamond}`

### Chat Messages

Chat messages can be automatically sent using the `c` field.

    c=CHANNEL[:TARGET]:MESSAGE

The `TARGET` value is only required when the `WHISPER` channel is used. All
channels supported by the
[SendChatMessage](https://warcraft.wiki.gg/wiki/API_SendChatMessage) function
are supported.

- Some channels such as `SAY` and `YELL` do not function in the open world.
- Target icons can be displayed using named `{circle}` or numbered `{rt1}`
  formats.

#### Examples

- `c=SAY:Something is on me...`
- `c=WHISPER:Madpriest:Hey bud, gimme dat pi`

### Emote Messages

Emotes can be added to the player's _default chat frame_ using the `e` field.

    e=MESSAGE

This simply adds a message to the frame using the player's configured emote text
color. It does _not_ broadcast an emote from that player to others.

- These messages will only appear in the `DEFAULT_CHAT_FRAME`.
- Colored text can be displayed using the `|cAARRGGBB<text>|r` format.

#### Examples

- `e=Something ominous is coming ...`
- `e=Dumbass and Mcgee collided causing a wipe!`
- `e=|cff8788EEWarlocko|r is the bomb!`

### Unit Frame Glows

Unit frames can be highlighted with a glow using the `g` field.

    g=UNIT:[TYPE=1]:[R:G:B[:A]]:[FREQUENCY]:[SCALE],...

The `TYPE` value selects the type of glow that should be used. The remaining
fields allow you override the color of the glow.

- The [LibGetFrame](https://www.curseforge.com/wow/addons/libgetframe) library
  is used to fetch the requested unit frame.
- The [LibCustomGlow](https://www.curseforge.com/wow/addons/libcustomglow)
  library is used to apply a glow to the frame.
- The `FREQUENCY` and `SCALE` values are passed to `LibCustomGlow` where
  applicable.
- Uses the `d` field to control the glow duration.
- The default color is a pale yellow.

| `TYPE` | Glow                                           |
| ------ | ---------------------------------------------- |
| `1`    | Pixel glow (rotating dashed lines) (_default_) |
| `2`    | Auto-cast glow (rotating particles)            |
| `3`    | Button glow (ability proc glow)                |

#### Examples

- `g=Bootyhoof,Krushmaster,Kingkonk`
- `g=Bozo:2:.9:0:0,Dingus::0:1:0:.5`

### Special Resource Bar

A large special resource bar can be displayed at the top-center of the screen
using the `b` field.

    b=[UNIT]:[RESOURCE][:TIMER][:R:G:B[:A]]

This bar will a resource type of the target unit. It can optionally display a
red countdown spark-line to indicate a time limit on dealing with this unit.

| `RESOURCE` | Description                |
| ---------- | -------------------------- |
| `1`        | Health                     |
| `2`        | Power (mana, energy, etc.) |
| `3`        | Damage Absorb              |
| `4`        | Healing Absorb             |

When called without a `TIMER` value, the red line will not appear and the bar
will remain active until another message is sent with either `b=` or `b=::0` as
the value.

When called without a `UNIT` value, the `TIMER` value can be used to display a
large generic timer bar.

#### Examples

- `b=boss1:3:20`
- `b=boss2:2`
- `b=::30`
- `b=`, `b=::0` (stop the display)

### Diagram Frame

A diagram frame for displaying shapes and lines can be shown using the `l` or
`z` fields.

    l=X:Y:X:Y:[THICKNESS=4]:[R=1]:[G=1]:[B=1]:[A=1],...
    z=SHAPE:[X=0]:[Y=0]:[R=1]:[G=1]:[B=1]:[A=1]:[SCALE=1]:[ANGLE=0],...

Lines are drawn between two XY coordinates and allow the thickness and color to
be customized. A number of shape textures are included in the addon (see table
below) and are positioned using their center-point. The color, scale and angle
(radians) of each shape can be customized.

When submitted together in a single message, lines are drawn first followed by
shapes. Each subsequent shape uses an increasing texture sub-level to ensure it
is drawn on top of the previous shape.

- The frame supports up to 10 lines and 16 shapes in a single display.
- The frame is 256x256 pixels and clips shapes that go outside of that area.
- Sending a new diagram will clear any previously displayed diagram.
- The default color of all lines and shapes is `1:1:1:1` (white).
- Uses the `d` field to control the display duration.

| `SHAPE` | Name     |     | `SHAPE` | Name      |
| ------- | -------- | --- | ------- | --------- |
| `c`     | Circle   |     | `q`     | Square    |
| `x`     | Cross    |     | `p`     | Pentagon  |
| `d`     | Diamond  |     | `h`     | Hexagon   |
| `m`     | Moon     |     | `y`     | Heptagon  |
| `s`     | Star     |     | `o`     | Octogon   |
| `t`     | Triangle |     | `g`     | TMDM logo |

#### Examples

- `l=-50:-50:50:50`
- `z=c:-50,x:50`
- `z=h::50,h:-25,h:25,h:-50:-50,h::-50:0:0.8:0,h:50:-50`

### Sound Notifications

Sounds can be played using the `s` field.

    s=SOUND

The `SOUND` value accepts either:

1. A
   [LibSharedMedia](https://www.wowace.com/projects/libsharedmedia-3-0/pages/api-documentation)
   sound name to play a sound included in another addon.
2. A `FileDataID` or a sound file path (see
   [PlaySoundFile](https://warcraft.wiki.gg/wiki/API_PlaySoundFile)).

Sound names are searched using a case-insensitive match and spaces are removed.
Sounds are played on the `master` sound channel to ensure they are heard by the
recipient. When passing a sound file path, use `/` instead of `\\` to reduce the
character count.

#### Examples

- `s=BigWigs: Alert`
- `s=bigwigs: alert`
- `s=BIGWIGS:ALERT`
- `s=Interface/Addons/BigWigs/Media/Sounds/Alert.ogg`
- `s=moan`
- `s=1348504`

### Display Duration

The duration of most of the addon's displays are controlled using the `d` field.

    d=SECONDS

This field defines the duration of the display in seconds. When included in a
message, the duration is applied to _all_ associated displays in that message.
Displays with different duration requirements must be sent as separate messages.

**NOTE:** Regardless of duration, all displays are immediately stopped when an
encounter ends.

#### Examples

- `d=5` (the default)
- `d=6.5`

## V2 Format

Future plans for a `v2` format would add support for messages over 255
characters.
