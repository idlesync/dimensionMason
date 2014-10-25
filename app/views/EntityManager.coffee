CreatureModel = require 'models/Creature'
CreatureView = require 'views/Creature'
config = require 'config'
utils = require 'utils'

class EntityManagerView
  constructor: (@viewportModel, @tileMapModel, seed) ->
    @el = new createjs.Container

    @_seed = seed

    @occupiedPositions = {}

    @entityModels = []
    @entityViews = []

    EventBus.addEventListener '!viewport:move', @onViewportMove, this

    @cacheCanvas()

  createHero: ->
    @creatureModel = new CreatureModel @viewportModel.x, @viewportModel.y, 'blue'
    @creatureView = new CreatureView @creatureModel, @viewportModel

    @creatureModel.skipMinimap = true

    @addEntity @creatureModel, @creatureView

    @cacheCanvas()

  getTileTypes: (tileType) ->
    tiles = @tileMapModel.getTileTypes()

    return [] if tiles.length is 0

    tiles[tileType]

  isOccupied: (worldX, worldY) ->
    @occupiedPositions["#{worldX}_#{worldY}"] is true

  addEntity: (entityModel, entityView) ->
    @entityModels.push entityModel
    @entityViews.push entityView
    @el.addChild entityView.el
    @occupiedPositions["#{entityModel.x}_#{entityModel.y}"] = true

  removeEntity: (entityModel, entityView) ->
    @occupiedPositions["#{entityModel.x}_#{entityModel.y}"] = false

    @el.removeChild entityView.el

    entityModel.dispose()
    entityView.dispose()

    index = _.indexOf @entityModels, entityModel
    @entityModels.splice index, 1

    index = _.indexOf @entityViews, entityView
    @entityViews.splice index, 1

  onViewportMove: ->
    @creatureModel.x = @viewportModel.x
    @creatureModel.y = @viewportModel.y

    EventBus.dispatch '!entityManager:move', this

    @cacheCanvas()

  cacheCanvas: ->
    width = config.viewportOptions.width * config.tileWidth
    height = config.viewportOptions.height * config.tileHeight

    @el.cache 0, 0, width, height

  dispose: ->
    entityModel.dispose() for entityModel in @entityModels
    entityView.dispose() for entityView in @entityViews

    EventBus.addEventListener '!viewport:move', @onViewportMove, this

module.exports = EntityManagerView
