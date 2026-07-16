package chess

import "core:fmt"
import "core:os"
import "core:strings"
import "core:sync"

inputThread :: proc(state: ^Game_State) {
    // Get next move.
    for {
        fmt.println("Enter move.")

        /*******************  TESTING  *********************************/
        // fmt.println(getValidMoves(state, [2]i8{6,1}))
        // fmt.println(state.moveList)
        // substringStart:= len(state.moveList) - 5
        // substringResult, ok:= strings.substring(state.moveList, (substringStart > 0)?substringStart:0, len(state.moveList))
        // fmt.print("Last move:")
        // fmt.println(strings.trim_space(substringResult))
                
        buf:[265]byte
        n,err := os.read(os.stdin, buf[:])

        if err!= nil {
            fmt.eprintln("Error reading input:", err)
        }
        else {
            input:= string(strings.to_lower(strings.trim_space(string(buf[:n]))))

            sync.mutex_lock(&state.mutex)
            inputError: = isValidMoveFormat(state, input)
            if(inputError == "None") {
                move:= moveStringToArray(input)
                isAllowed:= false
                validMoves:= getValidMoves(state, move[0])
                for validMove in validMoves {
                    if(move[1] == validMove) {
                        isAllowed = true
                    }
                }
                if(isAllowed) {
                    executeMove(state, move)
                }
                else {
                    fmt.println("Selected piece can't move there.")
                }
                
                // Update move list
                if state.moveList == "" {
                    state.moveList = strings.clone(input)
                } else {
                    state.moveList = strings.concatenate({state.moveList, "\n", input})
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