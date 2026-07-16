package chess

fileToInt:: proc(char: u8) -> i8 {
    switch char {
    case 'A': return 0
    case 'B': return 1
    case 'C': return 2
    case 'D': return 3
    case 'E': return 4
    case 'F': return 5
    case 'G': return 6
    case 'H': return 7
    case 'a': return 0
    case 'b': return 1
    case 'c': return 2
    case 'd': return 3
    case 'e': return 4
    case 'f': return 5
    case 'g': return 6
    case 'h': return 7
    }
    // error
    panic("Invalid file passed to fileToInt")
}

fileToChar:: proc(num: i8) -> u8 {
    switch num {
    case 0: return 'a' 
    case 1: return 'b'
    case 2: return 'c'
    case 3: return 'd'
    case 4: return 'e'
    case 5: return 'f'
    case 6: return 'g'
    case 7: return 'h'
    }
    //error
    panic("Invalid file passed to fileToChar")
}

moveStringToArray :: proc(input: string) -> [2][2]i8 {
    result:[2][2]i8
    result[0][0]=i8(7-(input[1]-'1'))
    result[0][1]=i8(fileToInt(input[0]))
    result[1][0]=i8(7-(input[3]-'1'))
    result[1][1]=i8(fileToInt(input[2]))

    return result
}