from os.path import abspath, join

import jinja2
import yaml
from dict_deep import deep_get
from flask import Markup
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
    template = jinja2.Template(source=template)
    return template.render(data=data)


def render_tex_template(path: str, data: dict) -> str:
    """
    Renders a tex template with given data.

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
    tex_jinja_env = jinja2.Environment(
        block_start_string='\BLOCK{',
        block_end_string='}',
        variable_start_string='\VAR{',
        variable_end_string='}',
        trim_blocks=True,
        autoescape=False,
        loader=jinja2.FileSystemLoader(abspath('.')),
    )
    template = tex_jinja_env.get_template(path)
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


def write_tex(name: str, path: str) -> None:
    """
    Write the TEX to disk.

    Parameters
    ----------
    name: str
        Name of the TEX

    path: str
        Path to write TEX to
    """
    data = read_data('index' if name == 'resume' else name, markup=False)
    tex = render_tex_template(join('portfolio', 'templates', f'{name}.tex'), data)
    with open(path, 'w+') as f:
        f.write(tex)


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
    with open(join('portfolio', 'data', f'{name}.yaml'), 'r+') as f:
        data = yaml.safe_load(f)

    elaboration_content = [
        'education',
        'experience.sections.industrial',
        'contributions',
    ]

    # Ignore name, tags, birthdate and blog (for now).
    sections = [section for section in data
                if section not in ('name',
                                   'tags',
                                   'birthdate',
                                   'about',
                                   'blog')]
    data['sections'] = sections

    if markup:
        for content in elaboration_content:
            section = deep_get(data, content)
            for i, subsection in enumerate(section):
                section[i]['elaboration'] = Markup(md(subsection['elaboration']))

    return data
