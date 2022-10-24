//
//  MapToolbarView.swift
//  Example-Swift
//
//  Created by Nicholas Shipes on 10/24/22.
//

import UIKit

class MapToolbarView: UIView {
    let playButton = UIButton(type: .custom)
    let timeLabel = UILabel()
    let activityIndicator = UIActivityIndicatorView(style: .medium)
    
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
        
        activityIndicator.color = .white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activityIndicator)
        
        timeLabel.font = .preferredFont(forTextStyle: .callout)
        timeLabel.textColor = .white
        timeLabel.textAlignment = .right
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(timeLabel)
        
        NSLayoutConstraint.activate([
            playButton.leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor),
            playButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            activityIndicator.leftAnchor.constraint(equalTo: playButton.rightAnchor, constant: 20),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            timeLabel.leftAnchor.constraint(equalTo: activityIndicator.rightAnchor, constant: 12),
            timeLabel.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor),
            timeLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            timeLabel.widthAnchor.constraint(equalToConstant: 165)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
