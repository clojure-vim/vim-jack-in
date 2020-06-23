if exists("g:loaded_jack_in")
  finish
endif
let g:loaded_jack_in = 1

let g:default_lein_task = 'repl'
let g:default_boot_task = 'repl'

let g:jack_in_injections =
      \ {'cider/cider-nrepl':
      \   {'version': '0.25.2',
      \    'middleware': 'cider.nrepl/cider-middleware',
      \    'lein_plugin': 1},
      \  'refactor-nrepl':
      \   {'version': '2.5.0',
      \    'middleware': 'refactor-nrepl.middleware/wrap-refactor'}}

command! -bang -nargs=* Boot call jack_in#boot(<bang>0,<q-args>)
command! -bang -nargs=* Lein call jack_in#lein(<bang>0,<q-args>)
command! -bang -nargs=* Clj call jack_in#clj(<bang>0,<q-args>)
