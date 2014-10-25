utils = require 'utils'

class DungeonGenerator
  constructor: (@seed, @options, cacheTiles = true) ->
    ROT.RNG.setSeed @seed

    diggerOptions =
  		roomWidth: [3, 7]
  		roomHeight: [3, 7]
  		dugPercentage: 0.06
  		timeLimit: 1000 * 5
  		corridorLength: [3, 6]

    #@map= new ROT.Map.Digger @options.size, @options.size, diggerOptions
    @map = new ROT.Map.Rogue @options.size, @options.size

    @tileCache = []

    @tileTypes = []

    @cacheAllTiles() if cacheTiles

  getStartPosition: ->
    #startPos = @map.getRooms()[0]

    #{x: startPos._x1, y: startPos._y1}
    room = @map.rooms[0][0]
    {x: room.x + 1, y: room.y + 1}

  getFinishPosition: ->
    rooms = @map.getRooms()
    endPos = rooms[rooms.length - 1]

    {x: endPos._x1 + 1, y: endPos._y1 + 1}

  getAllCells: ->
    @tileCache

  cacheAllTiles: ->
    @tileCache = []

    @map.create (x, y, value) =>
      value = +(!value)
      @tileCache[y] = [] if @tileCache[y] is undefined
      @tileCache[y][x] = value * 4

    for y in [0..@tileCache.length - 1]
      for x in [0..@tileCache[y].length - 1]
        cell = @tileCache[y][x]
        if cell is 4
          for yy in [(y-1)..(y+1)]
            for xx in [(x-1)..(x+1)]
              if @tileCache[yy][xx] is 0
                @tileCache[yy][xx] = 2

    for y in [0..@tileCache.length - 1]
      for x in [0..@tileCache[y].length - 1]
        cellValue = @tileCache[y][x]
        index = Math.floor cellValue / 2
        @tileTypes[index] = [] if @tileTypes[index] is undefined
        @tileTypes[index].push {x, y}

  getCell: (worldX, worldY) ->
    if @tileCache[worldY] and @tileCache[worldY][worldX]?
      return @tileCache[worldY][worldX]

module.exports = DungeonGenerator
