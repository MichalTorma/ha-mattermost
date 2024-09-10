#!/usr/bin/with-contenv bashio

# Get configuration values
POSTGRES_HOST=$(bashio::config 'postgres_host')
POSTGRES_PORT=$(bashio::config 'postgres_port')
POSTGRES_DATABASE=$(bashio::config 'postgres_database')
POSTGRES_USER=$(bashio::config 'postgres_user')
POSTGRES_PASSWORD=$(bashio::config 'postgres_password')
DOMAIN=$(bashio::config 'domain')

# Set environment variables for Mattermost
export MM_SQLSETTINGS_DRIVERNAME=postgres
# Use connection string without password, relying on .pgpass file instead
export MM_SQLSETTINGS_DATASOURCE="postgres://${POSTGRES_USER}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DATABASE}?sslmode=disable&connect_timeout=10"
export MM_SERVICESETTINGS_SITEURL="https://${DOMAIN}"

# Create .pgpass file for secure password storage
echo "${POSTGRES_HOST}:${POSTGRES_PORT}:${POSTGRES_DATABASE}:${POSTGRES_USER}:${POSTGRES_PASSWORD}" > ~/.pgpass
chmod 600 ~/.pgpass

# Update config.json with the new settings
if ! jq '.SqlSettings.DriverName = "postgres" |
    .SqlSettings.DataSource = env.MM_SQLSETTINGS_DATASOURCE |
    .ServiceSettings.SiteURL = env.MM_SERVICESETTINGS_SITEURL' \
    /mattermost/config/config.json > /tmp/config.json; then
    echo "Error updating config.json"
    exit 1
fi

if ! mv /tmp/config.json /mattermost/config/config.json; then
    echo "Error moving updated config.json"
    exit 1
fi

# Start Mattermost
exec /entrypoint.sh mattermost
