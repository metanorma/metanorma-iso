<?xml version="1.0" encoding="UTF-8"?><xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:iso="https://www.metanorma.org/ns/iso" xmlns:mathml="http://www.w3.org/1998/Math/MathML" xmlns:xalan="http://xml.apache.org/xalan" xmlns:fox="http://xmlgraphics.apache.org/fop/extensions" xmlns:pdf="http://xmlgraphics.apache.org/fop/extensions/pdf" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:java="http://xml.apache.org/xalan/java" exclude-result-prefixes="java" version="1.0">

	<xsl:output method="xml" encoding="UTF-8" indent="no"/>
	
	

	<xsl:key name="kfn" match="*[local-name() = 'fn'][not(ancestor::*[(local-name() = 'table' or local-name() = 'figure') and not(ancestor::*[local-name() = 'name'])])]" use="@reference"/>
	
	<xsl:key name="attachments" match="iso:eref[contains(@bibitemid, '.exp')]" use="@bibitemid"/>
	
	
	
	<xsl:variable name="namespace_full">https://www.metanorma.org/ns/iso</xsl:variable>
	
	<xsl:variable name="debug">false</xsl:variable>
	
	<xsl:variable name="docidentifierISO_undated" select="normalize-space(/iso:iso-standard/iso:bibdata/iso:docidentifier[@type = 'iso-undated'])"/>
	<xsl:variable name="docidentifierISO_">
		<xsl:value-of select="$docidentifierISO_undated"/>
		<xsl:if test="$docidentifierISO_undated = ''">
			<xsl:value-of select="/iso:iso-standard/iso:bibdata/iso:docidentifier[@type = 'iso'] | /iso:iso-standard/iso:bibdata/iso:docidentifier[@type = 'ISO']"/>
		</xsl:if>
	</xsl:variable>
	<xsl:variable name="docidentifierISO" select="normalize-space($docidentifierISO_)"/>

	<xsl:variable name="all_rights_reserved">
		<xsl:call-template name="getLocalizedString">
			<xsl:with-param name="key">all_rights_reserved</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>	
	<xsl:variable name="copyrightYear" select="/iso:iso-standard/iso:bibdata/iso:copyright/iso:from"/>
	<xsl:variable name="copyrightAbbr_">
		<xsl:for-each select="/iso:iso-standard/iso:bibdata/iso:copyright/iso:owner/iso:organization/iso:abbreviation[. != 'IEEE']">
			<xsl:value-of select="."/><xsl:if test="position() != last()">/</xsl:if>
		</xsl:for-each>
	</xsl:variable>
	<xsl:variable name="copyrightAbbr" select="normalize-space($copyrightAbbr_)"/>
	<xsl:variable name="copyrightAbbrIEEE" select="normalize-space(/iso:iso-standard/iso:bibdata/iso:copyright/iso:owner/iso:organization/iso:abbreviation[. = 'IEEE'])"/>
	<xsl:variable name="copyrightText">
		<xsl:value-of select="concat('© ', $copyrightAbbr, ' ', $copyrightYear ,' – ', $all_rights_reserved)"/>
		<xsl:if test="$copyrightAbbrIEEE != ''">
			<xsl:value-of select="$linebreak"/>
			<xsl:value-of select="concat('© ', $copyrightAbbrIEEE, ' ', $copyrightYear ,' – ', $all_rights_reserved)"/>
		</xsl:if>
	</xsl:variable>
  
	<xsl:variable name="lang-1st-letter_tmp" select="substring-before(substring-after(/iso:iso-standard/iso:bibdata/iso:docidentifier[@type = 'iso-with-lang'], '('), ')')"/>
	<xsl:variable name="lang-1st-letter" select="concat('(', $lang-1st-letter_tmp , ')')"/>
  
	<!-- <xsl:variable name="ISOname" select="concat(/iso:iso-standard/iso:bibdata/iso:docidentifier, ':', /iso:iso-standard/iso:bibdata/iso:copyright/iso:from , $lang-1st-letter)"/> -->
	<xsl:variable name="ISOname" select="/iso:iso-standard/iso:bibdata/iso:docidentifier[@type = 'iso-reference']"/>

	<xsl:variable name="part" select="/iso:iso-standard/iso:bibdata/iso:ext/iso:structuredidentifier/iso:project-number/@part"/>
	
	<xsl:variable name="doctype" select="/iso:iso-standard/iso:bibdata/iso:ext/iso:doctype"/>	 
  <xsl:variable name="doctype_localized" select="/iso:iso-standard/iso:bibdata/iso:ext/iso:doctype[@language = $lang]"/>
    
	<xsl:variable name="doctype_uppercased">
    <xsl:choose>
      <xsl:when test="$doctype_localized != ''">
        <xsl:value-of select="java:toUpperCase(java:java.lang.String.new(translate(normalize-space($doctype_localized),'-',' ')))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="java:toUpperCase(java:java.lang.String.new(translate(normalize-space($doctype),'-',' ')))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable> 
	 	
	<xsl:variable name="stage" select="number(/iso:iso-standard/iso:bibdata/iso:status/iso:stage)"/>
	<xsl:variable name="substage" select="number(/iso:iso-standard/iso:bibdata/iso:status/iso:substage)"/>	
	<xsl:variable name="stagename" select="normalize-space(/iso:iso-standard/iso:bibdata/iso:ext/iso:stagename)"/>
	<xsl:variable name="stagename_localized" select="normalize-space(/iso:iso-standard/iso:bibdata/iso:status/iso:stage[@language = $lang])"/>
	<xsl:variable name="abbreviation" select="normalize-space(/iso:iso-standard/iso:bibdata/iso:status/iso:stage/@abbreviation)"/>
		
	<xsl:variable name="stage-abbreviation">
		<xsl:choose>
			<xsl:when test="$abbreviation != ''">
				<xsl:value-of select="$abbreviation"/>
			</xsl:when>
			<xsl:when test="$stage = 0 and $substage = 0">PWI</xsl:when>
			<xsl:when test="$stage = 0">NWIP</xsl:when> <!-- NWIP (NP) -->
			<xsl:when test="$stage = 10">AWI</xsl:when>
			<xsl:when test="$stage = 20">WD</xsl:when>
			<xsl:when test="$stage = 30">CD</xsl:when>
			<xsl:when test="$stage = 40">DIS</xsl:when>
			<xsl:when test="$stage = 50">FDIS</xsl:when>
			<xsl:when test="$stage = 60 and $substage = 0">PRF</xsl:when>
			<xsl:when test="$stage = 60 and $substage = 60">IS</xsl:when>
			<xsl:when test="$stage &gt;=60">published</xsl:when>
			<xsl:otherwise/>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="stage-fullname-uppercased">
		<xsl:choose>
			<xsl:when test="$stagename_localized != ''">
				<xsl:value-of select="java:toUpperCase(java:java.lang.String.new($stagename_localized))"/>
			</xsl:when>
			<xsl:when test="$stagename != ''">
				<xsl:value-of select="java:toUpperCase(java:java.lang.String.new($stagename))"/>
			</xsl:when>
			<xsl:when test="$stage-abbreviation = 'NWIP' or                $stage-abbreviation = 'NP'">NEW WORK ITEM PROPOSAL</xsl:when>
			<xsl:when test="$stage-abbreviation = 'PWI'">PRELIMINARY WORK ITEM</xsl:when>
			<xsl:when test="$stage-abbreviation = 'AWI'">APPROVED WORK ITEM</xsl:when>
			<xsl:when test="$stage-abbreviation = 'WD'">WORKING DRAFT</xsl:when>
			<xsl:when test="$stage-abbreviation = 'CD'">COMMITTEE DRAFT</xsl:when>
			<xsl:when test="$stage-abbreviation = 'DIS'">DRAFT INTERNATIONAL STANDARD</xsl:when>
			<xsl:when test="$stage-abbreviation = 'FDIS'">FINAL DRAFT INTERNATIONAL STANDARD</xsl:when>
			<xsl:otherwise><xsl:value-of select="$doctype_uppercased"/></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:variable name="stagename-header-firstpage">
		<xsl:choose>
			<!-- <xsl:when test="$stage-abbreviation = 'PWI' or 
														$stage-abbreviation = 'NWIP' or 
														$stage-abbreviation = 'NP'">PRELIMINARY WORK ITEM</xsl:when> -->
			<xsl:when test="$stage-abbreviation = 'PRF'"><xsl:value-of select="$doctype_uppercased"/></xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$stage-fullname-uppercased"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:variable name="stagename-header-coverpage">
		<xsl:choose>
			<xsl:when test="$stage-abbreviation = 'DIS'">DRAFT</xsl:when>
			<xsl:when test="$stage-abbreviation = 'FDIS'">FINAL DRAFT</xsl:when>
			<xsl:when test="$stage-abbreviation = 'PRF'"/>
			<xsl:when test="$stage-abbreviation = 'IS'"/>
			<xsl:otherwise>
				<xsl:value-of select="$stage-fullname-uppercased"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<!-- UPPERCASED stage name -->	
	<!-- <item name="NWIP" show="true" header="PRELIMINARY WORK ITEM" shortname="NEW WORK ITEM PROPOSAL">NEW WORK ITEM PROPOSAL</item>
	<item name="PWI" show="true" header="PRELIMINARY WORK ITEM" shortname="PRELIMINARY WORK ITEM">PRELIMINARY WORK ITEM</item>		
	<item name="NP" show="true" header="PRELIMINARY WORK ITEM" shortname="NEW WORK ITEM PROPOSAL">NEW WORK ITEM PROPOSAL</item>
	<item name="AWI" show="true" header="APPROVED WORK ITEM" shortname="APPROVED WORK ITEM">APPROVED WORK ITEM</item>
	<item name="WD" show="true" header="WORKING DRAFT" shortname="WORKING DRAFT">WORKING DRAFT</item>
	<item name="CD" show="true" header="COMMITTEE DRAFT" shortname="COMMITTEE DRAFT">COMMITTEE DRAFT</item>
	<item name="DIS" show="true" header="DRAFT INTERNATIONAL STANDARD" shortname="DRAFT">DRAFT INTERNATIONAL STANDARD</item>
	<item name="FDIS" show="true" header="FINAL DRAFT INTERNATIONAL STANDARD" shortname="FINAL DRAFT">FINAL DRAFT INTERNATIONAL STANDARD</item>
	<item name="PRF">PROOF</item> -->
	
	
	<!-- 
		<status>
    <stage>30</stage>
    <substage>92</substage>
  </status>
	  The <stage> and <substage> values are well defined, 
		as the International Harmonized Stage Codes (https://www.iso.org/stage-codes.html):
		stage 60 means published, everything before is a Draft (90 means withdrawn, but the document doesn't change anymore) -->
	<xsl:variable name="isPublished">
		<xsl:choose>
			<xsl:when test="string($stage) = 'NaN'">false</xsl:when>
			<xsl:when test="$stage &gt;=60">true</xsl:when>
			<xsl:when test="normalize-space($stage-abbreviation) != ''">true</xsl:when>
			<xsl:otherwise>false</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:variable name="document-master-reference">
		<xsl:choose>
			<xsl:when test="$stage-abbreviation != ''">-publishedISO</xsl:when>
			<xsl:otherwise/>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="force-page-count-preface">
		<xsl:choose>
			<xsl:when test="$document-master-reference != ''">end-on-even</xsl:when>
			<xsl:otherwise>no-force</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:variable name="proof-text">PROOF/ÉPREUVE</xsl:variable>
	
	<!-- Example:
		<item level="1" id="Foreword" display="true">Foreword</item>
		<item id="term-script" display="false">3.2</item>
	-->
	<xsl:variable name="contents_">
		<contents>
			<xsl:call-template name="processPrefaceSectionsDefault_Contents"/>
			<xsl:call-template name="processMainSectionsDefault_Contents"/>
			<xsl:apply-templates select="//iso:indexsect" mode="contents"/>
			<xsl:call-template name="processTablesFigures_Contents"/>
		</contents>
	</xsl:variable>
	<xsl:variable name="contents" select="xalan:nodeset($contents_)"/>
	
	<xsl:variable name="lang_other">
		<xsl:for-each select="/iso:iso-standard/iso:bibdata/iso:title[@language != $lang]">
			<xsl:if test="not(preceding-sibling::iso:title[@language = current()/@language])">
				<lang><xsl:value-of select="@language"/></lang>
			</xsl:if>
		</xsl:for-each>
	</xsl:variable>
	
	<xsl:variable name="editorialgroup_">
		<!-- Example: ISO/TC 46/SC 2 -->
		<!-- ISO/SG SMART/SG TS/AG 1 -->
		<xsl:variable name="approvalgroup" select="normalize-space(/iso:iso-standard/iso:bibdata/iso:ext/iso:approvalgroup/@identifier)"/>
		<xsl:variable name="parts_by_slash">
			<xsl:call-template name="split">
				<xsl:with-param name="pText" select="$approvalgroup"/>
				<xsl:with-param name="sep" select="'/'"/>
				<xsl:with-param name="normalize-space">false</xsl:with-param>
				<xsl:with-param name="keep_sep">true</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="parts_with_subparts">
			<xsl:for-each select="xalan:nodeset($parts_by_slash)//item">
				<subitem>
					<xsl:call-template name="split">
						<xsl:with-param name="pText" select="."/>
						<xsl:with-param name="sep" select="' '"/>
						<xsl:with-param name="normalize-space">false</xsl:with-param>
						<xsl:with-param name="keep_sep">true</xsl:with-param>
					</xsl:call-template>
				</subitem>
			</xsl:for-each>
		</xsl:variable>
		<xsl:for-each select="xalan:nodeset($parts_with_subparts)//subitem">
			<xsl:choose>
				<xsl:when test="position() = 1">
					<xsl:value-of select="."/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:for-each select="item">
						<xsl:choose>
							<xsl:when test="position() = last()">
								<fo:inline font-weight="bold"><xsl:value-of select="."/></fo:inline>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="."/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:variable>
	<xsl:variable name="editorialgroup" select="xalan:nodeset($editorialgroup_)"/>
	
	<xsl:variable name="secretariat_">
		<xsl:variable name="value" select="normalize-space(/iso:iso-standard/iso:bibdata/iso:ext/iso:editorialgroup/iso:secretariat)"/>
		<xsl:if test="$value != ''">
			<xsl:call-template name="getLocalizedString">
				<xsl:with-param name="key">secretariat</xsl:with-param>
			</xsl:call-template>
			<xsl:text>: </xsl:text>
			<fo:inline font-weight="bold"><xsl:value-of select="$value"/></fo:inline>
		</xsl:if>
	</xsl:variable>
	<xsl:variable name="secretariat" select="xalan:nodeset($secretariat_)"/>
	
	<xsl:variable name="ics_">
		<xsl:for-each select="/iso:iso-standard/iso:bibdata/iso:ext/iso:ics/iso:code">
			<xsl:if test="position() = 1"><fo:inline>ICS: </fo:inline></xsl:if>
			<xsl:value-of select="."/>
			<xsl:if test="position() != last()"><xsl:text>; </xsl:text></xsl:if>
		</xsl:for-each>
	</xsl:variable>
	<xsl:variable name="ics" select="xalan:nodeset($ics_)"/>
	
	<xsl:variable name="XML" select="/"/>
	
	<xsl:template match="/">
		<xsl:call-template name="namespaceCheck"/>
		<fo:root xml:lang="{$lang}">
			
			<xsl:variable name="root-style">
				<root-style xsl:use-attribute-sets="root-style">
					<!-- <xsl:if test="$lang = 'zh'">
						<xsl:attribute name="font-family">Source Han Sans, Times New Roman, Cambria Math</xsl:attribute>
					</xsl:if> -->
				</root-style>
			</xsl:variable>
			<xsl:call-template name="insertRootStyle">
				<xsl:with-param name="root-style" select="$root-style"/>
			</xsl:call-template>
			
			<fo:layout-master-set>
				
				<!-- cover page -->
				<fo:simple-page-master master-name="cover-page" page-width="{$pageWidth}mm" page-height="{$pageHeight}mm">
					<fo:region-body margin-top="25.4mm" margin-bottom="25.4mm" margin-left="31.7mm" margin-right="31.7mm"/>
					<fo:region-before region-name="cover-page-header" extent="25.4mm"/>
					<fo:region-after/>
					<fo:region-start region-name="cover-left-region" extent="31.7mm"/>
					<fo:region-end region-name="cover-right-region" extent="31.7mm"/>
				</fo:simple-page-master>
				
				<fo:simple-page-master master-name="cover-page-published" page-width="{$pageWidth}mm" page-height="{$pageHeight}mm">
					<fo:region-body margin-top="12.7mm" margin-bottom="75mm" margin-left="78mm" margin-right="18.5mm"/>
					<fo:region-before region-name="cover-page-header" extent="12.7mm"/>
					<fo:region-after region-name="cover-page-footer" extent="75mm" display-align="after"/>
					<fo:region-start region-name="cover-left-region" extent="78mm"/>
					<fo:region-end region-name="cover-right-region" extent="18.5mm"/>
				</fo:simple-page-master>
				
				
				<fo:simple-page-master master-name="cover-page-publishedISO-odd" page-width="{$pageWidth}mm" page-height="{$pageHeight}mm">
					<fo:region-body margin-top="12.7mm" margin-bottom="75mm" margin-left="{$marginLeftRight1}mm" margin-right="{$marginLeftRight2}mm"/>
					<fo:region-before region-name="cover-page-header" extent="12.7mm"/>
					<fo:region-after region-name="cover-page-footer" extent="75mm" display-align="after"/>
					<fo:region-start region-name="cover-left-region" extent="{$marginLeftRight1}mm"/>
					<fo:region-end region-name="cover-right-region" extent="{$marginLeftRight2}mm"/>
				</fo:simple-page-master>
				<fo:simple-page-master master-name="cover-page-publishedISO-even" page-width="{$pageWidth}mm" page-height="{$pageHeight}mm">
					<fo:region-body margin-top="12.7mm" margin-bottom="75mm" margin-left="{$marginLeftRight2}mm" margin-right="{$marginLeftRight1}mm"/>
					<fo:region-before region-name="cover-page-header" extent="12.7mm"/>
					<fo:region-after region-name="cover-page-footer" extent="75mm" display-align="after"/>
					<fo:region-start region-name="cover-left-region" extent="{$marginLeftRight2}mm"/>
					<fo:region-end region-name="cover-right-region" extent="{$marginLeftRight1}mm"/>
				</fo:simple-page-master>
				<fo:page-sequence-master master-name="cover-page-publishedISO">
					<fo:repeatable-page-master-alternatives>
						<fo:conditional-page-master-reference odd-or-even="even" master-reference="cover-page-publishedISO-even"/>
						<fo:conditional-page-master-reference odd-or-even="odd" master-reference="cover-page-publishedISO-odd"/>
					</fo:repeatable-page-master-alternatives>
				</fo:page-sequence-master>


				<!-- contents pages -->
				<!-- odd pages -->
				<fo:simple-page-master master-name="odd" page-width="{$pageWidth}mm" page-height="{$pageHeight}mm">
					<fo:region-body margin-top="27.4mm" margin-bottom="{$marginBottom + 2}mm" margin-left="19mm" margin-right="19mm"/>
					<fo:region-before region-name="header-odd" extent="27.4mm"/> <!--   display-align="center" -->
					<fo:region-after region-name="footer-odd" extent="{$marginBottom}mm"/>
					<fo:region-start region-name="left-region" extent="19mm"/>
					<fo:region-end region-name="right-region" extent="19mm"/>
				</fo:simple-page-master>
				<!-- even pages -->
				<fo:simple-page-master master-name="even" page-width="{$pageWidth}mm" page-height="{$pageHeight}mm">
					<fo:region-body margin-top="27.4mm" margin-bottom="{$marginBottom + 2}mm" margin-left="19mm" margin-right="19mm"/>
					<fo:region-before region-name="header-even" extent="27.4mm"/> <!--   display-align="center" -->
					<fo:region-after region-name="footer-even" extent="{$marginBottom}mm"/>
					<fo:region-start region-name="left-region" extent="19mm"/>
					<fo:region-end region-name="right-region" extent="19mm"/>
				</fo:simple-page-master>
				<fo:page-sequence-master master-name="preface">
					<fo:repeatable-page-master-alternatives>
						<fo:conditional-page-master-reference odd-or-even="even" master-reference="even"/>
						<fo:conditional-page-master-reference odd-or-even="odd" master-reference="odd"/>
					</fo:repeatable-page-master-alternatives>
				</fo:page-sequence-master>
				<fo:page-sequence-master master-name="document">
					<fo:repeatable-page-master-alternatives>
						<fo:conditional-page-master-reference odd-or-even="even" master-reference="even"/>
						<fo:conditional-page-master-reference odd-or-even="odd" master-reference="odd"/>
					</fo:repeatable-page-master-alternatives>
				</fo:page-sequence-master>
				
				
				<!-- first page -->
				<fo:simple-page-master master-name="first-publishedISO" page-width="{$pageWidth}mm" page-height="{$pageHeight}mm">
					<fo:region-body margin-top="{$marginTop}mm" margin-bottom="{$marginBottom + 2}mm" margin-left="{$marginLeftRight1}mm" margin-right="{$marginLeftRight2}mm"/>
					<fo:region-before region-name="header-first" extent="{$marginTop}mm"/> <!--   display-align="center" -->
					<fo:region-after region-name="footer-odd" extent="{$marginBottom}mm"/>
					<fo:region-start region-name="left-region" extent="{$marginLeftRight1}mm"/>
					<fo:region-end region-name="right-region" extent="{$marginLeftRight2}mm"/>
				</fo:simple-page-master>
				<!-- odd pages -->
				<fo:simple-page-master master-name="odd-publishedISO" page-width="{$pageWidth}mm" page-height="{$pageHeight}mm">
					<fo:region-body margin-top="{$marginTop}mm" margin-bottom="{$marginBottom + 2}mm" margin-left="{$marginLeftRight1}mm" margin-right="{$marginLeftRight2}mm"/>
					<fo:region-before region-name="header-odd" extent="{$marginTop}mm"/> <!--   display-align="center" -->
					<fo:region-after region-name="footer-odd" extent="{$marginBottom}mm"/>
					<fo:region-start region-name="left-region" extent="{$marginLeftRight1}mm"/>
					<fo:region-end region-name="right-region" extent="{$marginLeftRight2}mm"/>
				</fo:simple-page-master>
				<!-- even pages -->
				<fo:simple-page-master master-name="even-publishedISO" page-width="{$pageWidth}mm" page-height="{$pageHeight}mm">
					<fo:region-body margin-top="{$marginTop}mm" margin-bottom="{$marginBottom + 2}mm" margin-left="{$marginLeftRight2}mm" margin-right="{$marginLeftRight1}mm"/>
					<fo:region-before region-name="header-even" extent="{$marginTop}mm"/>
					<fo:region-after region-name="footer-even" extent="{$marginBottom}mm"/>
					<fo:region-start region-name="left-region" extent="{$marginLeftRight2}mm"/>
					<fo:region-end region-name="right-region" extent="{$marginLeftRight1}mm"/>
				</fo:simple-page-master>
				<fo:simple-page-master master-name="blankpage" page-width="{$pageWidth}mm" page-height="{$pageHeight}mm">
					<fo:region-body margin-top="{$marginTop}mm" margin-bottom="{$marginBottom + 2}mm" margin-left="{$marginLeftRight2}mm" margin-right="{$marginLeftRight1}mm"/>
					<fo:region-before region-name="header" extent="{$marginTop}mm"/>
					<fo:region-after region-name="footer" extent="{$marginBottom}mm"/>
					<fo:region-start region-name="left" extent="{$marginLeftRight2}mm"/>
					<fo:region-end region-name="right" extent="{$marginLeftRight1}mm"/>
				</fo:simple-page-master>
				<fo:page-sequence-master master-name="preface-publishedISO">
					<fo:repeatable-page-master-alternatives>
						<fo:conditional-page-master-reference master-reference="blankpage" blank-or-not-blank="blank"/>
						<fo:conditional-page-master-reference odd-or-even="even" master-reference="even-publishedISO"/>
						<fo:conditional-page-master-reference odd-or-even="odd" master-reference="odd-publishedISO"/>
					</fo:repeatable-page-master-alternatives>
				</fo:page-sequence-master>
				
				
				<fo:page-sequence-master master-name="document-publishedISO">
					<fo:repeatable-page-master-alternatives>
						<fo:conditional-page-master-reference master-reference="first-publishedISO" page-position="first"/>
						<fo:conditional-page-master-reference odd-or-even="even" master-reference="even-publishedISO"/>
						<fo:conditional-page-master-reference odd-or-even="odd" master-reference="odd-publishedISO"/>
					</fo:repeatable-page-master-alternatives>
				</fo:page-sequence-master>
				
				<fo:simple-page-master master-name="last-page" page-width="{$pageWidth}mm" page-height="{$pageHeight}mm">
					<fo:region-body margin-top="{$marginTop}mm" margin-bottom="{$marginBottom}mm" margin-left="{$marginLeftRight2}mm" margin-right="{$marginLeftRight1}mm"/>
					<fo:region-before region-name="header-even" extent="{$marginTop}mm"/>
					<fo:region-after region-name="last-page-footer" extent="{$marginBottom}mm"/>
					<fo:region-start region-name="left-region" extent="{$marginLeftRight2}mm"/>
					<fo:region-end region-name="right-region" extent="{$marginLeftRight1}mm"/>
				</fo:simple-page-master>
				
				<!-- Index pages -->
				<fo:simple-page-master master-name="index-odd" page-width="{$pageWidth}mm" page-height="{$pageHeight}mm">
					<fo:region-body margin-top="{$marginTop}mm" margin-bottom="{$marginBottom}mm" margin-left="{$marginLeftRight1}mm" margin-right="{$marginLeftRight2}mm" column-count="2" column-gap="10mm"/>
					<fo:region-before region-name="header-odd" extent="{$marginTop}mm"/>
					<fo:region-after region-name="footer-odd" extent="{$marginBottom}mm"/>
					<fo:region-start region-name="left-region" extent="{$marginLeftRight1}mm"/>
					<fo:region-end region-name="right-region" extent="{$marginLeftRight2}mm"/>
				</fo:simple-page-master>
				<fo:simple-page-master master-name="index-even" page-width="{$pageWidth}mm" page-height="{$pageHeight}mm">
					<fo:region-body margin-top="{$marginTop}mm" margin-bottom="{$marginBottom}mm" margin-left="{$marginLeftRight2}mm" margin-right="{$marginLeftRight1}mm" column-count="2" column-gap="10mm"/>
					<fo:region-before region-name="header-even" extent="{$marginTop}mm"/>
					<fo:region-after region-name="footer-even" extent="{$marginBottom}mm"/>
					<fo:region-start region-name="left-region" extent="{$marginLeftRight2}mm"/>
					<fo:region-end region-name="right-region" extent="{$marginLeftRight1}mm"/>
				</fo:simple-page-master>
				<fo:page-sequence-master master-name="index">
					<fo:repeatable-page-master-alternatives>						
						<fo:conditional-page-master-reference odd-or-even="even" master-reference="index-even"/>
						<fo:conditional-page-master-reference odd-or-even="odd" master-reference="index-odd"/>
					</fo:repeatable-page-master-alternatives>
				</fo:page-sequence-master>
				
				
			</fo:layout-master-set>
			
			<fo:declarations>
				<xsl:call-template name="addPDFUAmeta"/>
				<xsl:for-each select="//*[local-name() = 'eref'][generate-id(.)=generate-id(key('attachments',@bibitemid)[1])]">
					<xsl:variable name="url" select="concat('url(file:',$basepath, @bibitemid, ')')"/>
					<pdf:embedded-file src="{$url}" filename="{@bibitemid}"/>
				</xsl:for-each>
			</fo:declarations>

			
			
			<xsl:call-template name="addBookmarks">
				<xsl:with-param name="contents" select="$contents"/>
			</xsl:call-template>
			
			<!-- cover page -->
			<xsl:choose>
				<xsl:when test="$stage-abbreviation != ''">
					<fo:page-sequence master-reference="cover-page-publishedISO" force-page-count="no-force">
						<fo:static-content flow-name="cover-page-footer" font-size="10pt">
							<fo:table table-layout="fixed" width="100%">
								<fo:table-column column-width="52mm"/>
								<fo:table-column column-width="7.5mm"/>
								<fo:table-column column-width="112.5mm"/>
								<fo:table-body>
									<fo:table-row>
										<fo:table-cell font-size="6.5pt" text-align="justify" display-align="after" padding-bottom="8mm">
											<!-- margin-top="-30mm"  -->
											<fo:block> <!-- margin-top="-100mm" -->
												<xsl:if test="$stage-abbreviation = 'DIS' or                       $stage-abbreviation = 'NWIP' or                       $stage-abbreviation = 'NP' or                       $stage-abbreviation = 'PWI' or                       $stage-abbreviation = 'AWI' or                       $stage-abbreviation = 'WD' or                       $stage-abbreviation = 'CD'">
													<fo:block margin-bottom="1.5mm">
														<xsl:text>THIS DOCUMENT IS A DRAFT CIRCULATED FOR COMMENT AND APPROVAL. IT IS THEREFORE SUBJECT TO CHANGE AND MAY NOT BE REFERRED TO AS AN INTERNATIONAL STANDARD UNTIL PUBLISHED AS SUCH.</xsl:text>
													</fo:block>
												</xsl:if>
												<xsl:if test="$stage-abbreviation = 'FDIS' or                       $stage-abbreviation = 'DIS' or                       $stage-abbreviation = 'NWIP' or                       $stage-abbreviation = 'NP' or                       $stage-abbreviation = 'PWI' or                       $stage-abbreviation = 'AWI' or                       $stage-abbreviation = 'WD' or                       $stage-abbreviation = 'CD'">
													<fo:block margin-bottom="1.5mm">
														<xsl:text>RECIPIENTS OF THIS DRAFT ARE INVITED TO
																			SUBMIT, WITH THEIR COMMENTS, NOTIFICATION
																			OF ANY RELEVANT PATENT RIGHTS OF WHICH
																			THEY ARE AWARE AND TO PROVIDE SUPPORTING
																			DOCUMENTATION.</xsl:text>
													</fo:block>
													<fo:block>
														<xsl:text>IN ADDITION TO THEIR EVALUATION AS
																BEING ACCEPTABLE FOR INDUSTRIAL, TECHNOLOGICAL,
																COMMERCIAL AND USER PURPOSES,
																DRAFT INTERNATIONAL STANDARDS MAY ON
																OCCASION HAVE TO BE CONSIDERED IN THE
																LIGHT OF THEIR POTENTIAL TO BECOME STANDARDS
																TO WHICH REFERENCE MAY BE MADE IN
																NATIONAL REGULATIONS.</xsl:text>
													</fo:block>
												</xsl:if>
											</fo:block>
										</fo:table-cell>
										<fo:table-cell>
											<fo:block> </fo:block>
										</fo:table-cell>
										<fo:table-cell display-align="after" padding-bottom="3mm">
											<fo:block-container height="22.5mm" display-align="center">
											
												<xsl:variable name="iso-fast-track">false</xsl:variable>
												
												<xsl:if test="normalize-space($iso-fast-track) = 'true'">
													<xsl:attribute name="height">28mm</xsl:attribute>
												</xsl:if>
												
												<fo:block>
													<xsl:if test="$stage-abbreviation = 'NWIP' or $stage-abbreviation = 'NP' or $stage-abbreviation = 'PWI' or $stage-abbreviation = 'AWI' or $stage-abbreviation = 'WD' or $stage-abbreviation = 'CD' or $stage-abbreviation = 'DIS' or $stage-abbreviation = 'FDIS'">
														<xsl:variable name="text">
															<xsl:for-each select="/iso:iso-standard/iso:preface/iso:note[@coverpage='true']/iso:p">
																<fo:block>
																	<xsl:apply-templates/>
																</fo:block>
															</xsl:for-each>
														</xsl:variable>
														<xsl:if test="normalize-space($text) != ''">
															<fo:block-container margin-left="1mm"> <!-- margin-bottom="7mm" margin-top="-15mm" -->
																<fo:block font-size="9pt" border="0.5pt solid black" fox:border-radius="5pt" padding-left="2mm" padding-top="2mm" padding-bottom="2mm">
																	<!-- <xsl:text>This document is circulated as received from the committee secretariat.</xsl:text> -->
																	<xsl:copy-of select="xalan:nodeset($text)/node()"/>
																</fo:block>
															</fo:block-container>
														</xsl:if>
														
														<xsl:if test="normalize-space($iso-fast-track) = 'true'">
															<fo:block-container space-before="2mm">
																<fo:block background-color="rgb(77,77,77)" color="white" fox:border-radius="5pt" text-align="center" display-align="center" font-size="19pt" font-weight="bold">
																	<fo:block-container height="13.2mm">
																		<fo:block>
																			<xsl:text>FAST TRACK PROCEDURE</xsl:text>
																		</fo:block>
																	</fo:block-container>
																</fo:block>
															</fo:block-container>
														</xsl:if>
													</xsl:if>
												</fo:block>
											</fo:block-container>
											<fo:block>
												<xsl:call-template name="insertTripleLine"/>
												<fo:table table-layout="fixed" width="100%"> <!-- margin-bottom="3mm" -->
													<fo:table-column column-width="50%"/>
													<fo:table-column column-width="50%"/>
													<fo:table-body>
														<fo:table-row height="34mm">
															<fo:table-cell display-align="center">
															
																<xsl:if test="$copyrightAbbrIEEE != ''">
																	<xsl:attribute name="display-align">before</xsl:attribute>
																</xsl:if>
																
																<fo:block text-align="left" margin-top="2mm">
																	
																	<xsl:if test="$copyrightAbbrIEEE != ''">
																		<xsl:attribute name="margin-top">0</xsl:attribute>
																	</xsl:if>
																
																	<!-- <xsl:variable name="docid" select="substring-before(/iso:iso-standard/iso:bibdata/iso:docidentifier, ' ')"/>
																	<xsl:for-each select="xalan:tokenize($docid, '/')"> -->
																	<xsl:variable name="content-height">
																		<xsl:choose>
																			<xsl:when test="$copyrightAbbrIEEE != ''">13.9</xsl:when>
																			<xsl:otherwise>19</xsl:otherwise>
																		</xsl:choose>
																	</xsl:variable>
																	
																	<xsl:for-each select="/iso:iso-standard/iso:bibdata/iso:copyright/iso:owner/iso:organization/iso:abbreviation[. != 'IEEE']">
																		<xsl:choose>
																			<xsl:when test=". = 'ISO'">
																				<fo:external-graphic src="{concat('data:image/png;base64,', normalize-space($Image-ISO-Logo))}" content-height="{$content-height}mm" content-width="scale-to-fit" scaling="uniform" fox:alt-text="Image {@alt}"/>
																			</xsl:when>
																			<xsl:when test=". = 'IEC'">
																				<fo:external-graphic src="{concat('data:image/png;base64,', normalize-space($Image-IEC-Logo))}" content-height="{$content-height}mm" content-width="scale-to-fit" scaling="uniform" fox:alt-text="Image {@alt}"/>
																			</xsl:when>
																			<xsl:otherwise/>
																		</xsl:choose>
																		<xsl:if test="position() != last()">
																			<fo:inline padding-right="1mm"> </fo:inline>
																		</xsl:if>
																	</xsl:for-each>
																	<xsl:if test="$copyrightAbbrIEEE != ''">
																		<fo:block>
																			<fo:external-graphic src="{concat('data:image/png;base64,', normalize-space($Image-IEEE-Logo))}" content-height="11mm" content-width="scale-to-fit" scaling="uniform" fox:alt-text="Image {@alt}"/>
																		</fo:block>
																	</xsl:if>
																</fo:block>
															</fo:table-cell>
															<fo:table-cell display-align="center">
																<fo:block text-align="right">																	
																	<!-- Reference number -->
																	<fo:block>
																		<xsl:call-template name="getLocalizedString">
																			<xsl:with-param name="key">reference_number</xsl:with-param>
																		</xsl:call-template>
																	</fo:block>
																	<fo:block>
																		<xsl:value-of select="$ISOname"/>																		
																	</fo:block>
																	<fo:block space-before="28pt">
																		<xsl:if test="$copyrightAbbrIEEE != ''">
																			<xsl:attribute name="space-before">14pt</xsl:attribute>
																		</xsl:if>
																		<fo:inline font-size="9pt">©</fo:inline><xsl:value-of select="concat(' ', $copyrightAbbr, ' ', $copyrightYear)"/>
																		<xsl:if test="$copyrightAbbrIEEE != ''">
																			<xsl:value-of select="$linebreak"/>
																			<fo:inline font-size="9pt">©</fo:inline>
																			<xsl:value-of select="concat(' ', $copyrightAbbrIEEE, ' ', $copyrightYear)"/>
																		</xsl:if>
																	</fo:block>
																</fo:block>
															</fo:table-cell>
														</fo:table-row>
													</fo:table-body>
												</fo:table>
											</fo:block>
										</fo:table-cell>
									</fo:table-row>
								</fo:table-body>
							</fo:table>
						</fo:static-content>
						
						<xsl:choose>
							<!-- COVER PAGE for DIS document only -->
							<xsl:when test="$stage-abbreviation = 'DIS'">
								<fo:flow flow-name="xsl-region-body">
									<fo:block-container>
										<fo:block margin-top="-1mm" font-size="20pt" text-align="right">
											<xsl:value-of select="$stage-fullname-uppercased"/>
										</fo:block>
										<fo:block font-size="20pt" font-weight="bold" text-align="right">
											<xsl:value-of select="$docidentifierISO"/>
										</fo:block>
										
										
										<fo:table table-layout="fixed" width="100%" margin-top="18mm">
											<fo:table-column column-width="59.5mm"/>
											<fo:table-column column-width="52mm"/>
											<fo:table-column column-width="59mm"/>
											<fo:table-body>
												<fo:table-row>
													<fo:table-cell>
														<fo:block> </fo:block>
													</fo:table-cell>
													<fo:table-cell>
														<fo:block margin-bottom="3mm">
															<xsl:copy-of select="$editorialgroup"/>
														</fo:block>
													</fo:table-cell>
													<fo:table-cell>
														<fo:block>
															<xsl:copy-of select="$secretariat"/>
														</fo:block>
													</fo:table-cell>
												</fo:table-row>
												<fo:table-row>
													<fo:table-cell>
														<fo:block> </fo:block>
													</fo:table-cell>
													<fo:table-cell>
														<fo:block>Voting begins on:</fo:block>
													</fo:table-cell>
													<fo:table-cell>
														<fo:block>Voting terminates on:</fo:block>
													</fo:table-cell>
												</fo:table-row>
												<fo:table-row>
													<fo:table-cell>
														<fo:block> </fo:block>
													</fo:table-cell>
													<fo:table-cell>
														<fo:block font-weight="bold">
															<xsl:choose>
																<xsl:when test="/iso:iso-standard/iso:bibdata/iso:date[@type = 'vote-started']/iso:on">
																	<xsl:value-of select="/iso:iso-standard/iso:bibdata/iso:date[@type = 'vote-started']/iso:on"/>
																</xsl:when>
																<xsl:otherwise>YYYY-MM-DD</xsl:otherwise>
															</xsl:choose>
														</fo:block>
													</fo:table-cell>
													<fo:table-cell>
														<fo:block font-weight="bold">
															<xsl:choose>
																<xsl:when test="/iso:iso-standard/iso:bibdata/iso:date[@type = 'vote-ended']/iso:on">
																	<xsl:value-of select="/iso:iso-standard/iso:bibdata/iso:date[@type = 'vote-ended']/iso:on"/>
																</xsl:when>
																<xsl:otherwise>YYYY-MM-DD</xsl:otherwise>
															</xsl:choose>
														</fo:block>
													</fo:table-cell>
												</fo:table-row>
											</fo:table-body>
										</fo:table>
										
										<fo:block-container line-height="1.1" margin-top="3mm">
											<xsl:call-template name="insertTripleLine"/>
											<fo:block margin-right="5mm">
												<fo:block font-size="18pt" font-weight="bold" margin-top="6pt" role="H1">
												
													<xsl:apply-templates select="/iso:iso-standard/iso:bibdata/iso:title[@language = $lang and @type = 'title-intro']"/>
																	
													<xsl:apply-templates select="/iso:iso-standard/iso:bibdata/iso:title[@language = $lang and @type = 'title-main']"/>
													
													<xsl:apply-templates select="/iso:iso-standard/iso:bibdata/iso:title[@language = $lang and @type = 'title-part']">
														<xsl:with-param name="isMainLang">true</xsl:with-param>
													</xsl:apply-templates>
													
													<xsl:apply-templates select="/iso:iso-standard/iso:bibdata/iso:title[@language = $lang and @type = 'title-amd']">
														<xsl:with-param name="isMainLang">true</xsl:with-param>
													</xsl:apply-templates>
												
												</fo:block>
												
												
												<xsl:for-each select="xalan:nodeset($lang_other)/lang">
													<xsl:variable name="lang_other" select="."/>
												
													<fo:block font-size="12pt"><xsl:value-of select="$linebreak"/></fo:block>
													<fo:block font-size="11pt" font-style="italic" line-height="1.1" role="H1">
														
														<!-- Example: title-intro fr -->
														<xsl:apply-templates select="$XML/iso:iso-standard/iso:bibdata/iso:title[@language = $lang_other and @type = 'title-intro']"/>
														
														<xsl:apply-templates select="$XML/iso:iso-standard/iso:bibdata/iso:title[@language = $lang_other and @type = 'title-main']"/>
														
														<xsl:apply-templates select="$XML/iso:iso-standard/iso:bibdata/iso:title[@language = $lang_other and @type = 'title-part']">
															<xsl:with-param name="curr_lang" select="$lang_other"/>
														</xsl:apply-templates>
														
														<xsl:apply-templates select="$XML/iso:iso-standard/iso:bibdata/iso:title[@language = $lang_other and @type = 'title-amd']">
															<xsl:with-param name="curr_lang" select="$lang_other"/>
														</xsl:apply-templates>
														
													</fo:block>
												</xsl:for-each>
											</fo:block>
											
											<fo:block margin-top="10mm">
												<xsl:copy-of select="$ics"/>
											</fo:block>
											
										</fo:block-container>
										
										
									</fo:block-container>
								</fo:flow>
							
							</xsl:when> <!-- END: $stage-abbreviation = 'DIS' -->
							<xsl:otherwise>
						
								<!-- COVER PAGE  for all documents except DIS -->
								<fo:flow flow-name="xsl-region-body">
									<fo:block-container>
										<fo:table table-layout="fixed" width="100%" font-size="24pt" line-height="1"> <!-- margin-bottom="35mm" -->
											<fo:table-column column-width="59.5mm"/>
											<fo:table-column column-width="67.5mm"/>
											<fo:table-column column-width="45.5mm"/>
											<fo:table-body>
												<fo:table-row>
													<fo:table-cell>
														<fo:block font-size="18pt">
															
															<xsl:value-of select="translate($stagename-header-coverpage, ' ', $linebreak)"/>
															
															<!-- if there is iteration number, then print it -->
															<xsl:variable name="iteration" select="number(/iso:iso-standard/iso:bibdata/iso:status/iso:iteration)"/>	
															
															<xsl:if test="number($iteration) = $iteration and                                         ($stage-abbreviation = 'NWIP' or                                         $stage-abbreviation = 'NP' or                                         $stage-abbreviation = 'PWI' or                                         $stage-abbreviation = 'AWI' or                                         $stage-abbreviation = 'WD' or                                         $stage-abbreviation = 'CD')">
																<xsl:text> </xsl:text><xsl:value-of select="$iteration"/>
															</xsl:if>
															<!-- <xsl:if test="$stage-name = 'draft'">DRAFT</xsl:if>
															<xsl:if test="$stage-name = 'final-draft'">FINAL<xsl:value-of select="$linebreak"/>DRAFT</xsl:if> -->
														</fo:block>
													</fo:table-cell>
													
													<xsl:variable name="lastWord">
														<xsl:call-template name="substring-after-last">
															<xsl:with-param name="value" select="$doctype_uppercased"/>
															<xsl:with-param name="delimiter" select="' '"/>
														</xsl:call-template>
													</xsl:variable>
													<xsl:variable name="font-size"><xsl:if test="string-length($lastWord) &gt;= 12">90%</xsl:if></xsl:variable> <!-- to prevent overlapping 'NORME INTERNATIONALE' to number -->
													
													<fo:table-cell>
														<fo:block text-align="left">
															<xsl:choose>
																<xsl:when test="$doctype = 'amendment'">
																	<xsl:value-of select="java:toUpperCase(java:java.lang.String.new(translate(/iso:iso-standard/iso:bibdata/iso:ext/iso:updates-document-type,'-',' ')))"/>
																</xsl:when>
																<xsl:otherwise>
																	<xsl:if test="$font-size != ''">
																		<xsl:attribute name="font-size"><xsl:value-of select="$font-size"/></xsl:attribute>
																	</xsl:if>
																	<xsl:value-of select="$doctype_uppercased"/>
																</xsl:otherwise>
															</xsl:choose>
														</fo:block>
													</fo:table-cell>
													<fo:table-cell>
														<fo:block text-align="right" font-weight="bold" margin-bottom="13mm">
															<xsl:if test="$font-size != ''">
																<xsl:attribute name="font-size"><xsl:value-of select="$font-size"/></xsl:attribute>
															</xsl:if>
															<xsl:value-of select="$docidentifierISO"/>
														</fo:block>
													</fo:table-cell>
												</fo:table-row>
												<fo:table-row height="25mm">
													<fo:table-cell number-columns-spanned="3" font-size="10pt" line-height="1.2">
														<fo:block text-align="right">
															<xsl:if test="$stage-abbreviation = 'PRF' or                          $stage-abbreviation = 'IS' or                          $stage-abbreviation = 'D' or                          $stage-abbreviation = 'published'">
																<xsl:call-template name="printEdition"/>
															</xsl:if>
															<xsl:choose>
																<xsl:when test="($stage-abbreviation = 'NWIP' or $stage-abbreviation = 'NP' or $stage-abbreviation = 'PWI' or $stage-abbreviation = 'AWI' or $stage-abbreviation = 'WD' or $stage-abbreviation = 'CD' or $stage-abbreviation = 'FDIS') and /iso:iso-standard/iso:bibdata/iso:version/iso:revision-date">
																	<xsl:value-of select="$linebreak"/>
																	<xsl:value-of select="/iso:iso-standard/iso:bibdata/iso:version/iso:revision-date"/>
																</xsl:when>
																<xsl:when test="$stage-abbreviation = 'IS' and /iso:iso-standard/iso:bibdata/iso:date[@type = 'published']">
																	<xsl:value-of select="$linebreak"/>
																	<xsl:value-of select="/iso:iso-standard/iso:bibdata/iso:date[@type = 'published']"/>
																</xsl:when>
																<xsl:when test="($stage-abbreviation = 'IS' or $stage-abbreviation = 'D') and /iso:iso-standard/iso:bibdata/iso:date[@type = 'created']">
																	<xsl:value-of select="$linebreak"/>
																	<xsl:value-of select="/iso:iso-standard/iso:bibdata/iso:date[@type = 'created']"/>
																</xsl:when>
																<xsl:when test="$stage-abbreviation = 'IS' or $stage-abbreviation = 'published'">
																	<xsl:value-of select="$linebreak"/>
																	<xsl:value-of select="substring(/iso:iso-standard/iso:bibdata/iso:version/iso:revision-date,1, 7)"/>
																</xsl:when>
															</xsl:choose>
														</fo:block>
														<!-- <xsl:value-of select="$linebreak"/>
														<xsl:value-of select="/iso:iso-standard/iso:bibdata/iso:version/iso:revision-date"/> -->
														<xsl:if test="$doctype = 'amendment'">
															<fo:block text-align="right" margin-right="0.5mm">
																<fo:block font-weight="bold" margin-top="4pt" role="H1">
																	<xsl:value-of select="$doctype_uppercased"/>
																	<xsl:text> </xsl:text>
																	<xsl:variable name="amendment-number" select="/iso:iso-standard/iso:bibdata/iso:ext/iso:structuredidentifier/iso:project-number/@amendment"/>
																	<xsl:if test="normalize-space($amendment-number) != ''">
																		<xsl:value-of select="$amendment-number"/><xsl:text> </xsl:text>
																	</xsl:if>
																</fo:block>
																<fo:block>
																	<xsl:if test="/iso:iso-standard/iso:bibdata/iso:date[@type = 'updated']">																		
																		<xsl:value-of select="/iso:iso-standard/iso:bibdata/iso:date[@type = 'updated']"/>
																	</xsl:if>
																</fo:block>
															</fo:block>
														</xsl:if>
													</fo:table-cell>
												</fo:table-row>
												<fo:table-row height="17mm">
													<fo:table-cell><fo:block/></fo:table-cell>
													<fo:table-cell number-columns-spanned="2" font-size="10pt" line-height="1.2" display-align="center">
														<fo:block>
															<xsl:if test="$stage-abbreviation = 'NWIP' or $stage-abbreviation = 'NP' or $stage-abbreviation = 'PWI' or $stage-abbreviation = 'AWI' or $stage-abbreviation = 'WD' or $stage-abbreviation = 'CD' or $stage-abbreviation = 'FDIS'">
																<fo:table table-layout="fixed" width="100%">
																	<fo:table-column column-width="50%"/>
																	<fo:table-column column-width="50%"/>
																	<fo:table-body>
																		<fo:table-row>
																			<fo:table-cell>
																				<fo:block>
																					<xsl:copy-of select="$editorialgroup"/>
																				</fo:block>
																			</fo:table-cell>
																			<fo:table-cell>
																				<fo:block>
																					<xsl:copy-of select="$secretariat"/>
																				</fo:block>
																			</fo:table-cell>
																		</fo:table-row>
																	</fo:table-body>
																</fo:table>
															</xsl:if>
														</fo:block>
													</fo:table-cell>
												</fo:table-row>
												
											</fo:table-body>
										</fo:table>
										
										
										<fo:table table-layout="fixed" width="100%">
											<fo:table-column column-width="52mm"/>
											<fo:table-column column-width="7.5mm"/>
											<fo:table-column column-width="112.5mm"/>
											<fo:table-body>
												<fo:table-row> <!--  border="1pt solid black" height="150mm"  -->
													<fo:table-cell font-size="11pt">
														<fo:block>
															<xsl:if test="$stage-abbreviation = 'FDIS'">
																<fo:block-container border="0.5mm solid black" width="51mm">
																	<fo:block margin="2mm">
																			<fo:block margin-bottom="8pt"><xsl:copy-of select="$editorialgroup"/></fo:block>
																			<fo:block margin-bottom="6pt"><xsl:value-of select="$secretariat"/></fo:block>
																			<fo:block margin-bottom="6pt">Voting begins on:<xsl:value-of select="$linebreak"/>
																				<fo:inline font-weight="bold">
																					<xsl:choose>
																						<xsl:when test="/iso:iso-standard/iso:bibdata/iso:date[@type = 'vote-started']/iso:on">
																							<xsl:value-of select="/iso:iso-standard/iso:bibdata/iso:date[@type = 'vote-started']/iso:on"/>
																						</xsl:when>
																						<xsl:otherwise>YYYY-MM-DD</xsl:otherwise>
																					</xsl:choose>
																				</fo:inline>
																			</fo:block>
																			<fo:block>Voting terminates on:<xsl:value-of select="$linebreak"/>
																				<fo:inline font-weight="bold">
																					<xsl:choose>
																						<xsl:when test="/iso:iso-standard/iso:bibdata/iso:date[@type = 'vote-ended']/iso:on">
																							<xsl:value-of select="/iso:iso-standard/iso:bibdata/iso:date[@type = 'vote-ended']/iso:on"/>
																						</xsl:when>
																						<xsl:otherwise>YYYY-MM-DD</xsl:otherwise>
																					</xsl:choose>
																				</fo:inline>
																			</fo:block>
																	</fo:block>
																</fo:block-container>
															</xsl:if>
														</fo:block>
													</fo:table-cell>
													<fo:table-cell>
														<fo:block> </fo:block>
													</fo:table-cell>
													<fo:table-cell>
														<xsl:call-template name="insertTripleLine"/>
														<fo:block-container line-height="1.1">
															<fo:block margin-right="5mm">
																<fo:block font-size="18pt" font-weight="bold" margin-top="12pt" role="H1">
																	
																	<xsl:apply-templates select="/iso:iso-standard/iso:bibdata/iso:title[@language = $lang and @type = 'title-intro']"/>
																	
																	<xsl:apply-templates select="/iso:iso-standard/iso:bibdata/iso:title[@language = $lang and @type = 'title-main']"/>
																	
																	<xsl:apply-templates select="/iso:iso-standard/iso:bibdata/iso:title[@language = $lang and @type = 'title-part']">
																		<xsl:with-param name="isMainLang">true</xsl:with-param>
																	</xsl:apply-templates>
																	
																	<xsl:apply-templates select="/iso:iso-standard/iso:bibdata/iso:title[@language = $lang and @type = 'title-amd']">
																		<xsl:with-param name="isMainLang">true</xsl:with-param>
																	</xsl:apply-templates>
																	
																</fo:block>
																			
																
																<xsl:for-each select="xalan:nodeset($lang_other)/lang">
																	<xsl:variable name="lang_other" select="."/>
																	
																	<fo:block font-size="12pt"><xsl:value-of select="$linebreak"/></fo:block>
																	<fo:block font-size="11pt" font-style="italic" line-height="1.1" role="H1">
																		
																		<!-- Example: title-intro fr -->
																		<xsl:apply-templates select="$XML/iso:iso-standard/iso:bibdata/iso:title[@language = $lang_other and @type = 'title-intro']"/>
																		
																		<xsl:apply-templates select="$XML/iso:iso-standard/iso:bibdata/iso:title[@language = $lang_other and @type = 'title-main']"/>
																		
																		<xsl:apply-templates select="$XML/iso:iso-standard/iso:bibdata/iso:title[@language = $lang_other and @type = 'title-part']">
																			<xsl:with-param name="curr_lang" select="$lang_other"/>
																		</xsl:apply-templates>
																		
																		<xsl:apply-templates select="$XML/iso:iso-standard/iso:bibdata/iso:title[@language = $lang_other and @type = 'title-amd']">
																			<xsl:with-param name="curr_lang" select="$lang_other"/>
																		</xsl:apply-templates>
																		
																	</fo:block>
																</xsl:for-each>
																
																<xsl:if test="$stage-abbreviation = 'NWIP' or $stage-abbreviation = 'NP' or $stage-abbreviation = 'PWI' or $stage-abbreviation = 'AWI' or $stage-abbreviation = 'WD' or $stage-abbreviation = 'CD' or $stage-abbreviation = 'FDIS'">
																	<fo:block margin-top="10mm">
																		<xsl:copy-of select="$ics"/>
																	</fo:block>
																</xsl:if>
																
															</fo:block>
														</fo:block-container>
													</fo:table-cell>
												</fo:table-row>
											</fo:table-body>
										</fo:table>
									</fo:block-container>
									<fo:block-container position="absolute" left="60mm" top="222mm" height="25mm" display-align="after">
										<fo:block>
											<xsl:if test="$stage-abbreviation = 'PRF'">
												<fo:block font-size="39pt" font-weight="bold"><xsl:value-of select="$proof-text"/></fo:block>
											</xsl:if>
										</fo:block>
									</fo:block-container>
								</fo:flow>
						</xsl:otherwise>
						</xsl:choose>
						
						
					</fo:page-sequence>
				</xsl:when>
					
				<xsl:when test="$isPublished = 'true'">
					<fo:page-sequence master-reference="cover-page-published" force-page-count="no-force">
						<fo:static-content flow-name="cover-page-footer" font-size="10pt">
							<xsl:call-template name="insertTripleLine"/>
							<fo:table table-layout="fixed" width="100%" margin-bottom="3mm">
								<fo:table-column column-width="50%"/>
								<fo:table-column column-width="50%"/>
								<fo:table-body>
									<fo:table-row height="32mm">
										<fo:table-cell display-align="center">
											<fo:block text-align="left">
												<fo:external-graphic src="{concat('data:image/png;base64,', normalize-space($Image-ISO-Logo))}" width="21mm" content-height="21mm" content-width="scale-to-fit" scaling="uniform" fox:alt-text="Image {@alt}"/>
											</fo:block>
										</fo:table-cell>
										<fo:table-cell display-align="center">
											<fo:block text-align="right">												
												<fo:block>
													<xsl:call-template name="getLocalizedString">
														<xsl:with-param name="key">reference_number</xsl:with-param>																			
													</xsl:call-template>
												</fo:block>
												<fo:block><xsl:value-of select="$ISOname"/></fo:block>
												<fo:block> </fo:block>
												<fo:block> </fo:block>
												<fo:block><fo:inline font-size="9pt">©</fo:inline><xsl:value-of select="concat(' ', $copyrightAbbr, ' ', $copyrightYear)"/>
													<xsl:if test="$copyrightAbbrIEEE != ''">
														<xsl:value-of select="$linebreak"/>
														<fo:inline font-size="9pt">©</fo:inline>
														<xsl:value-of select="concat(' ', $copyrightAbbrIEEE, ' ', $copyrightYear)"/>
													</xsl:if>
												</fo:block>
											</fo:block>
										</fo:table-cell>
									</fo:table-row>
								</fo:table-body>
							</fo:table>
						</fo:static-content>
						<fo:flow flow-name="xsl-region-body">
							<fo:block-container>
								<fo:table table-layout="fixed" width="100%" font-size="24pt" line-height="1" margin-bottom="35mm">
									<fo:table-column column-width="60%"/>
									<fo:table-column column-width="40%"/>
									<fo:table-body>
										<fo:table-row>
											<fo:table-cell>
												<fo:block text-align="left">
													<xsl:value-of select="$doctype_uppercased"/>
												</fo:block>
											</fo:table-cell>
											<fo:table-cell>
												<fo:block text-align="right" font-weight="bold" margin-bottom="13mm">
													<xsl:value-of select="$docidentifierISO"/>
												</fo:block>
											</fo:table-cell>
										</fo:table-row>
										<fo:table-row>
											<fo:table-cell number-columns-spanned="2" font-size="10pt" line-height="1.2">
												<fo:block text-align="right">
													<xsl:call-template name="printEdition"/>
													<xsl:value-of select="$linebreak"/>
													<xsl:value-of select="/iso:iso-standard/iso:bibdata/iso:version/iso:revision-date"/></fo:block>
											</fo:table-cell>
										</fo:table-row>
									</fo:table-body>
								</fo:table>
								
								<xsl:call-template name="insertTripleLine"/>
								<fo:block-container line-height="1.1">
									<fo:block margin-right="40mm">
										<fo:block font-size="18pt" font-weight="bold" margin-top="12pt" role="H1">
										
											<xsl:apply-templates select="/iso:iso-standard/iso:bibdata/iso:title[@language = $lang and @type = 'title-intro']"/>
																		
											<xsl:apply-templates select="/iso:iso-standard/iso:bibdata/iso:title[@language = $lang and @type = 'title-main']"/>
											
											<xsl:apply-templates select="/iso:iso-standard/iso:bibdata/iso:title[@language = $lang and @type = 'title-part']">
												<xsl:with-param name="isMainLang">true</xsl:with-param>
											</xsl:apply-templates>
											
										</fo:block>
											
										<xsl:for-each select="xalan:nodeset($lang_other)/lang">
											<xsl:variable name="lang_other" select="."/>
											
											<fo:block font-size="12pt"><xsl:value-of select="$linebreak"/></fo:block>
											<fo:block font-size="11pt" font-style="italic" line-height="1.1" role="H1">
												
												<!-- Example: title-intro fr -->
												<xsl:apply-templates select="$XML/iso:iso-standard/iso:bibdata/iso:title[@language = $lang_other and @type = 'title-intro']"/>
												
												<xsl:apply-templates select="$XML/iso:iso-standard/iso:bibdata/iso:title[@language = $lang_other and @type = 'title-main']"/>
												
												<xsl:apply-templates select="$XML/iso:iso-standard/iso:bibdata/iso:title[@language = $lang_other and @type = 'title-part']">
													<xsl:with-param name="curr_lang" select="$lang_other"/>
												</xsl:apply-templates>
												
											</fo:block>
										</xsl:for-each>
									</fo:block>
								</fo:block-container>
							</fo:block-container>
						</fo:flow>
					</fo:page-sequence>
				</xsl:when>
				<xsl:otherwise>
					<fo:page-sequence master-reference="cover-page" force-page-count="no-force">
						<fo:static-content flow-name="cover-page-header" font-size="10pt">
							<fo:block-container height="24mm" display-align="before">
								<fo:block padding-top="12.5mm">
									<xsl:value-of select="$copyrightText"/>
								</fo:block>
							</fo:block-container>
						</fo:static-content>
						<fo:flow flow-name="xsl-region-body">
							<fo:block-container text-align="right">
								<xsl:choose>
									<xsl:when test="/iso:iso-standard/iso:bibdata/iso:docidentifier[@type = 'iso-tc']">
										<!-- 17301  -->
										<fo:block font-size="14pt" font-weight="bold" margin-bottom="12pt">
											<xsl:value-of select="/iso:iso-standard/iso:bibdata/iso:docidentifier[@type = 'iso-tc']"/>
										</fo:block>
										<!-- Date: 2016-05-01  -->
										<fo:block margin-bottom="12pt">
											<xsl:text>Date: </xsl:text><xsl:value-of select="/iso:iso-standard/iso:bibdata/iso:version/iso:revision-date"/>
										</fo:block>
									
										<!-- ISO/CD 17301-1(E)  -->
										<fo:block margin-bottom="12pt">
											<xsl:value-of select="concat(/iso:iso-standard/iso:bibdata/iso:docidentifier, $lang-1st-letter)"/>
										</fo:block>
									</xsl:when>
									<xsl:otherwise>
										<fo:block font-size="14pt" font-weight="bold" margin-bottom="12pt">
											<!-- ISO/WD 24229(E)  -->
											<xsl:value-of select="concat(/iso:iso-standard/iso:bibdata/iso:docidentifier, $lang-1st-letter)"/>
										</fo:block>
										
									</xsl:otherwise>
								</xsl:choose>
								
								 
								<xsl:if test="normalize-space($editorialgroup) != ''">
									<!-- ISO/TC 34/SC 4/WG 3 -->
									<fo:block margin-bottom="12pt">
										<xsl:copy-of select="$editorialgroup"/>
									</fo:block>
								</xsl:if>
								
								<!-- Secretariat: AFNOR  -->
								<fo:block margin-bottom="100pt">
									<xsl:value-of select="$secretariat"/>
									<xsl:text> </xsl:text>
								</fo:block>


								</fo:block-container>
							<fo:block-container font-size="16pt">
								<!-- Information and documentation — Codes for transcription systems  -->
									<fo:block font-weight="bold" role="H1">
									
										<xsl:apply-templates select="/iso:iso-standard/iso:bibdata/iso:title[@language = $lang and @type = 'title-intro']"/>
																	
										<xsl:apply-templates select="/iso:iso-standard/iso:bibdata/iso:title[@language = $lang and @type = 'title-main']"/>
										
										<xsl:apply-templates select="/iso:iso-standard/iso:bibdata/iso:title[@language = $lang and @type = 'title-part']">
											<xsl:with-param name="isMainLang">true</xsl:with-param>
										</xsl:apply-templates>
									
									</fo:block>
									
									<xsl:for-each select="xalan:nodeset($lang_other)/lang">
										<xsl:variable name="lang_other" select="."/>
									
										<fo:block font-size="12pt"><xsl:value-of select="$linebreak"/></fo:block>
										<fo:block role="H1">
										
											<!-- Example: title-intro fr -->
											<xsl:apply-templates select="$XML/iso:iso-standard/iso:bibdata/iso:title[@language = $lang_other and @type = 'title-intro']"/>
											
											<xsl:apply-templates select="$XML/iso:iso-standard/iso:bibdata/iso:title[@language = $lang_other and @type = 'title-main']"/>
											
											<xsl:apply-templates select="$XML/iso:iso-standard/iso:bibdata/iso:title[@language = $lang_other and @type = 'title-part']">
												<xsl:with-param name="curr_lang" select="$lang_other"/>
											</xsl:apply-templates>
												
										</fo:block>
										
									</xsl:for-each>
									
							</fo:block-container>
							<fo:block font-size="11pt" margin-bottom="8pt"><xsl:value-of select="$linebreak"/></fo:block>
							<fo:block-container font-size="40pt" text-align="center" margin-bottom="12pt" border="0.5pt solid black">
								<xsl:variable name="stage-title" select="substring-after(substring-before($docidentifierISO, ' '), '/')"/>
								<xsl:choose>
									<xsl:when test="normalize-space($stage-title) != ''">
										<fo:block padding-top="2mm"><xsl:value-of select="$stage-title"/><xsl:text> stage</xsl:text></fo:block>
									</xsl:when>
									<xsl:otherwise>
										<xsl:attribute name="border">0pt solid white</xsl:attribute>
										<fo:block> </fo:block>
									</xsl:otherwise>
								</xsl:choose>
							</fo:block-container>
							<fo:block><xsl:value-of select="$linebreak"/></fo:block>
							
							<xsl:if test="/iso:iso-standard/iso:boilerplate/iso:license-statement">
								<fo:block-container font-size="10pt" margin-top="12pt" margin-bottom="6pt" border="0.5pt solid black">
									<fo:block padding-top="1mm">
										<xsl:apply-templates select="/iso:iso-standard/iso:boilerplate/iso:license-statement"/>
									</fo:block>
								</fo:block-container>
							</xsl:if>
						</fo:flow>
					</fo:page-sequence>
				</xsl:otherwise>
			</xsl:choose>	
			
			<xsl:variable name="updated_xml_step1">
				<xsl:apply-templates mode="update_xml_step1"/>
			</xsl:variable>
			<!-- DEBUG: updated_xml_step1=<xsl:copy-of select="$updated_xml_step1"/> -->
			
			<xsl:variable name="updated_xml_step2">
				<xsl:apply-templates select="xalan:nodeset($updated_xml_step1)" mode="update_xml_step2"/>
			</xsl:variable>
			<!-- DEBUG: updated_xml_step2=<xsl:copy-of select="$updated_xml_step2"/> -->
			
			<xsl:variable name="updated_xml_step3">
				<xsl:apply-templates select="xalan:nodeset($updated_xml_step2)" mode="update_xml_enclose_keep-together_within-line"/>
			</xsl:variable>
			<!-- DEBUG: updated_xml_step3=<xsl:copy-of select="$updated_xml_step3"/> -->
			
			<xsl:for-each select="xalan:nodeset($updated_xml_step3)">
			
				<fo:page-sequence master-reference="preface{$document-master-reference}" format="i" force-page-count="{$force-page-count-preface}">
					<xsl:call-template name="insertHeaderFooter">
						<xsl:with-param name="font-weight">normal</xsl:with-param>
					</xsl:call-template>
					<fo:flow flow-name="xsl-region-body" line-height="115%">
						<xsl:if test="/iso:iso-standard/iso:boilerplate/iso:copyright-statement">
						
							<fo:block-container height="252mm" display-align="after">
								<!-- <fo:block margin-bottom="3mm">
									<fo:external-graphic src="{concat('data:image/png;base64,', normalize-space($Image-Attention))}" width="14mm" content-height="13mm" content-width="scale-to-fit" scaling="uniform" fox:alt-text="Image {@alt}"/>								
									<fo:inline padding-left="6mm" font-size="12pt" font-weight="bold"></fo:inline>
								</fo:block> -->
								<fo:block line-height="90%">
									<fo:block font-size="9pt" text-align="justify">
										<xsl:apply-templates select="/iso:iso-standard/iso:boilerplate/iso:copyright-statement"/>
									</fo:block>
								</fo:block>
							</fo:block-container>						
						</xsl:if>
						
						
						<xsl:choose>
							<xsl:when test="$doctype = 'amendment'"/><!-- ToC shouldn't be generated in amendments. -->
							
							<xsl:otherwise>
								<xsl:if test="/iso:iso-standard/iso:boilerplate/iso:copyright-statement">
									<fo:block break-after="page"/>
								</xsl:if>
								<fo:block-container font-weight="bold">
									<fo:block role="TOC">
										<fo:block text-align-last="justify" font-size="16pt" margin-top="10pt" margin-bottom="18pt">
											<fo:inline font-size="16pt" font-weight="bold" role="H1">
												<!-- Contents -->
												<xsl:call-template name="getLocalizedString">
													<xsl:with-param name="key">table_of_contents</xsl:with-param>
												</xsl:call-template>
											</fo:inline>
											<fo:inline keep-together.within-line="always">
												<fo:leader leader-pattern="space"/>
												<fo:inline font-weight="normal" font-size="10pt">
													<!-- Page -->
													<xsl:call-template name="getLocalizedString">
													<xsl:with-param name="key">locality.page</xsl:with-param>
												</xsl:call-template>
												</fo:inline>
											</fo:inline>
										</fo:block>
										
										<xsl:if test="$debug = 'true'">
											<xsl:text disable-output-escaping="yes">&lt;!--</xsl:text>
												DEBUG
												contents=<xsl:copy-of select="$contents"/>
											<xsl:text disable-output-escaping="yes">--&gt;</xsl:text>
										</xsl:if>
										
										<xsl:variable name="margin-left">12</xsl:variable>
										<xsl:for-each select="$contents//item[@display = 'true']"><!-- [not(@level = 2 and starts-with(@section, '0'))] skip clause from preface -->
											
											<fo:block role="TOCI">
												<xsl:if test="@level = 1">
													<xsl:attribute name="margin-top">5pt</xsl:attribute>
												</xsl:if>
												<xsl:if test="@level = 3">
													<xsl:attribute name="margin-top">-0.7pt</xsl:attribute>
												</xsl:if>
												<fo:list-block>
													<xsl:attribute name="margin-left"><xsl:value-of select="$margin-left * (@level - 1)"/>mm</xsl:attribute>
													<xsl:if test="@level &gt;= 2 or @type = 'annex'">
														<xsl:attribute name="font-weight">normal</xsl:attribute>
													</xsl:if>
													<xsl:attribute name="provisional-distance-between-starts">
														<xsl:choose>
															<!-- skip 0 section without subsections -->
															<xsl:when test="@level &gt;= 3"><xsl:value-of select="$margin-left * 1.2"/>mm</xsl:when>
															<xsl:when test="@section != ''"><xsl:value-of select="$margin-left"/>mm</xsl:when>
															<xsl:otherwise>0mm</xsl:otherwise>
														</xsl:choose>
													</xsl:attribute>
													<fo:list-item>
														<fo:list-item-label end-indent="label-end()">
															<fo:block>														
																	<xsl:value-of select="@section"/>														
															</fo:block>
														</fo:list-item-label>
														<fo:list-item-body start-indent="body-start()">
															<fo:block text-align-last="justify" margin-left="12mm" text-indent="-12mm">
																<fo:basic-link internal-destination="{@id}" fox:alt-text="{title}">
																
																	<xsl:apply-templates select="title"/>
																	
																	<fo:inline keep-together.within-line="always">
																		<fo:leader font-size="9pt" font-weight="normal" leader-pattern="dots"/>
																		<fo:inline>
																			<xsl:if test="@level = 1 and @type = 'annex'">
																				<xsl:attribute name="font-weight">bold</xsl:attribute>
																			</xsl:if>
																			<fo:page-number-citation ref-id="{@id}"/>
																		</fo:inline>
																	</fo:inline>
																</fo:basic-link>
															</fo:block>
														</fo:list-item-body>
													</fo:list-item>
												</fo:list-block>
											</fo:block>
											
										</xsl:for-each>
										
										<!-- List of Tables -->
										<xsl:if test="$contents//tables/table">
											<xsl:call-template name="insertListOf_Title">
												<xsl:with-param name="title" select="$title-list-tables"/>
											</xsl:call-template>
											<xsl:for-each select="$contents//tables/table">
												<xsl:call-template name="insertListOf_Item"/>
											</xsl:for-each>
										</xsl:if>
										
										<!-- List of Figures -->
										<xsl:if test="$contents//figures/figure">
											<xsl:call-template name="insertListOf_Title">
												<xsl:with-param name="title" select="$title-list-figures"/>
											</xsl:call-template>
											<xsl:for-each select="$contents//figures/figure">
												<xsl:call-template name="insertListOf_Item"/>
											</xsl:for-each>
										</xsl:if>
										
									</fo:block>
								</fo:block-container>
							</xsl:otherwise>
						</xsl:choose>
						
						<!-- Foreword, Introduction -->					
						<xsl:call-template name="processPrefaceSectionsDefault"/>
							
					</fo:flow>
				</fo:page-sequence>
				
				<!-- BODY -->
				<fo:page-sequence master-reference="document{$document-master-reference}" initial-page-number="1" force-page-count="no-force">
					<fo:static-content flow-name="xsl-footnote-separator">
						<fo:block>
							<fo:leader leader-pattern="rule" leader-length="30%"/>
						</fo:block>
					</fo:static-content>
					<xsl:call-template name="insertHeaderFooter"/>
					<fo:flow flow-name="xsl-region-body">
					
						
						<fo:block-container>
							<!-- Information and documentation — Codes for transcription systems -->
							<!-- <fo:block font-size="16pt" font-weight="bold" margin-bottom="18pt">
								<xsl:value-of select="$title-en"/>
							</fo:block>
							 -->
							<fo:block font-size="18pt" font-weight="bold" margin-top="40pt" margin-bottom="20pt" line-height="1.1">
							
								<fo:block role="H1">
								
									<xsl:apply-templates select="/iso:iso-standard/iso:bibdata/iso:title[@language = $lang and @type = 'title-intro']"/>
									
									<xsl:apply-templates select="/iso:iso-standard/iso:bibdata/iso:title[@language = $lang and @type = 'title-main']"/>
									
									<xsl:apply-templates select="/iso:iso-standard/iso:bibdata/iso:title[@language = $lang and @type = 'title-part']">
										<xsl:with-param name="isMainLang">true</xsl:with-param>
										<xsl:with-param name="isMainBody">true</xsl:with-param>
									</xsl:apply-templates>
									
								</fo:block>
								<fo:block role="H1">
									<xsl:apply-templates select="/iso:iso-standard/iso:bibdata/iso:title[@language = $lang and @type = 'title-part']/node()"/>
								</fo:block>
								
								<xsl:apply-templates select="/iso:iso-standard/iso:bibdata/iso:title[@language = $lang and @type = 'title-amd']">
									<xsl:with-param name="isMainLang">true</xsl:with-param>
									<xsl:with-param name="isMainBody">true</xsl:with-param>
								</xsl:apply-templates>
								
							</fo:block>
						
						</fo:block-container>
						<!-- Clause(s) -->
						<fo:block>
							
							<xsl:choose>
								<xsl:when test="$doctype = 'amendment'">
									<xsl:apply-templates select="/iso:iso-standard/iso:sections/*"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:call-template name="processMainSectionsDefault"/>
								</xsl:otherwise>
							</xsl:choose>
							
							<fo:block id="lastBlock" font-size="1pt"> </fo:block>
						</fo:block>
						
					</fo:flow>
				</fo:page-sequence>
				
				
				<!-- Index -->
				<xsl:apply-templates select="//iso:indexsect" mode="index"/>
				
				<xsl:if test="$isPublished = 'true'">
					<fo:page-sequence master-reference="last-page" force-page-count="no-force">
						<xsl:call-template name="insertHeaderEven"/>
						<fo:static-content flow-name="last-page-footer" font-size="10pt">
							<fo:table table-layout="fixed" width="100%">
								<fo:table-column column-width="33%"/>
								<fo:table-column column-width="33%"/>
								<fo:table-column column-width="34%"/>
								<fo:table-body>
									<fo:table-row>
										<fo:table-cell display-align="center">
											<fo:block font-size="9pt"><xsl:value-of select="$copyrightText"/></fo:block>
										</fo:table-cell>
										<fo:table-cell>
											<fo:block font-size="11pt" font-weight="bold" text-align="center">
												<xsl:if test="$stage-abbreviation = 'PRF'">
													<xsl:value-of select="$proof-text"/>
												</xsl:if>
											</fo:block>
										</fo:table-cell>
										<fo:table-cell>
											<fo:block> </fo:block>
										</fo:table-cell>
									</fo:table-row>
								</fo:table-body>
							</fo:table>
						</fo:static-content>
						<fo:flow flow-name="xsl-region-body">
							<fo:block-container height="252mm" display-align="after">
								<xsl:call-template name="insertTripleLine"/>
								<fo:block-container>
									<fo:block font-size="12pt" font-weight="bold" padding-top="3.5mm" padding-bottom="0.5mm">
										<xsl:for-each select="/iso:iso-standard/iso:bibdata/iso:ext/iso:ics/iso:code">
											<xsl:if test="position() = 1"><fo:inline>ICS  </fo:inline></xsl:if>
											<xsl:value-of select="."/>
											<xsl:if test="position() != last()"><xsl:text>; </xsl:text></xsl:if>
										</xsl:for-each> 
										<!-- <xsl:choose>
											<xsl:when test="$stage-name = 'FDIS'">ICS&#xA0;&#xA0;01.140.30</xsl:when>
											<xsl:when test="$stage-name = 'PRF'">ICS&#xA0;&#xA0;35.240.63</xsl:when>
											<xsl:when test="$stage-name = 'published'">ICS&#xA0;&#xA0;35.240.30</xsl:when>
											<xsl:otherwise>ICS&#xA0;&#xA0;67.060</xsl:otherwise>
										</xsl:choose> -->
										</fo:block>
									<xsl:if test="/iso:iso-standard/iso:bibdata/iso:keyword">
										<fo:block font-size="9pt" margin-bottom="6pt">
											<xsl:variable name="title-descriptors">
												<xsl:call-template name="getTitle">
													<xsl:with-param name="name" select="'title-descriptors'"/>
												</xsl:call-template>
											</xsl:variable>
											<fo:inline font-weight="bold"><xsl:value-of select="$title-descriptors"/>: </fo:inline>
											<xsl:call-template name="insertKeywords">
												<xsl:with-param name="sorting">no</xsl:with-param>
											</xsl:call-template>
										</fo:block>
									</xsl:if>
									<xsl:variable name="countPages"/>
									<xsl:variable name="price_based_on">
										<xsl:call-template name="getLocalizedString">
											<xsl:with-param name="key">price_based_on</xsl:with-param>
										</xsl:call-template>
									</xsl:variable>
									<xsl:variable name="price_based_on_items">
										<xsl:call-template name="split">
											<xsl:with-param name="pText" select="$price_based_on"/>
											<xsl:with-param name="sep" select="'%'"/>
											<xsl:with-param name="normalize-space">false</xsl:with-param>
										</xsl:call-template>
									</xsl:variable>
									<!-- Price based on ... pages -->
									<fo:block font-size="9pt">
										<xsl:for-each select="xalan:nodeset($price_based_on_items)/item">
											<xsl:value-of select="."/>
											<xsl:if test="position() != last()">
												<fo:page-number-citation ref-id="lastBlock"/>
											</xsl:if>										
										</xsl:for-each>
									</fo:block>
								</fo:block-container>
							</fo:block-container>
						</fo:flow>
					</fo:page-sequence>
				</xsl:if>
			</xsl:for-each>
		</fo:root>
	</xsl:template> 

	
	<xsl:template name="insertListOf_Title">
		<xsl:param name="title"/>
		<fo:block role="TOCI" margin-top="5pt" keep-with-next="always">
			<xsl:value-of select="$title"/>
		</fo:block>
	</xsl:template>
	
	<xsl:template name="insertListOf_Item">
		<fo:block role="TOCI" font-weight="normal" text-align-last="justify" margin-left="12mm">
			<fo:basic-link internal-destination="{@id}">
				<xsl:call-template name="setAltText">
					<xsl:with-param name="value" select="@alt-text"/>
				</xsl:call-template>
				<xsl:apply-templates select="." mode="contents"/>
				<fo:inline keep-together.within-line="always">
					<fo:leader font-size="9pt" font-weight="normal" leader-pattern="dots"/>
					<fo:inline><fo:page-number-citation ref-id="{@id}"/></fo:inline>
				</fo:inline>
			</fo:basic-link>
		</fo:block>
	</xsl:template>

	
	<!-- ==================== -->
	<!-- display titles       -->
	<!-- ==================== -->
	<xsl:template match="iso:bibdata/iso:title[@type = 'title-intro']">
		<xsl:apply-templates/>
		<xsl:text> — </xsl:text>
	</xsl:template>

	<xsl:template match="iso:bibdata/iso:title[@type = 'title-main']">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="iso:bibdata/iso:title[@type = 'title-part']">
		<xsl:param name="curr_lang" select="$lang"/>
		<xsl:param name="isMainLang">false</xsl:param>
		<xsl:param name="isMainBody">false</xsl:param>
		<xsl:if test="$part != ''">
			<xsl:text> — </xsl:text>
			<xsl:variable name="part-text">
				<xsl:choose>
					<xsl:when test="$isMainLang = 'true'">
						<xsl:call-template name="getLocalizedString">
							<xsl:with-param name="key">locality.part</xsl:with-param>
						</xsl:call-template>
						<xsl:text> </xsl:text>
						<xsl:value-of select="$part"/>
						<xsl:text>:</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="java:replaceAll(java:java.lang.String.new($titles/title-part[@lang=$curr_lang]),'#',$part)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="$isMainBody = 'true'">
					<fo:block font-weight="normal" margin-top="12pt" line-height="1.1">
						<xsl:value-of select="$part-text"/>
					</fo:block>
				</xsl:when>
				<xsl:when test="$isMainLang = 'true'">
					<fo:block font-weight="normal" margin-top="6pt">
						<xsl:value-of select="$part-text"/>
					</fo:block>
				</xsl:when>
				<xsl:otherwise>
					<!-- <xsl:value-of select="$linebreak"/> -->
					<fo:block font-size="1pt" margin-top="5pt"> </fo:block>
					<xsl:value-of select="$part-text"/>
					<xsl:text> </xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<xsl:if test="$isMainBody = 'false'">
			<xsl:apply-templates/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="iso:bibdata/iso:title[@type = 'title-amd']">
		<xsl:param name="isMainLang">false</xsl:param>
		<xsl:param name="curr_lang" select="$lang"/>
		<xsl:param name="isMainBody">false</xsl:param>
		<xsl:if test="$doctype = 'amendment'">
			<fo:block margin-right="-5mm" margin-top="6pt" role="H1">
				<xsl:if test="$isMainLang = 'true'">
					<xsl:attribute name="margin-top">12pt</xsl:attribute>
				</xsl:if>
				<xsl:if test="$stage-abbreviation = 'DIS' or $isMainBody = 'true'">
					<xsl:attribute name="margin-right">0mm</xsl:attribute>
				</xsl:if>
				
				<fo:block font-weight="normal" line-height="1.1">
					<xsl:value-of select="$doctype_uppercased"/>
					<xsl:variable name="amendment-number" select="/iso:iso-standard/iso:bibdata/iso:ext/iso:structuredidentifier/iso:project-number/@amendment"/>
					<xsl:if test="normalize-space($amendment-number) != ''">
						<xsl:text> </xsl:text><xsl:value-of select="$amendment-number"/>
					</xsl:if>
					<xsl:text>: </xsl:text>
					<xsl:apply-templates/>
				</fo:block>
				
			</fo:block>
		</xsl:if>
	</xsl:template>
	
	
	<!-- ==================== -->
	<!-- END display titles   -->
	<!-- ==================== -->
	
	<xsl:template match="node()">		
		<xsl:apply-templates/>			
	</xsl:template>
	
	<!-- ============================= -->
	<!-- CONTENTS                                       -->
	<!-- ============================= -->
	
	<!-- element with title -->
	<xsl:template match="*[iso:title]" mode="contents">
		<xsl:variable name="level">
			<xsl:call-template name="getLevel">
				<xsl:with-param name="depth" select="iso:title/@depth"/>
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:variable name="section">
			<xsl:call-template name="getSection"/>
		</xsl:variable>
		
		<xsl:variable name="type">
			<xsl:choose>
				<xsl:when test="local-name() = 'indexsect'">index</xsl:when>
				<xsl:otherwise><xsl:value-of select="local-name()"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
			
		<xsl:variable name="display">
			<xsl:choose>				
				<xsl:when test="ancestor-or-self::iso:annex and $level &gt;= 2">false</xsl:when>
				<xsl:when test="$section = '' and $type = 'clause'">false</xsl:when>
				<xsl:when test="$level &lt;= $toc_level">true</xsl:when>
				<xsl:otherwise>false</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="skip">
			<xsl:choose>
				<xsl:when test="ancestor-or-self::iso:bibitem">true</xsl:when>
				<xsl:when test="ancestor-or-self::iso:term">true</xsl:when>				
				<xsl:otherwise>false</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		
		<xsl:if test="$skip = 'false'">		
		
			<xsl:variable name="title">
				<xsl:call-template name="getName"/>
			</xsl:variable>
			
			<xsl:variable name="root">
				<xsl:if test="ancestor-or-self::iso:preface">preface</xsl:if>
				<xsl:if test="ancestor-or-self::iso:annex">annex</xsl:if>
			</xsl:variable>
			
			<item id="{@id}" level="{$level}" section="{$section}" type="{$type}" root="{$root}" display="{$display}">
				<xsl:if test="$type = 'index'">
					<xsl:attribute name="level">1</xsl:attribute>
				</xsl:if>
				<title>
					<xsl:apply-templates select="xalan:nodeset($title)" mode="contents_item"/>
				</title>
				<xsl:if test="$type != 'index'">
					<xsl:apply-templates mode="contents"/>
				</xsl:if>
			</item>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="iso:p | iso:termsource | iso:termnote" mode="contents"/>

	
	
	<!-- ============================= -->
	<!-- ============================= -->

	
	<!-- <fo:block margin-bottom="12pt">© ISO 2019, Published in Switzerland.</fo:block>
			<fo:block font-size="10pt" margin-bottom="12pt">All rights reserved. Unless otherwise specified, no part of this publication may be reproduced or utilized otherwise in any form or by any means, electronic or mechanical, including photocopying, or posting on the internet or an intranet, without prior written permission. Permission can be requested from either ISO at the address below or ISO’s member body in the country of the requester.</fo:block>
			<fo:block font-size="10pt" text-indent="7.1mm">
				<fo:block>ISO copyright office</fo:block>
				<fo:block>Ch. de Blandonnet 8 • CP 401</fo:block>
				<fo:block>CH-1214 Vernier, Geneva, Switzerland</fo:block>
				<fo:block>Tel.  + 41 22 749 01 11</fo:block>
				<fo:block>Fax  + 41 22 749 09 47</fo:block>
				<fo:block>copyright@iso.org</fo:block>
				<fo:block>www.iso.org</fo:block>
			</fo:block> -->
	
	<xsl:template match="iso:copyright-statement/iso:clause[1]/iso:title" priority="2">
		<fo:block margin-left="0.5mm" margin-bottom="3mm" role="H1">
				<fo:external-graphic src="{concat('data:image/png;base64,', normalize-space($Image-Attention))}" width="14mm" content-height="13mm" content-width="scale-to-fit" scaling="uniform" fox:alt-text="Image {@alt}"/>
				<!-- <fo:inline padding-left="6mm" font-size="12pt" font-weight="bold">COPYRIGHT PROTECTED DOCUMENT</fo:inline> -->
				<fo:inline padding-left="6mm" font-size="12pt" font-weight="bold"><xsl:apply-templates/></fo:inline>
			</fo:block>
	</xsl:template>
	
	<xsl:template match="iso:copyright-statement//iso:p" priority="2">
		<fo:block>
			<xsl:if test="following-sibling::iso:p">
				<xsl:attribute name="margin-bottom">3pt</xsl:attribute>
				<xsl:attribute name="margin-left">0.5mm</xsl:attribute>
				<xsl:attribute name="margin-right">0.5mm</xsl:attribute>
			</xsl:if>
			<xsl:if test="contains(@id, 'address')">
				<xsl:attribute name="margin-left">4.5mm</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	


	
	<!-- ====== -->
	<!-- title      -->
	<!-- ====== -->
	
	<xsl:template match="iso:annex/iso:title">
		<xsl:choose>
			<xsl:when test="$doctype = 'amendment'">
				<xsl:call-template name="titleAmendment"/>				
			</xsl:when>
			<xsl:otherwise>
				<fo:block font-size="16pt" text-align="center" margin-bottom="48pt" keep-with-next="always" role="H1">
					<xsl:apply-templates/>
					<xsl:apply-templates select="following-sibling::*[1][local-name() = 'variant-title'][@type = 'sub']" mode="subtitle"/>
				</fo:block>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- Bibliography -->
	<xsl:template match="iso:references[not(@normative='true')]/iso:title">
		<xsl:choose>
			<xsl:when test="$doctype = 'amendment'">
				<xsl:call-template name="titleAmendment"/>				
			</xsl:when>
			<xsl:otherwise>
				<fo:block font-size="16pt" font-weight="bold" text-align="center" margin-top="6pt" margin-bottom="36pt" keep-with-next="always" role="H1">
					<xsl:apply-templates/>
				</fo:block>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="iso:title" name="title">
	
		<xsl:variable name="level">
			<xsl:call-template name="getLevel"/>
		</xsl:variable>
		
		<xsl:variable name="font-size">
			<xsl:choose>
				<xsl:when test="ancestor::iso:annex and $level = 2">13pt</xsl:when>
				<xsl:when test="ancestor::iso:annex and $level = 3">12pt</xsl:when>
				<xsl:when test="ancestor::iso:preface">16pt</xsl:when>
				<xsl:when test="$level = 2">12pt</xsl:when>
				<xsl:when test="$level &gt;= 3">11pt</xsl:when>
				<xsl:otherwise>13pt</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="element-name">
			<xsl:choose>
				<xsl:when test="../@inline-header = 'true'">fo:inline</xsl:when>
				<xsl:otherwise>fo:block</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="$doctype = 'amendment' and not(ancestor::iso:preface)">
				<fo:block font-size="11pt" font-style="italic" margin-bottom="12pt" keep-with-next="always" role="H{$level}">
					<xsl:apply-templates/>
					<xsl:apply-templates select="following-sibling::*[1][local-name() = 'variant-title'][@type = 'sub']" mode="subtitle"/>
				</fo:block>
			</xsl:when>
			
			<xsl:otherwise>
				<xsl:element name="{$element-name}">
					<xsl:attribute name="font-size"><xsl:value-of select="$font-size"/></xsl:attribute>
					<xsl:attribute name="font-weight">bold</xsl:attribute>
					<xsl:attribute name="margin-top"> <!-- margin-top -->
						<xsl:choose>
							<xsl:when test="ancestor::iso:preface">8pt</xsl:when>
							<xsl:when test="$level = 2 and ancestor::iso:annex">18pt</xsl:when>
							<xsl:when test="$level = 1">18pt</xsl:when>
							<xsl:when test="$level &gt;= 3">3pt</xsl:when>
							<xsl:when test="$level = ''">6pt</xsl:when><!-- 13.5pt -->
							<xsl:otherwise>12pt</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
					<xsl:attribute name="margin-bottom">
						<xsl:choose>
							<xsl:when test="ancestor::iso:preface">18pt</xsl:when>
							<!-- <xsl:otherwise>12pt</xsl:otherwise> -->
							<xsl:otherwise>8pt</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
					<xsl:attribute name="keep-with-next">always</xsl:attribute>		
					<xsl:attribute name="role">H<xsl:value-of select="$level"/></xsl:attribute>
					<xsl:if test="$element-name = 'fo:inline'">
						<xsl:choose>
							<xsl:when test="$lang = 'zh'">
								<xsl:value-of select="$tab_zh"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="padding-right">2mm</xsl:attribute>
							</xsl:otherwise>
						</xsl:choose>						
					</xsl:if>
					<xsl:apply-templates/>
					<xsl:apply-templates select="following-sibling::*[1][local-name() = 'variant-title'][@type = 'sub']" mode="subtitle"/>
				</xsl:element>
				
				<xsl:if test="$element-name = 'fo:inline' and not(following-sibling::iso:p)">
					<fo:block> <!-- margin-bottom="12pt" -->
						<xsl:value-of select="$linebreak"/>
					</fo:block>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	
	<xsl:template name="titleAmendment">
		<!-- <xsl:variable name="id">
			<xsl:call-template name="getId"/>
		</xsl:variable> id="{$id}"  -->
		<fo:block font-size="11pt" font-style="italic" margin-bottom="12pt" keep-with-next="always">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	
	<!-- ====== -->
	<!-- ====== -->

	
	<xsl:template match="iso:p" name="paragraph">
		<xsl:param name="inline" select="'false'"/>
		<xsl:param name="split_keep-within-line"/>
		<xsl:variable name="previous-element" select="local-name(preceding-sibling::*[1])"/>
		<xsl:variable name="element-name">
			<xsl:choose>
				<xsl:when test="$inline = 'true'">fo:inline</xsl:when>
				<xsl:when test="../@inline-header = 'true' and $previous-element = 'title'">fo:inline</xsl:when> <!-- first paragraph after inline title -->
				<xsl:when test="local-name(..) = 'admonition'">fo:inline</xsl:when>
				<xsl:otherwise>fo:block</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:element name="{$element-name}">
			<xsl:attribute name="text-align">
				<xsl:choose>
					<!-- <xsl:when test="ancestor::iso:preface">justify</xsl:when> -->
					<xsl:when test="@align"><xsl:value-of select="@align"/></xsl:when>
					<xsl:when test="ancestor::iso:td/@align"><xsl:value-of select="ancestor::iso:td/@align"/></xsl:when>
					<xsl:when test="ancestor::iso:th/@align"><xsl:value-of select="ancestor::iso:th/@align"/></xsl:when>
					<xsl:otherwise>justify</xsl:otherwise><!-- left -->
				</xsl:choose>
			</xsl:attribute>
			<xsl:attribute name="margin-bottom">8pt</xsl:attribute>
			<xsl:if test="@id">
				<xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
			</xsl:if>
			<!-- bookmarks only in paragraph -->
			<xsl:if test="count(iso:bookmark) != 0 and count(*) = count(iso:bookmark) and normalize-space() = ''">
				<xsl:attribute name="font-size">0</xsl:attribute>
				<xsl:attribute name="margin-bottom">0pt</xsl:attribute>
				<xsl:attribute name="line-height">0</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates>
				<xsl:with-param name="split_keep-within-line" select="$split_keep-within-line"/>
			</xsl:apply-templates>
		</xsl:element>
		<xsl:if test="$element-name = 'fo:inline' and not($inline = 'true') and not(local-name(..) = 'admonition')">
			<fo:block margin-bottom="12pt">
				 <xsl:if test="ancestor::iso:annex or following-sibling::iso:table">
					<xsl:attribute name="margin-bottom">0</xsl:attribute>
				 </xsl:if>
				<xsl:value-of select="$linebreak"/>
			</fo:block>
		</xsl:if>
		<xsl:if test="$inline = 'true'">
			<fo:block> </fo:block>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="iso:li//iso:p//text()">
		<xsl:choose>
			<xsl:when test="contains(., '&#9;')">
				<!-- <fo:inline white-space="pre"><xsl:value-of select="translate(., $thin_space, ' ')"/></fo:inline> -->
				<fo:inline white-space="pre"><xsl:value-of select="."/></fo:inline>
			</xsl:when>
			<xsl:otherwise>
				<!-- <xsl:value-of select="translate(., $thin_space, ' ')"/> -->
				<!-- <xsl:value-of select="."/> -->
				<xsl:call-template name="text"/>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	
	
	
	<xsl:template match="iso:p/iso:fn/iso:p">
		<xsl:apply-templates/>
	</xsl:template>
	
	
	<!-- For express listings PDF attachments -->
	<xsl:template match="*[local-name() = 'eref'][contains(@bibitemid, '.exp')]" priority="2">
		<fo:inline xsl:use-attribute-sets="eref-style">
			<xsl:variable name="url" select="concat('url(embedded-file:', @bibitemid, ')')"/>
			<fo:basic-link external-destination="{$url}" fox:alt-text="{@citeas}">
				<xsl:if test="normalize-space(@citeas) = ''">
					<xsl:attribute name="fox:alt-text"><xsl:value-of select="."/></xsl:attribute>
				</xsl:if>
				<xsl:apply-templates/>
			</fo:basic-link>
		</fo:inline>
	</xsl:template>
	

	<!-- =================== -->
	<!-- Index processing -->
	<!-- =================== -->
	
	<xsl:template match="iso:indexsect"/>
	<xsl:template match="iso:indexsect" mode="index">
	
		<fo:page-sequence master-reference="index" force-page-count="no-force">
			<xsl:variable name="header-title">
				<xsl:choose>
					<xsl:when test="./iso:title[1]/*[local-name() = 'tab']">
						<xsl:apply-templates select="./iso:title[1]/*[local-name() = 'tab'][1]/following-sibling::node()" mode="header"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="./iso:title[1]" mode="header"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:call-template name="insertHeaderFooter">
				<xsl:with-param name="header-title" select="$header-title"/>
			</xsl:call-template>
			
			<fo:flow flow-name="xsl-region-body">
				<fo:block id="{@id}" span="all">
					<xsl:apply-templates select="iso:title"/>
				</fo:block>
				<fo:block role="Index">
					<xsl:apply-templates select="*[not(local-name() = 'title')]"/>
				</fo:block>
			</fo:flow>
		</fo:page-sequence>
	</xsl:template>
	
	
	<xsl:template match="iso:xref" priority="2">
		<fo:basic-link internal-destination="{@target}" fox:alt-text="{@target}" xsl:use-attribute-sets="xref-style">
			<xsl:choose>
				<xsl:when test="@pagenumber='true'">
					<fo:inline>
						<xsl:if test="@id">
							<xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
						</xsl:if>
						<fo:page-number-citation ref-id="{@target}"/>
					</fo:inline>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates/>
				</xsl:otherwise>
			</xsl:choose>
		</fo:basic-link>
	</xsl:template>
	
	<!-- =================== -->
	<!-- End of Index processing -->
	<!-- =================== -->
	
	<!-- 
	<xsl:template match="text()[contains(., $thin_space)]">
		<xsl:value-of select="translate(., $thin_space, ' ')"/>
	</xsl:template> -->
	
	
	<xsl:template name="insertHeaderFooter">
		<xsl:param name="font-weight" select="'bold'"/>
		<xsl:call-template name="insertHeaderEven"/>
		<fo:static-content flow-name="footer-even" role="artifact">
			<fo:block-container> <!--  display-align="after" -->
				<fo:table table-layout="fixed" width="100%">
					<fo:table-column column-width="33%"/>
					<fo:table-column column-width="33%"/>
					<fo:table-column column-width="34%"/>
					<fo:table-body>
						<fo:table-row>
							<fo:table-cell display-align="center" padding-top="0mm" font-size="11pt" font-weight="{$font-weight}">
								<xsl:if test="contains($copyrightText, 'IEEE')">
									<xsl:attribute name="display-align">before</xsl:attribute>
								</xsl:if>
								<fo:block><fo:page-number/></fo:block>
							</fo:table-cell>
							<fo:table-cell display-align="center">
								<fo:block font-size="11pt" font-weight="bold" text-align="center">
									<xsl:if test="$stage-abbreviation = 'PRF'">
										<xsl:value-of select="$proof-text"/>
									</xsl:if>
								</fo:block>
							</fo:table-cell>
							<fo:table-cell display-align="center" padding-top="0mm" font-size="9pt">
								<fo:block text-align="right"><xsl:value-of select="$copyrightText"/></fo:block>
							</fo:table-cell>
						</fo:table-row>
					</fo:table-body>
				</fo:table>
			</fo:block-container>
		</fo:static-content>
		<fo:static-content flow-name="header-first">
			<fo:block-container margin-top="13mm" height="9mm" width="172mm" border-top="0.5mm solid black" border-bottom="0.5mm solid black" display-align="center" background-color="white">
				<fo:block text-align-last="justify" font-size="12pt" font-weight="bold">
					
					<xsl:value-of select="$stagename-header-firstpage"/>
					
					<fo:inline keep-together.within-line="always">
						<fo:leader leader-pattern="space"/>
						<fo:inline><xsl:value-of select="$ISOname"/></fo:inline>
					</fo:inline>
				</fo:block>
			</fo:block-container>
		</fo:static-content>
		<fo:static-content flow-name="header-odd" role="artifact">
			<fo:block-container height="24mm" display-align="before">
				<fo:block font-size="12pt" font-weight="bold" text-align="right" padding-top="12.5mm"><xsl:value-of select="$ISOname"/></fo:block>
			</fo:block-container>
		</fo:static-content>
		<fo:static-content flow-name="footer-odd" role="artifact">
			<fo:block-container> <!--  display-align="after" -->
				<fo:table table-layout="fixed" width="100%">
					<fo:table-column column-width="33%"/>
					<fo:table-column column-width="33%"/>
					<fo:table-column column-width="34%"/>
					<fo:table-body>
						<fo:table-row>
							<fo:table-cell display-align="center" padding-top="0mm" font-size="9pt">
								<fo:block><xsl:value-of select="$copyrightText"/></fo:block>
							</fo:table-cell>
							<fo:table-cell display-align="center">
								<fo:block font-size="11pt" font-weight="bold" text-align="center">
									<xsl:if test="$stage-abbreviation = 'PRF'">
										<xsl:value-of select="$proof-text"/>
									</xsl:if>
								</fo:block>
							</fo:table-cell>
							<fo:table-cell display-align="center" padding-top="0mm" font-size="11pt" font-weight="{$font-weight}">
								<xsl:if test="contains($copyrightText, 'IEEE')">
									<xsl:attribute name="display-align">before</xsl:attribute>
								</xsl:if>
								<fo:block text-align="right"><fo:page-number/></fo:block>
							</fo:table-cell>
						</fo:table-row>
					</fo:table-body>
				</fo:table>
			</fo:block-container>
		</fo:static-content>
	</xsl:template>
	<xsl:template name="insertHeaderEven">
		<fo:static-content flow-name="header-even" role="artifact">
			<fo:block-container height="24mm" display-align="before">
				<fo:block font-size="12pt" font-weight="bold" padding-top="12.5mm"><xsl:value-of select="$ISOname"/></fo:block>
			</fo:block-container>
		</fo:static-content>
	</xsl:template>
	
	<xsl:template name="insertTripleLine">
		<fo:block font-size="1.25pt">
			<fo:block><fo:leader leader-pattern="rule" rule-thickness="0.75pt" leader-length="100%"/></fo:block>
			<fo:block><fo:leader leader-pattern="rule" rule-thickness="0.75pt" leader-length="100%"/></fo:block>
			<fo:block><fo:leader leader-pattern="rule" rule-thickness="0.75pt" leader-length="100%"/></fo:block>
		</fo:block>
	</xsl:template>

	<xsl:variable name="Image-ISO-Logo">
		<xsl:text>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</xsl:text>
	</xsl:variable>
	
	<xsl:variable name="Image-IEC-Logo">
		<xsl:text>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</xsl:text>
	</xsl:variable>
	
	<xsl:variable name="Image-IEEE-Logo">
		<xsl:text>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</xsl:text>
	</xsl:variable>
	
	<xsl:variable name="Image-Attention">
		<xsl:text>iVBORw0KGgoAAAANSUhEUgAAAFEAAABHCAIAAADwYjznAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAA66SURBVHhezZt5sM/VG8fNVH7JruxkSZKQ3TAYS7aGajKpFBnRxBjjkhrLrRgmYwm59hrGjC0miSmmIgoVZYu00GJtxkyMkV2/1+fzPh7nfr7fe33v/X6/9/d7/3HmOc/nLM/7PM95zjnfS6F//xc4f/786dOnXaXAUdCcjx071rt373vvvbdChQrNmzdfuXKl+1CAKFDOR44cqVWrVqFChf4T4vbbb7/zzjsnT57sPhcUCo7ztWvX2rRpc9tttxUtWvSuEAgwp/z0009dowJBwXGeM2dO4cKFRZWySJEikvF2o0aNrly54tqlHwXE+cyZM9WrV4czJMW5WLFixv+OO+6YPn26a5p+FBDnjIwM/Ak9AHMcm5mZyWY2TeXKlf/66y/XOs0oCM4HDhwoU6aMMSSqs7Kyfv75Z5jjYXmeff7yyy+7DmlGQXB+7LHHcLKFcdu2bXft2vXtt9/Onz9fS8AnVqRkyZLff/+965NOpJ3zhg0bIsQ4k7/55psvv/xy9+7dnTp1MlezLp07d3bd0on0cr569WqTJk18VlxI9uzZs3XrVjhv37597dq199xzD2vBV9aFo2vVqlWuc9qQXs6zZs2CcLCJ77oLPlWqVOEohqo4U8L/hRdesEVBeOihhy5evOj6pwdp5Pz3339Xq1ZN5xOcEV577TXiWWxVfvXVV5R+M2Jh3Lhxboj0II2chw4dqtQF5EBtY+MsgXz2xhtvKKvTknAoX7780aNH3ShpQLo4Hzx4sFSpUmLCRgUzZsyAnlEVbZXo/XOLlSLg3UBpQLo4P/HEE+ZkhPbt23MOhXwdz5C1A+fWokWLuJmxNKwRK1W8eHG2vRsr1UgLZ51PArFaunRpzqevv/7aOAPJBpLZ448/zurQhWXC5xzjbrhUI/WcOZ+aNm2qQIUAwtNPPw0liBnbiADw6scff8xO9s8tnO8GTSlSz3n27NnwlLt0Pn3++edQEkNKE0KyNzWk9EGDBqkvIJPfd999586dc+OmDinmzPlUo0YN/3waNWrUvn37tmzZInohzWzMJYBt27ZxdMHTP7fGjBnjhk4dUsyZ84nXQuinIKrr1q3L+SRuKk0IWIbwZRL4pEmTlMkAYVK2bNnffvvNjZ4ipJLzL7/8wvsJQ7UhAa9iaEDGqOJJsvR3Ifi0Y8cOlPoK+Ep6b9GihdIBwNW9evVyE6QIqeTcs2dP/fQjW9u1a/fjjz+KqljBlgCePHlynz59eGwNHz58zZo1OrTVjJK4WLp0aYkSJexsZ7RNmza5OVKBlHH+7LPPMA4TMRRzeT+9//77uNHIQHjJkiV16tThK24E7FvigrylC6maUZLkWT4aMBRjIuD569evu5mSRmo4X7t2rXnz5hgXuDh08lNPPeUzwXscPDyhjInARqDxc889ZzcWQJLfuHFjxYoV+UpjwOrMmzfPTZY0UsOZ1z9myT4MxVzcrvNJ4ELCfdsWhWZWKobfeecd3cZZIMBuz8jI0Ji0QeA44FBw8yWHFHA+c+aMfz5BjOzt+w0yWVlZYVJzv3VSGqjSpWvXrsQFbGlPSTKjV+3atW1YMgWr4KZMDingPGLECEtdmPjAAw/gYXKVCIOdO3e++uqrClQRUGkCvZo1a0YzGhtt9j/PEv8Szh2WpOhmTQLJcj58+LB+6MAsefLtt9+2VCwCeAzrA4ohjLYEgJ8feeQRQkPt1RHs3bu3Y8eObHi1Z2XJ9m7iJJAsZw5PbJL1CJi4f/9+3boEOOD2Dz74QE/LkGkA0VAJ52eeeYY97PqEvQBZYPXq1bhXHeXw9evXu7nzi6Q4b9682UzBLA5Vzidi0r9pUhLnXLkrV66s64p4CsgAPXdMYjvk6wgDZDY5hznBr16sTsOGDXnGOAvyhaQ4t2rVCiNkOgLvp0h8SiAhQfv++++3sweol0pWjeC3vG3dAX2/+OKLqlWrWl8mYvs4C/KF/HPmvNXyAwziGcihShg7Y2+YTglYC65lWiAf9CVACPvly5cTydbe707Mv/766+Zq5uKtlswfPfLJ+ezZs3oAmR1DhgzRhpStQmB+CEL0ySefhHOwQmEXARnOnOeffPIJsRDpBVTlZla/fn1bYpJZMn/0yCdnXohKXQBTatWqRRAC31ArAXtVdwzxtBKgfPjhh1kvayz4IxACCxYsoDG7gJJlIrGR1Z01eUR+OP/+++9Esm0wLHjrrbf801UwGYHENm3aNFqqC3ZLAHBu3bq17jB+FxMASZGTuXPnzrbQCI8++qgzKI/ID+fnn3/e5iZcmzZtCiWZCGSlLwAcxQPDLhiAvhIYoXv37rYvcgIjcCj45xb46KOPnE15QZ45k6VkuiZGfvfdd0m5sjikeRMyF9Br3bp1ZcuWlatFWCV+HjZsmGI7FzAau7pfv35KCvRFYFNcvnzZWZYw8syZ9Os7uUePHrYVzTgJIOAdgq1O6ac9gBB6K/hpwQ5nYB0lhCMFAkmOc6t69eraVjJgypQpzrKEkTfOy5YtYz6sZD6Eu+++m1sRUWdmWWmgKg1L07JlS+OskqGIlPfee08HlaBe1lcIxgrPvMzMTOPMaJUqVTp16pSzLzHkgfOFCxd48bO0TAYQXnrpJeUewSzzrTSZ44rHE70wVxYDQj32oIoVDMQLl3muYmYGQTdw4EBnYmLIA+fx48crqrGYleZ82rFjh84nM06CEBp58xO29u/f3zgLOKpmzZoQ9ltK8OF/JV/OmTMHMxRurFrJkiVZUGdlAkiU8/HjxytUqKCgkq0sgX+o+rZKtlICO3bixIk2QuCjMDibNGnCclhLAxoprZQACC6FjAbBEzzLnKEJIFHOJEw/dWEoHMzJMgVINk1gZghkcjsZnu4irJKhunXrFvkZ0OArKSUA4os8whtWK4jD8Xbi/6QwIc7QK168uGJJWWf+/Pl2JptBglVD8wKoiqG8KO1fFQS+9g4q1/QGQyEiC6oSzC+++KK5mnHq1q37zz//OItzRUKcO3XqZDuZabgA6e9PBtnhKmHVBANBwXWqRo0aFt4AmYCP/MYQC9OboJxn5xbAMLabszhX3JozMWMXCQTOp7Vr10bOJwHZqhFZAvFSr149fCIrBV6RuV/jVMZqWKkJEybINgB5Ms4ff/zh7M4Zt+B86dIl+72ScTF3wIABpBCbW/DlWJiVxDBXGuOsFVyzZo3/AgW0FCJVII1AFdrNmjVjQJlHMPbu3duZnjNuwXnSpEkQZjgGZSGJTCZT6hI0d2jDrQVMxCYsCykHnqlWrRpRyoDWRkIEpo+UBAjPeOUaBmQRyTV8ctbngNw4nzhxwv9hHYG3uzlZs0oAZocJodppALJ+DMQtSoeQ52YWyf9+KcEgjaAqpb3MGVBjtmrVyhHIAblx5gphP+IyKLefyNU6Al9vshkngTBu3749lgECe+HChXF/EjJNRJDsa3Ru8Xox37CmixcvdhziIUfOrB/3G6IFwnILtx98opk0a6T0gcZXWpVIJnuPGjWKeyu3dz3IIlBjwa/qK5AsJSD0hgwZwiJiJJxxT+5/rM+Rsz3QNUqXLl04n/wpBclWCrEaA0o24aFDh3766ae9e/c6bagXXD1mQMHVb2gkUOIM3gJKZgDLWVbHJAbxOa9evRoPW2LQ+WTZ1Z9SiCglgPCj+ypg3Ny5c5999lkO+YyMDD4RnOjD5tFBrCpQNb0EyZRsumnTpmGwQpI45/Lz66+/Oj7ZEYfzlStX6tevr6wgJ/fp08ffyeFcbmJBGsGv6itQFQ9zeWJM/MCwgInsX0MCtYwtJZjGYJ8osZCMyJihpwNX9+zZ01HKjjicp06dSk8sA0RL1apVeannkloBsuDq3lfpAVs3KyuLMXGCVpOSHMlrQQ9S2vjtQThANr00IKKk5Jq0YsUK5SAGV5DG/Z8eUc6cT/YHB7rpfIp9A8StSogLPpEUeU7Yaga+CC929sO4mgnqJaga0asKJFOSGg8ePMiu8V3NjSX2jx5RzqRTnU+YhZN5P9lZIgQTxptSpY/wewDJOLNt27YyyGjDuXTp0qtWrdLvJNYr0j2it9KgKgvH8tlvsozPdLNmzXLcbiAbZzKz/SVNyYDzk00Yd4KIIJhSpQSBYNFLSNYILGvNmjVppp8NBLWXYFXgf/L1gpTs6pEjRzKsZtHejPyfvWycIz8ga6fZcII/gSANcPUQqloJYMXu4vZKHLGsrCkG4ZDMzEwtqyEcwMGq+uTDV5rMLITMgw8+yOBGZOjQoY5hiJucedzKFNoh6PbPQWIjBjOHMI2vFEwjIVJiDWHcuHFjMg2X5CpVqrzyyitGOOiWvYvBlKaPq5FMQM2cORM/iwvLyvbZv3+/42mcOZ8aNGggJ9OaCBw4cGBO6VTwlbeUEQBpBtqQ5H26ZMkSqhzXauDDevmQMhwm2/gG01CySfXH+sDRoau7d+8upsBx5v3EB9gCFoa3OAbFXkIEvyqZ0hBRxrbh2CN8IE8covc/GUyZiwAislX1mwzuVTLD4eDDDz8U2YDzyZMnK1WqpA1AC4SxY8fiZGhrFL/0BYCsqimlMfjKWBlEZFX9UjA5aJH9qzQRYH/fvn3hAiN4Ebncfy5duuQ4Dx48mLyibzRq0aLFDz/8QAIE7I28Ik+9btk4fzYAOO/bt6927dpyNYA299OAM3ncfySTvXiOjh49msvw8OHDrYxUTekj0tLgV5FVNcFgelV9+J/iNrOqfR02bNibb77JrhY1uZN3yPnz5wsdOHDA/uYmQJvPNAUSIlXBlw1xlSBux5wa+6CN38yqEoD0Bl+JAC/YQUruROYxV+jPP//UHzhDN7vbguQIctJHELdZrDIRDUhwUpBTS/T6BP8SJUrwjA32M9cj/d/zILuFV3MTBKua0qomhOoAvtJgn0yQbBogpcFpQ5jG9BEhUvpVARmO7dq141QOOF++fJk0Vq5cOb5pVf5PoLBMHvDiFtShQwf9EuzOZ3D06NFNmzbpfKI0KPUDyVZK8GUrfZjeBCsFk4MWubYJPnswvSFSFVBu3ryZJ5fj+e+//wVuVmgt0lkFPgAAAABJRU5ErkJggg==</xsl:text>
	</xsl:variable>
	
<xsl:param name="svg_images"/><xsl:variable name="images" select="document($svg_images)"/><xsl:param name="basepath"/><xsl:param name="external_index"/><xsl:param name="syntax-highlight">false</xsl:param><xsl:param name="add_math_as_text">true</xsl:param><xsl:param name="table_if">false</xsl:param><xsl:param name="table_widths"/><xsl:variable name="table_widths_from_if" select="xalan:nodeset($table_widths)"/><xsl:variable name="table_widths_from_if_calculated_">
		<xsl:for-each select="$table_widths_from_if//table">
			<xsl:copy>
				<xsl:copy-of select="@*"/>
				<xsl:call-template name="calculate-column-widths-autolayout-algorithm"/>
			</xsl:copy>
		</xsl:for-each>
	</xsl:variable><xsl:variable name="table_widths_from_if_calculated" select="xalan:nodeset($table_widths_from_if_calculated_)"/><xsl:param name="table_if_debug">false</xsl:param><xsl:variable name="isGenerateTableIF_">
		
				<xsl:value-of select="normalize-space($table_if) = 'true'"/>
			
	</xsl:variable><xsl:variable name="isGenerateTableIF" select="normalize-space($isGenerateTableIF_)"/><xsl:variable name="lang">
		<xsl:call-template name="getLang"/>
	</xsl:variable><xsl:variable name="papersize" select="java:toLowerCase(java:java.lang.String.new(normalize-space(//*[contains(local-name(), '-standard')]/*[local-name() = 'misc-container']/*[local-name() = 'presentation-metadata']/*[local-name() = 'papersize'])))"/><xsl:variable name="papersize_width_">
		<xsl:choose>
			<xsl:when test="$papersize = 'letter'">215.9</xsl:when>
			<xsl:when test="$papersize = 'a4'">210</xsl:when>
		</xsl:choose>
	</xsl:variable><xsl:variable name="papersize_width" select="normalize-space($papersize_width_)"/><xsl:variable name="papersize_height_">
		<xsl:choose>
			<xsl:when test="$papersize = 'letter'">279.4</xsl:when>
			<xsl:when test="$papersize = 'a4'">297</xsl:when>
		</xsl:choose>
	</xsl:variable><xsl:variable name="papersize_height" select="normalize-space($papersize_height_)"/><xsl:variable name="pageWidth_">
		<xsl:choose>
			<xsl:when test="$papersize_width != ''"><xsl:value-of select="$papersize_width"/></xsl:when>
			<xsl:otherwise>
				210
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable><xsl:variable name="pageWidth" select="normalize-space($pageWidth_)"/><xsl:variable name="pageHeight_">
		<xsl:choose>
			<xsl:when test="$papersize_height != ''"><xsl:value-of select="$papersize_height"/></xsl:when>
			<xsl:otherwise>
				297
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable><xsl:variable name="pageHeight" select="normalize-space($pageHeight_)"/><xsl:variable name="marginLeftRight1_">
		25
	</xsl:variable><xsl:variable name="marginLeftRight1" select="normalize-space($marginLeftRight1_)"/><xsl:variable name="marginLeftRight2_">
		12.5
	</xsl:variable><xsl:variable name="marginLeftRight2" select="normalize-space($marginLeftRight2_)"/><xsl:variable name="marginTop_">
		27.4
	</xsl:variable><xsl:variable name="marginTop" select="normalize-space($marginTop_)"/><xsl:variable name="marginBottom_">
		13
	</xsl:variable><xsl:variable name="marginBottom" select="normalize-space($marginBottom_)"/><xsl:variable name="titles_">
		
		
		<!-- These titles of Table of contents renders different than determined in localized-strings -->
		<title-toc lang="en">
			
			
			
		</title-toc>
		<title-toc lang="fr">
			<xsl:text>Sommaire</xsl:text>
		</title-toc>
		<title-toc lang="zh">
			
					<xsl:text>Contents</xsl:text>
				
		</title-toc>
		
		<title-descriptors lang="en">Descriptors</title-descriptors>
		
		<title-part lang="en">
			
				<xsl:text>Part #:</xsl:text>
			
			
			
		</title-part>
		<title-part lang="fr">
			
				<xsl:text>Partie #:</xsl:text>
			
			
			
		</title-part>
		<title-part lang="ru">
			
				<xsl:text>Часть #:</xsl:text>
			
			
		</title-part>
		<title-part lang="zh">第 # 部分:</title-part>
		
		<title-subpart lang="en">Sub-part #</title-subpart>
		<title-subpart lang="fr">Partie de sub #</title-subpart>
		
		<title-list-tables lang="en">List of Tables</title-list-tables>
		
		<title-list-figures lang="en">List of Figures</title-list-figures>
		
		<title-table-figures lang="en">Table of Figures</title-table-figures>
		
		<title-list-recommendations lang="en">List of Recommendations</title-list-recommendations>
		
		<title-summary lang="en">Summary</title-summary>
		
		<title-continued lang="ru">(продолжение)</title-continued>
		<title-continued lang="en">(continued)</title-continued>
		<title-continued lang="fr">(continué)</title-continued>
		
	</xsl:variable><xsl:variable name="titles" select="xalan:nodeset($titles_)"/><xsl:variable name="title-list-tables">
		<xsl:variable name="toc_table_title" select="//*[contains(local-name(), '-standard')]/*[local-name() = 'misc-container']/*[local-name() = 'toc'][@type='table']/*[local-name() = 'title']"/>
		<xsl:value-of select="$toc_table_title"/>
		<xsl:if test="normalize-space($toc_table_title) = ''">
			<xsl:call-template name="getTitle">
				<xsl:with-param name="name" select="'title-list-tables'"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:variable><xsl:variable name="title-list-figures">
		<xsl:variable name="toc_figure_title" select="//*[contains(local-name(), '-standard')]/*[local-name() = 'misc-container']/*[local-name() = 'toc'][@type='figure']/*[local-name() = 'title']"/>
		<xsl:value-of select="$toc_figure_title"/>
		<xsl:if test="normalize-space($toc_figure_title) = ''">
			<xsl:call-template name="getTitle">
				<xsl:with-param name="name" select="'title-list-figures'"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:variable><xsl:variable name="title-list-recommendations">
		<xsl:variable name="toc_requirement_title" select="//*[contains(local-name(), '-standard')]/*[local-name() = 'misc-container']/*[local-name() = 'toc'][@type='requirement']/*[local-name() = 'title']"/>
		<xsl:value-of select="$toc_requirement_title"/>
		<xsl:if test="normalize-space($toc_requirement_title) = ''">
			<xsl:call-template name="getTitle">
				<xsl:with-param name="name" select="'title-list-recommendations'"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:variable><xsl:variable name="bibdata">
		<xsl:copy-of select="//*[contains(local-name(), '-standard')]/*[local-name() = 'bibdata']"/>
		<xsl:copy-of select="//*[contains(local-name(), '-standard')]/*[local-name() = 'localized-strings']"/>
	</xsl:variable><xsl:variable name="linebreak">&#8232;</xsl:variable><xsl:variable name="tab_zh">　</xsl:variable><xsl:variable name="non_breaking_hyphen">‑</xsl:variable><xsl:variable name="thin_space"> </xsl:variable><xsl:variable name="zero_width_space">​</xsl:variable><xsl:variable name="hair_space"> </xsl:variable><xsl:variable name="en_dash">–</xsl:variable><xsl:template name="getTitle">
		<xsl:param name="name"/>
		<xsl:param name="lang"/>
		<xsl:variable name="lang_">
			<xsl:choose>
				<xsl:when test="$lang != ''">
					<xsl:value-of select="$lang"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="getLang"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="language" select="normalize-space($lang_)"/>
		<xsl:variable name="title_" select="$titles/*[local-name() = $name][@lang = $language]"/>
		<xsl:choose>
			<xsl:when test="normalize-space($title_) != ''">
				<xsl:value-of select="$title_"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$titles/*[local-name() = $name][@lang = 'en']"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:variable name="lower">abcdefghijklmnopqrstuvwxyz</xsl:variable><xsl:variable name="upper">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable><xsl:variable name="en_chars" select="concat($lower,$upper,',.`1234567890-=~!@#$%^*()_+[]{}\|?/')"/><xsl:variable name="font_noto_sans">Noto Sans, Noto Sans HK, Noto Sans JP, Noto Sans KR, Noto Sans SC, Noto Sans TC</xsl:variable><xsl:variable name="font_noto_sans_mono">Noto Sans Mono, Noto Sans Mono CJK HK, Noto Sans Mono CJK JP, Noto Sans Mono CJK KR, Noto Sans Mono CJK SC, Noto Sans Mono CJK TC</xsl:variable><xsl:variable name="font_noto_serif">Noto Serif, Noto Serif HK, Noto Serif JP, Noto Serif KR, Noto Serif SC, Noto Serif TC</xsl:variable><xsl:attribute-set name="root-style">
		
		
		
		
		
		
		
		
		
			<xsl:attribute name="font-family">Cambria, Times New Roman, Cambria Math, <xsl:value-of select="$font_noto_serif"/></xsl:attribute>
			<xsl:attribute name="font-family-generic">Serif</xsl:attribute>
			<xsl:attribute name="font-size">11pt</xsl:attribute>
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:template name="insertRootStyle">
		<xsl:param name="root-style"/>
		<xsl:variable name="root-style_" select="xalan:nodeset($root-style)"/>
		
		<xsl:variable name="additional_fonts_">
			<xsl:for-each select="//*[contains(local-name(), '-standard')][1]/*[local-name() = 'misc-container']/*[local-name() = 'presentation-metadata'][*[local-name() = 'name'] = 'fonts']/*[local-name() = 'value'] |       //*[contains(local-name(), '-standard')][1]/*[local-name() = 'presentation-metadata'][*[local-name() = 'name'] = 'fonts']/*[local-name() = 'value']">
				<xsl:value-of select="."/><xsl:if test="position() != last()">, </xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="additional_fonts" select="normalize-space($additional_fonts_)"/>
		
		<xsl:variable name="font_family_generic" select="$root-style_/root-style/@font-family-generic"/>
		
		<xsl:for-each select="$root-style_/root-style/@*">
		
			<xsl:choose>
				<xsl:when test="local-name() = 'font-family-generic'"><!-- skip, it's using for determine 'sans' or 'serif' --></xsl:when>
				<xsl:when test="local-name() = 'font-family'">
				
					<xsl:variable name="font_regional_prefix">
						<xsl:choose>
							<xsl:when test="$font_family_generic = 'Sans'">Noto Sans</xsl:when>
							<xsl:otherwise>Noto Serif</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
				
					<xsl:attribute name="{local-name()}">
					
						<xsl:variable name="font_extended">
							<xsl:choose>
								<xsl:when test="$lang = 'zh'"><xsl:value-of select="$font_regional_prefix"/> SC</xsl:when>
								<xsl:when test="$lang = 'hk'"><xsl:value-of select="$font_regional_prefix"/> HK</xsl:when>
								<xsl:when test="$lang = 'jp'"><xsl:value-of select="$font_regional_prefix"/> JP</xsl:when>
								<xsl:when test="$lang = 'kr'"><xsl:value-of select="$font_regional_prefix"/> KR</xsl:when>
								<xsl:when test="$lang = 'sc'"><xsl:value-of select="$font_regional_prefix"/> SC</xsl:when>
								<xsl:when test="$lang = 'tc'"><xsl:value-of select="$font_regional_prefix"/> TC</xsl:when>
							</xsl:choose>
						</xsl:variable>
						<xsl:if test="normalize-space($font_extended) != ''">
							<xsl:value-of select="$font_regional_prefix"/><xsl:text>, </xsl:text>
							<xsl:value-of select="$font_extended"/><xsl:text>, </xsl:text>
						</xsl:if>
					
						<xsl:value-of select="."/>
						
						<xsl:if test="$additional_fonts != ''">
							<xsl:text>, </xsl:text><xsl:value-of select="$additional_fonts"/>
						</xsl:if>
					</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		
			<!-- <xsl:choose>
				<xsl:when test="local-name() = 'font-family'">
					<xsl:attribute name="{local-name()}">
						<xsl:value-of select="."/>, <xsl:value-of select="$additional_fonts"/>
					</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="."/>
				</xsl:otherwise>
			</xsl:choose> -->
		</xsl:for-each>
	</xsl:template><xsl:attribute-set name="copyright-statement-style">
		
	</xsl:attribute-set><xsl:attribute-set name="copyright-statement-title-style">
		
		
	</xsl:attribute-set><xsl:attribute-set name="copyright-statement-p-style">
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="license-statement-style">
		
		
	</xsl:attribute-set><xsl:attribute-set name="license-statement-title-style">
		<xsl:attribute name="keep-with-next">always</xsl:attribute>
		
		
			<xsl:attribute name="text-align">center</xsl:attribute>
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="license-statement-p-style">
		
		
			<xsl:attribute name="margin-left">1.5mm</xsl:attribute>
			<xsl:attribute name="margin-right">1.5mm</xsl:attribute>
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="legal-statement-style">
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="legal-statement-title-style">
		<xsl:attribute name="keep-with-next">always</xsl:attribute>
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="legal-statement-p-style">
		
	</xsl:attribute-set><xsl:attribute-set name="feedback-statement-style">
		
		
	</xsl:attribute-set><xsl:attribute-set name="feedback-statement-title-style">
		<xsl:attribute name="keep-with-next">always</xsl:attribute>
		
	</xsl:attribute-set><xsl:attribute-set name="feedback-statement-p-style">
		
		
	</xsl:attribute-set><xsl:attribute-set name="link-style">
		
		
			<xsl:attribute name="color">blue</xsl:attribute>
			<xsl:attribute name="text-decoration">underline</xsl:attribute>
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="sourcecode-container-style">
		
	</xsl:attribute-set><xsl:attribute-set name="sourcecode-style">
		<xsl:attribute name="white-space">pre</xsl:attribute>
		<xsl:attribute name="wrap-option">wrap</xsl:attribute>
		<xsl:attribute name="role">Code</xsl:attribute>
		
		
		
		
		
		
		
		
		
			<xsl:attribute name="font-family">Courier New, <xsl:value-of select="$font_noto_sans_mono"/></xsl:attribute>			
			<xsl:attribute name="margin-bottom">12pt</xsl:attribute>
		
		
		
				
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="permission-style">
		
	</xsl:attribute-set><xsl:attribute-set name="permission-name-style">
		
	</xsl:attribute-set><xsl:attribute-set name="permission-label-style">
		
	</xsl:attribute-set><xsl:attribute-set name="requirement-style">
		
			<xsl:attribute name="margin-top">6pt</xsl:attribute>
			<xsl:attribute name="margin-bottom">6pt</xsl:attribute>
		
		
	</xsl:attribute-set><xsl:attribute-set name="requirement-name-style">
		<xsl:attribute name="keep-with-next">always</xsl:attribute>
		
			<xsl:attribute name="font-weight">bold</xsl:attribute>
			<xsl:attribute name="text-align">center</xsl:attribute>			
			<xsl:attribute name="margin-bottom">4pt</xsl:attribute>
		
		
	</xsl:attribute-set><xsl:attribute-set name="requirement-label-style">
		
	</xsl:attribute-set><xsl:attribute-set name="subject-style">
	</xsl:attribute-set><xsl:attribute-set name="inherit-style">
	</xsl:attribute-set><xsl:attribute-set name="description-style">
	</xsl:attribute-set><xsl:attribute-set name="specification-style">
	</xsl:attribute-set><xsl:attribute-set name="measurement-target-style">
	</xsl:attribute-set><xsl:attribute-set name="verification-style">
	</xsl:attribute-set><xsl:attribute-set name="import-style">
	</xsl:attribute-set><xsl:attribute-set name="recommendation-style">
		
		
	</xsl:attribute-set><xsl:attribute-set name="recommendation-name-style">
		
		
	</xsl:attribute-set><xsl:attribute-set name="recommendation-label-style">
		
	</xsl:attribute-set><xsl:attribute-set name="termexample-style">
		
		
		
		
		
			<xsl:attribute name="font-size">10pt</xsl:attribute>
			<xsl:attribute name="margin-top">8pt</xsl:attribute>
			<xsl:attribute name="margin-bottom">8pt</xsl:attribute>
			<xsl:attribute name="text-align">justify</xsl:attribute>
		
		
		

	</xsl:attribute-set><xsl:attribute-set name="example-style">
		
		
		
		
			<xsl:attribute name="font-size">10pt</xsl:attribute>
			<xsl:attribute name="margin-top">8pt</xsl:attribute>
			<xsl:attribute name="margin-bottom">8pt</xsl:attribute>
		
		
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="example-body-style">
		
		
		
					
			<xsl:attribute name="margin-left">7mm</xsl:attribute>
			<xsl:attribute name="margin-right">7mm</xsl:attribute>			
		
		
	</xsl:attribute-set><xsl:attribute-set name="example-name-style">
		
		
		
		
			<xsl:attribute name="keep-with-next">always</xsl:attribute>
			<xsl:attribute name="padding-right">5mm</xsl:attribute>
			<xsl:attribute name="margin-bottom">6pt</xsl:attribute>
		
		
		
		
		
		
		
		
		
		
				
				
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="example-p-style">
		
		
		
		
			<xsl:attribute name="font-size">10pt</xsl:attribute>
			<xsl:attribute name="margin-top">8pt</xsl:attribute>
			<xsl:attribute name="margin-bottom">8pt</xsl:attribute>
		
		
		
		
			<xsl:attribute name="text-align">justify</xsl:attribute>
		
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="termexample-name-style">
		
		
		
			<xsl:attribute name="padding-right">5mm</xsl:attribute>
		
		
				
				
	</xsl:attribute-set><xsl:variable name="table-border_">
		
		
	</xsl:variable><xsl:variable name="table-border" select="normalize-space($table-border_)"/><xsl:attribute-set name="table-container-style">
		<xsl:attribute name="margin-left">0mm</xsl:attribute>
		<xsl:attribute name="margin-right">0mm</xsl:attribute>
		
		
		
		
		
		
		
		
		
		
			<xsl:attribute name="font-size">10pt</xsl:attribute>
			<xsl:attribute name="margin-top">12pt</xsl:attribute>
			<xsl:attribute name="margin-bottom">8pt</xsl:attribute>
		
		
		
		
		
		
		
		
		
		
					
		
		
	</xsl:attribute-set><xsl:attribute-set name="table-style">
		<xsl:attribute name="table-omit-footer-at-break">true</xsl:attribute>
		<xsl:attribute name="table-layout">fixed</xsl:attribute>
		<xsl:attribute name="margin-left">0mm</xsl:attribute>
		<xsl:attribute name="margin-right">0mm</xsl:attribute>
		
		
		
		
		
		
		
		
		
		
			<xsl:attribute name="border">1.5pt solid black</xsl:attribute>
		
		
		
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="table-name-style">
		<xsl:attribute name="keep-with-next">always</xsl:attribute>
			
		
		
		
				
		
		
			<xsl:attribute name="font-size">11pt</xsl:attribute>
			<xsl:attribute name="font-weight">bold</xsl:attribute>
			<xsl:attribute name="text-align">center</xsl:attribute>
			<xsl:attribute name="margin-bottom">0pt</xsl:attribute>
				
		
		
		
				
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="table-row-style">
		<xsl:attribute name="min-height">4mm</xsl:attribute>
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="table-header-row-style" use-attribute-sets="table-row-style">
		<xsl:attribute name="font-weight">bold</xsl:attribute>
		
		
			<xsl:attribute name="border-top">solid black 1pt</xsl:attribute>
			<xsl:attribute name="border-bottom">solid black 1pt</xsl:attribute>
		
		
		
		
		
		
				
		
	</xsl:attribute-set><xsl:attribute-set name="table-footer-row-style" use-attribute-sets="table-row-style">
		
		
		
			<xsl:attribute name="font-size">9pt</xsl:attribute>
			<xsl:attribute name="border-left">solid black 1pt</xsl:attribute>
			<xsl:attribute name="border-right">solid black 1pt</xsl:attribute>
		
	</xsl:attribute-set><xsl:attribute-set name="table-body-row-style" use-attribute-sets="table-row-style">

	</xsl:attribute-set><xsl:attribute-set name="table-header-cell-style">
		<xsl:attribute name="font-weight">bold</xsl:attribute>
		<xsl:attribute name="border">solid black 1pt</xsl:attribute>
		<xsl:attribute name="padding-left">1mm</xsl:attribute>
		<xsl:attribute name="padding-right">1mm</xsl:attribute>
		<xsl:attribute name="display-align">center</xsl:attribute>
		
		
		
			<xsl:attribute name="padding-top">1mm</xsl:attribute>
		
		
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="table-cell-style">
		<xsl:attribute name="display-align">center</xsl:attribute>
		<xsl:attribute name="border">solid black 1pt</xsl:attribute>
		<xsl:attribute name="padding-left">1mm</xsl:attribute>
		<xsl:attribute name="padding-right">1mm</xsl:attribute>
		
		
		
		
			<xsl:attribute name="padding-top">0.5mm</xsl:attribute>
		
		
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="table-footer-cell-style">
		<xsl:attribute name="border">solid black 1pt</xsl:attribute>
		<xsl:attribute name="padding-left">1mm</xsl:attribute>
		<xsl:attribute name="padding-right">1mm</xsl:attribute>
		<xsl:attribute name="padding-top">1mm</xsl:attribute>
		
		
		
		
		
		
			<xsl:attribute name="border-top">solid black 0pt</xsl:attribute>
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="table-note-style">
		<xsl:attribute name="font-size">10pt</xsl:attribute>
		<xsl:attribute name="margin-bottom">12pt</xsl:attribute>
		
		
		
		
			<xsl:attribute name="font-size">9pt</xsl:attribute>
			<xsl:attribute name="margin-bottom">6pt</xsl:attribute>
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="table-fn-style">
		<xsl:attribute name="margin-bottom">12pt</xsl:attribute>
		
		
		
		
			<xsl:attribute name="font-size">9pt</xsl:attribute>
			<xsl:attribute name="margin-bottom">6pt</xsl:attribute>
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="table-fn-number-style">
		<xsl:attribute name="font-size">80%</xsl:attribute>
		<xsl:attribute name="padding-right">5mm</xsl:attribute>
		
		
		
		
		
			<xsl:attribute name="alignment-baseline">hanging</xsl:attribute>
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="fn-container-body-style">
		<xsl:attribute name="text-indent">0</xsl:attribute>
		<xsl:attribute name="start-indent">0</xsl:attribute>
		
		
	</xsl:attribute-set><xsl:attribute-set name="table-fn-body-style">
		
	</xsl:attribute-set><xsl:attribute-set name="figure-fn-number-style">
		<xsl:attribute name="font-size">80%</xsl:attribute>
		<xsl:attribute name="padding-right">5mm</xsl:attribute>
		<xsl:attribute name="vertical-align">super</xsl:attribute>
		
	</xsl:attribute-set><xsl:attribute-set name="figure-fn-body-style">
		<xsl:attribute name="text-align">justify</xsl:attribute>
		<xsl:attribute name="margin-bottom">12pt</xsl:attribute>
		
	</xsl:attribute-set><xsl:attribute-set name="dt-row-style">
		
		
	</xsl:attribute-set><xsl:attribute-set name="dt-cell-style">
	</xsl:attribute-set><xsl:attribute-set name="dt-block-style">
		<xsl:attribute name="margin-top">6pt</xsl:attribute>
		
		
		
		
		
		
		
			<xsl:attribute name="margin-top">0pt</xsl:attribute>
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="dl-name-style">
		<xsl:attribute name="keep-with-next">always</xsl:attribute>
		<xsl:attribute name="margin-bottom">6pt</xsl:attribute>
			
		
		
		
		
		
		
			<xsl:attribute name="font-weight">bold</xsl:attribute>
				
		
		
		
				
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="dd-cell-style">
		<xsl:attribute name="padding-left">2mm</xsl:attribute>
	</xsl:attribute-set><xsl:attribute-set name="appendix-style">
				
			<xsl:attribute name="font-size">12pt</xsl:attribute>
			<xsl:attribute name="font-weight">bold</xsl:attribute>
			<xsl:attribute name="margin-top">12pt</xsl:attribute>
			<xsl:attribute name="margin-bottom">12pt</xsl:attribute>
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="appendix-example-style">
		
			<xsl:attribute name="font-size">10pt</xsl:attribute>			
			<xsl:attribute name="margin-top">8pt</xsl:attribute>
			<xsl:attribute name="margin-bottom">8pt</xsl:attribute>
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="xref-style">
		
		
		
			<xsl:attribute name="color">blue</xsl:attribute>
			<xsl:attribute name="text-decoration">underline</xsl:attribute>
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="eref-style">
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="note-style">
		
		
		
		
				
				
		
		
			<xsl:attribute name="font-size">10pt</xsl:attribute>
			<xsl:attribute name="margin-top">8pt</xsl:attribute>
			<xsl:attribute name="margin-bottom">12pt</xsl:attribute>
			<xsl:attribute name="text-align">justify</xsl:attribute>
		
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:variable name="note-body-indent">10mm</xsl:variable><xsl:variable name="note-body-indent-table">5mm</xsl:variable><xsl:attribute-set name="note-name-style">
		
		
		
		
		
		
		
			<xsl:attribute name="padding-right">6mm</xsl:attribute>
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="table-note-name-style">
		<xsl:attribute name="padding-right">2mm</xsl:attribute>
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="note-p-style">
		
		
		
		
		
		
					
			<xsl:attribute name="margin-top">8pt</xsl:attribute>
			<xsl:attribute name="margin-bottom">12pt</xsl:attribute>			
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="termnote-style">
		
		
				
		
		
			<xsl:attribute name="font-size">10pt</xsl:attribute>
			<xsl:attribute name="margin-top">8pt</xsl:attribute>
			<xsl:attribute name="margin-bottom">8pt</xsl:attribute>
			<xsl:attribute name="text-align">justify</xsl:attribute>
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="termnote-name-style">
		
				
		
		
	</xsl:attribute-set><xsl:attribute-set name="termnote-p-style">
		
	</xsl:attribute-set><xsl:attribute-set name="quote-style">
		<xsl:attribute name="margin-left">12mm</xsl:attribute>
		<xsl:attribute name="margin-right">12mm</xsl:attribute>
		
		
			<xsl:attribute name="margin-top">12pt</xsl:attribute>
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="quote-source-style">		
		<xsl:attribute name="text-align">right</xsl:attribute>
		
				
	</xsl:attribute-set><xsl:attribute-set name="termsource-style">
		
		
		
		
		
		
			<xsl:attribute name="margin-bottom">8pt</xsl:attribute>
		
		
	</xsl:attribute-set><xsl:attribute-set name="termsource-text-style">
		
		
	</xsl:attribute-set><xsl:attribute-set name="origin-style">
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="term-style">
		
			<xsl:attribute name="margin-bottom">10pt</xsl:attribute>
		
	</xsl:attribute-set><xsl:attribute-set name="term-name-style">
		<xsl:attribute name="keep-with-next">always</xsl:attribute>
		<xsl:attribute name="font-weight">bold</xsl:attribute>
	</xsl:attribute-set><xsl:attribute-set name="figure-style">
		
	</xsl:attribute-set><xsl:attribute-set name="figure-name-style">
		
		
		
				
		
		
		
					
			<xsl:attribute name="font-weight">bold</xsl:attribute>
			<xsl:attribute name="text-align">center</xsl:attribute>
			<xsl:attribute name="margin-top">12pt</xsl:attribute>
			<xsl:attribute name="margin-bottom">12pt</xsl:attribute>
			<xsl:attribute name="keep-with-previous">always</xsl:attribute>
		
		
		
		
		
		
		
		
		

		
		
		
			
	</xsl:attribute-set><xsl:attribute-set name="formula-style">
		<xsl:attribute name="margin-top">6pt</xsl:attribute>
		<xsl:attribute name="margin-bottom">12pt</xsl:attribute>
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="formula-stem-block-style">
		<xsl:attribute name="text-align">center</xsl:attribute>
		
		
		
		
		
		
			<xsl:attribute name="text-align">left</xsl:attribute>
			<xsl:attribute name="margin-left">5mm</xsl:attribute>
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="formula-stem-number-style">
		<xsl:attribute name="text-align">right</xsl:attribute>
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="image-style">
		<xsl:attribute name="text-align">center</xsl:attribute>
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="figure-pseudocode-p-style">
		
	</xsl:attribute-set><xsl:attribute-set name="image-graphic-style">
		<xsl:attribute name="width">100%</xsl:attribute>
		<xsl:attribute name="content-height">100%</xsl:attribute>
		<xsl:attribute name="scaling">uniform</xsl:attribute>			
		
		
			<xsl:attribute name="content-height">scale-to-fit</xsl:attribute>
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="tt-style">
		
		
			<xsl:attribute name="font-family">Courier New, <xsl:value-of select="$font_noto_sans_mono"/></xsl:attribute>			
		
		
	</xsl:attribute-set><xsl:attribute-set name="sourcecode-name-style">
		<xsl:attribute name="font-size">11pt</xsl:attribute>
		<xsl:attribute name="font-weight">bold</xsl:attribute>
		<xsl:attribute name="text-align">center</xsl:attribute>
		<xsl:attribute name="margin-bottom">12pt</xsl:attribute>
		<xsl:attribute name="keep-with-previous">always</xsl:attribute>
		
	</xsl:attribute-set><xsl:attribute-set name="preferred-block-style">
		
		
		
		
			<xsl:attribute name="line-height">1.1</xsl:attribute>
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="preferred-term-style">
		<xsl:attribute name="keep-with-next">always</xsl:attribute>
		<xsl:attribute name="font-weight">bold</xsl:attribute>
		
		
	</xsl:attribute-set><xsl:attribute-set name="domain-style">
				
	</xsl:attribute-set><xsl:attribute-set name="admitted-style">
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="deprecates-style">
		
		
	</xsl:attribute-set><xsl:attribute-set name="definition-style">
		
		
			<xsl:attribute name="margin-bottom">6pt</xsl:attribute>
		
		
	</xsl:attribute-set><xsl:variable name="color-added-text">
		<xsl:text>rgb(0, 255, 0)</xsl:text>
	</xsl:variable><xsl:attribute-set name="add-style">
		
				<xsl:attribute name="color">red</xsl:attribute>
				<xsl:attribute name="text-decoration">underline</xsl:attribute>
				<!-- <xsl:attribute name="color">black</xsl:attribute>
				<xsl:attribute name="background-color"><xsl:value-of select="$color-added-text"/></xsl:attribute>
				<xsl:attribute name="padding-top">1mm</xsl:attribute>
				<xsl:attribute name="padding-bottom">0.5mm</xsl:attribute> -->
			
	</xsl:attribute-set><xsl:variable name="add-style">
			<add-style xsl:use-attribute-sets="add-style"/>
		</xsl:variable><xsl:template name="append_add-style">
		<xsl:copy-of select="xalan:nodeset($add-style)/add-style/@*"/>
	</xsl:template><xsl:variable name="color-deleted-text">
		<xsl:text>red</xsl:text>
	</xsl:variable><xsl:attribute-set name="del-style">
		<xsl:attribute name="color"><xsl:value-of select="$color-deleted-text"/></xsl:attribute>
		<xsl:attribute name="text-decoration">line-through</xsl:attribute>
	</xsl:attribute-set><xsl:attribute-set name="mathml-style">
		<xsl:attribute name="font-family">STIX Two Math</xsl:attribute>
		
			<xsl:attribute name="font-family">Cambria Math</xsl:attribute>
		
		
	</xsl:attribute-set><xsl:attribute-set name="list-style">
		
		
		
		
		
		
		
		
			<xsl:attribute name="provisional-distance-between-starts">7mm</xsl:attribute>
			<xsl:attribute name="margin-top">8pt</xsl:attribute>
		
		
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="list-name-style">
		<xsl:attribute name="keep-with-next">always</xsl:attribute>
			
		
		
		
		
		
			<xsl:attribute name="margin-top">8pt</xsl:attribute>
			<xsl:attribute name="font-weight">bold</xsl:attribute>
				
		
		
		
				
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="list-item-style">
		
		
	</xsl:attribute-set><xsl:attribute-set name="list-item-label-style">
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="list-item-body-style">
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="toc-style">
		<xsl:attribute name="line-height">135%</xsl:attribute>
	</xsl:attribute-set><xsl:attribute-set name="fn-reference-style">
		<xsl:attribute name="font-size">80%</xsl:attribute>
		<xsl:attribute name="keep-with-previous.within-line">always</xsl:attribute>
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="fn-style">
		<xsl:attribute name="keep-with-previous.within-line">always</xsl:attribute>
	</xsl:attribute-set><xsl:attribute-set name="fn-num-style">
		<xsl:attribute name="keep-with-previous.within-line">always</xsl:attribute>
		
		
		
		
		
		
		
		
		
			<xsl:attribute name="font-size">80%</xsl:attribute>
			<xsl:attribute name="vertical-align">super</xsl:attribute>
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="fn-body-style">
		<xsl:attribute name="font-weight">normal</xsl:attribute>
		<xsl:attribute name="font-style">normal</xsl:attribute>
		<xsl:attribute name="text-indent">0</xsl:attribute>
		<xsl:attribute name="start-indent">0</xsl:attribute>
		
		
		
		
		
		
		
		
		
			<xsl:attribute name="font-size">10pt</xsl:attribute>
			<xsl:attribute name="margin-bottom">12pt</xsl:attribute>
		
		
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="fn-body-num-style">
		<xsl:attribute name="keep-with-next.within-line">always</xsl:attribute>
		
		
		
		
		
		
		
		
		
			<xsl:attribute name="padding-right">3mm</xsl:attribute>
		
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="admonition-style">
		
		
		
		
		
		
		
		
			<xsl:attribute name="margin-bottom">12pt</xsl:attribute>
			<xsl:attribute name="font-weight">bold</xsl:attribute>
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="admonition-container-style">
		<xsl:attribute name="margin-left">0mm</xsl:attribute>
		<xsl:attribute name="margin-right">0mm</xsl:attribute>
		
		
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="admonition-name-style">
		<xsl:attribute name="keep-with-next">always</xsl:attribute>
		
		
		
		
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="admonition-p-style">
		
		
		
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="bibitem-normative-style">
		
		
		
		
		
		
		
		
			<xsl:attribute name="margin-bottom">6pt</xsl:attribute>
		
		
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="bibitem-normative-list-style">
		<xsl:attribute name="provisional-distance-between-starts">12mm</xsl:attribute>
		<xsl:attribute name="margin-bottom">12pt</xsl:attribute>
		
		
		
		
		<!-- <xsl:if test="$namespace = 'ieee'">
			<xsl:attribute name="margin-bottom">6pt</xsl:attribute>
			<xsl:attribute name="provisional-distance-between-starts">9.5mm</xsl:attribute>
		</xsl:if> -->
		
		
			<xsl:attribute name="margin-bottom">6pt</xsl:attribute>
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="bibitem-non-normative-style">
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="bibitem-non-normative-list-style">
		<xsl:attribute name="provisional-distance-between-starts">12mm</xsl:attribute>
		<xsl:attribute name="margin-bottom">12pt</xsl:attribute>
		
		
		
		
		
		
		
			<xsl:attribute name="margin-bottom">6pt</xsl:attribute>
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="bibitem-normative-list-body-style">
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="bibitem-non-normative-list-body-style">
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="bibitem-note-fn-style">
		<xsl:attribute name="keep-with-previous.within-line">always</xsl:attribute>
		<xsl:attribute name="font-size">65%</xsl:attribute>
		
		
		
		
		
		
		
		
		
			<xsl:attribute name="font-size">8pt</xsl:attribute>
			<xsl:attribute name="baseline-shift">30%</xsl:attribute>
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="bibitem-note-fn-number-style">
		<xsl:attribute name="keep-with-next.within-line">always</xsl:attribute>
		
		
		
		
		
		
		
		
		
			<xsl:attribute name="alignment-baseline">hanging</xsl:attribute>
			<xsl:attribute name="padding-right">3mm</xsl:attribute>
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="bibitem-note-fn-body-style">
		<xsl:attribute name="font-size">10pt</xsl:attribute>
		<xsl:attribute name="margin-bottom">12pt</xsl:attribute>
		<xsl:attribute name="start-indent">0pt</xsl:attribute>
		
		
		
		
		
		
		
			<xsl:attribute name="margin-bottom">4pt</xsl:attribute>
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="references-non-normative-style">
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="hljs-doctag">
		<xsl:attribute name="color">#d73a49</xsl:attribute>
	</xsl:attribute-set><xsl:attribute-set name="hljs-keyword">
		<xsl:attribute name="color">#d73a49</xsl:attribute>
	</xsl:attribute-set><xsl:attribute-set name="hljs-meta_hljs-keyword">
		<xsl:attribute name="color">#d73a49</xsl:attribute>
	</xsl:attribute-set><xsl:attribute-set name="hljs-template-tag">
		<xsl:attribute name="color">#d73a49</xsl:attribute>
	</xsl:attribute-set><xsl:attribute-set name="hljs-template-variable">
		<xsl:attribute name="color">#d73a49</xsl:attribute>
	</xsl:attribute-set><xsl:attribute-set name="hljs-type">
		<xsl:attribute name="color">#d73a49</xsl:attribute>
	</xsl:attribute-set><xsl:attribute-set name="hljs-variable_and_language_">
		<xsl:attribute name="color">#d73a49</xsl:attribute>
	</xsl:attribute-set><xsl:attribute-set name="hljs-title">
		<xsl:attribute name="color">#6f42c1</xsl:attribute>
	</xsl:attribute-set><xsl:attribute-set name="hljs-title_and_class_">
		<xsl:attribute name="color">#6f42c1</xsl:attribute>
	</xsl:attribute-set><xsl:attribute-set name="hljs-title_and_class__and_inherited__">
		<xsl:attribute name="color">#6f42c1</xsl:attribute>
	</xsl:attribute-set><xsl:attribute-set name="hljs-title_and_function_">
		<xsl:attribute name="color">#6f42c1</xsl:attribute>
	</xsl:attribute-set><xsl:attribute-set name="hljs-attr">
		<xsl:attribute name="color">#005cc5</xsl:attribute>
	</xsl:attribute-set><xsl:attribute-set name="hljs-attribute">
		<xsl:attribute name="color">#005cc5</xsl:attribute>
	</xsl:attribute-set><xsl:attribute-set name="hljs-literal">
		<xsl:attribute name="color">#005cc5</xsl:attribute>
	</xsl:attribute-set><xsl:attribute-set name="hljs-meta">
		<xsl:attribute name="color">#005cc5</xsl:attribute>
	</xsl:attribute-set><xsl:attribute-set name="hljs-number">
		<xsl:attribute name="color">#005cc5</xsl:attribute>
	</xsl:attribute-set><xsl:attribute-set name="hljs-operator">
		<xsl:attribute name="color">#005cc5</xsl:attribute>
	</xsl:attribute-set><xsl:attribute-set name="hljs-variable">
		<xsl:attribute name="color">#005cc5</xsl:attribute>
	</xsl:attribute-set><xsl:attribute-set name="hljs-selector-attr">
		<xsl:attribute name="color">#005cc5</xsl:attribute>
	</xsl:attribute-set><xsl:attribute-set name="hljs-selector-class">
		<xsl:attribute name="color">#005cc5</xsl:attribute>
	</xsl:attribute-set><xsl:attribute-set name="hljs-selector-id">
		<xsl:attribute name="color">#005cc5</xsl:attribute>
	</xsl:attribute-set><xsl:attribute-set name="hljs-regexp">
		<xsl:attribute name="color">#032f62</xsl:attribute>
	</xsl:attribute-set><xsl:attribute-set name="hljs-string">
		<xsl:attribute name="color">#032f62</xsl:attribute>
	</xsl:attribute-set><xsl:attribute-set name="hljs-meta_hljs-string">
		<xsl:attribute name="color">#032f62</xsl:attribute>
	</xsl:attribute-set><xsl:attribute-set name="hljs-built_in">
		<xsl:attribute name="color">#e36209</xsl:attribute>
	</xsl:attribute-set><xsl:attribute-set name="hljs-symbol">
		<xsl:attribute name="color">#e36209</xsl:attribute>
	</xsl:attribute-set><xsl:attribute-set name="hljs-comment">
		<xsl:attribute name="color">#6a737d</xsl:attribute>
	</xsl:attribute-set><xsl:attribute-set name="hljs-code">
		<xsl:attribute name="color">#6a737d</xsl:attribute>
	</xsl:attribute-set><xsl:attribute-set name="hljs-formula">
		<xsl:attribute name="color">#6a737d</xsl:attribute>
	</xsl:attribute-set><xsl:attribute-set name="hljs-name">
		<xsl:attribute name="color">#22863a</xsl:attribute>
	</xsl:attribute-set><xsl:attribute-set name="hljs-quote">
		<xsl:attribute name="color">#22863a</xsl:attribute>
	</xsl:attribute-set><xsl:attribute-set name="hljs-selector-tag">
		<xsl:attribute name="color">#22863a</xsl:attribute>
	</xsl:attribute-set><xsl:attribute-set name="hljs-selector-pseudo">
		<xsl:attribute name="color">#22863a</xsl:attribute>
	</xsl:attribute-set><xsl:attribute-set name="hljs-subst">
		<xsl:attribute name="color">#24292e</xsl:attribute>
	</xsl:attribute-set><xsl:attribute-set name="hljs-section">
		<xsl:attribute name="color">#005cc5</xsl:attribute>
		<xsl:attribute name="font-weight">bold</xsl:attribute>
	</xsl:attribute-set><xsl:attribute-set name="hljs-bullet">
		<xsl:attribute name="color">#735c0f</xsl:attribute>
	</xsl:attribute-set><xsl:attribute-set name="hljs-emphasis">
		<xsl:attribute name="color">#24292e</xsl:attribute>
		<xsl:attribute name="font-style">italic</xsl:attribute>
	</xsl:attribute-set><xsl:attribute-set name="hljs-strong">
		<xsl:attribute name="color">#24292e</xsl:attribute>
		<xsl:attribute name="font-weight">bold</xsl:attribute>
	</xsl:attribute-set><xsl:attribute-set name="hljs-addition">
		<xsl:attribute name="color">#22863a</xsl:attribute>
		<xsl:attribute name="background-color">#f0fff4</xsl:attribute>
	</xsl:attribute-set><xsl:attribute-set name="hljs-deletion">
		<xsl:attribute name="color">#b31d28</xsl:attribute>
		<xsl:attribute name="background-color">#ffeef0</xsl:attribute>
	</xsl:attribute-set><xsl:attribute-set name="hljs-char_and_escape_">
	</xsl:attribute-set><xsl:attribute-set name="hljs-link">
	</xsl:attribute-set><xsl:attribute-set name="hljs-params">
	</xsl:attribute-set><xsl:attribute-set name="hljs-property">
	</xsl:attribute-set><xsl:attribute-set name="hljs-punctuation">
	</xsl:attribute-set><xsl:attribute-set name="hljs-tag">
	</xsl:attribute-set><xsl:attribute-set name="indexsect-title-style">
		<xsl:attribute name="role">H1</xsl:attribute>
		
		
		
		
			<xsl:attribute name="font-size">16pt</xsl:attribute>
			<xsl:attribute name="font-weight">bold</xsl:attribute>
			<xsl:attribute name="margin-bottom">84pt</xsl:attribute>
		
		
	</xsl:attribute-set><xsl:attribute-set name="indexsect-clause-title-style">
		<xsl:attribute name="keep-with-next">always</xsl:attribute>
		
		
		
		
			<xsl:attribute name="font-size">10pt</xsl:attribute>
			<xsl:attribute name="font-weight">bold</xsl:attribute>
			<xsl:attribute name="margin-bottom">3pt</xsl:attribute>
		
		
	</xsl:attribute-set><xsl:variable name="border-block-added">2.5pt solid rgb(0, 176, 80)</xsl:variable><xsl:variable name="border-block-deleted">2.5pt solid rgb(255, 0, 0)</xsl:variable><xsl:variable name="ace_tag">ace-tag_</xsl:variable><xsl:template name="processPrefaceSectionsDefault_Contents">
		<xsl:variable name="nodes_preface_">
			<xsl:for-each select="/*/*[local-name()='preface']/*[not(local-name() = 'note' or local-name() = 'admonition')]">
				<node id="{@id}"/>
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="nodes_preface" select="xalan:nodeset($nodes_preface_)"/>
		
		<xsl:for-each select="/*/*[local-name()='preface']/*[not(local-name() = 'note' or local-name() = 'admonition')]">
			<xsl:sort select="@displayorder" data-type="number"/>
			
			<!-- process Section's title -->
			<xsl:variable name="preceding-sibling_id" select="$nodes_preface/node[@id = current()/@id]/preceding-sibling::node[1]/@id"/>
			<xsl:if test="$preceding-sibling_id != ''">
				<xsl:apply-templates select="parent::*/*[@type = 'section-title' and @id = $preceding-sibling_id and not(@displayorder)]" mode="contents_no_displayorder"/>
			</xsl:if>
			
			<xsl:apply-templates select="." mode="contents"/>
		</xsl:for-each>
	</xsl:template><xsl:template name="processMainSectionsDefault_Contents">
	
		<xsl:variable name="nodes_sections_">
			<xsl:for-each select="/*/*[local-name()='sections']/*">
				<node id="{@id}"/>
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="nodes_sections" select="xalan:nodeset($nodes_sections_)"/>
		
		<xsl:for-each select="/*/*[local-name()='sections']/* | /*/*[local-name()='bibliography']/*[local-name()='references'][@normative='true'] |    /*/*[local-name()='bibliography']/*[local-name()='clause'][*[local-name()='references'][@normative='true']]">
			<xsl:sort select="@displayorder" data-type="number"/>
			
			<!-- process Section's title -->
			<xsl:variable name="preceding-sibling_id" select="$nodes_sections/node[@id = current()/@id]/preceding-sibling::node[1]/@id"/>
			<xsl:if test="$preceding-sibling_id != ''">
				<xsl:apply-templates select="parent::*/*[@type = 'section-title' and @id = $preceding-sibling_id and not(@displayorder)]" mode="contents_no_displayorder"/>
			</xsl:if>
			
			<xsl:apply-templates select="." mode="contents"/>
		</xsl:for-each>
		
		<xsl:for-each select="/*/*[local-name()='annex']">
			<xsl:sort select="@displayorder" data-type="number"/>
			<xsl:apply-templates select="." mode="contents"/>
		</xsl:for-each>
		
		<xsl:for-each select="/*/*[local-name()='bibliography']/*[not(@normative='true') and not(*[local-name()='references'][@normative='true'])] |          /*/*[local-name()='bibliography']/*[local-name()='clause'][*[local-name()='references'][not(@normative='true')]]">
			<xsl:sort select="@displayorder" data-type="number"/>
			<xsl:apply-templates select="." mode="contents"/>
		</xsl:for-each>
	</xsl:template><xsl:template name="processTablesFigures_Contents">
		<xsl:param name="always"/>
		<xsl:if test="(//*[contains(local-name(), '-standard')]/*[local-name() = 'misc-container']/*[local-name() = 'toc'][@type='table']/*[local-name() = 'title']) or normalize-space($always) = 'true'">
			<xsl:call-template name="processTables_Contents"/>
		</xsl:if>
		<xsl:if test="(//*[contains(local-name(), '-standard')]/*[local-name() = 'misc-container']/*[local-name() = 'toc'][@type='figure']/*[local-name() = 'title']) or normalize-space($always) = 'true'">
			<xsl:call-template name="processFigures_Contents"/>
		</xsl:if>
	</xsl:template><xsl:template name="processTables_Contents">
		<tables>
			<xsl:for-each select="//*[local-name() = 'table'][@id and *[local-name() = 'name'] and normalize-space(@id) != '']">
				<table id="{@id}" alt-text="{*[local-name() = 'name']}">
					<xsl:copy-of select="*[local-name() = 'name']"/>
				</table>
			</xsl:for-each>
		</tables>
	</xsl:template><xsl:template name="processFigures_Contents">
		<figures>
			<xsl:for-each select="//*[local-name() = 'figure'][@id and *[local-name() = 'name'] and not(@unnumbered = 'true') and normalize-space(@id) != ''] | //*[@id and starts-with(*[local-name() = 'name'], 'Figure ') and normalize-space(@id) != '']">
				<figure id="{@id}" alt-text="{*[local-name() = 'name']}">
					<xsl:copy-of select="*[local-name() = 'name']"/>
				</figure>
			</xsl:for-each>
		</figures>
	</xsl:template><xsl:template name="processPrefaceSectionsDefault">
		<xsl:for-each select="/*/*[local-name()='preface']/*[not(local-name() = 'note' or local-name() = 'admonition')]">
			<xsl:sort select="@displayorder" data-type="number"/>
			<xsl:apply-templates select="."/>
		</xsl:for-each>
	</xsl:template><xsl:template name="processMainSectionsDefault">
		<xsl:for-each select="/*/*[local-name()='sections']/* | /*/*[local-name()='bibliography']/*[local-name()='references'][@normative='true']">
			<xsl:sort select="@displayorder" data-type="number"/>
			<xsl:apply-templates select="."/>
			
		</xsl:for-each>
		
		<xsl:for-each select="/*/*[local-name()='annex']">
			<xsl:sort select="@displayorder" data-type="number"/>
			<xsl:apply-templates select="."/>
		</xsl:for-each>
		
		<xsl:for-each select="/*/*[local-name()='bibliography']/*[not(@normative='true')] |          /*/*[local-name()='bibliography']/*[local-name()='clause'][*[local-name()='references'][not(@normative='true')]]">
			<xsl:sort select="@displayorder" data-type="number"/>
			<xsl:apply-templates select="."/>
		</xsl:for-each>
	</xsl:template><xsl:variable name="tag_fo_inline_keep-together_within-line_open">###fo:inline keep-together_within-line###</xsl:variable><xsl:variable name="tag_fo_inline_keep-together_within-line_close">###/fo:inline keep-together_within-line###</xsl:variable><xsl:template match="text()" name="text">
		<xsl:value-of select="."/>
	</xsl:template><xsl:template name="replace_fo_inline_tags">
		<xsl:param name="tag_open"/>
		<xsl:param name="tag_close"/>
		<xsl:param name="text"/>
		<xsl:choose>
			<xsl:when test="contains($text, $tag_open)">
				<xsl:value-of select="substring-before($text, $tag_open)"/>
				<!-- <xsl:text disable-output-escaping="yes">&lt;fo:inline keep-together.within-line="always"&gt;</xsl:text> -->
				<xsl:variable name="text_after" select="substring-after($text, $tag_open)"/>
				<fo:inline keep-together.within-line="always">
					<xsl:value-of select="substring-before($text_after, $tag_close)"/>
				</fo:inline>
				<!-- <xsl:text disable-output-escaping="yes">&lt;/fo:inline&gt;</xsl:text> -->
				<xsl:call-template name="replace_fo_inline_tags">
					<xsl:with-param name="tag_open" select="$tag_open"/>
					<xsl:with-param name="tag_close" select="$tag_close"/>
					<xsl:with-param name="text" select="substring-after($text_after, $tag_close)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise><xsl:value-of select="$text"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template match="*[local-name()='br']">
		<xsl:value-of select="$linebreak"/>
	</xsl:template><xsl:template match="*[local-name() = 'keep-together_within-line']">
		<xsl:param name="split_keep-within-line"/>
		
		<!-- <fo:inline>split_keep-within-line='<xsl:value-of select="$split_keep-within-line"/>'</fo:inline> -->
		<xsl:choose>
		
			<xsl:when test="normalize-space($split_keep-within-line) = 'true'">
				<xsl:variable name="sep">_</xsl:variable>
				<xsl:variable name="items">
					<xsl:call-template name="split">
						<xsl:with-param name="pText" select="."/>
						<xsl:with-param name="sep" select="$sep"/>
						<xsl:with-param name="normalize-space">false</xsl:with-param>
						<xsl:with-param name="keep_sep">true</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>
				<xsl:for-each select="xalan:nodeset($items)/item">
					<xsl:choose>
						<xsl:when test=". = $sep">
							<xsl:value-of select="$sep"/><xsl:value-of select="$zero_width_space"/>
						</xsl:when>
						<xsl:otherwise>
							<fo:inline keep-together.within-line="always"><xsl:apply-templates/></fo:inline>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</xsl:when>
			
			<xsl:otherwise>
				<fo:inline keep-together.within-line="always"><xsl:apply-templates/></fo:inline>
			</xsl:otherwise>
			
		</xsl:choose>
	</xsl:template><xsl:template match="*[local-name()='copyright-statement']">
		<fo:block xsl:use-attribute-sets="copyright-statement-style">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name()='copyright-statement']//*[local-name()='title']">
		
				<!-- process in the template 'title' -->
				<xsl:call-template name="title"/>
			
	</xsl:template><xsl:template match="*[local-name()='copyright-statement']//*[local-name()='p']">
		
		
				<!-- process in the template 'paragraph' -->
				<xsl:call-template name="paragraph"/>
			
	</xsl:template><xsl:template match="*[local-name()='license-statement']">
		<fo:block xsl:use-attribute-sets="license-statement-style">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name()='license-statement']//*[local-name()='title']">
		
				<xsl:variable name="level">
					<xsl:call-template name="getLevel"/>
				</xsl:variable>
				<fo:block role="H{$level}" xsl:use-attribute-sets="license-statement-title-style">
					<xsl:apply-templates/>
				</fo:block>
			
	</xsl:template><xsl:template match="*[local-name()='license-statement']//*[local-name()='p']">
		
				<fo:block xsl:use-attribute-sets="license-statement-p-style">
		
					
						<xsl:if test="following-sibling::*[local-name() = 'p']">
							<xsl:attribute name="margin-top">6pt</xsl:attribute>
							<xsl:attribute name="margin-bottom">6pt</xsl:attribute>
						</xsl:if>
					
					
					
					
					<xsl:apply-templates/>
				</fo:block>
			
	</xsl:template><xsl:template match="*[local-name()='legal-statement']">
		<fo:block xsl:use-attribute-sets="legal-statement-style">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name()='legal-statement']//*[local-name()='title']">
		
				<!-- process in the template 'title' -->
				<xsl:call-template name="title"/>
			
	
	</xsl:template><xsl:template match="*[local-name()='legal-statement']//*[local-name()='p']">
		<xsl:param name="margin"/>
		
				<!-- process in the template 'paragraph' -->
				<xsl:call-template name="paragraph">
					<xsl:with-param name="margin" select="$margin"/>
				</xsl:call-template>
			
	</xsl:template><xsl:template match="*[local-name()='feedback-statement']">
		<fo:block xsl:use-attribute-sets="feedback-statement-style">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name()='feedback-statement']//*[local-name()='title']">
		
				<!-- process in the template 'title' -->
				<xsl:call-template name="title"/>
			
	</xsl:template><xsl:template match="*[local-name()='feedback-statement']//*[local-name()='p']">
		<xsl:param name="margin"/>
		
				<!-- process in the template 'paragraph' -->
				<xsl:call-template name="paragraph">
					<xsl:with-param name="margin" select="$margin"/>
				</xsl:call-template>
			
	</xsl:template><xsl:template match="*[local-name()='td']//text() | *[local-name()='th']//text() | *[local-name()='dt']//text() | *[local-name()='dd']//text()" priority="1">
		<xsl:choose>
			<xsl:when test="parent::*[local-name() = 'keep-together_within-line']">
				<xsl:value-of select="."/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="addZeroWidthSpacesToTextNodes"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="addZeroWidthSpacesToTextNodes">
		<xsl:variable name="text"><text><xsl:call-template name="text"/></text></xsl:variable>
		<!-- <xsl:copy-of select="$text"/> -->
		<xsl:for-each select="xalan:nodeset($text)/text/node()">
			<xsl:choose>
				<xsl:when test="self::text()"><xsl:call-template name="add-zero-spaces-java"/></xsl:when>
				<xsl:otherwise><xsl:copy-of select="."/></xsl:otherwise> <!-- copy 'as-is' for <fo:inline keep-together.within-line="always" ...  -->
			</xsl:choose>
		</xsl:for-each>
	</xsl:template><xsl:template match="*[local-name()='table']" name="table">
	
		<xsl:variable name="table-preamble">
			
			
		</xsl:variable>
		
		<xsl:variable name="table">
	
			<xsl:variable name="simple-table">
				<xsl:call-template name="getSimpleTable">
					<xsl:with-param name="id" select="@id"/>
				</xsl:call-template>
			</xsl:variable>
			<!-- <xsl:variable name="simple-table" select="xalan:nodeset($simple-table_)"/> -->
		
			<!-- simple-table=<xsl:copy-of select="$simple-table"/> -->
		
			
			<!-- Display table's name before table as standalone block -->
			<!-- $namespace = 'iso' or  -->
			
			
			
			
			<xsl:variable name="cols-count" select="count(xalan:nodeset($simple-table)/*/tr[1]/td)"/>
			
			<xsl:variable name="colwidths">
				<xsl:if test="not(*[local-name()='colgroup']/*[local-name()='col'])">
					<xsl:call-template name="calculate-column-widths">
						<xsl:with-param name="cols-count" select="$cols-count"/>
						<xsl:with-param name="table" select="$simple-table"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:variable>
			<!-- <xsl:variable name="colwidths" select="xalan:nodeset($colwidths_)"/> -->
			
			<!-- DEBUG -->
			<xsl:if test="$table_if_debug = 'true'">
				<fo:block font-size="60%">
					<xsl:apply-templates select="xalan:nodeset($colwidths)" mode="print_as_xml"/>
				</fo:block>
			</xsl:if>
			
			
			<!-- <xsl:copy-of select="$colwidths"/> -->
			
			<!-- <xsl:text disable-output-escaping="yes">&lt;!- -</xsl:text>
			DEBUG
			colwidths=<xsl:copy-of select="$colwidths"/>
		<xsl:text disable-output-escaping="yes">- -&gt;</xsl:text> -->
			
			
			
			<xsl:variable name="margin-side">
				<xsl:choose>
					<xsl:when test="sum(xalan:nodeset($colwidths)//column) &gt; 75">15</xsl:when>
					<xsl:otherwise>0</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			
			<fo:block-container xsl:use-attribute-sets="table-container-style">
			
				
			
				
			
				
			
				
				
				
				
				
			
				
				
				
				
				
				<!-- end table block-container attributes -->
				
				<!-- display table's name before table for PAS inside block-container (2-columnn layout) -->
				
				
				<xsl:variable name="table_width_default">100%</xsl:variable>
				<xsl:variable name="table_width">
					<!-- for centered table always 100% (@width will be set for middle/second cell of outer table) -->
					<xsl:value-of select="$table_width_default"/>
				</xsl:variable>
				
				
				<xsl:variable name="table_attributes">
				
					<xsl:element name="table_attributes" use-attribute-sets="table-style">
						<xsl:attribute name="width"><xsl:value-of select="normalize-space($table_width)"/></xsl:attribute>
						
						
						
						
						
						
						
						
						
						
							<xsl:if test="*[local-name()='thead']">
								<xsl:attribute name="border-top">1pt solid black</xsl:attribute>
							</xsl:if>
							<xsl:if test="ancestor::*[local-name() = 'table']">
								<!-- for internal table in table cell -->
								<xsl:attribute name="border">0.5pt solid black</xsl:attribute>
							</xsl:if>
						
						
						
						
						
						
						
					</xsl:element>
				</xsl:variable>
				
				<xsl:if test="$isGenerateTableIF = 'true'">
					<!-- to determine start of table -->
					<fo:block id="{concat('table_if_start_',@id)}" keep-with-next="always" font-size="1pt">Start table '<xsl:value-of select="@id"/>'.</fo:block>
				</xsl:if>
				
				<fo:table id="{@id}">
					
					<xsl:if test="$isGenerateTableIF = 'true'">
						<xsl:attribute name="wrap-option">no-wrap</xsl:attribute>
					</xsl:if>
					
					<xsl:for-each select="xalan:nodeset($table_attributes)/table_attributes/@*">					
						<xsl:attribute name="{local-name()}">
							<xsl:value-of select="."/>
						</xsl:attribute>
					</xsl:for-each>
					
					<xsl:variable name="isNoteOrFnExist" select="./*[local-name()='note'] or .//*[local-name()='fn'][local-name(..) != 'name']"/>				
					<xsl:if test="$isNoteOrFnExist = 'true'">
						<xsl:attribute name="border-bottom">0pt solid black</xsl:attribute> <!-- set 0pt border, because there is a separete table below for footer  -->
					</xsl:if>
					
					
					<xsl:choose>
						<xsl:when test="$isGenerateTableIF = 'true'">
							<!-- generate IF for table widths -->
							<!-- example:
								<tr>
									<td valign="top" align="left" id="tab-symdu_1_1">
										<p>Symbol</p>
										<word id="tab-symdu_1_1_word_1">Symbol</word>
									</td>
									<td valign="top" align="left" id="tab-symdu_1_2">
										<p>Description</p>
										<word id="tab-symdu_1_2_word_1">Description</word>
									</td>
								</tr>
							-->
							<xsl:apply-templates select="xalan:nodeset($simple-table)" mode="process_table-if"/>
							
						</xsl:when>
						<xsl:otherwise>
					
							<xsl:choose>
								<xsl:when test="*[local-name()='colgroup']/*[local-name()='col']">
									<xsl:for-each select="*[local-name()='colgroup']/*[local-name()='col']">
										<fo:table-column column-width="{@width}"/>
									</xsl:for-each>
								</xsl:when>
								<xsl:otherwise>
									<xsl:call-template name="insertTableColumnWidth">
										<xsl:with-param name="colwidths" select="$colwidths"/>
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>
							
							<xsl:choose>
								<xsl:when test="not(*[local-name()='tbody']) and *[local-name()='thead']">
									<xsl:apply-templates select="*[local-name()='thead']" mode="process_tbody"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:apply-templates select="node()[not(local-name() = 'name') and not(local-name() = 'note')          and not(local-name() = 'thead') and not(local-name() = 'tfoot')]"/> <!-- process all table' elements, except name, header, footer and note that renders separaterely -->
								</xsl:otherwise>
							</xsl:choose>
					
						</xsl:otherwise>
					</xsl:choose>
					
				</fo:table>
				
				<xsl:variable name="colgroup" select="*[local-name()='colgroup']"/>				
				<xsl:for-each select="*[local-name()='tbody']"><!-- select context to tbody -->
					<xsl:call-template name="insertTableFooterInSeparateTable">
						<xsl:with-param name="table_attributes" select="$table_attributes"/>
						<xsl:with-param name="colwidths" select="$colwidths"/>				
						<xsl:with-param name="colgroup" select="$colgroup"/>				
					</xsl:call-template>
				</xsl:for-each>
				
				
				
				
				
				
				<xsl:if test="*[local-name()='bookmark']"> <!-- special case: table/bookmark -->
					<fo:block keep-with-previous="always" line-height="0.1">
						<xsl:for-each select="*[local-name()='bookmark']">
							<xsl:call-template name="bookmark"/>
						</xsl:for-each>
					</fo:block>
				</xsl:if>
				
			</fo:block-container>
		</xsl:variable>
		
		<xsl:variable name="isAdded" select="@added"/>
		<xsl:variable name="isDeleted" select="@deleted"/>
		
		<xsl:choose>
			<xsl:when test="@width">
	
				<!-- centered table when table name is centered (see table-name-style) -->
				
					<fo:table table-layout="fixed" width="100%">
						<fo:table-column column-width="proportional-column-width(1)"/>
						<fo:table-column column-width="{@width}"/>
						<fo:table-column column-width="proportional-column-width(1)"/>
						<fo:table-body>
							<fo:table-row>
								<fo:table-cell column-number="2">
									<xsl:copy-of select="$table-preamble"/>
									<fo:block>
										<xsl:call-template name="setTrackChangesStyles">
											<xsl:with-param name="isAdded" select="$isAdded"/>
											<xsl:with-param name="isDeleted" select="$isDeleted"/>
										</xsl:call-template>
										<xsl:copy-of select="$table"/>
									</fo:block>
								</fo:table-cell>
							</fo:table-row>
						</fo:table-body>
					</fo:table>
				
				
				
				
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$isAdded = 'true' or $isDeleted = 'true'">
						<xsl:copy-of select="$table-preamble"/>
						<fo:block>
							<xsl:call-template name="setTrackChangesStyles">
								<xsl:with-param name="isAdded" select="$isAdded"/>
								<xsl:with-param name="isDeleted" select="$isDeleted"/>
							</xsl:call-template>
							<xsl:copy-of select="$table"/>
						</fo:block>
					</xsl:when>
					<xsl:otherwise>
						<xsl:copy-of select="$table-preamble"/>
						<xsl:copy-of select="$table"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template><xsl:template match="*[local-name()='table']/*[local-name() = 'name']">
		<xsl:param name="continued"/>
		<xsl:if test="normalize-space() != ''">
		
			
				
					<fo:block xsl:use-attribute-sets="table-name-style">

						
						
						
						
						<xsl:choose>
							<xsl:when test="$continued = 'true'"> 
								
									<xsl:apply-templates/>
								
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates/>
							</xsl:otherwise>
						</xsl:choose>
						
						
					</fo:block>
			
				
			
		</xsl:if>
	</xsl:template><xsl:template name="calculate-columns-numbers">
		<xsl:param name="table-row"/>
		<xsl:variable name="columns-count" select="count($table-row/*)"/>
		<xsl:variable name="sum-colspans" select="sum($table-row/*/@colspan)"/>
		<xsl:variable name="columns-with-colspan" select="count($table-row/*[@colspan])"/>
		<xsl:value-of select="$columns-count + $sum-colspans - $columns-with-colspan"/>
	</xsl:template><xsl:template name="calculate-column-widths">
		<xsl:param name="table"/>
		<xsl:param name="cols-count"/>
		
				<xsl:call-template name="get-calculated-column-widths-autolayout-algorithm"/>
			
	</xsl:template><xsl:template name="calculate-column-widths-proportional">
		<xsl:param name="table"/>
		<xsl:param name="cols-count"/>
		<xsl:param name="curr-col" select="1"/>
		<xsl:param name="width" select="0"/>
		
		<!-- table=<xsl:copy-of select="$table"/> -->
		
		<xsl:if test="$curr-col &lt;= $cols-count">
			<xsl:variable name="widths">
				<xsl:choose>
					<xsl:when test="not($table)"><!-- this branch is not using in production, for debug only -->
						<xsl:for-each select="*[local-name()='thead']//*[local-name()='tr']">
							<xsl:variable name="words">
								<xsl:call-template name="tokenize">
									<xsl:with-param name="text" select="translate(*[local-name()='th'][$curr-col],'- —:', '    ')"/>
								</xsl:call-template>
							</xsl:variable>
							<xsl:variable name="max_length">
								<xsl:call-template name="max_length">
									<xsl:with-param name="words" select="xalan:nodeset($words)"/>
								</xsl:call-template>
							</xsl:variable>
							<width>
								<xsl:value-of select="$max_length"/>
							</width>
						</xsl:for-each>
						<xsl:for-each select="*[local-name()='tbody']//*[local-name()='tr']">
							<xsl:variable name="words">
								<xsl:call-template name="tokenize">
									<xsl:with-param name="text" select="translate(*[local-name()='td'][$curr-col],'- —:', '    ')"/>
								</xsl:call-template>
							</xsl:variable>
							<xsl:variable name="max_length">
								<xsl:call-template name="max_length">
									<xsl:with-param name="words" select="xalan:nodeset($words)"/>
								</xsl:call-template>
							</xsl:variable>
							<width>
								<xsl:value-of select="$max_length"/>
							</width>
							
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<!-- <curr_col><xsl:value-of select="$curr-col"/></curr_col> -->
						
						<!-- <table><xsl:copy-of select="$table"/></table>
						 -->
						<xsl:for-each select="xalan:nodeset($table)/*/*[local-name()='tr']">
							<xsl:variable name="td_text">
								<xsl:apply-templates select="td[$curr-col]" mode="td_text"/>
							</xsl:variable>
							<!-- <td_text><xsl:value-of select="$td_text"/></td_text> -->
							<xsl:variable name="words">
								<xsl:variable name="string_with_added_zerospaces">
									<xsl:call-template name="add-zero-spaces-java">
										<xsl:with-param name="text" select="$td_text"/>
									</xsl:call-template>
								</xsl:variable>
								<!-- <xsl:message>string_with_added_zerospaces=<xsl:value-of select="$string_with_added_zerospaces"/></xsl:message> -->
								<xsl:call-template name="tokenize">
									<!-- <xsl:with-param name="text" select="translate(td[$curr-col],'- —:', '    ')"/> -->
									<!-- 2009 thinspace -->
									<!-- <xsl:with-param name="text" select="translate(normalize-space($td_text),'- —:', '    ')"/> -->
									<xsl:with-param name="text" select="normalize-space(translate($string_with_added_zerospaces, '​­', '  '))"/> <!-- replace zero-width-space and soft-hyphen to space -->
								</xsl:call-template>
							</xsl:variable>
							<!-- words=<xsl:copy-of select="$words"/> -->
							<xsl:variable name="max_length">
								<xsl:call-template name="max_length">
									<xsl:with-param name="words" select="xalan:nodeset($words)"/>
								</xsl:call-template>
							</xsl:variable>
							<!-- <xsl:message>max_length=<xsl:value-of select="$max_length"/></xsl:message> -->
							<width>
								<xsl:variable name="divider">
									<xsl:choose>
										<xsl:when test="td[$curr-col]/@divide">
											<xsl:value-of select="td[$curr-col]/@divide"/>
										</xsl:when>
										<xsl:otherwise>1</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>
								<xsl:value-of select="$max_length div $divider"/>
							</width>
							
						</xsl:for-each>
					
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<!-- widths=<xsl:copy-of select="$widths"/> -->
			
			<column>
				<xsl:for-each select="xalan:nodeset($widths)//width">
					<xsl:sort select="." data-type="number" order="descending"/>
					<xsl:if test="position()=1">
							<xsl:value-of select="."/>
					</xsl:if>
				</xsl:for-each>
			</column>
			<xsl:call-template name="calculate-column-widths-proportional">
				<xsl:with-param name="cols-count" select="$cols-count"/>
				<xsl:with-param name="curr-col" select="$curr-col +1"/>
				<xsl:with-param name="table" select="$table"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template><xsl:template match="*[@keep-together.within-line or local-name() = 'keep-together_within-line']/text()" priority="2" mode="td_text">
		<!-- <xsl:message>DEBUG t1=<xsl:value-of select="."/></xsl:message>
		<xsl:message>DEBUG t2=<xsl:value-of select="java:replaceAll(java:java.lang.String.new(.),'.','X')"/></xsl:message> -->
		<xsl:value-of select="java:replaceAll(java:java.lang.String.new(.),'.','X')"/>
		
		<!-- if all capitals english letters or digits -->
		<xsl:if test="normalize-space(translate(., concat($upper,'0123456789'), '')) = ''">
			<xsl:call-template name="repeat">
				<xsl:with-param name="char" select="'X'"/>
				<xsl:with-param name="count" select="string-length(normalize-space(.)) * 0.5"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template><xsl:template match="text()" mode="td_text">
		<xsl:value-of select="translate(., $zero_width_space, ' ')"/><xsl:text> </xsl:text>
	</xsl:template><xsl:template match="*[local-name()='termsource']" mode="td_text">
		<xsl:value-of select="*[local-name()='origin']/@citeas"/>
	</xsl:template><xsl:template match="*[local-name()='link']" mode="td_text">
		<xsl:value-of select="@target"/>
	</xsl:template><xsl:template match="*[local-name()='math']" mode="td_text" name="math_length">
		<xsl:if test="$isGenerateTableIF = 'false'">
			<xsl:variable name="mathml_">
				<xsl:for-each select="*">
					<xsl:if test="local-name() != 'unit' and local-name() != 'prefix' and local-name() != 'dimension' and local-name() != 'quantity'">
						<xsl:copy-of select="."/>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>
			<xsl:variable name="mathml" select="xalan:nodeset($mathml_)"/>

			<xsl:variable name="math_text">
				<xsl:value-of select="normalize-space($mathml)"/>
				<xsl:for-each select="$mathml//@open"><xsl:value-of select="."/></xsl:for-each>
				<xsl:for-each select="$mathml//@close"><xsl:value-of select="."/></xsl:for-each>
			</xsl:variable>
			<xsl:value-of select="translate($math_text, ' ', '#')"/><!-- mathml images as one 'word' without spaces -->
		</xsl:if>
	</xsl:template><xsl:template name="calculate-column-widths-autolayout-algorithm">
		<xsl:param name="parent_table_page-width"/> <!-- for nested tables, in re-calculate step -->
		
		<!-- via intermediate format -->

		<!-- The algorithm uses two passes through the table data and scales linearly with the size of the table -->
	 
		<!-- In the first pass, line wrapping is disabled, and the user agent keeps track of the minimum and maximum width of each cell. -->
	 
		<!-- Since line wrap has been disabled, paragraphs are treated as long lines unless broken by BR elements. -->
		 
		<!-- get current table id -->
		<xsl:variable name="table_id" select="@id"/>
		<!-- find table by id in the file 'table_widths' -->
	<!-- 	<xsl:variable name="table-if_" select="$table_widths_from_if//table[@id = $table_id]"/>
		<xsl:variable name="table-if" select="xalan:nodeset($table-if_)"/> -->
		
		<!-- table='<xsl:copy-of select="$table"/>' -->
		<!-- table_id='<xsl:value-of select="$table_id"/>\ -->
		<!-- table-if='<xsl:copy-of select="$table-if"/>' -->
		<!-- table_widths_from_if='<xsl:copy-of select="$table_widths_from_if"/>' -->
		
		<xsl:variable name="table_with_cell_widths_">
			<xsl:apply-templates select="." mode="determine_cell_widths-if"/> <!-- read column's width from IF -->
		</xsl:variable>
		<xsl:variable name="table_with_cell_widths" select="xalan:nodeset($table_with_cell_widths_)"/>
		
		<!-- <xsl:if test="$table_if_debug = 'true'">
			<xsl:copy-of select="$table_with_cell_widths"/>
		</xsl:if> -->
		
		
		<!-- The minimum and maximum cell widths are then used to determine the corresponding minimum and maximum widths for the columns. -->
		
		<xsl:variable name="column_widths_">
			<!-- iteration of columns -->
			<xsl:for-each select="$table_with_cell_widths//tr[1]/td">
				<xsl:variable name="pos" select="position()"/>
				<column>
					<xsl:attribute name="width_max">
						<xsl:for-each select="ancestor::tbody//tr/td[$pos]/@width_max">
							<xsl:sort select="." data-type="number" order="descending"/>
							<xsl:if test="position() = 1"><xsl:value-of select="."/></xsl:if>
						</xsl:for-each>
					</xsl:attribute>
					<xsl:attribute name="width_min">
						<xsl:for-each select="ancestor::tbody//tr/td[$pos]/@width_min">
							<xsl:sort select="." data-type="number" order="descending"/>
							<xsl:if test="position() = 1"><xsl:value-of select="."/></xsl:if>
						</xsl:for-each>
					</xsl:attribute>
				</column>
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="column_widths" select="xalan:nodeset($column_widths_)"/>
		
		<!-- <column_widths>
			<xsl:copy-of select="$column_widths"/>
		</column_widths> -->
		
		<!-- These in turn, are used to find the minimum and maximum width for the table. -->
		<xsl:variable name="table_widths_">
			<table>
				<xsl:attribute name="width_max">
					<xsl:value-of select="sum($column_widths/column/@width_max)"/>
				</xsl:attribute>
				<xsl:attribute name="width_min">
					<xsl:value-of select="sum($column_widths/column/@width_min)"/>
				</xsl:attribute>
			</table>
		</xsl:variable>
		<xsl:variable name="table_widths" select="xalan:nodeset($table_widths_)"/>
		
		<xsl:variable name="page_width">
			<xsl:choose>
				<xsl:when test="$parent_table_page-width != ''">
					<xsl:value-of select="$parent_table_page-width"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="@page-width"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:if test="$table_if_debug = 'true'">
			<table_width>
				<xsl:copy-of select="$table_widths"/>
			</table_width>
			<debug>$page_width=<xsl:value-of select="$page_width"/></debug>
		</xsl:if>
		
		
		<!-- There are three cases: -->
		<xsl:choose>
			<!-- 1. The minimum table width is equal to or wider than the available space -->
			<xsl:when test="$table_widths/table/@width_min &gt;= $page_width and 1 = 2"> <!-- this condition isn't working see case 3 below -->
				<!-- call old algorithm -->
				<case1/>
				<!-- <xsl:variable name="cols-count" select="count(xalan:nodeset($table)/*/tr[1]/td)"/>
				<xsl:call-template name="calculate-column-widths-proportional">
					<xsl:with-param name="cols-count" select="$cols-count"/>
					<xsl:with-param name="table" select="$table"/>
				</xsl:call-template> -->
			</xsl:when>
			<!-- 2. The maximum table width fits within the available space. In this case, set the columns to their maximum widths. -->
			<xsl:when test="$table_widths/table/@width_max &lt;= $page_width">
				<case2/>
				<autolayout/>
				<xsl:for-each select="$column_widths/column/@width_max">
					<column divider="100"><xsl:value-of select="."/></column>
				</xsl:for-each>
			</xsl:when>
			<!-- 3. The maximum width of the table is greater than the available space, but the minimum table width is smaller. 
			In this case, find the difference between the available space and the minimum table width, lets call it W. 
			Lets also call D the difference between maximum and minimum width of the table. 
			For each column, let d be the difference between maximum and minimum width of that column. 
			Now set the column's width to the minimum width plus d times W over D. 
			This makes columns with large differences between minimum and maximum widths wider than columns with smaller differences. -->
			<xsl:when test="($table_widths/table/@width_max &gt; $page_width and $table_widths/table/@width_min &lt; $page_width) or ($table_widths/table/@width_min &gt;= $page_width)">
				<!-- difference between the available space and the minimum table width -->
				<xsl:variable name="W" select="$page_width - $table_widths/table/@width_min"/>
				<W><xsl:value-of select="$W"/></W>
				<!-- difference between maximum and minimum width of the table -->
				<xsl:variable name="D" select="$table_widths/table/@width_max - $table_widths/table/@width_min"/>
				<D><xsl:value-of select="$D"/></D>
				<case3/>
				<autolayout/>
				<xsl:if test="$table_widths/table/@width_min &gt;= $page_width">
					<split_keep-within-line>true</split_keep-within-line>
				</xsl:if>
				<xsl:for-each select="$column_widths/column">
					<!-- difference between maximum and minimum width of that column.  -->
					<xsl:variable name="d" select="@width_max - @width_min"/>
					<d><xsl:value-of select="$d"/></d>
					<width_min><xsl:value-of select="@width_min"/></width_min>
					<e><xsl:value-of select="$d * $W div $D"/></e>
					<!-- set the column's width to the minimum width plus d times W over D.  -->
					<column divider="100">
						<xsl:value-of select="round(@width_min + $d * $W div $D)"/> <!--  * 10 -->
					</column>
				</xsl:for-each>
				
			</xsl:when>
			<xsl:otherwise><unknown_case/></xsl:otherwise>
		</xsl:choose>
		
	</xsl:template><xsl:template name="get-calculated-column-widths-autolayout-algorithm">
		
		<!-- if nested 'dl' or 'table' -->
		<xsl:variable name="parent_table_id" select="normalize-space(ancestor::*[local-name() = 'table' or local-name() = 'dl'][1]/@id)"/>
		<parent_table_id><xsl:value-of select="$parent_table_id"/></parent_table_id>
			
		<parent_element><xsl:value-of select="local-name(..)"/></parent_element>
			
		<xsl:variable name="parent_table_page-width_">
			<xsl:if test="$parent_table_id != ''">
				<!-- determine column number in the parent table -->
				<xsl:variable name="parent_table_column_number">
					<xsl:choose>
						<xsl:when test="parent::*[local-name() = 'dd']">2</xsl:when>
						<xsl:otherwise> <!-- parent is table -->
							<xsl:value-of select="count(ancestor::*[local-name() = 'td'][1]/preceding-sibling::*[local-name() = 'td']) + 1"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<!-- find table by id in the file 'table_widths' and get all Nth `<column>...</column> -->
				<xsl:value-of select="$table_widths_from_if_calculated//table[@id = $parent_table_id]/column[number($parent_table_column_number)]"/>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="parent_table_page-width" select="normalize-space($parent_table_page-width_)"/>
		
		<!-- get current table id -->
		<xsl:variable name="table_id" select="@id"/>
		
		<xsl:choose>
			<xsl:when test="$parent_table_id = '' or $parent_table_page-width = ''">
				<!-- find table by id in the file 'table_widths' and get all `<column>...</column> -->
				<xsl:copy-of select="$table_widths_from_if_calculated//table[@id = $table_id]/node()"/>
			</xsl:when>
			<xsl:otherwise>
				<!-- recalculate columns width based on parent table width -->
				<xsl:for-each select="$table_widths_from_if//table[@id = $table_id]">
					<xsl:call-template name="calculate-column-widths-autolayout-algorithm">
						<xsl:with-param name="parent_table_page-width" select="$parent_table_page-width"/> <!-- padding-left = 2mm  = 50000-->
					</xsl:call-template>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template><xsl:template match="@*|node()" mode="determine_cell_widths-if">
		<xsl:copy>
				<xsl:apply-templates select="@*|node()" mode="determine_cell_widths-if"/>
		</xsl:copy>
	</xsl:template><xsl:template match="td | th" mode="determine_cell_widths-if">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			
			 <!-- The maximum width is given by the widest line.  -->
			<xsl:attribute name="width_max">
				<xsl:for-each select="p_len">
					<xsl:sort select="." data-type="number" order="descending"/>
					<xsl:if test="position() = 1"><xsl:value-of select="."/></xsl:if>
				</xsl:for-each>
			</xsl:attribute>
			
			<!-- The minimum width is given by the widest text element (word, image, etc.) -->
			<xsl:variable name="width_min">
				<xsl:for-each select="word_len">
					<xsl:sort select="." data-type="number" order="descending"/>
					<xsl:if test="position() = 1"><xsl:value-of select="."/></xsl:if>
				</xsl:for-each>
			</xsl:variable>
			<xsl:attribute name="width_min">
				<xsl:value-of select="$width_min"/>
			</xsl:attribute>
			
			<xsl:if test="$width_min = 0">
				<xsl:attribute name="width_min">1</xsl:attribute>
			</xsl:if>
			
			<xsl:apply-templates select="node()" mode="determine_cell_widths-if"/>
			
		</xsl:copy>
	</xsl:template><xsl:template match="*[local-name()='thead']">
		<xsl:param name="cols-count"/>
		<fo:table-header>
							
				<xsl:call-template name="table-header-title">
					<xsl:with-param name="cols-count" select="$cols-count"/>
				</xsl:call-template>				
			
			
			<xsl:apply-templates/>
		</fo:table-header>
	</xsl:template><xsl:template name="table-header-title">
		<xsl:param name="cols-count"/>
		<!-- row for title -->
		<fo:table-row>
			<fo:table-cell number-columns-spanned="{$cols-count}" border-left="1.5pt solid white" border-right="1.5pt solid white" border-top="1.5pt solid white" border-bottom="1.5pt solid black">
				
				
				
				
						<xsl:apply-templates select="ancestor::*[local-name()='table']/*[local-name()='name']">
							<xsl:with-param name="continued">true</xsl:with-param>
						</xsl:apply-templates>
						
						
							<xsl:for-each select="ancestor::*[local-name()='table'][1]">
								<xsl:call-template name="table_name_fn_display"/>
							</xsl:for-each>

							<fo:block text-align="right" font-style="italic">
								<xsl:text> </xsl:text>
								<fo:retrieve-table-marker retrieve-class-name="table_continued"/>
							</fo:block>
						
				
					
				
				
			</fo:table-cell>
		</fo:table-row>
	</xsl:template><xsl:template match="*[local-name()='thead']" mode="process_tbody">		
		<fo:table-body>
			<xsl:apply-templates/>
		</fo:table-body>
	</xsl:template><xsl:template match="*[local-name()='tfoot']">
		<xsl:apply-templates/>
	</xsl:template><xsl:template name="insertTableFooter">
		<xsl:param name="cols-count"/>
		<xsl:if test="../*[local-name()='tfoot']">
			<fo:table-footer>			
				<xsl:apply-templates select="../*[local-name()='tfoot']"/>
			</fo:table-footer>
		</xsl:if>
	</xsl:template><xsl:template name="insertTableFooterInSeparateTable">
		<xsl:param name="table_attributes"/>
		<xsl:param name="colwidths"/>
		<xsl:param name="colgroup"/>
		
		<xsl:variable name="isNoteOrFnExist" select="../*[local-name()='note'] or ..//*[local-name()='fn'][local-name(..) != 'name']"/>
		
		<xsl:variable name="isNoteOrFnExistShowAfterTable">
			
		</xsl:variable>
		
		<xsl:if test="$isNoteOrFnExist = 'true' or normalize-space($isNoteOrFnExistShowAfterTable) = 'true'">
		
			<xsl:variable name="cols-count">
				<xsl:choose>
					<xsl:when test="xalan:nodeset($colgroup)//*[local-name()='col']">
						<xsl:value-of select="count(xalan:nodeset($colgroup)//*[local-name()='col'])"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="count(xalan:nodeset($colwidths)//column)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			
			<xsl:variable name="tableWithNotesAndFootnotes">
			
				<fo:table keep-with-previous="always">
					<xsl:for-each select="xalan:nodeset($table_attributes)/table_attributes/@*">
						<xsl:variable name="name" select="local-name()"/>
						<xsl:choose>
							<xsl:when test="$name = 'border-top'">
								<xsl:attribute name="{$name}">0pt solid black</xsl:attribute>
							</xsl:when>
							<xsl:when test="$name = 'border'">
								<xsl:attribute name="{$name}"><xsl:value-of select="."/></xsl:attribute>
								<xsl:attribute name="border-top">0pt solid black</xsl:attribute>
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="{$name}"><xsl:value-of select="."/></xsl:attribute>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
					
					
					
					<xsl:choose>
						<xsl:when test="xalan:nodeset($colgroup)//*[local-name()='col']">
							<xsl:for-each select="xalan:nodeset($colgroup)//*[local-name()='col']">
								<fo:table-column column-width="{@width}"/>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<!-- $colwidths=<xsl:copy-of select="$colwidths"/> -->
							<xsl:call-template name="insertTableColumnWidth">
								<xsl:with-param name="colwidths" select="$colwidths"/>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
					
					<fo:table-body>
						<fo:table-row>
							<fo:table-cell xsl:use-attribute-sets="table-footer-cell-style" number-columns-spanned="{$cols-count}">
								
								

								
								
								<!-- fn will be processed inside 'note' processing -->
								
								
								
								
								
								
								<!-- for BSI (not PAS) display Notes before footnotes -->
								
								
								<!-- except gb and bsi  -->
								
										<xsl:apply-templates select="../*[local-name()='note']"/>
									
								
								
								<!-- horizontal row separator -->
								
								
								<!-- fn processing -->
								
										<xsl:call-template name="table_fn_display"/>
									
								
								
								<!-- for PAS display Notes after footnotes -->
								
								
							</fo:table-cell>
						</fo:table-row>
					</fo:table-body>
					
				</fo:table>
			</xsl:variable>
			
			<xsl:if test="normalize-space($tableWithNotesAndFootnotes) != ''">
				<xsl:copy-of select="$tableWithNotesAndFootnotes"/>
			</xsl:if>
			
			
			
		</xsl:if>
	</xsl:template><xsl:template match="*[local-name()='tbody']">
		
		<xsl:variable name="cols-count">
			<xsl:choose>
				<xsl:when test="../*[local-name()='thead']">					
					<xsl:call-template name="calculate-columns-numbers">
						<xsl:with-param name="table-row" select="../*[local-name()='thead']/*[local-name()='tr'][1]"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>					
					<xsl:call-template name="calculate-columns-numbers">
						<xsl:with-param name="table-row" select="./*[local-name()='tr'][1]"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		
			<!-- if there isn't 'thead' and there is a table's title -->
			<xsl:if test="not(ancestor::*[local-name()='table']/*[local-name()='thead']) and ancestor::*[local-name()='table']/*[local-name()='name']">
				<fo:table-header>
					<xsl:call-template name="table-header-title">
						<xsl:with-param name="cols-count" select="$cols-count"/>
					</xsl:call-template>
				</fo:table-header>
			</xsl:if>
		
		
		<xsl:apply-templates select="../*[local-name()='thead']">
			<xsl:with-param name="cols-count" select="$cols-count"/>
		</xsl:apply-templates>
		
		<xsl:call-template name="insertTableFooter">
			<xsl:with-param name="cols-count" select="$cols-count"/>
		</xsl:call-template>
		
		<fo:table-body>
							
				<xsl:variable name="title_continued_">
					<xsl:call-template name="getTitle">
						<xsl:with-param name="name" select="'title-continued'"/>
					</xsl:call-template>
				</xsl:variable>
				
				<xsl:variable name="title_continued">
					<xsl:value-of select="$title_continued_"/>
					
				</xsl:variable>
				
				<xsl:variable name="title_start" select="ancestor::*[local-name()='table'][1]/*[local-name()='name']/node()[1][self::text()]"/>
				<xsl:variable name="table_number" select="substring-before($title_start, '—')"/>
				
				<fo:table-row height="0" keep-with-next.within-page="always">
					<fo:table-cell>
					
						
						
						
							<fo:marker marker-class-name="table_continued"/>
						
						
						<fo:block/>
					</fo:table-cell>
				</fo:table-row>
				<fo:table-row height="0" keep-with-next.within-page="always">
					<fo:table-cell>
						
						<fo:marker marker-class-name="table_continued">
							<xsl:value-of select="$title_continued"/>
						</fo:marker>
						 <fo:block/>
					</fo:table-cell>
				</fo:table-row>
			

			<xsl:apply-templates/>
			
		</fo:table-body>
		
	</xsl:template><xsl:template match="/" mode="process_table-if">
		<xsl:param name="table_or_dl">table</xsl:param>
		<xsl:apply-templates mode="process_table-if">
			<xsl:with-param name="table_or_dl" select="$table_or_dl"/>
		</xsl:apply-templates>
	</xsl:template><xsl:template match="*[local-name()='tbody']" mode="process_table-if">
		<xsl:param name="table_or_dl">table</xsl:param>
		
		<fo:table-body>
			<xsl:for-each select="*[local-name() = 'tr']">
				<xsl:variable name="col_count" select="count(*)"/>

				<!-- iteration for each tr/td -->
				
				<xsl:choose>
					<xsl:when test="$table_or_dl = 'table'">
						<xsl:for-each select="*[local-name() = 'td' or local-name() = 'th']/*">
							<fo:table-row number-columns-spanned="{$col_count}">
								<!-- <test_table><xsl:copy-of select="."/></test_table> -->
								<xsl:call-template name="td"/>
							</fo:table-row>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise> <!-- $table_or_dl = 'dl' -->
						<xsl:for-each select="*[local-name() = 'td' or local-name() = 'th']">
							<xsl:variable name="is_dt" select="position() = 1"/>
							
							<xsl:for-each select="*">
								<!-- <test><xsl:copy-of select="."/></test> -->
								<fo:table-row number-columns-spanned="{$col_count}">
									<xsl:choose>
										<xsl:when test="$is_dt">
											<xsl:call-template name="insert_dt_cell"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:call-template name="insert_dd_cell"/>
										</xsl:otherwise>
									</xsl:choose>
								</fo:table-row>
							</xsl:for-each>
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>
				
			</xsl:for-each>
		</fo:table-body>
	</xsl:template><xsl:template match="*[local-name()='thead']/*[local-name()='tr']" priority="2">
		<fo:table-row xsl:use-attribute-sets="table-header-row-style">
		
			
			
			
				<xsl:choose>
					<xsl:when test="position() = 1">
						<xsl:attribute name="border-top">solid black 1.5pt</xsl:attribute>
						<xsl:attribute name="border-bottom">solid black 1pt</xsl:attribute>
					</xsl:when>
					<xsl:when test="position() = last()">
						<xsl:attribute name="border-top">solid black 1pt</xsl:attribute>
						<xsl:attribute name="border-bottom">solid black 1.5pt</xsl:attribute>
					</xsl:when>
				</xsl:choose>
			


			

			
			
			<xsl:call-template name="setTableRowAttributes"/>
			
			<xsl:apply-templates/>
		</fo:table-row>
	</xsl:template><xsl:template match="*[local-name()='tfoot']/*[local-name()='tr']" priority="2">
		<fo:table-row xsl:use-attribute-sets="table-footer-row-style">
			
			<xsl:call-template name="setTableRowAttributes"/>
			<xsl:apply-templates/>
		</fo:table-row>
	</xsl:template><xsl:template match="*[local-name()='tr']">
		<fo:table-row xsl:use-attribute-sets="table-body-row-style">
		
			
		
			
		
			
		
			<xsl:call-template name="setTableRowAttributes"/>
			<xsl:apply-templates/>
		</fo:table-row>
	</xsl:template><xsl:template name="setTableRowAttributes">
	
		
	
		

		
		
		
	</xsl:template><xsl:template match="*[local-name()='th']">
		<fo:table-cell xsl:use-attribute-sets="table-header-cell-style"> <!-- text-align="{@align}" -->
			<xsl:call-template name="setTextAlignment">
				<xsl:with-param name="default">center</xsl:with-param>
			</xsl:call-template>
			
			
			
			

			
			
			
			
			
			<xsl:if test="$lang = 'ar'">
				<xsl:attribute name="padding-right">1mm</xsl:attribute>
			</xsl:if>
			
			<xsl:call-template name="setTableCellAttributes"/>

			<fo:block>
				<xsl:apply-templates/>
			</fo:block>
		</fo:table-cell>
	</xsl:template><xsl:template name="setTableCellAttributes">
		<xsl:if test="@colspan">
			<xsl:attribute name="number-columns-spanned">
				<xsl:value-of select="@colspan"/>
			</xsl:attribute>
		</xsl:if>
		<xsl:if test="@rowspan">
			<xsl:attribute name="number-rows-spanned">
				<xsl:value-of select="@rowspan"/>
			</xsl:attribute>
		</xsl:if>
		<xsl:call-template name="display-align"/>
	</xsl:template><xsl:template name="display-align">
		<xsl:if test="@valign">
			<xsl:attribute name="display-align">
				<xsl:choose>
					<xsl:when test="@valign = 'top'">before</xsl:when>
					<xsl:when test="@valign = 'middle'">center</xsl:when>
					<xsl:when test="@valign = 'bottom'">after</xsl:when>
					<xsl:otherwise>before</xsl:otherwise>
				</xsl:choose>					
			</xsl:attribute>
		</xsl:if>
	</xsl:template><xsl:template match="*[local-name()='td']" name="td">
		<fo:table-cell xsl:use-attribute-sets="table-cell-style"> <!-- text-align="{@align}" -->
			<xsl:call-template name="setTextAlignment">
				<xsl:with-param name="default">left</xsl:with-param>
			</xsl:call-template>
			
			<xsl:if test="$lang = 'ar'">
				<xsl:attribute name="padding-right">1mm</xsl:attribute>
			</xsl:if>
			
			
			
			 <!-- bsi -->
			
			
			
			
			
			
			
			
				<xsl:if test="ancestor::*[local-name() = 'tfoot']">
					<xsl:attribute name="border">solid black 0</xsl:attribute>
				</xsl:if>
			
			
			

			
			
			
			
			
			
			<xsl:if test=".//*[local-name() = 'table']"> <!-- if there is nested table -->
				<xsl:attribute name="padding-right">1mm</xsl:attribute>
			</xsl:if>
			
			<xsl:call-template name="setTableCellAttributes"/>
			
			<xsl:if test="$isGenerateTableIF = 'true'">
				<xsl:attribute name="border">1pt solid black</xsl:attribute> <!-- border is mandatory, to determine page width -->
				<xsl:attribute name="text-align">left</xsl:attribute>
			</xsl:if>
			
			<fo:block>
			
				<xsl:if test="$isGenerateTableIF = 'true'">
					<xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
				</xsl:if>
			
			
				
				
				<xsl:apply-templates/>
				
				<xsl:if test="$isGenerateTableIF = 'true'"><fo:inline id="{@id}_end">end</fo:inline></xsl:if> <!-- to determine width of text --> <!-- <xsl:value-of select="$hair_space"/> -->

			</fo:block>			
		</fo:table-cell>
	</xsl:template><xsl:template match="*[local-name()='table']/*[local-name()='note']" priority="2">

		<fo:block xsl:use-attribute-sets="table-note-style">

			
			
			
		
			<!-- Table's note name (NOTE, for example) -->
			<fo:inline xsl:use-attribute-sets="table-note-name-style">
				
				
				
				
				
				
				
				<xsl:apply-templates select="*[local-name() = 'name']"/>
					
			</fo:inline>
			
			
			
			<xsl:apply-templates select="node()[not(local-name() = 'name')]"/>
		</fo:block>
		
	</xsl:template><xsl:template match="*[local-name()='table']/*[local-name()='note']/*[local-name()='p']" priority="2">
		<xsl:apply-templates/>
	</xsl:template><xsl:template match="*[local-name() = 'fn'][not(ancestor::*[(local-name() = 'table' or local-name() = 'figure') and not(ancestor::*[local-name() = 'name'])])]" priority="2" name="fn">
	
		<!-- list of footnotes to calculate actual footnotes number -->
		<xsl:variable name="p_fn_">
			<xsl:call-template name="get_fn_list"/>
		</xsl:variable>
		<xsl:variable name="p_fn" select="xalan:nodeset($p_fn_)"/>
		
		<xsl:variable name="gen_id" select="generate-id(.)"/>
		<xsl:variable name="lang" select="ancestor::*[contains(local-name(), '-standard')]/*[local-name()='bibdata']//*[local-name()='language'][@current = 'true']"/>
		<xsl:variable name="reference_">
			<xsl:value-of select="@reference"/>
			<xsl:if test="normalize-space(@reference) = ''"><xsl:value-of select="$gen_id"/></xsl:if>
		</xsl:variable>
		<xsl:variable name="reference" select="normalize-space($reference_)"/>
		<!-- fn sequence number in document -->
		<xsl:variable name="current_fn_number">
			<xsl:choose>
				<xsl:when test="@current_fn_number"><xsl:value-of select="@current_fn_number"/></xsl:when> <!-- for BSI -->
				<xsl:otherwise>
					<xsl:value-of select="count($p_fn//fn[@reference = $reference]/preceding-sibling::fn) + 1"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="current_fn_number_text">
			<xsl:value-of select="$current_fn_number"/>
			
			
				<xsl:text>)</xsl:text>
			
		</xsl:variable>
		
		<xsl:variable name="ref_id" select="concat('footnote_', $lang, '_', $reference, '_', $current_fn_number)"/>
		<xsl:variable name="footnote_inline">
			<fo:inline xsl:use-attribute-sets="fn-num-style">
				
				
				<fo:basic-link internal-destination="{$ref_id}" fox:alt-text="footnote {$current_fn_number}">
					<xsl:value-of select="$current_fn_number_text"/>
				</fo:basic-link>
			</fo:inline>
		</xsl:variable>
		<!-- DEBUG: p_fn=<xsl:copy-of select="$p_fn"/>
		gen_id=<xsl:value-of select="$gen_id"/> -->
		<xsl:choose>
			<xsl:when test="normalize-space(@skip_footnote_body) = 'true'">
				<xsl:copy-of select="$footnote_inline"/>
			</xsl:when>
			<xsl:when test="$p_fn//fn[@gen_id = $gen_id] or normalize-space(@skip_footnote_body) = 'false'">
				<fo:footnote xsl:use-attribute-sets="fn-style">
					<xsl:copy-of select="$footnote_inline"/>
					<fo:footnote-body>
						
						<fo:block-container xsl:use-attribute-sets="fn-container-body-style">
							
							<fo:block xsl:use-attribute-sets="fn-body-style">
								
								
								
								<fo:inline id="{$ref_id}" xsl:use-attribute-sets="fn-body-num-style">
									
									
									
									
									<xsl:value-of select="$current_fn_number_text"/>
								</fo:inline>
								<xsl:apply-templates/>
							</fo:block>
						</fo:block-container>
					</fo:footnote-body>
				</fo:footnote>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="$footnote_inline"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="get_fn_list">
		<xsl:choose>
			<xsl:when test="@current_fn_number"> <!-- for BSI, footnote reference number calculated already -->
				<fn gen_id="{generate-id(.)}">
					<xsl:copy-of select="@*"/>
					<xsl:copy-of select="node()"/>
				</fn>
			</xsl:when>
			<xsl:otherwise>
				<!-- itetation for:
				footnotes in bibdata/title
				footnotes in bibliography
				footnotes in document's body (except table's head/body/foot and figure text) 
				-->
				<xsl:for-each select="ancestor::*[contains(local-name(), '-standard')]/*[local-name() = 'bibdata']/*[local-name() = 'note'][@type='title-footnote']">
					<fn gen_id="{generate-id(.)}">
						<xsl:copy-of select="@*"/>
						<xsl:copy-of select="node()"/>
					</fn>
				</xsl:for-each>
				<xsl:for-each select="ancestor::*[contains(local-name(), '-standard')]/*[local-name()='boilerplate']/* |       ancestor::*[contains(local-name(), '-standard')]/*[local-name()='preface']/* |      ancestor::*[contains(local-name(), '-standard')]/*[local-name()='sections']/* |       ancestor::*[contains(local-name(), '-standard')]/*[local-name()='annex'] |      ancestor::*[contains(local-name(), '-standard')]/*[local-name()='bibliography']/*">
					<xsl:sort select="@displayorder" data-type="number"/>
					<xsl:for-each select=".//*[local-name() = 'bibitem'][ancestor::*[local-name() = 'references']]/*[local-name() = 'note'] |      .//*[local-name() = 'fn'][not(ancestor::*[(local-name() = 'table' or local-name() = 'figure') and not(ancestor::*[local-name() = 'name'])])][generate-id(.)=generate-id(key('kfn',@reference)[1])]">
						<!-- copy unique fn -->
						<fn gen_id="{generate-id(.)}">
							<xsl:copy-of select="@*"/>
							<xsl:copy-of select="node()"/>
						</fn>
					</xsl:for-each>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="table_fn_display">
		<xsl:variable name="references">
			
			<xsl:for-each select="..//*[local-name()='fn'][local-name(..) != 'name']">
				<xsl:call-template name="create_fn"/>
			</xsl:for-each>
		</xsl:variable>
		
		<xsl:for-each select="xalan:nodeset($references)//fn">
			<xsl:variable name="reference" select="@reference"/>
			<xsl:if test="not(preceding-sibling::*[@reference = $reference])"> <!-- only unique reference puts in note-->
				<fo:block xsl:use-attribute-sets="table-fn-style">
				
					
					
					<fo:inline id="{@id}" xsl:use-attribute-sets="table-fn-number-style">
						
						
						
						
						
						<xsl:value-of select="@reference"/>
						
						
						
						
						
						
						
					</fo:inline>
					<fo:inline xsl:use-attribute-sets="table-fn-body-style">
						<xsl:copy-of select="./node()"/>
					</fo:inline>
				</fo:block>
			</xsl:if>
		</xsl:for-each>
	</xsl:template><xsl:template name="create_fn">
		<fn reference="{@reference}" id="{@reference}_{ancestor::*[@id][1]/@id}">
			
			
			<xsl:apply-templates/>
		</fn>
	</xsl:template><xsl:template name="table_name_fn_display">
		<xsl:for-each select="*[local-name()='name']//*[local-name()='fn']">
			<xsl:variable name="reference" select="@reference"/>
			<fo:block id="{@reference}_{ancestor::*[@id][1]/@id}"><xsl:value-of select="@reference"/></fo:block>
			<fo:block margin-bottom="12pt">
				<xsl:apply-templates/>
			</fo:block>
		</xsl:for-each>
	</xsl:template><xsl:template name="fn_display_figure">
	
		<xsl:variable name="references">
			<xsl:for-each select=".//*[local-name()='fn'][not(parent::*[local-name()='name'])]">
				<fn reference="{@reference}" id="{@reference}_{ancestor::*[@id][1]/@id}">
					<xsl:apply-templates/>
				</fn>
			</xsl:for-each>
		</xsl:variable>
	
		<xsl:if test="xalan:nodeset($references)//fn">
		
			<xsl:variable name="key_iso">
				true
			</xsl:variable>
			
			<!-- current hierarchy is 'figure' element -->
			<xsl:variable name="following_dl_colwidths">
				<xsl:if test="*[local-name() = 'dl']"><!-- if there is a 'dl', then set the same columns width as for 'dl' -->
					<xsl:variable name="simple-table">
						<!-- <xsl:variable name="doc_ns">
							<xsl:if test="$namespace = 'bipm'">bipm</xsl:if>
						</xsl:variable>
						<xsl:variable name="ns">
							<xsl:choose>
								<xsl:when test="normalize-space($doc_ns)  != ''">
									<xsl:value-of select="normalize-space($doc_ns)"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="substring-before(name(/*), '-')"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable> -->
						
						<xsl:for-each select="*[local-name() = 'dl'][1]">
							<tbody>
								<xsl:apply-templates mode="dl"/>
							</tbody>
						</xsl:for-each>
					</xsl:variable>
					
					<xsl:call-template name="calculate-column-widths">
						<xsl:with-param name="cols-count" select="2"/>
						<xsl:with-param name="table" select="$simple-table"/>
					</xsl:call-template>
					
				</xsl:if>
			</xsl:variable>
			
			<xsl:variable name="maxlength_dt">
				<xsl:for-each select="*[local-name() = 'dl'][1]">
					<xsl:call-template name="getMaxLength_dt"/>			
				</xsl:for-each>
			</xsl:variable>

			<fo:block>
				<fo:table width="95%" table-layout="fixed">
					<xsl:if test="normalize-space($key_iso) = 'true'">
						<xsl:attribute name="font-size">10pt</xsl:attribute>
						
					</xsl:if>
					<xsl:choose>
						<!-- if there 'dl', then set same columns width -->
						<xsl:when test="xalan:nodeset($following_dl_colwidths)//column">
							<xsl:call-template name="setColumnWidth_dl">
								<xsl:with-param name="colwidths" select="$following_dl_colwidths"/>								
								<xsl:with-param name="maxlength_dt" select="$maxlength_dt"/>								
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<fo:table-column column-width="15%"/>
							<fo:table-column column-width="85%"/>
						</xsl:otherwise>
					</xsl:choose>
					<fo:table-body>
						<xsl:for-each select="xalan:nodeset($references)//fn">
							<xsl:variable name="reference" select="@reference"/>
							<xsl:if test="not(preceding-sibling::*[@reference = $reference])"> <!-- only unique reference puts in note-->
								<fo:table-row>
									<fo:table-cell>
										<fo:block>
											<fo:inline id="{@id}" xsl:use-attribute-sets="figure-fn-number-style">
												<xsl:value-of select="@reference"/>
											</fo:inline>
										</fo:block>
									</fo:table-cell>
									<fo:table-cell>
										<fo:block xsl:use-attribute-sets="figure-fn-body-style">
											<xsl:if test="normalize-space($key_iso) = 'true'">
												
														<xsl:attribute name="margin-bottom">0</xsl:attribute>
													
											</xsl:if>
											<xsl:copy-of select="./node()"/>
										</fo:block>
									</fo:table-cell>
								</fo:table-row>
							</xsl:if>
						</xsl:for-each>
					</fo:table-body>
				</fo:table>
			</fo:block>
		</xsl:if>
		
	</xsl:template><xsl:template match="*[local-name()='fn']">
		<fo:inline xsl:use-attribute-sets="fn-reference-style">
		
			
			
			
				<xsl:if test="ancestor::*[local-name()='table']">
					<xsl:attribute name="font-weight">normal</xsl:attribute>
					<xsl:attribute name="baseline-shift">15%</xsl:attribute>
				</xsl:if>
			
			
			<fo:basic-link internal-destination="{@reference}_{ancestor::*[@id][1]/@id}" fox:alt-text="{@reference}"> <!-- @reference   | ancestor::*[local-name()='clause'][1]/@id-->
				
				
				<xsl:value-of select="@reference"/>
				
				
			</fo:basic-link>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name()='fn']/text()[normalize-space() != '']">
		<fo:inline><xsl:value-of select="."/></fo:inline>
	</xsl:template><xsl:template match="*[local-name()='fn']//*[local-name()='p']">
		<fo:inline>
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name()='dl']">
		<xsl:variable name="isAdded" select="@added"/>
		<xsl:variable name="isDeleted" select="@deleted"/>
		<fo:block-container>
			
					<xsl:if test="not(ancestor::*[local-name() = 'quote'])">
						<xsl:attribute name="margin-left">0mm</xsl:attribute>
					</xsl:if>
				
			
			<xsl:if test="parent::*[local-name() = 'note']">
				<xsl:attribute name="margin-left">
					<xsl:choose>
						<xsl:when test="not(ancestor::*[local-name() = 'table'])"><xsl:value-of select="$note-body-indent"/></xsl:when>
						<xsl:otherwise><xsl:value-of select="$note-body-indent-table"/></xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				
			</xsl:if>
			
			<xsl:call-template name="setTrackChangesStyles">
				<xsl:with-param name="isAdded" select="$isAdded"/>
				<xsl:with-param name="isDeleted" select="$isDeleted"/>
			</xsl:call-template>
			
			<fo:block-container margin-left="0mm">
			
				
						<xsl:attribute name="margin-right">0mm</xsl:attribute>
					
				
				<xsl:variable name="parent" select="local-name(..)"/>
				
				<xsl:variable name="key_iso">
					
						<xsl:if test="$parent = 'figure' or $parent = 'formula'">true</xsl:if>
					 <!-- and  (not(../@class) or ../@class !='pseudocode') -->
				</xsl:variable>
				
				<xsl:variable name="onlyOneComponent" select="normalize-space($parent = 'formula' and count(*[local-name()='dt']) = 1)"/>
				
				<xsl:choose>
					<xsl:when test="$onlyOneComponent = 'true'"> <!-- only one component -->
						
								<fo:block margin-bottom="12pt" text-align="left">
									
										<xsl:attribute name="margin-bottom">0</xsl:attribute>
									
									<xsl:variable name="title-where">
										<xsl:call-template name="getLocalizedString">
											<xsl:with-param name="key">where</xsl:with-param>
										</xsl:call-template>
									</xsl:variable>
									<xsl:value-of select="$title-where"/><xsl:text> </xsl:text>
									<xsl:apply-templates select="*[local-name()='dt']/*"/>
									<xsl:text/>
									<xsl:apply-templates select="*[local-name()='dd']/*" mode="inline"/>
								</fo:block>
							
					</xsl:when> <!-- END: only one component -->
					<xsl:when test="$parent = 'formula'"> <!-- a few components -->
						<fo:block margin-bottom="12pt" text-align="left">
							
								<xsl:attribute name="margin-bottom">6pt</xsl:attribute>
							
							
							
							
							<xsl:variable name="title-where">
								<xsl:call-template name="getLocalizedString">
									<xsl:with-param name="key">where</xsl:with-param>
								</xsl:call-template>
							</xsl:variable>
							<xsl:value-of select="$title-where"/>
						</fo:block>
					</xsl:when>  <!-- END: a few components -->
					<xsl:when test="$parent = 'figure' and  (not(../@class) or ../@class !='pseudocode')"> <!-- definition list in a figure -->
						<fo:block font-weight="bold" text-align="left" margin-bottom="12pt" keep-with-next="always">
							
								<xsl:attribute name="font-size">10pt</xsl:attribute>
								<xsl:attribute name="margin-bottom">0</xsl:attribute>
							
							
							
							
							<xsl:variable name="title-key">
								<xsl:call-template name="getLocalizedString">
									<xsl:with-param name="key">key</xsl:with-param>
								</xsl:call-template>
							</xsl:variable>
							<xsl:value-of select="$title-key"/>
						</fo:block>
					</xsl:when>  <!-- END: definition list in a figure -->
				</xsl:choose>
				
				<!-- a few components -->
				<xsl:if test="$onlyOneComponent = 'false'">
					<fo:block>
						
							<xsl:if test="$parent = 'formula'">
								<xsl:attribute name="margin-left">4mm</xsl:attribute>
							</xsl:if>
							<xsl:attribute name="margin-top">12pt</xsl:attribute>
						
						
						
						
						
						<xsl:if test="ancestor::*[local-name() = 'dd' or local-name() = 'td']">
							<xsl:attribute name="margin-top">0</xsl:attribute>
						</xsl:if>
						
						<fo:block>
							
							
							
							
							<xsl:apply-templates select="*[local-name() = 'name']">
								<xsl:with-param name="process">true</xsl:with-param>
							</xsl:apply-templates>
							
							<xsl:if test="$isGenerateTableIF = 'true'">
								<!-- to determine start of table -->
								<fo:block id="{concat('table_if_start_',@id)}" keep-with-next="always" font-size="1pt">Start table '<xsl:value-of select="@id"/>'.</fo:block>
							</xsl:if>
							
							<fo:table width="95%" table-layout="fixed">
							
								<xsl:if test="$isGenerateTableIF = 'true'">
									<xsl:attribute name="wrap-option">no-wrap</xsl:attribute>
								</xsl:if>
							
								
								<xsl:choose>
									<xsl:when test="normalize-space($key_iso) = 'true' and $parent = 'formula'"/>
									<xsl:when test="normalize-space($key_iso) = 'true'">
										<xsl:attribute name="font-size">10pt</xsl:attribute>
										
									</xsl:when>
								</xsl:choose>
								
								
									<xsl:attribute name="width">100%</xsl:attribute>
								
								
								<xsl:choose>
									<xsl:when test="$isGenerateTableIF = 'true'">
										<!-- generate IF for table widths -->
										<!-- example:
											<tr>
												<td valign="top" align="left" id="tab-symdu_1_1">
													<p>Symbol</p>
													<word id="tab-symdu_1_1_word_1">Symbol</word>
												</td>
												<td valign="top" align="left" id="tab-symdu_1_2">
													<p>Description</p>
													<word id="tab-symdu_1_2_word_1">Description</word>
												</td>
											</tr>
										-->
										
										<!-- create virtual html table for dl/[dt and dd] -->
										<xsl:variable name="simple-table">
											
											<xsl:variable name="dl_table">
												<tbody>
													<xsl:apply-templates mode="dl_if">
														<xsl:with-param name="id" select="@id"/>
													</xsl:apply-templates>
												</tbody>
											</xsl:variable>
											
											<!-- dl_table='<xsl:copy-of select="$dl_table"/>' -->
											
											<!-- Step: replace <br/> to <p>...</p> -->
											<xsl:variable name="table_without_br">
												<xsl:apply-templates select="xalan:nodeset($dl_table)" mode="table-without-br"/>
											</xsl:variable>
											
											<!-- table_without_br='<xsl:copy-of select="$table_without_br"/>' -->
											
											<!-- Step: add id to each cell -->
											<!-- add <word>...</word> for each word, image, math -->
											<xsl:variable name="simple-table-id">
												<xsl:apply-templates select="xalan:nodeset($table_without_br)" mode="simple-table-id">
													<xsl:with-param name="id" select="@id"/>
												</xsl:apply-templates>
											</xsl:variable>
											
											<!-- simple-table-id='<xsl:copy-of select="$simple-table-id"/>' -->
											
											<xsl:copy-of select="xalan:nodeset($simple-table-id)"/>
											
										</xsl:variable>
										
										<!-- DEBUG: simple-table<xsl:copy-of select="$simple-table"/> -->
										
										<xsl:apply-templates select="xalan:nodeset($simple-table)" mode="process_table-if">
											<xsl:with-param name="table_or_dl">dl</xsl:with-param>
										</xsl:apply-templates>
										
									</xsl:when>
									<xsl:otherwise>
								
										<xsl:variable name="simple-table">
										
											<xsl:variable name="dl_table">
												<tbody>
													<xsl:apply-templates mode="dl">
														<xsl:with-param name="id" select="@id"/>
													</xsl:apply-templates>
												</tbody>
											</xsl:variable>
											
											<xsl:copy-of select="$dl_table"/>
										</xsl:variable>
								
										<xsl:variable name="colwidths">
											<xsl:call-template name="calculate-column-widths">
												<xsl:with-param name="cols-count" select="2"/>
												<xsl:with-param name="table" select="$simple-table"/>
											</xsl:call-template>
										</xsl:variable>
										
										<!-- <xsl:text disable-output-escaping="yes">&lt;!- -</xsl:text>
											DEBUG
											colwidths=<xsl:copy-of select="$colwidths"/>
										<xsl:text disable-output-escaping="yes">- -&gt;</xsl:text> -->
										
										<!-- colwidths=<xsl:copy-of select="$colwidths"/> -->
										
										<xsl:variable name="maxlength_dt">
											<xsl:call-template name="getMaxLength_dt"/>							
										</xsl:variable>
										
										<xsl:variable name="isContainsKeepTogetherTag_">
											
												 <xsl:value-of select="count(.//*[local-name() = $element_name_keep-together_within-line]) &gt; 0"/>
												
										</xsl:variable>
										<xsl:variable name="isContainsKeepTogetherTag" select="normalize-space($isContainsKeepTogetherTag_)"/>
										<!-- isContainsExpressReference=<xsl:value-of select="$isContainsExpressReference"/> -->
										
										
										<xsl:call-template name="setColumnWidth_dl">
											<xsl:with-param name="colwidths" select="$colwidths"/>							
											<xsl:with-param name="maxlength_dt" select="$maxlength_dt"/>
											<xsl:with-param name="isContainsKeepTogetherTag" select="$isContainsKeepTogetherTag"/>
										</xsl:call-template>
										
										<fo:table-body>
											
											<!-- DEBUG -->
											<xsl:if test="$table_if_debug = 'true'">
												<fo:table-row>
													<fo:table-cell number-columns-spanned="2" font-size="60%">
														<xsl:apply-templates select="xalan:nodeset($colwidths)" mode="print_as_xml"/>
													</fo:table-cell>
												</fo:table-row>
											</xsl:if>

											<xsl:apply-templates>
												<xsl:with-param name="key_iso" select="normalize-space($key_iso)"/>
												<xsl:with-param name="split_keep-within-line" select="xalan:nodeset($colwidths)/split_keep-within-line"/>
											</xsl:apply-templates>
											
										</fo:table-body>
									</xsl:otherwise>
								</xsl:choose>
							</fo:table>
						</fo:block>
					</fo:block>
				</xsl:if> <!-- END: a few components -->
			</fo:block-container>
		</fo:block-container>
		
		<xsl:if test="$isGenerateTableIF = 'true'"> <!-- process nested 'dl' -->
			<xsl:apply-templates select="*[local-name() = 'dd']/*[local-name() = 'dl']"/>
		</xsl:if>
		
	</xsl:template><xsl:template match="*[local-name() = 'dl']/*[local-name() = 'name']">
		<xsl:param name="process">false</xsl:param>
		<xsl:if test="$process = 'true'">
			<fo:block xsl:use-attribute-sets="dl-name-style">
				<xsl:apply-templates/>
			</fo:block>
		</xsl:if>
	</xsl:template><xsl:template name="setColumnWidth_dl">
		<xsl:param name="colwidths"/>		
		<xsl:param name="maxlength_dt"/>
		<xsl:param name="isContainsKeepTogetherTag"/>
		
		<!-- <colwidths><xsl:copy-of select="$colwidths"/></colwidths> -->
		
		<xsl:choose>
			<xsl:when test="xalan:nodeset($colwidths)/autolayout">
				<xsl:call-template name="insertTableColumnWidth">
					<xsl:with-param name="colwidths" select="$colwidths"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="ancestor::*[local-name()='dl']"><!-- second level, i.e. inlined table -->
				<fo:table-column column-width="50%"/>
				<fo:table-column column-width="50%"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="xalan:nodeset($colwidths)/autolayout">
						<xsl:call-template name="insertTableColumnWidth">
							<xsl:with-param name="colwidths" select="$colwidths"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="$isContainsKeepTogetherTag">
						<xsl:call-template name="insertTableColumnWidth">
							<xsl:with-param name="colwidths" select="$colwidths"/>
						</xsl:call-template>
					</xsl:when>
					<!-- to set width check most wide chars like `W` -->
					<xsl:when test="normalize-space($maxlength_dt) != '' and number($maxlength_dt) &lt;= 2"> <!-- if dt contains short text like t90, a, etc -->
						<fo:table-column column-width="7%"/>
						<fo:table-column column-width="93%"/>
					</xsl:when>
					<xsl:when test="normalize-space($maxlength_dt) != '' and number($maxlength_dt) &lt;= 5"> <!-- if dt contains short text like ABC, etc -->
						<fo:table-column column-width="15%"/>
						<fo:table-column column-width="85%"/>
					</xsl:when>
					<xsl:when test="normalize-space($maxlength_dt) != '' and number($maxlength_dt) &lt;= 7"> <!-- if dt contains short text like ABCDEF, etc -->
						<fo:table-column column-width="20%"/>
						<fo:table-column column-width="80%"/>
					</xsl:when>
					<xsl:when test="normalize-space($maxlength_dt) != '' and number($maxlength_dt) &lt;= 10"> <!-- if dt contains short text like ABCDEFEF, etc -->
						<fo:table-column column-width="25%"/>
						<fo:table-column column-width="75%"/>
					</xsl:when>
					<!-- <xsl:when test="xalan:nodeset($colwidths)/column[1] div xalan:nodeset($colwidths)/column[2] &gt; 1.7">
						<fo:table-column column-width="60%"/>
						<fo:table-column column-width="40%"/>
					</xsl:when> -->
					<xsl:when test="xalan:nodeset($colwidths)/column[1] div xalan:nodeset($colwidths)/column[2] &gt; 1.3">
						<fo:table-column column-width="50%"/>
						<fo:table-column column-width="50%"/>
					</xsl:when>
					<xsl:when test="xalan:nodeset($colwidths)/column[1] div xalan:nodeset($colwidths)/column[2] &gt; 0.5">
						<fo:table-column column-width="40%"/>
						<fo:table-column column-width="60%"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="insertTableColumnWidth">
							<xsl:with-param name="colwidths" select="$colwidths"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="insertTableColumnWidth">
		<xsl:param name="colwidths"/>
		
		<xsl:for-each select="xalan:nodeset($colwidths)//column">
			<xsl:choose>
				<xsl:when test=". = 1 or . = 0">
					<fo:table-column column-width="proportional-column-width(2)"/>
				</xsl:when>
				<xsl:otherwise>
					<!-- <fo:table-column column-width="proportional-column-width({.})"/> -->
					<xsl:variable name="divider">
						<xsl:value-of select="@divider"/>
						<xsl:if test="not(@divider)">1</xsl:if>
					</xsl:variable>
					<fo:table-column column-width="proportional-column-width({round(. div $divider)})"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template><xsl:template name="getMaxLength_dt">
		<xsl:variable name="lengths">
			<xsl:for-each select="*[local-name()='dt']">
				<xsl:variable name="maintext_length" select="string-length(normalize-space(.))"/>
				<xsl:variable name="attributes">
					<xsl:for-each select=".//@open"><xsl:value-of select="."/></xsl:for-each>
					<xsl:for-each select=".//@close"><xsl:value-of select="."/></xsl:for-each>
				</xsl:variable>
				<length><xsl:value-of select="string-length(normalize-space(.)) + string-length($attributes)"/></length>
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="maxLength">
			<xsl:for-each select="xalan:nodeset($lengths)/length">
				<xsl:sort select="." data-type="number" order="descending"/>
				<xsl:if test="position() = 1">
					<xsl:value-of select="."/>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<!-- <xsl:message>DEBUG:<xsl:value-of select="$maxLength"/></xsl:message> -->
		<xsl:value-of select="$maxLength"/>
	</xsl:template><xsl:template match="*[local-name()='dl']/*[local-name()='note']" priority="2">
		<xsl:param name="key_iso"/>
		<!-- <tr>
			<td>NOTE</td>
			<td>
				<xsl:apply-templates />
			</td>
		</tr>
		 -->
		<!-- OLD Variant -->
		<!-- <fo:table-row>
			<fo:table-cell>
				<fo:block margin-top="6pt">
					<xsl:if test="normalize-space($key_iso) = 'true'">
						<xsl:attribute name="margin-top">0</xsl:attribute>
					</xsl:if>
					<xsl:apply-templates select="*[local-name() = 'name']" />
				</fo:block>
			</fo:table-cell>
			<fo:table-cell>
				<fo:block>
					<xsl:apply-templates select="node()[not(local-name() = 'name')]" />
				</fo:block>
			</fo:table-cell>
		</fo:table-row> -->
		<!-- <tr>
			<td number-columns-spanned="2">NOTE <xsl:apply-templates /> </td>
		</tr> 
		-->
		<fo:table-row>
			<fo:table-cell number-columns-spanned="2">
				<fo:block>
					<xsl:call-template name="note"/>
				</fo:block>
			</fo:table-cell>
		</fo:table-row>
	</xsl:template><xsl:template match="*[local-name()='dt']" mode="dl">
		<xsl:param name="id"/>
		<xsl:variable name="row_number" select="count(preceding-sibling::*[local-name()='dt']) + 1"/>
		<tr>
			<td>
				<xsl:attribute name="id">
					<xsl:value-of select="concat($id,'_',$row_number,'_1')"/>
				</xsl:attribute>
				<xsl:apply-templates/>
			</td>
			<td>
				<xsl:attribute name="id">
					<xsl:value-of select="concat($id,'_',$row_number,'_2')"/>
				</xsl:attribute>
				
						<xsl:apply-templates select="following-sibling::*[local-name()='dd'][1]">
							<xsl:with-param name="process">true</xsl:with-param>
						</xsl:apply-templates>
					
			</td>
		</tr>
		
	</xsl:template><xsl:template match="*[local-name()='dt']">
		<xsl:param name="key_iso"/>
		<xsl:param name="split_keep-within-line"/>
		
		<fo:table-row xsl:use-attribute-sets="dt-row-style">
			<xsl:call-template name="insert_dt_cell">
				<xsl:with-param name="key_iso" select="$key_iso"/>
				<xsl:with-param name="split_keep-within-line" select="$split_keep-within-line"/>
			</xsl:call-template>
			<xsl:for-each select="following-sibling::*[local-name()='dd'][1]">
				<xsl:call-template name="insert_dd_cell">
					<xsl:with-param name="split_keep-within-line" select="$split_keep-within-line"/>
				</xsl:call-template>
			</xsl:for-each>
		</fo:table-row>
	</xsl:template><xsl:template name="insert_dt_cell">
		<xsl:param name="key_iso"/>
		<xsl:param name="split_keep-within-line"/>
		<fo:table-cell xsl:use-attribute-sets="dt-cell-style">
		
			<xsl:if test="$isGenerateTableIF = 'true'">
				<!-- border is mandatory, to calculate real width -->
				<xsl:attribute name="border">0.1pt solid black</xsl:attribute>
				<xsl:attribute name="text-align">left</xsl:attribute>
			</xsl:if>
			
			
			<fo:block xsl:use-attribute-sets="dt-block-style">
				<xsl:copy-of select="@id"/>
				
				<xsl:if test="normalize-space($key_iso) = 'true'">
					<xsl:attribute name="margin-top">0</xsl:attribute>
				</xsl:if>
				
				
				
				<xsl:apply-templates>
					<xsl:with-param name="split_keep-within-line" select="$split_keep-within-line"/>
				</xsl:apply-templates>
				
				<xsl:if test="$isGenerateTableIF = 'true'"><fo:inline id="{@id}_end">end</fo:inline></xsl:if> <!-- to determine width of text --> <!-- <xsl:value-of select="$hair_space"/> -->
				
			</fo:block>
		</fo:table-cell>
	</xsl:template><xsl:template name="insert_dd_cell">
		<xsl:param name="split_keep-within-line"/>
		<fo:table-cell xsl:use-attribute-sets="dd-cell-style">
		
			<xsl:if test="$isGenerateTableIF = 'true'">
				<!-- border is mandatory, to calculate real width -->
				<xsl:attribute name="border">0.1pt solid black</xsl:attribute>
			</xsl:if>
		
			<fo:block>
			
				<xsl:if test="$isGenerateTableIF = 'true'">
					<xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
				</xsl:if>
			
				

				<xsl:choose>
					<xsl:when test="$isGenerateTableIF = 'true'">
						<xsl:apply-templates> <!-- following-sibling::*[local-name()='dd'][1] -->
							<xsl:with-param name="process">true</xsl:with-param>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="."> <!-- following-sibling::*[local-name()='dd'][1] -->
							<xsl:with-param name="process">true</xsl:with-param>
							<xsl:with-param name="split_keep-within-line" select="$split_keep-within-line"/>
						</xsl:apply-templates>
					</xsl:otherwise>
				
				</xsl:choose>
				
				<xsl:if test="$isGenerateTableIF = 'true'"><fo:inline id="{@id}_end">end</fo:inline></xsl:if> <!-- to determine width of text --> <!-- <xsl:value-of select="$hair_space"/> -->
				
			</fo:block>
		</fo:table-cell>
	</xsl:template><xsl:template match="*[local-name()='dd']" mode="dl"/><xsl:template match="*[local-name()='dd']" mode="dl_process">
		<xsl:apply-templates/>
	</xsl:template><xsl:template match="*[local-name()='dd']">
		<xsl:param name="process">false</xsl:param>
		<xsl:param name="split_keep-within-line"/>
		<xsl:if test="$process = 'true'">
			<xsl:apply-templates select="@language"/>
			<xsl:apply-templates>
				<xsl:with-param name="split_keep-within-line" select="$split_keep-within-line"/>
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template><xsl:template match="*[local-name()='dd']/*[local-name()='p']" mode="inline">
		<fo:inline><xsl:text> </xsl:text><xsl:apply-templates/></fo:inline>
	</xsl:template><xsl:template match="*[local-name()='dt']" mode="dl_if">
		<xsl:param name="id"/>
		<xsl:variable name="row_number" select="count(preceding-sibling::*[local-name()='dt']) + 1"/>
		<tr>
			<td>
				<xsl:copy-of select="node()"/>
			</td>
			<td>
				
						<xsl:copy-of select="following-sibling::*[local-name()='dd'][1]/node()[not(local-name() = 'dl')]"/>
						
						<!-- get paragraphs from nested 'dl' -->
						<xsl:apply-templates select="following-sibling::*[local-name()='dd'][1]/*[local-name() = 'dl']" mode="dl_if_nested"/>
						
					
			</td>
		</tr>
		
	</xsl:template><xsl:template match="*[local-name()='dd']" mode="dl_if"/><xsl:template match="*[local-name()='dl']" mode="dl_if_nested">
		<xsl:for-each select="*[local-name() = 'dt']">
			<p>
				<xsl:copy-of select="node()"/>
				<xsl:text> </xsl:text>
				<xsl:copy-of select="following-sibling::*[local-name()='dd'][1]/*[local-name() = 'p']/node()"/>
			</p>
		</xsl:for-each>
	</xsl:template><xsl:template match="*[local-name()='dd']" mode="dl_if_nested"/><xsl:template match="*[local-name()='em']">
		<fo:inline font-style="italic">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name()='strong'] | *[local-name()='b']">
		<xsl:param name="split_keep-within-line"/>
		<fo:inline font-weight="bold">
			
			<xsl:apply-templates>
				<xsl:with-param name="split_keep-within-line" select="$split_keep-within-line"/>
			</xsl:apply-templates>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name()='padding']">
		<fo:inline padding-right="{@value}"> </fo:inline>
	</xsl:template><xsl:template match="*[local-name()='sup']">
		<fo:inline font-size="80%" vertical-align="super">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name()='sub']">
		<fo:inline font-size="80%" vertical-align="sub">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name()='tt']">
		<fo:inline xsl:use-attribute-sets="tt-style">
		
			<xsl:variable name="_font-size">
				
				
				
				
				
				inherit <!-- 10 -->
				
				
				
				
				
				
				
				
				
						
			</xsl:variable>
			<xsl:variable name="font-size" select="normalize-space($_font-size)"/>		
			<xsl:if test="$font-size != ''">
				<xsl:attribute name="font-size">
					<xsl:choose>
						<xsl:when test="$font-size = 'inherit'"><xsl:value-of select="$font-size"/></xsl:when>
						<xsl:when test="contains($font-size, '%')"><xsl:value-of select="$font-size"/></xsl:when>
						<xsl:when test="ancestor::*[local-name()='note'] or ancestor::*[local-name()='example']"><xsl:value-of select="$font-size * 0.91"/>pt</xsl:when>
						<xsl:otherwise><xsl:value-of select="$font-size"/>pt</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name()='tt']/text()" priority="2">
		<xsl:call-template name="add_spaces_to_sourcecode"/>
	</xsl:template><xsl:template match="*[local-name()='underline']">
		<fo:inline text-decoration="underline">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name()='add']" name="tag_add">
		<xsl:param name="skip">true</xsl:param>
		<xsl:param name="block">false</xsl:param>
		<xsl:param name="type"/>
		<xsl:param name="text-align"/>
		<xsl:choose>
			<xsl:when test="starts-with(., $ace_tag)"> <!-- examples: ace-tag_A1_start, ace-tag_A2_end, C1_start, AC_start -->
				<xsl:choose>
					<xsl:when test="$skip = 'true' and       ((local-name(../..) = 'note' and not(preceding-sibling::node())) or       (local-name(..) = 'title' and preceding-sibling::node()[1][local-name() = 'tab']) or      local-name(..) = 'formattedref' and not(preceding-sibling::node()))      and       ../node()[last()][local-name() = 'add'][starts-with(text(), $ace_tag)]"><!-- start tag displayed in template name="note" and title --></xsl:when>
					<xsl:otherwise>
						<xsl:variable name="tag">
							<xsl:call-template name="insertTag">
								<xsl:with-param name="type">
									<xsl:choose>
										<xsl:when test="$type = ''"><xsl:value-of select="substring-after(substring-after(., $ace_tag), '_')"/> <!-- start or end --></xsl:when>
										<xsl:otherwise><xsl:value-of select="$type"/></xsl:otherwise>
									</xsl:choose>
								</xsl:with-param>
								<xsl:with-param name="kind" select="substring(substring-before(substring-after(., $ace_tag), '_'), 1, 1)"/> <!-- A or C -->
								<xsl:with-param name="value" select="substring(substring-before(substring-after(., $ace_tag), '_'), 2)"/> <!-- 1, 2, C -->
							</xsl:call-template>
						</xsl:variable>
						<xsl:choose>
							<xsl:when test="$block = 'false'">
								<fo:inline>
									<xsl:copy-of select="$tag"/>									
								</fo:inline>
							</xsl:when>
							<xsl:otherwise>
								<fo:block> <!-- for around figures -->
									<xsl:if test="$text-align != ''">
										<xsl:attribute name="text-align"><xsl:value-of select="$text-align"/></xsl:attribute>
									</xsl:if>
									<xsl:copy-of select="$tag"/>
								</fo:block>
							</xsl:otherwise>
						</xsl:choose>
						
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="@amendment">
				<fo:inline>
					<xsl:call-template name="insertTag">
						<xsl:with-param name="kind">A</xsl:with-param>
						<xsl:with-param name="value"><xsl:value-of select="@amendment"/></xsl:with-param>
					</xsl:call-template>
					<xsl:apply-templates/>
					<xsl:call-template name="insertTag">
						<xsl:with-param name="type">closing</xsl:with-param>
						<xsl:with-param name="kind">A</xsl:with-param>
						<xsl:with-param name="value"><xsl:value-of select="@amendment"/></xsl:with-param>
					</xsl:call-template>
				</fo:inline>
			</xsl:when>
			<xsl:when test="@corrigenda">
				<fo:inline>
					<xsl:call-template name="insertTag">
						<xsl:with-param name="kind">C</xsl:with-param>
						<xsl:with-param name="value"><xsl:value-of select="@corrigenda"/></xsl:with-param>
					</xsl:call-template>
					<xsl:apply-templates/>
					<xsl:call-template name="insertTag">
						<xsl:with-param name="type">closing</xsl:with-param>
						<xsl:with-param name="kind">C</xsl:with-param>
						<xsl:with-param name="value"><xsl:value-of select="@corrigenda"/></xsl:with-param>
					</xsl:call-template>
				</fo:inline>
			</xsl:when>
			<xsl:otherwise>
				<fo:inline xsl:use-attribute-sets="add-style">
					<xsl:apply-templates/>
				</fo:inline>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="insertTag">
		<xsl:param name="type"/>
		<xsl:param name="kind"/>
		<xsl:param name="value"/>
		<xsl:variable name="add_width" select="string-length($value) * 20"/>
		<xsl:variable name="maxwidth" select="60 + $add_width"/>
			<fo:instream-foreign-object fox:alt-text="OpeningTag" baseline-shift="-20%"><!-- alignment-baseline="middle" -->
				<xsl:attribute name="height">5mm</xsl:attribute>
				<xsl:attribute name="content-width">100%</xsl:attribute>
				<xsl:attribute name="content-width">scale-down-to-fit</xsl:attribute>
				<xsl:attribute name="scaling">uniform</xsl:attribute>
				<svg xmlns="http://www.w3.org/2000/svg" width="{$maxwidth + 32}" height="80">
					<g>
						<xsl:if test="$type = 'closing' or $type = 'end'">
							<xsl:attribute name="transform">scale(-1 1) translate(-<xsl:value-of select="$maxwidth + 32"/>,0)</xsl:attribute>
						</xsl:if>
						<polyline points="0,0 {$maxwidth},0 {$maxwidth + 30},40 {$maxwidth},80 0,80 " stroke="black" stroke-width="5" fill="white"/>
						<line x1="0" y1="0" x2="0" y2="80" stroke="black" stroke-width="20"/>
					</g>
					<text font-family="Arial" x="15" y="57" font-size="40pt">
						<xsl:if test="$type = 'closing' or $type = 'end'">
							<xsl:attribute name="x">25</xsl:attribute>
						</xsl:if>
						<xsl:value-of select="$kind"/><tspan dy="10" font-size="30pt"><xsl:value-of select="$value"/></tspan>
					</text>
				</svg>
			</fo:instream-foreign-object>
	</xsl:template><xsl:template match="*[local-name()='del']">
		<fo:inline xsl:use-attribute-sets="del-style">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name()='hi']">
		<fo:inline background-color="yellow">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template><xsl:template match="text()[ancestor::*[local-name()='smallcap']]">
		<xsl:variable name="text" select="normalize-space(.)"/>
		<fo:inline font-size="75%">
				<xsl:if test="string-length($text) &gt; 0">
					<xsl:call-template name="recursiveSmallCaps">
						<xsl:with-param name="text" select="$text"/>
					</xsl:call-template>
				</xsl:if>
			</fo:inline> 
	</xsl:template><xsl:template name="recursiveSmallCaps">
    <xsl:param name="text"/>
    <xsl:variable name="char" select="substring($text,1,1)"/>
    <!-- <xsl:variable name="upperCase" select="translate($char, $lower, $upper)"/> -->
		<xsl:variable name="upperCase" select="java:toUpperCase(java:java.lang.String.new($char))"/>
    <xsl:choose>
      <xsl:when test="$char=$upperCase">
        <fo:inline font-size="{100 div 0.75}%">
          <xsl:value-of select="$upperCase"/>
        </fo:inline>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$upperCase"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="string-length($text) &gt; 1">
      <xsl:call-template name="recursiveSmallCaps">
        <xsl:with-param name="text" select="substring($text,2)"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template><xsl:template match="*[local-name() = 'pagebreak']">
		<fo:block break-after="page"/>
		<fo:block> </fo:block>
		<fo:block break-after="page"/>
	</xsl:template><xsl:template match="*[local-name() = 'span']">
		<xsl:apply-templates/>
	</xsl:template><xsl:template name="tokenize">
		<xsl:param name="text"/>
		<xsl:param name="separator" select="' '"/>
		<xsl:choose>
		
			<xsl:when test="$isGenerateTableIF = 'true' and not(contains($text, $separator))">
				<word><xsl:value-of select="normalize-space($text)"/></word>
			</xsl:when>
			<xsl:when test="not(contains($text, $separator))">
				<word>
					<xsl:variable name="len_str_tmp" select="string-length(normalize-space($text))"/>
					<xsl:choose>
						<xsl:when test="normalize-space(translate($text, 'X', '')) = ''"> <!-- special case for keep-together.within-line -->
							<xsl:value-of select="$len_str_tmp"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="str_no_en_chars" select="normalize-space(translate($text, $en_chars, ''))"/>
							<xsl:variable name="len_str_no_en_chars" select="string-length($str_no_en_chars)"/>
							<xsl:variable name="len_str">
								<xsl:choose>
									<xsl:when test="normalize-space(translate($text, $upper, '')) = ''"> <!-- english word in CAPITAL letters -->
										<xsl:value-of select="$len_str_tmp * 1.5"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="$len_str_tmp"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable> 
							
							<!-- <xsl:if test="$len_str_no_en_chars div $len_str &gt; 0.8">
								<xsl:message>
									div=<xsl:value-of select="$len_str_no_en_chars div $len_str"/>
									len_str=<xsl:value-of select="$len_str"/>
									len_str_no_en_chars=<xsl:value-of select="$len_str_no_en_chars"/>
								</xsl:message>
							</xsl:if> -->
							<!-- <len_str_no_en_chars><xsl:value-of select="$len_str_no_en_chars"/></len_str_no_en_chars>
							<len_str><xsl:value-of select="$len_str"/></len_str> -->
							<xsl:choose>
								<xsl:when test="$len_str_no_en_chars div $len_str &gt; 0.8"> <!-- means non-english string -->
									<xsl:value-of select="$len_str - $len_str_no_en_chars"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$len_str"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</word>
			</xsl:when>
			<xsl:otherwise>
				<word>
					<xsl:variable name="word" select="normalize-space(substring-before($text, $separator))"/>
					<xsl:choose>
						<xsl:when test="$isGenerateTableIF = 'true'">
							<xsl:value-of select="$word"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="string-length($word)"/>
						</xsl:otherwise>
					</xsl:choose>
				</word>
				<xsl:call-template name="tokenize">
					<xsl:with-param name="text" select="substring-after($text, $separator)"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="tokenize_with_tags">
		<xsl:param name="tags"/>
		<xsl:param name="text"/>
		<xsl:param name="separator" select="' '"/>
		<xsl:choose>
		
			<xsl:when test="not(contains($text, $separator))">
				<word>
					<xsl:call-template name="enclose_text_in_tags">
						<xsl:with-param name="text" select="normalize-space($text)"/>
						<xsl:with-param name="tags" select="$tags"/>
					</xsl:call-template>
				</word>
			</xsl:when>
			<xsl:otherwise>
				<word>
					<xsl:call-template name="enclose_text_in_tags">
						<xsl:with-param name="text" select="normalize-space(substring-before($text, $separator))"/>
						<xsl:with-param name="tags" select="$tags"/>
					</xsl:call-template>
				</word>
				<xsl:call-template name="tokenize_with_tags">
					<xsl:with-param name="text" select="substring-after($text, $separator)"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="enclose_text_in_tags">
		<xsl:param name="text"/>
		<xsl:param name="tags"/>
		<xsl:param name="num">1</xsl:param> <!-- default (start) value -->
		
		<xsl:variable name="tag_name" select="normalize-space(xalan:nodeset($tags)//tag[$num])"/>
		
		<xsl:choose>
			<xsl:when test="$tag_name = ''"><xsl:value-of select="$text"/></xsl:when>
			<xsl:otherwise>
				<xsl:element name="{$tag_name}">
					<xsl:call-template name="enclose_text_in_tags">
						<xsl:with-param name="text" select="$text"/>
						<xsl:with-param name="tags" select="$tags"/>
						<xsl:with-param name="num" select="$num + 1"/>
					</xsl:call-template>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="max_length">
		<xsl:param name="words"/>
		<xsl:for-each select="$words//word">
				<xsl:sort select="." data-type="number" order="descending"/>
				<xsl:if test="position()=1">
						<xsl:value-of select="."/>
				</xsl:if>
		</xsl:for-each>
	</xsl:template><xsl:template name="add-zero-spaces-java">
		<xsl:param name="text" select="."/>
		<!-- add zero-width space (#x200B) after characters: dash, dot, colon, equal, underscore, em dash, thin space  -->
		<xsl:value-of select="java:replaceAll(java:java.lang.String.new($text),'(-|\.|:|=|_|—| )','$1​')"/>
	</xsl:template><xsl:template name="add-zero-spaces-link-java">
		<xsl:param name="text" select="."/>
		<!-- add zero-width space (#x200B) after characters: dash, dot, colon, equal, underscore, em dash, thin space  -->
		<xsl:value-of select="java:replaceAll(java:java.lang.String.new($text),'(-|\.|:|=|_|—| |,)','$1​')"/>
	</xsl:template><xsl:template name="add-zero-spaces">
		<xsl:param name="text" select="."/>
		<xsl:variable name="zero-space-after-chars">-</xsl:variable>
		<xsl:variable name="zero-space-after-dot">.</xsl:variable>
		<xsl:variable name="zero-space-after-colon">:</xsl:variable>
		<xsl:variable name="zero-space-after-equal">=</xsl:variable>
		<xsl:variable name="zero-space-after-underscore">_</xsl:variable>
		<xsl:variable name="zero-space">​</xsl:variable>
		<xsl:choose>
			<xsl:when test="contains($text, $zero-space-after-chars)">
				<xsl:value-of select="substring-before($text, $zero-space-after-chars)"/>
				<xsl:value-of select="$zero-space-after-chars"/>
				<xsl:value-of select="$zero-space"/>
				<xsl:call-template name="add-zero-spaces">
					<xsl:with-param name="text" select="substring-after($text, $zero-space-after-chars)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="contains($text, $zero-space-after-dot)">
				<xsl:value-of select="substring-before($text, $zero-space-after-dot)"/>
				<xsl:value-of select="$zero-space-after-dot"/>
				<xsl:value-of select="$zero-space"/>
				<xsl:call-template name="add-zero-spaces">
					<xsl:with-param name="text" select="substring-after($text, $zero-space-after-dot)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="contains($text, $zero-space-after-colon)">
				<xsl:value-of select="substring-before($text, $zero-space-after-colon)"/>
				<xsl:value-of select="$zero-space-after-colon"/>
				<xsl:value-of select="$zero-space"/>
				<xsl:call-template name="add-zero-spaces">
					<xsl:with-param name="text" select="substring-after($text, $zero-space-after-colon)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="contains($text, $zero-space-after-equal)">
				<xsl:value-of select="substring-before($text, $zero-space-after-equal)"/>
				<xsl:value-of select="$zero-space-after-equal"/>
				<xsl:value-of select="$zero-space"/>
				<xsl:call-template name="add-zero-spaces">
					<xsl:with-param name="text" select="substring-after($text, $zero-space-after-equal)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="contains($text, $zero-space-after-underscore)">
				<xsl:value-of select="substring-before($text, $zero-space-after-underscore)"/>
				<xsl:value-of select="$zero-space-after-underscore"/>
				<xsl:value-of select="$zero-space"/>
				<xsl:call-template name="add-zero-spaces">
					<xsl:with-param name="text" select="substring-after($text, $zero-space-after-underscore)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="add-zero-spaces-equal">
		<xsl:param name="text" select="."/>
		<xsl:variable name="zero-space-after-equals">==========</xsl:variable>
		<xsl:variable name="regex_zero-space-after-equals">(==========)</xsl:variable>
		<xsl:variable name="zero-space-after-equal">=</xsl:variable>
		<xsl:variable name="regex_zero-space-after-equal">(=)</xsl:variable>
		<xsl:variable name="zero-space">​</xsl:variable>
		<xsl:choose>
			<xsl:when test="contains($text, $zero-space-after-equals)">
				<!-- <xsl:value-of select="substring-before($text, $zero-space-after-equals)"/>
				<xsl:value-of select="$zero-space-after-equals"/>
				<xsl:value-of select="$zero-space"/>
				<xsl:call-template name="add-zero-spaces-equal">
					<xsl:with-param name="text" select="substring-after($text, $zero-space-after-equals)"/>
				</xsl:call-template> -->
				<xsl:value-of select="java:replaceAll(java:java.lang.String.new(.),$regex_zero-space-after-equals,concat('$1',$zero_width_space))"/>
			</xsl:when>
			<xsl:when test="contains($text, $zero-space-after-equal)">
				<!-- <xsl:value-of select="substring-before($text, $zero-space-after-equal)"/>
				<xsl:value-of select="$zero-space-after-equal"/>
				<xsl:value-of select="$zero-space"/>
				<xsl:call-template name="add-zero-spaces-equal">
					<xsl:with-param name="text" select="substring-after($text, $zero-space-after-equal)"/>
				</xsl:call-template> -->
				<xsl:value-of select="java:replaceAll(java:java.lang.String.new(.),$regex_zero-space-after-equal,concat('$1',$zero_width_space))"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="getSimpleTable">
		<xsl:param name="id"/>
		
		<xsl:variable name="simple-table">
		
			<!-- Step 0. replace <br/> to <p>...</p> -->
			<xsl:variable name="table_without_br">
				<xsl:apply-templates mode="table-without-br"/>
			</xsl:variable>
		
			<!-- Step 1. colspan processing -->
			<xsl:variable name="simple-table-colspan">
				<tbody>
					<xsl:apply-templates select="xalan:nodeset($table_without_br)" mode="simple-table-colspan"/>
				</tbody>
			</xsl:variable>
			
			<!-- Step 2. rowspan processing -->
			<xsl:variable name="simple-table-rowspan">
				<xsl:apply-templates select="xalan:nodeset($simple-table-colspan)" mode="simple-table-rowspan"/>
			</xsl:variable>
			
			<!-- Step 3: add id to each cell -->
			<!-- add <word>...</word> for each word, image, math -->
			<xsl:variable name="simple-table-id">
				<xsl:apply-templates select="xalan:nodeset($simple-table-rowspan)" mode="simple-table-id">
					<xsl:with-param name="id" select="$id"/>
				</xsl:apply-templates>
			</xsl:variable>
			
			<xsl:copy-of select="xalan:nodeset($simple-table-id)"/>

		</xsl:variable>
		<xsl:copy-of select="$simple-table"/>
	</xsl:template><xsl:template match="@*|node()" mode="table-without-br">
		<xsl:copy>
				<xsl:apply-templates select="@*|node()" mode="table-without-br"/>
		</xsl:copy>
	</xsl:template><xsl:template match="*[local-name()='th' or local-name() = 'td'][not(*[local-name()='br']) and not(*[local-name()='p'])]" mode="table-without-br">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<p>
				<xsl:copy-of select="node()"/>
			</p>
		</xsl:copy>
	</xsl:template><xsl:template match="*[local-name()='th' or local-name()='td'][*[local-name()='br']]" mode="table-without-br">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:for-each select="*[local-name()='br']">
				<xsl:variable name="current_id" select="generate-id()"/>
				<p>
					<xsl:for-each select="preceding-sibling::node()[following-sibling::*[local-name() = 'br'][1][generate-id() = $current_id]][not(local-name() = 'br')]">
						<xsl:copy-of select="."/>
					</xsl:for-each>
				</p>
				<xsl:if test="not(following-sibling::*[local-name() = 'br'])">
					<p>
						<xsl:for-each select="following-sibling::node()">
							<xsl:copy-of select="."/>
						</xsl:for-each>
					</p>
				</xsl:if>
			</xsl:for-each>
		</xsl:copy>
	</xsl:template><xsl:template match="*[local-name()='th' or local-name()='td']/*[local-name() = 'p'][*[local-name()='br']]" mode="table-without-br">
		<xsl:for-each select="*[local-name()='br']">
			<xsl:variable name="current_id" select="generate-id()"/>
			<p>
				<xsl:for-each select="preceding-sibling::node()[following-sibling::*[local-name() = 'br'][1][generate-id() = $current_id]][not(local-name() = 'br')]">
					<xsl:copy-of select="."/>
				</xsl:for-each>
			</p>
			<xsl:if test="not(following-sibling::*[local-name() = 'br'])">
				<p>
					<xsl:for-each select="following-sibling::node()">
						<xsl:copy-of select="."/>
					</xsl:for-each>
				</p>
			</xsl:if>
		</xsl:for-each>
	</xsl:template><xsl:template match="text()[not(ancestor::*[local-name() = 'sourcecode'])]" mode="table-without-br">
		<xsl:variable name="text" select="translate(.,'&#9;&#10;&#13;','')"/>
		<xsl:value-of select="java:replaceAll(java:java.lang.String.new($text),' {2,}',' ')"/>
	</xsl:template><xsl:template match="*[local-name()='thead'] | *[local-name()='tbody']" mode="simple-table-colspan">
		<xsl:apply-templates mode="simple-table-colspan"/>
	</xsl:template><xsl:template match="*[local-name()='fn']" mode="simple-table-colspan"/><xsl:template match="*[local-name()='th'] | *[local-name()='td']" mode="simple-table-colspan">
		<xsl:choose>
			<xsl:when test="@colspan">
				<xsl:variable name="td">
					<xsl:element name="td">
						<xsl:attribute name="divide"><xsl:value-of select="@colspan"/></xsl:attribute>
						<xsl:apply-templates select="@*" mode="simple-table-colspan"/>
						<xsl:apply-templates mode="simple-table-colspan"/>
					</xsl:element>
				</xsl:variable>
				<xsl:call-template name="repeatNode">
					<xsl:with-param name="count" select="@colspan"/>
					<xsl:with-param name="node" select="$td"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="td">
					<xsl:apply-templates select="@*" mode="simple-table-colspan"/>
					<xsl:apply-templates mode="simple-table-colspan"/>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template match="@colspan" mode="simple-table-colspan"/><xsl:template match="*[local-name()='tr']" mode="simple-table-colspan">
		<xsl:element name="tr">
			<xsl:apply-templates select="@*" mode="simple-table-colspan"/>
			<xsl:apply-templates mode="simple-table-colspan"/>
		</xsl:element>
	</xsl:template><xsl:template match="@*|node()" mode="simple-table-colspan">
		<xsl:copy>
				<xsl:apply-templates select="@*|node()" mode="simple-table-colspan"/>
		</xsl:copy>
	</xsl:template><xsl:template name="repeatNode">
		<xsl:param name="count"/>
		<xsl:param name="node"/>
		
		<xsl:if test="$count &gt; 0">
			<xsl:call-template name="repeatNode">
				<xsl:with-param name="count" select="$count - 1"/>
				<xsl:with-param name="node" select="$node"/>
			</xsl:call-template>
			<xsl:copy-of select="$node"/>
		</xsl:if>
	</xsl:template><xsl:template match="@*|node()" mode="simple-table-rowspan">
		<xsl:copy>
				<xsl:apply-templates select="@*|node()" mode="simple-table-rowspan"/>
		</xsl:copy>
	</xsl:template><xsl:template match="tbody" mode="simple-table-rowspan">
		<xsl:copy>
				<xsl:copy-of select="tr[1]"/>
				<xsl:apply-templates select="tr[2]" mode="simple-table-rowspan">
						<xsl:with-param name="previousRow" select="tr[1]"/>
				</xsl:apply-templates>
		</xsl:copy>
	</xsl:template><xsl:template match="tr" mode="simple-table-rowspan">
		<xsl:param name="previousRow"/>
		<xsl:variable name="currentRow" select="."/>
	
		<xsl:variable name="normalizedTDs">
				<xsl:for-each select="xalan:nodeset($previousRow)//td">
						<xsl:choose>
								<xsl:when test="@rowspan &gt; 1">
										<xsl:copy>
												<xsl:attribute name="rowspan">
														<xsl:value-of select="@rowspan - 1"/>
												</xsl:attribute>
												<xsl:copy-of select="@*[not(name() = 'rowspan')]"/>
												<xsl:copy-of select="node()"/>
										</xsl:copy>
								</xsl:when>
								<xsl:otherwise>
										<xsl:copy-of select="$currentRow/td[1 + count(current()/preceding-sibling::td[not(@rowspan) or (@rowspan = 1)])]"/>
								</xsl:otherwise>
						</xsl:choose>
				</xsl:for-each>
		</xsl:variable>

		<xsl:variable name="newRow">
				<xsl:copy>
						<xsl:copy-of select="$currentRow/@*"/>
						<xsl:copy-of select="xalan:nodeset($normalizedTDs)"/>
				</xsl:copy>
		</xsl:variable>
		<xsl:copy-of select="$newRow"/>

		<xsl:apply-templates select="following-sibling::tr[1]" mode="simple-table-rowspan">
				<xsl:with-param name="previousRow" select="$newRow"/>
		</xsl:apply-templates>
	</xsl:template><xsl:template match="/" mode="simple-table-id">
		<xsl:param name="id"/>
		<xsl:variable name="id_prefixed" select="concat('table_if_',$id)"/> <!-- table id prefixed by 'table_if_' to simple search in IF  -->
		<xsl:apply-templates select="@*|node()" mode="simple-table-id">
			<xsl:with-param name="id" select="$id_prefixed"/>
		</xsl:apply-templates>
	</xsl:template><xsl:template match="@*|node()" mode="simple-table-id">
		<xsl:param name="id"/>
		<xsl:copy>
				<xsl:apply-templates select="@*|node()" mode="simple-table-id">
					<xsl:with-param name="id" select="$id"/>
				</xsl:apply-templates>
		</xsl:copy>
	</xsl:template><xsl:template match="*[local-name()='tbody']" mode="simple-table-id">
		<xsl:param name="id"/>
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:attribute name="id"><xsl:value-of select="$id"/></xsl:attribute>
			<xsl:apply-templates select="node()" mode="simple-table-id">
				<xsl:with-param name="id" select="$id"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template><xsl:template match="*[local-name()='th' or local-name()='td']" mode="simple-table-id">
		<xsl:param name="id"/>
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:variable name="row_number" select="count(../preceding-sibling::*) + 1"/>
			<xsl:variable name="col_number" select="count(preceding-sibling::*) + 1"/>
			<xsl:attribute name="id">
				<xsl:value-of select="concat($id,'_',$row_number,'_',$col_number)"/>
			</xsl:attribute>
			
			<xsl:for-each select="*[local-name() = 'p']">
				<xsl:copy>
					<xsl:copy-of select="@*"/>
					<xsl:variable name="p_num" select="count(preceding-sibling::*[local-name() = 'p']) + 1"/>
					<xsl:attribute name="id">
						<xsl:value-of select="concat($id,'_',$row_number,'_',$col_number,'_p_',$p_num)"/>
					</xsl:attribute>
					
					<xsl:copy-of select="node()"/>
				</xsl:copy>
			</xsl:for-each>
			
			
			<xsl:if test="$isGenerateTableIF = 'true'"> <!-- split each paragraph to words, image, math -->
			
				<xsl:variable name="td_text">
					<xsl:apply-templates select="." mode="td_text_with_formatting"/>
				</xsl:variable>
				
				<!-- td_text='<xsl:copy-of select="$td_text"/>' -->
			
				<xsl:variable name="words">
					<xsl:for-each select=".//*[local-name() = 'image' or local-name() = 'stem']">
						<word>
							<xsl:copy-of select="."/>
						</word>
					</xsl:for-each>
					
					<xsl:for-each select="xalan:nodeset($td_text)//*[local-name() = 'word'][normalize-space() != '']">
						<xsl:copy-of select="."/>
					</xsl:for-each>
					
				</xsl:variable>
				
				<xsl:for-each select="xalan:nodeset($words)/word">
					<xsl:variable name="num" select="count(preceding-sibling::word) + 1"/>
					<xsl:copy>
						<xsl:attribute name="id">
							<xsl:value-of select="concat($id,'_',$row_number,'_',$col_number,'_word_',$num)"/>
						</xsl:attribute>
						<xsl:copy-of select="node()"/>
					</xsl:copy>
				</xsl:for-each>
			</xsl:if>
		</xsl:copy>
		
	</xsl:template><xsl:template match="@*|node()" mode="td_text_with_formatting">
		<xsl:copy>
				<xsl:apply-templates select="@*|node()" mode="td_text_with_formatting"/>
		</xsl:copy>
	</xsl:template><xsl:template match="*[local-name() = 'stem' or local-name() = 'image']" mode="td_text_with_formatting"/><xsl:template match="*[local-name() = 'keep-together_within-line']/text()" mode="td_text_with_formatting">
		<xsl:variable name="formatting_tags">
			<xsl:call-template name="getFormattingTags"/>
		</xsl:variable>
		<word>
			<xsl:call-template name="enclose_text_in_tags">
				<xsl:with-param name="text" select="normalize-space(.)"/>
				<xsl:with-param name="tags" select="$formatting_tags"/>
			</xsl:call-template>
		</word>
	</xsl:template><xsl:template match="*[local-name() != 'keep-together_within-line']/text()" mode="td_text_with_formatting">
		
		<xsl:variable name="td_text" select="."/>
		
		<xsl:variable name="string_with_added_zerospaces">
			<xsl:call-template name="add-zero-spaces-java">
				<xsl:with-param name="text" select="$td_text"/>
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:variable name="formatting_tags">
			<xsl:call-template name="getFormattingTags"/>
		</xsl:variable>
		
		<!-- <word>text</word> -->
		<xsl:call-template name="tokenize_with_tags">
			<xsl:with-param name="tags" select="$formatting_tags"/>
			<xsl:with-param name="text" select="normalize-space(translate($string_with_added_zerospaces, '​­', '  '))"/> <!-- replace zero-width-space and soft-hyphen to space -->
		</xsl:call-template>
	</xsl:template><xsl:template name="getFormattingTags">
		<tags>
			<xsl:if test="ancestor::*[local-name() = 'strong']"><tag>strong</tag></xsl:if>
			<xsl:if test="ancestor::*[local-name() = 'em']"><tag>em</tag></xsl:if>
			<xsl:if test="ancestor::*[local-name() = 'sub']"><tag>sub</tag></xsl:if>
			<xsl:if test="ancestor::*[local-name() = 'sup']"><tag>sup</tag></xsl:if>
			<xsl:if test="ancestor::*[local-name() = 'tt']"><tag>tt</tag></xsl:if>
			<xsl:if test="ancestor::*[local-name() = 'keep-together_within-line']"><tag>keep-together_within-line</tag></xsl:if>
		</tags>
	</xsl:template><xsl:template name="getLang">
		<xsl:variable name="language_current" select="normalize-space(//*[local-name()='bibdata']//*[local-name()='language'][@current = 'true'])"/>
		<xsl:variable name="language">
			<xsl:choose>
				<xsl:when test="$language_current != ''">
					<xsl:value-of select="$language_current"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="language_current_2" select="normalize-space(xalan:nodeset($bibdata)//*[local-name()='bibdata']//*[local-name()='language'][@current = 'true'])"/>
					<xsl:choose>
						<xsl:when test="$language_current_2 != ''">
							<xsl:value-of select="$language_current_2"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="//*[local-name()='bibdata']//*[local-name()='language']"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="$language = 'English'">en</xsl:when>
			<xsl:otherwise><xsl:value-of select="$language"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="capitalizeWords">
		<xsl:param name="str"/>
		<xsl:variable name="str2" select="translate($str, '-', ' ')"/>
		<xsl:choose>
			<xsl:when test="contains($str2, ' ')">
				<xsl:variable name="substr" select="substring-before($str2, ' ')"/>
				<xsl:call-template name="capitalize">
					<xsl:with-param name="str" select="$substr"/>
				</xsl:call-template>
				<xsl:text> </xsl:text>
				<xsl:call-template name="capitalizeWords">
					<xsl:with-param name="str" select="substring-after($str2, ' ')"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="capitalize">
					<xsl:with-param name="str" select="$str2"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="capitalize">
		<xsl:param name="str"/>
		<xsl:value-of select="java:toUpperCase(java:java.lang.String.new(substring($str, 1, 1)))"/>
		<xsl:value-of select="substring($str, 2)"/>		
	</xsl:template><xsl:template match="mathml:math">
		<xsl:variable name="isAdded" select="@added"/>
		<xsl:variable name="isDeleted" select="@deleted"/>
		
		<fo:inline xsl:use-attribute-sets="mathml-style">
		
			
			
			
			
			<xsl:call-template name="setTrackChangesStyles">
				<xsl:with-param name="isAdded" select="$isAdded"/>
				<xsl:with-param name="isDeleted" select="$isDeleted"/>
			</xsl:call-template>
			
			<xsl:if test="$add_math_as_text = 'true'">
				<!-- insert helper tag -->
				<!-- set unique font-size (fiction) -->
				<xsl:variable name="font-size_sfx"><xsl:number level="any"/></xsl:variable>
				<fo:inline color="white" font-size="1.{$font-size_sfx}pt" font-style="normal" font-weight="normal"><xsl:value-of select="$zero_width_space"/></fo:inline> <!-- zero width space -->
			</xsl:if>
			
			<xsl:variable name="mathml_content">
				<xsl:apply-templates select="." mode="mathml_actual_text"/>
			</xsl:variable>
			
			
					<xsl:call-template name="mathml_instream_object">
						<xsl:with-param name="mathml_content" select="$mathml_content"/>
					</xsl:call-template>
				
			
		</fo:inline>
	</xsl:template><xsl:template name="getMathml_comment_text">
		<xsl:variable name="comment_text_following" select="following-sibling::node()[1][self::comment()]"/>
		<xsl:variable name="comment_text_">
			<xsl:choose>
				<xsl:when test="normalize-space($comment_text_following) != ''">
					<xsl:value-of select="$comment_text_following"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="normalize-space(translate(.,' ⁢','  '))"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable> 
		<xsl:variable name="comment_text_2" select="java:org.metanorma.fop.Util.unescape($comment_text_)"/>
		<xsl:variable name="comment_text" select="java:trim(java:java.lang.String.new($comment_text_2))"/>
		<xsl:value-of select="$comment_text"/>
	</xsl:template><xsl:template name="mathml_instream_object">
		<xsl:param name="comment_text"/>
		<xsl:param name="mathml_content"/>
	
		<xsl:variable name="comment_text_">
			<xsl:choose>
				<xsl:when test="normalize-space($comment_text) != ''"><xsl:value-of select="$comment_text"/></xsl:when>
				<xsl:otherwise><xsl:call-template name="getMathml_comment_text"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
	
		<xsl:variable name="mathml">
			<xsl:apply-templates select="." mode="mathml"/>
		</xsl:variable>
			
		<fo:instream-foreign-object fox:alt-text="Math">
					
			
			
			
				<xsl:if test="count(ancestor::*[local-name() = 'table']) &gt; 1">
					<xsl:attribute name="width">95%</xsl:attribute>
					<xsl:attribute name="content-height">100%</xsl:attribute>
					<xsl:attribute name="content-width">scale-down-to-fit</xsl:attribute>
					<xsl:attribute name="scaling">uniform</xsl:attribute>
				</xsl:if>
			
			
			
			
			<!-- put MathML in Actual Text -->
			<!-- DEBUG: mathml_content=<xsl:value-of select="$mathml_content"/> -->
			<xsl:attribute name="fox:actual-text">
				<xsl:value-of select="$mathml_content"/>
			</xsl:attribute>
			
			<!-- <xsl:if test="$add_math_as_text = 'true'"> -->
			<xsl:if test="normalize-space($comment_text_) != ''">
			<!-- put Mathin Alternate Text -->
				<xsl:attribute name="fox:alt-text">
					<xsl:value-of select="$comment_text_"/>
				</xsl:attribute>
			</xsl:if>
			<!-- </xsl:if> -->
		
			<xsl:copy-of select="xalan:nodeset($mathml)"/>
			
		</fo:instream-foreign-object>
	</xsl:template><xsl:template match="mathml:*" mode="mathml_actual_text">
		<!-- <xsl:text>a+b</xsl:text> -->
		<xsl:text>&lt;</xsl:text>
		<xsl:value-of select="local-name()"/>
		<xsl:if test="local-name() = 'math'">
			<xsl:text> xmlns="http://www.w3.org/1998/Math/MathML"</xsl:text>
		</xsl:if>
		<xsl:for-each select="@*">
			<xsl:text> </xsl:text>
			<xsl:value-of select="local-name()"/>
			<xsl:text>="</xsl:text>
			<xsl:value-of select="."/>
			<xsl:text>"</xsl:text>
		</xsl:for-each>
		<xsl:text>&gt;</xsl:text>		
		<xsl:apply-templates mode="mathml_actual_text"/>		
		<xsl:text>&lt;/</xsl:text>
		<xsl:value-of select="local-name()"/>
		<xsl:text>&gt;</xsl:text>
	</xsl:template><xsl:template match="text()" mode="mathml_actual_text">
		<xsl:value-of select="normalize-space()"/>
	</xsl:template><xsl:template match="@*|node()" mode="mathml">
		<xsl:copy>
				<xsl:apply-templates select="@*|node()" mode="mathml"/>
		</xsl:copy>
	</xsl:template><xsl:template match="mathml:mtext" mode="mathml">
		<xsl:copy>
			<!-- replace start and end spaces to non-break space -->
			<xsl:value-of select="java:replaceAll(java:java.lang.String.new(.),'(^ )|( $)',' ')"/>
		</xsl:copy>
	</xsl:template><xsl:template match="mathml:math/*[local-name()='unit']" mode="mathml"/><xsl:template match="mathml:math/*[local-name()='prefix']" mode="mathml"/><xsl:template match="mathml:math/*[local-name()='dimension']" mode="mathml"/><xsl:template match="mathml:math/*[local-name()='quantity']" mode="mathml"/><xsl:template match="mathml:mtd/mathml:mo/text()[. = '/']" mode="mathml">
		<xsl:value-of select="."/><xsl:value-of select="$zero_width_space"/>
	</xsl:template><xsl:template match="*[local-name()='localityStack']"/><xsl:template match="*[local-name()='link']" name="link">
		<xsl:variable name="target">
			<xsl:choose>
				<xsl:when test="@updatetype = 'true'">
					<xsl:value-of select="concat(normalize-space(@target), '.pdf')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="normalize-space(@target)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="target_text">
			<xsl:choose>
				<xsl:when test="starts-with(normalize-space(@target), 'mailto:')">
					<xsl:value-of select="normalize-space(substring-after(@target, 'mailto:'))"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="normalize-space(@target)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<fo:inline xsl:use-attribute-sets="link-style">
			
			<xsl:if test="starts-with(normalize-space(@target), 'mailto:')">
				<xsl:attribute name="keep-together.within-line">always</xsl:attribute>
			</xsl:if>
			
			
			
			
			
			
			
			
			
			
			<xsl:choose>
				<xsl:when test="$target_text = ''">
					<xsl:apply-templates/>
				</xsl:when>
				<xsl:otherwise>
					<fo:basic-link external-destination="{$target}" fox:alt-text="{$target}">
						<xsl:choose>
							<xsl:when test="normalize-space(.) = ''">
								<xsl:call-template name="add-zero-spaces-link-java">
									<xsl:with-param name="text" select="$target_text"/>
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<!-- output text from <link>text</link> -->
								<xsl:apply-templates/>
							</xsl:otherwise>
						</xsl:choose>
					</fo:basic-link>
				</xsl:otherwise>
			</xsl:choose>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name()='appendix']">
		<fo:block id="{@id}" xsl:use-attribute-sets="appendix-style">
			<xsl:apply-templates select="*[local-name()='title']"/>
		</fo:block>
		<xsl:apply-templates select="node()[not(local-name()='title')]"/>
	</xsl:template><xsl:template match="*[local-name()='appendix']/*[local-name()='title']" priority="2">
		<xsl:variable name="level">
			<xsl:call-template name="getLevel"/>
		</xsl:variable>
		<fo:inline role="H{$level}"><xsl:apply-templates/></fo:inline>
	</xsl:template><xsl:template match="*[local-name()='appendix']//*[local-name()='example']" priority="2">
		<fo:block id="{@id}" xsl:use-attribute-sets="appendix-example-style">			
			<xsl:apply-templates select="*[local-name()='name']"/>
		</fo:block>
		<xsl:apply-templates select="node()[not(local-name()='name')]"/>
	</xsl:template><xsl:template match="*[local-name() = 'callout']">		
		<fo:basic-link internal-destination="{@target}" fox:alt-text="{@target}">&lt;<xsl:apply-templates/>&gt;</fo:basic-link>
	</xsl:template><xsl:template match="*[local-name() = 'annotation']">
		<xsl:variable name="annotation-id" select="@id"/>
		<xsl:variable name="callout" select="//*[@target = $annotation-id]/text()"/>		
		<fo:block id="{$annotation-id}" white-space="nowrap">			
			<fo:inline>				
				<xsl:apply-templates>
					<xsl:with-param name="callout" select="concat('&lt;', $callout, '&gt; ')"/>
				</xsl:apply-templates>
			</fo:inline>
		</fo:block>		
	</xsl:template><xsl:template match="*[local-name() = 'annotation']/*[local-name() = 'p']">
		<xsl:param name="callout"/>
		<fo:inline id="{@id}">
			<!-- for first p in annotation, put <x> -->
			<xsl:if test="not(preceding-sibling::*[local-name() = 'p'])"><xsl:value-of select="$callout"/></xsl:if>
			<xsl:apply-templates/>
		</fo:inline>		
	</xsl:template><xsl:template match="*[local-name() = 'xref']">
		<fo:basic-link internal-destination="{@target}" fox:alt-text="{@target}" xsl:use-attribute-sets="xref-style">
			<xsl:if test="parent::*[local-name() = 'add']">
				<xsl:call-template name="append_add-style"/>
			</xsl:if>
			<xsl:apply-templates/>
		</fo:basic-link>
	</xsl:template><xsl:template match="*[local-name() = 'formula']" name="formula">
		<fo:block-container margin-left="0mm">
			<xsl:if test="parent::*[local-name() = 'note']">
				<xsl:attribute name="margin-left">
					<xsl:choose>
						<xsl:when test="not(ancestor::*[local-name() = 'table'])"><xsl:value-of select="$note-body-indent"/></xsl:when>
						<xsl:otherwise><xsl:value-of select="$note-body-indent-table"/></xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				
			</xsl:if>
			<fo:block-container margin-left="0mm">	
				<fo:block id="{@id}">
					<xsl:apply-templates select="node()[not(local-name() = 'name')]"/> <!-- formula's number will be process in 'stem' template -->
				</fo:block>
			</fo:block-container>
		</fo:block-container>
	</xsl:template><xsl:template match="*[local-name() = 'formula']/*[local-name() = 'dt']/*[local-name() = 'stem']">
		<fo:inline>
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name() = 'admitted']/*[local-name() = 'stem']">
		<fo:inline>
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name() = 'formula']/*[local-name() = 'name']"> <!-- show in 'stem' template -->
		<xsl:if test="normalize-space() != ''">
			<xsl:text>(</xsl:text><xsl:apply-templates/><xsl:text>)</xsl:text>
		</xsl:if>
	</xsl:template><xsl:template match="*[local-name() = 'formula'][*[local-name() = 'name']]/*[local-name() = 'stem']">
		<fo:block xsl:use-attribute-sets="formula-style">
		
			
		
			<fo:table table-layout="fixed" width="100%">
				<fo:table-column column-width="95%"/>
				<fo:table-column column-width="5%"/>
				<fo:table-body>
					<fo:table-row>
						<fo:table-cell display-align="center">
							<fo:block xsl:use-attribute-sets="formula-stem-block-style">
							
								
							
								<xsl:apply-templates/>
							</fo:block>
						</fo:table-cell>
						<fo:table-cell display-align="center">
							<fo:block xsl:use-attribute-sets="formula-stem-number-style">
								<xsl:apply-templates select="../*[local-name() = 'name']"/>
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
				</fo:table-body>
			</fo:table>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'formula'][not(*[local-name() = 'name'])]/*[local-name() = 'stem']">
		<fo:block xsl:use-attribute-sets="formula-style">
			<fo:block xsl:use-attribute-sets="formula-stem-block-style">
				<xsl:apply-templates/>
			</fo:block>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'note']" name="note">
	
		<fo:block-container id="{@id}" xsl:use-attribute-sets="note-style">
		
			
			
			
			
			
			
			
		
			
			
			<fo:block-container margin-left="0mm">
			
				
				
				
			
				
						<fo:block>
							
							
						
							
							
							
							
							<fo:inline xsl:use-attribute-sets="note-name-style">
							
								
								
								<!-- if 'p' contains all text in 'add' first and last elements in first p are 'add' -->
								<!-- <xsl:if test="*[not(local-name()='name')][1][node()[normalize-space() != ''][1][local-name() = 'add'] and node()[normalize-space() != ''][last()][local-name() = 'add']]"> -->
								<xsl:if test="*[not(local-name()='name')][1][count(node()[normalize-space() != '']) = 1 and *[local-name() = 'add']]">
									<xsl:call-template name="append_add-style"/>
								</xsl:if>
								
								
								<!-- if note contains only one element and first and last childs are `add` ace-tag, then move start ace-tag before NOTE's name-->
								<xsl:if test="count(*[not(local-name() = 'name')]) = 1 and *[not(local-name() = 'name')]/node()[last()][local-name() = 'add'][starts-with(text(), $ace_tag)]">
									<xsl:apply-templates select="*[not(local-name() = 'name')]/node()[1][local-name() = 'add'][starts-with(text(), $ace_tag)]">
										<xsl:with-param name="skip">false</xsl:with-param>
									</xsl:apply-templates> 
								</xsl:if>
								
								<xsl:apply-templates select="*[local-name() = 'name']"/>
								
							</fo:inline>
							
							<xsl:apply-templates select="node()[not(local-name() = 'name')]"/>
						</fo:block>
					
			</fo:block-container>
		</fo:block-container>
		
	</xsl:template><xsl:template match="*[local-name() = 'note']/*[local-name() = 'p']">
		<xsl:variable name="num"><xsl:number/></xsl:variable>
		<xsl:choose>
			<xsl:when test="$num = 1"> <!-- display first NOTE's paragraph in the same line with label NOTE -->
				<fo:inline xsl:use-attribute-sets="note-p-style">
					<xsl:apply-templates/>
				</fo:inline>
			</xsl:when>
			<xsl:otherwise>
				<fo:block xsl:use-attribute-sets="note-p-style">						
					<xsl:apply-templates/>
				</fo:block>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template match="*[local-name() = 'termnote']">
		<fo:block id="{@id}" xsl:use-attribute-sets="termnote-style">			
			
			<fo:inline xsl:use-attribute-sets="termnote-name-style">
			
				<xsl:if test="not(*[local-name() = 'name']/following-sibling::node()[1][self::text()][normalize-space()=''])">
					<xsl:attribute name="padding-right">1mm</xsl:attribute>
				</xsl:if>
			
				

				
				
				<!-- if 'p' contains all text in 'add' first and last elements in first p are 'add' -->
				<!-- <xsl:if test="*[not(local-name()='name')][1][node()[normalize-space() != ''][1][local-name() = 'add'] and node()[normalize-space() != ''][last()][local-name() = 'add']]"> -->
				<xsl:if test="*[not(local-name()='name')][1][count(node()[normalize-space() != '']) = 1 and *[local-name() = 'add']]">
					<xsl:call-template name="append_add-style"/>
				</xsl:if>
				
				<xsl:apply-templates select="*[local-name() = 'name']"/>
				
			</fo:inline>
			
			<xsl:apply-templates select="node()[not(local-name() = 'name')]"/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'note']/*[local-name() = 'name']">
		<xsl:param name="sfx"/>
		<xsl:variable name="suffix">
			<xsl:choose>
				<xsl:when test="$sfx != ''">
					<xsl:value-of select="$sfx"/>					
				</xsl:when>
				<xsl:otherwise>
					
					
					
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="normalize-space() != ''">
			<xsl:apply-templates/>
			<xsl:value-of select="$suffix"/>
		</xsl:if>
	</xsl:template><xsl:template match="*[local-name() = 'termnote']/*[local-name() = 'name']">
		<xsl:param name="sfx"/>
		<xsl:variable name="suffix">
			<xsl:choose>
				<xsl:when test="$sfx != ''">
					<xsl:value-of select="$sfx"/>					
				</xsl:when>
				<xsl:otherwise>
					
					
						<xsl:text>:</xsl:text>
					
					
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="normalize-space() != ''">
			<xsl:apply-templates/>
			<xsl:value-of select="$suffix"/>
		</xsl:if>
	</xsl:template><xsl:template match="*[local-name() = 'termnote']/*[local-name() = 'p']">
		<xsl:variable name="num"><xsl:number/></xsl:variable>
		<xsl:choose>
			<xsl:when test="$num = 1"> <!-- first paragraph renders in the same line as titlenote name -->
				<fo:inline xsl:use-attribute-sets="termnote-p-style">
					<xsl:apply-templates/>
				</fo:inline>
			</xsl:when>
			<xsl:otherwise>
				<fo:block xsl:use-attribute-sets="termnote-p-style">						
					<xsl:apply-templates/>
				</fo:block>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template match="*[local-name() = 'terms']">
		<!-- <xsl:message>'terms' <xsl:number/> processing...</xsl:message> -->
		<fo:block id="{@id}">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'term']">
		<fo:block id="{@id}" xsl:use-attribute-sets="term-style">

			
			
			
			
			<xsl:if test="parent::*[local-name() = 'term'] and not(preceding-sibling::*[local-name() = 'term'])">
				
					<xsl:attribute name="space-before">12pt</xsl:attribute>
				
			</xsl:if>
			<xsl:apply-templates select="node()[not(local-name() = 'name')]"/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'term']/*[local-name() = 'name']">
		<xsl:if test="normalize-space() != ''">
			<xsl:variable name="level">
				<xsl:call-template name="getLevelTermName"/>
			</xsl:variable>
			<fo:inline role="H{$level}">
				<xsl:apply-templates/>
			</fo:inline>
		</xsl:if>
	</xsl:template><xsl:template match="*[local-name() = 'figure']" name="figure">
		<xsl:variable name="isAdded" select="@added"/>
		<xsl:variable name="isDeleted" select="@deleted"/>
		<fo:block-container id="{@id}">			
			
			<xsl:call-template name="setTrackChangesStyles">
				<xsl:with-param name="isAdded" select="$isAdded"/>
				<xsl:with-param name="isDeleted" select="$isDeleted"/>
			</xsl:call-template>
			
			
			
			<fo:block xsl:use-attribute-sets="figure-style">
				<xsl:apply-templates select="node()[not(local-name() = 'name')]"/>
			</fo:block>
			<xsl:call-template name="fn_display_figure"/>
			<xsl:for-each select="*[local-name() = 'note']">
				<xsl:call-template name="note"/>
			</xsl:for-each>
			
			
					<xsl:apply-templates select="*[local-name() = 'name']"/> <!-- show figure's name AFTER image -->
				
			
		</fo:block-container>
	</xsl:template><xsl:template match="*[local-name() = 'figure'][@class = 'pseudocode']">
		<fo:block id="{@id}">
			<xsl:apply-templates select="node()[not(local-name() = 'name')]"/>
		</fo:block>
		<xsl:apply-templates select="*[local-name() = 'name']"/>
	</xsl:template><xsl:template match="*[local-name() = 'figure'][@class = 'pseudocode']//*[local-name() = 'p']">
		<fo:block xsl:use-attribute-sets="figure-pseudocode-p-style">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'image']">
		<xsl:variable name="isAdded" select="../@added"/>
		<xsl:variable name="isDeleted" select="../@deleted"/>
		<xsl:choose>
			<xsl:when test="ancestor::*[local-name() = 'title']">
				<fo:inline padding-left="1mm" padding-right="1mm">
					<xsl:variable name="src">
						<xsl:call-template name="image_src"/>
					</xsl:variable>
					<fo:external-graphic src="{$src}" fox:alt-text="Image {@alt}" vertical-align="middle"/>
				</fo:inline>
			</xsl:when>
			<xsl:otherwise>
				<fo:block xsl:use-attribute-sets="image-style">
					
					
					<xsl:variable name="src">
						<xsl:call-template name="image_src"/>
					</xsl:variable>
					
					<xsl:choose>
						<xsl:when test="$isDeleted = 'true'">
							<!-- enclose in svg -->
							<fo:instream-foreign-object fox:alt-text="Image {@alt}">
								<xsl:attribute name="width">100%</xsl:attribute>
								<xsl:attribute name="content-height">100%</xsl:attribute>
								<xsl:attribute name="content-width">scale-down-to-fit</xsl:attribute>
								<xsl:attribute name="scaling">uniform</xsl:attribute>
								
								
									<xsl:apply-templates select="." mode="cross_image"/>
									
							</fo:instream-foreign-object>
						</xsl:when>
						<xsl:otherwise>
							<fo:external-graphic src="{$src}" fox:alt-text="Image {@alt}" xsl:use-attribute-sets="image-graphic-style">
								<xsl:if test="not(@mimetype = 'image/svg+xml') and ../*[local-name() = 'name'] and not(ancestor::*[local-name() = 'table'])">
										
									<xsl:variable name="img_src">
										<xsl:choose>
											<xsl:when test="not(starts-with(@src, 'data:'))"><xsl:value-of select="concat($basepath, @src)"/></xsl:when>
											<xsl:otherwise><xsl:value-of select="@src"/></xsl:otherwise>
										</xsl:choose>
									</xsl:variable>
									
									<xsl:variable name="scale" select="java:org.metanorma.fop.Util.getImageScale($img_src, $width_effective, $height_effective)"/>
									<xsl:if test="number($scale) &lt; 100">
										<xsl:attribute name="content-width"><xsl:value-of select="$scale"/>%</xsl:attribute>
									</xsl:if>
								
								</xsl:if>
							
							</fo:external-graphic>
						</xsl:otherwise>
					</xsl:choose>
					
				</fo:block>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="image_src">
		<xsl:choose>
			<xsl:when test="@mimetype = 'image/svg+xml' and $images/images/image[@id = current()/@id]">
				<xsl:value-of select="$images/images/image[@id = current()/@id]/@src"/>
			</xsl:when>
			<xsl:when test="not(starts-with(@src, 'data:'))">
				<xsl:value-of select="concat('url(file:',$basepath, @src, ')')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="@src"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template match="*[local-name() = 'image']" mode="cross_image">
		<xsl:choose>
			<xsl:when test="@mimetype = 'image/svg+xml' and $images/images/image[@id = current()/@id]">
				<xsl:variable name="src">
					<xsl:value-of select="$images/images/image[@id = current()/@id]/@src"/>
				</xsl:variable>
				<xsl:variable name="width" select="document($src)/@width"/>
				<xsl:variable name="height" select="document($src)/@height"/>
				<svg xmlns="http://www.w3.org/2000/svg" xml:space="preserve" style="enable-background:new 0 0 595.28 841.89;" height="{$height}" width="{$width}" viewBox="0 0 {$width} {$height}" y="0px" x="0px" id="Layer_1" version="1.1">
					<image xlink:href="{$src}" style="overflow:visible;"/>
				</svg>
			</xsl:when>
			<xsl:when test="not(starts-with(@src, 'data:'))">
				<xsl:variable name="src">
					<xsl:value-of select="concat('url(file:',$basepath, @src, ')')"/>
				</xsl:variable>
				<xsl:variable name="file" select="java:java.io.File.new(@src)"/>
				<xsl:variable name="bufferedImage" select="java:javax.imageio.ImageIO.read($file)"/>
				<xsl:variable name="width" select="java:getWidth($bufferedImage)"/>
				<xsl:variable name="height" select="java:getHeight($bufferedImage)"/>
				<svg xmlns="http://www.w3.org/2000/svg" xml:space="preserve" style="enable-background:new 0 0 595.28 841.89;" height="{$height}" width="{$width}" viewBox="0 0 {$width} {$height}" y="0px" x="0px" id="Layer_1" version="1.1">
					<image xlink:href="{$src}" style="overflow:visible;"/>
				</svg>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="base64String" select="substring-after(@src, 'base64,')"/>
				<xsl:variable name="decoder" select="java:java.util.Base64.getDecoder()"/>
				<xsl:variable name="fileContent" select="java:decode($decoder, $base64String)"/>
				<xsl:variable name="bis" select="java:java.io.ByteArrayInputStream.new($fileContent)"/>
				<xsl:variable name="bufferedImage" select="java:javax.imageio.ImageIO.read($bis)"/>
				<xsl:variable name="width" select="java:getWidth($bufferedImage)"/>
				<xsl:variable name="height" select="java:getHeight($bufferedImage)"/>
				<svg xmlns="http://www.w3.org/2000/svg" xml:space="preserve" style="enable-background:new 0 0 595.28 841.89;" height="{$height}" width="{$width}" viewBox="0 0 {$width} {$height}" y="0px" x="0px" id="Layer_1" version="1.1">
					<image xlink:href="{@src}" height="{$height}" width="{$width}" style="overflow:visible;"/>
					<xsl:call-template name="svg_cross">
						<xsl:with-param name="width" select="$width"/>
						<xsl:with-param name="height" select="$height"/>
					</xsl:call-template>
				</svg>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template><xsl:template name="svg_cross">
		<xsl:param name="width"/>
		<xsl:param name="height"/>
		<line xmlns="http://www.w3.org/2000/svg" x1="0" y1="0" x2="{$width}" y2="{$height}" style="stroke: rgb(255, 0, 0); stroke-width:4px; "/>
		<line xmlns="http://www.w3.org/2000/svg" x1="0" y1="{$height}" x2="{$width}" y2="0" style="stroke: rgb(255, 0, 0); stroke-width:4px; "/>
	</xsl:template><xsl:variable name="figure_name_height">14</xsl:variable><xsl:variable name="width_effective" select="$pageWidth - $marginLeftRight1 - $marginLeftRight2"/><xsl:variable name="height_effective" select="$pageHeight - $marginTop - $marginBottom - $figure_name_height"/><xsl:variable name="image_dpi" select="96"/><xsl:variable name="width_effective_px" select="$width_effective div 25.4 * $image_dpi"/><xsl:variable name="height_effective_px" select="$height_effective div 25.4 * $image_dpi"/><xsl:template match="*[local-name() = 'figure'][not(*[local-name() = 'image']) and *[local-name() = 'svg']]/*[local-name() = 'name']/*[local-name() = 'bookmark']" priority="2"/><xsl:template match="*[local-name() = 'figure'][not(*[local-name() = 'image'])]/*[local-name() = 'svg']" priority="2" name="image_svg">
		<xsl:param name="name"/>
		
		<xsl:variable name="svg_content">
			<xsl:apply-templates select="." mode="svg_update"/>
		</xsl:variable>
		
		<xsl:variable name="alt-text">
			<xsl:choose>
				<xsl:when test="normalize-space(../*[local-name() = 'name']) != ''">
					<xsl:value-of select="../*[local-name() = 'name']"/>
				</xsl:when>
				<xsl:when test="normalize-space($name) != ''">
					<xsl:value-of select="$name"/>
				</xsl:when>
				<xsl:otherwise>Figure</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test=".//*[local-name() = 'a'][*[local-name() = 'rect'] or *[local-name() = 'polygon'] or *[local-name() = 'circle'] or *[local-name() = 'ellipse']]">
				<fo:block>
					<xsl:variable name="width" select="@width"/>
					<xsl:variable name="height" select="@height"/>
					
					<xsl:variable name="scale_x">
						<xsl:choose>
							<xsl:when test="$width &gt; $width_effective_px">
								<xsl:value-of select="$width_effective_px div $width"/>
							</xsl:when>
							<xsl:otherwise>1</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					
					<xsl:variable name="scale_y">
						<xsl:choose>
							<xsl:when test="$height * $scale_x &gt; $height_effective_px">
								<xsl:value-of select="$height_effective_px div ($height * $scale_x)"/>
							</xsl:when>
							<xsl:otherwise>1</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					
					<xsl:variable name="scale">
						<xsl:choose>
							<xsl:when test="$scale_y != 1">
								<xsl:value-of select="$scale_x * $scale_y"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$scale_x"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					 
					<xsl:variable name="width_scale" select="round($width * $scale)"/>
					<xsl:variable name="height_scale" select="round($height * $scale)"/>
					
					<fo:table table-layout="fixed" width="100%">
						<fo:table-column column-width="proportional-column-width(1)"/>
						<fo:table-column column-width="{$width_scale}px"/>
						<fo:table-column column-width="proportional-column-width(1)"/>
						<fo:table-body>
							<fo:table-row>
								<fo:table-cell column-number="2">
									<fo:block>
										<fo:block-container width="{$width_scale}px" height="{$height_scale}px">
											<xsl:if test="../*[local-name() = 'name']/*[local-name() = 'bookmark']">
												<fo:block line-height="0" font-size="0">
													<xsl:for-each select="../*[local-name() = 'name']/*[local-name() = 'bookmark']">
														<xsl:call-template name="bookmark"/>
													</xsl:for-each>
												</fo:block>
											</xsl:if>
											<fo:block text-depth="0" line-height="0" font-size="0">

												<fo:instream-foreign-object fox:alt-text="{$alt-text}">
													<xsl:attribute name="width">100%</xsl:attribute>
													<xsl:attribute name="content-height">100%</xsl:attribute>
													<xsl:attribute name="content-width">scale-down-to-fit</xsl:attribute>
													<xsl:attribute name="scaling">uniform</xsl:attribute>

													<xsl:apply-templates select="xalan:nodeset($svg_content)" mode="svg_remove_a"/>
												</fo:instream-foreign-object>
											</fo:block>
											
											<xsl:apply-templates select=".//*[local-name() = 'a'][*[local-name() = 'rect'] or *[local-name() = 'polygon'] or *[local-name() = 'circle'] or *[local-name() = 'ellipse']]" mode="svg_imagemap_links">
												<xsl:with-param name="scale" select="$scale"/>
											</xsl:apply-templates>
										</fo:block-container>
									</fo:block>
								</fo:table-cell>
							</fo:table-row>
						</fo:table-body>
					</fo:table>
				</fo:block>
				
			</xsl:when>
			<xsl:otherwise>
				<fo:block xsl:use-attribute-sets="image-style">
					<fo:instream-foreign-object fox:alt-text="{$alt-text}">
						<xsl:attribute name="width">100%</xsl:attribute>
						<xsl:attribute name="content-height">100%</xsl:attribute>
						<xsl:attribute name="content-width">scale-down-to-fit</xsl:attribute>
						<xsl:variable name="svg_width" select="xalan:nodeset($svg_content)/*/@width"/>
						<xsl:variable name="svg_height" select="xalan:nodeset($svg_content)/*/@height"/>
						<!-- effective height 297 - 27.4 - 13 =  256.6 -->
						<!-- effective width 210 - 12.5 - 25 = 172.5 -->
						<!-- effective height / width = 1.48, 1.4 - with title -->
						<xsl:if test="$svg_height &gt; ($svg_width * 1.4)"> <!-- for images with big height -->
							<xsl:variable name="width" select="(($svg_width * 1.4) div $svg_height) * 100"/>
							<xsl:attribute name="width"><xsl:value-of select="$width"/>%</xsl:attribute>
						</xsl:if>
						<xsl:attribute name="scaling">uniform</xsl:attribute>
						<xsl:copy-of select="$svg_content"/>
					</fo:instream-foreign-object>
				</fo:block>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template match="@*|node()" mode="svg_update">
		<xsl:copy>
				<xsl:apply-templates select="@*|node()" mode="svg_update"/>
		</xsl:copy>
	</xsl:template><xsl:template match="*[local-name() = 'image']/@href" mode="svg_update">
		<xsl:attribute name="href" namespace="http://www.w3.org/1999/xlink">
			<xsl:value-of select="."/>
		</xsl:attribute>
	</xsl:template><xsl:template match="*[local-name() = 'svg'][not(@width and @height)]" mode="svg_update">
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="svg_update"/>
			<xsl:variable name="viewbox_">
				<xsl:call-template name="split">
					<xsl:with-param name="pText" select="@viewBox"/>
					<xsl:with-param name="sep" select="' '"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="viewbox" select="xalan:nodeset($viewbox_)"/>
			<xsl:variable name="width" select="normalize-space($viewbox//item[3])"/>
			<xsl:variable name="height" select="normalize-space($viewbox//item[4])"/>
			
			<xsl:attribute name="width">
				<xsl:choose>
					<xsl:when test="$width != ''">
						<xsl:value-of select="round($width)"/>
					</xsl:when>
					<xsl:otherwise>400</xsl:otherwise> <!-- default width -->
				</xsl:choose>
			</xsl:attribute>
			<xsl:attribute name="height">
				<xsl:choose>
					<xsl:when test="$height != ''">
						<xsl:value-of select="round($height)"/>
					</xsl:when>
					<xsl:otherwise>400</xsl:otherwise> <!-- default height -->
				</xsl:choose>
			</xsl:attribute>
			
			<xsl:apply-templates mode="svg_update"/>
		</xsl:copy>
	</xsl:template><xsl:template match="*[local-name() = 'figure']/*[local-name() = 'image'][*[local-name() = 'svg']]" priority="3">
		<xsl:variable name="name" select="ancestor::*[local-name() = 'figure']/*[local-name() = 'name']"/>
		<xsl:for-each select="*[local-name() = 'svg']">
			<xsl:call-template name="image_svg">
				<xsl:with-param name="name" select="$name"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template><xsl:template match="*[local-name() = 'figure']/*[local-name() = 'image'][@mimetype = 'image/svg+xml' and @src[not(starts-with(., 'data:image/'))]]" priority="2">
		<xsl:variable name="svg_content" select="document(@src)"/>
		<xsl:variable name="name" select="ancestor::*[local-name() = 'figure']/*[local-name() = 'name']"/>
		<xsl:for-each select="xalan:nodeset($svg_content)/node()">
			<xsl:call-template name="image_svg">
				<xsl:with-param name="name" select="$name"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template><xsl:template match="@*|node()" mode="svg_remove_a">
		<xsl:copy>
				<xsl:apply-templates select="@*|node()" mode="svg_remove_a"/>
		</xsl:copy>
	</xsl:template><xsl:template match="*[local-name() = 'a']" mode="svg_remove_a">
		<xsl:apply-templates mode="svg_remove_a"/>
	</xsl:template><xsl:template match="*[local-name() = 'a']" mode="svg_imagemap_links">
		<xsl:param name="scale"/>
		<xsl:variable name="dest">
			<xsl:choose>
				<xsl:when test="starts-with(@href, '#')">
					<xsl:value-of select="substring-after(@href, '#')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="@href"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:for-each select="./*[local-name() = 'rect']">
			<xsl:call-template name="insertSVGMapLink">
				<xsl:with-param name="left" select="floor(@x * $scale)"/>
				<xsl:with-param name="top" select="floor(@y * $scale)"/>
				<xsl:with-param name="width" select="floor(@width * $scale)"/>
				<xsl:with-param name="height" select="floor(@height * $scale)"/>
				<xsl:with-param name="dest" select="$dest"/>
			</xsl:call-template>
		</xsl:for-each>
		
		<xsl:for-each select="./*[local-name() = 'polygon']">
			<xsl:variable name="points">
				<xsl:call-template name="split">
					<xsl:with-param name="pText" select="@points"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="x_coords">
				<xsl:for-each select="xalan:nodeset($points)//item[position() mod 2 = 1]">
					<xsl:sort select="." data-type="number"/>
					<x><xsl:value-of select="."/></x>
				</xsl:for-each>
			</xsl:variable>
			<xsl:variable name="y_coords">
				<xsl:for-each select="xalan:nodeset($points)//item[position() mod 2 = 0]">
					<xsl:sort select="." data-type="number"/>
					<y><xsl:value-of select="."/></y>
				</xsl:for-each>
			</xsl:variable>
			<xsl:variable name="x" select="xalan:nodeset($x_coords)//x[1]"/>
			<xsl:variable name="y" select="xalan:nodeset($y_coords)//y[1]"/>
			<xsl:variable name="width" select="xalan:nodeset($x_coords)//x[last()] - $x"/>
			<xsl:variable name="height" select="xalan:nodeset($y_coords)//y[last()] - $y"/>
			<xsl:call-template name="insertSVGMapLink">
				<xsl:with-param name="left" select="floor($x * $scale)"/>
				<xsl:with-param name="top" select="floor($y * $scale)"/>
				<xsl:with-param name="width" select="floor($width * $scale)"/>
				<xsl:with-param name="height" select="floor($height * $scale)"/>
				<xsl:with-param name="dest" select="$dest"/>
			</xsl:call-template>
		</xsl:for-each>
		
		<xsl:for-each select="./*[local-name() = 'circle']">
			<xsl:call-template name="insertSVGMapLink">
				<xsl:with-param name="left" select="floor((@cx - @r) * $scale)"/>
				<xsl:with-param name="top" select="floor((@cy - @r) * $scale)"/>
				<xsl:with-param name="width" select="floor(@r * 2 * $scale)"/>
				<xsl:with-param name="height" select="floor(@r * 2 * $scale)"/>
				<xsl:with-param name="dest" select="$dest"/>
			</xsl:call-template>
		</xsl:for-each>
		<xsl:for-each select="./*[local-name() = 'ellipse']">
			<xsl:call-template name="insertSVGMapLink">
				<xsl:with-param name="left" select="floor((@cx - @rx) * $scale)"/>
				<xsl:with-param name="top" select="floor((@cy - @ry) * $scale)"/>
				<xsl:with-param name="width" select="floor(@rx * 2 * $scale)"/>
				<xsl:with-param name="height" select="floor(@ry * 2 * $scale)"/>
				<xsl:with-param name="dest" select="$dest"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template><xsl:template name="insertSVGMapLink">
		<xsl:param name="left"/>
		<xsl:param name="top"/>
		<xsl:param name="width"/>
		<xsl:param name="height"/>
		<xsl:param name="dest"/>
		<fo:block-container position="absolute" left="{$left}px" top="{$top}px" width="{$width}px" height="{$height}px">
		 <fo:block font-size="1pt">
			<fo:basic-link internal-destination="{$dest}" fox:alt-text="svg link">
				<fo:inline-container inline-progression-dimension="100%">
					<fo:block-container height="{$height - 1}px" width="100%">
						<!-- DEBUG <xsl:if test="local-name()='polygon'">
							<xsl:attribute name="background-color">magenta</xsl:attribute>
						</xsl:if> -->
					<fo:block> </fo:block></fo:block-container>
				</fo:inline-container>
			</fo:basic-link>
		 </fo:block>
	  </fo:block-container>
	</xsl:template><xsl:template match="*[local-name() = 'emf']"/><xsl:template match="*[local-name() = 'figure']/*[local-name() = 'name'] |                *[local-name() = 'table']/*[local-name() = 'name'] |               *[local-name() = 'permission']/*[local-name() = 'name'] |               *[local-name() = 'recommendation']/*[local-name() = 'name'] |               *[local-name() = 'requirement']/*[local-name() = 'name']" mode="contents">		
		<xsl:apply-templates mode="contents"/>
		<xsl:text> </xsl:text>
	</xsl:template><xsl:template match="*[local-name() = 'figure']/*[local-name() = 'name'] |                *[local-name() = 'table']/*[local-name() = 'name'] |               *[local-name() = 'permission']/*[local-name() = 'name'] |               *[local-name() = 'recommendation']/*[local-name() = 'name'] |               *[local-name() = 'requirement']/*[local-name() = 'name'] |               *[local-name() = 'sourcecode']/*[local-name() = 'name']" mode="bookmarks">		
		<xsl:apply-templates mode="bookmarks"/>
		<xsl:text> </xsl:text>
	</xsl:template><xsl:template match="*[local-name() = 'figure' or local-name() = 'table' or local-name() = 'permission' or local-name() = 'recommendation' or local-name() = 'requirement']/*[local-name() = 'name']/text()" mode="contents" priority="2">
		<xsl:value-of select="."/>
	</xsl:template><xsl:template match="*[local-name() = 'figure' or local-name() = 'table' or local-name() = 'permission' or local-name() = 'recommendation' or local-name() = 'requirement' or local-name() = 'sourcecode']/*[local-name() = 'name']//text()" mode="bookmarks" priority="2">
		<xsl:value-of select="."/>
	</xsl:template><xsl:template match="node()" mode="contents">
		<xsl:apply-templates mode="contents"/>
	</xsl:template><xsl:template match="*[local-name() = 'preface' or local-name() = 'sections']/*[local-name() = 'p'][@type = 'section-title' and not(@displayorder)]" priority="3" mode="contents"/><xsl:template match="*[local-name() = 'p'][@type = 'section-title' and not(@displayorder)]" mode="contents_no_displayorder">
		<xsl:call-template name="contents_section-title"/>
	</xsl:template><xsl:template match="*[local-name() = 'p'][@type = 'section-title']" mode="contents_in_clause">
		<xsl:call-template name="contents_section-title"/>
	</xsl:template><xsl:template match="*[local-name() = 'clause']/*[local-name() = 'p'][@type = 'section-title' and (@depth != ../*[local-name() = 'title']/@depth or ../*[local-name() = 'title']/@depth = 1)]" priority="3" mode="contents"/><xsl:template match="*[local-name() = 'p'][@type = 'floating-title' or @type = 'section-title']" priority="2" name="contents_section-title" mode="contents">
		<xsl:variable name="level">
			<xsl:call-template name="getLevel">
				<xsl:with-param name="depth" select="@depth"/>
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:variable name="section">
			<xsl:choose>
				<xsl:when test="@type = 'section-title'"/>
				<xsl:otherwise>
					<xsl:value-of select="*[local-name() = 'tab'][1]/preceding-sibling::node()"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="type"><xsl:value-of select="@type"/></xsl:variable>
			
		<xsl:variable name="display">
			<xsl:choose>
				<xsl:when test="normalize-space(@id) = ''">false</xsl:when>
				<xsl:when test="$level &lt;= $toc_level">true</xsl:when>
				<xsl:otherwise>false</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="skip">false</xsl:variable>

		<xsl:if test="$skip = 'false'">		
		
			<xsl:variable name="title">
				<xsl:choose>
					<xsl:when test="*[local-name() = 'tab']">
						<xsl:choose>
							<xsl:when test="@type = 'section-title'">
								<xsl:value-of select="*[local-name() = 'tab'][1]/preceding-sibling::node()"/>
								<xsl:text>: </xsl:text>
								<xsl:copy-of select="*[local-name() = 'tab'][1]/following-sibling::node()"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:copy-of select="*[local-name() = 'tab'][1]/following-sibling::node()"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:copy-of select="node()"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:variable name="root">
				<xsl:if test="ancestor-or-self::*[local-name() = 'preface']">preface</xsl:if>
				<xsl:if test="ancestor-or-self::*[local-name() = 'annex']">annex</xsl:if>
			</xsl:variable>
			
			<item id="{@id}" level="{$level}" section="{$section}" type="{$type}" root="{$root}" display="{$display}">
				<title>
					<xsl:apply-templates select="xalan:nodeset($title)" mode="contents_item"/>
				</title>
			</item>
		</xsl:if>
	</xsl:template><xsl:template match="node()" mode="bookmarks">
		<xsl:apply-templates mode="bookmarks"/>
	</xsl:template><xsl:template match="*[local-name() = 'title' or local-name() = 'name']//*[local-name() = 'stem']" mode="contents">
		<xsl:apply-templates select="."/>
	</xsl:template><xsl:template match="*[local-name() = 'references'][@hidden='true']" mode="contents" priority="3"/><xsl:template match="*[local-name() = 'references']/*[local-name() = 'bibitem']" mode="contents"/><xsl:template match="*[local-name() = 'span']" mode="contents">
		<xsl:apply-templates mode="contents"/>
	</xsl:template><xsl:template match="*[local-name() = 'stem']" mode="bookmarks">
		<xsl:apply-templates mode="bookmarks"/>
	</xsl:template><xsl:template match="*[local-name() = 'span']" mode="bookmarks">
		<xsl:apply-templates mode="bookmarks"/>
	</xsl:template><xsl:template name="addBookmarks">
		<xsl:param name="contents"/>
		<xsl:variable name="contents_nodes" select="xalan:nodeset($contents)"/>
		<xsl:if test="$contents_nodes//item">
			<fo:bookmark-tree>
				<xsl:choose>
					<xsl:when test="$contents_nodes/doc">
						<xsl:choose>
							<xsl:when test="count($contents_nodes/doc) &gt; 1">
								<xsl:for-each select="$contents_nodes/doc">
									<fo:bookmark internal-destination="{contents/item[1]/@id}" starting-state="hide">
										<xsl:if test="@bundle = 'true'">
											<xsl:attribute name="internal-destination"><xsl:value-of select="@firstpage_id"/></xsl:attribute>
										</xsl:if>
										<fo:bookmark-title>
											<xsl:choose>
												<xsl:when test="not(normalize-space(@bundle) = 'true')"> <!-- 'bundle' means several different documents (not language versions) in one xml -->
													<xsl:variable name="bookmark-title_">
														<xsl:call-template name="getLangVersion">
															<xsl:with-param name="lang" select="@lang"/>
															<xsl:with-param name="doctype" select="@doctype"/>
															<xsl:with-param name="title" select="@title-part"/>
														</xsl:call-template>
													</xsl:variable>
													<xsl:choose>
														<xsl:when test="normalize-space($bookmark-title_) != ''">
															<xsl:value-of select="normalize-space($bookmark-title_)"/>
														</xsl:when>
														<xsl:otherwise>
															<xsl:choose>
																<xsl:when test="@lang = 'en'">English</xsl:when>
																<xsl:when test="@lang = 'fr'">Français</xsl:when>
																<xsl:when test="@lang = 'de'">Deutsche</xsl:when>
																<xsl:otherwise><xsl:value-of select="@lang"/> version</xsl:otherwise>
															</xsl:choose>
														</xsl:otherwise>
													</xsl:choose>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="@title-part"/>
												</xsl:otherwise>
											</xsl:choose>
										</fo:bookmark-title>
										
										<xsl:apply-templates select="contents/item" mode="bookmark"/>
										
										<xsl:call-template name="insertFigureBookmarks">
											<xsl:with-param name="contents" select="contents"/>
										</xsl:call-template>
										
										<xsl:call-template name="insertTableBookmarks">
											<xsl:with-param name="contents" select="contents"/>
											<xsl:with-param name="lang" select="@lang"/>
										</xsl:call-template>
										
									</fo:bookmark>
									
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>
								<xsl:for-each select="$contents_nodes/doc">
								
									<xsl:apply-templates select="contents/item" mode="bookmark"/>
									
									<xsl:call-template name="insertFigureBookmarks">
										<xsl:with-param name="contents" select="contents"/>
									</xsl:call-template>
										
									<xsl:call-template name="insertTableBookmarks">
										<xsl:with-param name="contents" select="contents"/>
										<xsl:with-param name="lang" select="@lang"/>
									</xsl:call-template>
									
								</xsl:for-each>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="$contents_nodes/contents/item" mode="bookmark"/>				
						
						<xsl:call-template name="insertFigureBookmarks">
							<xsl:with-param name="contents" select="$contents_nodes/contents"/>
						</xsl:call-template>
							
						<xsl:call-template name="insertTableBookmarks">
							<xsl:with-param name="contents" select="$contents_nodes/contents"/>
							<xsl:with-param name="lang" select="@lang"/>
						</xsl:call-template>
						
					</xsl:otherwise>
				</xsl:choose>
				
				 
				
				
				
				
				 
				
			</fo:bookmark-tree>
		</xsl:if>
	</xsl:template><xsl:template name="insertFigureBookmarks">
		<xsl:param name="contents"/>
		<xsl:variable name="contents_nodes" select="xalan:nodeset($contents)"/>
		<xsl:if test="$contents_nodes/figure">
			<fo:bookmark internal-destination="{$contents_nodes/figure[1]/@id}" starting-state="hide">
				<fo:bookmark-title>Figures</fo:bookmark-title>
				<xsl:for-each select="$contents_nodes/figure">
					<fo:bookmark internal-destination="{@id}">
						<fo:bookmark-title>
							<xsl:value-of select="normalize-space(title)"/>
						</fo:bookmark-title>
					</fo:bookmark>
				</xsl:for-each>
			</fo:bookmark>	
		</xsl:if>
		
		
				<xsl:if test="$contents_nodes//figures/figure">
					<fo:bookmark internal-destination="empty_bookmark" starting-state="hide">
					
						
						
						<xsl:variable name="bookmark-title">
							
									<xsl:value-of select="$title-list-figures"/>
								
						</xsl:variable>
						<fo:bookmark-title><xsl:value-of select="normalize-space($bookmark-title)"/></fo:bookmark-title>
						<xsl:for-each select="$contents_nodes//figures/figure">
							<fo:bookmark internal-destination="{@id}">
								<fo:bookmark-title><xsl:value-of select="normalize-space(.)"/></fo:bookmark-title>
							</fo:bookmark>
						</xsl:for-each>
					</fo:bookmark>
				</xsl:if>
			
	</xsl:template><xsl:template name="insertTableBookmarks">
		<xsl:param name="contents"/>
		<xsl:param name="lang"/>
		<xsl:variable name="contents_nodes" select="xalan:nodeset($contents)"/>
		<xsl:if test="$contents_nodes/table">
			<fo:bookmark internal-destination="{$contents_nodes/table[1]/@id}" starting-state="hide">
				<fo:bookmark-title>
					<xsl:choose>
						<xsl:when test="$lang = 'fr'">Tableaux</xsl:when>
						<xsl:otherwise>Tables</xsl:otherwise>
					</xsl:choose>
				</fo:bookmark-title>
				<xsl:for-each select="$contents_nodes/table">
					<fo:bookmark internal-destination="{@id}">
						<fo:bookmark-title>
							<xsl:value-of select="normalize-space(title)"/>
						</fo:bookmark-title>
					</fo:bookmark>
				</xsl:for-each>
			</fo:bookmark>	
		</xsl:if>
		
		
				<xsl:if test="$contents_nodes//tables/table">
					<fo:bookmark internal-destination="empty_bookmark" starting-state="hide">
						
						
						
						<xsl:variable name="bookmark-title">
							
									<xsl:value-of select="$title-list-tables"/>
								
						</xsl:variable>
						
						<fo:bookmark-title><xsl:value-of select="$bookmark-title"/></fo:bookmark-title>
						
						<xsl:for-each select="$contents_nodes//tables/table">
							<fo:bookmark internal-destination="{@id}">
								<fo:bookmark-title><xsl:value-of select="normalize-space(.)"/></fo:bookmark-title>
							</fo:bookmark>
						</xsl:for-each>
					</fo:bookmark>
				</xsl:if>
			
	</xsl:template><xsl:template name="getLangVersion">
		<xsl:param name="lang"/>
		<xsl:param name="doctype" select="''"/>
		<xsl:param name="title" select="''"/>
		<xsl:choose>
			<xsl:when test="$lang = 'en'">
				
				
				</xsl:when>
			<xsl:when test="$lang = 'fr'">
				
				
			</xsl:when>
			<xsl:when test="$lang = 'de'">Deutsche</xsl:when>
			<xsl:otherwise><xsl:value-of select="$lang"/> version</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template match="item" mode="bookmark">
		<xsl:choose>
			<xsl:when test="@id != ''">
				<fo:bookmark internal-destination="{@id}" starting-state="hide">
					<fo:bookmark-title>
						<xsl:if test="@section != ''">
							<xsl:value-of select="@section"/> 
							<xsl:text> </xsl:text>
						</xsl:if>
						<xsl:value-of select="normalize-space(title)"/>
					</fo:bookmark-title>
					<xsl:apply-templates mode="bookmark"/>
				</fo:bookmark>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates mode="bookmark"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template match="title" mode="bookmark"/><xsl:template match="text()" mode="bookmark"/><xsl:template match="*[local-name() = 'figure']/*[local-name() = 'name'] |         *[local-name() = 'image']/*[local-name() = 'name']">
		<xsl:if test="normalize-space() != ''">			
			<fo:block xsl:use-attribute-sets="figure-name-style">
				
				
				
				
				
				<xsl:apply-templates/>
			</fo:block>
		</xsl:if>
	</xsl:template><xsl:template match="*[local-name() = 'figure']/*[local-name() = 'fn']" priority="2"/><xsl:template match="*[local-name() = 'figure']/*[local-name() = 'note']"/><xsl:template match="*[local-name() = 'title']" mode="contents_item">
		<xsl:param name="mode">bookmarks</xsl:param>
		<xsl:apply-templates mode="contents_item">
			<xsl:with-param name="mode" select="$mode"/>
		</xsl:apply-templates>
		<!-- <xsl:text> </xsl:text> -->
	</xsl:template><xsl:template name="getSection">
		<xsl:value-of select="*[local-name() = 'title']/*[local-name() = 'tab'][1]/preceding-sibling::node()"/>
	</xsl:template><xsl:template name="getName">
		<xsl:choose>
			<xsl:when test="*[local-name() = 'title']/*[local-name() = 'tab']">
				<xsl:copy-of select="*[local-name() = 'title']/*[local-name() = 'tab'][1]/following-sibling::node()"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="*[local-name() = 'title']/node()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="insertTitleAsListItem">
		<xsl:param name="provisional-distance-between-starts" select="'9.5mm'"/>
		<xsl:variable name="section">						
			<xsl:for-each select="..">
				<xsl:call-template name="getSection"/>
			</xsl:for-each>
		</xsl:variable>							
		<fo:list-block provisional-distance-between-starts="{$provisional-distance-between-starts}">						
			<fo:list-item>
				<fo:list-item-label end-indent="label-end()">
					<fo:block>
						<xsl:value-of select="$section"/>
					</fo:block>
				</fo:list-item-label>
				<fo:list-item-body start-indent="body-start()">
					<fo:block>						
						<xsl:choose>
							<xsl:when test="*[local-name() = 'tab']">
								<xsl:apply-templates select="*[local-name() = 'tab'][1]/following-sibling::node()"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates/>
								<xsl:apply-templates select="following-sibling::*[1][local-name() = 'variant-title'][@type = 'sub']" mode="subtitle"/>
							</xsl:otherwise>
						</xsl:choose>
					</fo:block>
				</fo:list-item-body>
			</fo:list-item>
		</fo:list-block>
	</xsl:template><xsl:template name="extractSection">
		<xsl:value-of select="*[local-name() = 'tab'][1]/preceding-sibling::node()"/>
	</xsl:template><xsl:template name="extractTitle">
		<xsl:choose>
				<xsl:when test="*[local-name() = 'tab']">
					<xsl:apply-templates select="*[local-name() = 'tab'][1]/following-sibling::node()"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates/>
				</xsl:otherwise>
			</xsl:choose>
	</xsl:template><xsl:template match="*[local-name() = 'fn']" mode="contents"/><xsl:template match="*[local-name() = 'fn']" mode="bookmarks"/><xsl:template match="*[local-name() = 'fn']" mode="contents_item"/><xsl:template match="*[local-name() = 'xref'] | *[local-name() = 'eref']" mode="contents">
		<xsl:value-of select="."/>
	</xsl:template><xsl:template match="*[local-name() = 'review']" mode="contents_item"/><xsl:template match="*[local-name() = 'tab']" mode="contents_item">
		<xsl:text> </xsl:text>
	</xsl:template><xsl:template match="*[local-name() = 'strong']" mode="contents_item">
		<xsl:copy>
			<xsl:apply-templates mode="contents_item"/>
		</xsl:copy>		
	</xsl:template><xsl:template match="*[local-name() = 'em']" mode="contents_item">
		<xsl:copy>
			<xsl:apply-templates mode="contents_item"/>
		</xsl:copy>		
	</xsl:template><xsl:template match="*[local-name() = 'stem']" mode="contents_item">
		<xsl:copy-of select="."/>
	</xsl:template><xsl:template match="*[local-name() = 'br']" mode="contents_item">
		<xsl:text> </xsl:text>
	</xsl:template><xsl:template match="*[local-name() = 'name']" mode="contents_item">
		<xsl:param name="mode">bookmarks</xsl:param>
		<xsl:apply-templates mode="contents_item">
			<xsl:with-param name="mode" select="$mode"/>
		</xsl:apply-templates>
	</xsl:template><xsl:template match="*[local-name() = 'add']" mode="contents_item">
		<xsl:param name="mode">bookmarks</xsl:param>
		<xsl:choose>
			<xsl:when test="starts-with(text(), $ace_tag)">
				<xsl:if test="$mode = 'contents'">
					<xsl:copy>
						<xsl:apply-templates mode="contents_item"/>
					</xsl:copy>		
				</xsl:if>
			</xsl:when>
			<xsl:otherwise><xsl:apply-templates mode="contents_item"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template match="text()" mode="contents_item">
		<xsl:call-template name="keep_together_standard_number"/>
	</xsl:template><xsl:template match="*[local-name() = 'span']" mode="contents_item">
		<xsl:apply-templates mode="contents_item"/>
	</xsl:template><xsl:template match="*[local-name()='sourcecode']" name="sourcecode">
	
		<fo:block-container xsl:use-attribute-sets="sourcecode-container-style">
		
			<xsl:if test="not(ancestor::*[local-name() = 'li']) or ancestor::*[local-name() = 'example']">
				<xsl:attribute name="margin-left">0mm</xsl:attribute>
			</xsl:if>
			
			<xsl:if test="ancestor::*[local-name() = 'example']">
				<xsl:attribute name="margin-right">0mm</xsl:attribute>
			</xsl:if>
			
			<xsl:copy-of select="@id"/>
			
			<xsl:if test="parent::*[local-name() = 'note']">
				<xsl:attribute name="margin-left">
					<xsl:choose>
						<xsl:when test="not(ancestor::*[local-name() = 'table'])"><xsl:value-of select="$note-body-indent"/></xsl:when>
						<xsl:otherwise><xsl:value-of select="$note-body-indent-table"/></xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				
			</xsl:if>
			<fo:block-container margin-left="0mm">
		
				
				
				
				
				<fo:block xsl:use-attribute-sets="sourcecode-style">
					<xsl:variable name="_font-size">
						
												
						
						
						
						inherit<!-- 9 -->
						
						
						<!-- <xsl:if test="$namespace = 'ieee'">							
							<xsl:if test="$doctype = 'standard' and $stage = 'published'">8</xsl:if>
						</xsl:if> -->
						
								
						
						
						
												
						
								
				</xsl:variable>
				
				<xsl:variable name="font-size" select="normalize-space($_font-size)"/>		
				<xsl:if test="$font-size != ''">
					<xsl:attribute name="font-size">
						<xsl:choose>
							<xsl:when test="$font-size = 'inherit'"><xsl:value-of select="$font-size"/></xsl:when>
							<xsl:when test="contains($font-size, '%')"><xsl:value-of select="$font-size"/></xsl:when>
							<xsl:when test="ancestor::*[local-name()='note']"><xsl:value-of select="$font-size * 0.91"/>pt</xsl:when>
							<xsl:otherwise><xsl:value-of select="$font-size"/>pt</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
				</xsl:if>
				
				
				
				
				
				<xsl:apply-templates select="node()[not(local-name() = 'name')]"/>
			</fo:block>
			
			
					<xsl:apply-templates select="*[local-name()='name']"/> <!-- show sourcecode's name AFTER content -->
				
				
			
				
			</fo:block-container>
		</fo:block-container>
	</xsl:template><xsl:template match="*[local-name()='sourcecode']/text()" priority="2">
		<xsl:choose>
			<xsl:when test="normalize-space($syntax-highlight) = 'true' and normalize-space(../@lang) != ''"> <!-- condition for turn on of highlighting -->
				<xsl:variable name="syntax" select="java:org.metanorma.fop.Util.syntaxHighlight(., ../@lang)"/>
				<xsl:choose>
					<xsl:when test="normalize-space($syntax) != ''"><!-- if there is highlighted result -->
						<xsl:apply-templates select="xalan:nodeset($syntax)" mode="syntax_highlight"/> <!-- process span tags -->
					</xsl:when>
					<xsl:otherwise> <!-- if case of non-succesfull syntax highlight (for instance, unknown lang), process without highlighting -->
						<xsl:call-template name="add_spaces_to_sourcecode"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="add_spaces_to_sourcecode"/>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template><xsl:template name="add_spaces_to_sourcecode">
		<xsl:variable name="text_step1">
			<xsl:call-template name="add-zero-spaces-equal"/>
		</xsl:variable>
		<xsl:variable name="text_step2">
			<xsl:call-template name="add-zero-spaces-java">
				<xsl:with-param name="text" select="$text_step1"/>
			</xsl:call-template>
		</xsl:variable>
		
		<!-- <xsl:value-of select="$text_step2"/> -->
		
		<!-- add zero-width space after space -->
		<xsl:variable name="text_step3" select="java:replaceAll(java:java.lang.String.new($text_step2),' ',' ​')"/>
		
		<!-- split text by zero-width space -->
		<xsl:variable name="text_step4">
			<xsl:call-template name="split_for_interspers">
				<xsl:with-param name="pText" select="$text_step3"/>
				<xsl:with-param name="sep" select="$zero_width_space"/>
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:for-each select="xalan:nodeset($text_step4)/node()">
			<xsl:choose>
				<xsl:when test="local-name() = 'interspers'"> <!-- word with length more than 30 will be interspersed with zero-width space -->
					<xsl:call-template name="interspers-java">
						<xsl:with-param name="str" select="."/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
		
	</xsl:template><xsl:variable name="interspers_tag_open">###interspers123###</xsl:variable><xsl:variable name="interspers_tag_close">###/interspers123###</xsl:variable><xsl:template name="split_for_interspers">
		<xsl:param name="pText" select="."/>
		<xsl:param name="sep" select="','"/>
		<!-- word with length more than 30 will be interspersed with zero-width space -->
		<xsl:variable name="regex" select="concat('([^', $zero_width_space, ']{31,})')"/> <!-- sequence of characters (more 31), that doesn't contains zero-width space -->
		<xsl:variable name="text" select="java:replaceAll(java:java.lang.String.new($pText),$regex,concat($interspers_tag_open,'$1',$interspers_tag_close))"/>
		<xsl:call-template name="replace_tag_interspers">
			<xsl:with-param name="text" select="$text"/>
		</xsl:call-template>
	</xsl:template><xsl:template name="replace_tag_interspers">
		<xsl:param name="text"/>
		<xsl:choose>
			<xsl:when test="contains($text, $interspers_tag_open)">
				<xsl:value-of select="substring-before($text, $interspers_tag_open)"/>
				<xsl:variable name="text_after" select="substring-after($text, $interspers_tag_open)"/>
				<interspers>
					<xsl:value-of select="substring-before($text_after, $interspers_tag_close)"/>
				</interspers>
				<xsl:call-template name="replace_tag_interspers">
					<xsl:with-param name="text" select="substring-after($text_after, $interspers_tag_close)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise><xsl:value-of select="$text"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="interspers">
		<xsl:param name="str"/>
		<xsl:param name="char" select="$zero_width_space"/>
		<xsl:if test="$str != ''">
			<xsl:value-of select="substring($str, 1, 1)"/>
			
			<xsl:variable name="next_char" select="substring($str, 2, 1)"/>
			<xsl:if test="not(contains(concat(' -.:=_— ', $char), $next_char))">
				<xsl:value-of select="$char"/>
			</xsl:if>
			
			<xsl:call-template name="interspers">
				<xsl:with-param name="str" select="substring($str, 2)"/>
				<xsl:with-param name="char" select="$char"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template><xsl:template name="interspers-java">
		<xsl:param name="str"/>
		<xsl:param name="char" select="$zero_width_space"/>
		<xsl:value-of select="java:replaceAll(java:java.lang.String.new($str),'([^ -.:=_—])',concat('$1', $char))"/> <!-- insert $char after each char excep space, - . : = _ etc. -->
	</xsl:template><xsl:template match="*" mode="syntax_highlight">
		<xsl:apply-templates mode="syntax_highlight"/>
	</xsl:template><xsl:variable name="syntax_highlight_styles_">
		<style class="hljs-addition" xsl:use-attribute-sets="hljs-addition"/>
		<style class="hljs-attr" xsl:use-attribute-sets="hljs-attr"/>
		<style class="hljs-attribute" xsl:use-attribute-sets="hljs-attribute"/>
		<style class="hljs-built_in" xsl:use-attribute-sets="hljs-built_in"/>
		<style class="hljs-bullet" xsl:use-attribute-sets="hljs-bullet"/>
		<style class="hljs-char_and_escape_" xsl:use-attribute-sets="hljs-char_and_escape_"/>
		<style class="hljs-code" xsl:use-attribute-sets="hljs-code"/>
		<style class="hljs-comment" xsl:use-attribute-sets="hljs-comment"/>
		<style class="hljs-deletion" xsl:use-attribute-sets="hljs-deletion"/>
		<style class="hljs-doctag" xsl:use-attribute-sets="hljs-doctag"/>
		<style class="hljs-emphasis" xsl:use-attribute-sets="hljs-emphasis"/>
		<style class="hljs-formula" xsl:use-attribute-sets="hljs-formula"/>
		<style class="hljs-keyword" xsl:use-attribute-sets="hljs-keyword"/>
		<style class="hljs-link" xsl:use-attribute-sets="hljs-link"/>
		<style class="hljs-literal" xsl:use-attribute-sets="hljs-literal"/>
		<style class="hljs-meta" xsl:use-attribute-sets="hljs-meta"/>
		<style class="hljs-meta_hljs-string" xsl:use-attribute-sets="hljs-meta_hljs-string"/>
		<style class="hljs-meta_hljs-keyword" xsl:use-attribute-sets="hljs-meta_hljs-keyword"/>
		<style class="hljs-name" xsl:use-attribute-sets="hljs-name"/>
		<style class="hljs-number" xsl:use-attribute-sets="hljs-number"/>
		<style class="hljs-operator" xsl:use-attribute-sets="hljs-operator"/>
		<style class="hljs-params" xsl:use-attribute-sets="hljs-params"/>
		<style class="hljs-property" xsl:use-attribute-sets="hljs-property"/>
		<style class="hljs-punctuation" xsl:use-attribute-sets="hljs-punctuation"/>
		<style class="hljs-quote" xsl:use-attribute-sets="hljs-quote"/>
		<style class="hljs-regexp" xsl:use-attribute-sets="hljs-regexp"/>
		<style class="hljs-section" xsl:use-attribute-sets="hljs-section"/>
		<style class="hljs-selector-attr" xsl:use-attribute-sets="hljs-selector-attr"/>
		<style class="hljs-selector-class" xsl:use-attribute-sets="hljs-selector-class"/>
		<style class="hljs-selector-id" xsl:use-attribute-sets="hljs-selector-id"/>
		<style class="hljs-selector-pseudo" xsl:use-attribute-sets="hljs-selector-pseudo"/>
		<style class="hljs-selector-tag" xsl:use-attribute-sets="hljs-selector-tag"/>
		<style class="hljs-string" xsl:use-attribute-sets="hljs-string"/>
		<style class="hljs-strong" xsl:use-attribute-sets="hljs-strong"/>
		<style class="hljs-subst" xsl:use-attribute-sets="hljs-subst"/>
		<style class="hljs-symbol" xsl:use-attribute-sets="hljs-symbol"/>		
		<style class="hljs-tag" xsl:use-attribute-sets="hljs-tag"/>
		<!-- <style class="hljs-tag_hljs-attr" xsl:use-attribute-sets="hljs-tag_hljs-attr"></style> -->
		<!-- <style class="hljs-tag_hljs-name" xsl:use-attribute-sets="hljs-tag_hljs-name"></style> -->
		<style class="hljs-template-tag" xsl:use-attribute-sets="hljs-template-tag"/>
		<style class="hljs-template-variable" xsl:use-attribute-sets="hljs-template-variable"/>
		<style class="hljs-title" xsl:use-attribute-sets="hljs-title"/>
		<style class="hljs-title_and_class_" xsl:use-attribute-sets="hljs-title_and_class_"/>
		<style class="hljs-title_and_class__and_inherited__" xsl:use-attribute-sets="hljs-title_and_class__and_inherited__"/>
		<style class="hljs-title_and_function_" xsl:use-attribute-sets="hljs-title_and_function_"/>
		<style class="hljs-type" xsl:use-attribute-sets="hljs-type"/>
		<style class="hljs-variable" xsl:use-attribute-sets="hljs-variable"/>
		<style class="hljs-variable_and_language_" xsl:use-attribute-sets="hljs-variable_and_language_"/>
	</xsl:variable><xsl:variable name="syntax_highlight_styles" select="xalan:nodeset($syntax_highlight_styles_)"/><xsl:template match="span" mode="syntax_highlight" priority="2">
		<!-- <fo:inline color="green" font-style="italic"><xsl:apply-templates mode="syntax_highlight"/></fo:inline> -->
		<fo:inline>
			<xsl:variable name="classes_">
				<xsl:call-template name="split">
					<xsl:with-param name="pText" select="@class"/>
					<xsl:with-param name="sep" select="' '"/>
				</xsl:call-template>
				<!-- a few classes together (_and_ suffix) -->
				<xsl:if test="contains(@class, 'hljs-char') and contains(@class, 'escape_')">
					<item>hljs-char_and_escape_</item>
				</xsl:if>
				<xsl:if test="contains(@class, 'hljs-title') and contains(@class, 'class_')">
					<item>hljs-title_and_class_</item>
				</xsl:if>
				<xsl:if test="contains(@class, 'hljs-title') and contains(@class, 'class_') and contains(@class, 'inherited__')">
					<item>hljs-title_and_class__and_inherited__</item>
				</xsl:if>
				<xsl:if test="contains(@class, 'hljs-title') and contains(@class, 'function_')">
					<item>hljs-title_and_function_</item>
				</xsl:if>
				<xsl:if test="contains(@class, 'hljs-variable') and contains(@class, 'language_')">
					<item>hljs-variable_and_language_</item>
				</xsl:if>
				<!-- with parent classes (_ suffix) -->
				<xsl:if test="contains(@class, 'hljs-keyword') and contains(ancestor::*/@class, 'hljs-meta')">
					<item>hljs-meta_hljs-keyword</item>
				</xsl:if>
				<xsl:if test="contains(@class, 'hljs-string') and contains(ancestor::*/@class, 'hljs-meta')">
					<item>hljs-meta_hljs-string</item>
				</xsl:if>
			</xsl:variable>
			<xsl:variable name="classes" select="xalan:nodeset($classes_)"/>
			
			<xsl:for-each select="$classes/item">
				<xsl:variable name="class_name" select="."/>
				<xsl:for-each select="$syntax_highlight_styles/style[@class = $class_name]/@*[not(local-name() = 'class')]">
					<xsl:attribute name="{local-name()}"><xsl:value-of select="."/></xsl:attribute>
				</xsl:for-each>
			</xsl:for-each>
			
			<!-- <xsl:variable name="class_name">
				<xsl:choose>
					<xsl:when test="@class = 'hljs-attr' and ancestor::*/@class = 'hljs-tag'">hljs-tag_hljs-attr</xsl:when>
					<xsl:when test="@class = 'hljs-name' and ancestor::*/@class = 'hljs-tag'">hljs-tag_hljs-name</xsl:when>
					<xsl:when test="@class = 'hljs-string' and ancestor::*/@class = 'hljs-meta'">hljs-meta_hljs-string</xsl:when>
					<xsl:otherwise><xsl:value-of select="@class"/></xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:for-each select="$syntax_highlight_styles/style[@class = $class_name]/@*[not(local-name() = 'class')]">
				<xsl:attribute name="{local-name()}"><xsl:value-of select="."/></xsl:attribute>
			</xsl:for-each> -->
			
		<xsl:apply-templates mode="syntax_highlight"/></fo:inline>
	</xsl:template><xsl:template match="text()" mode="syntax_highlight" priority="2">
		<xsl:call-template name="add_spaces_to_sourcecode"/>
	</xsl:template><xsl:template match="*[local-name() = 'sourcecode']/*[local-name() = 'name']">
		<xsl:if test="normalize-space() != ''">		
			<fo:block xsl:use-attribute-sets="sourcecode-name-style">				
				<xsl:apply-templates/>
			</fo:block>
		</xsl:if>
	</xsl:template><xsl:template match="*[local-name() = 'permission']">
		<fo:block id="{@id}" xsl:use-attribute-sets="permission-style">			
			<xsl:apply-templates select="*[local-name()='name']"/>
			<xsl:apply-templates select="node()[not(local-name() = 'name')]"/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'permission']/*[local-name() = 'name']">
		<xsl:if test="normalize-space() != ''">
			<fo:block xsl:use-attribute-sets="permission-name-style">
				<xsl:apply-templates/>
				
			</fo:block>
		</xsl:if>
	</xsl:template><xsl:template match="*[local-name() = 'permission']/*[local-name() = 'label']">
		<fo:block xsl:use-attribute-sets="permission-label-style">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'requirement']">
		<fo:block id="{@id}" xsl:use-attribute-sets="requirement-style">			
			<xsl:apply-templates select="*[local-name()='name']"/>
			<xsl:apply-templates select="*[local-name()='label']"/>
			<xsl:apply-templates select="@obligation"/>
			<xsl:apply-templates select="*[local-name()='subject']"/>
			<xsl:apply-templates select="node()[not(local-name() = 'name') and not(local-name() = 'label') and not(local-name() = 'subject')]"/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'requirement']/*[local-name() = 'name']">
		<xsl:if test="normalize-space() != ''">
			<fo:block xsl:use-attribute-sets="requirement-name-style">
				
				<xsl:apply-templates/>
				
					<xsl:text>:</xsl:text>
				
			</fo:block>
		</xsl:if>
	</xsl:template><xsl:template match="*[local-name() = 'requirement']/*[local-name() = 'label']">
		<fo:block xsl:use-attribute-sets="requirement-label-style">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'requirement']/@obligation">
			<fo:block>
				<fo:inline padding-right="3mm">Obligation</fo:inline><xsl:value-of select="."/>
			</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'requirement']/*[local-name() = 'subject']" priority="2">
		<fo:block xsl:use-attribute-sets="subject-style">
			<xsl:text>Target Type </xsl:text><xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'recommendation']">
		<fo:block id="{@id}" xsl:use-attribute-sets="recommendation-style">			
			<xsl:apply-templates select="*[local-name()='name']"/>
			<xsl:apply-templates select="node()[not(local-name() = 'name')]"/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'recommendation']/*[local-name() = 'name']">
		<xsl:if test="normalize-space() != ''">
			<fo:block xsl:use-attribute-sets="recommendation-name-style">
				<xsl:apply-templates/>
				
			</fo:block>
		</xsl:if>
	</xsl:template><xsl:template match="*[local-name() = 'recommendation']/*[local-name() = 'label']">
		<fo:block xsl:use-attribute-sets="recommendation-label-style">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'subject']">
		<fo:block xsl:use-attribute-sets="subject-style">
			<xsl:text>Target Type </xsl:text><xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'inherit'] | *[local-name() = 'component'][@class = 'inherit']">
		<fo:block xsl:use-attribute-sets="inherit-style">
			<xsl:text>Dependency </xsl:text><xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'description'] | *[local-name() = 'component'][@class = 'description']">
		<fo:block xsl:use-attribute-sets="description-style">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'specification'] | *[local-name() = 'component'][@class = 'specification']">
		<fo:block xsl:use-attribute-sets="specification-style">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'measurement-target'] | *[local-name() = 'component'][@class = 'measurement-target']">
		<fo:block xsl:use-attribute-sets="measurement-target-style">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'verification'] | *[local-name() = 'component'][@class = 'verification']">
		<fo:block xsl:use-attribute-sets="verification-style">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'import'] | *[local-name() = 'component'][@class = 'import']">
		<fo:block xsl:use-attribute-sets="import-style">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'table'][@class = 'recommendation' or @class='requirement' or @class='permission']">
		<fo:block-container margin-left="0mm" margin-right="0mm" margin-bottom="12pt">
			<xsl:if test="ancestor::*[local-name() = 'table'][@class = 'recommendation' or @class='requirement' or @class='permission']">
				<xsl:attribute name="margin-bottom">0pt</xsl:attribute>
			</xsl:if>
			<fo:block-container margin-left="0mm" margin-right="0mm">
				<fo:table id="{@id}" table-layout="fixed" width="100%"> <!-- border="1pt solid black" -->
					<xsl:if test="ancestor::*[local-name() = 'table'][@class = 'recommendation' or @class='requirement' or @class='permission']">
						<!-- <xsl:attribute name="border">0.5pt solid black</xsl:attribute> -->
					</xsl:if>
					<xsl:variable name="simple-table">	
						<xsl:call-template name="getSimpleTable">
							<xsl:with-param name="id" select="@id"/>
						</xsl:call-template>
					</xsl:variable>					
					<xsl:variable name="cols-count" select="count(xalan:nodeset($simple-table)//tr[1]/td)"/>
					<xsl:if test="$cols-count = 2 and not(ancestor::*[local-name()='table'])">
						<fo:table-column column-width="30%"/>
						<fo:table-column column-width="70%"/>
					</xsl:if>
					<xsl:apply-templates mode="requirement"/>
				</fo:table>
				<!-- fn processing -->
				<xsl:if test=".//*[local-name() = 'fn']">
					<xsl:for-each select="*[local-name() = 'tbody']">
						<fo:block font-size="90%" border-bottom="1pt solid black">
							<xsl:call-template name="table_fn_display"/>
						</fo:block>
					</xsl:for-each>
				</xsl:if>
			</fo:block-container>
		</fo:block-container>
	</xsl:template><xsl:template match="*[local-name()='thead']" mode="requirement">		
		<fo:table-header>			
			<xsl:apply-templates mode="requirement"/>
		</fo:table-header>
	</xsl:template><xsl:template match="*[local-name()='tbody']" mode="requirement">		
		<fo:table-body>
			<xsl:apply-templates mode="requirement"/>
		</fo:table-body>
	</xsl:template><xsl:template match="*[local-name()='tr']" mode="requirement">
		<fo:table-row height="7mm" border-bottom="0.5pt solid grey">			
			<xsl:if test="parent::*[local-name()='thead']"> <!-- and not(ancestor::*[local-name() = 'table'][@class = 'recommendation' or @class='requirement' or @class='permission']) -->
				<xsl:attribute name="background-color">rgb(33, 55, 92)</xsl:attribute>
			</xsl:if>
			<xsl:if test="starts-with(*[local-name()='td'][1], 'Requirement ')">
				<xsl:attribute name="background-color">rgb(252, 246, 222)</xsl:attribute>
			</xsl:if>
			<xsl:if test="starts-with(*[local-name()='td'][1], 'Recommendation ')">
				<xsl:attribute name="background-color">rgb(233, 235, 239)</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates mode="requirement"/>
		</fo:table-row>
	</xsl:template><xsl:template match="*[local-name()='th']" mode="requirement">
		<fo:table-cell text-align="{@align}" display-align="center" padding="1mm" padding-left="2mm"> <!-- border="0.5pt solid black" -->
			<xsl:call-template name="setTextAlignment">
				<xsl:with-param name="default">left</xsl:with-param>
			</xsl:call-template>
			
			<xsl:call-template name="setTableCellAttributes"/>
			
			<fo:block>
				<xsl:apply-templates/>
			</fo:block>
		</fo:table-cell>
	</xsl:template><xsl:template match="*[local-name()='td']" mode="requirement">
		<fo:table-cell text-align="{@align}" display-align="center" padding="1mm" padding-left="2mm"> <!-- border="0.5pt solid black" -->
			<xsl:if test="*[local-name() = 'table'][@class = 'recommendation' or @class='requirement' or @class='permission']">
				<xsl:attribute name="padding">0mm</xsl:attribute>
				<xsl:attribute name="padding-left">0mm</xsl:attribute>
			</xsl:if>
			<xsl:call-template name="setTextAlignment">
				<xsl:with-param name="default">left</xsl:with-param>
			</xsl:call-template>
			
			<xsl:if test="following-sibling::*[local-name()='td'] and not(preceding-sibling::*[local-name()='td'])">
				<xsl:attribute name="font-weight">bold</xsl:attribute>
			</xsl:if>
			
			<xsl:call-template name="setTableCellAttributes"/>
			
			<fo:block>			
				<xsl:apply-templates/>
			</fo:block>			
		</fo:table-cell>
	</xsl:template><xsl:template match="*[local-name() = 'p'][@class='RecommendationTitle' or @class = 'RecommendationTestTitle']" priority="2">
		<fo:block font-size="11pt">
			
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'p2'][ancestor::*[local-name() = 'table'][@class = 'recommendation' or @class='requirement' or @class='permission']]">
		<fo:block>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'termexample']">
		<fo:block id="{@id}" xsl:use-attribute-sets="termexample-style">			
			<xsl:apply-templates select="*[local-name()='name']"/>
			<xsl:apply-templates select="node()[not(local-name() = 'name')]"/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'termexample']/*[local-name() = 'name']">
		<xsl:if test="normalize-space() != ''">
			<fo:inline xsl:use-attribute-sets="termexample-name-style">
				<xsl:apply-templates/>
			</fo:inline>
		</xsl:if>
	</xsl:template><xsl:template match="*[local-name() = 'termexample']/*[local-name() = 'p']">
		<xsl:variable name="element">inline
			
			
		</xsl:variable>		
		<xsl:choose>			
			<xsl:when test="contains($element, 'block')">
				<fo:block xsl:use-attribute-sets="example-p-style">
				
					
						
					<xsl:apply-templates/>
				</fo:block>
			</xsl:when>
			<xsl:otherwise>
				<fo:inline><xsl:apply-templates/></fo:inline>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template match="*[local-name() = 'example']">
		
		<fo:block-container id="{@id}" xsl:use-attribute-sets="example-style">
		
			
		
			<xsl:variable name="fo_element">
				<xsl:if test=".//*[local-name() = 'table'] or .//*[local-name() = 'dl'] or *[not(local-name() = 'name')][1][local-name() = 'sourcecode']">block</xsl:if> 
				inline
			</xsl:variable>
			
			<fo:block-container margin-left="0mm">
			
				<xsl:choose>
					
					<xsl:when test="contains(normalize-space($fo_element), 'block')">
					
						<!-- display name 'EXAMPLE' in a separate block  -->
						<fo:block>
							<xsl:apply-templates select="*[local-name()='name']">
								<xsl:with-param name="fo_element" select="$fo_element"/>
							</xsl:apply-templates>
						</fo:block>
						
						<fo:block-container xsl:use-attribute-sets="example-body-style">
							<fo:block-container margin-left="0mm" margin-right="0mm"> 
								<xsl:apply-templates select="node()[not(local-name() = 'name')]">
									<xsl:with-param name="fo_element" select="$fo_element"/>
								</xsl:apply-templates>
							</fo:block-container>
						</fo:block-container>
					</xsl:when> <!-- end block -->
					
					<xsl:otherwise> <!-- inline -->
					
						<!-- display 'EXAMPLE' and first element in the same line -->
						<fo:block>
							<xsl:apply-templates select="*[local-name()='name']">
								<xsl:with-param name="fo_element" select="$fo_element"/>
							</xsl:apply-templates>
							<fo:inline>
								<xsl:apply-templates select="*[not(local-name() = 'name')][1]">
									<xsl:with-param name="fo_element" select="$fo_element"/>
								</xsl:apply-templates>
							</fo:inline>
						</fo:block> 
						
						<xsl:if test="*[not(local-name() = 'name')][position() &gt; 1]">
							<!-- display further elements in blocks -->
							<fo:block-container xsl:use-attribute-sets="example-body-style">
								<fo:block-container margin-left="0mm" margin-right="0mm">
									<xsl:apply-templates select="*[not(local-name() = 'name')][position() &gt; 1]">
										<xsl:with-param name="fo_element" select="'block'"/>
									</xsl:apply-templates>
								</fo:block-container>
							</fo:block-container>
						</xsl:if>
					</xsl:otherwise> <!-- end inline -->
					
				</xsl:choose>
			</fo:block-container>
		</fo:block-container>
	</xsl:template><xsl:template match="*[local-name() = 'example']/*[local-name() = 'name']">
		<xsl:param name="fo_element">block</xsl:param>
	
		<xsl:choose>
			<xsl:when test="ancestor::*[local-name() = 'appendix']">
				<fo:inline>
					<xsl:apply-templates/>
				</fo:inline>
			</xsl:when>
			<xsl:when test="contains(normalize-space($fo_element), 'block')">
				<fo:block xsl:use-attribute-sets="example-name-style">
					<xsl:apply-templates/>
				</fo:block>
			</xsl:when>
			<xsl:otherwise>
				<fo:inline xsl:use-attribute-sets="example-name-style">
					<xsl:apply-templates/>
				</fo:inline>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template><xsl:template match="*[local-name() = 'example']/*[local-name() = 'p']">
		<xsl:param name="fo_element">block</xsl:param>
		
		<xsl:variable name="num"><xsl:number/></xsl:variable>
		<xsl:variable name="element">
			
				<xsl:choose>
					<xsl:when test="$num = 1 and not(contains($fo_element, 'block'))">inline</xsl:when>
					<xsl:otherwise>block</xsl:otherwise>
				</xsl:choose>
			
			<xsl:value-of select="$fo_element"/>
		</xsl:variable>		
		<xsl:choose>			
			<xsl:when test="starts-with(normalize-space($element), 'block')">
				<fo:block-container>
					<xsl:if test="ancestor::*[local-name() = 'li'] and contains(normalize-space($fo_element), 'block')">
						<xsl:attribute name="margin-left">0mm</xsl:attribute>
						<xsl:attribute name="margin-right">0mm</xsl:attribute>
					</xsl:if>
					<fo:block xsl:use-attribute-sets="example-p-style">
						
						
						<xsl:apply-templates/>
					</fo:block>
				</fo:block-container>
			</xsl:when>
			<xsl:otherwise>
				<fo:inline xsl:use-attribute-sets="example-p-style">
					<xsl:apply-templates/>					
				</fo:inline>
			</xsl:otherwise>
		</xsl:choose>	
	</xsl:template><xsl:template match="*[local-name() = 'termsource']" name="termsource">
		<fo:block xsl:use-attribute-sets="termsource-style">
			
			
			
			<!-- Example: [SOURCE: ISO 5127:2017, 3.1.6.02] -->			
			<xsl:variable name="termsource_text">
				<xsl:apply-templates/>
			</xsl:variable>
			<xsl:copy-of select="$termsource_text"/>
			<!-- <xsl:choose>
				<xsl:when test="starts-with(normalize-space($termsource_text), '[')">
					<xsl:copy-of select="$termsource_text"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="$namespace = 'bsi'">
						<xsl:choose>
							<xsl:when test="$document_type = 'PAS' and starts-with(*[local-name() = 'origin']/@citeas, '[')"><xsl:text>{</xsl:text></xsl:when>
							<xsl:otherwise><xsl:text>[</xsl:text></xsl:otherwise>
						</xsl:choose>
					</xsl:if>
					<xsl:if test="$namespace = 'gb' or $namespace = 'iso' or $namespace = 'iec' or $namespace = 'itu' or $namespace = 'unece' or $namespace = 'unece-rec' or $namespace = 'nist-cswp'  or $namespace = 'nist-sp' or $namespace = 'ogc-white-paper' or $namespace = 'csa' or $namespace = 'csd' or $namespace = 'm3d' or $namespace = 'iho' or $namespace = 'bipm' or $namespace = 'jcgm'">
						<xsl:text>[</xsl:text>
					</xsl:if>
					<xsl:copy-of select="$termsource_text"/>
					<xsl:if test="$namespace = 'bsi'">
						<xsl:choose>
							<xsl:when test="$document_type = 'PAS' and starts-with(*[local-name() = 'origin']/@citeas, '[')"><xsl:text>}</xsl:text></xsl:when>
							<xsl:otherwise><xsl:text>]</xsl:text></xsl:otherwise>
						</xsl:choose>
					</xsl:if>
					<xsl:if test="$namespace = 'gb' or $namespace = 'iso' or $namespace = 'iec' or $namespace = 'itu' or $namespace = 'unece' or $namespace = 'unece-rec' or $namespace = 'nist-cswp'  or $namespace = 'nist-sp' or $namespace = 'ogc-white-paper' or $namespace = 'csa' or $namespace = 'csd' or $namespace = 'm3d' or $namespace = 'iho' or $namespace = 'bipm' or $namespace = 'jcgm'">
						<xsl:text>]</xsl:text>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose> -->
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'termsource']/text()[starts-with(., '[SOURCE: Adapted from: ') or     starts-with(., '[SOURCE: Quoted from: ') or     starts-with(., '[SOURCE: Modified from: ')]" priority="2">
		<xsl:text>[</xsl:text><xsl:value-of select="substring-after(., '[SOURCE: ')"/>
	</xsl:template><xsl:template match="*[local-name() = 'termsource']/text()">
		<xsl:if test="normalize-space() != ''">
			<xsl:value-of select="."/>
		</xsl:if>
	</xsl:template><xsl:template match="*[local-name() = 'termsource']/*[local-name() = 'strong'][1][following-sibling::*[1][local-name() = 'origin']]/text()">
		<fo:inline xsl:use-attribute-sets="termsource-text-style">
			<xsl:value-of select="."/>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name() = 'origin']">
		<fo:basic-link internal-destination="{@bibitemid}" fox:alt-text="{@citeas}">
			<xsl:if test="normalize-space(@citeas) = ''">
				<xsl:attribute name="fox:alt-text"><xsl:value-of select="@bibitemid"/></xsl:attribute>
			</xsl:if>
			<fo:inline xsl:use-attribute-sets="origin-style">
				<xsl:apply-templates/>
			</fo:inline>
		</fo:basic-link>
	</xsl:template><xsl:template match="*[local-name() = 'modification']">
		<xsl:variable name="title-modified">
			<xsl:call-template name="getLocalizedString">
				<xsl:with-param name="key">modified</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		
    <xsl:variable name="text"><xsl:apply-templates/></xsl:variable>
		<xsl:choose>
			<xsl:when test="$lang = 'zh'"><xsl:text>、</xsl:text><xsl:value-of select="$title-modified"/><xsl:if test="normalize-space($text) != ''"><xsl:text>—</xsl:text></xsl:if></xsl:when>
			<xsl:otherwise><xsl:text>, </xsl:text><xsl:value-of select="$title-modified"/><xsl:if test="normalize-space($text) != ''"><xsl:text> — </xsl:text></xsl:if></xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates/>
	</xsl:template><xsl:template match="*[local-name() = 'modification']/*[local-name() = 'p']">
		<fo:inline><xsl:apply-templates/></fo:inline>
	</xsl:template><xsl:template match="*[local-name() = 'modification']/text()">
		<xsl:if test="normalize-space() != ''">
			<!-- <xsl:value-of select="."/> -->
			<xsl:call-template name="text"/>
		</xsl:if>
	</xsl:template><xsl:template match="*[local-name() = 'quote']">		
		<fo:block-container margin-left="0mm">
			<xsl:if test="parent::*[local-name() = 'note']">
				<xsl:if test="not(ancestor::*[local-name() = 'table'])">
					<xsl:attribute name="margin-left">5mm</xsl:attribute>
				</xsl:if>
			</xsl:if>
			
			
			<fo:block-container margin-left="0mm">
				<fo:block-container xsl:use-attribute-sets="quote-style">
					
					<fo:block-container margin-left="0mm" margin-right="0mm">
						<fo:block role="BlockQuote">
							<xsl:apply-templates select="./node()[not(local-name() = 'author') and not(local-name() = 'source')]"/> <!-- process all nested nodes, except author and source -->
						</fo:block>
					</fo:block-container>
				</fo:block-container>
				<xsl:if test="*[local-name() = 'author'] or *[local-name() = 'source']">
					<fo:block xsl:use-attribute-sets="quote-source-style">
						<!-- — ISO, ISO 7301:2011, Clause 1 -->
						<xsl:apply-templates select="*[local-name() = 'author']"/>
						<xsl:apply-templates select="*[local-name() = 'source']"/>				
					</fo:block>
				</xsl:if>
				
			</fo:block-container>
		</fo:block-container>
	</xsl:template><xsl:template match="*[local-name() = 'source']">
		<xsl:if test="../*[local-name() = 'author']">
			<xsl:text>, </xsl:text>
		</xsl:if>
		<fo:basic-link internal-destination="{@bibitemid}" fox:alt-text="{@citeas}">
			<xsl:apply-templates/>
		</fo:basic-link>
	</xsl:template><xsl:template match="*[local-name() = 'author']">
		<xsl:text>— </xsl:text>
		<xsl:apply-templates/>
	</xsl:template><xsl:variable name="bibitems_">
		<xsl:for-each select="//*[local-name() = 'bibitem']">
			<xsl:copy-of select="."/>
		</xsl:for-each>
	</xsl:variable><xsl:variable name="bibitems" select="xalan:nodeset($bibitems_)"/><xsl:variable name="bibitems_hidden_">
		<xsl:for-each select="//*[local-name() = 'bibitem'][@hidden='true']">
			<xsl:copy-of select="."/>
		</xsl:for-each>
		<xsl:for-each select="//*[local-name() = 'references'][@hidden='true']//*[local-name() = 'bibitem']">
			<xsl:copy-of select="."/>
		</xsl:for-each>
	</xsl:variable><xsl:variable name="bibitems_hidden" select="xalan:nodeset($bibitems_hidden_)"/><xsl:template match="*[local-name() = 'eref']">
		<xsl:variable name="current_bibitemid" select="@bibitemid"/>
		<!-- <xsl:variable name="external-destination" select="normalize-space(key('bibitems', $current_bibitemid)/*[local-name() = 'uri'][@type = 'citation'])"/> -->
		<xsl:variable name="external-destination" select="normalize-space($bibitems/*[local-name() ='bibitem'][@id = $current_bibitemid]/*[local-name() = 'uri'][@type = 'citation'])"/>
		<xsl:choose>
			<!-- <xsl:when test="$external-destination != '' or not(key('bibitems_hidden', $current_bibitemid))"> --> <!-- if in the bibliography there is the item with @bibitemid (and not hidden), then create link (internal to the bibitem or external) -->
			<xsl:when test="$external-destination != '' or not($bibitems_hidden/*[local-name() ='bibitem'][@id = $current_bibitemid])"> <!-- if in the bibliography there is the item with @bibitemid (and not hidden), then create link (internal to the bibitem or external) -->
				<fo:inline xsl:use-attribute-sets="eref-style">
					<xsl:if test="@type = 'footnote'">
						<xsl:attribute name="keep-together.within-line">always</xsl:attribute>
						<xsl:attribute name="keep-with-previous.within-line">always</xsl:attribute>
						<xsl:attribute name="vertical-align">super</xsl:attribute>
						<xsl:attribute name="font-size">80%</xsl:attribute>
						
					</xsl:if>	
					
					<xsl:variable name="citeas" select="java:replaceAll(java:java.lang.String.new(@citeas),'^\[?(.+?)\]?$','$1')"/> <!-- remove leading and trailing brackets -->
					<xsl:variable name="text" select="normalize-space()"/>
					
					
					
					
					
					<fo:basic-link fox:alt-text="{@citeas}">
						<xsl:if test="normalize-space(@citeas) = ''">
							<xsl:attribute name="fox:alt-text"><xsl:value-of select="."/></xsl:attribute>
						</xsl:if>
						<xsl:if test="@type = 'inline'">
							
							
							
						</xsl:if>
						
						<xsl:choose>
							<xsl:when test="$external-destination != ''"> <!-- external hyperlink -->
								<xsl:attribute name="external-destination"><xsl:value-of select="$external-destination"/></xsl:attribute>
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="internal-destination"><xsl:value-of select="@bibitemid"/></xsl:attribute>
							</xsl:otherwise>
						</xsl:choose>
						
						<xsl:apply-templates/>
					</fo:basic-link>
					
				</fo:inline>
			</xsl:when>
			<xsl:otherwise> <!-- if there is key('bibitems_hidden', $current_bibitemid) -->
			
				<!-- if in bibitem[@hidden='true'] there is url[@type='src'], then create hyperlink  -->
				<xsl:variable name="uri_src" select="normalize-space($bibitems_hidden/*[local-name() ='bibitem'][@id = $current_bibitemid]/*[local-name() = 'uri'][@type = 'src'])"/>
				<xsl:choose>
					<xsl:when test="$uri_src != ''">
						<fo:basic-link external-destination="{$uri_src}" fox:alt-text="{$uri_src}"><xsl:apply-templates/></fo:basic-link>
					</xsl:when>
					<xsl:otherwise><fo:inline><xsl:apply-templates/></fo:inline></xsl:otherwise>
				</xsl:choose>
				
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template match="*[local-name() = 'tab']">
		<!-- zero-space char -->
		<xsl:variable name="depth">
			<xsl:call-template name="getLevel">
				<xsl:with-param name="depth" select="../@depth"/>
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:variable name="padding">
			
			
			
			
			
			
			
			
				<xsl:choose>
					<xsl:when test="$depth = 2">3</xsl:when>
					<xsl:otherwise>4</xsl:otherwise>
				</xsl:choose>
			
			
			
			
			
			
			
			
			
			
			
			
			
		</xsl:variable>
		
		<xsl:variable name="padding-right">
			<xsl:choose>
				<xsl:when test="normalize-space($padding) = ''">0</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="normalize-space($padding)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="$lang = 'zh'">
				<fo:inline><xsl:value-of select="$tab_zh"/></fo:inline>
			</xsl:when>
			<xsl:when test="../../@inline-header = 'true'">
				<fo:inline font-size="90%">
					<xsl:call-template name="insertNonBreakSpaces">
						<xsl:with-param name="count" select="$padding-right"/>
					</xsl:call-template>
				</fo:inline>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="direction"><xsl:if test="$lang = 'ar'"><xsl:value-of select="$RLM"/></xsl:if></xsl:variable>
				<fo:inline padding-right="{$padding-right}mm"><xsl:value-of select="$direction"/>​</fo:inline>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template><xsl:template name="insertNonBreakSpaces">
		<xsl:param name="count"/>
		<xsl:if test="$count &gt; 0">
			<xsl:text> </xsl:text>
			<xsl:call-template name="insertNonBreakSpaces">
				<xsl:with-param name="count" select="$count - 1"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template><xsl:template match="*[local-name() = 'preferred']">
		<xsl:variable name="level">
			<xsl:call-template name="getLevel"/>
		</xsl:variable>
		<xsl:variable name="font-size">
			inherit
		</xsl:variable>
		<xsl:variable name="levelTerm">
			<xsl:call-template name="getLevelTermName"/>
		</xsl:variable>
		<fo:block font-size="{normalize-space($font-size)}" role="H{$levelTerm}" xsl:use-attribute-sets="preferred-block-style">
		
			
			
			<xsl:if test="parent::*[local-name() = 'term'] and not(preceding-sibling::*[local-name() = 'preferred'])"> <!-- if first preffered in term, then display term's name -->
				<fo:block xsl:use-attribute-sets="term-name-style">
					<xsl:apply-templates select="ancestor::*[local-name() = 'term'][1]/*[local-name() = 'name']"/>
				</fo:block>
			</xsl:if>
			
			<fo:block xsl:use-attribute-sets="preferred-term-style">
				<xsl:call-template name="setStyle_preferred"/>
				<xsl:apply-templates/>
			</fo:block>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'domain']">
		<fo:inline xsl:use-attribute-sets="domain-style">&lt;<xsl:apply-templates/>&gt;</fo:inline>
		<xsl:text> </xsl:text>
	</xsl:template><xsl:template match="*[local-name() = 'admitted']">
		<fo:block xsl:use-attribute-sets="admitted-style">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'deprecates']">
		<xsl:variable name="title-deprecated">
			<xsl:call-template name="getLocalizedString">
				<xsl:with-param name="key">deprecated</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<fo:block xsl:use-attribute-sets="deprecates-style">
			<xsl:value-of select="$title-deprecated"/>: <xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template name="setStyle_preferred">
		<xsl:if test="*[local-name() = 'strong']">
			<xsl:attribute name="font-weight">normal</xsl:attribute>
		</xsl:if>
	</xsl:template><xsl:template match="*[local-name() = 'preferred']/text()[contains(., ';')] | *[local-name() = 'preferred']/*[local-name() = 'strong']/text()[contains(., ';')]">
		<xsl:value-of select="java:replaceAll(java:java.lang.String.new(.), ';', $linebreak)"/>
	</xsl:template><xsl:template match="*[local-name() = 'definition']">
		<fo:block xsl:use-attribute-sets="definition-style">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'definition'][preceding-sibling::*[local-name() = 'domain']]">
		<xsl:apply-templates/>
	</xsl:template><xsl:template match="*[local-name() = 'definition'][preceding-sibling::*[local-name() = 'domain']]/*[local-name() = 'p'][1]">
		<fo:inline> <xsl:apply-templates/></fo:inline>
		<fo:block/>
	</xsl:template><xsl:template match="/*/*[local-name() = 'sections']/*" priority="2">
		
		<fo:block>
			<xsl:call-template name="setId"/>
			
			
			
			
				<xsl:variable name="pos"><xsl:number count="*"/></xsl:variable>
				<xsl:if test="$pos &gt;= 2">
					<xsl:attribute name="space-before">18pt</xsl:attribute>
				</xsl:if>
			
			
						
			
						
			
			
			<xsl:apply-templates/>
		</fo:block>
		
		
		
	</xsl:template><xsl:template match="//*[contains(local-name(), '-standard')]/*[local-name() = 'preface']/*" priority="2"> <!-- /*/*[local-name() = 'preface']/* -->
		<fo:block break-after="page"/>
		<fo:block>
			<xsl:call-template name="setId"/>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'clause']">
		<fo:block>
			<xsl:call-template name="setId"/>
			
			
			
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'definitions']">
		<fo:block id="{@id}">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'annex']">
		<fo:block break-after="page"/>
		<fo:block id="{@id}">
			
		</fo:block>
		<xsl:apply-templates/>
	</xsl:template><xsl:template match="*[local-name() = 'review']"> <!-- 'review' will be processed in mn2pdf/review.xsl -->
		<!-- comment 2019-11-29 -->
		<!-- <fo:block font-weight="bold">Review:</fo:block>
		<xsl:apply-templates /> -->
		
		<xsl:variable name="id_from" select="normalize-space(current()/@from)"/>

		<xsl:choose>
			<!-- if there isn't the attribute '@from', then -->
			<xsl:when test="$id_from = ''">
				<fo:block id="{@id}" font-size="1pt"><xsl:value-of select="$hair_space"/></fo:block>
			</xsl:when>
			<!-- if there isn't element with id 'from', then create 'bookmark' here -->
			<xsl:when test="not(ancestor::*[contains(local-name(), '-standard')]//*[@id = $id_from])">
				<fo:block id="{@from}" font-size="1pt"><xsl:value-of select="$hair_space"/></fo:block>
			</xsl:when>
		</xsl:choose>
		
	</xsl:template><xsl:template match="*[local-name() = 'name']/text()">
		<!-- 0xA0 to space replacement -->
		<xsl:value-of select="java:replaceAll(java:java.lang.String.new(.),' ',' ')"/>
	</xsl:template><xsl:variable name="ul_labels_">
		
				<label>—</label> <!-- em dash -->
			
	</xsl:variable><xsl:variable name="ul_labels" select="xalan:nodeset($ul_labels_)"/><xsl:template name="setULLabel">
		<xsl:variable name="list_level_" select="count(ancestor::*[local-name() = 'ul']) + count(ancestor::*[local-name() = 'ol'])"/>
		<xsl:variable name="list_level">
			<xsl:choose>
				<xsl:when test="$list_level_ &lt;= 3"><xsl:value-of select="$list_level_"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="$list_level_ mod 3"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$ul_labels/label[not(@level)]"> <!-- one label for all levels -->
				<xsl:apply-templates select="$ul_labels/label[not(@level)]" mode="ul_labels"/>
			</xsl:when>
			<xsl:when test="$list_level mod 3 = 0">
				<xsl:apply-templates select="$ul_labels/label[@level = 3]" mode="ul_labels"/>
			</xsl:when>
			<xsl:when test="$list_level mod 2 = 0">
				<xsl:apply-templates select="$ul_labels/label[@level = 2]" mode="ul_labels"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="$ul_labels/label[@level = 1]" mode="ul_labels"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template match="label" mode="ul_labels">
		<xsl:copy-of select="@*[not(local-name() = 'level')]"/>
		<xsl:value-of select="."/>
	</xsl:template><xsl:template name="getListItemFormat">
		<!-- Example: for BSI <?list-type loweralpha?> -->
		<xsl:variable name="processing_instruction_type" select="normalize-space(../preceding-sibling::*[1]/processing-instruction('list-type'))"/>
		<xsl:choose>
			<xsl:when test="local-name(..) = 'ul'">
				<xsl:choose>
					<xsl:when test="normalize-space($processing_instruction_type) = 'simple'"/>
					<xsl:otherwise><xsl:call-template name="setULLabel"/></xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise> <!-- for ordered lists 'ol' -->
			
				<!-- Example: for BSI <?list-start 2?> -->
				<xsl:variable name="processing_instruction_start" select="normalize-space(../preceding-sibling::*[1]/processing-instruction('list-start'))"/>

				<xsl:variable name="start_value">
					<xsl:choose>
						<xsl:when test="normalize-space($processing_instruction_start) != ''">
							<xsl:value-of select="number($processing_instruction_start) - 1"/><!-- if start="3" then start_value=2 + xsl:number(1) = 3 -->
						</xsl:when>
						<xsl:when test="normalize-space(../@start) != ''">
							<xsl:value-of select="number(../@start) - 1"/><!-- if start="3" then start_value=2 + xsl:number(1) = 3 -->
						</xsl:when>
						<xsl:otherwise>0</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				
				<xsl:variable name="curr_value"><xsl:number/></xsl:variable>
				
				<xsl:variable name="type">
					<xsl:choose>
						<xsl:when test="normalize-space($processing_instruction_type) != ''"><xsl:value-of select="$processing_instruction_type"/></xsl:when>
						<xsl:when test="normalize-space(../@type) != ''"><xsl:value-of select="../@type"/></xsl:when>
						
						<xsl:otherwise> <!-- if no @type or @class = 'steps' -->
							
							<xsl:variable name="list_level_" select="count(ancestor::*[local-name() = 'ul']) + count(ancestor::*[local-name() = 'ol'])"/>
							<xsl:variable name="list_level">
								<xsl:choose>
									<xsl:when test="$list_level_ &lt;= 5"><xsl:value-of select="$list_level_"/></xsl:when>
									<xsl:otherwise><xsl:value-of select="$list_level_ mod 5"/></xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							
							<xsl:choose>
								<xsl:when test="$list_level mod 5 = 0">roman_upper</xsl:when> <!-- level 5 -->
								<xsl:when test="$list_level mod 4 = 0">alphabet_upper</xsl:when> <!-- level 4 -->
								<xsl:when test="$list_level mod 3 = 0">roman</xsl:when> <!-- level 3 -->
								<xsl:when test="$list_level mod 2 = 0 and ancestor::*/@class = 'steps'">alphabet</xsl:when> <!-- level 2 and @class = 'steps'-->
								<xsl:when test="$list_level mod 2 = 0">arabic</xsl:when> <!-- level 2 -->
								<xsl:otherwise> <!-- level 1 -->
									<xsl:choose>
										<xsl:when test="ancestor::*/@class = 'steps'">arabic</xsl:when>
										<xsl:otherwise>alphabet</xsl:otherwise>
									</xsl:choose>
								</xsl:otherwise>
							</xsl:choose>
							
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				
				<xsl:variable name="format">
					<xsl:choose>
						<xsl:when test="$type = 'arabic'">
							1)
						</xsl:when>
						<xsl:when test="$type = 'alphabet'">
							a)
						</xsl:when>
						<xsl:when test="$type = 'alphabet_upper'">
							A.
						</xsl:when>
						<xsl:when test="$type = 'roman'">
							i)
						</xsl:when>
						<xsl:when test="$type = 'roman_upper'">I.</xsl:when>
						<xsl:otherwise>1.</xsl:otherwise> <!-- for any case, if $type has non-determined value, not using -->
					</xsl:choose>
				</xsl:variable>
				
				<xsl:number value="$start_value + $curr_value" format="{normalize-space($format)}" lang="en"/>
				
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template match="*[local-name() = 'ul'] | *[local-name() = 'ol']">
		<xsl:choose>
			<xsl:when test="parent::*[local-name() = 'note'] or parent::*[local-name() = 'termnote']">
				<fo:block-container>
					<xsl:attribute name="margin-left">
						<xsl:choose>
							<xsl:when test="not(ancestor::*[local-name() = 'table'])"><xsl:value-of select="$note-body-indent"/></xsl:when>
							<xsl:otherwise><xsl:value-of select="$note-body-indent-table"/></xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
					
					
					
					<fo:block-container margin-left="0mm">
						<fo:block>
							<xsl:apply-templates select="." mode="list"/>
						</fo:block>
					</fo:block-container>
				</fo:block-container>
			</xsl:when>
			<xsl:otherwise>
				<fo:block>
					<xsl:apply-templates select="." mode="list"/>
				</fo:block>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template match="*[local-name()='ul'] | *[local-name()='ol']" mode="list" name="list">
	
		<xsl:apply-templates select="*[local-name() = 'name']">
			<xsl:with-param name="process">true</xsl:with-param>
		</xsl:apply-templates>
	
		<fo:list-block xsl:use-attribute-sets="list-style">
		
			
			
			
			
			

			
			
			<xsl:if test="*[local-name() = 'name']">
				<xsl:attribute name="margin-top">0pt</xsl:attribute>
			</xsl:if>
			
			<xsl:apply-templates select="node()[not(local-name() = 'note')]"/>
		</fo:list-block>
		<!-- <xsl:for-each select="./iho:note">
			<xsl:call-template name="note"/>
		</xsl:for-each> -->
		<xsl:apply-templates select="./*[local-name() = 'note']"/>
	</xsl:template><xsl:template match="*[local-name() = 'ol' or local-name() = 'ul']/*[local-name() = 'name']">
		<xsl:param name="process">false</xsl:param>
		<xsl:if test="$process = 'true'">
			<fo:block xsl:use-attribute-sets="list-name-style">
				<xsl:apply-templates/>
			</fo:block>
		</xsl:if>
	</xsl:template><xsl:template match="*[local-name()='li']">
		<fo:list-item xsl:use-attribute-sets="list-item-style">
			<xsl:copy-of select="@id"/>
			
			
			
			<fo:list-item-label end-indent="label-end()">
				<fo:block xsl:use-attribute-sets="list-item-label-style">
				
					
				
					
				
					<!-- if 'p' contains all text in 'add' first and last elements in first p are 'add' -->
					<xsl:if test="*[1][count(node()[normalize-space() != '']) = 1 and *[local-name() = 'add']]">
						<xsl:call-template name="append_add-style"/>
					</xsl:if>
					
					<xsl:call-template name="getListItemFormat"/>
				</fo:block>
			</fo:list-item-label>
			<fo:list-item-body start-indent="body-start()" xsl:use-attribute-sets="list-item-body-style">
				<fo:block>
				
					
				
					
				
					<xsl:apply-templates/>
				
					<!-- <xsl:apply-templates select="node()[not(local-name() = 'note')]" />
					
					<xsl:for-each select="./bsi:note">
						<xsl:call-template name="note"/>
					</xsl:for-each> -->
				</fo:block>
			</fo:list-item-body>
		</fo:list-item>
	</xsl:template><xsl:variable name="index" select="document($external_index)"/><xsl:variable name="bookmark_in_fn">
		<xsl:for-each select="//*[local-name() = 'bookmark'][ancestor::*[local-name() = 'fn']]">
			<bookmark><xsl:value-of select="@id"/></bookmark>
		</xsl:for-each>
	</xsl:variable><xsl:template match="@*|node()" mode="index_add_id">
		<xsl:copy>
				<xsl:apply-templates select="@*|node()" mode="index_add_id"/>
		</xsl:copy>
	</xsl:template><xsl:template match="*[local-name() = 'xref']" mode="index_add_id">
		<xsl:variable name="id">
			<xsl:call-template name="generateIndexXrefId"/>
		</xsl:variable>
		<xsl:copy> <!-- add id to xref -->
			<xsl:apply-templates select="@*" mode="index_add_id"/>
			<xsl:attribute name="id">
				<xsl:value-of select="$id"/>
			</xsl:attribute>
			<xsl:apply-templates mode="index_add_id"/>
		</xsl:copy>
		<!-- split <xref target="bm1" to="End" pagenumber="true"> to two xref:
		<xref target="bm1" pagenumber="true"> and <xref target="End" pagenumber="true"> -->
		<xsl:if test="@to">
			<xsl:value-of select="$en_dash"/>
			<xsl:copy>
				<xsl:copy-of select="@*"/>
				<xsl:attribute name="target"><xsl:value-of select="@to"/></xsl:attribute>
				<xsl:attribute name="id">
					<xsl:value-of select="$id"/><xsl:text>_to</xsl:text>
				</xsl:attribute>
				<xsl:apply-templates mode="index_add_id"/>
			</xsl:copy>
		</xsl:if>
	</xsl:template><xsl:template match="@*|node()" mode="index_update">
		<xsl:copy>
				<xsl:apply-templates select="@*|node()" mode="index_update"/>
		</xsl:copy>
	</xsl:template><xsl:template match="*[local-name() = 'indexsect']//*[local-name() = 'li']" mode="index_update">
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="index_update"/>
		<xsl:apply-templates select="node()[1]" mode="process_li_element"/>
		</xsl:copy>
	</xsl:template><xsl:template match="*[local-name() = 'indexsect']//*[local-name() = 'li']/node()" mode="process_li_element" priority="2">
		<xsl:param name="element"/>
		<xsl:param name="remove" select="'false'"/>
		<xsl:param name="target"/>
		<!-- <node></node> -->
		<xsl:choose>
			<xsl:when test="self::text()  and (normalize-space(.) = ',' or normalize-space(.) = $en_dash) and $remove = 'true'">
				<!-- skip text (i.e. remove it) and process next element -->
				<!-- [removed_<xsl:value-of select="."/>] -->
				<xsl:apply-templates select="following-sibling::node()[1]" mode="process_li_element">
					<xsl:with-param name="target"><xsl:value-of select="$target"/></xsl:with-param>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="self::text()">
				<xsl:value-of select="."/>
				<xsl:apply-templates select="following-sibling::node()[1]" mode="process_li_element"/>
			</xsl:when>
			<xsl:when test="self::* and local-name(.) = 'xref'">
				<xsl:variable name="id" select="@id"/>
				<xsl:variable name="page" select="$index//item[@id = $id]"/>
				<xsl:variable name="id_next" select="following-sibling::*[local-name() = 'xref'][1]/@id"/>
				<xsl:variable name="page_next" select="$index//item[@id = $id_next]"/>
				
				<xsl:variable name="id_prev" select="preceding-sibling::*[local-name() = 'xref'][1]/@id"/>
				<xsl:variable name="page_prev" select="$index//item[@id = $id_prev]"/>
				
				<xsl:choose>
					<!-- 2nd pass -->
					<!-- if page is equal to page for next and page is not the end of range -->
					<xsl:when test="$page != '' and $page_next != '' and $page = $page_next and not(contains($page, '_to'))">  <!-- case: 12, 12-14 -->
						<!-- skip element (i.e. remove it) and remove next text ',' -->
						<!-- [removed_xref] -->
						
						<xsl:apply-templates select="following-sibling::node()[1]" mode="process_li_element">
							<xsl:with-param name="remove">true</xsl:with-param>
							<xsl:with-param name="target">
								<xsl:choose>
									<xsl:when test="$target != ''"><xsl:value-of select="$target"/></xsl:when>
									<xsl:otherwise><xsl:value-of select="@target"/></xsl:otherwise>
								</xsl:choose>
							</xsl:with-param>
						</xsl:apply-templates>
					</xsl:when>
					
					<xsl:when test="$page != '' and $page_prev != '' and $page = $page_prev and contains($page_prev, '_to')"> <!-- case: 12-14, 14, ... -->
						<!-- remove xref -->
						<xsl:apply-templates select="following-sibling::node()[1]" mode="process_li_element">
							<xsl:with-param name="remove">true</xsl:with-param>
						</xsl:apply-templates>
					</xsl:when>

					<xsl:otherwise>
						<xsl:apply-templates select="." mode="xref_copy">
							<xsl:with-param name="target" select="$target"/>
						</xsl:apply-templates>
						<xsl:apply-templates select="following-sibling::node()[1]" mode="process_li_element"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="self::* and local-name(.) = 'ul'">
				<!-- ul -->
				<xsl:apply-templates select="." mode="index_update"/>
			</xsl:when>
			<xsl:otherwise>
			 <xsl:apply-templates select="." mode="xref_copy">
					<xsl:with-param name="target" select="$target"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="following-sibling::node()[1]" mode="process_li_element"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template match="@*|node()" mode="xref_copy">
		<xsl:param name="target"/>
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="xref_copy"/>
			<xsl:if test="$target != '' and not(xalan:nodeset($bookmark_in_fn)//bookmark[. = $target])">
				<xsl:attribute name="target"><xsl:value-of select="$target"/></xsl:attribute>
			</xsl:if>
			<xsl:apply-templates select="node()" mode="xref_copy"/>
		</xsl:copy>
	</xsl:template><xsl:template name="generateIndexXrefId">
		<xsl:variable name="level" select="count(ancestor::*[local-name() = 'ul'])"/>
		
		<xsl:variable name="docid">
			<xsl:call-template name="getDocumentId"/>
		</xsl:variable>
		<xsl:variable name="item_number">
			<xsl:number count="*[local-name() = 'li'][ancestor::*[local-name() = 'indexsect']]" level="any"/>
		</xsl:variable>
		<xsl:variable name="xref_number"><xsl:number count="*[local-name() = 'xref']"/></xsl:variable>
		<xsl:value-of select="concat($docid, '_', $item_number, '_', $xref_number)"/> <!-- $level, '_',  -->
	</xsl:template><xsl:template match="*[local-name() = 'indexsect']/*[local-name() = 'title']" priority="4">
		<fo:block xsl:use-attribute-sets="indexsect-title-style">
			<!-- Index -->
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'indexsect']/*[local-name() = 'clause']/*[local-name() = 'title']" priority="4">
		<!-- Letter A, B, C, ... -->
		<fo:block xsl:use-attribute-sets="indexsect-clause-title-style">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'indexsect']/*[local-name() = 'clause']" priority="4">
		<xsl:apply-templates/>
		<fo:block>
			<xsl:if test="following-sibling::*[local-name() = 'clause']">
				<fo:block> </fo:block>
			</xsl:if>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'indexsect']//*[local-name() = 'ul']" priority="4">
		<xsl:apply-templates/>
	</xsl:template><xsl:template match="*[local-name() = 'indexsect']//*[local-name() = 'li']" priority="4">
		<xsl:variable name="level" select="count(ancestor::*[local-name() = 'ul'])"/>
		<fo:block start-indent="{5 * $level}mm" text-indent="-5mm">
			
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'indexsect']//*[local-name() = 'li']/text()">
		<!-- to split by '_' and other chars -->
		<xsl:call-template name="add-zero-spaces-java"/>
	</xsl:template><xsl:template match="*[local-name() = 'table']/*[local-name() = 'bookmark']" priority="2"/><xsl:template match="*[local-name() = 'bookmark']" name="bookmark">
		<!-- <fo:inline id="{@id}" font-size="1pt"/> -->
		<fo:inline id="{@id}" font-size="1pt"><xsl:value-of select="$hair_space"/></fo:inline>
		<!-- we need to add zero-width space, otherwise this fo:inline is missing in IF xml -->
		<xsl:if test="not(following-sibling::node()[normalize-space() != ''])"><fo:inline font-size="1pt"> </fo:inline></xsl:if>
	</xsl:template><xsl:template match="*[local-name() = 'errata']">
		<!-- <row>
					<date>05-07-2013</date>
					<type>Editorial</type>
					<change>Changed CA-9 Priority Code from P1 to P2 in <xref target="tabled2"/>.</change>
					<pages>D-3</pages>
				</row>
		-->
		<fo:table table-layout="fixed" width="100%" font-size="10pt" border="1pt solid black">
			<fo:table-column column-width="20mm"/>
			<fo:table-column column-width="23mm"/>
			<fo:table-column column-width="107mm"/>
			<fo:table-column column-width="15mm"/>
			<fo:table-body>
				<fo:table-row text-align="center" font-weight="bold" background-color="black" color="white">
					
					<fo:table-cell border="1pt solid black"><fo:block>Date</fo:block></fo:table-cell>
					<fo:table-cell border="1pt solid black"><fo:block>Type</fo:block></fo:table-cell>
					<fo:table-cell border="1pt solid black"><fo:block>Change</fo:block></fo:table-cell>
					<fo:table-cell border="1pt solid black"><fo:block>Pages</fo:block></fo:table-cell>
				</fo:table-row>
				<xsl:apply-templates/>
			</fo:table-body>
		</fo:table>
	</xsl:template><xsl:template match="*[local-name() = 'errata']/*[local-name() = 'row']">
		<fo:table-row>
			<xsl:apply-templates/>
		</fo:table-row>
	</xsl:template><xsl:template match="*[local-name() = 'errata']/*[local-name() = 'row']/*">
		<fo:table-cell border="1pt solid black" padding-left="1mm" padding-top="0.5mm">
			<fo:block><xsl:apply-templates/></fo:block>
		</fo:table-cell>
	</xsl:template><xsl:template match="*[local-name() = 'references'][@hidden='true']" priority="3"/><xsl:template match="*[local-name() = 'bibitem'][@hidden='true']" priority="3"/><xsl:template match="*[local-name() = 'bibitem'][starts-with(@id, 'hidden_bibitem_')]" priority="3"/><xsl:template match="*[local-name() = 'references'][@normative='true']" priority="2">
		
		
		
		<fo:block id="{@id}">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'references']">
		<xsl:if test="not(ancestor::*[local-name() = 'annex'])">
			
					<fo:block break-after="page"/>
				
		</xsl:if>
		
		<!-- <xsl:if test="ancestor::*[local-name() = 'annex']">
			<xsl:if test="$namespace = 'csa' or $namespace = 'csd' or $namespace = 'gb' or $namespace = 'iec' or $namespace = 'iso' or $namespace = 'itu'">
				<fo:block break-after="page"/>
			</xsl:if>
		</xsl:if> -->
		
		<fo:block id="{@id}" xsl:use-attribute-sets="references-non-normative-style">
			<xsl:apply-templates/>
		</fo:block>
		
		
		
		
	</xsl:template><xsl:template match="*[local-name() = 'bibitem']">
		<xsl:call-template name="bibitem"/>
	</xsl:template><xsl:template match="*[local-name() = 'references'][@normative='true']/*[local-name() = 'bibitem']" name="bibitem" priority="2">
		
				<fo:block id="{@id}" xsl:use-attribute-sets="bibitem-normative-style">
					<xsl:call-template name="processBibitem"/>
				</fo:block>
			

	</xsl:template><xsl:template match="*[local-name() = 'references'][not(@normative='true')]/*[local-name() = 'bibitem']" name="bibitem_non_normative" priority="2">
		
		 <!-- $namespace = 'csd' or $namespace = 'gb' or $namespace = 'iec' or $namespace = 'ieee' or $namespace = 'iso' or $namespace = 'jcgm' or $namespace = 'm3d' or 
			$namespace = 'mpfd' or $namespace = 'ogc' or $namespace = 'ogc-white-paper' -->
				<!-- Example: [1] ISO 9:1995, Information and documentation – Transliteration of Cyrillic characters into Latin characters – Slavic and non-Slavic languages -->	
				<fo:list-block id="{@id}" xsl:use-attribute-sets="bibitem-non-normative-list-style">
					<fo:list-item>
						<fo:list-item-label end-indent="label-end()">
							<fo:block>
								<fo:inline>
									
											<xsl:value-of select="*[local-name()='docidentifier'][@type = 'metanorma-ordinal']"/>
											<xsl:if test="not(*[local-name()='docidentifier'][@type = 'metanorma-ordinal'])">
												<xsl:number format="[1]" count="*[local-name()='bibitem'][not(@hidden = 'true')]"/>
											</xsl:if>
										
								</fo:inline>
							</fo:block>
						</fo:list-item-label>
						<fo:list-item-body start-indent="body-start()">
							<fo:block xsl:use-attribute-sets="bibitem-non-normative-list-body-style">
								<xsl:call-template name="processBibitem"/>
							</fo:block>
						</fo:list-item-body>
					</fo:list-item>
				</fo:list-block>
			
		
	</xsl:template><xsl:template name="processBibitem">
		
		
				<!-- start bibitem processing -->
				<xsl:if test=".//*[local-name() = 'fn']">
					<xsl:attribute name="line-height-shift-adjustment">disregard-shifts</xsl:attribute>
				</xsl:if>
				
				<!-- display document identifier, not number [1] -->
				<xsl:variable name="docidentifier">
					<xsl:choose>
						<xsl:when test="*[local-name() = 'docidentifier']/@type = 'metanorma'"/>
						<xsl:otherwise><xsl:value-of select="*[local-name() = 'docidentifier'][not(@type = 'metanorma-ordinal')]"/></xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:value-of select="$docidentifier"/>
				
				<xsl:apply-templates select="*[local-name() = 'note']"/>
				
				<xsl:if test="normalize-space($docidentifier) != '' and *[local-name() = 'formattedref']">
					<xsl:text>,</xsl:text>
					<xsl:text> </xsl:text>
				</xsl:if>
				
				<xsl:apply-templates select="*[local-name() = 'formattedref']"/>
				<!-- end bibitem processing -->
			
	</xsl:template><xsl:template name="processBibitemDocId">
		<xsl:variable name="_doc_ident" select="*[local-name() = 'docidentifier'][not(@type = 'DOI' or @type = 'metanorma' or @type = 'metanorma-ordinal' or @type = 'ISSN' or @type = 'ISBN' or @type = 'rfc-anchor')]"/>
		<xsl:choose>
			<xsl:when test="normalize-space($_doc_ident) != ''">
				<!-- <xsl:variable name="type" select="*[local-name() = 'docidentifier'][not(@type = 'DOI' or @type = 'metanorma' or @type = 'ISSN' or @type = 'ISBN' or @type = 'rfc-anchor')]/@type"/>
				<xsl:if test="$type != '' and not(contains($_doc_ident, $type))">
					<xsl:value-of select="$type"/><xsl:text> </xsl:text>
				</xsl:if> -->
				<xsl:value-of select="$_doc_ident"/>
			</xsl:when>
			<xsl:otherwise>
				<!-- <xsl:variable name="type" select="*[local-name() = 'docidentifier'][not(@type = 'metanorma')]/@type"/>
				<xsl:if test="$type != ''">
					<xsl:value-of select="$type"/><xsl:text> </xsl:text>
				</xsl:if> -->
				<xsl:value-of select="*[local-name() = 'docidentifier'][not(@type = 'metanorma') and not(@type = 'metanorma-ordinal')]"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="processPersonalAuthor">
		<xsl:choose>
			<xsl:when test="*[local-name() = 'name']/*[local-name() = 'completename']">
				<author>
					<xsl:apply-templates select="*[local-name() = 'name']/*[local-name() = 'completename']"/>
				</author>
			</xsl:when>
			<xsl:when test="*[local-name() = 'name']/*[local-name() = 'surname'] and *[local-name() = 'name']/*[local-name() = 'initial']">
				<author>
					<xsl:apply-templates select="*[local-name() = 'name']/*[local-name() = 'surname']"/>
					<xsl:text> </xsl:text>
					<xsl:apply-templates select="*[local-name() = 'name']/*[local-name() = 'initial']" mode="strip"/>
				</author>
			</xsl:when>
			<xsl:when test="*[local-name() = 'name']/*[local-name() = 'surname'] and *[local-name() = 'name']/*[local-name() = 'forename']">
				<author>
					<xsl:apply-templates select="*[local-name() = 'name']/*[local-name() = 'surname']"/>
					<xsl:text> </xsl:text>
					<xsl:apply-templates select="*[local-name() = 'name']/*[local-name() = 'forename']" mode="strip"/>
				</author>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="renderDate">		
			<xsl:if test="normalize-space(*[local-name() = 'on']) != ''">
				<xsl:value-of select="*[local-name() = 'on']"/>
			</xsl:if>
			<xsl:if test="normalize-space(*[local-name() = 'from']) != ''">
				<xsl:value-of select="concat(*[local-name() = 'from'], '–', *[local-name() = 'to'])"/>
			</xsl:if>
	</xsl:template><xsl:template match="*[local-name() = 'name']/*[local-name() = 'initial']/text()" mode="strip">
		<xsl:value-of select="translate(.,'. ','')"/>
	</xsl:template><xsl:template match="*[local-name() = 'name']/*[local-name() = 'forename']/text()" mode="strip">
		<xsl:value-of select="substring(.,1,1)"/>
	</xsl:template><xsl:template match="*[local-name() = 'title']" mode="title">
		<fo:inline><xsl:apply-templates/></fo:inline>
	</xsl:template><xsl:template match="*[local-name() = 'bibitem']/*[local-name() = 'title']" priority="2">
		<!-- <fo:inline><xsl:apply-templates /></fo:inline> -->
		<fo:inline font-style="italic"> <!-- BIPM BSI CSD CSA GB IEC IHO ISO ITU JCGM -->
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name() = 'bibitem']/*[local-name() = 'note']" priority="2">
	
		<!-- list of footnotes to calculate actual footnotes number -->
		<xsl:variable name="p_fn_">
			<xsl:call-template name="get_fn_list"/>
		</xsl:variable>
		<xsl:variable name="p_fn" select="xalan:nodeset($p_fn_)"/>
		<xsl:variable name="gen_id" select="generate-id(.)"/>
		<xsl:variable name="lang" select="ancestor::*[contains(local-name(), '-standard')]/*[local-name()='bibdata']//*[local-name()='language'][@current = 'true']"/>
		<!-- fn sequence number in document -->
		<xsl:variable name="current_fn_number">
			<xsl:choose>
				<xsl:when test="@current_fn_number"><xsl:value-of select="@current_fn_number"/></xsl:when> <!-- for BSI -->
				<xsl:otherwise>
					<!-- <xsl:value-of select="count($p_fn//fn[@reference = $reference]/preceding-sibling::fn) + 1" /> -->
					<xsl:value-of select="count($p_fn//fn[@gen_id = $gen_id]/preceding-sibling::fn) + 1"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<fo:footnote>
			<xsl:variable name="number">
				
						<xsl:value-of select="$current_fn_number"/>
					
			</xsl:variable>
			
			<xsl:variable name="current_fn_number_text">
				<xsl:value-of select="$number"/>
				
						<xsl:text>)</xsl:text>
					
			</xsl:variable>
			
			<fo:inline xsl:use-attribute-sets="bibitem-note-fn-style">
				<fo:basic-link internal-destination="{$gen_id}" fox:alt-text="footnote {$number}">
					<xsl:value-of select="$current_fn_number_text"/>
				</fo:basic-link>
			</fo:inline>
			<fo:footnote-body>
				<fo:block xsl:use-attribute-sets="bibitem-note-fn-body-style">
					<fo:inline id="{$gen_id}" xsl:use-attribute-sets="bibitem-note-fn-number-style">
						<xsl:value-of select="$current_fn_number_text"/>
					</fo:inline>
					<xsl:apply-templates/>
				</fo:block>
			</fo:footnote-body>
		</fo:footnote>
	</xsl:template><xsl:template match="*[local-name() = 'bibitem']/*[local-name() = 'edition']"> <!-- for iho -->
		<xsl:text> edition </xsl:text>
		<xsl:value-of select="."/>
	</xsl:template><xsl:template match="*[local-name() = 'bibitem']/*[local-name() = 'uri']"> <!-- for iho -->
		<xsl:text> (</xsl:text>
		<fo:inline xsl:use-attribute-sets="link-style">
			<fo:basic-link external-destination="." fox:alt-text=".">
				<xsl:value-of select="."/>							
			</fo:basic-link>
		</fo:inline>
		<xsl:text>)</xsl:text>
	</xsl:template><xsl:template match="*[local-name() = 'bibitem']/*[local-name() = 'docidentifier']"/><xsl:template match="*[local-name() = 'formattedref']">
		
		<xsl:apply-templates/>
	</xsl:template><xsl:template match="*[local-name() = 'form']">
		<fo:block>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'form']//*[local-name() = 'label']">
		<fo:inline><xsl:apply-templates/></fo:inline>
	</xsl:template><xsl:template match="*[local-name() = 'form']//*[local-name() = 'input'][@type = 'text' or @type = 'date' or @type = 'file' or @type = 'password']">
		<fo:inline>
			<xsl:call-template name="text_input"/>
		</fo:inline>
	</xsl:template><xsl:template name="text_input">
		<xsl:variable name="count">
			<xsl:choose>
				<xsl:when test="normalize-space(@maxlength) != ''"><xsl:value-of select="@maxlength"/></xsl:when>
				<xsl:when test="normalize-space(@size) != ''"><xsl:value-of select="@size"/></xsl:when>
				<xsl:otherwise>10</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:call-template name="repeat">
			<xsl:with-param name="char" select="'_'"/>
			<xsl:with-param name="count" select="$count"/>
		</xsl:call-template>
		<xsl:text> </xsl:text>
	</xsl:template><xsl:template match="*[local-name() = 'form']//*[local-name() = 'input'][@type = 'button']">
		<xsl:variable name="caption">
			<xsl:choose>
				<xsl:when test="normalize-space(@value) != ''"><xsl:value-of select="@value"/></xsl:when>
				<xsl:otherwise>BUTTON</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<fo:inline>[<xsl:value-of select="$caption"/>]</fo:inline>
	</xsl:template><xsl:template match="*[local-name() = 'form']//*[local-name() = 'input'][@type = 'checkbox']">
		<fo:inline padding-right="1mm">
			<fo:instream-foreign-object fox:alt-text="Box" baseline-shift="-10%">
				<xsl:attribute name="height">3.5mm</xsl:attribute>
				<xsl:attribute name="content-width">100%</xsl:attribute>
				<xsl:attribute name="content-width">scale-down-to-fit</xsl:attribute>
				<xsl:attribute name="scaling">uniform</xsl:attribute>
				<svg xmlns="http://www.w3.org/2000/svg" width="80" height="80">
					<polyline points="0,0 80,0 80,80 0,80 0,0" stroke="black" stroke-width="5" fill="white"/>
				</svg>
			</fo:instream-foreign-object>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name() = 'form']//*[local-name() = 'input'][@type = 'radio']">
		<fo:inline padding-right="1mm">
			<fo:instream-foreign-object fox:alt-text="Box" baseline-shift="-10%">
				<xsl:attribute name="height">3.5mm</xsl:attribute>
				<xsl:attribute name="content-width">100%</xsl:attribute>
				<xsl:attribute name="content-width">scale-down-to-fit</xsl:attribute>
				<xsl:attribute name="scaling">uniform</xsl:attribute>
				<svg xmlns="http://www.w3.org/2000/svg" width="80" height="80">
					<circle cx="40" cy="40" r="30" stroke="black" stroke-width="5" fill="white"/>
					<circle cx="40" cy="40" r="15" stroke="black" stroke-width="5" fill="white"/>
				</svg>
			</fo:instream-foreign-object>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name() = 'form']//*[local-name() = 'select']">
		<fo:inline>
			<xsl:call-template name="text_input"/>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name() = 'form']//*[local-name() = 'textarea']">
		<fo:block-container border="1pt solid black" width="50%">
			<fo:block> </fo:block>
		</fo:block-container>
	</xsl:template><xsl:variable name="toc_level">
		<!-- https://www.metanorma.org/author/ref/document-attributes/ -->
		<xsl:variable name="htmltoclevels" select="normalize-space(//*[local-name() = 'misc-container']/*[local-name() = 'presentation-metadata'][*[local-name() = 'name']/text() = 'HTML TOC Heading Levels']/*[local-name() = 'value'])"/> <!-- :htmltoclevels  Number of table of contents levels to render in HTML/PDF output; used to override :toclevels:-->
		<xsl:variable name="toclevels" select="normalize-space(//*[local-name() = 'misc-container']/*[local-name() = 'presentation-metadata'][*[local-name() = 'name']/text() = 'TOC Heading Levels']/*[local-name() = 'value'])"/> <!-- Number of table of contents levels to render -->
		<xsl:choose>
			<xsl:when test="$htmltoclevels != ''"><xsl:value-of select="number($htmltoclevels)"/></xsl:when> <!-- if there is value in xml -->
			<xsl:when test="$toclevels != ''"><xsl:value-of select="number($toclevels)"/></xsl:when>  <!-- if there is value in xml -->
			<xsl:otherwise><!-- default value -->
				3
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable><xsl:template match="*[local-name() = 'toc']">
		<xsl:param name="colwidths"/>
		<xsl:variable name="colwidths_">
			<xsl:choose>
				<xsl:when test="not($colwidths)">
					<xsl:variable name="toc_table_simple">
						<tbody>
							<xsl:apply-templates mode="toc_table_width"/>
						</tbody>
					</xsl:variable>
					<xsl:variable name="cols-count" select="count(xalan:nodeset($toc_table_simple)/*/tr[1]/td)"/>
					<xsl:call-template name="calculate-column-widths">
						<xsl:with-param name="cols-count" select="$cols-count"/>
						<xsl:with-param name="table" select="$toc_table_simple"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="$colwidths"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<fo:block role="TOCI" space-after="16pt">
			<fo:table width="100%" table-layout="fixed">
				<xsl:for-each select="xalan:nodeset($colwidths_)/column">
					<fo:table-column column-width="proportional-column-width({.})"/>
				</xsl:for-each>
				<fo:table-body>
					<xsl:apply-templates/>
				</fo:table-body>
			</fo:table>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name() = 'toc']//*[local-name() = 'li']" priority="2">
		<fo:table-row min-height="5mm">
			<xsl:apply-templates/>
		</fo:table-row>
	</xsl:template><xsl:template match="*[local-name() = 'toc']//*[local-name() = 'li']/*[local-name() = 'p']">
		<xsl:apply-templates/>
	</xsl:template><xsl:template match="*[local-name() = 'toc']//*[local-name() = 'xref']" priority="3">
		<!-- <xref target="cgpm9th1948r6">1.6.3<tab/>&#8220;9th CGPM, 1948:<tab/>decision to establish the SI&#8221;</xref> -->
		<xsl:variable name="target" select="@target"/>
		<xsl:for-each select="*[local-name() = 'tab']">
			<xsl:variable name="current_id" select="generate-id()"/>
			<fo:table-cell>
				<fo:block>
					<fo:basic-link internal-destination="{$target}" fox:alt-text="{.}">
						<xsl:for-each select="following-sibling::node()[not(self::*[local-name() = 'tab']) and preceding-sibling::*[local-name() = 'tab'][1][generate-id() = $current_id]]">
							<xsl:choose>
								<xsl:when test="self::text()"><xsl:value-of select="."/></xsl:when>
								<xsl:otherwise><xsl:apply-templates select="."/></xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</fo:basic-link>
				</fo:block>
			</fo:table-cell>
		</xsl:for-each>
		<!-- last column - for page numbers -->
		<fo:table-cell text-align="right" font-size="10pt" font-weight="bold" font-family="Arial">
			<fo:block>
				<fo:basic-link internal-destination="{$target}" fox:alt-text="{.}">
					<fo:page-number-citation ref-id="{$target}"/>
				</fo:basic-link>
			</fo:block>
		</fo:table-cell>
	</xsl:template><xsl:template match="*" mode="toc_table_width">
		<xsl:apply-templates mode="toc_table_width"/>
	</xsl:template><xsl:template match="*[local-name() = 'clause'][@type = 'toc']/*[local-name() = 'title']" mode="toc_table_width"/><xsl:template match="*[local-name() = 'clause'][not(@type = 'toc')]/*[local-name() = 'title']" mode="toc_table_width"/><xsl:template match="*[local-name() = 'li']" mode="toc_table_width">
		<tr>
			<xsl:apply-templates mode="toc_table_width"/>
		</tr>
	</xsl:template><xsl:template match="*[local-name() = 'xref']" mode="toc_table_width">
		<!-- <xref target="cgpm9th1948r6">1.6.3<tab/>&#8220;9th CGPM, 1948:<tab/>decision to establish the SI&#8221;</xref> -->
		<xsl:for-each select="*[local-name() = 'tab']">
			<xsl:variable name="current_id" select="generate-id()"/>
			<td>
				<xsl:for-each select="following-sibling::node()[not(self::*[local-name() = 'tab']) and preceding-sibling::*[local-name() = 'tab'][1][generate-id() = $current_id]]">
					<xsl:copy-of select="."/>
				</xsl:for-each>
			</td>
		</xsl:for-each>
		<td>333</td> <!-- page number, just for fill -->
	</xsl:template><xsl:template match="*[local-name() = 'variant-title']"/><xsl:template match="*[local-name() = 'variant-title'][@type = 'sub']" mode="subtitle">
		<fo:inline padding-right="5mm"> </fo:inline>
		<fo:inline><xsl:apply-templates/></fo:inline>
	</xsl:template><xsl:template match="*[local-name() = 'blacksquare']" name="blacksquare">
		<fo:inline padding-right="2.5mm" baseline-shift="5%">
			<fo:instream-foreign-object content-height="2mm" content-width="2mm" fox:alt-text="Quad">
					<svg xmlns="http://www.w3.org/2000/svg" xml:space="preserve" viewBox="0 0 2 2">
						<rect x="0" y="0" width="2" height="2" fill="black"/>
					</svg>
				</fo:instream-foreign-object>	
		</fo:inline>
	</xsl:template><xsl:template match="@language">
		<xsl:copy-of select="."/>
	</xsl:template><xsl:template match="*[local-name() = 'p'][@type = 'floating-title' or @type = 'section-title']" priority="4">
		<xsl:call-template name="title"/>
	</xsl:template><xsl:template match="*[local-name() = 'admonition']">
		
		
		
		
		
		
				<fo:block xsl:use-attribute-sets="admonition-style">
				
					
					
					<xsl:if test="@type = 'editorial'">
						<xsl:attribute name="color">green</xsl:attribute>
						<xsl:attribute name="font-weight">normal</xsl:attribute>
						
						<!-- <xsl:variable name="note-style">
							<style xsl:use-attribute-sets="note-style"></style>
						</xsl:variable>
						<xsl:for-each select="xalan:nodeset($note-style)//style/@*">
							<xsl:attribute name="{local-name()}"><xsl:value-of select="."/></xsl:attribute>
						</xsl:for-each> -->
					</xsl:if>
					
					
					
					
						<xsl:if test="@type != 'editorial'">
							<xsl:call-template name="displayAdmonitionName">
								<xsl:with-param name="sep"> — </xsl:with-param>
							</xsl:call-template>
						</xsl:if>
					
					
					
					
					<xsl:apply-templates select="node()[not(local-name() = 'name')]"/>
				</fo:block>
			
	</xsl:template><xsl:template name="displayAdmonitionName">
		<xsl:param name="sep"/> <!-- Example: ' - ' -->
		<!-- <xsl:choose>
			<xsl:when test="$namespace = 'nist-cswp' or $namespace = 'nist-sp'">
				<xsl:choose>
					<xsl:when test="@type='important'"><xsl:apply-templates select="@type"/></xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="*[local-name() = 'name']"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="*[local-name() = 'name']"/>
				<xsl:if test="not(*[local-name() = 'name'])">
					<xsl:apply-templates select="@type"/>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose> -->
		<xsl:variable name="name">
			<xsl:apply-templates select="*[local-name() = 'name']"/>
		</xsl:variable>
		<xsl:copy-of select="$name"/>
		<xsl:if test="normalize-space($name) != ''">
			<xsl:value-of select="$sep"/>
		</xsl:if>
	</xsl:template><xsl:template match="*[local-name() = 'admonition']/*[local-name() = 'name']">
		<xsl:apply-templates/>
	</xsl:template><xsl:template match="*[local-name() = 'admonition']/*[local-name() = 'p']">
		 <!-- processing for admonition/p found in the template for 'p' -->
				<xsl:call-template name="paragraph"/>
			
	</xsl:template><xsl:template match="@*|node()" mode="update_xml_step1">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="update_xml_step1"/>
		</xsl:copy>
	</xsl:template><xsl:template match="*[local-name() = 'preface']" mode="update_xml_step1">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			
			<xsl:variable name="nodes_preface_">
				<xsl:for-each select="*">
					<node id="{@id}"/>
				</xsl:for-each>
			</xsl:variable>
			<xsl:variable name="nodes_preface" select="xalan:nodeset($nodes_preface_)"/>
			
			<xsl:for-each select="*">
				<xsl:sort select="@displayorder" data-type="number"/>
				
				<!-- process Section's title -->
				<xsl:variable name="preceding-sibling_id" select="$nodes_preface/node[@id = current()/@id]/preceding-sibling::node[1]/@id"/>
				<xsl:if test="$preceding-sibling_id != ''">
					<xsl:apply-templates select="parent::*/*[@type = 'section-title' and @id = $preceding-sibling_id and not(@displayorder)]" mode="update_xml_step1"/>
				</xsl:if>
				
				<xsl:choose>
					<xsl:when test="@type = 'section-title' and not(@displayorder)"><!-- skip, don't copy, because copied in above 'apply-templates' --></xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="." mode="update_xml_step1"/>
					</xsl:otherwise>
				</xsl:choose>
				
			</xsl:for-each>
		</xsl:copy>
	</xsl:template><xsl:template match="*[local-name() = 'sections']" mode="update_xml_step1">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			
			<xsl:variable name="nodes_sections_">
				<xsl:for-each select="*">
					<node id="{@id}"/>
				</xsl:for-each>
			</xsl:variable>
			<xsl:variable name="nodes_sections" select="xalan:nodeset($nodes_sections_)"/>
			
			<!-- move section 'Normative references' inside 'sections' -->
			<xsl:for-each select="* |      ancestor::*[contains(local-name(), '-standard')]/*[local-name()='bibliography']/*[local-name()='references'][@normative='true'] |     ancestor::*[contains(local-name(), '-standard')]/*[local-name()='bibliography']/*[local-name()='clause'][*[local-name()='references'][@normative='true']]">
				<xsl:sort select="@displayorder" data-type="number"/>
				
				<!-- process Section's title -->
				<xsl:variable name="preceding-sibling_id" select="$nodes_sections/node[@id = current()/@id]/preceding-sibling::node[1]/@id"/>
				<xsl:if test="$preceding-sibling_id != ''">
					<xsl:apply-templates select="parent::*/*[@type = 'section-title' and @id = $preceding-sibling_id and not(@displayorder)]" mode="update_xml_step1"/>
				</xsl:if>
				
				<xsl:choose>
					<xsl:when test="@type = 'section-title' and not(@displayorder)"><!-- skip, don't copy, because copied in above 'apply-templates' --></xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="." mode="update_xml_step1"/>
					</xsl:otherwise>
				</xsl:choose>
				
			</xsl:for-each>
		</xsl:copy>
	</xsl:template><xsl:template match="*[local-name() = 'bibliography']" mode="update_xml_step1">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<!-- copy all elements from bibliography except 'Normative references' (moved to 'sections') -->
			<xsl:for-each select="*[not(@normative='true') and not(*[@normative='true'])]">
				<xsl:sort select="@displayorder" data-type="number"/>
				<xsl:apply-templates select="." mode="update_xml_step1"/>
			</xsl:for-each>
		</xsl:copy>
	</xsl:template><xsl:template match="*[local-name() = 'span']" mode="update_xml_step1">
		<xsl:apply-templates mode="update_xml_step1"/>
	</xsl:template>
		<!-- STEP2: add 'fn' after 'eref' and 'origin', if referenced to bibitem with 'note' = Withdrawn.' or 'Cancelled and replaced...'  -->
		<xsl:template match="@*|node()" mode="update_xml_step2">
			<xsl:copy>
				<xsl:apply-templates select="@*|node()" mode="update_xml_step2"/>
			</xsl:copy>
		</xsl:template>
		
		<xsl:variable name="localized_string_withdrawn">
			<xsl:call-template name="getLocalizedString">
				<xsl:with-param name="key">withdrawn</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="localized_string_cancelled_and_replaced">
			<xsl:variable name="str">
				<xsl:call-template name="getLocalizedString">
					<xsl:with-param name="key">cancelled_and_replaced</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="contains($str, '%')"><xsl:value-of select="substring-before($str, '%')"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="$str"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<!-- add 'fn' after eref and origin, to reference bibitem with note = 'Withdrawn.' or 'Cancelled and replaced...' -->
		<xsl:template match="*[local-name() = 'eref'] | *[local-name() = 'origin']" mode="update_xml_step2">
			<xsl:copy-of select="."/>
			
			<xsl:variable name="bibitemid" select="@bibitemid"/>
			<xsl:variable name="local_name" select="local-name()"/>
			<xsl:variable name="position"><xsl:number count="*[local-name() = $local_name][@bibitemid = $bibitemid]" level="any"/></xsl:variable>
			<xsl:if test="normalize-space($position) = '1'">
				<xsl:variable name="fn_text">
					<!-- <xsl:copy-of select="key('bibitems', $bibitemid)[1]/*[local-name() = 'note'][not(@type='Unpublished-Status')][normalize-space() = $localized_string_withdrawn or starts-with(normalize-space(), $localized_string_cancelled_and_replaced)]/node()" /> -->
					<xsl:copy-of select="$bibitems/*[local-name() ='bibitem'][@id = $bibitemid][1]/*[local-name() = 'note'][not(@type='Unpublished-Status')][normalize-space() = $localized_string_withdrawn or starts-with(normalize-space(), $localized_string_cancelled_and_replaced)]/node()"/>
				</xsl:variable>
				<xsl:if test="normalize-space($fn_text) != ''">
					<xsl:element name="fn" namespace="{$namespace_full}">
						<xsl:attribute name="reference">bibitem_<xsl:value-of select="$bibitemid"/></xsl:attribute>
						<xsl:element name="p" namespace="{$namespace_full}">
							<xsl:copy-of select="$fn_text"/>
						</xsl:element>
					</xsl:element>
				</xsl:if>
			</xsl:if>
		</xsl:template>
		
		<!-- add id for table without id (for autolayout algorithm) -->
		<!-- <xsl:template match="*[local-name() = 'table'][not(@id)]" mode="update_xml_step2">
			<xsl:copy>
				<xsl:apply-templates select="@*" mode="update_xml_step2"/>
				<xsl:attribute name="id">_abc<xsl:value-of select="generate-id()"/></xsl:attribute>
				
				<xsl:apply-templates select="node()" mode="update_xml_step2"/>
			</xsl:copy>
		</xsl:template> -->
		
		<!-- add @reference for fn -->
		<xsl:template match="*[local-name() = 'fn'][not(@reference)]" mode="update_xml_step2">
			<xsl:copy>
				<xsl:apply-templates select="@*" mode="update_xml_step2"/>
				<xsl:attribute name="reference"><xsl:value-of select="generate-id(.)"/></xsl:attribute>
				<xsl:apply-templates select="node()" mode="update_xml_step2"/>
			</xsl:copy>
		</xsl:template>
		
		
		<!-- add @reference for bibitem/note, similar to fn/reference -->
		<xsl:template match="*[local-name() = 'bibitem']/*[local-name() = 'note']" mode="update_xml_step2">
			<xsl:copy>
				<xsl:apply-templates select="@*" mode="update_xml_step2"/>
				
				<xsl:attribute name="reference">
					<xsl:value-of select="concat('bibitem_', ../@id, '_', count(preceding-sibling::*[local-name() = 'note']))"/>
				</xsl:attribute>
				
				<xsl:apply-templates select="node()" mode="update_xml_step2"/>
			</xsl:copy>
		</xsl:template>
		
		<!-- END STEP2: add 'fn' after 'eref' and 'origin', if referenced to bibitem with 'note' = Withdrawn.' or 'Cancelled and replaced...'  -->
		
		
		<!-- enclose sequence of 'char x' + 'combining char y' to <lang_none>xy</lang_none> -->
		<xsl:variable name="regex_combining_chars">(.[̀-ͯ])</xsl:variable>
		<xsl:variable name="element_name_lang_none">lang_none</xsl:variable>
		<xsl:variable name="tag_element_name_lang_none_open">###<xsl:value-of select="$element_name_lang_none"/>###</xsl:variable>
		<xsl:variable name="tag_element_name_lang_none_close">###/<xsl:value-of select="$element_name_lang_none"/>###</xsl:variable>

		<xsl:template match="text()" mode="update_xml_step2">
			<xsl:variable name="text_" select="java:replaceAll(java:java.lang.String.new(.), $regex_combining_chars, concat($tag_element_name_lang_none_open,'$1',$tag_element_name_lang_none_close))"/>
			<xsl:call-template name="replace_text_tags">
				<xsl:with-param name="tag_open" select="$tag_element_name_lang_none_open"/>
				<xsl:with-param name="tag_close" select="$tag_element_name_lang_none_close"/>
				<xsl:with-param name="text" select="$text_"/>
			</xsl:call-template>
		</xsl:template>
		
	<xsl:template match="@*|node()" mode="update_xml_enclose_keep-together_within-line">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="update_xml_enclose_keep-together_within-line"/>
		</xsl:copy>
	</xsl:template><xsl:variable name="express_reference_separators">_.\</xsl:variable><xsl:variable name="express_reference_characters" select="concat($upper,$lower,'1234567890',$express_reference_separators)"/><xsl:variable name="element_name_keep-together_within-line">keep-together_within-line</xsl:variable><xsl:template match="text()[not(ancestor::*[local-name() = 'bibdata'] or ancestor::*[local-name() = 'sourcecode'] or ancestor::*[local-name() = 'math'])]" name="keep_together_standard_number" mode="update_xml_enclose_keep-together_within-line">
	
		<!-- enclose standard's number into tag 'keep-together_within-line' -->
		<xsl:variable name="regex_standard_reference">([A-Z]{2,}(/[A-Z]{2,})* \d+(-\d+)*(:\d{4})?)</xsl:variable>
		<xsl:variable name="tag_keep-together_within-line_open">###<xsl:value-of select="$element_name_keep-together_within-line"/>###</xsl:variable>
		<xsl:variable name="tag_keep-together_within-line_close">###/<xsl:value-of select="$element_name_keep-together_within-line"/>###</xsl:variable>
		<xsl:variable name="text_" select="java:replaceAll(java:java.lang.String.new(.),$regex_standard_reference,concat($tag_keep-together_within-line_open,'$1',$tag_keep-together_within-line_close))"/>
		<xsl:variable name="text"><text><xsl:call-template name="replace_text_tags">
				<xsl:with-param name="tag_open" select="$tag_keep-together_within-line_open"/>
				<xsl:with-param name="tag_close" select="$tag_keep-together_within-line_close"/>
				<xsl:with-param name="text" select="$text_"/>
			</xsl:call-template></text></xsl:variable>
		
		<xsl:variable name="parent" select="local-name(..)"/>
		
		<xsl:variable name="text2">
			<text><xsl:for-each select="xalan:nodeset($text)/text/node()">
					
							<xsl:choose>
								<!-- if EXPRESS reference -->
								<xsl:when test="self::text() and $parent = 'strong' and translate(., $express_reference_characters, '') = ''">
									<xsl:element name="{$element_name_keep-together_within-line}"><xsl:value-of select="."/></xsl:element>
								</xsl:when>
								<xsl:otherwise><xsl:copy-of select="."/></xsl:otherwise> <!-- copy 'as-is' for <fo:inline keep-together.within-line="always" ...  -->
							</xsl:choose>
						
				</xsl:for-each></text>
		</xsl:variable>
		
		<!-- keep-together_within-line for: a/b, aaa/b, a/bbb, /b -->
		<xsl:variable name="regex_solidus_units">((\b((\S{1,3}\/\S+)|(\S+\/\S{1,3}))\b)|(\/\S{1,3})\b)</xsl:variable>
		<xsl:variable name="text3">
			<text><xsl:for-each select="xalan:nodeset($text2)/text/node()">
				<xsl:choose>
					<xsl:when test="self::text()">
						<xsl:variable name="text_units_" select="java:replaceAll(java:java.lang.String.new(.),$regex_solidus_units,concat($tag_keep-together_within-line_open,'$1',$tag_keep-together_within-line_close))"/>
						<xsl:variable name="text_units"><text><xsl:call-template name="replace_text_tags">
							<xsl:with-param name="tag_open" select="$tag_keep-together_within-line_open"/>
							<xsl:with-param name="tag_close" select="$tag_keep-together_within-line_close"/>
							<xsl:with-param name="text" select="$text_units_"/>
						</xsl:call-template></text></xsl:variable>
						<xsl:copy-of select="xalan:nodeset($text_units)/text/node()"/>
					</xsl:when>
					<xsl:otherwise><xsl:copy-of select="."/></xsl:otherwise> <!-- copy 'as-is' for <fo:inline keep-together.within-line="always" ...  -->
				</xsl:choose>
			</xsl:for-each></text>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="ancestor::*[local-name() = 'td' or local-name() = 'th']">
				<!-- keep-together_within-line for: a.b, aaa.b, a.bbb, .b  in table's cell ONLY -->
				<xsl:variable name="regex_dots_units">((\b((\S{1,3}\.\S+)|(\S+\.\S{1,3}))\b)|(\.\S{1,3})\b)</xsl:variable>
				<xsl:for-each select="xalan:nodeset($text3)/text/node()">
					<xsl:choose>
						<xsl:when test="self::text()">
							<xsl:variable name="text_dots_" select="java:replaceAll(java:java.lang.String.new(.),$regex_dots_units,concat($tag_keep-together_within-line_open,'$1',$tag_keep-together_within-line_close))"/>
							<xsl:variable name="text_dots"><text><xsl:call-template name="replace_text_tags">
								<xsl:with-param name="tag_open" select="$tag_keep-together_within-line_open"/>
								<xsl:with-param name="tag_close" select="$tag_keep-together_within-line_close"/>
								<xsl:with-param name="text" select="$text_dots_"/>
							</xsl:call-template></text></xsl:variable>
							<xsl:copy-of select="xalan:nodeset($text_dots)/text/node()"/>
						</xsl:when>
						<xsl:otherwise><xsl:copy-of select="."/></xsl:otherwise> <!-- copy 'as-is' for <fo:inline keep-together.within-line="always" ...  -->
					</xsl:choose>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise><xsl:copy-of select="xalan:nodeset($text3)/text/node()"/></xsl:otherwise>
		</xsl:choose>
		
	</xsl:template><xsl:template name="replace_text_tags">
		<xsl:param name="tag_open"/>
		<xsl:param name="tag_close"/>
		<xsl:param name="text"/>
		<xsl:choose>
			<xsl:when test="contains($text, $tag_open)">
				<xsl:value-of select="substring-before($text, $tag_open)"/>
				<xsl:variable name="text_after" select="substring-after($text, $tag_open)"/>
				
				<xsl:element name="{substring-before(substring-after($tag_open, '###'),'###')}">
					<xsl:value-of select="substring-before($text_after, $tag_close)"/>
				</xsl:element>
				
				<xsl:call-template name="replace_text_tags">
					<xsl:with-param name="tag_open" select="$tag_open"/>
					<xsl:with-param name="tag_close" select="$tag_close"/>
					<xsl:with-param name="text" select="substring-after($text_after, $tag_close)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise><xsl:value-of select="$text"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template match="*[local-name() = 'lang_none']">
		<fo:inline xml:lang="none"><xsl:value-of select="."/></fo:inline>
	</xsl:template><xsl:template name="printEdition">
		<xsl:variable name="edition_i18n" select="normalize-space((//*[contains(local-name(), '-standard')])[1]/*[local-name() = 'bibdata']/*[local-name() = 'edition'][normalize-space(@language) != ''])"/>
		<xsl:text> </xsl:text>
		<xsl:choose>
			<xsl:when test="$edition_i18n != ''">
				<!-- Example: <edition language="fr">deuxième édition</edition> -->
				<xsl:call-template name="capitalize">
					<xsl:with-param name="str" select="$edition_i18n"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="edition" select="normalize-space((//*[contains(local-name(), '-standard')])[1]/*[local-name() = 'bibdata']/*[local-name() = 'edition'])"/>
				<xsl:if test="$edition != ''"> <!-- Example: 1.3 -->
					<xsl:call-template name="capitalize">
						<xsl:with-param name="str">
							<xsl:call-template name="getLocalizedString">
								<xsl:with-param name="key">edition</xsl:with-param>
							</xsl:call-template>
						</xsl:with-param>
					</xsl:call-template>
					<xsl:text> </xsl:text>
					<xsl:value-of select="$edition"/>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="convertDate">
		<xsl:param name="date"/>
		<xsl:param name="format" select="'short'"/>
		<xsl:variable name="year" select="substring($date, 1, 4)"/>
		<xsl:variable name="month" select="substring($date, 6, 2)"/>
		<xsl:variable name="day" select="substring($date, 9, 2)"/>
		<xsl:variable name="monthStr">
			<xsl:call-template name="getMonthByNum">
				<xsl:with-param name="num" select="$month"/>
				<xsl:with-param name="lowercase" select="'true'"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="monthStr_localized">
			<xsl:if test="normalize-space($monthStr) != ''"><xsl:call-template name="getLocalizedString"><xsl:with-param name="key">month_<xsl:value-of select="$monthStr"/></xsl:with-param></xsl:call-template></xsl:if>
		</xsl:variable>
		<xsl:variable name="result">
			<xsl:choose>
				<xsl:when test="$format = 'ddMMyyyy'"> <!-- convert date from format 2007-04-01 to 1 April 2007 -->
					<xsl:if test="$day != ''"><xsl:value-of select="number($day)"/></xsl:if>
					<xsl:text> </xsl:text>
					<xsl:value-of select="normalize-space(concat($monthStr_localized, ' ' , $year))"/>
				</xsl:when>
				<xsl:when test="$format = 'ddMM'">
					<xsl:if test="$day != ''"><xsl:value-of select="number($day)"/></xsl:if>
					<xsl:text> </xsl:text><xsl:value-of select="$monthStr_localized"/>
				</xsl:when>
				<xsl:when test="$format = 'short' or $day = ''">
					<xsl:value-of select="normalize-space(concat($monthStr_localized, ' ', $year))"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="normalize-space(concat($monthStr_localized, ' ', $day, ', ' , $year))"/> <!-- January 01, 2022 -->
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="$result"/>
	</xsl:template><xsl:template name="getMonthByNum">
		<xsl:param name="num"/>
		<xsl:param name="lang">en</xsl:param>
		<xsl:param name="lowercase">false</xsl:param> <!-- return 'january' instead of 'January' -->
		<xsl:variable name="monthStr_">
			<xsl:choose>
				<xsl:when test="$lang = 'fr'">
					<xsl:choose>
						<xsl:when test="$num = '01'">Janvier</xsl:when>
						<xsl:when test="$num = '02'">Février</xsl:when>
						<xsl:when test="$num = '03'">Mars</xsl:when>
						<xsl:when test="$num = '04'">Avril</xsl:when>
						<xsl:when test="$num = '05'">Mai</xsl:when>
						<xsl:when test="$num = '06'">Juin</xsl:when>
						<xsl:when test="$num = '07'">Juillet</xsl:when>
						<xsl:when test="$num = '08'">Août</xsl:when>
						<xsl:when test="$num = '09'">Septembre</xsl:when>
						<xsl:when test="$num = '10'">Octobre</xsl:when>
						<xsl:when test="$num = '11'">Novembre</xsl:when>
						<xsl:when test="$num = '12'">Décembre</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="$num = '01'">January</xsl:when>
						<xsl:when test="$num = '02'">February</xsl:when>
						<xsl:when test="$num = '03'">March</xsl:when>
						<xsl:when test="$num = '04'">April</xsl:when>
						<xsl:when test="$num = '05'">May</xsl:when>
						<xsl:when test="$num = '06'">June</xsl:when>
						<xsl:when test="$num = '07'">July</xsl:when>
						<xsl:when test="$num = '08'">August</xsl:when>
						<xsl:when test="$num = '09'">September</xsl:when>
						<xsl:when test="$num = '10'">October</xsl:when>
						<xsl:when test="$num = '11'">November</xsl:when>
						<xsl:when test="$num = '12'">December</xsl:when>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="normalize-space($lowercase) = 'true'">
				<xsl:value-of select="java:toLowerCase(java:java.lang.String.new($monthStr_))"/>
			</xsl:when>
			<xsl:otherwise><xsl:value-of select="$monthStr_"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="getMonthLocalizedByNum">
		<xsl:param name="num"/>
		<xsl:variable name="monthStr">
			<xsl:choose>
				<xsl:when test="$num = '01'">january</xsl:when>
				<xsl:when test="$num = '02'">february</xsl:when>
				<xsl:when test="$num = '03'">march</xsl:when>
				<xsl:when test="$num = '04'">april</xsl:when>
				<xsl:when test="$num = '05'">may</xsl:when>
				<xsl:when test="$num = '06'">june</xsl:when>
				<xsl:when test="$num = '07'">july</xsl:when>
				<xsl:when test="$num = '08'">august</xsl:when>
				<xsl:when test="$num = '09'">september</xsl:when>
				<xsl:when test="$num = '10'">october</xsl:when>
				<xsl:when test="$num = '11'">november</xsl:when>
				<xsl:when test="$num = '12'">december</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:call-template name="getLocalizedString">
			<xsl:with-param name="key">month_<xsl:value-of select="$monthStr"/></xsl:with-param>
		</xsl:call-template>
	</xsl:template><xsl:template name="insertKeywords">
		<xsl:param name="sorting" select="'true'"/>
		<xsl:param name="charAtEnd" select="'.'"/>
		<xsl:param name="charDelim" select="', '"/>
		<xsl:choose>
			<xsl:when test="$sorting = 'true' or $sorting = 'yes'">
				<xsl:for-each select="//*[contains(local-name(), '-standard')]/*[local-name() = 'bibdata']//*[local-name() = 'keyword']">
					<xsl:sort data-type="text" order="ascending"/>
					<xsl:call-template name="insertKeyword">
						<xsl:with-param name="charAtEnd" select="$charAtEnd"/>
						<xsl:with-param name="charDelim" select="$charDelim"/>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="//*[contains(local-name(), '-standard')]/*[local-name() = 'bibdata']//*[local-name() = 'keyword']">
					<xsl:call-template name="insertKeyword">
						<xsl:with-param name="charAtEnd" select="$charAtEnd"/>
						<xsl:with-param name="charDelim" select="$charDelim"/>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="insertKeyword">
		<xsl:param name="charAtEnd"/>
		<xsl:param name="charDelim"/>
		<xsl:apply-templates/>
		<xsl:choose>
			<xsl:when test="position() != last()"><xsl:value-of select="$charDelim"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="$charAtEnd"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="addPDFUAmeta">
		<pdf:catalog>
				<pdf:dictionary type="normal" key="ViewerPreferences">
					<pdf:boolean key="DisplayDocTitle">true</pdf:boolean>
				</pdf:dictionary>
			</pdf:catalog>
		<x:xmpmeta xmlns:x="adobe:ns:meta/">
			<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
				<rdf:Description xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:pdf="http://ns.adobe.com/pdf/1.3/" rdf:about="">
				<!-- Dublin Core properties go here -->
					<dc:title>
						<xsl:variable name="title">
							<xsl:for-each select="(//*[contains(local-name(), '-standard')])[1]/*[local-name() = 'bibdata']">
								
										<xsl:value-of select="*[local-name() = 'title'][@language = $lang and @type = 'main']"/>
									
							</xsl:for-each>
						</xsl:variable>
						<xsl:choose>
							<xsl:when test="normalize-space($title) != ''">
								<xsl:value-of select="$title"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text> </xsl:text>
							</xsl:otherwise>
						</xsl:choose>							
					</dc:title>
					<dc:creator>
						<xsl:for-each select="(//*[contains(local-name(), '-standard')])[1]/*[local-name() = 'bibdata']">
							
									<xsl:for-each select="*[local-name() = 'contributor'][*[local-name() = 'role']/@type='author']">
										<xsl:value-of select="*[local-name() = 'organization']/*[local-name() = 'name']"/>
										<xsl:if test="position() != last()">; </xsl:if>
									</xsl:for-each>
								
						</xsl:for-each>
					</dc:creator>
					<dc:description>
						<xsl:variable name="abstract">
							
									<xsl:copy-of select="//*[contains(local-name(), '-standard')]/*[local-name() = 'preface']/*[local-name() = 'abstract']//text()[not(ancestor::*[local-name() = 'title'])]"/>									
								
						</xsl:variable>
						<xsl:value-of select="normalize-space($abstract)"/>
					</dc:description>
					<pdf:Keywords>
						<xsl:call-template name="insertKeywords"/>
					</pdf:Keywords>
				</rdf:Description>
				<rdf:Description xmlns:xmp="http://ns.adobe.com/xap/1.0/" rdf:about="">
					<!-- XMP properties go here -->
					<xmp:CreatorTool/>
				</rdf:Description>
			</rdf:RDF>
		</x:xmpmeta>
	</xsl:template><xsl:template name="getId">
		<xsl:choose>
			<xsl:when test="../@id">
				<xsl:value-of select="../@id"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat(generate-id(..), '_', text())"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="getLevel">
		<xsl:param name="depth"/>
		<xsl:choose>
			<xsl:when test="normalize-space(@depth) != ''">
				<xsl:value-of select="@depth"/>
			</xsl:when>
			<xsl:when test="normalize-space($depth) != ''">
				<xsl:value-of select="$depth"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="level_total" select="count(ancestor::*)"/>
				<xsl:variable name="level">
					<xsl:choose>
						<xsl:when test="parent::*[local-name() = 'preface']">
							<xsl:value-of select="$level_total - 1"/>
						</xsl:when>
						<xsl:when test="ancestor::*[local-name() = 'preface'] and not(ancestor::*[local-name() = 'foreword']) and not(ancestor::*[local-name() = 'introduction'])"> <!-- for preface/clause -->
							<xsl:value-of select="$level_total - 1"/>
						</xsl:when>
						<xsl:when test="ancestor::*[local-name() = 'preface']">
							<xsl:value-of select="$level_total - 2"/>
						</xsl:when>
						<xsl:when test="ancestor::*[local-name() = 'sections']">
							<xsl:value-of select="$level_total - 1"/>
						</xsl:when>
						<xsl:when test="ancestor::*[local-name() = 'bibliography']">
							<xsl:value-of select="$level_total - 1"/>
						</xsl:when>
						<xsl:when test="parent::*[local-name() = 'annex']">
							<xsl:value-of select="$level_total - 1"/>
						</xsl:when>
						<xsl:when test="ancestor::*[local-name() = 'annex']">
							<xsl:value-of select="$level_total"/>
						</xsl:when>
						<xsl:when test="local-name() = 'annex'">1</xsl:when>
						<xsl:when test="local-name(ancestor::*[1]) = 'annex'">1</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$level_total - 1"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:value-of select="$level"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="getLevelTermName">
		<xsl:choose>
			<xsl:when test="normalize-space(../@depth) != ''">
				<xsl:value-of select="../@depth"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="title_level_">
					<xsl:for-each select="../preceding-sibling::*[local-name() = 'title'][1]">
						<xsl:call-template name="getLevel"/>
					</xsl:for-each>
				</xsl:variable>
				<xsl:variable name="title_level" select="normalize-space($title_level_)"/>
				<xsl:choose>
					<xsl:when test="$title_level != ''"><xsl:value-of select="$title_level + 1"/></xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="getLevel"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="split">
		<xsl:param name="pText" select="."/>
		<xsl:param name="sep" select="','"/>
		<xsl:param name="normalize-space" select="'true'"/>
		<xsl:param name="keep_sep" select="'false'"/>
		<xsl:if test="string-length($pText) &gt;0">
			<item>
				<xsl:choose>
					<xsl:when test="$normalize-space = 'true'">
						<xsl:value-of select="normalize-space(substring-before(concat($pText, $sep), $sep))"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="substring-before(concat($pText, $sep), $sep)"/>
					</xsl:otherwise>
				</xsl:choose>
			</item>
			<xsl:if test="$keep_sep = 'true' and contains($pText, $sep)"><item><xsl:value-of select="$sep"/></item></xsl:if>
			<xsl:call-template name="split">
				<xsl:with-param name="pText" select="substring-after($pText, $sep)"/>
				<xsl:with-param name="sep" select="$sep"/>
				<xsl:with-param name="normalize-space" select="$normalize-space"/>
				<xsl:with-param name="keep_sep" select="$keep_sep"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template><xsl:template name="getDocumentId">		
		<xsl:call-template name="getLang"/><xsl:value-of select="//*[local-name() = 'p'][1]/@id"/>
	</xsl:template><xsl:template name="namespaceCheck">
		<xsl:variable name="documentNS" select="namespace-uri(/*)"/>
		<xsl:variable name="XSLNS">			
			
			
				<xsl:value-of select="document('')//*/namespace::iso"/>
			
			
			
			
			
			
			
			
			
			
			
						
			
			
			
			
		</xsl:variable>
		<xsl:if test="$documentNS != $XSLNS">
			<xsl:message>[WARNING]: Document namespace: '<xsl:value-of select="$documentNS"/>' doesn't equal to xslt namespace '<xsl:value-of select="$XSLNS"/>'</xsl:message>
		</xsl:if>
	</xsl:template><xsl:template name="getLanguage">
		<xsl:param name="lang"/>		
		<xsl:variable name="language" select="java:toLowerCase(java:java.lang.String.new($lang))"/>
		<xsl:choose>
			<xsl:when test="$language = 'en'">English</xsl:when>
			<xsl:when test="$language = 'fr'">French</xsl:when>
			<xsl:when test="$language = 'de'">Deutsch</xsl:when>
			<xsl:when test="$language = 'cn'">Chinese</xsl:when>
			<xsl:otherwise><xsl:value-of select="$language"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="setId">
		<xsl:attribute name="id">
			<xsl:choose>
				<xsl:when test="@id">
					<xsl:value-of select="@id"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="generate-id()"/>
				</xsl:otherwise>
			</xsl:choose>					
		</xsl:attribute>
	</xsl:template><xsl:template name="add-letter-spacing">
		<xsl:param name="text"/>
		<xsl:param name="letter-spacing" select="'0.15'"/>
		<xsl:if test="string-length($text) &gt; 0">
			<xsl:variable name="char" select="substring($text, 1, 1)"/>
			<fo:inline padding-right="{$letter-spacing}mm">
				<xsl:if test="$char = '®'">
					<xsl:attribute name="font-size">58%</xsl:attribute>
					<xsl:attribute name="baseline-shift">30%</xsl:attribute>
				</xsl:if>				
				<xsl:value-of select="$char"/>
			</fo:inline>
			<xsl:call-template name="add-letter-spacing">
				<xsl:with-param name="text" select="substring($text, 2)"/>
				<xsl:with-param name="letter-spacing" select="$letter-spacing"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template><xsl:template name="repeat">
		<xsl:param name="char" select="'*'"/>
		<xsl:param name="count"/>
		<xsl:if test="$count &gt; 0">
			<xsl:value-of select="$char"/>
			<xsl:call-template name="repeat">
				<xsl:with-param name="char" select="$char"/>
				<xsl:with-param name="count" select="$count - 1"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template><xsl:template name="getLocalizedString">
		<xsl:param name="key"/>
		<xsl:param name="formatted">false</xsl:param>
		<xsl:param name="lang"/>
		<xsl:param name="returnEmptyIfNotFound">false</xsl:param>
		
		<xsl:variable name="curr_lang">
			<xsl:choose>
				<xsl:when test="$lang != ''"><xsl:value-of select="$lang"/></xsl:when>
				<xsl:when test="$returnEmptyIfNotFound = 'true'"/>
				<xsl:otherwise>
					<xsl:call-template name="getLang"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="data_value">
			<xsl:choose>
				<xsl:when test="$formatted = 'true'">
					<xsl:apply-templates select="xalan:nodeset($bibdata)//*[local-name() = 'localized-string'][@key = $key and @language = $curr_lang]"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="normalize-space(xalan:nodeset($bibdata)//*[local-name() = 'localized-string'][@key = $key and @language = $curr_lang])"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="normalize-space($data_value) != ''">
				<xsl:choose>
					<xsl:when test="$formatted = 'true'"><xsl:copy-of select="$data_value"/></xsl:when>
					<xsl:otherwise><xsl:value-of select="$data_value"/></xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="/*/*[local-name() = 'localized-strings']/*[local-name() = 'localized-string'][@key = $key and @language = $curr_lang]">
				<xsl:choose>
					<xsl:when test="$formatted = 'true'">
						<xsl:apply-templates select="/*/*[local-name() = 'localized-strings']/*[local-name() = 'localized-string'][@key = $key and @language = $curr_lang]"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="/*/*[local-name() = 'localized-strings']/*[local-name() = 'localized-string'][@key = $key and @language = $curr_lang]"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$returnEmptyIfNotFound = 'true'"/>
			<xsl:otherwise>
				<xsl:variable name="key_">
					<xsl:call-template name="capitalize">
						<xsl:with-param name="str" select="translate($key, '_', ' ')"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:value-of select="$key_"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="setTrackChangesStyles">
		<xsl:param name="isAdded"/>
		<xsl:param name="isDeleted"/>
		<xsl:choose>
			<xsl:when test="local-name() = 'math'">
				<xsl:if test="$isAdded = 'true'">
					<xsl:attribute name="background-color"><xsl:value-of select="$color-added-text"/></xsl:attribute>
				</xsl:if>
				<xsl:if test="$isDeleted = 'true'">
					<xsl:attribute name="background-color"><xsl:value-of select="$color-deleted-text"/></xsl:attribute>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="$isAdded = 'true'">
					<xsl:attribute name="border"><xsl:value-of select="$border-block-added"/></xsl:attribute>
					<xsl:attribute name="padding">2mm</xsl:attribute>
				</xsl:if>
				<xsl:if test="$isDeleted = 'true'">
					<xsl:attribute name="border"><xsl:value-of select="$border-block-deleted"/></xsl:attribute>
					<xsl:if test="local-name() = 'table'">
						<xsl:attribute name="background-color">rgb(255, 185, 185)</xsl:attribute>
					</xsl:if>
					<xsl:attribute name="padding">2mm</xsl:attribute>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:variable name="LRM" select="'‎'"/><xsl:variable name="RLM" select="'‏'"/><xsl:template name="setWritingMode">
		<xsl:if test="$lang = 'ar'">
			<xsl:attribute name="writing-mode">rl-tb</xsl:attribute>
		</xsl:if>
	</xsl:template><xsl:template name="setAlignment">
		<xsl:param name="align" select="normalize-space(@align)"/>
		<xsl:choose>
			<xsl:when test="$lang = 'ar' and $align = 'left'">start</xsl:when>
			<xsl:when test="$lang = 'ar' and $align = 'right'">end</xsl:when>
			<xsl:when test="$align != ''">
				<xsl:value-of select="$align"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template><xsl:template name="setTextAlignment">
		<xsl:param name="default">left</xsl:param>
		<xsl:variable name="align" select="normalize-space(@align)"/>
		<xsl:attribute name="text-align">
			<xsl:choose>
				<xsl:when test="$lang = 'ar' and $align = 'left'">start</xsl:when>
				<xsl:when test="$lang = 'ar' and $align = 'right'">end</xsl:when>
				<xsl:when test="$align != '' and not($align = 'indent')"><xsl:value-of select="$align"/></xsl:when>
				<xsl:when test="ancestor::*[local-name() = 'td']/@align"><xsl:value-of select="ancestor::*[local-name() = 'td']/@align"/></xsl:when>
				<xsl:when test="ancestor::*[local-name() = 'th']/@align"><xsl:value-of select="ancestor::*[local-name() = 'th']/@align"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="$default"/></xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
		<xsl:if test="$align = 'indent'">
			<xsl:attribute name="margin-left">7mm</xsl:attribute>
		</xsl:if>
	</xsl:template><xsl:template name="number-to-words">
		<xsl:param name="number"/>
		<xsl:param name="first"/>
		<xsl:if test="$number != ''">
			<xsl:variable name="words">
				<words>
					<xsl:choose>
						<xsl:when test="$lang = 'fr'"> <!-- https://en.wiktionary.org/wiki/Appendix:French_numbers -->
							<word cardinal="1">Une-</word>
							<word ordinal="1">Première </word>
							<word cardinal="2">Deux-</word>
							<word ordinal="2">Seconde </word>
							<word cardinal="3">Trois-</word>
							<word ordinal="3">Tierce </word>
							<word cardinal="4">Quatre-</word>
							<word ordinal="4">Quatrième </word>
							<word cardinal="5">Cinq-</word>
							<word ordinal="5">Cinquième </word>
							<word cardinal="6">Six-</word>
							<word ordinal="6">Sixième </word>
							<word cardinal="7">Sept-</word>
							<word ordinal="7">Septième </word>
							<word cardinal="8">Huit-</word>
							<word ordinal="8">Huitième </word>
							<word cardinal="9">Neuf-</word>
							<word ordinal="9">Neuvième </word>
							<word ordinal="10">Dixième </word>
							<word ordinal="11">Onzième </word>
							<word ordinal="12">Douzième </word>
							<word ordinal="13">Treizième </word>
							<word ordinal="14">Quatorzième </word>
							<word ordinal="15">Quinzième </word>
							<word ordinal="16">Seizième </word>
							<word ordinal="17">Dix-septième </word>
							<word ordinal="18">Dix-huitième </word>
							<word ordinal="19">Dix-neuvième </word>
							<word cardinal="20">Vingt-</word>
							<word ordinal="20">Vingtième </word>
							<word cardinal="30">Trente-</word>
							<word ordinal="30">Trentième </word>
							<word cardinal="40">Quarante-</word>
							<word ordinal="40">Quarantième </word>
							<word cardinal="50">Cinquante-</word>
							<word ordinal="50">Cinquantième </word>
							<word cardinal="60">Soixante-</word>
							<word ordinal="60">Soixantième </word>
							<word cardinal="70">Septante-</word>
							<word ordinal="70">Septantième </word>
							<word cardinal="80">Huitante-</word>
							<word ordinal="80">Huitantième </word>
							<word cardinal="90">Nonante-</word>
							<word ordinal="90">Nonantième </word>
							<word cardinal="100">Cent-</word>
							<word ordinal="100">Centième </word>
						</xsl:when>
						<xsl:when test="$lang = 'ru'">
							<word cardinal="1">Одна-</word>
							<word ordinal="1">Первое </word>
							<word cardinal="2">Две-</word>
							<word ordinal="2">Второе </word>
							<word cardinal="3">Три-</word>
							<word ordinal="3">Третье </word>
							<word cardinal="4">Четыре-</word>
							<word ordinal="4">Четвертое </word>
							<word cardinal="5">Пять-</word>
							<word ordinal="5">Пятое </word>
							<word cardinal="6">Шесть-</word>
							<word ordinal="6">Шестое </word>
							<word cardinal="7">Семь-</word>
							<word ordinal="7">Седьмое </word>
							<word cardinal="8">Восемь-</word>
							<word ordinal="8">Восьмое </word>
							<word cardinal="9">Девять-</word>
							<word ordinal="9">Девятое </word>
							<word ordinal="10">Десятое </word>
							<word ordinal="11">Одиннадцатое </word>
							<word ordinal="12">Двенадцатое </word>
							<word ordinal="13">Тринадцатое </word>
							<word ordinal="14">Четырнадцатое </word>
							<word ordinal="15">Пятнадцатое </word>
							<word ordinal="16">Шестнадцатое </word>
							<word ordinal="17">Семнадцатое </word>
							<word ordinal="18">Восемнадцатое </word>
							<word ordinal="19">Девятнадцатое </word>
							<word cardinal="20">Двадцать-</word>
							<word ordinal="20">Двадцатое </word>
							<word cardinal="30">Тридцать-</word>
							<word ordinal="30">Тридцатое </word>
							<word cardinal="40">Сорок-</word>
							<word ordinal="40">Сороковое </word>
							<word cardinal="50">Пятьдесят-</word>
							<word ordinal="50">Пятидесятое </word>
							<word cardinal="60">Шестьдесят-</word>
							<word ordinal="60">Шестидесятое </word>
							<word cardinal="70">Семьдесят-</word>
							<word ordinal="70">Семидесятое </word>
							<word cardinal="80">Восемьдесят-</word>
							<word ordinal="80">Восьмидесятое </word>
							<word cardinal="90">Девяносто-</word>
							<word ordinal="90">Девяностое </word>
							<word cardinal="100">Сто-</word>
							<word ordinal="100">Сотое </word>
						</xsl:when>
						<xsl:otherwise> <!-- default english -->
							<word cardinal="1">One-</word>
							<word ordinal="1">First </word>
							<word cardinal="2">Two-</word>
							<word ordinal="2">Second </word>
							<word cardinal="3">Three-</word>
							<word ordinal="3">Third </word>
							<word cardinal="4">Four-</word>
							<word ordinal="4">Fourth </word>
							<word cardinal="5">Five-</word>
							<word ordinal="5">Fifth </word>
							<word cardinal="6">Six-</word>
							<word ordinal="6">Sixth </word>
							<word cardinal="7">Seven-</word>
							<word ordinal="7">Seventh </word>
							<word cardinal="8">Eight-</word>
							<word ordinal="8">Eighth </word>
							<word cardinal="9">Nine-</word>
							<word ordinal="9">Ninth </word>
							<word ordinal="10">Tenth </word>
							<word ordinal="11">Eleventh </word>
							<word ordinal="12">Twelfth </word>
							<word ordinal="13">Thirteenth </word>
							<word ordinal="14">Fourteenth </word>
							<word ordinal="15">Fifteenth </word>
							<word ordinal="16">Sixteenth </word>
							<word ordinal="17">Seventeenth </word>
							<word ordinal="18">Eighteenth </word>
							<word ordinal="19">Nineteenth </word>
							<word cardinal="20">Twenty-</word>
							<word ordinal="20">Twentieth </word>
							<word cardinal="30">Thirty-</word>
							<word ordinal="30">Thirtieth </word>
							<word cardinal="40">Forty-</word>
							<word ordinal="40">Fortieth </word>
							<word cardinal="50">Fifty-</word>
							<word ordinal="50">Fiftieth </word>
							<word cardinal="60">Sixty-</word>
							<word ordinal="60">Sixtieth </word>
							<word cardinal="70">Seventy-</word>
							<word ordinal="70">Seventieth </word>
							<word cardinal="80">Eighty-</word>
							<word ordinal="80">Eightieth </word>
							<word cardinal="90">Ninety-</word>
							<word ordinal="90">Ninetieth </word>
							<word cardinal="100">Hundred-</word>
							<word ordinal="100">Hundredth </word>
						</xsl:otherwise>
					</xsl:choose>
				</words>
			</xsl:variable>

			<xsl:variable name="ordinal" select="xalan:nodeset($words)//word[@ordinal = $number]/text()"/>
			
			<xsl:variable name="value">
				<xsl:choose>
					<xsl:when test="$ordinal != ''">
						<xsl:value-of select="$ordinal"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="$number &lt; 100">
								<xsl:variable name="decade" select="concat(substring($number,1,1), '0')"/>
								<xsl:variable name="digit" select="substring($number,2)"/>
								<xsl:value-of select="xalan:nodeset($words)//word[@cardinal = $decade]/text()"/>
								<xsl:value-of select="xalan:nodeset($words)//word[@ordinal = $digit]/text()"/>
							</xsl:when>
							<xsl:otherwise>
								<!-- more 100 -->
								<xsl:variable name="hundred" select="substring($number,1,1)"/>
								<xsl:variable name="digits" select="number(substring($number,2))"/>
								<xsl:value-of select="xalan:nodeset($words)//word[@cardinal = $hundred]/text()"/>
								<xsl:value-of select="xalan:nodeset($words)//word[@cardinal = '100']/text()"/>
								<xsl:call-template name="number-to-words">
									<xsl:with-param name="number" select="$digits"/>
								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="$first = 'true'">
					<xsl:variable name="value_lc" select="java:toLowerCase(java:java.lang.String.new($value))"/>
					<xsl:call-template name="capitalize">
						<xsl:with-param name="str" select="$value_lc"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$value"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template><xsl:template name="number-to-ordinal">
		<xsl:param name="number"/>
		<xsl:param name="curr_lang"/>
		<xsl:choose>
			<xsl:when test="$curr_lang = 'fr'">
				<xsl:choose>					
					<xsl:when test="$number = '1'">re</xsl:when>
					<xsl:otherwise>e</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$number = 1">st</xsl:when>
					<xsl:when test="$number = 2">nd</xsl:when>
					<xsl:when test="$number = 3">rd</xsl:when>
					<xsl:otherwise>th</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="setAltText">
		<xsl:param name="value"/>
		<xsl:attribute name="fox:alt-text">
			<xsl:choose>
				<xsl:when test="normalize-space($value) != ''">
					<xsl:value-of select="$value"/>
				</xsl:when>
				<xsl:otherwise>_</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
	</xsl:template><xsl:template name="substring-after-last">	
		<xsl:param name="value"/>
		<xsl:param name="delimiter"/>
		<xsl:choose>
			<xsl:when test="contains($value, $delimiter)">
				<xsl:call-template name="substring-after-last">
					<xsl:with-param name="value" select="substring-after($value, $delimiter)"/>
					<xsl:with-param name="delimiter" select="$delimiter"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$value"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template match="*" mode="print_as_xml">
		<xsl:param name="level">0</xsl:param>

		<fo:block margin-left="{2*$level}mm">
			<xsl:text>
&lt;</xsl:text>
			<xsl:value-of select="local-name()"/>
			<xsl:for-each select="@*">
				<xsl:text> </xsl:text>
				<xsl:value-of select="local-name()"/>
				<xsl:text>="</xsl:text>
				<xsl:value-of select="."/>
				<xsl:text>"</xsl:text>
			</xsl:for-each>
			<xsl:text>&gt;</xsl:text>
			
			<xsl:if test="not(*)">
				<fo:inline font-weight="bold"><xsl:value-of select="."/></fo:inline>
				<xsl:text>&lt;/</xsl:text>
					<xsl:value-of select="local-name()"/>
					<xsl:text>&gt;</xsl:text>
			</xsl:if>
		</fo:block>
		
		<xsl:if test="*">
			<fo:block>
				<xsl:apply-templates mode="print_as_xml">
					<xsl:with-param name="level" select="$level + 1"/>
				</xsl:apply-templates>
			</fo:block>
			<fo:block margin-left="{2*$level}mm">
				<xsl:text>&lt;/</xsl:text>
				<xsl:value-of select="local-name()"/>
				<xsl:text>&gt;</xsl:text>
			</fo:block>
		</xsl:if>
	</xsl:template></xsl:stylesheet>