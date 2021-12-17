" Append a window to the right if there is only one window currently,
" and add it to the bottom right if there are 2 or more.
function! s:AppendWin()
  let l:window_count winnr('$')
  if l:window_count == 1
    vsplit
    wincmd l
  else
    wincmd l
    split
  endif
  enew
endfunction

function! s:warn(str) abort
  echohl WarningMsg
  echomsg a:str
  echohl None
  let v:warningmsg = a:str
endfunction

function! s:FindBufName(name, num)
  let l:buf_name = a:name . '_' . a:num
  if bufexists(l:buf_name)
    let l:num = a:num + 1
    return s:FindBufName(a:name, l:num)
  else
    return l:buf_name
  endif
endfunction

function! s:RunRepl(name, cmd, is_bg) abort
  call AppendWin()
  Rooter
  call termopen(a:cmd)
  let l:buf_name = s:FindBufName(a:name, 0)
  execute "file" l:buf_name
endfunction

function! jack_in#clj_cmd(...)
  let l:clj_string = 'clojure -X:dev'
  let l:main_fn = ''
  let l:interactive = ''

  let l:deps = '-Sdeps '' {:deps {nrepl/nrepl {:mvn/version "0.8.3"} '
  let l:cider_opts = '--middleware ''['

  for [dep, inj] in items(g:jack_in_injections)
    let l:deps .= dep . ' {:mvn/version "' . inj['version'] . '"} '
    let l:cider_opts .= ' "'.inj['middleware'] . '"'
  endfor

  let l:deps .= '}}'''
  let l:cider_opts .= ']'''

  "let l:cmd = l:clj_string . ' ' . l:deps . ' ' . l:main_fn . ' ' . l:cider_opts . ' ' . l:interactive
  let l:cmd = l:clj_string
  return l:cmd
endfunction

function! jack_in#clj(is_bg, ...)
  call s:RunRepl("clj", call(function('jack_in#clj_cmd'), a:000), a:is_bg)
endfunction


function! jack_in#shadow_cmd(...)
  let l:shadow_string = 'npx shadow-cljs watch app'

  return l:shadow_string
endfunction

function! jack_in#shadow(is_bg, ...)
  call s:RunRepl("shadow", call(function('jack_in#shadow_cmd'), a:000), a:is_bg)
endfunction


function! jack_in#cljs_cmd(...)
  let l:clj_string = "clojure -M:cljs:dev "
  let l:main_fn = ''
  let l:interactive = ''

  let l:deps = '-Sdeps '' {:deps {nrepl/nrepl {:mvn/version "0.8.3"} '
  let l:cider_opts = '--middleware ''['

  for [dep, inj] in items(g:jack_in_injections)
    let l:deps .= dep . ' {:mvn/version "' . inj['version'] . '"} '
    let l:cider_opts .= ' "'.inj['middleware'] . '"'
  endfor

  let l:deps .= '}}'''
  let l:cider_opts .= ']'''

  let l:eval = "--eval \"(require \'shadow-repl)(shadow-repl/start\!)\""

  let l:cmd = l:clj_string . ' ' . l:eval

  return l:cmd

endfunction


function! jack_in#cljs(is_bg, ...)
  call s:RunRepl("cljs", call(function('jack_in#cljs_cmd'), a:000), a:is_bg)
endfunction


