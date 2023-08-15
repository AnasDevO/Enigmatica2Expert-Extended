## Installing

1) **Download** server pack zipfile
  > You can find this file on CurseForge under `Additional Files` or on GitHub under `Releases` => `Assets`
2) **Extract** it to an empty folder.
3) If you want to **change RAM** usage, Java arguments etc, see the "settings" file.
4) If you want to change worldgen:
  > - ⛺ **Biomes O' Plenty**: in file `server.properties` set `level-type=BIOMESOP`
  > - 🌌 **Skyblock**: change `level-type` as mentioned above, then in file [justenoughdimensions.cfg](config/justenoughdimensions/justenoughdimensions.cfg) set `initialSpawnDimensionId` to `3`
5) Double click "**ServerStart**" or "ServerStartLinux", whichever is appropriate. On Linux you cannot run the script via sh directly.
6) **Set** EULA=true

## Updating

1) **Backup** your world.
2) **Backup** your custom configs - `./server.properties`, `local/ftbutilities/ranks.txt` and some configs, like *Discord Integration* options.
3) **Delete** all the folders from the server that are in the archive.
4) **Extract** `.zip` into server folder with overwrite.
7) **Reapply** your custom configs. I recommend that you keep all changes in a seperate archive, so you can just **unarchive** them over after updating.
