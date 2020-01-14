## Configure GitHub's actions pipeline secrets  

In this step we'll create a dedicated secret variable for each of the API secrets collected in the previous step.

1. In the *OperatorOps* repository homepage, click the **Settings** tab and then select the **Secrets** tab.  
  ![github's settings tab](images/github-settings-tab.png)

2. For each of the API secrets you collected earlier, create a **Secret** variable with the corresponding names:
      ```
      Name: EOS_PRIVATE_KEY
      Value: <Your EOS private key>
      
      **Testnet** If using Kylin, make sure to import your Kylin private key.

      Name: PINATA_API_KEY
      Value: <Your Pinata api key>

      Name: PINATA_SECRET_API_KEY
      Value: <Your Pinata secret api key>

      Name: CLOUDFLARE_API_KEY
      Value: <Your Cloudflare api key> 

      Name: CLOUDFLARE_ZONE_ID
      Value: <Your Cloudflare zone id> 
      ```

3. In addition, also add the following secrets:
     -  ```
        Name: OPERATOR_DOMAIN_NAME
        Value: <Your Domain Name>
        ```
        For example: operator.com, subdomains are **not** allowed.

     - ```
        Name: EOS_ACCOUNT_NAME
        Value: <Your EOS account name>
        ```
        This value will be used as the EOS smart contract name. 

      **Testnet**
     - ```
        Name: DEPLOY_TO_TESTNET
        Value: true/false (default is false) 
        ```
        When value is *true* the deployment of the **CEO Core** will be to the **Kylin** Testnet, else, the deployment will be to the EOS mainnet.

   At the end, your setup should look like this...
     ![github's actions secrets](images/github-secret-screen.png)

Great! Now we created the secrets variables the pipeline expect to be exists, we're almost done... next, we'll enable the GitHub's Actions pipeline

<br/><br/>
Next: [Enable the GitHub's Actions pipeline](09-enable-pipeline.md)
Previous: [Collect API secrets](07-collect-api-keys.md)  
