config = require 'config'
utils = require 'utils'
ViewportModel = require 'models/Viewport'
ViewportView = require 'views/Viewport'
TileMapModel = require 'models/TileMap'
EntityManagerView = require 'views/EntityManager'
MinimapView = require 'views/Minimap'
galaxyGenerator = require 'generators/galaxy'
PortalModel = require 'models/Portal'
PortalView = require 'views/Portal'
CoinModel = require 'models/Coin'
CoinView = require 'views/Coin'
playerModel = require 'models/player'
StatusModel = require 'models/Status'
StatusView = require 'views/Status'

class DungeonScene
  doShadows: true

  constructor: (@options) ->
    @seed = @options.seed

    config.worldTileWidth = config.generators.dungeon.options.size
    config.worldTileHeight = config.generators.dungeon.options.size

    @el = new createjs.Container

    @tileMapModel = new TileMapModel config.generators.dungeon, @seed

    startPos = @tileMapModel.getStartPosition @seed + 102
    viewportX = startPos.x
    viewportY = startPos.y
    width = config.viewportOptions.width
    height = config.viewportOptions.height

    @viewportModel = new ViewportModel viewportX, viewportY, width, height
    @viewportView = new ViewportView @viewportModel, @tileMapModel
    @el.addChild @viewportView.el

    @entityManagerView = new EntityManagerView @viewportModel, @tileMapModel, @seed
    @createExit startPos.x, startPos.y, @options.worldX, @options.worldY
    @createCoins()
    @entityManagerView.createHero()
    @el.addChild @entityManagerView.el

    if @doShadows
      @viewportView.addShadowLayer @el, 4, 5

    @minimapView = new MinimapView @tileMapModel, @entityManagerView, @viewportModel, @doShadows
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

  createCoins: ->
    @coinViews = []

    grassTiles = @entityManagerView.getTileTypes 2
    coinCount = 4

    while coinCount
      index = Math.floor utils.random(+new Date) * grassTiles.length # non-deterministic
      position = grassTiles[index]

      continue if @entityManagerView.isOccupied position.x, position.y

      coinModel = new CoinModel position.x, position.y
      coinView = new CoinView coinModel, @viewportModel

      @coinViews.push coinView

      @entityManagerView.addEntity coinModel, coinView

      coinCount -= 1

    @entityManagerView.cacheCanvas()

  createExit: (x, y, worldX, worldY) ->
    @exitModel = new PortalModel x, y, worldX, worldY, 'blue'
    exitView = new PortalView @exitModel, @viewportModel

    @entityManagerView.addEntity @exitModel, exitView

    @entityManagerView.cacheCanvas()

  onKeyDown: (_event, args) ->
    x = @viewportModel.x
    y = @viewportModel.y

    switch args.keyCode
      when 37
        x = @viewportModel.x - 1
        x = utils.clamp x, config.worldTileWidth
      when 38
        y = @viewportModel.y - 1
        y = utils.clamp y, config.worldTileHeight
      when 39
        x = @viewportModel.x + 1
        x = utils.clamp x, config.worldTileWidth
      when 40
        y = @viewportModel.y + 1
        y = utils.clamp y, config.worldTileHeight
      when 32
        if @exitModel.x is x and @exitModel.y is y
          sceneLocation = 'scenes/World'
          options = {
            x: @options.worldX
            y: @options.worldY
            startPos:
              x: @options.entranceX
              y: @options.entranceY
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

    if @tileMapModel.getAllCells()[y][x] >= 4
      @checkStatus x, y

      @viewportModel.setPosition x, y

  checkStatus: (x, y) ->
    for coinView, index in @coinViews
      if coinView.model.x is x and coinView.model.y is y
        @statusModel.setStatus "You found a coin!", 'Press [Space] to pick up the coin'
        return

    if @exitModel.x is x and @exitModel.y is y
      seed = galaxyGenerator.getWorldSeed @options.worldX, @options.worldY
      worldName = (new Chance(seed)).city()

      @statusModel.setStatus "Portal back to #{worldName}", 'Press [Space] to leave this dungeon'
      return

    @statusModel.setStatus 'Dungeon', 'Use the arrow keys to explore'

  dispose: ->
    delete @tileMapModel

    if @doShadows
      @viewportView.removeShadowLayer @el

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

module.exports = DungeonScene
