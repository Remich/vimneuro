function! zettels#Create(...)

	call utility#SaveRegisters(['x', 'y', 'z'])

	let l:filename = sha256(strftime('%s%N'))[0:7].'.md'
	let l:date     = strftime('%F')
	let l:created  = l:date."".strftime('T%H:%H')
	
	if a:0 == 1		" is there a function argument?
		let @x = "# ".a:1
	else
		let @x = "# Zettel created on ".l:date
	endif
	
	let @z = l:date
	let @y = l:created
	execute "edit! ".l:filename
	execute "normal! i---\<cr>date: \<esc>\"zpo"
	execute "normal! icreated: \<esc>\"ypo"
	execute "normal! i---\<esc>2o"
	execute "normal! \"xp2o"
	silent execute "w!"

	call utility#RestoreRegisters()
	
	return l:filename
endfunction
