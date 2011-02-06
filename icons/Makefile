%.png: src/%.svg; convert -background none $< $@
# If you prefer a different color, use something like this. (#1E2320 is the destination color)
#%.png: src/%.svg; convert -background none -fill '#1E2320' -colorize 100% $< $@
SVG = $(wildcard src/*.svg)
PNG = $(patsubst src/%.svg,%.png,$(SVG))

all: $(PNG)
clean:
	rm -f $(PNG)
