# Vim-Markdown-Extra-Preview 
### Preview Markdown documents in a Browser.

This plugin passes the current buffer through Python-Markdown (with the 
`extra` extension) and displays the resulting HTML in the system default 
browser. 

The Python-Markdown library is included. However, Vim must be compiled with 
Python support (`+python`) and the matching version of Python must be 
installed on the system. The plugin checks this when called and will fail
with an error message if Python is not available.

## Usage

There are two commands available:

* Run the command `:Me` to preview the current buffer. This is the normal
  mode, converts the markdown buffer to a html file and open it in a new browser 
  window or tab with the result.

* Run the command `:Mer` to refresh the current buffer. The intention of this
  mode is making it work together with a browser plugin that reload the page
  when it changes. Then, this mode don't open a new browser tab or window, only
  save the html file to the disk. With a plugin like the 
  [Firefox's  Auto Reload][far] the browser tab it's automatically reloaded in
  order to view the changes.

  [far]: https://addons.mozilla.org/en-US/firefox/addon/auto-reload/
  

## Options

### Global Settings:                                        

The following settings can be set globally in your `.vimrc` file and will effect
the behavior of the plugin in all instances. Changing the global settings in 
one buffer will effect all buffers. See [Local Settings](#local_settings) if you 
want to change setting for a specific buffer.

* `g:VMEPoutputformat`

    The format of Markdown's output. This setting is simply passed on to 
Python-Markdown as-is and determines which format is output. 

    The formats are:

    -  `'xhtml'` (default)
    -  `'html'`


* `g:VMEPextensions`

    A list of extensions to be used by Python-Markdown when parsing the buffer. 
See [Python-Markdown's documentation][pmd] for a description of each extension. 
The 'extra' extension is used by default.

  [pmd]: http://packages.python.org/Markdown/
  

* `g:VMEPtemplate`

    The [template](#templates) in which the Markdown output is inserted. A 
default template is provided with the plugin. Additional templates may be added 
to the `templates` directory, and if set to that template's name (i.e., 
`mytemplate.html`), that template us used. If set to a full path of an 
existing file anywhere on the system (i.e., `/path/to/mytemplate.html`), 
then that file is used.

* `g:VMEPstylesheet`

    The style sheet which is linked to in the HTML output. If a filename is 
given, then the style sheet is assumed to be in the plugin's `stylesheets` 
directory. If a full path is given, then that path is used as-is.

* `g:VMEPoutputdirectory`

    The directory in which the output will be written before being displayed
in the browser. This must be a full path which is writable. When assigned an 
empty value(``), it is assumed that the system default temporary directory 
should be used. Empty by default.

* `g:VMEPhtmlreader`

    The browser in which the output will be displayed. Defaults to the system's
default browser. May be set to any executable of your choosing that is on 
the system path, or with a full path. The executable must except the path 
to the HTML output file as it's only argument.

## Local Settings                                          

Local settings are the same as the global settings except that they only apply
to a single buffer. If a local setting is not set, the corresponding global
setting will be used. To set a local setting, prepend the setting name with 
`b:` rather than `g:` (i.e., use `b:VMEPstylesheet` rather than 
`g:VEMPstylesheet`).

For example, to use a different template, when viewing the buffer, execute
the following command: 

    :let b:VMEPtemplate = '/path/to/template.html'

You could also use autocommands in your `.vimrc` file to use a different setting
for all files in a specific directory or of a specific type. Something like:

    au BufNewFile,BufRead /path/to/project/* \
                    let b:VMEPtemplate = '/path/to/template.html' | \
                    let b:VMEPstylesheet = '/path/to/style.css'

Note that each command is separated by a `|`. The `\` indicate line wraps as 
the command should all be one line. 

You could even create a `.vimrc` file in your project directory and source it:

    au BufNewFile,BufRead /path/to/project/* source /path/to/project/.vimrc

Just make sure your local `.vimrc` only defines buffer specific settings.

## Templates                                                  

The template pointed to by the `g:VMEPtemplate` setting must be a file which
is readable and contains the wrapper around which Markdown's output is inserted.
The file extension of the template is used as the file extension of the output
file. Templates use Python's string formatting to insert the following data:

* name:    

    The name of the buffer with the file-extension removed and underscores 
replaced by spaces (i.e., `foo_bar.txt` becomes `foo bar`). This is generally
expected to be used in the documents title.

* content: 
 
    The full body of Markdown's output.

* style:

    The full path to the style sheet set in `g:VMEPstylesheet`. 

If Python-Markdown's Meta-Data extension is used, any meta-data defined in the
buffer will also be added to the context passed to the template. The meta-data
will overwrite any of the existing data. This could be useful for setting a 
more verbose 'name' for the document or to set a document specific style. But 
it could also overwrite data if not used with care.

To enable the meta-data extension, it will need to included in the 
`g:VMEPextensions` setting (or its buffer specific counterpart) like this:

    :let g:VMEPextensions = ['extra', 'meta']

A simple template may look something like this:

     <html>
       <head>
         <title>%(name)s</title>
          <link rel="stylesheet" href="%(style)s"></link>
        </head>
        <body>
          %(content)s
        </body>
     </html>


