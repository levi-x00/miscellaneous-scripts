// aws lambda script to delete old indexes in Elasticsearch
// how to setup:
// - set env variables
//
const AWS = require('aws-sdk');

const awsCred = new AWS.EnvironmentCredentials('AWS'); // Lambda provided credentials
const region = 'ap-southeast-1';
const msPerDay = 1000 * 60 * 60 * 24;
const environment = process.env.ENVIRONMENT.split(';');
const retentionDay = parseInt(process.env.RETENTION_DAY, 10);

const dateDiffInDays = (d1, d2) => {
  const utc1 = Date.UTC(d1.getFullYear(), d1.getMonth(), d1.getDate());
  const utc2 = Date.UTC(d2.getFullYear(), d2.getMonth(), d2.getDate());
  return Math.floor((utc2 - utc1) / msPerDay);
};

// replace each elasticsearch endpoint accordingly
const domains = {
  prod: 'your-prod-es.ap-southeast-1.es.amazonaws.com',
  qa: 'your-qa-es.ap-southeast-1.es.amazonaws.com',
  dev: 'your-dev-es.ap-southeast-1.es.amazonaws.com',
};

const populateIndex = (domain, callback) => {
  const awsEndpoint = new AWS.Endpoint(domain);
  const req = new AWS.HttpRequest(awsEndpoint);

  req.method = 'GET';

  req.path = '/_cat/indices?v';
  req.region = region;
  req.headers['presigned-expires'] = false;
  req.headers.Host = awsEndpoint.host;

  const signer = new AWS.Signers.V4(req, 'es'); // es: service code
  signer.addAuthorization(awsCred, new Date());

  const send = new AWS.NodeHttpClient();
  send.handleRequest(req, null, (httpResp) => {
    let respBody = '';
    httpResp.on('data', (chunk) => {
      respBody += chunk;
    });
    httpResp.on('end', (chunk) => {
      const output = [];
      const logs = respBody.match(/(\w+|logs)-[^ ]+/g);
      logs.forEach((log) => {
        if (dateDiffInDays(
          new Date(log.replace(/(\w+|logs-)/, '')),
          new Date(),
        ) >= retentionDay) {
          output.push(log);
        }
      });
      if (output.length > 0) {
        callback(domain, output);
      }
    });
  }, (err) => {
    console.error(err);
  });
};

const sendRestAPI = (endpoint, method, command) => {
  const awsEndpoint = new AWS.Endpoint(endpoint);
  const req = new AWS.HttpRequest(awsEndpoint);
  req.method = method;
  req.path = command;
  req.region = region;
  req.headers['presigned-expires'] = false;
  req.headers.Host = awsEndpoint.host;

  const signer = new AWS.Signers.V4(req, 'es');
  signer.addAuthorization(awsCred, new Date());

  const send = new AWS.NodeHttpClient();
  send.handleRequest(req, null, (httpResp) => {
    let respBody = '';
    httpResp.on('data', (chunk) => {
      respBody += chunk;
    });
    httpResp.on('end', (chunk) => {
      const respObj = JSON.parse(respBody);
      if (respObj.errors) {
        console.error(respBody);
      } else if (process.env.DEBUG === 'true') {
        console.log(respBody);
      }
    });
  }, (err) => {
    console.log(err);
  });
};

// === main process ===
exports.handler = (event, callback) => {
  const target = domains[environment];
  populateIndex(target, (domain, outputs) => {
    outputs.forEach((output) => {
      if (!output.match('kibana-')) {
        // console.log('curl -XDELETE', `http://${domain}/${output}`);
        sendRestAPI(domain, 'DELETE', `/${output}`, null, null);
      }
    });
  });
};
