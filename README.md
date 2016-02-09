# jsdoc.vim


## YOU ARE LOOKING AT MY OWN FORK ##

See the original at https://github.com/heavenshell/vim-jsdoc/

Differences in this version:

- es6 enabled by default
- does not prompt for user input (even with old settings args, all removed)
- custom args for param name processing only accepts regexes


## About

jsdoc.vim generates [JSDoc](http://usejsdoc.org/) block comments based on
a function signature.

![image](https://github.com/heavenshell/vim-jsdoc/wiki/images/vim-jsdoc-screencast-preview.gif)

This plugin is based on https://gist.github.com/3903772#file-jsdoc-vim written
by [NAKAMURA, Hisashi](https://gist.github.com/sunvisor)

- `boolean`
- `null`
- `undefined`
- `number`
- `string`
- `symbol`
- `object`
- `function`
- `array`

## Usage

1. Move cursor on `function` keyword line.
1. Type `:JsDoc` to insert JSDoc.
1. Insert JSDoc above the `function` keyword line.

## Configuration

Option                                  | Default | Description
:-------------------------------------- | :------ | :----------
**g:jsdoc_return**                      | 1       | Add the `@return` tag.
**g:jsdoc_access_descriptions**         | 0       | Set value to 1 to turn on access tags like `@access <private|public>`. Set value to 2 to turn on access tags like `@<private|public>`
**g:jsdoc_underscore_private**          | 0       | Set value to 1 to turn on detecting underscore starting functions as private convention
**g:jsdoc_param_description_separator** | ' '     | Characters used to separate `@param` name and description.
**g:jsdoc_custom_args_hook**            | {}      | Override default type and description. See help more detail.
**g:jsdoc_type_hook**                   | {}      | Allow to insert default description depending on the type.
**g:jsdoc_tags**                        | see :h  | Allow use of alternate tags (the ones that support synonyms) per JSDoc documentation. Can be changed on a per tag basis, for example: `let g:jsdoc_tags = {} | let g:jsdoc_tags['param'] = 'arg'`

## Keymap

Since version `0.3`, `g:jsdoc_default_mapping` was removed.

Add following setting to .vimrc if you want same behavior as version `0.2.1`.

```viml
nmap <silent> <C-l> <Plug>(jsdoc)
```

Alternatively, you could add the following setting to your .vimrc to search for
the last `function` declaration and puts your jsdoc above it:

```viml
nmap <silent> <C-l> ?function<cr>:noh<cr><Plug>(jsdoc)
```
