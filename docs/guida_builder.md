# Guida alla buil delle regole Spectral per verificare per le specifiche OpenAPI (OAS) del ModI

## Introduzione

Questo repository contiene un insieme di regole per Spectral, utilizzate per verificare le interfacce OpenAPI riguardo al rispetto delle specifiche OpenAPI e dei modelli di interoperabilità tecnica per la Pubblica Amministrazione (PA).

## Struttura delle Cartelle

Attualmente, sono tre le cartelle di interesse:

- **rules**: contiene le regole relative al Modello di Interoperabilità (ModI) e altre regole opzionali;
- **security**: contiene regole relative agli aspetti di sicurezza, tutte opzionali;
- **override**: contiene file che, passati in input al builder, consentono di disattivare selettivamente alcune regole o di fare override delle relative proprietà. Al momento, si fa override solo della proprietà "severity" di Spectral, che indica la gravità della violazione. Tuttavia, il builder è progettato per supportare tutti i possibili altri override.

## Come Fare la Build

La build delle regole avviene in un container Docker. Dal `Makefile` incluso nel repository, è possibile evincere come eseguire il processo di build. Di seguito viene descritto il comando utilizzato per la build:

```sh
	docker run --rm\
		--user ${UID}:${GID} \
		-v "$(CURDIR)":/app\
		-w /app\
		-e RULES_FOLDERS=rules/\
		-e RULESET_NAME="Italian Guidelines"\
		-e RULESET_VERSION=1.0\
		-e RULESET_FILE_NAME=$(RULESET_DIR)/$@\
		-e TEMPLATE_FILE=rules/rules-template.yml.template\
		-e CONFIG_FILE=override/spectral-modi-override.yml\
		python:3.11-alpine\
		sh -c "python -m venv /tmp/venv; source /tmp/venv/bin/activate; pip install -r requirements.txt && python builder.py"
```

### Spiegazione del Comando

- `docker run --rm`: Avvia un container Docker e lo rimuove al termine dell'esecuzione.
- `--user ${UID}:${GID}`: Esegue il container con l'ID utente e il gruppo corrente.
- `-v "$(CURDIR)":/app`: Monta la directory corrente nel container sotto `/app`.
- `-w /app`: Imposta la directory di lavoro del container su `/app`.
- `-e RULES_FOLDERS=rules/`: Imposta la variabile d'ambiente `RULES_FOLDERS` per indicare la cartella (o le cartelle, separate da virgole) delle regole.
- `-e RULESET_NAME="Italian Guidelines Extended"`: Imposta la variabile d'ambiente `RULESET_NAME` con il nome che si vuole dare al set di regole; opzionale.
- `-e RULESET_VERSION=1.0`: Imposta la variabile d'ambiente `RULESET_VERSION` con la versione del set di regole; opzionale.
- `-e RULESET_FILE_NAME=$(RULESET_DIR)/$@`: Imposta la variabile d'ambiente `RULESET_FILE_NAME` con il percorso della cartella dove finirà il file in output.
- `-e TEMPLATE_FILE=rules/rules-template.yml.template`: Imposta la variabile d'ambiente `TEMPLATE_FILE` con il percorso del template delle regole; opzionale.
- `-e CONFIG_FILE=override/spectral-modi-override.yml`: Imposta la variabile d'ambiente `CONFIG_FILE` con il percorso al file di configurazione/override per la generazione delle regole; opzionale.
- `python:3.11-alpine`: Utilizza l'immagine Docker di Python 3.11 basata su Alpine, per la massima leggerezza e rapidità.
- `sh -c "python -m venv /tmp/venv; source /tmp/venv/bin/activate; pip install -r requirements.txt && python builder.py"`: Esegue una serie di comandi nel container:
  1. Crea un ambiente virtuale Python.
  2. Attiva l'ambiente virtuale.
  3. Installa le dipendenze elencate in `requirements.txt`.
  4. Esegue lo script `builder.py` per costruire le regole.

## Conclusione

Seguendo le istruzioni sopra descritte, è possibile effettuare la build delle regole per Spectral in modo da verificare le interfacce OpenAPI secondo le specifiche richieste.