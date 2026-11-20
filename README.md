# ananta-mod-kit

Mod kit for the ANANTA community server (build 4480568, v1.1.0) - loader, client mods
and the server-side gacha patch, in a structure the ACD Discord Control panel can
install automatically.

## Contents

| component | what it is | target |
|---|---|---|
| `loader/` | Il2CppNativeKit loader pair (winhttp.dll + dinput8.dll). Install FIRST. | game root |
| `mods/LocalRadio/` | Multi-station custom radio. Audio files are user content - drop your MP3s into `Audio/` after install. | `Il2CppNativeKit/Mods/LocalRadio/` |
| `mods/GachaTime/` + `server/patch/` | Gacha unlock - client mod and server hotpatch, installed together by the GM panel as one component. | `Il2CppNativeKit/Mods/GachaTime/` + `bin/patch/<N>/` |
| `mods/ScopeCdnRedirect/` | Redirects game CDN media requests to a mirror. Configure the mirror URL in `ScopeCdnRedirect.ini`. | `Il2CppNativeKit/Mods/ScopeCdnRedirect/` |
| `server/patch/` | Server-side hotpatch (gacha unlock) - goes into `bin/patch/<next free number>/` on the server. | `bin/patch/<N>/` |

## Install

Easiest way: the ACD GM panel (http://127.0.0.1:8790/mods) - point it at this folder
(or hit "Fetch" from the GitHub repo) and press Install per component.

Manual way:

1. Close the game.
2. Copy `loader/winhttp.dll` and `loader/dinput8.dll` into the game root
   (the folder with `Ananta.exe`). If the game already ships its own `dinput8.dll`,
   rename it to `dinput8_vendor_backup.dll` first.
3. Copy each mod folder you want from `mods/<Name>/` into
   `game root/Il2CppNativeKit/Mods/`.
4. Server patch: copy `server/patch/*` into `bin/patch/<next free number>/`
   on the server, then restart the server. The client GachaTime mod pairs with it.
5. Launch the game. `Il2CppNativeKit/Logs/ModLoader.log` shows what loaded.

## Uninstall

- Mods: delete the mod folder from `Il2CppNativeKit/Mods/`.
- Loader: delete `winhttp.dll` + `dinput8.dll` from the game root and restore
  `dinput8_vendor_backup.dll` back to `dinput8.dll`.
- Server patch: delete the `bin/patch/<N>/` folder you installed and restart the server.

## Notes

- Driver requirement: none for the mods. Game build must match 4480568.
- LocalRadio audio: the 220 MB of MP3s are intentionally NOT in this kit - they are
  user content. The radio works without them; add your own MP3s to
  `Il2CppNativeKit/Mods/LocalRadio/Audio/`.
- Logs live in `Il2CppNativeKit/Logs/ModLoader.log` - check there when a mod misbehaves.
- The GM panel mod page reads `manifest.json` from this folder, so keep the structure.