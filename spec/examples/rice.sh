asciidoctor rice.adoc
asciidoctor --trace -b iso -r 'asciidoctor-iso' rice.adoc
ruby ../../lib/asciidoctor/iso/word/wordconvert.rb  rice.xml

