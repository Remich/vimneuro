function! navigation#Go()
	call utility#SaveOptions()
	call utility#SetOptions()
	
	let l:word = expand("<cWORD>")

	" check if this is a valid Neuron link
	if match(l:word, '\v\<[A-Za-z0-9-_]+(\?cf)?\>') == -1
		call utility#RestoreOptions()
		return
	endif

	" extract filename
	let l:filename = []
	call substitute(l:word, '\v\<\zs.*\ze(\?cf)?\>', '\=add(l:filename, submatch(0))', 'g')
	let l:filename = l:filename[0].".md"

	" check for existing Zettel with supplied name
	let l:fullname = g:vimneuro_path_zettelkasten."/".l:filename
	if filereadable(l:fullname) == v:false
		echom "ERROR: Zettel with name '".l:fullname."' does not exist!"
		call utility#RestoreOptions()
		return
	endif

	" open Zettel in current window
	execute "edit! ".l:filename
	
	call utility#RestoreOptions()
endfunction

function! navigation#Preview()

	if exists("g:vimneuro_cmd_browser") == v:false
		echom "ERROR: 'g:vimneuro_cmd_browser' not set! Abort."
		return
	endif

	let l:filename = substitute(expand('%'), '\v\.md', '\.html', "")
	let l:url      = g:vimneuro_url_zettelkasten."/".l:filename
	let l:cmd      = shellescape(g:vimneuro_cmd_browser)." ".shellescape(l:url)

	if exists("g:vimneuro_cmd_browser_options") == v:true
		let l:opts = map(deepcopy(g:vimneuro_cmd_browser_options), 'shellescape(v:val)')
		let l:opts = join(l:opts, ' ')
		let l:cmd  = l:cmd." ".l:opts
	endif

	silent call jobstart(l:cmd)
endfunction

