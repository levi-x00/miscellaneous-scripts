/* eslint-disable no-restricted-syntax */
// script to start RDS instances
const aws = require('aws-sdk');

// replace 'your-profile-name'
const credentials = new aws.SharedIniFileCredentials({ profile: 'your-profile-name' });
aws.config.credentials = credentials;
aws.config.update({
  region: 'ap-southeast-1',
});

const rds = new aws.RDS({ apiVersion: '2014-10-31' });
const funcs = {};

const sleep = (seconds) => {
  const start = new Date().getTime();
  const ms = seconds * 1000;
  for (let i = 0; i < 1e7; i++) {
    if ((new Date().getTime() - start) > ms) {
      break;
    }
  }
};

funcs.listAllRDS = (nextMarker) => {
  return new Promise((resolve, reject) => {
    const params = {
      MaxRecords: 20,
    };
    if (nextMarker) params.Marker = nextMarker;
    rds.describeDBInstances(params, (err, data) => {
      if (err) reject(err);
      else resolve(data);
    });
  });
};

funcs.startInstance = (dbId) => {
  return new Promise((resolve, reject) => {
    const params = {
      DBInstanceIdentifier: dbId,
    };
    rds.startDBInstance(params, (err, data) => {
      if (err) reject(err);
      else resolve(data);
    });
  });
};

const run = async () => {
  let nextMarker = null;
  while (true) {
    try {
      // eslint-disable-next-line no-await-in-loop
      const data = await funcs.listAllRDS(nextMarker);
      // eslint-disable-next-line no-restricted-syntax
      // eslint-disable-next-line no-undef
      for (db of data.DBInstances) {
        if (db.DBInstanceStatus !== 'available') {
          try {
            const resp = await funcs.startInstance(db.DBInstanceIdentifier);
            console.log(`${db.DBInstanceIdentifier} started!`);
          } catch (e) {
            console.log(`Error start rds id: ${db.DBInstanceIdentifier}`);
          }
          sleep(0.5);
        }
      }
      if (!data.Marker) break;
      nextMarker = data.Marker;
    } catch (e1) {
      console.log(e1);
    }
  }
};

run();
