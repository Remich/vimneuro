" File: vimneuro.vim
" Author: René Michalke <rene@renemichalke.de>
" Description: A Vim Plugin for managing a Neuron Zettelkasten.

" Disable loading of plugin.
if exists("g:vimneuro_load") && g:vimneuro_load == 0
	finish
endif

if exists("g:vimneuro_path_zettelkasten") == v:false
	let g:vimneuro_path_zettelkasten = "/home/".$USER."/zettelkasten"
endif

if exists("g:vimneuro_url_zettelkasten") == v:false
	let g:vimneuro_url_zettelkasten = "http://localhost/zettelkasten"
endif

if exists("g:vimneuro_random_names") == v:true && g:vimneuro_random_names == 1
	let g:vimneuro_random_names = v:true
else
	let g:vimneuro_random_names = v:false
endif

" check if 'ripgrep' is installed
if trim(system("whereis rg")) ==# "rg:"
	echoe "ERRROR: ripgrep not found! A lot of stuff won't work. Please install rigrep."
endif

" Save user options, for restoring at the end of the script.
call utility#SaveOptions()
call utility#SetOptions()

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
			noremap <SID>GoZettel		:<c-u>call navigation#Go()<CR>
		endif

		" New Neuron Zettel
		if !hasmapto('<Plug>NeuronNewZettel')
			autocmd Filetype markdown nmap <buffer><leader>nn	<Plug>NeuronNewZettel
			noremap <unique> <script> <Plug>NeuronNewZettel		<SID>NewZettel
			noremap <SID>NewZettel		:<c-u>call zettels#New("")<CR>
		endif

		" Delete Zettel
		if !hasmapto('<Plug>NeuronDeleteZettel')
			autocmd Filetype markdown nmap <buffer><leader>nd	<Plug>NeuronDeleteZettel
			noremap <unique> <script> <Plug>NeuronDeleteZettel		<SID>DeleteZettel
			noremap <SID>DeleteZettel		:<c-u>call zettels#Delete()<CR>
		endif

		" Rename current Neuron Zettel
		if !hasmapto('<Plug>NeuronRenameCurrentZettel')
			autocmd Filetype markdown nmap <buffer><leader>nr	<Plug>NeuronRenameCurrentZettel
			noremap <unique> <script> <Plug>NeuronRenameCurrentZettel		<SID>RenameCurrentZettel
			noremap <SID>RenameCurrentZettel		:<c-u>call zettels#RenameCurrent()<CR>
		endif

		" Rename current Neuron Zettel to title of Zettel
		if !hasmapto('<Plug>NeuronRenameCurrentZettelToTitle')
			autocmd Filetype markdown nmap <buffer><leader>nR	<Plug>NeuronRenameCurrentZettelToTitle
			noremap <unique> <script> <Plug>NeuronRenameCurrentZettelToTitle		<SID>RenameCurrentZettelToTitle
			noremap <SID>RenameCurrentZettelToTitle		:<c-u>call zettels#RenameCurrentZettelToTitle()<CR>
			command! -nargs=? VNRenameToTitle	:call zettels#RenameCurrentZettelToTitle(<args>)
		endif

		if !hasmapto('<Plug>NeuronInsertLinkToAlternateBuffer')
			autocmd Filetype markdown nmap <buffer><leader>na	<Plug>NeuronInsertLinkToAlternateBuffer
			noremap <unique> <script> <Plug>NeuronInsertLinkToAlternateBuffer		<SID>InsertLinkToAlternateBuffer
			noremap <SID>InsertLinkToAlternateBuffer		:<c-u>call link#InsertLinkToAlternateBuffer()<CR>
		endif

		" Insert link of alternate file as unordered list item below the current line
		if !hasmapto('<Plug>NeuronInsertLinkToAlternateBufferAsUlItem')
			autocmd Filetype markdown nmap <buffer><leader>ap		<Plug>NeuronInsertLinkToAlternateBufferAsUlItem
			noremap <unique> <script> <Plug>NeuronInsertLinkToAlternateBufferAsUlItem		<SID>InsertLinkToAlternateBufferAsUlItem
			noremap <SID>InsertLinkToAlternateBufferAsUlItem		:<c-u>call link#InsertLinkToAlternateBufferAsUlItem()<cr>
		endif

		" Linking Operator (Normal Mode)
		if !hasmapto('<Plug>NeuronLinkingOperatorNormal')
			autocmd Filetype markdown nmap <buffer><leader>nl	<Plug>NeuronLinkingOperatorNormal
			noremap <unique> <script> <Plug>NeuronLinkingOperatorNormal		<SID>LinkingOperatorNormal
			noremap <SID>LinkingOperatorNormal		:<c-u>set operatorfunc=link#LinkingOperator<cr>g@
		endif

		" Linking Operator (Visual Mode)
		if !hasmapto('<Plug>NeuronLinkingOperatorVisual')
			autocmd Filetype markdown vmap <buffer><leader>nl	<Plug>NeuronLinkingOperatorVisual
			noremap <unique> <script> <Plug>NeuronLinkingOperatorVisual		<SID>LinkingOperatorVisual
			noremap <SID>LinkingOperatorVisual		:<c-u>call link#LinkingOperator(visualmode())<cr>
		endif

		" Create & copy link of filename of current buffer 
		if !hasmapto('<Plug>NeuronCopyLinkOfCurrentBuffer')
			autocmd Filetype markdown nmap <buffer><c-c>	<Plug>NeuronCopyLinkOfCurrentBuffer
			noremap <unique> <script> <Plug>NeuronCopyLinkOfCurrentBuffer		<SID>CopyLinkOfCurrentBuffer
			noremap <SID>CopyLinkOfCurrentBuffer		:<c-u>call link#CopyLinkOfCurrentBuffer()<cr>
		endif

		" Paste link as unordered list item below the current line
		if !hasmapto('<Plug>NeuronPasteLinkAsUlItem')
			autocmd Filetype markdown nmap <buffer><leader>p	<Plug>NeuronPasteLinkAsUlItem
			noremap <unique> <script> <Plug>NeuronPasteLinkAsUlItem		<SID>PastLinkAsUlItem
			noremap <SID>PastLinkAsUlItem		:<c-u>call link#PasteLinkAsUlItem()<cr>
		endif

		" Create & copy link of first filename in current line
		if !hasmapto('<Plug>NeuronCopyLinkOfCurrentLine')
			autocmd Filetype markdown,qf nmap <buffer><leader>C		<Plug>NeuronCopyLinkOfCurrentLine
			noremap <unique> <script> <Plug>NeuronCopyLinkOfCurrentLine		<SID>CopyLinkOfCurrentLine
			noremap <SID>CopyLinkOfCurrentLine		:<c-u>call link#CopyLinkOfCurrentLine(line('.'))<cr>
		endif

		" Create & copy link of first filename in current visual selection
		if !hasmapto('<Plug>NeuronCopyLinkOfSelection')
			autocmd Filetype markdown,qf vmap <buffer><leader>C		<Plug>NeuronCopyLinkOfSelection
			noremap <unique> <script> <Plug>NeuronCopyLinkOfSelection		<SID>CopyLinkOfSelection
			noremap <SID>CopyLinkOfSelection		:<c-u>call link#CopyLinkOfSelection()<cr>
		endif

		" Preview current file in new Firefox Tab
		if !hasmapto('<Plug>NeuronPreviewFile')
			autocmd Filetype markdown nmap <buffer><leader>np	<Plug>NeuronPreviewFile
			noremap <unique> <script> <Plug>NeuronPreviewFile		<SID>PreviewFile
			noremap <SID>PreviewFile		:<c-u>call navigation#Preview()<cr>
		endif
		
		" Add tag
		if !hasmapto('<Plug>NeuronAddTag')
			autocmd Filetype markdown nmap <buffer><leader>nt	<Plug>NeuronAddTag
			noremap <unique> <script> <Plug>NeuronAddTag		<SID>AddTag
			noremap <SID>AddTag		:<c-u>call meta#AddTag()<cr>
			command! -nargs=1 VNAddTag	:call meta#AddTag(<args>)
		endif
		
		" Remove tag
		if !hasmapto('<Plug>NeuronRemoveTag')
			autocmd Filetype markdown nmap <buffer><leader>nT	<Plug>NeuronRemoveTag
			noremap <unique> <script> <Plug>NeuronRemoveTag		<SID>RemoveTag
			noremap <SID>RemoveTag		:<c-u>call meta#RemoveTag()<cr>
			command! -nargs=1 VNRemoveTag	:call meta#RemoveTag(<args>)
		endif

		" Search by Tags
		if !hasmapto('<Plug>NeuronSearchByTags')
			autocmd Filetype markdown,qf nmap <buffer><leader>S	<Plug>NeuronSearchByTags
			noremap <unique> <script> <Plug>NeuronSearchByTags		<SID>SearchByTags
			noremap <SID>SearchByTags		:<c-u>call search#ByTags()<cr>
		endif
		
		" call vimneuro#Foobar()<cr>

		let g:vimneuro_did_load_mappings = 1
	endif
augroup END

" restore user options
call utility#RestoreOptions()
