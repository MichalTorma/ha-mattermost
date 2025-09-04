#!/usr/bin/with-contenv bashio
# ==============================================================================
# Home Assistant Community Add-on: Mattermost
# This file checks if all user configuration requirements are met
# ==============================================================================

# Require database configuration
if ! bashio::config.has_value 'database_host'; then
    bashio::exit.nok "You need to configure a database host!"
fi

if ! bashio::config.has_value 'database_user'; then
    bashio::exit.nok "You need to configure a database user!"
fi

if ! bashio::config.has_value 'database_password'; then
    bashio::exit.nok "You need to configure a database password!"
fi

if ! bashio::config.has_value 'database_name'; then
    bashio::exit.nok "You need to configure a database name!"
fi

# Require site URL for proper operation
if ! bashio::config.has_value 'site_url'; then
    bashio::log.warning "Site URL is not configured. Mattermost may not work properly without it."
fi

bashio::log.info "Configuration check passed!"
