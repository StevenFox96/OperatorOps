## Introduction  

This repository consists of source code, binaries and set of configuration files that works together to enable an easy to deploy and maintain the **Creator.eco Operator Core** (CEO Core) system.

The **CEO Core** is a web application based on a fully decentralized infrastructure, this guide will walk you through the installation and configuration of each of the involved components in the system.

As part of our installation process we'll need to configure some 3rd party services.  
Along the way we have tested many combinations of 3rd party service provider stacks, we found that the service providers stack which is the most easy-to-use is the one below:

1. [Blockstart - CreatorEco Package](https://dsphq.io/packages/blockstartac/ipfsservice1/blockpack2) for the DSP (dApp Service Provider) package.  
   > **Testnet**:  
   [Blockstart - CreatorEcoTest Package](https://dsphq.io/packages/blockstartac/ipfsservice1/blockpack2) for the DSP (dApp Service Provider) package.  
2. [Pinata](https://pinata.cloud/) for the IPFS pinning service provider.  
3. [Cloudflare](https://www.cloudflare.com/) for the DNS configuration service provider. 

**Please note!**  
Altough there is more than one alternative for each of the above mentioned service providers, this installation guide provided to you with a set of automations based on GitHub's automation freamwork ([GitHub's Actions](https://help.github.com/en/actions/automating-your-workflow-with-github-actions)) which are configured to work with the API of the above service providers stack. Therefore, if you choose to change the service providers stack defined above, the automations attached to this repository will stop working, and you'll need to perform some steps in the installation process manually.  

In addition, we having a clear roadmap regarding adding support for more service providers in our automation, but we will be more than happy to accept you *Pull Requests* :)

<br/><br/>
Next: [Prerequisites](02-prerequisites.md)  
Previous: [Home](../README.md)
