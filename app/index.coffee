CanvasAdapter = require 'adapters/Canvas'
StageView = require 'views/Stage'
config = require 'config'
utils = require 'utils'

utils.loadImages config.spriteSheetSource, ->
  canvasAdapter = new CanvasAdapter config.canvasAdapterOptions

  stageView = new StageView canvasAdapter.el, 'scenes/World'

  sceneLocation = 'scenes/World'
  options = {x: 0, y: 0}

  EventBus.dispatch '!scene:load', this, {sceneLocation, options}

  document.onkeydown = onKeyDown

onKeyDown = (event) ->
  EventBus.dispatch '!key:down', this, event
