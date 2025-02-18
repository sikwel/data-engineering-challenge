# siːkwəl: Data Engineering Challenge 🚀

Moin moin! Willkommen zum Data Engineering Projekt – hier geht's um Docker, Python, Open-Meteo API und ein paar Daten! Lies dir die Anleitung sorgsam durch und starte direkt mit dem Projekt.

## Was du brauchst

### Git

Kein Git? Kein Problem! Schnapp es dir hier: [Git Downloads](https://git-scm.com/downloads)

### Docker Desktop

Für die Challenge benötigst du Docker Desktop: [Docker Desktop](https://www.docker.com/products/docker-desktop)

#### Für Windows-Nutzer: WSL2 ist ein Muss

Falls du Windows nutzt, vergewissere dich, dass WSL2 installiert ist. Hier findest du eine Anleitung: [WSL2 Installation Guide](https://docs.docker.com/desktop/wsl/)

### VSCode

Als Entwicklungsumgebung nutzen wir einen vordefinierten Docker-Container. Hier haben wir dir schonmal ein paar hilfreiche Pakete vorinstalliert. Damit das läuft, benötigst du VSCode. Falls du bereits eine andere IDE hast, die sich mit einem Docker-Container verbindet, auch gut!

## Projekt-Setup

1. Klone das Repo:

    ```bash
    git clone https://github.com/sikwel/data-engineering-challenge.git
    cd data-engineering-challenge
    ```

2. Öffne das Projekt in Visual Studio Code – der Devcontainer regelt!

3. Falls etwas fehlt installiere es dir einfach per `pip`.

## Was wir machen

Unser Test-Projekt hat ein paar Aufgaben für dich vorgesehen:

1. **Mit der Open-Meteo API das Wetter checken:**
    - Schnapp dir die [Wetterdaten](https://open-meteo.com/) mit der Open-Meteo API.
    - Nutze Pythons `request` library
    - Wir wollen uns historische Wetterdaten (auf Stundenbasis) für **Region** aus dem AdventureWorks Datenset anschauen. Falls es hier keine genauen Standorte gibt, wähle einfach einen Ort für aus der jeweiligen Region. (Bspw. United States / Northwest -> Salem). Uns interessieren vor allem folgende Parameter:
        - Temperature
        - Relative Humidity
        - Rain
        - Weather Code
        - Wind Speed
        - Surface Pressure
    - Überlege dir ein geeigntes Logging im Fehler- oder Erfolgsfall. Das hilft nicht nur beim Debugging sondern freut den Benutzer 👍
    - Zeige deine Skills im Umgang mit APIs und Datenextraktion.

2. **Daten in DuckDB pumpen:**
    - Lade die Daten in ein lokales [DuckDB](https://duckdb.org/)
    - Damit es nicht zu langweilig wird, soll beim Start entschieden werden, welche Lade-Strategie man verwenden möchte.
        - **Full-Refresh:** Alle Daten im Data Warehouse werden überschrieben und neu eingefügt.
        - **Incremental:** Nur neue Daten werden werden in das Data Warehouse geladen
    - Schau dir den Response an und überlege dir, wie die Daten sinnvoll in DuckDB geschrieben werden müssen.

3. **Steuerung des Python-Skripts:**
    - Folgende Parameter des API-Aufrufs sollten per Kommandozeile überschrieben werden können:
        - Latitude
        - Longitude
        - Start Date
        - End Date
        - Timezone

4. **Modellierung der Daten mittels dbt:**
 
    - Modelliere die Adventure Works- und Wetterdaten mithilfe des data build tools
    - Orientiere dich hierbei an bekannten Datenmodellierungsansätzen und wähle den aus deiner Sicht besten Ansatz für die vorliegenden Daten
    - Fokus der Modellierung soll auf der Analyse der Umsätze nach von dir ausgewählten Kriterien (die 3 wichtigsten reichen) und der Verbindung zwischen dem *Wetter* und *Verkaufszahlen* liegen

4. **Docker-Container:**
    - Packe deine Implementierung in einen Docker-Container.
    - Am Ende wollen wir deine Anwendung im Docker-Container starten und die Parameter für den API Aufruf übergeben. Die Ausgabe des Loggings sollten in der Konsole zu sehen sein.

5. **...and beyond:**
    - Halt den Code clean und kommentiere klug.
    - Definiere Funktionen und Klassen wo sinnvoll.
    - Nutze `git` um dein Projekt zu versionieren und am Ende wieder in das Repository zu pushen, damit wir uns dein Ergebnis anschauen können.

## Let's Code!

Viel Erfolg und vor allem viel Spaß beim Coden! Bei Fragen stehen wir dir zur Verfügung. Happy coding! 🚀✨

## Anhang

### Nützliche Links

- [Open-Meteo Dokumentation](https://open-meteo.com/en/docs)
- [DuckDB Dokumentation](https://duckdb.org/docs/sql/introduction)
- [Adventure Works 2022 CSVs](https://www.kaggle.com/datasets/algorismus/adventure-works-in-excel-tables)
