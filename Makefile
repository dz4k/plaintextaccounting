all: pandoc html

# workaround for pandoc not being present in Cloudflare Pages platform V2
pandoc:
	pandoc --version || sudo apt install -y pandoc

# Generate html from all md files in src/, in out/
html: $(patsubst src/%,out/%,$(patsubst %.md,%.html,$(wildcard src/*.md src/quickref/*.md))) Makefile

PANDOC=pandoc \
	-f markdown-smart-tex_math_dollars+autolink_bare_uris+wikilinks_title_after_pipe \
	--lua-filter=fixwikilinks.lua

# generate html from a md file
out/%.html: src/%.md page.tmpl
	$(PANDOC) --template page.tmpl "$<" -o "$@"

# regenerate html whenever an md file changes
html-auto auto:
	watchexec -- make html
# no different:
#	watchexec --ignore-file=page.tmpl -- make html

BROWSE=open
LIVERELOADPORT=8100
LIVERELOAD=livereloadx -p $(LIVERELOADPORT) -s
  #  --exclude '*.html'
  # Exclude html files to avoid reloading browser as every page is generated.
  # A reload happens at the end when the css/js files get copied.

# Auto-regenerate html, and watch changes in a new browser window.
html-watch watch:
	make html-auto &
	(sleep 1; $(BROWSE) http://localhost:$(LIVERELOADPORT)/) &
	$(LIVERELOAD) out

clean:
	rm -f $(patsubst %.md,%.html,$(wildcard *.md))

