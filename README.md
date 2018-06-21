# My-Projects

PhotoLocation App
PhotoLocation app features about maintaining a list of locations around a particular region(Here we consider Sydney). It consists of three screens - Location lists, Map screen, Detail view of each location.

Default Locations : App has been loaded with default locations from the URL "http://bit.ly/test-locations".

Locations on List and Map : Users can view all these locations on the list view as well as on the Map view. Map button(Nav BarButton) on the right corner from locations screen will take you to the Map screen. There is a segment bar placed above this list with which user can sort the listed locations by distance or by Location name. Tapping on any location, user will be navigated to its Detail view. Detail view shows the name and editable notes(Notes are editable only for custom location)

View and Add Locations from Map Screen: 1. All listed locations can be viewed on Map screen which are added as annotation pins. 2. Users can also add their custom locations from the map screen on typing the desired location into the search bar. On typing the locations in the search bar, a list of matching locations will be displayed from which user can select the required location. Once selected user will be prompted to add name for the location. After typing the name and on clicking OK, a pin will be added for the location on the map. 3. These custom locations are persisted on device .

Detail screen of a location: 1. A detail view will be presented to the user when on tapping any location(pin) from map or on any of the locations from the list screen. 2. This screen has an option for the user to add Notes about their custom location. Notes can be added/edited only for user added(custom) locations. On tapping Save button(right navigation button)will save the edited notes, and Save button will be hidden for default locations. 3. This screen shows a MapView as well with its location coordinates pinned as Annotation.

Planning to extend this app to have save/edit default locations into CoreData, UI changes like differentiating custom and default location annotation pins in MapView, more information to the detail view, Code restructuring for more reusablity.

This app is built with Swift 4.0 Frameworks used : MapKit, UIKit, CoreData, CoreLocation
