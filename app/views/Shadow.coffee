config = require 'config'

class ShadowView
  constructor: ->
    @el = new createjs.Shape

    @setShadow 1, 1

  setShadow: (opacity, radius) ->
    @el.graphics.clear()

    return if opacity is 0

    @el.graphics.beginFill "rgba(0, 0, 0, #{opacity})"
    @el.graphics.drawRect 0 - (config.tileWidth / 2), 0 - (config.tileHeight / 2), config.tileWidth, config.tileHeight

  dispose: ->

module.exports = ShadowView
