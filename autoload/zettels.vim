function! zettels#TouchAndPrefill(title, name)

	call utility#SaveRegisters(['x', 'y', 'z'])

	if a:name ==# ""
		let l:filename = sha256(strftime('%s%N'))[0:7].'.md'
	else
		let l:filename = a:name
	endif
	
	let @x = "# ".a:title
	let @z = strftime('%F')
	let @y = strftime('%FT%H:%H') 
	
	execute "edit! ".l:filename
	execute "normal! i---\<cr>date: \<esc>\"zpo"
	execute "normal! icreated: \<esc>\"ypo"
	execute "normal! i---\<esc>2o"
	execute "normal! \"xp2o"
	silent execute "w!"

	call utility#RestoreRegisters()
endfunction

function! zettels#New(title)

	" check argument
	if a:title ==# ""
		let l:title = trim(input("Enter title for new Zettel: "))
		execute "redraw!" | echom " "
		if l:title ==# ""
			let l:title = 'Zettel created on '.strftime('%F')
		endif
	else
		let l:title = a:title
	endif

	" compute name
	let l:name     = zettels#ComputeNewZettelName(l:title)
	let l:filename = l:name.".md"

	" create Zettel
	call zettels#TouchAndPrefill(l:title, l:filename)
	
	" open Zettel
	execute "edit! ".l:filename
	execute "normal G"
	
endfunction

function! zettels#ComputeNewZettelName(title)

	let l:name = zettels#TransformTitleToName(a:title)

	if zettels#Exists(l:name) == v:true
		return zettels#GetIncrementalFilename(l:name)
	else
		return l:name
	endif

endfunction

function! zettels#TransformTitleToName(title)
	" replace spaces with '-'
	let l:name = a:title
	let l:name = substitute(l:name, '\v\s', '-', "g")
	" replace 'Umlaute'
	let l:name = substitute(l:name, '\vä', 'ae', "g")
	let l:name = substitute(l:name, '\vö', 'oe', "g")
	let l:name = substitute(l:name, '\vü', 'ue', "g")
	" replace 'ß'
	let l:name = substitute(l:name, '\vß', 'ss', "g")
	" remove all unallowed characters
	let l:name = substitute(l:name, '\v[^A-Za-z0-9_-]', '', "g")
	" replace multiple '-' with exactly one '-'
	let l:name = substitute(l:name, '\v-{2,}', '-', "g")
	" remove leading '-'
	let l:name = substitute(l:name, '\v^\zs-\ze.*', '', "g")
	" remove trailing '-'
	let l:name = substitute(l:name, '\v^.*\zs-\ze$', '', "g")
	" only lowercase letters
	let l:name = tolower(l:name)
	return l:name
endfunction

function! zettels#GetIncrementalFilename(name)
	let l:i        = 1
	let l:name     = a:name."-".l:i
	let l:filename = l:name.".md"
	let l:fullname = g:vimneuro_path_zettelkasten."/".l:filename

	while filereadable(l:fullname) == v:true
		let l:i        = l:i + 1
		let l:name     = a:name."-".l:i
		let l:filename = l:name.".md"
		let l:fullname = g:vimneuro_path_zettelkasten."/".l:filename
	endwhile

	return l:name
endfunction

function! zettels#Exists(name)
	let l:fullname = g:vimneuro_path_zettelkasten.'/'.a:name.'.md'
	if filereadable(l:fullname) == v:true
		return v:true
	else
		return v:false
	endif
endfunction

function! zettels#Delete()
	let l:filename = expand('%:p')
	let l:confirm  = confirm('Do you really want to delete Zettel '.shellescape(l:filename).'?', "&Yes\n&No")

	if l:confirm == 1
		let l:curbufname = bufname("%")
		if delete(l:filename) == -1
			echom "ERROR: Deletion failed."
		else
			let l:alternative = bufname("#")
			enew!
			execute "bwipeout! ".l:curbufname
			if l:alternative !=# ""
				execute "buffer ".l:alternative
			endif
		endif
	elseif l:confirm == 2
		return
	endif
endfunction

function! zettels#Rename(oldname, newname)

	" check if Zettel to rename really exists
	" TODO use zettels#Exists
	if filereadable(a:oldname) == v:false
		echom "ERROR: Zettel with name '".a:oldname."' does not exists!"
		return v:false
	endif

	" TODO use zettels#Exists
	" check for existing Zettel with supplied name
	if filereadable(a:newname) == v:true
		echom "ERROR: Zettel with name '".a:newname."' already exists!"
		return v:false
	endif

	" rename Zettel
	if rename(a:oldname, a:newname) == 0
		return v:true
	else
		return v:false
	endif

endfunction

function! zettels#RenameCurrent()

	let l:oldname = bufname()
	let l:newname = input("Enter new name: ")
	redraw
	echom ""

	if l:newname == ""
		echom "ERROR: No name supplied."
		return
	endif

	" check for valid name
	if match(l:newname, '[^A-Za-z0-9-_]') != -1
		echom "ERROR: '".l:newname."' is not a valid Zettel name. Allowed Characters: [A-Za-z0-9-_]"
		return
	endif

	let l:fullname = l:newname.".md"
	if zettels#Rename(l:oldname, l:fullname) != v:false
		execute "file! ".l:fullname
		silent write!

		" update all links
		let l:oldlink = substitute(l:oldname, '\v\.md', '', "")
		call link#Relink(l:oldlink, l:newname)
	endif

endfunction

function! zettels#RenameCurrentZettelToTitle(...)

	" per default, always confirm
	let l:dont_confirm = v:false

	if a:0 > 1
		echom "ERROR: Too many arguments supplied. Only zero or one argument are allowed."
	endif

	" check for optional argument, 
	" if we should prompt for confirmation before renaming
	if a:0 == 1		" is there a function argument?
		if a:1			" does the argument evaluate to true?
			let l:dont_confirm = v:true
		endif
	endif
	
	let l:title = parse#GetZettelTitle()
	if l:title == v:false
		echom "ERROR: No title found!"
		return
	endif

	let l:newname = zettels#TransformTitleToName(l:title)

	if l:newname ==# ""
		echom "ERROR: Title is empty!"
		return
	endif

	" abort, if name of Zettel is already the same as the title
	let l:filename = expand('%')	
	let l:basename = substitute(l:filename, '\v\.md', '', "")
	if l:newname ==# l:basename
		echom "Nothing to do."
		return
	endi

	if l:dont_confirm == v:false
		let l:confirm = confirm('Rename Zettel to '.shellescape(l:newname).'?', "&Yes\n&No")
	else
		let l:confirm = 1
	endif

	if l:confirm == 1
		
		let l:fullname = l:newname.".md"
		let l:oldname  = l:filename
		
		if zettels#Rename(l:oldname, l:fullname) != v:false
			execute "file! ".l:fullname
			silent write!

			" update all links
			call link#Relink(l:basename, l:newname)
		endif

	else
		return
	endif
endfunction
