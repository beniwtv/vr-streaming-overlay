# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.co##m/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [UNRELEASED] - 2020-XX-XX
### Added
- Added styling for connections tab
- Re-added position and rotation sliders to hand mode

### Changed
- Update code to use the new multi-overlay implementation of godot_openvr
- Update to Godot 3.2
- Improvements to the README
- Some tweaks to CPU/GPU usage
- Rotation sliders now allow for more fine-grained control

### Fixed
- Fixed skinning issue in font selection dialog
- Fixed skinning of sliders
- Fixed "undim on stare"
- Fixed not being able to accept login on enter
- Fixed saving of "Play chime on event" checkbox
- Fixed Twitch chat widget SSL mode crashing the overlay
- Fixed overlay crashing when host is reveived on Twitch
- Fixed parsing of PRIVMSG
- Improved handling of rotation in hand mode
- Fixed Twitch OAuth help text, fixes #10

## [0.0.3-alpha - 2019-09-15
### Added
- Events, when something on the overlay happens (e.g. new chat message)
- Option(s) to dim/undim overlay based on events
- Option to play a chime when an event happens (with audio output/device selection)
- Added undim when looking at the overlay (3 seconds by default)
- Add font option to Twitch widget + added Hack font
- Hand tracking now functional, with settings dialog
- Added compact mode display for Twitch chat widget
- Godot OpenVR library now compiled using Ubuntu 18.04 (hopefully prevents crashes)
- Added new UI theme (still needs some fixes)
- Added multiple overlay support

### Changed
- Fixed some stuff in the credits
- Refactored 80%+ for static typing
- Improved tracking on hands of the overlay
- Properly include godot-openvr addon like other addons for ease of use

### Fixed
- Remove old secret file before creating a new one, else we can't create it
- Prevent dimming of the overlay on hand tracking (not needed there)
- Fixed secret file corruption when closing overlay application without logging in

## [0.0.2-alpha] - 2019-05-18
### Added
- New widget system that allows to add and arrange widgets at will
- New connection system with secure storage
- Display VR overlay status in SteamVR under "General settings"
- Display error messages when connection to Twitch fails
- Handle connection drops / closes by reconnecting
- Twitch chat widget can now connect to multiple chat rooms
- This changelog

### Changed
- Connect to Twitch via SSL

### Fixed
- Fixed overlay moving itself when certain controllers/axis are used

## [0.0.1-alpha] - 2019-03-16
### Added
- Initial very rough alpha build

[Unreleased]: https://github.com/relamptk/vr-streaming-overlay/compare/0.0.3-alpha...HEAD
[0.0.3-alpha]: https://github.com/relamptk/vr-streaming-overlay/releases/tag/0.0.3-alpha
[0.0.2-alpha]: https://github.com/relamptk/vr-streaming-overlay/releases/tag/0.0.2-alpha
[0.0.1-alpha]: https://github.com/relamptk/vr-streaming-overlay/releases/tag/0.0.1-alpha
