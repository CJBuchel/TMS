<p align="center">
  <img src="https://raw.githubusercontent.com/CJBuchel/TMS/master/images/TMS_LOGO.png"/>
</p>

## Tournament Management System


- FLL management system for scoring, displaying and simplifying events. Built in Rust & Flutter, distributed in Docker, IOS, Android and Desktop applications

| Project Status | Pulls | Version | Size |
|--|--|--|--|
| [![Build Status](https://dev.azure.com/ConnorBuchel0890/ConnorBuchel/_apis/build/status%2FCJBuchel.TMS?branchName=master)](https://dev.azure.com/ConnorBuchel0890/ConnorBuchel/_build/latest?definitionId=24&branchName=master) | ![Docker Pulls](https://img.shields.io/docker/pulls/cjbuchel/tms) | ![Docker Image Version (latest by date)](https://img.shields.io/docker/v/cjbuchel/tms) | ![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/cjbuchel/tms) |

<p align="center">
  <img src="https://raw.githubusercontent.com/CJBuchel/TMS/master/images/prom1.png" width="400" style="margin-right: 10px"/>
  <img src="https://raw.githubusercontent.com/CJBuchel/TMS/master/images/prom3.png" width="400"/>
</p>


<p align="center">
  <img src="https://raw.githubusercontent.com/CJBuchel/TMS/master/images/prom2.png" width="400" height="550" style="margin-right: 10px"/>
  <img src="https://raw.githubusercontent.com/CJBuchel/TMS/master/images/prom4.png" width="400" height="550"/>
</p>

## Install
### Server Install
- Most TMS binaries can be found on the [release](https://github.com/CJBuchel/TMS/releases) page.
1. Download the required platform TMS build from the releases page, i.e `tms.zip` for windows.
2. Decompress this folder and place somewhere memorable.
3. Run the application inside the folder named `tms_server.exe`
    - There are some optional parameters you can run with the server to change it's configuration.
      - `--addr` modifies the address binding, e.g `--addr 0.0.0.0`, by default it's `0.0.0.0`
      - `--port` modifies which port TMS will run on, e.g `--addr 8080`, by default it's `8080`
      - `--no-tls` this switches the server from using `HTTPS` to the insecure `HTTP`, by default TLS is enabled for added security on public networks.
      - `--cert` this specifies the location of the certificate file used for TLS, e.g `--cert=cert.pem`
        - By default this will use `--cert=cert.pem`. If no cert is found at the location the server will generate it's own.
      - `--key` this specifies the location of the key file used for TLS, e.g `--key=key.rsa`
        - By default this will use `--key=key.rsa`. If no cert is found at the location the will will generate it's own
4. Familiarize yourself with the server directory.
    - `cert.pem` used for TLS as the public certificate handed out to clients for connecting
    - `key.rsa` used as the private for the server to decrypt messages sent from the clients
    - `log_config` this directory contains the runtime logs configurations, and what should and shouldn't be placed in the logs folder
    - `logs` this directory contains the logs for the server, and is split between `db.log`, `mdns.log` and `tms.log`. Where the DB logs containing the subscriptions to data, access and data entry modifications are placed. And TMS logs hold the general runtime logs for the server.
    - `tms.kvdb` this is the database of the server, and should `NEVER` be touched. The server by default (after setup in the ui) will create backups of this directory and place it inside the backups folder for safe keeping.
    - `backups` this directory contains the backups of the server in `.zip` format. From the UI you can restore backups/snapshots that are in this directory and create new backups. By default the server will create a backup every 10 minutes, and retain a total of 5 backups at a time.
      - Note, if you want to restore from a backup that is from a different event. Place the backup inside the `backups` folder. Then from the UI restore from that backup.
      - It's not recommended to directly remove the `tms.kvdb` directory and replace it with the backup you have on hand. But instead let the TMS server handle trying to parse, verify and replace the running config with the backup.
      - An upload backup button has not yet been added to the setup page as this is a fairly niche use case.
    - `tms_client` this directory contains the static website files that is hosted by the server.

### iOS Client
- The iOS client for iPads and similar devices can be found on the [App Store](https://apps.apple.com/au/app/tms_client/id6447258831), and can be used to connect to the server hosted on the same network.



### Docker Install
<!-- | Binary | Status |
|--|--|
| Docker Image | ![Azure DevOps builds (job)](https://img.shields.io/azure-devops/build/ConnorBuchel0890/e726ef53-95a3-4b7d-a618-830987485713/24/master?stage=Build&job=Docker) | -->

#### Steps

1. Install [Docker](https://docs.docker.com/engine/install/)
2. Pull the image
    1. Pull the image using the following command `docker pull cjbuchel/tms`, alternatively pull using `docker pull cjbuchel/tms:<version>` for a specific version.
3. Running the image in a container
    - Run `docker run -d -it -p 8080:8080 -p 5353:5353 --name tms cjbuchel/tms`
      - Or, for native network. Run `docker run -d -it --network host --name tms cjbuchel/tms`
    - Breaking down the command
      - The prior command runs the container in the background using the `-d` flag
      - The command also exposes the following ports `8080` & `5353`
        - `8080` is the primary network port, and is used for all endpoints, Web, HTTP, WS & DB control.
        - The ui is also located at this address under the `/ui` endpoint. `https://localhost:80880/ui`
        - Port `5353`(Optional) is the port used for [mDNS](http://multicastdns.org/) broadcasting. mDNS provides a way for non web compiled clients to scan and connect to the server if they're on the same subnet. While it's not critical, it does provide a layer of simplified networking for devices such as iPads or mobile devices. Allowing users to connect without needing to enter the server address. Or in the event that the host ip changes, it provides an automated manner for the client to scan and reconnect using the new IP.
      - `--network host` forces the container to use the host machines network configuration, rather than relying on it's own. This is not critical and is only useful if mDNS is enabled and port `5353` is exposed. As the broadcaster needs to broadcast the server (host machine) ip, not the internal docker ip. View https://docs.docker.com/network/network-tutorial-host/ for more information

## Quick Start
1. Once the server has been started navigate to the client (either through the hosted web address) or through the application
    - For example `https://localhost:8080`, or `http://localhost:8080` for non tls connections
2. Either wait for a network connection by monitoring the header messages (if on the web or using mDNS). 
    - Or navigate to the connection page in the top right corner and manually enter the ip. Afterwards go back to view selector screen
3. Once you have connected to the server and no header messages are displayed in the app bar. Login through the button in the top right.
    - On the first startup only one user will be active, `admin` with a password of `admin`.
4. After logging in go back to the view selector screen and click on `Setup`
5. Provide the generated CSV for your event or create a new one using a supported [FLL Schedule generator](https://firstaustralia.org/fll-scheduler/)
6. (Optional) Input an admin password, it's recommended but not essential. By default the password will stay as `admin`
7. (Optional) Input an event name
8. Click on the designated send buttons and go back to the view selector.
    - Note that the setup page is live, all of the options can be changed during the running of an event.
9. Setup users by going to the `Dashboard` page and clicking on the arrow on the left. Then click `Users` in the drawer menu.
10. You can either create your own users by clicking on the `+` or generate a set of default users for the event by clicking the `Add Defaults` button.
    - By default all generated users will have the password of their username (i.e, `head_referee` pass: `head_referee`) and should be changed to suite the event if needed.
11. Once complete the system should be ready for event use.

## Integrity Checks, Warning/Error codes
- TMS has an integrity system built in to catch common mistakes and problems that can be found during an event.
- Specifically that related to Teams, Judging Sessions and Game Matches.
- The integrity system runs as a service in the background, and does a pass over the database every `10 seconds`.
- During this time it iterates over the common data and checks for issues related to the prior mentioned. Such as, a score duplication, a team with less matches than others and more. See below for the full list of currently implemented Integrity Checks

#### Warnings
| Code | Description |
|--|--|
| W001 | Team name is missing. |
| W002 | Duplicate Team Name. |
| W003 | Team has a round 0 score. |
| W004 | No tables or teams found in match. |
| W005 | Match is complete but score not submitted. |
| W006 | Match is not complete but score submitted. |
| W007 | Blank table in match. |
| W008 | No team on table. |
| W009 | Team has judging session within 10 minutes of match. |
| W010 | No pods or teams found in sessions. |
| W011 | Session Complete, but no core values score submitted. |
| W012 | Session Complete, but no innovation score submitted. |
| W013 | Session Complete, but no robot design score submitted. |
| W014 | Session not Complete, but core values score submitted. |
| W015 | Session not Complete, but innovation score submitted. |
| W016 | Session not Complete, but robot design score submitted. |
| W017 | Blank pod in session. |
| W018 | No team in pod. |

#### Errors
| Code | Description |
|--|--|
| E001 | Team number is missing. |
| E002 | Duplicate Team Number. |
| E003 | Team has conflicting scores. |
| E004 | Table does not exist in event. |
| E005 | Team in match does not exist in this event. |
| E006 | Duplicate match number. |
| E007 | Team has fewer matches than the maximum number of rounds. |
| E008 | Pod does not exist in event. |
| E009 | Team in pod does not exist in this event. |
| E010 | Team has more than one judging session. |
| E011 | Team is not in any judging sessions. |
| E012 | Duplicate session number. |

- While the Integrity system finds most common issues, it doesn't find EVERYTHING, and therefore shouldn't be relied upon to determine if an Event to good to run or not.
- Above includes the checks that are currently implemented. But feel free to PR/Raise an issue for added checks.


## Sound Notice
- Chrome added an update in 2021 which stopped the use of auto play sounds without manual input of some kind. View [Auto Play Policy C66](https://developer.chrome.com/blog/autoplay/) for more information.
- This causes sound to work briefly but when left alone may cut out as it can't be done without user input.
- To bypass this on a chromium browser you must whitelist the website and allow sound. Click the info icon/lock symbol left of the site url, and then navigate to site settings -> sound, and then change to allow.
- You should be able to reload and save. For every new ip address you will need to re-complete this action.
- TMS has sound on any view which has the timer clock
- Similar actions may need to be taken in safari and/or other untested browsers.

### Privacy Policy
- [Client Policy](https://github.com/CJBuchel/TMS/blob/master/tms_client/privacy_policy/067e7bb7-4ac3-4226-ad84-52c27dad78d0_en.md)