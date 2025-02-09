# TMDM Encounter Client

The TMDM Encounter Client allows a raid leader to send display information and
trigger sounds across the raid group.

## Usage

To use this client, make simple weakauras (or your own addons) that construct
and send addon messages to your party or raid members. The client will parse
these messages and display the delivered information on their screen.

Advantages of this approach:

- The raid leader is the only one with the assignment logic. It is impossible
  for auras running on separate raider's machines to come up with conflicting
  assignments.
- Unique boss assignment auras do not need to be downloaded and kept in sync for
  every member of your raid.

## V1 Format

The `v1` addon message format allows simple `field=value` pairs to define
actions the encounter client should take. Each pair is separated by a semicolon.

    field=value;field=value;field=value

The **entire message** must fit in a single call to
`C_ChatInfo.SendAddonMessage()`, therefore it cannot exceed 255 characters.

```
/script C_ChatInfo.SendAddonMessage("TMDM_ECWAv1", "m=TEST", "WHISPER", UnitName("player"))
```

### Fields

| Field | Action                                        | Example                           |
| ----- | --------------------------------------------- | --------------------------------- |
| `c`   | Trigger a SAY, YELL, RAID or WHISPER message. | `c=SAY Something is on me...`     |
| `d`   | Duration for glows & messages (default: 5s)   | `d=10`, `d=6.5`                   |
| `e`   | Add an emote to the default chat frame        | `e=I messed up!`                  |
| `g`   | Glow multiple player unit frames              | `g=player1,player2,player3`       |
| `m`   | Disply a large message (also `m1`,`m2`,`m3`)  | `m={skull} SOAK MECHANIC {skull}` |
| `s`   | Play a sound (FileDataID, sound name or path) | `s=moan`, `s=569593`              |

### Examples

- `m=GO IN THE CAGE; d=10`
- `s=airhorn`
- `m=RUN TO {diamond};s=moan`
- `c=SAY Something is on me...;s=bikehorn`
- `m=|cff00ff00COLOR TEST|r MESSAGE`
- `c=WHISPER Player1 Hey bud, gimme dat external`

### Remember

- Only messages sent by the party or raid leader will be processed.
  - Use `RAID` to send commands to the entire raid at once.
  - Use `WHISPER` to send commands to individuals in the raid.
- Blizzard will rate limit addon messages if too many are sent in a short time
  period.
- The message is limited to 255 characters as no serializer is used to split the
  messages.
- Duration is applied to both the glow and display if sent in the same message.
- There are three separate message lines (`m1`, `m2` and `m3`). Using `m=` will
  assign text to the middle line (`m2`).
- The `m=` and `c=` fields both support `{circle}` and `{rt1}` for markers.

## V2 Format

Future plans for a V2 format:

- Add support for messages beyond 255 characters.
- Add destination players to messages, allowing a single RAID message to be
  processed by only some of the raid.
- Add a simple shape-drawing frame for positional assignments.
