define (require) ->
  utils = require 'lib/utils'
  StatefulUrlParams = require './stateful-url-params'

  ###*
   * Adds pagination support to a Collection. It relies on StatefulUrlParams
   * mixin to persist pagination state and add to url query params on every
   * sync action.
   * @param  {Collection} base superclass
  ###
  (base) -> class Paginated extends utils.mix(base).with StatefulUrlParams
    DEFAULTS: _.extend {}, @::DEFAULTS,
      page: 1
      per_page: 30

    ###*
     * Name of the property in response JSON that carries an array of items.
     * @type {String}
    ###
    syncKey: null

    ###*
     * Sets the pagination mode for collection.
     * @type {Boolean} True if infitine, false otherwise
    ###
    infinite: false

    initialize: ->
      super
      @on 'remove', -> @count = Math.max 0, (@count or 1) - 1

    parse: (resp) ->
      @nextPageId = resp.next_page_id if @infinite
      if @syncKey
        @count = parseInt resp.count
        resp[@syncKey]
      else resp
