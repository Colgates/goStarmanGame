//
//  GameScene.swift
//  goStarmanGame
//
//  Created by Evgenii Kolgin on 04.03.2021.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var audioPlayer: AVAudioPlayer!
    
    var isFingerOnPlayer = false
    
    var starfield: SKEmitterNode!
    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    
    var restartLabel: SKLabelNode!
    
    var possibleEnemies = ["asteroid1", "asteroid2", "asteroid3"]
    var gameTimer: Timer?
    var isGameOver = false
    
    var enemiesCreated = 0
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    let explosionSound = SKAction.playSoundFileNamed("explosion", waitForCompletion: false)
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        starfield = SKEmitterNode(fileNamed: "starfield")!
        starfield.position = CGPoint(x: 1024, y: 384)
        starfield.advanceSimulationTime(10)
        addChild(starfield)
        starfield.zPosition = -1
        
        playSound(soundName: String(Int.random(in: 1...16)))
        
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: 384)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.contactTestBitMask = 1
        addChild(player)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        score = 0
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        gameTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
    }
    
    @objc func createEnemy() {
        guard let enemy = possibleEnemies.randomElement() else { return }
        enemiesCreated += 1
        let sprite = SKSpriteNode(imageNamed: enemy)
        sprite.position = CGPoint(x: 1200, y: Int.random(in: 50...736))
        addChild(sprite)
        
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.categoryBitMask = 1
        sprite.physicsBody?.velocity = CGVector(dx: Int.random(in: -400...(-100)), dy: 0)
        sprite.physicsBody?.angularVelocity = CGFloat.random(in: 1...5)
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.angularDamping = 0
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self)
        
        let objects = nodes(at: touchLocation)
        if objects.contains(player) {
            isFingerOnPlayer.toggle()
        }
        
        if isGameOver {
            guard objects.contains(restartLabel) else { return }
            let newScene = GameScene(size: self.size)
            newScene.scaleMode = self.scaleMode
            let animation = SKTransition.fade(withDuration: 1.0)
            self.view?.presentScene(newScene, transition: animation)
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        for node in children {
            if node.position.x < -300 {
                node.removeFromParent()
            }
        }
        if !isGameOver {
            score += 1
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isFingerOnPlayer {
            guard let touch = touches.first else { return }
            var location = touch.location(in: self)
            
            if location.y < 50 {
                location.y = 50
            } else if location.y > 718 {
                location.y = 718
            }
            player.position = location
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isFingerOnPlayer = false
    }
    
    func playSound(soundName: String) {
        let url = Bundle.main.url(forResource: soundName, withExtension: "mp3")
        audioPlayer = try! AVAudioPlayer(contentsOf: url!)
        audioPlayer.play()
    }
    
    func gameOver() {
        let gameOver = SKSpriteNode(imageNamed: "GameOver")
        gameOver.position = CGPoint(x: 512, y: 384)
        gameOver.zPosition = 1
        addChild(gameOver)
        
        restartLabel = SKLabelNode(fontNamed: "Chalkduster")
        restartLabel.position = CGPoint(x: 512, y: 300)
        restartLabel.fontSize = 40
        restartLabel.zPosition = 1
        restartLabel.text = "Restart"
        addChild(restartLabel)
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = player.position
        addChild(explosion)
        run(explosionSound)
        player.removeFromParent()
        isGameOver = true
        gameTimer?.invalidate()
        audioPlayer.stop()
        gameOver()
    }
}
