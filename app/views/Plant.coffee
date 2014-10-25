utils = require 'utils'
config = require 'config'

class PlantView
  constructor: (@model, @viewportModel) ->
    @spriteSheet = new createjs.SpriteSheet @spriteSheetOptions

    animation = ('first second third fourth fifth sixth seventh eighth').split(' ')[@model.maturity]
    @el = new createjs.Sprite @spriteSheet, animation

    EventBus.addEventListener '!entityManager:move', @setPosition, this

    @setPosition()

  spriteSheetOptions:
    images: [utils.tilesetImg]
    frames:
      width: config.tileWidth
      height: config.tileHeight
    animations:
      first:
        frames: [225]
      second:
        frames: [226]
      third:
        frames: [227]
      fourth:
        frames: [228]
      fifth:
        frames: [229]
      sixth:
        frames: [230]
      seventh:
        frames: [231]
      eighth:
        frames: [232]

  setPosition: ->
    centerX = Math.floor @viewportModel.width / 2
    centerY = Math.floor @viewportModel.height / 2

    viewX = @viewportModel.x
    viewY = @viewportModel.y

    myX = @model.x
    myY = @model.y

    x = (myX - viewX) + centerX
    y = (myY - viewY) + centerY

    worldWidth = config.worldTileWidth
    halfWorldWidth = Math.floor worldWidth / 2

    worldHeight = config.worldTileHeight
    halfWorldHeight = Math.floor worldHeight / 2

    offsetX = 0
    offsetY = 0

    if myX > viewX + halfWorldWidth
      offsetX -= worldWidth

    if myX < viewX - halfWorldWidth
      offsetX += worldWidth

    if myY > viewY + halfWorldHeight
      offsetY -= worldHeight

    if myY < viewY - halfWorldHeight
      offsetY += worldHeight

    myNewX = x + offsetX
    myNewY = y + offsetY

    newX = myNewX * config.tileWidth
    newY = myNewY * config.tileHeight

    @el.x = newX
    @el.y = newY

  dispose: ->
    EventBus.removeEventListener '!entityManager:move', @setPosition, this

module.exports = PlantView
