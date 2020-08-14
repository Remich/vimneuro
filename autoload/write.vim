function! write#MetaData(meta)

	echom a:meta
	
	" write date
	if a:meta['date']['val'] != -1
		" write date always in first line of meta data
		call setline(a:meta['date']['line'], "date: ".a:meta['date']['val'])
	endif
	
	" write created
	if a:meta['created']['val'] != -1
		" write date always in first line of meta data
		call setline(a:meta['created']['line'], "created: ".a:meta['created']['val'])
	endif

	" write tags
	if a:meta['tags_start'] == -1
		let l:i = a:meta['end'] - 1
	else
		let l:i = a:meta['tags_start'] - 1
	endif

	" remove old tags
	call deletebufline(bufname(), a:meta['tags_start'], a:meta['tags_end'])
	
	if len(a:meta['tags']) > 0
		call append(l:i, 'tags:')
		let l:i += 1
		for tag in a:meta['tags']
			call append(l:i, '- '.tag)
			let l:i += 1
		endfor
	endif
	
endfunction
