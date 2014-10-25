utils = require 'utils'
config = require 'config'

class TileMapModel
  constructor: (generatorOptions, seed) ->
    @spritesheetOffset = generatorOptions.options.spritesheetOffset

    MapGenerator = require generatorOptions.location
    @mapGenerator = new MapGenerator seed, generatorOptions.options
    @tileCache = {}

  getCell: (x, y) ->
    x = utils.clamp x, config.worldTileWidth
    y = utils.clamp y, config.worldTileHeight

    @mapGenerator.getCell x, y

  getStartPosition: (seed) ->
    @mapGenerator.getStartPosition seed

  getFinishPosition: (seed) ->
    @mapGenerator.getFinishPosition seed

  getAllCells: ->
    @mapGenerator.getAllCells()

  getTileTypes: ->
    @mapGenerator.tileTypes

  getArea: (sliceWidth, sliceHeight, centerX, centerY) ->
    tileMapData = []

    xOffset = Math.floor sliceWidth / 2
    yOffset = Math.floor sliceHeight / 2

    for y in [0..sliceHeight - 1]
      tileMapData[y] = []
      for x in [0..sliceWidth - 1]
        worldX = utils.clamp x - xOffset + centerX, config.worldTileWidth
        worldY = utils.clamp y - yOffset + centerY, config.worldTileHeight

        tileMapData[y][x] = @getTile worldX, worldY

    tileMapData

  getTile: (worldX, worldY) ->
    if @tileCache["#{worldX}_#{worldY}"] isnt undefined
      return @tileCache["#{worldX}_#{worldY}"]

    x = worldX
    y = worldY

    sTL = @mapGenerator.getCell x, y
    sTR = @mapGenerator.getCell x + 1, y
    sBL = @mapGenerator.getCell x, y + 1
    sBR = @mapGenerator.getCell x + 1, y + 1

    hTL = sTL >> 1
    hTR = sTR >> 1
    hBL = sBL >> 1
    hBR = sBR >> 1

    saddle = ((sTL & 1) + (sTR & 1) + (sBL & 1) + (sBR & 1) + 1) >> 2

    shape = (hTL & 1) | (hTR & 1) << 1 | (hBL & 1) << 2 | (hBR & 1) << 3

    ring = ( hTL + hTR + hBL + hBR ) >> 2

    tileID = shape | (saddle << 4) | (ring << 5)

    row = (ring << 1) | saddle;
    col = shape - (ring & 1)

    index = row * 16 + col
    index += @spritesheetOffset

    return @tileCache["#{worldX}_#{worldY}"] = index

module.exports = TileMapModel
