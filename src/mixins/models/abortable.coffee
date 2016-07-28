define (require) ->
  utils = require 'lib/utils'
  ActiveSyncMachine = require './active-sync-machine'

  ###*
   * Aborts the existing fetch request if a new one is being requested.
  ###
  (base) -> class Abortable extends utils.mix(base).with ActiveSyncMachine
    fetch: ->
      $xhr = super
      if @currentXHR and _.isFunction(@currentXHR.abort) and @isSyncing()
        @currentXHR
          # muting the ajax error raised during abort
          .fail ($xhr) -> $xhr.errorHandled = true if $xhr.status is 0
          .abort()
      @currentXHR = if $xhr then $xhr.always => delete @currentXHR
