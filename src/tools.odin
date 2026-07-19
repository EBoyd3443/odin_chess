package chess

import "core:fmt"
import "core:strings"
import "core:strconv"

isValidMoveFormat :: proc(state: ^Game_State, move: string) -> string {
    
    if (len(move) < 4 || len(move) > 5) ||
    !((move[0] >= 'a' && move[0] <= 'h') || (move[0] >= 'A' && move[0] <= 'H'))||
    !((move[1] >= '1' && move[1] <= '8' ))||
    !((move[1] >= '1' && move[1] <= '8' ))||
    !((move[2] >= 'a' && move[2] <= 'h') || (move[2] >= 'A' && move[2] <= 'H')) ||
    !((move[3] >= '1' && move[3] <= '8' )) {
        return "Move format error."
    }

    pieceToMove : i8 = state.board[7-(move[1]-'1')][fileToInt(move[0])]
    targetSpave : i8 = state.board[7-(move[3]-'1')][fileToInt(move[2])]

    if(pieceToMove == 0) {
        return "No piece selected."
    }
    if(pieceToMove < 0 && state.whiteToPlay) {
        return "Black piece selected when white to play."
    }
    if(pieceToMove > 0 && !state.whiteToPlay) {
        return "White piece selected when black to play."
    }

    if((pieceToMove == 1 && move[3] == '8' && len(move) != 5) ||
    (pieceToMove == -1 && move[3] == '1' && len(move) != 5)) {
        return "Piece promotion missing from move."
    }

    if(len(move) == 5) {
        if(pieceToMove == 1 && move[3] == '8' || pieceToMove == -1 && move[3] == '1') {
            switch move[4] {
                case 'r': fallthrough
                case 'R': fallthrough
                case 'n': fallthrough
                case 'N': fallthrough
                case 'b': fallthrough
                case 'B': fallthrough
                case 'q': fallthrough
                case 'Q': return "None"
                case: return "Invalid piece promotion."
            } 
        }
        else {
            return "Invalid move for promotion"
        }
    }

    return "None"
}