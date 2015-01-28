proc = require 'child_process'
path = require 'path'
fs = require 'fs'

{CompositeDisposable} = require 'atom'

module.exports = Godef =
  subscriptions: null

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'godef:toggle': => @toggle()

  deactivate: ->
    @subscriptions.dispose()

  serialize: ->


  toggle: ->
      console.log 'godef:toggle'
      textEditor = atom.workspace.getActiveTextEditor()
      wordRange = textEditor.getCursor().getCurrentWordBufferRange()
      offset = textEditor.getBuffer().characterIndexForPosition(wordRange.end)
      offset = new Buffer(textEditor.getText().substring(0, offset)).length
      @godef(textEditor.getPath(), offset)


  godef: (file, offset) ->
      console.log '===========================Godef start ===================='
      gopath = process.env.GOPATH
      console.log 'GOPATH: ' + gopath
      godefpath = ""
      found = false

      for p in gopath.split(':')
          godefpath = path.join(p, 'bin', 'godef')
          exists = fs.existsSync(godefpath)
          if exists
              console.log 'find godef path:' + godefpath
              found = true
              break
          else
              continue

      if found
          console.log 'using godefpath: ' + godefpath
          args = [
              godefpath
              '-f'
              file
              '-o'
              offset
          ]
          console.log 'exec ' + args.join(' ')
          proc.exec args.join(' '), (err, stdout, stderr) ->
             location = stdout.split(':')
             if location.length == 3
                 row = parseInt(location[1])
                 column = parseInt(location[2])
                 options =
                     initialLine: (--row)
                     initialColumn: (--column)

                 atom.workspace.open(location[0], options)
      else
          return
