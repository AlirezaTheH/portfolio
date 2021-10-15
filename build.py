"""
Build script for portfolio.
"""
import os
import re
import shutil
from os.path import isdir, join

from portfolio.utils import write_html, write_tex

os.makedirs('site', exist_ok=True)
shutil.rmtree('site')
os.makedirs('site', exist_ok=True)
os.makedirs('site/files', exist_ok=True)

for file in os.listdir(join('portfolio', 'templates')):
    match = re.match(r'(?P<name>.+)\.(?P<ext>.+)', file)
    if match:
        if match.group('ext') == 'html':
            write_html(name=match.group('name'), path=join('site', file))
        elif match.group('ext') == 'tex':
            write_tex(name=match.group('name'), path=join('portfolio', 'tex', file))

static_dir = join('portfolio', 'static')
for filename in os.listdir(static_dir):
    filepath = join(static_dir, filename)
    if filename != 'scss' and isdir(filepath):
        shutil.copytree(filepath,
                        join('site', 'static', filename))
