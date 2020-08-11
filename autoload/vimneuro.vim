function! vimneuro#GoZettel()
	let l:word = expand("<cWORD>")

	" check if this is a valid Neuron link
	if match(l:word, '\v\<[A-Za-z0-9-_]+(\?cf)?\>') == -1
		return
	endif

	" extract filename
	let l:filename = []
	call substitute(l:word, '\v\<\zs.*\ze(\?cf)?\>', '\=add(l:filename, submatch(0))', 'g')
	let l:filename = l:filename[0].".md"

	" check for existing Zettel with supplied name
	let l:fullname = g:vimneuro_path_zettelkasten."/".l:filename
	if filereadable(l:fullname) == v:false
		echom "ERROR: Zettel with name '".l:fullname."' does not exist!"
		return
	endif

	" open Zettel in current window
	execute "edit! ".l:filename
endfunction

function! vimneuro#InsertMetaDataCreated()
	let l:reg_save = @z
	let l:date = trim(system('date "+%Y-%m-%dT%H:%M"'))
	let @z = "created: ".l:date."\n"
	execute "normal! 1j\"zpG"
	let @z = l:reg_save
endfunction

function! vimneuro#TransformTitleToName(title)
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

function! vimneuro#NewZettel()

	let l:title = trim(input("Enter title for new Zettel: "))

	" no title supplied, use default
	if l:title ==# ''
		let l:today = system('date "+%Y-%m-%d"')
		let l:title = 'Zettel created on '.l:today
		let l:name  = ''
	else
		let l:name = vimneuro#TransformTitleToName(l:title)
	endif

	redraw
	call vimneuro#CreateZettel(l:name, l:title)
endfunction

function! vimneuro#CreateZettel(name, title)

	if a:name != ""

		" check for valid name
		if match(a:name, '[^A-Za-z0-9-_]') != -1
			echom "ERROR: '".a:name."' is not a valid Zettel name. Allowed Characters: [A-Za-z0-9-_]"
			return
		endif

		" check for existing Zettel with supplied name
		let l:fullname = g:vimneuro_path_zettelkasten."/".a:name.".md"
		if filereadable(l:fullname) == v:true
			echom "ERROR: Zettel with name '".a:name."' already exists!"
			return
		endif
	endif

	" create Zettel
	if a:title == ""
		" let l:res = trim(system("neuron new"))
		let l:cmd = "neuron new"
	else
		" let l:res = trim(system("neuron new ".shellescape(a:title)))
		let l:cmd = "neuron new ".shellescape(a:title)
	endif

	let s:name = a:name
	let s:stdout = []

	function! s:OnEvent(job_id, data, event) dict

		if a:event == 'stdout'
			call add(s:stdout, join(a:data))
			let str = self.shell.' stdout: '.join(a:data)
		elseif a:event == 'stderr'
			let str = self.shell.' stderr: '.join(a:data)
		else
			let str = self.shell.' exited'

			if s:name != ""
				let l:fullname = g:vimneuro_path_zettelkasten."/".s:name.".md"
				call vimneuro#RenameZettel(trim(s:stdout[0]), l:fullname)
				execute "edit! ".l:fullname
			else
				execute "edit! ".trim(s:stdout[0])
			endif

			" insert meta-data 'created'
			call vimneuro#InsertMetaDataCreated()
		endif

		echom str
	endfunction

	let s:callbacks = {
				\ 'on_stdout': function('s:OnEvent'),
				\ 'on_stderr': function('s:OnEvent'),
				\ 'on_exit': function('s:OnEvent')
				\ }

	let job1 = jobstart(['bash', '-c', l:cmd], extend({'shell': 'shell 1'}, s:callbacks))
endfunction

function! vimneuro#DeleteZettel()
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

function! vimneuro#RenameZettel(oldname, newname)

	" check if Zettel to rename really exists
	if filereadable(a:oldname) == v:false
		echom "ERROR: Zettel with name '".a:oldname."' does not exists!"
		return v:false
	endif

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

function! vimneuro#RenameCurrentZettel()

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
	if vimneuro#RenameZettel(l:oldname, l:fullname) != v:false
		execute "file! ".l:fullname
		silent write!

		" update all links
		let l:oldlink = substitute(l:oldname, '\v\.md', '', "")
		call vimneuro#RelinkZettel(l:oldlink, l:newname)
	endif

endfunction

function! vimneuro#GetZettelTitle()
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

function! vimneuro#RenameCurrentZettelToTitle()
	let l:title   = vimneuro#GetZettelTitle()
	if l:title == v:false
		echom "ERROR: No title found!"
		return
	endif

	let l:newname = vimneuro#TransformTitleToName(l:title)

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

	let l:confirm = confirm('Rename Zettel to '.shellescape(l:newname).'?', "&Yes\n&No")

	if l:confirm == 1
		
		let l:fullname = l:newname.".md"
		let l:oldname  = l:filename
		
		if vimneuro#RenameZettel(l:oldname, l:fullname) != v:false
			execute "file! ".l:fullname
			silent write!

			" update all links
			call vimneuro#RelinkZettel(l:basename, l:newname)
		endif

	else
		return
	endif
endfunction

" replaces links to Zettel 'oldname' with 'newname' in every Zettel
function! vimneuro#RelinkZettel(oldname, newname)
	let l:curbuf    = bufnr()
	let linkpattern = '<'.a:oldname.'(\?cf)?>'

	silent execute "grep! '".linkpattern."'" 
	" copen
	execute 'cfdo %substitute/\v\<'.a:oldname.'(\?cf)?\>/\<'.a:newname.'\1\>/g'
	cfdo update

	" switch back to original buffer
	execute "buffer ".l:curbuf	
	return v:true
endfunction

function! vimneuro#CreateLinkOfFilename(filename)
	return "<" . substitute(a:filename, '\.md', '', "") .">"
endfunction

function! vimneuro#PasteLinkAsUlItem()
	execute "normal! o\<esc>\"_d0i- \<c-r>+\<esc>"
endfunction

function! vimneuro#GetLinkToAlternateBuffer()
	let l:filename = bufname(0)

	if l:filename ==# ""
		echom "ERROR: No alternative buffer"
		return v:false
	endif

	return vimneuro#CreateLinkOfFilename(l:filename)
endfunction

function! vimneuro#InsertLinkToAlternateBuffer()
	let l:link = vimneuro#GetLinkToAlternateBuffer()
	if l:link != v:false
		call nvim_paste(l:link, v:true, -1)
	endif
endfunction

function! vimneuro#InsertLinkToAlternateBufferAsUlItem()
	let l:link = vimneuro#GetLinkToAlternateBuffer()
	if l:link != v:false
		let @+ = l:link
		call vimneuro#PasteLinkAsUlItem()
	endif
endfunction

function! vimneuro#GetIncrementalFilename(name)
	let l:i        = 1
	let l:name     = a:name."-".l:i.".md"
	let l:fullname = g:vimneuro_path_zettelkasten."/".a:name

	while filereadable(l:fullname) == v:true
		let l:i        = l:i + 1
		let l:name     = a:name."-".l:i.".md"
		let l:fullname = g:vimneuro_path_zettelkasten."/".a:name
	endwhile

	return a:name."-".l:i
endfunction

" create a neuron link to the zettel matching the text
function! vimneuro#LinkingOperator(type)
	let sel_save = &selection
	let &selection = "inclusive"
	let reg_save_1 = @@
	let reg_save_2 = @k

	if a:type ==# 'v'
		normal! `<v`>y
	elseif a:type ==# 'char'
		normal! `[v`]y
	else
		return
	endif

	let l:title = trim(@@)
	silent execute "grep! '^\\# ".l:title."$'" 
	let l:results = getqflist()

	if len(l:results) == 0

		let l:confirm = confirm("ERROR: No Zettel with title ".shellescape(l:title)." found. Create new Zettel?", "&Yes\n&No")
		if l:confirm == 1
			let l:name     = vimneuro#TransformTitleToName(l:title)
			let l:fullname = g:vimneuro_path_zettelkasten."/".l:name.".md"
			if filereadable(l:fullname) == v:true
				let l:name = vimneuro#GetIncrementalFilename(l:name)
			endif
			call vimneuro#CreateZettel(l:name, l:title)
		else
			echom ""
		endif

	elseif len(l:results) > 1
		echoe "ERROR: Multiple Zettels with title (".shellescape(l:title).") found."
	else
		let d = l:results[0]
		let l:basename = trim(system('basename '.shellescape(bufname(d.bufnr))))
		let @k = vimneuro#CreateLinkOfFilename(l:basename)
		normal! `[v`]"kp
	endif

	let &selection = sel_save
	let @@ = reg_save_1
	let @k = reg_save_2
endfunction

function! vimneuro#CopyLinkOfCurrentBuffer()
	let l:filename = substitute(expand('%'), '\v\.md', '', "")
	let @+ = "<".l:filename.">"
	echom "'<".l:filename.">' copied to + register"
endfunction

function! vimneuro#CopyLinkOfCurrentLine(linenum)
	let l:link = vimneuro#GetLinkOfCurrentLine(a:linenum)	
	let @+ = l:link
	echom "'".l:link."' copied to + register"
endfunction

" searches for `FOOBAR.md` in the current line,
" creates and returns a Neuron link
function! vimneuro#GetLinkOfCurrentLine(linenum)
	let l:line     = getline(a:linenum)
	let l:filename = []
	call substitute(l:line, '\v(^|\s)\zs[a-z0-9]+\ze\.md', '\=add(l:filename, submatch(0))', 'g')

	if len(l:filename) == 0
		return
	endif

	let l:links = map(l:filename, '"<".v:val.">"')
	return l:links[0]
endfunction

function! vimneuro#CopyLinkOfSelection()
	let l:start = getpos("'<")
	let l:stop  = getpos("'>")
	let l:lines = range(l:start[1], l:stop[1])
	let l:links = map(l:lines, 'vimneuro#GetLinkOfCurrentLine(v:val)')
	let str = ""
	for i in l:links
		if i == v:false
			continue
		endif
		let str = str.i."\n"	
	endfor
	let @+ = str
	echom "Copied links to + register"
endfunction

function! vimneuro#PreviewFile()

	if exists("g:vimneuro_cmd_browser") == v:false
		echom "ERROR: 'g:vimneuro_cmd_browser' not set! Abort."
		return
	endif

	let l:filename = substitute(expand('%'), '\v\.md', '\.html', "")
	let l:url      = g:vimneuro_url_zettelkasten."/".l:filename
	let l:cmd      = shellescape(g:vimneuro_cmd_browser)." ".shellescape(l:url)

	if exists("g:vimneuro_cmd_browser_options") == v:true
		let l:opts = map(deepcopy(g:vimneuro_cmd_browser_options), 'shellescape(v:val)')
		let l:opts = join(l:opts, ' ')
		let l:cmd  = l:cmd." ".l:opts
	endif

	silent call jobstart(l:cmd)
endfunction

function! vimneuro#HasZettelMetaDataTag()
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

function! vimneuro#GetZettelMetaDataTagEnd(taglinenum)
	let l:curlinenum = a:taglinenum		
	let l:curline = getline(l:curlinenum)
	while match(l:curline, '\v- ') != -1
		let l:curlinenum = l:curlinenum + 1
		let l:curline = getline(l:curlinenum)
	endwhile
	return l:curlinenum
endfunction

function! vimneuro#GetZettelMetaDataEnd()
	let l:curlinenum = 2
	let l:curline = getline(l:curlinenum)
	while match(l:curline, '\v---') == -1
		let l:curlinenum = l:curlinenum + 1
		let l:curline = getline(l:curlinenum)
	endwhile
	return l:curlinenum - 1
endfunction

function! vimneuro#AddTag()
	let l:input = trim(input("Enter tag(s): "))
	if l:input ==# ""
		echom "ERROR: No tag(s) supplied."
		return
	endif

	let l:tags = split(l:input, '\v;')
	call map(l:tags, 'trim(v:val)')

	let l:regsave = @z

	let @z = ""
	for i in l:tags
		let @z = @z."- ".i."\n"
	endfor

	mark `

	" check if the Zettel already has some tags
	let l:taglinenum = vimneuro#HasZettelMetaDataTag()
	if l:taglinenum == v:false
		let l:insertafterlinenum = vimneuro#GetZettelMetaDataEnd()
		let l:regsave_1 = @y
		let @y = "tags:\n"
		execute "normal! ".l:insertafterlinenum."gg\<esc>\"yp"
		let @y = l:regsave_1
		let l:insertafterlinenum += 1
	else
		let l:insertafterlinenum = vimneuro#GetZettelMetaDataTagEnd(l:taglinenum)
	endif

	execute "normal! ".l:insertafterlinenum."gg\<esc>\"zp``"	

	echom ""
	let @z = l:regsave
endfunction
