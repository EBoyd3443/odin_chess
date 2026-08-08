package chess

import "core:fmt"
import "core:sync"
import rl "vendor:raylib"

SCREEN_WIDTH : i32 = 800
SCREEN_HEIGHT : i32 = 900

rlWindow :: proc(state: ^Shared_State) {
    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Chess")
    
    rl.SetTraceLogLevel(rl.TraceLogLevel.WARNING)

    rl.SetTargetFPS(60)

    glyphs:= [6]rune{
        0x265A, // ♚
        0x265B, // ♛
        0x265C, // ♜
        0x265D, // ♝
        0x265E, // ♞
        0x265F, // ♟
    }
    glyphFont : rl.Font = rl.LoadFontEx("/home/ericb/Projects/odin/Projects/chess/src/FreeSerif.ttf", 160, &glyphs[0], i32(len(glyphs)))

    for !rl.WindowShouldClose() {
        sync.mutex_lock(&state.mutex)
        switch state.renderScreen {
            case Render_Screens.main:
                rlMain(&state.renderScreen)
            case Render_Screens.settings:
                rlSettings(state)
            case Render_Screens.game:
                rlBoard(state, glyphFont)
            case:
        }
        sync.mutex_unlock(&state.mutex)
    }
    rl.UnloadFont(glyphFont)
    rl.CloseWindow()
}