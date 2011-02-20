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

if !exists('g:VMEPoutputformat')
    let g:VMEPoutputformat = 'xhtml'
endif

if !exists('g:VMEPoutputdirectory')
    let g:VMEPoutputdirectory = '/tmp'
endif

if !exists('g:VMEPhtmlreader')
    if has('mac')
        let g:VMEPhtmlreader = 'open'
    elseif has('win32') || has('win64')
        let g:VMEPhtmlreader = 'start'
    elseif has('unix') && executable('xdg-open')
        let g:VMEPhtmlreader = 'xdg-open'
    else
        let g:VMEPhtmlreader = ''
    end
endif

if !exists('g:VMEPstylesheet')
    let g:VMEPstylesheet = 'github.css'
endif

if !exists('g:VMEPextensions')
    let g:VMEPextensions = ['extra']
endif

let s:script_dir = expand("<sfile>:p:h")

function! PreviewMKDE()
python << PYTHON

import vim, sys, imp
from os import path, makedirs

def load_markdown(base):
    """ Import and create Markdown class instance. """
    f, p, d = imp.find_module('markdown', [base])
    try:
        markdown = imp.load_module('markdown', f, p, d)
    finally:
        if f:
            f.close()
    return markdown.Markdown(
        extensions = vim.eval('g:VMEPextensions'),
        output_format = vim.eval('g:VMEPoutputformat'),
    )

def build_context(markdown, base):
    """ Build the context to be passed to template. """
    buffer = vim.current.buffer
    if buffer.name is None:
        raise Exception('Your file is not saved.')
    name, ext = path.splitext(path.basename(buffer.name))
    body = '\n'.join(buffer)
    return dict(
        name = name.replace('_', ' '),
        content = markdown.convert(body),
        style = path.join(base, 'stylesheets', vim.eval('g:VMEPstylesheet'))
    )

def display(template, context):
    """ Write temp file to disk and display in browser. """
    reader = vim.eval('g:VMEPhtmlreader')
    if reader == '':
        vim.message('No suitable HTML reader found! Please set g:VMEPhtmlreader.')
    else:
        output_dir = path.realpath(vim.eval('g:VMEPoutputdirectory'))
        if not path.isdir(output_dir):
            makedirs(output_dir)
        file = path.join(output_dir, name + '.html')
        f = open(file, 'w')
       	f.write(template % context)  
        f.close()
        vim.command("silent ! %s %s" % (reader, file))
        vim.command('redraw!')

template = """
<!DOCTYPE html
 PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
 "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />

  <link rel="stylesheet" href="%(style)s"></link>

  <title>%(name)s</title>
  </head>
  <body>

    <div id="container">
      <div id="centered">
        <div id="article">
          <div class="page"> 
          %(content)s
          </div>
        </div>
      </div>
    </div>

  </body>
</html>
"""

base = path.join(vim.eval('s:script_dir'), 'vim-markdown-extra-preview')
markdown = load_markdown(base)
context = build_context(markdown, base)
display(template, context)

PYTHON
endfunction

:command! Mm :call PreviewMKDE()
