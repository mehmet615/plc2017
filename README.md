# MPFusionBase application updates
## Release 1.0.3.18
-- added native speakers<br>
-- added native general info<br>
<br><hr>
## Release 1.0.3.17
-- fixed attendees near me feature urls<br>
-- fixed the beacon RSSI issue<br>
<br><hr>
## Release 1.0.3.16
-- added the attendees near me support items<br>
<br><hr>
## Release 1.0.3.15
-- fixed AWS cookie issue<br>
<br><hr>
## Release 1.0.3.14
-- modified pass kit app identifier to be dynamically created<br>
-- added more error handling for logins<br>
-- hide side nav info when image present<br>
-- added theme options setting for hiding navigation divider<br>
-- fixed main menu header height<br>
-- moved belly height to constant setting<br>
<br><hr>
## Release 1.0.3.13
-- fixed missing libraries<br>
-- changed agenda default display type<br>
<br><hr>
## Release 1.0.3.12
-- removed submodules and added libraries<br>
-- updated mbprogressHUD<br>
<br><hr>
## Release 1.0.3.11
-- fixed cache clearing for WKWebView<br>
-- updated gitconfig to remove submodule pull<br>
<br><hr>
## Release 1.0.3.10
-- added SSO url<br>
<br><hr>
## Release 1.0.3.09
-- added default Wallet Pass creation<br>
-- updated default menu items<br>
-- fixed menu item loading on startup<br>
<br><hr>
## Release 1.0.3.08
-- fixed event defaults not loading<br>
-- added user creation endpoint to the login client<br>
-- added user deletion<br>
-- added new user creation method for updated /users API response<br>
<br><hr>
## Release 1.0.3.06
-- removed theme options plist and switched json with color descriptions<br>
-- added application defaults constants file<br>
-- fixed menu item color issue<br>
-- fixed belly bool issue<br>
-- added default sidenav stub in theme options<br>
-- added default settings for quick link cell border, clear search background and light search field text<br>
<br>
<hr>
## Release 1.0.3.05
-- added progress HUD for login auth request<br>
-- added separate section for login assets in theme options<br>
-- added options for search field quick setup against dark backgrounds<br>
-- updated theme option color fields<br>
-- added separate main menu background image field<br>
<br>
<hr>
## Release 1.0.3.04
-- extended login button<br>
-- added right nav profile updating on open<br>
-- changed document viewer to accept full paths<br>
<br>
<hr>
## Release 1.0.3.03
-- added nav bar tinting<br>
<br>
<hr>
## Release 1.0.3.02
-- switched beacon alerts to show session teaser text<br>
-- added push notification poll delivery<br>
<br>
<hr>
## Release 1.0.3.01
-- fixed fetchedUserID OneSignal updates<br>
-- changed all custom url schemes to accept full path URLs<br>
-- fixed gimbal API key constant<br>
-- fixed push notification crashes when launch from the background<br>
-- changed photo tagging behavior to be default<br>
-- fixed photo upload view constraint system<br>
-- updated meetingplay.com to mpeventapps.com<br>
<br>
<hr>
## Release 1.0.2.9
-- added profile uploads<br>
-- added updated OneSignal registration<br>
<br>
<hr>
## Release 1.0.2.8
-- added photo and video uploading options<br>
-- added fancy photo cropper<br>
-- added modular quick links coordinator<br>
<br>
<hr>
## Release 1.0.2.7
-- fixed main menu table view cell default selection style to show selected background<br>
-- added the pulse feed web view url<br>
<br>
<hr>
## Release 1.0.2.6
-- fixed OneSignal cold start crash<br>
-- fixed bug where app did not fetch user info to send to OneSignal<br>
<br>
<hr>
## Release 1.0.2.5
-- ensured attendeeTypeID gets set for OneSignal via API call to fet user info<br>
-- added a flag to the ThemeOptions.plist/json to enable fetchAllUsers in the data initializer<br>
-- added default white background to the photo uploads and filter view<br>
-- moved OneSignal signup to the login notification handler class instead of AppDelegate.m<br>