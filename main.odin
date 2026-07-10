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

Game_State :: struct {
    mutex: sync.Mutex,
    board: [8][8]i8,
    whiteToPlay: bool,
    whiteKingMoved: bool,
    blackKingMoved: bool,
    moveList: string,
}

main :: proc() {
    //color: (-) => black, (+) => white
    //pieces: 1 => pawn, 2 => bishop, 3 => knight, 4 => rook, 5 => queen, 6 => king
    state := Game_State {
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
        whiteKingMoved = false,
        blackKingMoved = false,
    }

    // Not currently used.
    // fileToChar:= make(map[i8]u8)
    // fileToChar[0] = 'a'
    // fileToChar[1] = 'b'
    // fileToChar[2] = 'c'
    // fileToChar[3] = 'd'
    // fileToChar[4] = 'e'
    // fileToChar[5] = 'f'
    // fileToChar[6] = 'g'
    // fileToChar[7] = 'h'
   
    t := thread.create_and_start_with_poly_data(
        &state,
        inputThread,
    )

    rlBoard(state.board) 
}