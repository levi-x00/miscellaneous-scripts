// Imports the Google Cloud client library.
// Script to get a file from gcp storage bucket and
// print the file content

const { Storage } = require('@google-cloud/storage');
const fs = require('fs').promises;

const localFile = 'D:\\My.Code\\JavaScript\\credentials.txt';

const main = async (bucketName, remoteFile, localFile) => {
  // 1. Download file from storage bucket
  const storage = new Storage();
  const params = {
    destination: localFile,
  };

  try {
    await storage
      .bucket(bucketName)
      .file(remoteFile)
      .download(params);
  } catch (e) {
    console.log(`Error get file from GCP storage. Error: ${e}`);
  }

  // 2. read the file content
  let content = '';
  try {
    content = await fs.readFile(localFile, 'utf-8');
  } catch (e) {
    console.log(`Error read file. Error: ${e}`);
  }
  console.log(content);
};

main('levi-playground', 'secret/credentials.txt', localFile);
