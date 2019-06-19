#!env python

import glob
from collections import OrderedDict
import re
import shlex
import textwrap

import jinja2


def main():
    # paths = glob.glob('/Users/shu/workspaces/st2/st2-packages/packages/st2/debian/st2*.service')
    # for path in paths:
    #   sh = SystemdUnitParser(path).to_script()
    #   print(sh)
    mistral_paths = glob.glob('/Users/shu/workspaces/st2/st2-packages/packages/st2mistral/debian/mistral-*.upstart')
    for path in mistral_paths:
        sh = UpstartJobParser(path).to_script()
        print(sh)


class UpstartJobParser:
    tmpl_str = '''
#!/bin/bash
set -e

{{ data }}
'''.strip()

    def __init__(self, target):
        self.target = target
        self.parse()

    def parse(self):
        option_format = re.compile('.*^script$(.*)^end script$.*', flags=(re.MULTILINE | re.DOTALL))
        with open(self.target, 'r') as f:
            lines = f.read()
            option_kv = option_format.match(lines)
            if option_kv:
                script_block = option_kv.group(1)
                script_block = textwrap.dedent(script_block).strip()
                self.data = script_block

    def to_script(self):
        tmpl = jinja2.Template(self.tmpl_str)
        return tmpl.render(data=self.data)


class SystemdUnitParser:

    tmpl_str = '''
#!/bin/bash
set -e

# asdf
{%- for k, v in data.get('Environment', {}).items() %}
{{ k }}="{{ v }}"
{%- endfor %}

{%- if data.get('EnvironmentFile') %}
# Read configuration variable file if it is present
set -o allexport
[ -r {{ data['EnvironmentFile'] }} ] && . {{ data['EnvironmentFile'] }}
set +o allexport
{%- endif %}

exec {{ data['ExecStart'] }}
'''.strip()

    def __init__(self, target):
        self.target = target
        self.parse()

    def parse(self):
        res = {}
        option_format = re.compile('^([a-zA-Z0-9]+)=(.*)')

        with open(self.target, 'r') as f:
            lines = f.readlines()
            for line in lines:
                option_kv = option_format.match(line)
                if option_kv:
                    key = option_kv.group(1)
                    val = option_kv.group(2)
                    if key == 'Environment':
                        if key not in res:
                            res[key] = OrderedDict()

                        res[key].update(self.parse_env(val))

                    elif key == 'EnvironmentFile':
                        res[key] = val.lstrip('-')

                    else:
                        res[key] = val
        self.data = res

    def parse_env(self, env):
        res = {}
        env_format = re.compile('^([a-zA-Z0-9_]+)=(.*)')

        for elm in shlex.split(env):
            env_kv = env_format.match(elm)
            key = env_kv.group(1)
            val = env_kv.group(2)
            res[key] = val

        return res

    def to_script(self):
        tmpl = jinja2.Template(self.tmpl_str)
        return tmpl.render(data=self.data)


if __name__ == '__main__':
    main()
