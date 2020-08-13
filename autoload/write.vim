function! write#MetaData(meta)
	" remove old meta-data
	call deletebufline(bufname(), a:meta['start']+1, a:meta['end']-1)

	let l:i = a:meta['start']

	" write date
	if a:meta['date']['val'] != -1
		" write date always in first line of meta data
		call append(l:i, "date: ".a:meta['date']['val'])
		let l:i += 1
	endif
	
	" write created
	if a:meta['created']['val'] != -1
		" write date always in first line of meta data
		call append(l:i, "created: ".a:meta['created']['val'])
		let l:i += 1
	endif

	" write tags
	if len(a:meta['tags']) > 0
		call append(l:i, 'tags:')
		let l:i += 1
		for tag in a:meta['tags']
			call append(l:i, '- '.tag)
			let l:i += 1
		endfor
	endif
	
endfunction
