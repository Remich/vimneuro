function! navigation#Go()
	call utility#SaveOptions()
	call utility#SetOptions()
	
	let l:word = expand("<cWORD>")

	" check if this is a valid Neuron link
	if match(l:word, '\v\<[A-Za-z0-9-_]+(\?cf)?\>') == -1
		" no, then check if there are any links in the current line

		let l:names = []
		call substitute(getline(line('.')), '\v\<([A-Za-z0-9-_]+(\?cf)?)\>', '\=add(l:names, submatch(1))', 'g')

		if len(l:names) == 0
			" no links on current line, exit
			call utility#RestoreOptions()
			return
		endif
			
	else
		" extract zettel name(s)
		let l:names = []
		call substitute(l:word, '\v\<([A-Za-z0-9-_]+(\?cf)?)\>', '\=add(l:names, submatch(1))', 'g')
	endif

	if len(l:names) == 1
		" <cWORD> only contains one link
		let l:name = l:names[0]
	else
		" <cWORD> contains more than one link
		let i = 1
		let l:links = []
		for l in l:names
			call add(l:links, i.'. '.l)
			let i += 1
		endfor
		
		let l:list   = extend(['Multiple links under cursor. Select link:'], l:links)
		let l:choice = inputlist(l:list)
		let l:name   = l:names[l:choice-1]
		execute "redraw!"
	endif

	let l:filename = l:name.'.md'
	let l:fullname = g:vimneuro_path_zettelkasten."/".l:filename
	
	" check for existing zettel with supplied name
	if filereadable(l:fullname) == v:false
		echom "ERROR: Zettel with name '".l:fullname."' does not exist!"
		call utility#RestoreOptions()
		return
	endif

	" open zettel in current window
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

