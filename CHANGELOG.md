# Easyredmine Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Fixed
- Add local config volume to fix issue #16

### Changed
- Upgrade Makefiles to 9.2.1

## [v6.2.14-3] - 2024-09-18
### Changed
- Relicense to AGPL-3.0-only

## [v6.2.14-2] - 2024-08-07
### Changed
- [#12] Upgrade base image to 3.15.11-2

### Security
- fix CVE-2024-41110

## [v6.2.14-1] - 2024-07-03
### Changed
- [#8] Upgrade base image to 3.15.11-1
- [#8] Upgrade redis to 6.2.14-r0

### Removed
- [#8] State check for `upgrading`, since that state is never set.

## [v6.2.12-1] - 2023-04-21
### Changed
- Upgrade base image to 3.15.8-1 (#6)
- Upgrade redis to 6.2.12-r0 (#6)

## [v6.2.6-2] - 2022-04-11
### Changed
- Upgrade base image to 3.15.3-1
- Upgrade zlib package to fix CVE-2018-25032; #3

## [v6.2.6-1] - 2017-06-20
### Added
- First version of the redis Dogu (#1)
