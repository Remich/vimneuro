function! meta#AddTag(...)

	if a:0 == 0
		let l:input = trim(input("Enter tag(s): "))
		redraw
	else
		let [l:input] = a:000
		let l:input   = trim(l:input)
	endif

	if l:input ==# ""
		echom "ERROR: No tag(s) supplied."
		return
	endif
		
	" split by separator ';'
	let l:tags = split(l:input, '\v;')
	call map(l:tags, 'trim(v:val)')

	if len(l:tags) == 0
		echom "ERROR: No tag(s) supplied."
		return
	endif

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

function! meta#RemoveTag(...)
	
	if a:0 == 0
		let l:input = trim(input("Enter tag(s): "))
		redraw
	else
		let [l:input] = a:000
		let l:input   = trim(l:input)
	endif

	if l:input ==# ""
		echom "ERROR: No tag(s) supplied."
		return
	endif

	" split by separator ';'
	let l:tags = split(l:input, '\v;')
	call map(l:tags, 'trim(v:val)')

	if len(l:tags) == 0
		echom "ERROR: No tag(s) supplied."
		return
	endif
	
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
