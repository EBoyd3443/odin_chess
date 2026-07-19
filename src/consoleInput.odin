package chess

import "core:fmt"
import "core:os"
import "core:strings"
import "core:sync"

inputThread :: proc(state: ^Shared_State) {
    // Get next move.
    for {
        fmt.println("Enter move.")

        /*******************  TESTING  *********************************/
        //fmt.println(state.gameState.whiteKingPosition)
                
        buf:[265]byte
        n,err := os.read(os.stdin, buf[:])

        if err!= nil {
            fmt.eprintln("Error reading input:", err)
        }
        else {
            input:= string(strings.to_lower(strings.trim_space(string(buf[:n]))))

            sync.mutex_lock(&state.mutex)
            inputError: = isValidMoveFormat(&state.gameState, input)
            if(inputError == "None") {
                
                move:= moveStringToBasicMove(input)
                
                // Checking for allowed move
                isAllowed:= validateMove (&state.gameState, &move)                
                moveExecuted:= false
                // Control based on allowed move
                //allowed move and king in check
                if(isAllowed && !isNotAttacked(&state.gameState, 
                (state.gameState.whiteToPlay)?state.gameState.whiteKingPosition[0]:state.gameState.blackKingPosition[0],
                (state.gameState.whiteToPlay)?state.gameState.whiteKingPosition[1]:state.gameState.blackKingPosition[1])) {
                    //explore the future
                    undoMove:= exploreMove(&state.gameState, move)
                    // Checking for moves that leave king in check
                    if(isNotAttacked(&state.gameState, 
                    (state.gameState.whiteToPlay)?state.gameState.whiteKingPosition[0]:state.gameState.blackKingPosition[0],
                    (state.gameState.whiteToPlay)?state.gameState.whiteKingPosition[1]:state.gameState.blackKingPosition[1])) {
                        reverseExplore(&state.gameState, undoMove)
                        executeMove(&state.gameState, move)
                        moveExecuted = true
                    }
                    else {
                        fmt.println("Cant make that move while in check.")
                    }
                } // not allowed or king not in check
                else{
                    //allowed and king not in check
                    if(isAllowed) {
                        executeMove(&state.gameState, move)
                        moveExecuted = true
                    } //not allowed                    
                    else {
                        fmt.println("Selected piece can't move there.")
                    }
                }
                
                // Update move list
                if(moveExecuted) {
                    if state.gameState.moveList == "" {
                        state.gameState.moveList = strings.clone(input)
                    } else {
                        state.gameState.moveList = strings.concatenate({state.gameState.moveList, "\n", input})
                    }
                }
                
                // Clear console window
                // fmt.print("\x1b[2J\x1b[H")
            }
            else {
                fmt.println(inputError)
            }
            sync.mutex_unlock(&state.mutex)
        }
    }     
}