" create a Neuron link from text supplied by the operator
" to a zettel matching it's title
function! link#LinkingOperator(type)
	call utility#SaveOptions()
	call utility#SetOptions()
	call utility#SaveRegisters(['@', 'k'])

	if a:type ==# 'v'
		normal! `<v`>y
	elseif a:type ==# 'char'
		normal! `[v`]y
	else
		call utility#RestoreOptions()
		return
	endif

	let l:title = trim(@@)
	silent execute "grep! '^\\# ".l:title."$'" 
	let l:results = getqflist()

	if len(l:results) == 0

		let l:confirm = confirm("ERROR: No zettel with title ".shellescape(l:title)." found. Create new zettel?", "&Yes\n&No")
		if l:confirm == 1
			call zettels#New(l:title)
		else
			echom ""
		endif

	elseif len(l:results) > 1
		" TODO selection prompt, instead of error
		echoe "ERROR: Multiple zettels with title ".shellescape(l:title)." found."
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
		echom "ERROR: No alternative buffer!"
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
	let l:link = link#GetLinkToAlternateBuffer()
	if l:link != v:false
		call append(line('.')-1, "- ".l:link)
	endif
endfunction

function! link#CopyLinkOfCurrentBuffer()
	let l:filename = substitute(expand('%'), '\v\.md', '', "")
	let @+ = "<".l:filename.">"
	echom "Copied '<".l:filename.">' to + register."
endfunction

function! link#CopyLinkOfCurrentLine(linenum)
	let l:link = link#GetLinkOfCurrentLine(a:linenum)	

	if l:link == v:false
		echom "No names of Markdown files in current line found!"
		return
	endif
	
	let @+ = l:link
	echom "'Copied ".l:link."' + register."
endfunction

" searches for the first occurence of `FOOBAR.md` in the current line,
" creates and returns a Neuron link
function! link#GetLinkOfCurrentLine(linenum)
	let l:line     = getline(a:linenum)
	let l:filename = []
	call substitute(l:line, '\v\zs[A-Za-z0-9-_]+\ze\.md', '\=add(l:filename, submatch(0))', 'g')

	if len(l:filename) == 0
		return v:false
	endif

	let l:links = map(l:filename, '"<".v:val.">"')
	return l:links[0]
endfunction

function! link#CopyLinkOfSelection()
	let l:start = getpos("'<")
	let l:stop  = getpos("'>")
	let l:lines = range(l:start[1], l:stop[1])
	let l:links = map(l:lines, 'link#GetLinkOfCurrentLine(v:val)')
	let l:str = ""
	for i in l:links
		if i == v:false
			continue
		endif
		let l:str = l:str.i."\n"	
	endfor
	let @+ = l:str

	if l:str ==# ""
		echom "No names of Markdown files in selection found!"
		return
	endif
	
	echom "Copied links to + register."
endfunction

" replaces links to zettel 'oldname' with 'newname' in every zettel
function! link#Relink(oldname, newname)
	call utility#SaveOptions()
	call utility#SetOptions()

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

	call utility#RestoreOptions()
	return v:true
endfunction

function! link#PasteLinkAsUlItem()
	execute "normal! o\<esc>\"_d0i- \<c-r>+\<esc>"
endfunction
