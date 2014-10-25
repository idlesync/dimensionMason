class StatusModel
  constructor: (@title = '', @description = '') ->

  setStatus: (@title, @description) ->
    @onChange @title, @description

  onChange: ->
    # meant to be overridden by view

  dispose: ->

module.exports = StatusModel
