let g:vimneuro_save_options   = {}
let g:vimneuro_save_registers = {}
let g:vimneuro_save_cf_id     = -1

function! utility#PrintOptions()
	echom &grepprg
	echom &grepformat
	echom &cpo
	echom &selection
	pwd
endfunction

function! utility#SaveOptions()
	let g:vimneuro_save_options["grepprg"]    = &grepprg
	let g:vimneuro_save_options["grepformat"] = &grepformat
	let g:vimneuro_save_options["cpo"]        = &cpo
	let g:vimneuro_save_options["selection"]  = &selection
	let g:vimneuro_save_options["cwd"]				= getcwd()
endfunction

function! utility#SetOptions()
	set grepprg=rg\ --vimgrep\ --smart-case
	set grepformat^=%f:%l:%c:%m
	set cpo&vim
	set selection=inclusive
endfunction

function! utility#RestoreOptions()
	let &grepprg    = g:vimneuro_save_options["grepprg"]
	let &grepformat = g:vimneuro_save_options["grepformat"]
	let &cpo        = g:vimneuro_save_options["cpo"]
	let &selection  = g:vimneuro_save_options["selection"]
	execute "cd ".g:vimneuro_save_options["cwd"]
endfunction

function! utility#PrintRegisters()
	echom g:vimneuro_save_registers
	for key in keys(g:vimneuro_save_registers)
		echom getreg(key)
	endfor
endfunction

function! utility#SaveRegisters(regs)
	for i in a:regs
		let g:vimneuro_save_registers[i] = getreg(i)
	endfor
endfunction

function! utility#RestoreRegisters()
	for key in keys(g:vimneuro_save_registers)
		call setreg(key, g:vimneuro_save_registers[key])
	endfor
	let g:vimneuro_save_registers = {}
endfunction

function! utility#SaveCfStack()
	
	" check if there are any qflists
  if getqflist({'nr' : '$'}).nr == 0
		" no, abort
		return
	endif
		
	" get id of current qflist
	let l:qfid = getqflist({'id' : 0}).id
	
	" save
	let g:vimneuro_save_cf_id = l:qfid
endfunction

function! utility#RestoreCfStack(qflist, title)
	
	" no previous list
	if g:vimneuro_save_cf_id == -1
		" empty whole stack
		call setqflist([], 'f')
		" add new list on top of stack
		call setqflist(a:qflist)
		return
	endif
		
	" get id of current list
	let l:cur_qfid = getqflist({'id': 0}).id

	while l:cur_qfid != g:vimneuro_save_cf_id
		" free current list
		call setqflist([], 'r')
		" go to previous list
		silent colder
		" get id of current list
		let l:cur_qfid = getqflist({'id': 0}).id
	endwhile
	
	" add new list on top of stack
	call setqflist(a:qflist)
	
	" set title
	call setqflist([], 'r', { 'title' : a:title })
		
endfunction
