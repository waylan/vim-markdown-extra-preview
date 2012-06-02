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
" Copyright (C) 2012 joe di castro  <joe@joedicastro.com>
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
    let g:VMEPoutputdirectory = ''
endif

if !exists('g:VMEPhtmlreader')
    let g:VMEPhtmlreader = ''
endif

if !exists('g:VMEPstylesheet')
    let g:VMEPstylesheet = 'github.css'
endif

if !exists('g:VMEPtemplate')
    let g:VMEPtemplate = 'github.html'
endif

if !exists('g:VMEPextensions')
    let g:VMEPextensions = ['extra']
endif

let s:script_dir = expand("<sfile>:p:h")

function! PreviewME(refresh)
python << PYTHON

import vim, sys, imp, codecs, webbrowser
from os import path, makedirs, linesep
from tempfile import gettempdir

base = path.join(vim.eval('s:script_dir'), 'vim-markdown-extra-preview')

def get_setting(setting):
    """ Resolve a vim variable. First try 'b:setting', then 'g:setting'. """
    b = 'b:' + setting
    if int(vim.eval("exists('%s')" % b)):
        return vim.eval(b)
    else:
        return vim.eval('g:'+setting)

def load_markdown():
    """ Import and create Markdown class instance. """
    f, p, d = imp.find_module('markdown', [base])
    try:
        markdown = imp.load_module('markdown', f, p, d)
    finally:
        if f:
            f.close()
    return markdown.Markdown(
        extensions = get_setting('VMEPextensions'),
        output_format = get_setting('VMEPoutputformat'),
    )

def build_context(markdown):
    """ Build the context to be passed to template. """
    buffer = vim.current.buffer
    if buffer.name is None:
        raise Exception('Your file is not saved.')
    name, ext = path.splitext(path.basename(buffer.name))
    body = linesep.join(buffer)
    style = get_setting('VMEPstylesheet')
    if not path.isfile(style):
        style = path.join(base, 'stylesheets', style)
    context = dict(
        name = name.replace('_', ' '),
        # content = markdown.convert(body),
        content = markdown.convert(unicode(body, 'utf-8')),
        style = style,
    )
    if hasattr(markdown, 'Meta'):
        for k, v in markdown.Meta:
            context[k] = ' '.join(v)
    return context

def load_template():
    """ Load template from file system. """
    temp_path = get_setting('VMEPtemplate')
    if not path.isfile(temp_path):
        temp_path = path.join(base, 'templates', temp_path)
    f = open(temp_path, 'r')
    template = f.read()
    f.close()
    x, file_ext = path.splitext(temp_path)
    return template, file_ext

def display(template, file_ext, context):
    """ Write temp file to disk and display in browser. """
    reader = get_setting('VMEPhtmlreader')
    output_dir = get_setting('VMEPoutputdirectory')
    if not output_dir: 
        output_dir = gettempdir()
    else: 
        output_dir = path.realpath(output_dir)
        if not path.isdir(output_dir):
            makedirs(output_dir)
    name = context['name'].replace(' ', '_') + file_ext
    file = path.join(output_dir, name)
    f = codecs.open(file, 'w', encoding='utf-8', errors='xmlcharrefreplace')
    f.write(template % context)  
    f.close()
    refresh = bool(vim.eval('a:refresh'))
    if not refresh:
        if reader == '':
            # if VMEPhtmlreader is not set, use the default browser
            webbrowser.open(file)
        else:
            webbrowser.get("{0} %s".format(reader)).open(file)

markdown = load_markdown()
template, file_ext = load_template()
context = build_context(markdown)
display(template, file_ext, context)

PYTHON
endfunction

:command! Me :call PreviewME('')
:command! Mer :call PreviewME('True')
