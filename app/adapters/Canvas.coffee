class CanvasAdapter
  constructor: (rawOptions = {}) ->
    options = _.defaults rawOptions, @DEFAULT_OPTIONS

    $canvasEl = $ '<canvas>'
    $canvasEl.attr
      width: options.width
      height: options.height

    $(options.selector).append $canvasEl

    @el = $canvasEl.get 0

  DEFAULT_OPTIONS:
    width: 480
    height: 320
    selector: 'body'

  dispose: ->
    @el.remove()

module.exports = CanvasAdapter
