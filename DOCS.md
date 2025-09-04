# Home Assistant Add-on: Mattermost

Mattermost team communication platform for Home Assistant.

## Installation

Before installing this add-on, you need to set up a database. This add-on supports both PostgreSQL and MySQL databases.

### Database Setup

#### Option 1: PostgreSQL (Recommended)

1. Install the "PostgreSQL" add-on from the official add-on store
2. Configure the PostgreSQL add-on:
   ```yaml
   databases:
     - mattermost
   logins:
     - username: mattermost
       password: your_secure_password
   rights:
     - username: mattermost
       database: mattermost
   ```
3. Start the PostgreSQL add-on

#### Option 2: External Database

If you prefer to use an external database, ensure it's accessible from your Home Assistant instance and create a database and user for Mattermost.

### Add-on Installation

1. Navigate to **Settings** → **Add-ons** → **Add-on Store**
2. Add this repository URL to your add-on store
3. Find "Mattermost" and click **Install**

## Configuration

### Minimal Configuration

The minimal configuration requires database settings:

```yaml
database_type: postgres
database_host: core-postgres
database_port: 5432
database_name: mattermost
database_user: mattermost
database_password: your_secure_password
site_url: https://your-homeassistant-url.com:8065
```

### Full Configuration Example

```yaml
database_type: postgres
database_host: core-postgres
database_port: 5432
database_name: mattermost
database_user: mattermost
database_password: your_secure_password
site_url: https://mattermost.yourdomain.com
enable_email: true
smtp_server: smtp.gmail.com
smtp_port: 587
smtp_username: your-email@gmail.com
smtp_password: your-app-password
smtp_enable_security: true
admin_email: admin@yourdomain.com
team_name: My Home Team
log_level: INFO
```

## Configuration Options

### Database Settings

- **database_type**: Choose between `postgres` or `mysql`
- **database_host**: Database server hostname
- **database_port**: Database server port (5432 for PostgreSQL, 3306 for MySQL)
- **database_name**: Database name for Mattermost
- **database_user**: Database username
- **database_password**: Database password

### Site Settings

- **site_url**: The full URL where Mattermost will be accessible. This is crucial for proper operation of webhooks, email notifications, and mobile apps.

### Email Settings (Optional)

- **enable_email**: Enable email notifications
- **smtp_server**: SMTP server hostname
- **smtp_port**: SMTP server port (usually 587 for TLS or 465 for SSL)
- **smtp_username**: SMTP authentication username
- **smtp_password**: SMTP authentication password
- **smtp_enable_security**: Enable TLS/SSL for SMTP
- **admin_email**: Administrator email address

### General Settings

- **team_name**: Name of your team/organization
- **log_level**: Logging level (`DEBUG`, `INFO`, `WARN`, `ERROR`)

## First Run

After starting the add-on for the first time:

1. Open the Web UI at `http://your-ha-ip:8065`
2. Complete the initial setup wizard
3. Create your first admin user
4. Configure your first team

## Network Access

### Internal Access

The add-on runs on port 8065 and is accessible within your Home Assistant network.

### External Access

For external access, you have several options:

1. **Home Assistant's built-in proxy** (if supported)
2. **Reverse proxy** (Nginx Proxy Manager, Traefik, etc.)
3. **VPN access** to your home network

### Setting up Reverse Proxy

If using a reverse proxy, ensure you set the `site_url` configuration to match your external domain:

```yaml
site_url: https://mattermost.yourdomain.com
```

Example Nginx configuration:
```nginx
server {
    listen 80;
    server_name mattermost.yourdomain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name mattermost.yourdomain.com;

    ssl_certificate /path/to/your/certificate.crt;
    ssl_certificate_key /path/to/your/private.key;

    location / {
        proxy_pass http://your-ha-ip:8065;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## Data Persistence

Data is stored in the following locations:

- **Configuration**: `/mattermost/config/config.json`
- **File uploads**: `/mattermost/data/`
- **Logs**: `/mattermost/logs/`
- **Plugins**: `/mattermost/plugins/`

These directories are automatically created and managed by the add-on.

## Troubleshooting

### Common Issues

1. **Database Connection Failed**
   - Verify database credentials
   - Ensure database is running and accessible
   - Check if database and user exist

2. **Can't Access Web Interface**
   - Check if port 8065 is accessible
   - Verify firewall settings
   - Check add-on logs for errors

3. **Email Notifications Not Working**
   - Verify SMTP settings
   - Check if SMTP server allows connections from your IP
   - For Gmail, use app-specific passwords

### Viewing Logs

To view add-on logs:
1. Go to **Settings** → **Add-ons** → **Mattermost**
2. Click on the **Log** tab

For more detailed logs, set `log_level` to `DEBUG` in the configuration.

### Backup and Restore

Important data to backup:
- Database (handled by your database solution)
- Configuration files (included in Home Assistant snapshots)
- File uploads in `/mattermost/data/`

## Performance Tuning

For better performance:

1. **Database Optimization**:
   - Use PostgreSQL for better performance
   - Ensure database has adequate resources
   - Consider using connection pooling

2. **Resource Allocation**:
   - Ensure adequate RAM for your Home Assistant instance
   - Monitor CPU usage during peak times

3. **File Storage**:
   - Consider using external file storage for large teams
   - Regularly clean up old files if needed

## Security Considerations

1. **Use strong database passwords**
2. **Enable HTTPS for external access**
3. **Keep the add-on updated**
4. **Regularly backup your data**
5. **Use proper firewall rules**
6. **Consider enabling multi-factor authentication in Mattermost**

## Updates

The add-on will notify you when updates are available. Always backup your data before updating.

To update:
1. Go to **Settings** → **Add-ons** → **Mattermost**
2. Click **Update** when available
3. Restart the add-on after updating

## Support

For support:
- Check the [GitHub repository](https://github.com/MichalTorma/ha-mattermost) for issues and documentation
- Visit the [Home Assistant Community Forum](https://community.home-assistant.io)
- Join the [Home Assistant Discord](https://discord.gg/c5DvZ4e)
