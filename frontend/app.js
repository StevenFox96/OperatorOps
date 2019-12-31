const pinataSDK = require('@pinata/sdk');
const pinata = pinataSDK('process.env.PINATA_API_KEY', 'process.env.PINATA_SECRET_API_KEY');

pinata.testAuthentication().then((result) => {
    //handle successful authentication here
    console.log(result);
}).catch((err) => {
    //handle error here
    console.log(err);
});