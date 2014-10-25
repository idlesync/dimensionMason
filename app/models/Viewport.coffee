class ViewportModel
  constructor: (@x, @y, @width, @height) ->
    @discoveredTiles = {}

  setPosition: (x, y) ->
    if y isnt @y or x isnt @x
      @x = x
      @y = y

      EventBus.dispatch "!viewport:move", this

  dispose: ->

module.exports = ViewportModel
