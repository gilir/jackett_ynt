# Jackett for YunoHost

[![Integration level](https://dash.yunohost.org/integration/jackett.svg)](https://dash.yunohost.org/appci/app/jackett)
[![Install Jackett with YunoHost](https://install-app.yunohost.org/install-with-yunohost.png)](https://install-app.yunohost.org/?app=jackett)

*[Lire ce readme en français.](./README_fr.md)*

> *This package allow you to install Jackett quickly and simply on a YunoHost server.
If you don't have YunoHost, please see [here](https://yunohost.org/#/install) to know how to install and enjoy it.*

## Overview
Jackett works as a proxy server: it translates queries from apps (Sonarr, Radarr, SickRage, CouchPotato, Mylar, Lidarr, DuckieTV, qBittorrent, Nefarious etc) into tracker-site-specific http queries, parses the html response, then sends results back to the requesting software. This allows for getting recent uploads (like RSS) and performing searches. Jackett is a single repository of maintained indexer scraping & translation logic - removing the burden from other apps.

**Shipped version:** 0.12.1115

## Configuration

You can configure Jackett directly in the admin panel.

## Documentation

 * Official documentation: https://github.com/Jackett/Jackett/wiki

## YunoHost specific features

#### Supported architectures

* x86-64b - [![Build Status](https://ci-apps.yunohost.org/ci/logs/jackett%20%28Apps%29.svg)](https://ci-apps.yunohost.org/ci/apps/jackett/)
* ARMv8-A - [![Build Status](https://ci-apps-arm.yunohost.org/ci/logs/jackett%20%28Apps%29.svg)](https://ci-apps-arm.yunohost.org/ci/apps/jackett/)

## Limitations

* Work only on port 9117.

## Links

 * Report a bug: https://github.com/YunoHost-Apps/jackett_ynh/issues
 * App website: https://github.com/Jackett/Jackett
 * Upstream app repository: https://github.com/Jackett/Jackett
 * YunoHost website: https://yunohost.org/

---

Developers info
----------------

**Only if you want to use a testing branch for coding, instead of merging directly into master.**
Please do your pull request to the [testing branch](https://github.com/YunoHost-Apps/jackett_ynh/tree/testing).

To try the testing branch, please proceed like that.
```
sudo yunohost app install https://github.com/YunoHost-Apps/jackett_ynh/tree/testing --debug
or
sudo yunohost app upgrade jackett -u https://github.com/YunoHost-Apps/jackett_ynh/tree/testing --debug
```
