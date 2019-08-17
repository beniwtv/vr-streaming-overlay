# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.co##m/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [UNRELEASED] - 2019-XX-XX
### Added
- Events, when something on the overlay happens (e.g. new chat message)
- Option(s) to dim/undim overlay based on events
- Option to play a chime when an event happens (with audio output/device selection)
- Added undim when looking at the overlay (3 seconds by default)
- Add font option to Twitch widget + added Hack font

### Changed
- Fixed some stuff in the credits
- Refactored 80%+ for static typing
- Improved tracking on hands of the overlay

### Fixed
- Remove old secret file before creating a new one, else we can't create it
- Prevent dimming of the overlay on hand tracking (not needed there)

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

[Unreleased]: https://github.com/relamptk/vr-streaming-overlay/compare/0.0.2-alpha...HEAD
[0.0.2-alpha]: https://github.com/relamptk/vr-streaming-overlay/releases/tag/0.0.2-alpha
[0.0.1-alpha]: https://github.com/relamptk/vr-streaming-overlay/releases/tag/0.0.1-alpha
