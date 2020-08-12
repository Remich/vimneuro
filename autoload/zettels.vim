function! zettels#Create(...)

	let l:save_reg_z = @z
	let l:save_reg_y = @y
	let l:save_reg_x = @x

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

	let @z = l:save_reg_z
	let @y = l:save_reg_y
	let @x = l:save_reg_x
	
	return l:filename
endfunction
