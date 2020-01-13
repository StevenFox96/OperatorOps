const pinataSDK = require('@pinata/sdk');
const pinata = pinataSDK(process.env.PINATA_API_KEY, process.env.PINATA_SECRET_API_KEY);
const sourcePath = '../src/';
const options = {
    pinataMetadata: {
        name: process.env.PINATA_API_KEY,
        keyvalues: {
            customKey: 'customValue',
            customKey2: 'customValue'
        }
    },
    pinataOptions: {
        cidVersion: 0
    }
};

pinata.pinFromFS(sourcePath, options).then((result) => {
    console.log(result.IpfsHash);
}).catch((err) => {
    console.log(err);
});