//
//  SwiftUIFortuneWheelView.swift
//  SwiftUIFortuneWheel
//
//  Created by AS on 28/08/2023.
//

import SwiftUI
import Foundation

public struct SwiftUIFortuneWheelView: View {
    
    @ObservedObject var vm = SwiftUIFortuneWheelViewVM()
    @State var newOption: String = ""
    
    @State var saveCounter: Int = 0
    
    public var body: some View {
        VStack {
            HStack {
                TextField("Add option", text: $newOption)
                Button("Save") {
                    vm.save(newOption: newOption)
                    saveCounter += 1
                    newOption = ""
                }
            }
            .padding(20.0)
            
            /*
             The addition of .id() here was, for some reason necessary to get ArcWheelView to redraw. For some reason it was not correctly picking up changes to other @State vars in ContentViewVM.
             Some more detail on this issue on SO here: https://stackoverflow.com/questions/70917713/swiftui-view-does-not-update-when-state-variable-changes
             */
            ArcWheelView(options: vm.wheelOptions).id(saveCounter)
        }

    }
}

class SwiftUIFortuneWheelViewVM: ObservableObject {
    @Published var wheelOptions: [String] = ["Option 1", "Option 2"]
    
    func save(newOption: String) -> Void {
        //remove the placeholder option if this is currently the only option in the wheelOptions array
        if self.wheelOptions.count == 2 && self.wheelOptions[0] == "Option 1" && self.wheelOptions[1] == "Option 2" {
            self.wheelOptions = []
        }
        
        self.wheelOptions.append(newOption)
    }
    
}
