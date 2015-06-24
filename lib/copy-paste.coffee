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
    @subscriptions.add atom.commands.add 'atom-workspace', 'copy-paste:toggle': => @toggle()
    # @subscriptions.add atom.commands.add 'atom-workspace', 'copy-paste:paste': => @paste()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @copyPasteView.destroy()

  serialize: ->
    copyPasteViewState: @copyPasteView.serialize()

  toggle: ->
    console.log 'CopyPaste was toggled!'
    editor = atom.workspace.getActiveTextEditor()
    code = atom.clipboard.read()
    calls = []
    recCall = () ->
      if calls.length>0
        calls[0]()
    calls = Array.prototype.map.call code, (char)->
      ()->
        setTimeout ()->
          editor.insertText(char,
            autoIndent: false
            autoIndentNewline: false
          )
          calls.shift()
          recCall()
        , Math.round(Math.random()*300)

    recCall()
    # console.log(calls)
    # if @modalPanel.isVisible()
      # @modalPanel.hide()
    # else
      # @modalPanel.show()

  paste: ->
    console.log 'CopyPaste was toggled!'
    editor = atom.workspace.activePaneItem;
    editor.insertText('Hello, World!')
    # selection = editor.getSelection();
    # text = selection.getText();
    # options = font: 'Star Wars'
    # figlet = require('figlet');
    # figlet text, options, (err, asciiArt) ->
    #   if (err)
    #     console.error(err);
    #   else
    #     selection.insertText("\n" + asciiArt + "\n");
