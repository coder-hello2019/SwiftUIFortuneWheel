//
//  MarkerView.swift
//  FortuneWheel
//
//  Created by AS on 10/09/2023.
//

import SwiftUI

struct MarkerView: View {
    var body: some View {
        Image(systemName: "triangle.fill")
            .font(.largeTitle)
            .foregroundColor(Color(red: 2/255, green: 7/255, blue: 93/255))
            .rotationEffect(Angle(degrees: 180.0))
        
    }
    
    func marketHeight(text: String) -> CGFloat {
        // NB SPM requires that NSFont rather than UIFont is used becase MacOS required
        let textWidth = text.size(withAttributes: [.font: UIFont.systemFont(ofSize: 11)]).width
        print("textWidth for \(text): \(textWidth)")
        return textWidth
        
        print("textWidth for \(text): \(textWidth)")
        return textWidth
    }
}

