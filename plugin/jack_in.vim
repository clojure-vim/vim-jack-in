if exists("g:loaded_jack_in")
  finish
endif
let g:loaded_jack_in = 1

let g:default_lein_task = 'repl'
let g:default_boot_task = 'repl'

command! -nargs=* Boot call jack_in#boot(<q-args>)
command! -nargs=* Lein call jack_in#lein(<q-args>)
