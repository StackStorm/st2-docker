#!env python

from collections import OrderedDict
import re
import shlex
import jinja2

templateString = '''
#!/bin/bash
set -e

# 
{%- for k, v in m.get('Environment', {}).items() %}
{{ k }}="{{ v }}"
{%- endfor %}

{%- if m.get('EnvironmentFile') %}
# Read configuration variable file if it is present
set -o allexport
[ -r {{ m['EnvironmentFile'] }} ] && . {{ m['EnvironmentFile'] }}
set +o allexport
{%- endif %}

exec {{ m['ExecStart'] }}
'''.strip()

path = '/Users/shu/workspaces/st2/st2-packages/packages/st2/debian/st2api.service'


class SystemdUnitParser:

  def __init__(self, target):
    self.target = target

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
            if not key in res:
              res[key] = OrderedDict()

            res[key].update(self.parse_env(val))

          elif key == 'EnvironmentFile':
            res[key] = val.lstrip('-')

          else:
            res[key] = val
    self.parseResult = res
    return res

  def parse_env(self, env):
    res = {}
    env_format = re.compile('^([a-zA-Z0-9_]+)=(.*)')

    for elm in shlex.split(env):
      env_kv = env_format.match(elm)
      key = env_kv.group(1)
      val = env_kv.group(2)
      res[key] = val

    return res


m = SystemdUnitParser(path).parse()

print(m)

tmpl = jinja2.Template(templateString)
print(tmpl.render(m=m))
