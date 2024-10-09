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

## Binary Installs
- Most TMS Server and Client binaries can be found on the [release](https://github.com/CJBuchel/TMS/releases) page.


### Docker Install
<!-- | Binary | Status |
|--|--|
| Docker Image | ![Azure DevOps builds (job)](https://img.shields.io/azure-devops/build/ConnorBuchel0890/e726ef53-95a3-4b7d-a618-830987485713/24/master?stage=Build&job=Docker) | -->

#### Steps

1. Install [Docker](https://docs.docker.com/engine/install/)
2. Pull the image
    1. Pull the image using the following command `docker pull cjbuchel/tms`, alternatively pull using `docker pull cjbuchel/tms:<version>` for a specific version.
3. Running the image in a container
    - For an AIO (all in one) container run `docker run -d -it --network host -p 8080:8080 -p 2121:2121 -p 2122:2122 -p 5353:5353 --name tms cjbuchel/tms`
    - Breaking down the command
      - The prior command runs the container in the background using the `-d` flag
      - The command also exposes the following ports `8080`, `2121`, `2122` & `5353`
        - `8080` is the Web Server port and is the port used when navigating to the web client. I.e `http://10.0.100.15:8080`. The port is not specialized and can be switched to another if desired. I.e `-p 8080:3000`
        - Ports `2121` & `2122` are for the server connections and shouldn't be changed, `2121` is for http and mainline data requests, and `2122` is for quick information bursts and pub sub updates (like the timer)
        - Port `5353`(Optional) is the port used for [mDNS](http://multicastdns.org/) broadcasting. mDNS provides a way for non web compiled clients to scan and connect to the server if they're on the same subnet. While it's not critical, it does provide a layer of simplified networking for devices such as iPads or mobile devices. Allowing users to connect without needing to enter the server address. Or in the event that the host ip changes, it provides an automated manner for the client to scan and reconnect using the new IP.
      - `--network host` forces the container to use the host machines network configuration, rather than relying on it's own. This is not critical and is only useful if mDNS is enabled and port `5353` is exposed. As the broadcaster needs to broadcast the server (host machine) ip, not the internal docker ip. View https://docs.docker.com/network/network-tutorial-host/ for more information
    - Optional environment parameters
      - The image offers options for configuring the container for different operating modes.
      - Pass in any of the following by appending the command i.e `docker run ... cjbuchel/tms --no-client`
        - `--no-client`
        - `--no-server`

## Quick Start
1. Once the server has been started navigate to the client (either through the hosted web address) or through the application
    - For example `localhost:8080`
2. Either wait for a network connection by monitoring the header messages (if on the web or using mDNS). 
    - Or navigate to the connection page in the top right corner and manually enter the ip. Afterwards go back to view selector screen
3. Once you have connected to the server and no header messages are displayed in the app bar. Login through the button in the top right.
    - On the first startup only one user will be active, `admin` with a password of `admin`.
4. After logging in go back to the view selector screen and click on `Setup`
5. Provide the generated CSV for your event or create a new one using a supported [FLL Schedule generator](https://firstaustralia.org/fll-scheduler/)
6. (Optional) Input an admin password, it's recommended but not essential. By default the password will stay as `admin`
7. (Optional) Input an event name
8. Click submit and go back to the view selector.
    - Note that the setup page is live, most of the options can be edited and submitted again during a running event with the exception of the CSV file which will overwrite the existing data.
9. Setup users by going to the `Dashboard` page and clicking on the arrow on the left. Then click `Users` in the drawer menu.
10. You can either create your own users by clicking on the `+` or generate a set of default users for the event by clicking the `Add Defaults` button.
    - By default all generated users will have the password of their username and should be changed to suite the event if needed.
11. Once complete the system should be ready for event use.

## Sound Notice
- Chrome added an update in 2021 which stopped the use of auto play sounds without manual input of some kind. View [Auto Play Policy C66](https://developer.chrome.com/blog/autoplay/) for more information.
- This causes sound to work briefly but when left alone may cut out as it can't be done without user input.
- To bypass this on a chromium browser you must whitelist the website and allow sound. Click the info icon/lock symbol left of the site url, and then navigate to site settings -> sound, and then change to allow.
- You should be able to reload and save. For every new ip address you will need to re-complete this action.
- TMS has sound on any view which has the timer clock
- Similar actions may need to be taken in safari and/or other untested browsers.

### Privacy Policy
- [Client Policy](https://github.com/CJBuchel/TMS/blob/master/tms-client/privacy_policy/067e7bb7-4ac3-4226-ad84-52c27dad78d0_en.md)