class LoadingScene
  constructor: (@options, @callbackFn) ->
    @el = new createjs.Container

    _.bindAll this, 'onTick'
    @el.addEventListener 'tick', @onTick

    loadingEl = new createjs.Text 'Loading...', '26px Helvetica', '#333333'
    loadingEl.x = 10
    loadingEl.y = 10
    @el.addChild loadingEl

    @timer = undefined

  onTick: ->
    return if @timer
    @timer = setTimeout =>
      @callbackFn @options
      @timer = undefined
    , 1000 / 2

  dispose: ->
    createjs.Ticker.removeEventListener 'tick', @onTick

module.exports = LoadingScene
