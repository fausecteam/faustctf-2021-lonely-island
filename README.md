Lonely Island
================

A small capture the flag multiplayer game


## Build Instructions

`make`

This will download the necessary dependencies from [godotengine.org](https://godotengine.org) and build the project.

You can run the server with `cd dist_root/srv/lonely-island/ && ./server` and the client with `cd dist_root/srv/lonely-island && ./client`

To run the checker, you will need the [ctf_gameserver](https://github.com/fausecteam/ctf-gameserver/tree/master/src) python dependency.

Subsequently, the checker can be run with `python3 checker/lonely-island-checker.py <ip> <team> <tick>`

## Sample Exploit

In the `exploit/` directory, an example exploit is provided. It will extract the flags of new clients joining the game. This means that you need to have the exploit running while the checker is running as well.

To run the exploit you need a suitable version of Godot Engine. If you've built the project, you can use `src/build/godot/Godot_v3.2.3-stable_x11.64`. The exploit requires a host and port given via environment variables. An example invocation could look like this: `cd exploit && HOST=localhost PORT=4321 ../src/build/godot/Godot_v3.2.3-stable_x11.64 remote.tscn`

## Artwork

### 3D Models
* "Modular terrain" by `Keith at Fertile Soil Productions`, retrieved from [Open Game Art](https://opengameart.org/content/modular-terrain). License: [CC0](http://creativecommons.org/publicdomain/zero/1.0/)
* "3D Rigged Characters" by `Kenney`, retrieved from [Open Game Art](https://opengameart.org/content/3d-rigged-characters). License: [CC0](http://creativecommons.org/publicdomain/zero/1.0/)
* "Flintlock" by `djonvincent`, retrieved from [Open Game Art](https://opengameart.org/content/flintlock). License: [CC0](http://creativecommons.org/publicdomain/zero/1.0/)

### Textures
* "tileable grass and water" by `forkart`, retrieved from [Open Game Art](https://opengameart.org/content/tileable-grass-and-water). License: [CC0](http://creativecommons.org/publicdomain/zero/1.0/)
* "Crosshair pack (200x)" by `Kenney`, retrieved from [Open Game Art](https://opengameart.org/content/crosshair-pack-200%C3%97). License: [CC0](http://creativecommons.org/publicdomain/zero/1.0/)
* "Map Pergaments" by `Nia Mi`, retrieved from [Open Game Art](https://opengameart.org/content/map-pergaments). License: [CC0](http://creativecommons.org/publicdomain/zero/1.0/)

### Fonts
* "Nugie Romantic" by `cove703`, retrieved from [Fontspace](https://www.fontspace.com/nugie-romantic-font-f33764). License: Freeware
* "Playfair Display Font" by `Claus Eggers Sørensen`, retrieved from [Fontspace](https://www.fontspace.com/playfair-display-font-f44531). License: [SIL Open Font License](https://scripts.sil.org/ofl)
