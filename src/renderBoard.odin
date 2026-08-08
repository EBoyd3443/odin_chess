package chess

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

rlBoard :: proc(state: ^Shared_State, renderFont: rl.Font) {
    rl.BeginDrawing()
    rl.ClearBackground(rl.RAYWHITE)
    for i in 0..=7 {
        for j in 0..=7 {
            if(state.selectedSquare[1] == i8(i) && state.selectedSquare[0] == i8(j)){
                rl.DrawRectangle(
                    i32(i*100),
                    i32(j*100),
                    100,
                    100,
                    rl.YELLOW
                )
                rl.DrawRectangle(
                    i32(i*100) + 10,
                    i32(j*100) + 10,
                    80,
                    80,
                    ((i+j)%2 == 1)?rl.Color({100,100,100,255}):rl.Color({175,175,175,255})
                )
            }
            else {
                rl.DrawRectangle(
                    i32(i*100),
                    i32(j*100),
                    100,
                    100,
                    ((i+j)%2 == 1)?rl.Color({100,100,100,255}):rl.Color({175,175,175,255})
                )  
            }
            
            switch(state.gameState.board[j][i]) {
                case -6:
                    rl.DrawTextCodepoint(renderFont, renderFont.glyphs[0].value, {f32(i*100)+25,f32(j*100)+10}, 80, rl.BLACK)
                case -5:
                    rl.DrawTextCodepoint(renderFont, renderFont.glyphs[1].value, {f32(i*100)+25,f32(j*100)+10}, 80, rl.BLACK)
                case -4:
                    rl.DrawTextCodepoint(renderFont, renderFont.glyphs[2].value, {f32(i*100)+25,f32(j*100)+10}, 80, rl.BLACK)
                case -3:
                    rl.DrawTextCodepoint(renderFont, renderFont.glyphs[3].value, {f32(i*100)+25,f32(j*100)+10}, 80, rl.BLACK)
                case -2:
                    rl.DrawTextCodepoint(renderFont, renderFont.glyphs[4].value, {f32(i*100)+25,f32(j*100)+10}, 80, rl.BLACK)
                case -1:
                    rl.DrawTextCodepoint(renderFont, renderFont.glyphs[5].value, {f32(i*100)+25,f32(j*100)+10}, 80, rl.BLACK)
                case 1:
                    rl.DrawTextCodepoint(renderFont, renderFont.glyphs[5].value, {f32(i*100)+25,f32(j*100)+10}, 80, rl.WHITE)
                case 2:
                    rl.DrawTextCodepoint(renderFont, renderFont.glyphs[4].value, {f32(i*100)+25,f32(j*100)+10}, 80, rl.WHITE)
                case 3:
                    rl.DrawTextCodepoint(renderFont, renderFont.glyphs[3].value, {f32(i*100)+25,f32(j*100)+10}, 80, rl.WHITE)
                case 4:
                    rl.DrawTextCodepoint(renderFont, renderFont.glyphs[2].value, {f32(i*100)+25,f32(j*100)+10}, 80, rl.WHITE)
                case 5:
                    rl.DrawTextCodepoint(renderFont, renderFont.glyphs[1].value, {f32(i*100)+25,f32(j*100)+10}, 80, rl.WHITE)
                case 6:
                    rl.DrawTextCodepoint(renderFont, renderFont.glyphs[0].value, {f32(i*100)+25,f32(j*100)+10}, 80, rl.WHITE)
            }
        }
    }
    handleBoardInput(state)
    rl.EndDrawing()
}

handleBoardInput :: proc(state: ^Shared_State) {
    if(rl.IsMouseButtonReleased(rl.MouseButton.LEFT)) {
        mouseX: i8
        switch rl.GetMouseX() {
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
        switch rl.GetMouseY() {
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
        if(mouseX == state.selectedSquare[1] && mouseY == state.selectedSquare[0]) {
            // deselect current clicked square
            state.selectedSquare = {-1,-1}
        }
        else{
            if(state.selectedSquare == {-1,-1}) {
                // if first square not selected
                if(mouseX >= 0 && mouseY >= 0) {
                    state.selectedSquare = {mouseY, mouseX}                    
                }
            }
            else {
                // handle when first square selected
                
                // validMoves:= validateMove(&state.gameState, state.selectedSquare)
                // selectedPiece:= state.gameState.board[state.selectedSquare[0][state.selectedSquare[1]]]
                // proposedMove = {
                //     from = state.selectedSquare,
                //     to = {mouseY,MouseX}
                // }
            }
        }
    }
}