# How to become a dWeb Operator?

The **dWeb Operator** role is one of the most fundamental building blocks of the **dWeb** ecosystem.  
A **dWeb Operator** has many responsibilities. Among them are managing the lifecycle of the **dWeb Application**, maintaining security, preserving the availability and reliability of the **dWeb Application** and customization for the target market.

For more in-depth information about the **dWeb Operator** role, and the other roles in the **dWeb eocsystem** please check [here](https://google.com).


### Intorduction:

Below you will find a step-by-step guide that will provide you all the necessary components to be a **dWeb Operator**. 

Although we use specific *service providers* ([*Cloudflare*](https://www.cloudflare.com/), [*Pinata*](https://pinata.cloud/) etc.) in this guide, plase note that each of this services has alternatives, and you are more than welcome to choose other service providers, and use them in your personal installation process.

Please note, as we've tested many configurations combinations for the *service providers* stack along the way, we've found that the *service providers* list below enable the most easy-to-use and configure installation process.

1. [Blockstart Base Package](https://dsphq.io/packages/blockstartac/ipfsservice1/blockpack2) as a DSP (dApp Service Provider) package.  
2. [Pinata](https://pinata.cloud/) as an IPFS pinning service.  
3. [Cloudflare](https://www.cloudflare.com/) as a DNS configuration service. 


### Prerequisites:

In order to complete this guide and become a **dWeb Operator**, you will need the following:

1. An active EOS account with a balance of 10000 DAPP tokens.  
2. An active [github](https://github.com/) account.
3. An active [Pinata](https://pinata.cloud/signup) account.
4. An active [Cloudflare](https://dash.cloudflare.com/sign-up) account. 

  > You can purchase DAPP tokens by using the [Bancor](https://www.bancor.network) or [NewDex](https://www.newdex.io).


### Configuration Architecture:

![dWeb architecture](images/dWeb-arch.png)


### Installation:

The **dWeb Operator** installation process consists of 5 major steps:

1. Select a DSP and a DSP package to use.
2. Stake DAPP tokens to the selected DSP.
3. Deploy the **dWeb Core** smart contract to the EOS blockchain.
4. Upload the **dWeb's Application** to the IPFS network.
5. Configure your DNS to point to the **dWeb Application**.  

Although the above steps may look complex at first glance, don't worry, most of this process is automated via a GitHub's actions pipeline.
If you are not familiar with GitHub's actions, it's simply an automation framework that helps developers automate their workflow and manage their application lifecycle.
As you will see in the next steps, we will utilize this framework in the journy to become an dWeb Operator. 


### Work environment arrangment:
First thing first, before we can deploy anything, we need to arrange our work environment.

#### 1. Fork the OperatorOps github's repository.
1. Login to your GitHub.com account.
   > if you don't have one already, you can create a new account [here](https://github.com/join?source=login).
2. Navigate to the [Creator-Eco/OperatorOps](https://github.com/Creator-Eco/OperatorOps) repository.
3. On the upper-right side click the **Fork** button, to copy the repo to your account.
   
   ![fork the Creator-Eco/OperatorOps](images/github-fork.png)

Great!! You now have your own copy of the **dWeb Core** source code.  
In the next step, we'll configure GitHub's actions pipeline. 


#### 2. Collect API secrets. 
Our GitHub's actions pipeline will work with the API of each of the *service providers* we mentioned above (Cloudflare, Pinata, etc.), in order to do that the GitHub's actions pipeline will use a dedicated API key for each of services.  

In this step we will create a separate GitHub's actions [Secret](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/creating-and-using-encrypted-secrets) variable that will be used later in the pipeline.

- EOS private key:  
  > With this key GitHub's actions pipeline will be able to deploy the **dWeb Core** smart contract to the EOS blockchain.  
  
  Depands on the way you've created your EOS account, either you used the ```cleos``` CLI or via an online service such as [Scatter](https://support.get-scatter.com/article/33-creating-an-eos-account), this guide assumes that you have access to your EOS account's private key.

- Pinata API key:
  > With this key GitHub's actions pipeline will be able to upload and start pinning the **dWeb appliaction** files in IPFS.
   
1. Connect to your [Pinata](https://pinata.cloud/signup) account.
2. In the upper-right corner, click on your profile image and navigate to your **Account Page**.
3. In the **Account Page**, the relevat values exists under the **PINATA API KEY** and **PINATA SECRET API KEY** fields.
   
![Pinata account page](images/pinata.png)

- Cloudflare API key:

  > With this key GitHub's actions pipeline will be able to configure your DNS to point to the location of the **dWeb appliaction** you have uploded to IPFS.

1. Connect to your [Cloudflare](https://dash.cloudflare.com/sign-up) account.
2. In the upper-right corner, click on your **My profile** button and navigate to you profile homepage.
3. Navigate to the **API Tokens** tab.
4. Click the **Create Token** button.
5. Fill the form as following:

![Cloudflare create Api token](images/cloudflare.png)

6. Click the **Continue to Summary** button, and then the **Create Token** button.
7. Save the API token you are provided for later use.

Super Baller!!! We now have all the necessary secrets in order to activate the OperatorOps GitHub's actions pipeline.

#### 3. Configure GitHub's actions pipeline secrets.

In this step we'll create a dedicated secret variable for each of the API secrets we collected in the privious step.
1. In the *OperatorOps* repository homepage, click the **Settings** tab and then select the **Secrets** tab.  
  ![github's settings tab](images/github-settings-tab.png)

2. For each of the API secrets you collected earlier, create a **Secret** variable with the corresponding names:
      ```
      Name: EOS_PRIVATE_KEY
      Value: <Your EOS private key>

      Name: PINATA_API_KEY
      Value: <Your Pinata api key>

      Name: PINATA_SECRET_API_KEY
      Value: <Your Pinata secret api key>

      Name: CLOUDFLARE_API_KEY
      Value: <Your Cloudflare api key>     
      ```
   At the end of the process, your setup should look like this...
     ![github's actions secrets](images/github-secrets-screen.png)

Yay! Now that we defined all the secrets we need, let's go and activate the github's actions pipeline.

#### 4. Activate the github's actions pipeline.

1. Navigate to the **Actions** tab and activate the workflow.
  ![github's actions secrets](images/github-activate-workflow.png)

2. 
