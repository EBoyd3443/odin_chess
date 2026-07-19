package tests

import "core:testing"
import "core:fmt"

@require import chess "../src"

// Checkmate examples pulled from wikipedia

@(test)
isCheckmate_testCase1::proc(t: ^testing.T) {
    testState : chess.Game_State = {    
        board = {
            { BLACK*ROOK,   BLACK*KNIGHT, BLACK*BISHOP, 0,           BLACK*KING, BLACK*BISHOP, BLACK*KNIGHT, BLACK*ROOK },
            { BLACK*PAWN,   BLACK*PAWN,   BLACK*PAWN,   BLACK*PAWN,  0,          BLACK*PAWN,   BLACK*PAWN,   BLACK*PAWN },
            { 0,            0,            0,            0,           0,          0,            0,            0          },
            { 0,            0,            0,            0,           BLACK*PAWN, 0,            0,            0          },
            { 0,            0,            0,            0,           0,          0,            WHITE*PAWN,   BLACK*QUEEN},
            { 0,            0,            0,            0,           0,          WHITE*PAWN,   0,            0          },
            { WHITE*PAWN,   WHITE*PAWN,   WHITE*PAWN,   WHITE*PAWN,  WHITE*PAWN, 0,            0,            WHITE*PAWN },
            { WHITE*ROOK,   WHITE*KNIGHT, WHITE*BISHOP, WHITE*QUEEN, WHITE*KING, WHITE*BISHOP, WHITE*KNIGHT, WHITE*ROOK },
        },
        whiteToPlay = true,
        whitePiecesCaptured = 0,
        blackPiecesCaptured = 0,
        disableBlackKingSideCastling = false,
        disableBlackQueenSideCastling = false,
        disableWhiteKingSideCastling = false,
        disableWhiteQueenSideCastling = false,
        whiteKingPosition = {7,4},
        blackKingPosition = {0,4},
    }

    testing.expect(t, chess.isCheckmate(&testState, WHITE), "isCheckmate test case 1 failed.")
}

@(test)
isCheckmate_testCase2::proc(t: ^testing.T) {
    testState : chess.Game_State = {    
        board = {
            { 0,            WHITE*QUEEN,  0,            0,            0,           0,            0,            0           },
            { 0,            0,            0,            0,            0,           BLACK*PAWN,   BLACK*KING,   0           },
            { 0,            0,            BLACK*PAWN,   0,            0,           0,            BLACK*PAWN,   0           },
            { 0,            BLACK*PAWN,   0,            0,            WHITE*KNIGHT,0,            0,            BLACK*PAWN  },
            { 0,            BLACK*BISHOP, 0,            0,            0,           0,            0,            WHITE*PAWN  },
            { 0,            BLACK*BISHOP, BLACK*KNIGHT, 0,            0,           0,            0,            0           },
            { 0,            0,            BLACK*ROOK,   0,            0,           0,            WHITE*PAWN,   0           },
            { 0,            0,            WHITE*KING,   0,            0,           0,            0,            0           },
        },
        whiteToPlay = false,
        whitePiecesCaptured = 0,
        blackPiecesCaptured = 0,
        disableBlackKingSideCastling = true,
        disableBlackQueenSideCastling = true,
        disableWhiteKingSideCastling = true,
        disableWhiteQueenSideCastling = true,
        whiteKingPosition = {7,2},
        blackKingPosition = {1,6},
    }

    testing.expect(t, chess.isCheckmate(&testState, WHITE), "isCheckmate test case 2 failed.")
}

@(test)
isCheckmate_testCase3::proc(t: ^testing.T) {
    testState : chess.Game_State = {    
        board = {
            { 0,            0,            0,            0,            0,           0,            0,            0           },
            { 0,            0,            0,            0,            0,           0,            0,            0           },
            { 0,            0,            0,            0,            0,           0,            0,            0           },
            { 0,            0,            0,            0,            0,           WHITE*KING,   0,            BLACK*KING  },
            { 0,            0,            0,            0,            0,           0,            0,            0           },
            { 0,            0,            0,            0,            0,           0,            0,            0           },
            { 0,            0,            0,            0,            0,           0,            0,            0           },
            { 0,            0,            0,            0,            0,           0,            0,            WHITE*ROOK  },
        },
        whiteToPlay = false,
        whitePiecesCaptured = 0,
        blackPiecesCaptured = 0,
        disableBlackKingSideCastling = true,
        disableBlackQueenSideCastling = true,
        disableWhiteKingSideCastling = true,
        disableWhiteQueenSideCastling = true,
        whiteKingPosition = {3,5},
        blackKingPosition = {3,7},
    }

    testing.expect(t, chess.isCheckmate(&testState, BLACK), "isCheckmate test case 3 failed.")
}

@(test)
isCheckmate_testCase4::proc(t: ^testing.T) {
    testState : chess.Game_State = {    
        board = {
            { 0,            0,            0,            0,            0,           0,            BLACK*ROOK,   BLACK*KING  },
            { 0,            0,            BLACK*PAWN,   WHITE*ROOK,   WHITE*PAWN,  WHITE*KNIGHT, BLACK*PAWN,   BLACK*PAWN  },
            { 0,            0,            BLACK*PAWN,   0,            0,           0,            0,            0           },
            { BLACK*PAWN,   0,            0,            0,            0,           BLACK*PAWN,   0,            0           },
            { 0,            0,            0,            0,            0,           0,            BLACK*KNIGHT, 0           },
            { BLACK*QUEEN,  0,            0,            0,            0,           0,            WHITE*PAWN,   0           },
            { WHITE*PAWN,   0,            0,            0,            WHITE*PAWN,  WHITE*PAWN,   0,            WHITE*PAWN  },
            { 0,            0,            0,            0,            0,           0,            WHITE*KING,   0           },
        },
        whiteToPlay = false,
        whitePiecesCaptured = 0,
        blackPiecesCaptured = 0,
        disableBlackKingSideCastling = true,
        disableBlackQueenSideCastling = true,
        disableWhiteKingSideCastling = true,
        disableWhiteQueenSideCastling = true,
        whiteKingPosition = {7,6},
        blackKingPosition = {0,7},
    }

    testing.expect(t, chess.isCheckmate(&testState, BLACK), "isCheckmate test case 4 failed.")
}