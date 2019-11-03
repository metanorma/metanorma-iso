require "spec_helper"

RSpec.describe Asciidoctor::ISO do
  it "processes basic tables" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      .Table Name
      |===
      |A |B |C

      h|1 |2 |3
      |===
    INPUT
            #{BLANK_HDR}
       <sections>
         <table id="_">
         <name>Table Name</name>
         <thead>
           <tr>
             <th align="left">A</th>
             <th align="left">B</th>
             <th align="left">C</th>
           </tr>
         </thead>
         <tbody>
           <tr>
             <th align="left">1</th>
             <td align="left">2</td>
             <td align="left">3</td>
           </tr>
         </tbody>
       </table>
       </sections>
       </iso-standard>
    OUTPUT
  end

  it "inserts header rows in a table with a name and no header" do
        expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      [headerrows=2]
      .Table Name
      |===
      |A |B |C
      h|1 |2 |3
      h|1 |2 |3
      |===
    INPUT
    #{BLANK_HDR}
           <sections>
         <table id="_">
         <name>Table Name</name>
         <thead><tr>
             <td align="left">A</td>
             <td align="left">B</td>
             <td align="left">C</td>
           </tr><tr>
             <th align="left">1</th>
             <td align="left">2</td>
             <td align="left">3</td>
           </tr></thead>
         <tbody>


           <tr>
             <th align="left">1</th>
             <td align="left">2</td>
             <td align="left">3</td>
           </tr>
         </tbody>
       </table>
       </sections>
       </iso-standard>
    OUTPUT
  end


  it "inserts header rows in a table without a name and no header" do
        expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      [headerrows=2]
      |===
      |A |B |C
      h|1 |2 |3
      h|1 |2 |3
      |===
    INPUT
    #{BLANK_HDR}
           <sections>
         <table id="_"><thead><tr>
             <td align="left">A</td>
             <td align="left">B</td>
             <td align="left">C</td>
           </tr><tr>
             <th align="left">1</th>
             <td align="left">2</td>
             <td align="left">3</td>
           </tr></thead>
         <tbody>


           <tr>
             <th align="left">1</th>
             <td align="left">2</td>
             <td align="left">3</td>
           </tr>
         </tbody>
       </table>
       </sections>
       </iso-standard>
    OUTPUT
  end

  it "processes complex tables" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iso, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      [cols="<,^,^,^,^",options="header,footer",headerrows=2]
      .Maximum permissible mass fraction of defects
      |===
      .2+|Defect 4+^| Maximum permissible mass fraction of defects in husked rice +
      stem:[w_max]
      | in husked rice | in milled rice (non-glutinous) | in husked parboiled rice | in milled parboiled rice
      
      | Extraneous matter: organic footnote:[Organic extraneous matter includes foreign seeds, husks, bran, parts of straw, etc.] | 1,0 | 0,5 | 1,0 | 0,5
      // not rendered list here
      | Extraneous matter: inorganic footnote:[Inorganic extraneous matter includes stones, sand, dust, etc.] | 0,5 | 0,5 | 0,5 | 0,5
      | Paddy | 2,5 | 0,3 | 2,5 | 0,3
      | Husked rice, non-parboiled | Not applicable | 1,0 | 1,0 | 1,0
      | Milled rice, non-parboiled | 1,0 | Not applicable | 1,0 | 1,0
      | Husked rice, parboiled | 1,0 | 1,0 | Not applicable | 1,0
      | Milled rice, parboiled | 1,0 | 1,0 | 1,0 | Not applicable
      | Chips | 0,1 | 0,1 | 0,1 | 0,1
      | HDK | 2,0 footnoteref:[defectsmass,The maximum permissible mass fraction of defects shall be determined with respect to the mass fraction obtained after milling.] | 2,0 | 2,0 footnoteref:[defectsmass] | 2,0
      | Damaged kernels | 4,0 | 3,0 | 4,0 | 3,0
      | Immature and/or malformed kernels | 8,0 | 2,0 | 8,0 | 2,0
      | Chalky kernels | 5,0 footnoteref:[defectsmass] | 5,0 | Not applicable | Not applicable
      | Red kernels and red-streaked kernels | 12,0 | 12,0 | 12,0 footnoteref:[defectsmass] | 12,0
      | Partly gelatinized kernels | Not applicable | Not applicable | 11,0 footnoteref:[defectsmass] | 11,0
      | Pecks | Not applicable | Not applicable | 4,0 | 2,0
      | Waxy rice | 1,0 footnoteref:[defectsmass] | 1,0 | 1,0 footnoteref:[defectsmass] | 1,0
      
      5+a| Live insects shall not be present. Dead insects shall be included in extraneous matter.
      |===
    INPUT
            #{BLANK_HDR}
       <sections>
         <table id="_">
         <name>Maximum permissible mass fraction of defects</name>
         <thead>
           <tr>
             <th rowspan="2" align="left">Defect</th>
             <th colspan="4" align="center">Maximum permissible mass fraction of defects in husked rice<br/>
       <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><msub><mi>w</mi><mi>max</mi></msub></math></stem></th>
           </tr>
         <tr>
             <td align="left">in husked rice</td>
             <td align="center">in milled rice (non-glutinous)</td>
             <td align="center">in husked parboiled rice</td>
             <td align="center">in milled parboiled rice</td>
           </tr></thead>
         <tbody>

           <tr>
             <td align="left">Extraneous matter: organic<fn reference="a">
         <p id="_">Organic extraneous matter includes foreign seeds, husks, bran, parts of straw, etc.</p>
       </fn></td>
             <td align="center">1,0</td>
             <td align="center">0,5</td>
             <td align="center">1,0</td>
             <td align="center">0,5</td>
           </tr>
           <tr>
             <td align="left">Extraneous matter: inorganic<fn reference="b">
         <p id="_">Inorganic extraneous matter includes stones, sand, dust, etc.</p>
       </fn></td>
             <td align="center">0,5</td>
             <td align="center">0,5</td>
             <td align="center">0,5</td>
             <td align="center">0,5</td>
           </tr>
           <tr>
             <td align="left">Paddy</td>
             <td align="center">2,5</td>
             <td align="center">0,3</td>
             <td align="center">2,5</td>
             <td align="center">0,3</td>
           </tr>
           <tr>
             <td align="left">Husked rice, non-parboiled</td>
             <td align="center">Not applicable</td>
             <td align="center">1,0</td>
             <td align="center">1,0</td>
             <td align="center">1,0</td>
           </tr>
           <tr>
             <td align="left">Milled rice, non-parboiled</td>
             <td align="center">1,0</td>
             <td align="center">Not applicable</td>
             <td align="center">1,0</td>
             <td align="center">1,0</td>
           </tr>
           <tr>
             <td align="left">Husked rice, parboiled</td>
             <td align="center">1,0</td>
             <td align="center">1,0</td>
             <td align="center">Not applicable</td>
             <td align="center">1,0</td>
           </tr>
           <tr>
             <td align="left">Milled rice, parboiled</td>
             <td align="center">1,0</td>
             <td align="center">1,0</td>
             <td align="center">1,0</td>
             <td align="center">Not applicable</td>
           </tr>
           <tr>
             <td align="left">Chips</td>
             <td align="center">0,1</td>
             <td align="center">0,1</td>
             <td align="center">0,1</td>
             <td align="center">0,1</td>
           </tr>
           <tr>
             <td align="left">HDK</td>
             <td align="center">2,0<fn reference="c">
         <p id="_">The maximum permissible mass fraction of defects shall be determined with respect to the mass fraction obtained after milling.</p>
       </fn></td>
             <td align="center">2,0</td>
             <td align="center">2,0<fn reference="c">
         <p id="_">The maximum permissible mass fraction of defects shall be determined with respect to the mass fraction obtained after milling.</p>
       </fn></td>
             <td align="center">2,0</td>
           </tr>
           <tr>
             <td align="left">Damaged kernels</td>
             <td align="center">4,0</td>
             <td align="center">3,0</td>
             <td align="center">4,0</td>
             <td align="center">3,0</td>
           </tr>
           <tr>
             <td align="left">Immature and/or malformed kernels</td>
             <td align="center">8,0</td>
             <td align="center">2,0</td>
             <td align="center">8,0</td>
             <td align="center">2,0</td>
           </tr>
           <tr>
             <td align="left">Chalky kernels</td>
             <td align="center">5,0<fn reference="c">
         <p id="_">The maximum permissible mass fraction of defects shall be determined with respect to the mass fraction obtained after milling.</p>
       </fn></td>
             <td align="center">5,0</td>
             <td align="center">Not applicable</td>
             <td align="center">Not applicable</td>
           </tr>
           <tr>
             <td align="left">Red kernels and red-streaked kernels</td>
             <td align="center">12,0</td>
             <td align="center">12,0</td>
             <td align="center">12,0<fn reference="c">
         <p id="_">The maximum permissible mass fraction of defects shall be determined with respect to the mass fraction obtained after milling.</p>
       </fn></td>
             <td align="center">12,0</td>
           </tr>
           <tr>
             <td align="left">Partly gelatinized kernels</td>
             <td align="center">Not applicable</td>
             <td align="center">Not applicable</td>
             <td align="center">11,0<fn reference="c">
         <p id="_">The maximum permissible mass fraction of defects shall be determined with respect to the mass fraction obtained after milling.</p>
       </fn></td>
             <td align="center">11,0</td>
           </tr>
           <tr>
             <td align="left">Pecks</td>
             <td align="center">Not applicable</td>
             <td align="center">Not applicable</td>
             <td align="center">4,0</td>
             <td align="center">2,0</td>
           </tr>
           <tr>
             <td align="left">Waxy rice</td>
             <td align="center">1,0<fn reference="c">
         <p id="_">The maximum permissible mass fraction of defects shall be determined with respect to the mass fraction obtained after milling.</p>
       </fn></td>
             <td align="center">1,0</td>
             <td align="center">1,0<fn reference="c">
         <p id="_">The maximum permissible mass fraction of defects shall be determined with respect to the mass fraction obtained after milling.</p>
       </fn></td>
             <td align="center">1,0</td>
           </tr>
         </tbody>
         <tfoot>
           <tr>
             <td colspan="5" align="left">
               <p id="_">Live insects shall not be present. Dead insects shall be included in extraneous matter.</p>
             </td>
           </tr>
         </tfoot>
       </table>
       </sections>
       </iso-standard>
    OUTPUT
  end
end

