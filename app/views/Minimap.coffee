config = require 'config'

class MinimapView
  constructor: (@tileMapModel, @entityManagerView, @viewportModel, @doShadows = false) ->
    @el = new createjs.Container

    #@el.shadow = new createjs.Shadow 'rgba(0, 0, 0, 0.6)', 1, 1, 0

    minimapWidth = config.minimapOptions.tileWidth * config.worldTileWidth
    minimapHeight = config.minimapOptions.tileHeight * config.worldTileHeight

    @backgroundEl = new createjs.Shape
    @backgroundEl.graphics.beginFill('#000000').drawRect 0, 0, minimapWidth, minimapHeight
    @backgroundEl.cache 0, 0, minimapWidth, minimapHeight
    @el.addChild @backgroundEl

    @terrainEl = new createjs.Shape
    @buildTileViews()
    @el.addChild @terrainEl

    @entityEl = new createjs.Shape
    @el.addChild @entityEl

    @shadowEl = new createjs.Shape
    #@el.addChild @shadowEl

    @overlayEl = new createjs.Shape
    @el.addChild @overlayEl

    @drawEntityViews()
    @drawShadowViews() if @doShadows
    @drawOverlayView()

    EventBus.addEventListener '!viewport:move', @drawView, this

  drawEntityViews: ->
    entityModels = @entityManagerView.entityModels

    el = @entityEl

    el.graphics.clear()

    tileWidth = config.minimapOptions.tileWidth
    tileHeight = config.minimapOptions.tileHeight

    minimapWidth = config.minimapOptions.tileWidth * config.worldTileWidth
    minimapHeight = config.minimapOptions.tileHeight * config.worldTileHeight

    for entityModel in entityModels
      continue if entityModel.skipMinimap

      entityX = entityModel.x * tileWidth
      entityY = entityModel.y * tileHeight

      el.graphics.beginFill(entityModel.minimapColor).drawRect(entityX, entityY, tileWidth, tileHeight)

    el.cache 0, 0, minimapWidth, minimapHeight

  buildTileViews: ->
    tileValues = @tileMapModel.getAllCells()

    tileWidth = config.minimapOptions.tileWidth
    tileHeight = config.minimapOptions.tileHeight

    for y in [0..tileValues.length - 1]
      for x in [0..tileValues[y].length - 1]
        tileValue = tileValues[y][x]

        color = ['#02b0fa', '#e3c486', '#00b017', '#00b017'][Math.floor(tileValue / 2)]
        #color = ['rgba(0, 0, 0, 0)', 'rgba(0, 0, 0, 0)', '#00b017', '#00b017'][Math.floor(tileValue / 2)]

        tileX = x * config.minimapOptions.tileWidth
        tileY = y * config.minimapOptions.tileHeight

        @terrainEl.graphics.beginFill(color).drawRect(tileX, tileY, tileWidth, tileHeight)

    minimapWidth = config.minimapOptions.tileWidth * config.worldTileWidth
    minimapHeight = config.minimapOptions.tileHeight * config.worldTileHeight

    @terrainEl.cache 0, 0, minimapWidth, minimapHeight

  drawShadowViews: ->
    tileValues = @tileMapModel.getAllCells()

    tileWidth = config.minimapOptions.tileWidth
    tileHeight = config.minimapOptions.tileHeight

    @shadowEl.graphics.clear()

    minimapWidth = config.minimapOptions.tileWidth * config.worldTileWidth
    minimapHeight = config.minimapOptions.tileHeight * config.worldTileHeight

    #@shadowEl.graphics.beginFill('#000000').drawRect(0, 0, minimapWidth, minimapHeight)

    for index, discoveredTile of @viewportModel.discoveredTiles
      coords = index.split '_'
      x = +coords[0]
      y = +coords[1]
      tileX = x * config.minimapOptions.tileWidth
      tileY = y * config.minimapOptions.tileHeight

      tileValue = tileValues[y][x]

      color = '#000000'

      @shadowEl.graphics.beginFill(color).drawRect(tileX, tileY, tileWidth, tileHeight)

    @shadowEl.cache 0, 0, minimapWidth, minimapHeight

    @terrainEl.filters = [
      new createjs.AlphaMaskFilter(@shadowEl.cacheCanvas)
    ]

    @entityEl.filters = [
      new createjs.AlphaMaskFilter(@shadowEl.cacheCanvas)
    ]

    @terrainEl.cache 0, 0, minimapWidth, minimapHeight
    @entityEl.cache 0, 0, minimapWidth, minimapHeight

  drawView: ->
    @drawEntityViews()
    @drawOverlayView()
    @drawShadowViews() if @doShadows

  drawOverlayView: ->
    el = @overlayEl

    width = config.viewportOptions.width * config.minimapOptions.tileWidth
    height = config.viewportOptions.height * config.minimapOptions.tileHeight

    halfWidth = Math.floor width / 2
    halfHeight = Math.floor height / 2

    x = (@viewportModel.x * config.minimapOptions.tileWidth) - halfWidth
    y = (@viewportModel.y * config.minimapOptions.tileHeight) - halfHeight

    w = config.worldTileWidth * config.minimapOptions.tileWidth
    h = config.worldTileHeight * config.minimapOptions.tileHeight

    #el.shadow = new createjs.Shadow '#000000', 1, 1, 0

    g = el.graphics
    g.clear()
    g.setStrokeStyle(2, 'square')

    g.setStrokeStyle(2, 'square')
    g.beginStroke('rgba(0, 0, 136, 0.6)')
    g.drawRect x + width / 2 + 1, y + height / 2 + 1, 2, 2

    g.beginStroke('rgba(255, 255, 0, 0.6)')
    g.drawRect x, y, width, height # center
    g.drawRect x - w, y, width, height # west
    g.drawRect x - w, y - h, width, height # north west
    g.drawRect x + w, y, width, height # east
    g.drawRect x + w, y - h, width, height # north east
    g.drawRect x + w, y + h, width, height # south east
    g.drawRect x - w, y + h, width, height # south west
    g.drawRect x, y + h, width, height # south
    g.drawRect x, y - h, width, height # north

    el.cache 0, 0, w, h

  dispose: ->
    EventBus.removeEventListener '!viewport:move', @drawView, this

module.exports = MinimapView
