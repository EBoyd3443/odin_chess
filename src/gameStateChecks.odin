package chess

import "core:fmt"
import "core:strings"
import "core:strconv"

isStalemate :: proc(state: ^Game_State, color: i8) -> bool {
    remainingPieceList:[dynamic][2]i8 = (color == WHITE)?getWhitePieces(state):getBlackPieces(state)
    
    for piece in remainingPieceList {
        moves:= getValidMoves(state, piece)
        defer delete(moves)
        if(len(moves) > 0){
            return false
        }
    }
    return true
}

isCheckmate :: proc(state: ^Game_State, color:i8) -> bool {
    kingPosition:= (color == WHITE)?state.whiteKingPosition:state.blackKingPosition
    if(isNotAttacked(state, kingPosition[0], kingPosition[1], (color==WHITE)?BLACK:WHITE)) {
        return false
    }
    validKingMoves:= getValidMoves(state, kingPosition)
    defer delete(validKingMoves)
    if(len(validKingMoves) > 0) {
        return false
    }
    else {
        remainingPieceList:[dynamic][2]i8 = (color == WHITE)?getWhitePieces(state):getBlackPieces(state)
        for piece in remainingPieceList {
            moves:= getValidMoves(state, piece)
            for move in moves {
                undoMove:= exploreMove(state, move)
                kingPosition = (color == WHITE)?state.whiteKingPosition:state.blackKingPosition
                if(isNotAttacked(state, kingPosition[0], kingPosition[1], (color==WHITE)?BLACK:WHITE)) {
                    reverseExplore(state, undoMove)
                    return false
                }
                else {
                    reverseExplore(state, undoMove)
                }
            }
            delete(moves)
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
    // Lines past here should never run in real game. Late exit fine for tests.
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
    // Lines past here should never run in real game. Late exit fine for tests.
    return result
}

isNotAttacked :: proc(state: ^Game_State, y: i8, x: i8, assignAttacker: i8 = 0) -> bool {
    attackingColor:i8
    if(assignAttacker == 0) {
        attackingColor = (state.whiteToPlay)? -1: 1
    }
    else {
        attackingColor = assignAttacker
    }
    if(isOnBoard(y + attackingColor, x + 1) && state.board[y+attackingColor][x+1] == attackingColor * PAWN) {
        return false
    }
    if(isOnBoard(y + attackingColor, x - 1) && state.board[y+attackingColor][x-1] == attackingColor * PAWN) {
        return false
    }
    //rook (and half queen)
    //right
    for i:i8=x+1; i<8; i+=1 {
        target: i8 = state.board[y][i]
        
        if(target == attackingColor * QUEEN || target == attackingColor * ROOK) {
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
        
        if(target == attackingColor * QUEEN || target == attackingColor * ROOK) {
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
        
        if(target == attackingColor * QUEEN || target == attackingColor * ROOK) {
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
        
        if(target == attackingColor * QUEEN || target == attackingColor * ROOK) {
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
        
        if(target == attackingColor * QUEEN || target == attackingColor * BISHOP) {
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
        
        if(target == attackingColor * QUEEN || target == attackingColor * BISHOP) {
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
        
        if(target == attackingColor * QUEEN || target == attackingColor * BISHOP) {
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
        
        if(target == attackingColor * QUEEN || target == attackingColor * BISHOP) {
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
            if(state.board[i[1]][i[0]] == attackingColor * KNIGHT) {
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
            if(state.board[i[1]][i[0]] == attackingColor * KING) {
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
                if(newMove.to[0] < 7) {
                    append(&validTargetMoves, newMove)
                }
                else {
                    newMove.piecePromotion = BLACK*BISHOP
                    append(&validTargetMoves, newMove)
                    newMove.piecePromotion = BLACK*KNIGHT
                    append(&validTargetMoves, newMove)
                    newMove.piecePromotion = BLACK*ROOK
                    append(&validTargetMoves, newMove)
                    newMove.piecePromotion = BLACK*QUEEN
                    append(&validTargetMoves, newMove)
                }
            }
            if(isOnBoard(targetPiece[0]+1, targetPiece[1]+1) &&
                state.board[targetPiece[0]+1][targetPiece[1]+1] > 0) {
                newMove : Basic_Move = {
                    moveType = Move_Type.capture,
                    from = targetPiece,
                    to = {targetPiece[0]+1, targetPiece[1]+1},
                }
                if(newMove.to[0] < 7) {
                    append(&validTargetMoves, newMove)
                }
                else {
                    newMove.piecePromotion = BLACK*BISHOP
                    append(&validTargetMoves, newMove)
                    newMove.piecePromotion = BLACK*KNIGHT
                    append(&validTargetMoves, newMove)
                    newMove.piecePromotion = BLACK*ROOK
                    append(&validTargetMoves, newMove)
                    newMove.piecePromotion = BLACK*QUEEN
                    append(&validTargetMoves, newMove)
                }
            }
            if(isOnBoard(targetPiece[0]+1, targetPiece[1]-1) &&
                state.board[targetPiece[0]+1][targetPiece[1]-1] > 0) {
                newMove : Basic_Move = {
                    moveType = Move_Type.capture,
                    from = targetPiece,
                    to = {targetPiece[0]+1, targetPiece[1]-1},
                }
                if(newMove.to[0] < 7) {
                    append(&validTargetMoves, newMove)
                }
                else {
                    newMove.piecePromotion = BLACK*BISHOP
                    append(&validTargetMoves, newMove)
                    newMove.piecePromotion = BLACK*KNIGHT
                    append(&validTargetMoves, newMove)
                    newMove.piecePromotion = BLACK*ROOK
                    append(&validTargetMoves, newMove)
                    newMove.piecePromotion = BLACK*QUEEN
                    append(&validTargetMoves, newMove)
                }
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
                if(newMove.to[0] > 0) {
                    append(&validTargetMoves, newMove)
                }
                else {
                    newMove.piecePromotion = WHITE*BISHOP
                    append(&validTargetMoves, newMove)
                    newMove.piecePromotion = WHITE*KNIGHT
                    append(&validTargetMoves, newMove)
                    newMove.piecePromotion = WHITE*ROOK
                    append(&validTargetMoves, newMove)
                    newMove.piecePromotion = WHITE*QUEEN
                    append(&validTargetMoves, newMove)
                }
            }
            if(isOnBoard(targetPiece[0]-1, targetPiece[1]+1) &&
                state.board[targetPiece[0]-1][targetPiece[1]+1] < 0) {
                newMove : Basic_Move = {
                    moveType = Move_Type.capture,
                    from = targetPiece,
                    to = {targetPiece[0]-1, targetPiece[1]+1},
                }
                if(newMove.to[0] > 0) {
                    append(&validTargetMoves, newMove)
                }
                else {
                    newMove.piecePromotion = WHITE*BISHOP
                    append(&validTargetMoves, newMove)
                    newMove.piecePromotion = WHITE*KNIGHT
                    append(&validTargetMoves, newMove)
                    newMove.piecePromotion = WHITE*ROOK
                    append(&validTargetMoves, newMove)
                    newMove.piecePromotion = WHITE*QUEEN
                    append(&validTargetMoves, newMove)
                }
            }
            if(isOnBoard(targetPiece[0]-1, targetPiece[1]-1) && 
            state.board[targetPiece[0]-1][targetPiece[1]-1] < 0) {
                newMove : Basic_Move = {
                    moveType = Move_Type.capture,
                    from = targetPiece,
                    to = {targetPiece[0]-1, targetPiece[1]-1},
                }
                if(newMove.to[0] > 0) {
                    append(&validTargetMoves, newMove)
                }
                else {
                    newMove.piecePromotion = WHITE*BISHOP
                    append(&validTargetMoves, newMove)
                    newMove.piecePromotion = WHITE*KNIGHT
                    append(&validTargetMoves, newMove)
                    newMove.piecePromotion = WHITE*ROOK
                    append(&validTargetMoves, newMove)
                    newMove.piecePromotion = WHITE*QUEEN
                    append(&validTargetMoves, newMove)
                }
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
    
    // Simulate moves, remove moves that put king in check.
    removalList: [dynamic]int
    for i:=0; i<len(validTargetMoves); i+=1 {
        undoMove:= exploreMove(state, validTargetMoves[i])
        kingPosition:=(ownColor==WHITE)?state.whiteKingPosition:state.blackKingPosition
        putKingInCheck:= !isNotAttacked(state, kingPosition[0],kingPosition[1], enemyColor)
        if(putKingInCheck) {
            append(&removalList, i)
        }
        reverseExplore(state, undoMove)
    }
    for i:=len(removalList)-1; i >= 0; i -= 1 {
        ordered_remove(&validTargetMoves, removalList[i])
    }
    delete(removalList)
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