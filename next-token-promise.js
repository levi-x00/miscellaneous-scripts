/**
 * Author: Levi
 * Purpose: sample script promise model to get all values in AWS
 * */


const AWS = require('aws-sdk');

const autoscaling = new AWS.AutoScaling({
  region: 'ap-southeast-1',
});

const describeASG = (nextToken) => {
  return new Promise((resolve, reject) => {
    const params = {};

    if (nextToken) params.NextToken = nextToken;

    autoscaling.describeAutoScalingGroups(params, (err, data) => {
      if (err) reject(err);
      else resolve(data);
    });
  });
};

const resolveASG = async () => {
  const results = [];
  let nextToken = null;

  while (true) {
    const data = await describeASG(nextToken);
    nextToken = data.NextToken;

    data.AutoScalingGroups.forEach((asg) => {
      results.push(asg);
    });

    if (data.NextToken === undefined) break;
  }
  console.log(results.length);
};

resolveASG();
