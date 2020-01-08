# Creator.eco Operator Setup Guide

This is a step-by-step installation guide to become a **Creator.eco Operator** (CEO).  
You can read more about the **Creator.eco** ecosystem and the different roles it has [here](https://google.com).

**Please Note!**  
> This installation guide has two installation paths.  
> The first, which is the main path, refer to an installation process of the **CEO Core** components in a production environment, the EOS mainnet.  
> The second path, which is also labled with the word **Testnet** in the relevant places in this guide, refer to an installation process of the **CEO Core** components in a sandbox environment, in this guide we use the [Kylin](https://www.cryptokylin.io/) testnet as our sandbox environment which can provide a playground for the EOS contracts that are part of the **CEO Core** components.  


## Target Audience

The target audience for this guide is someone planning to support a production deployment of the **CEO Core** components and wants to understand how everything fits together.


## Copyright

[![CC BY 4.0][cc-by-shield]][cc-by]  
[![CC BY 4.0][cc-by-image]][cc-by]

[cc-by-image]: https://i.creativecommons.org/l/by/4.0/88x31.png
[cc-by]: http://creativecommons.org/licenses/by/4.0/
[cc-by-shield]: https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg

This work is licensed under a [Creative Commons Attribution 4.0 International
License][cc-by].


[License agreement](LICENSE)


## Table of contents:

1. [Introduction](docs/01-introduction.md)
2. [Prerequisites](docs/02-prerequisites.md)
3. [System Architecture](docs/03-architecture.md)
4. [Installation process overview](docs/04-overview.md)
5. [Work environment arrangment](docs/05-work-env-arrange.md)  
    5.1. [Fork the OperatorOps GitHub's repository](docs/06-fork-repo.md)   
    5.2. [Collect API secrets](docs/07-collect-api-keys.md)  
    5.3. [Configure GitHub's actions pipeline secrets](docs/08-create-secrets.md)  
    5.4. [Enable the GitHub's actions pipeline](docs/09-enable-pipeline.md)  
6. [Create a Release and run the installation process](docs/10-create-release.md)  
7. [Installation validation](docs/11-validation.md)  
8. [Summary](docs/12-summary.md)