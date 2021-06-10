// script to print log entries from GCP Cloud Logging

const { Logging } = require('@google-cloud/logging');

const getLogEntries = async () => {
  const logging = new Logging();
  // replace this project id
  const projectId = '[PROJECT_ID]';
  const options = {
    pageSize: 10,
    filter: `resource.type="gce_firewall_rule" AND logName="projects/${projectId}/logs/cloudaudit.googleapis.com%2Factivity"`,
  };

  // const entries = null;
  try {
    const [entries] = await logging.getEntries(options);
    entries.forEach((entry) => {
      console.log(entry.data.value.toString());
    });
  } catch (e) {
    console.log(e);
  }
};

getLogEntries();

