playerModel = require 'models/player'

class StatusView
  constructor: (@model, width, height) ->
    @el = new createjs.Container

    @titleEl = new createjs.Text 'Title', '26px Helvetica', '#333333'
    @titleEl.lineWidth = width
    @el.addChild @titleEl

    @descriptionEl = new createjs.Text 'some long description that should wrap ', '16px Helvetica', '#333333'
    @descriptionEl.y = 12 + @titleEl.getMeasuredHeight()
    @descriptionEl.lineWidth = width
    @el.addChild @descriptionEl

    @inventoryEl = new createjs.Text "Coins: #{playerModel.coins}", '16px Helvetica', '#333333'
    @inventoryEl.y = height - 24
    @el.addChild @inventoryEl

    _.bindAll this, 'onModelChange'
    @model.onChange = @onModelChange

  onModelChange: (title, description) ->
    @titleEl.text = title
    @descriptionEl.text = description

    @descriptionEl.y = 12 + @titleEl.getMeasuredHeight()

    @inventoryEl.text = "Coins: #{playerModel.coins}"

  dispose: ->
    @model.onChange = undefined
    @el.removeChild @titleEl
    @el.removeChild @descriptionEl

module.exports = StatusView
