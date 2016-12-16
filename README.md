<img src="https://github.com/jasperscholten/JasperScholten-pset6/blob/master/doc/parkeerIconRed-83.5%402x.png"></br>

##PARKEER. Find parking locations in Amsterdam with an iOS app

**PARKEER. enables you to find the perfect parking spot in Amsterdam, based upon advice from the ParkShark API. After registering an account, you can manually start your search by looking on the map (“In de buurt”) or you can generate an advice based on your current location (“Parkeeradvies”). The third option is to take a look at your saved favorite parking locations (“Favorieten”).**

When you choose to take the manual way, the app will show a map populated by pins representing nearby parking locations. Clicking on one of these pins, will show you the address of that specific location, as well as a button that enables you to directly find the fastest route to that location; the route will be shown in Apple Maps. Two additional buttons are present in the bar at the bottom of the screen. The first (“Centreer kaart”) will center the map on a default location. This location is on first launch set to the city centre, but can be adjusted by using the second bottom bar button (the blue arrow); selecting it will set your current location as the new center of the map. To navigate over the map, just drag and new pins will automatically be loaded.

If you don’t want to find a parking spot yourself, but rather be advised by the app, you should click on “Parkeeradvies”. In that case a table will pop up, showing a list of recommended parking locations judged from your current location. This advice is based on distance, but also on parking rate. If you would like to remember one of these locations, there is also the option to add it to your favorites (click “+ Favorieten”). This will add the location to a list that can be accessed by selecting “Favorieten” in the main menu.

> Curious of the app? You can start by taking a look at the screenshots below, but you could also download the complete project. Any questions? Send me an e-mail at j.o.scholten@student.vu.nl

***Code remarks***

PARKEER. uses the ParkShark API to get data about all current parking locations in Amsterdam (see http://api.parkshark.nl/jsonapi.html). This data is retrieved using HTTP-requests in both mapViewController and ParkingAdviceViewController. The functions are written in such a way, that data has to be retrieved continuously, making sure that the shown information is always based on the current location of the user (and thus up-to-date). A consequence is, that the app can state restore the viewController, but not the data that was shown (which, again, is a conscious design choice).
Moreover, the mapViewController contains two comparable, but still different functions for HTTP requests. However, they are deliberately not merged into a general function, because of their different asynchronous parts. This setup is essential to ensure that all data is retrieved, before the map will be populated with pins.
User defaults is used to save the center of the map, as set by the user. Firebase saves data about favorite parking locations, and it is also the foundation of the signing/logging in feature.

***Design remarks***

After several tests with different layouts of all views, different ways of using stack views (e.g. vertical in portrait, horizontal in landscape mode), and feedback from different people, the conclusion was drawn that it’s best to only use portrait mode and disable landscape mode. Landscape mode only makes the content of a view less clear most of the time, and it did not add any value to the app’s user experience. Therefore, only portrait mode is enabled.

***Screenshots***

<img src="https://github.com/jasperscholten/JasperScholten-pset6/blob/master/doc/1_AppIcon.PNG" width="250">
<img src="https://github.com/jasperscholten/JasperScholten-pset6/blob/master/doc/2_LoginScreen.PNG" width="250">
<img src="https://github.com/jasperscholten/JasperScholten-pset6/blob/master/doc/3_Registering.PNG" width="250"></br>
*From left to right: (1) App icon, (2) Login screen (3) Registering a new account.*</br></br>
<img src="https://github.com/jasperscholten/JasperScholten-pset6/blob/master/doc/4_MainMenu.PNG" width="250">
<img src="https://github.com/jasperscholten/JasperScholten-pset6/blob/master/doc/5_MapView.PNG" width="250">
<img src="https://github.com/jasperscholten/JasperScholten-pset6/blob/master/doc/7_NewDefaultCenter.PNG" width="250"></br>
*From left to right: (4) Main menu, (5) Mapview with one pin showing information (6) Setting a new default center.*</br></br>
<img src="https://github.com/jasperscholten/JasperScholten-pset6/blob/master/doc/8_LoadingAdvice.PNG" width="250">
<img src="https://github.com/jasperscholten/JasperScholten-pset6/blob/master/doc/9_AdviceTableView.PNG" width="250">
<img src="https://github.com/jasperscholten/JasperScholten-pset6/blob/master/doc/10_FavoritesTableView.PNG" width="250"></br>
*From left to right: (4) Loading advice, (5) Tableview of advice, based on current location (6) Tableview with favorite parking locations.*

*&copy; 2016 Jasper Scholten, 11157887*
