# MM-Remote 
[![Build and Release apk](https://github.com/Klettner/MM-Remote/workflows/Build%20and%20Release%20apk/badge.svg)](https://GitHub.com/Klettner/MM-Remote/releases/)
[![GitHub release](https://img.shields.io/github/release/Klettner/MM-Remote)](https://GitHub.com/Klettner/MM-Remote/releases/)
[![GitHub license](https://img.shields.io/github/license/Klettner/MM-Remote)](https://github.com/Klettner/MM-Remote/blob/master/LICENSE)
![GitHub All Releases](https://img.shields.io/github/downloads/Klettner/MM-Remote/total)
  
MM-Remote is an Android 📱 and Windows 💻 app to control your [**MagicMirror**](https://magicmirror.builders/) remotely.  
  
![](assets/currentDeviceHomeTab.png)
  
## Features ##
  * Change the monitor brightness :high_brightness:    
  * Send alerts to the mirror  
  * Shutdown and reboot the mirror  
  * Turn the monitor on and off  
  * Play, stop and skip images :camera: of a photo-slideshow
  * Switch between UI-pages of the mirror
  * Create your own custom commands  
  * Start a timer on the mirror
  * Start a stop-watch :hourglass_flowing_sand: on the mirror

### v3.0.0 ###
  * Windows desktop :computer: support
  * Sync monitor brightness and status (on/of) with mirror
  * Switch between light and dark mode :first_quarter_moon_with_face:
  * Improved Stopwatch/Timer card
  * Improved settings page
  * Upgrade of Flutter and Android version
  
&nbsp;
## Dependencies ##
  
### Required :warning: (the app won't work without it): ###
| Module | Usage |
| ------ |------ |
| [MMM-Remote-Control](https://github.com/Jopyth/MMM-Remote-Control) (version 2.2.0 or higher)| Communication between app and mirror |
    
### Optional (without these, some default commands won't work): ###
If you do not use all the optional dependencies some default commands won't work, but such commands can be hidden in the settings.  

| Module | Usage |  
| ------ |------ |  
| [MMM-BackgroundSlideshow](https://github.com/darickc/MMM-BackgroundSlideshow) | Controlling a photo-slideshow on the mirror |  
| [MMM-Pages](https://github.com/edward-shen/MMM-pages) | Switching between different UI-pages |  
| [MMM-StopwatchTimer](https://github.com/klettner/MMM-StopwatchTimer) | Controlling a timer/stop-watch on the mirror |  
  
&nbsp;
## Installation guide ##
* For Android 📱 look [here](https://github.com/Klettner/MM-Remote/wiki/Installation-Android)
* For Windows 💻 look [here](https://github.com/Klettner/MM-Remote/wiki/Installation-Windows)

## Getting started ##
After starting the MM-Remote app, tab on the :heavy_plus_sign: on the bottom-right to add you MagicMirror. 
  - Give your mirror a name
  - Add it's IP-address to the next field (e.g. something like 192.168.0.0). You can get the IP-address by typing `hostname -I` in the console of the raspberry pi 
  - The last field requires the apiKey you have specified for the MMM-Remote-Control module in the config.js of your mirror (make sure it is correct, otherwise the app will not be able to communicate with the mirror)

**How to get your apiKey:**  
Open the config.js file and search for MMM-Remote-Control. It should look something like this:  
```
{
    module: 'MMM-Remote-Control'
    config: {
        apiKey: 'bc2e979db92f4741afad01d5d18eb8e2'
    }
},
```
If you can't find the attribute 'apiKey', add it to your config. You can choose the value of this attribute by yourself.
Don't make it to simple, think about it as a password for your mirror. This is the value you need to add in the apiKey 
field when creating a device in the MM-Remote app. You can find more information about the apiKey [here](https://github.com/Jopyth/MMM-Remote-Control/blob/master/API/README.md).

Now you should be able to remote control your mirror. If you want to reorder or hide some default commands displayed in
the **HOME** tab, go to settings and check :white_check_mark: the default command boxes in the order in which these commands 
should be displayed. Keep in mind, if you don't use all the modules mentioned under dependencies, some buttons might not
work (e.g. changing the displayed UI-pages of your mirror via the left and right arrows on the bottom only works if you 
are using the MMM-Pages module). You can always create you own commands in the **CUSTOM-COMMANDS** tab to extend the 
functionalities of the app. If there are any MagicMirror modules for which it is impractical to create your own **CUSTOM-COMMANDS** (e.g. because you need text input fields, a slider or many buttons) let me know, I might consider creating :wrench: a default command for it in future releases.  
   
&nbsp;
## :bulb: Trouble shooting :bulb: ##  
 * If something is not working properly, have a look at the [wiki](https://github.com/Klettner/MM-Remote/wiki/Trouble-shooting) first. 
 * If it still can't be resolved, create an issue.

&nbsp;
## Final words :tada: ##
This is the first app I have created, therefore I would be happy about some feedback.  
If you have any feature requests, bugs or ideas for improvements please create an issue. 
If you want to contribute yourself, feel free to make a pull request.
