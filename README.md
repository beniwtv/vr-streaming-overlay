# VR Streaming Overlay

This is a SteamVR overlay for streamers on Linux/Windows.
(Made using the awesome Godot game engine ;)

**Note:** The master on this repository is kept roughly in sync with Godot / Godot OpenVR master.
For official releases of Godot please check the releases page and/or the respective branches.

**Note:** While this is also compiled for Windows at the moment, this is currently untested. Feedback is welcome here :)

Also note this is in an early state, but testers/feedback are welcome of course!

Current features:
- Should support all SteamVR-supported headsets (only HTC Vive/Valve Index tested though - feedback welcome)
- Adjustable background opacity and color
- Adjustable overlay size in the VR world
- Shows Twitch chat
- Track overlay with left/right hand
- Configurable position and rotation relative to tracking device or absolute in VR world
- Configurable widget system to show different things - like Twitch chat and Twitch stats (followers, current viewers, alerts...)
- Trigger gesture to show/hide overlay (attached left/right hand)

Planned features / ideas:
- Capture arbitrary windows
- AUR package
- Stream statistics integration (subs, followers, viewers, alerts...)
- Integration of other streaming services (patches will be welcome ;)

Linux notes
-----------
On Linux, Steam may not automatically add the SteamVR libraries to your $LD_LIBRARY_PATH variable. If so, when starting the overlay outside of Steam, it may fail to load the required libraries.

There are a couple of ways to fix this:

1) Launch the overlay from within Steam -> add it as non-Steam game

2) Run the overlay through the steam runtime manually (change the path to suit your Steam installation):

```
/home/<user>/.steam/steam/ubuntu12_32/steam-runtime/run.sh <path/to/overlay_bin>
```

3) Adjust your $LD_LIBRARY_PATH variable accordingly:

```
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:"/path/to/libgodot_openvr.so/dir/":"/home/<user>/.steam/steam/steamapps/common/SteamVR/bin/"
```

License
-------
The overlay is licensed under the MIT license model. See [3rd-party-licenses.md](3rd-party-licenses.md) for additional third-party licenses.

How to get help
---------------
My nick is beniwtv on all platforms, mostly.

You can contact me on Matrix, or in Discord in the Linux Gamers Group server, GamingOnLinux server or the Godot server.
