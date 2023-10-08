//
//  WinnerOverlayView.swift
//  FortuneWheel
//
//  Created by AS on 17/09/2023.
//

import SwiftUI

struct WinnerOverlayView: View {
    
    var winnerName: String
    
    @State var particles: [Particle] = []
    @State var coordinates: [CGPoint] = []
    
    @Binding var presentWinnerAlert: Bool
        
    var body: some View {
        VStack {
            GeometryReader { geo in
                VStack {
                    VStack {
                        Text("The winner is")
                        Text("\(winnerName.uppercased())")
                            .bold()
                            .font(.largeTitle)
                        Button("Spin again") {
                            presentWinnerAlert = false
                        }
                        .padding(20.0)
                    }
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
                    .onAppear {
                        // TODO: consider how we can remove the two refercnces to DispatchQueue.main.async
                        
                        // create and position particles
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.07) {
                            self.particles = generateRandomParticles(numOfParticles: 150, in: geo.frame(in: .local), positionInCentre: true)
                            
                            for item in self.particles {
                                self.coordinates.append(CGPoint(x: item.x, y: item.y))
                            }
                        }
                        
                        // move particles off screen
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {

                            withAnimation(.easeInOut(duration: 5.0)) {
                                let availableSpace = geo.frame(in: .global)
                                
                                /*
                                 For a particle to go offscreen:
                                 - its x-coord must be less than minX or greater than maxX
                                 AND
                                 - its y-coord must be less than minY or greater than maxY.
                                 
                                 The code below randomly selectes in which off-screen direction the particle will move.
                                 */
                                
                                
                                for i in 0..<self.particles.count {
                                    var xCoord: Double = 0.0
                                    var yCoord: Double = 0.0
                                    
                                    let randomDouble = Double.random(in: 0..<100)
                                    
                                    if Int.random(in: 0..<10) <= 5 {
                                        xCoord = (availableSpace.minX - 1000) * randomDouble
                                    } else {
                                        xCoord = (availableSpace.maxX + 1000) * randomDouble
                                    }
                                    
                                    if Int.random(in: 0..<10) <= 5 {
                                        yCoord = (availableSpace.minY - 1000) * randomDouble
                                    } else {
                                        yCoord = (availableSpace.maxY + 1000) * randomDouble
                                    }
                                    
                                    coordinates[i].x = xCoord
                                    coordinates[i].y = yCoord
                                }
                            }
                        }
                    }
                }

                
                ForEach(0..<self.particles.count, id: \.self) {
                    Rectangle()
                        .foregroundColor(particles[$0].color)
                        .frame(width: 10, height: 10)
                        .position(x: coordinates[$0].x, y: coordinates[$0].y)
                        .rotation3DEffect(.degrees(Double.random(in: 0..<90)), axis: (x: Double.random(in: 0..<1), y: Double.random(in: 0..<1), z: Double.random(in: 0..<1)))
                }

            }
        }
    }
    
    func generateRandomParticles(numOfParticles: Int, in availableSpace: CGRect, positionInCentre: Bool) -> [Particle] {
        
        var newParticles: [Particle] = []
        
        var xCoord: Double = 0.0
        var yCoord: Double = 0.0
        
        for _ in 0..<numOfParticles {
            let particleColor = Globals().colors.randomElement()!
            
            if positionInCentre {
                xCoord = (availableSpace.maxX - availableSpace.minX) / 2
                yCoord = (availableSpace.maxY - availableSpace.minY) / 2
            } else {
                xCoord = Double.random(in: availableSpace.minX..<availableSpace.maxX)
                yCoord = Double.random(in: availableSpace.minY..<availableSpace.maxY)
            }
            
            let newParticle = Particle(x: xCoord, y: yCoord, z: Double.random(in: 0..<360), opacity: Double.random(in: 0..<1), color: particleColor, xOffset: 0.0, yOffset: 0.0)
            newParticles.append(newParticle)
        }
        
        return newParticles
    }
}


// conform to Hashable so that we can use Particle in ForEach views
struct Particle: Hashable {
    var x: Double
    var y: Double
    var z: Double
    var opacity: Double
    var color: Color
    
    // for moving particles
    var xOffset: CGFloat
    var yOffset: CGFloat
}
