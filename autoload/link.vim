" create a Neuron link from text supplied by the operator
" to a Zettel matching it's title
function! link#LinkingOperator(type)
	call utility#SaveOptions()
	call utility#SetOptions()
	call utility#SaveRegisters(['@', 'k'])

	if a:type ==# 'v'
		normal! `<v`>y
	elseif a:type ==# 'char'
		normal! `[v`]y
	else
		return
	endif

	let l:title = trim(@@)
	silent execute "grep! '^\\# ".l:title."$'" 
	let l:results = getqflist()

	if len(l:results) == 0

		let l:confirm = confirm("ERROR: No Zettel with title ".shellescape(l:title)." found. Create new Zettel?", "&Yes\n&No")
		if l:confirm == 1
			call zettels#New(l:title)
		else
			echom ""
		endif

	elseif len(l:results) > 1
		" TODO selection prompt, instead of error
		echoe "ERROR: Multiple Zettels with title (".shellescape(l:title).") found."
	else
		let d = l:results[0]
		let l:basename = trim(system('basename '.shellescape(bufname(d.bufnr))))
		let @k = link#CreateLinkOfFilename(l:basename)
		normal! `[v`]"kp
	endif

	call utility#RestoreRegisters()
	call utility#RestoreOptions()
endfunction

function! link#CreateLinkOfFilename(filename)
	return "<" . substitute(a:filename, '\.md', '', "") .">"
endfunction

function! link#GetLinkToAlternateBuffer()
	let l:filename = bufname(0)

	if l:filename ==# ""
		echom "ERROR: No alternative buffer"
		return v:false
	endif

	return link#CreateLinkOfFilename(l:filename)
endfunction

function! link#InsertLinkToAlternateBuffer()
	let l:link = link#GetLinkToAlternateBuffer()
	if l:link != v:false
		call nvim_paste(l:link, v:true, -1)
	endif
endfunction

function! link#InsertLinkToAlternateBufferAsUlItem()
	call utility#SaveRegisters(['+'])	
	let l:link = link#GetLinkToAlternateBuffer()
	if l:link != v:false
		let @+ = l:link
		execute "normal! o\<esc>\"_d0i- \<c-r>+\<esc>"
	endif
	call utility#RestoreRegisters()
endfunction

function! link#CopyLinkOfCurrentBuffer()
	let l:filename = substitute(expand('%'), '\v\.md', '', "")
	let @+ = "<".l:filename.">"
	echom "'<".l:filename.">' copied to + register"
endfunction

function! link#CopyLinkOfCurrentLine(linenum)
	let l:link = link#GetLinkOfCurrentLine(a:linenum)	
	let @+ = l:link
	echom "'".l:link."' copied to + register"
endfunction

" searches for `FOOBAR.md` in the current line,
" creates and returns a Neuron link
function! link#GetLinkOfCurrentLine(linenum)
	let l:line     = getline(a:linenum)
	let l:filename = []
	call substitute(l:line, '\v(^|\s)\zs[a-z0-9]+\ze\.md', '\=add(l:filename, submatch(0))', 'g')

	if len(l:filename) == 0
		return
	endif

	let l:links = map(l:filename, '"<".v:val.">"')
	return l:links[0]
endfunction

function! link#CopyLinkOfSelection()
	let l:start = getpos("'<")
	let l:stop  = getpos("'>")
	let l:lines = range(l:start[1], l:stop[1])
	let l:links = map(l:lines, 'link#GetLinkOfCurrentLine(v:val)')
	let str = ""
	for i in l:links
		if i == v:false
			continue
		endif
		let str = str.i."\n"	
	endfor
	let @+ = str
	echom "Copied links to + register"
endfunction

" replaces links to Zettel 'oldname' with 'newname' in every Zettel
function! link#Relink(oldname, newname)
	let l:curbuf    = bufnr()
	let linkpattern = '<'.a:oldname.'(\?cf)?>'

	silent execute "grep! '".linkpattern."' *.md" 
	" copen
	execute 'cfdo %substitute/\v\<'.a:oldname.'(\?cf)?\>/\<'.a:newname.'\1\>/g'
	cfdo update
	
	" restore old quickfix list
	let l:num_qflists = getqflist({'nr' : '$'}).nr
	if l:num_qflists > 1
		silent colder
	endif

	" switch back to original buffer
	execute "buffer ".l:curbuf	
	return v:true
endfunction

function! link#PasteLinkAsUlItem()
	execute "normal! o\<esc>\"_d0i- \<c-r>+\<esc>"
endfunction