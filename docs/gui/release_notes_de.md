# Release Notes

Im Folgenden finden Sie die Release Notes für das Sonatype Nexus-Dogu. 

Technische Details zu einem Release finden Sie im zugehörigen Changelog.

## [Unreleased]

## [v6.2.21-1] - 2025-11-06
### Changed 
- Redis ist nun in der Version v6.2.21 verfügbar [Release-Notes](https://github.com/redis/redis/releases/tag/6.2.21)

## [v6.2.20-1] - 2025-10-07
### Changed 
- Redis ist nun in der Version v6.2.20 verfügbar [Release-Notes](https://github.com/redis/redis/releases/tag/6.2.20)
### Sicherheit
- Behebung folgender CVEs:
* [CVE-2025-49844](https://nvd.nist.gov/vuln/detail/CVE-2025-49844) - Ein Lua-Skript kann zur Remote-Code-Ausführung führen  
* [CVE-2025-46817](https://nvd.nist.gov/vuln/detail/CVE-2025-46817) - Ein Lua-Skript kann zu einem Integer Overflow und potenzieller Remote-Code-Ausführung führen  
* [CVE-2025-46818](https://www.wiz.io/vulnerability-database/cve/cve-2025-46818) - Ein Lua-Skript kann im Kontext eines anderen Benutzers ausgeführt werden  
* [CVE-2025-46819](https://nvd.nist.gov/vuln/detail/CVE-2025-46819) - Lua Out-of-Bounds-Read  

## [v6.2.19-1] - 2025-07-08
### Changed 
- Redis ist nun in der Version v6.2.19 verfügbar [Release-Notes](https://github.com/redis/redis/releases/tag/6.2.19)

## [v6.2.17-3] - 2025-04-25
### Changed
- Die Verwendung von Speicher und CPU wurden für die Kubernetes-Multinode-Umgebung optimiert.

## [v6.2.17-2] - 2025-02-12
Wir haben nur technische Änderungen vorgenommen. Näheres finden Sie in den Changelogs.

## [v6.2.17-1] - 2025-01-24

### Redis 6.2.17 (6. Januar 2025)
- **Sicherheitsfixes**
  - **CVE-2024-46981**: Behebte ein Problem, bei dem Lua-Skriptbefehle zu einer Remote-Code-Ausführung führen konnten.

### Redis 6.2.16 (2. Oktober 2024)
- **Sicherheitsfixes**
  - **CVE-2024-31449**: Behebte ein Problem, bei dem Lua-Bibliotheksbefehle zu einem Stack-Overflow führen und möglicherweise eine Remote-Code-Ausführung ermöglichen konnten.
  - **CVE-2024-31227**: Behebte eine potenzielle Denial-of-Service-Schwachstelle durch fehlerhafte ACL-Selektoren.
  - **CVE-2024-31228**: Behebte eine potenzielle Denial-of-Service-Schwachstelle, die durch ungebundenes Pattern-Matching verursacht wurde.

### Redis 6.2.15 (18. Oktober 2023)
- **Sicherheitsfixes**
  - **CVE-2023-45145**: Behebte eine Race-Condition während des Startvorgangs, die durch die falsche Reihenfolge der Systemaufrufe `listen(2)` und `chmod(2)` verursacht wurde. Diese Schwachstelle hätte einem anderen Prozess ermöglicht, die vorgesehenen Unix-Socket-Berechtigungen zu umgehen.

## Release 6.2.14-3

- Die Cloudogu-eigenen Quellen werden von der MIT-Lizenz auf die AGPL-3.0-only relizensiert.
