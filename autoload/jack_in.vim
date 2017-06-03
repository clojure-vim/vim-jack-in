function! s:RunRepl(cmd)
  if exists(':Start!') == 2
    execute 'Start! '.a:cmd
  else
    tabnew
    call termopen(a:cmd)
    tabprevious
  endif
endfunction

let s:boot_deps = [['cider/cider-nrepl', '0.15.0-SNAPSHOT'], ['refactor-nrepl', '2.2.0']]
let s:boot_middleware = ['cider.nrepl/cider-middleware', 'refactor-nrepl.middleware/wrap-refactor']

let s:lein_plugins = [['cider/cider-nrepl', '0.15.0-SNAPSHOT'], ['refactor-nrepl', '2.2.0']]

let g:default_lein_task = 'repl'
let g:default_boot_task = 'repl'

function! jack_in#boot(...)
  let l:boot_string = 'boot -i "(require ''cider.tasks)"'
  for dep in s:boot_deps
    let l:boot_string .= ' -d '.dep[0].':'.dep[1]
  endfor
  let l:boot_string .= ' cider.tasks/add-middleware'
  for middleware in s:boot_middleware
    let l:boot_string .= ' -m '.middleware
  endfor
  if a:0 > 0 && a:1 != ''
    let l:boot_task = join(a:000, ' ')
  else
    let l:boot_task = g:default_boot_task
  endif
  call s:RunRepl(l:boot_string.' '.l:boot_task)
endfunction

function! jack_in#lein(...)
  let l:lein_string = 'lein'
  for plugin in s:lein_plugins
    let l:lein_string .= ' update-in :plugins conj ''['.plugin[0].' "'.plugin[1].'"]'' --'
  endfor
  if a:0 > 0 && a:1 != ''
    let l:lein_task = join(a:000, ' ')
  else
    let l:lein_task = g:default_lein_task
  endif
  call s:RunRepl(l:lein_string.' '.l:lein_task)
endfunction
