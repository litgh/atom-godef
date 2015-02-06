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
      textEditor = atom.workspace.getActiveTextEditor()
      wordStart = textEditor.getSelectedBufferRange().start
      offset = textEditor.getTextInBufferRange([[0,0], wordStart]).length
      @godef(textEditor.getPath(), offset)


  godef: (file, offset) ->
      gopath = atom.config.get('godef.goPath')
      gopath = process.env.GOPATH if not gopath?
      if gopath?
        atom.config.set('godef.goPath', gopath)
      else
        console.log 'cannot found GOPATH'
        return

      console.log 'GOPATH: ' + gopath

      godefpath = atom.config.get('godef.godefPath')
      found = false
      if not godefpath?
        for p in gopath.split(':')
            godefpath = path.join(p, 'bin', 'godef')
            exists = fs.existsSync(godefpath)
            if exists
                found = true
                atom.config.set('godef.godefPath', godefpath)
                break
            else
                continue
      else
        found = true

      if found
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
        console.log 'godef not found'
