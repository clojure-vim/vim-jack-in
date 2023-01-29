function! s:warn(str) abort
  echohl WarningMsg
  echomsg a:str
  echohl None
  let v:warningmsg = a:str
endfunction

function! s:RunRepl(cmd, is_bg) abort
  if exists(':Start') == 2
    execute 'Start' . (a:is_bg ? '!' : '') a:cmd
  else
    call s:warn('dispatch.vim not installed, please install it.')
    if has('nvim')
      call s:warn('neovim detected, falling back on termopen()')
      tabnew
      call termopen(a:cmd)
      tabprevious
    endif
  endif
endfunction

function! jack_in#boot_cmd(...)
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
  return l:boot_string.' '.l:boot_task
endfunction

function! jack_in#boot(is_bg,...)
  call s:RunRepl(call(function('jack_in#boot_cmd'), a:000), a:is_bg)
endfunction

function! jack_in#lein_cmd(...)
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

  return l:lein_string.' '.l:lein_task
endfunction

function! jack_in#lein(is_bg, ...)
  call s:RunRepl(call(function('jack_in#lein_cmd'), a:000), a:is_bg)
endfunction

function! jack_in#clj_cmd(...)
  let l:clj_string = 'clj'
  let l:deps_map = '{:deps {nrepl/nrepl {:mvn/version "0.9.0"} '
  let l:cider_opts = '-e "(require ''nrepl.cmdline) (nrepl.cmdline/-main \"--middleware\" \"['

  for [dep, inj] in items(g:jack_in_injections)
    let l:deps_map .= dep . ' {:mvn/version "' . inj['version'] . '"} '
    let l:cider_opts .= ' '.inj['middleware']
  endfor

  let l:deps_map .= '}}'
  let l:cider_opts .= ']\")"'

  return l:clj_string . ' -Sdeps ''' . l:deps_map . ''' ' . join(a:000, ' ') . ' ' . l:cider_opts . ' '
endfunction

function! jack_in#clj(is_bg, ...)
  call s:RunRepl(call(function('jack_in#clj_cmd'), a:000), a:is_bg)
endfunction
