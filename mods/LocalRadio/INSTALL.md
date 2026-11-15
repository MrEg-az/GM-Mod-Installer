# MyRadio v0.3 — your own radio station in ANANTA

A new station ("My Radio") appears in the in-game vehicle radio next to the
original ones. Its tracks are your own MP3 files, played locally through the
client's own MP3 decoder. Original stations, songs and the v0.2 local radio
are untouched.

## Install

1. Restore the mod loader into the game root (from `modloader_ru.zip`):
   - `winhttp.dll`
   - `dinput8.dll`
2. Create the mod folder in the game root:

   ```
   Il2CppNativeKit\Mods\LocalRadio\
   ```

   and put these files inside:
   - `Mod.dll` (the LocalRadio native bridge — unchanged from 0.2)
   - `LocalRadio.lua` (this v0.3 script)
   - `LocalRadio.ini` (Enabled=1)
   - `LocalRadioTracks.ini` (this one — see below)
   - `Audio\` — your MP3 files

3. Edit two places:

   **`LocalRadioTracks.ini`** — map track ids to your files:
   ```ini
   99001=my_cool_song.mp3
   99002=another_song.mp3
   99003=third.mp3
   ```
   Filenames: latin letters/digits/underscore/dash/dot, no paths.
   The files go into the `Audio\` folder next to Mod.dll.

   **`LocalRadio.lua`** — the MYSTATION block at the top:
   ```lua
   local MYSTATION_NAME    = 'My Radio'
   local MYSTATION_NUMBER  = '105.5'
   local MYSTATION_COVER   = 28001538   -- cover art id (see below)
   local MYSTATION_ICON    = 28001561   -- icon art id
   local MYSTATION_TRACKS = {
       {file = 99001, title = 'Track One',  singer = 'Artist'},
       ...
   }
   ```

4. Start the game. Check `Il2CppNativeKit\Mods\LocalRadio\LocalRadio.log`:
   - `READY localFiles=...`
   - `MYSTATION injected id=99000 songs=N name=... cover=...`
   - In the car radio you should see the new station at the end of the list.

## Cover / icon art

`MYSTATION_COVER` / `MYSTATION_ICON` are **SguiImageConfig ids** — any image
already shipped with the game. Radio covers:

- 28001535–28001554: `S_radiocover_04` … `S_radiocover_23`
- 28001555+: `S_radiocover_01_s` … (small variants)

Full list: `configs-v2\SguiImageConfig.json` (field `ImgPath` tells you what
each id looks like). Pick any id from that table — station 1 uses
28001538 (`S_radiocover_07.png`) and 28001561 for its icon.

## How it works

- The station config (id 99000) is injected at runtime: `rawset` hooks on
  `LTConfig.VehicleRadioConfig.GetConfig/LoadAt/count` and
  `LTConfig.RadioSongsConfig.GetConfig` — the radio manager and the UI panel
  both read the station through those, so it appears in the normal flow.
- Your songs use `IsDefaultGain=true` → unlocked for every player, no server
  unlock data needed.
- Playback goes through the existing v0.2 pipeline: `CreateSoundData` swaps
  the game's CDN url-id for your `file:///` MP3 via the native file map.
- `PlaylistId` is intentionally absent on the injected station — a non-nil
  value would make the game treat it as a cloud (NetEase music) station.
- Nothing outside the mod folder is modified: original stations, config files
  and the server are untouched.

## Adding tracks later

1. Drop the MP3 into `Audio\`
2. Add `99004=my_next_song.mp3` to `LocalRadioTracks.ini`
3. Add `{file = 99004, title = '...', singer = '...'}` to `MYSTATION_TRACKS`
   in `LocalRadio.lua`
4. Restart the game

## Verify

`LocalRadio.log` in the mod folder:
```
READY localFiles=... unavailable=... stations=...
MYSTATION injected id=99000 songs=3 name=My Radio cover=28001538
LOCAL_FILE_SELECTED urlId=99001 uri=file:///...
LOCAL_AUDIO_POST uuid=...
```
`uuid > 0` on LOCAL_AUDIO_POST means the audio player accepted the track.
If sound is silent, send `LocalRadio.log` plus the matching timeframe from
`log\Player.log` (AudioManager/Wwise lines).
