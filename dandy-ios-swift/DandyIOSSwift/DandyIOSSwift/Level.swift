

import UIKit

let cellSymbols : [String] = [
  " ",
  "█",
  "D",
  "u",
  "d",
  "K",
  "F",
  "$",
  "i",
  "1",
  "2",
  "3",
  "♡",
  "a",
  "b",
  "c",
  "↙",
  "←",
  "↖",
  "↑",
  "↗",
  "→",
  "↘",
  "↓",
  "①",
  "②",
  "③",
  "④"
]

enum Cell : Byte {
  case Space
  case Wall
  case Door
  case Up
  case Down
  case Key
  case Food
  case Money
  case Bomb
  case Monster0, Monster1, Monster2
  case Heart
  case Generator0, Generator1, Generator2
  case Arrow0, Arrow1, Arrow2, Arrow3, Arrow4, Arrow5, Arrow6, Arrow7
  case Player0, Player1, Player2, Player3

  func description() -> String {
    return cellSymbols[Int(self.rawValue)]
  }

  func isEnemy() -> Bool {
    let rv = self.rawValue
    let m0 = Monster0.rawValue
    let g2 = Generator2.rawValue
    return rv >= m0 && rv <= g2
  }

  func isPlayer() -> Bool {
    let rv = self.rawValue
    let p0 = Player0.rawValue
    let p3 = Player3.rawValue
    return rv >= p0 && rv <= p3
  }
}

// Returns a tupple for the active region for a given x, y
func getActive(x: Float32, y: Float32, xView: Int, yView: Int, xMax : Int, yMax: Int) ->
  (x1 : Int, y1: Int, x2: Int, y2: Int) {
    let xa = getActiveAxis(x, xView, xMax)
    let ya = getActiveAxis(y, yView, yMax)
    return (xa.u1, ya.u1, xa.u2, ya.u2)
}

func getActiveAxis(u: Float32, uView: Int, uMax: Int) -> (u1: Int, u2: Int) {
  var x = u - Float32(uView) * 0.5
  x = max(x, 0.0)
  x = min(x, Float32(uMax - uView))
  let start = Int(x)
  let end = min(start + uView + 1, uMax)
  return (start, end)
}

class Level {
  let width: Int
  let height: Int
  var data: Array<Cell>
  init(width: Int, height: Int) {
    self.width = width
    self.height = height
    self.data = [Cell](count: Int(width * height), repeatedValue:Cell.Space)
  }

  func description() -> String {
    var s = ""
    for y in 0..<height {
      for x in 0..<width {
        s += self[x,y].description()
      }
      s += "\n"
    }
    return s
  }

  func read(data:NSData) {
    var b = UnsafePointer<Byte>(data.bytes)
    var i = 0
    for y in 0..<height {
      for var x = 0; x < width; x += 2 {
        let d = b[0]
        b++
        self.data[i++] = byteToCell(d & Byte(0xf))
        self.data[i++] = byteToCell((d >> 4) & Byte(0xf))
      }
    }
  }

  func find(cell:Cell) ->(Int, Int)? {
    let len = data.count
    for i in 0..<len {
      if data[i] == cell {
        let y = i / width
        let x = i - y * width
        return (x, y)
      }
    }
    return nil
  }

  func openDoor(x: Int, y: Int) {
    // Recursive flood fill from this coord
    if self[x,y] == Cell.Door {
      self[x, y] = Cell.Space
      for dy in max(0,y-1)...min(y+1, height-1) {
        for dx in max(0,x-1)...min(x+1, width-1) {
          openDoor(dx, y:dy)
        }
      }
    }
  }

  func byteToCell(d : Byte) -> Cell {
    if let c = Cell(rawValue:d) {
      return c
    }
    return Cell.Space
  }

  // Convert 2D coordinate to 1D index.
  func index(x : Int, y : Int) -> Int {
    if (x < 0 || x >= width || y < 0 || y >= height) {
      return -1
    }
    return x + width * y
  }

  subscript(i: Int) -> Cell {
    get {
      return data[i]
    }
    set {
      data[i] = newValue
    }
  }

  subscript(x :Int, y: Int) -> Cell {
    get {
      return data[index(x,y:y)]
    }
    set {
      data[index(x,y:y)] = newValue
    }
  }
}
