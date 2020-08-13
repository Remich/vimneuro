function! meta#AddTag()
	let l:input = trim(input("Enter tag(s): "))
	redraw
	if l:input ==# ""
		echom "ERROR: No tag(s) supplied."
		return
	endif

	let l:tags = split(l:input, '\v;')
	call map(l:tags, 'trim(v:val)')

	" parse meta data
	let l:meta = parse#MetaData()
	if l:meta == {}
		return
	endif

	" adding
	call extend(l:meta['tags'], l:tags)
	call uniq(sort(l:meta['tags']))

	call write#MetaData(l:meta)
	return
endfunction

function! meta#RemoveTag()
	let l:input = trim(input("Enter tag(s): "))
	redraw
	if l:input ==# ""
		echom "ERROR: No tag(s) supplied."
		return
	endif

	let l:tags = split(l:input, '\v;')
	call map(l:tags, 'trim(v:val)')

	" parse meta data
	let l:meta = parse#MetaData()
	if l:meta == {}
		return
	endif

	" removing
	for i in l:tags
		call filter(l:meta['tags'], 'v:val !=# i')
	endfor
	
	call write#MetaData(l:meta)
	return
endfunction
