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

if exists("g:vimneuro_path_zettelkasten") == v:false
	let g:vimneuro_path_zettelkasten = "/home/".$USER."/zettelkasten"
endif

if exists("g:vimneuro_url_zettelkasten") == v:false
	let g:vimneuro_url_zettelkasten = "http://localhost/zettelkasten"
endif

augroup vimneuro
	autocmd!

	" ============
	" = MAPPINGS =
	" ============

	if exists("g:vimneuro_did_load_mappings") == v:false

		" Go Zettel
		if !hasmapto('<Plug>NeuronGoZettel')
			autocmd Filetype markdown nmap <buffer><leader>gf	<Plug>NeuronGoZettel
			noremap <unique> <script> <Plug>NeuronGoZettel		<SID>GoZettel
			noremap <SID>GoZettel		:<c-u>call vimneuro#GoZettel()<CR>
		endif

		" New Neuron Zettel
		if !hasmapto('<Plug>NeuronNewZettel')
			autocmd Filetype markdown nmap <buffer><leader>nn	<Plug>NeuronNewZettel
			noremap <unique> <script> <Plug>NeuronNewZettel		<SID>NewZettel
			noremap <SID>NewZettel		:<c-u>call vimneuro#NewZettel()<CR>
		endif

		" Delete Zettel
		if !hasmapto('<Plug>NeuronDeleteZettel')
			autocmd Filetype markdown nmap <buffer><leader>nd	<Plug>NeuronDeleteZettel
			noremap <unique> <script> <Plug>NeuronDeleteZettel		<SID>DeleteZettel
			noremap <SID>DeleteZettel		:<c-u>call vimneuro#DeleteZettel()<CR>
		endif

		" Rename current Neuron Zettel
		if !hasmapto('<Plug>NeuronRenameCurrentZettel')
			autocmd Filetype markdown nmap <buffer><leader>nr	<Plug>NeuronRenameCurrentZettel
			noremap <unique> <script> <Plug>NeuronRenameCurrentZettel		<SID>RenameCurrentZettel
			noremap <SID>RenameCurrentZettel		:<c-u>call vimneuro#RenameCurrentZettel()<CR>
		endif

		" Rename current Neuron Zettel to title of Zettel
		if !hasmapto('<Plug>NeuronRenameCurrentZettelToTitle')
			autocmd Filetype markdown nmap <buffer><leader>nR	<Plug>NeuronRenameCurrentZettelToTitle
			noremap <unique> <script> <Plug>NeuronRenameCurrentZettelToTitle		<SID>RenameCurrentZettelToTitle
			noremap <SID>RenameCurrentZettelToTitle		:<c-u>call vimneuro#RenameCurrentZettelToTitle()<CR>
			command! -nargs=0 VNRenameToTitle	:call vimneuro#RenameCurrentZettelToTitle()
		endif

		if !hasmapto('<Plug>NeuronInsertLinkToAlternateBuffer')
			autocmd Filetype markdown nmap <buffer><leader>na	<Plug>NeuronInsertLinkToAlternateBuffer
			noremap <unique> <script> <Plug>NeuronInsertLinkToAlternateBuffer		<SID>InsertLinkToAlternateBuffer
			noremap <SID>InsertLinkToAlternateBuffer		:<c-u>call vimneuro#InsertLinkToAlternateBuffer()<CR>
		endif

		" Insert link of alternate file as unordered list item below the current line
		if !hasmapto('<Plug>NeuronInsertLinkToAlternateBufferAsUlItem')
			autocmd Filetype markdown nmap <buffer><leader>a<c-v>	<Plug>NeuronInsertLinkToAlternateBufferAsUlItem
			noremap <unique> <script> <Plug>NeuronInsertLinkToAlternateBufferAsUlItem		<SID>InsertLinkToAlternateBufferAsUlItem
			noremap <SID>InsertLinkToAlternateBufferAsUlItem		:<c-u>call vimneuro#InsertLinkToAlternateBufferAsUlItem()<cr>
		endif

		" Linking Operator (Normal Mode)
		if !hasmapto('<Plug>NeuronLinkingOperatorNormal')
			autocmd Filetype markdown nmap <buffer><leader>nl	<Plug>NeuronLinkingOperatorNormal
			noremap <unique> <script> <Plug>NeuronLinkingOperatorNormal		<SID>LinkingOperatorNormal
			noremap <SID>LinkingOperatorNormal		:<c-u>set operatorfunc=vimneuro#LinkingOperator<cr>g@
		endif

		" Linking Operator (Visual Mode)
		if !hasmapto('<Plug>NeuronLinkingOperatorVisual')
			autocmd Filetype markdown vmap <buffer><leader>nl	<Plug>NeuronLinkingOperatorVisual
			noremap <unique> <script> <Plug>NeuronLinkingOperatorVisual		<SID>LinkingOperatorVisual
			noremap <SID>LinkingOperatorVisual		:<c-u>call vimneuro#LinkingOperator(visualmode())<cr>
		endif

		" Create & copy link of filename of current buffer 
		if !hasmapto('<Plug>NeuronCopyLinkOfCurrentBuffer')
			autocmd Filetype markdown nmap <buffer><c-c>	<Plug>NeuronCopyLinkOfCurrentBuffer
			noremap <unique> <script> <Plug>NeuronCopyLinkOfCurrentBuffer		<SID>CopyLinkOfCurrentBuffer
			noremap <SID>CopyLinkOfCurrentBuffer		:<c-u>call vimneuro#CopyLinkOfCurrentBuffer()<cr>
		endif

		" Paste link as unordered list item below the current line
		if !hasmapto('<Plug>NeuronPasteLinkAsUlItem')
			autocmd Filetype markdown nmap <buffer><leader><c-v>	<Plug>NeuronPasteLinkAsUlItem
			noremap <unique> <script> <Plug>NeuronPasteLinkAsUlItem		<SID>PastLinkAsUlItem
			noremap <SID>PastLinkAsUlItem		:<c-u>call vimneuro#PasteLinkAsUlItem()<cr>
		endif

		" Create & copy link of first filename in current line
		if !hasmapto('<Plug>NeuronCopyLinkOfCurrentLine')
			autocmd Filetype * nmap <buffer><leader>ncl	<Plug>NeuronCopyLinkOfCurrentLine
			noremap <unique> <script> <Plug>NeuronCopyLinkOfCurrentLine		<SID>CopyLinkOfCurrentLine
			noremap <SID>CopyLinkOfCurrentLine		:<c-u>call vimneuro#CopyLinkOfCurrentLine(line('.'))<cr>
		endif

		" Create & copy link of first filename in current visual selection
		if !hasmapto('<Plug>NeuronCopyLinkOfSelection')
			autocmd Filetype * vmap <buffer><leader>ncl	<Plug>NeuronCopyLinkOfSelection
			noremap <unique> <script> <Plug>NeuronCopyLinkOfSelection		<SID>CopyLinkOfSelection
			noremap <SID>CopyLinkOfSelection		:<c-u>call vimneuro#CopyLinkOfSelection()<cr>
		endif

		" Preview current file in new Firefox Tab
		if !hasmapto('<Plug>NeuronPreviewFile')
			autocmd Filetype markdown nmap <buffer><leader>np	<Plug>NeuronPreviewFile
			noremap <unique> <script> <Plug>NeuronPreviewFile		<SID>PreviewFile
			noremap <SID>PreviewFile		:<c-u>call vimneuro#PreviewFile()<cr>
		endif
		
		" Add tag
		if !hasmapto('<Plug>NeuronAddTag')
			autocmd Filetype markdown nmap <buffer><leader>nt	<Plug>NeuronAddTag
			noremap <unique> <script> <Plug>NeuronAddTag		<SID>AddTag
			noremap <SID>AddTag		:<c-u>call vimneuro#AddTag()<cr>
		endif

		" call vimneuro#Foobar()<cr>

		let g:vimneuro_did_load_mappings = 1
	endif
augroup END

" Restore user's options.
let &cpo = s:save_cpo
unlet s:save_cpo
