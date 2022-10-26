//
//  MapOptionsViewController.swift
//  Example-Swift
//
//  Created by Nicholas Shipes on 10/24/22.
//

import UIKit

struct Layer {
    var code: String
    var title: String
}

protocol MapOptionsViewControllerDelegate: AnyObject {
    func mapOptionsViewControllerDidAddLayers(layers: [String])
    func mapOptionsViewControllerDidRemoveLayers(layers: [String])
}

class MapOptionsViewController: UIViewController {
    let tableView = UITableView(frame: .zero, style: .plain)
    var items: [Layer] = []
    var selectedIndexPaths: [IndexPath] = []
    var deselectedIndexPaths: [IndexPath] = []
    weak var delegate: MapOptionsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Layers"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(self.close))
        
        items = [
            Layer(code: "temperatures", title: "Temperatures"),
            Layer(code: "wind-speeds", title: "Wind Speeds"),
            Layer(code: "wind-particles", title: "Wind Particles"),
            Layer(code: "wind-dir", title: "Wind Direction"),
            Layer(code: "wind-barbs", title: "Wind Barbs"),
            Layer(code: "alerts", title: "Alerts"),
            Layer(code: "alerts-outline", title: "Alerts (Outline)"),
            Layer(code: "dew-points", title: "Dew Points"),
            Layer(code: "pressure-msl", title: "Surface Pressure"),
            Layer(code: "pressure-msl-contour", title: "Surface Pressure (Contour)")
        ]
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @objc func close() {
        let addedCodes = selectedIndexPaths.map { items[$0.row].code }
        let removedCodes = deselectedIndexPaths.map { items[$0.row].code }
        
        if addedCodes.count > 0 {
            delegate?.mapOptionsViewControllerDidAddLayers(layers: addedCodes)
        }
        
        if removedCodes.count > 0 {
            delegate?.mapOptionsViewControllerDidRemoveLayers(layers: removedCodes)
        }
        
        dismiss(animated: true)
    }
}

extension MapOptionsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        let item = items[indexPath.item]
        cell.textLabel?.text = item.title
        cell.accessoryType = selectedIndexPaths.contains(indexPath) ? .checkmark : .none
        return cell
    }
    
    
}

extension MapOptionsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        var selected = false
        
        if let index = selectedIndexPaths.firstIndex(of: indexPath) {
            selectedIndexPaths.remove(at: index)
            deselectedIndexPaths.append(indexPath)
        } else {
            selected = true
            selectedIndexPaths.append(indexPath)
            if let index = deselectedIndexPaths.firstIndex(of: indexPath) {
                deselectedIndexPaths.remove(at: index)
            }
        }
        
        cell?.accessoryType = selected ? .checkmark : .none
        tableView.deselectRow(at: indexPath, animated: true)
//        let item = items[indexPath.item]
    }
}
