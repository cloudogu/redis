# Release Notes

Below you will find the release notes for the Sonatype Nexus Dogu. 

Technical details on a release can be found in the corresponding Changelog.

## [Unreleased]
### Changed 
- Redis has been updated to version v6.2.20 [Release Notes](https://github.com/redis/redis/releases/tag/6.2.20)
### Security
- CVE Fixes:
* [CVE-2025-49844](https://nvd.nist.gov/vuln/detail/CVE-2025-49844) – A Lua script may lead to remote code execution  
* [CVE-2025-46817](https://nvd.nist.gov/vuln/detail/CVE-2025-46817) – A Lua script may lead to integer overflow and potential RCE  
* [CVE-2025-46818](https://www.wiz.io/vulnerability-database/cve/cve-2025-46818) – A Lua script can be executed in the context of another user  
* [CVE-2025-46819](https://nvd.nist.gov/vuln/detail/CVE-2025-46819) – Lua out-of-bound read  

## [v6.2.19-1] - 2025-07-08
### Changed 
- Redis has been updated to version v6.2.19 [Release Notes](https://github.com/redis/redis/releases/tag/6.2.19)

## [v6.2.17-3] - 2025-04-25
### Changed
- Usage of memory and CPU was optimized for the Kubernetes Mutlinode environment.

## [v6.2.17-2] - 2025-02-12
We have only made technical changes. You can find more details in the changelogs.

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
