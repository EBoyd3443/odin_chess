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
        fmt.println(getValidMoves(state, [2]i8{6,1}))
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

            inputError: = isValidMove(state, input)
            if(inputError == "None") {
                sync.mutex_lock(&state.mutex)
                
                move:=moveStringToArray(input)
                executeMove(state, move)
                
                if state.moveList == "" {
                    state.moveList = strings.clone(input)
                } else {
                    state.moveList = strings.concatenate({state.moveList, "\n", input})
                }
                
                sync.mutex_unlock(&state.mutex)
                //fmt.print("\x1b[2J\x1b[H")
            }
            else {
                fmt.println(inputError)
            }
        }
    }     
}