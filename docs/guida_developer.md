# 🧑‍💻 Guida alla Verifica delle interfacce OpenAPI per Developer

Durante lo sviluppo di un servio può essere utile avere una visione in tempo reale di errori e warning della interfaccia OpenAPI.

## 🛠️ Strumenti di Verifica

A tal proposito, è consigliabile utilizzare gli strumenti di verifica:

* All'interno del proprio IDE per indicare in tempo reale e puntualmente quanto rilevato.
[Qui](guida_verifica.md#secondo-metodo-lestensione-per-ide) è presente un esempio relativo a VSCode.
* All'interno della propria pipeline di CI/CD (Continuous Integration/Continuous Delivery), per avere un rapporto immediato di eventuali errori o warning nel momento in cui si fanno delle modifiche al repository. [Qui](guida_verifica.md#quarto-metodo-github-action) è presente un esempio che utilizza le GitHub Action.

## 🛠️ Altri Strumenti di Sviluppo

È possibile utilizzare un editor come [Swagger](https://editor.swagger.io/) per:

* visualizzare graficamente e analizzare un'interfacce OpenAPI;
* sviluppare codice che implementi l'API;
* effettuare test in tempo reale.