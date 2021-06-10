/**
 * author : Levi
 * Purpose: Another Research on EC2 Credential Compromise
 * */

const AWS = require('aws-sdk');

const sesRegion = process.env.REGION || 'us-west-2';
const ses = new AWS.SES({
  region: sesRegion,
});

const sendEmail = (sender, recipients, message) => {
  return new Promise((resolve, reject) => {
    const params = {
      Destination: {
        ToAddresses: recipients,
      },
      Message: {
        Body: {
          Html: {
            Data: message.body,
            Charset: 'iso-8859-1',
          },
        },
        Subject: {
          Data: message.subject,
          Charset: 'iso-8859-1',
        },
      },
      Source: sender,
    };
    ses.sendEmail(params, (err, data) => {
      if (err) {
        reject(err);
      } else {
        resolve(data);
      }
    });
  });
};


exports.handler = async (event) => {
  console.log(JSON.stringify(event));
  // environment
  const env = process.env.ENVIRONMENT || 'dev';
  // add SENDER and RECIPIENTS in environment variables to override these
  const sender = process.env.SENDER || 'noreply@yourmail.com';
  const recipients = process.env.RECIPIENTS.split(',') || ['mydefaultrecipients@yourmail.com'];

  const time = new Date(event.time);
  time.setHours(time.getHours() + 8);
  const timeSGT = `${time.toLocaleDateString()} ${time.toLocaleTimeString()} SGT`;

  const accountID = event.account;
  const findingID = event.detail.id;

  const level = event.detail.severity;
  let severity = '';

  if (level >= 0.1 && level <= 3.9) {
    severity = 'Low';
  } else if (level >= 4 && level <= 6.9) {
    severity = 'Medium';
  } else {
    severity = 'High';
  }

  // TODO implement
  let body = '<p>GuardDuty Finding Alert</p>';
  body += '<table cellpadding="2">';
  body += `<tr align="left" valign="top"><td align="left" valign="top"><string>Event Time</string></td><td>:</td><td>${timeSGT}</td></tr>`;
  body += `<tr align="left" valign="top"><td align="left" valign="top"><string>Finding ID</string></td><td>:</td><td>${findingID}</td></tr>`;
  body += `<tr align="left" valign="top"><td align="left" valign="top"><string>Account ID</string></td><td>:</td><td>${accountID}</td></tr>`;
  body += `<tr align="left" valign="top"><td align="left" valign="top"><string>Type</string></td><td>:</td><td>${event.detail.type}</td></tr>`;
  body += `<tr align="left" valign="top"><td align="left" valign="top"><string>Title</string></td><td>:</td><td>${event.detail.title}</td></tr>`;
  body += `<tr align="left" valign="top"><td align="left" valign="top"><string>Severity</string></td><td>:</td><td>${severity}</td></tr>`;
  body += `<tr align="left" valign="top"><td align="left" valign="top"><string>Description</string></td><td>:</td><td>${event.detail.description}</td></tr>`;
  body += '</table>';

  const message = {
    subject: `[${env}][GuardDuty Alert] ${event.detail.type}`,
    body,
  };

  try {
    const response = await sendEmail(sender, recipients, message);
    console.log(`Success Sending Email: ${JSON.stringify(response)}`);
  } catch (e) {
    console.log(`Error Sending Email: ${e}`);
  }
};
