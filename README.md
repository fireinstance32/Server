# Server

Roblox scripts for this game, kept in Git and synced into Roblox Studio with [Rojo](https://rojo.space).

## Folder layout

Each folder under `src/` maps to a place in Studio's Explorer:

| Folder in this repo                         | In Studio                                   |
| ------------------------------------------- | ------------------------------------------- |
| `src/ServerScriptService/`                  | ServerScriptService                         |
| `src/ReplicatedStorage/Shared/`             | ReplicatedStorage > Shared                  |
| `src/StarterPlayer/StarterPlayerScripts/`   | StarterPlayer > StarterPlayerScripts        |
| `src/StarterPlayer/StarterCharacterScripts/`| StarterPlayer > StarterCharacterScripts     |
| `src/StarterGui/`                           | StarterGui                                  |

The file name decides the script type:

| File name             | Becomes a    |
| --------------------- | ------------ |
| `Name.server.luau`    | Script       |
| `Name.client.luau`    | LocalScript  |
| `Name.luau`           | ModuleScript |

A folder becomes a Folder. A folder containing `init.server.luau`, `init.client.luau`
or `init.luau` becomes that script, with the folder's other files as its children.

Anything already in your game that is **not** in these files is left alone
(`$ignoreUnknownInstances` is on), so syncing won't delete your existing scripts, parts or GUIs.

## One-time setup (Windows)

1. **Install Git**: <https://git-scm.com/download/win>
2. **Install Rokit** (a Roblox tool manager): <https://github.com/rojo-rbx/rokit#installation>
3. **Clone this repo and install Rojo:**
   ```
   git clone https://github.com/fireinstance32/Server.git
   cd Server
   rokit install
   ```
4. **Install the Rojo plugin in Studio:** run `rojo plugin install`, or get
   "Rojo" from the Creator Store, then restart Studio.

## Everyday workflow

1. Get the latest changes: `git pull`
2. Start the sync server in the repo folder: `rojo serve`
3. In Studio, open your place, go to **Plugins > Rojo > Connect**.
   The scripts from `src/` appear in your game, and they update live while
   `rojo serve` keeps running.
4. Publish or save the place in Studio as usual.

## Moving your existing scripts into the repo

Rojo syncs **from files into Studio**. To bring scripts you already have
under Git:

1. In Studio, open the script and copy all of its code.
2. Create a file in the matching `src/` folder with the right suffix, e.g. a
   Script named `GameManager` in ServerScriptService becomes
   `src/ServerScriptService/GameManager.server.luau`, and paste the code in.
3. Commit and push:
   ```
   git add .
   git commit -m "Add GameManager script"
   git push
   ```
4. Once the file version is synced in, delete the old copy in Studio so there
   aren't two scripts with the same name.

The `Main` and `Hello` scripts are small examples; delete them whenever you like.
