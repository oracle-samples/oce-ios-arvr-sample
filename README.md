# About Augmented & Virtual Reality Sample

This repository holds the sample source code for an iOS app which displays 3D models in Augmented Reality, and Virtual 360° images managed in Oracle Content Management.  This is a companion app to a custom-built Oracle Content Management site.

Please see the complete [solution article](https://docs.oracle.com/en/solutions/develop-marketing-website/set-cafe-supremo-marketing-website1.html).

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
When you run on the simulator, the application contains two additional buttons to preview a 3D mug and view a 360 degree panorama image. These buttons are useful because there is no camera available. However, since you cannot scan a QR code, you must supply some parameters so that data may be retrieved from your Oracle Content Management instance.

Open the file `DemoParameters.swift` and provide values that correspond to your Oracle Content Management instance and published assets:

```json 
{
    "scheme": "https",
    "host": "ocereferencegen2-oce0004.cec.ocp.oraclecloud.com",
    "channelToken": "b2f5a8a18bbc42bb949885fdaf1f43ee",
    "mugAssetID": "CORE8D5D8FD0FF8E4E34A4E4542C6D971650",
    "mugDecalID": "CONTAC2173A2CF7E4D058670FDA0AFAF666E",
    "panoramaAssetID": "CORE692BB127E7FD4AD98010AA6CEA5416B1"
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
