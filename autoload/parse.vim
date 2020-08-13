function! parse#GetZettelTitle()
	let l:title      = []
	let l:found      = v:false
	let l:pattern    = '\v^# \zs.*\ze$'
	let l:curlinenum = 1
	let l:lastline   = line('$')

	while l:found == v:false && l:curlinenum != l:lastline + 1
		let l:curline = getline(l:curlinenum)
		if match(l:curline, l:pattern) != -1
			let l:found = v:true
			call substitute(l:curline, l:pattern, '\=add(l:title, submatch(0))', 'g')
			return l:title[0]
		endif
		let l:curlinenum += 1
	endwhile

	return v:false
endfunction

function! parse#HasZettelMetaDataTag()
	let l:curlinenum = 2
	let l:found      = v:false
	let l:curline    = getline(l:curlinenum)
	while match(l:curline, '\v---') == -1 && l:found == v:false
		let l:curlinenum = l:curlinenum + 1
		let l:curline    = getline(l:curlinenum)
		if match(l:curline, '\v^tags:') != -1
			let l:found = v:true
		endif
	endwhile

	if l:found == v:false
		return v:false
	else
		return l:curlinenum
	endif
endfunction

function! parse#GetZettelMetaDataTagEnd(taglinenum)
	let l:curlinenum = a:taglinenum		
	let l:curline = getline(l:curlinenum)
	while match(l:curline, '\v- ') != -1
		let l:curlinenum = l:curlinenum + 1
		let l:curline = getline(l:curlinenum)
	endwhile
	return l:curlinenum
endfunction

function! parse#GetZettelMetaDataEnd()
	let l:curlinenum = 2
	let l:curline = getline(l:curlinenum)
	while match(l:curline, '\v---') == -1
		let l:curlinenum = l:curlinenum + 1
		let l:curline = getline(l:curlinenum)
	endwhile
	return l:curlinenum - 1
endfunction

