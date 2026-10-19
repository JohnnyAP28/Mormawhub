# MormawHub — Training Map Edition

Starter project for a Roblox Studio aim-training map. Includes a self-contained UI, FOV ring, target ESP limited to `Workspace.TrainingTargets`, and Studio-only movement testing.

## Project layout

- `src/ReplicatedStorage/MormawHub/Config.lua` — shared defaults and colors.
- `src/ServerScriptService/MormawMovementServer.server.lua` — server-validated Studio movement controls.
- `src/StarterPlayer/StarterPlayerScripts/MormawHubClient.client.lua` — UI, FOV ring, and training-target ESP.

## Install in Roblox Studio

1. In `ReplicatedStorage`, create a Folder named `MormawHub`.
2. Put a ModuleScript named `Config` in that folder and paste `Config.lua`.
3. Add a `RemoteEvent` named `MovementRequest` to the same folder.
4. Add the server script to `ServerScriptService`.
5. Add the client LocalScript to `StarterPlayer > StarterPlayerScripts`.
6. In `Workspace`, create a Folder named `TrainingTargets` and put your own target dummy Models inside. Each target should contain a `HumanoidRootPart` or `Head`.
7. Press **Play** in Studio.

## Included features

- Dark MormawHub panel with purple accent.
- FOV ring toggle and radius cycling.
- Target overlay toggle, boxes/highlights, names, distance labels, and range cycling.
- WalkSpeed and JumpPower test controls.
- RightShift toggles the panel.

## Safety and limitations

- The ESP only scans Models placed in `Workspace.TrainingTargets`; it does not scan live players.
- The aim module is a visual training aid. It does not automatically aim at players.
- Movement changes are accepted only when `RunService:IsStudio()` is true, and the server clamps values. Do not expose test controls in a published public experience.
- Settings are session-local; persistence is not implemented yet.
- This is a starter implementation and should be tested in Studio before use.
