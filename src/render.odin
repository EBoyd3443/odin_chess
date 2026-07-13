package chess

import rl "vendor:raylib"

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