# atom-godef
Find definition under current cursor for golang using 'godef'

## Installation

The plugin assumes `godef` is present at `$GOPATH/bin/godef`. You need install `godef` first:

	go get -v code.google.com/p/rog-go/exp/cmd/godef

## Usage

To activate godef , run `godef:toggle` via CommandPalette,
or apply some keybindings in your keymap.cson:

```coffee
'atom-text-editor':
	'ctrl-k': 'godef:toggle'
```
