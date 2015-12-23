CopyPasteView = require './copy-paste-view'
{CompositeDisposable} = require 'atom'

module.exports = CopyPaste =
  copyPasteView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @copyPasteView = new CopyPasteView(state.copyPasteViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @copyPasteView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    # debugger
    @subscriptions.add atom.commands.add 'atom-workspace',
      'copy-paste:stop': => @stop()
      'copy-paste:paste': => @paste()
    # @subscriptions.add atom.commands.add 'atom-workspace',
    # @subscriptions.add atom.commands.add 'atom-workspace',


  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @copyPasteView.destroy()

  serialize: ->
    copyPasteViewState: @copyPasteView.serialize()

  stop: ->
    # debugger
    @recCall = () ->
      console.log('Pasting stopped')

  paste: ->
    # debugger
    console.log 'Pasting in progress!'
    editor = atom.workspace.getActiveTextEditor()
    code = atom.clipboard.read()
    calls = []
    @recCall = () ->
      if calls.length>0
        calls[0]()
    calls = Array.prototype.map.call code, (char, index, list) =>
      if char is ' ' and code[index+1] and code[index+1] isnt ' ' then baseDelay = 400
      else if char is ' ' and code[index+1] and code[index+1] is ' ' then baseDelay = 0
      else baseDelay = 100
      () =>
        setTimeout () =>
          editor.insertText(char,
            autoIndent: false
            autoIndentNewline: false
          )
          calls.shift()
          @recCall()
        , Math.round(baseDelay + Math.random()*250)
    @recCall()
