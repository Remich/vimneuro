" File: vimneuro.vim
" Author: René Michalke <rene@renemichalke.de>
" Description: A Vim Plugin for managing a Neuron Zettelkasten.

" Disable loading of plugin.
if exists("g:vimneuro_load") && g:vimneuro_load == 0
  finish
endif

" Save user's options, for restoring at the end of the script.
let s:save_cpo = &cpo
set cpo&vim


function! s:Test()
	echom "hello from test"	
endfunction

augroup vimneuro
	autocmd!
	
	" ============
	" = MAPPINGS =
	" ============
	
	if exists("g:vimneuro_did_load_mappings") == v:false
	
	" Buffer local mapping for: open file on current line with `xdg-open`.
	if !hasmapto('<Plug>NeuroTest')
		autocmd Filetype markdown nmap <buffer><leader>qtq	<Plug>NeuroTest
	endif
	noremap <unique> <script> <Plug>NeuroTest		<SID>Test
	noremap <SID>Test		:<c-u> call <SID>Test()<CR>
	
	let g:vimneuro_did_load_mappings = 1
augroup END

" Restore user's options.
let &cpo = s:save_cpo
unlet s:save_cpo
