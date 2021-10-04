"""
Simple flask app to preview portfolio.
"""
from os.path import join

import yaml
from dict_deep import deep_get
from flask import Flask, Markup, render_template
from markdown import markdown as md

app = Flask(__name__)


def make_html(name: str) -> str:
    """
    Makes HTML with provided data

    Parameters
    ----------
    name: str
        Name of data

    Returns
    -------
    html: str
        Created HTML
    """
    data = read_data(name)
    html = render_template(f'{name}.html', data=data)
    return html


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

    # Ignore name and contact
    sections = [section for section in data
                if section not in ('name', 'tags')]
    data['sections'] = sections

    if markup:
        for content in elaboration_content:
            section = deep_get(data, content)
            for i, subsection in enumerate(section):
                section[i]['elaboration'] = Markup(md(subsection['elaboration']))

    return data


@app.route('/')
def index() -> str:
    """
    Main page

    Returns
    -------
    html: str
        The main page HTML
    """
    html = make_html('index')
    return html


if __name__ == '__main__':
    app.run(debug=True, port=5657)
