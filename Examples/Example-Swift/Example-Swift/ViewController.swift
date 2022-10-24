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

class MapToolbarView: UIView {
    let playButton = UIButton(type: .custom)
    let timeLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        layoutMargins = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        layer.cornerRadius = 4
        
        let iconConfiguration = UIImage.SymbolConfiguration(scale: .large)
        playButton.setImage(UIImage(systemName: "play.fill", withConfiguration: iconConfiguration), for: .normal)
        playButton.setImage(UIImage(systemName: "stop.fill", withConfiguration: iconConfiguration), for: .selected)
        playButton.tintColor = .white
        playButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(playButton)
        
        timeLabel.font = .preferredFont(forTextStyle: .callout)
        timeLabel.textColor = .white
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(timeLabel)
        
        NSLayoutConstraint.activate([
            playButton.leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor),
            playButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            timeLabel.leftAnchor.constraint(equalTo: playButton.rightAnchor, constant: 20),
            timeLabel.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor),
            timeLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ViewController: UIViewController {
    var mapView: MapsGLView!
    var legendView: MapsGLLegendView!
    let toolbarView = MapToolbarView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let account = MapsGLAccount(id: "wgE96YE3scTQLKjnqiMsv", secret: "2Hv7vYXBj0YAJED8xaiADX5X1szKbLFhd9waCEWT")
        let configuration = MapsGLConfiguration(account: account)
        
        mapView = MapsGLView(config: configuration, frame: view.bounds)
        mapView.delegate = self
        view.addSubview(mapView)
        
        legendView = MapsGLLegendView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 100.0))
        legendView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(legendView)
        
        toolbarView.playButton.addTarget(mapView, action: #selector(MapsGLView.toggle), for: .touchUpInside)
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
    }
}

extension ViewController: MapsGLViewDelegate {
    
    func mapsglViewDidLoad(mapView: MapsGLView) {
        print("loaded")
        
        mapView.getTimelineCurrentDate { [weak self] date in
            self?.toolbarView.timeLabel.text = date.formatted()
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
        mapView.addWeatherLayer("temperatures")
//        mapView.addWeatherLayer("wind-particles")
        mapView.getBounds()
        
//        mapView.setCenter(CLLocationCoordinate2D(latitude: 47.5, longitude: -121.5))
//        mapView.setZoom(0)
        
//        let delay = DispatchTime.now() + 3.0
//        DispatchQueue.main.asyncAfter(deadline: delay, execute: {
//            mapView.setZoom(0)
//            mapView.query(coordinate: CLLocationCoordinate2D(latitude: 47.5, longitude: -121.5)) { result in
//                print(result)
//            }
//        })
    }
    
    func mapsglViewDidReceiveClick(mapView: MapsGLView, coordinate: CLLocationCoordinate2D) {
        print("clicked: \(coordinate)")
        mapView.query(coordinate: coordinate) { result in
            print("query result: \(result)")
        }
    }
    
    func mapsglViewDidAddLayer(mapView: MapsGLView) {
        mapView.getLegend { [weak self] result in
            if result.count > 0 {
                for item in result {
                    guard let base64Str = item["data"] as? String,
                          let imageData = Data(base64Encoded: base64Str),
                          let image = UIImage(data: imageData),
                          let key = item["key"] as? String,
                          let label = item["label"] as? String else { return }
                    
                    self?.legendView.addLegend(key: key, label: label, image: image)
                }
            }
            
        }
    }
    
    func mapsglViewDidStartAnimating(mapView: MapsGLView) {
        toolbarView.playButton.isSelected = true
    }
    
    func mapsglViewDidStopAnimating(mapView: MapsGLView) {
        toolbarView.playButton.isSelected = false
    }
    
    func mapsglViewDidAdvanceAnimation(mapView: MapsGLView, progress: Float, date: Date) {
        toolbarView.timeLabel.text = date.formatted()
    }
    
//    func mapsglViewDidMove(mapView: MapsGLView) {
//        view.getCenter { center in
//            print("center: \(center)")
//        }
//        view.getZoom { zoom in
//            print("zoom: \(zoom)")
//        }
//    }
}

