# Local build script
sass portfolio/static/scss/style.scss portfolio/static/css/style.css
python build.py
cd portfolio/latex || exit
mkdir -vp build
latexmk -pdf -interaction=batchmode -output-directory=build resume.tex
cd ../..
mv portfolio/latex/build/resume.pdf site/files
rm -rf portfolio/latex/build
