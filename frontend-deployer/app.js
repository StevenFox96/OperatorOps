const pinataSDK = require('@pinata/sdk');
const pinata = pinataSDK(process.env.PINATA_API_KEY, process.env.PINATA_SECRET_API_KEY);
const sourcePath = './frontend/src/';
const options = {
    pinataMetadata: {
        name: 'My Awesome Website',
        keyvalues: {
            customKey: 'customValue',
            customKey2: 'customValue2'
        }
    },
    pinataOptions: {
        cidVersion: 0
    }
};
pinata.pinFromFS(sourcePath, options).then((result) => {
    //handle results here
    console.log(result.IpfsHash);
}).catch((err) => {
    //handle error here
    console.log(err);
});