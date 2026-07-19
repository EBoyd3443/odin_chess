package chess

import "core:fmt"
import "core:strings"
import "core:strconv"

isStalemate :: proc(state: ^Game_State, color: i8) -> bool {
    remainingPieceList:[dynamic][2]i8 = (color == WHITE)?getWhitePieces(state):getBlackPieces(state)

    for piece in remainingPieceList {
        moves:= getValidMoves(state, piece)
        if(len(moves) > 0){
            return false
        }
    }
    return true
}

isCheckMate :: proc(state: ^Game_State, color:i8) -> bool {
    if(len(getValidMoves(state, (color == WHITE)?state.whiteKingPosition:state.blackKingPosition)) > 0) {
        return false
    }
    else {
        remainingPieceList:[dynamic][2]i8 = (color == WHITE)?getWhitePieces(state):getBlackPieces(state)

        for piece in remainingPieceList {
            moves:= getValidMoves(state, piece)
            for move in moves {
                undoMove:= exploreMove(state, move)
                if(isNotAttacked(state, state.whiteKingPosition[0], state.whiteKingPosition[1])) {
                    reverseExplore(state, undoMove)
                    return false
                }
                else {
                    reverseExplore(state, undoMove)
                }
            }
        }
    }
    return true
}

getWhitePieces :: proc(state: ^Game_State) -> [dynamic][2]i8 {
    remainingPieces:= 16-state.whitePiecesCaptured
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
    fmt.println("gameStateChecks.odin(line60): index >= remainingPieces early exit not hit.")
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
    fmt.println("gameStateChecks.odin(line 82): index >= remainingPieces early exit not hit.")
    return result
}

isNotAttacked :: proc(state: ^Game_State, y: i8, x: i8) -> bool {
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
        
        if(target == color * QUEEN || target == color * ROOK) {
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
        
        if(target == color * QUEEN || target == color * ROOK) {
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
        
        if(target == color * QUEEN || target == color * ROOK) {
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
        
        if(target == color * QUEEN || target == color * ROOK) {
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
        
        if(target == color * QUEEN || target == color * BISHOP) {
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
        
        if(target == color * QUEEN || target == color * BISHOP) {
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
        
        if(target == color * QUEEN || target == color * BISHOP) {
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
        
        if(target == color * QUEEN || target == color * BISHOP) {
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
            if(state.board[i[1]][i[0]] == color * KNIGHT) {
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
            if(state.board[i[1]][i[0]] == color * KING) {
                return false
            }
        }
    }
    return true
}

getValidMoves :: proc(state: ^Game_State, targetPiece: [2]i8) -> [dynamic]Basic_Move {
    pieceType : i8 = state.board[targetPiece[0]][targetPiece[1]]
    ownColor:i8 = state.board[targetPiece[0]][targetPiece[1]]>0?WHITE:BLACK
    enemyColor: i8 = state.board[targetPiece[0]][targetPiece[1]]>0?BLACK:WHITE

    validTargetMoves: [dynamic]Basic_Move

    switch(pieceType) {
        case BLACK*KING:
            if(!state.disableBlackQueenSideCastling && 
            isEmpty(state.board[0][1]) && isNotAttacked(state, 0, 1) &&
            isEmpty(state.board[0][2]) && isNotAttacked(state, 0, 2) &&
            isEmpty(state.board[0][3]) && isNotAttacked(state, 0, 3)) {
                newMove : Basic_Move = {
                    moveType = Move_Type.castling,
                    from = targetPiece,
                    to = {0, 2},
                }
                append(&validTargetMoves, newMove)
            }
            if(!state.disableBlackKingSideCastling &&
            isEmpty(state.board[0][5]) && isNotAttacked(state, 0, 5) &&
            isEmpty(state.board[0][6]) && isNotAttacked(state, 0, 6)) {
                newMove : Basic_Move = {
                    moveType = Move_Type.castling,
                    from = targetPiece,
                    to = {0, 6},
                }
                append(&validTargetMoves, newMove)
            }
            for i in -1..=1 {
                for j in -1..=1 {
                    if(isOnBoard(targetPiece[0]+i8(i), targetPiece[1]+i8(j)) &&
                    !containsOwnPiece(ownColor, (state.board[targetPiece[0]+i8(i)][targetPiece[1]+i8(j)]))&&
                    isNotAttacked(state, targetPiece[0]+i8(i), targetPiece[1]+i8(j))) {
                        newMove: Basic_Move = {
                            moveType = isEmpty(state.board[targetPiece[0]+i8(i)][targetPiece[1]+i8(j)])?Move_Type.standard:Move_Type.capture,
                            from = targetPiece,
                            to = {targetPiece[0]+i8(i), targetPiece[1]+i8(j)},
                        }
                        append(&validTargetMoves, newMove)
                    }
                }
            }
        case WHITE*KING:
            if(!state.disableWhiteQueenSideCastling &&
            isEmpty(state.board[7][1]) && isNotAttacked(state, 7, 1) &&
            isEmpty(state.board[7][2]) && isNotAttacked(state, 7, 2) &&
            isEmpty(state.board[7][3]) && isNotAttacked(state, 7, 3)) {
                newMove : Basic_Move = {
                    moveType = Move_Type.castling,
                    from = targetPiece,
                    to = {7, 2},
                }
                append(&validTargetMoves, newMove)
            }
            if(!state.disableWhiteKingSideCastling &&
            isEmpty(state.board[7][5]) && isNotAttacked(state, 7, 5) &&
            isEmpty(state.board[7][6]) && isNotAttacked(state, 7, 6)) {
                newMove : Basic_Move = {
                    moveType = Move_Type.castling,
                    from = targetPiece,
                    to = {7, 6},
                }
                append(&validTargetMoves, newMove)
            }
            for i in -1..=1 {
                for j in -1..=1 {
                    if(isOnBoard(targetPiece[0]+i8(i), targetPiece[1]+i8(j)) &&
                    !containsOwnPiece(ownColor, (state.board[targetPiece[0]+i8(i)][targetPiece[1]+i8(j)]))&&
                    isNotAttacked(state, targetPiece[0]+i8(i), targetPiece[1]+i8(j))) {
                        newMove : Basic_Move = {
                            moveType = isEmpty(state.board[targetPiece[0]+i8(i)][targetPiece[1]+i8(j)])?Move_Type.standard:Move_Type.capture,
                            from = targetPiece,
                            to = {targetPiece[0]+i8(i), targetPiece[1]+i8(j)},
                        }
                        append(&validTargetMoves, newMove)
                    }
                }
            }
        case BLACK*QUEEN:
            fallthrough
        case WHITE*QUEEN:
            checkDirections: [8][2]int = {{-1,-1}, {-1, 0}, {-1, 1},
                                          { 0,-1}, /*QUEEN*/{ 0, 1},
                                          { 1,-1}, { 1, 0}, { 1, 1}}       
            for direction in checkDirections {
                for i in 1..=7 {
                    targetMove: [2]i8 = {targetPiece[0] + i8(i*direction[0]), targetPiece[1] + i8(i*direction[1])}
                    if(isOnBoard(targetMove[0],targetMove[1])) {
                        if(isEmpty(state.board[targetMove[0]][targetMove[1]])) {
                            newMove : Basic_Move = {
                                moveType = Move_Type.standard,
                                from = targetPiece,
                                to = {targetMove[0], targetMove[1]},
                            }
                            append(&validTargetMoves, newMove)
                        }
                        else {
                            if(enemyColor * state.board[targetMove[0]][targetMove[1]] > 0) {
                                newMove : Basic_Move = {
                                    moveType = Move_Type.capture,
                                    from = targetPiece,
                                    to = {targetMove[0], targetMove[1]},
                                }
                                append(&validTargetMoves, newMove)
                            }
                            break
                        }
                    }
                }
            }
        case BLACK*ROOK:
            fallthrough
        case WHITE*ROOK:
            checkDirections:[4][2]int ={        {-1, 0},
                                        { 0, 1}, /*ROOK*/ { 0, 1},
                                                { 1, 0}} 
            for direction in checkDirections {
                for i in 1..=7 {
                    targetMove: [2]i8 = {targetPiece[0] + i8(i*direction[0]), targetPiece[1] + i8(i*direction[1])}
                    if(isOnBoard(targetMove[0],targetMove[1])) {
                        if(isEmpty(state.board[targetMove[0]][targetMove[1]])) {
                            newMove : Basic_Move = {
                                moveType = Move_Type.standard,
                                from = targetPiece,
                                to = {targetMove[0], targetMove[1]},
                            }
                            append(&validTargetMoves, newMove)
                        }
                        else {
                            if(enemyColor * state.board[targetMove[0]][targetMove[1]] > 0) {
                                newMove : Basic_Move = {
                                    moveType = Move_Type.capture,
                                    from = targetPiece,
                                    to = {targetMove[0], targetMove[1]},
                                }
                                append(&validTargetMoves, newMove)
                            }
                            break
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
                newMove : Basic_Move = {
                    moveType = isEmpty(state.board[move[0]][move[1]])?Move_Type.standard:Move_Type.capture,
                    from = targetPiece,
                    to = {move[0],move[1]},
                }
                append(&validTargetMoves, newMove)
            }
        }
        case BLACK*BISHOP:
            fallthrough
        case WHITE*BISHOP:
            checkDirections:[4][2]int ={{-1,-1},          {-1, 1},
                                                /*BISHOP*/          
                                        { 1,-1},          { 1, 1}}
            for direction in checkDirections {
                for i in 1..=7 {
                    targetMove: [2]i8 = {targetPiece[0] + i8(i*direction[0]), targetPiece[1] + i8(i*direction[1])}
                    if(isOnBoard(targetMove[0],targetMove[1])) {
                        if(isEmpty(state.board[targetMove[0]][targetMove[1]])) {
                            newMove : Basic_Move = {
                                moveType = Move_Type.standard,
                                from = targetPiece,
                                to = {targetMove[0], targetMove[1]},
                            }
                            append(&validTargetMoves, newMove)
                        }
                        else {
                            if(enemyColor * state.board[targetMove[0]][targetMove[1]] > 0) {
                                newMove : Basic_Move = {
                                    moveType = Move_Type.capture,
                                    from = targetPiece,
                                    to = {targetMove[0], targetMove[1]},
                                }
                                append(&validTargetMoves, newMove)
                            }
                            break
                        }
                    }
                }
            }
        case BLACK*PAWN:
            if(isEmpty(state.board[targetPiece[0]+1][targetPiece[1]])) {
                newMove : Basic_Move = {
                    moveType = Move_Type.standard,
                    from = targetPiece,
                    to = {targetPiece[0]+1, targetPiece[1]},
                }
                append(&validTargetMoves, newMove)
            }
            if(isOnBoard(targetPiece[0]+1, targetPiece[1]+1) &&
                state.board[targetPiece[0]+1][targetPiece[1]+1] > 0) {
                newMove : Basic_Move = {
                    moveType = Move_Type.capture,
                    from = targetPiece,
                    to = {targetPiece[0]+1, targetPiece[1]+1},
                }
                append(&validTargetMoves, newMove)
            }
            if(isOnBoard(targetPiece[0]+1, targetPiece[1]-1) &&
                state.board[targetPiece[0]+1][targetPiece[1]-1] > 0) {
                newMove : Basic_Move = {
                    moveType = Move_Type.capture,
                    from = targetPiece,
                    to = {targetPiece[0]+1, targetPiece[1]-1},
                }
                append(&validTargetMoves, newMove)
            }
            if(targetPiece[0] == 1 && isEmpty(state.board[i8(targetPiece[0]+1)][targetPiece[1]]) &&
            isEmpty(state.board[targetPiece[0]+2][targetPiece[1]])) {
                newMove : Basic_Move = {
                    moveType = Move_Type.standard,
                    from = targetPiece,
                    to = {targetPiece[0]+2, targetPiece[1]},
                }
                append(&validTargetMoves, newMove)
            }
            //En passant
            if(targetPiece[0] == 4) {
                //En passant left
                if(targetPiece[1]-1>=0 && state.board[targetPiece[0]][targetPiece[1]-1] == WHITE*PAWN) {
                    substringStart:= len(state.moveList) - 5
                    lastMove, ok:= strings.substring(state.moveList, (substringStart > 0)?substringStart:0, len(state.moveList))
                    lastMove = strings.trim_space(lastMove)

                    //build valid en passant last move
                    validRank:= 8 - targetPiece[0]
                    validEnPassantLastMove:= ""
                    buf: [1]byte
                    validEnPassantLastMove = strings.concatenate({validEnPassantLastMove,
                        strings.clone(string([]u8{fileToChar(targetPiece[1]-1)}))})
                    validEnPassantLastMove = strings.concatenate({validEnPassantLastMove, 
                        strconv.write_int(buf[:], i64(validRank-2), 10)})
                    validEnPassantLastMove = strings.concatenate({validEnPassantLastMove, 
                        strings.clone(string([]u8{fileToChar(targetPiece[1]-1)}))})
                    validEnPassantLastMove = strings.concatenate({validEnPassantLastMove,
                        strconv.write_int(buf[:], i64(validRank), 10)})
                    
                    if(strings.equal_fold(lastMove, validEnPassantLastMove)) {
                        newMove : Basic_Move = {
                            moveType = Move_Type.enPassant,
                            from = targetPiece,
                            to = {targetPiece[0]+1, targetPiece[1]-1},
                        }
                        append(&validTargetMoves, newMove)
                    }
                }
                //En passant right
                if(targetPiece[1]+1<8 && state.board[targetPiece[0]][targetPiece[1]+1] == WHITE*PAWN) {
                    substringStart:= len(state.moveList) - 5
                    lastMove, ok:= strings.substring(state.moveList, (substringStart > 0)?substringStart:0, len(state.moveList))
                    lastMove = strings.trim_space(lastMove)

                    //build valid en passant last move
                    validRank:= 8 - targetPiece[0]
                    validEnPassantLastMove:= ""
                    buf: [1]byte
                    validEnPassantLastMove = strings.concatenate({validEnPassantLastMove,
                        strings.clone(string([]u8{fileToChar(targetPiece[1]+1)}))})
                    validEnPassantLastMove = strings.concatenate({validEnPassantLastMove, 
                        strconv.write_int(buf[:], i64(validRank-2), 10)})
                    validEnPassantLastMove = strings.concatenate({validEnPassantLastMove, 
                        strings.clone(string([]u8{fileToChar(targetPiece[1]+1)}))})
                    validEnPassantLastMove = strings.concatenate({validEnPassantLastMove,
                        strconv.write_int(buf[:], i64(validRank), 10)})
                    if(strings.equal_fold(lastMove,validEnPassantLastMove)) {
                        newMove : Basic_Move = {
                            moveType = Move_Type.enPassant,
                            from = targetPiece,
                            to = {targetPiece[0]+1, targetPiece[1]+1},
                        }
                        append(&validTargetMoves, newMove)
                    }
                }
            }
        case WHITE*PAWN:
            if(isEmpty(state.board[i8(targetPiece[0]-1)][targetPiece[1]])) {
                newMove : Basic_Move = {
                    moveType = Move_Type.standard,
                    from = targetPiece,
                    to = {targetPiece[0]-1, targetPiece[1]},
                }
                append(&validTargetMoves, newMove)
            }
            if(isOnBoard(targetPiece[0]-1, targetPiece[1]+1) &&
                state.board[targetPiece[0]-1][targetPiece[1]+1] < 0) {
                newMove : Basic_Move = {
                    moveType = Move_Type.capture,
                    from = targetPiece,
                    to = {targetPiece[0]-1, targetPiece[1]+1},
                }
                append(&validTargetMoves, newMove)
            }
            if(isOnBoard(targetPiece[0]-1, targetPiece[1]-1) && 
            state.board[targetPiece[0]-1][targetPiece[1]-1] < 0) {
                newMove : Basic_Move = {
                    moveType = Move_Type.capture,
                    from = targetPiece,
                    to = {targetPiece[0]-1, targetPiece[1]-1},
                }
                append(&validTargetMoves, newMove)
            }
            if(targetPiece[0] == 6 && isEmpty(state.board[targetPiece[0]-1][targetPiece[1]]) &&
            isEmpty(state.board[targetPiece[0]-2][targetPiece[1]])) {
                newMove : Basic_Move = {
                    moveType = Move_Type.standard,
                    from = targetPiece,
                    to = {targetPiece[0]-2, targetPiece[1]},
                }
                append(&validTargetMoves, newMove)
            }
            //En passant
            if(targetPiece[0] == 3) {
                //En passant left
                if(targetPiece[1]-1>=0 && state.board[targetPiece[0]][targetPiece[1]-1] == BLACK*PAWN) {
                    substringStart:= len(state.moveList) - 5
                    lastMove, ok:= strings.substring(state.moveList, (substringStart > 0)?substringStart:0, len(state.moveList))
                    lastMove = strings.trim_space(lastMove)

                    //build valid en passant last move
                    validRank:= 8 - targetPiece[0]
                    validEnPassantLastMove:= ""
                    buf: [1]byte
                    validEnPassantLastMove = strings.concatenate({validEnPassantLastMove,
                        strings.clone(string([]u8{fileToChar(targetPiece[1]-1)}))})
                    validEnPassantLastMove = strings.concatenate({validEnPassantLastMove, 
                        strconv.write_int(buf[:], i64(validRank+2), 10)})
                    validEnPassantLastMove = strings.concatenate({validEnPassantLastMove, 
                        strings.clone(string([]u8{fileToChar(targetPiece[1]-1)}))})
                    validEnPassantLastMove = strings.concatenate({validEnPassantLastMove,
                        strconv.write_int(buf[:], i64(validRank), 10)})
                    
                    if(strings.equal_fold(lastMove, validEnPassantLastMove)) {
                        newMove : Basic_Move = {
                            moveType = Move_Type.enPassant,
                            from = targetPiece,
                            to = {targetPiece[0]-1, targetPiece[1]-1},
                        }
                        append(&validTargetMoves, newMove)
                    }
                }
                //En passant right
                if(targetPiece[1]+1<8 && state.board[targetPiece[0]][targetPiece[1]+1] == BLACK*PAWN) {
                    substringStart:= len(state.moveList) - 5
                    lastMove, ok:= strings.substring(state.moveList, (substringStart > 0)?substringStart:0, len(state.moveList))
                    lastMove = strings.trim_space(lastMove)

                    //build valid en passant last move
                    validRank:= 8 - targetPiece[0]
                    validEnPassantLastMove:= ""
                    buf: [1]byte
                    validEnPassantLastMove = strings.concatenate({validEnPassantLastMove,
                        strings.clone(string([]u8{fileToChar(targetPiece[1]+1)}))})
                    validEnPassantLastMove = strings.concatenate({validEnPassantLastMove, 
                        strconv.write_int(buf[:], i64(validRank+2), 10)})
                    validEnPassantLastMove = strings.concatenate({validEnPassantLastMove, 
                        strings.clone(string([]u8{fileToChar(targetPiece[1]+1)}))})
                    validEnPassantLastMove = strings.concatenate({validEnPassantLastMove,
                        strconv.write_int(buf[:], i64(validRank), 10)})
                    if(strings.equal_fold(lastMove,validEnPassantLastMove)) {
                        newMove : Basic_Move = {
                            moveType = Move_Type.enPassant,
                            from = targetPiece,
                            to = {targetPiece[0]-1, targetPiece[1]+1},
                        }
                        append(&validTargetMoves, newMove)
                    }
                }
            }
    }

    //old notes:
    //check for pin to king
    //find piece pinning
    //if move list contains piece pinning, that is only return value

    //new notes: simulate moves, remove moves that put king in check.
    // To Do: add pawn promotions to move list if moving to ends
    // convert move [2]i8 to new Basic_Move type  (DONE)

    return validTargetMoves
}

isOnBoard :: proc(x: i8, y: i8) -> bool {
    return x >= 0 && x < 8 && y >= 0 && y < 8
}

isEmpty :: proc(target: i8) -> bool {
    return target == 0
}

containsOwnPiece :: proc(ownColor: i8, target: i8) -> bool {
    return target * ownColor > 0
}