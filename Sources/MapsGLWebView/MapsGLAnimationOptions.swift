//
//  File.swift
//  
//
//  Created by Nicholas Shipes on 10/24/22.
//

import Foundation

public struct MapsGLAnimationOptions {
    public var start: Date
    public var end: Date
    public var duration: TimeInterval
    public var delay: TimeInterval
    public var endDelay: TimeInterval
    public var autoplay: Bool
    public var enableRepeat: Bool
    public var enabled: Bool
    
    private let dateFormatter = DateFormatter()
    
    public init() {
        self.start = Date().addingTimeInterval(-24 * 3600)
        self.end = Date()
        self.duration = 4.0
        self.delay = 0
        self.endDelay = 1.0
        self.autoplay = false
        self.enableRepeat = true
        self.enabled = true
    }
    
    public func toDictionary() -> [String: Any] {
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        
        return [
            "start": dateFormatter.string(from: start),
            "end": dateFormatter.string(from: end),
            "duration": duration,
            "delay": delay,
            "endDelay": endDelay,
            "repeat": enableRepeat,
            "enabled": enabled,
            "autoplay": autoplay
        ]
    }
}
