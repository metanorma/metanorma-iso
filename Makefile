SRC  := $(wildcard draft-*.adoc)
TXT  := $(patsubst %.adoc,%.txt,$(SRC))
XML  := $(patsubst %.adoc,%.xml,$(SRC))
HTML := $(patsubst %.adoc,%.html,$(SRC))
NITS := $(patsubst %.adoc,%.nits,$(SRC))

SHELL := /bin/bash
# Ensure the xml2rfc cache directory exists locally
IGNORE := $(shell mkdir -p $(HOME)/.cache/xml2rfc)

TRANG_RELEASE := https://github.com/relaxng/jing-trang/releases/download/V20181222/trang-20181222.zip
TRANG_JAR := ${CURDIR}/trang/trang.jar
XSDVIPATH := ${CURDIR}/xsdvi/xsdvi.jar
XSLT_FILE := ${CURDIR}/xsl/xs3p.xsl
XSLT_FILE_MERGE := ${CURDIR}/xsl/xsdmerge.xsl
RNG_FILE_SRC := lib/asciidoctor/iso/isostandard.rng
XSD_FILE_DEST := ${CURDIR}/xsd_doc/isostandard.xsd

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


xsdvi/xsdvi.zip:
	mkdir -p $(dir $@)
	curl -sSL https://sourceforge.net/projects/xsdvi/files/latest/download > $@

$(XSDVIPATH): xsdvi/xercesImpl.jar
	curl -sSL https://github.com/metanorma/xsdvi/releases/download/v1.0/xsdvi-1.0.jar > $@

$(XSLT_FILE):
	mkdir -p $(dir $@)
	curl -sSL https://raw.githubusercontent.com/metanorma/xs3p/main/xsl/xs3p.xsl > $@

$(XSLT_FILE_MERGE):
	mkdir -p $(dir $@)
	curl -sSL https://raw.githubusercontent.com/metanorma/xs3p/main/xsl/xsdmerge.xsl > $@


xsdvi/xercesImpl.jar: xsdvi/xsdvi.zip
	unzip -p $< dist/lib/xercesImpl.jar > $@

$(TRANG_JAR):
	mkdir -p $(dir $@); \
	cd $(dir $@); \
	curl -sSL $(TRANG_RELEASE) > trang.zip; \
 	unzip -p trang.zip trang-20181222/trang.jar > $@


$(XSD_FILE_DEST): $(TRANG_JAR)
	mkdir -p $(dir $@); \
	java -jar $< $(RNG_FILE_SRC) $@

xsd_doc:  $(XSD_FILE_DEST) $(XSDVIPATH) $(XSLT_FILE) $(XSLT_FILE_MERGE)
	mkdir -p $@/diagrams; \
	cd $@; \
	java -jar $(XSDVIPATH) $< -rootNodeName all -oneNodeOnly -outputPath diagrams; \
	xsltproc --nonet --stringparam rootxsd iso-standard --output $@.tmp $(XSLT_FILE_MERGE) $<;\
	xsltproc --nonet --param title "'Metanorma XML Schema Documentation, ISO Standard'" \
		--output index.html $(XSLT_FILE) $@.tmp;\
	rm $@.tmp

