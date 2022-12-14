//
//  MapsGLLegendView.swift
//  MapsGLTest
//
//  Created by Nicholas Shipes on 10/22/22.
//

import UIKit

public class MapsGLLegendItem: UIView {
    var key: String!
    let titleLabel = UILabel()
    let imageView = UIImageView()
    
    convenience init(key: String, label: String, image: UIImage) {
        self.init(frame: CGRect())
        
        self.key = key
        self.titleLabel.text = label
        self.imageView.image = image
        
        let height = image.size.height / UIScreen.main.scale
        
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: height)
        ])
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layoutMargins = UIEdgeInsets(top: 4, left: 2, bottom: 2, right: 2)
        
        titleLabel.font = .preferredFont(forTextStyle: .caption2)
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        let fontDescriptor = titleLabel.font.fontDescriptor
        let symTraits = fontDescriptor.symbolicTraits
        let descriptor = fontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits(arrayLiteral: symTraits, .traitBold))
        titleLabel.font = UIFont(descriptor: descriptor!, size: 0) //size 0 means keep the size as it is
        
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            titleLabel.leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor, constant: 4),
            titleLabel.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor),
            imageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0),
            imageView.leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor),
            imageView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class MapsGLLegendView: UIView {
    public var legends: [String: MapsGLLegendItem] = [:]
    public let stackView = UIStackView(frame: CGRect())
    private var updateTask: DispatchWorkItem?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.85)
        layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layer.cornerRadius = 4
        
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .leading
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            stackView.leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor),
            stackView.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor),
            stackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func addLegend(key: String, label: String, image: UIImage) {
        if legends[key] == nil {
            let legendItem = MapsGLLegendItem(key: key, label: label, image: image)
            stackView.addArrangedSubview(legendItem)
            legends[key] = legendItem
        }
    }
    
    public func removeLegend(key: String) {
        if let legendItem = legends[key] {
            stackView.removeArrangedSubview(legendItem)
            legendItem.removeFromSuperview()
            legends[key] = nil
        }
        
    }
    
    public func updateLegends(data: [[String: Any]]) {
        var keysToRemove: [String] = Array(legends.keys)
        
        if data.count > 0 {
            for item in data {
                guard let base64Str = item["data"] as? String,
                      let imageData = Data(base64Encoded: base64Str),
                      let image = UIImage(data: imageData),
                      let key = item["key"] as? String,
                      let label = item["label"] as? String else { return }
                
                let index = keysToRemove.firstIndex(of: key)
                
                // remove existing item if one exists for the key
                if let _ = index {
                    removeLegend(key: key)
                }
                
                addLegend(key: key, label: label, image: image)
                print("added legend: \(key)")
                
                if let index = index {
                    keysToRemove.remove(at: index)
                }
            }
        }
        print(keysToRemove)
        
        for key in keysToRemove {
            removeLegend(key: key)
        }
    }
}
