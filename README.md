## MM-Remote 
![Build and Release apk](https://github.com/Klettner/MM-Remote/workflows/Build%20and%20Release%20apk/badge.svg?branch=master)  
[![GitHub release](https://img.shields.io/github/tag/Naereen/StrapDown.js.svg)](https://GitHub.com/Naeeen/StrapDown.js/release/)
  
MM-Remote is an Android app to control your **MagicMirror** via smartphone.  
  
![](assets/MMRemote.png)
  
### Features ###
  * Change the brightness  
  * Play, stop and skip image of a slideshow    
  * Send alerts to the mirror  
  * Shutdown and reboot the mirror  
  * Turn monitor on and off  
  * Switch between pages  
  * Create your own custom commands  
  
### Dependencies ###
  * MMM-BackgroundSlideshow
  * MMM-Pages and MMM-Navigation
  * MMM-Tools
  
It is also possible to use the App without all the dependencies, but this will limit its functionality.  
  
&nbsp;
## Set-up (easy) ##
Click [here](https://github.com/Klettner/MM-Remote/releases) and choose the latest release. There are three different .apk files available (the file which will install the app on your phone). Pick the .apk file which is compatible with your phone and download it. If you don't know which one to choose you can simply download all three .apk files and try the following steps which each of them.  
Once the file is downloaded to your phone, click on it to install. A warning will popup as this app was not downloaded from the app store. If you ignore the warning, the app will install and your done. If there is an error message, the .apk file is most likely not compatible with you phone and you need to try one of the other remaining .apk file.  
Once the app is installed you can delete the .apk files, these are not needed anymore.  
  
After starting the MM-Remote app, tab on the `+` on the bottom-right to add you MagicMirror. 
  - Give your mirror an arbitrary name. 
  - Add it's IP-address to the next field (e.g. something like 192.168.0.0). You can get the IP-address by typing `ipconfig` in the console of the raspberry pi. In the output after *inet addr:* you will find the ip-adress. 
  - Put the port in the last field (e.g. 8080) and click on create.

Now you should be able to remote controle your mirror. But keep in mind, if you don't use all the modules mentioned under dependencies, some of the buttons might not work (e.g. changing the displayed pages of your mirror via the left and right arrows on the bottom only works if you are using the MMM-Pages module). But you can always create you own commands in the **CUSTOM-COMMANDS** tab.  
   
&nbsp;
## Trouble shooting ##  
  - If you have performed the above steps but the mirror still does not respond, have a look at you *config.js* file. Usually at the beginning of the file there is  someting called the `ipWhitelist:`. Add the IP-address of your smartphone here to allow it sending commands to your mirror. If you don't know how to find out the IP-address of your smartphone a quick search with your favorite search engine will help.  
  - Check if the port you have specified in your *config.js* file is the same as in the app.  
    
&nbsp;
## Set-up (hard) ##
You can also clone the repository and compile the code by yourself instead of downloading the .apk files. It is written in **Dart** with the help of googles **Flutter** framework. If you have never used Flutter before, there is a good [documentation](https://flutter.dev/docs/get-started/install) available.

&nbsp;
## Final words ##  
This is the first app I have coded, therefore I would be happy about some feedback.  
If you have any ideas for improvments, bugs or feature requests feel free to write an issue.  
If you want to contribute yourself, you can of course make a pull request.
