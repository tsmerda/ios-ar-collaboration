# AR Collaboration iOS

## Author
Tomáš Šmerda

## Description
Discover a cutting-edge iOS app for collaborative augmented reality experiences. Share and manipulate scenes in real-time, leveraging ARKit, RealityKit, and MultipeerConnectivity. Experience the future of AR with seamless usability and potential for further development in the metaverse.

## Architecture
* MetaCollaboration project is implemented using the <strong>Model-View-ViewModel (MVVM)</strong> architecture pattern.
* The app uses iOS 16 and SwiftUI 4.0

## Prerequisites
* iOS 16
* For proper functionality, you need to run the [AR Manuals Backend](https://git.pef.mendelu.cz/metaverse/ar-manuals-backend) locally and change the correct IP address in the NetworkManager file

```
private let baseURL = "http://192.168.1.13:8080/api/v3"
```

## How to create a USDZ Model for a 3D Manual

### 1. Download the sample app from Apple's official documentation
Begin by downloading a sample app provided by Apple specifically for ARKit in iOS. This can be found at the following link: [Scanning and Detecting 3D Objects](https://developer.apple.com/documentation/arkit/arkit_in_ios/content_anchors/scanning_and_detecting_3d_objects).

### 2. Scan your desired 3D object using the sample app
Utilize the downloaded sample app to scan the 3D object you wish to include in your manual. Once the object is successfully scanned, export it as an .arobject file.

### 3. Use Reality Composer app on an iPad
With your .arobject file ready, open the Reality Composer app on an iPad. In the app, select the “Object” type and import your scanned .arobject. Reality Composer allows you to manipulate and annotate your 3D object in a more intuitive way.

### 4. Place 3D annotation models around the object
Place 3D annotation models around your object at locations that need explanations or highlights. This step involves adding interactive elements to your 3D object, enhancing the instructional value of your manual.

### 5. Delete the main .arobject and export as USDZ
After positioning all annotation models correctly, remove the main .arobject from your project. Then, export the entire project as a USDZ file.

> Exporting in USDZ format might require enabling USDZ export in the app's settings on your iPad.

### 6. Create one USDZ model per AR manual step
Each USDZ model exported from Reality Composer represents a single step in your AR manual.

### 7. Upload USDZ models and .arobject files to your backend
Finally, upload the USDZ models along with the .arobject file to your backend through Swagger UI.

### 8. Access your backend using MongoDB Compass
To finalize the setup, access your backend through MongoDB Compass. In MongoDB Compass, you'll need to correctly assign the name of the models to each step of your manual. This ensures that the right 3D model is associated with the appropriate instructional step.

> Make sure that each step in the manual has its own unique identifier to maintain order and consistency in the AR manual and to ensure that the iOS app works properly
