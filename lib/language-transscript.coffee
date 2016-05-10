#LanguageTransScriptView = require './language-transscript-view'
{CompositeDisposable} = require 'atom'
path = require 'path'
helpers = null

lint = (editor) ->
  console.log "lint"
  helpers ?= require('atom-linter')
  regex = '^line (?<line>[0-9]+):(?<col>[0-9]+)\\s*(?<message>.+)$'
  filePath = editor.getPath()
  javaPath = atom.config.get "language-transscript.javaPath"
  metaCompilerPath = atom.config.get "language-transscript.metaCompilerPath"

  helpers.exec(javaPath, ["-jar", metaCompilerPath + "/transscript-1.0.0-SNAPSHOT.jar", "parse", "quiet", "rules=" + filePath], {stream: 'both'}).then (output) ->
    console.log output.stderr
    console.log output.stdout

    errors = helpers.parse(output.stderr, regex).map (message) ->
      message.filePath = filePath
      message.type = 'Error'
      line = message.range[0][0]
      col = message.range[0][1]
      message.range = helpers.rangeFromLineNumber(editor, line, col)
      message
    return errors


module.exports = LanguageTransScript =
  #languageTransScriptView: null
  subscriptions: null

  activate: (state) ->
    #@languageTransScriptView = new LanguageTransScriptView(state.languageTransscriptViewState)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that check syntax on save
    #@subscriptions.add atom.commands.add 'atom-workspace', 'core:save' : => @onSave()
    console.log "TransScript Activated"

    #@subscriptions.add atom.commands.add 'atom-workspace', 'language-transscript:toggle': => @toggle()

  deactivate: ->
    @subscriptions.dispose()
    #@languageTransScriptView.destroy()

  serialize: ->
    #languageTransScriptViewState: @languageTransScriptView.serialize()

  provideLinter: =>
    provider =
      grammarScopes: ['source.transscript']
      scope: 'file'
      lintOnFly: false
      name: 'TransScript Lint'
      lint: (editor) => lint editor
