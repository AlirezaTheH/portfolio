"""
Simple flask app to preview portfolio.
"""
from flask import Flask, render_template
from utils import read_data

app = Flask(__name__)


@app.route('/')
def index() -> str:
    """
    Main page

    Returns
    -------
    html: str
        The main page HTML
    """
    data = read_data('index')
    html = render_template('index.html', data=data)
    return html


if __name__ == '__main__':
    app.run(debug=True, port=5657)
