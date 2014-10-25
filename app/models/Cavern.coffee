class CavernModel
  minimapColor: '#880000'

  constructor: (@x, @y, @color) ->
    @minimapColor = ({'orange': '#bd6727', 'blue': '#4e62a5', 'green': '#76b8fa'})[@color]

  dispose: ->

module.exports = CavernModel
