function! parse#MetaData()

	let l:meta = {
				\ 'start'				: 1,
				\ 'end'					: -1,
				\ 'date'				: {'val': -1, 'line': -1},
				\ 'created'			: {'val': -1, 'line': -1},
				\ 'tags_start'	: -1,
				\ 'tags_end'		: -1,
				\ 'tags'				: []
				\ }
	
	" parse line by line:

	let l:i         = 1
	let l:end_found = v:false
	let l:lastline  = line('$')
	let l:filename  = bufname()
	let l:state = 'parsing_meta'

	while l:i <= l:lastline && l:end_found == v:false

		let l:curline = getline(l:i)

		" is line empty?
		if l:i > 1 && match(l:curline, '\v^\s*$') != -1
			echoe "Parsing of '".l:filename."' failed! Meta-Section has empty lines."
			return {}
		endif

		" is line meta end?
		if l:i > 1 && match(l:curline, '\v^---$') != -1
			let l:meta['end'] = l:i
			let l:end_found = v:true

			if l:state ==# 'parsing_tags'
				let l:meta['tags_end'] = l:i - 1
			endif
			
			continue
		endif

		" check for missing meta end
		" this check fails if the Zettel also is missing the level-1 heading
		if l:i > 1 && match(l:curline, '\v^#.*$') != -1
			echoe "Parsing of '".l:filename."' failed! Meta-Section has no end."
			return {}
		endif

		if l:state ==# 'parsing_meta'
		
			" is first line of Zettel a meta start?
			if l:i == 1 && match(l:curline, '\v^---$') == -1
				echoe "Parsing of '".l:filename."' failed! First line is missing '---'."
				return {}
			elseif l:i == 1
				let l:i += 1
				continue
			endif

			" is line meta attribute?
			if match(l:curline, '\v^[^:]+:[^:]*$') != -1
				
				" check for missing ':'
				if match(l:curline, '\v^.*:.*$') == -1
					echoe "Parsing of '".l:filename."' failed! Missing ':' in line ".l:i
					return {}
				endif

				" extract meta type from current line
				let l:metaattribute = []
				call substitute(l:curline, '\v^\zs[^:]+\ze:', '\=add(l:metaattribute, submatch(0))', 'g')

				if l:metaattribute[0] ==# "date"
					" extract 'date' value
					let l:date = []
					call substitute(l:curline, '\v^[^:]+:\zs[^$]+\ze', '\=add(l:date, submatch(0))', 'g')
					
					if len(l:date) == 0 || trim(l:date[0]) ==# ""
						echoe "Parsing of '".l:filename."' failed! Attribute 'date' has no value."
						return {}	
					endif
						
					let l:meta['date']['val']  = trim(l:date[0])
					let l:meta['date']['line'] = l:i
					
				elseif l:metaattribute[0] ==# "created"
					" extract 'created' value
					let l:created = []
					call substitute(l:curline, '\v^[^:]+:\zs[^$]+\ze', '\=add(l:created, submatch(0))', 'g')
					
					if len(l:created) == 0 || trim(l:created[0]) ==# ""
						echoe "Parsing of '".l:filename."' failed! Attribute 'created' has no value."
						return {}	
					endif
					
					let l:meta['created']['val']  = trim(l:created[0])
					let l:meta['created']['line'] = l:i
					
				elseif l:metaattribute[0] ==# "tags"
					
					" now the tags section starts
					let l:meta['tags_start'] = l:i
					let l:state = 'parsing_tags'
					let l:i += 1
					continue
					
				endif
				
			endif
			
		elseif l:state ==# 'parsing_tags'

			" check for missing '-'
			if match(l:curline, '\v^- .*$') == -1
				echoe "Parsing of '".l:filename."' failed! Missing '- ' in line ".l:i
				return {}
			endif

			" is ending of tag section?
			if match(l:curline, '\v^([^-]|---$)') != -1
				" now the tags section ends
				let l:meta['tags_end'] = l:i - 1
				let l:state = 'parsing_meta'
				continue
			endif
		
			" extract tags
			let l:tag = []
			call substitute(l:curline, '\v^- \zs[^$]+\ze$', '\=add(l:tag, submatch(0))', 'g')
			
			if len(l:tag) == 0 || trim(l:tag[0]) ==# ""
				echoe "Parsing of '".l:filename."' failed! Attribute 'tags' has one or more empty value(s)."
				return {}	
			endif
			
			call add(l:meta['tags'], trim(l:tag[0]))
		endif

		let l:i += 1
	endwhile

	return l:meta
endfunction


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

