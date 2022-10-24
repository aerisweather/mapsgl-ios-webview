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
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
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
            titleLabel.leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor),
            titleLabel.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor),
            imageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0),
            imageView.leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor),
            imageView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 22)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class MapsGLLegendView: UIView {
    public var legends: [String: MapsGLLegendItem] = [:]
    public let stackView = UIStackView(frame: CGRect())
    
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
            legends[key] = nil
        }
    }
    
    public func updateLegends(data: [[String: Any]]) {
        for view in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(view)
        }
        
        if data.count > 0 {
            for item in data {
                guard let base64Str = item["data"] as? String,
                      let imageData = Data(base64Encoded: base64Str),
                      let image = UIImage(data: imageData),
                      let key = item["key"] as? String,
                      let label = item["label"] as? String else { return }
                
                addLegend(key: key, label: label, image: image)
            }
        }
    }
}
