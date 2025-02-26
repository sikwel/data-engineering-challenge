## 0. Repo erfolgreich in die Dev-Container-Umgebung geklont

## 1. Install additional requirements (ich wollte euer req-file nicht anrühren)
```
pip install -r requirements
```

## 2. Meteo Daten ziehen
### Variante A: Einmal alles, bidde
Aus dem Projektverzeichnis `utils\clean_and_load_all_data.sh` ausführen. Das initiert die DB (weil der erste Call ein `--load_type full` ist) und batch-loaded über entsprechende Args das Wetter für alle relevanten Regionen im relevanten Zeitraum.

### Variante B: Rumspielen und selber Daten auswählen über CLI Args
Aus dem Projektverzeichnis `extract_meteo\main.py` ausführen und über die Args bestimmen, was und wie geladen wird.
Achtung: Default config ist ein Increment Load. Der geht aber nur, wenn's bereits eine DB gibt, in die appended werden kann, es muss also eine `duckdb\dev_db.duckdb` existieren. Falls das nicht der Fall ist: Im ersten Schuss also `--load_type full` als args nehmen, wenn diese DB nicht besteht.

## dbt durchlaufen lassen
Aus dem dbt Projekt Folder ... falls es Probleme mit den Profiles gibt, direkt die .dbt Folder liegende profiles.yml einbinden:

- `dbt deps` Dependencies laden
- `dbt seed --profiles-dir ./.dbt` Seeds laufen lassen, ggf. `--full-refresh`
- `dbt seed --profiles-dir ./.dbt` Models laufen lassen
- `dbt seed --profiles-dir ./.dbt` for safety ;-)

## Insights
Wer dann Bock auf Business Insights hat, kann sich die Models `datamarts.analytics.*` angucken, bpsw:
- `SELECT * FROM {{ref("products_performance_alltime")}}`