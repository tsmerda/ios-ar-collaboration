# AR Collaboration iOS

## Author
Tomáš Šmerda

## Description
Discover a cutting-edge iOS app for collaborative augmented reality experiences. Share and manipulate scenes in real-time, leveraging ARKit, RealityKit, and MultipeerConnectivity. Experience the future of AR with seamless usability and potential for further development in the metaverse.

## Architecture
* MetaCollaboration project is implemented using the <strong>Model-View-ViewModel (MVC)</strong> architecture pattern.
* The app uses iOS 16 and SwiftUI 4.0

## Prerequisites
* iOS 16
* For proper functionality, you need to run the [AR Manuals Backend](https://git.pef.mendelu.cz/metaverse/ar-manuals-backend) locally and change the correct IP address in the NetworkManager file

```
private let baseURL = "http://192.168.1.13:8080/api/v3"
```
