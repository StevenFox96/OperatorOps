# How to become a dWeb Operator?

The setup process of becoming a dWeb operator consists of three parts:

1. Deployment of smart contracts to EOS blockchain.
2. Deployment of the dWeb's application to an IPFS network.
3. DNS configuration.  

Although the above steps may look complex at first glance, don't worry, this process is fully automated via a github action pipeline.
If you are not familiar with github actions, it's simply an automation framework that helps developer manage their application lifecycle.
As you would see in the next steps, we will utilize this framework in our journy to become an dWeb Operator. 

### Work environment arrangment:
First thing first, before we can deploy anything, let's arrange our work environment.

#### 1. Connect to GitHub.com and get the sources.
1. Login to your github.com account.
   > if you don't have one already, you can create a new account [here](https://github.com/join?source=login).
2. Navigate to the [Creator-Eco/OperatorOps](https://github.com/Creator-Eco/OperatorOps) repository.
3. On the upper-right side click the **Fork** button, to copy the repo to your account.
   
   ![fork the Creator-Eco/OperatorOps](images/github-fork.png)

#### 2. Configure the github actions pipeline.
1. In order to activate the github actions workflow, we first need to defined a few environment variables:
    
    - Navigate to the **Settings** -> **Secrets** tab.
    ![actions tab](images/github-settings-tab.png)
    - Click the *'Add a new secrets'* button, and add the following Secrets:
      ```
      Name: EOS_PRIVATE_KEY
      Value: <Your EOS private key>

      Name: PINATA_API_KEY
      Value: <Your Pinata api key>

      Name: CLOUDFLARE_API_KEY
      Value: <Your Cloudflare api key>     
      ```
    - At the end of the process, your screen should look like that...
     ![actions tab](images/github-secrets-screen.png)

2. Navigate to the **Actions** tab and activate the workflow.