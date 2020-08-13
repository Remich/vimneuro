let g:vimneuro_save_options = {}
let g:vimneuro_save_registers = {}

function! utility#PrintOptions()
	echom &grepprg
	echom &grepformat
	echom &cpo
endfunction

function! utility#SaveOptions()
	let g:vimneuro_save_options["grepprg"]    = &grepprg
	let g:vimneuro_save_options["grepformat"] = &grepformat
	let g:vimneuro_save_options["cpo"]        = &cpo
endfunction

function! utility#SetOptions()
	set grepprg=rg\ --vimgrep\ --smart-case
	set grepformat^=%f:%l:%c:%m
	set cpo&vim
endfunction

function! utility#RestoreOptions()
	let &grepprg    = g:vimneuro_save_options["grepprg"]
	let &grepformat = g:vimneuro_save_options["grepformat"]
	let &cpo        = g:vimneuro_save_options["cpo"]
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
