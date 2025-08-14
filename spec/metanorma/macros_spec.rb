require "spec_helper"

RSpec.describe Metanorma::Standoc do
  it "processes embed macro with document in a different flavour" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}

      [[clause1]]
      == Clause 1

      embed::spec/assets/iso.adoc[]
    INPUT
    output = <<~OUTPUT
      <metanorma xmlns='https://www.metanorma.org/ns/standoc' type='semantic' version='#{Metanorma::Standoc::VERSION}' flavor="standoc">
       <bibdata type='standard'>
         <title language='en' format='text/plain'>Document title</title>
         <language>en</language>
         <script>Latn</script>
         <status>
           <stage>published</stage>
         </status>
         <copyright>
           <from>#{Date.today.year}</from>
         </copyright>
         <ext>
           <doctype>standard</doctype>
                <flavor>standoc</flavor>
         </ext>
                    <relation type='derivedFrom'>
             <bibitem>
               <title language='en' format='text/plain' type='main'>
                 Medical devices — Quality management systems — Requirements for
                 regulatory purposes
               </title>
               <title language='en' format='text/plain' type='title-main'>
                 Medical devices — Quality management systems — Requirements for
                 regulatory purposes
               </title>
               <title language='fr' format='text/plain' type='main'>
                 Dispositifs médicaux — Systèmes de management de la qualité —
                 Exigences à des fins réglementaires
               </title>
               <title language='fr' format='text/plain' type='title-main'>
                 Dispositifs médicaux — Systèmes de management de la qualité —
                 Exigences à des fins réglementaires
               </title>
               <contributor>
                 <role type='author'/>
                 <organization>
                   <name>International Organization for Standardization</name>
                   <abbreviation>ISO</abbreviation>
                 </organization>
               </contributor>
               <contributor>
                 <role type='publisher'/>
                 <organization>
                   <name>International Organization for Standardization</name>
                   <abbreviation>ISO</abbreviation>
                 </organization>
               </contributor>
                <contributor>
                  <role type="authorizer"><description>Agency</description></role>
                  <organization>
                    <name>International Organization for Standardization</name>
                    <abbreviation>ISO</abbreviation>
                  </organization>
                </contributor>
               <language>en</language>
               <script>Latn</script>
               <status>
                 <stage>60</stage>
                 <substage>60</substage>
               </status>
               <copyright>
                 <from>#{Date.today.year}</from>
                 <owner>
                   <organization>
                     <name>International Organization for Standardization</name>
                     <abbreviation>ISO</abbreviation>
                   </organization>
                 </owner>
               </copyright>
               <ext>
                 <doctype>standard</doctype>
                <flavor>iso</flavor>
                 <stagename>International Standard</stagename>
               </ext>
             </bibitem>
           </relation>
              </bibdata>
              <sections>
                <clause id="_" anchor='clause1' inline-header='false' obligation='normative'>
                  <title id="_">Clause 1</title>
                </clause>
              </sections>
      </standard-standard>
    OUTPUT
    xml = Nokogiri::XML(Asciidoctor
      .convert(input, backend: :standoc, header_footer: true))
    xml.at("//xmlns:metanorma-extension")&.remove
    expect(Canon.format_xml(strip_guid(xml.to_xml)))
      .to be_equivalent_to Canon.format_xml(output)
  end
end
