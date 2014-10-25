utils = require 'utils'
config = require 'config'

class CavernView
  constructor: (@model, @viewportModel) ->
    @spriteSheet = new createjs.SpriteSheet @spriteSheetOptions

    @el = new createjs.Sprite @spriteSheet, @model.color

    EventBus.addEventListener '!entityManager:move', @setPosition, this

    @setPosition()

  spriteSheetOptions:
    images: [utils.tilesetImg]
    frames:
      width: config.tileWidth
      height: config.tileHeight
    animations:
      blue:
        frames: [233]
      orange:
        frames: [235]
      green:
        frames: [237]

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

module.exports = CavernView
