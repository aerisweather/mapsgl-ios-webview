//
//  File.swift
//  
//
//  Created by Nicholas Shipes on 10/24/22.
//

import Foundation

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
    
    public init(account: MapsGLAccount) {
        self.account = account
        self.animation = MapsGLAnimationOptions()
    }
}
