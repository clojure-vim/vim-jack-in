function! s:RunRepl(cmd)
  if exists(':Start!') == 2
    execute 'Start! '.a:cmd
  else
    tabnew
    call termopen(a:cmd)
    tabprevious
  endif
endfunction

let s:injections = [{'dependency': ['cider/cider-nrepl', '0.15.0'],
                  \  'lein_plugin': 1,
                  \  'middleware': 'cider.nrepl/cider-middleware'},
                  \ {'dependency': ['refactor-nrepl', '2.3.1'],
                  \  'middleware': 'refactor-nrepl.middleware/wrap-refactor'},
                  \ {'dependency': ['com.gfredericks.dominic/debug-repl', '0.0.1'],
                  \  'middleware': 'com.gfredericks.debug-repl/wrap-debug-repl'}]

function! jack_in#boot(...)
  let l:boot_string = 'boot -i "(require ''cider.tasks)"'
  for inj in s:injections
    let l:boot_string .= printf(' -d %s:%s', inj['dependency'][0], inj['dependency'][1])
  endfor
  let l:boot_string .= ' cider.tasks/add-middleware'
  for inj in s:injections
    let l:boot_string .= ' -m '.inj['middleware']
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
  for inj in s:injections
    let l:dep_vector = printf('''[%s "%s"]''', inj['dependency'][0], inj['dependency'][1])
    if !get(inj, 'lein_plugin')
      let l:lein_string .= ' update-in :dependencies conj '.l:dep_vector.' --'
      let l:lein_string .= ' update-in :repl-options:nrepl-middleware conj '.inj['middleware'].' --'
    else
      let l:lein_string .= ' update-in :plugins conj '.l:dep_vector.' --'
    endif
  endfor
  if a:0 > 0 && a:1 != ''
    let l:lein_task = join(a:000, ' ')
  else
    let l:lein_task = g:default_lein_task
  endif
  call s:RunRepl(l:lein_string.' '.l:lein_task)
endfunction
