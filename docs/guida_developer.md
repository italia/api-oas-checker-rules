# Guida alla verifica delle interfacce OpenAPI per developer

Durante lo sviluppo di un'API può essere utile avere una visione in tempo reale di errori e warning all'interno della specifica.

## Strumenti di verifica

Per questo, è consigliabile utilizzare gli strumenti di verifica:

* All'interno del proprio IDE per indicare in tempo reale e puntualmente quanto rilevato. [Qui](guida_validazione.md#secondo-metodo-lestensione-per-ide) è presente un esempio relativo a VSCode.
* All'interno della propria pipeline di CI/CD (Continuous Integration/Continuous Delivery), per avere un rapporto immediato di eventuali errori o warning nel momento in cui si fanno delle modifiche al repository. [Qui](guida_validazione.md#quarto-metodo-github-action) è presente un esempio che utilizza le GitHub Action.

## Altri strumenti di sviluppo

È possibile utilizzare un editor come [Swagger](https://editor.swagger.io/) per:

* visualizzare graficamente e analizzare un'interfacce OpenAPI;
* sviluppare codice che implementi l'API;
* effettuare test in tempo reale.
