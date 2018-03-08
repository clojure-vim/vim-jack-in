function! s:RunRepl(cmd)
  if exists(':Start!') == 2
    execute 'Start! '.a:cmd
  else
    tabnew
    call termopen(a:cmd)
    tabprevious
  endif
endfunction

function! jack_in#boot(...)
  let l:boot_string = 'boot -x -i "(require ''cider.tasks)"'
  for [dep, inj] in items(g:jack_in_injections)
    let l:boot_string .= printf(' -d %s:%s', dep, inj['version'])
  endfor
  let l:boot_string .= ' cider.tasks/add-middleware'
  for inj in values(g:jack_in_injections)
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
  for [dep, inj] in items(g:jack_in_injections)
    let l:dep_vector = printf('''[%s "%s"]''', dep, inj['version'])
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

function! jack_in#clj(...)
  let l:clj_string = 'clj'
  let l:deps_map = '{:deps {'
  let l:cider_opts = '-e ''(require (quote cider-nrepl.main)) (cider-nrepl.main/init ['

  for [dep, inj] in items(g:jack_in_injections)
    let l:deps_map .= dep . ' {:mvn/version "' . inj['version'] . '"} '
    let l:cider_opts .= ' "'.inj['middleware'].'"'
  endfor

  let l:deps_map .= '}}'
  let l:cider_opts .= '])'''

  let l:command = l:clj_string . ' ' . join(a:000, ' ') . ' -Sdeps ''' . l:deps_map . ''' ' . l:cider_opts . ' '

  call s:RunRepl(l:command)
endfunction
