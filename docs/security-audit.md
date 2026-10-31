# Sicherheitsprüfung: tor-socks-proxy

Geprüfter Stand: `PeterDaveHello/tor-socks-proxy`, Commit `c08514e9e7459a3b47fbf1c2a609d584ede903b4`, unveränderter Worktree. Profil: **standard**, gesamter Repository-Quellstand. Kein vorgegebenes Budget. Neun Agentenaufrufe: vier Reconnaissance-Prüfungen, drei Hunter sowie zwei unabhängige Coverage-Kritiker. Ein kompatibler früherer Audit-Ledger lag nicht vor.

## Ergebnis und Aussagegrenze

**Keine bestätigte Sicherheitslücke und kein nach unabhängiger Quellprüfung verbleibender konkreter Verdachtsfall.** Das ist eine Prüfung dieses kleinen Verpackungs- und Konfigurationsrepositorys, keine Sicherheitsgarantie für Tor, curl, Alpine, Container-Runtime oder eine reale Netzwerkkonfiguration. Es wurden keine laufenden Systeme, Registries oder fremden Dienste für den Audit getestet.

Die Durchführung war source-only innerhalb der vorgeschriebenen Source-/Local-Grenze. Für Zielcode-Ausführung waren weder ein vollständiger Offline-Tor-Toolchain noch alle erforderlichen Sandbox-Ressourcenlimits nachgewiesen. Deshalb wurden im Audit keine Builds, Zielprogramme oder Fixtures ausgeführt. Spätere Engineering- und Releaseprüfungen gehören zu einer getrennten Revision und ändern diese Evidenz nicht.

## Bestätigte Findings

Keine. `findings.json` enthält `[]`; es gibt keine Schweregrade zu vergeben. Da keine Kandidaten überlebt haben, waren Kandidatenvalidierung und abschließende Verifikation einzelner Finding-Records nicht anwendbar.

## NEEDS VALIDATION

Keine konkreten, quellenbelegten Boundary-Hypothesen blieben übrig. Fehlende Best Practices oder unbekannte Provider-Einstellungen wurden nicht als Schwachstellen dargestellt. Tatsächliche Host-Erreichbarkeit, Paketimplementierungen und externe Publisher-Pipelines sind außerhalb der Quell-Evidenz und bleiben allgemeine Scope-Grenzen.

## Nachvollziehbare Verbesserungen

- `docker-compose.yml:9` leitet DNS an Container-Port 53 weiter, obwohl `torrc:3` auf 8853 lauscht. Das ist ein bestätigter Funktionsfehler, keine belegte Sicherheitsverletzung.
- `Dockerfile:7-10`: stabile Paketquellen verwenden, wenn diese die benötigten Tor-/Transport-Versionen bereitstellen; Edge-/Testing-Mischung vermeiden.
- `Dockerfile:1`: Basis-Image-Digest festschreiben und kontrolliert aktualisieren. Aufgelöste Pakete und Image-Identitäten im Release dokumentieren.
- `Dockerfile:14`: Konfiguration root-eigen und schreibgeschützt halten; dem Dienst nur das private Datenverzeichnis schreibbar geben.
- `.dockerignore:1-4`: Build-Kontext auf tatsächlich kopierte Laufzeitdateien begrenzen.
- `docker-compose.yml:4-11`: Capabilities entfernen, neue Privilegien verbieten, Root-Dateisystem schreibschützen und Ressourcen begrenzen. Diese Maßnahmen sind zusätzliche Absicherung; ein Host-Escape wurde nicht gefunden.
- `torrc:5`: privaten persistenten Datenträger und stabile Dienst-UID/GID vorsehen, damit Guard-/Tor-Zustand Imagewechsel übersteht.
- `Dockerfile:16-17`: den Facebook-Onion-Healthcheck durch eine zeitlich und mengenmäßig begrenzte Tor-Prüfung ersetzen. Keine unnötigen Redirects oder Klartextprotokolle zulassen.
- `.travis.yml:13-24`: ungepinntes npx und veraltete parallele CI durch einen gepflegten Build-/Testablauf ersetzen. Veröffentlichung ausschließlich aus vertrauenswürdigem Branch und anhand der getesteten Artefakte.
- `README.md:70-73`: keinen garantierten IP-Wechsel nach zehn Minuten oder einem Neustart versprechen.

## Positive Quellmuster

Tor startet direkt unter einem Benutzer ohne Root-Rechte (`Dockerfile:19-22`). Das Datenverzeichnis erhält Modus 0700 (`Dockerfile:11`). Es wird nur die benannte `torrc` kopiert, kein gesamter Quellbaum (`Dockerfile:14`). Dokumentation und Compose binden Host-Ports an Loopback. Ein ControlPort, ein privilegierter Entrypoint, ein Docker-Socket-Mount, Klartext-Geheimnisse oder eine Veröffentlichung mit privilegierten Pull-Request-Inputs sind im geprüften Stand nicht vorhanden.

## Abdeckung

Neun deterministische Einheiten wurden anhand konkreter Quellpfade geschlossen: SOCKS-Publikation, DNS-Publikation, Prozess-/Host-Autorität, privater Zustand, Build-Abhängigkeiten, CI, Geheimnisse im Repository, Healthcheck und Neustart/Lifecycle. Status: **9 covered, 0 candidate, 0 blocked, 0 deferred**. Beide unabhängigen Coverage-Kritiker meldeten keine zusätzlichen Einheiten oder Wiederholungsaufträge. `coverage-ledger.json` enthält Prüfungen und Zuordnung der Attack-Class-Blöcke.

Tor-/curl-Protokollimplementierungen, Kryptografie in Abhängigkeiten, reale Host-Firewalls, Provider-Berechtigungen und außerhalb des Repositorys betriebene Update-/Releasepipelines waren nicht im Quellumfang. Nicht vorhandene Web-, Tenant-, Cloud-IAM-, Browser-, Mobile- oder AI-Subsysteme wurden nicht erfunden. Ein einzelner Audit erschöpft den Gegenstand nicht.

Beide maschinellen Validatoren (`validate-findings.cjs`, `validate-coverage-ledger.cjs`) bestehen. Die nachfolgende Fork-Implementierung ist ein eigener Quellstand und wird gesondert geprüft und getestet.
