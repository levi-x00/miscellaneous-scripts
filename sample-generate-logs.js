// this script run on local computer
// prerequisites:
// 1. aws nodejs sdk installed
// 2. aws profile name is setup

const aws = require('aws-sdk');

// replace profile name
const credentials = new aws.SharedIniFileCredentials({ profile: 'your-profile-name' });
aws.config.credentials = credentials;
aws.config.update({
  region: 'ap-southeast-1',
});
const logs = new aws.CloudWatchLogs();

const getLogEvents = (logGroup, streamName) => {
  return new Promise((resolve, reject) => {
    const currDate = new Date();
    const oneDayAgo = currDate.setHours(currDate.getHours() - 250);
    const params = {
      logGroupName: logGroup,
      logStreamName: streamName,
      endTime: +new Date(),
      limit: 10,
      startTime: oneDayAgo,
    };
    logs.getLogEvents(params, (err, data) => {
      if (err) reject(err);
      else resolve(data);
    });
  });
};

const createLogStream = (logGroup, streamName) => {
  return new Promise((resolve, reject) => {
    const params = {
      logGroupName: logGroup,
      logStreamName: streamName,
    };
    logs.createLogStream(params, (err, data) => {
      if (err) reject(err);
      else resolve(data);
    });
  });
};

const putLogEvents = (events, logGroup, streamName, token = null) => {
  return new Promise((resolve, reject) => {
    const params = {
      logEvents: events,
      logGroupName: logGroup,
      logStreamName: streamName,
      sequenceToken: token,
    };
    logs.putLogEvents(params, (err, data) => {
      if (err) reject(err);
      else resolve(data);
    });
  });
};

const describeLogStream = (logGroup, streamName) => {
  return new Promise((resolve, reject) => {
    const params = {
      logGroupName: logGroup,
      logStreamNamePrefix: streamName,
      // orderBy: 'LastEventTime',
    };
    logs.describeLogStreams(params, (err, data) => {
      if (err) reject(err);
      else resolve(data);
    });
  });
};

const run = async (logGroup, streamName) => {
  // const samples = [];
  // try {
  //   const response = await getLogEvents(logGroup, streamName);
  //   // console.log(response);
  //   response.events.forEach((event) => {
  //     // console.log(event);
  //     samples.push(event.message);
  //   });
  //   // console.log(samples);
  // } catch (e) {
  //   console.log(e);
  // }

  // // ========= to get the next token ===========
  let token = null;
  try {
    const response = await describeLogStream(logGroup, streamName);
    token = response.logStreams[0].uploadSequenceToken;
  } catch (e) {
    console.log(e);
  }

  // // ==== create logs stream ====
  // try {
  //   const createLogStreamResp = await createLogStream(logGroup, streamName);
  //   console.log('Response:');
  //   console.log(createLogStreamResp);
  // } catch (e) {
  //   console.log(e);
  // }

  // ==================================
  const events = [];
  const samples = [
    'some logs samples',
    'some logs samples',
  ];

  samples.forEach((s) => {
    events.push({
      timestamp: +new Date(),
      message: s,
    });
  });
  try {
    const putLogEventsResp = await putLogEvents(events, logGroup, streamName, token);
    console.log(putLogEventsResp);
  } catch (e) {
    console.log(e);
  }
};

// put log stream here
const logStream = 'Your-LogStream-Here';
// put log group here
run('Your-LogGroupName', logStream);

