#!/usr/bin/env make -f

OUTFILE ?= slides.pdf

pdf:
	TEXINPUTS="$(shell kpsewhich -show-path tex):${THEME_PATH}" \
    TTFONTS="$(shell kpsewhich -show-path 'truetype fonts'):${FONT_PATH}" \
	pandoc \
		-f 'markdown+link_attributes' \
		-t beamer \
		-o $(OUTFILE) \
		--pdf-engine xelatex \
		-V "mainfont:FiraSans" \
		-V "mainfontoptions:Path=${FONT_PATH}/, UprightFont=*-Regular, ItalicFont=*-Italic, BoldItalicFont=*-BoldItalic" \
		-V "theme:metropolis" \
		slides.md

dev:
	sh -c 'while :; do make pdf; inotifywait slides.md Makefile; done'

devz:
	sh -c 'zathura slides.pdf & make dev'

.PHONY: build dev devz
