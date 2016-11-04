#LanguageToscaView = require './language-tosca-view'
{CompositeDisposable} = require 'atom'
path = require 'path'
helpers = null
notified = false

lint = (editor) ->
  helpers ?= require('atom-linter')
  regex = 'line (?<line>[0-9]+):(?<col>[0-9]+)\\s*(?<message>.+)'
  filePath = editor.getPath()
  javaPath = atom.config.get "language-tosca.javaPath"
  metaCompilerPath = atom.config.get "language-tosca.metaCompilerPath"
  grammars =  atom.config.get "language-tosca.grammarClassname"
  grammarsPath =  atom.config.get "language-tosca.grammarClasspath"

  cp = metaCompilerPath + "/tosca.jar"
  cp += ":" + metaCompilerPath + "/tosca.jar:libs/*"
  cp += ":" + grammarsPath if grammarsPath

  grammars = "parsers=" + grammars if grammars
  helpers.exec(javaPath, ["-cp", cp, "org.transscript.Tool", "parse", "quiet", grammars, "rules=" + filePath], {stream: 'both'}).then (output) ->
    console.log output.stderr
    if not notified and (output.stderr.search "/Error: Unable to access jarfile/") isnt -1
      atom.notifications.addError(output.stderr, {detail: "Go to Tosca settings and fix path to Tosca jar file.", dismissable:true})
      notified = true

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
