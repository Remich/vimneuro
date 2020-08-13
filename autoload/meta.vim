function! meta#AddTag()
	let l:input = trim(input("Enter tag(s): "))
	redraw
	if l:input ==# ""
		echom "ERROR: No tag(s) supplied."
		return
	endif

	let l:tags = split(l:input, '\v;')
	call map(l:tags, 'trim(v:val)')

	call utility#SaveRegisters(['z', 'y'])

	let @z = ""
	for i in l:tags
		let @z = @z."- ".i."\n"
	endfor

	mark `

	" check if the Zettel already has some tags
	let l:taglinenum = parse#HasZettelMetaDataTag()
	if l:taglinenum == v:false
		let l:insertafterlinenum = meta#GetZettelMetaDataEnd()
		let @y = "tags:\n"
		execute "normal! ".l:insertafterlinenum."gg\<esc>\"yp"
		let l:insertafterlinenum += 1
	else
		let l:insertafterlinenum = parse#GetZettelMetaDataTagEnd(l:taglinenum)
	endif

	execute "normal! ".l:insertafterlinenum."gg\<esc>\"zp``"	

	echom ""
	call utility#RestoreRegisters()
endfunction
