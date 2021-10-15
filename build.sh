# Local build script
python build.py
cd portfolio/tex || exit
mkdir -vp build
latexmk -pdf --interaction=batchmode --output-directory=build resume.tex
cd ../..
mv portfolio/tex/build/resume.pdf site/files
rm -rf portfolio/tex/build
