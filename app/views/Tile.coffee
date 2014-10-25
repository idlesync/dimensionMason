config = require 'config'
utils = require 'utils'

class TileView
  constructor: (@tileModel, @hasShadows = false) ->
    @el = new createjs.Bitmap utils.tilesetImg

    @tileModel.setIndexCallback =>
      @setTileIndex()

    @setTileIndex()

  setTileIndex: ->
    tileIndex = @tileModel.tileIndex

    x = tileIndex % 16
    y = Math.floor tileIndex / 16

    # tile width, height
    th = config.tileWidth
    tw = config.tileHeight

    # offsets
    ox = 0 # 1 + x
    oy = 0 # 1 + y

    @el.sourceRect = new createjs.Rectangle x * tw + ox, y * th + oy, tw, th

  dispose: ->

module.exports = TileView
