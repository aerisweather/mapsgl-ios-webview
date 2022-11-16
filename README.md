# mapsgl-ios-webview

MapsGLWebView for iOS allows developers to effortlessly integrate our [MapsGL](https://www.aerisweather.com/products/mapsgl/) product and features into their iOS applications. It renders a map and weather data using a WKWebView and interacts with our [MapsGL Javascript SDK](https://www.aerisweather.com/docs/mapsgl/) using a Javascript-to-native bridge, allowing your to use native Swift or ObjectiveC code to control your map and its weather content.

You'll first need access to our AerisWeather data and services. If you don't already have an account and active subscription, [sign up for an AerisWeather Developer account](https://www.aerisweather.com/signup/developer/). Upon signing up, a demo application with your client ID and secret keys will be generated which you can use for your account configuration below.

## Getting Started

Our MapsGLView can be installed using [Swift Package Manager (SPM)](https://www.swift.org/package-manager/) or by manually including it in your project. 

To use Swift Package Manager (SPM):

1. Open your Xcode project or workspace, then go to **File > Swift Packages > Add Package Dependency**.
2. Enter `https://github.com/aerisweather/mapsgl-ios-webview.git` as the URL, press **Enter** to pull in the package, and click **Add Package**.
3. Once everything is fetched, select the **MapsGLWebView** library and then press finish.
4. Copy the HTML file from `Sources/MapsGLWebView/HTML/mapview.html` into your own app bundle. This is the HTML file that is used for rendering your MapsGL map and weather layers using our [MapsGL Javascript SDK](https://www.aerisweather.com/docs/mapsgl/).
5. In your code, you can now `import MapsGLWebView` to start using the features from this package.

To include the package manually, drag the package's files under `Sources` into your project's them into your app target within Xcode, optionally copying them into your directory.

### Usage

Including a MapsGL view in your app requires you to first set up your account using `MapsGLAccount` and providing your keys:

```swift
let account = MapsGLAccount(id: "CLIENT_ID", secret: "CLIENT_SECRET")
```

You can then creating an instance of `MapsGLView`, instantiating it with an instance of `MapsGLConfiguration` that contains your account information and any other supported options as [documented by our MapsGL Javascript SDK](https://www.aerisweather.com/docs/mapsgl/reference/map-controller/#configuration):

```swift
let mapView = MapsGLView(config: configuration, frame: view.bounds)
view.addSubview(mapView)
```

### Getting Map Information

Getting information about the map, such as its current center coordinate, zoom level, whether it contains a particular weather layer, uses callbacks since communication between your native code and the underlying WKWebView happens asynchronously. 

For example, to get the underlying map's current center coordinate:

```swift
mapView.getCenter { center in
    print(center)
}
```

These methods also support async/await if you'd rather avoid callbacks:

```swift
let center = await mapView.getCenter()
```

### Events and MapsGLViewDelegate

Many of the applicable [events triggered](https://www.aerisweather.com/docs/mapsgl/reference/map-controller/#events) by the `MapController` instance of our MapsGL Javascript SDK are forwarded to your MapsGLView instance's delegate when assigned.

The following delegate methods are supported: 

```swift
func mapsglViewDidLoad(mapView: MapsGLView)
func mapsglViewDidZoom(mapView: MapsGLView)
func mapsglViewDidMove(mapView: MapsGLView)
func mapsglViewDidReceiveClick(mapView: MapsGLView, coordinate: CLLocationCoordinate2D)
func mapsglViewDidStartLoading(mapView: MapsGLView)
func mapsglViewDidCompleteLoading(mapView: MapsGLView)
func mapsglViewDidAddSource(mapView: MapsGLView)
func mapsglViewDidAddLayer(mapView: MapsGLView, layer: String)
func mapsglViewDidRemoveSource(mapView: MapsGLView)
func mapsglViewDidRemoveLayer(mapView: MapsGLView, layer: String)
func mapsglViewDidUpdateLayers(mapView: MapsGLView)
func mapsglViewDidStartAnimating(mapView: MapsGLView)
func mapsglViewDidPauseAnimation(mapView: MapsGLView)
func mapsglViewDidResumeAnimation(mapView: MapsGLView)
func mapsglViewDidStopAnimating(mapView: MapsGLView)
func mapsglViewDidAdvanceAnimation(mapView: MapsGLView, progress: Double, date: Date)
```

## Example App

Review the example apps for Swift and SwiftUI (coming soon) in the `Examples` directory of this repository for more in-depth examples of how to use many of the features provided by MapsGLWebView. These example projects demonstrate how to set up your MapsGLView instance, how to use MapsGLViewDelegate, include a legend view, and how to implement native controls for your MapsGLView.

Note that you will need to update the code in these example apps to provide your AerisWeather account keys in order for MapsGL functionality to work. You'll see lines like `MapsGLAccount(id: "CLIENT_ID", secret: "CLIENT_SECRET")` that you will need to update with your account access keys.

The example apps are also set up to use Mapbox for the base map in `mapview.html`. If you wish to use Mapbox, you'll need to update `mapview.html` with your Mapbox access token. Otherwise, you can use a different mapping library as described in the "Customization" section below.

## Customization

If you're looking for even more customization options beyond what's supported by this MapsGLWebView package, you can clone this repo and update the included `mapview.html` file with additional configurations and options supported by our core [MapsGL Javascript SDK](https://www.aerisweather.com/docs/mapsgl/). 

By default this package uses the Mapsbox JS GL SDK in `mapview.html`. However, if you'd rather use a different mapping library, you can change this in your app bundle's `mapview.html` by instantiating a different map instance and updating the map controller to one supported and provided by our MapsGL SDK. [Review our SDK documentation](https://www.aerisweather.com/docs/mapsgl/getting-started/) on how to configure its usage for different mapping libraries.

## Support

Feel free to post an issue in this Github repo for any bugs, technical issues or questions you may have related to this package. For sales information regarding our [MapsGL](https://www.aerisweather.com/products/mapsgl/) product and subscriptions, reach out to our [sales team](https://www.aerisweather.com/contact/sales/).