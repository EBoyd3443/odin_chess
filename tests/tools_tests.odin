package tests

import "core:testing"

@require import chess "../src"

WHITE:= chess.WHITE
BLACK:= chess.BLACK

PAWN:= chess.PAWN
BISHOP:= chess.BISHOP
KNIGHT:= chess.KNIGHT
ROOK:= chess.ROOK
QUEEN:= chess.QUEEN
KING:= chess.KING

@(test)
moveStringToArray_withinRange::proc(t: ^testing.T) {
    stringList:[8]string={"a1A8","b2B7","c3C6","d4D5","E5e4","F6f3","G7g2","H8h1"}
    procedureResult: [8][2][2]i8
    for i in 0..=7 {
        procedureResult[i] = chess.moveStringToArray(stringList[i])
    }
    expectedResult: [8][2][2]i8 = {
        {{7,0},{0,0}},
        {{6,1},{1,1}},
        {{5,2},{2,2}},
        {{4,3},{3,3}},
        {{3,4},{4,4}},
        {{2,5},{5,5}},
        {{1,6},{6,6}},
        {{0,7},{7,7}},
    }
    equivalence:=true
    for z in 0..=7 {
        for i in 0..=1 {
            for j in 0..=1 {
                if(expectedResult[z][i][j] != procedureResult[z][i][j]) {
                    equivalence = false
                }
            }
        }
    }
    testing.expect(t, equivalence, "moveStringToArray within range test failed.")
}

@(test)
executeMove_simpleTest::proc(t: ^testing.T) {
    testState : chess.Game_State =  {
        board = {
            { 0,            0,            0,            0,           0,          0,            0,            0         },
            { 0,            0,            0,            0,           0,          0,            0,            0         },
            { 0,            0,            0,            0,           0,          0,            0,            0         },
            { 0,            0,            0,            0,           0,          0,            0,            0         },
            { 0,            0,            0,            0,           0,          0,            0,            0         },
            { 0,            0,            0,            0,           0,          0,            0,            0         },
            { 0,            0,            0,            0,           0,          0,            0,            0         },
            { WHITE*KNIGHT, 0,            0,            0,           0,          0,            0,            0         },
        },
        whiteToPlay = true,
        whiteKingMoved = false,
        blackKingMoved = false,
        whitePiecesCaptured = 0,
        blackPiecesCaptured = 0,
    }
    testMove:[2][2]i8 = {{7,0},{5,1}}
    intendedBoard:[8][8]i8 = {
        { 0,            0,            0,            0,           0,          0,            0,            0         },
        { 0,            0,            0,            0,           0,          0,            0,            0         },
        { 0,            0,            0,            0,           0,          0,            0,            0         },
        { 0,            0,            0,            0,           0,          0,            0,            0         },
        { 0,            0,            0,            0,           0,          0,            0,            0         },
        { 0,            WHITE*KNIGHT, 0,            0,           0,          0,            0,            0         },
        { 0,            0,            0,            0,           0,          0,            0,            0         },
        { 0,            0,            0,            0,           0,          0,            0,            0         },
    }
    chess.executeMove(&testState, testMove)
    equivalence:=true
    for i in 0..=7 {
        for j in 0..=7 {
            if(testState.board[i][j] != intendedBoard[i][j]) {
                equivalence = false
            }
        }
    }
    testing.expect(t, equivalence, "moveStringToArray within range test failed.")
}

// Additions for executeMove
    // To Do: Test working en passant

    // To Do: Test capture with enemy pawn in en passant square, but not having moved two on last move

    // To Do: Test castling

@(test)
getWhitePieces_simpleTest::proc(t: ^testing.T) {
    testState : chess.Game_State =  {
        board = {
            { WHITE*KING,   0,            0,            0,           0,          0,            0,            WHITE*PAWN},
            { 0,            0,            0,            0,           0,          0,            WHITE*BISHOP, 0         },
            { 0,            0,            0,            0,           0,          WHITE*KNIGHT, 0,            0         },
            { 0,            0,            0,            0,           WHITE*PAWN, 0,            0,            0         },
            { 0,            0,            0,            WHITE*QUEEN, 0,          0,            0,            0         },
            { 0,            0,            WHITE*ROOK,   0,           0,          0,            0,            0         },
            { 0,            WHITE*BISHOP, 0,            0,           0,          0,            0,            0         },
            { WHITE*KNIGHT, 0,            0,            0,           0,          0,            0,            WHITE*PAWN},
        },
        whiteToPlay = true,
        whiteKingMoved = false,
        blackKingMoved = false,
        whitePiecesCaptured = 0,
        blackPiecesCaptured = 0,
    }
    testMove:[2][2]i8 = {{7,0},{5,1}}
    intendedPieceList: [dynamic][2]i8
    defer delete(intendedPieceList)
    addLocation:[2]i8 = {0,0}
    append(&intendedPieceList, addLocation)
    addLocation = {7,7}
    append(&intendedPieceList, addLocation)
    addLocation = {7,0}
    append(&intendedPieceList, addLocation)
    addLocation = {6,1}
    append(&intendedPieceList, addLocation)
    addLocation = {5,2}
    append(&intendedPieceList, addLocation)
    addLocation = {4,3}
    append(&intendedPieceList, addLocation)
    addLocation = {3,4}
    append(&intendedPieceList, addLocation)
    addLocation = {2,5}
    append(&intendedPieceList, addLocation)
    addLocation = {1,6}
    append(&intendedPieceList, addLocation)
    addLocation = {0,7}
    append(&intendedPieceList, addLocation)

    actualPieceList:[dynamic][2]i8 = chess.getWhitePieces(&testState)
    equivalence:=true
    for i in actualPieceList {
        contains:=false
        for j in intendedPieceList {
            if(i == j) {
                contains = true
                break
            }
        }
        if(!contains) {
            equivalence = false
        }
    }
    testing.expect(t, equivalence, "moveStringToArray within range test failed.")
}

@(test)
getBlackPieces_simpleTest::proc(t: ^testing.T) {
    testState : chess.Game_State =  {
        board = {
            { BLACK*KING,   0,            0,            0,           0,          0,            0,            BLACK*PAWN},
            { 0,            0,            0,            0,           0,          0,            BLACK*BISHOP, 0         },
            { 0,            0,            0,            0,           0,          BLACK*KNIGHT, 0,            0         },
            { 0,            0,            0,            0,           BLACK*PAWN, 0,            0,            0         },
            { 0,            0,            0,            BLACK*QUEEN, 0,          0,            0,            0         },
            { 0,            0,            BLACK*ROOK,   0,           0,          0,            0,            0         },
            { 0,            BLACK*BISHOP, 0,            0,           0,          0,            0,            0         },
            { BLACK*KNIGHT, 0,            0,            0,           0,          0,            0,            BLACK*PAWN},
        },
        whiteToPlay = true,
        whiteKingMoved = false,
        blackKingMoved = false,
        whitePiecesCaptured = 0,
        blackPiecesCaptured = 0,
    }
    testMove:[2][2]i8 = {{7,0},{5,1}}
    intendedPieceList: [dynamic][2]i8
    defer delete(intendedPieceList)
    addLocation:[2]i8 = {0,0}
    append(&intendedPieceList, addLocation)
    addLocation = {7,7}
    append(&intendedPieceList, addLocation)
    addLocation = {7,0}
    append(&intendedPieceList, addLocation)
    addLocation = {6,1}
    append(&intendedPieceList, addLocation)
    addLocation = {5,2}
    append(&intendedPieceList, addLocation)
    addLocation = {4,3}
    append(&intendedPieceList, addLocation)
    addLocation = {3,4}
    append(&intendedPieceList, addLocation)
    addLocation = {2,5}
    append(&intendedPieceList, addLocation)
    addLocation = {1,6}
    append(&intendedPieceList, addLocation)
    addLocation = {0,7}
    append(&intendedPieceList, addLocation)

    actualPieceList:[dynamic][2]i8 = chess.getWhitePieces(&testState)
    equivalence:=true
    for i in actualPieceList {
        contains:=false
        for j in intendedPieceList {
            if(i == j) {
                contains = true
                break
            }
        }
        if(!contains) {
            equivalence = false
        }
    }
    testing.expect(t, equivalence, "moveStringToArray within range test failed.")
}

// @(test)
// isValidMove_test::proc(t: ^testing.T) {
    
// }

// @(test)
// isEmpty_test::proc(t: ^testing.T) {
    
// }

// @(test)
// containsOwnPiece_test::proc(t: ^testing.T) {
    
// }

// @(test)
// isNotAttacked_test::proc(t: ^testing.T) {
    
// }

// @(test)
// isOnBoard_test::proc(t: ^testing.T) {
    
// }

// @(test)
// getValidMoves_test::proc(t: ^testing.T) {
    
// }

///////////////////////////////////////////
//     Notes: Current procedures         //
///////////////////////////////////////////

// moveStringToArray :: proc(input: string) -> [2][2]i8 

// executeMove :: proc(state: ^Game_State, move: [2][2]i8) 

// getWhitePieces :: proc(state: ^Game_State) -> [dynamic][2]i8 

// getBlackPieces :: proc(state: ^Game_State) -> [dynamic][2]i8 

// isValidMove :: proc(move: string, state: ^Game_State, fileToInt: map[u8]i8) -> string 

// isEmpty :: proc(target: i8) -> bool 

// containsOwnPiece :: proc(state: ^Game_State, ownColor: i8, target: i8) -> bool 

// isNotAttacked :: proc(state: ^Game_State, x: i8, y: i8) -> bool 

// isOnBoard :: proc(x: i8, y: i8) -> bool 

// getValidMoves :: proc(state: ^Game_State, targetPiece: string, fileToInt: map[u8]i8) -> [dynamic][2]i8 