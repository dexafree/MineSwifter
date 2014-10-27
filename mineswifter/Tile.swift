//
//  Tile.swift
//  MineSwifter
//
//  Created by Dexafree on 23/10/14.
//  Copyright (c) 2014 dexafree. All rights reserved.
//

import SpriteKit

class TileSprite: SKSpriteNode {
    
    var isBomb: Bool
    var isUnlocked: Bool
    var row: Int
    var col: Int

    override init(){
        self.isBomb = false
        self.isUnlocked = false
        self.row = 0
        self.col = 0
        
        let texture = SKTexture(imageNamed: "tile") // We initialize it with the default layout
        super.init(texture: texture, color: nil, size: texture.size())
    }
    
    init(row: Int, col: Int){
        self.isBomb = false
        self.isUnlocked = false
        self.row = row
        self.col = col
        
        let texture = SKTexture(imageNamed: "tile") // We initialize it with the default layout
        super.init(texture: texture, color: nil, size: texture.size())
    }
    


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}