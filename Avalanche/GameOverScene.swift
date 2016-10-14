//
//  GameOverScene.swift
//  Avalanche
//
//  Created by Pascal Sturmfels on 9/22/16.
//  Copyright © 2016 LooseFuzz. All rights reserved.
//

import SpriteKit
import GameKit

class GameOverScene: SKScene {
    var replayButton: ButtonLabelNode!
    var menuButton: ButtonLabelNode!
    var highScore: Int!
    var highScoreLabel: SKLabelNode!
    
    
    //MARK: Initializing Methods
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        replayButton = ButtonLabelNode()
        menuButton = ButtonLabelNode()
        
        let center: CGPoint = CGPoint(x: self.frame.midX, y: self.frame.midY)
        
        replayButton.setup(withText: "Replay: ", withFontSize: 48.0, withButtonName: "Replay", normalTextureName: "replayNormal", highlightedTextureName: "replayHighlighted", atPosition: center)
        replayButton.position.y += replayButton.height * 0.5 + 10
        
        menuButton.setup(withText: "Menu: ", withFontSize: 48.0, withButtonName: "Menu", normalTextureName: "menuNormal", highlightedTextureName: "menuHighlighted", atPosition: center)
        menuButton.position.y -= menuButton.height * 0.5 + 10
        
        highScoreLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        highScoreLabel.fontSize = 42.0
        highScoreLabel.text = "Score: \(highScore!) ft"
        highScoreLabel.position = center
        highScoreLabel.position.y += replayButton.height + highScoreLabel.frame.height * 1.4
        
        self.addChild(replayButton)
        self.addChild(menuButton)
        self.addChild(highScoreLabel)
        
        let localPlayer = GKLocalPlayer.localPlayer()
        if localPlayer.isAuthenticated {
            localPlayer.loadDefaultLeaderboardIdentifier(completionHandler: { (identifier, error) in
                if error != nil {
                    NSLog("Could not load leaderboard: \(error!)")
                } else if let leaderboardIdentifier = identifier {
                    let scoreObject: GKScore = GKScore(leaderboardIdentifier: leaderboardIdentifier, player: localPlayer)
                    scoreObject.value = Int64(self.highScore)
                    
                    GKScore.report([scoreObject], withCompletionHandler: { (error) in
                        if error != nil {
                            NSLog("Could not report score \(scoreObject) to leaderboard \(leaderboardIdentifier)")
                        }
                    })
                }
            })
        }
    }
    
    //MARK: Touch Methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let objects = nodes(at: location) as [SKNode]
            for object in objects {
                if object.name == "Replay" {
                    replayButton.didPress()
                    break
                }
                else if object.name == "Menu" {
                    menuButton.didPress()
                    break
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if replayButton.isPressed {
            replayButton.didRelease()
            transitionToReplay()
        }
        else if menuButton.isPressed {
            menuButton.didRelease()
            transitionToMenu()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        var movedOverButton: Bool = false
        
        for touch in touches {
            let location = touch.location(in: self)
            let objects = nodes(at: location) as [SKNode]
            for object in objects {
                if object.name == "Replay" || object.name == "Menu" {
                    movedOverButton = true
                    break
                }
            }
        }
        
        if !movedOverButton {
            replayButton.didRelease()
            menuButton.didRelease()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        replayButton.didRelease()
        menuButton.didRelease()
    }
    
    //MARK: Transition Methods
    func transitionToMenu() {
        let menuScene = MenuScene(size: self.size)
        menuScene.scaleMode = .resizeFill
        let transition = SKTransition.crossFade(withDuration: 0.5)
        self.scene!.view!.presentScene(menuScene, transition: transition)
    }
    
    func transitionToReplay() {
        let gameScene = GameScene(fileNamed: "GameScene")!
        gameScene.size = self.size
        let transition = SKTransition.crossFade(withDuration: 0.5)
        gameScene.scaleMode = .resizeFill
        self.scene!.view!.presentScene(gameScene, transition: transition)
    }
}

