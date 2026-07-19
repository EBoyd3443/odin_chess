package tests

import "core:testing"
import "core:fmt"

@require import chess "../src"

@(test)
isStalemate_testCase1::proc(t: ^testing.T) {
    testState : chess.Game_State = {    
        board = {
            { 0,            0,            0,            0,           0,          BLACK*KING,   0,            0          },
            { 0,            0,            0,            0,           0,          WHITE*PAWN,   0,            0          },
            { 0,            0,            0,            0,           0,          WHITE*KING,   0,            0          },
            { 0,            0,            0,            0,           0,          0,            0,            0          },
            { 0,            0,            0,            0,           0,          0,            0,            0          },
            { 0,            0,            0,            0,           0,          0,            0,            0          },
            { 0,            0,            0,            0,           0,          0,            0,            0          },
            { 0,            0,            0,            0,           0,          0,            0,            0          },
        },
        whiteToPlay = true,
        whitePiecesCaptured = 0,
        blackPiecesCaptured = 0,
        disableBlackKingSideCastling = true,
        disableBlackQueenSideCastling = true,
        disableWhiteKingSideCastling = true,
        disableWhiteQueenSideCastling = true,
    }

    testing.expect(t, chess.isStalemate(&testState, BLACK), "isStalemate test case 1 failed.")
}

@(test)
isStalemate_testCase2::proc(t: ^testing.T) {
    testState : chess.Game_State = {
        board = {
            { BLACK*KING,   BLACK*BISHOP, 0,            0,           0,          0,            0,            WHITE*ROOK },
            { 0,            0,            0,            0,           0,          0,            0,            0          },
            { 0,            WHITE*KING,   0,            0,           0,          0,            0,            0          },
            { 0,            0,            0,            0,           0,          0,            0,            0          },
            { 0,            0,            0,            0,           0,          0,            0,            0          },
            { 0,            0,            0,            0,           0,          0,            0,            0          },
            { 0,            0,            0,            0,           0,          0,            0,            0          },
            { 0,            0,            0,            0,           0,          0,            0,            0          },
        },
        whiteToPlay = true,
        whitePiecesCaptured = 0,
        blackPiecesCaptured = 0,
        disableBlackKingSideCastling = true,
        disableBlackQueenSideCastling = true,
        disableWhiteKingSideCastling = true,
        disableWhiteQueenSideCastling = true,
    }

    testing.expect(t, chess.isStalemate(&testState, BLACK), "isStalemate test case 2 failed.")
}

@(test)
isStalemate_testCase3::proc(t: ^testing.T) {
    testState : chess.Game_State = {
        board = {
            { 0,            0,            0,            0,           0,          0,            0,            WHITE*KING },
            { 0,            0,            0,            0,           0,          0,            0,            0          },
            { 0,            0,            0,            0,           0,          0,            0,            0          },
            { 0,            0,            0,            0,           0,          0,            0,            0          },
            { 0,            0,            0,            0,           0,          0,            0,            0          },
            { 0,            WHITE*QUEEN,  0,            0,           0,          0,            0,            0          },
            { 0,            0,            0,            0,           0,          0,            0,            0          },
            { BLACK*KING,   0,            0,            0,           0,          0,            0,            0          },
        },
        whiteToPlay = true,
        whitePiecesCaptured = 0,
        blackPiecesCaptured = 0,
        disableBlackKingSideCastling = true,
        disableBlackQueenSideCastling = true,
        disableWhiteKingSideCastling = true,
        disableWhiteQueenSideCastling = true,
    }

    testing.expect(t, chess.isStalemate(&testState, BLACK), "isStalemate test case 3 failed.")
}

@(test)
isStalemate_testCase4::proc(t: ^testing.T) {
    testState : chess.Game_State = {
        board = {
            { 0,            0,            0,            0,           0,          0,            0,            0,         },
            { 0,            0,            0,            0,           0,          0,            0,            0          },
            { 0,            0,            0,            0,           0,          0,            0,            0          },
            { 0,            0,            0,            0,           0,          0,            0,            0          },
            { 0,            0,            0,            0,           0,          0,            0,            0          },
            { 0,            0,            WHITE*KING,   0,           0,          0,            0,            0          },
            { 0,            WHITE*ROOK,   0,            0,           0,          0,            0,            0          },
            { BLACK*KING,   0,            0,            0,           0,          0,            0,            0          },
        },
        whiteToPlay = true,
        whitePiecesCaptured = 0,
        blackPiecesCaptured = 0,
        disableBlackKingSideCastling = true,
        disableBlackQueenSideCastling = true,
        disableWhiteKingSideCastling = true,
        disableWhiteQueenSideCastling = true,
    }

    testing.expect(t, chess.isStalemate(&testState, BLACK), "isStalemate test case 4 failed.")
}

@(test)
isStalemate_testCase5::proc(t: ^testing.T) {
    testState : chess.Game_State = {
        board = {
            { WHITE*KNIGHT, WHITE*BISHOP, BLACK*KING,   0,           0,          0,           0,            0          },
            { WHITE*PAWN,   BLACK*PAWN,   WHITE*PAWN,   0,           BLACK*PAWN, 0,           0,            0          },
            { 0,            WHITE*PAWN,   0,            0,           WHITE*PAWN, 0,           0,            0          },
            { 0,            0,            0,            0,           0,          0,           0,            0          },
            { 0,            0,            0,            0,           0,          0,           0,            0          },
            { 0,            0,            0,            BLACK*PAWN,  0,          BLACK*PAWN,  0,            0          },
            { 0,            0,            0,            WHITE*PAWN,  BLACK*PAWN, WHITE*PAWN,  BLACK*PAWN,   BLACK*PAWN },
            { 0,            0,            0,            0,           WHITE*KING, BLACK*BISHOP,BLACK*ROOK,   BLACK*QUEEN},
        },
        whiteToPlay = true,
        whitePiecesCaptured = 0,
        blackPiecesCaptured = 0,
        disableBlackKingSideCastling = true,
        disableBlackQueenSideCastling = true,
        disableWhiteKingSideCastling = true,
        disableWhiteQueenSideCastling = true,
    }

    testing.expect(t, chess.isStalemate(&testState, WHITE), "isStalemate test case 5 failed.")
}

@(test)
isStalemate_testCase6::proc(t: ^testing.T) {
    testState : chess.Game_State = {
        board = {
            { WHITE*KNIGHT, WHITE*BISHOP, BLACK*KING,   0,           0,          0,           0,            0          },
            { WHITE*PAWN,   BLACK*PAWN,   WHITE*PAWN,   0,           BLACK*PAWN, 0,           0,            0          },
            { 0,            WHITE*PAWN,   0,            0,           WHITE*PAWN, 0,           0,            0          },
            { 0,            0,            0,            0,           0,          0,           0,            0          },
            { 0,            0,            0,            0,           0,          0,           0,            0          },
            { 0,            0,            0,            BLACK*PAWN,  0,          BLACK*PAWN,  0,            0          },
            { 0,            0,            0,            WHITE*PAWN,  BLACK*PAWN, WHITE*PAWN,  BLACK*PAWN,   BLACK*PAWN },
            { 0,            0,            0,            0,           WHITE*KING, BLACK*BISHOP,BLACK*ROOK,   BLACK*QUEEN},
        },
        whiteToPlay = true,
        whitePiecesCaptured = 0,
        blackPiecesCaptured = 0,
        disableBlackKingSideCastling = true,
        disableBlackQueenSideCastling = true,
        disableWhiteKingSideCastling = true,
        disableWhiteQueenSideCastling = true,
    }

    testing.expect(t, chess.isStalemate(&testState, WHITE), "isStalemate test case 6 failed.")
}