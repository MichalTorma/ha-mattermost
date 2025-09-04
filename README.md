# Home Assistant Add-on: Mattermost

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]
![Supports armhf Architecture][armhf-shield]
![Supports armv7 Architecture][armv7-shield]
![Supports i386 Architecture][i386-shield]
![Project Stage][project-stage-shield]
[![License][license-shield]](LICENSE.md)

![Project Maintenance][maintenance-shield]
[![GitHub Activity][commits-shield]][commits]

Mattermost team communication platform for Home Assistant.

## About

Mattermost is an open-source, self-hostable online chat service with file sharing, search, and integrations. It is designed as an internal chat for organizations and companies, and is marketed as an open-source alternative to Slack and Microsoft Teams.

This add-on provides a simple way to run Mattermost within your Home Assistant environment, allowing you to have secure team communication alongside your smart home automation.

## Installation

The installation of this add-on is straightforward:

1. Navigate in your Home Assistant frontend to **Settings** → **Add-ons** → **Add-on Store**.
2. Add this repository to your add-on store.
3. Find the "Mattermost" add-on and click it.
4. Click on the "INSTALL" button.

## How to use

To use this add-on, you need to:

1. Set up a PostgreSQL or MySQL database (the PostgreSQL add-on is recommended).
2. Configure the add-on with your database settings.
3. Set up your site URL for proper operation.
4. Start the add-on.

## Configuration

Add-on configuration:

```yaml
database_type: postgres
database_host: core-postgres
database_port: 5432
database_name: mattermost
database_user: mattermost
database_password: "your_password_here"
site_url: "https://your-domain.com"
enable_email: false
smtp_server: ""
smtp_port: 587
smtp_username: ""
smtp_password: ""
smtp_enable_security: true
admin_email: ""
team_name: "Home Assistant Team"
log_level: "INFO"
```

### Option: `database_type` (required)

The type of database to use. Currently supports `postgres` and `mysql`.

### Option: `database_host` (required)

The hostname of your database server. If using the PostgreSQL add-on, use `core-postgres`.

### Option: `database_port` (required)

The port number of your database server. Default is `5432` for PostgreSQL and `3306` for MySQL.

### Option: `database_name` (required)

The name of the database to use for Mattermost.

### Option: `database_user` (required)

The username to connect to the database.

### Option: `database_password` (required)

The password to connect to the database.

### Option: `site_url` (optional)

The URL where your Mattermost instance will be accessible. This is important for proper functionality, especially if you plan to use features like email notifications or webhooks.

### Option: `enable_email` (optional)

Enable email notifications. Default is `false`.

### Option: `smtp_server` (optional)

SMTP server for sending emails. Required if `enable_email` is `true`.

### Option: `smtp_port` (optional)

SMTP server port. Default is `587`.

### Option: `smtp_username` (optional)

Username for SMTP authentication.

### Option: `smtp_password` (optional)

Password for SMTP authentication.

### Option: `smtp_enable_security` (optional)

Enable TLS security for SMTP. Default is `true`.

### Option: `admin_email` (optional)

Email address for the system administrator.

### Option: `team_name` (optional)

Name of your team/organization. Default is "Home Assistant Team".

### Option: `log_level` (optional)

Set the log level. Options: `DEBUG`, `INFO`, `WARN`, `ERROR`. Default is `INFO`.

## Support

Got questions?

You have several options to get them answered:

- The [Home Assistant Discord Chat Server][discord].
- The Home Assistant [Community Forum][forum].
- Join the [Reddit subreddit][reddit] in [/r/homeassistant][reddit]

In case you've found a bug, please [open an issue on our GitHub][issue].

## Contributing

This is an active open-source project. We are always open to people who want to
use the code or contribute to it.

We have set up a separate document containing our
[contribution guidelines](CONTRIBUTING.md).

Thank you for being involved! :heart_eyes:

## Authors & contributors

The original setup of this repository is by [Michal Torma][torma].

For a full list of all authors and contributors,
check [the contributor's page][contributors].

## License

MIT License

Copyright (c) 2024 Michal Torma

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armhf-shield]: https://img.shields.io/badge/armhf-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[i386-shield]: https://img.shields.io/badge/i386-yes-green.svg
[commits-shield]: https://img.shields.io/github/commit-activity/y/MichalTorma/ha-mattermost.svg
[commits]: https://github.com/MichalTorma/ha-mattermost/commits/main
[contributors]: https://github.com/MichalTorma/ha-mattermost/graphs/contributors
[discord]: https://discord.gg/c5DvZ4e
[forum]: https://community.home-assistant.io
[torma]: https://github.com/MichalTorma
[issue]: https://github.com/MichalTorma/ha-mattermost/issues
[license-shield]: https://img.shields.io/github/license/MichalTorma/ha-mattermost.svg
[maintenance-shield]: https://img.shields.io/maintenance/yes/2024.svg
[project-stage-shield]: https://img.shields.io/badge/project%20stage-experimental-yellow.svg
[reddit]: https://reddit.com/r/homeassistant
[repository]: https://github.com/MichalTorma/ha-mattermost