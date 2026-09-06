package chess

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

rlBoard :: proc(state: ^Shared_State, renderFont: rl.Font) {
    boardOffsetX:i32=100
    boardOffsetY:i32=0
    rl.BeginDrawing()
    rl.ClearBackground(rl.Color({200,200,200,255}))
    for i in 0..=7 {
        for j in 0..=7 {
            hundredI:i32=i32(i*100)
            hundredJ:i32=i32(j*100)
            if(state.selectedSquare[1] == i8(i) && state.selectedSquare[0] == i8(j)){
                rl.DrawRectangle(
                    hundredI+boardOffsetX,
                    hundredJ+boardOffsetY,
                    100,
                    100,
                    rl.YELLOW
                )
                rl.DrawRectangle(
                    hundredI+boardOffsetX + 10,
                    hundredJ+boardOffsetY + 10,
                    80,
                    80,
                    ((i+j)%2 == 1)?rl.Color({100,100,100,255}):rl.Color({175,175,175,255})
                )
            }
            else {
                rl.DrawRectangle(
                    hundredI+boardOffsetX,
                    hundredJ+boardOffsetY,
                    100,
                    100,
                    ((i+j)%2 == 1)?rl.Color({100,100,100,255}):rl.Color({175,175,175,255})
                )
            }        
            
            switch(state.gameState.board[j][i]) {
                case -6:
                    rl.DrawTextCodepoint(renderFont, renderFont.glyphs[0].value, {f32(hundredI+boardOffsetX)+25,f32(hundredJ+boardOffsetY)+10}, 80, rl.BLACK)
                case -5:
                    rl.DrawTextCodepoint(renderFont, renderFont.glyphs[1].value, {f32(hundredI+boardOffsetX)+25,f32(hundredJ+boardOffsetY)+10}, 80, rl.BLACK)
                case -4:
                    rl.DrawTextCodepoint(renderFont, renderFont.glyphs[2].value, {f32(hundredI+boardOffsetX)+25,f32(hundredJ+boardOffsetY)+10}, 80, rl.BLACK)
                case -3:
                    rl.DrawTextCodepoint(renderFont, renderFont.glyphs[3].value, {f32(hundredI+boardOffsetX)+25,f32(hundredJ+boardOffsetY)+10}, 80, rl.BLACK)
                case -2:
                    rl.DrawTextCodepoint(renderFont, renderFont.glyphs[4].value, {f32(hundredI+boardOffsetX)+25,f32(hundredJ+boardOffsetY)+10}, 80, rl.BLACK)
                case -1:
                    rl.DrawTextCodepoint(renderFont, renderFont.glyphs[5].value, {f32(hundredI+boardOffsetX)+25,f32(hundredJ+boardOffsetY)+10}, 80, rl.BLACK)
                case 1:
                    rl.DrawTextCodepoint(renderFont, renderFont.glyphs[5].value, {f32(hundredI+boardOffsetX)+25,f32(hundredJ+boardOffsetY)+10}, 80, rl.WHITE)
                case 2:
                    rl.DrawTextCodepoint(renderFont, renderFont.glyphs[4].value, {f32(hundredI+boardOffsetX)+25,f32(hundredJ+boardOffsetY)+10}, 80, rl.WHITE)
                case 3:
                    rl.DrawTextCodepoint(renderFont, renderFont.glyphs[3].value, {f32(hundredI+boardOffsetX)+25,f32(hundredJ+boardOffsetY)+10}, 80, rl.WHITE)
                case 4:
                    rl.DrawTextCodepoint(renderFont, renderFont.glyphs[2].value, {f32(hundredI+boardOffsetX)+25,f32(hundredJ+boardOffsetY)+10}, 80, rl.WHITE)
                case 5:
                    rl.DrawTextCodepoint(renderFont, renderFont.glyphs[1].value, {f32(hundredI+boardOffsetX)+25,f32(hundredJ+boardOffsetY)+10}, 80, rl.WHITE)
                case 6:
                    rl.DrawTextCodepoint(renderFont, renderFont.glyphs[0].value, {f32(hundredI+boardOffsetX)+25,f32(hundredJ+boardOffsetY)+10}, 80, rl.WHITE)
            }
        }
    }
    rl.DrawRectangle(
        i32(boardOffsetX),
        i32(800+boardOffsetY),
        800,
        100,
        rl.WHITE
    )
    switch state.needPromotion[0] {
        case 0:
            drawPromotionSelect(state, renderFont)
        case 7:
            drawPromotionSelect(state, renderFont)
    }
    handleBoardInput(state, boardOffsetX, boardOffsetY)
    rl.EndDrawing()
}

drawPromotionSelect :: proc(state: ^Shared_State, renderFont: rl.Font) {
    color:i8=(state.gameState.board[state.selectedSquare[0]][state.selectedSquare[1]]>0)?WHITE:BLACK
    yPosition:i32=(color==WHITE)?100:650
    rl.DrawRectangle(
        i32(state.needPromotion[1])*100 + 25,
        yPosition,
        250,
        50,
        rl.GRAY
    )
    rookBox: rl.Rectangle = {
        x = f32(state.needPromotion[1])*100 + 30,
        y = f32(yPosition)+5,
        width = 40,
        height = 40
    }
    if(rl.GuiButton(rookBox, " ")) {
        proposedMove:Basic_Move = {
            moveType=(state.gameState.board[state.needPromotion[0]][state.needPromotion[1]] == 0)?Move_Type.standard:Move_Type.capture,
            from = state.selectedSquare,
            to = {state.needPromotion[0],state.needPromotion[1]},
            piecePromotion = color*ROOK
        }
        executeMove(&state.gameState, proposedMove)
        state.selectedSquare = {-1,-1}
        state.needPromotion = {-1,-1}
    }
    rl.DrawTextCodepoint(renderFont, renderFont.glyphs[2].value, {f32(state.needPromotion[1])*100 + 37, f32(yPosition)+5}, 40, rl.BLACK)
    bishopBox: rl.Rectangle = {
        x = f32(state.needPromotion[1])*100 + 80,
        y = f32(yPosition)+5,
        width = 40,
        height = 40
    }
    if(rl.GuiButton(bishopBox, " ")) {
        proposedMove:Basic_Move = {
            moveType=(state.gameState.board[state.needPromotion[0]][state.needPromotion[1]] == 0)?Move_Type.standard:Move_Type.capture,
            from = state.selectedSquare,
            to = {state.needPromotion[0],state.needPromotion[1]},
            piecePromotion = color*BISHOP
        }
        executeMove(&state.gameState, proposedMove)
        state.selectedSquare = {-1,-1}
        state.needPromotion = {-1,-1}
    }
    rl.DrawTextCodepoint(renderFont, renderFont.glyphs[4].value, {f32(state.needPromotion[1])*100 + 87, f32(yPosition)+5}, 40, rl.BLACK)
    knightBox: rl.Rectangle = {
        x = f32(state.needPromotion[1])*100 + 130,
        y = f32(yPosition)+5,
        width = 40,
        height = 40
    }
    if(rl.GuiButton(knightBox, " ")) {
        proposedMove:Basic_Move = {
            moveType=(state.gameState.board[state.needPromotion[0]][state.needPromotion[1]] == 0)?Move_Type.standard:Move_Type.capture,
            from = state.selectedSquare,
            to = {state.needPromotion[0],state.needPromotion[1]},
            piecePromotion = color*KNIGHT
        }
        executeMove(&state.gameState, proposedMove)
        state.selectedSquare = {-1,-1}
        state.needPromotion = {-1,-1}
    }
    rl.DrawTextCodepoint(renderFont, renderFont.glyphs[3].value, {f32(state.needPromotion[1])*100 + 137, f32(yPosition)+5}, 40, rl.BLACK)
    queenBox: rl.Rectangle = {
        x = f32(state.needPromotion[1])*100 + 180,
        y = f32(yPosition)+5,
        width = 40,
        height = 40
    }
    if(rl.GuiButton(queenBox, " ")) {
        proposedMove:Basic_Move = {
            moveType=(state.gameState.board[state.needPromotion[0]][state.needPromotion[1]] == 0)?Move_Type.standard:Move_Type.capture,
            from = state.selectedSquare,
            to = {state.needPromotion[0],state.needPromotion[1]},
            piecePromotion = color*QUEEN
        }
        executeMove(&state.gameState, proposedMove)
        state.selectedSquare = {-1,-1}
        state.needPromotion = {-1,-1}
    }
    rl.DrawTextCodepoint(renderFont, renderFont.glyphs[1].value, {f32(state.needPromotion[1])*100 + 187, f32(yPosition)+5}, 40, rl.BLACK)
    exitBox: rl.Rectangle = {
        x = f32(state.needPromotion[1])*100 + 230,
        y = f32(yPosition)+5,
        width = 40,
        height = 40
    }
    if(rl.GuiButton(exitBox, " ")) {
        state.needPromotion = {-1,-1}
    }
    rl.DrawTextCodepoint(renderFont, renderFont.glyphs[6].value, {f32(state.needPromotion[1])*100 + 237, f32(yPosition)+6}, 40, rl.BLACK)
}

handleBoardInput :: proc(state: ^Shared_State, boardOffsetX: i32, boardOffsetY: i32) {
    if(rl.IsMouseButtonReleased(rl.MouseButton.LEFT)) {
        mouseX: i8
        switch (rl.GetMouseX() - boardOffsetX) {
            case 0..<100: mouseX = 0
            case 100..<200: mouseX = 1
            case 200..<300: mouseX = 2
            case 300..<400: mouseX = 3
            case 400..<500: mouseX = 4
            case 500..<600: mouseX = 5
            case 600..<700: mouseX = 6
            case 700..<800: mouseX = 7
            case: mouseX = -1
        }
        mouseY: i8
        switch (rl.GetMouseY() - boardOffsetY) {
            case 0..<100: mouseY = 0
            case 100..<200: mouseY = 1
            case 200..<300: mouseY = 2
            case 300..<400: mouseY = 3
            case 400..<500: mouseY = 4
            case 500..<600: mouseY = 5
            case 600..<700: mouseY = 6
            case 700..<800: mouseY = 7
            case: mouseY = -1
        }
        if(state.needPromotion == {-1,-1} && mouseX >= 0 && mouseY >= 0) {
            if(mouseX == state.selectedSquare[1] && mouseY == state.selectedSquare[0]) {
                // deselect current clicked square
                state.selectedSquare = {-1,-1}
            }
            else{
                if(state.selectedSquare == {-1,-1}) {
                    // if player selecting an active player piece
                    if(mouseX >= 0 && mouseY >= 0 && activePlayerControls(&state.gameState, {mouseY, mouseX})) {
                        state.selectedSquare = {mouseY, mouseX}
                    }
                }
                else {
                    // handle when from square for a move is selected
                    // ToDo: solve pawn promotion.
                    selectedPiece:= state.gameState.board[state.selectedSquare[0]][state.selectedSquare[1]]
                    if(mouseY == (state.gameState.whiteToPlay?0:7) && (selectedPiece == WHITE*PAWN || selectedPiece == BLACK*PAWN)){
                        //fmt.println("need to promote.", mouseY, (state.gameState.whiteToPlay?0:7), state.gameState.whiteToPlay, selectedPiece)
                        // Promotion needed.
                        state.needPromotion = {mouseY, mouseX}
                    }
                    else {
                        proposedMove:Basic_Move = {
                                from = state.selectedSquare,
                                to = {mouseY,mouseX}
                        }
                        if(validateMove(&state.gameState, &proposedMove)) {
                            executeMove(&state.gameState, proposedMove)
                            state.selectedSquare = {-1,-1}
                        }    
                    }
                }
            }
        }
    }
}