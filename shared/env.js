const path = require('path');
const dotenv = require('dotenv');

module.exports = async ({ options, resolveConfigurationProperty }) => {
  // Load env vars into Serverless environment
  // You can do more complicated env var resolution with dotenv here
  const local = dotenv.config({ path: '.env.runtime.local' }).parsed;
  const global = dotenv.config({ path: '.env.runtime' }).parsed;
  const services = dotenv.config({ path: path.join(__dirname, 'services.env') }).parsed;
  return Object.assign(
    {},
    local,
    global,
    services,
    process.env   // system environment variables
  );
};
