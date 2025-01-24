# Release Notes

Below you will find the release notes for the Sonatype Nexus Dogu. 

Technical details on a release can be found in the corresponding Changelog.

## [Unreleased]

## [v6.2.17-1] - 2025-01-24

### Redis 6.2.17 (January 6, 2025)
- **Security Fixes**
  - **CVE-2024-46981**: Fixed an issue where Lua script commands could lead to remote code execution.


### Redis 6.2.16 (October 2, 2024)
- **Security Fixes**
  - **CVE-2024-31449**: Resolved an issue where Lua library commands could lead to a stack overflow, potentially resulting in remote code execution.
  - **CVE-2024-31227**: Fixed a potential denial-of-service vulnerability due to malformed ACL selectors.
  - **CVE-2024-31228**: Addressed a potential denial-of-service vulnerability caused by unbounded pattern matching.

### Redis 6.2.15 (October 18, 2023)
- **Security Fixes**
  - **CVE-2023-45145**: Addressed a race condition during startup caused by the incorrect order of `listen(2)` and `chmod(2)` system calls. This vulnerability could allow another process to bypass the intended Unix socket permissions.

## Release 6.2.14-3

- Relicense own code to AGPL-3.0-only