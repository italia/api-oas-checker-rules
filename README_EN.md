# Guide to Validating OpenAPI for Technical Interoperability of the Italian Public Administration

## Purpose of the Guide

This guide aims to provide the necessary instructions to validate OpenAPI interfaces to ensure they adhere to the rules of the Technical Interoperability Model for the Italian Public Administration (PA).

For more information on the model, you can download the document [here](https://www.agid.gov.it/sites/agid/files/2024-05/linee_guida_interoperabilit_tecnica_pa.pdf) and open it with Adobe Reader to view the attachments. The attachment with the rules is titled **Implementation Recommendations**.

## Validation Methods

## Validation Methods Index

1. 🌐 [First Method: the Website](#first-method-the-website)
2. 🖥️ [Second Method: IDE Extension](#second-method-ide-extension)
3. 💻 [Third Method: Command Line Interface (CLI)](#third-method-command-line-interface-cli)
4. ⚙️ [Fourth Method: GitHub Action](#fourth-method-github-action)

### First Method: the Website

#### Italian OpenAPI Validation Checker

[**Italian OpenAPI Validation Checker**](https://italia.github.io/api-oas-checker/) is a web app that allows you to validate OpenAPI interfaces directly from your browser, identifying all present errors.

To perform the validation, simply:
1. Insert the content of an OpenAPI interface.
2. Click on **Validate**.

![Italian OpenAPI Validation Checker](resources/img/website1.png)

#### Important

- Use the **ModI Guidelines** ruleset.
- Correct all errors highlighted in red.
- Optionally correct warnings highlighted in orange.
- Suggestions are highlighted in grey and are also optional.

### Second Method: IDE Extension

#### The Extension

Spectral, the tool behind the website, is also available as an extension for **Visual Studio Code** and other IDEs.

> **What is Spectral?**
> 
> Spectral is an open-source linting tool designed for validating, formatting, and cleaning JSON and YAML files. It is particularly useful for verifying OpenAPI specifications, ensuring they adhere to defined standards and best practices.
> 
> For more information, visit the official [Spectral](https://stoplight.io/open-source/spectral/) website.

#### Installation

You can download the extension from the integrated store in your preferred IDE, such as Visual Studio Code. The extension for Visual Studio Code can be downloaded [here](https://marketplace.visualstudio.com/items?itemName=stoplight.spectral).

![Installation on VS Code](resources/img/extension1.png)

#### Configuration

From the extension settings in the IDE, you need to configure the rules file. You can choose between two options:
1. Have the rules file locally on your computer and provide the relevant path.
2. Provide the remote URL (e.g., GitHub) to the rules file.

For files on GitHub, you can refer to the [official repository](https://github.com/italia/api-oas-checker-rules/releases) of the rules.

![Configuration on VS Code](resources/img/extension2.png)

#### Functionality

The extension highlights errors and warnings in real-time in the opened OpenAPI files (.yaml, .yml, or .json).

![Functionality on VS Code](resources/img/extension3.png)

### Third Method: Command Line Interface (CLI)

#### Command Line Interface (CLI)

Spectral can also be used from the command line (CLI) for bulk validation of OpenAPI.

On GitHub, at [this link](https://github.com/stoplightio/spectral), there is a guide for installing Spectral locally via npm (more info [here](https://www.npmjs.com/)) and yarn (more info [here](https://yarnpkg.com/)).

![Retrieving the tool](resources/img/cli1.png)

To validate an OpenAPI file, use the following command in the terminal:

```sh
spectral lint openapi_file_path –e utf8 –D –f json –o output_file_path –r rules_file_path -v
```

![Tool command](resources/img/cli2.png)

#### Command Parameters

- `openapi_file_path`: the path to the file containing the OpenAPI interface to be validated;
- `output_file_path`: the path to the output JSON file that will contain all identified errors;
- `rules_file_path`: the path to the rules file for validation, also remote.

#### Tip

By removing the `–D` parameter, the tool will also output warnings and suggestions for even greater compliance with best practices for interoperability and the OpenAPI 3 standard.

The output file, in JSON format, lists all occurrences where the rules were violated.

![Retrieving the tool](resources/img/cli3.png)

### Fourth Method: GitHub Action

#### GitHub Action

An easily integrable GitHub Action has been created that allows for the validation of OpenAPI interfaces with Spectral for every push and pull request on a repository. This solution automates the validation process, ensuring that every change is checked in accordance with established rules.

#### Customization

The action can be further customized by modifying, for example, the folder where the OpenAPI files are searched and the branches subject to the linter. This allows the action to be tailored to the specific needs of your project.

#### Working Example

At the link [resources/github-action.yml](resources/github-action.yml) you will find a working example of the GitHub Action. The Action always downloads the latest published ruleset, ensuring that validation is always up-to-date with the latest available rules. After execution, at the bottom of the execution page, as shown in the image, an archive with the results of the Spectral analysis on any OpenAPI files is available.

![Example on GitHub in the Action section](resources/img/github1.png)

We hope this guide is useful in ensuring your OpenAPI interfaces meet the required standards for technical interoperability in the Italian Public Administration. Happy validating!