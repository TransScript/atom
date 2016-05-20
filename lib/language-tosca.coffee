#LanguageToscaView = require './language-tosca-view'
{CompositeDisposable} = require 'atom'
path = require 'path'
helpers = null

lint = (editor) ->
  helpers ?= require('atom-linter')
  regex = 'line (?<line>[0-9]+):(?<col>[0-9]+)\\s*(?<message>.+)'
  filePath = editor.getPath()
  javaPath = atom.config.get "language-tosca.javaPath"
  metaCompilerPath = atom.config.get "language-tosca.metaCompilerPath"

  # TODO: configurable
  grammars = "org.transscript.text.Text4MetaParser,org.transscript.core.CoreMetaParser"

  helpers.exec(javaPath, ["-jar", metaCompilerPath + "/transscript-1.0.0-SNAPSHOT.jar", "parse", "quiet", "grammars=" + grammars, "rules=" + filePath], {stream: 'both'}).then (output) ->
    errors = helpers.parse(output.stderr, regex).map (message) ->
      message.filePath = filePath
      message.type = 'Error'
      line = message.range[0][0]
      col = message.range[0][1]
      message.range = helpers.rangeFromLineNumber(editor, line, col)
      message.text = message.text.replace /expectin.+/, ""
      message
    return errors


module.exports = LanguageTosca =
  #languageToscaView: null
  subscriptions: null

  activate: (state) ->
    #@languageToscaView = new LanguageToscaView(state.languageTransscriptViewState)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that check syntax on save
    #@subscriptions.add atom.commands.add 'atom-workspace', 'core:save' : => @onSave()
    console.log "Tosca Activated"

    #@subscriptions.add atom.commands.add 'atom-workspace', 'language-tosca:toggle': => @toggle()

  deactivate: ->
    @subscriptions.dispose()
    #@languageToscaView.destroy()

  serialize: ->
    #languageToscaViewState: @languageToscaView.serialize()

  provideLinter: =>
    provider =
      grammarScopes: ['source.tosca']
      scope: 'file'
      lintOnFly: false
      name: 'Tosca'
      lint: (editor) => lint editor
