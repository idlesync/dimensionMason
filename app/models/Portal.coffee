utils = require 'utils'
config = require 'config'

class PortalModel
  minimapColor: '#ff0000'

  constructor: (@x, @y, @worldX, @worldY, @color) ->
    @minimapColor = ({'blue': '#00ffff', 'yellow': '#880000'})[color]

  dispose: ->

module.exports = PortalModel
