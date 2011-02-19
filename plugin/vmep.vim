" vim-markdown-extra-preview
" ===========================
"
" A Python port of <http://github.com/robgleeson/vim-markdown-preview>.
" 
" This is a direct port - except that Python-Markdown is used rather then the
" Ruby library 'kramdown'. This gives us Python-Markdown's extensions (extra,
" etc.).
"
" Copyright (C) 2011 Waylan Limberg <waylan@gmail.com>
"
" vim-markdown-extra-preview is free software: you can redistribute it and/or 
" modify it under the terms of the GNU General Public License as published by
" the Free Software Foundation, either version 3 of the License, or
" (at your option) any later version.
"
" This program is distributed in the hope that it will be useful,
" but WITHOUT ANY WARRANTY; without even the implied warranty of
" MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
" GNU General Public License for more details.
"
" You should have received a copy of the GNU General Public License
" along with this program.  If not, see <http://www.gnu.org/licenses/>.
 

if !has('python')
    echo "Error: Vim must be compiled with Python support (+python)."
    finish
endif

if !exists('g:VMPoutputformat')
    let g:VMPoutputformat = 'html'
endif

if !exists('g:VMPoutputdirectory')
    let g:VMPoutputdirectory = '/tmp'
endif

if !exists('g:VMPhtmlreader')
    if has('mac')
        let g:VMPhtmlreader = 'open'
    elseif has('win32') || has('win64')
        let g:VMPhtmlreader = 'start'
    elseif has('unix') && executable('xdg-open')
        let g:VMPhtmlreader = 'xdg-open'
    else
        let g:VMPhtmlreader = ''
    end
endif

if !exists('g:VMPstylesheet')
    let g:VMPstylesheet = 'github.css'
endif

let s:script_dir = expand("<sfile>:p:h")

function! PreviewMKD()
python << PYTHON

import vim, sys, imp
from os import path, makedirs

base = path.join(vim.eval('s:script_dir'), 'vim-markdown-extra-preview')

def load_markdown(base):
    f, p, d = imp.find_module('markdown', [base])
    print p
    try:
        return imp.load_module('markdown', f, p, d)
    finally:
        if f:
            f.close()
markdown = load_markdown(base)

stylesheet = path.join(base, 'stylesheets', vim.eval('g:VMPstylesheet'))
output_dir = path.realpath(vim.eval('g:VMPoutputdirectory'))
if not path.isdir(output_dir):
    makedirs(output_dir)

buffer = vim.current.buffer
if buffer.name is None:
    raise Exception('Your file is not saved.')
name, ext = path.splitext(path.basename(buffer.name))
body = '\n'.join(buffer)

template = """
<!DOCTYPE html
 PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
 "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />

  <link rel="stylesheet" href="%s"></link>

  <title>%s</title>
  </head>
  <body>

    <div id="container">
      <div id="centered">
        <div id="article">
          <div class="page"> 
          %s
          </div>
        </div>
      </div>
    </div>

  </body>
</html>
"""

format = vim.eval('g:VMPoutputformat')
if format == 'html':
    reader = vim.eval('g:VMPhtmlreader')
    if reader == '':
        vim.message('No suitable HTML reader found! Please set g:VMPhtmlreader.')
    else:
        file = path.join(output_dir, name + '.html')
        f = open(file, 'w')
       	f.write(template % (stylesheet, name, markdown.markdown(body, ['extra'])))  
	f.close()
        vim.command("silent ! %s %s" % (reader, file))
        vim.command('redraw!')
elif format == 'pdf':
    vim.message('output format not implemented yet.')
else:
    vim.message('Unrecognized output format! Check g:VMPoutputformat.')

PYTHON
endfunction

:command! Mm :call PreviewMKD()
