# VR Streaming Overlay

This is a VR overlay for SteamVR for streamers on Linux.
(It is made with Godot, so theoretically this could run on Windows and MacOSX too, feedback and patches welcome ;)

**Note:** The master on this repository is now kept in sync with the Godot / Godot OpenVR master.
For official releases of Godot please check the releases page and/or the respective branches.

Right now this needs a specially compiled Godot OpenVR plugin for which I have not had the time to make a pull request to get it into Godot OpenVR. See "How to get help" and bug me for the patch or compiled version for the time being :)

Also note this is in *VERY* early state, you probably do not want to try this yet (but early testers/feedback are welcome of course).

Current features:
- Should support all SteamVR-supported headsets (only Vive tested though - feedback welcome)
- Adjustable background opacity and color
- Adjustable overlay size in the VR world
- Shows Twitch chat

Planned features:
- Trigger gesture to show overlay (attached left/right hand)
- Track overlay with that hand
- Configurable widget system to show different things - like Twitch chat and Twitch stats (followers, current viewers, alerts...)
- Twitch emotes integration
- Integration of other streaming services (patches will be welcome ;)

Linux notes
-----------
On Linux, Steam will not automatically add the SteamVR libraries to your $LD_LIBRARY_PATH variable. As such, when starting the overlay outside of Steam, it will fail to load the required libraries.

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
The overlay is licensed under the MIT license model. See credits for additional third-party licenses.

How to get help
---------------
My nick is beniwtv on all platforms, mostly.

You can contact me via the #godot-vr channel on IRC/Matrix, or in Discord in the Linux Gamers Group server, GamingOnLinux server or the Godot server.

You can also follow me on Twitter:
https://twitter.com/beniwtv
