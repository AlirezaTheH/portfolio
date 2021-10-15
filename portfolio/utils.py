from os.path import join

import yaml
from dict_deep import deep_get
from flask import Markup
from jinja2 import Template
from markdown import markdown as md


def render_template(path: str, data: dict) -> str:
    """
    Renders a template with given data.

    Parameters
    ----------
    path: str
        Path to the template
    data:
        The provided data for rendering

    Returns
    -------
    template: str
        Rendered template
    """
    with open(path, 'r+') as f:
        template = f.read()
    template = Template(source=template)
    return template.render(data=data)


def write_html(name: str, path: str) -> None:
    """
    Write the HTML to disk.

    Parameters
    ----------
    name: str
        Name of the HTML

    path: str
        Path to write HTML to
    """
    data = read_data(name)
    html = render_template(join('portfolio', 'templates', f'{name}.html'), data)
    with open(path, 'w+') as f:
        f.write(html)


def read_data(name: str, markup: bool = True) -> dict:
    """
    Reads the data from disk.

    Parameters
    ----------
    name: str
        Name of data

    markup: bool
        If the data has elaboration content to markup

    Returns
    -------
    data: dict
        The data
    """
    with open(join('portfolio', 'data', f'{name}.yml'), 'r+') as f:
        data = yaml.safe_load(f)

    elaboration_content = [
        'education',
        'experience.sections.industrial',
    ]

    # Ignore name and tags
    sections = [section for section in data
                if section not in ('name', 'tags')]
    data['sections'] = sections

    if markup:
        for content in elaboration_content:
            section = deep_get(data, content)
            for i, subsection in enumerate(section):
                section[i]['elaboration'] = Markup(md(subsection['elaboration']))

    return data
