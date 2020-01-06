## Introduction <a name="introduction"></a>

This step-to-step guide will help you to deploy the **Creator.eco Operator Core** components (CEO Core) to EOS mainnet.  
The **CEO Core** are a collection of source code, binaries and configurations that are all operate together to enable the CEO to expose its website to his users.

The **CEO Core** installation process involves among other things a configuration of some 3rd party service providers such as **IPFS Pinning** service provider and **DNS configuration** service provider. As we've tested many configurations combinations for the service providers stack along the way, we've found that the service providers list below enable the most easy-to-use and configure installation process.

1. [Blockstart Base Package](https://dsphq.io/packages/blockstartac/ipfsservice1/blockpack2) for the DSP (dApp Service Provider) package.  
2. [Pinata](https://pinata.cloud/) for the IPFS pinning service provider.  
3. [Cloudflare](https://www.cloudflare.com/) for the DNS configuration service provider. 

> **Please note!**  
> Altough there is more than one alternative for each of the above mentioned service providers, this installation guide provided to you with a set of automations based on GitHub's automation freamwork ([GitHub's Actions](https://help.github.com/en/actions/automating-your-workflow-with-github-actions)) which are configured to work against the API of the above service providers stack. Therefore, if you'll choose to change the service providers stack defined above, the automations attached to this repository will stop working, and you'll need to make some steps in the installation process manually.  
> In addition, it worth mention we do have plans to improve the automation, and support more stacks of service providers, but for now, we only support the service providers stack defined above.


Next: [Prerequisites](02-prerequisites.md)