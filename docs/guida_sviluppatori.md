# Guida alla validazione delle API in formato OpenAPI per sviluppatori

Durante lo sviluppo di un'API può essere utile avere una visione in tempo reale di errori e warning all'interno della specifica.

## Strumenti di validazione

Per questo, è consigliabile utilizzare gli strumenti di validazione:

* all'interno del proprio editor, che indichi in tempo reale e puntualmente quanto rilevato. [Qui un esempio, relativo a VSCode](docs/guida_validazione.md#secondo-metodo-lestensione-per-ide)
* all'interno della propria pipeline di CI/CD (Continuous Integration/Continuous Delivery), per avere un rapporto immediato di eventuali errori o warning nel momento in cui si fanno delle modifiche al repository
  [Qui un esempio, che utilizza le GitHub actions](doc/guida_validazione.md##quarto-metodo-github-action)

## Altri strumenti di sviluppo

È possibile utilizzare un editor come [Swagger](https://editor.swagger.io/), che permetta di interpretare e analizzare un'API, nonché di creare parti di codice che implementino l'API ed effettuare test in tempo reale.
