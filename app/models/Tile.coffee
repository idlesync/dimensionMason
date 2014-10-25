class TileModel
  constructor: (@tileIndex, @x, @y) ->

  setTileIndex: (newTileIndex) ->
    if @tileIndex isnt newTileIndex
      @tileIndex = newTileIndex

      @onChangeTileIndex()

  setIndexCallback: (newCallback) ->
    @onChangeTileIndex = newCallback

  onChangeTileIndex: ->
    # meant to be overridden

  dispose: ->

module.exports = TileModel
