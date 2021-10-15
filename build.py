"""
Build script for resume HTML version.
"""
import os
import shutil
from os.path import isdir, join

from portfolio.utils import write_html

os.makedirs('site', exist_ok=True)
shutil.rmtree('site')
os.makedirs('site', exist_ok=True)

for file in os.listdir(join('portfolio', 'templates')):
    write_html(name=file[:-5], path=join('site', file))

static_dir = join('portfolio', 'static')
for filename in os.listdir(static_dir):
    filepath = join(static_dir, filename)
    if filename != 'scss' and isdir(filepath):
        shutil.copytree(filepath,
                        join('site', 'static', filename))
