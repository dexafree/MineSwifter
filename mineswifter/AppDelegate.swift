//
//  AppDelegate.swift
//  MineSwifter
//
//  Created by Dexafree on 22/10/14.
//  Copyright (c) 2014 dexafree. All rights reserved.
//


import Cocoa
import SpriteKit


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var skView: SKView!
    
    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        /* Pick a size for the scene */
        let scene = GameScene()

        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .AspectFit
        
        /* Get the size of a single tile, in order to make further calculations */
        var sprite: SKSpriteNode = SKSpriteNode(imageNamed: "tile_white")
        
        var spriteSize: CGSize = sprite.size
        
        var xSize = CGFloat(scene.COLS)*spriteSize.width
        
        var ySize = CGFloat(scene.ROWS)*spriteSize.height
        
        /* Set the scene size */
        scene.size = CGSize(width: xSize, height: ySize)
        
        self.skView!.presentScene(scene)
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        self.skView!.ignoresSiblingOrder = true
        self.skView!.showsFPS = true
        self.skView!.showsNodeCount = true
        
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }
}
