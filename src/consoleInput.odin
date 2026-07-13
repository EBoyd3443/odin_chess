package chess

import "core:fmt"
import "core:os"
import "core:strings"
import "core:sync"

inputThread :: proc(state: ^Game_State) {


    // Get next move.
    for {
        fileToInt:= make(map[u8]i8)
        defer delete(fileToInt)
        fileToInt['A'] = 0
        fileToInt['B'] = 1
        fileToInt['C'] = 2
        fileToInt['D'] = 3
        fileToInt['E'] = 4
        fileToInt['F'] = 5
        fileToInt['G'] = 6
        fileToInt['H'] = 7
        fileToInt['a'] = 0
        fileToInt['b'] = 1
        fileToInt['c'] = 2
        fileToInt['d'] = 3
        fileToInt['e'] = 4
        fileToInt['f'] = 5
        fileToInt['g'] = 6
        fileToInt['h'] = 7

        fmt.println("Enter move.")

        /*******************  TESTING  *********************************/
        fmt.println(getValidMoves(state, [2]i8{6,1}, fileToInt))
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

            inputError: = isValidMove(state, input, fileToInt)
            if(inputError == "None") {
                sync.mutex_lock(&state.mutex)
                
                move:=moveStringToArray(input)
                executeMove(state, move)
                
                // currentPiece := state.board[7-(input[1]-'1')][fileToInt[input[0]]]
                // state.board[7-(input[1]-'1')][fileToInt[input[0]]] = 0
                // state.board[7-(input[3]-'1')][fileToInt[input[2]]] = currentPiece
                
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

/*--------- deprecated in lieu of raylib render -------------*/

// logBoard :: proc(board : [8][8]i8) {
//     numToPiece:= make(map[i8]u8)
//     numToPiece[0] = ' '
//     numToPiece[1] = 'P'
//     numToPiece[2] = 'B'
//     numToPiece[3] = 'N'
//     numToPiece[4] = 'R'
//     numToPiece[5] = 'Q'
//     numToPiece[6] = 'K'
//     fmt.println(" ---------------------------------")
//     for i in board {
//         for j in i {
//             fmt.print(" | ")
//             fmt.print(rune(numToPiece[(j<0)?-j:j]))
//         }
//         fmt.println(" | ")
//         fmt.println(" ---------------------------------")
//     }
// }