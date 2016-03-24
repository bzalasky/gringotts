# This mixin adds genericSave handler method that could be used in combine
# with editable mixin to handle save actions from editable UI input controls.
#
# Pass delayedSave true in options to turn on couple of secs delay before
# saving update value on server. The notification with Undo will be shown.
define (require) ->
  utils = require 'lib/utils'

  _revertChanges = (opts, $xhr) ->
    opts.$field?.text opts.original
    opts.$field?.attr 'href', opts.href if opts.href
    @makeEditable? opts unless $xhr

    if $xhr?.status is 406
      response = utils.parseJSON $xhr.responseText
      message = response?.errors[opts.attribute]
      if message
        $xhr.errorHandled = true
        @publishEvent 'notify', message, classes: 'alert-danger'

  genericSave = (opts) ->
    # The model should already have been validated
    # by the editable mixin.
    opts = _.extend {}, _.omit(opts, ['success']),
      wait: yes, validate: no
    if opts.delayedSave
      @publishEvent 'notify', opts.saveMessage,
        _.extend {}, opts,
          success: ->
            opts.model.save opts.attribute, opts.value, opts
            .fail ($xhr) => _revertChanges.call this, opts, $xhr
          undo: =>
            _revertChanges.call this, opts
    else
      opts.model.save opts.attribute, opts.value, opts
      .done => @publishEvent 'notify', opts.saveMessage
      .fail ($xhr) => _revertChanges.call this, opts, $xhr

  {genericSave}
