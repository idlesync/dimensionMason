config = require 'config'
LoadingScene = require 'scenes/Loading'

class StageView
  constructor: (canvasEl, sceneLocation) ->
    @el = new createjs.Stage canvasEl

    createjs.Ticker.setFPS config.fps
    createjs.Ticker.useRAF = true

    _.bindAll this, 'onTick'
    createjs.Ticker.addEventListener 'tick', @onTick
    EventBus.addEventListener '!scene:load', @onSceneLoad, this

  onSceneLoad: (event, sceneProperties) ->
    @loadScene sceneProperties.sceneLocation, sceneProperties.options

  loadScene: (sceneLocation, options) ->
    @disposeScene @scene

    loadingScene = new LoadingScene {sceneLocation, options}, (options) =>
      @disposeScene loadingScene

      Scene = require options.sceneLocation
      @scene = new Scene options.options

      @el.addChild @scene.el

    @el.addChild loadingScene.el

  onTick: ->
    @el.update()

  disposeScene: (scene) ->
    if scene
      @el.removeChild scene.el
      scene.dispose()

  dispose: ->
    @disposeScene @scene
    createjs.Ticker.removeEventListener 'tick', @onTick
    EventBus.removeEventListener '!scene:load', @onSceneLoad, this

module.exports = StageView
