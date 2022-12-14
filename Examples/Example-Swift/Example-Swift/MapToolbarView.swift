//
//  MapToolbarView.swift
//  Example-Swift
//
//  Created by Nicholas Shipes on 10/24/22.
//

import UIKit

class MapToolbarView: UIView {
    let playButton = UIButton(type: .custom)
    let layersButton = UIButton(type: .custom)
    let timeLabel = UILabel()
    let dateLabel = UILabel()
    let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    private let dateFormatter = DateFormatter()
    
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
        
        layersButton.setImage(UIImage(systemName: "square.3.layers.3d.top.filled", withConfiguration: iconConfiguration), for: .normal)
        layersButton.tintColor = .white
        layersButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(layersButton)
        
        activityIndicator.color = .white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activityIndicator)
        
        timeLabel.font = .preferredFont(forTextStyle: .callout)
        timeLabel.textColor = .white
        timeLabel.textAlignment = .right
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(timeLabel)
        
        dateLabel.font = .preferredFont(forTextStyle: .callout)
        dateLabel.textColor = .white
        dateLabel.textAlignment = .right
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            playButton.leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor),
            playButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            activityIndicator.leftAnchor.constraint(equalTo: playButton.rightAnchor, constant: 20),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            dateLabel.leftAnchor.constraint(equalTo: activityIndicator.rightAnchor, constant: 12),
            dateLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            dateLabel.widthAnchor.constraint(equalToConstant: 50),
            timeLabel.leftAnchor.constraint(equalTo: dateLabel.rightAnchor),
            timeLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            timeLabel.widthAnchor.constraint(equalToConstant: 80),
            layersButton.leftAnchor.constraint(equalTo: timeLabel.rightAnchor, constant: 20),
            layersButton.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor),
            layersButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        dateFormatter.dateFormat = "MM/dd"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(date: Date) {
        dateLabel.text = dateFormatter.string(from: date)
        timeLabel.text = date.formatted(date: .omitted, time: .shortened)
    }
}
