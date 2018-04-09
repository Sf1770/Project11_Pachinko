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
    var ballImages = [String]()
    var scoreLbl: SKLabelNode!
    var editLbl: SKLabelNode!
    let numOfBalls = 5
    var ballCount = 0
    
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
    struct game{
        static var isOver : Bool = false
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
        
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)
        for item in items{
            //adds all the ball images into an array to be randomly chosen in the game
            if item.hasPrefix("ball") && !item.hasSuffix("@2x.png") && !item.hasSuffix("@3x.png"){
                ballImages.append(item)
            }
        }
        //print(ballImages)


    }
    
    func makeBouncer(at position: CGPoint){
        //creates a bouncer at the position passed in
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0)
        bouncer.physicsBody?.isDynamic = false //When true, object is moved by physics simulator based on gravity & collisions; bouncer should not move based on collisions and gravity
        addChild(bouncer)
    }
    
    func makeSlot(at position: CGPoint, isGood: Bool){
        // creates a slot for the balls to fall into to receive points/lose points
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
        
        //rotates the slot Glow
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
        
    }
    
    func collisionBetween(ball: SKNode, object: SKNode){
        //helps to track points based on object/slot name being good or bad
        if object.name == "good" {
            destroy(ball: ball)
            score += 1
            ballCount -= 1

        } else if object.name == "bad"{
            destroy(ball: ball)
            score -= 1
        }
    }
    
    func destroy(ball: SKNode){
        //destroys the ball once it lands in a slot, adds a Fire Particle effect to show the destruction
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles.sks"){
            fireParticles.position = ball.position
            addChild(fireParticles)
            
        }

        ball.removeFromParent()
        
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        //checks to make sure that both variables have nodes attached before attempting to unwrap them
        guard let nodeA = contact.bodyA.node else {
            return
        }
        guard let nodeB = contact.bodyB.node else {
            return
        }
        
        //checks to see which node is the ball in order to call collisionBetween method
        if nodeA.name == "ball"{
            if nodeB.name == "obstacle"{
                //if the ball hits an obstacle box than the obstacle box disappears
                nodeB.removeFromParent()
            } else{
                collisionBetween(ball: nodeA, object: nodeB)
            }
        } else if nodeB.name == "ball"{
            if nodeA.name == "obstacle"{
                //if the ball hits an obstacle box than the obstacle box disappears
                nodeA.removeFromParent()
                
            } else{
                //This is called when a ball hits a good/bad slot
                collisionBetween(ball: nodeB, object: nodeA)
            }
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            
            let objects = nodes(at: location)
            //print(objects.count)
            if objects.contains(editLbl){
                //checks whether the edit label has been pressed, and reverses the value of editingmode variable
                editingMode = !editingMode
            } else{
                if editingMode{
                    //print(location)
                    
                    let size = CGSize(width: GKRandomDistribution(lowestValue: 16, highestValue: 128).nextInt(), height: 16)
                    let box = SKSpriteNode(color: RandomColor(), size: size)
                    if objects.count == 1{
                        box.zRotation = RandomCGFloat(min: 0, max: 3)
                        box.position = location
                        box.name = "obstacle"
                        box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                        box.physicsBody?.isDynamic = false
                        addChild(box)
                    } else{
                        //removes the box if there is already a box in that position
                        objects[0].removeFromParent()
                    }
                } else{
                    if ballCount > numOfBalls{
                        score = 0
                        ballCount = 0
                        editingMode = false
                        let ac = UIAlertController(title: "No More Balls", message: "You have reached your ball limit.", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .cancel))
                        ac.addAction(UIAlertAction(title: "Play Again", style: .default))
                        self.view?.window?.rootViewController?.present(ac, animated: true, completion: goToGameScene)
        
                    }
                    else{
                        let ballNum = RandomInt(min: 0, max: (ballImages.count-1))
                        let ball = SKSpriteNode(imageNamed: ballImages[ballNum])
                        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
                        ball.physicsBody!.contactTestBitMask = ball.physicsBody!.collisionBitMask
                        ball.physicsBody?.restitution = 0.4 //bounciness
                        ball.position = CGPoint(x: location.x, y: 768)
                        ball.name = "ball"
                        addChild(ball)
                        ballCount += 1
                    }
                }
            }
        }
    }
    
    func goToGameScene(){
        let gameScene:GameScene = GameScene(size: self.view!.bounds.size)
        let transition = SKTransition.fade(withDuration: 1.0)
        gameScene.scaleMode = SKSceneScaleMode.fill
        self.view?.presentScene(gameScene, transition: transition)
    }
}
