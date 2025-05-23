# v2.19

- Added some more utilities.
- Use degrees instead of radians.

# v2.18

- Allow Creature GUIDs in glows.

# v2.17

- Add texture for Mug'Zee's room.
- Allow unit nameplate glows.

# v2.16

- Strip realm names from the filter list before checking.

# v2.15

- Add experiment to try improving sound consistency.

# v2.14

- Update embedded libraries (LibOpenRaid had some print() statements).

# v2.13

- Added `/tmdm notify` command to trigger special events during encounters.
- Added SharedMedia_Causese as a required addon dependency.
- Added `smc:` prefix for sound fields as a shortcut for playing Causese sounds.

# v2.12

- Added more spec orders.
- Fixed a bug in the spec sorting function.
- Fixed a UI template bug introduced in 11.1.5.
- Updated TOC for 11.1.5

# v2.11

- Expand our sound library =)

# v2.10

- Always use ChatThrottleLib when sending messages.

# v2.9

- Fixed up some texture paths.

# v2.8

- Added texture database support to the diagram frame.
- Added text-boxes to the diagram frame.
- Added target marker texture support to the diagram frame.
- Added `TMDM.Emit()` function with support for messages over 255 characters.
- Added more diagraming utilities.
- Added background image for Sprocketmonger Lockenstocks's room.
- Added `TMDM.SPEC` tables for spec ID lookups.

# v2.7

- Added `/tmdm lock` command for moving the display frames.
- Added `/tmdm reset` command for resetting frame positions.
- Added utilities for group sorting.

# v2.6

- Added `f` field for filtering message recipients.
- Added utilities for parsing YAML objects in MRT notes.

# v2.5

- Added support for generic timer bars to the `b` field.
- The `/tmdm send` command now prints the message length.

# v2.4

- Added the `/tmdm send TARGET MESSAGE` command for quickly testing fields and
  values.
- Added type, color, frequency and scale values for glows.
- Increased the shape texture sizes to 256x256.
- Fixed color codes in `e=` emote messages.
- Updated the "outdated" list in the version checker to include version numbers.
- Changed separator to `:` for `c=` messages.
- Changed official V1 prefix to `TMDMv1` (the old `TMDM_ECWAv1` prefix is still
  supported).

# v2.3

- Removed `shapes.psd` from the release file.
- Fixed line displays in diagrams not resetting.

# v2.2

- Fixed version checks in large groups.
- Added `b=unit:resource[:timer]` for special bar displays.
- Added `z=shape[:options],...` for diagram displays.

# v2.1

- Fix group leader check.

# v2.0

- Converted to a proper addon.
- Implemented base v1 functionality without a dependency on WeakAuras.
- Added the `/tmdmvc` command for version checking.
- Added support for sending whispers: `c=WHISPER <TARGET> <MESSAGE>`

# v1.x (Legacy)

This is the changelog from the original weakaura.

| Version | Description                                                                   |
| ------- | ----------------------------------------------------------------------------- |
| 1.17    | Allow override of RCLC master looter.                                         |
| 1.16    | Fix !keys functionality for DF.                                               |
| 1.15    | Fix trim() call (now strtrim())                                               |
| 1.14    | Updated mythic+ key item id for Shadowlands.                                  |
| 1.13    | Updated for Shadowlands. Removed DBM option support.                          |
| 1.12    | Added custom options for configuring glows.                                   |
| 1.11    | Added support for glowing unit frames.                                        |
| 1.10    | Added support for multiple text channels.                                     |
| 1.9     | Improve performance in large raids.                                           |
| 1.8     | Added support for numeric raid target icons.                                  |
| 1.7     | Added support for mythic+ key printing.                                       |
| 1.6     | Added support for version checks.                                             |
| 1.5     | Fixed API for 8.0 (BfA)                                                       |
| 1.4     | Added sound debouncer.<br>Added support for tweaking DBM options.             |
| 1.3     | Added support for `e` field.                                                  |
| 1.2     | Added support for escape sequences.<br>Fixed a timer bug in display messages. |
| 1.1     | Added support for `c` field.                                                  |
| 1.0     | Initial release!                                                              |
