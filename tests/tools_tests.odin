package tests

import "core:testing"
import "core:fmt"

@require import chess "../src"

WHITE:= chess.WHITE
BLACK:= chess.BLACK

PAWN:= chess.PAWN
BISHOP:= chess.BISHOP
KNIGHT:= chess.KNIGHT
ROOK:= chess.ROOK
QUEEN:= chess.QUEEN
KING:= chess.KING

// Depricated -> To Do: Make version for moveStringToBasicMove
// @(test)
// moveStringToArray_withinRange::proc(t: ^testing.T) {
//     stringList:[8]string={"a1A8","b2B7","c3C6","d4D5","E5e4","F6f3","G7g2","H8h1"}
//     procedureResult: [8][2][2]i8
//     for i in 0..=7 {
//         procedureResult[i] = chess.moveStringToArray(stringList[i])
//     }
//     expectedResult: [8][2][2]i8 = {
//         {{7,0},{0,0}},
//         {{6,1},{1,1}},
//         {{5,2},{2,2}},
//         {{4,3},{3,3}},
//         {{3,4},{4,4}},
//         {{2,5},{5,5}},
//         {{1,6},{6,6}},
//         {{0,7},{7,7}},
//     }
//     equivalence:=true
//     for z in 0..=7 {
//         for i in 0..=1 {
//             for j in 0..=1 {
//                 if(expectedResult[z][i][j] != procedureResult[z][i][j]) {
//                     equivalence = false
//                 }
//             }
//         }
//     }
//     testing.expect(t, equivalence, "moveStringToArray within range test failed.")
// }

@(test)
executeMove_simpleTest::proc(t: ^testing.T) {
    testState : chess.Game_State = {
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
        whitePiecesCaptured = 0,
        blackPiecesCaptured = 0,
    }
    testMove : chess.Basic_Move = {
        moveType = chess.Move_Type.standard,
        from = {7,0},
        to = {5,1},
        piecePromotion = 0,
    }
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
    testing.expect(t, equivalence, "executeMove simple test failed.")
}

// Additions for executeMove
    // To Do: Test working en passant

    // To Do: Test capture with enemy pawn in en passant square, but not having moved two on last move

    // To Do: Test castling

@(test)
getWhitePieces_simpleTest::proc(t: ^testing.T) {
    testState : chess.Game_State = {
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
        whitePiecesCaptured = 6,
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
    if(len(intendedPieceList) == len(actualPieceList)) {
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
    }
    else {
        equivalence = false
    }
    testing.expect(t, equivalence, "getWhitePieces simple test failed.")
}

@(test)
getBlackPieces_simpleTest::proc(t: ^testing.T) {
    testState : chess.Game_State = {
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
        whitePiecesCaptured = 0,
        blackPiecesCaptured = 6,
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

    actualPieceList:[dynamic][2]i8 = chess.getBlackPieces(&testState)
    equivalence:=true
    if(len(intendedPieceList) == len(actualPieceList)) {
        for i in actualPieceList {
            contains:= false
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
    }
    else {
        equivalence = false
    }
    testing.expect(t, equivalence, "getBlackPieces simple test failed.")
}

@(test)
isValidMove_tests::proc(t: ^testing.T) {
    testState : chess.Game_State = {
        board = {
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
    }

    testing.expect(t, chess.isValidMoveFormat(&testState, "") == "Move format error.", "isValidMove empty string test failed.")
    testing.expect(t, chess.isValidMoveFormat(&testState, "a1a") == "Move format error.", "isValidMove 3char string test failed.")
    testing.expect(t, chess.isValidMoveFormat(&testState, "a1a3a4") == "Move format error.", "isValidMove 6char string test failed.")
    testing.expect(t, chess.isValidMoveFormat(&testState, "a5a4") == "No piece selected.", "isValidMove no piece selected test failed.")
    testing.expect(t, chess.isValidMoveFormat(&testState, "a7a6") == "Black piece selected when white to play.", "isValidMove black selected when white to play test failed.")
    testState.whiteToPlay = false
    testing.expect(t, chess.isValidMoveFormat(&testState, "a2a4") == "White piece selected when black to play.", "isValidMove white selected when black to play test failed.")
    testState.whiteToPlay = true
    testing.expect(t, chess.isValidMoveFormat(&testState, "a2a8") == "Piece promotion missing from move.", "isValidMove piece promotion(white) failed.")
    testState.whiteToPlay = false
    testing.expect(t, chess.isValidMoveFormat(&testState, "a7a1") == "Piece promotion missing from move.", "isValidMove piece promotion(black) failed.")
    testState.whiteToPlay = true
    testing.expect(t, chess.isValidMoveFormat(&testState, "a2a4") == "None", "isValidMove valid move failed.")
}

@(test)
isEmpty_test::proc(t: ^testing.T) {
    testing.expect(t, chess.isEmpty(0), "isEmpty test failed.")
}

@(test)
containsOwnPiece_test::proc(t: ^testing.T) {
    testing.expect(t, chess.containsOwnPiece(-1, -5), "containsOwnPiece black test failed")
    testing.expect(t, chess.containsOwnPiece(1, 5), "containsOwnPiece white test failed")
    testing.expect(t, !chess.containsOwnPiece(-1, 0), "containsOwnPiece empty target test failed")
}

@(test)
isNotAttacked_test::proc(t: ^testing.T) {
    testState : chess.Game_State = {
        board = {
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
    }
    expectedResult : [8][8]bool = {
        { true,  false, false, false, false, false, false, true  },
        { false, false, false, false, false, false, false, false },
        { false, false, false, false, false, false, false, false },
        { true,  true,  true,  true,  true,  true,  true,  true  },
        { true,  true,  true,  true,  true,  true,  true,  true  },
        { true,  true,  true,  true,  true,  true,  true,  true  },
        { true,  true,  true,  true,  true,  true,  true,  true  },
        { true,  true,  true,  true,  true,  true,  true,  true  },        
    }
    for x in 0..=7 {
        for y in 0..=7 {
            message:= fmt.aprintf("isNotAttacked test failed at (%d,%d)",y,x)
            defer delete(message)
            testing.expect(t, chess.isNotAttacked(&testState, i8(y), i8(x)) == expectedResult[y][x], message)
        }
    }
}

@(test)
isOnBoard_test::proc(t: ^testing.T) {
    testing.expect(t, chess.isOnBoard(0,0), "isOnBoard at (0,0) edge test failed.")
    testing.expect(t, chess.isOnBoard(7,7), "isOnBoard at (7,7) edge test failed.")
    testing.expect(t, chess.isOnBoard(0,7), "isOnBoard at (0,7) edge test failed.")
    testing.expect(t, chess.isOnBoard(7,0), "isOnBoard at (7,0) edge test failed.")
    testing.expect(t, !chess.isOnBoard(8,0), "isOnBoard at (8,0) outside edge test failed.")
    testing.expect(t, !chess.isOnBoard(0,8), "isOnBoard at (0,8) outside edge test failed.")
    testing.expect(t, !chess.isOnBoard(-1,0), "isOnBoard at (-1,0) outside edge test failed.")
    testing.expect(t, !chess.isOnBoard(0,-1), "isOnBoard at (0,-1) outside edge test failed.")
}

@(test)
getValidMoves_whitePawnOpening::proc(t: ^testing.T) {
    testState : chess.Game_State = {    
        board = {
            { 0,            0,            0,            0,           0,          0,            0,            0         },
            { 0,            0,            0,            0,           0,          0,            0,            0         },
            { 0,            0,            0,            0,           0,          0,            0,            0         },
            { 0,            0,            0,            0,           0,          0,            0,            0         },
            { 0,            0,            WHITE*KNIGHT, 0,           0,          0,            0,            0         },
            { 0,            WHITE*KNIGHT, 0,            0,           0,          0,            0,            0         },
            { WHITE*PAWN,   WHITE*PAWN,   WHITE*PAWN,   0,           WHITE*PAWN, 0,            0,            WHITE*PAWN},
            { 0,            0,            0,            0,           0,          0,            0,            0         },
        },
        whiteToPlay = true,
        whitePiecesCaptured = 0,
        blackPiecesCaptured = 0,
    }
    expectedResults: [5][dynamic]chess.Basic_Move
    expectedMove: chess.Basic_Move = {
        from = {6,0},
        to = {5,0}
    }
    append(&expectedResults[0], expectedMove)
    expectedMove = {
        from = {6,0},
        to = {4,0}
    }
    append(&expectedResults[0], expectedMove)
    expectedMove = {
        from = {6,2},
        to = {5,2}
    }
    append(&expectedResults[2], expectedMove)
    expectedMove = {
        from = {6,4},
        to = {5,4}
    }
    append(&expectedResults[3], expectedMove)
    expectedMove = {
        from = {6,4},
        to = {4,4}
    }
    append(&expectedResults[3], expectedMove)
    expectedMove = {
        from = {6,7},
        to = {5,7}
    }
    append(&expectedResults[4], expectedMove)
    expectedMove = {
        from = {6,7},
        to = {4,7}
    }
    append(&expectedResults[4], expectedMove)
    for i in 0..=4 {
        defer delete(expectedResults[i])
    }
    
    actualResults: [5][dynamic]chess.Basic_Move
    actualResults[0] = chess.getValidMoves(&testState, {6,0})
    actualResults[1] = chess.getValidMoves(&testState, {6,1})
    actualResults[2] = chess.getValidMoves(&testState, {6,2})
    actualResults[3] = chess.getValidMoves(&testState, {6,4})
    actualResults[4] = chess.getValidMoves(&testState, {6,7})
    for i in 0..=4 {
        defer delete(actualResults[i])
    }
    equivalence:bool
    if(len(actualResults[0]) == len(expectedResults[0]) && len(actualResults[1]) == len(expectedResults[1]) && 
    len(actualResults[2]) == len(expectedResults[2])){
        equivalence = true
        for x in 0..=4 {
            for i in actualResults[x] {
                contains:= false
                for j in expectedResults[x]{
                    if(i.from == j.from && i.to == j.to) {
                        contains = true
                        break
                    }
                }
                if(!contains) {
                    equivalence = false
                }
            }
        }
    }
    else{
        equivalence = false
    }
    testing.expect(t, equivalence, "getValidMoves white pawn opening test failed.") 
}

@(test)
getValidMoves_blackPawnOpening::proc(t: ^testing.T) {
    testState : chess.Game_State = {    
        board = {
            { 0,            0,            0,            0,           0,          0,            0,            0         },
            { BLACK*PAWN,   BLACK*PAWN,   BLACK*PAWN,   0,           BLACK*PAWN, 0,            0,            BLACK*PAWN},
            { 0,            BLACK*KNIGHT, 0,            0,           0,          0,            0,            0         },
            { 0,            0,            BLACK*KNIGHT, 0,           0,          0,            0,            0         },
            { 0,            0,            0,            0,           0,          0,            0,            0         },
            { 0,            0,            0,            0,           0,          0,            0,            0         },
            { 0,            0,            0,            0,           0,          0,            0,            0         },
            { 0,            0,            0,            0,           0,          0,            0,            0         },
        },
        whiteToPlay = false,
        whitePiecesCaptured = 0,
        blackPiecesCaptured = 0,
    }
    expectedResults: [5][dynamic]chess.Basic_Move
    expectedMove: chess.Basic_Move = {
        from = {1,0},
        to = {3,0}
    }
    append(&expectedResults[0], expectedMove)
    expectedMove = {
        from = {1,0},
        to = {2,0}
    }
    append(&expectedResults[0], expectedMove)
    expectedMove = {
        from = {1,2},
        to = {2,2}
    }
    append(&expectedResults[2], expectedMove)
    expectedMove = {
        from = {1,4},
        to = {3,4}
    }
    append(&expectedResults[3], expectedMove)
    expectedMove = {
        from = {1,4},
        to = {2,4}
    }
    append(&expectedResults[3], expectedMove)
    expectedMove = {
        from = {1,7},
        to = {3,7}
    }
    append(&expectedResults[4], expectedMove)
    expectedMove = {
        from = {1,7},
        to = {2,7}
    }
    append(&expectedResults[4], expectedMove)
    for i in 0..=4 {
        defer delete(expectedResults[i])
    }
    
    actualResults: [5][dynamic]chess.Basic_Move
    actualResults[0] = chess.getValidMoves(&testState, {1,0})
    actualResults[1] = chess.getValidMoves(&testState, {1,1})
    actualResults[2] = chess.getValidMoves(&testState, {1,2})
    actualResults[3] = chess.getValidMoves(&testState, {1,4})
    actualResults[4] = chess.getValidMoves(&testState, {1,7})
    for i in 0..=4 {
        defer delete(actualResults[i])
    }
    equivalence:bool
    if(len(actualResults[0]) == len(expectedResults[0]) && len(actualResults[1]) == len(expectedResults[1]) && 
    len(actualResults[2]) == len(expectedResults[2])){
        equivalence = true
        for x in 0..=4 {
            for i in actualResults[x] {
                contains:= false
                for j in expectedResults[x]{
                    if(i.from == j.from && i.to == j.to) {
                        contains = true
                        break
                    }
                }
                if(!contains) {
                    equivalence = false
                }
            }
        }
    }
    else{
        equivalence = false
    }
    testing.expect(t, equivalence, "getValidMoves black pawn opening test failed.") 
}

@(test)
getValidMoves_bishopTest::proc(t: ^testing.T) {
    testState : chess.Game_State = {    
        board = {
            { 0,            0,            0,            0,           0,          0,            0,            0         },
            { BLACK*KNIGHT, 0,            0,            0,           WHITE*PAWN, 0,            0,            0         },
            { 0,            0,            0,            0,           0,          0,            0,            0         },
            { 0,            0,            BLACK*BISHOP, 0,           0,          0,            0,            0         },
            { 0,            0,            0,            0,           0,          0,            0,            0         },
            { 0,            0,            0,            0,           0,          0,            0,            0         },
            { 0,            0,            0,            0,           0,          0,            0,            0         },
            { 0,            0,            0,            0,           0,          0,            0,            0         },
        },
        whiteToPlay = true,
        whitePiecesCaptured = 0,
        blackPiecesCaptured = 0,
    }
    expectedResults: [dynamic]chess.Basic_Move
    expectedMove: chess.Basic_Move = {
        from = {3,2},
        to = {2,1}
    }
    append(&expectedResults, expectedMove)
    expectedMove = {
        from = {3,2},
        to = {1,4}
    }
    append(&expectedResults, expectedMove)
    expectedMove = {
        from = {3,2},
        to = {2,3}
    }
    append(&expectedResults, expectedMove)
    expectedMove = {
        from = {3,2},
        to = {4,1}
    }
    append(&expectedResults, expectedMove)
    expectedMove = {
        from = {3,2},
        to = {5,0}
    }
    append(&expectedResults, expectedMove)
    expectedMove = {
        from = {3,2},
        to = {4,3}
    }
    append(&expectedResults, expectedMove)
    expectedMove = {
        from = {3,2},
        to = {5,4}
    }
    append(&expectedResults, expectedMove)
    expectedMove = {
        from = {3,2},
        to = {6,5}
    }
    append(&expectedResults, expectedMove)
    expectedMove = {
        from = {3,2},
        to = {7,6}
    }
    append(&expectedResults, expectedMove)
    defer delete(expectedResults)
    
    actualResults: [dynamic]chess.Basic_Move
    actualResults = chess.getValidMoves(&testState, {3,2})
    defer delete(actualResults)

    equivalence:bool
    
    if(len(actualResults) == len(expectedResults)){
        equivalence = true
        for i in actualResults {
            contains:= false
            for j in expectedResults{
                if(i.from == j.from && i.to == j.to) {
                    contains = true
                    break
                }
            }
            if(!contains) {
                equivalence = false
            }
        }
    }
    else{
        equivalence = false
    }
    testing.expect(t, equivalence, "getValidMoves bishop test failed.")
}


@(test)
getValidMoves_knightTest::proc(t: ^testing.T) {
    testState : chess.Game_State = {    
        board = {
            { 0,            0,            0,            0,           0,          0,            0,            0         },
            { BLACK*KNIGHT, WHITE*PAWN,   0,            0,           0,          0,            0,            0         },
            { 0,            0,            0,            0,           0,          0,            0,            0         },
            { 0,            0,            BLACK*KNIGHT, 0,           0,          0,            0,            0         },
            { 0,            0,            0,            0,           0,          0,            0,            0         },
            { 0,            0,            0,            BLACK*PAWN,  0,          0,            0,            0         },
            { 0,            0,            0,            0,           0,          0,            0,            0         },
            { 0,            0,            0,            0,           0,          0,            0,            0         },
        },
        whiteToPlay = true,
        whitePiecesCaptured = 0,
        blackPiecesCaptured = 0,
    }
    expectedResults: [2][dynamic]chess.Basic_Move
    expectedMove: chess.Basic_Move = {
        from = {1,0},
        to = {0,2}
    }
    append(&expectedResults[0], expectedMove)
    expectedMove =  {
        from = {1,0},
        to = {2,2}
    }
    append(&expectedResults[0], expectedMove)
    expectedMove = {
        from = {1,0},
        to = {3,1}
    }
    append(&expectedResults[0], expectedMove)
    expectedMove = {
        from = {3,2},
        to = {1,1}
    }
    append(&expectedResults[1], expectedMove)
    expectedMove = {
        from = {3,2},
        to = {1,3}
    }
    append(&expectedResults[1], expectedMove)
    expectedMove = {
        from = {3,2},
        to = {2,0}
    }
    append(&expectedResults[1], expectedMove)
    expectedMove = {
        from = {3,2},
        to = {2,4}
    } 
    append(&expectedResults[1], expectedMove)
    expectedMove = {
        from = {3,2},
        to = {4,0}
    }
    append(&expectedResults[1], expectedMove)
    expectedMove = {
        from = {3,2},
        to = {4,4}
    }
    append(&expectedResults[1], expectedMove)
    expectedMove = {
        from = {3,2},
        to = {5,1}
    }
    append(&expectedResults[1], expectedMove)
    for i in 0..=1 {
        defer delete(expectedResults[i])
    }
    
    actualResults: [2][dynamic]chess.Basic_Move
    actualResults[0] = chess.getValidMoves(&testState, {1,0})
    actualResults[1] = chess.getValidMoves(&testState, {3,2})
    for i in 0..=1 {
        defer delete(actualResults[i])
    }

    equivalence:bool
    if(len(actualResults[0]) == len(expectedResults[0]) && len(actualResults[1]) == len(expectedResults[1])){
        equivalence = true
        for x in 0..=1 {
            for i in actualResults[x] {
                contains:= false
                for j in expectedResults[x]{
                    if(i.from == j.from && i.to == j.to) {
                        contains = true
                        break
                    }
                }
                if(!contains) {
                    equivalence = false
                }
            }
        }
    }
    else{
        equivalence = false
    }
    testing.expect(t, equivalence, "getValidMoves bishop test failed.") 
}

///////////////////////////////////////////
//     Notes: Current procedures         //
///////////////////////////////////////////

// moveStringToArray :: proc(input: string) -> [2][2]i8 

// executeMove :: proc(state: ^Game_State, move: [2][2]i8) 

// getWhitePieces :: proc(state: ^Game_State) -> [dynamic][2]i8 

// getBlackPieces :: proc(state: ^Game_State) -> [dynamic][2]i8 

// isValidMove :: proc(state: ^Game_State, move: string) -> string 

// isEmpty :: proc(target: i8) -> bool 

// containsOwnPiece :: proc(ownColor: i8, target: i8) -> bool 

// isNotAttacked :: proc(state: ^Game_State, y: i8, x: i8) -> bool 

// isOnBoard :: proc(x: i8, y: i8) -> bool 

// getValidMoves :: proc(state: ^Game_State, targetPiece: [2]i8) -> [dynamic][2]i8 