//
//  globals.swift
//  FortuneWheel
//
//  Created by AS on 16/09/2023.
//

import Foundation
import SwiftUI

// class to hold global vars
class Globals {
    var radius: CGFloat
    var rotationAngle: Double
    var colors: [Color]
    var animationDuration: Double
    
    init() {
        self.radius = 150
        self.rotationAngle = Double.random(in: 320..<560)
        self.colors = [.red, .blue, .yellow, .green, .purple, .mint, .pink, .teal, .indigo, .orange]
        self.animationDuration = 2.5
        self.rotationAngle = self.rotationAngle * self.animationDuration
    }
}
