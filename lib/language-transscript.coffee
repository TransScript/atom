LanguageTransScriptView = require './language-transscript-view'
{CompositeDisposable} = require 'atom'
path = require 'path'
process = require 'child_process'
#byline = require 'byline'

module.exports = LanguageTransScript =
  languageTransScriptView: null
  subscriptions: null

  activate: (state) ->
    @languageTransScriptView = new LanguageTransScriptView(state.languageTransscriptViewState)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that check syntax on save
    @subscriptions.add atom.commands.add 'atom-workspace', 'core:save': => @onSave()
    console.log "TransScript Activated"

    #@subscriptions.add atom.commands.add 'atom-workspace', 'language-transscript:toggle': => @toggle()

  deactivate: ->
    @subscriptions.dispose()
    @languageTransScriptView.destroy()

  serialize: ->
    languageTransScriptViewState: @languageTransScriptView.serialize()

  onSave: ->
    @check()

  check: ->
    editor = atom.workspace.getActiveTextEditor()
    return unless editor?

    filePath = editor.getPath()
    if path.extname(filePath) not in [".crs4", ".tsc"]
      console.log "TransScript Syntax Checker: Ignore file " + filePath
      return

    javaPath = atom.config.get "language-transscript.javaPath"
    metaCompilerPath = atom.config.get "language-transscript.metaCompilerPath"
    proc = process.spawn javaPath, ["-jar", metaCompilerPath + "/transscript-1.0.0-ALPHA.jar", "parse", "rules=" + filePath]

    proc.stdout.on 'data', (data) ->
      console.log data.toString()

    proc.stderr.on 'data', (data) ->
      console.log data.toString()
