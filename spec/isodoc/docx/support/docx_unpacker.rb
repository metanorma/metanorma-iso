# frozen_string_literal: true

require "tmpdir"
require "zip"
require "nokogiri"

module IsoDoc
  module Iso
    module Docx
      # Test helper: unpacks a DOCX package into a temp dir and exposes
      # parsed XML for the individual word/*.xml parts. Used by the
      # end-to-end spec to assert against adapter output.
      class DocxUnpacker
        W_NS = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
        R_NS = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"

        def self.unpack(docx_path)
          dir = Dir.mktmpdir("docx-unpack")
          Zip::File.open(docx_path) do |zip|
            zip.each do |entry|
              next unless entry.name.start_with?("word/")

              target = File.join(dir, entry.name)
              FileUtils.mkdir_p(File.dirname(target))
              entry.extract(target)
            end
          end
          new(dir)
        end

        def initialize(dir)
          @dir = dir
        end

        def read(relative)
          path = File.join(@dir, relative)
          return nil unless File.exist?(path)

          Nokogiri::XML(File.read(path, encoding: "utf-8"))
        end

        def document_xml
          read("word/document.xml") || raise(StandardError, "missing word/document.xml")
        end

        def styles_xml
          read("word/styles.xml")
        end

        def numbering_xml
          read("word/numbering.xml")
        end

        def header_xml(name)
          read("word/#{name}.xml")
        end

        def footer_xml(name)
          read("word/#{name}.xml")
        end

        def header_names
          Dir.glob("header*.xml", base: File.join(@dir, "word"))
             .map { |f| File.basename(f, ".xml") }
        end

        def footer_names
          Dir.glob("footer*.xml", base: File.join(@dir, "word"))
             .map { |f| File.basename(f, ".xml") }
        end

        def cleanup
          FileUtils.rm_rf(@dir)
        end
      end
    end
  end
end
