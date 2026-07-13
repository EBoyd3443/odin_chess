package tests

import "core:testing"

@require import chess "../src"

@(test)
moveStringToArray_firstTest::proc(t:^testing.T) {
    procedureResult: [2][2]i8 = chess.moveStringToArray("b2b4")
    expectedResult: [2][2]i8 = {{6,1},{4,1}}
    equivolence:=true
    for i in 0..=1 {
        for j in 0 ..=1 {
            if(expectedResult[i][j] != procedureResult[i][j]) {
                equivolence = false
            }
        }
    }
    testing.expect(t, equivolence, "moveStringToArray(b2b4) == {{6,1},{4,1}}")
}

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