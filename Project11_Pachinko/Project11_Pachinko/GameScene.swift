//
//  GameScene.swift
//  Project11_Pachinko
//
//  Created by Sabrina Fletcher on 3/7/18.
//  Copyright © 2018 Sabrina Fletcher. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var scoreLbl: SKLabelNode!
    var editLbl: SKLabelNode!
    
    var editingMode: Bool = false{
        didSet {
            if editingMode{
                editLbl.text = "Done"
            } else {
                editLbl.text = "Edit"
            }
        }
    }
    
    var score = 0 {
        didSet {
            scoreLbl.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        
        physicsWorld.contactDelegate = self
        
        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))
        
        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
        
        scoreLbl = SKLabelNode(fontNamed: "Chalkduster")
        scoreLbl.text = "Score: 0"
        scoreLbl.horizontalAlignmentMode = .right
        scoreLbl.position = CGPoint(x: 980, y: 700)
        addChild(scoreLbl)
        
        editLbl = SKLabelNode(fontNamed: "Chalkduster")
        editLbl.text = "Edit"
        editLbl.position = CGPoint(x: 80, y: 700)
        addChild(editLbl)

    }
    
    func makeBouncer(at position: CGPoint){
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0)
        bouncer.physicsBody?.isDynamic = false //When true, object is moved by physics simulator based on gravity & collisions
        addChild(bouncer)
    }
    
    func makeSlot(at position: CGPoint, isGood: Bool){
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        
        if isGood{
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        } else{
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        
        slotBase.position = position
        slotGlow.position = position
        
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        
        addChild(slotBase)
        addChild(slotGlow)
        
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
        
    }
    
    func collisionBetween(ball: SKNode, object: SKNode){
        if object.name == "good" {
            destroy(ball: ball)
            score += 1
        } else if object.name == "bad"{
            destroy(ball: ball)
            score -= 1
        }
    }
    
    func destroy(ball: SKNode){
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles"){
            fireParticles.position = ball.position
            addChild(fireParticles)
        }
        ball.removeFromParent()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else {
            return
        }
        guard let nodeB = contact.bodyB.node else {
            return
        }
        
        if nodeA.name == "ball"{
            collisionBetween(ball: nodeA, object: nodeB)
        } else if nodeB.name == "ball"{
            collisionBetween(ball: nodeB, object: nodeA)
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            
            let objects = nodes(at: location)
            if objects.contains(editLbl){
                editingMode = !editingMode
            } else{
                if editingMode{
                    let size = CGSize(width: GKRandomDistribution(lowestValue: 16, highestValue: 128).nextInt(), height: 16)
                    let box = SKSpriteNode(color: RandomColor(), size: size)
                    box.zRotation = RandomCGFloat(min: 0, max: 3)
                    box.position = location
                    
                    box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                    box.physicsBody?.isDynamic = false
                    addChild(box)
                } else{
                    let ball = SKSpriteNode(imageNamed: "ballRed")
                    ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
                    ball.physicsBody!.contactTestBitMask = ball.physicsBody!.collisionBitMask
                    ball.physicsBody?.restitution = 0.4 //bounciness
                    ball.position = location
                    ball.name = "ball"
                    addChild(ball)
                }
                
            }
            
            
        }
    }
}