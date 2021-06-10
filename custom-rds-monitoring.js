/**
 * Author: Levi
 * Purpose: to monitor RDS in Kibana, then send alert if necessary
 * Created:  17/01/2020
 * Setup:
 * // setup env variables
 * - ENVIRONMENT: dev/qa/prod
 */

const AWS = require('aws-sdk');

// npm install split-array
const splitArray = require('split-array');

// replace the region if necessary
AWS.config.update({
  region: 'ap-southeast-1',
});
const cloudwatch = new AWS.CloudWatch();
const rds = new AWS.RDS();
const currTime = () => {
  return new Date();
};
const minutes = 1;
const minutesBackoff = 1;
const period = minutes * 60;

const yyyyMMdd = currTime().toISOString().split('T')[0];

const startTime = new Date();
startTime.setMinutes(startTime.getMinutes() - (3 * minutesBackoff));

const endTime = new Date();
endTime.setMinutes(endTime.getMinutes() - (2 * minutesBackoff));

const listAllRDS = (nextMarker) => {
  return new Promise((resolve, reject) => {
    const params = {};
    if (nextMarker) params.Marker = nextMarker;
    rds.describeDBInstances(params, (err, data) => {
      if (err) reject(err);
      else resolve(data);
    });
  });
};

// set environment variables in aws lambda
const domains = {
  prod: 'your-prod-event-domain.ap-southeast-1.es.amazonaws.com',
  qa: 'your-qa-event-domain.ap-southeast-1.es.amazonaws.com',
  dev: 'your-dev-event-domain.ap-southeast-1.es.amazonaws.com',
};

const postToES = (document) => {
  // set the following environment variables
  const environment = process.env.ENVIRONMENT;
  // replace regoin if necessary
  const region = 'ap-southeast-1';
  const domain = domains[environment];
  const index = `rdsmon-${yyyyMMdd}`;
  const type = 'rdsmon';
  const endpoint = new AWS.Endpoint(domain);
  const request = new AWS.HttpRequest(endpoint, region);

  request.method = 'POST';
  request.path += `${index}/${type}`;
  request.body = JSON.stringify(document);
  request.headers.host = domain;
  request.headers['Content-Type'] = 'application/json';

  const credentials = new AWS.EnvironmentCredentials('AWS');
  const signer = new AWS.Signers.V4(request, 'es');
  signer.addAuthorization(credentials, new Date());

  const client = new AWS.HttpClient();
  client.handleRequest(request, null, (response) => {
    console.log(`${response.statusCode} ${response.statusMessage}`);
    let responseBody = '';
    response.on('data', (chunk) => {
      responseBody += chunk;
    });
    response.on('end', (chunk) => {
      console.log(`Response body: ${responseBody}`);
    });
  }, (error) => {
    console.log(`Error: ${error}`);
  });
};

// samples queries that need to be monitored
const createMetricQueries = (dbIdentifiers) => {
  const allQueries = [];
  const metrics = {
    CPUUtilization: {
      Unit: 'Percent',
      Stat: 'Average',
    },
    FreeStorageSpace: {
      Unit: 'Bytes',
      Stat: 'Average',
    },
    DatabaseConnections: {
      Unit: 'Count',
      Stat: 'SampleCount',
    },
    FreeableMemory: {
      Unit: 'Bytes',
      Stat: 'Average',
    },
    ReadIOPS: {
      Unit: 'Count/Second',
      Stat: 'SampleCount',
    },
    WriteIOPS: {
      Unit: 'Count/Second',
      Stat: 'SampleCount',
    },
  };

  Object.keys(metrics).forEach((metric) => {
    dbIdentifiers.forEach((dbID) => {
      const query = {
        Id: `${dbID.replace(/-/g, '')}_${metric}_${metrics[metric].Stat}`,
        MetricStat: {
          Metric: {
            Namespace: 'AWS/RDS',
            MetricName: metric,
            Dimensions: [{
              Name: 'DBInstanceIdentifier',
              Value: dbID,
            }],
          },
          Period: period,
          Unit: metrics[metric].Unit,
          Stat: metrics[metric].Stat,
        },
      };
      allQueries.push(query);
    });
  });
  return allQueries;
};

const getMetricData = (metricQueries) => {
  return new Promise((resolve, reject) => {
    const params = {
      MetricDataQueries: metricQueries,
      StartTime: startTime,
      EndTime: new Date(endTime),
      ScanBy: 'TimestampDescending',
    };
    cloudwatch.getMetricData(params, (err, data) => {
      if (err) reject(err);
      else resolve(data);
    });
  });
};

const main = async () => {
  const nextMarker = null;
  const rdsIds = {};

  // #1. Get all data RDS Data and Db Tags information
  while (true) {
    try {
      const data = await listAllRDS(nextMarker);
      for (db of data.DBInstances) {
        // replace the account id and region if necessary
        const resourceName = `arn:aws:rds:ap-southeast-1:ACCOUNT_ID:db:${db.DBInstanceIdentifier}`;
        try {
          const dbTags = await rds.listTagsForResource({
            ResourceName: resourceName,
          }).promise();
          db.DBTags = dbTags;
        } catch (e2) {
          console.log(e2);
        }
        if (db.DBInstanceStatus === 'available') {
          rdsIds[db.DBInstanceIdentifier] = {};
          rdsIds[db.DBInstanceIdentifier].instanceType = db.DBInstanceClass;
          rdsIds[db.DBInstanceIdentifier].engine = db.Engine;
          // Object.assign(rdsIds[db.DBInstanceIdentifier], {
          //   CPUUtilization: 0,
          //   FreeableMemory: 0,
          //   FreeableMemory: 0,
          //   DatabaseConnections: 0,
          // });
          db.DBTags.TagList.forEach((tag) => {
            rdsIds[db.DBInstanceIdentifier][tag.Key] = tag.Value;
          });
        }
      }
      if (!data.Marker) break;
    } catch (e1) {
      console.log(e1);
    }
  }

  // #2 Form queries
  const dbIds = Object.keys(rdsIds);
  const metricQueries = createMetricQueries(dbIds);
  const metricQueryBatches = splitArray(metricQueries, 100);

  // #3 Get metric queries
  for (batch of metricQueryBatches) {
    try {
      const results = await getMetricData(batch);
      results.MetricDataResults.forEach((item) => {
        // console.log(item);
        if (item.Values.length) {
          const [rdsId, metricName] = item.Label.split(' ');
          rdsIds[rdsId][metricName] = item.Values[0];
        }
      });
    } catch (e) {
      console.log(e);
    }
  }

  // #4 Post to ElasticSearch
  const rdsIdsList = Object.keys(rdsIds);
  for (let i = 0; i < rdsIdsList.length; i++) {
    const timestamp = new Date();
    const output = {};
    output['@timestamp'] = new Date(timestamp.setMinutes(timestamp.getMinutes() - 2 * minutesBackoff));
    output.rdsID = rdsIdsList[i];
    Object.assign(output, rdsIds[rdsIdsList[i]]);
    postToES(output);
  }
};

exports.handler = (event) => {
  main();
};
