" File: jsdoc.vim
"
" Author:   NAKAMURA, Hisashi <https://github.com/sunvisor>
"
" Contributors:
" - Shinya Ohyanagi <sohyanagi@gmail.com>
"   (https://github.com/heavenshell/vim-jsdoc/)
" - David O'Trakoun <me@davidosomething.com>
"   (https://github.com/davidosomething/vim-jsdoc/)
"
" Version:  0.7.0
"
" Description: Generate JSDoc to your JavaScript file.
" License: BSD, see LICENSE for more details.

let s:save_cpo = &cpo
set cpo&vim

let g:jsdoc_additional_descriptions = get(g:, 'jsdoc_additional_descriptions')
let g:jsdoc_return                  = get(g:, 'jsdoc_return', 1)
let g:jsdoc_return_description      = get(g:, 'jsdoc_return_description', 1)
let g:jsdoc_access_descriptions     = get(g:, 'jsdoc_access_descriptions')
let g:jsdoc_underscore_private      = get(g:, 'jsdoc_underscore_private')

let g:jsdoc_param_description_separator =
      \ get(g:, 'jsdoc_param_description_separator', ' ')
let g:jsdoc_custom_args_hook = exists('g:jsdoc_custom_args_hook')
      \ ? g:jsdoc_custom_args_hook
      \ : {}
let g:jsdoc_type_hook = exists('g:jsdoc_type_hook')
      \ ? g:jsdoc_type_hook
      \ : {}

" Default tag names
"   @returns      (synonyms: @return)
"   @function     (synonyms: @func, @method)
"   @param        (synonyms: @arg, @argument)
"   @description  (synonyms: @desc)
"   @class        (synonyms: @constructor)
let s:jsdoc_default_tags = {
      \   'returns':   'returns',
      \   'function':  'function',
      \   'param':     'param',
      \   'class':     'class'
      \ }

" This is the value that's actually used
let g:jsdoc_tags = exists('g:jsdoc_tags')
      \ ? g:jsdoc_tags
      \ : {}

" Fill in any missing ones with defaults, keeping user overrides
call extend(g:jsdoc_tags, s:jsdoc_default_tags, 'keep')

" Return data types for argument type auto completion :)
function! jsdoc#listDataTypes(A, L, P) abort
  let l:types = ['boolean', 'null', 'undefined', 'number', 'string', 'symbol', 'object', 'function', 'array']
  return join(l:types, "\n")
endfunction

" FIXME
" regex['arrow'] extracted extra chars.
" If `const foo = (arg1, arg2) => true;` extracts `(arg`, `arg2)`.
" We don't need `(` and `)`.
" Currently `(` and `)` are deleted by substitute().
" @see jsdoc#insert() for where these regexes are matched to the string
" @see test/test.js for examples
let s:regexs = {
      \   'function_declaration':  '^.\{-}\s*function\s*\*\?\s\+\([a-zA-Z_$][a-zA-Z0-9_$]*\)\s*\**(\s*\([^)]*\)\s*).*$',
      \   'function_expression':   '^.\{-}\s*\([a-zA-Z_$][a-zA-Z0-9_$]*\)\s*[:=]\s*function\s*\**\s*(\s*\([^)]*\)\s*).*$',
      \   'anonymous_function':    '^.\{-}\s*function\s*\**\s*(\s*\([^)]*\)\s*).*$',
      \   'shorthand':             '^.\{-}\s*\([a-zA-Z_$][a-zA-Z0-9_$]*\)\s*(\s*\([^)]*\)\s*).*$',
      \   'arrow':                 '^.\{-}\s*\([a-zA-Z_$][a-zA-Z0-9_$]*\)\s*[:=]\s*(\s*\([^)]*\)\s*)\s*=>.*$'
      \ }

function! s:build_description(argType, arg) abort
  let l:description = ''
  let l:override = 0
  if has_key(g:jsdoc_type_hook, a:argType)
    if type(g:jsdoc_type_hook[a:argType]) == 1
      let l:description = g:jsdoc_type_hook[a:argType]
    elseif type(g:jsdoc_type_hook[a:argType]) == 4
      if has_key(g:jsdoc_type_hook[a:argType], 'force_override')
        let l:override = g:jsdoc_type_hook[a:argType]['force_override']
      endif
      if has_key(g:jsdoc_type_hook[a:argType], 'description')
        let l:description = g:jsdoc_type_hook[a:argType]['description']
      endif
    endif
  endif

  return l:description
endfunction

function! s:hookArgs(lines, space, arg, hook, argType, argDescription) abort
  " Hook function signature's args for insert as default value.
  if g:jsdoc_custom_args_hook == {}
    call add(a:lines, a:space . ' * @' . g:jsdoc_tags['param'] . ' ' . a:arg)
  else

    let l:matchedArg = ''

    " Loop through regexes list `hook = keys(g:jsdoc_custom_args_hook)` to
    " find first instance where the arg name is matched by the hook regex
    for l:pat in a:hook
      if !empty(matchstr(a:arg, l:pat))
        let l:matchedArg = l:pat
        break
      endif
    endfor

    if l:matchedArg ==# ''

      let l:type = '{' . a:argType . '} '
      let l:description = a:argDescription !=# ''
            \ ? g:jsdoc_param_description_separator . a:argDescription
            \ : ''
      call add(a:lines, a:space . ' * @' . g:jsdoc_tags['param'] . ' ' . l:type . a:arg . l:description)

    else

      let l:type = ''
      let l:customArg = g:jsdoc_custom_args_hook[l:matchedArg]
      if a:argType ==# ''
        if has_key(l:customArg, 'type')
          let l:type = l:customArg['type'] . ' '
        endif
      else
        let l:type = '{' . a:argType . '} '
      endif

      let l:description = ''
      if a:argDescription ==# ''
        if has_key(l:customArg, 'description')
          let l:description = g:jsdoc_param_description_separator . l:customArg['description']
        endif
      else
        let l:description = g:jsdoc_param_description_separator . a:argDescription
      endif
      call add(a:lines, a:space . ' * @' . g:jsdoc_tags['param'] . ' ' . l:type . a:arg . l:description)

    endif

  endif

  return a:lines

endfunction

function! jsdoc#insert() abort
  let l:line = getline('.')
  let l:indentCharSpace = ' '
  let l:indentCharTab   = '	'
  let l:autoexpandtab   = &l:expandtab

  if l:autoexpandtab == 0 " noexpandtab
    " tabs
    let l:indent      = indent('.') / &l:tabstop
    let l:indentChar  = l:indentCharTab
  elseif l:autoexpandtab == 1 " expandtab
    " spaces
    let l:indent      = indent('.')
    let l:indentChar  = l:indentCharSpace
  endif

  let l:space = repeat(l:indentChar, l:indent)

  " Determine function defintion style
  let l:is_function = 0
  let l:is_named    = 0
  if l:line =~ s:regexs['function_declaration']
    let l:is_function = 1
    let l:is_named    = 1
    let l:regex       = s:regexs['function_declaration']
  elseif l:line =~ s:regexs['function_expression']
    let l:is_function = 1
    let l:is_named    = 1
    let l:regex       = s:regexs['function_expression']
  elseif l:line =~ s:regexs['anonymous_function']
    let l:is_function = 1
    let l:regex       = s:regexs['anonymous_function']
  elseif l:line =~ s:regexs['arrow']
    let l:is_function = 1
    let l:is_named    = 1
    let l:regex       = s:regexs['arrow']
  elseif l:line =~ s:regexs['shorthand']
    let l:is_function = 1
    let l:is_named    = 1
    let l:regex       = s:regexs['shorthand']
  endif

  let l:lines = []
  let l:desc = ''
  call add(l:lines, l:space . '/**')
  call add(l:lines, l:space . ' * ' . l:desc)
  call add(l:lines, l:space . ' *')

  let l:funcName = ''
  if l:is_function

    " Parse function definition
    " @FIXME: Does not work if function is split over several lines...
    " e.g.
    " ```
    " function name(
    "   arg1
    "   arg2
    " ) { }
    let l:argString = ''
    if l:is_named
      let l:funcName = substitute(l:line, l:regex, '\1', 'g')
      let l:argString = substitute(l:line, l:regex, '\2', 'g')
    else
      let l:argString = substitute(l:line, l:regex, '\1', 'g')
    endif
    let l:args = split(l:argString, '\s*,\s*')

    if g:jsdoc_additional_descriptions == 1
      call add(l:lines, l:space . ' * @name ' . l:funcName)
      call add(l:lines, l:space . ' * @' . g:jsdoc_tags['function'])
    endif

    if g:jsdoc_access_descriptions > 0
      " either @access public/private
      " or     @public/private
      let l:access_tag = g:jsdoc_access_descriptions == 1
           \ ? ' * @access '
           \ : ' * @'

      let l:access = g:jsdoc_underscore_private == 1 && l:funcName[0] ==# '_'
            \ ? 'private'
            \ : 'public'

      call add(l:lines, l:space . l:access_tag . l:access)
    endif

    let l:hook = keys(g:jsdoc_custom_args_hook)
    for l:arg in l:args
      " Remove `(` or `)` from args.
      let l:arg = substitute(l:arg, '\((\|)\)', '', '')
      let l:lines = s:hookArgs(l:lines, l:space, l:arg, l:hook, '', '')
    endfor
  endif

  if g:jsdoc_return == 1
    call add(l:lines, l:space . ' * @' . g:jsdoc_tags['returns'] . ' {undefined}')
  endif

  call add(l:lines, l:space . ' */')

  let l:paste = &g:paste
  let &g:paste = 1

  call append(line('.') - 1, l:lines)

  let l:pos = line('.') - (len(l:lines) - 1)

  silent! execute 'normal! ' . l:pos . 'G$'
  if l:desc ==# '' && l:funcName !=# ''
    silent! execute 'normal! a' . l:funcName
  endif

  let &g:paste = l:paste
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
