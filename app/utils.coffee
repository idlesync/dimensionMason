config = require 'config'

utils =
  clamp: (index, size) ->
    (index + size) % size

  random: (seed) ->
    new RNG(seed).uniform()

  loadImages: (spriteSheetSource, callback) ->
    @tilesetImg = new Image

    @tilesetImg.onload = callback

    @tilesetImg.src = spriteSheetSource

module.exports = utils
