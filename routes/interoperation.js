const express = require("express");
const router = express.Router();
const config = require("../config");
const { randomUUID } = require("crypto");
const { S3Client, PutObjectCommand } = require("@aws-sdk/client-s3");
const { getSignedUrl } = require("@aws-sdk/cloudfront-signer");
const fs = require("fs").promises;
const os = require("os");
const path = require("path");
// GET ping-pong for health check
router.get("/ping", function (req, res, next) {
  res.send(`pong`);
});

// GET app version
router.get("/version", function (req, res, next) {
  res.json({
    version: config.version,
    date: config.date,
  });
});

router.post('/get-manifest-file-signed-url', async function(req, res, next) {
  console.log('returning Signed URL')
  try {
    // Check if the necessary data is in the request body
    if (!req.body || !req.body.manifest) {
      console.log('Missing manifest data in the request body.')
      return res.status(400).send({
        error: 'Bad Request',
        message: 'Missing manifest data in the request body.'
      });
    }
   
    let response = await uploadManifestToS3(req.body);
    
    res.send({
      manifestSignedUrl: response
    });
  } catch (error) {
      console.error(error);
      console.log('An unknown error occurred while processing the request.')
      return res.status(500).send({
        error: 'Internal Server Error',
        message: error.message || 'An unknown error occurred while processing the request.'
      });
  }
});

async function uploadManifestToS3(parameters) {
  try {
    const s3Client = new S3Client({
      region: config.AWS_REGION,
      // credentials: {
      //   accessKeyId: config.S3_ACCESS_KEY_ID,
      //   secretAccessKey: config.S3_SECRET_ACCESS_KEY,
      // },
    });
    
    //convert body into a CSV file
    const manifestCsv = parameters.manifest
    const tempCsvFile = `${randomUUID()}.csv`;
    const tempCsvFilePath = path.join(os.tmpdir(), tempCsvFile);
    try {
        console.log("write File to temp dir")
        await fs.writeFile(tempCsvFilePath, manifestCsv, {
          encoding: "utf-8",
        });
    } catch (e){
        console.log("Failed to write File to temp dir")
      try{
        
        console.log('Attempting to Stringify data')
        const manifestCsvTry = JSON.stringify(parameters.manifest)
        await fs.writeFile(tempCsvFilePath, manifestCsvTry, {
          encoding: "utf-8",
        });}
      catch (e){
        console.log('Failed to Write to file , Malformed data ', e)
        //   return getSignedUrl({
        //     url: `Failed to Write to file , Malformed data `,
        //     dateLessThan: new Date(
        //       Date.now() + 1000 * config.SIGNED_URL_EXPIRY_SECONDS
        //     ),
        // });
      }
    
    }
    

    const uploadParams = {
      Bucket: config.FILE_MANIFEST_BUCKET_NAME,
      Key: tempCsvFile,
      Body: await fs.readFile(tempCsvFilePath, { encoding: "utf-8" }),
    };
    const uploadCommand = new PutObjectCommand(uploadParams);
    //upload CSV
    console.log('Sending upload to S3Client')
    console.log(config.FILE_MANIFEST_BUCKET_NAME)
    try {
    await s3Client.send(uploadCommand)
    }
   catch (e){
        console.log('Failed send file to s3 ', e);
        console.error('Failed send file to s3 ', e);
    //   return getSignedUrl({
    //     url: `S3 failed connect `,
    //     dateLessThan: new Date(
    //       Date.now() + 1000 * config.SIGNED_URL_EXPIRY_SECONDS
    //     ),
    // });
    }
    console.log('returning Signed URL')
    return getSignedUrl({
      keyPairId: config.CLOUDFRONT_KEY_PAIR_ID,
      privateKey: config.CLOUDFRONT_PRIVATE_KEY,
      url: `${config.CLOUDFRONT_DOMAIN}/${tempCsvFile}`,
      dateLessThan: new Date(
        Date.now() + 1000 * config.SIGNED_URL_EXPIRY_SECONDS
      ),
    });
  } catch (error) {
    console.log('Failed getSignedUrl from cloudfront ', error);
    console.error(error);
  //   return getSignedUrl({
  //     url: 'code exits uploadManifestToS3' + error,
  //     dateLessThan: new Date(
  //       Date.now() + 1000 * config.SIGNED_URL_EXPIRY_SECONDS
  //     ),
  // });
  }
}

module.exports = router;
