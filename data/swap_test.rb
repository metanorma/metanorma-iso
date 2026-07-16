require "zip"

ref_parts = {}
Zip::File.open("iso-rice-sample-output-repaired.docx") do |z|
  z.each { |e| next if e.directory?; ref_parts[e.name] = e.get_input_stream.read }
end

our_parts = {}
Zip::File.open("rice_output.docx") do |z|
  z.each { |e| next if e.directory?; our_parts[e.name] = e.get_input_stream.read }
end

parts_to_test = [
  "word/styles.xml",
  "word/numbering.xml",
  "word/settings.xml",
  "word/fontTable.xml",
  "word/webSettings.xml",
  "word/theme/theme1.xml",
  "word/footnotes.xml",
  "word/endnotes.xml",
  "word/header1.xml",
  "word/footer1.xml",
]

was_zip64 = Zip.write_zip64_support
Zip.write_zip64_support = false
begin
  parts_to_test.each do |part_name|
    next unless our_parts.key?(part_name)

    slug = File.basename(part_name, ".xml").gsub(/[^a-zA-Z0-9]/, "_")
    test_name = "test_swap_#{slug}"
    test = ref_parts.dup
    test[part_name] = our_parts[part_name]

    Zip::OutputStream.open("#{test_name}.docx") do |zos|
      test.each do |path, content|
        entry = Zip::Entry.new("#{test_name}.docx", path)
        entry.internal_file_attributes = 0
        entry.external_file_attributes = 0
        entry.fstype = Zip::FSTYPE_FAT
        zos.put_next_entry(entry)
        zos.write(content)
      end
    end
    puts "Created #{test_name}.docx (swapped #{part_name})"
  end
ensure
  Zip.write_zip64_support = was_zip64
end
