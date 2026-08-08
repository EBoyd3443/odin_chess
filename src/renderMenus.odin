package chess

import rl "vendor:raylib"

rlMain :: proc(screen: ^Render_Screens) {
    rl.BeginDrawing()

    rl.ClearBackground(rl.RAYWHITE)
    
    startBox: rl.Rectangle = {
        x = 300,
        y = 300,
        width = 200,
        height = 50
    }
    if(rl.GuiButton(startBox, "START")) {
        screen^ = Render_Screens.game
    }

    settingsBox: rl.Rectangle = {
        x = 300,
        y = 400,
        width = 200,
        height = 50
    }
    if(rl.GuiButton(settingsBox, "SETTINGS")) {
        screen^ = Render_Screens.settings
    }
    rl.EndDrawing()
}

rlSettings :: proc(state: ^Shared_State) {
    rl.BeginDrawing()

    rl.ClearBackground(rl.RAYWHITE)

    freeplayBox: rl.Rectangle = {
        x = 300,
        y = 300,
        width = 200,
        height = 50
    }
    if(rl.GuiButton(freeplayBox, "FREEPLAY")) {
        state.gameType = Game_Type.freeplay
    }

    aiBox: rl.Rectangle = {
        x = 300,
        y = 400,
        width = 200,
        height = 50
    }
    if(rl.GuiButton(aiBox, "AI")) {
        state.gameType = Game_Type.ai
    }
    
    backBox: rl.Rectangle = {
        x = 300,
        y = 500,
        width = 200,
        height = 50
    }
    if(rl.GuiButton(backBox, "BACK")) {
        state.renderScreen = Render_Screens.main
    }
    rl.EndDrawing()
}