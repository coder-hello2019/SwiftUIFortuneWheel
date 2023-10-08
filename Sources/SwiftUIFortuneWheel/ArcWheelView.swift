//
//  TestWheelView.swift
//  FortuneWheel
//
//  Created by AS on 28/08/2023.
//

import Foundation
import SwiftUI

// struct to store the path object for each segment as well as its parameters relevant to end-of-spin determinations
struct CustomPath {
    var path: Path
    var startAngleDouble: Double
    var endAngleDouble: Double
    let pathStart: CGPoint = CGPoint(x: 196.5, y: 196.5)
    var sliceRange: Double = 120.0
    var indexFloat: Double
    let globals = Globals()
    
    // consider deleting - probably not needed as we always create CustomPaths in the View and then save them
    mutating func addPath() -> Void {
        var path = Path()
        path.move(to: pathStart)
        path.addArc(center: pathStart, radius: globals.radius, startAngle: .degrees(indexFloat * sliceRange), endAngle: .degrees((indexFloat + 1) * sliceRange), clockwise: false)
        self.path = path
    }
    
    // update the path for a rotation by the specified number of degrees
    // if the specified point is touching the marker,return true - that segment is the winner
    mutating func modifyPath(by degrees: Double) -> Bool {
        self.startAngleDouble += degrees
        self.endAngleDouble += degrees

        var newPath = Path()
        newPath.move(to: pathStart)
        newPath.addArc(center: pathStart, radius: globals.radius, startAngle: .degrees(self.startAngleDouble), endAngle: .degrees(self.endAngleDouble), clockwise: false)
        self.path = newPath
        
        // check if updated path intersects the wheel marker
        if self.path.contains(CGPoint(x: pathStart.x, y: pathStart.y - (globals.radius - 1.0))) {
            print("The winner is option #\(indexFloat)")
            return true
        }
        return false
    }
}

struct ArcWheelView: View {
    
    var globals = Globals()
    
    // MARK: vars related to spin animation and winner popup activation
    @State var rotationAngle = 0.0
    
    @State var workItem: DispatchWorkItem?
    
    @State var options: [String]
        
    // array to keep track of paths corresponding to each option in the 'options' array
    @State var optionPaths: [CustomPath] = []
    
    // index denoting the winning option
    @State var winnerIndex: Int? = nil
    // display alert if winner found
    @State var presentWinnerAlert: Bool = false
        
    var body: some View {
        
        VStack {
            Text("Swipe the wheel to spin \(Image(systemName: "hand.draw.fill"))")
                .font(.largeTitle)
                .padding(10.0)
            
            GeometryReader { geo in
                VStack {
                    ZStack {
                        MarkerView()
                            .position(CGPoint(x: startPoint(geo: geo).x, y: startPoint(geo: geo).y - 149))
                            .zIndex(1.0)
                        Circle()
                            .fill(.gray.opacity(0.5))
                            .frame(width: globals.radius * 2 + 40.0, height: globals.radius * 2 + 40.0)
                            .position(self.startPoint(geo: geo))
                            .zIndex(0)
                        ForEach(options.indices, id: \.self) {index in
                            let indexFloat = CGFloat(index)
//                            var _ = print("index: \(index) || startAngle: \(indexFloat * sliceRange) || endAngle: \((indexFloat + 1) * sliceRange) || color: \(globals.colors[index % globals.colors.count]) || name: \(options[index])")
                            ZStack {
                                Path { path in
                                    path.move(to: self.startPoint(geo: geo))
                                    path.addArc(center: self.startPoint(geo: geo), radius: globals.radius, startAngle: .degrees(indexFloat * sliceRange), endAngle: .degrees((indexFloat + 1) * sliceRange), clockwise: false)
                                 }
                                .fill(globals.colors[index % globals.colors.count])
                                .onAppear {
                                    createCustomPaths(geo: geo)
                                }
                                
                                label(text: options[index], index: CGFloat(index), offset: geo.size.width / 4, availableWidth: geo.size.width)

                            }
                            .rotationEffect(Angle(degrees: rotationAngle))
                        }
                        
                        // TODO: delete - this is just to help with creating the circle visually
                        Circle()
                            .frame(width: 30, height: 30)
                            .foregroundColor(Color(red: 2/255, green: 7/255, blue: 93/255))
                            .position(startPoint(geo: geo))
                    } // end ZStack here
                    .frame(width: geo.size.width, height: geo.size.width)
                    .onChange(of: winnerIndex) { _ in
                        print("winnerIndex: \(winnerIndex)")
                        print("options[winnerIndex]: \(options[winnerIndex!])")
                    }
                    
                } // end inner VStack here
            } // end GeoReader here
            .gesture(
                DragGesture()
                    .onEnded {_ in
                        withAnimation(.linear(duration: globals.animationDuration)) {
                            rotationAngle += globals.rotationAngle
                        }
                        updateCustomPaths()
                        
                        /*
                         If we previously created a workItem which activates the winner pop-up, we need to cancel it so that it can be replaced with a new workItem (either for a completely fresh spin, or if a user has pulled the wheel multiple times during the same spin turn).
                         */
                        if let existingWorkItem = self.workItem {
                            self.workItem?.cancel()
                        }
                        
                        // check for winner after the animation has finished
                        self.workItem = DispatchWorkItem {
                            if self.winnerIndex != nil {
                                presentWinnerAlert = true
                            }
                        }
                        
                        // we can force unwrap the workItem here because we create it in the immediately-preceding lines
                        DispatchQueue.main.asyncAfter(deadline: .now() + globals.animationDuration + 0.1, execute: self.workItem!)
                        
                    }
            )
        }
        .sheet(isPresented: $presentWinnerAlert) {
            WinnerOverlayView(winnerName: options[winnerIndex!], presentWinnerAlert: $presentWinnerAlert)
        }
    }
    
    // this function creates repition vis-a-vis the ForEach view but it's probably the safest way of saving the paths
    func createCustomPaths(geo: GeometryProxy) -> Void {
        // we need this safeguard because for some reason the view re-draws twice so the .onAppear (and therefore this func) are called twice
        if optionPaths.count == options.count {
            return
        }
        
        // make sure that we're not appending new paths to an already-existing array of custom paths
        self.optionPaths = []
        
        for (index, _) in options.enumerated() {
            let indexFloat = CGFloat(index)
            
            var pathToAppend = Path()
            pathToAppend.move(to: self.startPoint(geo: geo))
            pathToAppend.addArc(center: self.startPoint(geo: geo), radius: globals.radius, startAngle: .degrees(indexFloat * sliceRange), endAngle: .degrees((indexFloat + 1) * sliceRange), clockwise: false)
            
            optionPaths.append(CustomPath(path: pathToAppend, startAngleDouble: indexFloat * sliceRange, endAngleDouble: (indexFloat + 1) * sliceRange, indexFloat: indexFloat))
        }
    }
    
    func updateCustomPaths() -> Void {
        print("updateCustomPaths called")
        print("optionPaths: \(optionPaths)")
        for index in 0..<optionPaths.count {
            print("Trying to modify index \(index)")

            if optionPaths[index].modifyPath(by: globals.rotationAngle) == true {
                self.winnerIndex = index
                print("Assigned index to winnerIndex")
            }
            print("\(options[index]) - new startAngle: \(optionPaths[index].startAngleDouble), new endAngle: \(optionPaths[index].endAngleDouble)")
        }
    }

    func startPoint(geo: GeometryProxy) -> CGPoint {
        CGPoint(x: geo.size.width / 2, y: geo.size.width / 2)
    }
    
    func rotationAmount(index: CGFloat) -> Double {
        
        let rotationAmount: Double = (sliceRange / 2) + (index * sliceRange)
        print("rotationAmount: \(rotationAmount)")
        return rotationAmount
    }
    
    func xyOffset(index: CGFloat) -> CGSize {
        let text = options[Int(index)]
        let textWidth = textWidth(text: text)
        
        let radius: Double = globals.radius
        
        let rotationAmount = rotationAmount(index: index)
        
        let sinAmount = sin(degrees: rotationAmount)
        let cosAmount = cos(degrees: rotationAmount)
        print("cosAmount: \(cosAmount), sinAmount: \(sinAmount)")
        
        // need to incl. floor because function returns non-zero amount due to known rounding errors in Swift
        let xOffset = (textWidth - radius) * cosAmount
        let yOffset = (textWidth - radius) * sinAmount
        
        // using the negative values here as Swift counts the direction of the circle in the opposite direction to the unit circle
        return CGSize(width: -xOffset, height: -yOffset)
    }
    
    func sin(degrees: Double) -> Double {
        return __sinpi(degrees/180.0)
    }
    
    func cos(degrees: Double) -> Double {
        return __cospi(degrees/180.0)
    }
    
    func label(text: String, index: CGFloat, offset: CGFloat, availableWidth: CGFloat) -> some View {
        var _ = print("xyOffset: \(xyOffset(index: index))")
                
        return Text("\(text)")
            .font(.subheadline)
            .bold()
            .foregroundColor(.white)
            .rotationEffect(Angle(degrees: rotationAmount(index: index)), anchor: .center)
            .offset(xyOffset(index: index))
            .padding(50.0)

    }
    
    /*
    The range of degrees covered by a single slice of the wheel. This has to be a ceiling because otherwise - due to floating point imprecision - we might end up with gaps in the wheel e.g 7 options times range of 51.0 is equal to 357.0 rather than 360, unless we use a ceiling.
     */
    var sliceRange: Double {
        ceil(360.0 / Double(options.count))
    }
    
    func textWidth(text: String) -> CGFloat {
        // NB UIFont changed to NSFont here as SPM requires MacOS
        let textWidth = text.size(withAttributes: [.font: UIFont.systemFont(ofSize: 11)]).width
        print("textWidth for \(text): \(textWidth)")
        return textWidth
    }

}
