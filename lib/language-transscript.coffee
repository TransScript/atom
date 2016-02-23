LanguageTransscriptView = require './language-transscript-view'
{CompositeDisposable} = require 'atom'

module.exports = LanguageTransscript =
  languageTransscriptView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @languageTransscriptView = new LanguageTransscriptView(state.languageTransscriptViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @languageTransscriptView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'language-transscript:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @languageTransscriptView.destroy()

  serialize: ->
    languageTransscriptViewState: @languageTransscriptView.serialize()

  toggle: ->
    console.log 'LanguageTransscript was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
