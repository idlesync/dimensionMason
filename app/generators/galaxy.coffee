utils = require 'utils'
config = require 'config'

class GalaxyGenerator
  constructor: ->

  getWorldSeed: (x, y) ->
    size = config.generators.galaxy.options.size

    x = utils.clamp x, size
    y = utils.clamp y, size

    index = y * size + x

    Math.floor utils.random(index * config.seed) * 0xffffff

module.exports = new GalaxyGenerator
