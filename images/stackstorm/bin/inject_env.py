#!/opt/stackstorm/st2/bin/python

"""
    jinja2 template converter script

    This script will accept template input from STDIN, then render output to STDOUT
    Within a template, you can access environment variables with `env['YOUR_ENVVAR']`

    Usage example:
    env HOGE=fuga inject_env.py < template_file > output_file
"""

import os
import sys
import jinja2

def striptrailingslash(value):
    """
    custom filter that strips forwarding slashes
    """
    return value.strip('/')

# create jinja environment and add custom filters
environment = jinja2.Environment(loader=None)
environment.filters['striptrailingslash'] = striptrailingslash

# load template string from STDIN, then render to STDOUT
template = environment.from_string(sys.stdin.read())
sys.stdout.write(template.render(env=os.environ))
