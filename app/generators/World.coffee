utils = require 'utils'

class WorldGenerator
  constructor: (@seed, @options, cacheTiles = true) ->

    @tileCache = []
    @chunkCache = []

    @tileTypes = []

    @cacheAllTiles() if cacheTiles

  getStartPosition: (seed) ->
    grassTiles = @tileTypes[2]
    index = Math.floor utils.random(seed) * grassTiles.length
    grassTiles[index]

  getFinishPosition: (seed) ->
    grassTiles = @tileTypes[2]
    index = Math.floor utils.random(seed) * grassTiles.length
    grassTiles[index]

  getAllCells: ->
    return @tileCache

  cacheAllTiles: ->
    for y in [0..@options.worldChunkHeight - 1]
      for x in [0..@options.worldChunkWidth - 1]
        chunk = @getChunk x, y

        for cy in [0..chunk.length - 1]
          for cx in [0..chunk[cy].length - 1]
            vx = x * @options.chunkTileWidth + cx
            vy = y * @options.chunkTileHeight + cy

            cellValue = @getCell vx, vy

            index = Math.floor cellValue / 2
            @tileTypes[index] = [] if @tileTypes[index] is undefined
            @tileTypes[index].push {x:vx, y:vy}

  getCell: (worldX, worldY) ->
    if @tileCache[worldY] and @tileCache[worldY][worldX]?
      return @tileCache[worldY][worldX]

    worldChunkX = Math.floor worldX / @options.chunkTileWidth
    worldChunkY = Math.floor worldY / @options.chunkTileHeight
    chunkX = worldX % @options.chunkTileWidth
    chunkY = worldY % @options.chunkTileHeight

    chunk = @getChunk worldChunkX, worldChunkY

    cell = Math.floor chunk[chunkY][chunkX] * @options.maxHeight

    @tileCache[worldY] = [] unless @tileCache[worldY]?
    @tileCache[worldY][worldX] = cell

    cell

  getChunk: (worldChunkX, worldChunkY) ->
    row0 = [
        @chunkEdgeIndex worldChunkX - 1, worldChunkY - 1
        @chunkEdgeIndex worldChunkX, worldChunkY - 1
        @chunkEdgeIndex worldChunkX + 1, worldChunkY - 1
        @chunkEdgeIndex worldChunkX + 2, worldChunkY - 1
      ]
    row1 = [
        @chunkEdgeIndex worldChunkX - 1, worldChunkY
        @chunkEdgeIndex worldChunkX, worldChunkY
        @chunkEdgeIndex worldChunkX + 1, worldChunkY
        @chunkEdgeIndex worldChunkX + 2, worldChunkY
      ]
    row2 = [
        @chunkEdgeIndex worldChunkX - 1, worldChunkY + 1
        @chunkEdgeIndex worldChunkX, worldChunkY + 1
        @chunkEdgeIndex worldChunkX + 1, worldChunkY + 1
        @chunkEdgeIndex worldChunkX + 2, worldChunkY + 1
      ]
    row3 = [
        @chunkEdgeIndex worldChunkX - 1, worldChunkY + 2
        @chunkEdgeIndex worldChunkX, worldChunkY + 2
        @chunkEdgeIndex worldChunkX + 1, worldChunkY + 2
        @chunkEdgeIndex worldChunkX + 2, worldChunkY + 2
      ]

    chunkTileWidth = @options.chunkTileWidth
    chunkTileHeight = @options.chunkTileHeight
    @bilinearInterpolate chunkTileWidth, chunkTileHeight, row0, row1, row2, row3


  chunkEdgeIndex: (x, y) ->
    width = @options.worldChunkWidth
    height = @options.worldChunkHeight
    seed = @seed

    x = @clamp x, width
    y = @clamp y, height

    utils.random(y * width + x + seed)

  bilinearInterpolate: (width, height, row0, row1, row2, row3) ->
    cells = []

    for y in [0..height - 1]
      cells[y] = []
      yFactor = y / height

      for x in [0..width - 1]
        xFactor = x / width

        i0 = @terp xFactor, row0[0], row0[1], row0[2], row0[3]
        i1 = @terp xFactor, row1[0], row1[1], row1[2], row1[3]
        i2 = @terp xFactor, row2[0], row2[1], row2[2], row2[3]
        i3 = @terp xFactor, row3[0], row3[1], row3[2], row3[3]

        cells[y][x] = @terp yFactor, i0, i1, i2, i3

    cells

  terp: (t, a, b, c, d) ->
    val = 0.5 * (c - a + (2.0*a - 5.0*b + 4.0*c - d + (3.0*(b - c) + d - a)*t)*t)*t + b

    val = Math.max 0, val
    val = Math.min 1, val

    val

  clamp: (index, size) ->
    (index + size) % size

module.exports = WorldGenerator
