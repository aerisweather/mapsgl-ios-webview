//
//  MapsGLView.swift
//  MapsGLTest
//
//  Created by Nicholas Shipes on 10/22/22.
//

import UIKit
import WebKit
import CoreLocation
import WKWebViewJavascriptBridge

public enum MapViewError: Error {
    case invalidPath
}

@objc public protocol MapsGLViewDelegate: AnyObject {
    @objc optional func mapsglViewDidLoad(mapView: MapsGLView)
    @objc optional func onReady()
    @objc optional func mapsglViewDidZoom(mapView: MapsGLView)
    @objc optional func mapsglViewDidMove(mapView: MapsGLView)
    @objc optional func mapsglViewDidReceiveClick(mapView: MapsGLView, coordinate: CLLocationCoordinate2D)
    @objc optional func mapsglViewDidStartLoading(mapView: MapsGLView)
    @objc optional func mapsglViewDidCompleteLoading(mapView: MapsGLView)
    @objc optional func mapsglViewDidAddSource(mapView: MapsGLView)
    @objc optional func mapsglViewDidAddLayer(mapView: MapsGLView)
    @objc optional func mapsglViewDidRemoveSource(mapView: MapsGLView)
    @objc optional func mapsglViewDidRemoveLayer(mapView: MapsGLView)
    @objc optional func mapsglViewDidStartAnimating(mapView: MapsGLView)
    @objc optional func mapsglViewDidPauseAnimation(mapView: MapsGLView)
    @objc optional func mapsglViewDidResumeAnimation(mapView: MapsGLView)
    @objc optional func mapsglViewDidStopAnimating(mapView: MapsGLView)
    @objc optional func mapsglViewDidAdvanceAnimation(mapView: MapsGLView, progress: Double, date: Date)
}

public typealias MapsGLLayerOptions = [String: Any]

public struct CoordinateBounds {
    var northwest: CLLocationCoordinate2D
    var southeast: CLLocationCoordinate2D
}

public class MapsGLView: UIView {
    public var configuration: MapsGLConfiguration
    public let webView = WKWebView(frame: CGRect(), configuration: WKWebViewConfiguration())
    public weak var delegate: MapsGLViewDelegate?
    public var isAnimating = false
    
    private var bridge: WKWebViewJavascriptBridge!
    private let dateFormatter = DateFormatter()
    
    convenience public init(config: MapsGLConfiguration, frame: CGRect) {
        self.init(frame: frame)
        self.configuration = config
    }
    
    override public init(frame: CGRect) {
        self.configuration = MapsGLConfiguration(account: MapsGLAccount(id: "", secret: ""))
        super.init(frame: frame)
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        
        webView.frame = bounds
        webView.navigationDelegate = self
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        addSubview(webView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        webView.scrollView.addGestureRecognizer(tap)
        
        bridge = WKWebViewJavascriptBridge(webView: webView)
        bridge.register(handlerName: "log") { parameters, callback in
            guard let message = parameters?["message"] else { return }
            print("\(message) - \(parameters?["data"] ?? [:])")
        }
        
        loadMapView()
        setupEvents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Map
    
    public func getCenter(_ callback: @escaping (CLLocationCoordinate2D) -> Void) {
        bridge.call(handlerName: "getCenter") { (response) in
            if let data = response as? [String: Any], let lat = data["lat"] as? Double, let lon = data["lon"] as? Double {
                callback(CLLocationCoordinate2D(latitude: lat, longitude: lon))
            }
        }
    }
    
    public func setCenter(_ coordinate: CLLocationCoordinate2D) {
        let data = [
            "lat": coordinate.latitude,
            "lon": coordinate.longitude
        ]
        bridge.call(handlerName: "setCenter", data: data)
    }
    
    public func getZoom(_ callback: @escaping (Float) -> Void) {
        bridge.call(handlerName: "getZoom") { (response) in
            if let zoom = response as? Float {
                callback(zoom)
            }
        }
    }
    
    public func setZoom(_ zoom: Float) {
        bridge.call(handlerName: "setZoom", data: [ "zoom": zoom ])
    }
    
    public func getBounds(_ callback: @escaping (CoordinateBounds) -> Void) {
        bridge.call(handlerName: "getBounds") { (response) in
            if let data = response as? [String: Any],
               let north = data["north"] as? Double,
               let south = data["south"] as? Double,
               let west = data["west"] as? Double,
               let east = data["east"] as? Double
            {
                let nw = CLLocationCoordinate2D(latitude: north, longitude: west)
                let se = CLLocationCoordinate2D(latitude: south, longitude: east)
                callback(CoordinateBounds(northwest: nw, southeast: se))
            }
        }
    }
    
    public func getBearing(_ callback: @escaping (Float) -> Void) {
        bridge.call(handlerName: "getBearing") { (response) in
            if let bearing = response as? Float {
                callback(bearing)
            }
        }
    }
    
    public func getPitch(_ callback: @escaping (Float) -> Void) {
        bridge.call(handlerName: "getPitch") { (response) in
            if let pitch = response as? Float {
                callback(pitch)
            }
        }
    }
    
    public func getFov(_ callback: @escaping (Float) -> Void) {
        bridge.call(handlerName: "getFov") { (response) in
            if let fov = response as? Float {
                callback(fov)
            }
        }
    }
    
    public func getLegend(_ callback: @escaping ([AnyObject]) -> Void) {
        bridge.call(handlerName: "getLegend") { (response) in
            if let result = response as? [AnyObject] {
                callback(result)
            }
        }
    }
    
    // MARK: - Weather Layers
    
    public func hasWeatherLayer(_ layer: String, _ callback: @escaping (Bool) -> Void) {
        let data: [String : Any] = [
            "layer": layer
        ]
        bridge.call(handlerName: "hasWeatherLayer", data: data) { (response) in
            if let result = response as? Bool {
                callback(result)
            }
        }
    }
    
    public func addWeatherLayer(_ layer: String, options: MapsGLLayerOptions = [:]) {
        let data: [String : Any] = [
            "layer": layer,
            "options": options
        ]
        bridge.call(handlerName: "addWeatherLayer", data: data)
    }
    
    public func removeWeatherLayer(_ layer: String) {
        let data: [String : Any] = [
            "layer": layer
        ]
        bridge.call(handlerName: "removeWeatherLayer", data: data)
    }
    
    // MARK: - Querying Features
    
    public func query(coordinate: CLLocationCoordinate2D, _ callback: @escaping (Any?) -> Void) {
        let data = [
            "lat": coordinate.latitude,
            "lon": coordinate.longitude
        ]
        bridge.call(handlerName: "query", data: data) { (response) in
            callback(response)
        }
    }
    
    // MARK: - Timeline
    
    public func getTimelineStartDate(_ callback: @escaping (Date) -> Void) {
        bridge.call(handlerName: "timeline.startDate") { [weak self] (response) in
            guard let dateStr = response as? String else { return }
            if let date = self?.dateFormatter.date(from: dateStr) {
                callback(date)
            }
        }
    }
    
    public func getTimelineEndDate(_ callback: @escaping (Date) -> Void) {
        bridge.call(handlerName: "timeline.endDate") { [weak self] (response) in
            guard let dateStr = response as? String else { return }
            if let date = self?.dateFormatter.date(from: dateStr) {
                callback(date)
            }
        }
    }
    
    public func getTimelineCurrentDate(_ callback: @escaping (Date) -> Void) {
        bridge.call(handlerName: "timeline.currentDate") { [weak self] (response) in
            guard let dateStr = response as? String else { return }
            if let date = self?.dateFormatter.date(from: dateStr) {
                callback(date)
            }
        }
    }
    
    @objc public func toggle() {
        if isAnimating {
            stop()
        } else {
            play()
        }
    }
    
    @objc public func play() {
        isAnimating = true
        bridge.call(handlerName: "timeline.play", data: [:])
    }
    
    @objc public func pause() {
        bridge.call(handlerName: "timeline.pause", data: [:])
    }
    
    @objc public func resume() {
        bridge.call(handlerName: "timeline.resume", data: [:])
    }
    
    @objc public func stop() {
        isAnimating = false
        bridge.call(handlerName: "timeline.stop", data: [:])
    }
    
    @objc public func restart() {
        bridge.call(handlerName: "timeline.restart", data: [:])
    }
    
    // MARK: - Private

    private func loadMapView() {
        do {
            guard let htmlPath = Bundle.main.path(forResource: "mapview", ofType: "html") else {
                throw MapViewError.invalidPath
            }
            
            let html = try String(contentsOfFile: htmlPath, encoding: .utf8)
            let baseUrl = URL(fileURLWithPath: htmlPath)
            webView.loadHTMLString(html, baseURL: baseUrl)
        } catch MapViewError.invalidPath {
            print("Invalid map view path")
        } catch let error {
            print("WebView - load map view error: \(error)")
        }
    }
    
    private func configureMapView() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        
        let config = [
            "account": [
                "id": configuration.account.id,
                "secret": configuration.account.secret
            ],
            "animation": configuration.animation.toDictionary()
        ]
        bridge.call(handlerName: "configureMap", data: config)
    }
    
    private func setupEvents() {
        bridge.register(handlerName: "onLoad") { [weak self] parameters, callback in
            self?.configureMapView()
        }
        bridge.register(handlerName: "onReady") { [weak self] parameters, callback in
            guard let view = self else { return }
            self?.delegate?.mapsglViewDidLoad?(mapView: view)
        }
        bridge.register(handlerName: "onMapClick") { [weak self] parameters, callback in
            guard let view = self,
                  let coord = parameters?["coord"] as? [String: Any],
                  let lat = coord["lat"] as? Double,
                  let lon = coord["lon"] as? Double else { return }
            self?.delegate?.mapsglViewDidReceiveClick?(mapView: view, coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
        }
        bridge.register(handlerName: "onZoom") { [weak self] parameters, callback in
            guard let view = self else { return }
            self?.delegate?.mapsglViewDidZoom?(mapView: view)
        }
        bridge.register(handlerName: "onMove") { [weak self] parameters, callback in
            guard let view = self else { return }
            self?.delegate?.mapsglViewDidMove?(mapView: view)
        }
        bridge.register(handlerName: "onLoadStart") { [weak self] parameters, callback in
            guard let view = self else { return }
            self?.delegate?.mapsglViewDidStartLoading?(mapView: view)
        }
        bridge.register(handlerName: "onLoadComplete") { [weak self] parameters, callback in
            guard let view = self else { return }
            self?.delegate?.mapsglViewDidCompleteLoading?(mapView: view)
        }
        bridge.register(handlerName: "onAddSource") { [weak self] parameters, callback in
            guard let view = self else { return }
            self?.delegate?.mapsglViewDidAddSource?(mapView: view)
        }
        bridge.register(handlerName: "onAddLayer") { [weak self] parameters, callback in
            guard let view = self else { return }
            self?.delegate?.mapsglViewDidAddLayer?(mapView: view)
        }
        bridge.register(handlerName: "onRemoveSource") { [weak self] parameters, callback in
            guard let view = self else { return }
            self?.delegate?.mapsglViewDidRemoveSource?(mapView: view)
        }
        bridge.register(handlerName: "onRemoveLayer") { [weak self] parameters, callback in
            guard let view = self else { return }
            self?.delegate?.mapsglViewDidRemoveLayer?(mapView: view)
        }
        bridge.register(handlerName: "onAnimationStart") { [weak self] parameters, callback in
            guard let view = self else { return }
            self?.delegate?.mapsglViewDidStartAnimating?(mapView: view)
        }
        bridge.register(handlerName: "onAnimationPause") { [weak self] parameters, callback in
            guard let view = self else { return }
            self?.delegate?.mapsglViewDidPauseAnimation?(mapView: view)
        }
        bridge.register(handlerName: "onAnimationResume") { [weak self] parameters, callback in
            guard let view = self else { return }
            self?.delegate?.mapsglViewDidResumeAnimation?(mapView: view)
        }
        bridge.register(handlerName: "onAnimationStop") { [weak self] parameters, callback in
            guard let view = self else { return }
            self?.delegate?.mapsglViewDidStopAnimating?(mapView: view)
        }
        bridge.register(handlerName: "onAnimationAdvance") { [weak self] parameters, callback in
            guard let view = self else { return }
            if let position = parameters?["position"] as? Double, let dateStr = parameters?["date"] as? String {
                self?.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
                if let date = self?.dateFormatter.date(from: dateStr) {
                    self?.delegate?.mapsglViewDidAdvanceAnimation?(mapView: view, progress: position, date: date)
                }
            }
        }
    }
    
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        print("TAPPED")
        print(sender.location(in: webView))
    }
}

//extension ViewController: UIGestureRecognizerDelegate {
//
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }
//}

extension MapsGLView: WKNavigationDelegate {
    
}
