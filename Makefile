# What to compile by default?
SOURCES := $(wildcard *.org)
TARGETS := $(patsubst %.org,docs/%.html,$(SOURCES))

STYLES := css/tufte-css/tufte.css \
	css/pandoc.css \
	css/pandoc-solarized.css \
	css/tufte-extra.css

.PHONY: all
all: $(TARGETS)

# Note: you will need pandoc 2 or greater for this to work

## Generalized rule: how to build a .html file from each .org
docs/%.html: %.org css/tufte.html5 $(STYLES) Makefile css/tufte.html5
	pandoc \
		--katex \
		--section-divs \
		--from org \
		--filter pandoc-sidenote \
		--lua-filter=filters/links-to-html.lua \
		--to html5+smart \
		--template=css/tufte \
		$(foreach style,$(STYLES),--css $(notdir $(style))) \
		--output $@ \
		$<

.PHONY: clean
clean:
	rm $(TARGETS)

# The default tufte.css file expects all the assets to be in the same folder.
# In real life, instead of duplicating the files you'd want to put them in a
# shared "css/" folder or something, and adjust the `--css` flags to the pandoc
# command to give the correct paths to each CSS file.
.PHONY: docs
docs:
	cp -r $(STYLES) css/tufte-css/et-book/ docs/
