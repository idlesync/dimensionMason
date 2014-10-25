TileModel = require 'models/Tile'
TileView = require 'views/Tile'
ShadowView = require 'views/Shadow'
config = require 'config'
utils = require 'utils'

class ViewportView
  constructor: (@viewportModel, @tileMapModel) ->
    @el = new createjs.Container
    @tileLayerEl = new createjs.Container
    @el.addChild @tileLayerEl

    @tileViewLookup = {}
    @tileModelLookup = {}
    @buildTileModels()
    @buildTileViews()
    @tileLayerEl.addChild(tileView.el) for index, tileView of @tileViewLookup

    EventBus.addEventListener '!viewport:move', @drawMap, this

    @cacheGraphics()

  addShadowLayer: (el, @shadowCutoff, @shadowRange) ->
    @shadowLayerEl = new createjs.Container

    @shadowViewLookup = {}
    @buildShadowViews()
    @shadowLayerEl.addChild(shadowView.el) for index, shadowView of @shadowViewLookup

    EventBus.addEventListener '!viewport:move', @drawShadows, this

    el.addChild @shadowLayerEl

  buildShadowViews: ->
    offsetX = Math.floor config.tileWidth / 2
    offsetY = Math.floor config.tileHeight / 2

    width = @viewportModel.width + 1
    height = @viewportModel.height + 1

    for y in [0..height - 1]
      for x in [0..width - 1]
        shadowView = new ShadowView

        shadowView.el.x = x * config.tileWidth - offsetX
        shadowView.el.y = y * config.tileHeight - offsetY

        @shadowViewLookup["#{x}_#{y}"] = shadowView

    @doShadows()

  drawShadows: ->
    shadowView.setShadow(1, 1) for index, shadowView of @shadowViewLookup

    @doShadows()
    @cacheGraphics()

  buildTileViews: ->
    offsetX = Math.floor config.tileWidth / 2
    offsetY = Math.floor config.tileHeight / 2

    width = @viewportModel.width + 1
    height = @viewportModel.height + 1

    for y in [0..height - 1]
      for x in [0..width - 1]
        tileModel = @tileModelLookup["#{x}_#{y}"]
        tileView = new TileView tileModel

        tileView.el.x = tileModel.x * config.tileWidth - offsetX
        tileView.el.y = tileModel.y * config.tileHeight - offsetY

        @tileViewLookup["#{x}_#{y}"] = tileView

  buildTileModels: ->
    width = @viewportModel.width
    height = @viewportModel.height
    x = @viewportModel.x
    y = @viewportModel.y

    tileMapData = @tileMapModel.getArea width + 1, height + 1, x - 1, y

    for y in [0..tileMapData.length - 1]
      for x in [0..tileMapData[y].length - 1]
        tileModel = new TileModel tileMapData[y][x], x, y
        @tileModelLookup["#{x}_#{y}"] = tileModel

  drawMap: ->
    width = @viewportModel.width
    height = @viewportModel.height
    vx = @viewportModel.x
    vy = @viewportModel.y

    tileMapData = @tileMapModel.getArea width + 1, height + 1, vx - 1, vy

    for y in [0..tileMapData.length - 1]
      for x in [0..tileMapData[y].length - 1]
        tileModel = @tileModelLookup["#{x}_#{y}"]

        tileModel.setTileIndex tileMapData[y][x]

    @cacheGraphics()

  doShadows: ->
    fov = new ROT.FOV.PreciseShadowcasting (x, y) =>
      val = @tileMapModel.getCell x, y

      val >= @shadowCutoff

    width = @viewportModel.width
    height = @viewportModel.height
    vx = @viewportModel.x
    vy = @viewportModel.y
    vpx = vx - Math.floor(width / 2) - 1
    vpy = vy - Math.floor(height / 2) - 1

    fov.compute @viewportModel.x, @viewportModel.y, @shadowRange, (x, y, r, visibility) =>
      if visibility isnt 0
        @viewportModel.discoveredTiles["#{x}_#{y}"] = true

      x -= vpx
      y -= vpy
      shadowView = @shadowViewLookup["#{x}_#{y}"]

      shadowView.setShadow(1 - visibility, r / @shadowRange) if shadowView?

  cacheGraphics: ->
    width = @viewportModel.width
    height = @viewportModel.height

    @el.cache 0, 0, width * config.tileWidth, height * config.tileHeight

  removeShadowLayer: (el) ->
    EventBus.removeEventListener '!viewport:move', @drawShadows, this
    @shadowLayerEl.removeChild(shadowView.el) for index, shadowView of @tileViewLookup
    shadowView.dispose() for index, shadowView of @shadowViewLookup

    el.removeChild @shadowLayerEl

  dispose: ->
    EventBus.removeEventListener '!viewport:move', @drawMap, this
    @tileLayerEl.removeChild(tileView.el) for index, tileView of @tileViewLookup
    @el.removeChild @tileLayerEl
    tileModel.dispose() for index, tileModel of @tileModelLookup
    tileView.dispose() for index, tileView of @tileViewLookup

module.exports = ViewportView
