package chess

import "core:fmt"
import "core:strings"
import "core:strconv"

moveStringToArray :: proc(input: string) -> [2][2]i8 {
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

    result:[2][2]i8
    result[0][0]=i8(7-(input[1]-'1'))
    result[0][1]=i8(fileToInt[input[0]])
    result[1][0]=i8(7-(input[3]-'1'))
    result[1][1]=i8(fileToInt[input[2]])

    return result
}

executeMove :: proc(state: ^Game_State, move: [2][2]i8) {
    //To Do: en passant capture scoring
    //To Do: en passant capture piece cleanup
    //To Do: castling piece movement
    if(state.whiteToPlay) {
        if(state.board[move[1][0]][move[1][1]] < 0) {
            state.blackPiecesCaptured += 1
        }
    }
    else {
        if(state.board[move[1][0]][move[1][1]] > 0) {
            state.whitePiecesCaptured += 1
        }
    }
    currentPiece := state.board[move[0][0]][move[0][1]]
    state.board[move[0][0]][move[0][1]] = 0
    state.board[move[1][0]][move[1][1]] = currentPiece
}

getWhitePieces :: proc(state: ^Game_State) -> [dynamic][2]i8 {
    remainingPieces:= 16-state.whitePiecesCaptured
    //fmt.print("White remaining: ")
    //fmt.println(remainingPieces)
    result:[dynamic][2]i8
    defer delete(result)
    foundPieces: i8 = 0
    for y:i8=7;y>=0;y-=1 {
        for x:i8=0;x<8;x+=1 {
            if(state.board[y][x] > 0) {
                target:[2]i8= {y, x}
                append(&result, target)
                foundPieces+=1
                if(foundPieces >= remainingPieces){
                    return result
                }
            }
        }
    }
    // Lines past here should never run.
    fmt.println("tools.odin(line73): index >= remainingPieces early exit not hit.")
    return result
}

getBlackPieces :: proc(state: ^Game_State) -> [dynamic][2]i8 {
    remainingPieces:= 16-state.blackPiecesCaptured
    result:[dynamic][2]i8
    defer delete(result)
    foundPieces: i8 = 0
    for y:i8=0;y<8;y+=1 {
        for x:i8=0;x<8;x+=1 {
            if(state.board[y][x] < 0) {
                target:[2]i8= {y, x}
                append(&result, target)
                foundPieces+=1
                if(foundPieces >= remainingPieces){
                    return result
                }
            }
        }
    }
    // Lines past here should never run.
    fmt.println("tools.odin(line95): index >= remainingPieces early exit not hit.")
    return result
}

isValidMove :: proc(state: ^Game_State, move: string, fileToInt: map[u8]i8) -> string {
    
    if (len(move) < 4 || len(move) > 5) ||
    !((move[0] >= 'a' && move[0] <= 'h') || (move[0] >= 'A' && move[0] <= 'H'))||
    !((move[1] >= '1' && move[1] <= '8' ))||
    !((move[1] >= '1' && move[1] <= '8' ))||
    !((move[2] >= 'a' && move[2] <= 'h') || (move[2] >= 'A' && move[2] <= 'H')) ||
    !((move[3] >= '1' && move[3] <= '8' )) {
        return "Move format error."
    }

    pieceToMove : i8 = state.board[7-(move[1]-'1')][fileToInt[move[0]]]
    targetSpave : i8 = state.board[7-(move[3]-'1')][fileToInt[move[2]]]

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

    state.whiteToPlay = (pieceToMove > 0)?false:true
    return "None"
}

isEmpty :: proc(target: i8) -> bool {
    return target == 0
}

containsOwnPiece :: proc(ownColor: i8, target: i8) -> bool {
    return target * ownColor > 0
}

isNotAttacked :: proc(state: ^Game_State, x: i8, y: i8) -> bool {
    color: i8 = (state.whiteToPlay)? -1: 1
    if(isOnBoard(y + color, x + 1) && state.board[y+color][x+1] == color * PAWN) {
        return false
    }
    if(isOnBoard(y + color, x - 1) && state.board[y+color][x-1] == color * PAWN) {
        return false
    }
    //rook (and half queen)
    //right
    for i:i8=x+1; i<8; i+=1 {
        target: i8 = state.board[y][i]
        
        if(target == color * QUEEN || target == color * ROOK){
            return false
        }
        if(target != 0) {
            //blocked
            break
        }
    }
    //left
    for i:i8=x-1; i>=0; i-=1 {
        target: i8 = state.board[y][i]
        
        if(target == color * QUEEN || target == color * ROOK){
            return false
        }
        if(target != 0) {
            //blocked
            break
        }
    }
    //down
    for i:i8=y+1; i<8; i+=1 {
        target: i8 = state.board[i][x]
        
        if(target == color * QUEEN || target == color * ROOK){
            return false
        }
        if(target != 0) {
            //blocked
            break
        }
    }
    //up
    for i:i8=y-1; i>=0; i-=1 {
        target: i8 = state.board[i][x]
        
        if(target == color * QUEEN || target == color * ROOK){
            return false
        }
        if(target != 0) {
            //blocked
            break
        }
    }

    //bishop (and half queen)
        //down right
    for i:i8=1; isOnBoard(x+i, y+i); i+=1 {
        target: i8 = state.board[y+i][x+i]
        
        if(target == color * QUEEN || target == color * BISHOP){
            return false
        }
        if(target != 0) {
            //blocked
            break
        }
    }
    //up right
    for i:i8=1; isOnBoard(x+i, y-i); i+=1 {
        target: i8 = state.board[y-i][x+i]
        
        if(target == color * QUEEN || target == color * BISHOP){
            return false
        }
        if(target != 0) {
            //blocked
            break
        }
    }
    //down left
    for i:i8=1; isOnBoard(x-i, y+i); i+=1 {
        target: i8 = state.board[y+i][x-i]
        
        if(target == color * QUEEN || target == color * BISHOP){
            return false
        }
        if(target != 0) {
            //blocked
            break
        }
    }
    //up left
    for i:i8=1; isOnBoard(x-i, y-i); i+=1 {
        target: i8 = state.board[y-i][x-i]
        
        if(target == color * QUEEN || target == color * BISHOP){
            return false
        }
        if(target != 0) {
            //check for own piece
            break
        }
    }
    //knights
    knightMoves: [][]i8 = {
        {x + 2, y + 1},
        {x + 1, y + 2},
        {x - 1, y + 2},
        {x - 2, y + 1},
        {x + 2, y - 1},
        {x + 1, y - 2},
        {x - 1, y - 2},
        {x - 2, y - 1},
    }
    for i in knightMoves {
        if(isOnBoard(i[1], i[0])) {
            if(state.board[i[1]][i[0]] == color * KNIGHT){
                return false
            }
        }
    }
    //king
    kingMoves: [][]i8 = {
        {x + 1, y - 1},
        {x + 1, y},
        {x + 1, y + 1},
        {x, y - 1},
        {x, y + 1},
        {x - 1, y - 1},
        {x - 1, y},
        {x - 1, y + 1},
    }
    for i in kingMoves {
        if(isOnBoard(i[1], i[0])) {
            if(state.board[i[1]][i[0]] == color * KING){
                return false
            }
        }
    }
    return true
}

isOnBoard :: proc(x: i8, y: i8) -> bool {
    return x >= 0 && x < 8 && y >= 0 && y < 8
}


getValidMoves :: proc(state: ^Game_State, targetPiece: [2]i8, fileToInt: map[u8]i8) -> [dynamic][2]i8 {
    pieceType : i8 = state.board[targetPiece[0]][targetPiece[1]]
    ownColor:i8 = state.board[targetPiece[0]][targetPiece[1]]>0?WHITE:BLACK
    enemyColor: i8 = state.board[targetPiece[0]][targetPiece[1]]>0?BLACK:WHITE

    validTargetMoves: [dynamic][2]i8

    switch(pieceType) {
        case BLACK*KING:
            if(!state.blackKingMoved && 
            isEmpty(state.board[0][1]) && isNotAttacked(state, 0, 1) &&
            isEmpty(state.board[0][2]) && isNotAttacked(state, 0, 2) &&
            isEmpty(state.board[0][3]) && isNotAttacked(state, 0, 3)) {
                append(&validTargetMoves, [2]i8{0, 2})
            }
            if(!state.blackKingMoved && 
            isEmpty(state.board[0][5]) && isNotAttacked(state, 0, 5) &&
            isEmpty(state.board[0][6]) && isNotAttacked(state, 0, 6)) {
                append(&validTargetMoves, [2]i8{0, 6})
            }
            for i in -1..=1 {
                for j in -1..=1{
                    if(isOnBoard(targetPiece[0]+i8(i), targetPiece[1]+i8(j)) &&
                    !containsOwnPiece(ownColor, (state.board[targetPiece[0]+i8(i)][targetPiece[1]+i8(j)]))&&
                    isNotAttacked(state, targetPiece[0]+i8(i), targetPiece[1]+i8(j))) {
                        append(&validTargetMoves, [2]i8{targetPiece[0]+i8(i), targetPiece[1]+i8(j)})
                    }
                }
            }
        case WHITE*KING:
            if(!state.whiteKingMoved && 
            isEmpty(state.board[7][1]) && isNotAttacked(state, 7, 1) &&
            isEmpty(state.board[7][2]) && isNotAttacked(state, 7, 2) &&
            isEmpty(state.board[7][3]) && isNotAttacked(state, 7, 3)) {
                append(&validTargetMoves, [2]i8{7, 2})
            }
            if(!state.whiteKingMoved && 
            isEmpty(state.board[7][5]) && isNotAttacked(state, 7, 5) &&
            isEmpty(state.board[7][6]) && isNotAttacked(state, 7, 6)) {
                append(&validTargetMoves, [2]i8{7, 6})
            }
            for i in -1..=1 {
                for j in -1..=1 {
                    if(isOnBoard(targetPiece[0]+i8(i), targetPiece[1]+i8(j)) &&
                    !containsOwnPiece(ownColor, (state.board[targetPiece[0]+i8(i)][targetPiece[1]+i8(j)]))&&
                    isNotAttacked(state, targetPiece[0]+i8(i), targetPiece[1]+i8(j))) {
                        append(&validTargetMoves, [2]i8{targetPiece[0]+i8(i), targetPiece[1]+i8(j)})
                    }
                }
            }
        case BLACK*QUEEN:
            fallthrough
        case WHITE*QUEEN:
            checkNorth: bool = true
            checkNorthEast: bool = true
            checkEast: bool = true
            checkSouthEast: bool = true
            checkSouth: bool = true
            checkSouthWest: bool = true
            checkWest: bool = true
            checkNorthWest: bool = true
            for i in 1..=7 {
                if(checkNorth) {
                    if(isOnBoard(targetPiece[0] - i8(i), targetPiece[1])) {
                        if(isEmpty(state.board[targetPiece[0]-i8(i)][targetPiece[1]])) {
                            append(&validTargetMoves, [2]i8{targetPiece[0]-i8(i), targetPiece[1]})
                        }
                        else {
                            if(enemyColor * state.board[targetPiece[0]-i8(i)][targetPiece[1]] > 0) {
                                append(&validTargetMoves, [2]i8{targetPiece[0]-i8(i), targetPiece[1]})
                            }
                            checkNorth = false
                        }
                    }
                }
                if(checkNorthEast) {
                    if(isOnBoard(targetPiece[0] - i8(i), targetPiece[1] + i8(i))) {
                        if(isEmpty(state.board[targetPiece[0]-i8(i)][targetPiece[1]+i8(i)])) {
                            append(&validTargetMoves, [2]i8{targetPiece[0]-i8(i), targetPiece[1]+i8(i)})
                        }
                        else {
                            if(enemyColor * state.board[targetPiece[0]-i8(i)][targetPiece[1]+i8(i)] > 0) {
                                append(&validTargetMoves, [2]i8{targetPiece[0]-i8(i), targetPiece[1]+i8(i)})
                            }
                            checkNorthEast = false
                        }
                    }
                }
                if(checkEast) {
                    if(isOnBoard(targetPiece[0], targetPiece[1] + i8(i))) {
                        if(isEmpty(state.board[targetPiece[0]][targetPiece[1]+i8(i)])) {
                            append(&validTargetMoves, [2]i8{targetPiece[0], targetPiece[1]+i8(i)})
                        }
                        else {
                            if(enemyColor * state.board[targetPiece[0]][targetPiece[1]+i8(i)] > 0) {
                                append(&validTargetMoves, [2]i8{targetPiece[0], targetPiece[1]+i8(i)})
                            }
                            checkEast = false
                        }
                    }
                }
                if(checkSouthEast) {
                    if(isOnBoard(targetPiece[0] + i8(i), targetPiece[1] + i8(i))) {
                        if(isEmpty(state.board[targetPiece[0]+i8(i)][targetPiece[1]+i8(i)])) {
                            append(&validTargetMoves, [2]i8{targetPiece[0]+i8(i), targetPiece[1]+i8(i)})
                        }
                        else {
                            if(enemyColor * state.board[targetPiece[0]+i8(i)][targetPiece[1]+i8(i)] > 0) {
                                append(&validTargetMoves, [2]i8{targetPiece[0]+i8(i), targetPiece[1]+i8(i)})
                            }
                            checkSouthEast = false
                        }
                    }
                }
                if(checkSouth) {
                    if(isOnBoard(targetPiece[0] + i8(i), targetPiece[1])) {
                        if(isEmpty(state.board[targetPiece[0]+i8(i)][targetPiece[1]])) {
                            append(&validTargetMoves, [2]i8{targetPiece[0]+i8(i), targetPiece[1]})
                        }
                        else {
                            if(enemyColor * state.board[targetPiece[0]+i8(i)][targetPiece[1]] > 0) {
                                append(&validTargetMoves, [2]i8{targetPiece[0]+i8(i), targetPiece[1]})
                            }
                            checkSouth = false
                        }
                    }
                }
                if(checkSouthWest) {
                    if(isOnBoard(targetPiece[0] + i8(i), targetPiece[1] - i8(i))) {
                        if(isEmpty(state.board[targetPiece[0]+i8(i)][targetPiece[1]-i8(i)])) {
                            append(&validTargetMoves, [2]i8{targetPiece[0]+i8(i), targetPiece[1]-i8(i)})
                        }
                        else {
                            if(enemyColor * state.board[targetPiece[0]+i8(i)][targetPiece[1]-i8(i)] > 0) {
                                append(&validTargetMoves, [2]i8{targetPiece[0]+i8(i), targetPiece[1]-i8(i)})
                            }
                            checkSouthWest = false
                        }
                    }
                }
                if(checkWest) {
                    if(isOnBoard(targetPiece[0], targetPiece[1] - i8(i))) {
                        if(isEmpty(state.board[targetPiece[0]][targetPiece[1]-i8(i)])) {
                            append(&validTargetMoves, [2]i8{targetPiece[0], targetPiece[1]-i8(i)})
                        }
                        else {
                            if(enemyColor * state.board[targetPiece[0]][targetPiece[1]-i8(i)] > 0) {
                                append(&validTargetMoves, [2]i8{targetPiece[0], targetPiece[1]-i8(i)})
                            }
                            checkWest = false
                        }
                    }
                }
                if(checkNorthWest) {
                    if(isOnBoard(targetPiece[0] - i8(i), targetPiece[1] - i8(i))) {
                        if(isEmpty(state.board[targetPiece[0]-i8(i)][targetPiece[1]-i8(i)])) {
                            append(&validTargetMoves, [2]i8{targetPiece[0]-i8(i), targetPiece[1]-i8(i)})
                        }
                        else {
                            if(enemyColor * state.board[targetPiece[0]-i8(i)][targetPiece[1]-i8(i)] > 0) {
                                append(&validTargetMoves, [2]i8{targetPiece[0]-i8(i), targetPiece[1]-i8(i)})
                            }
                            checkNorthWest = false
                        }
                    }
                }
            }
        case BLACK*ROOK:
            fallthrough
        case WHITE*ROOK:
            checkNorth: bool = true
            checkEast: bool = true
            checkSouth: bool = true
            checkWest: bool = true
            for i in 1..=7 {
                if(checkNorth) {
                    if(isOnBoard(targetPiece[0] - i8(i), targetPiece[1])) {
                        if(isEmpty(state.board[targetPiece[0]-i8(i)][targetPiece[1]])) {
                            append(&validTargetMoves, [2]i8{targetPiece[0]-i8(i), targetPiece[1]})
                        }
                        else {
                            if(enemyColor * state.board[targetPiece[0]-i8(i)][targetPiece[1]] > 0) {
                                append(&validTargetMoves, [2]i8{targetPiece[0]-i8(i), targetPiece[1]})
                            }
                            checkNorth = false
                        }
                    }
                }
                if(checkEast) {
                    if(isOnBoard(targetPiece[0], targetPiece[1] + i8(i))) {
                        if(isEmpty(state.board[targetPiece[0]][targetPiece[1]+i8(i)])) {
                            append(&validTargetMoves, [2]i8{targetPiece[0], targetPiece[1]+i8(i)})
                        }
                        else {
                            if(enemyColor * state.board[targetPiece[0]][targetPiece[1]+i8(i)] > 0) {
                                append(&validTargetMoves, [2]i8{targetPiece[0], targetPiece[1]+i8(i)})
                            }
                            checkEast = false
                        }
                    }
                }
                if(checkSouth) {
                    if(isOnBoard(targetPiece[0] + i8(i), targetPiece[1])) {
                        if(isEmpty(state.board[targetPiece[0]+i8(i)][targetPiece[1]])) {
                            append(&validTargetMoves, [2]i8{targetPiece[0]+i8(i), targetPiece[1]})
                        }
                        else {
                            if(enemyColor * state.board[targetPiece[0]+i8(i)][targetPiece[1]] > 0) {
                                append(&validTargetMoves, [2]i8{targetPiece[0]+i8(i), targetPiece[1]})
                            }
                            checkSouth = false
                        }
                    }
                }
                if(checkWest) {
                    if(isOnBoard(targetPiece[0], targetPiece[1] - i8(i))) {
                        if(isEmpty(state.board[targetPiece[0]][targetPiece[1]-i8(i)])) {
                            append(&validTargetMoves, [2]i8{targetPiece[0], targetPiece[1]-i8(i)})
                        }
                        else {
                            if(enemyColor * state.board[targetPiece[0]][targetPiece[1]-i8(i)] > 0) {
                                append(&validTargetMoves, [2]i8{targetPiece[0], targetPiece[1]-i8(i)})
                            }
                            checkWest = false
                        }
                    }
                }
            }
        case BLACK*KNIGHT:
            fallthrough
        case WHITE*KNIGHT:
        knightMoves: [8][2]i8 = {
            {targetPiece[0] + 2, targetPiece[1] + 1},
            {targetPiece[0] + 1, targetPiece[1] + 2},
            {targetPiece[0] - 1, targetPiece[1] + 2},
            {targetPiece[0] - 2, targetPiece[1] + 1},
            {targetPiece[0] + 2, targetPiece[1] - 1},
            {targetPiece[0] + 1, targetPiece[1] - 2},
            {targetPiece[0] - 1, targetPiece[1] - 2},
            {targetPiece[0] - 2, targetPiece[1] - 1},
        }
        for move in knightMoves {
            if(isOnBoard(move[0],move[1]) && enemyColor * state.board[move[0]][move[1]] >= 0) {
                append(&validTargetMoves, move)
            }
        }
        case BLACK*BISHOP:
            fallthrough
        case WHITE*BISHOP:
            checkNorthEast: bool = true
            checkSouthEast: bool = true
            checkSouthWest: bool = true
            checkNorthWest: bool = true
            for i in 1..=7 {
                if(checkNorthEast) {
                    if(isOnBoard(targetPiece[0] - i8(i), targetPiece[1] + i8(i))) {
                        if(isEmpty(state.board[targetPiece[0]-i8(i)][targetPiece[1]+i8(i)])) {
                            append(&validTargetMoves, [2]i8{targetPiece[0]-i8(i), targetPiece[1]+i8(i)})
                        }
                        else {
                            if(enemyColor * state.board[targetPiece[0]-i8(i)][targetPiece[1]+i8(i)] > 0) {
                                append(&validTargetMoves, [2]i8{targetPiece[0]-i8(i), targetPiece[1]+i8(i)})
                            }
                            checkNorthEast = false
                        }
                    }
                }
                if(checkSouthEast) {
                    if(isOnBoard(targetPiece[0] + i8(i), targetPiece[1] + i8(i))) {
                        if(isEmpty(state.board[targetPiece[0]+i8(i)][targetPiece[1]+i8(i)])) {
                            append(&validTargetMoves, [2]i8{targetPiece[0]+i8(i), targetPiece[1]+i8(i)})
                        }
                        else {
                            if(enemyColor * state.board[targetPiece[0]+i8(i)][targetPiece[1]+i8(i)] > 0) {
                                append(&validTargetMoves, [2]i8{targetPiece[0]+i8(i), targetPiece[1]+i8(i)})
                            }
                            checkSouthEast = false
                        }
                    }
                }
                if(checkSouthWest) {
                    if(isOnBoard(targetPiece[0] + i8(i), targetPiece[1] - i8(i))) {
                        if(isEmpty(state.board[targetPiece[0]+i8(i)][targetPiece[1]-i8(i)])) {
                            append(&validTargetMoves, [2]i8{targetPiece[0]+i8(i), targetPiece[1]-i8(i)})
                        }
                        else {
                            if(enemyColor * state.board[targetPiece[0]+i8(i)][targetPiece[1]-i8(i)] > 0) {
                                append(&validTargetMoves, [2]i8{targetPiece[0]+i8(i), targetPiece[1]-i8(i)})
                            }
                            checkSouthWest = false
                        }
                    }
                }
                if(checkNorthWest) {
                    if(isOnBoard(targetPiece[0] - i8(i), targetPiece[1] - i8(i))) {
                        if(isEmpty(state.board[targetPiece[0]-i8(i)][targetPiece[1]-i8(i)])) {
                            append(&validTargetMoves, [2]i8{targetPiece[0]-i8(i), targetPiece[1]-i8(i)})
                        }
                        else {
                            if(enemyColor * state.board[targetPiece[0]-i8(i)][targetPiece[1]-i8(i)] > 0) {
                                append(&validTargetMoves, [2]i8{targetPiece[0]-i8(i), targetPiece[1]-i8(i)})
                            }
                            checkNorthWest = false
                        }
                    }
                }
            }
        case BLACK*PAWN:
            if(isEmpty(state.board[targetPiece[0]+1][targetPiece[1]])) {
                append(&validTargetMoves, [2]i8{targetPiece[0]+1, targetPiece[1]})
            }
            if(isOnBoard(targetPiece[0]+1, targetPiece[1]+1) &&
                state.board[targetPiece[0]+1][targetPiece[1]+1] > 0) {
                append(&validTargetMoves, [2]i8{targetPiece[0]+1, targetPiece[1]+1})
            }
            if(isOnBoard(targetPiece[0]+1, targetPiece[1]-1) &&
                state.board[targetPiece[0]+1][targetPiece[1]-1] > 0) {
                append(&validTargetMoves, [2]i8{targetPiece[0]+1, targetPiece[1]-1})
            }
            if(targetPiece[0] == 1 && isEmpty(state.board[i8(targetPiece[0]+1)][targetPiece[1]]) &&
            isEmpty(state.board[targetPiece[0]+2][targetPiece[1]])) {
                append(&validTargetMoves, [2]i8{targetPiece[0]+2, targetPiece[1]})
            }
            //En passant
            if(targetPiece[0] == 4) {
                //En passant left
                if(targetPiece[1]-1>=0 && state.board[targetPiece[0]][targetPiece[1]-1] == WHITE*PAWN) {
                    substringStart:= len(state.moveList) - 5
                    lastMove, ok:= strings.substring(state.moveList, (substringStart > 0)?substringStart:0, len(state.moveList))
                    lastMove = strings.trim_space(lastMove)

                    //build valid en passant last move
                    fileToChar:= make(map[i8]u8)
                    defer delete(fileToChar)
                    fileToChar[0] = 'a'
                    fileToChar[1] = 'b'
                    fileToChar[2] = 'c'
                    fileToChar[3] = 'd'
                    fileToChar[4] = 'e'
                    fileToChar[5] = 'f'
                    fileToChar[6] = 'g'
                    fileToChar[7] = 'h'
                    validRank:= 8 - targetPiece[0]
                    validEnPassantLastMove:= ""
                    buf: [1]byte
                    validEnPassantLastMove = strings.concatenate({validEnPassantLastMove,
                        strings.clone(string([]u8{fileToChar[targetPiece[1]-1]}))})
                    validEnPassantLastMove = strings.concatenate({validEnPassantLastMove, 
                        strconv.write_int(buf[:], i64(validRank-2), 10)})
                    validEnPassantLastMove = strings.concatenate({validEnPassantLastMove, 
                        strings.clone(string([]u8{fileToChar[targetPiece[1]-1]}))})
                    validEnPassantLastMove = strings.concatenate({validEnPassantLastMove,
                        strconv.write_int(buf[:], i64(validRank), 10)})
                    
                    if(strings.equal_fold(lastMove, validEnPassantLastMove)) {
                        append(&validTargetMoves, [2]i8{targetPiece[0]+1, targetPiece[1]-1})
                    }
                }
                //En passant right
                if(targetPiece[1]+1<8 && state.board[targetPiece[0]][targetPiece[1]+1] == WHITE*PAWN) {
                    substringStart:= len(state.moveList) - 5
                    lastMove, ok:= strings.substring(state.moveList, (substringStart > 0)?substringStart:0, len(state.moveList))
                    lastMove = strings.trim_space(lastMove)

                    //build valid en passant last move
                    fileToChar:= make(map[i8]u8)
                    defer delete(fileToChar)
                    fileToChar[0] = 'a'
                    fileToChar[1] = 'b'
                    fileToChar[2] = 'c'
                    fileToChar[3] = 'd'
                    fileToChar[4] = 'e'
                    fileToChar[5] = 'f'
                    fileToChar[6] = 'g'
                    fileToChar[7] = 'h'
                    validRank:= 8 - targetPiece[0]
                    validEnPassantLastMove:= ""
                    buf: [1]byte
                    validEnPassantLastMove = strings.concatenate({validEnPassantLastMove,
                        strings.clone(string([]u8{fileToChar[targetPiece[1]+1]}))})
                    validEnPassantLastMove = strings.concatenate({validEnPassantLastMove, 
                        strconv.write_int(buf[:], i64(validRank-2), 10)})
                    validEnPassantLastMove = strings.concatenate({validEnPassantLastMove, 
                        strings.clone(string([]u8{fileToChar[targetPiece[1]+1]}))})
                    validEnPassantLastMove = strings.concatenate({validEnPassantLastMove,
                        strconv.write_int(buf[:], i64(validRank), 10)})
                    if(strings.equal_fold(lastMove,validEnPassantLastMove)) {
                        append(&validTargetMoves, [2]i8{i8(targetPiece[0]+1), i8(targetPiece[1]+1)})
                    }
                }
            }
        case WHITE*PAWN:
            if(isEmpty(state.board[i8(targetPiece[0]-1)][targetPiece[1]])) {
                append(&validTargetMoves, [2]i8{targetPiece[0]-1, targetPiece[1]})
            }
            if(isOnBoard(targetPiece[0]-1, targetPiece[1]+1) &&
                state.board[targetPiece[0]-1][targetPiece[1]+1] < 0) {
                append(&validTargetMoves, [2]i8{targetPiece[0]+1, targetPiece[1]+1})
            }
            if(isOnBoard(targetPiece[0]-1, targetPiece[1]-1) && 
            state.board[targetPiece[0]-1][targetPiece[1]-1] < 0) {
                append(&validTargetMoves, [2]i8{targetPiece[0]+1, targetPiece[1]-1})
            }
            if(targetPiece[0] == 6 && isEmpty(state.board[targetPiece[0]-1][targetPiece[1]]) &&
            isEmpty(state.board[targetPiece[0]-2][targetPiece[1]])) {
                append(&validTargetMoves, [2]i8{targetPiece[0]-2, targetPiece[1]})
            }
            //En passant
            if(targetPiece[0] == 3) {
                //En passant left
                if(targetPiece[1]-1>=0 && state.board[targetPiece[0]][targetPiece[1]-1] == BLACK*PAWN) {
                    substringStart:= len(state.moveList) - 5
                    lastMove, ok:= strings.substring(state.moveList, (substringStart > 0)?substringStart:0, len(state.moveList))
                    lastMove = strings.trim_space(lastMove)

                    //build valid en passant last move
                    fileToChar:= make(map[i8]u8)
                    defer delete(fileToChar)
                    fileToChar[0] = 'a'
                    fileToChar[1] = 'b'
                    fileToChar[2] = 'c'
                    fileToChar[3] = 'd'
                    fileToChar[4] = 'e'
                    fileToChar[5] = 'f'
                    fileToChar[6] = 'g'
                    fileToChar[7] = 'h'
                    validRank:= 8 - targetPiece[0]
                    validEnPassantLastMove:= ""
                    buf: [1]byte
                    validEnPassantLastMove = strings.concatenate({validEnPassantLastMove,
                        strings.clone(string([]u8{fileToChar[targetPiece[1]-1]}))})
                    validEnPassantLastMove = strings.concatenate({validEnPassantLastMove, 
                        strconv.write_int(buf[:], i64(validRank+2), 10)})
                    validEnPassantLastMove = strings.concatenate({validEnPassantLastMove, 
                        strings.clone(string([]u8{fileToChar[targetPiece[1]-1]}))})
                    validEnPassantLastMove = strings.concatenate({validEnPassantLastMove,
                        strconv.write_int(buf[:], i64(validRank), 10)})
                    
                    if(strings.equal_fold(lastMove, validEnPassantLastMove)) {
                        append(&validTargetMoves, [2]i8{targetPiece[0]-1, targetPiece[1]-1})
                    }
                }
                //En passant right
                if(targetPiece[1]+1<8 && state.board[targetPiece[0]][targetPiece[1]+1] == BLACK*PAWN) {
                    substringStart:= len(state.moveList) - 5
                    lastMove, ok:= strings.substring(state.moveList, (substringStart > 0)?substringStart:0, len(state.moveList))
                    lastMove = strings.trim_space(lastMove)

                    //build valid en passant last move
                    fileToChar:= make(map[i8]u8)
                    defer delete(fileToChar)
                    fileToChar[0] = 'a'
                    fileToChar[1] = 'b'
                    fileToChar[2] = 'c'
                    fileToChar[3] = 'd'
                    fileToChar[4] = 'e'
                    fileToChar[5] = 'f'
                    fileToChar[6] = 'g'
                    fileToChar[7] = 'h'
                    validRank:= 8 - targetPiece[0]
                    validEnPassantLastMove:= ""
                    buf: [1]byte
                    validEnPassantLastMove = strings.concatenate({validEnPassantLastMove,
                        strings.clone(string([]u8{fileToChar[targetPiece[1]+1]}))})
                    validEnPassantLastMove = strings.concatenate({validEnPassantLastMove, 
                        strconv.write_int(buf[:], i64(validRank+2), 10)})
                    validEnPassantLastMove = strings.concatenate({validEnPassantLastMove, 
                        strings.clone(string([]u8{fileToChar[targetPiece[1]+1]}))})
                    validEnPassantLastMove = strings.concatenate({validEnPassantLastMove,
                        strconv.write_int(buf[:], i64(validRank), 10)})
                    if(strings.equal_fold(lastMove,validEnPassantLastMove)) {
                        append(&validTargetMoves, [2]i8{targetPiece[0]-1, targetPiece[1]+1})
                    }
                }
            }
    }
    return validTargetMoves
}