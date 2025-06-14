//
//  ContentView.swift
//  Ball
//
//  Created by Alex Feies on 6/13/25.
//

import SwiftUI
import SpriteKit

class GameScene: SKScene {
    var ball: SKShapeNode!
    var ballSpeed = CGPoint(x: 150, y: 200)  // Ball moves right and up
    
    override func didMove(to view: SKView) {
        // Set background color
        backgroundColor = .blue
        
        // Create the ball
        createBall()
    }
    
    func createBall() {
        // Make a red circle ball
        ball = SKShapeNode(circleOfRadius: 20)
        ball.fillColor = .red
        
        // Start ball in center of screen
        ball.position = CGPoint(x: frame.midX, y: frame.midY)
        
        // Add ball to the scene
        addChild(ball)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Move the ball
        ball.position.x += ballSpeed.x / 60
        ball.position.y += ballSpeed.y / 60
        
        // Check if ball hits left or right wall
        if ball.position.x < 20 || ball.position.x > frame.width - 20 {
            ballSpeed.x = -ballSpeed.x  // Reverse horizontal direction
        }
        
        // Check if ball hits top or bottom wall
        if ball.position.y < 20 || ball.position.y > frame.height - 20 {
            ballSpeed.y = -ballSpeed.y  // Reverse vertical direction
        }
        
        // Keep ball inside screen (in case it goes out of bounds)
        if ball.position.x < 20 { ball.position.x = 20 }
        if ball.position.x > frame.width - 20 { ball.position.x = frame.width - 20 }
        if ball.position.y < 20 { ball.position.y = 20 }
        if ball.position.y > frame.height - 20 { ball.position.y = frame.height - 20 }
    }
}

struct ContentView: View {
    var body: some View {
        SpriteView(scene: GameScene(size: CGSize(width: 400, height: 800)))
            .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
