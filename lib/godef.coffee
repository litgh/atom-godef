proc = require 'child_process'
path = require 'path'
fs = require 'fs'
Q = require 'q'

{CompositeDisposable, TextEditor} = require 'atom'

module.exports = Godef =
  config:
      show:
        title: 'Show definition position'
        description: 'Choose one: Right, or New'
        type: 'string'
        default: 'New'
        enum: ['Right', 'New']
        order: 0


  subscriptions: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable

    atom.workspace.onDidChangeActivePaneItem (item) =>
      if item instanceof TextEditor
        item.scrollToCursorPosition()

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'godef:toggle': =>
      @find()


  deactivate: ->
    @subscriptions.dispose()

  serialize: ->

  find: ->
    textEditor = atom.workspace.getActiveTextEditor()
    grammar = textEditor?.getGrammar()

    if !grammar or grammar.name != 'Go'
      return

    wordEnd = textEditor.getSelectedBufferRange().end
    offset = new Buffer(textEditor.getTextInBufferRange([[0,0], wordEnd])).length
    @godef(textEditor.getPath(), offset, atom.config.get 'godef.show')

  godef: (file, offset, position) ->
    @gopath = process.env.GOPATH
    if not @gopath
      console.log "GOPATH not found."
      return

    found = false
    if not @godefpath?
      for p in @gopath.split(':')
        @godefpath = path.join(p, 'bin', 'godef')
        exists = fs.existsSync(@godefpath)
        if exists
            found = true
            break
        else
            continue

      if not found
        console.log "godef not find."
        return

    args = [
        @godefpath
        '-f'
        file
        '-o'
        offset
    ]
    
    proc.exec args.join(' '), (err, stdout, stderr) =>
      location = stdout.split(':')
      if location.length == 3
        row = parseInt(location[1])
        column = parseInt(location[2])
        options =
          initialLine: (--row)
          initialColumn: (--column)

        options.split = position.toLowerCase() if position != 'New'
        editor = atom.workspace.open(location[0], options)
