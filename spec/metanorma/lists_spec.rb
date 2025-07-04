require "spec_helper"

RSpec.describe Metanorma::Iso do
  it "processes simple lists" do
    output = Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{ASCIIDOC_BLANK_HDR}
      * List 1
      * List 2
      * List 3

      . List A
      . List B
      . List C

      List D:: List E
      List F:: List G

    INPUT
    expect(Xml::C14n.format(strip_guid(output))).to be_equivalent_to Xml::C14n.format(<<~"OUTPUT")
      #{BLANK_HDR}
        <sections>
          <ul id="_">
            <li>
              <p id="_">List 1</p>
            </li>
            <li>
              <p id="_">List 2</p>
            </li>
            <li>
              <p id="_">List 3</p>
              <ol id="_">
                <li>
                  <p id="_">List A</p>
                </li>
                <li>
                  <p id="_">List B</p>
                </li>
                <li>
                  <p id="_">List C</p>
                  <dl id="_">
                    <dt>List D</dt>
                    <dd id="_">
                      <p id="_">List E</p>
                    </dd>
                    <dt>List F</dt>
                    <dd id="_">
                      <p id="_">List G</p>
                    </dd>
                  </dl>
                </li>
              </ol>
            </li>
          </ul>
        </sections>
      </metanorma>
    OUTPUT
  end

  it "processes complex lists" do
    output = Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{ASCIIDOC_BLANK_HDR}
      [[id]]
      * First
      * Second
      +
      --
      entry1

      entry2
      --

      [[id1]]
      [loweralpha]
      . First
      . Second
      [upperalpha,start=4]
      .. Third
      .. Fourth
      . Fifth
      . Sixth

      [lowerroman]
      . A
      . B
      [upperroman]
      .. C
      .. D
      [arabic]
      ... E
      ... F


      Notes1::
      Notes::  Note 1.
      +
      Note 2.
      +
      Note 3.

    INPUT
    expect(Xml::C14n.format(strip_guid(output))).to be_equivalent_to Xml::C14n.format(<<~"OUTPUT")
      #{BLANK_HDR}
        <sections>
          <ul id="_" anchor="id">
            <li>
              <p id="_">First</p>
            </li>
            <li>
              <p id="_">Second</p>
              <p id="_">entry1</p>
              <p id="_">entry2</p>
            </li>
          </ul>
          <ol id="_" anchor="id1" type="alphabet">
            <li>
              <p id="_">First</p>
            </li>
            <li>
              <p id="_">Second</p>
              <ol id='_' start='4' type="alphabet_upper">
                <li>
                  <p id="_">Third</p>
                </li>
                <li>
                  <p id="_">Fourth</p>
                </li>
              </ol>
            </li>
            <li>
              <p id="_">Fifth</p>
            </li>
            <li>
              <p id="_">Sixth</p>
            </li>
          </ol>
          <ol id="_" type="roman">
            <li>
              <p id="_">A</p>
            </li>
            <li>
              <p id="_">B</p>
              <ol id="_" type="roman_upper">
                <li>
                  <p id="_">C</p>
                </li>
                <li>
                  <p id="_">D</p>
                  <ol id="_" type="arabic">
                    <li>
                      <p id="_">E</p>
                    </li>
                    <li>
                      <p id="_">F</p>
                      <dl id="_">
                        <dt>Notes1</dt>
                        <dd/>
                        <dt>Notes</dt>
                        <dd id="_">
                          <p id="_">Note 1.</p>
                          <p id="_">Note 2.</p>
                          <p id="_">Note 3.</p>
                        </dd>
                      </dl>
                    </li>
                  </ol>
                </li>
              </ol>
            </li>
          </ol>
        </sections>
      </metanorma>
    OUTPUT
  end

  it "anchors lists and list items" do
    expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to Xml::C14n.format(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      [[id1]]
      * [[id2]] List item
      * Hello [[id3]] List item

    INPUT
      #{BLANK_HDR}
        <sections>
          <ul id="_" anchor="id1">
            <li id="_" anchor="id2">
              <p id="_">List item</p>
            </li>
            <li>
              <p id="_">Hello <bookmark id="_" anchor="id3"/> List item</p>
            </li>
          </ul>
        </sections>
      </metanorma>
    OUTPUT
  end
end
