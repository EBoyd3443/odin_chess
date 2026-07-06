package chess

import "core:fmt"
import "core:os"
import "core:strings"
import "core:sync"
import "core:thread"
import rl "vendor:raylib"

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
    // fileToChar[1] = 'A'
    // fileToChar[2] = 'B'
    // fileToChar[3] = 'C'
    // fileToChar[4] = 'D'
    // fileToChar[5] = 'E'
    // fileToChar[6] = 'F'
    // fileToChar[7] = 'G'
    // fileToChar[8] = 'H'
   
    t := thread.create_and_start_with_poly_data(
        &state,
        inputThread,
    )

    rlBoard(state.board) 
}

inputThread :: proc(state: ^Game_State) {
    fileToInt:= make(map[u8]i8)
    fileToInt['A'] = 0
    fileToInt['B'] = 1
    fileToInt['C'] = 2
    fileToInt['D'] = 3
    fileToInt['E'] = 4
    fileToInt['F'] = 5
    fileToInt['G'] = 6
    fileToInt['H'] = 7
    fileToInt['a'] = 0
    fileToInt['b'] = 1
    fileToInt['c'] = 2
    fileToInt['d'] = 3
    fileToInt['e'] = 4
    fileToInt['f'] = 5
    fileToInt['g'] = 6
    fileToInt['h'] = 7

    // Get next move.
    for {
        fmt.println("Enter move.")

        /*******************  TESTING  *********************************/
        fmt.println(getValidMoves(state, "d3", fileToInt))
        fmt.println(isNotAttacked(state, 1, 3))
                
        
        buf:[265]byte
        n,err := os.read(os.stdin, buf[:])
        if err!= nil {
            fmt.eprintln("Error reading input:", err)
        }
        else {
            input:= string(strings.trim_space(string(buf[:n])))

            inputError: = isValidMove(input, state, fileToInt)
            if(inputError == "None") {
                sync.mutex_lock(&state.mutex)
                currentPiece := state.board[7-(input[1]-'1')][fileToInt[input[0]]]
                state.board[7-(input[1]-'1')][fileToInt[input[0]]] = 0
                state.board[7-(input[3]-'1')][fileToInt[input[2]]] = currentPiece
                sync.mutex_unlock(&state.mutex)
                //fmt.print("\x1b[2J\x1b[H")
            }
            else {
                fmt.println(inputError)
            }
        }
    }     
}

isValidMove :: proc(move: string, state: ^Game_State, fileToInt: map[u8]i8) -> string {
    
    if (len(move) < 4 || len(move) > 5) ||
    !((move[0] >= 'a' && move[0] <= 'h') || (move[0] >= 'A' && move[0] <= 'H'))||
    !((move[1] >= '1' && move[1] <= '8' ))||
    !((move[1] >= '1' && move[1] <= '8' ))||
    !((move[2] >= 'a' && move[2] <= 'h') || (move[2] >= 'A' && move[2] <= 'H')) ||
    !((move[3] >= '1' && move[3] <= '8' )) {
        return "Move format error."
    }

    pieceToMove : i8 = state.board[7-(move[1]-'1')][fileToInt[move[0]]]
    targetSpave : i8 = state.board[7-(move[3]-'1')][fileToInt[move[2]]]

    if(pieceToMove == 0) {
        return "No piece selected."
    }
    if(pieceToMove < 0 && state.whiteToPlay) {
        return "Black piece selected when white to play."
    }
    if(pieceToMove > 0 && !state.whiteToPlay) {
        return "White piece selected when black to play."
    }

    if((pieceToMove == 1 && move[3] == '8' && len(move) != 5) ||
        (pieceToMove == -1 && move[3] == '1' && len(move) != 5)) {
        return "Piece promotion missing from move."
    }

    state.whiteToPlay = (pieceToMove > 0)?false:true
    return "None"
}

isEmpty :: proc(target: i8) -> bool {
    return target == 0
}

containsOwnPiece :: proc(state: ^Game_State, ownColor: i8, target: i8) -> bool {
    return target * ownColor > 0
}

isNotAttacked :: proc(state: ^Game_State, x: i8, y: i8) -> bool {
    color: i8 = (state.whiteToPlay)? -1: 1
    //pawns
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
        if(target * color > 0) {
            //check for own piece
            break
        }
        if(target == color * QUEEN || target == color * ROOK){
            return false
        }
    }
    //left
    for i:i8=x-1; i>=0; i-=1 {
        target: i8 = state.board[y][i]
        if(target * color > 0) {
            //check for own piece
            break
        }
        if(target == color * QUEEN || target == color * ROOK){
            return false
        }
    }
    //down
    for i:i8=y+1; i<8; i+=1 {
        target: i8 = state.board[i][x]
        if(target * color > 0) {
            //check for own piece
            break
        }
        if(target == color * QUEEN || target == color * ROOK){
            return false
        }
    }
    //up
    for i:i8=y-1; i>=0; i-=1 {
        target: i8 = state.board[i][x]
        if(target * color > 0) {
            //check for own piece
            break
        }
        if(target == color * QUEEN || target == color * ROOK){
            return false
        }
    }

    //bishop (and half queen)
        //down right
    for i:i8=1; isOnBoard(x+i, y+i); i+=1 {
        target: i8 = state.board[y+i][x+i]
        if(target * color > 0) {
            //check for own piece
            break
        }
        if(target == color * QUEEN || target == color * BISHOP){
            return false
        }
    }
    //up right
    for i:i8=1; isOnBoard(x+i, y-i); i+=1 {
        target: i8 = state.board[y-i][x+i]
        if(target * color > 0) {
            //check for own piece
            break
        }
        if(target == color * QUEEN || target == color * BISHOP){
            return false
        }
    }
    //down left
    for i:i8=1; isOnBoard(x-i, y+i); i+=1 {
        target: i8 = state.board[y+i][x-i]
        if(target * color > 0) {
            //check for own piece
            break
        }
        if(target == color * QUEEN || target == color * BISHOP){
            return false
        }
    }
    //up left
    for i:i8=1; isOnBoard(x-i, y-i); i+=1 {
        target: i8 = state.board[y-i][x-i]
        if(target * color > 0) {
            //check for own piece
            break
        }
        if(target == color * QUEEN || target == color * BISHOP){
            return false
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
            if(state.board[i[1]][i[0]] == color * KNIGHT){
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
            if(state.board[i[1]][i[0]] == color * KING){
                return false
            }
        }
    }
    return true
}

isOnBoard :: proc(x: i8, y: i8) -> bool {
    return x >= 0 && x < 8 && y >= 0 && y < 8
}

getValidMoves :: proc(state: ^Game_State, targetPiece: string, fileToInt: map[u8]i8) -> [dynamic][2]i8 {
    pieceCoord : [2]u8 = {7-(targetPiece[1]-'1'), u8(fileToInt[targetPiece[0]])}
    pieceType : i8 = state.board[pieceCoord[0]][pieceCoord[1]]
    ownColor:i8 = state.board[pieceCoord[0]][pieceCoord[1]]>0?WHITE:BLACK
    enemyColor: i8 = state.board[pieceCoord[0]][pieceCoord[1]]>0?BLACK:WHITE

    validTargetMoves: [dynamic][2]i8

    switch(pieceType) {
        case BLACK*KING:
            if(!state.blackKingMoved && 
            isEmpty(state.board[0][1]) && isNotAttacked(state, 0, 1) &&
            isEmpty(state.board[0][2]) && isNotAttacked(state, 0, 2) &&
            isEmpty(state.board[0][3]) && isNotAttacked(state, 0, 3)) {
                append(&validTargetMoves, [2]i8{0, 2})
            }
            if(!state.blackKingMoved && 
            isEmpty(state.board[0][5]) && isNotAttacked(state, 0, 5) &&
            isEmpty(state.board[0][6]) && isNotAttacked(state, 0, 6)) {
                append(&validTargetMoves, [2]i8{0, 6})
            }
            for i in -1..=1 {
                for j in -1..=1{
                    if(isOnBoard(i8(pieceCoord[0])+i8(i), i8(pieceCoord[1])+i8(j)) &&
                    !containsOwnPiece(state, ownColor, (state.board[i8(pieceCoord[0])+i8(i)][i8(pieceCoord[1])+i8(j)]))&&
                    isNotAttacked(state, i8(pieceCoord[0])+i8(i), i8(pieceCoord[1])+i8(j))) {
                        append(&validTargetMoves, [2]i8{i8(pieceCoord[0])+i8(i), i8(pieceCoord[1])+i8(j)})
                    }
                }
            }
        case WHITE*KING:
            if(!state.whiteKingMoved && 
            isEmpty(state.board[7][1]) && isNotAttacked(state, 7, 1) &&
            isEmpty(state.board[7][2]) && isNotAttacked(state, 7, 2) &&
            isEmpty(state.board[7][3]) && isNotAttacked(state, 7, 3)) {
                append(&validTargetMoves, [2]i8{7, 2})
            }
            if(!state.whiteKingMoved && 
            isEmpty(state.board[7][5]) && isNotAttacked(state, 7, 5) &&
            isEmpty(state.board[7][6]) && isNotAttacked(state, 7, 6)) {
                append(&validTargetMoves, [2]i8{7, 6})
            }
            for i in -1..=1 {
                for j in -1..=1 {
                    if(isOnBoard(i8(pieceCoord[0])+i8(i), i8(pieceCoord[1])+i8(j)) &&
                    !containsOwnPiece(state, ownColor, (state.board[i8(pieceCoord[0])+i8(i)][i8(pieceCoord[1])+i8(j)]))&&
                    isNotAttacked(state, i8(pieceCoord[0])+i8(i), i8(pieceCoord[1])+i8(j))) {
                        append(&validTargetMoves, [2]i8{i8(pieceCoord[0])+i8(i), i8(pieceCoord[1])+i8(j)})
                    }
                }
            }
        case BLACK*QUEEN:
            fallthrough
        case WHITE*QUEEN:
            checkNorth: bool = true
            checkNorthEast: bool = true
            checkEast: bool = true
            checkSouthEast: bool = true
            checkSouth: bool = true
            checkSouthWest: bool = true
            checkWest: bool = true
            checkNorthWest: bool = true
            for i in 1..=7 {
                if(checkNorth) {
                    if(isOnBoard(i8(pieceCoord[0]) - i8(i), i8(pieceCoord[1]))) {
                        if(isEmpty(state.board[i8(pieceCoord[0])-i8(i)][i8(pieceCoord[1])])) {
                            append(&validTargetMoves, [2]i8{i8(pieceCoord[0])-i8(i), i8(pieceCoord[1])})
                        }
                        else {
                            if((state.whiteToPlay?WHITE:BLACK) * state.board[i8(pieceCoord[0])-i8(i)][i8(pieceCoord[1])] > 0) {
                                append(&validTargetMoves, [2]i8{i8(pieceCoord[0])-i8(i), i8(pieceCoord[1])})
                            }
                            checkNorth = false
                        }
                    }
                }
                if(checkNorthEast) {
                    if(isOnBoard(i8(pieceCoord[0]) - i8(i), i8(pieceCoord[1]) + i8(i))) {
                        if(isEmpty(state.board[i8(pieceCoord[0])-i8(i)][i8(pieceCoord[1])+i8(i)])) {
                            append(&validTargetMoves, [2]i8{i8(pieceCoord[0])-i8(i), i8(pieceCoord[1])+i8(i)})
                        }
                        else {
                            if((state.whiteToPlay?WHITE:BLACK) * state.board[i8(pieceCoord[0])-i8(i)][i8(pieceCoord[1])+i8(i)] > 0) {
                                append(&validTargetMoves, [2]i8{i8(pieceCoord[0])-i8(i), i8(pieceCoord[1])+i8(i)})
                            }
                            checkNorthEast = false
                        }
                    }
                }
                if(checkEast) {
                    if(isOnBoard(i8(pieceCoord[0]), i8(pieceCoord[1]) + i8(i))) {
                        if(isEmpty(state.board[i8(pieceCoord[0])][i8(pieceCoord[1])+i8(i)])) {
                            append(&validTargetMoves, [2]i8{i8(pieceCoord[0]), i8(pieceCoord[1])+i8(i)})
                        }
                        else {
                            if(enemyColor * state.board[i8(pieceCoord[0])][i8(pieceCoord[1])+i8(i)] > 0) {
                                append(&validTargetMoves, [2]i8{i8(pieceCoord[0]), i8(pieceCoord[1])+i8(i)})
                            }
                            checkEast = false
                        }
                    }
                }
                if(checkSouthEast) {
                    if(isOnBoard(i8(pieceCoord[0]) + i8(i), i8(pieceCoord[1]) + i8(i))) {
                        if(isEmpty(state.board[i8(pieceCoord[0])+i8(i)][i8(pieceCoord[1])+i8(i)])) {
                            append(&validTargetMoves, [2]i8{i8(pieceCoord[0])+i8(i), i8(pieceCoord[1])+i8(i)})
                        }
                        else {
                            if(enemyColor * state.board[i8(pieceCoord[0])+i8(i)][i8(pieceCoord[1])+i8(i)] > 0) {
                                append(&validTargetMoves, [2]i8{i8(pieceCoord[0])+i8(i), i8(pieceCoord[1])+i8(i)})
                            }
                            checkSouthEast = false
                        }
                    }
                }
                if(checkSouth) {
                    if(isOnBoard(i8(pieceCoord[0]) + i8(i), i8(pieceCoord[1]))) {
                        if(isEmpty(state.board[i8(pieceCoord[0])+i8(i)][i8(pieceCoord[1])])) {
                            append(&validTargetMoves, [2]i8{i8(pieceCoord[0])+i8(i), i8(pieceCoord[1])})
                        }
                        else {
                            if(enemyColor * state.board[i8(pieceCoord[0])+i8(i)][i8(pieceCoord[1])] > 0) {
                                append(&validTargetMoves, [2]i8{i8(pieceCoord[0])+i8(i), i8(pieceCoord[1])})
                            }
                            checkSouth = false
                        }
                    }
                }
                if(checkSouthWest) {
                    if(isOnBoard(i8(pieceCoord[0]) + i8(i), i8(pieceCoord[1]) - i8(i))) {
                        if(isEmpty(state.board[i8(pieceCoord[0])+i8(i)][i8(pieceCoord[1])-i8(i)])) {
                            append(&validTargetMoves, [2]i8{i8(pieceCoord[0])+i8(i), i8(pieceCoord[1])-i8(i)})
                        }
                        else {
                            if(enemyColor * state.board[i8(pieceCoord[0])+i8(i)][i8(pieceCoord[1])-i8(i)] > 0) {
                                append(&validTargetMoves, [2]i8{i8(pieceCoord[0])+i8(i), i8(pieceCoord[1])-i8(i)})
                            }
                            checkSouthWest = false
                        }
                    }
                }
                if(checkWest) {
                    if(isOnBoard(i8(pieceCoord[0]), i8(pieceCoord[1]) - i8(i))) {
                        if(isEmpty(state.board[i8(pieceCoord[0])][i8(pieceCoord[1])-i8(i)])) {
                            append(&validTargetMoves, [2]i8{i8(pieceCoord[0]), i8(pieceCoord[1])-i8(i)})
                        }
                        else {
                            if(enemyColor * state.board[i8(pieceCoord[0])][i8(pieceCoord[1])-i8(i)] > 0) {
                                append(&validTargetMoves, [2]i8{i8(pieceCoord[0]), i8(pieceCoord[1])-i8(i)})
                            }
                            checkWest = false
                        }
                    }
                }
                if(checkNorthWest) {
                    if(isOnBoard(i8(pieceCoord[0]) - i8(i), i8(pieceCoord[1]) - i8(i))) {
                        if(isEmpty(state.board[i8(pieceCoord[0])-i8(i)][i8(pieceCoord[1])-i8(i)])) {
                            append(&validTargetMoves, [2]i8{i8(pieceCoord[0])-i8(i), i8(pieceCoord[1])-i8(i)})
                        }
                        else {
                            if(enemyColor * state.board[i8(pieceCoord[0])-i8(i)][i8(pieceCoord[1])-i8(i)] > 0) {
                                append(&validTargetMoves, [2]i8{i8(pieceCoord[0])-i8(i), i8(pieceCoord[1])-i8(i)})
                            }
                            checkNorthWest = false
                        }
                    }
                }
            }
        // case BLACK*ROOK:
        //     fallthrough
        // case WHITE*ROOK:
        // case BLACK*KNIGHT:
        //     fallthrough
        // case WHITE*KNIGHT:
        // case BLACK*BISHOP:
        //     fallthrough
        // case WHITE*BISHOP:
        // case BLACK*PAWN:
            
        // case WHITE*PAWN:
    }
    return validTargetMoves
}

logBoard :: proc(board : [8][8]i8) {
    numToPiece:= make(map[i8]u8)
    numToPiece[0] = ' '
    numToPiece[1] = 'P'
    numToPiece[2] = 'B'
    numToPiece[3] = 'N'
    numToPiece[4] = 'R'
    numToPiece[5] = 'Q'
    numToPiece[6] = 'K'
    fmt.println(" ---------------------------------")
    for i in board {
        for j in i {
            fmt.print(" | ")
            fmt.print(rune(numToPiece[(j<0)?-j:j]))
        }
        fmt.println(" | ")
        fmt.println(" ---------------------------------")
    }
}

rlBoard :: proc(board: [8][8]i8) {
    screenWidth : i32 = 800
    screenHeight : i32 = 800

    rl.SetTraceLogLevel(rl.TraceLogLevel.WARNING)

    rl.InitWindow(screenWidth, screenHeight, "Chess Board")

    rl.SetTargetFPS(60)

    for !rl.WindowShouldClose() {
        rl.BeginDrawing()

        rl.ClearBackground(rl.RAYWHITE)
        for i in 0..=7 {
            for j in 0..=7 {
                rl.DrawRectangle(
                    i32(i*100),
                    i32(j*100),
                    100,
                    100,
                    ((i+j)%2 == 1)?rl.GRAY:rl.WHITE
                )
                switch(board[j][i]) {
                    case -6:
                        rl.DrawText("K",i32(i*100)+30,i32(j*100)+30,50,rl.BLACK)
                    case -5:
                        rl.DrawText("Q",i32(i*100)+30,i32(j*100)+30,50,rl.BLACK)
                    case -4:
                        rl.DrawText("R",i32(i*100)+30,i32(j*100)+30,50,rl.BLACK)
                    case -3:
                        rl.DrawText("N",i32(i*100)+30,i32(j*100)+30,50,rl.BLACK)
                    case -2:
                        rl.DrawText("B",i32(i*100)+30,i32(j*100)+30,50,rl.BLACK)
                    case -1:
                        rl.DrawText("P",i32(i*100)+30,i32(j*100)+30,50,rl.BLACK)
                    case 1:
                        rl.DrawText("p",i32(i*100)+30,i32(j*100)+30,50,rl.BLACK)
                    case 2:
                        rl.DrawText("b",i32(i*100)+30,i32(j*100)+30,50,rl.BLACK)
                    case 3:
                        rl.DrawText("n",i32(i*100)+30,i32(j*100)+30,50,rl.BLACK)
                    case 4:
                        rl.DrawText("r",i32(i*100)+30,i32(j*100)+30,50,rl.BLACK)
                    case 5:
                        rl.DrawText("q",i32(i*100)+30,i32(j*100)+30,50,rl.BLACK)
                    case 6:
                        rl.DrawText("k",i32(i*100)+30,i32(j*100)+30,50,rl.BLACK)
                }
            }
        }
        rl.EndDrawing()
    }
    rl.CloseWindow()
}