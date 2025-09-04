#!/usr/bin/with-contenv bashio
# ==============================================================================
# Home Assistant Community Add-on: Mattermost
# Configures Mattermost based on user settings
# ==============================================================================

readonly CONFIG_FILE="/mattermost/config/config.json"
readonly TEMPLATE_FILE="/mattermost/server/config/config.json"

bashio::log.info "Configuring Mattermost..."

# Create config directory
mkdir -p /mattermost/config

# Copy default config if it doesn't exist
if [[ ! -f "${CONFIG_FILE}" ]]; then
    bashio::log.info "Creating initial Mattermost configuration..."
    cp "${TEMPLATE_FILE}" "${CONFIG_FILE}"
fi

# Read configuration values
DATABASE_TYPE=$(bashio::config 'database_type')
DATABASE_HOST=$(bashio::config 'database_host')
DATABASE_PORT=$(bashio::config 'database_port')
DATABASE_NAME=$(bashio::config 'database_name')
DATABASE_USER=$(bashio::config 'database_user')
DATABASE_PASSWORD=$(bashio::config 'database_password')
SITE_URL=$(bashio::config 'site_url')
ENABLE_EMAIL=$(bashio::config 'enable_email')
SMTP_SERVER=$(bashio::config 'smtp_server')
SMTP_PORT=$(bashio::config 'smtp_port')
SMTP_USERNAME=$(bashio::config 'smtp_username')
SMTP_PASSWORD=$(bashio::config 'smtp_password')
SMTP_ENABLE_SECURITY=$(bashio::config 'smtp_enable_security')
ADMIN_EMAIL=$(bashio::config 'admin_email')
TEAM_NAME=$(bashio::config 'team_name')
LOG_LEVEL=$(bashio::config 'log_level')

# Build database connection string
if [[ "${DATABASE_TYPE}" == "postgres" ]]; then
    DB_DRIVER_NAME="postgres"
    DB_DATA_SOURCE="postgres://${DATABASE_USER}:${DATABASE_PASSWORD}@${DATABASE_HOST}:${DATABASE_PORT}/${DATABASE_NAME}?sslmode=disable&connect_timeout=10"
elif [[ "${DATABASE_TYPE}" == "mysql" ]]; then
    DB_DRIVER_NAME="mysql"
    DB_DATA_SOURCE="${DATABASE_USER}:${DATABASE_PASSWORD}@tcp(${DATABASE_HOST}:${DATABASE_PORT})/${DATABASE_NAME}?charset=utf8mb4,utf8&readTimeout=30s&writeTimeout=30s"
fi

# Update configuration using jq
bashio::log.info "Updating Mattermost configuration file..."

# Database settings
jq --arg driver "${DB_DRIVER_NAME}" \
   --arg datasource "${DB_DATA_SOURCE}" \
   '.SqlSettings.DriverName = $driver | .SqlSettings.DataSource = $datasource' \
   "${CONFIG_FILE}" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "${CONFIG_FILE}"

# Service settings
if bashio::var.has_value "${SITE_URL}"; then
    jq --arg siteurl "${SITE_URL}" \
       '.ServiceSettings.SiteURL = $siteurl' \
       "${CONFIG_FILE}" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "${CONFIG_FILE}"
fi

# Email settings
jq --argjson enable "${ENABLE_EMAIL}" \
   '.EmailSettings.EnableEmailBatching = $enable | .EmailSettings.SendEmailNotifications = $enable' \
   "${CONFIG_FILE}" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "${CONFIG_FILE}"

if bashio::var.true "${ENABLE_EMAIL}"; then
    jq --arg server "${SMTP_SERVER}" \
       --arg port "${SMTP_PORT}" \
       --arg username "${SMTP_USERNAME}" \
       --arg password "${SMTP_PASSWORD}" \
       --argjson security "${SMTP_ENABLE_SECURITY}" \
       '.EmailSettings.SMTPServer = $server | 
        .EmailSettings.SMTPPort = $port | 
        .EmailSettings.SMTPUsername = $username | 
        .EmailSettings.SMTPPassword = $password |
        .EmailSettings.ConnectionSecurity = (if $security then "TLS" else "" end)' \
       "${CONFIG_FILE}" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "${CONFIG_FILE}"
fi

# Team settings
if bashio::var.has_value "${TEAM_NAME}"; then
    jq --arg teamname "${TEAM_NAME}" \
       '.TeamSettings.SiteName = $teamname' \
       "${CONFIG_FILE}" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "${CONFIG_FILE}"
fi

# Log settings
jq --arg loglevel "${LOG_LEVEL}" \
   '.LogSettings.ConsoleLevel = $loglevel | .LogSettings.FileLevel = $loglevel' \
   "${CONFIG_FILE}" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "${CONFIG_FILE}"

# File settings for Home Assistant
jq '.FileSettings.Directory = "/mattermost/data" | 
    .FileSettings.EnableFileAttachments = true | 
    .FileSettings.MaxFileSize = 52428800' \
   "${CONFIG_FILE}" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "${CONFIG_FILE}"

# Plugin settings
jq '.PluginSettings.Directory = "/mattermost/plugins" | 
    .PluginSettings.ClientDirectory = "/mattermost/client/plugins"' \
   "${CONFIG_FILE}" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "${CONFIG_FILE}"

# Ensure proper permissions
chown mattermost:mattermost "${CONFIG_FILE}"

bashio::log.info "Mattermost configuration completed!"
