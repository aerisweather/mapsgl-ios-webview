//
//  File.swift
//  
//
//  Created by Nicholas Shipes on 10/24/22.
//

import Foundation
import CoreLocation

public struct MapsGLAccount {
    public let id: String
    public let secret: String
    
    public init(id: String, secret: String) {
        self.id = id
        self.secret = secret
    }
}

public struct MapsGLConfiguration {
    public let account: MapsGLAccount
    public var animation: MapsGLAnimationOptions
    public var centerCoordinate: CLLocationCoordinate2D
    public var zoomLevel: Float
    
    public init(account: MapsGLAccount) {
        self.account = account
        self.animation = MapsGLAnimationOptions()
        self.centerCoordinate = CLLocationCoordinate2D(latitude: 35.5, longitude: -93.5)
        self.zoomLevel = 2
    }
}
