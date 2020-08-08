" File: vimneuro.vim
" Author: René Michalke <rene@renemichalke.de>
" Description: A Vim Plugin for managing a Neuron Zettelkasten.

" Disable loading of plugin.
if exists("g:vimneuro_load") && g:vimneuro_load == 0
	finish
endif

" TODO Check for User Setting of path to Zettelkasten
let g:vimneuro_path_zettelkasten = "/home/".$USER."/zettelkasten"

" Save user's options, for restoring at the end of the script.
let s:save_cpo = &cpo
set cpo&vim

augroup vimneuro
	autocmd!

	" ============
	" = MAPPINGS =
	" ============

	if exists("g:vimneuro_did_load_mappings") == v:false

		" Go Zettel
		if !hasmapto('<Plug>NeuronGoZettel')
			autocmd Filetype markdown nmap <buffer><leader>gf	<Plug>NeuronGoZettel
		endif
		noremap <unique> <script> <Plug>NeuronGoZettel		<SID>GoZettel
		noremap <SID>GoZettel		:<c-u>call vimneuro#GoZettel()<CR>
		
		" New Neuron Zettel
		if !hasmapto('<Plug>NeuronNewZettel')
			autocmd Filetype markdown nmap <buffer><leader>nn	<Plug>NeuronNewZettel
		endif
		noremap <unique> <script> <Plug>NeuronNewZettel		<SID>NewZettel
		noremap <SID>NewZettel		:<c-u>call vimneuro#NewZettel()<CR>

		" Rename current Neuron Zettel
		if !hasmapto('<Plug>NeuronRenameCurrentZettel')
			autocmd Filetype markdown nmap <buffer><leader>nr	<Plug>NeuronRenameCurrentZettel
		endif
		noremap <unique> <script> <Plug>NeuronRenameCurrentZettel		<SID>RenameCurrentZettel
		noremap <SID>RenameCurrentZettel		:<c-u>call vimneuro#RenameCurrentZettel()<CR>

		" Insert link to alternate buffer
		if !hasmapto('<Plug>NeuronInsertLinkToAlternateBuffer')
			autocmd Filetype markdown nmap <buffer><leader>na	<Plug>NeuronInsertLinkToAlternateBuffer
		endif
		noremap <unique> <script> <Plug>NeuronInsertLinkToAlternateBuffer		<SID>InsertLinkToAlternateBuffer
		noremap <SID>InsertLinkToAlternateBuffer		:<c-u>call vimneuro#InsertLinkToAlternateBuffer()<CR>
		
		" Insert link of alternate file as unordered list item below the current line
		if !hasmapto('<Plug>NeuronInsertLinkToAlternateBufferAsUlItem')
			autocmd Filetype markdown nmap <buffer><leader>a<c-v>	<Plug>NeuronInsertLinkToAlternateBufferAsUlItem
		endif
		noremap <unique> <script> <Plug>NeuronInsertLinkToAlternateBufferAsUlItem		<SID>InsertLinkToAlternateBufferAsUlItem
		noremap <SID>InsertLinkToAlternateBufferAsUlItem		:<c-u>call vimneuro#InsertLinkToAlternateBufferAsUlItem()<cr>
		
		" Linking Operator (Normal Mode)
		if !hasmapto('<Plug>NeuronLinkingOperatorNormal')
			autocmd Filetype markdown nmap <buffer><leader>nl	<Plug>NeuronLinkingOperatorNormal
		endif
		noremap <unique> <script> <Plug>NeuronLinkingOperatorNormal		<SID>LinkingOperatorNormal
		noremap <SID>LinkingOperatorNormal		:<c-u>set operatorfunc=vimneuro#LinkingOperator<cr>g@
		
		" Linking Operator (Visual Mode)
		if !hasmapto('<Plug>NeuronLinkingOperatorVisual')
			autocmd Filetype markdown vmap <buffer><leader>nl	<Plug>NeuronLinkingOperatorVisual
		endif
		noremap <unique> <script> <Plug>NeuronLinkingOperatorVisual		<SID>LinkingOperatorVisual
		noremap <SID>LinkingOperatorVisual		:<c-u>call vimneuro#LinkingOperator(visualmode())<cr>
		
		" Create & copy link of filename of current buffer 
		if !hasmapto('<Plug>NeuronCopyLinkOfCurrentBuffer')
			autocmd Filetype markdown nmap <buffer><c-c>	<Plug>NeuronCopyLinkOfCurrentBuffer
		endif
		noremap <unique> <script> <Plug>NeuronCopyLinkOfCurrentBuffer		<SID>CopyLinkOfCurrentBuffer
		noremap <SID>CopyLinkOfCurrentBuffer		:<c-u>call vimneuro#CopyLinkOfCurrentBuffer()<cr>
		
		" Paste link as unordered list item below the current line
		if !hasmapto('<Plug>NeuronPasteLinkAsUlItem')
			autocmd Filetype markdown nmap <buffer><leader><c-v>	<Plug>NeuronPasteLinkAsUlItem
		endif
		noremap <unique> <script> <Plug>NeuronPasteLinkAsUlItem		<SID>PastLinkAsUlItem
		noremap <SID>PastLinkAsUlItem		:<c-u>call vimneuro#PasteLinkAsUlItem()<cr>
		
		" Create & copy link of first filename in current line
		if !hasmapto('<Plug>NeuronCopyLinkOfCurrentLine')
			autocmd Filetype * nmap <buffer><leader>ncl	<Plug>NeuronCopyLinkOfCurrentLine
		endif
		noremap <unique> <script> <Plug>NeuronCopyLinkOfCurrentLine		<SID>CopyLinkOfCurrentLine
		noremap <SID>CopyLinkOfCurrentLine		:<c-u>call vimneuro#CopyLinkOfCurrentLine(line('.'))<cr>
		
		" Create & copy link of first filename in current visual selection
		if !hasmapto('<Plug>NeuronCopyLinkOfSelection')
			autocmd Filetype * vmap <buffer><leader>ncl	<Plug>NeuronCopyLinkOfSelection
		endif
		noremap <unique> <script> <Plug>NeuronCopyLinkOfSelection		<SID>CopyLinkOfSelection
		noremap <SID>CopyLinkOfSelection		:<c-u>call vimneuro#CopyLinkOfSelection()<cr>
		
		" call vimneuro#Foobar()<cr>

		let g:vimneuro_did_load_mappings = 1
	endif
augroup END

" Restore user's options.
let &cpo = s:save_cpo
unlet s:save_cpo
