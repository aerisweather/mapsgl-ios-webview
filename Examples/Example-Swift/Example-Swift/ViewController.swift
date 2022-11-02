//
//  ViewController.swift
//  MapsGLTest
//
//  Created by Nicholas Shipes on 10/21/22.
//

import UIKit
import WebKit
import CoreLocation
import MapsGLWebView

class ViewController: UIViewController {
    var mapView: MapsGLView!
    var legendView: MapsGLLegendView!
    let toolbarView = MapToolbarView()
    private var optionsController: UINavigationController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let account = MapsGLAccount(id: "wgE96YE3scTQLKjnqiMsv", secret: "2Hv7vYXBj0YAJED8xaiADX5X1szKbLFhd9waCEWT")
        var configuration = MapsGLConfiguration(account: account)
        configuration.animation.pauseWhileLoading = true
        
        mapView = MapsGLView(config: configuration, frame: view.bounds)
        mapView.delegate = self
        view.addSubview(mapView)
        
        legendView = mapView.legendView
        legendView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(legendView)
        
        toolbarView.playButton.isEnabled = false
        toolbarView.playButton.addTarget(mapView, action: #selector(MapsGLView.toggle), for: .touchUpInside)
        toolbarView.layersButton.addTarget(self, action: #selector(ViewController.showOptions), for: .touchUpInside)
        toolbarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbarView)
        
        NSLayoutConstraint.activate([
            legendView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            legendView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            legendView.widthAnchor.constraint(equalToConstant: 300),
            toolbarView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toolbarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            toolbarView.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        let optionsController = MapOptionsViewController()
        optionsController.delegate = self
        
        let optionsNavigationController = UINavigationController(rootViewController: optionsController)
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            optionsNavigationController.navigationBar.standardAppearance = appearance
            optionsNavigationController.navigationBar.scrollEdgeAppearance = appearance
        }
        self.optionsController = optionsNavigationController
    }
    
    @objc func showOptions() {
        present(optionsController, animated: true)
    }
}

extension ViewController: MapOptionsViewControllerDelegate {
    
    func mapOptionsViewControllerDidAddLayers(layers: [String]) {
        for layer in layers {
            mapView.addWeatherLayer(layer)
        }
    }
    
    func mapOptionsViewControllerDidRemoveLayers(layers: [String]) {
        for layer in layers {
            mapView.removeWeatherLayer(layer)
        }
    }
}

extension ViewController: MapsGLViewDelegate {
    
    func mapsglViewDidLoad(mapView: MapsGLView) {
        print("loaded")
        
        mapView.getTimelineCurrentDate { [weak self] date in
            self?.toolbarView.update(date: date)
        }
        
//        mapView.addWeatherLayer("temperatures", options: [
//            "paint": [
//                "sample": [
//                    "colorscale": [
//                        "interval": 5
//                    ]
//                ]
//            ]
//        ])
//        mapView.addWeatherLayer("wind-dir")
//        mapView.addWeatherLayer("wind-particles")
        mapView.getBounds { bounds in
            print(bounds)
        }
        mapView.getCenter { center in
            print(center)
        }
        
        mapView.setCenter(CLLocationCoordinate2D(latitude: 47.5, longitude: -121.5))
        mapView.setZoom(2)
        
    }
    
    func mapsglViewDidReceiveClick(mapView: MapsGLView, coordinate: CLLocationCoordinate2D) {
        print("clicked: \(coordinate)")
        mapView.query(coordinate: coordinate) { result in
            print("query result: \(String(describing: result))")
        }
    }
    
    func mapsglViewDidUpdateLayers(mapView: MapsGLView) {
        print("layers updated: \(mapView.activeLayers)")
        toolbarView.playButton.isEnabled = mapView.activeLayers.count > 0
    }
    
    func mapsglViewDidUpdateLegends(mapView: MapsGLView) {
        print("legends updated")
        mapView.updateLegends()
    }
    
    func mapsglViewDidAddLayer(mapView: MapsGLView, layer: String) {
        print("added layer: \(layer)")
    }
    
    func mapsglViewDidRemoveLayer(mapView: MapsGLView, layer: String) {
        print("removed layer: \(layer)")
    }
    
    func mapsglViewDidStartLoading(mapView: MapsGLView) {
        toolbarView.activityIndicator.startAnimating()
    }
    
    func mapsglViewDidCompleteLoading(mapView: MapsGLView) {
        toolbarView.activityIndicator.stopAnimating()
    }
    
    func mapsglViewDidStartAnimating(mapView: MapsGLView) {
        toolbarView.playButton.isSelected = true
    }
    
    func mapsglViewDidStopAnimating(mapView: MapsGLView) {
        toolbarView.playButton.isSelected = false
    }
    
    func mapsglViewDidAdvanceAnimation(mapView: MapsGLView, progress: Double, date: Date) {
        toolbarView.update(date: date)
    }
}

