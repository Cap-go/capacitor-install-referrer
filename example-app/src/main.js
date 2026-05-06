import './style.css';
import { InstallReferrer } from '@capgo/capacitor-install-referrer';

const output = document.getElementById('plugin-output');
const fetchAppleAttribution = document.getElementById('fetch-apple-attribution');
const referrerButton = document.getElementById('get-referrer');
const versionButton = document.getElementById('get-version');

const setOutput = (value) => {
  output.textContent = typeof value === 'string' ? value : JSON.stringify(value, null, 2);
};

referrerButton.addEventListener('click', async () => {
  try {
    const result = await InstallReferrer.getReferrer({
      fetchAppleAttribution: fetchAppleAttribution.checked,
    });
    setOutput(result);
  } catch (error) {
    setOutput('Error: ' + (error?.message ?? error));
  }
});

versionButton.addEventListener('click', async () => {
  try {
    const result = await InstallReferrer.getPluginVersion();
    setOutput(result);
  } catch (error) {
    setOutput('Error: ' + (error?.message ?? error));
  }
});
