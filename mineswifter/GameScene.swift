//
//  GameScene.swift
//  MineSwifter
//
//  Created by Dexafree on 22/10/14.
//  Copyright (c) 2014 dexafree. All rights reserved.
//

import SpriteKit

/*
 * Ugly hack needed to be able to receive and process the Right-Click events
 */
extension SKView {
    override public func rightMouseDown(theEvent: NSEvent) {
        self.scene!.rightMouseDown(theEvent)
    }
}

/* Make Int class able to generate random numbers */
extension Int {
    static func random(range: Range<Int> ) -> Int{
        var offset = 0
        
        if range.startIndex < 0 {  // allow negative ranges
            offset = abs(range.startIndex)
        }
        
        let mini = UInt32(range.startIndex + offset)
        let maxi = UInt32(range.endIndex   + offset)
        
        return Int(mini + arc4random_uniform(maxi - mini)) - offset
    }
}

class GameScene: SKScene {
    
    enum GameState{
        case WIN
        case LOST
        case PLAYING
    }
    
    /* Constant declaration */
    let ROWS: Int = 10
    let COLS: Int = 10
    let BOMBS_NUMBER: Int = 25
    
    
    var board: [[TileSprite]] = [[TileSprite]]()
    
    var status: GameState = GameState.PLAYING
    
    /* Scene entry point */
    override func didMoveToView(view: SKView) {
        
        /* Set the background color to black */
        backgroundColor = SKColor.blackColor()
        
        /* Double loop for filling the board */
        for row in 0..<ROWS {

            board.append([TileSprite]())
            
            for col in 0..<COLS{
            
                /* Create a new TileSprite, calculate its size and set its position */
                var tileSprite = TileSprite()

                var x: CGFloat = (tileSprite.size.width * CGFloat(col))+(tileSprite.size.width/2)
                var y: CGFloat = (tileSprite.size.height * CGFloat(row))+(tileSprite.size.height/2)

                
                tileSprite.position = CGPoint(x: x, y: y)

                /* Set its column and row, in order to be able to retrieve it when it's clicked */
                tileSprite.row = row
                tileSprite.col = col
                
                /* Append the tile to the array and show it */
                board[row].append(tileSprite)
                addChild(tileSprite)
            }
        }
        
        /* Fill the board with bombs */
        fillBombs()
    }
    
    
    /* 
     * Set some bombs to the board
     * TODO: Random generation
     */
    func fillBombs(){
        
        for numBombs in 0..<BOMBS_NUMBER {
            var randomRow: Int
            var randomCol: Int
            
            do {
                randomRow = Int.random(0..<ROWS)
                randomCol = Int.random(0..<COLS)
            } while(board[randomRow][randomCol].isBomb)
            
            insertBomb(randomRow, col: randomCol)
            
        }
    }
    
    /* Shows all the bombs in the board */
    func showAllBombs(){
        for row in 0..<ROWS {
            for col in 0..<COLS {
                if(board[row][col].isBomb) {putBomb(row, col: col)}
            }
        }
    }
    
    /* Inserts a bomb at a desired position */
    func insertBomb(row: Int, col: Int){
        board[row][col].isBomb = true
    }
    
    /* Changes the layout of a flagged tile to a normal one */
    func removeFlag(row: Int, col: Int){
        board[row][col].isFlagged = false
        board[row][col].texture = SKTexture(imageNamed: "tile")
    }
    
    /* Changes the layout of a tile to the Flagged one */
    func putFlag(row: Int, col: Int){
        board[row][col].isFlagged = true
        board[row][col].texture = SKTexture(imageNamed: "tile_flag")
    }
    
    /* Changes the layout of a tile to a bomb one */
    func putBomb(row: Int, col: Int){
        board[row][col].texture = SKTexture(imageNamed: "tile_bomb")
    }
    
    /* Changes the layout of a tile to the corresponding number */
    func putNumber(row: Int, col: Int, number: Int){
        var string: NSString
        
        if(number == 0) {
            string = "white"
        } else {
            string = "\(number)"
        }
        
        var tileString: String! = "tile_\(string)"
        
        board[row][col].texture = SKTexture(imageNamed: tileString)
    }
    
    /* React to a tile press */
    func pressTile(row: Int, col: Int){
        
        
        if (row >= ROWS || col >= COLS || row < 0 || col < 0 || board[row][col].isUnlocked){
            /* DON'T DO ANYTHING */
        } else {
            
            /* If it's a bomb, set the layout of the tile to the bomb one, and mark the game as Lost */
            if board[row][col].isBomb {
                showAllBombs()
                status = GameState.LOST
            } else {
                
                /* If it's not a bomb, first check again if the tile is not unlocked */
                if (!board[row][col].isUnlocked) {
                    
                    /* Get the number of surrounding bombs to the tile */
                    var roundingBombs = getSurroundingBombs(row, col: col)
                    
                    /*
                     * Mark the tile as unlocked. It's very important to do it before calling the
                     * Recursive function, because if it's not done in that order, we would end in
                     * a deadlock, because consecutive tiles would be calling to each other forever
                     */
                    board[row][col].isUnlocked = true
                    
                    /* Change the layout of the tile to its number (or blank) */
                    putNumber(row, col: col, number: roundingBombs)
                    
                    /* If there were no bombs surrounding that tile, discover recursively the surrounding tiles */
                    
                    if roundingBombs == 0 {
                        var i: Int
                        var j: Int
                        
                        for(i = -1; i <= 1; i++){
                            for(j = -1; j <= 1; j++){
                                pressTile(row+i, col: col+j)
                            }
                        }
                    }
                }
            }
        }
    }
    
    /* Returns how many bombs are surrounding a specific tile */
    func getSurroundingBombs(row: Int, col: Int) -> Int! {
        var bombCount: Int = 0
        var i: Int
        var j: Int
        
        for(i = -1;i<=1;i++){
            for(j = -1;j<=1;j++){
                if(row + i >= 0 && row + i < ROWS ){
                    if(col + j >= 0 && col + j < COLS){
                        if(board[row+i][col+j].isBomb){
                            bombCount++;
                        }
                        
                    }
                }
            }
        }
        
        return bombCount;
    }
    
    /* Reacts to a Right-Click */
    override func rightMouseDown(theEvent: NSEvent) {
        
        /* We need to convert the location `view coordinates` to `scene coordinates`, in order to select the correct node. */
        var location: CGPoint = theEvent.locationInNode(self)
        
        /*
         * By checking if nodeAtPoint(location) is different to self, we ensure that
         * a tile has been pressed, because if the click was performed outside the board,
         * the returned node would be the scene itself
         */
        if (nodeAtPoint(location) != self) {
            let touchedNode: TileSprite = nodeAtPoint(location) as TileSprite
            
            /* Retrieve the row and col previously stored at that node */
            var row = touchedNode.row
            var col = touchedNode.col
            
            println("ROW: \(row) COL:\(col)")
            
            if(status == GameState.PLAYING && !board[row][col].isUnlocked){
                if(board[row][col].isFlagged){
                    removeFlag(row, col: col)
                } else {
                    putFlag(row, col: col)
                }
            } else {
                println("STATUS: \(status.hashValue)")
            }
            
            
        } else {
            println("Right click out of board")
        }

    }
    
    /* Reacts to a Left-Click */
    override func mouseDown(theEvent: NSEvent) {
        
        /* We need to convert the location `view coordinates` to `scene coordinates`, in order to select the correct node. */
        var location: CGPoint = theEvent.locationInNode(self)
        
        
        if (nodeAtPoint(location) != self) {
            let touchedNode: TileSprite = nodeAtPoint(location) as TileSprite
            
            var row = touchedNode.row
            var col = touchedNode.col
            
            println("ROW: \(row) COL:\(col)")
            
            if(status == GameState.PLAYING && !board[row][col].isFlagged){
                pressTile(row, col: col)
            } else {
                println("STATUS: \(status.hashValue)")
            }
            

        } else {
            println("Left click out of board")
        }
        
        
    }
    
}

