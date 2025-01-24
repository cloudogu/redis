# Release Notes

Im Folgenden finden Sie die Release Notes für das Sonatype Nexus-Dogu. 

Technische Details zu einem Release finden Sie im zugehörigen Changelog.


## Release 6.2.17-1

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
