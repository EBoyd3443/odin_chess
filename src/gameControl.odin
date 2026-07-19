package chess

import "core:fmt"

executeMove :: proc(state: ^Game_State, move: Basic_Move) {
    // Handle disable castling
    if(!state.disableBlackKingSideCastling && !state.disableBlackQueenSideCastling && move.from == {0, 4}) {
        state.disableBlackKingSideCastling = true
        state.disableBlackQueenSideCastling = true
    }
    if(!state.disableWhiteKingSideCastling && !state.disableWhiteQueenSideCastling && move.from == {7,4}) {
        state.disableWhiteKingSideCastling = true
        state.disableWhiteQueenSideCastling = true
    }
    if(!state.disableBlackKingSideCastling && (move.from == {0,7} || move.to =={0,7})) {
        state.disableBlackKingSideCastling = true
    }
    if(!state.disableBlackQueenSideCastling && (move.from == {0,0} || move.to =={0,0})) {
        state.disableBlackQueenSideCastling = true
    }
    if(!state.disableWhiteKingSideCastling && (move.from == {7,7} || move.to =={7,7})) {
        state.disableWhiteKingSideCastling = true
    }
    if(!state.disableWhiteQueenSideCastling && (move.from == {7,0} || move.to =={7,0})) {
        state.disableWhiteQueenSideCastling = true
    }    
    
    // En passant scoring and cleanup
    if(state.board[move.from[0]][move.from[1]] == BLACK*PAWN && move.from[0] == 4 && move.from[1] != move.to[1] &&
    state.board[move.to[0]][move.to[1]] == 0) {
        state.whitePiecesCaptured += 1
        state.board[move.from[0]][move.to[1]] = 0
    }
    if(state.board[move.from[0]][move.from[1]] == WHITE*PAWN && move.from[0] == 3 && move.from[1] != move.to[1] &&
    state.board[move.to[0]][move.to[1]] == 0) {
        state.blackPiecesCaptured += 1
        state.board[move.from[0]][move.to[1]] = 0
    }

    // Standard move scoring
    if(state.whiteToPlay) {
        if(state.board[move.to[0]][move.to[1]] < 0) {
            state.blackPiecesCaptured += 1
        }
    }
    else {
        if(state.board[move.to[0]][move.to[1]] > 0) {
            state.whitePiecesCaptured += 1
        }
    }

    // Standard move
    currentPiece := state.board[move.from[0]][move.from[1]]
    state.board[move.from[0]][move.from[1]] = 0
    state.board[move.to[0]][move.to[1]] = currentPiece

    if(currentPiece == WHITE*KING) {
        state.whiteKingPosition = {move.to[0], move.to[1]}
    }
    if(currentPiece == BLACK*KING) {
        state.blackKingPosition = {move.to[0], move.to[1]}
    }
    
    // Rook castling piece movement
    if(move.from == {0,4} && move.to == {0,2} && state.board[0][2] == BLACK*KING) {
        state.board[0][0] = 0
        state.board[0][3] = BLACK*ROOK
    }
    if(move.from == {0,4} && move.to == {0,6} && state.board[0][6] == BLACK*KING) {
        state.board[0][7] = 0
        state.board[0][5] = BLACK*ROOK
    }
    if(move.from == {7,4} && move.to == {7,2} && state.board[7][2] == WHITE*KING) {
        state.board[7][0] = 0
        state.board[7][3] = WHITE*ROOK
    }
    if(move.from == {7,4} && move.to == {7,6} && state.board[7][6] == WHITE*KING) {
        state.board[7][7] = 0
        state.board[7][5] = WHITE*ROOK
    }

    promotePawn(state, move)

    // Update who's turn it is.
    state.whiteToPlay = (state.whiteToPlay)?false:true
}

exploreMove :: proc(state: ^Game_State, move: Basic_Move) -> Reversible_Move {
    result: Reversible_Move = {
        basicMove = move,

        movedPiece = state.board[move.from[0]][move.from[1]],
        capturedPiece = state.board[move.to[0]][move.to[1]],

        whitePiecesCaptured = state.whitePiecesCaptured,
        blackPiecesCaptured = state.blackPiecesCaptured,
        disableWhiteKingSideCastling = state.disableWhiteKingSideCastling,
        disableWhiteQueenSideCastling = state.disableWhiteQueenSideCastling,
        disableBlackKingSideCastling = state.disableBlackKingSideCastling,
        disableBlackQueenSideCastling = state.disableBlackQueenSideCastling,
    }

    // Handle disable castling
    if(!state.disableBlackKingSideCastling && !state.disableBlackQueenSideCastling && move.from == {0, 4}) {
        state.disableBlackKingSideCastling = true
        state.disableBlackQueenSideCastling = true
    }
    if(!state.disableWhiteKingSideCastling && !state.disableWhiteQueenSideCastling && move.from == {7,4}) {
        state.disableWhiteKingSideCastling = true
        state.disableWhiteQueenSideCastling = true
    }
    if(!state.disableBlackKingSideCastling && (move.from == {0,7} || move.to =={0,7})) {
        state.disableBlackKingSideCastling = true
    }
    if(!state.disableBlackQueenSideCastling && (move.from == {0,0} || move.to =={0,0})) {
        state.disableBlackQueenSideCastling = true
    }
    if(!state.disableWhiteKingSideCastling && (move.from == {7,7} || move.to =={7,7})) {
        state.disableWhiteKingSideCastling = true
    }
    if(!state.disableWhiteQueenSideCastling && (move.from == {7,0} || move.to =={7,0})) {
        state.disableWhiteQueenSideCastling = true
    }    
    
    // En passant scoring and cleanup
    if(state.board[move.from[0]][move.from[1]] == BLACK*PAWN && move.from[0] == 4 && move.from[1] != move.to[1] &&
    state.board[move.to[0]][move.to[1]] == 0) {
        result.basicMove.moveType = Move_Type.enPassant
        result.capturedPiece = state.board[move.from[0]][move.to[1]]
        result.enPassantCaptureSquare = {move.from[0], move.to[1]}
        state.whitePiecesCaptured += 1
        state.board[move.from[0]][move.to[1]] = 0
    }
    if(state.board[move.from[0]][move.from[1]] == WHITE*PAWN && move.from[0] == 3 && move.from[1] != move.to[1] &&
    state.board[move.to[0]][move.to[1]] == 0) {
        result.basicMove.moveType = Move_Type.enPassant
        result.capturedPiece = state.board[move.from[0]][move.to[1]]
        result.enPassantCaptureSquare = {move.from[0], move.to[1]}
        state.blackPiecesCaptured += 1
        state.board[move.from[0]][move.to[1]] = 0
    }

    // Standard move scoring
    if(state.whiteToPlay) {
        if(state.board[move.to[0]][move.to[1]] < 0) {
            state.blackPiecesCaptured += 1
        }
    }
    else {
        if(state.board[move.to[0]][move.to[1]] > 0) {
            state.whitePiecesCaptured += 1
        }
    }

    // Standard move
    currentPiece := state.board[move.from[0]][move.from[1]]
    state.board[move.from[0]][move.from[1]] = 0
    state.board[move.to[0]][move.to[1]] = currentPiece

    if(currentPiece == WHITE*KING) {
        state.whiteKingPosition = {move.to[0], move.to[1]}
    }
    if(currentPiece == BLACK*KING) {
        state.blackKingPosition = {move.to[0], move.to[1]}
    }
    
    // Rook castling piece movement
    if(move.from == {0,4} && move.to == {0,2} && state.board[0][2] == BLACK*KING) {
        result.basicMove.moveType = Move_Type.castling
        result.castlingRook = BLACK*ROOK
        result.castlingRookSquares = {{0,0},{0,3}}
        state.board[0][0] = 0
        state.board[0][3] = BLACK*ROOK
    }
    if(move.from == {0,4} && move.to == {0,6} && state.board[0][6] == BLACK*KING) {
        result.basicMove.moveType = Move_Type.castling
        result.castlingRook = BLACK*ROOK
        result.castlingRookSquares = {{0,7},{0,5}}
        state.board[0][7] = 0
        state.board[0][5] = BLACK*ROOK
    }
    if(move.from == {7,4} && move.to == {7,2} && state.board[7][2] == WHITE*KING) {
        result.basicMove.moveType = Move_Type.castling
        result.castlingRook = WHITE*ROOK
        result.castlingRookSquares = {{7,0},{7,3}}
        state.board[7][0] = 0
        state.board[7][3] = WHITE*ROOK
    }
    if(move.from == {7,4} && move.to == {7,6} && state.board[7][6] == WHITE*KING) {
        result.basicMove.moveType = Move_Type.castling
        result.castlingRook = WHITE*ROOK
        result.castlingRookSquares = {{7,7},{7,5}}
        state.board[7][7] = 0
        state.board[7][5] = WHITE*ROOK
    }

    promotePawn(state, move)

    // Update who's turn it is.
    state.whiteToPlay = !state.whiteToPlay

    return result
}

reverseExplore :: proc(state: ^Game_State, move: Reversible_Move) {
    switch move.basicMove.moveType {
        case Move_Type.enPassant:
            state.board[move.enPassantCaptureSquare[0]][move.enPassantCaptureSquare[1]] = move.capturedPiece
            state.board[move.basicMove.to[0]][move.basicMove.to[1]] = 0
        case Move_Type.castling:
            state.board[move.castlingRookSquares[0][0]][move.castlingRookSquares[0][1]] = move.castlingRook
            state.board[move.castlingRookSquares[1][0]][move.castlingRookSquares[1][1]] = 0
            state.board[move.basicMove.to[0]][move.basicMove.to[1]] = 0
        case Move_Type.capture:
            state.board[move.basicMove.to[0]][move.basicMove.to[1]] = move.capturedPiece
        case Move_Type.standard:
            state.board[move.basicMove.to[0]][move.basicMove.to[1]] = 0
    }
    state.board[move.basicMove.from[0]][move.basicMove.from[1]] = move.movedPiece
    state.whitePiecesCaptured = move.whitePiecesCaptured
    state.blackPiecesCaptured = move.blackPiecesCaptured
    state.disableWhiteKingSideCastling = move.disableWhiteKingSideCastling
    state.disableWhiteQueenSideCastling = move.disableWhiteQueenSideCastling
    state.disableBlackKingSideCastling = move.disableBlackKingSideCastling
    state.disableBlackQueenSideCastling = move.disableBlackQueenSideCastling
    state.whiteToPlay = !state.whiteToPlay
}

promotePawn :: proc(state: ^Game_State, move: Basic_Move) {
    if(move.piecePromotion != 0) {
        state.board[move.to[0]][move.to[1]] = move.piecePromotion
    }
}
