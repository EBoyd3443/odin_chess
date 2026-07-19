package chess

import "core:sync"
import "core:thread"

WHITE: i8 = 1
BLACK: i8 = -1

PAWN: i8 = 1
BISHOP: i8 = 2
KNIGHT: i8 = 3
ROOK: i8 = 4
QUEEN: i8 = 5
KING: i8 = 6

Shared_State :: struct {
    mutex: sync.Mutex,
    gameState: Game_State,
}

Game_State :: struct {
    board: [8][8]i8,
    whiteToPlay: bool,
    whitePiecesCaptured: i8,
    blackPiecesCaptured: i8,
    whiteKingPosition: [2]i8,
    blackKingPosition: [2]i8,
    disableWhiteKingSideCastling: bool,
    disableWhiteQueenSideCastling: bool,
    disableBlackKingSideCastling: bool,
    disableBlackQueenSideCastling: bool,
    moveList: string,
}

Move_Type :: enum {
    standard,
    capture,
    enPassant,
    castling,
}

Basic_Move :: struct {
    moveType: Move_Type,
    from: [2]i8,
    to: [2]i8,
    piecePromotion: i8,
}

Reversible_Move :: struct {
    basicMove: Basic_Move,

    movedPiece: i8,
    capturedPiece: i8,

    castlingRook: i8,
    castlingRookSquares: [2][2]i8,
    enPassantCaptureSquare: [2]i8,
    whitePiecesCaptured: i8,
    blackPiecesCaptured: i8,
    disableWhiteKingSideCastling: bool,
    disableWhiteQueenSideCastling: bool,
    disableBlackKingSideCastling: bool,
    disableBlackQueenSideCastling: bool,
}

main :: proc() {
    //color: (-) => black, (+) => white
    //pieces: 1 => pawn, 2 => bishop, 3 => knight, 4 => rook, 5 => queen, 6 => king
    state := Shared_State {
        gameState = {
            board ={
                { BLACK*ROOK, BLACK*KNIGHT, BLACK*BISHOP, BLACK*QUEEN, BLACK*KING, BLACK*BISHOP, BLACK*KNIGHT, BLACK*ROOK},
                { BLACK*PAWN, BLACK*PAWN,   BLACK*PAWN,   BLACK*PAWN,  BLACK*PAWN, BLACK*PAWN,   BLACK*PAWN,   BLACK*PAWN},
                { 0,          0,            0,            0,           0,          0,            0,            0         },
                { 0,          0,            0,            0,           0,          0,            0,            0         },
                { 0,          0,            0,            0,           0,          0,            0,            0         },
                { 0,          0,            0,            0,           0,          0,            0,            0         },
                { WHITE*PAWN, WHITE*PAWN,   WHITE*PAWN,   WHITE*PAWN,  WHITE*PAWN, WHITE*PAWN,   WHITE*PAWN,   WHITE*PAWN},
                { WHITE*ROOK, WHITE*KNIGHT, WHITE*BISHOP, WHITE*QUEEN, WHITE*KING, WHITE*BISHOP, WHITE*KNIGHT, WHITE*ROOK},
            },
            whiteToPlay = true,
            whitePiecesCaptured = 0,
            blackPiecesCaptured = 0,
            whiteKingPosition = {7,4},
            blackKingPosition = {0,4},
        }
    }
   
    t := thread.create_and_start_with_poly_data(
        &state,
        inputThread,
    )

    rlBoard(state.gameState.board)
}