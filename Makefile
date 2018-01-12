SRC  := $(wildcard draft-*.adoc)
TXT  := $(patsubst %.adoc,%.txt,$(SRC))
XML  := $(patsubst %.adoc,%.xml,$(SRC))
HTML := $(patsubst %.adoc,%.html,$(SRC))
NITS := $(patsubst %.adoc,%.nits,$(SRC))

SHELL := /bin/bash
# Ensure the xml2rfc cache directory exists locally
IGNORE := $(shell mkdir -p $(HOME)/.cache/xml2rfc)

all: $(TXT) $(HTML) $(XML) $(NITS)

clean:
	rm -f $(TXT) $(HTML) $(XML)

%.xml: %.adoc
	#bundle exec asciidoctor -r ./lib/glob-include-processor.rb -r asciidoctor-rfc -b rfc2 $^ --trace > $@
	bundle exec asciidoctor -r ./lib/glob-include-processor.rb -r asciidoctor-rfc -b rfc2 -a flush-biblio=true $^ --trace > $@

%.xml3: %.adoc
	#bundle exec asciidoctor -r ./lib/glob-include-processor.rb -r asciidoctor-rfc -b rfc2 $^ --trace > $@
	bundle exec asciidoctor -r ./lib/glob-include-processor.rb -r asciidoctor-rfc -b rfc3 -a flush-biblio=true $^ --trace > $@

%.txt: %.xml
	xml2rfc --text $^ $@

%.html: %.xml
	xml2rfc --html $^ $@

%.nits: %.txt
	VERSIONED_NAME=`grep :name: $*.adoc | cut -f 2 -d ' '`; \
	cp $^ $${VERSIONED_NAME}.txt && \
	idnits --verbose $${VERSIONED_NAME}.txt > $@ && \
	cp $@ $${VERSIONED_NAME}.nits && \
	cat $${VERSIONED_NAME}.nits

open:
	open *.txt

