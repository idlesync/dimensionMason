config = require 'config'
utils = require 'utils'
ViewportModel = require 'models/Viewport'
ViewportView = require 'views/Viewport'
TileMapModel = require 'models/TileMap'
EntityManagerView = require 'views/EntityManager'
MinimapView = require 'views/Minimap'
galaxyGenerator = require 'generators/galaxy'
StatusModel = require 'models/Status'
StatusView = require 'views/Status'
PlantModel = require 'models/Plant'
PlantView = require 'views/Plant'
CoinModel = require 'models/Coin'
CoinView = require 'views/Coin'
CavernModel = require 'models/Cavern'
CavernView = require 'views/Cavern'
CreatureModel = require 'models/Creature'
CreatureView = require 'views/Creature'
PortalModel = require 'models/Portal'
PortalView = require 'views/Portal'
playerModel = require 'models/player'

class WorldScene
  constructor: (@options) ->
    @seed = galaxyGenerator.getWorldSeed @options.x, @options.y

    @worldName = (new Chance(@seed)).city()

    config.worldTileWidth = config.generators.world.options.worldChunkWidth * config.generators.world.options.chunkTileWidth
    config.worldTileHeight = config.generators.world.options.worldChunkHeight * config.generators.world.options.chunkTileHeight

    @el = new createjs.Container

    @tileMapModel = new TileMapModel config.generators.world, @seed

    @_seed = @seed

    @coinViews = []
    @portalModels = []
    @cavernModels = []

    startPos = @tileMapModel.getStartPosition @seed + 999999
    spawnPos = startPos
    if @options.startPos
      spawnPos = @options.startPos
    viewportX = spawnPos.x
    viewportY = spawnPos.y
    width = config.viewportOptions.width
    height = config.viewportOptions.height

    @viewportModel = new ViewportModel viewportX, viewportY, width, height
    @viewportView = new ViewportView @viewportModel, @tileMapModel
    @el.addChild @viewportView.el

    @entityManagerView = new EntityManagerView @viewportModel, @tileMapModel, @seed
    @createPortals startPos.x, startPos.y, @options.x, @options.y
    @createCaverns()
    @createPlants()
    @createCoins()
    @entityManagerView.createHero()
    @el.addChild @entityManagerView.el

    @minimapView = new MinimapView @tileMapModel, @entityManagerView, @viewportModel
    @minimapView.el.x = config.viewportOptions.width * config.tileWidth + 10
    @minimapView.el.y = 0
    @el.addChild @minimapView.el

    @statusModel = new StatusModel
    width = config.worldTileWidth * config.minimapOptions.tileWidth
    height = (config.viewportOptions.height * config.tileHeight) - (config.worldTileHeight * config.minimapOptions.tileHeight + 10)
    @statusView = new StatusView @statusModel, width, height
    @statusView.el.x = config.viewportOptions.width * config.tileWidth + 10
    @statusView.el.y = config.worldTileHeight * config.minimapOptions.tileHeight + 10
    @el.addChild @statusView.el

    @checkStatus @viewportModel.x, @viewportModel.y

    EventBus.addEventListener '!key:down', @onKeyDown, this

  onKeyDown: (_event, args) ->
    x = @viewportModel.x
    y = @viewportModel.y

    switch args.keyCode
      when 37
        x = x - 1
        x = utils.clamp x, config.worldTileWidth
      when 38
        y = y - 1
        y = utils.clamp y, config.worldTileHeight
      when 39
        x = x + 1
        x = utils.clamp x, config.worldTileWidth
      when 40
        y = y + 1
        y = utils.clamp y, config.worldTileHeight
      when 32
        for cavernModel, index in @cavernModels
          if cavernModel.x is x and cavernModel.y is y
            sceneLocation = 'scenes/Dungeon'
            options = {
              worldX: @options.x
              worldY: @options.y
              seed: @seed + index
              entranceX: cavernModel.x
              entranceY: cavernModel.y
            }

            EventBus.dispatch '!scene:load', this, {sceneLocation, options}
            return

        for portalModel, index in @portalModels
          if portalModel.x is x and portalModel.y is y
            sceneLocation = 'scenes/World'
            options = {
              x: portalModel.worldX
              y: portalModel.worldY
            }

            EventBus.dispatch '!scene:load', this, {sceneLocation, options}
            return

        for coinView, index in @coinViews
          coinModel = coinView.model
          if coinModel.x is x and coinModel.y is y
            @coinViews.splice index, 1

            @entityManagerView.removeEntity coinModel, coinView

            playerModel.coins += 5

            break

    if @tileMapModel.getAllCells()[y][x] >= 2
      @checkStatus x, y

      @viewportModel.setPosition x, y

  createPlants: ->
    grassTiles = @entityManagerView.getTileTypes 2
    plantCount = Math.floor grassTiles.length / 16

    while plantCount
      index = Math.floor utils.random(@_seed++) * grassTiles.length
      position = grassTiles[index]

      continue if @entityManagerView.isOccupied position.x, position.y

      maturity = Math.floor 8 * utils.random(@_seed++)

      plantModel = new PlantModel position.x, position.y, maturity
      plantView = new PlantView plantModel, @viewportModel

      @entityManagerView.addEntity plantModel, plantView

      plantCount -= 1

    @entityManagerView.cacheCanvas()

  createCaverns: ->
    grassTiles = @entityManagerView.getTileTypes 2

    for color in ['blue', 'orange', 'green']
      index = Math.floor utils.random(@_seed++) * grassTiles.length
      position = grassTiles[index]

      continue if @entityManagerView.isOccupied position.x, position.y

      cavernModel = new CavernModel position.x, position.y, color
      cavernView = new CavernView cavernModel, @viewportModel

      @entityManagerView.addEntity cavernModel, cavernView

      @cavernModels.push cavernModel

    @entityManagerView.cacheCanvas()

  createPortals: (centerX, centerY, worldX, worldY) ->
    createPortal = (x, y, wX, wY) =>
      x = utils.clamp x, config.worldTileWidth
      y = utils.clamp y, config.worldTileHeight

      wX = utils.clamp wX, config.generators.galaxy.options.size
      wY = utils.clamp wY, config.generators.galaxy.options.size

      portalModel = new PortalModel x, y, wX, wY, 'yellow'
      portalView = new PortalView portalModel, @viewportModel
      @entityManagerView.addEntity portalModel, portalView

      @portalModels.push portalModel

    # North Portal
    createPortal centerX, centerY - 1, worldX, worldY - 1, 'yellow'

    # East Portal
    createPortal centerX + 1, centerY, worldX + 1, worldY, 'yellow'

    # South Portal
    createPortal centerX, centerY + 1, worldX, worldY + 1, 'yellow'

    # West Portal
    createPortal centerX - 1, centerY, worldX - 1, worldY, 'yellow'

  createCoins: ->
    sandTiles = @entityManagerView.getTileTypes 1
    coinCount = 4

    while coinCount
      index = Math.floor utils.random(+new Date) * sandTiles.length # non-deterministic
      position = sandTiles[index]

      continue if @entityManagerView.isOccupied position.x, position.y

      coinModel = new CoinModel position.x, position.y
      coinView = new CoinView coinModel, @viewportModel

      @coinViews.push coinView

      @entityManagerView.addEntity coinModel, coinView

      coinCount -= 1

    @entityManagerView.cacheCanvas()

  checkStatus: (x, y) ->
    for cavernModel, index in @cavernModels
      if cavernModel.x is x and cavernModel.y is y
        @statusModel.setStatus 'Dungeon Entrance', 'Press [Space] to explore this dungeon'
        return

    for portalModel, index in @portalModels
      if portalModel.x is x and portalModel.y is y
        seed = galaxyGenerator.getWorldSeed portalModel.worldX, portalModel.worldY
        worldName = (new Chance(seed)).city()

        @statusModel.setStatus "Portal to #{worldName} [#{portalModel.worldX},#{portalModel.worldY}]", 'Press [Space] to travel through this portal'
        return

    for coinView, index in @coinViews
      if coinView.model.x is x and coinView.model.y is y
        @statusModel.setStatus 'You found a coin!', 'Press [Space] to pick up the coin'
        return

    @statusModel.setStatus "Planet #{@worldName} [#{@options.x},#{@options.y}]", 'Use the arrow keys to explore'

  dispose: ->
    delete @tileMapModel

    @el.removeChild @statusView.el
    @statusModel.dispose()
    @statusView.dispose()

    @el.removeChild @viewportView.el
    @viewportModel.dispose()
    @viewportView.dispose()

    @el.removeChild @entityManagerView.el
    @entityManagerView.dispose()

    @el.removeChild @minimapView.el
    @minimapView.dispose()

    EventBus.removeEventListener '!key:down', @onKeyDown, this

module.exports = WorldScene
