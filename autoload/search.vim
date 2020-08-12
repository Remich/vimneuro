let g:searchquery = ""

function! search#SearchByTags()
	let l:input = trim(input("Search: "))
	redraw!

	let l:exact       = ''
	let l:neg         = v:false
	let l:op          = []
	let l:flags       = []
	let l:only_invert = v:false
	let l:neg_str     = ""
	
	if l:input ==# ""
		" get all files with any or none tags
		" won't find files without a tag meta data entry
		let l:tag   = '.*'
	elseif l:input ==# "!"
		" don't search, only invert
		let l:only_invert = v:true
		let l:neg         = v:true
		let l:new_str     = "!"
	else
		
		" check for flag '\e' (exact match)
		call substitute(l:input, '\v\zs\\e\ze', '\=add(l:flags, submatch(0))', 'g')
		let l:input = trim(substitute(l:input, '\v\zs\\e\ze', '', 'g'))
		
		if len(l:flags) == 0
			let l:exact = '.*'
		else
			let l:exact = ''
		endif

		" extract operators '&' and '|'
		call substitute(l:input, '\v^\zs[&|]{1}\ze', '\=add(l:op, submatch(0))', 'g')
		let l:input = trim(substitute(l:input, '\v^\zs[&|]{1}\ze', '', 'g'))
		
		" check for negation operator
		if match(l:input, '\v^!') == -1
			let l:neg = v:false
			let l:neg_str = ""
		else
			let l:neg = v:true
			let l:neg_str = "!"
			" remove negation operator
			let l:input = trim(substitute(l:input, '\v^!', '', ""))
		endif
	
		let l:tag = l:input
	endif
	
	" remember current qflist
	let l:qf_cur = getqflist()

	" grep
	if l:only_invert == v:false
		" search pattern
		let l:pat = '\A^---$(.*\n)+?(tags:\n)(.*\n)*?(- ("'')?'.l:exact.l:tag.l:exact.'("'')?\n)(.*\n)*?^---$'
		execute 'silent! grep! --multiline '.shellescape(l:pat) | execute 'redraw' | copen
	endif
	
	" invert
	if l:neg == v:true
		call search#InvertMatches()
	endif

	if l:only_invert == v:true
		if l:exact !=# ''
			let g:searchquery = "!".g:searchquery
		else
			let g:searchquery = '!"'.g:searchquery.'"'
		endif
	elseif len(l:op) == 0
		if l:exact !=# ''
			let g:searchquery = l:neg_str.l:tag
		else
			let g:searchquery = l:neg_str.'"'.l:tag.'"'
		endif
	elseif l:op[0] ==# '&'
		" compute intersection of previous qflist with current
		call search#IntersectCurrentAndPreviousQfLists(l:qf_cur)

		if l:exact !=# ''
			let g:searchquery .= " & ".l:neg_str.l:tag
		else
			let g:searchquery .= " & ".l:neg_str.'"'.l:tag.'"'
		endif
	elseif l:op[0] ==# '|'
		" compute union of previous qflist with current
		call search#UnionOfCurrentAndPreviousQfLists(l:qf_cur)

		if l:exact !=# ''
			let g:searchquery .= " | ".l:neg_str.l:tag
		else
			let g:searchquery .= " | ".l:neg_str.'"'.l:tag.'"'
		endif
	endif

	call search#QfSanitize()
	
	echom "Current Search Query: ".g:searchquery
endfunction

function! search#HasSameFilename(e1, e2)
	let [t1, t2] = [bufname(a:e1.bufnr), bufname(a:e2.bufnr)]
	return t1 ==# t2 ? 0 : 1
endfunction

function! search#CmpQfByFilename(e1, e2)
	let [t1, t2] = [bufname(a:e1.bufnr), bufname(a:e2.bufnr)]
	return t1 <# t2 ? -1 : t1 ==# t2 ? 0 : 1
endfunction

function! search#QfSanitize()
	
	" get qflist
	let l:qf = getqflist()
	
	" abort if no entries
	if len(l:qf) == 0
		return
	endif
	
	" remove duplicates
	call uniq(l:qf, 'search#HasSameFilename')

	" create a list of just the filenames
	let l:files = []
	for d in l:qf
		call add(l:files, bufname(d.bufnr))
	endfor
	
	" grep for the titles
	execute 'silent! grep! "^\#{1} .*$" '.join(l:files, ' ') | execute 'redraw!' | copen
	
	" remove duplicates again
	let l:qf = getqflist()
	call uniq(l:qf, 'search#HasSameFilename')
	
	" sort by filename and set
	call setqflist(sort(l:qf, 'search#CmpQfByFilename'))
	
endfunction

function! search#InvertMatches()

	" get list of all Zettels
	let l:files = system('ls *.md')
	let l:files = split(l:files, '\n')

	" remove the files currently in the quickfix-list
	let l:qf = getqflist()
	for d in l:qf
		call filter(l:files, 'v:val !=# '.shellescape(bufname(d.bufnr)))
	endfor

	" get the titles
	execute 'silent! grep! "^\#{1} .*$" '.join(l:files, ' ') | execute 'redraw!'
endfunction

function! search#IntersectCurrentAndPreviousQfLists(qf_prev)
	let l:num_qflists = getqflist({'nr' : '$'}).nr
	let l:num_cur     = getqflist({'nr' : 0}).nr
	
	if l:num_qflists == 1
		" nothing to do
		return
	endif
	
	let l:cur = getqflist()
	let l:new = []

	for d in l:cur
		for e in a:qf_prev
			if shellescape(bufname(e.bufnr)) ==# shellescape(bufname(d.bufnr))
				call add(l:new, d)
			endif
		endfor
	endfor

	call setqflist(l:new)
	
endfunction

function! search#UnionOfCurrentAndPreviousQfLists(qf_prev)
	let l:num_qflists = getqflist({'nr' : '$'}).nr
	let l:num_cur     = getqflist({'nr' : 0}).nr
	
	if l:num_qflists == 1
		" nothing to do
		return
	endif
	
	let l:cur  = getqflist()
	call extend(l:cur, a:qf_prev)
	call setqflist(l:cur)
endfunction
