<?xml version="1.0" encoding="UTF-8"?><xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:iso="https://www.metanorma.org/ns/iso" xmlns:mathml="http://www.w3.org/1998/Math/MathML" xmlns:xalan="http://xml.apache.org/xalan" xmlns:fox="http://xmlgraphics.apache.org/fop/extensions" xmlns:java="http://xml.apache.org/xalan/java" exclude-result-prefixes="java" version="1.0">

	<xsl:output method="xml" encoding="UTF-8" indent="no"/>
	
	<xsl:param name="svg_images"/>
	<xsl:variable name="images" select="document($svg_images)"/>
	
	

	<xsl:key name="kfn" match="iso:p/iso:fn" use="@reference"/>
	
	
	
	<xsl:variable name="debug">false</xsl:variable>
	<xsl:variable name="pageWidth" select="'210mm'"/>
	<xsl:variable name="pageHeight" select="'297mm'"/>

	<xsl:variable name="copyrightText" select="concat('© ISO ', iso:iso-standard/iso:bibdata/iso:copyright/iso:from ,' – All rights reserved')"/>
  
	<xsl:variable name="lang-1st-letter_tmp" select="substring-before(substring-after(/iso:iso-standard/iso:bibdata/iso:docidentifier[@type = 'iso-with-lang'], '('), ')')"/>
	<xsl:variable name="lang-1st-letter" select="concat('(', $lang-1st-letter_tmp , ')')"/>
  
	<!-- <xsl:variable name="ISOname" select="concat(/iso:iso-standard/iso:bibdata/iso:docidentifier, ':', /iso:iso-standard/iso:bibdata/iso:copyright/iso:from , $lang-1st-letter)"/> -->
	<xsl:variable name="ISOname" select="/iso:iso-standard/iso:bibdata/iso:docidentifier[@type = 'iso-reference']"/>

	<!-- Information and documentation — Codes for transcription systems  -->
	<xsl:variable name="title-en" select="/iso:iso-standard/iso:bibdata/iso:title[@language = 'en' and @type = 'main']"/>
	<xsl:variable name="title-fr" select="/iso:iso-standard/iso:bibdata/iso:title[@language = 'fr' and @type = 'main']"/>
	<xsl:variable name="title-intro" select="/iso:iso-standard/iso:bibdata/iso:title[@language = 'en' and @type = 'title-intro']"/>
	<xsl:variable name="title-intro-fr" select="/iso:iso-standard/iso:bibdata/iso:title[@language = 'fr' and @type = 'title-intro']"/>
	<xsl:variable name="title-main" select="/iso:iso-standard/iso:bibdata/iso:title[@language = 'en' and @type = 'title-main']"/>
	<xsl:variable name="title-main-fr" select="/iso:iso-standard/iso:bibdata/iso:title[@language = 'fr' and @type = 'title-main']"/>
	<xsl:variable name="part" select="/iso:iso-standard/iso:bibdata/iso:ext/iso:structuredidentifier/iso:project-number/@part"/>
	<xsl:variable name="title-part" select="/iso:iso-standard/iso:bibdata/iso:title[@language = 'en' and @type = 'title-part']"/>
	<xsl:variable name="title-part-fr" select="/iso:iso-standard/iso:bibdata/iso:title[@language = 'fr' and @type = 'title-part']"/>

	<xsl:variable name="doctype_uppercased" select="translate(translate(/iso:iso-standard/iso:bibdata/iso:ext/iso:doctype,'-',' '), $lower,$upper)"/>
	
	<xsl:variable name="stage" select="number(/iso:iso-standard/iso:bibdata/iso:status/iso:stage)"/>
	<xsl:variable name="substage" select="number(/iso:iso-standard/iso:bibdata/iso:status/iso:substage)"/>	
	<xsl:variable name="stagename" select="normalize-space(/iso:iso-standard/iso:bibdata/iso:ext/iso:stagename)"/>
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
			<xsl:when test="$stagename != ''">
				<xsl:value-of select="translate($stagename, $lower, $upper)"/>
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

	<xsl:variable name="title-figure">
		<xsl:text>Figure </xsl:text>
	</xsl:variable>
	
	<!-- Example:
		<item level="1" id="Foreword" display="true">Foreword</item>
		<item id="term-script" display="false">3.2</item>
	-->
	<xsl:variable name="contents">
		<contents>
			<xsl:apply-templates select="/iso:iso-standard/iso:preface/node()" mode="contents"/>
				<!-- <xsl:with-param name="sectionNum" select="'0'"/>
			</xsl:apply-templates> -->
			<xsl:apply-templates select="/iso:iso-standard/iso:sections/iso:clause[1]" mode="contents"> <!-- [@id = '_scope'] -->
				<xsl:with-param name="sectionNum" select="'1'"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="/iso:iso-standard/iso:bibliography/iso:references[1]" mode="contents"> <!-- [@id = '_normative_references'] -->
				<xsl:with-param name="sectionNum" select="'2'"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="/iso:iso-standard/iso:sections/*[position() &gt; 1]" mode="contents"> <!-- @id != '_scope' -->
				<xsl:with-param name="sectionNumSkew" select="'1'"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="/iso:iso-standard/iso:annex" mode="contents"/>
			<xsl:apply-templates select="/iso:iso-standard/iso:bibliography/iso:references[position() &gt; 1]" mode="contents"/> <!-- @id = '_bibliography' -->
			
			<xsl:apply-templates select="//iso:figure" mode="contents"/>
			
			<xsl:apply-templates select="//iso:table" mode="contents"/>
			
		</contents>
	</xsl:variable>
	
	<xsl:variable name="lang">
		<xsl:call-template name="getLang"/>
	</xsl:variable>
	
	<xsl:template match="/">
		<xsl:message>INFO: Document namespace: '<xsl:value-of select="namespace-uri(/*)"/>'</xsl:message>
		<fo:root font-family="Cambria, Times New Roman, Cambria Math, HanSans" font-size="11pt" xml:lang="{$lang}"> <!--   -->
			<fo:layout-master-set>
				
				<!-- cover page -->
				<fo:simple-page-master master-name="cover-page" page-width="{$pageWidth}" page-height="{$pageHeight}">
					<fo:region-body margin-top="25.4mm" margin-bottom="25.4mm" margin-left="31.7mm" margin-right="31.7mm"/>
					<fo:region-before region-name="cover-page-header" extent="25.4mm"/>
					<fo:region-after/>
					<fo:region-start region-name="cover-left-region" extent="31.7mm"/>
					<fo:region-end region-name="cover-right-region" extent="31.7mm"/>
				</fo:simple-page-master>
				
				<fo:simple-page-master master-name="cover-page-published" page-width="{$pageWidth}" page-height="{$pageHeight}">
					<fo:region-body margin-top="12.7mm" margin-bottom="40mm" margin-left="78mm" margin-right="18.5mm"/>
					<fo:region-before region-name="cover-page-header" extent="12.7mm"/>
					<fo:region-after region-name="cover-page-footer" extent="40mm" display-align="after"/>
					<fo:region-start region-name="cover-left-region" extent="78mm"/>
					<fo:region-end region-name="cover-right-region" extent="18.5mm"/>
				</fo:simple-page-master>
				
				
				<fo:simple-page-master master-name="cover-page-publishedISO-odd" page-width="{$pageWidth}" page-height="{$pageHeight}">
					<fo:region-body margin-top="12.7mm" margin-bottom="40mm" margin-left="25mm" margin-right="12.5mm"/>
					<fo:region-before region-name="cover-page-header" extent="12.7mm"/>
					<fo:region-after region-name="cover-page-footer" extent="40mm" display-align="after"/>
					<fo:region-start region-name="cover-left-region" extent="25mm"/>
					<fo:region-end region-name="cover-right-region" extent="12.5mm"/>
				</fo:simple-page-master>
				<fo:simple-page-master master-name="cover-page-publishedISO-even" page-width="{$pageWidth}" page-height="{$pageHeight}">
					<fo:region-body margin-top="12.7mm" margin-bottom="40mm" margin-left="12.5mm" margin-right="25mm"/>
					<fo:region-before region-name="cover-page-header" extent="12.7mm"/>
					<fo:region-after region-name="cover-page-footer" extent="40mm" display-align="after"/>
					<fo:region-start region-name="cover-left-region" extent="12.5mm"/>
					<fo:region-end region-name="cover-right-region" extent="25mm"/>
				</fo:simple-page-master>
				<fo:page-sequence-master master-name="cover-page-publishedISO">
					<fo:repeatable-page-master-alternatives>
						<fo:conditional-page-master-reference odd-or-even="even" master-reference="cover-page-publishedISO-even"/>
						<fo:conditional-page-master-reference odd-or-even="odd" master-reference="cover-page-publishedISO-odd"/>
					</fo:repeatable-page-master-alternatives>
				</fo:page-sequence-master>


				<!-- contents pages -->
				<!-- odd pages -->
				<fo:simple-page-master master-name="odd" page-width="{$pageWidth}" page-height="{$pageHeight}">
					<fo:region-body margin-top="27.4mm" margin-bottom="13mm" margin-left="19mm" margin-right="19mm"/>
					<fo:region-before region-name="header-odd" extent="27.4mm"/> <!--   display-align="center" -->
					<fo:region-after region-name="footer-odd" extent="13mm"/>
					<fo:region-start region-name="left-region" extent="19mm"/>
					<fo:region-end region-name="right-region" extent="19mm"/>
				</fo:simple-page-master>
				<!-- even pages -->
				<fo:simple-page-master master-name="even" page-width="{$pageWidth}" page-height="{$pageHeight}">
					<fo:region-body margin-top="27.4mm" margin-bottom="13mm" margin-left="19mm" margin-right="19mm"/>
					<fo:region-before region-name="header-even" extent="27.4mm"/> <!--   display-align="center" -->
					<fo:region-after region-name="footer-even" extent="13mm"/>
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
				<fo:simple-page-master master-name="first-publishedISO" page-width="{$pageWidth}" page-height="{$pageHeight}">
					<fo:region-body margin-top="27.4mm" margin-bottom="13mm" margin-left="25mm" margin-right="12.5mm"/>
					<fo:region-before region-name="header-first" extent="27.4mm"/> <!--   display-align="center" -->
					<fo:region-after region-name="footer-odd" extent="13mm"/>
					<fo:region-start region-name="left-region" extent="25mm"/>
					<fo:region-end region-name="right-region" extent="12.5mm"/>
				</fo:simple-page-master>
				<!-- odd pages -->
				<fo:simple-page-master master-name="odd-publishedISO" page-width="{$pageWidth}" page-height="{$pageHeight}">
					<fo:region-body margin-top="27.4mm" margin-bottom="13mm" margin-left="25mm" margin-right="12.5mm"/>
					<fo:region-before region-name="header-odd" extent="27.4mm"/> <!--   display-align="center" -->
					<fo:region-after region-name="footer-odd" extent="13mm"/>
					<fo:region-start region-name="left-region" extent="25mm"/>
					<fo:region-end region-name="right-region" extent="12.5mm"/>
				</fo:simple-page-master>
				<!-- even pages -->
				<fo:simple-page-master master-name="even-publishedISO" page-width="{$pageWidth}" page-height="{$pageHeight}">
					<fo:region-body margin-top="27.4mm" margin-bottom="13mm" margin-left="12.5mm" margin-right="25mm"/>
					<fo:region-before region-name="header-even" extent="27.4mm"/>
					<fo:region-after region-name="footer-even" extent="13mm"/>
					<fo:region-start region-name="left-region" extent="12.5mm"/>
					<fo:region-end region-name="right-region" extent="25mm"/>
				</fo:simple-page-master>
				<fo:simple-page-master master-name="blankpage" page-width="{$pageWidth}" page-height="{$pageHeight}">
					<fo:region-body margin-top="27.4mm" margin-bottom="13mm" margin-left="12.5mm" margin-right="25mm"/>
					<fo:region-before region-name="header" extent="27.4mm"/>
					<fo:region-after region-name="footer" extent="13mm"/>
					<fo:region-start region-name="left" extent="12.5mm"/>
					<fo:region-end region-name="right" extent="25mm"/>
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
				
				<fo:simple-page-master master-name="last-page" page-width="{$pageWidth}" page-height="{$pageHeight}">
					<fo:region-body margin-top="27.4mm" margin-bottom="13mm" margin-left="12.5mm" margin-right="25mm"/>
					<fo:region-before region-name="header-even" extent="27.4mm"/>
					<fo:region-after region-name="last-page-footer" extent="13mm"/>
					<fo:region-start region-name="left-region" extent="12.5mm"/>
					<fo:region-end region-name="right-region" extent="25mm"/>
				</fo:simple-page-master>
				
			</fo:layout-master-set>

			<fo:declarations>
				<pdf:catalog xmlns:pdf="http://xmlgraphics.apache.org/fop/extensions/pdf">
						<pdf:dictionary type="normal" key="ViewerPreferences">
							<pdf:boolean key="DisplayDocTitle">true</pdf:boolean>
						</pdf:dictionary>
					</pdf:catalog>
				<x:xmpmeta xmlns:x="adobe:ns:meta/">
					<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
						<rdf:Description xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:pdf="http://ns.adobe.com/pdf/1.3/" rdf:about="">
						<!-- Dublin Core properties go here -->
							<dc:title><xsl:value-of select="$title-en"/></dc:title>
							<dc:creator><xsl:value-of select="/iso:iso-standard/iso:bibdata/iso:contributor[iso:role/@type='author']/iso:organization/iso:name"/></dc:creator>
							<dc:description>
								<xsl:variable name="abstract">
									<xsl:copy-of select="/iso:iso-standard/iso:bibliography/iso:references/iso:bibitem/iso:abstract//text()"/>
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
			</fo:declarations>
			
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
										<fo:table-cell font-size="6.5pt" text-align="justify" display-align="after" padding-bottom="8mm"><!-- before -->
											<!-- margin-top="-30mm"  -->
											<fo:block margin-top="-100mm">
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
										<fo:table-cell>
											<xsl:if test="$stage-abbreviation = 'DIS'">
												<fo:block-container margin-top="-15mm" margin-bottom="7mm" margin-left="1mm">
													<fo:block font-size="9pt" border="0.5pt solid black" fox:border-radius="5pt" padding-left="2mm" padding-top="2mm" padding-bottom="2mm">
														<xsl:text>This document is circulated as received from the committee secretariat.</xsl:text>
													</fo:block>
												</fo:block-container>
											</xsl:if>
											<fo:block>
												<fo:table table-layout="fixed" width="100%" border-top="1mm double black" margin-bottom="3mm">
													<fo:table-column column-width="50%"/>
													<fo:table-column column-width="50%"/>
													<fo:table-body>
														<fo:table-row height="34mm">
															<fo:table-cell display-align="center">
																<fo:block text-align="left" margin-top="2mm">
																	<xsl:variable name="docid" select="substring-before(/iso:iso-standard/iso:bibdata/iso:docidentifier, ' ')"/>
																	<xsl:for-each select="xalan:tokenize($docid, '/')">
																		<xsl:choose>
																			<xsl:when test=". = 'ISO'">
																				<fo:external-graphic src="{concat('data:image/png;base64,', normalize-space($Image-ISO-Logo))}" width="21mm" content-height="21mm" content-width="scale-to-fit" scaling="uniform" fox:alt-text="Image {@alt}"/>
																			</xsl:when>
																			<xsl:when test=". = 'IEC'">
																				<fo:external-graphic src="{concat('data:image/png;base64,', normalize-space($Image-IEC-Logo))}" width="19.8mm" content-height="19.8mm" content-width="scale-to-fit" scaling="uniform" fox:alt-text="Image {@alt}"/>
																			</xsl:when>
																			<xsl:otherwise/>
																		</xsl:choose>
																		<xsl:if test="position() != last()">
																			<fo:inline padding-right="1mm"> </fo:inline>
																		</xsl:if>
																	</xsl:for-each>
																</fo:block>
															</fo:table-cell>
															<fo:table-cell display-align="center">
																<fo:block text-align="right">
																	<fo:block>Reference number</fo:block>
																	<fo:block>
																		<xsl:value-of select="$ISOname"/>																		
																	</fo:block>
																	<fo:block> </fo:block>
																	<fo:block> </fo:block>
																	<fo:block><fo:inline font-size="9pt">©</fo:inline><xsl:value-of select="concat(' ISO ', iso:iso-standard/iso:bibdata/iso:copyright/iso:from)"/></fo:block>
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
											<xsl:value-of select="/iso:iso-standard/iso:bibdata/iso:docidentifier[@type = 'iso']"/>
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
														<fo:block margin-bottom="3mm">ISO/TC <fo:inline font-weight="bold"><xsl:value-of select="/iso:iso-standard/iso:bibdata/iso:ext/iso:editorialgroup/iso:technical-committee/@number"/></fo:inline>
														</fo:block>
													</fo:table-cell>
													<fo:table-cell>
														<fo:block>Secretariat: <fo:inline font-weight="bold"><xsl:value-of select="/iso:iso-standard/iso:bibdata/iso:ext/iso:editorialgroup/iso:secretariat"/></fo:inline></fo:block>
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
										
										<fo:block-container border-top="1mm double black" line-height="1.1" margin-top="3mm">
											<fo:block margin-right="5mm">
												<fo:block font-size="18pt" font-weight="bold" margin-top="6pt">
													<xsl:if test="normalize-space($title-intro) != ''">
														<xsl:value-of select="$title-intro"/>
														<xsl:text> — </xsl:text>
													</xsl:if>
													
													<xsl:value-of select="$title-main"/>
													
													<xsl:if test="normalize-space($title-part) != ''">
														<xsl:if test="$part != ''">
															<xsl:text> — </xsl:text>
															<fo:block font-weight="normal" margin-top="6pt">
																<xsl:text>Part </xsl:text><xsl:value-of select="$part"/>
																<xsl:text>:</xsl:text>
															</fo:block>
														</xsl:if>
														<xsl:value-of select="$title-part"/>
													</xsl:if>
												</fo:block>
															
												<fo:block font-size="9pt"><xsl:value-of select="$linebreak"/></fo:block>
												<fo:block font-size="11pt" font-style="italic" line-height="1.5">
													
													<xsl:if test="normalize-space($title-intro-fr) != ''">
														<xsl:value-of select="$title-intro-fr"/>
														<xsl:text> — </xsl:text>
													</xsl:if>
													
													<xsl:value-of select="$title-main-fr"/>
													
													<xsl:if test="normalize-space($title-part-fr) != ''">
														<xsl:if test="$part != ''">
															<xsl:text> — </xsl:text>
															<xsl:text>Partie </xsl:text>
															<xsl:value-of select="$part"/>
															<xsl:text>:</xsl:text>
														</xsl:if>
														<xsl:value-of select="$title-part-fr"/>
													</xsl:if>
												</fo:block>
											</fo:block>
											<fo:block margin-top="10mm">
												<xsl:for-each select="/iso:iso-standard/iso:bibdata/iso:ext/iso:ics/iso:code">
													<xsl:if test="position() = 1"><fo:inline>ICS: </fo:inline></xsl:if>
													<xsl:value-of select="."/>
													<xsl:if test="position() != last()"><xsl:text>; </xsl:text></xsl:if>
												</xsl:for-each>
											</fo:block>
										</fo:block-container>
										
										
									</fo:block-container>
								</fo:flow>
							
							</xsl:when>
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
													<fo:table-cell>
														<fo:block text-align="left">
															<xsl:value-of select="$doctype_uppercased"/>
														</fo:block>
													</fo:table-cell>
													<fo:table-cell>
														<fo:block text-align="right" font-weight="bold" margin-bottom="13mm">
															<xsl:value-of select="/iso:iso-standard/iso:bibdata/iso:docidentifier[@type = 'iso']"/>
														</fo:block>
													</fo:table-cell>
												</fo:table-row>
												<fo:table-row height="42mm">
													<fo:table-cell number-columns-spanned="3" font-size="10pt" line-height="1.2">
														<fo:block text-align="right">
															<xsl:if test="$stage-abbreviation = 'PRF' or                          $stage-abbreviation = 'IS' or                          $stage-abbreviation = 'published'">
																<xsl:call-template name="printEdition"/>
															</xsl:if>
															<xsl:choose>
																<xsl:when test="$stage-abbreviation = 'IS'">
																	<xsl:value-of select="$linebreak"/>
																	<xsl:value-of select="/iso:iso-standard/iso:bibdata/iso:date[@type = 'published']"/>
																</xsl:when>
																<xsl:when test="$stage-abbreviation = 'published'">
																	<xsl:value-of select="$linebreak"/>
																	<xsl:value-of select="substring(/iso:iso-standard/iso:bibdata/iso:version/iso:revision-date,1, 7)"/>
																</xsl:when>
															</xsl:choose>
															<!-- <xsl:value-of select="$linebreak"/>
															<xsl:value-of select="/iso:iso-standard/iso:bibdata/iso:version/iso:revision-date"/> -->
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
																			<fo:block margin-bottom="8pt">ISO/TC <fo:inline font-weight="bold"><xsl:value-of select="/iso:iso-standard/iso:bibdata/iso:ext/iso:editorialgroup/iso:technical-committee/@number"/></fo:inline></fo:block>
																			<fo:block margin-bottom="6pt">Secretariat: <xsl:value-of select="/iso:iso-standard/iso:bibdata/iso:ext/iso:editorialgroup/iso:secretariat"/></fo:block>
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
														<fo:block-container border-top="1mm double black" line-height="1.1">
															<fo:block margin-right="5mm">
																<fo:block font-size="18pt" font-weight="bold" margin-top="12pt">
																	
																	<xsl:if test="normalize-space($title-intro) != ''">
																		<xsl:value-of select="$title-intro"/>
																		<xsl:text> — </xsl:text>
																	</xsl:if>
																	
																	<xsl:value-of select="$title-main"/>
																	
																	<xsl:if test="normalize-space($title-part) != ''">
																		<xsl:if test="$part != ''">
																			<xsl:text> — </xsl:text>
																			<fo:block font-weight="normal" margin-top="6pt">
																				<xsl:text>Part </xsl:text><xsl:value-of select="$part"/>
																				<xsl:text>:</xsl:text>
																			</fo:block>
																		</xsl:if>
																		<xsl:value-of select="$title-part"/>
																	</xsl:if>
																</fo:block>
																			
																<fo:block font-size="9pt"><xsl:value-of select="$linebreak"/></fo:block>
																<fo:block font-size="11pt" font-style="italic" line-height="1.5">
																	
																	<xsl:if test="normalize-space($title-intro-fr) != ''">
																		<xsl:value-of select="$title-intro-fr"/>
																		<xsl:text> — </xsl:text>
																	</xsl:if>
																	
																	<xsl:value-of select="$title-main-fr"/>
																	
																	<xsl:if test="normalize-space($title-part-fr) != ''">
																		<xsl:if test="$part != ''">
																			<xsl:text> — </xsl:text>
																			<xsl:text>Partie </xsl:text>
																			<xsl:value-of select="$part"/>
																			<xsl:text>:</xsl:text>
																		</xsl:if>
																		<xsl:value-of select="$title-part-fr"/>
																	</xsl:if>
																</fo:block>
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
							<fo:table table-layout="fixed" width="100%" border-top="1mm double black" margin-bottom="3mm">
								<fo:table-column column-width="50%"/>
								<fo:table-column column-width="50%"/>
								<fo:table-body>
									<fo:table-row height="32mm">
										<fo:table-cell display-align="center">
											<fo:block text-align="left">
												<fo:external-graphic src="{concat('data:image/png;base64,', normalize-space($Image-ISO-Logo2))}" width="21mm" content-height="21mm" content-width="scale-to-fit" scaling="uniform" fox:alt-text="Image {@alt}"/>
											</fo:block>
										</fo:table-cell>
										<fo:table-cell display-align="center">
											<fo:block text-align="right">
												<fo:block>Reference number</fo:block>
												<fo:block><xsl:value-of select="$ISOname"/></fo:block>
												<fo:block> </fo:block>
												<fo:block> </fo:block>
												<fo:block><fo:inline font-size="9pt">©</fo:inline><xsl:value-of select="concat(' ISO ', iso:iso-standard/iso:bibdata/iso:copyright/iso:from)"/></fo:block>
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
													<xsl:value-of select="/iso:iso-standard/iso:bibdata/iso:docidentifier[@type = 'iso']"/>
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
								
								<fo:block-container border-top="1mm double black" line-height="1.1">
									<fo:block margin-right="40mm">
									<fo:block font-size="18pt" font-weight="bold" margin-top="12pt">
									
										<xsl:if test="normalize-space($title-intro) != ''">
											<xsl:value-of select="$title-intro"/>
											<xsl:text> — </xsl:text>
										</xsl:if>
										
										<xsl:value-of select="$title-main"/>
										
										<xsl:if test="normalize-space($title-part) != ''">
											<xsl:if test="$part != ''">
												<xsl:text> — </xsl:text>
												<fo:block font-weight="normal" margin-top="6pt">
													<xsl:text>Part </xsl:text><xsl:value-of select="$part"/>
													<xsl:text>:</xsl:text>
												</fo:block>
											</xsl:if>
											<xsl:value-of select="$title-part"/>
										</xsl:if>
									</fo:block>
												
									<fo:block font-size="9pt"><xsl:value-of select="$linebreak"/></fo:block>
									<fo:block font-size="11pt" font-style="italic" line-height="1.5">
										
										<xsl:if test="normalize-space($title-intro-fr) != ''">
											<xsl:value-of select="$title-intro-fr"/>
											<xsl:text> — </xsl:text>
										</xsl:if>
										
										<xsl:value-of select="$title-main-fr"/>

										<xsl:if test="normalize-space($title-part-fr) != ''">
											<xsl:if test="$part != ''">
												<xsl:text> — </xsl:text>
												<xsl:text>Partie </xsl:text>
												<xsl:value-of select="$part"/>
												<xsl:text>:</xsl:text>
											</xsl:if>
											<xsl:value-of select="$title-part-fr"/>
										</xsl:if>
									</fo:block>
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
								
								<!-- ISO/TC 46/WG 3  -->
										<!-- <fo:block margin-bottom="12pt">
											<xsl:value-of select="concat('ISO/', /iso:iso-standard/iso:bibdata/iso:ext/iso:editorialgroup/iso:technical-committee/@type, ' ',
																																				/iso:iso-standard/iso:bibdata/iso:ext/iso:editorialgroup/iso:technical-committee/@number, '/', 
																																				/iso:iso-standard/iso:bibdata/iso:ext/iso:editorialgroup/iso:workgroup/@type, ' ',
																																				/iso:iso-standard/iso:bibdata/iso:ext/iso:editorialgroup/iso:workgroup/@number)"/>
								 -->
								<!-- ISO/TC 34/SC 4/WG 3 -->
								<fo:block margin-bottom="12pt">
									<xsl:text>ISO</xsl:text>
									<xsl:for-each select="/iso:iso-standard/iso:bibdata/iso:ext/iso:editorialgroup/iso:technical-committee[@number]">
										<xsl:text>/TC </xsl:text><xsl:value-of select="@number"/>
									</xsl:for-each>
									<xsl:for-each select="/iso:iso-standard/iso:bibdata/iso:ext/iso:editorialgroup/iso:subcommittee[@number]">
										<xsl:text>/SC </xsl:text>
										<xsl:value-of select="@number"/>
									</xsl:for-each>
									<xsl:for-each select="/iso:iso-standard/iso:bibdata/iso:ext/iso:editorialgroup/iso:workgroup[@number]">
										<xsl:text>/WG </xsl:text>
										<xsl:value-of select="@number"/>
									</xsl:for-each>
								</fo:block>
								
								<!-- Secretariat: AFNOR  -->
								
								<fo:block margin-bottom="100pt">
									<xsl:text>Secretariat: </xsl:text>
									<xsl:value-of select="/iso:iso-standard/iso:bibdata/iso:ext/iso:editorialgroup/iso:secretariat"/>
									<xsl:text> </xsl:text>
								</fo:block>
									
								
								
								</fo:block-container>
							<fo:block-container font-size="16pt">
								<!-- Information and documentation — Codes for transcription systems  -->
									<fo:block font-weight="bold">
									
										<xsl:if test="normalize-space($title-intro) != ''">
											<xsl:value-of select="$title-intro"/>
											<xsl:text> — </xsl:text>
										</xsl:if>
										
										<xsl:value-of select="$title-main"/>
										
										<xsl:if test="normalize-space($title-part) != ''">
											<xsl:if test="$part != ''">
												<xsl:text> — </xsl:text>
												<fo:block font-weight="normal" margin-top="6pt">
													<xsl:text>Part </xsl:text><xsl:value-of select="$part"/>
													<xsl:text>:</xsl:text>
												</fo:block>
											</xsl:if>
											<xsl:value-of select="$title-part"/>
										</xsl:if>
									</fo:block>
									
									<fo:block font-size="12pt"><xsl:value-of select="$linebreak"/></fo:block>
									<fo:block>
										<xsl:if test="normalize-space($title-intro-fr) != ''">
											<xsl:value-of select="$title-intro-fr"/>
											<xsl:text> — </xsl:text>
										</xsl:if>
										
										<xsl:value-of select="$title-main-fr"/>
										
										<xsl:if test="normalize-space($title-part-fr) != ''">
											<xsl:if test="$part != ''">
												<xsl:text> — </xsl:text>
												<fo:block margin-top="6pt" font-weight="normal">
													<xsl:text>Partie </xsl:text><xsl:value-of select="$part"/>
													<xsl:text>:</xsl:text>
												</fo:block>
											</xsl:if>
											<xsl:value-of select="$title-part-fr"/>
										</xsl:if>
									</fo:block>
							</fo:block-container>
							<fo:block font-size="11pt" margin-bottom="8pt"><xsl:value-of select="$linebreak"/></fo:block>
							<fo:block-container font-size="40pt" text-align="center" margin-bottom="12pt" border="0.5pt solid black">
								<xsl:variable name="stage-title" select="substring-after(substring-before(/iso:iso-standard/iso:bibdata/iso:docidentifier[@type = 'iso'], ' '), '/')"/>
								<fo:block padding-top="2mm"><xsl:value-of select="$stage-title"/><xsl:text> stage</xsl:text></fo:block>
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
			
			<fo:page-sequence master-reference="preface{$document-master-reference}" format="i" force-page-count="{$force-page-count-preface}">
				<xsl:call-template name="insertHeaderFooter">
					<xsl:with-param name="font-weight">normal</xsl:with-param>
				</xsl:call-template>
				<fo:flow flow-name="xsl-region-body" line-height="115%">
					<xsl:if test="/iso:iso-standard/iso:boilerplate/iso:copyright-statement">
					
						<fo:block-container height="252mm" display-align="after">
							<fo:block margin-bottom="3mm">
								<fo:external-graphic src="{concat('data:image/png;base64,', normalize-space($Image-Attention))}" width="14mm" content-height="13mm" content-width="scale-to-fit" scaling="uniform" fox:alt-text="Image {@alt}"/>
								<fo:inline padding-left="6mm" font-size="12pt" font-weight="bold">COPYRIGHT PROTECTED DOCUMENT</fo:inline>
							</fo:block>
							<fo:block line-height="90%">
								<fo:block font-size="9pt" text-align="justify">
									<xsl:apply-templates select="/iso:iso-standard/iso:boilerplate/iso:copyright-statement"/>
								</fo:block>
							</fo:block>
						</fo:block-container>
						<fo:block break-after="page"/>
					</xsl:if>
					
					<fo:block-container font-weight="bold">
						
						<fo:block text-align-last="justify" font-size="16pt" margin-top="10pt" margin-bottom="18pt">
							<fo:inline font-size="16pt" font-weight="bold">Contents</fo:inline>
							<fo:inline keep-together.within-line="always">
								<fo:leader leader-pattern="space"/>
								<fo:inline font-weight="normal" font-size="10pt">Page</fo:inline>
							</fo:inline>
						</fo:block>
						
						<xsl:if test="$debug = 'true'">
							<xsl:text disable-output-escaping="yes">&lt;!--</xsl:text>
								DEBUG
								contents=<xsl:copy-of select="xalan:nodeset($contents)"/>
							<xsl:text disable-output-escaping="yes">--&gt;</xsl:text>
						</xsl:if>
						
						<xsl:variable name="margin-left">12</xsl:variable>
						<xsl:for-each select="xalan:nodeset($contents)//item[@display = 'true'][not(@level = 2 and starts-with(@section, '0'))]"><!-- skip clause from preface -->
							
							<fo:block>
								<xsl:if test="@level = 1">
									<xsl:attribute name="margin-top">5pt</xsl:attribute>
								</xsl:if>
								<xsl:if test="@level = 3">
									<xsl:attribute name="margin-top">-0.7pt</xsl:attribute>
								</xsl:if>
								<fo:list-block>
									<xsl:attribute name="margin-left"><xsl:value-of select="$margin-left * (@level - 1)"/>mm</xsl:attribute>
									<xsl:if test="@level &gt;= 2">
										<xsl:attribute name="font-weight">normal</xsl:attribute>
									</xsl:if>
									<xsl:attribute name="provisional-distance-between-starts">
										<xsl:choose>
											<!-- skip 0 section without subsections -->
											<xsl:when test="@level &gt;= 3"><xsl:value-of select="$margin-left * 1.2"/>mm</xsl:when>
											<xsl:when test="@section != '' and not(@display-section = 'false')"><xsl:value-of select="$margin-left"/>mm</xsl:when>
											<xsl:otherwise>0mm</xsl:otherwise>
										</xsl:choose>
									</xsl:attribute>
									<fo:list-item>
										<fo:list-item-label end-indent="label-end()">
											<fo:block>
												<xsl:if test="@section and not(@display-section = 'false')"> <!-- output below   -->
													<xsl:value-of select="@section"/>
												</xsl:if>
											</fo:block>
										</fo:list-item-label>
											<fo:list-item-body start-indent="body-start()">
												<fo:block text-align-last="justify" margin-left="12mm" text-indent="-12mm">
													<fo:basic-link internal-destination="{@id}" fox:alt-text="{text()}">
														<xsl:if test="@section and @display-section = 'false'">
															<xsl:value-of select="@section"/><xsl:text> </xsl:text>
														</xsl:if>
														<xsl:if test="@addon != ''">
															<fo:inline font-weight="normal">(<xsl:value-of select="@addon"/>)</fo:inline>
														</xsl:if>
														<xsl:text> </xsl:text><xsl:value-of select="text()"/>
														<fo:inline keep-together.within-line="always">
															<fo:leader font-size="9pt" font-weight="normal" leader-pattern="dots"/>
															<fo:inline><fo:page-number-citation ref-id="{@id}"/></fo:inline>
														</fo:inline>
													</fo:basic-link>
												</fo:block>
											</fo:list-item-body>
									</fo:list-item>
								</fo:list-block>
							</fo:block>
							
						</xsl:for-each>
					</fo:block-container>
					<!-- Foreword, Introduction -->
					<xsl:apply-templates select="/iso:iso-standard/iso:preface/node()"/>
						
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
							<fo:block>
								<xsl:if test="normalize-space($title-intro) != ''">
									<xsl:value-of select="$title-intro"/>
									<xsl:text> — </xsl:text>
								</xsl:if>
								
								<xsl:value-of select="$title-main"/>
								
								<xsl:if test="normalize-space($title-part) != ''">
									<xsl:if test="$part != ''">
										<xsl:text> — </xsl:text>
										<fo:block font-weight="normal" margin-top="12pt" line-height="1.1">
											<xsl:text>Part </xsl:text><xsl:value-of select="$part"/>
											<xsl:text>:</xsl:text>
										</fo:block>
									</xsl:if>
								</xsl:if>
							</fo:block>
							<fo:block>
								<xsl:value-of select="$title-part"/>
							</fo:block>
						</fo:block>
					
						
					</fo:block-container>
					<!-- Clause(s) -->
					<fo:block>
						
						<xsl:apply-templates select="/iso:iso-standard/iso:sections/iso:clause[1]"> <!-- Scope -->
							<xsl:with-param name="sectionNum" select="'1'"/>
						</xsl:apply-templates>

						<!-- <fo:block space-before="27pt">&#xA0;</fo:block> -->
						 <!-- Normative references  -->
						<xsl:apply-templates select="/iso:iso-standard/iso:bibliography/iso:references[1]">
							<xsl:with-param name="sectionNum" select="'2'"/>
						</xsl:apply-templates>
						
						<!-- <fo:block space-before="18pt">&#xA0;</fo:block> -->
						 <!-- main sections -->
						<xsl:apply-templates select="/iso:iso-standard/iso:sections/*[position() &gt; 1]">
							<xsl:with-param name="sectionNumSkew" select="'1'"/>
						</xsl:apply-templates>
						
						<!-- Annex(s) -->
						<xsl:apply-templates select="/iso:iso-standard/iso:annex"/>
						
						<!-- Bibliography -->
						<xsl:apply-templates select="/iso:iso-standard/iso:bibliography/iso:references[position() &gt; 1]"/>
						
						<fo:block id="lastBlock" font-size="1pt"> </fo:block>
					</fo:block>
					
				</fo:flow>
			</fo:page-sequence>
			
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
							<fo:block-container border-top="1mm double black">
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
										<fo:inline font-weight="bold"><xsl:value-of select="$title-descriptors"/>: </fo:inline>
										<xsl:call-template name="insertKeywords">
											<xsl:with-param name="sorting">no</xsl:with-param>
										</xsl:call-template>
									</fo:block>
								</xsl:if>
								<fo:block font-size="9pt">Price based on <fo:page-number-citation ref-id="lastBlock"/> pages</fo:block>
							</fo:block-container>
						</fo:block-container>
					</fo:flow>
				</fo:page-sequence>
			</xsl:if>
		</fo:root>
	</xsl:template> 

	<!-- for pass the paremeter 'sectionNum' over templates, like 'tunnel' parameter in XSLT 2.0 -->
	<xsl:template match="node()">
		<xsl:param name="sectionNum"/>
		<xsl:param name="sectionNumSkew"/>
		<xsl:apply-templates>
			<xsl:with-param name="sectionNum" select="$sectionNum"/>
			<xsl:with-param name="sectionNumSkew" select="$sectionNumSkew"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<!-- ============================= -->
	<!-- CONTENTS                                       -->
	<!-- ============================= -->
	<xsl:template match="node()" mode="contents">
		<xsl:param name="sectionNum"/>
		<xsl:param name="sectionNumSkew"/>
		<xsl:apply-templates mode="contents">
			<xsl:with-param name="sectionNum" select="$sectionNum"/>
			<xsl:with-param name="sectionNumSkew" select="$sectionNumSkew"/>
		</xsl:apply-templates>
	</xsl:template>

	
	<!-- calculate main section number (1,2,3) and pass it deep into templates -->
	<!-- it's necessary, because there is itu:bibliography/itu:references from other section, but numbering should be sequental -->
	<xsl:template match="iso:iso-standard/iso:sections/*" mode="contents">
		<xsl:param name="sectionNum"/>
		<xsl:param name="sectionNumSkew" select="0"/>
		<xsl:variable name="sectionNum_">
			<xsl:choose>
				<xsl:when test="$sectionNum"><xsl:value-of select="$sectionNum"/></xsl:when>
				<xsl:when test="$sectionNumSkew != 0">
					<xsl:variable name="number"><xsl:number count="*"/></xsl:variable> <!-- iso:sections/iso:clause | iso:sections/iso:terms -->
					<xsl:value-of select="$number + $sectionNumSkew"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:number count="*"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:apply-templates mode="contents">
			<xsl:with-param name="sectionNum" select="$sectionNum_"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<!-- Any node with title element - clause, definition, annex,... -->
	<xsl:template match="iso:title | iso:preferred" mode="contents">
		<xsl:param name="sectionNum"/>
		<!-- sectionNum=<xsl:value-of select="$sectionNum"/> -->
		<xsl:variable name="id">
			<xsl:call-template name="getId"/>
		</xsl:variable>
		
		<xsl:variable name="level">
			<xsl:call-template name="getLevel"/>
		</xsl:variable>
		
		<xsl:variable name="section">
			<xsl:call-template name="getSection">
				<xsl:with-param name="sectionNum" select="$sectionNum"/>
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:variable name="display">
			<xsl:choose>
				<xsl:when test="ancestor::iso:bibitem">false</xsl:when>
				<xsl:when test="ancestor::iso:term">false</xsl:when>
				<xsl:when test="ancestor::iso:annex and $level &gt;= 2">false</xsl:when>
				<xsl:when test="$level &lt;= 3">true</xsl:when>
				<xsl:otherwise>false</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="display-section">
			<xsl:choose>
				<xsl:when test="ancestor::iso:annex">false</xsl:when>
				<xsl:otherwise>true</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="type">
			<xsl:value-of select="local-name(..)"/>
		</xsl:variable>

		<xsl:variable name="root">
			<xsl:choose>
				<xsl:when test="ancestor::iso:annex">annex</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<item id="{$id}" level="{$level}" section="{$section}" display-section="{$display-section}" display="{$display}" type="{$type}" root="{$root}">
			<xsl:attribute name="addon">
				<xsl:if test="local-name(..) = 'annex'"><xsl:value-of select="../@obligation"/></xsl:if>
			</xsl:attribute>
			<xsl:value-of select="."/>
		</item>
		
		<xsl:apply-templates mode="contents">
			<xsl:with-param name="sectionNum" select="$sectionNum"/>
		</xsl:apply-templates>
		
	</xsl:template>
	
	
	<xsl:template match="iso:figure" mode="contents">
		<item level="" id="{@id}" display="false">
			<xsl:attribute name="section">
				<xsl:call-template name="getFigureNumber"/>
				<!-- <xsl:text>Figure </xsl:text><xsl:number format="A.1-1" level="multiple" count="iso:annex | iso:figure"/> -->
			</xsl:attribute>
		</item>
	</xsl:template>
	
	
	<xsl:template match="iso:table" mode="contents">
		<xsl:param name="sectionNum"/>
		<xsl:variable name="annex-id" select="ancestor::iso:annex/@id"/>
		<item level="" id="{@id}" display="false" type="table">
			<xsl:attribute name="section">				
				<xsl:value-of select="$title-table"/>
				<xsl:call-template name="getTableNumber"/>
			</xsl:attribute>
			<xsl:value-of select="iso:name/text()"/>
		</item>
	</xsl:template>
	
	<xsl:template match="iso:formula" mode="contents">
		<item level="" id="{@id}" display="false">
			<xsl:attribute name="section">
				<xsl:text>Formula (</xsl:text><xsl:number format="A.1" level="multiple" count="iso:annex | iso:formula"/><xsl:text>)</xsl:text>
			</xsl:attribute>
		</item>
	</xsl:template>
	
	<xsl:template match="iso:li" mode="contents">
		<xsl:param name="sectionNum"/>
		<item level="" id="{@id}" display="false" type="li">
			<xsl:attribute name="section">
				<xsl:call-template name="getListItemFormat"/>
			</xsl:attribute>
			<xsl:attribute name="parent_section">
				<xsl:for-each select="ancestor::*[not(local-name() = 'p' or local-name() = 'ol')][1]">
					<xsl:call-template name="getSection">
						<xsl:with-param name="sectionNum" select="$sectionNum"/>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:attribute>
		</item>
		<xsl:apply-templates mode="contents">
			<xsl:with-param name="sectionNum" select="$sectionNum"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template name="getListItemFormat">
		<xsl:choose>
			<xsl:when test="local-name(..) = 'ul'">—</xsl:when> <!-- dash -->
			<xsl:otherwise> <!-- for ordered lists -->
				<xsl:choose>
					<xsl:when test="../@type = 'arabic'">
						<xsl:number format="a)"/>
					</xsl:when>
					<xsl:when test="../@type = 'alphabet'">
						<xsl:number format="a)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:number format="1."/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	
	<!-- ============================= -->
	<!-- ============================= -->
	
	
	<xsl:template match="iso:license-statement//iso:title">
		<fo:block text-align="center" font-weight="bold">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	
	<xsl:template match="iso:license-statement//iso:p">
		<fo:block margin-left="1.5mm" margin-right="1.5mm">
			<xsl:if test="following-sibling::iso:p">
				<xsl:attribute name="margin-top">6pt</xsl:attribute>
				<xsl:attribute name="margin-bottom">6pt</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	
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
	
	<xsl:template match="iso:copyright-statement//iso:p">
		<fo:block>
			<xsl:if test="preceding-sibling::iso:p">
				<!-- <xsl:attribute name="font-size">10pt</xsl:attribute> -->
			</xsl:if>
			<xsl:if test="following-sibling::iso:p">
				<!-- <xsl:attribute name="margin-bottom">12pt</xsl:attribute> -->
				<xsl:attribute name="margin-bottom">3pt</xsl:attribute>
			</xsl:if>
			<xsl:if test="contains(@id, 'address')"> <!-- not(following-sibling::iso:p) -->
				<!-- <xsl:attribute name="margin-left">7.1mm</xsl:attribute> -->
				<xsl:attribute name="margin-left">4mm</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	
	<!-- Foreword, Introduction -->
	<xsl:template match="iso:iso-standard/iso:preface/*">
		<fo:block break-after="page"/>
		<xsl:apply-templates/>
	</xsl:template>
	

	
	<!-- clause, terms, clause, ...-->
	<xsl:template match="iso:iso-standard/iso:sections/*">
		<xsl:param name="sectionNum"/>
		<xsl:param name="sectionNumSkew" select="0"/>
		<fo:block>
			<xsl:variable name="pos"><xsl:number count="*"/></xsl:variable> <!-- iso:sections/iso:clause | iso:sections/iso:terms | iso:sections/iso:definitions -->
			<xsl:if test="$pos &gt;= 2">
				<xsl:attribute name="space-before">18pt</xsl:attribute>
			</xsl:if>
			<!-- pos=<xsl:value-of select="$pos" /> -->
			<xsl:variable name="sectionNum_">
				<xsl:choose>
					<xsl:when test="$sectionNum"><xsl:value-of select="$sectionNum"/></xsl:when>
					<xsl:when test="$sectionNumSkew != 0">
						<xsl:variable name="number"><xsl:number count="*"/></xsl:variable> <!--iso:sections/iso:clause | iso:sections/iso:terms | iso:sections/iso:definitions -->
						<xsl:value-of select="$number + $sectionNumSkew"/>
					</xsl:when>
				</xsl:choose>
			</xsl:variable>
			<xsl:if test="not(iso:title)">
				<fo:block margin-top="3pt" margin-bottom="12pt">
					<xsl:value-of select="$sectionNum_"/><xsl:number format=".1 " level="multiple" count="iso:clause"/>
				</fo:block>
			</xsl:if>
			<xsl:apply-templates>
				<xsl:with-param name="sectionNum" select="$sectionNum_"/>
			</xsl:apply-templates>
		</fo:block>
	</xsl:template>
	

	
	<xsl:template match="iso:clause//iso:clause[not(iso:title)]">
		<xsl:param name="sectionNum"/>
		<xsl:variable name="section">
			<xsl:call-template name="getSection">
				<xsl:with-param name="sectionNum" select="$sectionNum"/>
			</xsl:call-template>
		</xsl:variable>
		
		<fo:block margin-top="3pt"><!-- margin-bottom="6pt" -->
			<fo:inline font-weight="bold" padding-right="3mm">
				<xsl:value-of select="$section"/><!-- <xsl:number format=".1 "  level="multiple" count="iso:clause/iso:clause" /> -->
			</fo:inline>
			<xsl:apply-templates>
				<xsl:with-param name="sectionNum" select="$sectionNum"/>
				<xsl:with-param name="inline" select="'true'"/>
			</xsl:apply-templates>
		</fo:block>
	</xsl:template>
	
	
	<xsl:template match="iso:title">
		<xsl:param name="sectionNum"/>
		
		<xsl:variable name="parent-name" select="local-name(..)"/>
		<xsl:variable name="references_num_current">
			<xsl:number level="any" count="iso:references"/>
		</xsl:variable>
		
		<xsl:variable name="id">
			<xsl:call-template name="getId"/>
		</xsl:variable>
		
		<xsl:variable name="level">
			<xsl:call-template name="getLevel"/>
		</xsl:variable>
		
		<xsl:variable name="section">
			<xsl:call-template name="getSection">
				<xsl:with-param name="sectionNum" select="$sectionNum"/>
			</xsl:call-template>
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
			<xsl:when test="$parent-name = 'annex'">
				<fo:block id="{$id}" font-size="16pt" font-weight="bold" text-align="center" margin-bottom="12pt" keep-with-next="always">
					<xsl:value-of select="$section"/>
					<xsl:if test=" ../@obligation">
						<xsl:value-of select="$linebreak"/>
						<fo:inline font-weight="normal">(<xsl:value-of select="../@obligation"/>)</fo:inline>
					</xsl:if>
					<fo:block margin-top="18pt" margin-bottom="48pt"><xsl:apply-templates/></fo:block>
				</fo:block>
			</xsl:when>
			<xsl:when test="$parent-name = 'references' and $references_num_current != 1"> <!-- Bibliography -->
				<fo:block id="{$id}" font-size="16pt" font-weight="bold" text-align="center" margin-top="6pt" margin-bottom="36pt" keep-with-next="always">
					<xsl:apply-templates/>
				</fo:block>
			</xsl:when>
			
			<xsl:otherwise>
				<xsl:element name="{$element-name}">
					<xsl:attribute name="id"><xsl:value-of select="$id"/></xsl:attribute>
					<xsl:attribute name="font-size"><xsl:value-of select="$font-size"/></xsl:attribute>
					<xsl:attribute name="font-weight">bold</xsl:attribute>
					<xsl:attribute name="margin-top"> <!-- margin-top -->
						<xsl:choose>
							<xsl:when test="ancestor::iso:preface">8pt</xsl:when>
							<xsl:when test="$level = 2 and ancestor::iso:annex">18pt</xsl:when>
							<xsl:when test="$level = 1">18pt</xsl:when>
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
					
					
						<!-- DEBUG level=<xsl:value-of select="$level"/>x -->
						<!-- section=<xsl:value-of select="$sectionNum"/> -->
						<!-- <xsl:if test="$sectionNum"> -->
						<xsl:value-of select="$section"/>
						<xsl:if test="$section != ''">
							<xsl:choose>
								<xsl:when test="$level = 2">
									<fo:inline padding-right="2mm"> </fo:inline>
								</xsl:when>
								<xsl:otherwise>
									<fo:inline padding-right="3mm"> </fo:inline>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:if>
				
						<xsl:apply-templates/>
				</xsl:element>
				
				<xsl:if test="$element-name = 'fo:inline' and not(following-sibling::iso:p)">
					<fo:block> <!-- margin-bottom="12pt" -->
						<xsl:value-of select="$linebreak"/>
					</fo:block>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	

	
	<xsl:template match="iso:p">
		<xsl:param name="inline" select="'false'"/>
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
			<xsl:apply-templates/>
		</xsl:element>
		<xsl:if test="$element-name = 'fo:inline' and not($inline = 'true') and not(local-name(..) = 'admonition')">
			<fo:block margin-bottom="12pt">
				 <xsl:if test="ancestor::iso:annex">
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
				<fo:inline white-space="pre"><xsl:value-of select="."/></fo:inline>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	
	<!--
	<fn reference="1">
			<p id="_8e5cf917-f75a-4a49-b0aa-1714cb6cf954">Formerly denoted as 15 % (m/m).</p>
		</fn>
	-->
	
	<xsl:variable name="p_fn">
		<xsl:for-each select="//iso:p/iso:fn[generate-id(.)=generate-id(key('kfn',@reference)[1])]">
			<!-- copy unique fn -->
			<fn gen_id="{generate-id(.)}">
				<xsl:copy-of select="@*"/>
				<xsl:copy-of select="node()"/>
			</fn>
		</xsl:for-each>
	</xsl:variable>
	
	<xsl:template match="iso:p/iso:fn" priority="2">
		<xsl:variable name="gen_id" select="generate-id(.)"/>
		<xsl:variable name="reference" select="@reference"/>
		<xsl:variable name="number">
			<!-- <xsl:number level="any" count="iso:p/iso:fn"/> -->
			<xsl:value-of select="count(xalan:nodeset($p_fn)//fn[@reference = $reference]/preceding-sibling::fn) + 1"/>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="xalan:nodeset($p_fn)//fn[@gen_id = $gen_id]">
				<fo:footnote>
					<fo:inline font-size="80%" keep-with-previous.within-line="always" vertical-align="super">
						<fo:basic-link internal-destination="footnote_{@reference}_{$number}" fox:alt-text="footnote {@reference} {$number}">
							<!-- <xsl:value-of select="@reference"/> -->
							<xsl:value-of select="$number + count(//iso:bibitem[ancestor::iso:references[@id='_normative_references']]/iso:note)"/><xsl:text>)</xsl:text>
						</fo:basic-link>
					</fo:inline>
					<fo:footnote-body>
						<fo:block font-size="10pt" margin-bottom="12pt">
							<fo:inline id="footnote_{@reference}_{$number}" keep-with-next.within-line="always" padding-right="3mm"> <!-- font-size="60%"  alignment-baseline="hanging" -->
								<xsl:value-of select="$number + count(//iso:bibitem[ancestor::iso:references[@id='_normative_references']]/iso:note)"/><xsl:text>)</xsl:text>
							</fo:inline>
							<xsl:for-each select="iso:p">
									<xsl:apply-templates/>
							</xsl:for-each>
						</fo:block>
					</fo:footnote-body>
				</fo:footnote>
			</xsl:when>
			<xsl:otherwise>
				<fo:inline font-size="60%" keep-with-previous.within-line="always" vertical-align="super">
					<fo:basic-link internal-destination="footnote_{@reference}_{$number}" fox:alt-text="footnote {@reference} {$number}">
						<xsl:value-of select="$number + count(//iso:bibitem/iso:note)"/>
					</fo:basic-link>
				</fo:inline>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="iso:p/iso:fn/iso:p">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="iso:review">
		<!-- comment 2019-11-29 -->
		<!-- <fo:block font-weight="bold">Review:</fo:block>
		<xsl:apply-templates /> -->
	</xsl:template>

	<xsl:template match="text()">
		<xsl:value-of select="."/>
	</xsl:template>

	<xsl:template match="iso:image">
		<fo:block-container text-align="center">
			<fo:block>
				<fo:external-graphic src="{@src}" fox:alt-text="Image {@alt}"/>
			</fo:block>
			<fo:block font-weight="bold" margin-top="12pt" margin-bottom="12pt">
				<xsl:value-of select="$title-figure"/>
				<xsl:call-template name="getFigureNumber"/>
			</fo:block>
		</fo:block-container>
	</xsl:template>

	<xsl:template match="iso:figure">
		<fo:block-container id="{@id}">
			<fo:block>
				<xsl:apply-templates/>
			</fo:block>
			<xsl:call-template name="fn_display_figure"/>
			<xsl:for-each select="iso:note//iso:p">
				<xsl:call-template name="note"/>
			</xsl:for-each>
			<fo:block font-weight="bold" text-align="center" margin-top="12pt" margin-bottom="12pt" keep-with-previous="always">
				<xsl:call-template name="getFigureNumber"/>
				<xsl:if test="iso:name">
					<xsl:if test="not(local-name(..) = 'figure')">
						<xsl:text> — </xsl:text>
					</xsl:if>
					<xsl:value-of select="iso:name"/>
				</xsl:if>
			</fo:block>
		</fo:block-container>
	</xsl:template>
	
	<xsl:template name="getFigureNumber">
		<xsl:choose>
			<xsl:when test="ancestor::iso:annex">
				<xsl:choose>
					<xsl:when test="local-name(..) = 'figure'">
						<xsl:number format="a) "/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$title-figure"/><xsl:number format="A.1-1" level="multiple" count="iso:annex | iso:figure"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$title-figure"/><xsl:number format="1" level="any"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="iso:figure/iso:name"/>
	<xsl:template match="iso:figure/iso:fn" priority="2"/>
	<xsl:template match="iso:figure/iso:note"/>
	
	
	<xsl:template match="iso:figure/iso:image">
		<fo:block text-align="center">
			<xsl:variable name="src">
				<xsl:choose>
					<xsl:when test="@mimetype = 'image/svg+xml' and $images/images/image[@id = current()/@id]">
						<xsl:value-of select="$images/images/image[@id = current()/@id]/@src"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="@src"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>		
			<fo:external-graphic src="{$src}" width="100%" content-height="scale-to-fit" scaling="uniform" fox:alt-text="Image {@alt}"/>  <!-- src="{@src}" -->
		</fo:block>
	</xsl:template>
	
	
	<xsl:template match="iso:bibitem">
		<fo:block id="{@id}" margin-bottom="6pt"> <!-- 12 pt -->
			<xsl:variable name="docidentifier">
				<xsl:if test="iso:docidentifier">
					<xsl:choose>
						<xsl:when test="iso:docidentifier/@type = 'metanorma'"/>
						<xsl:otherwise><xsl:value-of select="iso:docidentifier"/></xsl:otherwise>
					</xsl:choose>
				</xsl:if>
			</xsl:variable>
			<xsl:value-of select="$docidentifier"/>
			<xsl:apply-templates select="iso:note"/>			
			<xsl:if test="normalize-space($docidentifier) != ''">, </xsl:if>
			<fo:inline font-style="italic">
				<xsl:choose>
					<xsl:when test="iso:title[@type = 'main' and @language = 'en']">
						<xsl:value-of select="iso:title[@type = 'main' and @language = 'en']"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="iso:title"/>
					</xsl:otherwise>
				</xsl:choose>
			</fo:inline>
		</fo:block>
	</xsl:template>
	
	
	<xsl:template match="iso:bibitem/iso:note">
		<fo:footnote>
			<xsl:variable name="number">
				<xsl:number level="any" count="iso:bibitem/iso:note"/>
			</xsl:variable>
			<fo:inline font-size="8pt" keep-with-previous.within-line="always" baseline-shift="30%"> <!--85% vertical-align="super"-->
				<fo:basic-link internal-destination="footnote_{../@id}" fox:alt-text="footnote {$number}">
					<xsl:value-of select="$number"/><xsl:text>)</xsl:text>
				</fo:basic-link>
			</fo:inline>
			<fo:footnote-body>
				<fo:block font-size="10pt" margin-bottom="4pt" start-indent="0pt">
					<fo:inline id="footnote_{../@id}" keep-with-next.within-line="always" alignment-baseline="hanging" padding-right="3mm"><!-- font-size="60%"  -->
						<xsl:value-of select="$number"/><xsl:text>)</xsl:text>
					</fo:inline>
					<xsl:apply-templates/>
				</fo:block>
			</fo:footnote-body>
		</fo:footnote>
	</xsl:template>
	
	
	
	<xsl:template match="iso:ul | iso:ol">
		<fo:list-block provisional-distance-between-starts="7mm" margin-top="8pt"> <!-- margin-bottom="8pt" -->
			<xsl:apply-templates/>
		</fo:list-block>
		<xsl:for-each select="./iso:note//iso:p">
			<xsl:call-template name="note"/>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="iso:ul//iso:note |  iso:ol//iso:note"/>
	
	<xsl:template match="iso:li">
		<fo:list-item id="{@id}">
			<fo:list-item-label end-indent="label-end()">
				<fo:block>
					<xsl:call-template name="getListItemFormat"/>
				</fo:block>
			</fo:list-item-label>
			<fo:list-item-body start-indent="body-start()">
				<xsl:apply-templates/>
				<xsl:apply-templates select=".//iso:note" mode="process"/>
			</fo:list-item-body>
		</fo:list-item>
	</xsl:template>
	
	<xsl:template match="iso:term">
		<xsl:param name="sectionNum"/>
		<fo:block margin-bottom="10pt">
			<xsl:apply-templates>
				<xsl:with-param name="sectionNum" select="$sectionNum"/>
			</xsl:apply-templates>
		</fo:block>
	</xsl:template>
	
	<xsl:template match="iso:preferred">
		<xsl:param name="sectionNum"/>
		<fo:block line-height="1.1">
			<fo:block font-weight="bold" keep-with-next="always">
				<fo:inline id="{../@id}">
					<xsl:variable name="section">
						<xsl:call-template name="getSection">
							<xsl:with-param name="sectionNum" select="$sectionNum"/>
						</xsl:call-template>
					</xsl:variable>
					<xsl:value-of select="$section"/>
					<!-- <xsl:value-of select="$sectionNum"/>.<xsl:number count="iso:term"/> -->
				</fo:inline>
			</fo:block>
			<fo:block font-weight="bold" keep-with-next="always">
				<xsl:apply-templates/>
			</fo:block>
		</fo:block>
	</xsl:template>
	
	<xsl:template match="iso:admitted">
		<fo:block>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	
	<xsl:template match="iso:deprecates">
		<fo:block>DEPRECATED: <xsl:apply-templates/></fo:block>
	</xsl:template>
	
	<xsl:template match="iso:definition[preceding-sibling::iso:domain]">
		<xsl:apply-templates/>
	</xsl:template>
	<xsl:template match="iso:definition[preceding-sibling::iso:domain]/iso:p">
		<fo:inline> <xsl:apply-templates/></fo:inline>
		<fo:block> </fo:block>
	</xsl:template>
	
	<xsl:template match="iso:definition">
		<fo:block margin-bottom="6pt">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	
	<xsl:template match="iso:termsource">
		<fo:block margin-bottom="8pt"> <!-- keep-with-previous="always" -->
			<!-- Example: [SOURCE: ISO 5127:2017, 3.1.6.02] -->
			<fo:basic-link internal-destination="{iso:origin/@bibitemid}" fox:alt-text="{iso:origin/@citeas}">
				<xsl:text>[SOURCE: </xsl:text>
				<xsl:value-of select="iso:origin/@citeas"/>
				
				<xsl:apply-templates select="iso:origin/iso:localityStack"/>
				
				<!-- <xsl:if test="iso:origin/iso:locality/iso:referenceFrom">
					<xsl:text>, </xsl:text><xsl:value-of select="iso:origin/iso:locality/iso:referenceFrom"/>
				</xsl:if> -->
			</fo:basic-link>
			<xsl:apply-templates select="iso:modification"/>
			<xsl:text>]</xsl:text>
		</fo:block>
	</xsl:template>
	
	<xsl:template match="iso:modification">
		<xsl:text>, modified — </xsl:text>
		<xsl:apply-templates/>
	</xsl:template>
	<xsl:template match="iso:modification/iso:p">
		<fo:inline><xsl:apply-templates/></fo:inline>
	</xsl:template>
	
	<xsl:template match="iso:termnote">
		<fo:block font-size="10pt" margin-top="8pt" margin-bottom="8pt" text-align="justify">
			<xsl:text>Note </xsl:text>
			<xsl:number/>
			<xsl:text> to entry: </xsl:text>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	
	<xsl:template match="iso:termnote/iso:p">
		<fo:inline><xsl:apply-templates/></fo:inline>
		<!-- <xsl:if test="following-sibling::* and not(following-sibling::iso:p)">
			<xsl:value-of select="$linebreak"/>
			<xsl:value-of select="$linebreak"/>
		</xsl:if> -->
	</xsl:template>
	
	<xsl:template match="iso:domain">
		<fo:inline>&lt;<xsl:apply-templates/>&gt;</fo:inline><xsl:text> </xsl:text>
	</xsl:template>
	
	
	<xsl:template match="iso:termexample">
		<fo:block font-size="10pt" margin-top="8pt" margin-bottom="8pt" text-align="justify">
			<fo:inline padding-right="5mm">
				<xsl:text>EXAMPLE </xsl:text>
				<xsl:if test="count(ancestor::iso:term[1]//iso:termexample) &gt; 1">
					<xsl:number/>
				</xsl:if>
			</fo:inline>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	
	<xsl:template match="iso:termexample/iso:p">
		<fo:inline><xsl:apply-templates/></fo:inline>
	</xsl:template>

	
	<xsl:template match="iso:annex">
		<fo:block break-after="page"/>
		<xsl:apply-templates/>
	</xsl:template>

	
	<!-- <xsl:template match="iso:references[@id = '_bibliography']"> -->
	<xsl:template match="iso:references[position() &gt; 1]">
		<fo:block break-after="page"/>
			<xsl:apply-templates/>
	</xsl:template>


	<!-- Example: [1] ISO 9:1995, Information and documentation – Transliteration of Cyrillic characters into Latin characters – Slavic and non-Slavic languages -->
	<!-- <xsl:template match="iso:references[@id = '_bibliography']/iso:bibitem"> -->
	<xsl:template match="iso:references[position() &gt; 1]/iso:bibitem">
		<fo:list-block margin-bottom="6pt" provisional-distance-between-starts="12mm">
			<fo:list-item>
				<fo:list-item-label end-indent="label-end()">
					<fo:block>
						<fo:inline id="{@id}">
							<xsl:number format="[1]"/>
						</fo:inline>
					</fo:block>
				</fo:list-item-label>
				<fo:list-item-body start-indent="body-start()">
					<fo:block>
						<xsl:variable name="docidentifier">
							<xsl:if test="iso:docidentifier">
								<xsl:choose>
									<xsl:when test="iso:docidentifier/@type = 'metanorma'"/>
									<xsl:otherwise><xsl:value-of select="iso:docidentifier"/></xsl:otherwise>
								</xsl:choose>
							</xsl:if>
						</xsl:variable>
						<xsl:value-of select="$docidentifier"/>
						<xsl:apply-templates select="iso:note"/>
						<xsl:if test="normalize-space($docidentifier) != ''">, </xsl:if>
						<xsl:choose>
							<xsl:when test="iso:title[@type = 'main' and @language = 'en']">
								<xsl:apply-templates select="iso:title[@type = 'main' and @language = 'en']"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="iso:title"/>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:apply-templates select="iso:formattedref"/>
					</fo:block>
				</fo:list-item-body>
			</fo:list-item>
		</fo:list-block>
	</xsl:template>
	
	<!-- <xsl:template match="iso:references[@id = '_bibliography']/iso:bibitem" mode="contents"/> -->
	<xsl:template match="iso:references[position() &gt; 1]/iso:bibitem" mode="contents"/>
	
	<!-- <xsl:template match="iso:references[@id = '_bibliography']/iso:bibitem/iso:title"> -->
	<xsl:template match="iso:references[position() &gt; 1]/iso:bibitem/iso:title">
		<fo:inline font-style="italic">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template>

	<xsl:template match="iso:quote">
		<fo:block margin-top="12pt" margin-left="12mm" margin-right="12mm">
			<xsl:apply-templates select=".//iso:p"/>
		</fo:block>
		<fo:block text-align="right">
			<!-- — ISO, ISO 7301:2011, Clause 1 -->
			<xsl:text>— </xsl:text><xsl:value-of select="iso:author"/>
			<xsl:if test="iso:source">
				<xsl:text>, </xsl:text>
				<xsl:apply-templates select="iso:source"/>
			</xsl:if>
		</fo:block>
	</xsl:template>
	
	<xsl:template match="iso:source">
		<fo:basic-link internal-destination="{@bibitemid}" fox:alt-text="{@citeas}">
			<xsl:value-of select="@citeas" disable-output-escaping="yes"/>
			<xsl:apply-templates select="iso:localityStack"/>
		</fo:basic-link>
	</xsl:template>
	
	
	<xsl:template match="mathml:math" priority="2">
		<fo:inline font-family="Cambria Math">
			<fo:instream-foreign-object fox:alt-text="Math">
				<xsl:copy-of select="."/>
			</fo:instream-foreign-object>
		</fo:inline>
	</xsl:template>
	
	<xsl:template match="iso:xref">
		<xsl:param name="sectionNum"/>
		
		<xsl:variable name="target" select="normalize-space(@target)"/>
		<fo:basic-link internal-destination="{$target}" fox:alt-text="{$target}">
			<xsl:variable name="section" select="xalan:nodeset($contents)//item[@id = $target]/@section"/>
			<!-- <xsl:if test="not(starts-with($section, 'Figure') or starts-with($section, 'Table'))"> -->
				<xsl:attribute name="color">blue</xsl:attribute>
				<xsl:attribute name="text-decoration">underline</xsl:attribute>
			<!-- </xsl:if> -->
			<xsl:variable name="type" select="xalan:nodeset($contents)//item[@id = $target]/@type"/>
			<xsl:variable name="root" select="xalan:nodeset($contents)//item[@id =$target]/@root"/>
			<xsl:variable name="level" select="xalan:nodeset($contents)//item[@id =$target]/@level"/>
			<xsl:choose>
				<xsl:when test="$type = 'clause' and $root != 'annex' and $level = 1"><xsl:value-of select="$title-clause"/></xsl:when><!-- and not (ancestor::annex) -->
				<xsl:when test="$type = 'li'">
					<xsl:attribute name="color">black</xsl:attribute>
					<xsl:attribute name="text-decoration">none</xsl:attribute>
					<xsl:variable name="parent_section" select="xalan:nodeset($contents)//item[@id =$target]/@parent_section"/>
					<xsl:variable name="currentSection">
						<xsl:call-template name="getSection"/>
					</xsl:variable>
					<xsl:if test="not(contains($parent_section, $currentSection))">
						<fo:basic-link internal-destination="{$target}" fox:alt-text="{$target}">
							<xsl:attribute name="color">blue</xsl:attribute>
							<xsl:attribute name="text-decoration">underline</xsl:attribute>
							<xsl:value-of select="$parent_section"/><xsl:text> </xsl:text>
						</fo:basic-link>
					</xsl:if>
				</xsl:when>
				<xsl:otherwise/> <!-- <xsl:value-of select="$type"/> -->
			</xsl:choose>
			<xsl:value-of select="$section"/>
      </fo:basic-link>
	</xsl:template>
	
	<xsl:template match="iso:example/iso:p">
		<fo:block font-size="10pt" margin-top="8pt" margin-bottom="8pt">
			<!-- <xsl:if test="ancestor::iso:li">
				<xsl:attribute name="font-size">11pt</xsl:attribute>
			</xsl:if> -->
			<xsl:variable name="claims_id" select="ancestor::iso:clause[1]/@id"/>
			<fo:inline padding-right="5mm">
				<xsl:text>EXAMPLE </xsl:text>
				<xsl:if test="count(ancestor::iso:clause[1]//iso:example) &gt; 1">
					<xsl:number count="iso:example[ancestor::iso:clause[@id = $claims_id]]" level="any"/>
				</xsl:if>
			</fo:inline>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	
	<xsl:template match="iso:note/iso:p" name="note">
		<fo:block font-size="10pt" margin-top="8pt" margin-bottom="12pt" text-align="justify">
			<xsl:variable name="claims_id" select="ancestor::iso:clause[1]/@id"/>
			<fo:inline padding-right="6mm">
				<xsl:text>NOTE </xsl:text>
				<xsl:if test="count(ancestor::iso:clause[1]//iso:note) &gt; 1">
					<xsl:number count="iso:note[ancestor::iso:clause[@id = $claims_id]]" level="any"/>
				</xsl:if>
			</fo:inline>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>

	<!-- <eref type="inline" bibitemid="IEC60050-113" citeas="IEC 60050-113:2011"><localityStack><locality type="clause"><referenceFrom>113-01-12</referenceFrom></locality></localityStack></eref> -->
	<xsl:template match="iso:eref">
		<fo:basic-link internal-destination="{@bibitemid}" fox:alt-text="{@citeas}"> <!-- font-size="9pt" color="blue" vertical-align="super" -->
			<xsl:if test="@type = 'footnote'">
				<xsl:attribute name="keep-together.within-line">always</xsl:attribute>
				<xsl:attribute name="font-size">80%</xsl:attribute>
				<xsl:attribute name="keep-with-previous.within-line">always</xsl:attribute>
				<xsl:attribute name="vertical-align">super</xsl:attribute>
			</xsl:if>
			<!-- <xsl:if test="@type = 'inline'">
				<xsl:attribute name="color">blue</xsl:attribute>
				<xsl:attribute name="text-decoration">underline</xsl:attribute>
			</xsl:if> -->
			
			<xsl:choose>
				<xsl:when test="@citeas and normalize-space(text()) = ''">
					<xsl:value-of select="@citeas" disable-output-escaping="yes"/>
				</xsl:when>
				<xsl:when test="@bibitemid and normalize-space(text()) = ''">
					<xsl:value-of select="//iso:bibitem[@id = current()/@bibitemid]/iso:docidentifier"/>
				</xsl:when>
				<xsl:otherwise/>
			</xsl:choose>
			<xsl:apply-templates select="iso:localityStack"/>
			<xsl:apply-templates select="text()"/>
		</fo:basic-link>
	</xsl:template>
	
	<xsl:template match="iso:locality">
		<xsl:choose>
			<xsl:when test="ancestor::iso:termsource"/>
			<xsl:when test="@type ='clause' and ancestor::iso:eref"/>
			<xsl:when test="@type ='clause'"><xsl:value-of select="$title-clause"/></xsl:when>
			<xsl:when test="@type ='annex'"><xsl:value-of select="$title-annex"/></xsl:when>
			<xsl:when test="@type ='table'"><xsl:value-of select="$title-table"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="@type"/></xsl:otherwise>
		</xsl:choose>
		<xsl:text> </xsl:text><xsl:value-of select="iso:referenceFrom"/>
	</xsl:template>
	
	<xsl:template match="iso:admonition">
		<fo:block margin-bottom="12pt" font-weight="bold"> <!-- text-align="center"  -->
			<xsl:value-of select="translate(@type, $lower, $upper)"/>
			<xsl:text> — </xsl:text>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	
	<xsl:template match="iso:formula/iso:dt/iso:stem">
		<fo:inline>
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template>
	
	<xsl:template match="iso:formula/iso:stem">
		<fo:block id="{../@id}" margin-top="6pt" margin-bottom="12pt">
			<fo:table table-layout="fixed" width="100%">
				<fo:table-column column-width="95%"/>
				<fo:table-column column-width="5%"/>
				<fo:table-body>
					<fo:table-row>
						<fo:table-cell display-align="center">
							<fo:block text-align="left" margin-left="5mm">
								<xsl:apply-templates/>
							</fo:block>
						</fo:table-cell>
						<fo:table-cell display-align="center">
							<fo:block text-align="right">
								<xsl:choose>
									<xsl:when test="ancestor::iso:annex">
										<xsl:text>(</xsl:text><xsl:number format="A.1" level="multiple" count="iso:annex | iso:formula"/><xsl:text>)</xsl:text>
									</xsl:when>
									<xsl:otherwise> <!-- not(ancestor::iso:annex) -->
										<!-- <xsl:text>(</xsl:text><xsl:number level="any" count="iso:formula"/><xsl:text>)</xsl:text> -->
									</xsl:otherwise>
								</xsl:choose>
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
				</fo:table-body>
			</fo:table>
			<fo:inline keep-together.within-line="always">
			</fo:inline>
		</fo:block>
	</xsl:template>
	
	
	<xsl:template match="iso:br" priority="2">
		<!-- <fo:block>&#xA0;</fo:block> -->
		<xsl:value-of select="$linebreak"/>
	</xsl:template>
	
	<xsl:template name="insertHeaderFooter">
		<xsl:param name="font-weight" select="'bold'"/>
		<xsl:call-template name="insertHeaderEven"/>
		<fo:static-content flow-name="footer-even">
			<fo:block-container> <!--  display-align="after" -->
				<fo:table table-layout="fixed" width="100%">
					<fo:table-column column-width="33%"/>
					<fo:table-column column-width="33%"/>
					<fo:table-column column-width="34%"/>
					<fo:table-body>
						<fo:table-row>
							<fo:table-cell display-align="center" padding-top="0mm" font-size="11pt" font-weight="{$font-weight}">
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
		<fo:static-content flow-name="header-odd">
			<fo:block-container height="24mm" display-align="before">
				<fo:block font-size="12pt" font-weight="bold" text-align="right" padding-top="12.5mm"><xsl:value-of select="$ISOname"/></fo:block>
			</fo:block-container>
		</fo:static-content>
		<fo:static-content flow-name="footer-odd">
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
								<fo:block text-align="right"><fo:page-number/></fo:block>
							</fo:table-cell>
						</fo:table-row>
					</fo:table-body>
				</fo:table>
			</fo:block-container>
		</fo:static-content>
	</xsl:template>
	<xsl:template name="insertHeaderEven">
		<fo:static-content flow-name="header-even">
			<fo:block-container height="24mm" display-align="before">
				<fo:block font-size="12pt" font-weight="bold" padding-top="12.5mm"><xsl:value-of select="$ISOname"/></fo:block>
			</fo:block-container>
		</fo:static-content>
	</xsl:template>
	
	<xsl:template name="getId">
		<xsl:choose>
			<xsl:when test="../@id">
				<xsl:value-of select="../@id"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="text()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="getLevel">
		<xsl:variable name="level_total" select="count(ancestor::*)"/>
		<xsl:variable name="level">
			<xsl:choose>
				<xsl:when test="ancestor::iso:preface">
					<xsl:value-of select="$level_total - 2"/>
				</xsl:when>
				<xsl:when test="ancestor::iso:sections">
					<xsl:value-of select="$level_total - 2"/>
				</xsl:when>
				<xsl:when test="ancestor::iso:bibliography">
					<xsl:value-of select="$level_total - 2"/>
				</xsl:when>
				<xsl:when test="local-name(ancestor::*[1]) = 'annex'">1</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$level_total - 1"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="$level"/>
	</xsl:template>

	<xsl:template name="getSection">
		<xsl:param name="sectionNum"/>
		<xsl:variable name="level">
			<xsl:call-template name="getLevel"/>
		</xsl:variable>
		<xsl:variable name="section">
			<xsl:choose>
				<xsl:when test="ancestor::iso:bibliography">
					<xsl:value-of select="$sectionNum"/>
				</xsl:when>
				<xsl:when test="ancestor::iso:sections">
					<!-- 1, 2, 3, 4, ... from main section (not annex, bibliography, ...) -->
					<xsl:choose>
						<xsl:when test="$level = 1">
							<xsl:value-of select="$sectionNum"/>
						</xsl:when>
						<xsl:when test="$level &gt;= 2">
							<xsl:variable name="num">
								<xsl:number format=".1" level="multiple" count="iso:clause/iso:clause |                                            iso:clause/iso:terms |                                            iso:terms/iso:term |                                            iso:clause/iso:term |                                             iso:terms/iso:clause |                                           iso:terms/iso:definitions |                                           iso:definitions/iso:clause |                                           iso:definitions/iso:definitions |                                           iso:clause/iso:definitions"/>
							</xsl:variable>
							<xsl:value-of select="concat($sectionNum, $num)"/>
						</xsl:when>
						<xsl:otherwise>
							<!-- z<xsl:value-of select="$sectionNum"/>z -->
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<!-- <xsl:when test="ancestor::iso:annex[@obligation = 'informative']">
					<xsl:choose>
						<xsl:when test="$level = 1">
							<xsl:text>Annex  </xsl:text>
							<xsl:number format="I" level="any" count="iso:annex[@obligation = 'informative']"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:number format="I.1" level="multiple" count="iso:annex[@obligation = 'informative'] | iso:clause"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when> -->
				<xsl:when test="ancestor::iso:annex">
					<xsl:variable name="annexid" select="normalize-space(/iso:iso-standard/iso:bibdata/iso:ext/iso:structuredidentifier/iso:annexid)"/>
					<xsl:choose>
						<xsl:when test="$level = 1">
							<xsl:value-of select="$title-annex"/>
							<xsl:choose>
								<xsl:when test="count(//iso:annex) = 1 and $annexid != ''">
									<xsl:value-of select="$annexid"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:number format="A" level="any" count="iso:annex"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>							
							<xsl:choose>
								<xsl:when test="count(//iso:annex) = 1 and $annexid != ''">
									<xsl:value-of select="$annexid"/><xsl:number format=".1" level="multiple" count="iso:clause"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:number format="A.1" level="multiple" count="iso:annex | iso:clause"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="ancestor::iso:preface"> <!-- if preface and there is clause(s) -->
					<xsl:choose>
						<xsl:when test="$level = 1 and  ..//iso:clause">0</xsl:when>
						<xsl:when test="$level &gt;= 2">
							<xsl:variable name="num">
								<xsl:number format=".1" level="multiple" count="iso:clause"/>
							</xsl:variable>
							<xsl:value-of select="concat('0', $num)"/>
						</xsl:when>
						<xsl:otherwise>
							<!-- z<xsl:value-of select="$sectionNum"/>z -->
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="$section"/>
	</xsl:template>

	<xsl:variable name="Image-ISO-Logo2">
		<xsl:text>
			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
		</xsl:text>
	</xsl:variable>
	
	<xsl:variable name="Image-ISO-Logo">
		<xsl:text>iVBORw0KGgoAAAANSUhEUgAAAPcAAADiCAYAAACSl1F7AAAAGXRFWHRTb2Z0d2FyZQBBZG9i
			ZSBJbWFnZVJlYWR5ccllPAAABT9pVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tl
			dCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1l
			dGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUu
			Ni1jMDE0IDc5LjE1Njc5NywgMjAxNC8wOC8yMC0wOTo1MzowMiAgICAgICAgIj4gPHJkZjpS
			REYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgt
			bnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wUmlnaHRzPSJo
			dHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvcmlnaHRzLyIgeG1sbnM6eG1wTU09Imh0dHA6
			Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRv
			YmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9u
			cy5hZG9iZS5jb20veGFwLzEuMC8iIHhtbG5zOmRjPSJodHRwOi8vcHVybC5vcmcvZGMvZWxl
			bWVudHMvMS4xLyIgeG1wUmlnaHRzOk1hcmtlZD0iVHJ1ZSIgeG1wUmlnaHRzOldlYlN0YXRl
			bWVudD0iaHR0cDovL3d3dy5pc28ub3JnL2lzby9ob21lL3BvbGljaWVzLmh0bSIgeG1wTU06
			T3JpZ2luYWxEb2N1bWVudElEPSJ4bXAuZGlkOjNjZGZlYTk5LWYzY2QtNDcyYS1hNGVmLWQ4
			ZmY5MDQ4YTk0NSIgeG1wTU06RG9jdW1lbnRJRD0ieG1wLmRpZDozRjU0RkYwNTc5OTIxMUVB
			QjEyNkEyOUU0MUE2ODdFNCIgeG1wTU06SW5zdGFuY2VJRD0ieG1wLmlpZDozRjU0RkYwNDc5
			OTIxMUVBQjEyNkEyOUU0MUE2ODdFNCIgeG1wOkNyZWF0b3JUb29sPSJBZG9iZSBJbkRlc2ln
			biBDQyAyMDE3IChXaW5kb3dzKSI+IDx4bXBNTTpEZXJpdmVkRnJvbSBzdFJlZjppbnN0YW5j
			ZUlEPSJ1dWlkOjRhOTA3NDQ2LTExMTgtNGZmZi1iY2E4LWU1NWI5YjBhNTBmZCIgc3RSZWY6
			ZG9jdW1lbnRJRD0ieG1wLmlkOjFlNzM4NzEwLWMyNzUtYjU0Yy1hYWUwLWYwMzYwMTQyZTJl
			ZSIvPiA8ZGM6cmlnaHRzPiA8cmRmOkFsdD4gPHJkZjpsaSB4bWw6bGFuZz0ieC1kZWZhdWx0
			Ij7CqSBJU08g77u/MjAxOO+7vzwvcmRmOmxpPiA8L3JkZjpBbHQ+IDwvZGM6cmlnaHRzPiA8
			ZGM6Y3JlYXRvcj4gPHJkZjpTZXE+IDxyZGY6bGk+SVNPPC9yZGY6bGk+IDwvcmRmOlNlcT4g
			PC9kYzpjcmVhdG9yPiA8ZGM6dGl0bGU+IDxyZGY6QWx0PiA8cmRmOmxpIHhtbDpsYW5nPSJ4
			LWRlZmF1bHQiPklTTy9GRElTIDg2MDEtMjoyMDE5PC9yZGY6bGk+IDwvcmRmOkFsdD4gPC9k
			Yzp0aXRsZT4gPC9yZGY6RGVzY3JpcHRpb24+IDwvcmRmOlJERj4gPC94OnhtcG1ldGE+IDw/
			eHBhY2tldCBlbmQ9InIiPz7JxxdJAAAhu0lEQVR42uxdB9gV1bXdiv4g0lQsqBAUe6+A7dmw
			xf4sIRoVjSbGksRoYkmeYqJRoxITNZqoscRnYk1i14iCXVMUKyKgYAeRIohge2c5677/Ov+5
			7b8zZ+beu9b37e/C3PnvzJw565y999l7n0WGDz9ojJlta4IgNAuudTJiUbWDIDQnRG5BELkF
			QRC5BUEQuQVBELkFQRC5BUEQuQVB5BYEQeQWBEHkFgRB5BYEQeQWBEHkFgSRWxAEkVsQBJFb
			EASRWxAEkVsQBJFbEERuQRBEbkEQRG5BEERuQRBqwGJqgobFp04mOJnq5C0n7/HzXSfTnMx1
			8omTeU4WOJnPv1vCSVcn3Z20OVnSyXJOVnCykpPl+bmyk7WcLK6mFrmF9PCGkyecvOjkBSfj
			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
			GAcdXP9eq1y1BRl1WGJDrD7CfQep2yQPrRemh4G0s0dyVvqtlQ7OiBN9NP+/PFV4VPTcgmou
			wl6voh0bj7fGzPkc1epq0x5fpd3+eAm/wuUWhcJ+TjIiHfMB3uM7NbYJKs4cT19FH3URkbvR
			gXpmSBOFowi5xtdatHZcjZf7Pc6aN/D/S9D2RX03eJF9Ti8s023EmRge+lJ51m/TLr60zL0g
			QaawvgznXWfW7bF8uCcHo93U58JhkeHDDxpj+dskvdkxm/Yz1PcnzJ/xlJTZtQ3JWbBnsRwH
			D/bDlm4K6RD6HoZb9iWiWg2YQEZoFM0G8LAfRcEMirJAd1DdTXJnEajSY81f8yxpdKP5sAdn
			6pX1mqWWtzpWLCL6xyQ4wksfo0qc11roXai2oxT0ThTlVIvcQpnZbw9rT2WcR7Udzi5ExGEX
			k6kZ3Rtsd4TBIqBmK5K6h16ZyC10DqgFPoxSAMJOsQQ1nmSfQtX+XdrTnVXrl6AWsTxVagi2
			+UGmGzzvvfQ6RG4hXcD7PsRK1y0D+d/jrF/Y0vdja/eId6OAzF2pSi9HP4Agcgs5J39PNYOg
			CDVBELkFQRC5BUEQuQVBELkFQRC5BUEQuQVB5BYEQeQWBEHkFgRB5BYEQeQWBEHkFgSRWxAE
			kVsQBJFbEASRWxAEkVsQBJFbEERuQRBEbkEQRG5BEERuQRBEbkEQRG5BELkFQWgkYDuhiU76
			qCkEoWkwtUDuI9UWgtB8+D8BBgBziI7n+Kw0uQAAAABJRU5ErkJggg==
		</xsl:text>
	</xsl:variable>
	
	<xsl:variable name="Image-IEC-Logo">
		<xsl:text>iVBORw0KGgoAAAANSUhEUgAAAOwAAADlCAYAAABQ3BvcAAAAGXRFWHRTb2Z0d2FyZQBBZG9i
			ZSBJbWFnZVJlYWR5ccllPAAAA39pVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tl
			dCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1l
			dGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUu
			Ni1jMDE0IDc5LjE1Njc5NywgMjAxNC8wOC8yMC0wOTo1MzowMiAgICAgICAgIj4gPHJkZjpS
			REYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgt
			bnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6
			Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRv
			YmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9u
			cy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6QUZCNjhD
			NjM3QTUxMTFFQUE0MDdDNjQ1OTIxQjc1Q0IiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6
			QUZCNjhDNjI3QTUxMTFFQUE0MDdDNjQ1OTIxQjc1Q0IiIHhtcDpDcmVhdG9yVG9vbD0iTW96
			aWxsYS81LjAgKE1hY2ludG9zaDsgSW50ZWwgTWFjIE9TIFggMTBfMTRfNikgQXBwbGVXZWJL
			aXQvNTM3LjM2IChLSFRNTCwgbGlrZSBHZWNrbykgQ2hyb21lLzc3LjAuMzg2NS45MCBTYWZh
			cmkvNTM3LjM2Ij4gPHhtcE1NOkRlcml2ZWRGcm9tIHN0UmVmOmluc3RhbmNlSUQ9InV1aWQ6
			OGRjOTFlYTktMGJlYy00YjJiLWI5ZjctYTNlMjA3ZTBiM2RjIiBzdFJlZjpkb2N1bWVudElE
			PSJ1dWlkOmZmYjEyOTA0LTcyNWItNGRlOS1iNTYxLWU3YmY0YjEzMDMyZSIvPiA8L3JkZjpE
			ZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/
			PuNo9+0AAA5WSURBVHja7J1pkBXlFYYPEQRlFAxjQFExIho0igY3NJAyRkVErTJKTFwTo0lc
			UdyIK2i5gFvFRI0aV1BBQDRaMYLEBTXGjS2ZuCO4sOjIKKIMAjkn/VlSFMz0vff0dud5qt7i
			xzSnu7/u9/a3n1bdu205UUQOEQDIO8O+RRkAFAcMC4BhAQDDAmBYAMCwAIBhATAsAGBYAMCw
			ABgWADAsAGBYAAwLABgWADAsAIYFAAwLABgWAMMCAIYFAAwLgGEBAMMCAIYFwLAAgGEBAMMC
			YFgAwLAAgGEBMCwAYFgAwLAAGBYAMCwAYFgADAsAGBYAMCwAhgUADAsAGBYAwwIAhgUADAuA
			YQEgW1pTBFAgPlW9qZob9LFqkapRtUTVUbWuagPVJqotgrpXy7uOYSHPzFZNUj2tekn1umpF
			GXHaqnZU9Vb1Ue0bDI1hm6PLJl2k9Tq+p21ctkwWzJ+fh/JcrFpeoOffLrzMeeIV1f2qiao3
			nGIuVb0YdLOqVTDwANVhqh9g2LUwZtw46dq1q2vMuro6OeiAAVmU39uq+8JX4NVQZSsSl6gu
			zsF1WNX2dtUtocqbNCtV04OuCNXmY1WnqjbO8wOj06k83gi/zD1UF6ieKqBZ88BM1XEq+wU/
			JyWzrok5qktV3VS/Ub2HYauH60N1anyZ7SkQ+afqAFUv1V2hypoHvghf+W1Ul6mWYdjiYuY8
			XnWG6kuKoyzmharnnqrHQtU0j5hxL1Ttai0uDFtMfhvaWVAe1tbfVnV3jo26OtODacfm5YIY
			1omHVZNupRjKwsZHT034x65GtZdqJ9VWqs4SjclalbZB9YHqNdXLEg0PfVVC7M9VR4R27ZkY
			Nv+8rzqLYiiLD1UDJRqq8aZ3iL2fanfVOjH/n3UOPhq+9H+P+bW3Y4aEH4BzMWy+sc6HzyiG
			knlLtX/41wubwXRi6EvoWWaMDVU/D7KJGMNDdT1OB+J5qvaqUzBsPrHxwTsSir29ajdVhwzv
			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
			QDH4nwADAD8qVGA5YSc/AAAAAElFTkSuQmCC
			</xsl:text>
	</xsl:variable>
	
	<xsl:variable name="Image-Attention">
		<xsl:text>
			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
		</xsl:text>
	</xsl:variable>
	
		<xsl:template name="number-to-words">
		<xsl:param name="number"/>
		<xsl:variable name="words">
			<words>
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
			</words>
		</xsl:variable>

		<xsl:variable name="ordinal" select="xalan:nodeset($words)//word[@ordinal = $number]/text()"/>

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
	</xsl:template>
	
	<xsl:template name="printEdition">
		<xsl:variable name="edition" select="normalize-space(/iso:iso-standard/iso:bibdata/iso:edition)"/>
		<xsl:text> </xsl:text>
		<xsl:choose>
			<xsl:when test="number($edition) = $edition">
				<xsl:call-template name="number-to-words">
					<xsl:with-param name="number" select="$edition"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$edition != ''">
				<xsl:value-of select="$edition"/>
			</xsl:when>
		</xsl:choose>
		<xsl:if test="$edition != ''"><xsl:text> edition</xsl:text></xsl:if>
	</xsl:template>
	
<xsl:variable name="title-table">
		
			<xsl:text>Table </xsl:text>
									
		
	</xsl:variable><xsl:variable name="title-note">
		
			<xsl:text>NOTE </xsl:text>
		
		
	</xsl:variable><xsl:variable name="title-figure">
		
			<xsl:text>Figure </xsl:text>
		
		
	</xsl:variable><xsl:variable name="title-example">
		
			<xsl:text>EXAMPLE </xsl:text>
		
		
	</xsl:variable><xsl:variable name="title-annex">
		
			<xsl:text>Annex </xsl:text>
		
		
	</xsl:variable><xsl:variable name="title-appendix">
		<xsl:text>Appendix </xsl:text>
	</xsl:variable><xsl:variable name="title-clause">
		
			<xsl:text>Clause </xsl:text>
		
		
	</xsl:variable><xsl:variable name="title-edition">
		<xsl:text>Edition </xsl:text>
	</xsl:variable><xsl:variable name="title-toc">
		
	</xsl:variable><xsl:variable name="title-key">Key</xsl:variable><xsl:variable name="title-where">where</xsl:variable><xsl:variable name="title-descriptors">Descriptors</xsl:variable><xsl:variable name="lower">abcdefghijklmnopqrstuvwxyz</xsl:variable><xsl:variable name="upper">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable><xsl:variable name="en_chars" select="concat($lower,$upper,',.`1234567890-=~!@#$%^*()_+[]{}\|?/')"/><xsl:variable name="linebreak" select="'&#8232;'"/><xsl:attribute-set name="link-style">
		
			<xsl:attribute name="color">blue</xsl:attribute>
			<xsl:attribute name="text-decoration">underline</xsl:attribute>
		
		
	</xsl:attribute-set><xsl:attribute-set name="sourcecode-style">
		
			<xsl:attribute name="font-family">Courier</xsl:attribute>
			<xsl:attribute name="font-size">9pt</xsl:attribute>
			<xsl:attribute name="margin-bottom">12pt</xsl:attribute>
		
		
		
		
		
				
		
		
	</xsl:attribute-set><xsl:attribute-set name="appendix-style">
				
			<xsl:attribute name="font-size">12pt</xsl:attribute>
			<xsl:attribute name="font-weight">bold</xsl:attribute>
			<xsl:attribute name="margin-top">12pt</xsl:attribute>
			<xsl:attribute name="margin-bottom">12pt</xsl:attribute>
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="appendix-example-style">
		
			<xsl:attribute name="font-size">10pt</xsl:attribute>			
			<xsl:attribute name="margin-top">8pt</xsl:attribute>
			<xsl:attribute name="margin-bottom">8pt</xsl:attribute>
		
		
		
	</xsl:attribute-set><xsl:template match="text()">
		<xsl:value-of select="."/>
	</xsl:template><xsl:template match="*[local-name()='br']">
		<xsl:value-of select="$linebreak"/>
	</xsl:template><xsl:template match="*[local-name()='td']//text() | *[local-name()='th']//text() | *[local-name()='dt']//text() | *[local-name()='dd']//text()" priority="1">
		<!-- <xsl:call-template name="add-zero-spaces"/> -->
		<xsl:call-template name="add-zero-spaces-java"/>
	</xsl:template><xsl:template match="*[local-name()='table']">
	
		<xsl:variable name="simple-table">
			<!-- <xsl:copy> -->
				<xsl:call-template name="getSimpleTable"/>
			<!-- </xsl:copy> -->
		</xsl:variable>
	
		<!-- DEBUG -->
		<!-- SourceTable=<xsl:copy-of select="current()"/>EndSourceTable -->
		<!-- Simpletable=<xsl:copy-of select="$simple-table"/>EndSimpltable -->
	
		<!-- <xsl:variable name="namespace" select="substring-before(name(/*), '-')"/> -->
		
		<!-- <xsl:if test="$namespace = 'iso'">
			<fo:block space-before="6pt">&#xA0;</fo:block>				
		</xsl:if> -->
		
		<xsl:choose>
			<xsl:when test="@unnumbered = 'true'"/>
			<xsl:otherwise>
				
				
				
					<fo:block font-weight="bold" text-align="center" margin-bottom="6pt" keep-with-next="always">
						
							<xsl:attribute name="margin-top">12pt</xsl:attribute>
						
						
						
						
						
						
						
						
						
						<xsl:value-of select="$title-table"/>
						
						<xsl:call-template name="getTableNumber"/>

						
						<xsl:if test="*[local-name()='name']">
							
							
							
								<xsl:text> — </xsl:text>
							
							<xsl:apply-templates select="*[local-name()='name']" mode="process"/>
						</xsl:if>
					</fo:block>
				
				
					<xsl:call-template name="fn_name_display"/>
				
			</xsl:otherwise>
		</xsl:choose>
		
		<xsl:variable name="cols-count" select="count(xalan:nodeset($simple-table)//tr[1]/td)"/>
		
		<!-- <xsl:variable name="cols-count">
			<xsl:choose>
				<xsl:when test="*[local-name()='thead']">
					<xsl:call-template name="calculate-columns-numbers">
						<xsl:with-param name="table-row" select="*[local-name()='thead']/*[local-name()='tr'][1]"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="calculate-columns-numbers">
						<xsl:with-param name="table-row" select="*[local-name()='tbody']/*[local-name()='tr'][1]"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable> -->
		<!-- cols-count=<xsl:copy-of select="$cols-count"/> -->
		<!-- cols-count2=<xsl:copy-of select="$cols-count2"/> -->
		
		
		
		<xsl:variable name="colwidths">
			<xsl:call-template name="calculate-column-widths">
				<xsl:with-param name="cols-count" select="$cols-count"/>
				<xsl:with-param name="table" select="$simple-table"/>
			</xsl:call-template>
		</xsl:variable>
		
		<!-- <xsl:variable name="colwidths2">
			<xsl:call-template name="calculate-column-widths">
				<xsl:with-param name="cols-count" select="$cols-count"/>
			</xsl:call-template>
		</xsl:variable> -->
		
		<!-- cols-count=<xsl:copy-of select="$cols-count"/>
		colwidthsNew=<xsl:copy-of select="$colwidths"/>
		colwidthsOld=<xsl:copy-of select="$colwidths2"/>z -->
		
		<xsl:variable name="margin-left">
			<xsl:choose>
				<xsl:when test="sum(xalan:nodeset($colwidths)//column) &gt; 75">15</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<fo:block-container margin-left="-{$margin-left}mm" margin-right="-{$margin-left}mm">			
			
			
			
			
			
			
			
				<xsl:attribute name="margin-left">0mm</xsl:attribute>
				<xsl:attribute name="margin-right">0mm</xsl:attribute>
				<xsl:attribute name="margin-bottom">8pt</xsl:attribute>
			
			
			<fo:table id="{@id}" table-layout="fixed" width="100%" margin-left="{$margin-left}mm" margin-right="{$margin-left}mm" table-omit-footer-at-break="true">
				
					<xsl:attribute name="border">1.5pt solid black</xsl:attribute>
				
				
				
				
					<xsl:attribute name="margin-left">0mm</xsl:attribute>
					<xsl:attribute name="margin-right">0mm</xsl:attribute>
				
				
				
				
				
				
					<xsl:attribute name="font-size">10pt</xsl:attribute>
				
				
				
				<xsl:for-each select="xalan:nodeset($colwidths)//column">
					<xsl:choose>
						<xsl:when test=". = 1 or . = 0">
							<fo:table-column column-width="proportional-column-width(2)"/>
						</xsl:when>
						<xsl:otherwise>
							<fo:table-column column-width="proportional-column-width({.})"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
				<xsl:apply-templates/>
			</fo:table>
			
			
			
		</fo:block-container>
	</xsl:template><xsl:template name="getTableNumber">
		<xsl:choose>
			<xsl:when test="ancestor::*[local-name()='executivesummary']"> <!-- NIST -->
				<xsl:text>ES-</xsl:text><xsl:number format="1" count="*[local-name()='executivesummary']//*[local-name()='table'][not(@unnumbered) or @unnumbered != 'true']"/>
			</xsl:when>
			<xsl:when test="ancestor::*[local-name()='annex']">
				
					<xsl:variable name="annex-id" select="ancestor::*[local-name()='annex']/@id"/>
					<xsl:number format="A." count="*[local-name()='annex']"/><xsl:number format="1" level="any" count="*[local-name()='table'][(not(@unnumbered) or @unnumbered != 'true') and ancestor::*[local-name()='annex'][@id = $annex-id]]"/>
				
				
				
				
				
				
				
				
			</xsl:when>
			<xsl:otherwise>
				
				
					<xsl:number format="A." count="*[local-name()='annex']"/>
					<xsl:number format="1" level="any" count="//*[local-name()='table']                                       [not(ancestor::*[local-name()='annex'])                                        and not(ancestor::*[local-name()='executivesummary'])                                       and not(ancestor::*[local-name()='bibdata'])]                                       [not(@unnumbered) or @unnumbered != 'true']"/>
					
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template match="*[local-name()='table']/*[local-name()='name']"/><xsl:template match="*[local-name()='table']/*[local-name()='name']" mode="process">
		<xsl:apply-templates/>
	</xsl:template><xsl:template name="calculate-columns-numbers">
		<xsl:param name="table-row"/>
		<xsl:variable name="columns-count" select="count($table-row/*)"/>
		<xsl:variable name="sum-colspans" select="sum($table-row/*/@colspan)"/>
		<xsl:variable name="columns-with-colspan" select="count($table-row/*[@colspan])"/>
		<xsl:value-of select="$columns-count + $sum-colspans - $columns-with-colspan"/>
	</xsl:template><xsl:template name="calculate-column-widths">
		<xsl:param name="table"/>
		<xsl:param name="cols-count"/>
		<xsl:param name="curr-col" select="1"/>
		<xsl:param name="width" select="0"/>
		
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
						<xsl:for-each select="xalan:nodeset($table)//tr">
							<xsl:variable name="td_text">
								<xsl:apply-templates select="td[$curr-col]" mode="td_text"/>
							</xsl:variable>
							<xsl:variable name="words">
								<xsl:variable name="string_with_added_zerospaces">
									<xsl:call-template name="add-zero-spaces-java">
										<xsl:with-param name="text" select="$td_text"/>
									</xsl:call-template>
								</xsl:variable>
								<xsl:call-template name="tokenize">
									<!-- <xsl:with-param name="text" select="translate(td[$curr-col],'- —:', '    ')"/> -->
									<!-- 2009 thinspace -->
									<!-- <xsl:with-param name="text" select="translate(normalize-space($td_text),'- —:', '    ')"/> -->
									<xsl:with-param name="text" select="normalize-space(translate($string_with_added_zerospaces, '​', ' '))"/>
								</xsl:call-template>
							</xsl:variable>
							<xsl:variable name="max_length">
								<xsl:call-template name="max_length">
									<xsl:with-param name="words" select="xalan:nodeset($words)"/>
								</xsl:call-template>
							</xsl:variable>
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

			
			<column>
				<xsl:for-each select="xalan:nodeset($widths)//width">
					<xsl:sort select="." data-type="number" order="descending"/>
					<xsl:if test="position()=1">
							<xsl:value-of select="."/>
					</xsl:if>
				</xsl:for-each>
			</column>
			<xsl:call-template name="calculate-column-widths">
				<xsl:with-param name="cols-count" select="$cols-count"/>
				<xsl:with-param name="curr-col" select="$curr-col +1"/>
				<xsl:with-param name="table" select="$table"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template><xsl:template match="text()" mode="td_text">
		<xsl:variable name="zero-space">​</xsl:variable>
		<xsl:value-of select="translate(., $zero-space, ' ')"/><xsl:text> </xsl:text>
	</xsl:template><xsl:template match="*[local-name()='termsource']" mode="td_text">
		<xsl:value-of select="*[local-name()='origin']/@citeas"/>
	</xsl:template><xsl:template match="*[local-name()='link']" mode="td_text">
		<xsl:value-of select="@target"/>
	</xsl:template><xsl:template match="*[local-name()='table2']"/><xsl:template match="*[local-name()='thead']"/><xsl:template match="*[local-name()='thead']" mode="process">
		<!-- font-weight="bold" -->
		<fo:table-header>
			<xsl:apply-templates/>
		</fo:table-header>
	</xsl:template><xsl:template match="*[local-name()='tfoot']"/><xsl:template match="*[local-name()='tfoot']" mode="process">
		<xsl:apply-templates/>
	</xsl:template><xsl:template name="insertTableFooter">
		<xsl:variable name="isNoteOrFnExist" select="../*[local-name()='note'] or ..//*[local-name()='fn'][local-name(..) != 'name']"/>
		<xsl:if test="../*[local-name()='tfoot'] or           $isNoteOrFnExist = 'true'">
		
			<fo:table-footer>
			
				<xsl:apply-templates select="../*[local-name()='tfoot']" mode="process"/>
				
				<!-- if there are note(s) or fn(s) then create footer row -->
				<xsl:if test="$isNoteOrFnExist = 'true'">
				
					<xsl:variable name="cols-count">
						<xsl:choose>
							<xsl:when test="../*[local-name()='thead']">
								<!-- <xsl:value-of select="count(../*[local-name()='thead']/*[local-name()='tr']/*[local-name()='th'])"/> -->
								<xsl:call-template name="calculate-columns-numbers">
									<xsl:with-param name="table-row" select="../*[local-name()='thead']/*[local-name()='tr'][1]"/>
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<!-- <xsl:value-of select="count(./*[local-name()='tr'][1]/*[local-name()='td'])"/> -->
								<xsl:call-template name="calculate-columns-numbers">
									<xsl:with-param name="table-row" select="./*[local-name()='tr'][1]"/>
								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
				
					<fo:table-row>
						<fo:table-cell border="solid black 1pt" padding-left="1mm" padding-right="1mm" padding-top="1mm" number-columns-spanned="{$cols-count}">
							
								<xsl:attribute name="border-top">solid black 0pt</xsl:attribute>
							
							
							
							<!-- fn will be processed inside 'note' processing -->
							
							
							<!-- except gb -->
							
								<xsl:apply-templates select="../*[local-name()='note']" mode="process"/>
							
							
							<!-- horizontal row separator -->
							
							
							<!-- fn processing -->
							<xsl:call-template name="fn_display"/>
							
						</fo:table-cell>
					</fo:table-row>
					
				</xsl:if>
			</fo:table-footer>
		
		</xsl:if>
	</xsl:template><xsl:template match="*[local-name()='tbody']">
		
		<xsl:apply-templates select="../*[local-name()='thead']" mode="process"/>
		
		<xsl:call-template name="insertTableFooter"/>
		
		<fo:table-body>
			<xsl:apply-templates/>
			<!-- <xsl:apply-templates select="../*[local-name()='tfoot']" mode="process"/> -->
		
		</fo:table-body>
		
	</xsl:template><xsl:template match="*[local-name()='tr']">
		<xsl:variable name="parent-name" select="local-name(..)"/>
		<!-- <xsl:variable name="namespace" select="substring-before(name(/*), '-')"/> -->
		<fo:table-row min-height="4mm">
				<xsl:if test="$parent-name = 'thead'">
					<xsl:attribute name="font-weight">bold</xsl:attribute>
					
					
					
						<xsl:choose>
							<xsl:when test="position() = 1">
								<xsl:attribute name="border-top">solid black 1.5pt</xsl:attribute>
								<xsl:attribute name="border-bottom">solid black 1pt</xsl:attribute>
							</xsl:when>
							<xsl:when test="position() = last()">
								<xsl:attribute name="border-top">solid black 1pt</xsl:attribute>
								<xsl:attribute name="border-bottom">solid black 1.5pt</xsl:attribute>
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="border-top">solid black 1pt</xsl:attribute>
								<xsl:attribute name="border-bottom">solid black 1pt</xsl:attribute>
							</xsl:otherwise>
						</xsl:choose>
					
					
					
				</xsl:if>
				<xsl:if test="$parent-name = 'tfoot'">
					
						<xsl:attribute name="font-size">9pt</xsl:attribute>
						<xsl:attribute name="border-left">solid black 1pt</xsl:attribute>
						<xsl:attribute name="border-right">solid black 1pt</xsl:attribute>
					
					
				</xsl:if>
				
				
			<xsl:apply-templates/>
		</fo:table-row>
	</xsl:template><xsl:template match="*[local-name()='th']">
		<fo:table-cell text-align="{@align}" font-weight="bold" border="solid black 1pt" padding-left="1mm" display-align="center">
			
				<xsl:attribute name="padding-top">1mm</xsl:attribute>
			
			
			
			
			
			
			
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
			<fo:block>
				<xsl:apply-templates/>
			</fo:block>
		</fo:table-cell>
	</xsl:template><xsl:template match="*[local-name()='td']">
		<fo:table-cell text-align="{@align}" display-align="center" border="solid black 1pt" padding-left="1mm">
			 <!--  and ancestor::*[local-name() = 'thead'] -->
				<xsl:attribute name="padding-top">0.5mm</xsl:attribute>
			
			
			
				<xsl:if test="ancestor::*[local-name() = 'tfoot']">
					<xsl:attribute name="border">solid black 0</xsl:attribute>
				</xsl:if>
			
			
			
			
			
			
			
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
			<fo:block>
				<xsl:apply-templates/>
			</fo:block>
			<!-- <xsl:choose>
				<xsl:when test="count(*) = 1 and *[local-name() = 'p']">
					<xsl:apply-templates />
				</xsl:when>
				<xsl:otherwise>
					<fo:block>
						<xsl:apply-templates />
					</fo:block>
				</xsl:otherwise>
			</xsl:choose> -->
			
			
		</fo:table-cell>
	</xsl:template><xsl:template match="*[local-name()='table']/*[local-name()='note']"/><xsl:template match="*[local-name()='table']/*[local-name()='note']" mode="process">
		
		
			<fo:block font-size="10pt" margin-bottom="12pt">
				
					<xsl:attribute name="font-size">9pt</xsl:attribute>
					<xsl:attribute name="margin-bottom">6pt</xsl:attribute>
				
				
				
				
				<fo:inline padding-right="2mm">
					
					
					<xsl:value-of select="$title-note"/>
					
						<xsl:variable name="id" select="ancestor::*[local-name() = 'table'][1]/@id"/>
						<xsl:if test="count(//*[local-name()='note'][ancestor::*[@id = $id]]) &gt; 1">
							<xsl:number count="*[local-name()='note'][ancestor::*[@id = $id]]" level="any"/>
						</xsl:if>
						
					
					
					
				</fo:inline>
				<xsl:apply-templates mode="process"/>
			</fo:block>
		
	</xsl:template><xsl:template match="*[local-name()='table']/*[local-name()='note']/*[local-name()='p']" mode="process">
		<xsl:apply-templates/>
	</xsl:template><xsl:template name="fn_display">
		<xsl:variable name="references">
			<xsl:for-each select="..//*[local-name()='fn'][local-name(..) != 'name']">
				<fn reference="{@reference}" id="{@reference}_{ancestor::*[@id][1]/@id}">
					
					
					<xsl:apply-templates/>
				</fn>
			</xsl:for-each>
		</xsl:variable>
		<xsl:for-each select="xalan:nodeset($references)//fn">
			<xsl:variable name="reference" select="@reference"/>
			<xsl:if test="not(preceding-sibling::*[@reference = $reference])"> <!-- only unique reference puts in note-->
				<fo:block margin-bottom="12pt">
					
						<xsl:attribute name="font-size">9pt</xsl:attribute>
						<xsl:attribute name="margin-bottom">6pt</xsl:attribute>
					
					
					
					
					<fo:inline font-size="80%" padding-right="5mm" id="{@id}">
						
						
							<xsl:attribute name="alignment-baseline">hanging</xsl:attribute>
						
						
						
						
						
						<xsl:value-of select="@reference"/>
						
					</fo:inline>
					<fo:inline>
						
						<xsl:apply-templates/>
					</fo:inline>
				</fo:block>
			</xsl:if>
		</xsl:for-each>
	</xsl:template><xsl:template name="fn_name_display">
		<!-- <xsl:variable name="references">
			<xsl:for-each select="*[local-name()='name']//*[local-name()='fn']">
				<fn reference="{@reference}" id="{@reference}_{ancestor::*[@id][1]/@id}">
					<xsl:apply-templates />
				</fn>
			</xsl:for-each>
		</xsl:variable>
		$references=<xsl:copy-of select="$references"/> -->
		<xsl:for-each select="*[local-name()='name']//*[local-name()='fn']">
			<xsl:variable name="reference" select="@reference"/>
			<fo:block id="{@reference}_{ancestor::*[@id][1]/@id}"><xsl:value-of select="@reference"/></fo:block>
			<fo:block margin-bottom="12pt">
				<xsl:apply-templates/>
			</fo:block>
		</xsl:for-each>
	</xsl:template><xsl:template name="fn_display_figure">
		<xsl:variable name="key_iso">
			true <!-- and (not(@class) or @class !='pseudocode') -->
		</xsl:variable>
		<xsl:variable name="references">
			<xsl:for-each select=".//*[local-name()='fn']">
				<fn reference="{@reference}" id="{@reference}_{ancestor::*[@id][1]/@id}">
					<xsl:apply-templates/>
				</fn>
			</xsl:for-each>
		</xsl:variable>
		<xsl:if test="xalan:nodeset($references)//fn">
			<fo:block>
				<fo:table width="95%" table-layout="fixed">
					<xsl:if test="normalize-space($key_iso) = 'true'">
						<xsl:attribute name="font-size">10pt</xsl:attribute>
						
					</xsl:if>
					<fo:table-column column-width="15%"/>
					<fo:table-column column-width="85%"/>
					<fo:table-body>
						<xsl:for-each select="xalan:nodeset($references)//fn">
							<xsl:variable name="reference" select="@reference"/>
							<xsl:if test="not(preceding-sibling::*[@reference = $reference])"> <!-- only unique reference puts in note-->
								<fo:table-row>
									<fo:table-cell>
										<fo:block>
											<fo:inline font-size="80%" padding-right="5mm" vertical-align="super" id="{@id}">
												
												<xsl:value-of select="@reference"/>
											</fo:inline>
										</fo:block>
									</fo:table-cell>
									<fo:table-cell>
										<fo:block text-align="justify" margin-bottom="12pt">
											
											<xsl:if test="normalize-space($key_iso) = 'true'">
												<xsl:attribute name="margin-bottom">0</xsl:attribute>
											</xsl:if>
											
											<xsl:apply-templates/>
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
		<!-- <xsl:variable name="namespace" select="substring-before(name(/*), '-')"/> -->
		<fo:inline font-size="80%" keep-with-previous.within-line="always">
			
				<xsl:if test="ancestor::*[local-name()='td']">
					<xsl:attribute name="font-weight">normal</xsl:attribute>
					<!-- <xsl:attribute name="alignment-baseline">hanging</xsl:attribute> -->
					<xsl:attribute name="baseline-shift">15%</xsl:attribute>
				</xsl:if>
			
			
			
			
			<fo:basic-link internal-destination="{@reference}_{ancestor::*[@id][1]/@id}" fox:alt-text="{@reference}"> <!-- @reference   | ancestor::*[local-name()='clause'][1]/@id-->
				
				<xsl:value-of select="@reference"/>
			</fo:basic-link>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name()='fn']/*[local-name()='p']">
		<fo:inline>
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name()='dl']">
		<xsl:variable name="parent" select="local-name(..)"/>
		
		<xsl:variable name="key_iso">
			
				<xsl:if test="$parent = 'figure' or $parent = 'formula'">true</xsl:if>
			 <!-- and  (not(../@class) or ../@class !='pseudocode') -->
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="$parent = 'formula' and count(*[local-name()='dt']) = 1"> <!-- only one component -->
				
				
					<fo:block margin-bottom="12pt" text-align="left">
						
							<xsl:attribute name="margin-bottom">0</xsl:attribute>
												
						<xsl:value-of select="$title-where"/><xsl:text> </xsl:text>
						<xsl:apply-templates select="*[local-name()='dt']/*"/>
						<xsl:text/>
						<xsl:apply-templates select="*[local-name()='dd']/*" mode="inline"/>
					</fo:block>
				
			</xsl:when>
			<xsl:when test="$parent = 'formula'"> <!-- a few components -->
				<fo:block margin-bottom="12pt" text-align="left">
					
						<xsl:attribute name="margin-bottom">6pt</xsl:attribute>
					
					
					
										
					<xsl:value-of select="$title-where"/>
				</fo:block>
			</xsl:when>
			<xsl:when test="$parent = 'figure' and  (not(../@class) or ../@class !='pseudocode')">
				<fo:block font-weight="bold" text-align="left" margin-bottom="12pt">
					
						<xsl:attribute name="font-size">10pt</xsl:attribute>
						<xsl:attribute name="margin-bottom">0</xsl:attribute>
					
					
					
					<xsl:value-of select="$title-key"/>
				</fo:block>
			</xsl:when>
		</xsl:choose>
		
		<!-- a few components -->
		<xsl:if test="not($parent = 'formula' and count(*[local-name()='dt']) = 1)">
			<fo:block>
				
					<xsl:if test="$parent = 'formula'">
						<xsl:attribute name="margin-left">4mm</xsl:attribute>
					</xsl:if>
					<xsl:attribute name="margin-top">12pt</xsl:attribute>
				
				
				
				
				<fo:block>
					
					
					
					<!-- create virtual html table for dl/[dt and dd] -->
					<xsl:variable name="html-table">
						<xsl:variable name="ns" select="substring-before(name(/*), '-')"/>
						<xsl:element name="{$ns}:table">
							<tbody>
								<xsl:apply-templates mode="dl"/>
							</tbody>
						</xsl:element>
					</xsl:variable>
					<!-- html-table<xsl:copy-of select="$html-table"/> -->
					<xsl:variable name="colwidths">
						<xsl:call-template name="calculate-column-widths">
							<xsl:with-param name="cols-count" select="2"/>
							<xsl:with-param name="table" select="$html-table"/>
						</xsl:call-template>
					</xsl:variable>
					<!-- colwidths=<xsl:value-of select="$colwidths"/> -->
					
					<fo:table width="95%" table-layout="fixed">
						
						<xsl:choose>
							<xsl:when test="normalize-space($key_iso) = 'true' and $parent = 'formula'">
								<!-- <xsl:attribute name="font-size">11pt</xsl:attribute> -->
							</xsl:when>
							<xsl:when test="normalize-space($key_iso) = 'true'">
								<xsl:attribute name="font-size">10pt</xsl:attribute>
								
							</xsl:when>
						</xsl:choose>
						<xsl:choose>
							<xsl:when test="ancestor::*[local-name()='dl']"><!-- second level, i.e. inlined table -->
								<fo:table-column column-width="50%"/>
								<fo:table-column column-width="50%"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:choose>
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
										<xsl:for-each select="xalan:nodeset($colwidths)//column">
											<xsl:choose>
												<xsl:when test=". = 1 or . = 0">
													<fo:table-column column-width="proportional-column-width(2)"/>
												</xsl:when>
												<xsl:otherwise>
													<fo:table-column column-width="proportional-column-width({.})"/>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:for-each>
									</xsl:otherwise>
								</xsl:choose>
								<!-- <fo:table-column column-width="15%"/>
								<fo:table-column column-width="85%"/> -->
							</xsl:otherwise>
						</xsl:choose>
						<fo:table-body>
							<xsl:apply-templates>
								<xsl:with-param name="key_iso" select="normalize-space($key_iso)"/>
							</xsl:apply-templates>
						</fo:table-body>
					</fo:table>
				</fo:block>
			</fo:block>
		</xsl:if>
	</xsl:template><xsl:template match="*[local-name()='dl']/*[local-name()='note']">
		<xsl:param name="key_iso"/>
		
		<!-- <tr>
			<td>NOTE</td>
			<td>
				<xsl:apply-templates />
			</td>
		</tr>
		 -->
		<fo:table-row>
			<fo:table-cell>
				<fo:block margin-top="6pt">
					<xsl:if test="normalize-space($key_iso) = 'true'">
						<xsl:attribute name="margin-top">0</xsl:attribute>
					</xsl:if>
					<xsl:value-of select="$title-note"/>
				</fo:block>
			</fo:table-cell>
			<fo:table-cell>
				<fo:block>
					<xsl:apply-templates/>
				</fo:block>
			</fo:table-cell>
		</fo:table-row>
	</xsl:template><xsl:template match="*[local-name()='dt']" mode="dl">
		<tr>
			<td>
				<xsl:apply-templates/>
			</td>
			<td>
				
				
					<xsl:apply-templates select="following-sibling::*[local-name()='dd'][1]" mode="process"/>
				
			</td>
		</tr>
		
	</xsl:template><xsl:template match="*[local-name()='dt']">
		<xsl:param name="key_iso"/>
		
		<fo:table-row>
			<fo:table-cell>
				<fo:block margin-top="6pt">
					
						<xsl:attribute name="margin-top">0pt</xsl:attribute>
					
					
					<xsl:if test="normalize-space($key_iso) = 'true'">
						<xsl:attribute name="margin-top">0</xsl:attribute>
						
					</xsl:if>
					
					
					
					<xsl:apply-templates/>
										
				</fo:block>
			</fo:table-cell>
			<fo:table-cell>
				<fo:block>
					
					
					
						<xsl:apply-templates select="following-sibling::*[local-name()='dd'][1]" mode="process"/>
					
				</fo:block>
			</fo:table-cell>
		</fo:table-row>
		
	</xsl:template><xsl:template match="*[local-name()='dd']" mode="dl"/><xsl:template match="*[local-name()='dd']" mode="dl_process">
		<xsl:apply-templates/>
	</xsl:template><xsl:template match="*[local-name()='dd']"/><xsl:template match="*[local-name()='dd']" mode="process">
		<xsl:apply-templates/>
	</xsl:template><xsl:template match="*[local-name()='dd']/*[local-name()='p']" mode="inline">
		<fo:inline><xsl:text> </xsl:text><xsl:apply-templates/></fo:inline>
	</xsl:template><xsl:template match="*[local-name()='em']">
		<fo:inline font-style="italic">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name()='strong']">
		<fo:inline font-weight="bold">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name()='sup']">
		<fo:inline font-size="80%" vertical-align="super">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name()='sub']">
		<fo:inline font-size="80%" vertical-align="sub">
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name()='tt']">
		<fo:inline font-family="Courier" font-size="10pt">			
			<xsl:apply-templates/>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name()='del']">
		<fo:inline font-size="10pt" color="red" text-decoration="line-through">
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
    <xsl:variable name="upperCase" select="translate($char, $lower, $upper)"/>
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
  </xsl:template><xsl:template name="tokenize">
		<xsl:param name="text"/>
		<xsl:param name="separator" select="' '"/>
		<xsl:choose>
			<xsl:when test="not(contains($text, $separator))">
				<word>
					<xsl:variable name="str_no_en_chars" select="normalize-space(translate($text, $en_chars, ''))"/>
					<xsl:variable name="len_str_no_en_chars" select="string-length($str_no_en_chars)"/>
					<xsl:variable name="len_str_tmp" select="string-length(normalize-space($text))"/>
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
				</word>
			</xsl:when>
			<xsl:otherwise>
				<word>
					<xsl:value-of select="string-length(normalize-space(substring-before($text, $separator)))"/>
				</word>
				<xsl:call-template name="tokenize">
					<xsl:with-param name="text" select="substring-after($text, $separator)"/>
				</xsl:call-template>
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
		<xsl:variable name="zero-space-after-equal">=</xsl:variable>
		<xsl:variable name="zero-space">​</xsl:variable>
		<xsl:choose>
			<xsl:when test="contains($text, $zero-space-after-equals)">
				<xsl:value-of select="substring-before($text, $zero-space-after-equals)"/>
				<xsl:value-of select="$zero-space-after-equals"/>
				<xsl:value-of select="$zero-space"/>
				<xsl:call-template name="add-zero-spaces-equal">
					<xsl:with-param name="text" select="substring-after($text, $zero-space-after-equals)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="contains($text, $zero-space-after-equal)">
				<xsl:value-of select="substring-before($text, $zero-space-after-equal)"/>
				<xsl:value-of select="$zero-space-after-equal"/>
				<xsl:value-of select="$zero-space"/>
				<xsl:call-template name="add-zero-spaces-equal">
					<xsl:with-param name="text" select="substring-after($text, $zero-space-after-equal)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template name="getSimpleTable">
		<xsl:variable name="simple-table">
		
			<!-- Step 1. colspan processing -->
			<xsl:variable name="simple-table-colspan">
				<tbody>
					<xsl:apply-templates mode="simple-table-colspan"/>
				</tbody>
			</xsl:variable>
			
			<!-- Step 2. rowspan processing -->
			<xsl:variable name="simple-table-rowspan">
				<xsl:apply-templates select="xalan:nodeset($simple-table-colspan)" mode="simple-table-rowspan"/>
			</xsl:variable>
			
			<xsl:copy-of select="xalan:nodeset($simple-table-rowspan)"/>
					
			<!-- <xsl:choose>
				<xsl:when test="current()//*[local-name()='th'][@colspan] or current()//*[local-name()='td'][@colspan] ">
					
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="current()"/>
				</xsl:otherwise>
			</xsl:choose> -->
		</xsl:variable>
		<xsl:copy-of select="$simple-table"/>
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
	</xsl:template><xsl:template name="getLang">
		<xsl:variable name="language" select="//*[local-name()='bibdata']//*[local-name()='language']"/>
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
				<xsl:value-of select="translate(substring($substr, 1, 1), $lower, $upper)"/>
				<xsl:value-of select="substring($substr, 2)"/>
				<xsl:text> </xsl:text>
				<xsl:call-template name="capitalizeWords">
					<xsl:with-param name="str" select="substring-after($str2, ' ')"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="translate(substring($str2, 1, 1), $lower, $upper)"/>
				<xsl:value-of select="substring($str2, 2)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template><xsl:template match="mathml:math">
		<fo:inline font-family="STIX2Math">
			<fo:instream-foreign-object fox:alt-text="Math"> 
				<xsl:copy-of select="."/>
			</fo:instream-foreign-object>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name()='localityStack']">
		<xsl:for-each select="*[local-name()='locality']">
			<xsl:if test="position() =1"><xsl:text>, </xsl:text></xsl:if>
			<xsl:apply-templates select="."/>
			<xsl:if test="position() != last()"><xsl:text>; </xsl:text></xsl:if>
		</xsl:for-each>
	</xsl:template><xsl:template match="*[local-name()='link']" name="link">
		<xsl:variable name="target">
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
			<xsl:choose>
				<xsl:when test="$target = ''">
					<xsl:apply-templates/>
				</xsl:when>
				<xsl:otherwise>
					<fo:basic-link external-destination="{@target}" fox:alt-text="{@target}">
						<xsl:choose>
							<xsl:when test="normalize-space(.) = ''">
								<xsl:value-of select="$target"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates/>
							</xsl:otherwise>
						</xsl:choose>
					</fo:basic-link>
				</xsl:otherwise>
			</xsl:choose>
		</fo:inline>
	</xsl:template><xsl:template match="*[local-name()='sourcecode']" name="sourcecode">
		<fo:block xsl:use-attribute-sets="sourcecode-style">
			<!-- <xsl:choose>
				<xsl:when test="@lang = 'en'"></xsl:when>
				<xsl:otherwise> -->
					<xsl:attribute name="white-space">pre</xsl:attribute>
					<xsl:attribute name="wrap-option">wrap</xsl:attribute>
				<!-- </xsl:otherwise>
			</xsl:choose> -->
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name()='bookmark']">
		<fo:inline id="{@id}"/>
	</xsl:template><xsl:template match="*[local-name()='appendix']">
		<fo:block id="{@id}" xsl:use-attribute-sets="appendix-style">
			<fo:inline padding-right="5mm"><xsl:value-of select="$title-appendix"/> <xsl:number/></fo:inline>
			<xsl:apply-templates select="*[local-name()='title']" mode="process"/>
		</fo:block>
		<xsl:apply-templates/>
	</xsl:template><xsl:template match="*[local-name()='appendix']/*[local-name()='title']"/><xsl:template match="*[local-name()='appendix']/*[local-name()='title']" mode="process">
		<fo:inline><xsl:apply-templates/></fo:inline>
	</xsl:template><xsl:template match="*[local-name()='appendix']//*[local-name()='example']">
		<fo:block xsl:use-attribute-sets="appendix-example-style">
			<xsl:variable name="claims_id" select="ancestor::*[local-name()='clause'][1]/@id"/>
			<xsl:value-of select="$title-example"/>
			<xsl:if test="count(ancestor::*[local-name()='clause'][1]//*[local-name()='example']) &gt; 1">
					<xsl:number count="*[local-name()='example'][ancestor::*[local-name()='clause'][@id = $claims_id]]" level="any"/><xsl:text> </xsl:text>
				</xsl:if>
			<xsl:if test="*[local-name()='name']">
				<xsl:text>— </xsl:text><xsl:apply-templates select="*[local-name()='name']" mode="process"/>
			</xsl:if>
		</fo:block>
		<xsl:apply-templates/>
	</xsl:template><xsl:template match="*[local-name()='appendix']//*[local-name()='example']/*[local-name()='name']"/><xsl:template match="*[local-name()='appendix']//*[local-name()='example']/*[local-name()='name']" mode="process">
		<fo:inline><xsl:apply-templates/></fo:inline>
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
	</xsl:template><xsl:template name="convertDate">
		<xsl:param name="date"/>
		<xsl:param name="format" select="'short'"/>
		<xsl:variable name="year" select="substring($date, 1, 4)"/>
		<xsl:variable name="month" select="substring($date, 6, 2)"/>
		<xsl:variable name="day" select="substring($date, 9, 2)"/>
		<xsl:variable name="monthStr">
			<xsl:choose>
				<xsl:when test="$month = '01'">January</xsl:when>
				<xsl:when test="$month = '02'">February</xsl:when>
				<xsl:when test="$month = '03'">March</xsl:when>
				<xsl:when test="$month = '04'">April</xsl:when>
				<xsl:when test="$month = '05'">May</xsl:when>
				<xsl:when test="$month = '06'">June</xsl:when>
				<xsl:when test="$month = '07'">July</xsl:when>
				<xsl:when test="$month = '08'">August</xsl:when>
				<xsl:when test="$month = '09'">September</xsl:when>
				<xsl:when test="$month = '10'">October</xsl:when>
				<xsl:when test="$month = '11'">November</xsl:when>
				<xsl:when test="$month = '12'">December</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="result">
			<xsl:choose>
				<xsl:when test="$format = 'short' or $day = ''">
					<xsl:value-of select="normalize-space(concat($monthStr, ' ', $year))"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="normalize-space(concat($monthStr, ' ', $day, ', ' , $year))"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="$result"/>
	</xsl:template><xsl:template name="insertKeywords">
		<xsl:param name="sorting" select="'true'"/>
		<xsl:param name="charAtEnd" select="'.'"/>
		<xsl:param name="charDelim" select="', '"/>
		<xsl:choose>
			<xsl:when test="$sorting = 'true' or $sorting = 'yes'">
				<xsl:for-each select="/*/*[local-name() = 'bibdata']//*[local-name() = 'keyword']">
					<xsl:sort data-type="text" order="ascending"/>
					<xsl:call-template name="insertKeyword">
						<xsl:with-param name="charAtEnd" select="$charAtEnd"/>
						<xsl:with-param name="charDelim" select="$charDelim"/>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="/*/*[local-name() = 'bibdata']//*[local-name() = 'keyword']">
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
	</xsl:template></xsl:stylesheet>