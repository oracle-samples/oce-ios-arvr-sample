# About Augmented & Virtual Reality Sample

This repository holds the sample source code for an iOS app which displays 3D models in Augmented Reality, and Virtual 360° images managed in Oracle Content Management.  This is a companion app to a custom-built Oracle Content Management site.

Please see the complete [solution article](https://docs.oracle.com/en/solutions/develop-marketing-website).


## Installation

Source code may be obtained from Github:

```
git clone https://github.com/oracle-samples/oce-ios-arvr-sample
```

## Running the project

Open the project file, `ARDemo.xcodeproj`.

Select an appropriate iOS target and click the Run button.

### On-Device
When you run on-device, the application is intended to be used by scanning an on-screen QR code from an Oracle Content Management web page. The instance URL and content identifiers are passed along as part of QR code, so no additional configuration is necessary.

### Simulator
When you run on the simulator, the camera is unavailable so QR codes may not be scanned. However, you may click the gear icon in the top right to display two additional (simulator-only) buttons to preview a 3D mug and view a 360 degree panorama image. Just keep in mind that you must supply some parameters so that data may be retrieved from your Oracle Content Management instance.

Open the file `DemoParameters.swift` and provide values that correspond to your Oracle Content Management instance and published assets:

```json 
{
    "scheme": "https",
    "host": "oce.example.com",
    "channelToken": "",
    "mugAssetID": "",
    "mugDecalID": "",
    "panoramaAssetID": ""
}
```

- `scheme` - will always be "https"
- `host` - the host (and optional port) for your Content Management instace
- `channelToken` - the token associated with the location to which assets have been published
- `mugAssetID` - the identifier of structured content representing the coffee mug
- `mugDecalID` - the identifier of the image asset that will be applied to the mug 
- `panoramaAssetID`  - the identifier of the structured content representing the 360 degree panorama to display

## Contributing

This project welcomes contributions from the community. Before submitting a pull
request, please [review our contribution guide](./CONTRIBUTING.md).

## Security

Please consult the [security guide](./SECURITY.md) for our responsible security
vulnerability disclosure process.

## License

Copyright (c) 2023 Oracle and/or its affiliates and released under the
[Universal Permissive License (UPL)](https://oss.oracle.com/licenses/upl/), Version 1.0
