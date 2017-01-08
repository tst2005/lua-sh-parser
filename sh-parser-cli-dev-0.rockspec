-- vim: set ft=lua:

package = 'sh-parser-cli'
version = 'dev-0'

source = {
  url = 'git://github.com/jirutka/sh-parser.git',
  branch = 'master',
}

description = {
  summary = 'Parser of POSIX Shell Command Language - command-line utility',
  detailed = [[TODO]],
  homepage = 'https://github.com/jirutka/sh-parser',
  maintainer = 'Jakub Jirutka <jakub@jirutka.cz>',
  license = 'MIT',
}

dependencies = {
  'lua >= 5.1',
  'lua-cjson ~> 2.0',
  'optarg ~> 0.2',
  'sh-parser',
}

build = {
  type = 'builtin',
  install = {
    bin = {
      ['sh-parser'] = 'bin/sh-parser'
    }
  }
}
