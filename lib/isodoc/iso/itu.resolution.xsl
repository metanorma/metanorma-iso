<?xml version="1.0" encoding="UTF-8"?><xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:itu="https://www.metanorma.org/ns/itu" xmlns:mathml="http://www.w3.org/1998/Math/MathML" xmlns:xalan="http://xml.apache.org/xalan" xmlns:fox="http://xmlgraphics.apache.org/fop/extensions" xmlns:java="http://xml.apache.org/xalan/java" exclude-result-prefixes="java" version="1.0">

	<xsl:output method="xml" encoding="UTF-8" indent="no"/>
	
	
	
	<xsl:key name="kfn" match="*[local-name() = 'fn'][not(ancestor::*[(local-name() = 'table' or local-name() = 'figure') and not(ancestor::*[local-name() = 'name'])])]" use="@reference"/>
	
	
	
	<xsl:variable name="debug">false</xsl:variable>
	
	<!-- Rec. ITU-T G.650.1 (03/2018) -->
	<xsl:variable name="footerprefix" select="'Rec. '"/>
	<xsl:variable name="docname">		
		<xsl:value-of select="substring-before(/itu:itu-standard/itu:bibdata/itu:docidentifier[@type = 'ITU'], ' ')"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="substring-after(/itu:itu-standard/itu:bibdata/itu:docidentifier[@type = 'ITU'], ' ')"/>
		<xsl:text> </xsl:text>
	</xsl:variable>
	<xsl:variable name="docdate">
		<xsl:call-template name="formatDate">
			<xsl:with-param name="date" select="/itu:itu-standard/itu:bibdata/itu:date[@type = 'published']/itu:on"/>
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="doctype" select="/itu:itu-standard/itu:bibdata/itu:ext/itu:doctype[not(@language) or @language = '']"/>

	<xsl:variable name="xSTR-ACRONYM">
		<xsl:variable name="x" select="/itu:itu-standard/itu:bibdata/itu:series[@type = 'main']/itu:title[@type = 'abbrev']"/>
		<xsl:variable name="acronym" select="/itu:itu-standard/itu:bibdata/itu:docnumber"/>
		<xsl:value-of select="concat($x,'STR-', $acronym)"/>
	</xsl:variable>
	

	<!-- Example:
		<item level="1" id="Foreword" display="true">Foreword</item>
		<item id="term-script" display="false">3.2</item>
	-->
	<xsl:variable name="contents_">
		<contents>
			<!-- <xsl:apply-templates select="/itu:itu-standard/itu:preface/node()" mode="contents"/> -->
			<xsl:apply-templates select="/itu:itu-standard/itu:sections/itu:clause[@type='scope']" mode="contents"/> <!-- @id = 'scope' -->
				
			<!-- Normative references -->
			<xsl:apply-templates select="/itu:itu-standard/itu:bibliography/itu:references[@normative='true']" mode="contents"/> <!-- @id = 'references' -->
			
			<xsl:apply-templates select="/itu:itu-standard/itu:sections/*[not(@type='scope')]" mode="contents"/> <!-- @id != 'scope' -->
				
			<xsl:apply-templates select="/itu:itu-standard/itu:annex" mode="contents"/>
			
			<!-- Bibliography -->
			<xsl:apply-templates select="/itu:itu-standard/itu:bibliography/itu:references[not(@normative='true')]" mode="contents"/> <!-- @id = 'bibliography' -->
			
			<xsl:apply-templates select="//itu:table" mode="contents"/>
			
			<xsl:call-template name="processTablesFigures_Contents">
				<xsl:with-param name="always" select="$doctype = 'technical-report' or $doctype = 'technical-paper'"/>
			</xsl:call-template>
		</contents>
	</xsl:variable>
	<xsl:variable name="contents" select="xalan:nodeset($contents_)"/>
	
	<xsl:variable name="doctypeTitle">
		<xsl:choose>
			<xsl:when test="/itu:itu-standard/itu:bibdata/itu:ext/itu:doctype[@language = $lang]">
				<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:ext/itu:doctype[@language = $lang]"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="capitalizeWords">
					<xsl:with-param name="str" select="$doctype"/>
				</xsl:call-template>		
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:variable name="footer-text">
		<xsl:choose>
			<xsl:when test="$doctype = 'technical-report' or $doctype = 'technical-paper'">
				<xsl:variable name="date" select="concat('(',substring(/itu:itu-standard/itu:bibdata/itu:version/itu:revision-date,1,7), ')')"/>
				<xsl:value-of select="concat($xSTR-ACRONYM, ' ', $date)"/>
			</xsl:when>
			<xsl:when test="$doctype = 'implementers-guide'">
				<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:ext/itu:doctype[@language = $lang]"/>
				<xsl:text> for </xsl:text>
				<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:docidentifier[@type='ITU-Recommendation']"/>
				<xsl:text> </xsl:text>
				<xsl:variable name="date" select="concat('(',substring(/itu:itu-standard/itu:bibdata/itu:date[@type = 'published']/itu:on,1,7), ')')"/>
				<xsl:value-of select="$date"/>
			</xsl:when>
			<xsl:when test="$doctype = 'resolution'">
				<!-- WTSA-16 – Resolution 1  -->
				<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:ext/itu:meeting/@acronym"/>
				<xsl:text> – </xsl:text>
				<xsl:value-of select="$doctypeTitle"/>
				<xsl:text> </xsl:text>
				<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:ext/itu:structuredidentifier/itu:docnumber"/>
			</xsl:when>
			<xsl:when test="$doctype = 'recommendation-supplement'">
				<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:docidentifier[@type = 'ITU-Supplement-Short']"/>
				<xsl:text> </xsl:text>
				<xsl:value-of select="$docdate"/>
			</xsl:when>
			<xsl:when test="$doctype = 'service-publication'">
				<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:docidentifier[@type = 'ITU-lang']"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat($footerprefix, $docname, ' ', $docdate)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:variable name="isAmendment" select="normalize-space(/itu:itu-standard/itu:bibdata/itu:ext/itu:structuredidentifier/itu:amendment[@language = $lang])"/>
	<xsl:variable name="isCorrigendum" select="normalize-space(/itu:itu-standard/itu:bibdata/itu:ext/itu:structuredidentifier/itu:corrigendum[@language = $lang])"/>
	
	<xsl:template match="/">
		<xsl:call-template name="namespaceCheck"/>
		<fo:root xml:lang="{$lang}">
			<xsl:variable name="root-style">
				<root-style xsl:use-attribute-sets="root-style">
					<!-- <xsl:if test="$lang != 'ar'">
						<xsl:attribute name="xml:lang"><xsl:value-of select="$lang"/></xsl:attribute>
					</xsl:if> -->
					<xsl:if test="$doctype = 'resolution'">
						<xsl:attribute name="font-size">11pt</xsl:attribute>
					</xsl:if>
					<xsl:if test="$doctype = 'service-publication'">
						<xsl:attribute name="font-size">11pt</xsl:attribute>
						<xsl:attribute name="font-family">Arial, STIX Two Math</xsl:attribute>
					</xsl:if>
					<xsl:call-template name="setWritingMode"/>
					<xsl:if test="$lang = 'ar'">
						<xsl:attribute name="font-family">Traditional Arabic, Times New Roman, STIX Two Math</xsl:attribute>
					</xsl:if>
				</root-style>
			</xsl:variable>
			<xsl:call-template name="insertRootStyle">
				<xsl:with-param name="root-style" select="$root-style"/>
			</xsl:call-template>
			
			<fo:layout-master-set>
			
				<!-- Technical Report first page -->
				<fo:simple-page-master master-name="TR-first-page" page-width="{$pageWidth}mm" page-height="{$pageHeight}mm">
					<fo:region-body margin-top="21.6mm" margin-bottom="25.4mm" margin-left="20.1mm" margin-right="22.6mm"/>
					<fo:region-before region-name="TR-first-page-header" extent="21.6mm" display-align="center"/>
					<fo:region-after region-name="TR-first-page-footer" extent="25.4mm" display-align="center"/>					
					<fo:region-start region-name="TR-first-page-left-region" extent="20.1mm"/>
					<fo:region-end region-name="TR-first-page-right-region" extent="22.6mm"/>
				</fo:simple-page-master>
				
				<!-- Service Publication first page -->
				<fo:simple-page-master master-name="SP-first-page" page-width="{$pageWidth}mm" page-height="{$pageHeight}mm">
					<fo:region-body margin-top="20mm" margin-bottom="20mm" margin-left="20mm" margin-right="20mm"/>
					<fo:region-before region-name="header" extent="20mm"/>
					<fo:region-after region-name="footer" extent="20mm"/>					
					<fo:region-start region-name="left-region" extent="20mm"/>
					<fo:region-end region-name="right-region" extent="20mm"/>
				</fo:simple-page-master>
				
				<!-- cover page -->
				<fo:simple-page-master master-name="cover-page" page-width="{$pageWidth}mm" page-height="{$pageHeight}mm">
					<fo:region-body margin-top="19.2mm" margin-bottom="5mm" margin-left="19.2mm" margin-right="19.2mm"/>
					<fo:region-before region-name="cover-page-header" extent="19.2mm" display-align="center"/>
					<fo:region-after/>
					<fo:region-start region-name="cover-left-region" extent="19.2mm"/>
					<fo:region-end region-name="cover-right-region" extent="19.2mm"/>
				</fo:simple-page-master>
				<!-- contents pages -->
				<!-- odd pages Preface -->
				<fo:simple-page-master master-name="odd-preface" page-width="{$pageWidth}mm" page-height="{$pageHeight}mm">
					<fo:region-body margin-top="19.2mm" margin-bottom="19.2mm" margin-left="19.2mm" margin-right="19.2mm"/>
					<fo:region-before region-name="header-odd" extent="19.2mm" display-align="center"/>
					<fo:region-after region-name="footer-odd" extent="19.2mm"/>
					<fo:region-start region-name="left-region" extent="19.2mm"/>
					<fo:region-end region-name="right-region" extent="19.2mm"/>
				</fo:simple-page-master>
				<!-- even pages Preface -->
				<fo:simple-page-master master-name="even-preface" page-width="{$pageWidth}mm" page-height="{$pageHeight}mm">
					<fo:region-body margin-top="19.2mm" margin-bottom="19.2mm" margin-left="19.2mm" margin-right="19.2mm"/>
					<fo:region-before region-name="header-even" extent="19.2mm" display-align="center"/>
					<fo:region-after region-name="footer-even" extent="19.2mm"/>
					<fo:region-start region-name="left-region" extent="19.2mm"/>
					<fo:region-end region-name="right-region" extent="19.2mm"/>
				</fo:simple-page-master>
				<fo:page-sequence-master master-name="document-preface">
					<fo:repeatable-page-master-alternatives>
						<fo:conditional-page-master-reference odd-or-even="even" master-reference="even-preface"/>
						<fo:conditional-page-master-reference odd-or-even="odd" master-reference="odd-preface"/>
					</fo:repeatable-page-master-alternatives>
				</fo:page-sequence-master>
				<!-- odd pages Body -->
				<fo:simple-page-master master-name="odd" page-width="{$pageWidth}mm" page-height="{$pageHeight}mm">
					<fo:region-body margin-top="{$marginTop}mm" margin-bottom="{$marginBottom}mm" margin-left="{$marginLeftRight1}mm" margin-right="{$marginLeftRight2}mm"/>
					<fo:region-before region-name="header-odd" extent="{$marginTop}mm" display-align="center"/>
					<fo:region-after region-name="footer-odd" extent="{$marginBottom}mm"/>
					<fo:region-start region-name="left-region" extent="{$marginLeftRight1}mm"/>
					<fo:region-end region-name="right-region" extent="{$marginLeftRight2}mm"/>
				</fo:simple-page-master>
				<!-- even pages Body -->
				<fo:simple-page-master master-name="even" page-width="{$pageWidth}mm" page-height="{$pageHeight}mm">
					<fo:region-body margin-top="{$marginTop}mm" margin-bottom="{$marginBottom}mm" margin-left="{$marginLeftRight2}mm" margin-right="{$marginLeftRight1}mm"/>
					<fo:region-before region-name="header-even" extent="{$marginTop}mm" display-align="center"/>
					<fo:region-after region-name="footer-even" extent="{$marginBottom}mm"/>
					<fo:region-start region-name="left-region" extent="{$marginLeftRight2}mm"/>
					<fo:region-end region-name="right-region" extent="{$marginLeftRight1}mm"/>
				</fo:simple-page-master>
				<fo:page-sequence-master master-name="document">
					<fo:repeatable-page-master-alternatives>
						<fo:conditional-page-master-reference odd-or-even="even" master-reference="even"/>
						<fo:conditional-page-master-reference odd-or-even="odd" master-reference="odd"/>
					</fo:repeatable-page-master-alternatives>
				</fo:page-sequence-master>
			</fo:layout-master-set>

			<fo:declarations>
				<xsl:call-template name="addPDFUAmeta"/>
			</fo:declarations>
			
			<xsl:call-template name="addBookmarks">
				<xsl:with-param name="contents" select="$contents"/>
			</xsl:call-template>
			
			
			<xsl:if test="$doctype = 'technical-report' or               $doctype = 'technical-paper' or              $doctype = 'implementers-guide'">
				<fo:page-sequence master-reference="TR-first-page">
					<fo:flow flow-name="xsl-region-body">						
							<fo:block>
								<fo:table width="175mm" table-layout="fixed" border-top="1.5pt solid black">									
									<fo:table-column column-width="29mm"/>
									<fo:table-column column-width="45mm"/>
									<fo:table-column column-width="28mm"/>
									<fo:table-column column-width="72mm"/>
									<fo:table-body>
										<fo:table-row>
											<fo:table-cell padding-left="1mm" padding-top="3mm">
													<fo:block font-weight="bold">Question(s):</fo:block>
											</fo:table-cell>
											<fo:table-cell padding-top="3mm">
													<fo:block><xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:ext/itu:editorialgroup/itu:group/itu:name"/></fo:block>
											</fo:table-cell>
											<fo:table-cell padding-top="3mm">
													<fo:block font-weight="bold">Meeting, date:</fo:block>
											</fo:table-cell>
											<fo:table-cell padding-top="3mm" text-align="right" padding-right="1mm">
												<fo:block>
													<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:ext/itu:meeting"/>
													<xsl:text>, </xsl:text>
													<xsl:call-template name="formatMeetingDate">
														<xsl:with-param name="date" select="/itu:itu-standard/itu:bibdata/itu:ext/itu:meeting-date/itu:from"/>
													</xsl:call-template>													
													<xsl:text>/</xsl:text>
													<xsl:call-template name="formatMeetingDate">
														<xsl:with-param name="date" select="/itu:itu-standard/itu:bibdata/itu:ext/itu:meeting-date/itu:to"/>
													</xsl:call-template>													
												</fo:block>
											</fo:table-cell>
										</fo:table-row>
									</fo:table-body>
								</fo:table>
								
								<fo:table width="175mm" table-layout="fixed">									
									<fo:table-column column-width="29mm"/>
									<fo:table-column column-width="10mm"/>
									<fo:table-column column-width="35mm"/>
									<fo:table-column column-width="9mm"/>
									<fo:table-column column-width="83mm"/>
									<fo:table-column column-width="6mm"/>
									<fo:table-body>										
										<fo:table-row>
											<fo:table-cell padding-left="1mm" padding-top="2mm">
												<fo:block font-weight="bold">Study Group:</fo:block>
											</fo:table-cell>
											<fo:table-cell padding-top="2mm">
												<fo:block><xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:ext/itu:editorialgroup/itu:subgroup/itu:name"/></fo:block>
											</fo:table-cell>
											<fo:table-cell padding-top="2mm">
												<fo:block font-weight="bold">Working Party:</fo:block>
											</fo:table-cell>
											<fo:table-cell padding-top="2mm">
												<fo:block><xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:ext/itu:editorialgroup/itu:workgroup/itu:name"/></fo:block>
											</fo:table-cell>
											<fo:table-cell padding-top="2mm">
												<fo:block font-weight="bold">Intended type of document <fo:inline font-weight="normal">(R-C-TD)</fo:inline>:</fo:block>
											</fo:table-cell>
											<fo:table-cell padding-top="2mm">
												<fo:block font-weight="normal"><xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:ext/itu:intended-type"/></fo:block>
											</fo:table-cell>
										</fo:table-row>
										<fo:table-row>
											<fo:table-cell padding-left="1mm" padding-top="2mm">
												<fo:block font-weight="bold">Source:</fo:block>
											</fo:table-cell>
											<fo:table-cell number-columns-spanned="4" padding-top="2mm">
												<fo:block><xsl:value-of select="java:toUpperCase(java:java.lang.String.new(/itu:itu-standard/itu:bibdata/itu:ext/itu:source))"/></fo:block>
											</fo:table-cell>
										</fo:table-row>
										<fo:table-row>
											<fo:table-cell padding-left="1mm" padding-top="2mm">
												<fo:block font-weight="bold">Title:</fo:block>
											</fo:table-cell>
											<fo:table-cell number-columns-spanned="4" padding-top="2mm">
												<fo:block role="H1"><xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:title[@language='en' and @type='main']"/></fo:block>
											</fo:table-cell>
										</fo:table-row>
									</fo:table-body>
								</fo:table>
								
								<xsl:if test="/itu:itu-standard/itu:bibdata/itu:contributor/itu:person">								
									<fo:table width="175mm" table-layout="fixed" line-height="110%">
										<fo:table-column column-width="29mm"/>
										<fo:table-column column-width="75mm"/>
										<fo:table-column column-width="71mm"/>									
										<fo:table-body>
										
											<xsl:for-each select="/itu:itu-standard/itu:bibdata/itu:contributor/itu:person">
											
										
												<fo:table-row border-top="1.5pt solid black">
													<xsl:if test="position() = last()">
														<xsl:attribute name="border-bottom">1.5pt solid black</xsl:attribute>
													</xsl:if>
													<fo:table-cell padding-left="1mm" padding-top="2.5mm">
														<fo:block font-weight="bold">Contact:</fo:block>
													</fo:table-cell>
													<fo:table-cell padding-top="3mm">
														<fo:block><xsl:value-of select="itu:name/itu:completename"/></fo:block>
														<fo:block><xsl:value-of select="itu:affiliation/itu:organization/itu:name"/></fo:block>
														<fo:block><xsl:value-of select="itu:affiliation/itu:organization/itu:address/itu:formattedAddress"/></fo:block>
													</fo:table-cell>
													<fo:table-cell padding-top="3mm">
														<fo:block>Tel: <xsl:value-of select="itu:phone[not(@type)]"/></fo:block>
														<fo:block>Fax: <xsl:value-of select="itu:phone[@type = 'fax']"/></fo:block>
														<fo:block>E-mail: <xsl:value-of select="itu:email"/></fo:block>
													</fo:table-cell>
												</fo:table-row>
											</xsl:for-each>											
										</fo:table-body>
									</fo:table>
								</xsl:if>
								<fo:block space-before="0.5mm" font-size="9pt" margin-left="1mm">Please do not change the structure of this table, just insert the necessary information.</fo:block>
								<fo:block space-before="6pt">&lt;INSERT TEXT&gt;</fo:block>
							</fo:block>
					</fo:flow>
				</fo:page-sequence>
			</xsl:if>
			
			<!-- ============================================= -->
			<!-- Cover page for service-publication -->
			<!-- ============================================= -->
			<xsl:if test="$doctype = 'service-publication'">
				<fo:page-sequence master-reference="SP-first-page" force-page-count="no-force">
					<fo:flow flow-name="xsl-region-body">
						<fo:block font-size="10pt" font-style="italic" text-align="center">
							<fo:block>
								<xsl:call-template name="getLocalizedString">
									<xsl:with-param name="key">annex_to_itu_ob</xsl:with-param>
								</xsl:call-template>
							</fo:block>
							<fo:block>
								<xsl:call-template name="getLocalizedString">
									<xsl:with-param name="key">number_abbrev</xsl:with-param>
								</xsl:call-template>
								<xsl:value-of select="/*/itu:bibdata/itu:docnumber"/>
								<xsl:text> – </xsl:text>
								<xsl:value-of select="translate(normalize-space(/*/itu:bibdata/itu:date[@type='published' and @format]),' ','')"/>
							</fo:block>
						</fo:block>
						
						<fo:block font-size="14pt" margin-top="7mm">
							<fo:block font-weight="bold">
								<fo:inline baseline-shift="-140%" padding-right="6mm">
									<xsl:if test="$lang = 'ar'">
										<xsl:attribute name="padding-right">0mm</xsl:attribute>
										<xsl:attribute name="padding-left">6mm</xsl:attribute>
									</xsl:if>
									<fo:instream-foreign-object content-height="18.5mm" content-width="16.1mm" fox:alt-text="Image Logo">
										<xsl:copy-of select="$Image-ITU-Globe-Logo"/>
									</fo:instream-foreign-object>
								</fo:inline>
								<xsl:variable name="itu_name">
									<xsl:call-template name="getLocalizedString">
										<xsl:with-param name="key">international_telecommunication_union</xsl:with-param>
									</xsl:call-template>
								</xsl:variable>
								<xsl:value-of select="java:toUpperCase(java:java.lang.String.new($itu_name))"/>
							</fo:block>
						</fo:block>
						<fo:block-container margin-left="10mm">
							<fo:block-container margin-left="0mm">
								
								<fo:block font-size="20pt" font-weight="bold" space-before="30mm">
									<xsl:call-template name="getLocalizedString">
										<xsl:with-param name="key">tsb</xsl:with-param>
									</xsl:call-template>
								</fo:block>
								<fo:block font-size="14pt" font-weight="bold">
									<xsl:variable name="tsb_full">
										<xsl:call-template name="getLocalizedString">
											<xsl:with-param name="key">tsb_full</xsl:with-param>
											<xsl:with-param name="formatted">true</xsl:with-param>
										</xsl:call-template>
									</xsl:variable>
									<xsl:value-of select="java:toUpperCase(java:java.lang.String.new($tsb_full))"/>
								</fo:block>
								<fo:block-container height="20mm" display-align="center">
									<fo:block font-weight="bold">
										<!-- complements -->
										<!-- To do: Example: COMPLEMENT  TO  ITU-T  RECOMMENDATIONS  F.69  (06/1994) AND  F.68  (11/1988) -->
									</fo:block>
								</fo:block-container>
								<fo:block-container>
									<fo:block font-size="1pt"><fo:leader leader-pattern="rule" leader-length="90%" rule-style="solid" rule-thickness="1pt"/></fo:block>
									<fo:block-container height="75mm" display-align="center">
										<xsl:variable name="title_main" select="/*/itu:bibdata/itu:title[@type='main' and @language = $lang]"/>
										<xsl:variable name="series_main" select="normalize-space(/*/itu:bibdata/itu:series[@type='main']/itu:title)"/>
										<xsl:variable name="series_secondary" select="normalize-space(/*/itu:bibdata/itu:series[@type='secondary']/itu:title)"/>
										<xsl:variable name="series_tertiary" select="normalize-space(/*/itu:bibdata/itu:series[@type='tertiary']/itu:title)"/>
										<fo:block font-weight="bold" role="H1">
											<xsl:choose>
												<xsl:when test="$series_main != '' and $series_secondary != '' and $series_tertiary = ''">
													<fo:block font-size="16pt">
														<xsl:value-of select="$series_main"/>
													</fo:block>
													<fo:block font-size="14pt">
														<xsl:if test="not(starts-with($series_secondary, '('))">
															<xsl:text>(</xsl:text>
														</xsl:if>
														<xsl:value-of select="$series_secondary"/>
														<xsl:if test="not(starts-with($series_secondary, '('))">
															<xsl:text>)</xsl:text>
														</xsl:if>
													</fo:block>
												</xsl:when>
												<xsl:when test="$series_main != '' and $series_secondary != '' and $series_tertiary != ''">
													<fo:block font-size="16pt">
														<xsl:value-of select="$series_main"/>
													</fo:block>
													<fo:block font-size="14pt">
														<xsl:if test="not(starts-with($series_secondary, '('))">
															<xsl:text>(</xsl:text>
														</xsl:if>
														<xsl:value-of select="$series_secondary"/>
														<xsl:if test="not(starts-with($series_secondary, '('))">
															<xsl:text>)</xsl:text>
														</xsl:if>
													</fo:block>
													<fo:block font-size="12pt" space-before="12pt" space-after="12pt">
														<xsl:value-of select="$series_tertiary"/>
													</fo:block>
													<fo:block font-size="16pt">
														<xsl:value-of select="$title_main"/>
													</fo:block>
												</xsl:when>
												<xsl:when test="$series_main != '' and $series_secondary = '' and $series_tertiary = ''">
													<fo:block font-size="16pt">
														<xsl:value-of select="$title_main"/>
													</fo:block>
													<fo:block font-size="14pt">
														<xsl:if test="not(starts-with($series_main, '('))">
															<xsl:text>(</xsl:text>
														</xsl:if>
														<xsl:value-of select="$series_main"/>
														<xsl:if test="not(starts-with($series_main, '('))">
															<xsl:text>)</xsl:text>
														</xsl:if>
													</fo:block>
												</xsl:when>
												<xsl:otherwise>
													<fo:block font-size="16pt">
														<xsl:value-of select="$title_main"/>
													</fo:block>
												</xsl:otherwise>
											</xsl:choose>
										</fo:block>
										
										<fo:block font-size="14pt">
										</fo:block>
										<fo:block font-size="14pt">
											<fo:block> </fo:block>
											<xsl:variable name="position-sp" select="/*/itu:bibdata/itu:title[@type='position-sp' and @language = $lang]"/>
											<xsl:value-of select="java:toUpperCase(java:java.lang.String.new($position-sp))"/>
										</fo:block>
									</fo:block-container>
									<fo:block font-size="1pt"><fo:leader leader-pattern="rule" leader-length="90%" rule-style="solid" rule-thickness="1pt"/></fo:block>
								</fo:block-container>
							
							</fo:block-container>
						</fo:block-container>
						
						<fo:block space-before="25mm" font-weight="bold">
							<xsl:variable name="placedate">
								<xsl:call-template name="getLocalizedString">
									<xsl:with-param name="key">placedate</xsl:with-param>
								</xsl:call-template>
							</xsl:variable>
							<xsl:variable name="year" select="substring(/*/itu:bibdata/itu:date[@type = 'published']/itu:on,1,4)"/>
							<xsl:if test="normalize-space($year) != ''">
								<xsl:value-of select="java:replaceAll(java:java.lang.String.new($placedate),'%',$year)"/>
							</xsl:if>
						</fo:block>
					</fo:flow>
				</fo:page-sequence>
			</xsl:if>
			<!-- ============================================= -->
			<!-- END Cover page for service-publication -->
			<!-- ============================================= -->
			
			
			<!-- ============================================= -->
			<!-- Cover page -->
			<!-- ============================================= -->
			<xsl:if test="$doctype != 'service-publication'">
				<!-- cover page -->
				<fo:page-sequence master-reference="cover-page" writing-mode="lr-tb">
					<xsl:if test="$doctype = 'resolution'">
						<xsl:attribute name="force-page-count">no-force</xsl:attribute>
					</xsl:if>
					<fo:flow flow-name="xsl-region-body">
					
						<fo:block-container absolute-position="fixed" top="265mm">
							<fo:block text-align="right" margin-right="19mm">
								<xsl:choose>
									<xsl:when test="$doctype = 'resolution'">
										<fo:external-graphic src="{concat('data:image/png;base64,', normalize-space($Image-Logo_resolution))}" content-height="21mm" content-width="scale-to-fit" scaling="uniform" fox:alt-text="Image Logo"/>
									</xsl:when>
									<xsl:otherwise>
										<fo:external-graphic src="{concat('data:image/png;base64,', normalize-space($Image-Logo))}" content-height="17.7mm" content-width="scale-to-fit" scaling="uniform" fox:alt-text="Image Logo"/>
									</xsl:otherwise>
								</xsl:choose>
								
							</fo:block>
						</fo:block-container>
					
						<fo:block-container absolute-position="fixed" left="-7mm" top="0" font-size="0">
							<fo:block text-align="left">
								<fo:external-graphic src="{concat('data:image/png;base64,', normalize-space($Image-Fond-Rec))}" width="43.6mm" content-height="299.2mm" content-width="scale-to-fit" scaling="uniform" fox:alt-text="Image Cover Page"/>
							</fo:block>
						</fo:block-container>
						<fo:block-container font-family="Arial">
							<xsl:variable name="annexid" select="normalize-space(/itu:itu-standard/itu:bibdata/itu:ext/itu:structuredidentifier/itu:annexid)"/>
							<fo:table width="100%" table-layout="fixed"> <!-- 175.4mm-->
								<fo:table-column column-width="25.2mm"/>
								<fo:table-column column-width="44.4mm"/>
								<fo:table-column column-width="35.8mm"/>
								<fo:table-column column-width="67mm"/>
								<fo:table-body>
									<fo:table-row height="37.5mm"> <!-- 42.5mm -->
										<fo:table-cell>
											<fo:block> </fo:block>
										</fo:table-cell>
										<fo:table-cell number-columns-spanned="3">
											<fo:block-container>
												<xsl:call-template name="setWritingMode"/>
												<fo:block font-family="Arial" font-size="13pt" font-weight="bold" color="gray"> <!--  margin-top="16pt" letter-spacing="4pt", Helvetica for letter-spacing working -->
													<fo:block><xsl:value-of select="$linebreak"/></fo:block>
													<xsl:call-template name="addLetterSpacing">
														<xsl:with-param name="text" select="/itu:itu-standard/itu:bibdata/itu:contributor[itu:role/@type='author']/itu:organization/itu:name"/>
													</xsl:call-template>
												</fo:block>
											</fo:block-container>
										</fo:table-cell>
									</fo:table-row>
									<fo:table-row>
										<fo:table-cell>
											<fo:block> </fo:block>
										</fo:table-cell>
										<fo:table-cell padding-top="2mm" padding-bottom="-1mm">
											<fo:block-container>
												<xsl:call-template name="setWritingMode"/>
												<fo:block font-family="Arial" font-size="36pt" font-weight="bold" margin-top="6pt" letter-spacing="2pt"> <!-- Helvetica for letter-spacing working -->
													<fo:block>
														<xsl:value-of select="substring-before(/itu:itu-standard/itu:bibdata/itu:docidentifier[@type = 'ITU'], ' ')"/>
													</fo:block>
												</fo:block>
											</fo:block-container>
										</fo:table-cell>
										<fo:table-cell padding-top="1mm" number-columns-spanned="2" padding-bottom="-1mm">
											<fo:block-container>
												<xsl:call-template name="setWritingMode"/>
												<fo:block font-size="30pt" font-weight="bold" text-align="right" margin-top="12pt" padding="0mm">
													<xsl:choose>
														<xsl:when test="$doctype = 'technical-report' or $doctype = 'technical-paper'">
															<xsl:value-of select="$doctypeTitle"/>
														</xsl:when>
														<xsl:when test="$doctype = 'implementers-guide'">
															<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:docidentifier[@type='ITU-Recommendation']"/>
															<xsl:text> </xsl:text>
															<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:ext/itu:doctype[@language = $lang]"/>
														</xsl:when>
														<xsl:when test="$doctype = 'resolution'"/>
														<xsl:when test="$doctype = 'recommendation-supplement'">
															<!-- Series L -->
															<xsl:variable name="title-series">
																<xsl:call-template name="getLocalizedString">
																	<xsl:with-param name="key">series</xsl:with-param>
																</xsl:call-template>
															</xsl:variable>
															<xsl:call-template name="capitalize">
																<xsl:with-param name="str" select="$title-series"/>
															</xsl:call-template>
															<xsl:text> </xsl:text>
															<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:series[@type='main']/itu:title[@type='abbrev']"/>
															<!-- Ex. Supplement 37 -->
															<fo:block font-size="18pt">
																<xsl:call-template name="getLocalizedString">
																	<xsl:with-param name="key">doctype_dict.recommendation-supplement</xsl:with-param>
																</xsl:call-template>
																<xsl:text> </xsl:text>
																<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:docnumber"/>
															</fo:block>
														</xsl:when>
														<xsl:otherwise>
															<xsl:value-of select="substring-after(/itu:itu-standard/itu:bibdata/itu:docidentifier[@type = 'ITU'], ' ')"/>
														</xsl:otherwise>
													</xsl:choose>
												</fo:block>
											</fo:block-container>
										</fo:table-cell>
									</fo:table-row>
									<fo:table-row height="17.2mm">
										<fo:table-cell>
											<fo:block> </fo:block>
										</fo:table-cell>
										<fo:table-cell font-size="10pt" number-columns-spanned="2" padding-top="1mm">
											<fo:block-container>
												<xsl:call-template name="setWritingMode"/>
												<fo:block>
													<xsl:text>TELECOMMUNICATION</xsl:text>
												</fo:block>
												<fo:block>
													<xsl:text>STANDARDIZATION SECTOR</xsl:text>
												</fo:block>
												<fo:block>
													<xsl:text>OF ITU</xsl:text>
												</fo:block>
											</fo:block-container>
										</fo:table-cell>
										<fo:table-cell text-align="right">
											<xsl:if test="$annexid != ''">
												<fo:block-container>
													<xsl:call-template name="setWritingMode"/>
													<fo:block font-size="18pt" font-weight="bold">
														<xsl:call-template name="getLocalizedString">
															<xsl:with-param name="key">annex</xsl:with-param>
														</xsl:call-template>
														<xsl:text> </xsl:text>
														<xsl:value-of select="$annexid"/>
													</fo:block>
												</fo:block-container>
											</xsl:if>
											<xsl:if test="$isAmendment != ''">
												<fo:block-container>
													<xsl:call-template name="setWritingMode"/>
													<fo:block font-size="18pt" font-weight="bold">
														<xsl:value-of select="$isAmendment"/>
													</fo:block>
												</fo:block-container>
											</xsl:if>
											<xsl:if test="$isCorrigendum != ''">
												<fo:block-container>
													<xsl:call-template name="setWritingMode"/>
													<fo:block font-size="18pt" font-weight="bold">
														<xsl:value-of select="$isCorrigendum"/>
													</fo:block>
												</fo:block-container>
											</xsl:if>
											<fo:block font-size="14pt">
												<xsl:choose>
													<xsl:when test="($doctype = 'technical-report' or $doctype = 'technical-paper') and /itu:itu-standard/itu:bibdata/itu:version/itu:revision-date">
														<xsl:text>(</xsl:text>
															<xsl:call-template name="formatMeetingDate">
																<xsl:with-param name="date" select="/itu:itu-standard/itu:bibdata/itu:version/itu:revision-date"/>
															</xsl:call-template>
														<xsl:text>)</xsl:text>
													</xsl:when>
													<xsl:otherwise>
														<xsl:call-template name="formatDate">
															<xsl:with-param name="date" select="/itu:itu-standard/itu:bibdata/itu:date[@type = 'published']/itu:on"/>
														</xsl:call-template>
													</xsl:otherwise>
												</xsl:choose>
											</fo:block>
										</fo:table-cell>
									</fo:table-row>
									<fo:table-row height="64mm"> <!-- 59mm -->
										<fo:table-cell>
											<fo:block> </fo:block>
										</fo:table-cell>
										<fo:table-cell font-size="16pt" number-columns-spanned="3" border-bottom="0.5mm solid black" padding-right="2mm" display-align="after">
											<fo:block-container>
												<xsl:call-template name="setWritingMode"/>
												<fo:block padding-bottom="7mm">
													<xsl:if test="$doctype = 'resolution'">
														<fo:block><xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:ext/itu:meeting"/></fo:block>
														<fo:block>
															<xsl:variable name="meeting-place" select="/itu:itu-standard/itu:bibdata/itu:ext/itu:meeting-place"/>
															<xsl:variable name="meeting-date_from" select="/itu:itu-standard/itu:bibdata/itu:ext/itu:meeting-date/itu:from"/>
															<xsl:variable name="meeting-date_from_year" select="substring($meeting-date_from, 1, 4)"/>
															<xsl:variable name="meeting-date_to" select="/itu:itu-standard/itu:bibdata/itu:ext/itu:meeting-date/itu:to"/>
															<xsl:variable name="meeting-date_to_year" select="substring($meeting-date_to, 1, 4)"/>
															
															<xsl:variable name="date_format">
																<xsl:choose>
																	<xsl:when test="$meeting-date_from_year = $meeting-date_to_year">ddMM</xsl:when>
																	<xsl:otherwise>ddMMyyyy</xsl:otherwise>
																</xsl:choose>
															</xsl:variable>
															<xsl:variable name="meeting-date_from_str">
																<xsl:call-template name="convertDate">
																	<xsl:with-param name="date" select="$meeting-date_from"/>
																	<xsl:with-param name="format" select="$date_format"/>
																</xsl:call-template>
															</xsl:variable>													

															<xsl:variable name="meeting-date_to_str">
																<xsl:call-template name="convertDate">
																	<xsl:with-param name="date" select="$meeting-date_to"/>
																	<xsl:with-param name="format" select="'ddMMyyyy'"/>
																</xsl:call-template>
															</xsl:variable>
															
															<xsl:value-of select="$meeting-place"/>
															<xsl:if test="$meeting-place != '' and (normalize-space($meeting-date_from_str) != '' or normalize-space($meeting-date_to_str != ''))">
																<xsl:text>, </xsl:text>
																<xsl:value-of select="$meeting-date_from_str"/>
																<xsl:if test="normalize-space($meeting-date_from_str) != '' and  normalize-space($meeting-date_to_str) != ''">
																<xsl:text> – </xsl:text>
																</xsl:if>
																<xsl:value-of select="$meeting-date_to_str"/>
															</xsl:if>
														</fo:block>
													</xsl:if>
													<fo:block text-transform="uppercase">
														<xsl:variable name="series_title" select="normalize-space(/itu:itu-standard/itu:bibdata/itu:series[@type = 'main']/itu:title[@type = 'full'])"/>
														<xsl:if test="$series_title != ''">
															<xsl:variable name="title">
																<xsl:if test="$doctype != 'resolution'">
																	<!-- <xsl:text>Series </xsl:text> -->
																	<xsl:call-template name="getLocalizedString">
																		<xsl:with-param name="key">series</xsl:with-param>
																	</xsl:call-template>
																	<xsl:text> </xsl:text>
																</xsl:if>
																<xsl:value-of select="$series_title"/>
															</xsl:variable>
															<xsl:value-of select="$title"/>												
														</xsl:if>
													</fo:block>
													<xsl:choose>
														<xsl:when test="$doctype = 'recommendation-supplement'"/>
														<xsl:otherwise>
															<xsl:if test="/itu:itu-standard/itu:bibdata/itu:series">
																<fo:block margin-top="6pt">
																	<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:series[@type = 'secondary']"/>
																	<xsl:if test="normalize-space(/itu:itu-standard/itu:bibdata/itu:series[@type = 'tertiary']) != ''">
																		<xsl:text> — </xsl:text>
																		<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:series[@type = 'tertiary']"/>
																	</xsl:if>
																</fo:block>
															</xsl:if>
														</xsl:otherwise>
													</xsl:choose>
												</fo:block>
											</fo:block-container>
										</fo:table-cell>
									</fo:table-row>
									<fo:table-row height="40mm">
										<fo:table-cell>
											<fo:block> </fo:block>
										</fo:table-cell>
										<fo:table-cell font-size="18pt" number-columns-spanned="3">
											<fo:block-container>
												<xsl:call-template name="setWritingMode"/>
												<fo:block padding-right="2mm" margin-top="6pt" role="H1">
													<xsl:if test="not(/itu:itu-standard/itu:bibdata/itu:title[@type = 'annex' and @language = 'en']) and $isAmendment = '' and $isCorrigendum = ''">
														<xsl:attribute name="font-weight">bold</xsl:attribute>
													</xsl:if>
													<xsl:if test="($doctype = 'technical-report' or $doctype = 'technical-paper') and /itu:itu-standard/itu:bibdata/itu:docnumber">
														<fo:block font-weight="bold">													
															<xsl:value-of select="$xSTR-ACRONYM"/>
														</fo:block>
													</xsl:if>
													<xsl:if test="$doctype = 'implementers-guide'">
														<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:ext/itu:doctype[@language = $lang]"/>
														<xsl:text> for </xsl:text>
													</xsl:if>
													<xsl:if test="$doctype = 'resolution'">
														<!-- Resolution 1 -->
														<xsl:value-of select="$doctypeTitle"/><xsl:text> </xsl:text><xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:ext/itu:structuredidentifier/itu:docnumber"/>
														<xsl:text> – </xsl:text>
													</xsl:if>
													<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:title[@type = 'main' and @language = 'en']"/>
												</fo:block>
												<xsl:for-each select="/itu:itu-standard/itu:bibdata/itu:title[@type = 'annex' and @language = 'en']">
													<fo:block font-weight="bold" role="H1">
														<xsl:value-of select="."/>
													</fo:block>
												</xsl:for-each>
												<xsl:if test="$isAmendment != ''">
													<fo:block padding-right="2mm" margin-top="6pt" font-weight="bold" role="H1">
														<xsl:value-of select="$isAmendment"/>
														<xsl:if test="/itu:itu-standard/itu:bibdata/itu:title[@type = 'amendment']">
															<xsl:text>: </xsl:text>
															<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:title[@type = 'amendment']"/>
														</xsl:if>
													</fo:block>
												</xsl:if>
												<xsl:if test="$isCorrigendum != ''">
													<fo:block padding-right="2mm" margin-top="6pt" font-weight="bold" role="H1">
														<xsl:value-of select="$isCorrigendum"/>
														<xsl:if test="/itu:itu-standard/itu:bibdata/itu:title[@type = 'corrigendum']">
															<xsl:text>: </xsl:text>
															<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:title[@type = 'corrigendum']"/>
														</xsl:if>
													</fo:block>
												</xsl:if>
											</fo:block-container>
										</fo:table-cell>
									</fo:table-row>
									<fo:table-row height="40mm">
										<fo:table-cell>
											<fo:block> </fo:block>
										</fo:table-cell>
										<fo:table-cell number-columns-spanned="3">
											<fo:block-container>
												<xsl:call-template name="setWritingMode"/>
												<xsl:choose>
													<xsl:when test="/itu:itu-standard/itu:boilerplate/itu:legal-statement/itu:clause[@id='draft-warning']">
														<xsl:attribute name="border">0.7mm solid black</xsl:attribute>
														<fo:block padding-top="3mm" margin-left="1mm" margin-right="1mm">
															<xsl:apply-templates select="/itu:itu-standard/itu:boilerplate/itu:legal-statement/itu:clause[@id='draft-warning']" mode="caution"/>
														</fo:block>
													</xsl:when>
													<xsl:otherwise>
														<fo:block> </fo:block>
													</xsl:otherwise>
												</xsl:choose>
											</fo:block-container>
										</fo:table-cell>
									</fo:table-row>
									<fo:table-row height="25mm">
										<fo:table-cell>
											<fo:block> </fo:block>
										</fo:table-cell>
										<fo:table-cell number-columns-spanned="3">
											<fo:block-container>
												<xsl:call-template name="setWritingMode"/>
												<fo:block font-size="16pt" margin-top="3pt">
													<xsl:if test="/itu:itu-standard/itu:boilerplate/itu:legal-statement/itu:clause[@id='draft-warning']">
														<xsl:attribute name="margin-top">6pt</xsl:attribute>
														<xsl:if test="$doctype = 'recommendation-supplement'">
															<xsl:attribute name="margin-top">12pt</xsl:attribute>
														</xsl:if>
													</xsl:if>
													
													<xsl:choose>
														<xsl:when test="$doctype = 'technical-report' or $doctype = 'technical-paper'">
															<xsl:if test="/itu:itu-standard/itu:bibdata/itu:status/itu:stage">
																<xsl:call-template name="capitalizeWords">
																	<xsl:with-param name="str" select="/itu:itu-standard/itu:bibdata/itu:status/itu:stage"/>
																</xsl:call-template>												
																<xsl:text> </xsl:text>
															</xsl:if>
															<xsl:value-of select="$doctypeTitle"/>
															<xsl:text>  </xsl:text>
															<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:docidentifier[@type='ITU']"/>
														</xsl:when>
														<xsl:when test="$doctype = 'implementers-guide'"/>
														<xsl:when test="$doctype = 'resolution'"/>
														<xsl:when test="$doctype = 'recommendation-supplement'">
															<xsl:if test="/itu:itu-standard/itu:bibdata/itu:status/itu:stage = 'draft'">Draft </xsl:if>
															<xsl:text>ITU-</xsl:text><xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:ext/itu:editorialgroup/itu:bureau"/><xsl:text> </xsl:text>
															<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:docidentifier[@type = 'ITU-Supplement']"/>
														</xsl:when>
														<xsl:otherwise>
															<xsl:value-of select="$doctypeTitle"/>
															<xsl:text>  </xsl:text>
															<xsl:if test="/itu:itu-standard/itu:bibdata/itu:contributor/itu:organization/itu:abbreviation">
																<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:contributor/itu:organization/itu:abbreviation"/>
																<xsl:text>-</xsl:text>
															</xsl:if>
															<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:ext/itu:structuredidentifier/itu:bureau"/>
															<xsl:text>  </xsl:text>
															<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:ext/itu:structuredidentifier/itu:docnumber"/>
														</xsl:otherwise>
													</xsl:choose>
													
													<xsl:if test="$annexid != ''">
														<xsl:text> — </xsl:text>
														<xsl:call-template name="getLocalizedString">
															<xsl:with-param name="key">annex</xsl:with-param>
														</xsl:call-template>
														<xsl:text> </xsl:text>
														<xsl:value-of select="$annexid"/>
													</xsl:if>
												</fo:block>
											</fo:block-container>
										</fo:table-cell>
									</fo:table-row>
								</fo:table-body>
							</fo:table>
						</fo:block-container>
					</fo:flow>
				</fo:page-sequence>
			</xsl:if>
			<!-- ============================================= -->
			<!-- END Cover page -->
			<!-- ============================================= -->
			
			
			<fo:page-sequence master-reference="document-preface" initial-page-number="1" format="i" force-page-count="no-force">
				<xsl:if test="$doctype = 'service-publication'">
					<xsl:attribute name="master-reference">document</xsl:attribute>
					<xsl:attribute name="format">1</xsl:attribute>
				</xsl:if>
				<xsl:choose>
					<xsl:when test="$doctype = 'service-publication'">
						<xsl:call-template name="insertHeaderFooterSP"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="insertHeaderFooter"/>
					</xsl:otherwise>
				</xsl:choose>
				
				<fo:flow flow-name="xsl-region-body">
				
					<xsl:if test="/itu:itu-standard/itu:preface/* or /itu:itu-standard/itu:bibdata/itu:keyword">
						<fo:block-container font-size="14pt" font-weight="bold">
							<xsl:choose>
								<xsl:when test="$doctype = 'implementers-guide'"/>
								<xsl:when test="$doctype = 'recommendation-supplement'">
									<fo:block>
										<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:docidentifier[@type = 'ITU-Supplement-Internal']"/>
									</fo:block>
								</xsl:when>
								<xsl:when test="$doctype = 'service-publication'"/>
								<xsl:otherwise>
									<fo:block>
										<xsl:value-of select="$doctypeTitle"/>
										<xsl:text> </xsl:text>
										<xsl:value-of select="$docname"/>
									</fo:block>
								</xsl:otherwise>
							</xsl:choose>
							<fo:block text-align="center" margin-top="15pt" margin-bottom="15pt" role="H1">
								<xsl:if test="$doctype = 'service-publication'">
									<xsl:attribute name="margin-top">0pt</xsl:attribute>
									<xsl:attribute name="margin-bottom">0pt</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:title[@type = 'main' and @language = $lang]"/>
							</fo:block>
						</fo:block-container>
						<!-- Summary, History ... -->
						<xsl:call-template name="processPrefaceSectionsDefault"/>
						
						<!-- Keywords -->
						<xsl:if test="/itu:itu-standard/itu:bibdata/itu:keyword">
							<fo:block font-size="12pt">
								<xsl:value-of select="$linebreak"/>
								<xsl:value-of select="$linebreak"/>
							</fo:block>
							<fo:block font-weight="bold" margin-top="18pt" margin-bottom="18pt">
								<xsl:call-template name="getLocalizedString">
									<xsl:with-param name="key">keywords</xsl:with-param>
								</xsl:call-template>
							</fo:block>
							<fo:block>
								<xsl:call-template name="insertKeywords"/>
							</fo:block>
						</xsl:if>
						
						<xsl:if test="$doctype != 'service-publication'">
							<fo:block break-after="page"/>
						</xsl:if>
					</xsl:if>
					
					
					<!-- FOREWORD -->
					<fo:block font-size="11pt" text-align="justify">
						<xsl:apply-templates select="/itu:itu-standard/itu:boilerplate/itu:legal-statement"/>
						<xsl:apply-templates select="/itu:itu-standard/itu:boilerplate/itu:license-statement"/>
						<xsl:apply-templates select="/itu:itu-standard/itu:boilerplate/itu:copyright-statement"/>
					</fo:block>
					
					<xsl:if test="$debug = 'true'">
						<xsl:text disable-output-escaping="yes">&lt;!--</xsl:text>
							DEBUG
							contents=<xsl:copy-of select="$contents"/>
						<xsl:text disable-output-escaping="yes">--&gt;</xsl:text>
					</xsl:if>
					
					<xsl:if test="$contents//item[@display = 'true'] and $doctype != 'resolution' and $doctype != 'service-publication'">
						<fo:block break-after="page"/>
							<fo:block-container>
								<fo:block role="TOC">
								<fo:block margin-top="6pt" text-align="center" font-weight="bold" role="H1">
									<xsl:call-template name="getLocalizedString">
										<xsl:with-param name="key">table_of_contents</xsl:with-param>
									</xsl:call-template>
								</fo:block>
								<fo:block margin-top="6pt" text-align="end" font-weight="bold">
									<xsl:call-template name="getLocalizedString">
										<xsl:with-param name="key">Page.sg</xsl:with-param>
									</xsl:call-template>
								</fo:block>
								
								<xsl:for-each select="$contents//item[@display = 'true']">									
									<fo:block role="TOCI">
										<xsl:if test="@level = 1">
											<xsl:attribute name="margin-top">6pt</xsl:attribute>
										</xsl:if>
										<xsl:if test="@level &gt;= 2">
											<xsl:attribute name="margin-top">4pt</xsl:attribute>
											<!-- <xsl:attribute name="margin-left">12mm</xsl:attribute> -->
										</xsl:if>
										<fo:list-block provisional-label-separation="3mm">
											<xsl:attribute name="provisional-distance-between-starts">
												<xsl:choose>
													<xsl:when test="@section != ''">
														<xsl:if test="@level = 1">
															<xsl:choose>
																<xsl:when test="string-length(@section) &gt; 10">27mm</xsl:when>
																<xsl:when test="string-length(@section) &gt; 5">22mm</xsl:when>
																<!-- <xsl:when test="@type = 'annex'">20mm</xsl:when> -->
																<xsl:otherwise>12mm</xsl:otherwise>
															</xsl:choose>
														</xsl:if>
														<xsl:if test="@level &gt;= 2"><xsl:value-of select="(@level - 1) * 26"/>mm</xsl:if>
													</xsl:when> <!--   -->
													<xsl:otherwise>0mm</xsl:otherwise>
												</xsl:choose>
											</xsl:attribute>
											<fo:list-item>
												<fo:list-item-label end-indent="label-end()">
													<xsl:if test="@level &gt;= 2">
														<xsl:attribute name="start-indent"><xsl:value-of select="(@level - 1) * 12"/>mm</xsl:attribute>
													</xsl:if>
													<fo:block>
														<xsl:if test="@section">															
															<xsl:value-of select="@section"/>
														</xsl:if>
													</fo:block>
												</fo:list-item-label>
													<fo:list-item-body start-indent="body-start()">
														<fo:block text-align-last="justify">															
															<fo:basic-link internal-destination="{@id}" fox:alt-text="{title}">
																<xsl:apply-templates select="title"/>
																<fo:inline keep-together.within-line="always">
																	<fo:leader leader-pattern="dots"/>
																	<fo:page-number-citation ref-id="{@id}"/>
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
									<fo:block margin-top="6pt" text-align="end" font-weight="bold" keep-with-next="always">
										<xsl:call-template name="getLocalizedString">
											<xsl:with-param name="key">Page.sg</xsl:with-param>
										</xsl:call-template>
									</fo:block>
									<fo:block-container>
										<xsl:for-each select="$contents//tables/table">
											<xsl:call-template name="insertListOf_Item"/>
										</xsl:for-each>
									</fo:block-container>
								</xsl:if>
								
								<!-- List of Figures -->
								<xsl:if test="$contents//figures/figure">
									<xsl:call-template name="insertListOf_Title">
										<xsl:with-param name="title" select="$title-list-figures"/>
									</xsl:call-template>
									<fo:block margin-top="6pt" text-align="end" font-weight="bold" keep-with-next="always">
										<xsl:call-template name="getLocalizedString">
											<xsl:with-param name="key">Page.sg</xsl:with-param>
										</xsl:call-template>
									</fo:block>
									<fo:block-container>
										<xsl:for-each select="$contents//figures/figure">
											<xsl:call-template name="insertListOf_Item"/>
										</xsl:for-each>
									</fo:block-container>
								</xsl:if>
							
							</fo:block>
						</fo:block-container>
					</xsl:if>
					
				</fo:flow>
			</fo:page-sequence>
			
			<!-- BODY -->
			<fo:page-sequence master-reference="document" initial-page-number="1" force-page-count="no-force">
				<xsl:if test="$doctype = 'service-publication'">
					<xsl:attribute name="initial-page-number">auto</xsl:attribute>
				</xsl:if>
				<fo:static-content flow-name="xsl-footnote-separator">
					<fo:block>
						<fo:leader leader-pattern="rule" leader-length="30%"/>
					</fo:block>
				</fo:static-content>
				<xsl:choose>
					<xsl:when test="$doctype = 'service-publication'">
						<xsl:call-template name="insertHeaderFooterSP"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="insertHeaderFooter"/>
					</xsl:otherwise>
				</xsl:choose>
				
				<fo:flow flow-name="xsl-region-body">
				
					<xsl:if test="$doctype != 'service-publication'">
						<fo:block-container font-size="14pt">
							<xsl:choose>
								<xsl:when test="$doctype = 'resolution'">
									<fo:block text-align="center">
										<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:title[@type='resolution' and @language = $lang]"/>
									</fo:block>
								</xsl:when>
								<xsl:when test="$doctype = 'implementers-guide'"/>
								<xsl:when test="$doctype = 'recommendation-supplement'">
									<fo:block font-weight="bold">
										<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:docidentifier[@type = 'ITU-Supplement-Internal']"/>
									</fo:block>
								</xsl:when>
								<xsl:otherwise>
									<fo:block font-weight="bold">
										<xsl:value-of select="$doctypeTitle"/>
										<xsl:text> </xsl:text>
										<xsl:value-of select="$docname"/>
									</fo:block>
								</xsl:otherwise>
							</xsl:choose>
							
							<fo:block font-weight="bold" text-align="center" margin-top="15pt" margin-bottom="15pt" role="H1">
								<xsl:value-of select="/itu:itu-standard/itu:bibdata/itu:title[@type = 'main' and @language = $lang]"/>
								
								<xsl:variable name="subtitle" select="/itu:itu-standard/itu:bibdata/itu:title[@type = 'subtitle' and @language = $lang]"/>
								<xsl:if test="$subtitle != ''">
									<fo:block margin-top="18pt" font-weight="normal" font-style="italic">
										<xsl:value-of select="$subtitle"/>
									</fo:block>								
								</xsl:if>
								
								<xsl:variable name="resolution-placedate" select="/itu:itu-standard/itu:bibdata/itu:title[@type = 'resolution-placedate' and @language = $lang]"/>
								<xsl:if test="$doctype = 'resolution' and $resolution-placedate != ''">
									<fo:block font-size="11pt" margin-top="6pt" font-weight="normal">
										<fo:inline font-style="italic">
											<xsl:text>(</xsl:text><xsl:value-of select="$resolution-placedate"/><xsl:text>)</xsl:text>
										</fo:inline>
										<xsl:apply-templates select="/itu:itu-standard/itu:bibdata/itu:note[@type = 'title-footnote']" mode="title_footnote"/>
									</fo:block>
								</xsl:if>
							</fo:block>
						</fo:block-container>
					</xsl:if>
					
					
					<!-- Clause(s) -->
					<fo:block>
						<!-- Scope -->
						<xsl:apply-templates select="/itu:itu-standard/itu:sections/itu:clause[@type='scope']"/> <!-- @id = 'scope' -->
							
						<!-- Normative references -->						
						<xsl:apply-templates select="/itu:itu-standard/itu:bibliography/itu:references[@normative='true']"/> <!-- @id = 'references' -->
							
						<xsl:apply-templates select="/itu:itu-standard/itu:sections/*[not(@type='scope')]"/> <!-- @id != 'scope' -->
							
						<xsl:apply-templates select="/itu:itu-standard/itu:annex"/>
						
						<!-- Bibliography -->
						<xsl:apply-templates select="/itu:itu-standard/itu:bibliography/itu:references[not(@normative='true')]"/> <!-- @id = 'bibliography' -->
					</fo:block>
					
				</fo:flow>
			</fo:page-sequence>
			
			
		</fo:root>
	</xsl:template> 

	<xsl:template name="insertListOf_Title">
		<xsl:param name="title"/>
		<fo:block space-before="36pt" text-align="center" font-weight="bold" keep-with-next="always">
			<xsl:value-of select="$title"/>
		</fo:block>
	</xsl:template>
	
	<xsl:template name="insertListOf_Item">
		<fo:block text-align-last="justify" margin-top="6pt" role="TOCI">
			<fo:basic-link internal-destination="{@id}">
				<xsl:call-template name="setAltText">
					<xsl:with-param name="value" select="@alt-text"/>
				</xsl:call-template>
				<xsl:apply-templates select="." mode="contents"/>
				<fo:inline keep-together.within-line="always">
					<fo:leader leader-pattern="dots"/>
					<fo:page-number-citation ref-id="{@id}"/>
				</fo:inline>
			</fo:basic-link>
		</fo:block>
	</xsl:template>

	<xsl:template match="node()">		
		<xsl:apply-templates/>			
	</xsl:template>
	
	<!-- ============================= -->
	<!-- CONTENTS                                       -->
	<!-- ============================= -->
	
	<!-- element with title -->
	<xsl:template match="*[itu:title]" mode="contents">
		<xsl:variable name="level">
			<xsl:call-template name="getLevel">
				<xsl:with-param name="depth" select="itu:title/@depth"/>
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:variable name="section">
			<!-- <xsl:call-template name="getSection"/> -->
			<xsl:for-each select="*[local-name() = 'title']/*[local-name() = 'tab'][1]/preceding-sibling::node()">
				<xsl:value-of select="."/>
			</xsl:for-each>
		</xsl:variable>
		
		<xsl:variable name="type">
			<xsl:value-of select="local-name()"/>
		</xsl:variable>
			
		<xsl:variable name="display">
			<xsl:choose>				
				<xsl:when test="$level &gt; $toc_level">false</xsl:when>
				<xsl:when test="$section = '' and $type = 'clause' and $level &gt;= 2">false</xsl:when>
				<xsl:otherwise>true</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="skip">
			<xsl:choose>
				<xsl:when test="ancestor-or-self::itu:bibitem">true</xsl:when>
				<xsl:when test="ancestor-or-self::itu:term">true</xsl:when>
				<xsl:when test="@inline-header = 'true' and not(*[local-name() = 'title']/*[local-name() = 'tab'])">true</xsl:when>
				<xsl:otherwise>false</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:if test="$skip = 'false'">		
			
			<xsl:variable name="title">
				<xsl:call-template name="getName"/>
			</xsl:variable>
			
			<item level="{$level}" section="{$section}" type="{$type}" display="{$display}">
				<xsl:call-template name="setId"/>
				<title>
					<xsl:apply-templates select="xalan:nodeset($title)" mode="contents_item"/>
				</title>
				<xsl:apply-templates mode="contents"/>
			</item>
			
		</xsl:if>	
		
	</xsl:template>

	<xsl:template match="itu:strong" mode="contents_item" priority="2">
		<xsl:apply-templates mode="contents_item"/>
	</xsl:template>
	
	<xsl:template match="itu:br" mode="contents_item" priority="2">
		<fo:inline> </fo:inline>
	</xsl:template>


	<xsl:template match="itu:references" mode="contents">
		<xsl:apply-templates mode="contents"/>			
	</xsl:template>
	
	
	<!-- ============================= -->
	<!-- ============================= -->

	
	<!-- ============================= -->
	<!-- PREFACE (Summary, History, ...)          -->
	<!-- ============================= -->
	
	<!-- Summary -->
	<xsl:template match="itu:itu-standard/itu:preface/itu:abstract[@id = '_summary']" priority="3">
		<fo:block font-size="12pt">
			<xsl:value-of select="$linebreak"/>
			<xsl:value-of select="$linebreak"/>
		</fo:block>
		<fo:block font-weight="bold" margin-top="18pt" margin-bottom="18pt">			
			<xsl:variable name="title-summary">
				<xsl:call-template name="getTitle">
					<xsl:with-param name="name" select="'title-summary'"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:value-of select="$title-summary"/>
		</fo:block>
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="itu:preface/itu:clause" priority="3">
		<xsl:if test="$doctype != 'service-publication'">
			<fo:block font-size="12pt">
				<xsl:value-of select="$linebreak"/>
				<xsl:value-of select="$linebreak"/>
			</fo:block>
		</xsl:if>
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="itu:preface//itu:title" priority="3">
		<!-- <xsl:if test="$doctype = 'service-publication'">
			<fo:block>&#xa0;</fo:block>
			<fo:block>&#xa0;</fo:block>
		</xsl:if> -->
		<xsl:variable name="level">
			<xsl:call-template name="getLevel"/>
		</xsl:variable>
		<fo:block font-weight="bold" margin-top="18pt" margin-bottom="18pt" keep-with-next="always" role="H{$level}">
			<xsl:if test="$doctype = 'service-publication'">
				<xsl:attribute name="margin-top">24pt</xsl:attribute>
				<xsl:attribute name="margin-bottom">12pt</xsl:attribute>
				<xsl:attribute name="font-size">12pt</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates/>
			<xsl:apply-templates select="following-sibling::*[1][local-name() = 'variant-title'][@type = 'sub']" mode="subtitle"/>
		</fo:block>
		<!-- <xsl:if test="$doctype = 'service-publication'">
			<fo:block keep-with-next="always">&#xa0;</fo:block>
		</xsl:if> -->
	</xsl:template>
	<!-- ============================= -->
	<!-- ============================= -->
	
	
	<!-- ============================= -->
	<!-- PARAGRAPHS                                    -->
	<!-- ============================= -->	
	<xsl:template match="itu:p | itu:sections/itu:p" name="paragraph">
		<xsl:param name="split_keep-within-line"/>
		<xsl:variable name="previous-element" select="local-name(preceding-sibling::*[1])"/>
		<xsl:variable name="element-name">
			<xsl:choose>
				<xsl:when test="../@inline-header = 'true' and $previous-element = 'title'">fo:inline</xsl:when> <!-- first paragraph after inline title -->
				<xsl:otherwise>fo:block</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:element name="{$element-name}">
			<xsl:attribute name="margin-top">6pt</xsl:attribute>
			<xsl:if test="@keep-with-next = 'true'">
				<xsl:attribute name="keep-with-next">always</xsl:attribute>
			</xsl:if>
			<xsl:if test="@class='supertitle'">
				<xsl:attribute name="space-before">36pt</xsl:attribute>
				<xsl:attribute name="margin-bottom">24pt</xsl:attribute>
				<xsl:attribute name="margin-top">0pt</xsl:attribute>
				<xsl:attribute name="font-size">14pt</xsl:attribute>
				
			</xsl:if>
			<xsl:attribute name="text-align">
				<xsl:choose>
					<xsl:when test="@class='supertitle'">center</xsl:when>
					<!-- <xsl:when test="@align"><xsl:value-of select="@align"/></xsl:when> -->
					<xsl:when test="@align"><xsl:call-template name="setAlignment"/></xsl:when>
					<xsl:when test="ancestor::*[1][local-name() = 'td']/@align">
						<!-- <xsl:value-of select="ancestor::*[1][local-name() = 'td']/@align"/> -->
						<xsl:call-template name="setAlignment">
							<xsl:with-param name="align" select="ancestor::*[1][local-name() = 'td']/@align"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="ancestor::*[1][local-name() = 'th']/@align">
						<!-- <xsl:value-of select="ancestor::*[1][local-name() = 'th']/@align"/> -->
						<xsl:call-template name="setAlignment">
							<xsl:with-param name="align" select="ancestor::*[1][local-name() = 'th']/@align"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>justify</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			
			<xsl:if test="not(preceding-sibling::*) and parent::itu:li and $doctype = 'service-publication'">
				<fo:inline padding-right="9mm">
					<xsl:if test="$lang = 'ar'">
						<xsl:attribute name="padding-right">0mm</xsl:attribute>
						<xsl:attribute name="padding-left">9mm</xsl:attribute>
					</xsl:if>
					<xsl:for-each select="parent::itu:li">
						<xsl:call-template name="getListItemFormat"/>
					</xsl:for-each>
				</fo:inline>
			</xsl:if>
			
			<xsl:apply-templates>
				<xsl:with-param name="split_keep-within-line" select="$split_keep-within-line"/>
			</xsl:apply-templates>
		</xsl:element>
		<xsl:if test="$element-name = 'fo:inline'">
			<fo:block><xsl:value-of select="$linebreak"/></fo:block>
		</xsl:if>
	</xsl:template>

	
	<!-- ============================= -->
	<!-- ============================= -->
	
	

	<xsl:template match="itu:clause[@id='draft-warning']/itu:title" mode="caution">
		<fo:block font-size="16pt" font-family="Times New Roman" font-style="italic" font-weight="bold" text-align="center" space-after="6pt" role="H1">
			<xsl:apply-templates/>
			<xsl:apply-templates select="following-sibling::*[1][local-name() = 'variant-title'][@type = 'sub']" mode="subtitle"/>
		</fo:block>
	</xsl:template>
	
	<xsl:template match="itu:clause[@id='draft-warning']/itu:p" mode="caution">
		<fo:block font-size="12pt" font-family="Times New Roman" text-align="justify">
			<xsl:apply-templates/>
			<xsl:apply-templates select="following-sibling::*[1][local-name() = 'variant-title'][@type = 'sub']" mode="subtitle"/>
		</fo:block>
	</xsl:template>
	
	<!-- ====== -->
	<!-- title      -->
	<!-- ====== -->	
	<xsl:template match="itu:annex/itu:title">
		<fo:block font-size="14pt" font-weight="bold" text-align="center" margin-bottom="18pt" role="H1">			
			<fo:block>
				<xsl:apply-templates/>
				<xsl:apply-templates select="following-sibling::*[1][local-name() = 'variant-title'][@type = 'sub']" mode="subtitle"/>
			</fo:block>
			<xsl:if test="$doctype != 'resolution'">
				<fo:block font-size="12pt" font-weight="normal" margin-top="6pt">
					<xsl:choose>
						<xsl:when test="parent::*[@obligation = 'informative']">
							<xsl:text>(This appendix does not form an integral part of this Recommendation.)</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>(This annex forms an integral part of this Recommendation.)</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</fo:block>
			</xsl:if>
		</fo:block>
	</xsl:template>
	
	<!-- Bibliography -->
	<xsl:template match="itu:references[not(@normative='true')]/itu:title">
		<fo:block font-size="14pt" font-weight="bold" text-align="center" margin-bottom="18pt" role="H1">
			<xsl:if test="$doctype = 'implementers-guide'">
				<xsl:attribute name="text-align">left</xsl:attribute>
				<xsl:attribute name="font-size">12pt</xsl:attribute>
				<xsl:attribute name="margin-bottom">12pt</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	
	<xsl:template match="itu:title" name="title">
		
		<xsl:variable name="level">
			<xsl:call-template name="getLevel"/>
		</xsl:variable>
		
		<xsl:variable name="font-size">
			<xsl:choose>
				<xsl:when test="$level = 1 and $doctype = 'resolution'">14pt</xsl:when>
				<xsl:when test="$doctype = 'service-publication'">11pt</xsl:when>
				<xsl:when test="$level &gt;= 2 and $doctype = 'resolution' and ../@inline-header = 'true'">11pt</xsl:when>
				<xsl:when test="$level = 2">12pt</xsl:when>
				<xsl:when test="$level &gt;= 3">12pt</xsl:when>
				<xsl:otherwise>12pt</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="element-name">
			<xsl:choose>
				<xsl:when test="../@inline-header = 'true'">fo:inline</xsl:when>
				<xsl:otherwise>fo:block</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="space-before">
			<xsl:choose>
					<xsl:when test="$level = 1 and $doctype = 'service-publication'">12pt</xsl:when>
					<xsl:when test="$level = '' or $level = 1">18pt</xsl:when>
					<xsl:when test="$level = 2">12pt</xsl:when>
					<xsl:otherwise>6pt</xsl:otherwise>
				</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="space-after">
			<xsl:choose>
				<xsl:when test="$level = 1 and $doctype = 'resolution'">24pt</xsl:when>
				<xsl:when test="$level = 1 and $doctype = 'service-publication'">12pt</xsl:when>
				<xsl:when test="$level = 2">6pt</xsl:when>
				<xsl:otherwise>6pt</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="text-align">
			<xsl:choose>
				<xsl:when test="$level = 1 and $doctype = 'resolution'">center</xsl:when>
				<xsl:when test="$lang = 'ar'">start</xsl:when>
				<xsl:otherwise>left</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:element name="{$element-name}">
			<xsl:attribute name="font-size"><xsl:value-of select="$font-size"/></xsl:attribute>
			<xsl:attribute name="font-weight">bold</xsl:attribute>
			<xsl:attribute name="text-align"><xsl:value-of select="$text-align"/></xsl:attribute>
			<xsl:attribute name="space-before"><xsl:value-of select="$space-before"/></xsl:attribute>
			<xsl:attribute name="space-after"><xsl:value-of select="$space-after"/></xsl:attribute>
			<xsl:attribute name="keep-with-next">always</xsl:attribute>
			<xsl:if test="$element-name = 'fo:inline'">
				<xsl:attribute name="padding-right">
					<xsl:choose>
						<xsl:when test="$level = 2">9mm</xsl:when>
						<xsl:when test="$level = 3">6.5mm</xsl:when>
						<xsl:otherwise>4mm</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="role">H<xsl:value-of select="$level"/></xsl:attribute>
			<xsl:apply-templates/>
			<xsl:apply-templates select="following-sibling::*[1][local-name() = 'variant-title'][@type = 'sub']" mode="subtitle"/>
		</xsl:element>
		
		<xsl:if test="$element-name = 'fo:inline' and not(following-sibling::itu:p)">
			<fo:block margin-bottom="12pt"><xsl:value-of select="$linebreak"/></fo:block>
		</xsl:if>
		
	</xsl:template>
	
	
	<!-- ====== -->
	<!-- ====== -->
	
	<xsl:template match="itu:legal-statement//itu:p | itu:license-statement//itu:p" priority="2">
		<fo:block margin-top="6pt">
			<xsl:apply-templates/>
		</fo:block>
		<xsl:if test="not(following-sibling::itu:p)"> <!-- last para -->
			<fo:block margin-top="6pt"> </fo:block>
			<fo:block margin-top="6pt"> </fo:block>
			<fo:block margin-top="6pt"> </fo:block>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="itu:copyright-statement//itu:p" priority="2">
		<fo:block>
			<xsl:if test="not(preceding-sibling::itu:p)"> <!-- first para -->
				<xsl:attribute name="text-align">center</xsl:attribute>
				<xsl:attribute name="margin-top">6pt</xsl:attribute>
				<xsl:attribute name="margin-bottom">14pt</xsl:attribute>
				<xsl:attribute name="keep-with-next">always</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	
	
	<xsl:template match="itu:preferred" priority="2">		
		<!-- DEBUG need -->
		<xsl:variable name="level">
			<xsl:call-template name="getLevel"/>
		</xsl:variable>
		<xsl:variable name="levelTerm">
			<xsl:call-template name="getLevelTermName"/>
		</xsl:variable>
		<fo:block space-before="6pt" text-align="justify" role="H{$levelTerm}">
			<fo:inline padding-right="5mm" font-weight="bold">				
				<!-- level=<xsl:value-of select="$level"/> -->
				<xsl:attribute name="padding-right">
					<xsl:choose>
						<xsl:when test="$level = 4">2mm</xsl:when>
						<xsl:when test="$level = 3">4mm</xsl:when>
						<xsl:otherwise>5mm</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:apply-templates select="ancestor::itu:term[1]/itu:name"/>
			</fo:inline>
			<fo:inline font-weight="bold">
				<xsl:call-template name="setStyle_preferred"/>
				<xsl:apply-templates/>
			</fo:inline>
			<xsl:if test="../itu:termsource/itu:origin">
				<xsl:text>: </xsl:text>
				<xsl:variable name="citeas" select="../itu:termsource/itu:origin/@citeas"/>
				<xsl:variable name="bibitemid" select="../itu:termsource/itu:origin/@bibitemid"/>
				<xsl:variable name="origin_text" select="normalize-space(../itu:termsource/itu:origin/text())"/>
				
				<fo:basic-link internal-destination="{$bibitemid}" fox:alt-text="{$citeas}">
					<xsl:choose>
						<xsl:when test="$origin_text != ''">
							<xsl:text> </xsl:text><xsl:apply-templates select="../itu:termsource/itu:origin/node()"/>
						</xsl:when>
						<xsl:when test="contains($citeas, '[')">
							<xsl:text> </xsl:text><xsl:value-of select="$citeas"/> <!--  disable-output-escaping="yes" -->
						</xsl:when>
						<xsl:otherwise>
							<xsl:text> [</xsl:text><xsl:value-of select="$citeas"/><xsl:text>]</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</fo:basic-link>
			</xsl:if>			
			<xsl:if test="following-sibling::itu:definition/node()">
				<xsl:text>: </xsl:text>
				<xsl:apply-templates select="following-sibling::itu:definition/node()" mode="process"/>			
			</xsl:if>			
		</fo:block>
		<!-- <xsl:if test="following-sibling::itu:table">
			<fo:block space-after="18pt">&#xA0;</fo:block>
		</xsl:if> -->
	</xsl:template> <!-- preferred -->
	
	<xsl:template match="itu:term[itu:preferred]/itu:termsource" priority="2"/>
	
	
	<xsl:template match="itu:definition/itu:p" priority="2"/>
	<xsl:template match="itu:definition/itu:formula" priority="2"/>
	
	<xsl:template match="itu:definition/itu:p" mode="process" priority="2">
		<xsl:choose>
			<xsl:when test="position() = 1">
				<fo:inline>
					<xsl:apply-templates/>
				</fo:inline>
			</xsl:when>
			<xsl:otherwise>
				<fo:block margin-top="6pt" text-align="justify">
					<xsl:apply-templates/>						
				</fo:block>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="itu:definition/*" mode="process">
		<xsl:apply-templates select="."/>
	</xsl:template>

	<!-- footnotes for title -->
	<xsl:template match="itu:bibdata/itu:note[@type = 'title-footnote']" mode="title_footnote">
		<xsl:variable name="number" select="position()"/>
		<fo:footnote>
			<fo:inline font-size="60%" keep-with-previous.within-line="always" vertical-align="super">
				<fo:basic-link internal-destination="title_footnote_{$number}" fox:alt-text="titlefootnote  {$number}">
					<xsl:value-of select="$number"/>
				</fo:basic-link>
				<xsl:if test="position() != last()">,</xsl:if><!-- <fo:inline  baseline-shift="20%">,</fo:inline> -->
			</fo:inline>
			<fo:footnote-body>
				<fo:block font-size="11pt" margin-bottom="12pt" text-align="justify">
					<fo:inline id="title_footnote_{$number}" font-size="85%" padding-right="2mm" keep-with-next.within-line="always" baseline-shift="30%">
						<xsl:value-of select="$number"/>
					</fo:inline>
					<xsl:apply-templates/>
				</fo:block>
			</fo:footnote-body>
		</fo:footnote>
	</xsl:template>

	
	
	<xsl:template match="*[local-name()='tt']" priority="2">
		<xsl:variable name="element-name">
			<xsl:choose>
				<xsl:when test="ancestor::itu:dd">fo:inline</xsl:when>
				<xsl:when test="ancestor::itu:title">fo:inline</xsl:when>
				<xsl:when test="normalize-space(ancestor::itu:p[1]//text()[not(parent::itu:tt)]) != ''">fo:inline</xsl:when>
				<xsl:otherwise>fo:block</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:element name="{$element-name}">
			<xsl:attribute name="font-family">Courier New, <xsl:value-of select="$font_noto_sans_mono"/></xsl:attribute>
			<xsl:attribute name="font-size">10pt</xsl:attribute>
			<xsl:if test="local-name(..) != 'dt' and not(ancestor::itu:dd) and not(ancestor::itu:title)">
				<xsl:attribute name="text-align">center</xsl:attribute>
			</xsl:if>
			<xsl:if test="ancestor::itu:title">
				<xsl:attribute name="font-size">11pt</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>

	
	<xsl:template match="itu:ul | itu:ol | itu:sections/itu:ul | itu:sections/itu:ol" mode="list" priority="2">
		<xsl:if test="preceding-sibling::*[1][local-name() = 'title'] and $doctype != 'service-publication'">
			<fo:block padding-top="-8pt" font-size="1pt"> </fo:block>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="$doctype = 'service-publication'">
				<xsl:apply-templates select="node()[not(local-name() = 'note')]"/>
			</xsl:when>
			<xsl:otherwise>
				<fo:list-block>
					<xsl:if test="$doctype = 'service-publication'">
						<xsl:attribute name="provisional-distance-between-starts">0mm</xsl:attribute>
					</xsl:if>
					<xsl:apply-templates select="node()[not(local-name() = 'note')]"/>
				</fo:list-block>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates select="./itu:note"/>
		<xsl:if test="../@inline-header='true'">
			<fo:block><xsl:value-of select="$linebreak"/></fo:block>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="itu:ul//itu:note  | itu:ol//itu:note" priority="2">
		<fo:block id="{@id}">
			<xsl:apply-templates select="itu:name"/>
			<xsl:apply-templates select="node()[not(local-name() = 'name')]"/>
		</fo:block>
	</xsl:template>
	
	<xsl:template match="itu:ul//itu:note/itu:p  | itu:ol//itu:note/itu:p" priority="3">		
		<fo:block font-size="11pt" margin-top="4pt">			
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	
	<xsl:template match="itu:li" priority="2">
		<xsl:choose>
			<xsl:when test="$doctype = 'service-publication'">
				<fo:block id="{@id}">
					<xsl:apply-templates select="node()[not(local-name() = 'note')]"/>
					<xsl:apply-templates select="./itu:note"/>
				</fo:block>
				<xsl:if test="following-sibling::itu:li">
					<fo:block> </fo:block>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<fo:list-item>
					<xsl:copy-of select="@id"/>
					<fo:list-item-label end-indent="label-end()">
						<fo:block>
							<xsl:call-template name="getListItemFormat"/>
						</fo:block>
					</fo:list-item-label>
					<fo:list-item-body start-indent="body-start()">
						<fo:block-container>
							<xsl:if test="$doctype = 'service-publication'">
								<xsl:attribute name="margin-bottom">12pt</xsl:attribute>
							</xsl:if>
							<xsl:variable name="attribute-margin">
								<xsl:choose>
									<xsl:when test="$lang = 'ar'">margin-right</xsl:when>
									<xsl:otherwise>margin-left</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<xsl:if test="../preceding-sibling::*[1][local-name() = 'title']">
								<xsl:attribute name="{$attribute-margin}">18mm</xsl:attribute>
							</xsl:if>
							<xsl:if test="local-name(..) = 'ul'">
								<xsl:attribute name="{$attribute-margin}">7mm</xsl:attribute>
								<xsl:if test="ancestor::itu:table">
									<xsl:attribute name="{$attribute-margin}">4.5mm</xsl:attribute>
								</xsl:if>
							</xsl:if>
							
							<fo:block-container margin-left="0mm" margin-right="0mm">
								<fo:block>
									
									<xsl:apply-templates select="node()[not(local-name() = 'note')]"/>
									<xsl:apply-templates select="./itu:note"/>
								</fo:block>
							</fo:block-container>
						</fo:block-container>
					</fo:list-item-body>
				</fo:list-item>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="itu:li//itu:p[not(parent::itu:dd)]">
		<fo:block margin-bottom="0pt"> <!-- margin-bottom="6pt" -->
			<!-- <xsl:if test="local-name(ancestor::itu:li[1]/..) = 'ul'">
				<xsl:attribute name="margin-bottom">0pt</xsl:attribute>
			</xsl:if> -->
			<xsl:if test="not(preceding-sibling::*) and parent::itu:li and $doctype = 'service-publication'">
				<fo:inline padding-right="9mm">
					<xsl:if test="$lang = 'ar'">
						<xsl:attribute name="padding-right">0mm</xsl:attribute>
						<xsl:attribute name="padding-left">9mm</xsl:attribute>
					</xsl:if>
					<xsl:for-each select="parent::itu:li">
						<xsl:call-template name="getListItemFormat"/>
					</xsl:for-each>
				</fo:inline>
			</xsl:if>
			
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	
	<xsl:template match="itu:link" priority="2">
		<fo:inline color="blue">
			<xsl:if test="local-name(..) = 'formattedref' or ancestor::itu:preface">
				<xsl:attribute name="text-decoration">underline</xsl:attribute>
				<!-- <xsl:attribute name="font-family">Arial</xsl:attribute>
				<xsl:attribute name="font-size">8pt</xsl:attribute> -->
			</xsl:if>
			<xsl:call-template name="link"/>
		</fo:inline>
	</xsl:template>
	

<!-- 	
	<xsl:template match="itu:annex/itu:clause">
		<xsl:apply-templates />
	</xsl:template> -->
	
	<!-- Clause without title -->
<!-- 	<xsl:template match="itu:clause[not(itu:title)]">
		
		<xsl:variable name="section">
			<xsl:for-each select="*[1]">
				<xsl:call-template name="getSection">
					<xsl:with-param name="sectionNum" select="$sectionNum"/>
				</xsl:call-template>
			</xsl:for-each>
		</xsl:variable>
		<fo:block space-before="12pt" space-after="18pt" font-weight="bold">
			<fo:inline id="{@id}"><xsl:value-of select="$section"/></fo:inline>
		</fo:block>
		<xsl:apply-templates />			
	</xsl:template> -->


	
		
	<xsl:template name="insertHeaderFooter">
		<fo:static-content flow-name="footer-even" font-family="Times New Roman" font-size="11pt" role="artifact">
			<fo:block-container height="19mm" display-align="after">
				<fo:table table-layout="fixed" width="100%" display-align="after">
					<fo:table-column column-width="10%"/>
					<fo:table-column column-width="90%"/>
					<fo:table-body>
						<fo:table-row>
							<fo:table-cell text-align="start" padding-bottom="8mm">
								<fo:block><fo:page-number/></fo:block>
							</fo:table-cell>
							<fo:table-cell font-weight="bold" text-align="start" padding-bottom="8mm">
								<fo:block><xsl:value-of select="$footer-text"/></fo:block>
							</fo:table-cell>
						</fo:table-row>
					</fo:table-body>
				</fo:table>
			</fo:block-container>
		</fo:static-content>
		<fo:static-content flow-name="footer-odd" font-family="Times New Roman" font-size="11pt" role="artifact">
			<fo:block-container height="19mm" display-align="after">
				<fo:table table-layout="fixed" width="100%" display-align="after">
					<fo:table-column column-width="90%"/>
					<fo:table-column column-width="10%"/>
					<fo:table-body>
						<fo:table-row>
							<fo:table-cell font-weight="bold" text-align="end" padding-bottom="8mm">
								<fo:block><xsl:value-of select="$footer-text"/></fo:block>
							</fo:table-cell>
							<fo:table-cell text-align="end" padding-bottom="8mm" padding-right="2mm">
								<fo:block><fo:page-number/></fo:block>
							</fo:table-cell>
						</fo:table-row>
					</fo:table-body>
				</fo:table>
			</fo:block-container>
		</fo:static-content>
	</xsl:template>

	<xsl:template name="insertHeaderFooterSP">
		<fo:static-content flow-name="footer-even" role="artifact">
			<fo:block-container height="20mm">
				<fo:table table-layout="fixed" width="100%" margin-top="3mm">
					<fo:table-column column-width="proportional-column-width(2)"/>
					<fo:table-column column-width="proportional-column-width(2)"/>
					<fo:table-column column-width="proportional-column-width(2)"/>
					<fo:table-body>
						<fo:table-row>
							<fo:table-cell text-align="start" font-size="10pt" display-align="center">
								<fo:block><xsl:value-of select="$footer-text"/></fo:block>
							</fo:table-cell>
							<fo:table-cell text-align="center">
								<fo:block>– <fo:page-number/> –</fo:block>
							</fo:table-cell>
							<fo:table-cell>
								<fo:block> </fo:block>
							</fo:table-cell>
						</fo:table-row>
					</fo:table-body>
				</fo:table>
			</fo:block-container>
		</fo:static-content>
		<fo:static-content flow-name="footer-odd" role="artifact">
			<fo:block-container height="20mm">
				<fo:table table-layout="fixed" width="100%" margin-top="3mm">
					<fo:table-column column-width="proportional-column-width(2)"/>
					<fo:table-column column-width="proportional-column-width(2)"/>
					<fo:table-column column-width="proportional-column-width(2)"/>
					<fo:table-body>
						<fo:table-row>
							<fo:table-cell text-align="start" font-size="10pt" display-align="center">
								<fo:block><xsl:value-of select="$footer-text"/></fo:block>
							</fo:table-cell>
							<fo:table-cell text-align="center">
								<fo:block>– <fo:page-number/> –</fo:block>
							</fo:table-cell>
							<fo:table-cell>
								<fo:block> </fo:block>
							</fo:table-cell>
						</fo:table-row>
					</fo:table-body>
				</fo:table>
			</fo:block-container>
		</fo:static-content>
	</xsl:template>

	
	<xsl:variable name="Image-Fond-Rec">
		<xsl:text>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</xsl:text>
	</xsl:variable>
	
	<xsl:variable name="Image-Logo">
		<xsl:text>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</xsl:text>
	</xsl:variable>
	
	<xsl:variable name="Image-Logo_resolution">
		<xsl:text>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</xsl:text>
	</xsl:variable>
	
	<xsl:variable name="Image-ITU-Globe-Logo">
		<svg xmlns="http://www.w3.org/2000/svg" xmlns:svg="http://www.w3.org/2000/svg" version="1.0" width="73.126601mm" height="82.727799mm" id="svg99">
			<defs id="defs3">
				<pattern id="WMFhbasepattern" patternUnits="userSpaceOnUse" width="6" height="6" x="0" y="0"/>
			</defs>
			<path style="fill:#aec6e6;fill-rule:evenodd;fill-opacity:1;stroke:none;" d="  M 130.85065,301.63584   L 133.60396,301.59677   L 136.35728,301.51862   L 139.09106,301.36234   L 141.82485,301.16698   L 144.51958,300.91301   L 147.21431,300.60043   L 149.88951,300.22925   L 152.54519,299.79946   L 155.18134,299.31106   L 157.79796,298.78358   L 160.39505,298.1975   L 162.97262,297.55282   L 165.53066,296.86906   L 168.06918,296.12669   L 170.58817,295.34525   L 173.08763,294.48566   L 175.56756,293.60654   L 178.00844,292.66882   L 180.44932,291.67248   L 182.85114,290.63707   L 185.21391,289.56259   L 187.57669,288.4295   L 189.9004,287.25734   L 192.20459,286.02658   L 194.46973,284.75674   L 196.71534,283.44782   L 198.94142,282.09984   L 201.12845,280.71278   L 203.27642,279.26712   L 205.40487,277.78238   L 207.51379,276.25858   L 209.56413,274.6957   L 207.04514,276.1609   L 204.46757,277.58702   L 201.89,278.97408   L 199.27338,280.32206   L 196.63723,281.61144   L 193.98155,282.88128   L 191.30635,284.09251   L 188.59209,285.26467   L 185.85831,286.39776   L 183.12452,287.49178   L 180.35168,288.54672   L 177.55932,289.54306   L 174.7279,290.50032   L 171.89648,291.41851   L 169.04553,292.2781   L 166.17506,293.09861   L 163.28506,293.86051   L 160.37553,294.60288   L 157.42695,295.2671   L 154.47836,295.91179   L 151.52978,296.49787   L 148.54215,297.02534   L 145.53498,297.51374   L 142.52782,297.94354   L 139.4816,298.33426   L 136.43538,298.66637   L 133.36964,298.95941   L 130.3039,299.19384   L 127.21862,299.36966   L 124.11383,299.50642   L 120.9895,299.58456   L 117.86518,299.62363   L 116.38112,299.6041   L 114.89707,299.58456   L 113.41301,299.56502   L 111.94848,299.50642   L 110.48396,299.46734   L 108.9999,299.3892   L 107.53537,299.31106   L 106.09037,299.23291   L 107.59396,299.50642   L 109.09754,299.77992   L 110.62065,300.03389   L 112.14375,300.26832   L 113.66686,300.48322   L 115.2095,300.67858   L 116.75213,300.8544   L 118.29477,301.01069   L 119.85693,301.16698   L 121.39957,301.28419   L 122.96173,301.38187   L 124.52389,301.47955   L 126.10558,301.53816   L 127.68727,301.59677   L 129.24944,301.6163   L 130.85065,301.63584  z " id="path5"/>
			<path style="fill:#b0c8e7;fill-rule:evenodd;fill-opacity:1;stroke:none;" d="  M 130.85065,301.63584   L 134.59984,301.57723   L 138.32951,301.42094   L 142.02012,301.14744   L 145.6912,300.77626   L 149.34275,300.30739   L 152.95526,299.72131   L 156.5287,299.05709   L 160.0631,298.27565   L 163.57796,297.39653   L 167.05377,296.43926   L 170.471,295.38432   L 173.86871,294.2317   L 177.20783,292.98139   L 180.52743,291.65294   L 183.76891,290.22682   L 186.99087,288.72254   L 190.15425,287.12059   L 193.27858,285.4405   L 196.3248,283.68226   L 199.35149,281.84587   L 202.30007,279.93134   L 205.2096,277.93867   L 208.06054,275.86786   L 210.85291,273.7189   L 213.56717,271.49179   L 216.24237,269.20608   L 218.85899,266.84222   L 221.39751,264.40022   L 223.87744,261.89962   L 226.27927,259.3404   L 228.62251,256.72258   L 230.88765,254.02661   L 227.99765,256.39046   L 225.04906,258.69571   L 222.06143,260.94235   L 219.01521,263.11085   L 215.91041,265.24027   L 212.76656,267.29155   L 209.58365,269.28422   L 206.36169,271.19875   L 203.08115,273.05467   L 199.76155,274.85198   L 196.40291,276.57115   L 193.0052,278.21218   L 189.56844,279.79459   L 186.09263,281.29886   L 182.55824,282.72499   L 179.00432,284.07298   L 175.43087,285.36235   L 171.79884,286.57358   L 168.12776,287.70667   L 164.43715,288.74208   L 160.70749,289.71888   L 156.9583,290.61754   L 153.17005,291.43805   L 149.34275,292.16088   L 145.49593,292.80557   L 141.62958,293.37211   L 137.72417,293.86051   L 133.79923,294.25123   L 129.85477,294.56381   L 125.87126,294.7787   L 121.86822,294.91546   L 117.86518,294.97406   L 115.34619,294.95453   L 112.84673,294.89592   L 110.34727,294.81778   L 107.86733,294.68102   L 105.3874,294.52474   L 102.92699,294.34891   L 100.46659,294.11448   L 98.025709,293.86051   L 95.58483,293.56747   L 93.163478,293.2549   L 90.742126,292.88371   L 88.340301,292.49299   L 85.938475,292.08274   L 83.556177,291.63341   L 81.193406,291.14501   L 78.830635,290.61754   L 80.31469,291.28176   L 81.837798,291.90691   L 83.34138,292.53206   L 84.884016,293.13768   L 86.407124,293.70422   L 87.969287,294.27077   L 89.511923,294.79824   L 91.074085,295.32571   L 92.655775,295.83365   L 94.237465,296.30251   L 95.819154,296.77138   L 97.420371,297.2207   L 99.021588,297.63096   L 100.64233,298.04122   L 102.26308,298.4124   L 103.88382,298.78358   L 105.52409,299.1157   L 107.16436,299.44781   L 108.80463,299.74085   L 110.46443,300.01435   L 112.12423,300.26832   L 113.80355,300.50275   L 115.48288,300.71765   L 117.1622,300.91301   L 118.84153,301.0693   L 120.54038,301.22558   L 122.23923,301.3428   L 123.95761,301.44048   L 125.67599,301.51862   L 127.39437,301.57723   L 129.11275,301.6163   L 130.85065,301.63584  z " id="path7"/>
			<path style="fill:#b3cae8;fill-rule:evenodd;fill-opacity:1;stroke:none;" d="  M 106.09037,299.23291   L 107.53537,299.31106   L 108.9999,299.3892   L 110.48396,299.46734   L 111.94848,299.50642   L 113.41301,299.56502   L 114.89707,299.58456   L 116.38112,299.6041   L 117.86518,299.62363   L 120.9895,299.58456   L 124.11383,299.50642   L 127.21862,299.36966   L 130.3039,299.19384   L 133.36964,298.95941   L 136.43538,298.66637   L 139.4816,298.33426   L 142.52782,297.94354   L 145.53498,297.51374   L 148.54215,297.02534   L 151.52978,296.49787   L 154.47836,295.91179   L 157.42695,295.2671   L 160.37553,294.60288   L 163.28506,293.86051   L 166.17506,293.09861   L 169.04553,292.2781   L 171.89648,291.41851   L 174.7279,290.50032   L 177.55932,289.54306   L 180.35168,288.54672   L 183.12452,287.49178   L 185.85831,286.39776   L 188.59209,285.26467   L 191.30635,284.09251   L 193.98155,282.88128   L 196.63723,281.61144   L 199.27338,280.32206   L 201.89,278.97408   L 204.46757,277.58702   L 207.04514,276.1609   L 209.56413,274.6957   L 210.85291,273.69936   L 212.12217,272.68349   L 213.3719,271.64808   L 214.62163,270.61267   L 215.8323,269.55773   L 217.06251,268.46371   L 218.25366,267.38923   L 219.4448,266.27568   L 220.61643,265.16213   L 221.76852,264.02904   L 222.92062,262.87642   L 224.05318,261.70426   L 225.16623,260.5321   L 226.27927,259.3404   L 227.37278,258.12917   L 228.44677,256.91794   L 229.50123,255.68717   L 230.53616,254.43686   L 231.57109,253.18656   L 232.5865,251.91672   L 233.58238,250.62734   L 234.57826,249.33797   L 235.53508,248.00952   L 236.49191,246.70061   L 237.4292,245.37216   L 238.34697,244.02418   L 239.24522,242.65666   L 240.14346,241.28914   L 241.00265,239.90208   L 241.86184,238.51502   L 242.7015,237.10843   L 243.52164,235.70184   L 240.534,238.80806   L 237.46826,241.83614   L 234.34393,244.80562   L 231.1415,247.69694   L 227.86096,250.49059   L 224.52183,253.2061   L 221.1046,255.84346   L 217.60926,258.40267   L 214.07487,260.88374   L 210.44284,263.2476   L 206.77176,265.55285   L 203.0421,267.74088   L 199.23432,269.85077   L 195.3875,271.86298   L 191.48209,273.7775   L 187.5181,275.61389   L 183.49554,277.33306   L 179.41439,278.95454   L 175.29418,280.47835   L 171.13492,281.90448   L 166.91708,283.21339   L 162.66019,284.42462   L 158.34472,285.51864   L 153.99019,286.51498   L 149.61613,287.3941   L 145.1835,288.156   L 140.7118,288.80069   L 136.20106,289.3477   L 131.67079,289.77749   L 127.10146,290.07053   L 122.49308,290.24635   L 117.86518,290.3245   L 115.95153,290.30496   L 114.0574,290.26589   L 112.16328,290.22682   L 110.26916,290.14867   L 108.39456,290.05099   L 106.51997,289.95331   L 104.64537,289.81656   L 102.79031,289.66027   L 100.91571,289.48445   L 99.080169,289.30862   L 97.225101,289.09373   L 95.38956,288.8593   L 93.554019,288.60533   L 91.718477,288.33182   L 89.902463,288.05832   L 88.066922,287.74574   L 86.270435,287.41363   L 84.454421,287.06198   L 82.657934,286.71034   L 80.880974,286.31962   L 79.084487,285.90936   L 77.307526,285.4991   L 75.550093,285.06931   L 73.79266,284.60045   L 72.035227,284.13158   L 70.277794,283.64318   L 68.539888,283.13525   L 66.821509,282.60778   L 65.083603,282.06077   L 63.365224,281.49422   L 61.666372,280.90814   L 59.967521,280.30253   L 61.256305,281.16211   L 62.564616,281.98262   L 63.892454,282.80314   L 65.220293,283.60411   L 66.548131,284.38555   L 67.915023,285.14746   L 69.262389,285.90936   L 70.629281,286.65173   L 72.0157,287.37456   L 73.40212,288.07786   L 74.808066,288.76162   L 76.214013,289.42584   L 77.619959,290.09006   L 79.045432,290.73475   L 80.470906,291.34037   L 81.915906,291.94598   L 83.380434,292.53206   L 84.825434,293.11814   L 86.289962,293.66515   L 87.774017,294.19262   L 89.258071,294.7201   L 90.742126,295.22803   L 92.245707,295.6969   L 93.749289,296.16576   L 95.272397,296.61509   L 96.795506,297.04488   L 98.318615,297.45514   L 99.86125,297.84586   L 101.40389,298.21704   L 102.96605,298.56869   L 104.50868,298.9008   L 106.09037,299.23291  z " id="path9"/>
			<path style="fill:#b5cbe8;fill-rule:evenodd;fill-opacity:1;stroke:none;" d="  M 78.830635,290.61754   L 81.193406,291.14501   L 83.556177,291.63341   L 85.938475,292.08274   L 88.340301,292.49299   L 90.742126,292.88371   L 93.163478,293.2549   L 95.58483,293.56747   L 98.025709,293.86051   L 100.46659,294.11448   L 102.92699,294.34891   L 105.3874,294.52474   L 107.86733,294.68102   L 110.34727,294.81778   L 112.84673,294.89592   L 115.34619,294.95453   L 117.86518,294.97406   L 121.86822,294.91546   L 125.87126,294.7787   L 129.85477,294.56381   L 133.79923,294.25123   L 137.72417,293.86051   L 141.62958,293.37211   L 145.49593,292.80557   L 149.34275,292.16088   L 153.17005,291.43805   L 156.9583,290.61754   L 160.70749,289.71888   L 164.43715,288.74208   L 168.12776,287.70667   L 171.79884,286.57358   L 175.43087,285.36235   L 179.00432,284.07298   L 182.55824,282.72499   L 186.09263,281.29886   L 189.56844,279.79459   L 193.0052,278.21218   L 196.40291,276.57115   L 199.76155,274.85198   L 203.08115,273.05467   L 206.36169,271.19875   L 209.58365,269.28422   L 212.76656,267.29155   L 215.91041,265.24027   L 219.01521,263.11085   L 222.06143,260.94235   L 225.04906,258.69571   L 227.99765,256.39046   L 230.88765,254.02661   L 231.68826,253.03027   L 232.48886,252.03394   L 233.26994,251.0376   L 234.05103,250.02173   L 234.81258,249.00586   L 235.55461,247.98998   L 236.31616,246.95458   L 237.03866,245.91917   L 237.76116,244.86422   L 238.48366,243.80928   L 239.18664,242.75434   L 239.88961,241.67986   L 240.57306,240.60538   L 241.23697,239.51136   L 241.92042,238.41734   L 242.56481,237.32333   L 243.2092,236.22931   L 243.83407,235.11576   L 244.45894,234.00221   L 245.0838,232.86912   L 245.68914,231.73603   L 246.27495,230.60294   L 246.86076,229.45032   L 247.42704,228.2977   L 247.9738,227.14507   L 248.52056,225.97291   L 249.06732,224.82029   L 249.59454,223.62859   L 250.10225,222.45643   L 250.60995,221.26474   L 251.09813,220.07304   L 251.5863,218.88134   L 248.67677,222.63226   L 245.65008,226.30502   L 242.52576,229.89965   L 239.3038,233.39659   L 236.00373,236.79586   L 232.5865,240.09744   L 229.09116,243.30134   L 225.49819,246.4271   L 221.80758,249.43565   L 218.03886,252.34651   L 214.19203,255.14016   L 210.2671,257.83613   L 206.24453,260.41488   L 202.16338,262.87642   L 198.00412,265.24027   L 193.76676,267.48691   L 189.45128,269.5968   L 185.07723,271.60901   L 180.64459,273.48446   L 176.13384,275.22317   L 171.56452,276.84466   L 166.93661,278.34893   L 162.25012,279.71645   L 157.52458,280.92768   L 152.72093,282.0217   L 147.87823,282.97896   L 142.97694,283.79947   L 138.0366,284.4637   L 133.05721,284.99117   L 128.03876,285.36235   L 122.96173,285.59678   L 117.86518,285.67493   L 115.4243,285.65539   L 113.00294,285.59678   L 110.60112,285.51864   L 108.19929,285.40142   L 105.817,285.24514   L 103.4347,285.04978   L 101.0524,284.83488   L 98.689628,284.58091   L 96.346384,284.28787   L 94.00314,283.9753   L 91.659896,283.62365   L 89.336179,283.25246   L 87.031989,282.82267   L 84.727799,282.39288   L 82.443136,281.90448   L 80.158473,281.39654   L 77.893337,280.86907   L 75.647729,280.30253   L 73.40212,279.69691   L 71.176038,279.07176   L 68.969483,278.40754   L 66.762928,277.72378   L 64.5759,277.00094   L 62.388873,276.23904   L 60.221372,275.47714   L 58.073398,274.65662   L 55.944952,273.83611   L 53.816505,272.97653   L 51.707585,272.07787   L 49.618193,271.15968   L 47.548327,270.20242   L 45.497989,269.24515   L 46.415759,270.04613   L 47.353057,270.86664   L 48.309881,271.64808   L 49.266706,272.44906   L 50.223531,273.2305   L 51.199882,273.9924   L 52.176234,274.7543   L 53.172113,275.49667   L 54.148464,276.23904   L 55.144343,276.98141   L 56.159749,277.70424   L 57.175155,278.42707   L 58.19056,279.13037   L 59.225493,279.81413   L 60.260426,280.49789   L 61.295359,281.18165   L 62.349819,281.84587   L 63.404278,282.5101   L 64.458738,283.15478   L 65.532725,283.77994   L 66.606712,284.40509   L 67.680699,285.03024   L 68.774213,285.63586   L 69.867727,286.24147   L 70.961241,286.82755   L 72.074281,287.3941   L 73.187322,287.96064   L 74.300363,288.50765   L 75.413404,289.05466   L 76.545972,289.60166   L 77.67854,290.1096   L 78.830635,290.61754  z " id="path11"/>
			<path style="fill:#b7cde9;fill-rule:evenodd;fill-opacity:1;stroke:none;" d="  M 59.967521,280.30253   L 61.666372,280.90814   L 63.365224,281.49422   L 65.083603,282.06077   L 66.821509,282.60778   L 68.539888,283.13525   L 70.277794,283.64318   L 72.035227,284.13158   L 73.79266,284.60045   L 75.550093,285.06931   L 77.307526,285.4991   L 79.084487,285.9289   L 80.880974,286.31962   L 82.657934,286.71034   L 84.454421,287.06198   L 86.270435,287.41363   L 88.086449,287.74574   L 89.902463,288.05832   L 91.718477,288.33182   L 93.554019,288.60533   L 95.38956,288.8593   L 97.225101,289.09373   L 99.080169,289.30862   L 100.91571,289.48445   L 102.79031,289.66027   L 104.64537,289.81656   L 106.51997,289.95331   L 108.39456,290.05099   L 110.26916,290.14867   L 112.16328,290.22682   L 114.0574,290.28542   L 115.95153,290.30496   L 117.86518,290.3245   L 122.49308,290.24635   L 127.10146,290.07053   L 131.67079,289.77749   L 136.20106,289.3477   L 140.7118,288.80069   L 145.1835,288.156   L 149.61613,287.3941   L 153.99019,286.51498   L 158.34472,285.51864   L 162.66019,284.42462   L 166.91708,283.21339   L 171.13492,281.90448   L 175.29418,280.47835   L 179.41439,278.95454   L 183.49554,277.33306   L 187.5181,275.61389   L 191.48209,273.7775   L 195.3875,271.86298   L 199.23432,269.85077   L 203.0421,267.74088   L 206.77176,265.55285   L 210.44284,263.2476   L 214.05534,260.88374   L 217.60926,258.40267   L 221.1046,255.86299   L 224.52183,253.22563   L 227.86096,250.49059   L 231.1415,247.69694   L 234.34393,244.80562   L 237.46826,241.85568   L 240.534,238.80806   L 243.52164,235.70184   L 244.5761,233.78731   L 245.61103,231.87278   L 246.60691,229.93872   L 247.58326,227.96558   L 248.52056,225.99245   L 249.43833,223.99978   L 250.31705,221.98757   L 251.15671,219.95582   L 251.95732,217.90454   L 252.7384,215.85326   L 253.48042,213.76291   L 254.1834,211.67256   L 254.86684,209.56267   L 255.49171,207.43325   L 256.09705,205.28429   L 256.66333,203.13533   L 253.92955,207.47232   L 251.03955,211.71163   L 248.03238,215.85326   L 244.90806,219.89722   L 241.64704,223.82395   L 238.28839,227.67254   L 234.79305,231.38438   L 231.18055,235.01808   L 227.47042,238.51502   L 223.64312,241.89475   L 219.71818,245.15726   L 215.67609,248.30256   L 211.53636,251.33064   L 207.31852,254.20243   L 202.98352,256.97654   L 198.57041,259.59437   L 194.07919,262.07544   L 189.49034,264.41976   L 184.80385,266.62733   L 180.05878,268.69814   L 175.2356,270.59314   L 170.33432,272.37091   L 165.35492,273.97286   L 160.31695,275.41853   L 155.20086,276.7079   L 150.0262,277.84099   L 144.81248,278.79826   L 139.52066,279.5797   L 134.17025,280.20485   L 128.78079,280.65418   L 123.33274,280.92768   L 117.86518,281.02536   L 114.97517,280.98629   L 112.12423,280.92768   L 109.27328,280.79093   L 106.44186,280.6151   L 103.62997,280.40021   L 100.81808,280.1267   L 98.025709,279.81413   L 95.233343,279.46248   L 92.480032,279.05222   L 89.72672,278.58336   L 86.992935,278.09496   L 84.278678,277.54795   L 81.583947,276.96187   L 78.889216,276.31718   L 76.23354,275.63342   L 73.577863,274.91059   L 70.941713,274.14869   L 68.344618,273.32818   L 65.747523,272.48813   L 63.169954,271.58947   L 60.611913,270.65174   L 58.092925,269.67494   L 55.573938,268.65907   L 53.074478,267.60413   L 50.614071,266.49058   L 48.153665,265.35749   L 45.732313,264.18533   L 43.330488,262.95456   L 40.94819,261.70426   L 38.604946,260.41488   L 36.261702,259.08643   L 33.957512,257.71891   L 35.402512,259.32086   L 36.86704,260.90328   L 38.370621,262.46616   L 39.89373,263.98997   L 41.436366,265.49424   L 42.998528,266.97898   L 44.599745,268.44418   L 46.220489,269.8703   L 47.86076,271.2769   L 49.520557,272.64442   L 51.199882,273.9924   L 52.918261,275.32085   L 54.63664,276.61022   L 56.394073,277.86053   L 58.171033,279.11083   L 59.967521,280.30253  z " id="path13"/>
			<path style="fill:#b8ceea;fill-rule:evenodd;fill-opacity:1;stroke:none;" d="  M 45.497989,269.24515   L 47.548327,270.20242   L 49.618193,271.15968   L 51.707585,272.07787   L 53.816505,272.95699   L 55.944952,273.83611   L 58.073398,274.65662   L 60.221372,275.47714   L 62.388873,276.23904   L 64.5759,277.00094   L 66.762928,277.72378   L 68.949956,278.40754   L 71.176038,279.07176   L 73.40212,279.69691   L 75.647729,280.30253   L 77.893337,280.86907   L 80.158473,281.39654   L 82.443136,281.90448   L 84.727799,282.39288   L 87.031989,282.82267   L 89.336179,283.25246   L 91.659896,283.62365   L 94.00314,283.9753   L 96.346384,284.28787   L 98.689628,284.58091   L 101.0524,284.83488   L 103.4347,285.04978   L 105.817,285.24514   L 108.19929,285.40142   L 110.60112,285.51864   L 113.00294,285.59678   L 115.4243,285.65539   L 117.86518,285.67493   L 122.96173,285.59678   L 128.03876,285.36235   L 133.05721,284.99117   L 138.0366,284.4637   L 142.97694,283.79947   L 147.87823,282.97896   L 152.72093,282.0217   L 157.52458,280.92768   L 162.25012,279.71645   L 166.93661,278.34893   L 171.56452,276.84466   L 176.13384,275.22317   L 180.64459,273.48446   L 185.07723,271.60901   L 189.45128,269.5968   L 193.76676,267.48691   L 198.00412,265.24027   L 202.16338,262.87642   L 206.24453,260.41488   L 210.2671,257.83613   L 214.19203,255.14016   L 218.03886,252.34651   L 221.80758,249.43565   L 225.49819,246.4271   L 229.09116,243.30134   L 232.5865,240.09744   L 236.00373,236.79586   L 239.3038,233.39659   L 242.52576,229.89965   L 245.65008,226.30502   L 248.67677,222.63226   L 251.5863,218.86181   L 252.28928,217.04496   L 252.97272,215.20858   L 253.61711,213.37219   L 254.24198,211.51627   L 254.82779,209.64082   L 255.39407,207.76536   L 255.94083,205.87037   L 256.44853,203.95584   L 256.93671,202.04131   L 257.40536,200.10725   L 257.83495,198.17318   L 258.22549,196.21958   L 258.59651,194.26598   L 258.94799,192.29285   L 259.26043,190.31971   L 259.53381,188.32704   L 257.03434,193.17197   L 254.37867,197.91922   L 251.54725,202.54925   L 248.57914,207.0816   L 245.45481,211.51627   L 242.1938,215.81419   L 238.7961,220.01443   L 235.24218,224.09746   L 231.55157,228.04373   L 227.74379,231.85325   L 223.79933,235.54555   L 219.73771,239.1011   L 215.55893,242.5199   L 211.24345,245.80195   L 206.83034,248.92771   L 202.30007,251.91672   L 197.67216,254.7299   L 192.94662,257.40634   L 188.10392,259.92648   L 183.1831,262.2708   L 178.14513,264.4393   L 173.04857,266.4515   L 167.85438,268.28789   L 162.56256,269.94845   L 157.21215,271.41365   L 151.78363,272.72256   L 146.27701,273.81658   L 140.7118,274.71523   L 135.08802,275.43806   L 129.40565,275.946   L 123.64518,276.25858   L 117.86518,276.37579   L 114.60416,276.33672   L 111.36267,276.23904   L 108.12119,276.06322   L 104.91875,275.84832   L 101.73585,275.55528   L 98.552939,275.20363   L 95.409087,274.77384   L 92.265234,274.30498   L 89.160436,273.75797   L 86.055638,273.17189   L 82.989893,272.50766   L 79.943676,271.78483   L 76.916986,271.00339   L 73.92935,270.16334   L 70.941713,269.28422   L 67.993131,268.32696   L 65.064076,267.33062   L 62.174075,266.25614   L 59.303601,265.14259   L 56.452654,263.97043   L 53.640762,262.7592   L 50.848396,261.46982   L 48.075557,260.14138   L 45.361299,258.77386   L 42.647042,257.34773   L 39.991365,255.86299   L 37.355215,254.31965   L 34.75812,252.75677   L 32.180552,251.11574   L 29.642037,249.43565   L 27.142577,247.71648   L 24.682171,245.95824   L 25.814739,247.54066   L 26.966834,249.12307   L 28.157983,250.68595   L 29.349132,252.2293   L 30.579335,253.7531   L 31.829065,255.27691   L 33.098322,256.76165   L 34.406633,258.22685   L 35.714945,259.67251   L 37.042783,261.09864   L 38.409675,262.50523   L 39.776568,263.89229   L 41.182514,265.25981   L 42.588461,266.60779   L 44.033461,267.93624   L 45.497989,269.24515  z " id="path15"/>
			<path style="fill:#bacfeb;fill-rule:evenodd;fill-opacity:1;stroke:none;" d="  M 33.957512,257.71891   L 36.261702,259.08643   L 38.604946,260.41488   L 40.94819,261.70426   L 43.330488,262.95456   L 45.732313,264.18533   L 48.153665,265.35749   L 50.614071,266.49058   L 53.074478,267.60413   L 55.573938,268.65907   L 58.092925,269.67494   L 60.611913,270.65174   L 63.169954,271.58947   L 65.747523,272.48813   L 68.344618,273.32818   L 70.941713,274.14869   L 73.577863,274.91059   L 76.23354,275.63342   L 78.889216,276.31718   L 81.583947,276.96187   L 84.278678,277.54795   L 86.992935,278.09496   L 89.72672,278.58336   L 92.480032,279.05222   L 95.233343,279.46248   L 98.025709,279.81413   L 100.81808,280.1267   L 103.62997,280.40021   L 106.44186,280.6151   L 109.27328,280.79093   L 112.12423,280.92768   L 114.97517,280.98629   L 117.86518,281.02536   L 123.33274,280.92768   L 128.78079,280.65418   L 134.17025,280.20485   L 139.52066,279.5797   L 144.81248,278.79826   L 150.0262,277.84099   L 155.20086,276.7079   L 160.31695,275.41853   L 165.35492,273.97286   L 170.33432,272.37091   L 175.2356,270.59314   L 180.05878,268.69814   L 184.80385,266.62733   L 189.49034,264.41976   L 194.07919,262.07544   L 198.57041,259.59437   L 202.98352,256.97654   L 207.31852,254.20243   L 211.53636,251.33064   L 215.67609,248.30256   L 219.71818,245.15726   L 223.64312,241.89475   L 227.47042,238.51502   L 231.18055,235.01808   L 234.79305,231.38438   L 238.28839,227.67254   L 241.64704,223.82395   L 244.90806,219.89722   L 248.03238,215.85326   L 251.03955,211.71163   L 253.92955,207.47232   L 256.66333,203.13533   L 257.09293,201.39662   L 257.50299,199.63838   L 257.89353,197.88014   L 258.24502,196.1219   L 258.59651,194.34413   L 258.90894,192.56635   L 259.18232,190.76904   L 259.4557,188.97173   L 259.69002,187.15488   L 259.90482,185.33803   L 260.10009,183.52118   L 260.25631,181.6848   L 260.41252,179.84842   L 260.51016,178.01203   L 260.60779,176.15611   L 260.66637,174.30019   L 258.47935,179.59445   L 256.09705,184.79102   L 253.51948,189.88992   L 250.78569,194.8716   L 247.85664,199.73606   L 244.75184,204.46378   L 241.49083,209.09381   L 238.05407,213.58709   L 234.46109,217.94362   L 230.7119,222.16339   L 226.82602,226.24642   L 222.78393,230.19269   L 218.58562,233.98267   L 214.27014,237.61637   L 209.81798,241.09378   L 205.22912,244.39536   L 200.52311,247.54066   L 195.6804,250.51013   L 190.74007,253.32331   L 185.68256,255.94114   L 180.5079,258.3636   L 175.25513,260.61024   L 169.88519,262.66152   L 164.41762,264.51744   L 158.87195,266.178   L 153.22863,267.62366   L 147.50721,268.85443   L 141.72721,269.8703   L 135.84957,270.67128   L 129.91336,271.25736   L 123.91856,271.60901   L 117.86518,271.72622   L 114.25267,271.66762   L 110.67923,271.5504   L 107.12531,271.35504   L 103.59091,271.062   L 100.07605,270.69082   L 96.600236,270.26102   L 93.143951,269.73355   L 89.707193,269.12794   L 86.289962,268.46371   L 82.911785,267.72134   L 79.553135,266.90083   L 76.23354,266.00218   L 72.933471,265.02538   L 69.672456,263.98997   L 66.450496,262.87642   L 63.248062,261.70426   L 60.084683,260.45395   L 56.960357,259.14504   L 53.875086,257.75798   L 50.809342,256.31232   L 47.782651,254.80805   L 44.814542,253.22563   L 41.86596,251.58461   L 38.956432,249.88498   L 36.105485,248.12674   L 33.293592,246.29035   L 30.501227,244.4149   L 27.786969,242.4613   L 25.092238,240.46862   L 22.456089,238.41734   L 19.858993,236.30746   L 17.300952,234.13896   L 18.199195,235.72138   L 19.097439,237.28426   L 20.034737,238.84714   L 20.991561,240.39048   L 21.967913,241.91429   L 22.963792,243.41856   L 23.95967,244.92283   L 24.994603,246.40757   L 26.049063,247.87277   L 27.12305,249.33797   L 28.216564,250.7641   L 29.329605,252.19022   L 30.462173,253.59682   L 31.594741,254.98387   L 32.766363,256.35139   L 33.957512,257.71891  z " id="path17"/>
			<path style="fill:#bcd1ec;fill-rule:evenodd;fill-opacity:1;stroke:none;" d="  M 24.682171,245.95824   L 27.142577,247.71648   L 29.642037,249.43565   L 32.180552,251.11574   L 34.75812,252.75677   L 37.355215,254.31965   L 39.991365,255.86299   L 42.647042,257.34773   L 45.361299,258.77386   L 48.075557,260.14138   L 50.848396,261.46982   L 53.640762,262.7592   L 56.452654,263.97043   L 59.303601,265.14259   L 62.174075,266.25614   L 65.064076,267.33062   L 67.993131,268.32696   L 70.941713,269.28422   L 73.92935,270.16334   L 76.916986,271.00339   L 79.943676,271.78483   L 82.989893,272.50766   L 86.055638,273.17189   L 89.160436,273.75797   L 92.265234,274.30498   L 95.409087,274.77384   L 98.552939,275.20363   L 101.73585,275.55528   L 104.91875,275.84832   L 108.12119,276.06322   L 111.36267,276.23904   L 114.60416,276.33672   L 117.86518,276.37579   L 123.64518,276.25858   L 129.40565,275.946   L 135.08802,275.43806   L 140.7118,274.71523   L 146.27701,273.81658   L 151.78363,272.72256   L 157.21215,271.41365   L 162.56256,269.94845   L 167.85438,268.28789   L 173.04857,266.4515   L 178.14513,264.4393   L 183.1831,262.2708   L 188.10392,259.92648   L 192.94662,257.40634   L 197.67216,254.7299   L 202.30007,251.91672   L 206.83034,248.92771   L 211.24345,245.80195   L 215.55893,242.5199   L 219.73771,239.1011   L 223.79933,235.54555   L 227.74379,231.85325   L 231.55157,228.04373   L 235.24218,224.09746   L 238.7961,220.01443   L 242.1938,215.81419   L 245.45481,211.51627   L 248.57914,207.0816   L 251.54725,202.54925   L 254.37867,197.91922   L 257.03434,193.17197   L 259.53381,188.32704   L 259.67049,187.23302   L 259.80718,186.15854   L 259.94387,185.06453   L 260.04151,183.97051   L 260.15867,182.8765   L 260.25631,181.78248   L 260.33441,180.66893   L 260.43205,179.57491   L 260.49063,178.46136   L 260.54921,177.36734   L 260.60779,176.25379   L 260.64685,175.14024   L 260.6859,174.02669   L 260.70543,172.91314   L 260.72495,171.78005   L 260.72495,170.6665   L 260.72495,169.43573   L 260.70543,168.20496   L 260.66637,166.99373   L 260.62732,165.76296   L 260.58826,164.55173   L 260.52968,163.3405   L 260.45158,162.12926   L 260.37347,160.91803   L 258.53793,166.62254   L 256.48759,172.22938   L 254.22245,177.71899   L 251.74252,183.11093   L 249.04779,188.36611   L 246.17731,193.50408   L 243.09204,198.52483   L 239.83103,203.40883   L 236.37474,208.15608   L 232.74271,212.74704   L 228.93494,217.18171   L 224.97096,221.47963   L 220.83122,225.62126   L 216.53528,229.58707   L 212.08311,233.39659   L 207.47473,237.01075   L 202.72966,240.46862   L 197.84791,243.73114   L 192.82946,246.79829   L 187.69385,249.67008   L 182.42155,252.34651   L 177.05161,254.80805   L 171.54499,257.07422   L 165.94073,259.1255   L 160.23884,260.94235   L 154.43931,262.52477   L 148.54215,263.89229   L 142.54735,265.02538   L 136.49397,265.9045   L 130.34295,266.54918   L 124.13335,266.9399   L 117.86518,267.07666   L 113.95977,267.01805   L 110.09342,266.86176   L 106.24659,266.62733   L 102.41929,266.27568   L 98.631047,265.84589   L 94.881857,265.29888   L 91.152193,264.67373   L 87.442057,263.9509   L 83.790502,263.14992   L 80.158473,262.25126   L 76.565499,261.25493   L 73.011579,260.18045   L 69.496713,259.02782   L 66.001374,257.77752   L 62.564616,256.44907   L 59.166912,255.02294   L 55.827789,253.53821   L 52.508194,251.97533   L 49.247179,250.31477   L 46.025218,248.5956   L 42.861839,246.77875   L 39.737514,244.9033   L 36.671769,242.9497   L 33.645079,240.91795   L 30.67697,238.8276   L 27.767442,236.6591   L 24.916495,234.432   L 22.124129,232.12675   L 19.370817,229.7629   L 16.695614,227.3209   L 14.059464,224.82029   L 11.501423,222.26107   L 12.184869,223.82395   L 12.887842,225.38683   L 13.610342,226.93018   L 14.35237,228.45398   L 15.113924,229.97779   L 15.875478,231.5016   L 16.676087,232.98634   L 17.496222,234.49061   L 18.335885,235.95581   L 19.175547,237.42101   L 20.054264,238.86667   L 20.93298,240.31234   L 21.850751,241.73846   L 22.768521,243.16459   L 23.705819,244.55165   L 24.682171,245.95824  z " id="path19"/>
			<path style="fill:#bed3ec;fill-rule:evenodd;fill-opacity:1;stroke:none;" d="  M 17.300952,234.13896   L 19.858993,236.30746   L 22.456089,238.41734   L 25.092238,240.46862   L 27.786969,242.48083   L 30.501227,244.4149   L 33.293592,246.29035   L 36.105485,248.12674   L 38.956432,249.88498   L 41.86596,251.58461   L 44.814542,253.22563   L 47.782651,254.80805   L 50.809342,256.31232   L 53.875086,257.75798   L 56.960357,259.14504   L 60.084683,260.45395   L 63.248062,261.70426   L 66.450496,262.87642   L 69.672456,263.98997   L 72.933471,265.02538   L 76.23354,266.00218   L 79.553135,266.90083   L 82.911785,267.72134   L 86.289962,268.46371   L 89.707193,269.14747   L 93.143951,269.73355   L 96.600236,270.26102   L 100.07605,270.69082   L 103.59091,271.062   L 107.12531,271.35504   L 110.67923,271.5504   L 114.25267,271.66762   L 117.86518,271.72622   L 123.91856,271.60901   L 129.91336,271.25736   L 135.84957,270.67128   L 141.72721,269.8703   L 147.50721,268.85443   L 153.22863,267.62366   L 158.87195,266.178   L 164.41762,264.51744   L 169.88519,262.66152   L 175.25513,260.61024   L 180.5079,258.3636   L 185.68256,255.94114   L 190.74007,253.32331   L 195.6804,250.51013   L 200.52311,247.54066   L 205.22912,244.39536   L 209.81798,241.09378   L 214.27014,237.61637   L 218.58562,233.98267   L 222.78393,230.19269   L 226.82602,226.24642   L 230.7119,222.16339   L 234.46109,217.94362   L 238.05407,213.58709   L 241.49083,209.09381   L 244.75184,204.46378   L 247.85664,199.73606   L 250.78569,194.8716   L 253.51948,189.88992   L 256.09705,184.79102   L 258.47935,179.59445   L 260.66637,174.30019   L 260.6859,173.85086   L 260.6859,173.40154   L 260.70543,172.95221   L 260.70543,172.48334   L 260.72495,172.03402   L 260.72495,171.58469   L 260.72495,171.11582   L 260.72495,170.6665   L 260.72495,169.24037   L 260.6859,167.81424   L 260.64685,166.38811   L 260.60779,164.96198   L 260.52968,163.53586   L 260.45158,162.12926   L 260.35394,160.72267   L 260.23678,159.31608   L 260.10009,157.90949   L 259.9634,156.52243   L 259.80718,155.11584   L 259.63144,153.72878   L 259.4557,152.36126   L 259.2409,150.97421   L 259.0261,149.60669   L 258.8113,148.21963   L 257.38583,154.29533   L 255.70651,160.25381   L 253.79286,166.11461   L 251.62536,171.85819   L 249.24306,177.48456   L 246.62644,182.99371   L 243.77549,188.36611   L 240.70974,193.58222   L 237.44873,198.68112   L 233.97292,203.62373   L 230.28231,208.41005   L 226.41596,213.02054   L 222.37386,217.47475   L 218.13649,221.75314   L 213.72338,225.8557   L 209.15406,229.78243   L 204.40899,233.51381   L 199.5077,237.04982   L 194.46973,240.37094   L 189.27554,243.47717   L 183.94466,246.38803   L 178.47709,249.06446   L 172.89236,251.526   L 167.17094,253.7531   L 161.35188,255.72624   L 155.41566,257.46494   L 149.38181,258.94968   L 143.25032,260.18045   L 137.0212,261.15725   L 130.71396,261.86054   L 124.3091,262.2708   L 117.86518,262.42709   L 113.70592,262.36848   L 109.56619,262.19266   L 105.46551,261.89962   L 101.40389,261.48936   L 97.36179,260.98142   L 93.378275,260.33674   L 89.414287,259.6139   L 85.489354,258.77386   L 81.603474,257.81659   L 77.776175,256.76165   L 73.968404,255.60902   L 70.219213,254.35872   L 66.528604,252.9912   L 62.877049,251.54554   L 59.264547,250.00219   L 55.710627,248.34163   L 52.215288,246.62246   L 48.759003,244.78608   L 45.361299,242.87155   L 42.041704,240.85934   L 38.761162,238.76899   L 35.558728,236.58096   L 32.395349,234.33432   L 29.310078,231.99   L 26.302914,229.56754   L 23.334805,227.06693   L 20.464331,224.48818   L 17.652438,221.83128   L 14.899127,219.09624   L 12.223923,216.30259   L 9.6463547,213.4308   L 7.1273673,210.48086   L 7.6350702,212.02421   L 8.1427731,213.56755   L 8.68953,215.09136   L 9.2362869,216.61517   L 9.822098,218.11944   L 10.407909,219.62371   L 11.013247,221.12798   L 11.657639,222.61272   L 12.302031,224.07792   L 12.96595,225.54312   L 13.649397,227.00832   L 14.35237,228.45398   L 15.055343,229.88011   L 15.79737,231.30624   L 16.539398,232.73237   L 17.300952,234.13896  z " id="path21"/>
			<path style="fill:#c1d3ed;fill-rule:evenodd;fill-opacity:1;stroke:none;" d="  M 11.501423,222.26107   L 14.059464,224.82029   L 16.695614,227.3209   L 19.370817,229.7629   L 22.124129,232.12675   L 24.916495,234.432   L 27.767442,236.6591   L 30.67697,238.8276   L 33.645079,240.91795   L 36.671769,242.9497   L 39.737514,244.9033   L 42.861839,246.77875   L 46.025218,248.5956   L 49.247179,250.31477   L 52.508194,251.95579   L 55.827789,253.53821   L 59.166912,255.02294   L 62.564616,256.44907   L 66.001374,257.77752   L 69.496713,259.02782   L 73.011579,260.18045   L 76.565499,261.25493   L 80.158473,262.25126   L 83.790502,263.14992   L 87.442057,263.9509   L 91.152193,264.67373   L 94.881857,265.29888   L 98.631047,265.84589   L 102.41929,266.27568   L 106.24659,266.62733   L 110.09342,266.86176   L 113.95977,267.01805   L 117.86518,267.07666   L 124.13335,266.9399   L 130.34295,266.54918   L 136.49397,265.9045   L 142.54735,265.02538   L 148.54215,263.89229   L 154.43931,262.52477   L 160.23884,260.94235   L 165.94073,259.1255   L 171.54499,257.07422   L 177.05161,254.80805   L 182.42155,252.34651   L 187.69385,249.67008   L 192.82946,246.79829   L 197.84791,243.73114   L 202.72966,240.46862   L 207.47473,237.01075   L 212.08311,233.39659   L 216.53528,229.58707   L 220.83122,225.62126   L 224.97096,221.47963   L 228.93494,217.18171   L 232.74271,212.74704   L 236.37474,208.13654   L 239.83103,203.40883   L 243.09204,198.52483   L 246.17731,193.50408   L 249.04779,188.36611   L 251.74252,183.11093   L 254.22245,177.71899   L 256.48759,172.22938   L 258.53793,166.62254   L 260.37347,160.91803   L 260.23678,159.33562   L 260.10009,157.7532   L 259.92435,156.17078   L 259.7486,154.58837   L 259.53381,153.02549   L 259.31901,151.46261   L 259.08468,149.91926   L 258.83083,148.35638   L 258.55745,146.81304   L 258.26455,145.28923   L 257.95212,143.74589   L 257.62016,142.22208   L 257.26867,140.71781   L 256.91718,139.194   L 256.52664,137.68973   L 256.1361,136.20499   L 255.15975,142.57373   L 253.91002,148.86432   L 252.38691,155.0377   L 250.59042,161.11339   L 248.52056,167.05234   L 246.19684,172.87406   L 243.61927,178.57858   L 240.78785,184.1268   L 237.74164,189.51874   L 234.46109,194.77392   L 230.94623,199.87282   L 227.21656,204.79589   L 223.29163,209.54314   L 219.1519,214.11456   L 214.8169,218.51016   L 210.30615,222.69086   L 205.60014,226.69574   L 200.71838,230.46619   L 195.66088,234.04128   L 190.46669,237.38194   L 185.09675,240.5077   L 179.59013,243.37949   L 173.92729,246.01685   L 168.14729,248.41978   L 162.2306,250.5492   L 156.19674,252.42466   L 150.04573,254.02661   L 143.79708,255.35506   L 137.45079,256.41   L 131.00687,257.15237   L 124.46531,257.62123   L 117.86518,257.77752   L 113.47159,257.69938   L 109.09754,257.50402   L 104.78206,257.1719   L 100.50564,256.70304   L 96.248749,256.09742   L 92.050437,255.39413   L 87.891179,254.53454   L 83.790502,253.57728   L 79.709352,252.48326   L 75.70631,251.27203   L 71.742322,249.96312   L 67.817388,248.51746   L 63.970562,246.97411   L 60.182318,245.31355   L 56.433127,243.53578   L 52.762045,241.66032   L 49.149544,239.68718   L 45.615151,237.59683   L 42.139339,235.4088   L 38.722108,233.14262   L 35.382985,230.75923   L 32.12197,228.27816   L 28.939064,225.71894   L 25.834266,223.06205   L 22.807575,220.32701   L 19.858993,217.49429   L 16.988519,214.58342   L 14.215681,211.57488   L 11.52095,208.48819   L 8.9238544,205.3429   L 6.4048671,202.09992   L 4.0030419,198.79834   L 4.3350015,200.32214   L 4.7060151,201.82642   L 5.0770288,203.33069   L 5.4675694,204.83496   L 5.8776371,206.33923   L 6.3072319,207.82397   L 6.7563537,209.28917   L 7.2250025,210.7739   L 7.6936513,212.2391   L 8.1818271,213.68477   L 8.709057,215.13043   L 9.2362869,216.5761   L 9.7635169,218.00222   L 10.329801,219.42835   L 10.915612,220.85448   L 11.501423,222.26107  z " id="path23"/>
			<path style="fill:#c3d5ee;fill-rule:evenodd;fill-opacity:1;stroke:none;" d="  M 7.1273673,210.48086   L 9.6463547,213.4308   L 12.223923,216.30259   L 14.899127,219.09624   L 17.652438,221.83128   L 20.464331,224.48818   L 23.334805,227.06693   L 26.302914,229.56754   L 29.310078,231.99   L 32.395349,234.33432   L 35.558728,236.58096   L 38.761162,238.76899   L 42.041704,240.85934   L 45.361299,242.87155   L 48.759003,244.78608   L 52.215288,246.62246   L 55.710627,248.34163   L 59.264547,250.00219   L 62.877049,251.54554   L 66.528604,252.9912   L 70.219213,254.35872   L 73.968404,255.60902   L 77.776175,256.76165   L 81.603474,257.81659   L 85.489354,258.77386   L 89.414287,259.6139   L 93.378275,260.33674   L 97.36179,260.98142   L 101.40389,261.48936   L 105.46551,261.89962   L 109.56619,262.19266   L 113.70592,262.36848   L 117.86518,262.42709   L 124.3091,262.2708   L 130.71396,261.86054   L 137.0212,261.15725   L 143.25032,260.18045   L 149.38181,258.94968   L 155.41566,257.46494   L 161.35188,255.72624   L 167.17094,253.7531   L 172.89236,251.526   L 178.47709,249.06446   L 183.94466,246.38803   L 189.27554,243.47717   L 194.46973,240.37094   L 199.5077,237.04982   L 204.40899,233.51381   L 209.15406,229.78243   L 213.72338,225.8557   L 218.13649,221.75314   L 222.37386,217.47475   L 226.41596,213.02054   L 230.28231,208.41005   L 233.97292,203.62373   L 237.44873,198.68112   L 240.70974,193.58222   L 243.77549,188.36611   L 246.62644,182.99371   L 249.24306,177.48456   L 251.62536,171.85819   L 253.79286,166.11461   L 255.70651,160.25381   L 257.38583,154.29533   L 258.8113,148.21963   L 258.53793,146.71536   L 258.24502,145.21109   L 257.93259,143.70682   L 257.62016,142.20254   L 257.2882,140.71781   L 256.91718,139.23307   L 256.54617,137.76787   L 256.17516,136.30267   L 255.76509,134.83747   L 255.33549,133.37227   L 254.9059,131.92661   L 254.45678,130.48094   L 253.9686,129.05482   L 253.49995,127.62869   L 252.99225,126.20256   L 252.46502,124.79597   L 251.99637,131.43821   L 251.19576,138.0023   L 250.08272,144.46872   L 248.67677,150.81792   L 246.97792,157.0499   L 244.98616,163.16467   L 242.7015,169.14269   L 240.16299,174.98395   L 237.35109,180.66893   L 234.30488,186.21715   L 230.98528,191.58955   L 227.43136,196.78613   L 223.64312,201.82642   L 219.64008,206.65181   L 215.42224,211.30138   L 210.9896,215.75558   L 206.34217,219.97536   L 201.51899,223.99978   L 196.50054,227.78976   L 191.30635,231.34531   L 185.93642,234.66643   L 180.41026,237.75312   L 174.7279,240.5663   L 168.88931,243.10598   L 162.91404,245.3917   L 156.82161,247.4039   L 150.59248,249.12307   L 144.2462,250.52966   L 137.78275,251.66275   L 131.24119,252.46373   L 124.58248,252.95213   L 117.86518,253.12795   L 113.2568,253.04981   L 108.68747,252.81538   L 104.17672,252.42466   L 99.705034,251.89718   L 95.272397,251.23296   L 90.878815,250.41245   L 86.543813,249.45518   L 82.267393,248.36117   L 78.049554,247.14994   L 73.890296,245.78242   L 69.789618,244.27814   L 65.747523,242.67619   L 61.764008,240.91795   L 57.858601,239.06203   L 54.031302,237.06936   L 50.262585,234.95947   L 46.571975,232.73237   L 42.979001,230.40758   L 39.444608,227.94605   L 35.988323,225.40637   L 32.629673,222.72994   L 29.368659,219.97536   L 26.185752,217.10357   L 23.080954,214.1341   L 20.093318,211.08648   L 17.203317,207.92165   L 14.391424,204.67867   L 11.696693,201.35755   L 9.1191247,197.93875   L 6.6391915,194.44181   L 4.2568933,190.84718   L 1.9917574,187.19395   L 2.1870278,188.67869   L 2.4018251,190.18296   L 2.6361496,191.6677   L 2.890001,193.15243   L 3.1438524,194.63717   L 3.4367579,196.10237   L 3.7296634,197.56757   L 4.042096,199.03277   L 4.3740556,200.47843   L 4.7255422,201.9241   L 5.0770288,203.36976   L 5.4675694,204.79589   L 5.8581101,206.24155   L 6.2681778,207.64814   L 6.6782455,209.07427   L 7.1273673,210.48086  z " id="path25"/>
			<path style="fill:#c5d6ef;fill-rule:evenodd;fill-opacity:1;stroke:none;" d="  M 4.0030419,198.79834   L 6.4048671,202.09992   L 8.9238544,205.3429   L 11.52095,208.48819   L 14.215681,211.57488   L 16.988519,214.58342   L 19.858993,217.49429   L 22.807575,220.32701   L 25.834266,223.06205   L 28.939064,225.71894   L 32.12197,228.27816   L 35.382985,230.75923   L 38.722108,233.14262   L 42.139339,235.4088   L 45.615151,237.59683   L 49.149544,239.68718   L 52.762045,241.66032   L 56.433127,243.53578   L 60.182318,245.31355   L 63.970562,246.97411   L 67.817388,248.51746   L 71.742322,249.96312   L 75.70631,251.27203   L 79.709352,252.48326   L 83.790502,253.57728   L 87.891179,254.53454   L 92.050437,255.39413   L 96.248749,256.09742   L 100.50564,256.70304   L 104.78206,257.1719   L 109.09754,257.50402   L 113.47159,257.69938   L 117.86518,257.77752   L 124.46531,257.62123   L 131.00687,257.15237   L 137.45079,256.41   L 143.79708,255.35506   L 150.04573,254.02661   L 156.19674,252.42466   L 162.2306,250.5492   L 168.14729,248.41978   L 173.92729,246.01685   L 179.59013,243.37949   L 185.09675,240.5077   L 190.46669,237.38194   L 195.66088,234.04128   L 200.71838,230.46619   L 205.60014,226.69574   L 210.30615,222.69086   L 214.8169,218.51016   L 219.1519,214.11456   L 223.29163,209.54314   L 227.21656,204.79589   L 230.94623,199.87282   L 234.46109,194.77392   L 237.74164,189.51874   L 240.78785,184.1268   L 243.61927,178.57858   L 246.19684,172.87406   L 248.52056,167.05234   L 250.59042,161.11339   L 252.38691,155.0377   L 253.91002,148.86432   L 255.15975,142.57373   L 256.1361,136.20499   L 255.74556,134.75933   L 255.31597,133.3332   L 254.88637,131.90707   L 254.43725,130.48094   L 253.98813,129.07435   L 253.49995,127.66776   L 253.01178,126.26117   L 252.50407,124.87411   L 251.97684,123.48706   L 251.44961,122.11954   L 250.90286,120.75202   L 250.31705,119.3845   L 249.75076,118.03651   L 249.14542,116.68853   L 248.54009,115.36008   L 247.91522,114.03163   L 247.93475,114.5591   L 247.93475,115.08658   L 247.95427,115.61405   L 247.9738,116.14152   L 247.9738,116.68853   L 247.9738,117.216   L 247.99333,117.74347   L 247.99333,118.27094   L 247.81758,124.97179   L 247.30988,131.5945   L 246.48975,138.09998   L 245.33765,144.50779   L 243.89265,150.81792   L 242.13522,156.9913   L 240.08488,163.04746   L 237.76116,168.94733   L 235.14454,174.72998   L 232.27407,180.33682   L 229.14974,185.78736   L 225.75204,191.06208   L 222.13954,196.18051   L 218.27318,201.08405   L 214.17251,205.81176   L 209.87656,210.34411   L 205.34629,214.64203   L 200.62074,218.74459   L 195.71946,222.61272   L 190.60338,226.22688   L 185.33108,229.62614   L 179.88303,232.7519   L 174.27878,235.6237   L 168.49877,238.24152   L 162.60161,240.5663   L 156.54823,242.61758   L 150.37769,244.37582   L 144.07045,245.82149   L 137.66559,246.97411   L 131.16309,247.79462   L 124.54342,248.30256   L 117.86518,248.47838   L 113.08105,248.3807   L 108.33598,248.12674   L 103.62997,247.69694   L 99.002061,247.11086   L 94.393681,246.3685   L 89.863409,245.4503   L 85.391718,244.37582   L 80.978609,243.16459   L 76.62408,241.79707   L 72.328133,240.27326   L 68.129821,238.6127   L 63.970562,236.81539   L 59.908939,234.88133   L 55.925425,232.81051   L 52.020018,230.60294   L 48.212246,228.25862   L 44.463056,225.79709   L 40.831027,223.21834   L 37.277107,220.50283   L 33.840349,217.68965   L 30.4817,214.75925   L 27.240212,211.71163   L 24.09636,208.5468   L 21.069669,205.28429   L 18.140614,201.9241   L 15.328721,198.44669   L 12.653518,194.89114   L 10.075949,191.2379   L 7.6350702,187.48699   L 5.3113532,183.65794   L 3.1243254,179.75074   L 1.0739869,175.74586   L 1.132568,177.23059   L 1.2106761,178.69579   L 1.3083113,180.16099   L 1.4254735,181.62619   L 1.5621627,183.07186   L 1.6988519,184.53706   L 1.8550682,185.98272   L 2.0308115,187.42838   L 2.2260818,188.87405   L 2.4408792,190.30018   L 2.6556766,191.7263   L 2.890001,193.15243   L 3.1438524,194.57856   L 3.4172309,195.98515   L 3.6906094,197.39174   L 4.0030419,198.79834  z " id="path27"/>
			<path style="fill:#c5d8ef;fill-rule:evenodd;fill-opacity:1;stroke:none;" d="  M 1.9917574,187.19395   L 4.2568933,190.84718   L 6.6391915,194.44181   L 9.1191247,197.93875   L 11.696693,201.35755   L 14.391424,204.67867   L 17.203317,207.94118   L 20.093318,211.08648   L 23.080954,214.1341   L 26.185752,217.10357   L 29.368659,219.97536   L 32.629673,222.72994   L 35.988323,225.40637   L 39.444608,227.94605   L 42.979001,230.40758   L 46.571975,232.73237   L 50.262585,234.95947   L 54.031302,237.06936   L 57.858601,239.06203   L 61.764008,240.91795   L 65.747523,242.67619   L 69.789618,244.29768   L 73.890296,245.78242   L 78.049554,247.14994   L 82.267393,248.36117   L 86.543813,249.45518   L 90.878815,250.41245   L 95.272397,251.23296   L 99.705034,251.89718   L 104.17672,252.42466   L 108.68747,252.81538   L 113.2568,253.04981   L 117.86518,253.12795   L 124.58248,252.95213   L 131.24119,252.46373   L 137.78275,251.66275   L 144.2462,250.52966   L 150.59248,249.12307   L 156.82161,247.4039   L 162.91404,245.3917   L 168.88931,243.10598   L 174.7279,240.5663   L 180.41026,237.75312   L 185.93642,234.66643   L 191.30635,231.34531   L 196.50054,227.78976   L 201.51899,223.99978   L 206.34217,219.97536   L 210.9896,215.75558   L 215.42224,211.30138   L 219.64008,206.65181   L 223.64312,201.82642   L 227.43136,196.78613   L 230.98528,191.58955   L 234.30488,186.21715   L 237.35109,180.66893   L 240.16299,174.98395   L 242.7015,169.14269   L 244.98616,163.16467   L 246.97792,157.0499   L 248.67677,150.81792   L 250.08272,144.46872   L 251.19576,138.0023   L 251.99637,131.45774   L 252.46502,124.79597   L 251.95732,123.42845   L 251.43009,122.08046   L 250.88333,120.73248   L 250.31705,119.3845   L 249.75076,118.05605   L 249.16495,116.7276   L 248.55961,115.41869   L 247.93475,114.10978   L 247.30988,112.8204   L 246.66549,111.51149   L 246.00157,110.24165   L 245.33765,108.95227   L 244.65421,107.68243   L 243.95123,106.43213   L 243.24826,105.18182   L 242.52576,103.93152   L 242.62339,104.81064   L 242.7015,105.7093   L 242.79914,106.58842   L 242.87725,107.48707   L 242.93583,108.36619   L 243.01393,109.26485   L 243.07252,110.1635   L 243.1311,111.06216   L 243.17015,111.96082   L 243.2092,112.85947   L 243.24826,113.75813   L 243.28731,114.65678   L 243.30684,115.55544   L 243.32637,116.47363   L 243.32637,117.37229   L 243.34589,118.27094   L 243.17015,124.73736   L 242.68197,131.1061   L 241.90089,137.39669   L 240.78785,143.57006   L 239.38191,149.64576   L 237.70258,155.60424   L 235.73035,161.4455   L 233.48474,167.15002   L 230.96575,172.69824   L 228.19292,178.10971   L 225.16623,183.38443   L 221.90521,188.46379   L 218.40987,193.38686   L 214.68021,198.13411   L 210.73575,202.686   L 206.57649,207.04253   L 202.22196,211.2037   L 197.67216,215.14997   L 192.92709,218.88134   L 188.00628,222.37829   L 182.92925,225.6408   L 177.65695,228.66888   L 172.24796,231.44299   L 166.70229,233.96314   L 161.00039,236.20978   L 155.16181,238.18291   L 149.20606,239.86301   L 143.15268,241.2696   L 136.96261,242.38315   L 130.67491,243.16459   L 124.3091,243.65299   L 117.86518,243.82882   L 112.90531,243.73114   L 108.00402,243.4381   L 103.16132,242.96923   L 98.377196,242.32454   L 93.632127,241.4845   L 88.965166,240.46862   L 84.356786,239.29646   L 79.826514,237.94848   L 75.37435,236.44421   L 70.980768,234.76411   L 66.68482,232.94726   L 62.466981,230.95459   L 58.32725,228.82517   L 54.285154,226.53946   L 50.340693,224.11699   L 46.493867,221.55778   L 42.744677,218.86181   L 39.093121,216.00955   L 35.558728,213.05962   L 32.141497,209.97293   L 28.841429,206.76902   L 25.658522,203.42837   L 22.592778,199.99003   L 19.644196,196.43448   L 16.85183,192.76171   L 14.176626,188.99126   L 11.638112,185.12314   L 9.2362869,181.15733   L 6.971151,177.11338   L 4.8622314,172.95221   L 2.909528,168.7129   L 1.1130409,164.39544   L 1.0739869,165.17688   L 1.0544598,165.95832   L 1.0154058,166.73976   L 0.99587872,167.5212   L 0.97635169,168.30264   L 0.97635169,169.08408   L 0.95682465,169.88506   L 0.95682465,170.6665   L 0.95682465,171.72144   L 0.97635169,172.75685   L 0.99587872,173.81179   L 1.0349328,174.8472   L 1.0739869,175.88261   L 1.1130409,176.91802   L 1.171622,177.95342   L 1.2302031,178.98883   L 1.2887842,180.02424   L 1.3668924,181.05965   L 1.4450005,182.07552   L 1.5426357,183.11093   L 1.6402708,184.1268   L 1.757433,185.14267   L 1.8745952,186.17808   L 1.9917574,187.19395  z " id="path29"/>
			<path style="fill:#c8d9f0;fill-rule:evenodd;fill-opacity:1;stroke:none;" d="  M 247.99333,118.27094   L 247.99333,117.74347   L 247.9738,117.216   L 247.9738,116.68853   L 247.9738,116.14152   L 247.95427,115.61405   L 247.93475,115.08658   L 247.91522,114.5591   L 247.91522,114.03163   L 247.29035,112.74226   L 246.64596,111.45288   L 246.00157,110.18304   L 245.31812,108.93274   L 244.65421,107.6629   L 243.95123,106.41259   L 243.24826,105.18182   L 242.52576,103.95106   L 241.80326,102.72029   L 241.06123,101.50906   L 240.29968,100.31736   L 239.53812,99.106128   L 238.75704,97.933968   L 237.95643,96.742272   L 237.15582,95.570112   L 236.33569,94.417488   L 236.60907,95.863152   L 236.88245,97.328352   L 237.11677,98.793552   L 237.35109,100.25875   L 237.56589,101.72395   L 237.76116,103.20869   L 237.93691,104.69342   L 238.09312,106.17816   L 238.22981,107.68243   L 238.34697,109.16717   L 238.44461,110.67144   L 238.54224,112.19525   L 238.60082,113.69952   L 238.65941,115.22333   L 238.67893,116.74714   L 238.69846,118.27094   L 238.54224,124.50293   L 238.0736,130.63723   L 237.29251,136.69339   L 236.23805,142.65187   L 234.89069,148.49314   L 233.25042,154.23672   L 231.3563,159.84355   L 229.18879,165.33317   L 226.76744,170.68603   L 224.11177,175.90214   L 221.20224,180.96197   L 218.05839,185.8655   L 214.68021,190.61275   L 211.08723,195.18418   L 207.29899,199.56024   L 203.29595,203.76048   L 199.09764,207.76536   L 194.72358,211.55534   L 190.15425,215.14997   L 185.40919,218.5297   L 180.5079,221.67499   L 175.4504,224.58586   L 170.23668,227.24275   L 164.88627,229.66522   L 159.39918,231.83371   L 153.79492,233.7287   L 148.05397,235.36973   L 142.21539,236.71771   L 136.25964,237.77266   L 130.20626,238.5541   L 124.07477,239.02296   L 117.86518,239.17925   L 112.76862,239.06203   L 107.71112,238.74946   L 102.73172,238.24152   L 97.810912,237.51869   L 92.968208,236.6005   L 88.184084,235.48694   L 83.458542,234.19757   L 78.830635,232.73237   L 74.280836,231.07181   L 69.828673,229.23542   L 65.454617,227.24275   L 61.178197,225.07426   L 56.999411,222.74947   L 52.937788,220.24886   L 48.973801,217.6115   L 45.126975,214.81786   L 41.397311,211.88746   L 37.765283,208.80077   L 34.289471,205.57733   L 30.930821,202.23667   L 27.689334,198.75926   L 24.604062,195.1451   L 21.65548,191.41373   L 18.843588,187.58467   L 16.187911,183.61886   L 13.688451,179.55538   L 11.345207,175.39421   L 9.1581788,171.13536   L 7.1468943,166.7593   L 5.2918261,162.30509   L 3.6320283,157.77274   L 2.1284467,153.1427   L 1.9917574,154.21718   L 1.8550682,155.29166   L 1.737906,156.38568   L 1.6207438,157.46016   L 1.5231086,158.55418   L 1.4254735,159.64819   L 1.3473653,160.74221   L 1.2692572,161.83622   L 1.1911491,162.93024   L 1.132568,164.02426   L 1.0739869,165.11827   L 1.0349328,166.23182   L 0.99587872,167.32584   L 0.97635169,168.43939   L 0.97635169,169.55294   L 0.95682465,170.6665   L 0.95682465,171.31118   L 0.97635169,171.93634   L 0.97635169,172.58102   L 0.99587872,173.20618   L 1.0154058,173.85086   L 1.0349328,174.47602   L 1.0544598,175.1207   L 1.0739869,175.74586   L 3.1243254,179.75074   L 5.3113532,183.65794   L 7.6350702,187.48699   L 10.075949,191.2379   L 12.653518,194.89114   L 15.328721,198.44669   L 18.140614,201.9241   L 21.069669,205.28429   L 24.09636,208.5468   L 27.240212,211.71163   L 30.4817,214.75925   L 33.840349,217.68965   L 37.277107,220.50283   L 40.831027,223.21834   L 44.463056,225.79709   L 48.212246,228.25862   L 52.020018,230.60294   L 55.925425,232.81051   L 59.908939,234.88133   L 63.970562,236.81539   L 68.129821,238.6127   L 72.328133,240.27326   L 76.62408,241.79707   L 80.978609,243.16459   L 85.391718,244.37582   L 89.863409,245.4503   L 94.393681,246.3685   L 99.002061,247.11086   L 103.62997,247.69694   L 108.33598,248.12674   L 113.08105,248.3807   L 117.86518,248.47838   L 124.54342,248.30256   L 131.16309,247.79462   L 137.66559,246.97411   L 144.07045,245.82149   L 150.37769,244.37582   L 156.54823,242.61758   L 162.60161,240.5663   L 168.49877,238.24152   L 174.27878,235.6237   L 179.88303,232.7519   L 185.33108,229.62614   L 190.60338,226.22688   L 195.71946,222.61272   L 200.62074,218.74459   L 205.34629,214.64203   L 209.87656,210.34411   L 214.17251,205.81176   L 218.27318,201.08405   L 222.13954,196.18051   L 225.75204,191.06208   L 229.14974,185.78736   L 232.27407,180.33682   L 235.14454,174.72998   L 237.76116,168.94733   L 240.08488,163.04746   L 242.13522,156.9913   L 243.89265,150.81792   L 245.33765,144.50779   L 246.48975,138.09998   L 247.30988,131.5945   L 247.81758,124.97179   L 247.99333,118.27094  z " id="path31"/>
			<path style="fill:#cadaf0;fill-rule:evenodd;fill-opacity:1;stroke:none;" d="  M 243.34589,118.27094   L 243.32637,117.37229   L 243.32637,116.47363   L 243.30684,115.55544   L 243.28731,114.65678   L 243.24826,113.75813   L 243.2092,112.85947   L 243.17015,111.96082   L 243.1311,111.06216   L 243.07252,110.1635   L 243.01393,109.26485   L 242.93583,108.36619   L 242.87725,107.48707   L 242.79914,106.58842   L 242.7015,105.7093   L 242.62339,104.81064   L 242.52576,103.93152   L 241.78373,102.72029   L 241.0417,101.48952   L 240.28015,100.29782   L 239.5186,99.086592   L 238.73751,97.914432   L 237.93691,96.722736   L 237.1363,95.550576   L 236.31616,94.397952   L 235.4765,93.245328   L 234.63684,92.11224   L 233.77765,90.979152   L 232.91846,89.846064   L 232.03974,88.732512   L 231.1415,87.638496   L 230.24325,86.54448   L 229.32548,85.450464   L 229.89177,87.404064   L 230.419,89.3772   L 230.90717,91.369872   L 231.3563,93.38208   L 231.78589,95.394288   L 232.17643,97.406496   L 232.52792,99.43824   L 232.84035,101.48952   L 233.11373,103.56034   L 233.36758,105.63115   L 233.56285,107.7215   L 233.73859,109.81186   L 233.87528,111.90221   L 233.97292,114.03163   L 234.0315,116.14152   L 234.05103,118.27094   L 233.89481,124.2685   L 233.44569,130.16837   L 232.70366,135.9901   L 231.68826,141.71414   L 230.37994,147.32098   L 228.81778,152.84966   L 226.98224,158.2416   L 224.91237,163.51632   L 222.58866,168.67382   L 220.01109,173.69458   L 217.21872,178.55904   L 214.19203,183.26722   L 210.95055,187.8191   L 207.51379,192.2147   L 203.86223,196.43448   L 200.01541,200.47843   L 195.97331,204.32702   L 191.75547,207.98026   L 187.36189,211.41859   L 182.81209,214.66157   L 178.10607,217.68965   L 173.24384,220.4833   L 168.2254,223.06205   L 163.07026,225.38683   L 157.79796,227.47718   L 152.4085,229.29403   L 146.88235,230.85691   L 141.27809,232.16582   L 135.55667,233.1817   L 129.73761,233.92406   L 123.84045,234.37339   L 117.86518,234.52968   L 112.63193,234.41246   L 107.45727,234.06082   L 102.36071,233.49427   L 97.342263,232.71283   L 92.382396,231.7165   L 87.500638,230.50526   L 82.696988,229.09867   L 77.990973,227.49672   L 73.382593,225.69941   L 68.852321,223.70674   L 64.439211,221.53824   L 60.143264,219.17438   L 55.944952,216.65424   L 51.863802,213.95827   L 47.919341,211.10602   L 44.092042,208.07794   L 40.381906,204.9131   L 36.827986,201.59198   L 33.410755,198.11458   L 30.14974,194.50042   L 27.025415,190.76904   L 24.057306,186.88138   L 21.26494,182.89603   L 18.62879,178.77394   L 16.168384,174.53462   L 13.864194,170.1781   L 11.755274,165.74342   L 9.841625,161.172   L 8.103719,156.52243   L 6.5806104,151.79472   L 5.233245,146.94979   L 4.1006771,142.04626   L 3.8077716,143.41378   L 3.5343931,144.7813   L 3.2610146,146.14882   L 3.0071632,147.51634   L 2.7728388,148.90339   L 2.5385144,150.29045   L 2.343244,151.6775   L 2.1479737,153.0841   L 1.9527034,154.47115   L 1.7964871,155.87774   L 1.6402708,157.28434   L 1.5035816,158.71046   L 1.3864194,160.11706   L 1.2887842,161.54318   L 1.1911491,162.96931   L 1.1130409,164.39544   L 2.909528,168.7129   L 4.8622314,172.95221   L 6.971151,177.11338   L 9.2362869,181.15733   L 11.638112,185.12314   L 14.176626,188.99126   L 16.85183,192.76171   L 19.644196,196.43448   L 22.592778,199.99003   L 25.658522,203.42837   L 28.841429,206.76902   L 32.141497,209.97293   L 35.558728,213.05962   L 39.093121,216.00955   L 42.744677,218.86181   L 46.493867,221.55778   L 50.340693,224.11699   L 54.285154,226.53946   L 58.32725,228.82517   L 62.466981,230.95459   L 66.68482,232.94726   L 70.980768,234.76411   L 75.37435,236.44421   L 79.826514,237.94848   L 84.356786,239.29646   L 88.965166,240.46862   L 93.632127,241.4845   L 98.377196,242.32454   L 103.16132,242.96923   L 108.00402,243.4381   L 112.90531,243.73114   L 117.86518,243.82882   L 124.3091,243.65299   L 130.67491,243.16459   L 136.96261,242.38315   L 143.15268,241.2696   L 149.20606,239.86301   L 155.16181,238.18291   L 161.00039,236.20978   L 166.70229,233.96314   L 172.24796,231.44299   L 177.65695,228.66888   L 182.92925,225.6408   L 188.00628,222.37829   L 192.92709,218.88134   L 197.67216,215.14997   L 202.22196,211.2037   L 206.57649,207.04253   L 210.73575,202.686   L 214.68021,198.13411   L 218.40987,193.38686   L 221.90521,188.46379   L 225.16623,183.38443   L 228.19292,178.10971   L 230.96575,172.69824   L 233.48474,167.15002   L 235.73035,161.4455   L 237.70258,155.60424   L 239.38191,149.64576   L 240.78785,143.57006   L 241.90089,137.39669   L 242.68197,131.1061   L 243.17015,124.73736   L 243.34589,118.27094  z " id="path33"/>
			<path style="fill:#cbdbf1;fill-rule:evenodd;fill-opacity:1;stroke:none;" d="  M 238.69846,118.27094   L 238.67893,116.74714   L 238.65941,115.22333   L 238.60082,113.69952   L 238.54224,112.19525   L 238.44461,110.67144   L 238.34697,109.16717   L 238.22981,107.68243   L 238.09312,106.17816   L 237.93691,104.69342   L 237.76116,103.20869   L 237.56589,101.72395   L 237.35109,100.25875   L 237.11677,98.793552   L 236.88245,97.328352   L 236.60907,95.863152   L 236.33569,94.417488   L 235.49603,93.264864   L 234.63684,92.11224   L 233.77765,90.979152   L 232.91846,89.846064   L 232.02021,88.712976   L 231.12197,87.61896   L 230.22373,86.505408   L 229.30596,85.430928   L 228.36866,84.336912   L 227.43136,83.281968   L 226.47454,82.207488   L 225.51771,81.17208   L 224.54136,80.136672   L 223.54548,79.101264   L 222.5496,78.085392   L 221.5342,77.089056   L 222.00285,78.280752   L 222.4715,79.491984   L 222.90109,80.703216   L 223.33068,81.914448   L 223.74075,83.145216   L 224.15082,84.375984   L 224.54136,85.606752   L 224.91237,86.857056   L 225.26386,88.10736   L 225.61535,89.357664   L 225.92778,90.607968   L 226.25974,91.877808   L 226.55265,93.147648   L 226.84555,94.437024   L 227.11893,95.706864   L 227.37278,96.99624   L 227.6071,98.305152   L 227.84143,99.594528   L 228.05623,100.90344   L 228.2515,102.21235   L 228.42724,103.52126   L 228.60298,104.84971   L 228.73967,106.17816   L 228.87636,107.50661   L 228.99352,108.83506   L 229.11069,110.1635   L 229.18879,111.51149   L 229.2669,112.85947   L 229.32548,114.20746   L 229.36454,115.55544   L 229.38407,116.92296   L 229.40359,118.27094   L 229.24738,124.01453   L 228.81778,129.67997   L 228.11481,135.26726   L 227.13846,140.77642   L 225.88873,146.16835   L 224.38514,151.46261   L 222.62771,156.63965   L 220.63595,161.71901   L 218.39035,166.66162   L 215.92994,171.46747   L 213.25474,176.13658   L 210.34521,180.66893   L 207.24041,185.04499   L 203.92081,189.26477   L 200.42547,193.30872   L 196.71534,197.17685   L 192.84898,200.88869   L 188.80689,204.38563   L 184.58905,207.70675   L 180.21499,210.81298   L 175.68472,213.72384   L 171.01776,216.40027   L 166.21411,218.86181   L 161.27377,221.10845   L 156.19674,223.10112   L 151.02208,224.85936   L 145.73025,226.36363   L 140.34079,227.5944   L 134.83417,228.59074   L 129.24944,229.29403   L 123.5866,229.72382   L 117.86518,229.88011   L 112.51477,229.74336   L 107.24247,229.37218   L 102.04828,228.76656   L 96.912668,227.90698   L 91.874694,226.8325   L 86.914827,225.52358   L 82.033069,223.99978   L 77.268472,222.26107   L 72.601511,220.30747   L 68.051712,218.15851   L 63.619076,215.81419   L 59.303601,213.27451   L 55.105289,210.53947   L 51.043666,207.64814   L 47.138259,204.56146   L 43.350015,201.31848   L 39.737514,197.91922   L 36.261702,194.34413   L 32.942106,190.63229   L 29.798253,186.76416   L 26.830144,182.75928   L 24.018251,178.61765   L 21.421156,174.3588   L 18.980277,169.9632   L 16.754195,165.45038   L 14.723383,160.83989   L 12.907369,156.11218   L 11.286625,151.28678   L 9.8806791,146.36371   L 8.709057,141.34296   L 7.7717594,136.24406   L 7.0492592,131.06702   L 6.6391915,132.41501   L 6.2291238,133.76299   L 5.8581101,135.11098   L 5.4675694,136.45896   L 5.1160828,137.82648   L 4.7645962,139.194   L 4.4521637,140.56152   L 4.1202041,141.92904   L 3.8272986,143.3161   L 3.5343931,144.70315   L 3.2610146,146.10974   L 3.0071632,147.4968   L 2.7728388,148.90339   L 2.5385144,150.30998   L 2.323717,151.71658   L 2.1284467,153.1427   L 3.6320283,157.77274   L 5.2918261,162.30509   L 7.1468943,166.7593   L 9.1581788,171.13536   L 11.345207,175.39421   L 13.688451,179.55538   L 16.187911,183.61886   L 18.843588,187.58467   L 21.65548,191.41373   L 24.604062,195.1451   L 27.689334,198.75926   L 30.930821,202.23667   L 34.289471,205.57733   L 37.765283,208.80077   L 41.397311,211.88746   L 45.126975,214.81786   L 48.973801,217.6115   L 52.937788,220.24886   L 56.999411,222.74947   L 61.178197,225.07426   L 65.454617,227.24275   L 69.828673,229.23542   L 74.280836,231.07181   L 78.830635,232.73237   L 83.458542,234.19757   L 88.184084,235.48694   L 92.968208,236.6005   L 97.810912,237.51869   L 102.73172,238.24152   L 107.71112,238.74946   L 112.76862,239.06203   L 117.86518,239.17925   L 124.07477,239.02296   L 130.20626,238.5541   L 136.25964,237.77266   L 142.21539,236.71771   L 148.05397,235.36973   L 153.79492,233.7287   L 159.39918,231.83371   L 164.88627,229.66522   L 170.23668,227.24275   L 175.4504,224.58586   L 180.5079,221.67499   L 185.40919,218.5297   L 190.15425,215.14997   L 194.72358,211.55534   L 199.09764,207.76536   L 203.29595,203.76048   L 207.29899,199.56024   L 211.08723,195.18418   L 214.68021,190.61275   L 218.05839,185.8655   L 221.20224,180.96197   L 224.11177,175.90214   L 226.76744,170.68603   L 229.18879,165.33317   L 231.3563,159.84355   L 233.25042,154.23672   L 234.89069,148.49314   L 236.23805,142.65187   L 237.29251,136.69339   L 238.0736,130.63723   L 238.54224,124.50293   L 238.69846,118.27094  z " id="path35"/>
			<path style="fill:#cfdef2;fill-rule:evenodd;fill-opacity:1;stroke:none;" d="  M 234.05103,118.27094   L 234.0315,116.14152   L 233.97292,114.03163   L 233.87528,111.90221   L 233.73859,109.81186   L 233.56285,107.7215   L 233.36758,105.63115   L 233.11373,103.56034   L 232.84035,101.48952   L 232.52792,99.43824   L 232.17643,97.406496   L 231.78589,95.394288   L 231.3563,93.38208   L 230.90717,91.369872   L 230.419,89.3772   L 229.89177,87.404064   L 229.32548,85.450464   L 228.38819,84.356448   L 227.43136,83.281968   L 226.47454,82.207488   L 225.47866,81.133008   L 224.50231,80.078064   L 223.4869,79.042656   L 222.49102,78.007248   L 221.45609,76.991376   L 220.42116,75.99504   L 219.3667,74.998704   L 218.31224,74.002368   L 217.25778,73.025568   L 216.16426,72.068304   L 215.09028,71.130576   L 213.97724,70.192848   L 212.88372,69.25512   L 213.56717,70.642176   L 214.25061,72.029232   L 214.91453,73.435824   L 215.55893,74.861952   L 216.18379,76.28808   L 216.78913,77.733744   L 217.37494,79.179408   L 217.9217,80.625072   L 218.46845,82.109808   L 218.99568,83.575008   L 219.48386,85.059744   L 219.97203,86.564016   L 220.42116,88.068288   L 220.85075,89.592096   L 221.26082,91.115904   L 221.65136,92.659248   L 222.02237,94.202592   L 222.37386,95.745936   L 222.68629,97.308816   L 222.99872,98.871696   L 223.2721,100.45411   L 223.52595,102.03653   L 223.76028,103.63848   L 223.95555,105.24043   L 224.15082,106.84238   L 224.30704,108.46387   L 224.44373,110.08536   L 224.54136,111.70685   L 224.639,113.34787   L 224.69758,114.9889   L 224.73663,116.62992   L 224.75616,118.27094   L 224.59994,123.7801   L 224.18987,129.2111   L 223.50643,134.56397   L 222.56913,139.83869   L 221.37798,144.99619   L 219.93298,150.07555   L 218.25366,155.05723   L 216.34001,159.90216   L 214.21156,164.64941   L 211.84879,169.2599   L 209.27122,173.73365   L 206.49838,178.07064   L 203.51075,182.27088   L 200.32784,186.2953   L 196.96919,190.18296   L 193.4348,193.8948   L 189.72466,197.43082   L 185.83878,200.79101   L 181.81621,203.97538   L 177.6179,206.96438   L 173.2829,209.7385   L 168.81121,212.31725   L 164.20283,214.6811   L 159.45776,216.81053   L 154.61505,218.72506   L 149.63566,220.40515   L 144.55863,221.85082   L 139.40349,223.04251   L 134.13119,223.99978   L 128.78079,224.664   L 123.35227,225.07426   L 117.86518,225.23054   L 112.41713,225.09379   L 107.0472,224.68354   L 101.75537,224.01931   L 96.561182,223.10112   L 91.425572,221.92896   L 86.407124,220.52237   L 81.486312,218.88134   L 76.682661,217.00589   L 71.996173,214.896   L 67.426847,212.59075   L 62.974684,210.07061   L 58.678736,207.3551   L 54.519478,204.4247   L 50.496909,201.31848   L 46.630557,198.0169   L 42.939947,194.55902   L 39.405554,190.90579   L 36.046904,187.11581   L 32.863998,183.15   L 29.876362,179.0279   L 27.083996,174.76906   L 24.4869,170.37346   L 22.104602,165.86064   L 19.937101,161.21107   L 17.984398,156.44429   L 16.246492,151.56029   L 14.74291,146.57861   L 13.49318,141.47971   L 12.477775,136.30267   L 11.71622,131.04749   L 11.228044,125.69462   L 10.99372,120.28315   L 10.446963,121.59206   L 9.9197331,122.92051   L 9.4120302,124.22942   L 8.9238544,125.57741   L 8.4356786,126.90586   L 7.9865568,128.25384   L 7.517908,129.60182   L 7.0883132,130.96934   L 6.6587185,132.31733   L 6.2486508,133.70438   L 5.8581101,135.0719   L 5.4870965,136.45896   L 5.1160828,137.84602   L 4.7645962,139.23307   L 4.4326367,140.63966   L 4.1006771,142.04626   L 5.233245,146.94979   L 6.5806104,151.79472   L 8.103719,156.52243   L 9.841625,161.172   L 11.755274,165.74342   L 13.864194,170.1781   L 16.168384,174.53462   L 18.62879,178.77394   L 21.26494,182.89603   L 24.057306,186.88138   L 27.025415,190.76904   L 30.14974,194.50042   L 33.410755,198.11458   L 36.827986,201.59198   L 40.381906,204.9131   L 44.092042,208.07794   L 47.919341,211.10602   L 51.863802,213.95827   L 55.944952,216.65424   L 60.143264,219.17438   L 64.439211,221.53824   L 68.852321,223.70674   L 73.382593,225.69941   L 77.990973,227.49672   L 82.696988,229.09867   L 87.500638,230.50526   L 92.382396,231.7165   L 97.342263,232.71283   L 102.36071,233.49427   L 107.45727,234.06082   L 112.63193,234.41246   L 117.86518,234.52968   L 123.84045,234.37339   L 129.73761,233.92406   L 135.55667,233.1817   L 141.27809,232.16582   L 146.88235,230.85691   L 152.4085,229.29403   L 157.79796,227.47718   L 163.07026,225.38683   L 168.2254,223.06205   L 173.24384,220.4833   L 178.10607,217.68965   L 182.81209,214.66157   L 187.36189,211.41859   L 191.75547,207.98026   L 195.97331,204.32702   L 200.01541,200.47843   L 203.86223,196.43448   L 207.51379,192.2147   L 210.95055,187.8191   L 214.19203,183.26722   L 217.21872,178.55904   L 220.01109,173.69458   L 222.58866,168.67382   L 224.91237,163.51632   L 226.98224,158.2416   L 228.81778,152.84966   L 230.37994,147.32098   L 231.68826,141.71414   L 232.70366,135.9901   L 233.44569,130.16837   L 233.89481,124.2685   L 234.05103,118.27094  z " id="path37"/>
			<path style="fill:#d1def2;fill-rule:evenodd;fill-opacity:1;stroke:none;" d="  M 229.40359,118.27094   L 229.38407,116.92296   L 229.36454,115.55544   L 229.32548,114.20746   L 229.2669,112.85947   L 229.18879,111.51149   L 229.11069,110.1635   L 228.99352,108.83506   L 228.87636,107.50661   L 228.73967,106.17816   L 228.60298,104.84971   L 228.42724,103.52126   L 228.2515,102.21235   L 228.05623,100.90344   L 227.84143,99.594528   L 227.6071,98.305152   L 227.37278,96.99624   L 227.11893,95.706864   L 226.84555,94.437024   L 226.55265,93.147648   L 226.25974,91.877808   L 225.92778,90.607968   L 225.61535,89.357664   L 225.26386,88.10736   L 224.91237,86.857056   L 224.54136,85.606752   L 224.15082,84.375984   L 223.74075,83.145216   L 223.33068,81.914448   L 222.90109,80.703216   L 222.4715,79.491984   L 222.00285,78.280752   L 221.5342,77.089056   L 220.47974,76.053648   L 219.40575,75.01824   L 218.33176,74.021904   L 217.23825,73.025568   L 216.12521,72.029232   L 215.01217,71.071968   L 213.8796,70.095168   L 212.74703,69.15744   L 211.59494,68.219712   L 210.44284,67.30152   L 209.27122,66.383328   L 208.08007,65.504208   L 206.88892,64.605552   L 205.69777,63.745968   L 204.4871,62.886384   L 203.27642,62.046336   L 204.25277,63.570144   L 205.2096,65.113488   L 206.14689,66.676368   L 207.04514,68.239248   L 207.92385,69.8412   L 208.76352,71.443152   L 209.58365,73.084176   L 210.38426,74.7252   L 211.14582,76.38576   L 211.88784,78.065856   L 212.59082,79.745952   L 213.27426,81.445584   L 213.91865,83.184288   L 214.52399,84.903456   L 215.1098,86.661696   L 215.67609,88.419936   L 216.20332,90.197712   L 216.69149,91.995024   L 217.14061,93.792336   L 217.57021,95.609184   L 217.98028,97.445568   L 218.33176,99.281952   L 218.66372,101.13787   L 218.95663,102.99379   L 219.23001,104.86925   L 219.46433,106.76424   L 219.6596,108.65923   L 219.81582,110.55422   L 219.93298,112.46875   L 220.03062,114.40282   L 220.0892,116.33688   L 220.10872,118.27094   L 219.97203,123.54566   L 219.58149,128.74224   L 218.91757,133.86067   L 218.01933,138.90096   L 216.88676,143.84357   L 215.50034,148.6885   L 213.89913,153.45528   L 212.06359,158.08531   L 210.01325,162.61766   L 207.76764,167.0328   L 205.28771,171.31118   L 202.63203,175.47235   L 199.78108,179.47723   L 196.75439,183.34536   L 193.53243,187.0572   L 190.15425,190.61275   L 186.60033,193.99248   L 182.8902,197.21592   L 179.02385,200.244   L 175.0208,203.09626   L 170.86154,205.75315   L 166.58512,208.23422   L 162.17201,210.48086   L 157.66127,212.53214   L 153.01384,214.36853   L 148.24924,215.97048   L 143.40654,217.35754   L 138.4662,218.49062   L 133.42822,219.38928   L 128.31214,220.0535   L 123.11795,220.44422   L 117.86518,220.58098   L 112.59288,220.44422   L 107.39869,220.0535   L 102.2826,219.38928   L 97.244628,218.49062   L 92.304288,217.35754   L 87.461584,215.97048   L 82.696988,214.36853   L 78.069081,212.53214   L 73.538809,210.48086   L 69.125699,208.23422   L 64.849279,205.75315   L 60.690021,203.09626   L 56.686979,200.244   L 52.820626,197.21592   L 49.11049,193.99248   L 45.55657,190.61275   L 42.178393,187.0572   L 38.956432,183.34536   L 35.929742,179.47723   L 33.078795,175.47235   L 30.423119,171.31118   L 27.943185,167.0328   L 25.697576,162.61766   L 23.647238,158.08531   L 21.811697,153.45528   L 20.21048,148.6885   L 18.82406,143.84357   L 17.691493,138.90096   L 16.793249,133.86067   L 16.12933,128.74224   L 15.738789,123.54566   L 15.6021,118.27094   L 15.621627,117.19646   L 15.641154,116.10245   L 15.660681,115.02797   L 15.699735,113.95349   L 15.758316,112.87901   L 15.816897,111.80453   L 15.895005,110.73005   L 15.973114,109.6751   L 15.309194,110.94494   L 14.664802,112.23432   L 14.02041,113.54323   L 13.395545,114.83261   L 12.790207,116.14152   L 12.204396,117.46997   L 11.618585,118.79842   L 11.052301,120.12686   L 10.505544,121.47485   L 9.9587872,122.82283   L 9.4510843,124.19035   L 8.9433814,125.53834   L 8.4356786,126.92539   L 7.9670298,128.29291   L 7.4983809,129.67997   L 7.0492592,131.06702   L 7.7717594,136.24406   L 8.709057,141.34296   L 9.8806791,146.36371   L 11.286625,151.28678   L 12.907369,156.11218   L 14.723383,160.83989   L 16.754195,165.46992   L 18.980277,169.9632   L 21.421156,174.3588   L 24.018251,178.61765   L 26.830144,182.75928   L 29.798253,186.76416   L 32.942106,190.63229   L 36.261702,194.34413   L 39.737514,197.91922   L 43.350015,201.31848   L 47.138259,204.56146   L 51.043666,207.64814   L 55.105289,210.55901   L 59.303601,213.27451   L 63.619076,215.81419   L 68.051712,218.15851   L 72.601511,220.30747   L 77.268472,222.26107   L 82.033069,223.99978   L 86.914827,225.52358   L 91.874694,226.8325   L 96.912668,227.90698   L 102.04828,228.76656   L 107.24247,229.37218   L 112.51477,229.74336   L 117.86518,229.88011   L 123.5866,229.72382   L 129.24944,229.29403   L 134.83417,228.59074   L 140.34079,227.61394   L 145.73025,226.36363   L 151.02208,224.85936   L 156.19674,223.10112   L 161.27377,221.10845   L 166.21411,218.86181   L 171.01776,216.40027   L 175.68472,213.72384   L 180.21499,210.81298   L 184.58905,207.70675   L 188.80689,204.38563   L 192.84898,200.88869   L 196.71534,197.17685   L 200.42547,193.30872   L 203.92081,189.26477   L 207.24041,185.04499   L 210.34521,180.66893   L 213.25474,176.13658   L 215.92994,171.46747   L 218.39035,166.66162   L 220.63595,161.71901   L 222.62771,156.63965   L 224.38514,151.46261   L 225.88873,146.16835   L 227.13846,140.77642   L 228.11481,135.26726   L 228.81778,129.67997   L 229.24738,124.01453   L 229.40359,118.27094  z " id="path39"/>
			<path style="fill:#d2e0f3;fill-rule:evenodd;fill-opacity:1;stroke:none;" d="  M 224.75616,118.27094   L 224.73663,116.62992   L 224.69758,114.9889   L 224.639,113.34787   L 224.54136,111.70685   L 224.44373,110.08536   L 224.30704,108.46387   L 224.15082,106.84238   L 223.95555,105.24043   L 223.76028,103.63848   L 223.52595,102.03653   L 223.2721,100.45411   L 222.99872,98.871696   L 222.68629,97.308816   L 222.37386,95.745936   L 222.02237,94.202592   L 221.65136,92.659248   L 221.26082,91.115904   L 220.85075,89.592096   L 220.42116,88.068288   L 219.97203,86.564016   L 219.48386,85.059744   L 218.99568,83.575008   L 218.46845,82.109808   L 217.9217,80.625072   L 217.37494,79.179408   L 216.78913,77.733744   L 216.18379,76.28808   L 215.55893,74.861952   L 214.91453,73.435824   L 214.25061,72.029232   L 213.56717,70.642176   L 212.88372,69.25512   L 211.69257,68.297856   L 210.4819,67.340592   L 209.29075,66.402864   L 208.06054,65.484672   L 206.83034,64.56648   L 205.60014,63.667824   L 204.33088,62.788704   L 203.08115,61.92912   L 201.81189,61.069536   L 200.52311,60.229488   L 199.23432,59.408976   L 197.92601,58.608   L 196.6177,57.807024   L 195.28986,57.025584   L 193.96203,56.26368   L 192.61466,55.521312   L 193.92297,57.123264   L 195.21176,58.764288   L 196.46149,60.424848   L 197.69169,62.104944   L 198.86331,63.824112   L 200.01541,65.562816   L 201.12845,67.340592   L 202.20243,69.118368   L 203.21784,70.935216   L 204.23325,72.791136   L 205.19007,74.647056   L 206.10784,76.542048   L 206.98656,78.43704   L 207.82622,80.371104   L 208.62683,82.324704   L 209.36886,84.29784   L 210.09136,86.290512   L 210.7748,88.30272   L 211.39967,90.354   L 211.98548,92.40528   L 212.53223,94.476096   L 213.02041,96.546912   L 213.46953,98.6568   L 213.8796,100.78622   L 214.25061,102.91565   L 214.56305,105.06461   L 214.83642,107.2331   L 215.05122,109.42114   L 215.22697,111.60917   L 215.34413,113.81674   L 215.42224,116.04384   L 215.46129,118.27094   L 215.3246,123.31123   L 214.95359,128.25384   L 214.32872,133.15738   L 213.46953,137.96323   L 212.37602,142.69094   L 211.06771,147.32098   L 209.52507,151.85333   L 207.78717,156.288   L 205.83446,160.60546   L 203.66696,164.82523   L 201.32372,168.90826   L 198.7852,172.87406   L 196.07095,176.70312   L 193.16142,180.39542   L 190.09567,183.93144   L 186.87371,187.3307   L 183.47601,190.55414   L 179.94162,193.6213   L 176.25101,196.53216   L 172.42371,199.24766   L 168.45972,201.78734   L 164.37857,204.13166   L 160.16073,206.30016   L 155.84526,208.25376   L 151.41262,209.99246   L 146.88235,211.53581   L 142.23491,212.84472   L 137.5289,213.93874   L 132.72525,214.79832   L 127.82396,215.42347   L 122.88362,215.79466   L 117.86518,215.93141   L 112.8272,215.79466   L 107.88686,215.42347   L 102.98558,214.79832   L 98.181926,213.93874   L 93.456383,212.84472   L 88.828476,211.53581   L 84.298205,209.99246   L 79.865568,208.25376   L 75.550093,206.30016   L 71.332254,204.13166   L 67.251104,201.78734   L 63.287116,199.24766   L 59.459818,196.53216   L 55.769208,193.6213   L 52.234815,190.55414   L 48.837111,187.3307   L 45.615151,183.93144   L 42.549406,180.39542   L 39.639878,176.70312   L 36.925621,172.87406   L 34.387106,168.90826   L 32.043862,164.82523   L 29.876362,160.60546   L 27.923658,156.288   L 26.185752,151.85333   L 24.643117,147.32098   L 23.334805,142.69094   L 22.241291,137.96323   L 21.382102,133.15738   L 20.757237,128.25384   L 20.386223,123.31123   L 20.249534,118.27094   L 20.269061,117.05971   L 20.288588,115.82894   L 20.327642,114.61771   L 20.386223,113.40648   L 20.444804,112.19525   L 20.522912,110.98402   L 20.620548,109.77278   L 20.73771,108.58109   L 20.854872,107.38939   L 21.011088,106.1977   L 21.147778,105.006   L 21.323521,103.83384   L 21.499264,102.64214   L 21.714061,101.46998   L 21.909332,100.31736   L 22.143656,99.1452   L 21.343048,100.3955   L 20.542439,101.66534   L 19.761358,102.93518   L 18.999804,104.20502   L 18.257777,105.51394   L 17.515749,106.80331   L 16.812776,108.11222   L 16.090276,109.42114   L 15.40683,110.74958   L 14.723383,112.09757   L 14.078991,113.44555   L 13.415072,114.79354   L 12.790207,116.14152   L 12.184869,117.52858   L 11.579531,118.8961   L 10.99372,120.28315   L 11.228044,125.69462   L 11.71622,131.04749   L 12.477775,136.30267   L 13.49318,141.47971   L 14.74291,146.55907   L 16.246492,151.56029   L 17.984398,156.44429   L 19.937101,161.21107   L 22.104602,165.86064   L 24.4869,170.37346   L 27.083996,174.76906   L 29.876362,179.0279   L 32.863998,183.15   L 36.046904,187.11581   L 39.405554,190.90579   L 42.939947,194.55902   L 46.630557,198.0169   L 50.496909,201.31848   L 54.519478,204.4247   L 58.678736,207.3551   L 62.974684,210.07061   L 67.426847,212.59075   L 71.996173,214.896   L 76.682661,217.00589   L 81.486312,218.88134   L 86.407124,220.52237   L 91.425572,221.92896   L 96.561182,223.10112   L 101.75537,224.01931   L 107.0472,224.68354   L 112.41713,225.09379   L 117.86518,225.23054   L 123.35227,225.07426   L 128.78079,224.664   L 134.13119,223.99978   L 139.40349,223.04251   L 144.55863,221.85082   L 149.63566,220.40515   L 154.61505,218.72506   L 159.45776,216.81053   L 164.20283,214.6811   L 168.81121,212.31725   L 173.2829,209.7385   L 177.6179,206.96438   L 181.81621,203.97538   L 185.83878,200.79101   L 189.72466,197.43082   L 193.4348,193.8948   L 196.96919,190.18296   L 200.32784,186.2953   L 203.51075,182.27088   L 206.49838,178.07064   L 209.27122,173.73365   L 211.84879,169.2599   L 214.21156,164.64941   L 216.34001,159.90216   L 218.25366,155.05723   L 219.93298,150.07555   L 221.37798,144.99619   L 222.56913,139.83869   L 223.50643,134.56397   L 224.18987,129.2111   L 224.59994,123.7801   L 224.75616,118.27094  z " id="path41"/>
			<path style="fill:#d6e2f3;fill-rule:evenodd;fill-opacity:1;stroke:none;" d="  M 220.10872,118.27094   L 220.0892,116.33688   L 220.03062,114.40282   L 219.93298,112.46875   L 219.81582,110.55422   L 219.6596,108.65923   L 219.46433,106.76424   L 219.23001,104.86925   L 218.95663,102.99379   L 218.66372,101.13787   L 218.33176,99.281952   L 217.98028,97.445568   L 217.57021,95.609184   L 217.14061,93.792336   L 216.69149,91.995024   L 216.20332,90.197712   L 215.67609,88.419936   L 215.1098,86.661696   L 214.52399,84.903456   L 213.91865,83.184288   L 213.27426,81.445584   L 212.59082,79.745952   L 211.88784,78.065856   L 211.14582,76.38576   L 210.38426,74.7252   L 209.58365,73.084176   L 208.76352,71.443152   L 207.92385,69.8412   L 207.04514,68.239248   L 206.14689,66.676368   L 205.2096,65.113488   L 204.25277,63.570144   L 203.27642,62.046336   L 201.92906,61.14768   L 200.60122,60.26856   L 199.23432,59.408976   L 197.86743,58.568928   L 196.50054,57.748416   L 195.11412,56.927904   L 193.70817,56.146464   L 192.30223,55.365024   L 190.89628,54.60312   L 189.47081,53.860752   L 188.02581,53.13792   L 186.58081,52.415088   L 185.11628,51.731328   L 183.65175,51.047568   L 182.1677,50.40288   L 180.68364,49.758192   L 182.40202,51.37968   L 184.08135,53.04024   L 185.70209,54.739872   L 187.30331,56.478576   L 188.84594,58.256352   L 190.33,60.0732   L 191.79453,61.92912   L 193.20047,63.824112   L 194.56736,65.758176   L 195.87568,67.731312   L 197.14493,69.723984   L 198.35561,71.755728   L 199.5077,73.826544   L 200.62074,75.936432   L 201.6752,78.065856   L 202.69061,80.234352   L 203.64743,82.422384   L 204.52615,84.649488   L 205.36581,86.896128   L 206.14689,89.162304   L 206.88892,91.467552   L 207.55284,93.792336   L 208.15818,96.156192   L 208.70494,98.520048   L 209.19311,100.92298   L 209.60318,103.34544   L 209.97419,105.78744   L 210.2671,108.24898   L 210.50142,110.73005   L 210.67717,113.23066   L 210.7748,115.7508   L 210.81386,118.27094   L 210.67717,123.05726   L 210.32568,127.78498   L 209.73987,132.43454   L 208.91973,137.0255   L 207.8848,141.51878   L 206.63507,145.93392   L 205.17054,150.25138   L 203.49122,154.47115   L 201.63615,158.59325   L 199.58581,162.59813   L 197.3402,166.50533   L 194.93838,170.27578   L 192.34128,173.90947   L 189.58797,177.42595   L 186.65892,180.80568   L 183.57364,184.02912   L 180.35168,187.11581   L 176.97351,190.04621   L 173.45864,192.80078   L 169.82661,195.39907   L 166.05789,197.802   L 162.15249,200.04864   L 158.14945,202.09992   L 154.02924,203.95584   L 149.8114,205.63594   L 145.49593,207.10114   L 141.08282,208.35144   L 136.5916,209.38685   L 132.00275,210.20736   L 127.35531,210.79344   L 122.62977,211.14509   L 117.86518,211.28184   L 113.08105,211.14509   L 108.35551,210.79344   L 103.70808,210.20736   L 99.119223,209.38685   L 94.628005,208.35144   L 90.214896,207.10114   L 85.899421,205.63594   L 81.681582,203.95584   L 77.561378,202.09992   L 73.558336,200.04864   L 69.652929,197.802   L 65.884212,195.39907   L 62.252183,192.80078   L 58.737317,190.04621   L 55.359141,187.11581   L 52.13718,184.02912   L 49.051909,180.80568   L 46.142381,177.42595   L 43.369542,173.90947   L 40.772446,170.27578   L 38.370621,166.50533   L 36.125012,162.59813   L 34.074674,158.59325   L 32.219606,154.47115   L 30.540281,150.25138   L 29.075753,145.93392   L 27.826023,141.51878   L 26.79109,137.0255   L 25.970955,132.43454   L 25.385144,127.78498   L 25.033657,123.05726   L 24.916495,118.27094   L 24.916495,117.31368   L 24.936022,116.33688   L 24.955549,115.37962   L 24.994603,114.40282   L 25.033657,113.44555   L 25.092238,112.48829   L 25.150819,111.53102   L 25.228928,110.5933   L 25.307036,109.63603   L 25.404671,108.67877   L 25.502306,107.74104   L 25.599941,106.80331   L 25.853793,104.92786   L 26.146698,103.0524   L 26.478658,101.21602   L 26.830144,99.379632   L 27.220685,97.543248   L 27.65028,95.7264   L 28.118929,93.929088   L 28.626631,92.151312   L 29.173388,90.393072   L 29.739672,88.634832   L 28.763321,89.8656   L 27.806496,91.096368   L 26.869198,92.366208   L 25.931901,93.616512   L 25.01413,94.905888   L 24.115887,96.195264   L 23.23717,97.48464   L 22.358454,98.793552   L 21.518791,100.122   L 20.679129,101.45045   L 19.858993,102.79843   L 19.038858,104.14642   L 18.257777,105.51394   L 17.476695,106.88146   L 16.715141,108.26851   L 15.973114,109.6751   L 15.895005,110.73005   L 15.816897,111.80453   L 15.758316,112.87901   L 15.699735,113.95349   L 15.660681,115.02797   L 15.641154,116.10245   L 15.621627,117.19646   L 15.6021,118.27094   L 15.738789,123.54566   L 16.12933,128.74224   L 16.793249,133.86067   L 17.691493,138.90096   L 18.82406,143.84357   L 20.21048,148.6885   L 21.811697,153.45528   L 23.647238,158.08531   L 25.697576,162.61766   L 27.943185,167.0328   L 30.423119,171.31118   L 33.078795,175.47235   L 35.929742,179.47723   L 38.956432,183.34536   L 42.178393,187.0572   L 45.55657,190.61275   L 49.11049,193.99248   L 52.820626,197.21592   L 56.686979,200.244   L 60.690021,203.09626   L 64.849279,205.75315   L 69.125699,208.23422   L 73.538809,210.48086   L 78.069081,212.53214   L 82.696988,214.36853   L 87.461584,215.97048   L 92.304288,217.35754   L 97.244628,218.49062   L 102.2826,219.38928   L 107.39869,220.0535   L 112.59288,220.44422   L 117.86518,220.58098   L 123.11795,220.44422   L 128.31214,220.0535   L 133.42822,219.38928   L 138.4662,218.49062   L 143.40654,217.35754   L 148.24924,215.97048   L 153.01384,214.36853   L 157.66127,212.53214   L 162.17201,210.48086   L 166.58512,208.23422   L 170.86154,205.75315   L 175.0208,203.09626   L 179.02385,200.244   L 182.8902,197.21592   L 186.60033,193.99248   L 190.15425,190.61275   L 193.53243,187.0572   L 196.75439,183.34536   L 199.78108,179.47723   L 202.63203,175.47235   L 205.28771,171.31118   L 207.76764,167.0328   L 210.01325,162.61766   L 212.06359,158.08531   L 213.89913,153.45528   L 215.50034,148.6885   L 216.88676,143.84357   L 218.01933,138.90096   L 218.91757,133.86067   L 219.58149,128.74224   L 219.97203,123.54566   L 220.10872,118.27094  z " id="path43"/>
			<path style="fill:#d7e3f4;fill-rule:evenodd;fill-opacity:1;stroke:none;" d="  M 215.46129,118.27094   L 215.42224,116.04384   L 215.34413,113.81674   L 215.22697,111.60917   L 215.05122,109.42114   L 214.83642,107.2331   L 214.56305,105.06461   L 214.25061,102.91565   L 213.8796,100.78622   L 213.46953,98.6568   L 213.02041,96.546912   L 212.53223,94.476096   L 211.98548,92.40528   L 211.39967,90.354   L 210.7748,88.30272   L 210.09136,86.290512   L 209.36886,84.29784   L 208.62683,82.324704   L 207.82622,80.371104   L 206.98656,78.43704   L 206.10784,76.542048   L 205.19007,74.647056   L 204.23325,72.791136   L 203.21784,70.935216   L 202.20243,69.118368   L 201.12845,67.340592   L 200.01541,65.562816   L 198.86331,63.824112   L 197.69169,62.104944   L 196.46149,60.424848   L 195.21176,58.764288   L 193.92297,57.123264   L 192.61466,55.521312   L 191.09155,54.7008   L 189.56844,53.899824   L 188.02581,53.118384   L 186.48317,52.376016   L 184.92101,51.633648   L 183.33932,50.910816   L 181.75763,50.20752   L 180.15641,49.543296   L 178.5552,48.879072   L 176.93445,48.25392   L 175.31371,47.628768   L 173.67344,47.042688   L 172.01364,46.476144   L 170.37337,45.929136   L 168.69404,45.401664   L 167.01472,44.893728   L 169.20175,46.417536   L 171.34972,47.999952   L 173.43911,49.640976   L 175.46992,51.340608   L 177.46168,53.118384   L 179.39486,54.935232   L 181.26945,56.810688   L 183.08547,58.744752   L 184.86243,60.737424   L 186.56128,62.788704   L 188.20155,64.879056   L 189.78324,67.028016   L 191.28682,69.216048   L 192.73182,71.443152   L 194.11824,73.728864   L 195.44608,76.073184   L 196.69581,78.43704   L 197.86743,80.859504   L 198.96095,83.301504   L 199.99588,85.802112   L 200.9527,88.341792   L 201.83142,90.901008   L 202.63203,93.499296   L 203.35453,96.136656   L 203.99892,98.813088   L 204.56521,101.50906   L 205.05338,104.2441   L 205.44392,106.99867   L 205.75635,109.79232   L 205.97115,112.58597   L 206.10784,115.41869   L 206.16642,118.27094   L 206.04926,122.82283   L 205.69777,127.31611   L 205.13149,131.73125   L 204.36993,136.08778   L 203.37406,140.36616   L 202.18291,144.54686   L 200.79649,148.64942   L 199.2148,152.67384   L 197.45736,156.58104   L 195.50466,160.39056   L 193.37621,164.08286   L 191.07202,167.67749   L 188.61162,171.13536   L 185.995,174.47602   L 183.22216,177.67992   L 180.2931,180.74707   L 177.22736,183.67747   L 174.02492,186.45158   L 170.6858,189.06941   L 167.22952,191.53094   L 163.63654,193.83619   L 159.94593,195.96562   L 156.13816,197.91922   L 152.23275,199.67746   L 148.21019,201.25987   L 144.10951,202.64693   L 139.93072,203.83862   L 135.6543,204.83496   L 131.29977,205.59686   L 126.88667,206.16341   L 122.39545,206.51506   L 117.86518,206.63227   L 113.31538,206.51506   L 108.82416,206.16341   L 104.41105,205.59686   L 100.05652,204.83496   L 95.7801,203.83862   L 91.601315,202.64693   L 87.500638,201.25987   L 83.478069,199.67746   L 79.572662,197.91922   L 75.764891,195.96562   L 72.074281,193.83619   L 68.481307,191.53094   L 65.025022,189.06941   L 61.685899,186.45158   L 58.483466,183.67747   L 55.417722,180.74707   L 52.488667,177.67992   L 49.715828,174.47602   L 47.099205,171.13536   L 44.638799,167.67749   L 42.334609,164.08286   L 40.206162,160.39056   L 38.253459,156.58104   L 36.496026,152.67384   L 34.914336,148.64942   L 33.527917,144.54686   L 32.336768,140.36616   L 31.340889,136.08778   L 30.579335,131.73125   L 30.013051,127.31611   L 29.661564,122.82283   L 29.544402,118.27094   L 29.563929,116.92296   L 29.602983,115.55544   L 29.642037,114.20746   L 29.720145,112.85947   L 29.798253,111.53102   L 29.915416,110.20258   L 30.052105,108.87413   L 30.208321,107.54568   L 30.364537,106.21723   L 30.559808,104.90832   L 30.774605,103.61894   L 30.989403,102.31003   L 31.243254,101.02066   L 31.497105,99.73128   L 31.790011,98.46144   L 32.082916,97.1916   L 32.414876,95.92176   L 32.746836,94.671456   L 33.098322,93.421152   L 33.469336,92.170848   L 33.859876,90.94008   L 34.269944,89.709312   L 34.699539,88.49808   L 35.148661,87.286848   L 35.597782,86.095152   L 36.085958,84.903456   L 36.574134,83.71176   L 37.081837,82.5396   L 37.609067,81.36744   L 38.155824,80.214816   L 38.722108,79.062192   L 39.288392,77.929104   L 38.097243,79.140336   L 36.906094,80.371104   L 35.753999,81.621408   L 34.601904,82.891248   L 33.469336,84.161088   L 32.356295,85.450464   L 31.262781,86.759376   L 30.169267,88.087824   L 29.114807,89.416272   L 28.060347,90.764256   L 27.025415,92.131776   L 26.010009,93.499296   L 25.01413,94.886352   L 24.037779,96.292944   L 23.080954,97.719072   L 22.143656,99.1452   L 21.909332,100.31736   L 21.714061,101.46998   L 21.499264,102.64214   L 21.323521,103.83384   L 21.147778,105.006   L 21.011088,106.1977   L 20.854872,107.38939   L 20.73771,108.58109   L 20.620548,109.77278   L 20.522912,110.98402   L 20.444804,112.19525   L 20.386223,113.40648   L 20.327642,114.61771   L 20.288588,115.82894   L 20.269061,117.05971   L 20.249534,118.27094   L 20.386223,123.31123   L 20.757237,128.25384   L 21.382102,133.15738   L 22.241291,137.96323   L 23.334805,142.69094   L 24.643117,147.32098   L 26.185752,151.85333   L 27.923658,156.288   L 29.876362,160.60546   L 32.043862,164.82523   L 34.387106,168.90826   L 36.925621,172.87406   L 39.639878,176.70312   L 42.549406,180.39542   L 45.615151,183.93144   L 48.837111,187.3307   L 52.234815,190.55414   L 55.769208,193.6213   L 59.459818,196.53216   L 63.287116,199.24766   L 67.251104,201.78734   L 71.332254,204.13166   L 75.550093,206.30016   L 79.865568,208.25376   L 84.298205,209.99246   L 88.828476,211.53581   L 93.456383,212.84472   L 98.181926,213.93874   L 102.98558,214.79832   L 107.88686,215.42347   L 112.8272,215.79466   L 117.86518,215.93141   L 122.88362,215.79466   L 127.82396,215.42347   L 132.72525,214.79832   L 137.5289,213.93874   L 142.23491,212.84472   L 146.88235,211.53581   L 151.41262,209.99246   L 155.84526,208.25376   L 160.16073,206.30016   L 164.37857,204.13166   L 168.45972,201.78734   L 172.42371,199.24766   L 176.25101,196.53216   L 179.94162,193.6213   L 183.47601,190.55414   L 186.87371,187.3307   L 190.09567,183.93144   L 193.16142,180.39542   L 196.07095,176.70312   L 198.7852,172.87406   L 201.32372,168.90826   L 203.66696,164.82523   L 205.83446,160.60546   L 207.78717,156.288   L 209.52507,151.85333   L 211.06771,147.32098   L 212.37602,142.69094   L 213.46953,137.96323   L 214.32872,133.15738   L 214.95359,128.25384   L 215.3246,123.31123   L 215.46129,118.27094  z " id="path45"/>
			<path style="fill:#d9e4f4;fill-rule:evenodd;fill-opacity:1;stroke:none;" d="  M 210.81386,118.27094   L 210.7748,115.7508   L 210.67717,113.23066   L 210.50142,110.73005   L 210.2671,108.24898   L 209.97419,105.78744   L 209.60318,103.34544   L 209.19311,100.92298   L 208.70494,98.520048   L 208.15818,96.156192   L 207.55284,93.792336   L 206.88892,91.467552   L 206.14689,89.162304   L 205.36581,86.896128   L 204.52615,84.649488   L 203.64743,82.422384   L 202.69061,80.234352   L 201.6752,78.065856   L 200.62074,75.936432   L 199.5077,73.826544   L 198.35561,71.755728   L 197.14493,69.723984   L 195.87568,67.731312   L 194.56736,65.758176   L 193.20047,63.824112   L 191.79453,61.92912   L 190.34952,60.0732   L 188.84594,58.256352   L 187.30331,56.478576   L 185.70209,54.739872   L 184.08135,53.04024   L 182.40202,51.37968   L 180.68364,49.758192   L 178.88716,49.015824   L 177.09067,48.312528   L 175.25513,47.609232   L 173.41959,46.964544   L 171.58405,46.319856   L 169.72898,45.71424   L 167.85438,45.12816   L 165.96026,44.581152   L 164.06614,44.05368   L 162.17201,43.56528   L 160.25837,43.096416   L 158.32519,42.666624   L 156.39201,42.256368   L 154.43931,41.885184   L 152.48661,41.533536   L 150.51438,41.201424   L 153.28721,42.451728   L 156.021,43.780176   L 158.6962,45.22584   L 161.31283,46.749648   L 163.85134,48.371136   L 166.3508,50.070768   L 168.77215,51.86808   L 171.1154,53.743536   L 173.40006,55.716672   L 175.62614,57.748416   L 177.75459,59.858304   L 179.82445,62.065872   L 181.79668,64.332048   L 183.71033,66.656832   L 185.52635,69.05976   L 187.24473,71.540832   L 188.885,74.060976   L 190.44716,76.659264   L 191.91169,79.31616   L 193.27858,82.031664   L 194.54784,84.805776   L 195.71946,87.61896   L 196.79345,90.490752   L 197.75027,93.421152   L 198.60946,96.390624   L 199.37101,99.399168   L 200.01541,102.44678   L 200.54264,105.55301   L 200.97223,108.67877   L 201.26514,111.8436   L 201.44088,115.0475   L 201.51899,118.27094   L 201.40183,122.5884   L 201.06987,126.82771   L 200.54264,131.02795   L 199.82014,135.15005   L 198.88284,139.194   L 197.75027,143.15981   L 196.44196,147.04747   L 194.93838,150.85699   L 193.25905,154.56883   L 191.40398,158.16346   L 189.3927,161.67994   L 187.2252,165.0792   L 184.88196,168.36125   L 182.40202,171.50654   L 179.7854,174.55416   L 177.01256,177.46502   L 174.10303,180.23914   L 171.05682,182.85696   L 167.91296,185.33803   L 164.63242,187.68235   L 161.23472,189.85085   L 157.71985,191.86306   L 154.12688,193.71898   L 150.41674,195.39907   L 146.60897,196.90334   L 142.72309,198.21226   L 138.7591,199.34534   L 134.71701,200.26354   L 130.5968,201.0059   L 126.39849,201.53338   L 122.16112,201.86549   L 117.86518,201.9827   L 113.5497,201.86549   L 109.31233,201.53338   L 105.11402,201.0059   L 100.99382,200.26354   L 96.951722,199.34534   L 92.987735,198.21226   L 89.101855,196.90334   L 85.294083,195.39907   L 81.583947,193.71898   L 77.990973,191.86306   L 74.476107,189.85085   L 71.078403,187.68235   L 67.797861,185.33803   L 64.654009,182.85696   L 61.607791,180.23914   L 58.698263,177.46502   L 55.925425,174.55416   L 53.308802,171.50654   L 50.828869,168.36125   L 48.485625,165.0792   L 46.318124,161.67994   L 44.306839,158.16346   L 42.451771,154.56883   L 40.772446,150.85699   L 39.268865,147.04747   L 37.960554,143.15981   L 36.827986,139.194   L 35.910215,135.15005   L 35.168188,131.02795   L 34.640958,126.82771   L 34.308998,122.5884   L 34.191836,118.27094   L 34.211363,116.47363   L 34.269944,114.65678   L 34.367579,112.85947   L 34.504269,111.0817   L 34.680012,109.30392   L 34.875282,107.54568   L 35.129134,105.78744   L 35.402512,104.04874   L 35.714945,102.31003   L 36.066431,100.59086   L 36.456972,98.891232   L 36.886567,97.211136   L 37.335688,95.53104   L 37.823864,93.87048   L 38.331567,92.20992   L 38.897851,90.588432   L 39.483662,88.966944   L 40.089,87.364992   L 40.752919,85.782576   L 41.436366,84.20016   L 42.139339,82.656816   L 42.881366,81.113472   L 43.662447,79.6092   L 44.463056,78.104928   L 45.283191,76.620192   L 46.161908,75.154992   L 47.040624,73.709328   L 47.958395,72.2832   L 48.915219,70.876608   L 49.872044,69.509088   L 50.88745,68.141568   L 51.902856,66.793584   L 50.379747,68.004816   L 48.856638,69.235584   L 47.372584,70.485888   L 45.888529,71.755728   L 44.424002,73.045104   L 42.998528,74.354016   L 41.573055,75.702   L 40.186635,77.049984   L 38.800216,78.43704   L 37.433324,79.824096   L 36.105485,81.250224   L 34.777647,82.676352   L 33.488863,84.141552   L 32.219606,85.626288   L 30.969875,87.111024   L 29.739672,88.634832   L 29.173388,90.393072   L 28.626631,92.151312   L 28.118929,93.929088   L 27.65028,95.7264   L 27.220685,97.543248   L 26.830144,99.379632   L 26.478658,101.21602   L 26.146698,103.0524   L 25.853793,104.92786   L 25.599941,106.80331   L 25.502306,107.74104   L 25.385144,108.67877   L 25.307036,109.63603   L 25.228928,110.5933   L 25.150819,111.53102   L 25.092238,112.48829   L 25.033657,113.44555   L 24.994603,114.40282   L 24.955549,115.37962   L 24.916495,116.33688   L 24.916495,117.31368   L 24.896968,118.27094   L 25.033657,123.05726   L 25.385144,127.78498   L 25.970955,132.43454   L 26.79109,137.0255   L 27.826023,141.51878   L 29.075753,145.93392   L 30.540281,150.25138   L 32.219606,154.47115   L 34.074674,158.59325   L 36.125012,162.59813   L 38.370621,166.50533   L 40.772446,170.27578   L 43.369542,173.90947   L 46.122854,177.42595   L 49.051909,180.80568   L 52.13718,184.02912   L 55.359141,187.11581   L 58.737317,190.04621   L 62.252183,192.80078   L 65.884212,195.39907   L 69.652929,197.802   L 73.558336,200.04864   L 77.561378,202.09992   L 81.681582,203.95584   L 85.899421,205.63594   L 90.214896,207.10114   L 94.628005,208.35144   L 99.119223,209.38685   L 103.70808,210.20736   L 108.35551,210.79344   L 113.08105,211.14509   L 117.86518,211.28184   L 122.62977,211.14509   L 127.35531,210.79344   L 132.00275,210.20736   L 136.5916,209.38685   L 141.08282,208.35144   L 145.49593,207.10114   L 149.8114,205.63594   L 154.02924,203.95584   L 158.14945,202.09992   L 162.15249,200.04864   L 166.05789,197.802   L 169.82661,195.39907   L 173.45864,192.80078   L 176.97351,190.04621   L 180.35168,187.11581   L 183.57364,184.02912   L 186.65892,180.80568   L 189.58797,177.42595   L 192.34128,173.90947   L 194.93838,170.27578   L 197.3402,166.50533   L 199.58581,162.59813   L 201.63615,158.59325   L 203.49122,154.47115   L 205.17054,150.25138   L 206.63507,145.93392   L 207.8848,141.51878   L 208.91973,137.0255   L 209.73987,132.43454   L 210.32568,127.78498   L 210.67717,123.05726   L 210.81386,118.27094  z " id="path47"/>
			<path style="fill:#dce6f5;fill-rule:evenodd;fill-opacity:1;stroke:none;" d="  M 206.16642,118.27094   L 206.10784,115.41869   L 205.97115,112.58597   L 205.75635,109.77278   L 205.44392,106.99867   L 205.05338,104.2441   L 204.56521,101.50906   L 203.99892,98.813088   L 203.35453,96.136656   L 202.63203,93.499296   L 201.83142,90.901008   L 200.9527,88.341792   L 199.99588,85.802112   L 198.96095,83.301504   L 197.86743,80.859504   L 196.69581,78.43704   L 195.44608,76.073184   L 194.11824,73.728864   L 192.73182,71.443152   L 191.28682,69.216048   L 189.78324,67.028016   L 188.20155,64.879056   L 186.56128,62.788704   L 184.86243,60.737424   L 183.08547,58.744752   L 181.26945,56.810688   L 179.39486,54.935232   L 177.46168,53.118384   L 175.46992,51.340608   L 173.43911,49.640976   L 171.34972,47.999952   L 169.20175,46.417536   L 167.01472,44.893728   L 164.86675,44.288112   L 162.67972,43.702032   L 161.5862,43.428528   L 160.49269,43.155024   L 159.37965,42.901056   L 158.28614,42.666624   L 157.17309,42.432192   L 156.06005,42.19776   L 154.94701,41.982864   L 153.83397,41.767968   L 152.7014,41.572608   L 151.58836,41.377248   L 150.45579,41.201424   L 149.32323,41.0256   L 148.19066,40.869312   L 147.05809,40.73256   L 145.92552,40.576272   L 144.77343,40.459056   L 143.62133,40.34184   L 142.48877,40.224624   L 141.33667,40.126944   L 140.16505,40.029264   L 139.01295,39.95112   L 137.86086,39.892512   L 136.68924,39.833904   L 135.53714,39.794832   L 134.36552,39.75576   L 133.1939,39.716688   L 132.02227,39.716688   L 130.85065,39.697152   L 130.36248,39.697152   L 129.8743,39.697152   L 129.38613,39.716688   L 128.91748,39.716688   L 128.4293,39.736224   L 127.94112,39.736224   L 127.45295,39.75576   L 126.9843,39.75576   L 130.63586,40.283232   L 134.24836,40.947456   L 137.78275,41.787504   L 141.27809,42.78384   L 144.69532,43.916928   L 148.03444,45.206304   L 151.29546,46.651968   L 154.49789,48.234384   L 157.60269,49.953552   L 160.60985,51.809472   L 163.53891,53.802144   L 166.37033,55.892496   L 169.10411,58.139136   L 171.74026,60.483456   L 174.25925,62.944992   L 176.66107,65.504208   L 178.96526,68.18064   L 181.13276,70.954752   L 183.20263,73.84608   L 185.11628,76.796016   L 186.91277,79.863168   L 188.57256,83.008464   L 190.09567,86.231904   L 191.48209,89.533488   L 192.7123,92.913216   L 193.78628,96.351552   L 194.70405,99.868032   L 195.46561,103.44312   L 196.07095,107.07682   L 196.50054,110.76912   L 196.77392,114.5005   L 196.87155,118.27094   L 196.75439,122.35397   L 196.46149,126.35885   L 195.95378,130.32466   L 195.25081,134.21232   L 194.37209,138.04138   L 193.31763,141.79229   L 192.0679,145.46506   L 190.66196,149.04014   L 189.08027,152.55662   L 187.32283,155.95589   L 185.42871,159.25747   L 183.35885,162.48091   L 181.17182,165.5676   L 178.82857,168.55661   L 176.32911,171.4284   L 173.71249,174.16344   L 170.97871,176.78126   L 168.10823,179.28187   L 165.1206,181.62619   L 162.03533,183.81422   L 158.81337,185.88504   L 155.5133,187.78003   L 152.11559,189.53827   L 148.60073,191.12069   L 145.02728,192.52728   L 141.3562,193.77758   L 137.60701,194.83253   L 133.77971,195.71165   L 129.89383,196.41494   L 125.92984,196.92288   L 121.9268,197.21592   L 117.86518,197.33314   L 113.78403,197.21592   L 109.78098,196.92288   L 105.817,196.41494   L 101.93112,195.71165   L 98.103817,194.83253   L 94.354627,193.77758   L 90.683545,192.52728   L 87.110097,191.12069   L 83.595231,189.53827   L 80.197527,187.78003   L 76.897459,185.88504   L 73.675498,183.81422   L 70.590227,181.62619   L 67.602591,179.28187   L 64.732117,176.78126   L 61.998332,174.16344   L 59.38171,171.4284   L 56.882249,168.55661   L 54.539005,165.5676   L 52.351977,162.48091   L 50.282112,159.25747   L 48.38799,155.95589   L 46.630557,152.55662   L 45.048867,149.04014   L 43.64292,145.46506   L 42.39319,141.79229   L 41.33873,138.04138   L 40.460014,134.21232   L 39.757041,130.32466   L 39.249338,126.35885   L 38.956432,122.35397   L 38.858797,118.27094   L 38.878324,115.80941   L 38.995486,113.36741   L 39.190757,110.92541   L 39.444608,108.52248   L 39.776568,106.13909   L 40.186635,103.77523   L 40.655284,101.43091   L 41.182514,99.125664   L 41.787852,96.839952   L 42.471298,94.573776   L 43.193799,92.346672   L 44.013934,90.139104   L 44.873123,87.970608   L 45.790894,85.841184   L 46.786773,83.731296   L 47.821706,81.66048   L 48.934746,79.628736   L 50.086841,77.636064   L 51.317045,75.662928   L 52.586302,73.7484   L 53.91414,71.853408   L 55.281032,70.017024   L 56.726033,68.219712   L 58.210087,66.461472   L 59.733196,64.76184   L 61.314886,63.081744   L 62.93563,61.460256   L 64.614955,59.897376   L 66.333334,58.373568   L 68.090767,56.888832   L 69.906781,55.462704   L 71.742322,54.095184   L 70.629281,54.681264   L 69.496713,55.28688   L 68.383672,55.892496   L 67.290158,56.517648   L 66.196644,57.1428   L 65.10313,57.787488   L 64.009617,58.451712   L 62.93563,59.115936   L 61.861643,59.78016   L 60.807183,60.46392   L 59.752723,61.167216   L 58.698263,61.870512   L 57.663331,62.573808   L 56.628398,63.29664   L 55.593465,64.039008   L 54.578059,64.781376   L 53.562653,65.523744   L 52.547248,66.285648   L 51.551369,67.067088   L 50.55549,67.848528   L 49.579139,68.629968   L 48.602787,69.430944   L 47.626435,70.23192   L 46.669611,71.052432   L 45.732313,71.89248   L 44.775488,72.712992   L 43.838191,73.572576   L 42.92042,74.412624   L 42.00265,75.291744   L 41.084879,76.151328   L 40.186635,77.030448   L 39.288392,77.929104   L 38.722108,79.062192   L 38.155824,80.214816   L 37.609067,81.36744   L 37.081837,82.5396   L 36.574134,83.71176   L 36.085958,84.903456   L 35.597782,86.095152   L 35.148661,87.286848   L 34.699539,88.49808   L 34.269944,89.709312   L 33.859876,90.94008   L 33.469336,92.170848   L 33.098322,93.421152   L 32.746836,94.671456   L 32.414876,95.92176   L 32.082916,97.1916   L 31.790011,98.46144   L 31.497105,99.73128   L 31.243254,101.02066   L 30.989403,102.31003   L 30.774605,103.61894   L 30.559808,104.90832   L 30.364537,106.21723   L 30.208321,107.54568   L 30.052105,108.87413   L 29.915416,110.20258   L 29.798253,111.53102   L 29.720145,112.85947   L 29.642037,114.20746   L 29.602983,115.55544   L 29.563929,116.92296   L 29.544402,118.27094   L 29.661564,122.82283   L 30.013051,127.31611   L 30.579335,131.73125   L 31.340889,136.08778   L 32.336768,140.36616   L 33.527917,144.54686   L 34.914336,148.64942   L 36.496026,152.67384   L 38.253459,156.58104   L 40.206162,160.39056   L 42.334609,164.08286   L 44.638799,167.67749   L 47.099205,171.13536   L 49.715828,174.47602   L 52.488667,177.67992   L 55.417722,180.74707   L 58.483466,183.67747   L 61.685899,186.45158   L 65.025022,189.06941   L 68.481307,191.53094   L 72.074281,193.83619   L 75.764891,195.96562   L 79.572662,197.91922   L 83.478069,199.67746   L 87.500638,201.25987   L 91.601315,202.64693   L 95.7801,203.83862   L 100.05652,204.83496   L 104.41105,205.59686   L 108.82416,206.16341   L 113.31538,206.51506   L 117.86518,206.63227   L 122.39545,206.51506   L 126.88667,206.16341   L 131.29977,205.59686   L 135.6543,204.83496   L 139.93072,203.83862   L 144.10951,202.64693   L 148.21019,201.25987   L 152.23275,199.67746   L 156.13816,197.91922   L 159.94593,195.96562   L 163.63654,193.83619   L 167.22952,191.53094   L 170.6858,189.06941   L 174.02492,186.45158   L 177.22736,183.67747   L 180.2931,180.74707   L 183.22216,177.67992   L 185.995,174.47602   L 188.61162,171.13536   L 191.07202,167.67749   L 193.37621,164.08286   L 195.50466,160.39056   L 197.45736,156.58104   L 199.2148,152.67384   L 200.79649,148.64942   L 202.18291,144.54686   L 203.37406,140.36616   L 204.36993,136.08778   L 205.13149,131.73125   L 205.69777,127.31611   L 206.04926,122.82283   L 206.16642,118.27094  z " id="path49"/>
			<path style="fill:#dee7f5;fill-rule:evenodd;fill-opacity:1;stroke:none;" d="  M 201.51899,118.27094   L 201.44088,115.0475   L 201.26514,111.8436   L 200.97223,108.67877   L 200.54264,105.55301   L 200.01541,102.44678   L 199.37101,99.399168   L 198.60946,96.390624   L 197.75027,93.421152   L 196.79345,90.490752   L 195.71946,87.61896   L 194.54784,84.805776   L 193.27858,82.031664   L 191.91169,79.31616   L 190.44716,76.659264   L 188.885,74.060976   L 187.24473,71.540832   L 185.52635,69.05976   L 183.71033,66.656832   L 181.79668,64.332048   L 179.82445,62.065872   L 177.75459,59.858304   L 175.62614,57.748416   L 173.40006,55.716672   L 171.1154,53.743536   L 168.77215,51.86808   L 166.3508,50.070768   L 163.85134,48.371136   L 161.31283,46.749648   L 158.6962,45.22584   L 156.021,43.780176   L 153.28721,42.451728   L 150.51438,41.201424   L 149.3037,41.0256   L 148.09302,40.849776   L 146.88235,40.693488   L 145.67167,40.556736   L 144.461,40.419984   L 143.23079,40.302768   L 142.00059,40.185552   L 140.77039,40.087872   L 139.54018,39.990192   L 138.30998,39.912048   L 137.07978,39.85344   L 135.83005,39.794832   L 134.59984,39.75576   L 133.35011,39.716688   L 132.10038,39.716688   L 130.85065,39.697152   L 128.07781,39.736224   L 125.30498,39.814368   L 122.57119,39.970656   L 119.83741,40.166016   L 117.12315,40.43952   L 114.42842,40.752096   L 111.73369,41.12328   L 109.07801,41.553072   L 106.44186,42.021936   L 103.80571,42.568944   L 101.20862,43.155024   L 98.61152,43.799712   L 96.033952,44.503008   L 93.495437,45.245376   L 90.97645,46.026816   L 88.47699,46.8864   L 85.997056,47.785056   L 83.53665,48.722784   L 81.095771,49.71912   L 78.693946,50.754528   L 76.311648,51.848544   L 73.948877,52.981632   L 71.605633,54.173328   L 69.301443,55.404096   L 67.036307,56.673936   L 64.790698,57.982848   L 62.564616,59.350368   L 60.377588,60.75696   L 58.210087,62.202624   L 56.081641,63.68736   L 53.972721,65.230704   L 51.902856,66.793584   L 50.88745,68.141568   L 49.872044,69.509088   L 48.915219,70.876608   L 47.958395,72.2832   L 47.040624,73.709328   L 46.161908,75.154992   L 45.283191,76.620192   L 44.463056,78.104928   L 43.662447,79.6092   L 42.881366,81.113472   L 42.139339,82.656816   L 41.436366,84.20016   L 40.752919,85.782576   L 40.089,87.364992   L 39.483662,88.966944   L 38.897851,90.588432   L 38.331567,92.20992   L 37.823864,93.87048   L 37.335688,95.53104   L 36.886567,97.211136   L 36.456972,98.891232   L 36.066431,100.59086   L 35.714945,102.31003   L 35.402512,104.04874   L 35.129134,105.78744   L 34.875282,107.54568   L 34.680012,109.30392   L 34.504269,111.0817   L 34.367579,112.85947   L 34.269944,114.65678   L 34.211363,116.47363   L 34.191836,118.27094   L 34.308998,122.5884   L 34.640958,126.82771   L 35.168188,131.02795   L 35.910215,135.15005   L 36.827986,139.194   L 37.960554,143.15981   L 39.268865,147.04747   L 40.772446,150.85699   L 42.451771,154.56883   L 44.306839,158.16346   L 46.318124,161.67994   L 48.485625,165.0792   L 50.828869,168.36125   L 53.308802,171.50654   L 55.925425,174.55416   L 58.698263,177.46502   L 61.607791,180.23914   L 64.654009,182.85696   L 67.797861,185.33803   L 71.078403,187.68235   L 74.476107,189.85085   L 77.990973,191.86306   L 81.583947,193.71898   L 85.294083,195.39907   L 89.101855,196.90334   L 92.987735,198.21226   L 96.951722,199.34534   L 100.99382,200.26354   L 105.11402,201.0059   L 109.31233,201.53338   L 113.5497,201.86549   L 117.86518,201.9827   L 122.16112,201.86549   L 126.39849,201.53338   L 130.5968,201.0059   L 134.71701,200.26354   L 138.7591,199.34534   L 142.72309,198.21226   L 146.60897,196.90334   L 150.41674,195.39907   L 154.12688,193.71898   L 157.71985,191.86306   L 161.23472,189.85085   L 164.63242,187.68235   L 167.91296,185.33803   L 171.05682,182.85696   L 174.10303,180.23914   L 177.01256,177.46502   L 179.7854,174.55416   L 182.40202,171.50654   L 184.88196,168.36125   L 187.2252,165.0792   L 189.3927,161.67994   L 191.40398,158.16346   L 193.25905,154.56883   L 194.93838,150.85699   L 196.44196,147.04747   L 197.75027,143.15981   L 198.88284,139.194   L 199.82014,135.15005   L 200.54264,131.02795   L 201.06987,126.82771   L 201.40183,122.5884   L 201.51899,118.27094  z    M 192.22412,118.27094   L 192.12648,122.1   L 191.83358,125.88998   L 191.36493,129.60182   L 190.70101,133.27459   L 189.88088,136.86922   L 188.86547,140.40523   L 187.69385,143.8631   L 186.36601,147.24283   L 184.88196,150.52488   L 183.24168,153.74832   L 181.4452,156.85454   L 179.51202,159.88262   L 177.44216,162.79349   L 175.2356,165.60667   L 172.89236,168.30264   L 170.43195,170.88139   L 167.85438,173.34293   L 165.15965,175.68725   L 162.34776,177.89482   L 159.43823,179.96563   L 156.41154,181.8997   L 153.30674,183.69701   L 150.08478,185.33803   L 146.80424,186.82277   L 143.42606,188.15122   L 139.96978,189.32338   L 136.43538,190.33925   L 132.84241,191.15976   L 129.17133,191.82398   L 125.46119,192.29285   L 121.67295,192.58589   L 117.86518,192.68357   L 114.03788,192.58589   L 110.24963,192.29285   L 106.5395,191.82398   L 102.86841,191.15976   L 99.275439,190.33925   L 95.741046,189.32338   L 92.284761,188.15122   L 88.906584,186.82277   L 85.626043,185.33803   L 82.404082,183.69701   L 79.299284,181.8997   L 76.272594,179.96563   L 73.363066,177.89482   L 70.551173,175.68725   L 67.856442,173.34293   L 65.278874,170.88139   L 62.818467,168.30264   L 60.475223,165.60667   L 58.268669,162.79349   L 56.198803,159.88262   L 54.265627,156.85454   L 52.46914,153.74832   L 50.828869,150.52488   L 49.344814,147.24283   L 48.016976,143.8631   L 46.845354,140.40523   L 45.829948,136.86922   L 45.009813,133.27459   L 44.345894,129.60182   L 43.877245,125.88998   L 43.584339,122.1   L 43.506231,118.27094   L 43.584339,114.46142   L 43.877245,110.67144   L 44.345894,106.9596   L 45.009813,103.28683   L 45.829948,99.692208   L 46.845354,96.156192   L 48.016976,92.69832   L 49.344814,89.318592   L 50.828869,86.036544   L 52.46914,82.813104   L 54.265627,79.70688   L 56.198803,76.6788   L 58.268669,73.767936   L 60.475223,70.954752   L 62.818467,68.258784   L 65.278874,65.680032   L 67.856442,63.218496   L 70.551173,60.874176   L 73.363066,58.666608   L 76.272594,56.595792   L 79.299284,54.661728   L 82.404082,52.864416   L 85.626043,51.223392   L 88.906584,49.738656   L 92.284761,48.410208   L 95.741046,47.238048   L 99.275439,46.222176   L 102.86841,45.401664   L 106.5395,44.73744   L 110.24963,44.268576   L 114.03788,43.975536   L 117.86518,43.877856   L 121.67295,43.975536   L 125.46119,44.268576   L 129.17133,44.73744   L 132.84241,45.401664   L 136.43538,46.222176   L 139.96978,47.238048   L 143.42606,48.410208   L 146.80424,49.738656   L 150.08478,51.223392   L 153.30674,52.864416   L 156.41154,54.661728   L 159.43823,56.595792   L 162.34776,58.666608   L 165.15965,60.874176   L 167.85438,63.218496   L 170.43195,65.680032   L 172.89236,68.258784   L 175.2356,70.954752   L 177.44216,73.767936   L 179.51202,76.6788   L 181.4452,79.70688   L 183.24168,82.813104   L 184.88196,86.036544   L 186.36601,89.318592   L 187.69385,92.69832   L 188.86547,96.156192   L 189.88088,99.692208   L 190.70101,103.28683   L 191.36493,106.9596   L 191.83358,110.67144   L 192.12648,114.46142   L 192.22412,118.27094  z   " id="path51"/>
			<path style="fill:#dfe9f6;fill-rule:evenodd;fill-opacity:1;stroke:none;" d="  M 196.87155,118.27094   L 196.77392,114.5005   L 196.50054,110.76912   L 196.07095,107.07682   L 195.46561,103.44312   L 194.70405,99.868032   L 193.78628,96.351552   L 192.7123,92.913216   L 191.48209,89.533488   L 190.09567,86.231904   L 188.57256,83.008464   L 186.91277,79.863168   L 185.11628,76.796016   L 183.20263,73.84608   L 181.13276,70.954752   L 178.96526,68.18064   L 176.66107,65.504208   L 174.25925,62.944992   L 171.74026,60.483456   L 169.10411,58.139136   L 166.37033,55.892496   L 163.53891,53.802144   L 160.60985,51.809472   L 157.60269,49.953552   L 154.49789,48.234384   L 151.29546,46.651968   L 148.03444,45.206304   L 144.69532,43.916928   L 141.27809,42.78384   L 137.78275,41.787504   L 134.24836,40.947456   L 130.63586,40.283232   L 126.9843,39.75576   L 125.12923,39.833904   L 123.27416,39.931584   L 121.43862,40.0488   L 119.60308,40.205088   L 117.76754,40.361376   L 115.95153,40.576272   L 114.13551,40.791168   L 112.3195,41.045136   L 110.52301,41.31864   L 108.74605,41.61168   L 106.94956,41.943792   L 105.1726,42.275904   L 103.41517,42.647088   L 101.65774,43.057344   L 99.919832,43.4676   L 98.181926,43.916928   L 96.44402,44.385792   L 94.725641,44.874192   L 93.007262,45.382128   L 91.30841,45.929136   L 89.629085,46.476144   L 87.94976,47.062224   L 86.270435,47.66784   L 84.610637,48.292992   L 82.970366,48.93768   L 81.330095,49.62144   L 79.709352,50.3052   L 78.088608,51.028032   L 76.487391,51.7704   L 74.886174,52.512768   L 73.304485,53.294208   L 71.742322,54.095184   L 69.906781,55.462704   L 68.090767,56.888832   L 66.333334,58.373568   L 64.614955,59.897376   L 62.93563,61.460256   L 61.314886,63.081744   L 59.733196,64.76184   L 58.210087,66.461472   L 56.726033,68.219712   L 55.281032,70.017024   L 53.91414,71.853408   L 52.586302,73.7484   L 51.317045,75.662928   L 50.086841,77.636064   L 48.934746,79.628736   L 47.821706,81.66048   L 46.786773,83.731296   L 45.790894,85.841184   L 44.873123,87.970608   L 44.013934,90.139104   L 43.193799,92.346672   L 42.471298,94.573776   L 41.787852,96.839952   L 41.182514,99.125664   L 40.655284,101.43091   L 40.186635,103.77523   L 39.776568,106.13909   L 39.444608,108.52248   L 39.190757,110.92541   L 38.995486,113.36741   L 38.878324,115.80941   L 38.858797,118.27094   L 38.956432,122.35397   L 39.249338,126.35885   L 39.757041,130.32466   L 40.460014,134.21232   L 41.33873,138.04138   L 42.39319,141.79229   L 43.64292,145.46506   L 45.048867,149.04014   L 46.630557,152.55662   L 48.38799,155.95589   L 50.282112,159.25747   L 52.351977,162.48091   L 54.539005,165.5676   L 56.882249,168.55661   L 59.38171,171.4284   L 61.998332,174.16344   L 64.732117,176.78126   L 67.602591,179.28187   L 70.590227,181.62619   L 73.675498,183.81422   L 76.897459,185.88504   L 80.197527,187.78003   L 83.595231,189.53827   L 87.110097,191.12069   L 90.683545,192.52728   L 94.354627,193.77758   L 98.103817,194.83253   L 101.93112,195.71165   L 105.817,196.41494   L 109.78098,196.92288   L 113.78403,197.21592   L 117.86518,197.33314   L 121.9268,197.21592   L 125.92984,196.92288   L 129.89383,196.41494   L 133.77971,195.71165   L 137.60701,194.83253   L 141.3562,193.77758   L 145.02728,192.52728   L 148.60073,191.12069   L 152.11559,189.53827   L 155.5133,187.78003   L 158.81337,185.88504   L 162.03533,183.81422   L 165.1206,181.62619   L 168.10823,179.28187   L 170.97871,176.78126   L 173.71249,174.16344   L 176.32911,171.4284   L 178.82857,168.55661   L 181.17182,165.5676   L 183.35885,162.48091   L 185.42871,159.25747   L 187.32283,155.95589   L 189.08027,152.55662   L 190.66196,149.04014   L 192.0679,145.46506   L 193.31763,141.79229   L 194.37209,138.04138   L 195.25081,134.21232   L 195.95378,130.32466   L 196.46149,126.35885   L 196.75439,122.35397   L 196.87155,118.27094  z    M 187.57669,118.27094   L 187.47905,121.86557   L 187.20567,125.40158   L 186.75655,128.89853   L 186.15121,132.33686   L 185.37013,135.71659   L 184.43283,139.01818   L 183.33932,142.26115   L 182.08959,145.42598   L 180.68364,148.51267   L 179.16053,151.52122   L 177.48121,154.45162   L 175.6652,157.2648   L 173.71249,159.99984   L 171.64263,162.6372   L 169.4556,165.17688   L 167.15141,167.59934   L 164.73006,169.90459   L 162.19154,172.09262   L 159.55539,174.16344   L 156.82161,176.11704   L 154.00971,177.93389   L 151.08066,179.61398   L 148.0735,181.15733   L 144.98823,182.54438   L 141.82485,183.79469   L 138.58336,184.8887   L 135.28329,185.82643   L 131.90511,186.60787   L 128.46835,187.21349   L 124.97302,187.66282   L 121.43862,187.93632   L 117.86518,188.034   L 114.2722,187.93632   L 110.73781,187.66282   L 107.24247,187.21349   L 103.80571,186.60787   L 100.42753,185.82643   L 97.127466,184.8887   L 93.885978,183.79469   L 90.722599,182.54438   L 87.637327,181.15733   L 84.630164,179.61398   L 81.701109,177.93389   L 78.889216,176.11704   L 76.155431,174.16344   L 73.519282,172.09262   L 70.980768,169.90459   L 68.559415,167.59934   L 66.255225,165.17688   L 64.068198,162.6372   L 61.998332,159.99984   L 60.045629,157.2648   L 58.229615,154.45162   L 56.55029,151.52122   L 55.027181,148.51267   L 53.621235,145.42598   L 52.371504,142.26115   L 51.277991,139.01818   L 50.340693,135.71659   L 49.559612,132.33686   L 48.954274,128.89853   L 48.505152,125.40158   L 48.231773,121.86557   L 48.134138,118.27094   L 48.231773,114.69586   L 48.505152,111.15984   L 48.954274,107.6629   L 49.559612,104.22456   L 50.340693,100.84483   L 51.277991,97.543248   L 52.371504,94.300272   L 53.621235,91.13544   L 55.027181,88.048752   L 56.55029,85.040208   L 58.229615,82.109808   L 60.045629,79.296624   L 61.998332,76.561584   L 64.068198,73.924224   L 66.255225,71.384544   L 68.559415,68.96208   L 70.980768,66.656832   L 73.519282,64.4688   L 76.155431,62.397984   L 78.889216,60.444384   L 81.701109,58.627536   L 84.630164,56.94744   L 87.637327,55.423632   L 90.722599,54.01704   L 93.885978,52.766736   L 97.127466,51.67272   L 100.42753,50.734992   L 103.80571,49.953552   L 107.24247,49.347936   L 110.73781,48.898608   L 114.2722,48.625104   L 117.86518,48.527424   L 121.43862,48.625104   L 124.97302,48.898608   L 128.46835,49.347936   L 131.90511,49.953552   L 135.28329,50.734992   L 138.58336,51.67272   L 141.82485,52.766736   L 144.98823,54.01704   L 148.0735,55.423632   L 151.08066,56.94744   L 154.00971,58.627536   L 156.82161,60.444384   L 159.55539,62.397984   L 162.19154,64.4688   L 164.73006,66.656832   L 167.15141,68.96208   L 169.4556,71.384544   L 171.64263,73.924224   L 173.71249,76.561584   L 175.6652,79.296624   L 177.48121,82.109808   L 179.16053,85.040208   L 180.68364,88.048752   L 182.08959,91.13544   L 183.33932,94.300272   L 184.43283,97.543248   L 185.37013,100.84483   L 186.15121,104.22456   L 186.75655,107.6629   L 187.20567,111.15984   L 187.47905,114.69586   L 187.57669,118.27094  z   " id="path53"/>
			<path style="fill:#e3eaf6;fill-rule:evenodd;fill-opacity:1;stroke:none;" d="  M 192.22412,118.27094   L 192.12648,114.46142   L 191.83358,110.67144   L 191.36493,106.9596   L 190.70101,103.28683   L 189.88088,99.692208   L 188.86547,96.156192   L 187.69385,92.69832   L 186.36601,89.318592   L 184.88196,86.036544   L 183.24168,82.813104   L 181.4452,79.70688   L 179.51202,76.6788   L 177.44216,73.767936   L 175.2356,70.954752   L 172.89236,68.258784   L 170.43195,65.680032   L 167.85438,63.218496   L 165.15965,60.874176   L 162.34776,58.666608   L 159.43823,56.595792   L 156.41154,54.661728   L 153.30674,52.864416   L 150.08478,51.223392   L 146.80424,49.738656   L 143.42606,48.410208   L 139.96978,47.238048   L 136.43538,46.222176   L 132.84241,45.401664   L 129.17133,44.73744   L 125.46119,44.268576   L 121.67295,43.975536   L 117.86518,43.877856   L 114.03788,43.975536   L 110.24963,44.268576   L 106.5395,44.73744   L 102.86841,45.401664   L 99.275439,46.222176   L 95.741046,47.238048   L 92.284761,48.410208   L 88.906584,49.738656   L 85.626043,51.223392   L 82.404082,52.864416   L 79.299284,54.661728   L 76.272594,56.595792   L 73.363066,58.666608   L 70.551173,60.874176   L 67.856442,63.218496   L 65.278874,65.680032   L 62.818467,68.258784   L 60.475223,70.954752   L 58.268669,73.767936   L 56.198803,76.6788   L 54.265627,79.70688   L 52.46914,82.813104   L 50.828869,86.036544   L 49.344814,89.318592   L 48.016976,92.69832   L 46.845354,96.156192   L 45.829948,99.692208   L 45.009813,103.28683   L 44.345894,106.9596   L 43.877245,110.67144   L 43.584339,114.46142   L 43.486704,118.27094   L 43.584339,122.1   L 43.877245,125.88998   L 44.345894,129.60182   L 45.009813,133.27459   L 45.829948,136.86922   L 46.845354,140.40523   L 48.016976,143.8631   L 49.344814,147.24283   L 50.828869,150.52488   L 52.46914,153.74832   L 54.265627,156.85454   L 56.198803,159.88262   L 58.268669,162.79349   L 60.475223,165.60667   L 62.818467,168.30264   L 65.278874,170.88139   L 67.856442,173.34293   L 70.551173,175.68725   L 73.363066,177.89482   L 76.272594,179.96563   L 79.299284,181.8997   L 82.404082,183.69701   L 85.626043,185.33803   L 88.906584,186.82277   L 92.284761,188.15122   L 95.741046,189.32338   L 99.275439,190.33925   L 102.86841,191.15976   L 106.5395,191.82398   L 110.24963,192.29285   L 114.03788,192.58589   L 117.86518,192.68357   L 121.67295,192.58589   L 125.46119,192.29285   L 129.17133,191.82398   L 132.84241,191.15976   L 136.43538,190.33925   L 139.96978,189.32338   L 143.42606,188.15122   L 146.80424,186.82277   L 150.08478,185.33803   L 153.30674,183.69701   L 156.41154,181.8997   L 159.43823,179.96563   L 162.34776,177.89482   L 165.15965,175.68725   L 167.85438,173.34293   L 170.43195,170.88139   L 172.89236,168.30264   L 175.2356,165.60667   L 177.44216,162.79349   L 179.51202,159.88262   L 181.4452,156.85454   L 183.24168,153.74832   L 184.88196,150.52488   L 186.36601,147.24283   L 187.69385,143.8631   L 188.86547,140.40523   L 189.88088,136.86922   L 190.70101,133.27459   L 191.36493,129.60182   L 191.83358,125.88998   L 192.12648,122.1   L 192.22412,118.27094  z    M 182.92925,118.27094   L 182.83162,121.63114   L 182.57777,124.93272   L 182.1677,128.19523   L 181.60141,131.39914   L 180.87891,134.54443   L 180.0002,137.63112   L 178.96526,140.6592   L 177.81317,143.60914   L 176.50486,146.50046   L 175.05986,149.31365   L 173.49769,152.02915   L 171.79884,154.66651   L 170.00236,157.22573   L 168.06918,159.68726   L 166.01884,162.05112   L 163.87087,164.3173   L 161.60573,166.46626   L 159.24296,168.51754   L 156.78255,170.4516   L 154.22451,172.24891   L 151.58836,173.94854   L 148.87411,175.51142   L 146.06221,176.95709   L 143.17221,178.266   L 140.22363,179.41862   L 137.19694,180.45403   L 134.11167,181.33315   L 130.96782,182.05598   L 127.76538,182.62253   L 124.50437,183.03278   L 121.2043,183.28675   L 117.86518,183.38443   L 114.50653,183.28675   L 111.20646,183.03278   L 107.94544,182.62253   L 104.74301,182.05598   L 101.59916,181.33315   L 98.513885,180.45403   L 95.487195,179.41862   L 92.538613,178.266   L 89.648612,176.95709   L 86.836719,175.51142   L 84.122461,173.94854   L 81.486312,172.24891   L 78.92827,170.4516   L 76.467864,168.51754   L 74.105093,166.46626   L 71.839957,164.3173   L 69.691983,162.05112   L 67.641645,159.68726   L 65.708468,157.22573   L 63.911981,154.66651   L 62.213129,152.02915   L 60.650967,149.31365   L 59.205966,146.50046   L 57.897655,143.60914   L 56.74556,140.6592   L 55.710627,137.63112   L 54.831911,134.54443   L 54.10941,131.39914   L 53.543126,128.19523   L 53.133059,124.93272   L 52.879207,121.63114   L 52.801099,118.27094   L 52.879207,114.93029   L 53.133059,111.6287   L 53.543126,108.36619   L 54.10941,105.16229   L 54.831911,102.01699   L 55.710627,98.930304   L 56.74556,95.902224   L 57.897655,92.952288   L 59.205966,90.06096   L 60.650967,87.247776   L 62.213129,84.532272   L 63.911981,81.894912   L 65.708468,79.335696   L 67.641645,76.87416   L 69.691983,74.510304   L 71.839957,72.244128   L 74.105093,70.095168   L 76.467864,68.043888   L 78.92827,66.109824   L 81.486312,64.312512   L 84.122461,62.61288   L 86.836719,61.05   L 89.648612,59.604336   L 92.538613,58.295424   L 95.487195,57.1428   L 98.513885,56.107392   L 101.59916,55.228272   L 104.74301,54.50544   L 107.94544,53.938896   L 111.20646,53.52864   L 114.50653,53.274672   L 117.86518,53.176992   L 121.2043,53.274672   L 124.50437,53.52864   L 127.76538,53.938896   L 130.96782,54.50544   L 134.11167,55.228272   L 137.19694,56.107392   L 140.22363,57.1428   L 143.17221,58.295424   L 146.06221,59.604336   L 148.87411,61.05   L 151.58836,62.61288   L 154.22451,64.312512   L 156.78255,66.109824   L 159.24296,68.043888   L 161.60573,70.095168   L 163.87087,72.244128   L 166.01884,74.510304   L 168.06918,76.87416   L 170.00236,79.335696   L 171.79884,81.894912   L 173.49769,84.532272   L 175.05986,87.247776   L 176.50486,90.06096   L 177.81317,92.952288   L 178.96526,95.902224   L 180.0002,98.930304   L 180.87891,102.01699   L 181.60141,105.16229   L 182.1677,108.36619   L 182.57777,111.6287   L 182.83162,114.93029   L 182.92925,118.27094  z   " id="path55"/>
			<path style="fill:#e4ecf7;fill-rule:evenodd;fill-opacity:1;stroke:none;" d="  M 187.57669,118.27094   L 187.47905,114.69586   L 187.20567,111.15984   L 186.75655,107.6629   L 186.15121,104.22456   L 185.37013,100.84483   L 184.43283,97.543248   L 183.33932,94.300272   L 182.08959,91.13544   L 180.68364,88.048752   L 179.16053,85.040208   L 177.48121,82.109808   L 175.6652,79.296624   L 173.71249,76.561584   L 171.64263,73.924224   L 169.4556,71.384544   L 167.15141,68.96208   L 164.73006,66.656832   L 162.19154,64.4688   L 159.55539,62.397984   L 156.82161,60.444384   L 154.00971,58.627536   L 151.08066,56.94744   L 148.0735,55.423632   L 144.98823,54.01704   L 141.82485,52.766736   L 138.58336,51.67272   L 135.28329,50.734992   L 131.90511,49.953552   L 128.46835,49.347936   L 124.97302,48.898608   L 121.43862,48.625104   L 117.86518,48.527424   L 114.2722,48.625104   L 110.73781,48.898608   L 107.24247,49.347936   L 103.80571,49.953552   L 100.42753,50.734992   L 97.127466,51.67272   L 93.885978,52.766736   L 90.722599,54.01704   L 87.637327,55.423632   L 84.630164,56.94744   L 81.701109,58.627536   L 78.889216,60.444384   L 76.155431,62.397984   L 73.519282,64.4688   L 70.980768,66.656832   L 68.559415,68.96208   L 66.255225,71.384544   L 64.068198,73.924224   L 61.998332,76.561584   L 60.045629,79.296624   L 58.229615,82.109808   L 56.55029,85.040208   L 55.027181,88.048752   L 53.621235,91.13544   L 52.371504,94.300272   L 51.277991,97.543248   L 50.340693,100.84483   L 49.559612,104.22456   L 48.954274,107.6629   L 48.505152,111.15984   L 48.231773,114.69586   L 48.153665,118.27094   L 48.231773,121.86557   L 48.505152,125.40158   L 48.954274,128.89853   L 49.559612,132.33686   L 50.340693,135.71659   L 51.277991,139.01818   L 52.371504,142.26115   L 53.621235,145.42598   L 55.027181,148.51267   L 56.55029,151.52122   L 58.229615,154.45162   L 60.045629,157.2648   L 61.998332,159.99984   L 64.068198,162.6372   L 66.255225,165.17688   L 68.559415,167.59934   L 70.980768,169.90459   L 73.519282,172.09262   L 76.155431,174.16344   L 78.889216,176.11704   L 81.701109,177.93389   L 84.630164,179.61398   L 87.637327,181.13779   L 90.722599,182.54438   L 93.885978,183.79469   L 97.127466,184.8887   L 100.42753,185.82643   L 103.80571,186.60787   L 107.24247,187.21349   L 110.73781,187.66282   L 114.2722,187.93632   L 117.86518,188.034   L 121.43862,187.93632   L 124.97302,187.66282   L 128.46835,187.21349   L 131.90511,186.60787   L 135.28329,185.82643   L 138.58336,184.8887   L 141.82485,183.79469   L 144.98823,182.54438   L 148.0735,181.13779   L 151.08066,179.61398   L 154.00971,177.93389   L 156.82161,176.11704   L 159.55539,174.16344   L 162.19154,172.09262   L 164.73006,169.90459   L 167.15141,167.59934   L 169.4556,165.17688   L 171.64263,162.6372   L 173.71249,159.99984   L 175.6652,157.2648   L 177.48121,154.45162   L 179.16053,151.52122   L 180.68364,148.51267   L 182.08959,145.42598   L 183.33932,142.26115   L 184.43283,139.01818   L 185.37013,135.71659   L 186.15121,132.33686   L 186.75655,128.89853   L 187.20567,125.40158   L 187.47905,121.86557   L 187.57669,118.27094  z    M 178.28182,118.27094   L 178.20371,121.3967   L 177.96939,124.46386   L 177.57884,127.49194   L 177.05161,130.46141   L 176.36817,133.39181   L 175.54803,136.2636   L 174.61074,139.05725   L 173.51722,141.81182   L 172.30655,144.48826   L 170.97871,147.08654   L 169.53371,149.62622   L 167.95202,152.06822   L 166.27269,154.45162   L 164.4762,156.73733   L 162.58208,158.92536   L 160.5708,161.01571   L 158.48141,163.02792   L 156.29438,164.92291   L 154.00971,166.72022   L 151.62742,168.40032   L 149.18654,169.98274   L 146.64802,171.4284   L 144.05093,172.75685   L 141.37572,173.96808   L 138.62241,175.0621   L 135.81052,175.99982   L 132.95957,176.82034   L 130.03052,177.5041   L 127.06241,178.03157   L 124.03572,178.42229   L 120.96997,178.63718   L 117.86518,178.71533   L 114.74085,178.63718   L 111.67511,178.42229   L 108.64842,178.03157   L 105.68031,177.5041   L 102.75125,176.82034   L 99.880777,175.99982   L 97.088412,175.0621   L 94.3351,173.96808   L 91.659896,172.75685   L 89.062801,171.4284   L 86.524286,169.98274   L 84.083407,168.40032   L 81.701109,166.72022   L 79.416446,164.92291   L 77.229418,163.02792   L 75.140026,161.01571   L 73.128741,158.92536   L 71.234619,156.73733   L 69.438132,154.45162   L 67.758807,152.06822   L 66.177117,149.62622   L 64.732117,147.08654   L 63.404278,144.48826   L 62.193602,141.81182   L 61.100088,139.05725   L 60.162791,136.2636   L 59.342655,133.39181   L 58.659209,130.46141   L 58.131979,127.49194   L 57.741439,124.46386   L 57.526641,121.3967   L 57.448533,118.27094   L 57.526641,115.16472   L 57.741439,112.09757   L 58.131979,109.06949   L 58.659209,106.10002   L 59.342655,103.16962   L 60.162791,100.31736   L 61.100088,97.504176   L 62.193602,94.7496   L 63.404278,92.073168   L 64.732117,89.47488   L 66.177117,86.9352   L 67.758807,84.4932   L 69.438132,82.109808   L 71.234619,79.824096   L 73.128741,77.636064   L 75.140026,75.545712   L 77.229418,73.533504   L 79.416446,71.638512   L 81.701109,69.8412   L 84.083407,68.161104   L 86.524286,66.578688   L 89.062801,65.133024   L 91.659896,63.804576   L 94.3351,62.593344   L 97.088412,61.499328   L 99.880777,60.5616   L 102.75125,59.741088   L 105.68031,59.057328   L 108.64842,58.529856   L 111.67511,58.139136   L 114.74085,57.904704   L 117.86518,57.82656   L 120.96997,57.904704   L 124.03572,58.139136   L 127.06241,58.529856   L 130.03052,59.057328   L 132.95957,59.741088   L 135.81052,60.5616   L 138.62241,61.499328   L 141.37572,62.593344   L 144.05093,63.804576   L 146.64802,65.133024   L 149.18654,66.578688   L 151.62742,68.161104   L 154.00971,69.8412   L 156.29438,71.638512   L 158.48141,73.533504   L 160.5708,75.545712   L 162.58208,77.636064   L 164.4762,79.824096   L 166.27269,82.109808   L 167.95202,84.4932   L 169.53371,86.9352   L 170.97871,89.47488   L 172.30655,92.073168   L 173.51722,94.7496   L 174.61074,97.504176   L 175.54803,100.31736   L 176.36817,103.16962   L 177.05161,106.10002   L 177.57884,109.06949   L 177.96939,112.09757   L 178.20371,115.16472   L 178.28182,118.27094  z   " id="path57"/>
			<path style="fill:#e6edf8;fill-rule:evenodd;fill-opacity:1;stroke:none;" d="  M 182.92925,118.27094   L 182.83162,114.93029   L 182.57777,111.6287   L 182.1677,108.36619   L 181.60141,105.16229   L 180.87891,102.01699   L 180.0002,98.930304   L 178.96526,95.902224   L 177.81317,92.952288   L 176.50486,90.06096   L 175.05986,87.247776   L 173.49769,84.532272   L 171.79884,81.894912   L 170.00236,79.335696   L 168.06918,76.87416   L 166.01884,74.510304   L 163.87087,72.244128   L 161.60573,70.095168   L 159.24296,68.043888   L 156.78255,66.109824   L 154.22451,64.312512   L 151.58836,62.61288   L 148.87411,61.05   L 146.06221,59.604336   L 143.17221,58.295424   L 140.22363,57.1428   L 137.19694,56.107392   L 134.11167,55.228272   L 130.96782,54.50544   L 127.76538,53.938896   L 124.50437,53.52864   L 121.2043,53.274672   L 117.86518,53.176992   L 114.50653,53.274672   L 111.20646,53.52864   L 107.94544,53.938896   L 104.74301,54.50544   L 101.59916,55.228272   L 98.513885,56.107392   L 95.487195,57.1428   L 92.538613,58.295424   L 89.648612,59.604336   L 86.836719,61.05   L 84.122461,62.61288   L 81.486312,64.312512   L 78.92827,66.109824   L 76.467864,68.043888   L 74.105093,70.095168   L 71.839957,72.244128   L 69.691983,74.510304   L 67.641645,76.87416   L 65.708468,79.335696   L 63.911981,81.894912   L 62.213129,84.532272   L 60.650967,87.247776   L 59.205966,90.06096   L 57.897655,92.952288   L 56.74556,95.902224   L 55.710627,98.930304   L 54.831911,102.01699   L 54.10941,105.16229   L 53.543126,108.36619   L 53.133059,111.6287   L 52.879207,114.93029   L 52.801099,118.27094   L 52.879207,121.63114   L 53.133059,124.93272   L 53.543126,128.19523   L 54.10941,131.39914   L 54.831911,134.54443   L 55.710627,137.63112   L 56.74556,140.6592   L 57.897655,143.60914   L 59.205966,146.50046   L 60.650967,149.31365   L 62.213129,152.02915   L 63.911981,154.66651   L 65.708468,157.22573   L 67.641645,159.68726   L 69.691983,162.05112   L 71.839957,164.3173   L 74.105093,166.46626   L 76.467864,168.51754   L 78.92827,170.4516   L 81.486312,172.24891   L 84.122461,173.94854   L 86.836719,175.51142   L 89.648612,176.95709   L 92.538613,178.266   L 95.487195,179.41862   L 98.513885,180.45403   L 101.59916,181.33315   L 104.74301,182.05598   L 107.94544,182.62253   L 111.20646,183.03278   L 114.50653,183.28675   L 117.86518,183.38443   L 121.2043,183.28675   L 124.50437,183.03278   L 127.76538,182.62253   L 130.96782,182.05598   L 134.11167,181.33315   L 137.19694,180.45403   L 140.22363,179.41862   L 143.17221,178.266   L 146.06221,176.95709   L 148.87411,175.51142   L 151.58836,173.94854   L 154.22451,172.24891   L 156.78255,170.4516   L 159.24296,168.51754   L 161.60573,166.46626   L 163.87087,164.3173   L 166.01884,162.05112   L 168.06918,159.68726   L 170.00236,157.22573   L 171.79884,154.66651   L 173.49769,152.02915   L 175.05986,149.31365   L 176.50486,146.50046   L 177.81317,143.60914   L 178.96526,140.6592   L 180.0002,137.63112   L 180.87891,134.54443   L 181.60141,131.39914   L 182.1677,128.19523   L 182.57777,124.93272   L 182.83162,121.63114   L 182.92925,118.27094  z    M 173.63438,118.27094   L 173.55628,121.14274   L 173.34148,123.99499   L 172.98999,126.7691   L 172.50182,129.52368   L 171.87695,132.21965   L 171.1154,134.87654   L 170.23668,137.4553   L 169.2408,139.99498   L 168.12776,142.47605   L 166.89756,144.87898   L 165.55019,147.20376   L 164.10519,149.46994   L 162.54303,151.65797   L 160.88323,153.76786   L 159.14532,155.7996   L 157.29026,157.73366   L 155.35708,159.58958   L 153.32627,161.32829   L 151.21735,162.98885   L 149.03032,164.55173   L 146.76519,165.99739   L 144.44147,167.34538   L 142.03964,168.57614   L 139.55971,169.6897   L 137.0212,170.68603   L 134.44363,171.56515   L 131.78795,172.32706   L 129.09322,172.93267   L 126.33991,173.44061   L 123.56707,173.79226   L 120.71612,174.00715   L 117.86518,174.06576   L 114.9947,174.00715   L 112.16328,173.79226   L 109.37092,173.44061   L 106.6176,172.93267   L 103.92287,172.32706   L 101.2672,171.56515   L 98.689628,170.68603   L 96.151114,169.6897   L 93.671181,168.57614   L 91.269356,167.34538   L 88.945639,165.99739   L 86.680503,164.55173   L 84.493475,162.98885   L 82.384555,161.32829   L 80.353744,159.58958   L 78.420567,157.73366   L 76.565499,155.7996   L 74.827593,153.76786   L 73.167795,151.65797   L 71.605633,149.46994   L 70.160632,147.20376   L 68.813267,144.87898   L 67.583064,142.47605   L 66.470023,139.99498   L 65.474144,137.4553   L 64.595428,134.87654   L 63.833873,132.21965   L 63.228535,129.52368   L 62.720832,126.7691   L 62.369346,123.99499   L 62.154548,121.14274   L 62.095967,118.27094   L 62.154548,115.41869   L 62.369346,112.56643   L 62.720832,109.79232   L 63.228535,107.03774   L 63.833873,104.34178   L 64.595428,101.68488   L 65.474144,99.106128   L 66.470023,96.566448   L 67.583064,94.085376   L 68.813267,91.682448   L 70.160632,89.357664   L 71.605633,87.091488   L 73.167795,84.903456   L 74.827593,82.793568   L 76.565499,80.761824   L 78.420567,78.82776   L 80.353744,76.97184   L 82.384555,75.233136   L 84.493475,73.572576   L 86.680503,72.009696   L 88.945639,70.564032   L 91.269356,69.216048   L 93.671181,67.98528   L 96.151114,66.871728   L 98.689628,65.875392   L 101.2672,64.996272   L 103.92287,64.234368   L 106.6176,63.609216   L 109.37092,63.120816   L 112.16328,62.769168   L 114.9947,62.554272   L 117.86518,62.476128   L 120.71612,62.554272   L 123.56707,62.769168   L 126.33991,63.120816   L 129.09322,63.609216   L 131.78795,64.234368   L 134.44363,64.996272   L 137.0212,65.875392   L 139.55971,66.871728   L 142.03964,67.98528   L 144.44147,69.216048   L 146.76519,70.564032   L 149.03032,72.009696   L 151.21735,73.572576   L 153.32627,75.233136   L 155.35708,76.97184   L 157.29026,78.82776   L 159.14532,80.761824   L 160.88323,82.793568   L 162.54303,84.903456   L 164.10519,87.091488   L 165.55019,89.357664   L 166.89756,91.682448   L 168.12776,94.085376   L 169.2408,96.566448   L 170.23668,99.106128   L 171.1154,101.68488   L 171.87695,104.34178   L 172.50182,107.03774   L 172.98999,109.79232   L 173.34148,112.56643   L 173.55628,115.41869   L 173.63438,118.27094  z   " id="path59"/>
			<path style="fill:#e9eff8;fill-rule:evenodd;fill-opacity:1;stroke:none;" d="  M 178.28182,118.27094   L 178.20371,115.16472   L 177.96939,112.09757   L 177.57884,109.06949   L 177.05161,106.10002   L 176.36817,103.16962   L 175.54803,100.31736   L 174.61074,97.504176   L 173.51722,94.7496   L 172.30655,92.073168   L 170.97871,89.47488   L 169.53371,86.9352   L 167.95202,84.4932   L 166.27269,82.109808   L 164.4762,79.824096   L 162.58208,77.636064   L 160.5708,75.545712   L 158.48141,73.533504   L 156.29438,71.638512   L 154.00971,69.8412   L 151.62742,68.161104   L 149.18654,66.578688   L 146.64802,65.133024   L 144.05093,63.804576   L 141.37572,62.593344   L 138.62241,61.499328   L 135.81052,60.5616   L 132.95957,59.741088   L 130.03052,59.057328   L 127.06241,58.529856   L 124.03572,58.139136   L 120.96997,57.904704   L 117.86518,57.82656   L 114.74085,57.904704   L 111.67511,58.139136   L 108.64842,58.529856   L 105.68031,59.057328   L 102.75125,59.741088   L 99.880777,60.5616   L 97.088412,61.499328   L 94.3351,62.593344   L 91.659896,63.804576   L 89.062801,65.133024   L 86.524286,66.578688   L 84.083407,68.161104   L 81.701109,69.8412   L 79.416446,71.638512   L 77.229418,73.533504   L 75.140026,75.545712   L 73.128741,77.636064   L 71.234619,79.824096   L 69.438132,82.109808   L 67.758807,84.4932   L 66.177117,86.9352   L 64.732117,89.47488   L 63.404278,92.073168   L 62.193602,94.7496   L 61.100088,97.504176   L 60.162791,100.31736   L 59.342655,103.16962   L 58.659209,106.10002   L 58.131979,109.06949   L 57.741439,112.09757   L 57.526641,115.16472   L 57.448533,118.27094   L 57.526641,121.3967   L 57.741439,124.46386   L 58.131979,127.49194   L 58.659209,130.46141   L 59.342655,133.39181   L 60.162791,136.2636   L 61.100088,139.05725   L 62.193602,141.81182   L 63.404278,144.48826   L 64.732117,147.08654   L 66.177117,149.62622   L 67.758807,152.06822   L 69.438132,154.45162   L 71.234619,156.73733   L 73.128741,158.92536   L 75.140026,161.01571   L 77.229418,163.02792   L 79.416446,164.92291   L 81.701109,166.72022   L 84.083407,168.40032   L 86.524286,169.98274   L 89.062801,171.4284   L 91.659896,172.75685   L 94.3351,173.96808   L 97.088412,175.0621   L 99.880777,175.99982   L 102.75125,176.82034   L 105.68031,177.5041   L 108.64842,178.03157   L 111.67511,178.42229   L 114.74085,178.63718   L 117.86518,178.71533   L 120.96997,178.63718   L 124.03572,178.42229   L 127.06241,178.03157   L 130.03052,177.5041   L 132.95957,176.82034   L 135.81052,175.99982   L 138.62241,175.0621   L 141.37572,173.96808   L 144.05093,172.75685   L 146.64802,171.4284   L 149.18654,169.98274   L 151.62742,168.40032   L 154.00971,166.72022   L 156.29438,164.92291   L 158.48141,163.02792   L 160.5708,161.01571   L 162.58208,158.92536   L 164.4762,156.73733   L 166.27269,154.45162   L 167.95202,152.06822   L 169.53371,149.62622   L 170.97871,147.08654   L 172.30655,144.48826   L 173.51722,141.81182   L 174.61074,139.05725   L 175.54803,136.2636   L 176.36817,133.39181   L 177.05161,130.46141   L 177.57884,127.49194   L 177.96939,124.46386   L 178.20371,121.3967   L 178.28182,118.27094  z    M 168.98695,118.27094   L 168.90884,120.9083   L 168.71357,123.50659   L 168.38161,126.06581   L 167.93249,128.58595   L 167.36621,131.06702   L 166.68276,133.48949   L 165.88215,135.87288   L 164.96438,138.17813   L 163.92945,140.4443   L 162.81641,142.65187   L 161.56668,144.80083   L 160.23884,146.87165   L 158.81337,148.88386   L 157.30978,150.81792   L 155.68904,152.67384   L 154.00971,154.45162   L 152.23275,156.13171   L 150.37769,157.7532   L 148.44451,159.25747   L 146.43323,160.6836   L 144.36336,162.03158   L 142.21539,163.26235   L 140.00883,164.3759   L 137.76322,165.41131   L 135.43951,166.3295   L 133.05721,167.13048   L 130.63586,167.81424   L 128.15592,168.38078   L 125.63693,168.83011   L 123.07889,169.16222   L 120.4818,169.35758   L 117.86518,169.43573   L 115.22903,169.35758   L 112.63193,169.16222   L 110.07389,168.83011   L 107.5549,168.38078   L 105.07497,167.81424   L 102.65362,167.13048   L 100.27132,166.3295   L 97.967128,165.41131   L 95.701992,164.3759   L 93.495437,163.26235   L 91.347464,162.03158   L 89.277598,160.6836   L 87.266314,159.25747   L 85.333137,157.7532   L 83.478069,156.13171   L 81.701109,154.45162   L 80.021784,152.67384   L 78.40104,150.81792   L 76.897459,148.88386   L 75.471985,146.87165   L 74.12462,144.80083   L 72.894417,142.65187   L 71.781376,140.4443   L 70.746443,138.17813   L 69.828673,135.87288   L 69.028064,133.48949   L 68.344618,131.06702   L 67.778334,128.58595   L 67.329212,126.06581   L 66.997253,123.50659   L 66.801982,120.9083   L 66.723874,118.27094   L 66.801982,115.65312   L 66.997253,113.05483   L 67.329212,110.49562   L 67.778334,107.97547   L 68.344618,105.4944   L 69.028064,103.07194   L 69.828673,100.68854   L 70.746443,98.36376   L 71.781376,96.11712   L 72.894417,93.909552   L 74.12462,91.760592   L 75.471985,89.689776   L 76.897459,87.677568   L 78.40104,85.743504   L 80.021784,83.887584   L 81.701109,82.109808   L 83.478069,80.429712   L 85.333137,78.808224   L 87.266314,77.303952   L 89.277598,75.877824   L 91.347464,74.549376   L 93.495437,73.299072   L 95.701992,72.18552   L 97.967128,71.150112   L 100.27132,70.23192   L 102.65362,69.430944   L 105.07497,68.747184   L 107.5549,68.18064   L 110.07389,67.731312   L 112.63193,67.3992   L 115.22903,67.20384   L 117.86518,67.125696   L 120.4818,67.20384   L 123.07889,67.3992   L 125.63693,67.731312   L 128.15592,68.18064   L 130.63586,68.747184   L 133.05721,69.430944   L 135.43951,70.23192   L 137.76322,71.150112   L 140.00883,72.18552   L 142.21539,73.299072   L 144.36336,74.549376   L 146.43323,75.877824   L 148.44451,77.303952   L 150.37769,78.808224   L 152.23275,80.429712   L 154.00971,82.109808   L 155.68904,83.887584   L 157.30978,85.743504   L 158.81337,87.677568   L 160.23884,89.689776   L 161.56668,91.760592   L 162.81641,93.909552   L 163.92945,96.11712   L 164.96438,98.36376   L 165.88215,100.68854   L 166.68276,103.07194   L 167.36621,105.4944   L 167.93249,107.97547   L 168.38161,110.49562   L 168.71357,113.05483   L 168.90884,115.65312   L 168.98695,118.27094  z   " id="path61"/>
			<path style="fill:#eaf0f9;fill-rule:evenodd;fill-opacity:1;stroke:none;" d="  M 173.63438,118.27094   L 173.55628,115.41869   L 173.34148,112.56643   L 172.98999,109.79232   L 172.50182,107.03774   L 171.87695,104.34178   L 171.1154,101.68488   L 170.23668,99.106128   L 169.2408,96.566448   L 168.12776,94.085376   L 166.89756,91.682448   L 165.55019,89.357664   L 164.10519,87.091488   L 162.54303,84.903456   L 160.88323,82.793568   L 159.14532,80.761824   L 157.29026,78.82776   L 155.35708,76.97184   L 153.32627,75.233136   L 151.21735,73.572576   L 149.03032,72.009696   L 146.76519,70.564032   L 144.44147,69.216048   L 142.03964,67.98528   L 139.55971,66.871728   L 137.0212,65.875392   L 134.44363,64.996272   L 131.78795,64.234368   L 129.09322,63.609216   L 126.33991,63.120816   L 123.56707,62.769168   L 120.71612,62.554272   L 117.86518,62.476128   L 114.9947,62.554272   L 112.16328,62.769168   L 109.37092,63.120816   L 106.6176,63.609216   L 103.92287,64.234368   L 101.2672,64.996272   L 98.689628,65.875392   L 96.151114,66.871728   L 93.671181,67.98528   L 91.269356,69.216048   L 88.945639,70.564032   L 86.680503,72.009696   L 84.493475,73.572576   L 82.384555,75.233136   L 80.353744,76.97184   L 78.420567,78.82776   L 76.565499,80.761824   L 74.827593,82.793568   L 73.167795,84.903456   L 71.605633,87.091488   L 70.160632,89.357664   L 68.813267,91.682448   L 67.583064,94.085376   L 66.470023,96.566448   L 65.474144,99.106128   L 64.595428,101.68488   L 63.833873,104.34178   L 63.228535,107.03774   L 62.720832,109.79232   L 62.369346,112.56643   L 62.154548,115.41869   L 62.095967,118.27094   L 62.154548,121.14274   L 62.369346,123.99499   L 62.720832,126.7691   L 63.228535,129.52368   L 63.833873,132.21965   L 64.595428,134.87654   L 65.474144,137.4553   L 66.470023,139.99498   L 67.583064,142.47605   L 68.813267,144.87898   L 70.160632,147.20376   L 71.605633,149.46994   L 73.167795,151.65797   L 74.827593,153.76786   L 76.565499,155.7996   L 78.420567,157.73366   L 80.353744,159.58958   L 82.384555,161.32829   L 84.493475,162.98885   L 86.680503,164.55173   L 88.945639,165.99739   L 91.269356,167.34538   L 93.671181,168.57614   L 96.151114,169.6897   L 98.689628,170.68603   L 101.2672,171.56515   L 103.92287,172.32706   L 106.6176,172.95221   L 109.37092,173.44061   L 112.16328,173.79226   L 114.9947,174.00715   L 117.86518,174.0853   L 120.71612,174.00715   L 123.56707,173.79226   L 126.33991,173.44061   L 129.09322,172.95221   L 131.78795,172.32706   L 134.44363,171.56515   L 137.0212,170.68603   L 139.55971,169.6897   L 142.03964,168.57614   L 144.44147,167.34538   L 146.76519,165.99739   L 149.03032,164.55173   L 151.21735,162.98885   L 153.32627,161.32829   L 155.35708,159.58958   L 157.29026,157.73366   L 159.14532,155.7996   L 160.88323,153.76786   L 162.54303,151.65797   L 164.10519,149.46994   L 165.55019,147.20376   L 166.89756,144.87898   L 168.12776,142.47605   L 169.2408,139.99498   L 170.23668,137.4553   L 171.1154,134.87654   L 171.87695,132.21965   L 172.50182,129.52368   L 172.98999,126.7691   L 173.34148,123.99499   L 173.55628,121.14274   L 173.63438,118.27094  z    M 164.33952,118.27094   L 164.26141,120.67387   L 164.08566,123.03773   L 163.79276,125.36251   L 163.38269,127.64822   L 162.87499,129.89486   L 162.25012,132.10243   L 161.5081,134.27093   L 160.66843,136.38082   L 159.75066,138.4321   L 158.71573,140.4443   L 157.60269,142.3979   L 156.39201,144.27336   L 155.10323,146.09021   L 153.71681,147.84845   L 152.25228,149.54808   L 150.70965,151.15003   L 149.10843,152.69338   L 147.40958,154.15858   L 145.65214,155.54563   L 143.83613,156.83501   L 141.96154,158.04624   L 140.00883,159.15979   L 137.99755,160.1952   L 135.94721,161.11339   L 133.83829,161.95344   L 131.67079,162.69581   L 129.46423,163.32096   L 127.21862,163.8289   L 124.93396,164.23915   L 122.61024,164.53219   L 120.24747,164.70802   L 117.86518,164.76662   L 115.46335,164.70802   L 113.10058,164.53219   L 110.77686,164.23915   L 108.4922,163.8289   L 106.24659,163.32096   L 104.04004,162.69581   L 101.87253,161.95344   L 99.763615,161.11339   L 97.713277,160.1952   L 95.701992,159.15979   L 93.749289,158.04624   L 91.874694,156.83501   L 90.058679,155.54563   L 88.301246,154.15858   L 86.602395,152.69338   L 85.001178,151.15003   L 83.458542,149.54808   L 81.994015,147.84845   L 80.607595,146.09021   L 79.318811,144.27336   L 78.108135,142.3979   L 76.995094,140.4443   L 75.960161,138.4321   L 75.042391,136.38082   L 74.202728,134.27093   L 73.460701,132.10243   L 72.835836,129.89486   L 72.328133,127.64822   L 71.918065,125.36251   L 71.62516,123.03773   L 71.449416,120.67387   L 71.390835,118.27094   L 71.449416,115.88755   L 71.62516,113.5237   L 71.918065,111.19891   L 72.328133,108.9132   L 72.835836,106.66656   L 73.460701,104.45899   L 74.202728,102.2905   L 75.042391,100.18061   L 75.960161,98.129328   L 76.995094,96.11712   L 78.108135,94.16352   L 79.318811,92.288064   L 80.607595,90.471216   L 81.994015,88.712976   L 83.458542,87.013344   L 85.001178,85.411392   L 86.602395,83.868048   L 88.301246,82.402848   L 90.058679,81.015792   L 91.874694,79.726416   L 93.749289,78.515184   L 95.701992,77.401632   L 97.713277,76.366224   L 99.763615,75.448032   L 101.87253,74.607984   L 104.04004,73.865616   L 106.24659,73.240464   L 108.4922,72.732528   L 110.77686,72.322272   L 113.10058,72.029232   L 115.46335,71.853408   L 117.86518,71.775264   L 120.24747,71.853408   L 122.61024,72.029232   L 124.93396,72.322272   L 127.21862,72.732528   L 129.46423,73.240464   L 131.67079,73.865616   L 133.83829,74.607984   L 135.94721,75.448032   L 137.99755,76.366224   L 140.00883,77.401632   L 141.96154,78.515184   L 143.83613,79.726416   L 145.65214,81.015792   L 147.40958,82.402848   L 149.10843,83.868048   L 150.70965,85.411392   L 152.25228,87.013344   L 153.71681,88.712976   L 155.10323,90.471216   L 156.39201,92.288064   L 157.60269,94.16352   L 158.71573,96.11712   L 159.75066,98.129328   L 160.66843,100.18061   L 161.5081,102.2905   L 162.25012,104.45899   L 162.87499,106.66656   L 163.38269,108.9132   L 163.79276,111.19891   L 164.08566,113.5237   L 164.26141,115.88755   L 164.33952,118.27094  z   " id="path63"/>
			<path style="fill:#ecf1f9;fill-rule:evenodd;fill-opacity:1;stroke:none;" d="  M 168.98695,118.27094   L 168.90884,115.65312   L 168.71357,113.05483   L 168.38161,110.49562   L 167.93249,107.97547   L 167.36621,105.4944   L 166.68276,103.07194   L 165.88215,100.68854   L 164.96438,98.36376   L 163.92945,96.11712   L 162.81641,93.909552   L 161.56668,91.760592   L 160.23884,89.689776   L 158.81337,87.677568   L 157.30978,85.743504   L 155.68904,83.887584   L 154.00971,82.109808   L 152.23275,80.429712   L 150.37769,78.808224   L 148.44451,77.303952   L 146.43323,75.877824   L 144.36336,74.549376   L 142.21539,73.299072   L 140.00883,72.18552   L 137.76322,71.150112   L 135.43951,70.23192   L 133.05721,69.430944   L 130.63586,68.747184   L 128.15592,68.18064   L 125.63693,67.731312   L 123.07889,67.3992   L 120.4818,67.20384   L 117.86518,67.125696   L 115.22903,67.20384   L 112.63193,67.3992   L 110.07389,67.731312   L 107.5549,68.18064   L 105.07497,68.747184   L 102.65362,69.430944   L 100.27132,70.23192   L 97.967128,71.150112   L 95.701992,72.18552   L 93.495437,73.299072   L 91.347464,74.549376   L 89.277598,75.877824   L 87.266314,77.303952   L 85.333137,78.808224   L 83.478069,80.429712   L 81.701109,82.109808   L 80.021784,83.887584   L 78.40104,85.743504   L 76.897459,87.677568   L 75.471985,89.689776   L 74.144147,91.760592   L 72.894417,93.909552   L 71.781376,96.11712   L 70.746443,98.36376   L 69.828673,100.68854   L 69.028064,103.07194   L 68.344618,105.4944   L 67.778334,107.97547   L 67.329212,110.49562   L 66.997253,113.05483   L 66.801982,115.65312   L 66.743401,118.27094   L 66.801982,120.9083   L 66.997253,123.50659   L 67.329212,126.06581   L 67.778334,128.58595   L 68.344618,131.06702   L 69.028064,133.48949   L 69.828673,135.87288   L 70.746443,138.17813   L 71.781376,140.4443   L 72.894417,142.65187   L 74.144147,144.80083   L 75.471985,146.87165   L 76.897459,148.88386   L 78.40104,150.81792   L 80.021784,152.67384   L 81.701109,154.45162   L 83.478069,156.13171   L 85.333137,157.7532   L 87.266314,159.25747   L 89.277598,160.6836   L 91.347464,162.03158   L 93.495437,163.26235   L 95.701992,164.3759   L 97.967128,165.41131   L 100.27132,166.3295   L 102.65362,167.13048   L 105.07497,167.81424   L 107.5549,168.38078   L 110.07389,168.83011   L 112.63193,169.16222   L 115.22903,169.35758   L 117.86518,169.43573   L 120.4818,169.35758   L 123.07889,169.16222   L 125.63693,168.83011   L 128.15592,168.38078   L 130.63586,167.81424   L 133.05721,167.13048   L 135.43951,166.3295   L 137.76322,165.41131   L 140.00883,164.3759   L 142.21539,163.26235   L 144.36336,162.03158   L 146.43323,160.6836   L 148.44451,159.25747   L 150.37769,157.7532   L 152.23275,156.13171   L 154.00971,154.45162   L 155.68904,152.67384   L 157.30978,150.81792   L 158.81337,148.88386   L 160.23884,146.87165   L 161.56668,144.80083   L 162.81641,142.65187   L 163.92945,140.4443   L 164.96438,138.17813   L 165.88215,135.87288   L 166.68276,133.48949   L 167.36621,131.06702   L 167.93249,128.58595   L 168.38161,126.06581   L 168.71357,123.50659   L 168.90884,120.9083   L 168.98695,118.27094  z    M 159.69208,118.27094   L 159.6335,120.43944   L 159.45776,122.54933   L 159.20391,124.65922   L 158.83289,126.7105   L 158.36424,128.74224   L 157.79796,130.71538   L 157.15357,132.66898   L 156.39201,134.56397   L 155.55235,136.41989   L 154.63458,138.2172   L 153.61917,139.97544   L 152.54519,141.67507   L 151.37357,143.3161   L 150.12384,144.89851   L 148.81552,146.42232   L 147.4291,147.86798   L 145.9841,149.25504   L 144.461,150.56395   L 142.87931,151.81426   L 141.23903,152.98642   L 139.54018,154.0609   L 137.78275,155.07677   L 135.98626,155.99496   L 134.13119,156.83501   L 132.23707,157.59691   L 130.28437,158.2416   L 128.31214,158.80814   L 126.28133,159.27701   L 124.23099,159.64819   L 122.1416,159.90216   L 120.01315,160.07798   L 117.86518,160.11706   L 115.69767,160.07798   L 113.58876,159.90216   L 111.47984,159.64819   L 109.4295,159.27701   L 107.39869,158.80814   L 105.42646,158.2416   L 103.47375,157.59691   L 101.57963,156.83501   L 99.724561,155.99496   L 97.928074,155.07677   L 96.170641,154.0609   L 94.471789,152.98642   L 92.831518,151.81426   L 91.249829,150.56395   L 89.72672,149.25504   L 88.281719,147.86798   L 86.8953,146.42232   L 85.586989,144.89851   L 84.337259,143.3161   L 83.165637,141.67507   L 82.09165,139.97544   L 81.076244,138.2172   L 80.158473,136.41989   L 79.318811,134.56397   L 78.557257,132.66898   L 77.912865,130.71538   L 77.346581,128.74224   L 76.877932,126.7105   L 76.506918,124.65922   L 76.253067,122.54933   L 76.077323,120.43944   L 76.038269,118.27094   L 76.077323,116.12198   L 76.253067,114.0121   L 76.506918,111.90221   L 76.877932,109.85093   L 77.346581,107.81918   L 77.912865,105.84605   L 78.557257,103.89245   L 79.318811,101.99746   L 80.158473,100.14154   L 81.076244,98.344224   L 82.09165,96.585984   L 83.165637,94.886352   L 84.337259,93.245328   L 85.586989,91.662912   L 86.8953,90.139104   L 88.281719,88.69344   L 89.72672,87.306384   L 91.249829,85.997472   L 92.831518,84.747168   L 94.471789,83.575008   L 96.170641,82.500528   L 97.928074,81.484656   L 99.724561,80.566464   L 101.57963,79.726416   L 103.47375,78.964512   L 105.42646,78.319824   L 107.39869,77.75328   L 109.4295,77.284416   L 111.47984,76.913232   L 113.58876,76.659264   L 115.69767,76.48344   L 117.86518,76.424832   L 120.01315,76.48344   L 122.1416,76.659264   L 124.23099,76.913232   L 126.28133,77.284416   L 128.31214,77.75328   L 130.28437,78.319824   L 132.23707,78.964512   L 134.13119,79.726416   L 135.98626,80.566464   L 137.78275,81.484656   L 139.54018,82.500528   L 141.23903,83.575008   L 142.87931,84.747168   L 144.461,85.997472   L 145.9841,87.306384   L 147.4291,88.69344   L 148.81552,90.139104   L 150.12384,91.662912   L 151.37357,93.245328   L 152.54519,94.886352   L 153.61917,96.585984   L 154.63458,98.344224   L 155.55235,100.14154   L 156.39201,101.99746   L 157.15357,103.89245   L 157.79796,105.84605   L 158.36424,107.81918   L 158.83289,109.85093   L 159.20391,111.90221   L 159.45776,114.0121   L 159.6335,116.12198   L 159.69208,118.27094  z   " id="path65"/>
			<path style="fill:#eff3fa;fill-rule:evenodd;fill-opacity:1;stroke:none;" d="  M 164.33952,118.27094   L 164.26141,115.88755   L 164.08566,113.5237   L 163.79276,111.19891   L 163.38269,108.9132   L 162.87499,106.66656   L 162.25012,104.45899   L 161.5081,102.2905   L 160.66843,100.18061   L 159.75066,98.129328   L 158.71573,96.11712   L 157.60269,94.16352   L 156.39201,92.288064   L 155.10323,90.471216   L 153.71681,88.712976   L 152.25228,87.013344   L 150.70965,85.411392   L 149.10843,83.868048   L 147.40958,82.402848   L 145.65214,81.015792   L 143.83613,79.726416   L 141.96154,78.515184   L 140.00883,77.401632   L 137.99755,76.366224   L 135.94721,75.448032   L 133.83829,74.607984   L 131.67079,73.865616   L 129.46423,73.240464   L 127.21862,72.732528   L 124.93396,72.322272   L 122.61024,72.029232   L 120.24747,71.853408   L 117.86518,71.775264   L 115.46335,71.853408   L 113.10058,72.029232   L 110.77686,72.322272   L 108.4922,72.732528   L 106.24659,73.240464   L 104.04004,73.865616   L 101.87253,74.607984   L 99.763615,75.448032   L 97.713277,76.366224   L 95.701992,77.401632   L 93.749289,78.515184   L 91.874694,79.726416   L 90.058679,81.015792   L 88.301246,82.402848   L 86.602395,83.868048   L 85.001178,85.411392   L 83.458542,87.013344   L 81.994015,88.712976   L 80.607595,90.471216   L 79.318811,92.288064   L 78.108135,94.16352   L 76.995094,96.11712   L 75.960161,98.129328   L 75.042391,100.18061   L 74.202728,102.2905   L 73.460701,104.45899   L 72.835836,106.66656   L 72.328133,108.9132   L 71.918065,111.19891   L 71.62516,113.5237   L 71.449416,115.88755   L 71.390835,118.27094   L 71.449416,120.67387   L 71.62516,123.03773   L 71.918065,125.36251   L 72.328133,127.64822   L 72.835836,129.89486   L 73.460701,132.10243   L 74.202728,134.27093   L 75.042391,136.38082   L 75.960161,138.4321   L 76.995094,140.4443   L 78.108135,142.3979   L 79.318811,144.27336   L 80.607595,146.09021   L 81.994015,147.84845   L 83.458542,149.54808   L 85.001178,151.15003   L 86.602395,152.69338   L 88.301246,154.15858   L 90.058679,155.54563   L 91.874694,156.83501   L 93.749289,158.04624   L 95.701992,159.15979   L 97.713277,160.1952   L 99.763615,161.11339   L 101.87253,161.95344   L 104.04004,162.69581   L 106.24659,163.32096   L 108.4922,163.8289   L 110.77686,164.23915   L 113.10058,164.53219   L 115.46335,164.70802   L 117.86518,164.76662   L 120.24747,164.70802   L 122.61024,164.53219   L 124.93396,164.23915   L 127.21862,163.8289   L 129.46423,163.32096   L 131.67079,162.69581   L 133.83829,161.95344   L 135.94721,161.11339   L 137.99755,160.1952   L 140.00883,159.15979   L 141.96154,158.04624   L 143.83613,156.83501   L 145.65214,155.54563   L 147.40958,154.15858   L 149.10843,152.69338   L 150.70965,151.15003   L 152.25228,149.54808   L 153.71681,147.84845   L 155.10323,146.09021   L 156.39201,144.27336   L 157.60269,142.3979   L 158.71573,140.4443   L 159.75066,138.4321   L 160.66843,136.38082   L 161.5081,134.27093   L 162.25012,132.10243   L 162.87499,129.89486   L 163.38269,127.64822   L 163.79276,125.36251   L 164.08566,123.03773   L 164.26141,120.67387   L 164.33952,118.27094  z    M 155.04465,118.27094   L 154.98607,120.18547   L 154.84938,122.08046   L 154.61505,123.93638   L 154.28309,125.77277   L 153.87303,127.57008   L 153.36532,129.34786   L 152.77951,131.06702   L 152.11559,132.76666   L 151.37357,134.40768   L 150.55343,136.00963   L 149.65519,137.57251   L 148.67883,139.07678   L 147.6439,140.54198   L 146.55039,141.94858   L 145.37877,143.29656   L 144.14856,144.58594   L 142.85978,145.8167   L 141.51241,146.98886   L 140.10647,148.08288   L 138.64194,149.11829   L 137.13836,150.09509   L 135.5762,150.99374   L 133.97498,151.81426   L 132.33471,152.55662   L 130.63586,153.22085   L 128.91748,153.80693   L 127.14052,154.31486   L 125.34403,154.72512   L 123.50849,155.05723   L 121.65342,155.29166   L 119.7593,155.42842   L 117.86518,155.46749   L 115.95153,155.42842   L 114.0574,155.29166   L 112.20234,155.05723   L 110.36679,154.72512   L 108.57031,154.31486   L 106.79335,153.80693   L 105.07497,153.22085   L 103.37612,152.55662   L 101.73585,151.81426   L 100.13463,150.99374   L 98.572466,150.09509   L 97.068885,149.11829   L 95.604357,148.08288   L 94.198411,146.98886   L 92.851045,145.8167   L 91.562261,144.58594   L 90.332058,143.29656   L 89.160436,141.94858   L 88.066922,140.54198   L 87.031989,139.07678   L 86.055638,137.57251   L 85.157394,136.00963   L 84.337259,134.40768   L 83.595231,132.76666   L 82.931312,131.06702   L 82.345501,129.34786   L 81.837798,127.57008   L 81.427731,125.77277   L 81.095771,123.93638   L 80.861447,122.08046   L 80.724757,120.18547   L 80.685703,118.27094   L 80.724757,116.37595   L 80.861447,114.48096   L 81.095771,112.62504   L 81.427731,110.78866   L 81.837798,108.99134   L 82.345501,107.21357   L 82.931312,105.4944   L 83.595231,103.79477   L 84.337259,102.15374   L 85.157394,100.55179   L 86.055638,98.988912   L 87.031989,97.48464   L 88.066922,96.01944   L 89.160436,94.612848   L 90.332058,93.264864   L 91.562261,91.975488   L 92.851045,90.74472   L 94.198411,89.57256   L 95.604357,88.478544   L 97.068885,87.443136   L 98.572466,86.466336   L 100.13463,85.56768   L 101.73585,84.747168   L 103.37612,84.0048   L 105.07497,83.340576   L 106.79335,82.754496   L 108.57031,82.24656   L 110.36679,81.836304   L 112.20234,81.504192   L 114.0574,81.26976   L 115.95153,81.133008   L 117.86518,81.0744   L 119.7593,81.133008   L 121.65342,81.26976   L 123.50849,81.504192   L 125.34403,81.836304   L 127.14052,82.24656   L 128.91748,82.754496   L 130.63586,83.340576   L 132.33471,84.0048   L 133.97498,84.747168   L 135.5762,85.56768   L 137.13836,86.466336   L 138.64194,87.443136   L 140.10647,88.478544   L 141.51241,89.57256   L 142.85978,90.74472   L 144.14856,91.975488   L 145.37877,93.264864   L 146.55039,94.612848   L 147.6439,96.01944   L 148.67883,97.48464   L 149.65519,98.988912   L 150.55343,100.55179   L 151.37357,102.15374   L 152.11559,103.79477   L 152.77951,105.4944   L 153.36532,107.21357   L 153.87303,108.99134   L 154.28309,110.78866   L 154.61505,112.62504   L 154.84938,114.48096   L 154.98607,116.37595   L 155.04465,118.27094  z   " id="path67"/>
			<path style="fill:#f0f4fa;fill-rule:evenodd;fill-opacity:1;stroke:none;" d="  M 159.69208,118.27094   L 159.6335,116.12198   L 159.45776,114.0121   L 159.20391,111.90221   L 158.83289,109.85093   L 158.36424,107.81918   L 157.79796,105.84605   L 157.15357,103.89245   L 156.39201,101.99746   L 155.55235,100.14154   L 154.63458,98.344224   L 153.61917,96.585984   L 152.54519,94.886352   L 151.37357,93.245328   L 150.12384,91.662912   L 148.81552,90.139104   L 147.4291,88.69344   L 145.9841,87.306384   L 144.461,85.997472   L 142.87931,84.747168   L 141.23903,83.575008   L 139.54018,82.500528   L 137.78275,81.484656   L 135.98626,80.566464   L 134.13119,79.726416   L 132.23707,78.964512   L 130.28437,78.319824   L 128.31214,77.75328   L 126.28133,77.284416   L 124.23099,76.913232   L 122.1416,76.659264   L 120.01315,76.48344   L 117.86518,76.424832   L 115.69767,76.48344   L 113.58876,76.659264   L 111.47984,76.913232   L 109.4295,77.284416   L 107.39869,77.75328   L 105.42646,78.319824   L 103.47375,78.964512   L 101.57963,79.726416   L 99.724561,80.566464   L 97.928074,81.484656   L 96.170641,82.500528   L 94.471789,83.575008   L 92.831518,84.747168   L 91.249829,85.997472   L 89.72672,87.306384   L 88.281719,88.69344   L 86.8953,90.139104   L 85.586989,91.662912   L 84.337259,93.245328   L 83.165637,94.886352   L 82.09165,96.585984   L 81.076244,98.344224   L 80.158473,100.14154   L 79.318811,101.99746   L 78.557257,103.89245   L 77.912865,105.84605   L 77.346581,107.81918   L 76.877932,109.85093   L 76.506918,111.90221   L 76.253067,114.0121   L 76.077323,116.12198   L 76.038269,118.27094   L 76.077323,120.43944   L 76.253067,122.54933   L 76.506918,124.65922   L 76.877932,126.7105   L 77.346581,128.74224   L 77.912865,130.71538   L 78.557257,132.66898   L 79.318811,134.56397   L 80.158473,136.41989   L 81.076244,138.2172   L 82.09165,139.97544   L 83.165637,141.67507   L 84.337259,143.3161   L 85.586989,144.89851   L 86.8953,146.42232   L 88.281719,147.86798   L 89.72672,149.25504   L 91.249829,150.56395   L 92.831518,151.81426   L 94.471789,152.98642   L 96.170641,154.0609   L 97.928074,155.07677   L 99.724561,155.99496   L 101.57963,156.83501   L 103.47375,157.59691   L 105.42646,158.2416   L 107.39869,158.80814   L 109.4295,159.27701   L 111.47984,159.64819   L 113.58876,159.90216   L 115.69767,160.07798   L 117.86518,160.11706   L 120.01315,160.07798   L 122.1416,159.90216   L 124.23099,159.64819   L 126.28133,159.27701   L 128.31214,158.80814   L 130.28437,158.2416   L 132.23707,157.59691   L 134.13119,156.83501   L 135.98626,155.99496   L 137.78275,155.07677   L 139.54018,154.0609   L 141.23903,152.98642   L 142.87931,151.81426   L 144.461,150.56395   L 145.9841,149.25504   L 147.4291,147.86798   L 148.81552,146.42232   L 150.12384,144.89851   L 151.37357,143.3161   L 152.54519,141.67507   L 153.61917,139.97544   L 154.63458,138.2172   L 155.55235,136.41989   L 156.39201,134.56397   L 157.15357,132.66898   L 157.79796,130.71538   L 158.36424,128.74224   L 158.83289,126.7105   L 159.20391,124.65922   L 159.45776,122.54933   L 159.6335,120.43944   L 159.69208,118.27094  z    M 150.39721,118.27094   L 150.33863,119.95104   L 150.22147,121.6116   L 150.00667,123.23309   L 149.73329,124.83504   L 149.36228,126.41746   L 148.93269,127.9608   L 148.40546,129.46507   L 147.83917,130.94981   L 147.17525,132.39547   L 146.45275,133.80206   L 145.67167,135.15005   L 144.83201,136.4785   L 143.93377,137.74834   L 142.95741,138.9791   L 141.94201,140.1708   L 140.86802,141.30389   L 139.73545,142.37837   L 138.5443,143.39424   L 137.3141,144.37104   L 136.04484,145.2697   L 134.71701,146.10974   L 133.36964,146.89118   L 131.96369,147.61402   L 130.51869,148.27824   L 129.03464,148.84478   L 127.53106,149.37226   L 125.98842,149.80205   L 124.40673,150.17323   L 122.80552,150.44674   L 121.18477,150.66163   L 119.52497,150.77885   L 117.86518,150.83746   L 116.18585,150.77885   L 114.52605,150.66163   L 112.90531,150.44674   L 111.30409,150.17323   L 109.7224,149.80205   L 108.17977,149.37226   L 106.67619,148.84478   L 105.19213,148.27824   L 103.74713,147.61402   L 102.34118,146.89118   L 100.99382,146.10974   L 99.66598,145.2697   L 98.396723,144.37104   L 97.16652,143.39424   L 95.975371,142.37837   L 94.842803,141.30389   L 93.768816,140.1708   L 92.75341,138.9791   L 91.777058,137.74834   L 90.878815,136.4785   L 90.039152,135.15005   L 89.258071,133.80206   L 88.535571,132.39547   L 87.871652,130.94981   L 87.305368,129.46507   L 86.778138,127.9608   L 86.348543,126.41746   L 85.977529,124.83504   L 85.704151,123.23309   L 85.489354,121.6116   L 85.372191,119.95104   L 85.333137,118.27094   L 85.372191,116.61038   L 85.489354,114.94982   L 85.704151,113.32834   L 85.977529,111.72638   L 86.348543,110.14397   L 86.778138,108.60062   L 87.305368,107.09635   L 87.871652,105.61162   L 88.535571,104.16595   L 89.258071,102.75936   L 90.039152,101.41138   L 90.878815,100.08293   L 91.777058,98.813088   L 92.75341,97.58232   L 93.768816,96.390624   L 94.842803,95.257536   L 95.975371,94.183056   L 97.16652,93.167184   L 98.396723,92.190384   L 99.66598,91.291728   L 100.99382,90.45168   L 102.34118,89.67024   L 103.74713,88.947408   L 105.19213,88.283184   L 106.67619,87.71664   L 108.17977,87.189168   L 109.7224,86.759376   L 111.30409,86.388192   L 112.90531,86.114688   L 114.52605,85.899792   L 116.18585,85.782576   L 117.86518,85.723968   L 119.52497,85.782576   L 121.18477,85.899792   L 122.80552,86.114688   L 124.40673,86.388192   L 125.98842,86.759376   L 127.53106,87.189168   L 129.03464,87.71664   L 130.51869,88.283184   L 131.96369,88.947408   L 133.36964,89.67024   L 134.71701,90.45168   L 136.04484,91.291728   L 137.3141,92.190384   L 138.5443,93.167184   L 139.73545,94.183056   L 140.86802,95.257536   L 141.94201,96.390624   L 142.95741,97.58232   L 143.93377,98.813088   L 144.83201,100.08293   L 145.67167,101.41138   L 146.45275,102.75936   L 147.17525,104.16595   L 147.83917,105.61162   L 148.40546,107.09635   L 148.93269,108.60062   L 149.36228,110.14397   L 149.73329,111.72638   L 150.00667,113.32834   L 150.22147,114.94982   L 150.33863,116.61038   L 150.39721,118.27094  z   " id="path69"/>
			<path style="fill:#f1f5fb;fill-rule:evenodd;fill-opacity:1;stroke:none;" d="  M 155.04465,118.27094   L 154.98607,116.37595   L 154.84938,114.48096   L 154.61505,112.62504   L 154.28309,110.78866   L 153.87303,108.99134   L 153.36532,107.21357   L 152.77951,105.4944   L 152.11559,103.79477   L 151.37357,102.15374   L 150.55343,100.55179   L 149.65519,98.988912   L 148.67883,97.48464   L 147.6439,96.01944   L 146.55039,94.612848   L 145.37877,93.264864   L 144.14856,91.975488   L 142.85978,90.74472   L 141.51241,89.57256   L 140.10647,88.478544   L 138.64194,87.443136   L 137.13836,86.466336   L 135.5762,85.56768   L 133.97498,84.747168   L 132.33471,84.0048   L 130.63586,83.340576   L 128.91748,82.754496   L 127.14052,82.24656   L 125.34403,81.836304   L 123.50849,81.504192   L 121.65342,81.26976   L 119.7593,81.133008   L 117.86518,81.0744   L 115.95153,81.133008   L 114.0574,81.26976   L 112.20234,81.504192   L 110.36679,81.836304   L 108.57031,82.24656   L 106.79335,82.754496   L 105.07497,83.340576   L 103.37612,84.0048   L 101.73585,84.747168   L 100.13463,85.56768   L 98.572466,86.466336   L 97.068885,87.443136   L 95.604357,88.478544   L 94.198411,89.57256   L 92.851045,90.74472   L 91.562261,91.975488   L 90.332058,93.264864   L 89.160436,94.612848   L 88.066922,96.01944   L 87.031989,97.48464   L 86.055638,98.988912   L 85.157394,100.55179   L 84.337259,102.15374   L 83.595231,103.79477   L 82.931312,105.4944   L 82.345501,107.21357   L 81.837798,108.99134   L 81.427731,110.78866   L 81.095771,112.62504   L 80.861447,114.48096   L 80.724757,116.37595   L 80.685703,118.27094   L 80.724757,120.18547   L 80.861447,122.08046   L 81.095771,123.93638   L 81.427731,125.77277   L 81.837798,127.57008   L 82.345501,129.34786   L 82.931312,131.06702   L 83.595231,132.76666   L 84.337259,134.40768   L 85.157394,136.00963   L 86.055638,137.57251   L 87.031989,139.07678   L 88.066922,140.54198   L 89.160436,141.94858   L 90.332058,143.29656   L 91.562261,144.58594   L 92.851045,145.8167   L 94.198411,146.98886   L 95.604357,148.08288   L 97.068885,149.11829   L 98.572466,150.09509   L 100.13463,150.99374   L 101.73585,151.81426   L 103.37612,152.55662   L 105.07497,153.22085   L 106.79335,153.80693   L 108.57031,154.31486   L 110.36679,154.72512   L 112.20234,155.05723   L 114.0574,155.29166   L 115.95153,155.42842   L 117.86518,155.46749   L 119.7593,155.42842   L 121.65342,155.29166   L 123.50849,155.05723   L 125.34403,154.72512   L 127.14052,154.31486   L 128.91748,153.80693   L 130.63586,153.22085   L 132.33471,152.55662   L 133.97498,151.81426   L 135.5762,150.99374   L 137.13836,150.09509   L 138.64194,149.11829   L 140.10647,148.08288   L 141.51241,146.98886   L 142.85978,145.8167   L 144.14856,144.58594   L 145.37877,143.29656   L 146.55039,141.94858   L 147.6439,140.54198   L 148.67883,139.07678   L 149.65519,137.57251   L 150.55343,136.00963   L 151.37357,134.40768   L 152.11559,132.76666   L 152.77951,131.06702   L 153.36532,129.34786   L 153.87303,127.57008   L 154.28309,125.77277   L 154.61505,123.93638   L 154.84938,122.08046   L 154.98607,120.18547   L 155.04465,118.27094  z    M 145.74978,118.27094   L 145.71073,119.71661   L 145.59356,121.1232   L 145.41782,122.52979   L 145.1835,123.89731   L 144.87106,125.2453   L 144.48052,126.57374   L 144.05093,127.88266   L 143.54322,129.13296   L 142.99647,130.38326   L 142.3716,131.57496   L 141.70768,132.74712   L 140.98518,133.88021   L 140.2041,134.97422   L 139.36444,136.02917   L 138.50525,137.04504   L 137.56795,138.0023   L 136.61113,138.94003   L 135.59572,139.79962   L 134.54126,140.63966   L 133.44775,141.4211   L 132.31518,142.14394   L 131.14356,142.80816   L 129.95241,143.43331   L 128.70268,143.98032   L 127.43342,144.48826   L 126.14464,144.91805   L 124.8168,145.30877   L 123.46943,145.60181   L 122.10254,145.85578   L 120.71612,146.0316   L 119.29065,146.14882   L 117.86518,146.16835   L 116.42017,146.14882   L 115.01423,146.0316   L 113.60828,145.85578   L 112.24139,145.60181   L 110.89402,145.30877   L 109.56619,144.91805   L 108.2774,144.48826   L 107.00814,143.98032   L 105.75841,143.43331   L 104.56727,142.80816   L 103.39564,142.14394   L 102.26308,141.4211   L 101.16956,140.63966   L 100.1151,139.79962   L 99.099696,138.94003   L 98.142871,138.0023   L 97.205574,137.04504   L 96.346384,136.02917   L 95.506722,134.97422   L 94.725641,133.88021   L 94.00314,132.74712   L 93.339221,131.57496   L 92.714356,130.38326   L 92.167599,129.13296   L 91.659896,127.88266   L 91.230302,126.57374   L 90.839761,125.2453   L 90.546855,123.89731   L 90.293004,122.52979   L 90.117261,121.1232   L 90.000098,119.71661   L 89.980571,118.27094   L 90.000098,116.84482   L 90.117261,115.43822   L 90.293004,114.03163   L 90.546855,112.66411   L 90.839761,111.31613   L 91.230302,109.98768   L 91.659896,108.6983   L 92.167599,107.42846   L 92.714356,106.17816   L 93.339221,104.98646   L 94.00314,103.8143   L 94.725641,102.68122   L 95.506722,101.5872   L 96.346384,100.53226   L 97.205574,99.516384   L 98.142871,98.55912   L 99.099696,97.621392   L 100.1151,96.761808   L 101.16956,95.92176   L 102.26308,95.14032   L 103.39564,94.417488   L 104.56727,93.753264   L 105.75841,93.128112   L 107.00814,92.581104   L 108.2774,92.073168   L 109.56619,91.643376   L 110.89402,91.252656   L 112.24139,90.959616   L 113.60828,90.705648   L 115.01423,90.529824   L 116.42017,90.412608   L 117.86518,90.373536   L 119.29065,90.412608   L 120.71612,90.529824   L 122.10254,90.705648   L 123.46943,90.959616   L 124.8168,91.252656   L 126.14464,91.643376   L 127.43342,92.073168   L 128.70268,92.581104   L 129.95241,93.128112   L 131.14356,93.753264   L 132.31518,94.417488   L 133.44775,95.14032   L 134.54126,95.92176   L 135.59572,96.761808   L 136.61113,97.621392   L 137.56795,98.55912   L 138.50525,99.516384   L 139.36444,100.53226   L 140.2041,101.5872   L 140.98518,102.68122   L 141.70768,103.8143   L 142.3716,104.98646   L 142.99647,106.17816   L 143.54322,107.42846   L 144.05093,108.6983   L 144.48052,109.98768   L 144.87106,111.31613   L 145.1835,112.66411   L 145.41782,114.03163   L 145.59356,115.43822   L 145.71073,116.84482   L 145.74978,118.27094  z   " id="path71"/>
			<path style="fill:#f4f7fb;fill-rule:evenodd;fill-opacity:1;stroke:none;" d="  M 150.39721,118.27094   L 150.33863,116.61038   L 150.22147,114.94982   L 150.00667,113.32834   L 149.73329,111.72638   L 149.36228,110.14397   L 148.93269,108.60062   L 148.40546,107.09635   L 147.83917,105.61162   L 147.17525,104.16595   L 146.45275,102.75936   L 145.67167,101.41138   L 144.83201,100.08293   L 143.91424,98.813088   L 142.95741,97.58232   L 141.94201,96.390624   L 140.86802,95.257536   L 139.73545,94.183056   L 138.5443,93.167184   L 137.3141,92.20992   L 136.04484,91.291728   L 134.71701,90.45168   L 133.36964,89.67024   L 131.96369,88.947408   L 130.51869,88.283184   L 129.03464,87.71664   L 127.53106,87.189168   L 125.98842,86.759376   L 124.40673,86.388192   L 122.80552,86.114688   L 121.18477,85.899792   L 119.52497,85.782576   L 117.86518,85.723968   L 116.18585,85.782576   L 114.52605,85.899792   L 112.90531,86.114688   L 111.30409,86.388192   L 109.7224,86.759376   L 108.17977,87.189168   L 106.67619,87.71664   L 105.19213,88.283184   L 103.74713,88.947408   L 102.34118,89.67024   L 100.99382,90.45168   L 99.66598,91.291728   L 98.396723,92.20992   L 97.16652,93.167184   L 95.975371,94.183056   L 94.842803,95.257536   L 93.768816,96.390624   L 92.75341,97.58232   L 91.777058,98.813088   L 90.878815,100.08293   L 90.039152,101.41138   L 89.258071,102.75936   L 88.535571,104.16595   L 87.871652,105.61162   L 87.305368,107.09635   L 86.778138,108.60062   L 86.348543,110.14397   L 85.977529,111.72638   L 85.704151,113.32834   L 85.489354,114.94982   L 85.372191,116.61038   L 85.333137,118.27094   L 85.372191,119.95104   L 85.489354,121.6116   L 85.704151,123.23309   L 85.977529,124.83504   L 86.348543,126.41746   L 86.778138,127.9608   L 87.305368,129.46507   L 87.871652,130.94981   L 88.535571,132.39547   L 89.258071,133.80206   L 90.039152,135.15005   L 90.878815,136.4785   L 91.777058,137.74834   L 92.75341,138.9791   L 93.768816,140.1708   L 94.842803,141.30389   L 95.975371,142.37837   L 97.16652,143.39424   L 98.396723,144.37104   L 99.66598,145.2697   L 100.99382,146.10974   L 102.34118,146.89118   L 103.74713,147.61402   L 105.19213,148.27824   L 106.67619,148.84478   L 108.17977,149.37226   L 109.7224,149.80205   L 111.30409,150.17323   L 112.90531,150.44674   L 114.52605,150.66163   L 116.18585,150.77885   L 117.86518,150.81792   L 119.52497,150.77885   L 121.18477,150.66163   L 122.80552,150.44674   L 124.40673,150.17323   L 125.98842,149.80205   L 127.53106,149.37226   L 129.03464,148.84478   L 130.51869,148.27824   L 131.96369,147.61402   L 133.36964,146.89118   L 134.71701,146.10974   L 136.04484,145.2697   L 137.3141,144.37104   L 138.5443,143.39424   L 139.73545,142.37837   L 140.86802,141.30389   L 141.94201,140.1708   L 142.95741,138.9791   L 143.91424,137.74834   L 144.83201,136.4785   L 145.67167,135.15005   L 146.45275,133.80206   L 147.17525,132.39547   L 147.83917,130.94981   L 148.40546,129.46507   L 148.93269,127.9608   L 149.36228,126.41746   L 149.73329,124.83504   L 150.00667,123.23309   L 150.22147,121.6116   L 150.33863,119.95104   L 150.39721,118.27094  z    M 141.10235,118.27094   L 141.06329,119.48218   L 140.96566,120.65434   L 140.82897,121.8265   L 140.61417,122.95958   L 140.36032,124.09267   L 140.04789,125.18669   L 139.67687,126.2807   L 139.2668,127.33565   L 138.79816,128.35152   L 138.29045,129.36739   L 137.72417,130.34419   L 137.11883,131.28192   L 136.47444,132.18058   L 135.79099,133.0597   L 135.04897,133.91928   L 134.28741,134.72026   L 133.4868,135.48216   L 132.62761,136.22453   L 131.7489,136.90829   L 130.85065,137.55298   L 129.91336,138.15859   L 128.937,138.72514   L 127.9216,139.23307   L 126.90619,139.70194   L 125.85173,140.11219   L 124.75822,140.48338   L 123.6647,140.79595   L 122.53214,141.04992   L 121.39957,141.26482   L 120.22795,141.40157   L 119.05632,141.49925   L 117.86518,141.51878   L 116.6545,141.49925   L 115.48288,141.40157   L 114.31126,141.26482   L 113.17869,141.04992   L 112.04612,140.79595   L 110.95261,140.48338   L 109.85909,140.11219   L 108.80463,139.70194   L 107.78923,139.23307   L 106.77382,138.72514   L 105.79747,138.15859   L 104.86017,137.55298   L 103.96193,136.90829   L 103.08321,136.22453   L 102.22402,135.48216   L 101.42341,134.72026   L 100.66186,133.91928   L 99.919832,133.0597   L 99.236385,132.18058   L 98.591993,131.28192   L 97.986655,130.34419   L 97.420371,129.36739   L 96.912668,128.35152   L 96.44402,127.33565   L 96.033952,126.2807   L 95.662938,125.18669   L 95.350506,124.09267   L 95.096654,122.95958   L 94.881857,121.8265   L 94.745168,120.65434   L 94.647532,119.48218   L 94.628005,118.27094   L 94.647532,117.07925   L 94.745168,115.90709   L 94.881857,114.73493   L 95.096654,113.60184   L 95.350506,112.46875   L 95.662938,111.37474   L 96.033952,110.28072   L 96.44402,109.22578   L 96.912668,108.2099   L 97.420371,107.19403   L 97.986655,106.21723   L 98.591993,105.2795   L 99.236385,104.38085   L 99.919832,103.50173   L 100.66186,102.64214   L 101.42341,101.84117   L 102.22402,101.07926   L 103.08321,100.3369   L 103.96193,99.653136   L 104.86017,99.008448   L 105.79747,98.402832   L 106.77382,97.836288   L 107.78923,97.328352   L 108.80463,96.859488   L 109.85909,96.449232   L 110.95261,96.078048   L 112.04612,95.765472   L 113.17869,95.511504   L 114.31126,95.296608   L 115.48288,95.159856   L 116.6545,95.062176   L 117.86518,95.023104   L 119.05632,95.062176   L 120.22795,95.159856   L 121.39957,95.296608   L 122.53214,95.511504   L 123.6647,95.765472   L 124.75822,96.078048   L 125.85173,96.449232   L 126.90619,96.859488   L 127.9216,97.328352   L 128.937,97.836288   L 129.91336,98.402832   L 130.85065,99.008448   L 131.7489,99.653136   L 132.62761,100.3369   L 133.4868,101.07926   L 134.28741,101.84117   L 135.04897,102.64214   L 135.79099,103.50173   L 136.47444,104.38085   L 137.11883,105.2795   L 137.72417,106.21723   L 138.29045,107.19403   L 138.79816,108.2099   L 139.2668,109.22578   L 139.67687,110.28072   L 140.04789,111.37474   L 140.36032,112.46875   L 140.61417,113.60184   L 140.82897,114.73493   L 140.96566,115.90709   L 141.06329,117.07925   L 141.10235,118.27094  z   " id="path73"/>
			<path style="fill:#f6f8fc;fill-rule:evenodd;fill-opacity:1;stroke:none;" d="  M 145.74978,118.27094   L 145.71073,116.84482   L 145.59356,115.43822   L 145.41782,114.03163   L 145.1835,112.66411   L 144.87106,111.31613   L 144.48052,109.98768   L 144.05093,108.6983   L 143.54322,107.42846   L 142.99647,106.17816   L 142.3716,104.98646   L 141.70768,103.8143   L 140.98518,102.68122   L 140.2041,101.5872   L 139.36444,100.53226   L 138.50525,99.516384   L 137.56795,98.55912   L 136.61113,97.621392   L 135.59572,96.761808   L 134.54126,95.92176   L 133.44775,95.14032   L 132.31518,94.417488   L 131.14356,93.753264   L 129.95241,93.128112   L 128.70268,92.581104   L 127.43342,92.073168   L 126.14464,91.643376   L 124.8168,91.252656   L 123.46943,90.959616   L 122.10254,90.705648   L 120.71612,90.529824   L 119.29065,90.412608   L 117.86518,90.373536   L 116.42017,90.412608   L 115.01423,90.529824   L 113.60828,90.705648   L 112.24139,90.959616   L 110.89402,91.252656   L 109.56619,91.643376   L 108.2774,92.073168   L 107.00814,92.581104   L 105.75841,93.128112   L 104.56727,93.753264   L 103.39564,94.417488   L 102.26308,95.14032   L 101.16956,95.92176   L 100.1151,96.761808   L 99.099696,97.621392   L 98.142871,98.55912   L 97.205574,99.516384   L 96.346384,100.53226   L 95.506722,101.5872   L 94.725641,102.68122   L 94.00314,103.8143   L 93.339221,104.98646   L 92.714356,106.17816   L 92.167599,107.42846   L 91.659896,108.6983   L 91.230302,109.98768   L 90.839761,111.31613   L 90.546855,112.66411   L 90.293004,114.03163   L 90.117261,115.43822   L 90.000098,116.84482   L 89.980571,118.27094   L 90.000098,119.71661   L 90.117261,121.1232   L 90.293004,122.52979   L 90.546855,123.89731   L 90.839761,125.2453   L 91.230302,126.57374   L 91.659896,127.88266   L 92.167599,129.13296   L 92.714356,130.38326   L 93.339221,131.57496   L 94.00314,132.74712   L 94.725641,133.88021   L 95.506722,134.97422   L 96.346384,136.02917   L 97.205574,137.04504   L 98.142871,138.0023   L 99.099696,138.94003   L 100.1151,139.79962   L 101.16956,140.63966   L 102.26308,141.4211   L 103.39564,142.14394   L 104.56727,142.80816   L 105.75841,143.43331   L 107.00814,143.98032   L 108.2774,144.48826   L 109.56619,144.91805   L 110.89402,145.30877   L 112.24139,145.60181   L 113.60828,145.85578   L 115.01423,146.0316   L 116.42017,146.14882   L 117.86518,146.16835   L 119.29065,146.14882   L 120.71612,146.0316   L 122.10254,145.85578   L 123.46943,145.60181   L 124.8168,145.30877   L 126.14464,144.91805   L 127.43342,144.48826   L 128.70268,143.98032   L 129.95241,143.43331   L 131.14356,142.80816   L 132.31518,142.14394   L 133.44775,141.4211   L 134.54126,140.63966   L 135.59572,139.79962   L 136.61113,138.94003   L 137.56795,138.0023   L 138.50525,137.04504   L 139.36444,136.02917   L 140.2041,134.97422   L 140.98518,133.88021   L 141.70768,132.74712   L 142.3716,131.57496   L 142.99647,130.38326   L 143.54322,129.13296   L 144.05093,127.88266   L 144.48052,126.57374   L 144.87106,125.2453   L 145.1835,123.89731   L 145.41782,122.52979   L 145.59356,121.1232   L 145.71073,119.71661   L 145.74978,118.27094  z    M 136.45491,118.27094   L 136.41586,119.22821   L 136.35728,120.18547   L 136.24011,121.10366   L 136.06437,122.02186   L 135.84957,122.92051   L 135.61525,123.81917   L 135.32234,124.67875   L 134.99038,125.5188   L 134.61937,126.33931   L 134.2093,127.14029   L 133.76018,127.92173   L 133.27201,128.68363   L 132.74478,129.40646   L 132.19802,130.10976   L 131.61221,130.79352   L 131.00687,131.43821   L 130.36248,132.04382   L 129.67903,132.6299   L 128.97606,133.17691   L 128.25356,133.70438   L 127.492,134.19278   L 126.71092,134.64211   L 125.91031,135.05237   L 125.09018,135.42355   L 124.25052,135.75566   L 123.39133,136.0487   L 122.49308,136.30267   L 121.59484,136.49803   L 120.67707,136.67386   L 119.7593,136.79107   L 118.80247,136.84968   L 117.86518,136.86922   L 116.90835,136.84968   L 115.95153,136.79107   L 115.03376,136.67386   L 114.11599,136.49803   L 113.21774,136.30267   L 112.3195,136.0487   L 111.46031,135.75566   L 110.62065,135.42355   L 109.80051,135.05237   L 108.9999,134.64211   L 108.21882,134.19278   L 107.45727,133.70438   L 106.73477,133.17691   L 106.03179,132.6299   L 105.34835,132.04382   L 104.70395,131.43821   L 104.09862,130.79352   L 103.51281,130.10976   L 102.96605,129.40646   L 102.43882,128.68363   L 101.95064,127.92173   L 101.50152,127.14029   L 101.09145,126.33931   L 100.72044,125.5188   L 100.38848,124.67875   L 100.09557,123.81917   L 99.841723,122.92051   L 99.646453,122.02186   L 99.47071,121.10366   L 99.353548,120.18547   L 99.294966,119.22821   L 99.275439,118.27094   L 99.294966,117.33322   L 99.353548,116.37595   L 99.47071,115.45776   L 99.646453,114.53957   L 99.841723,113.64091   L 100.09557,112.74226   L 100.38848,111.88267   L 100.72044,111.04262   L 101.09145,110.22211   L 101.50152,109.42114   L 101.95064,108.6397   L 102.43882,107.87779   L 102.96605,107.15496   L 103.51281,106.45166   L 104.09862,105.7679   L 104.70395,105.12322   L 105.34835,104.5176   L 106.03179,103.93152   L 106.73477,103.38451   L 107.45727,102.85704   L 108.21882,102.36864   L 108.9999,101.91931   L 109.80051,101.50906   L 110.62065,101.13787   L 111.46031,100.80576   L 112.3195,100.51272   L 113.21774,100.27829   L 114.11599,100.06339   L 115.03376,99.887568   L 115.95153,99.770352   L 116.90835,99.711744   L 117.86518,99.672672   L 118.80247,99.711744   L 119.7593,99.770352   L 120.67707,99.887568   L 121.59484,100.06339   L 122.49308,100.27829   L 123.39133,100.51272   L 124.25052,100.80576   L 125.09018,101.13787   L 125.91031,101.50906   L 126.71092,101.91931   L 127.492,102.36864   L 128.25356,102.85704   L 128.97606,103.38451   L 129.67903,103.93152   L 130.36248,104.5176   L 131.00687,105.12322   L 131.61221,105.7679   L 132.19802,106.45166   L 132.74478,107.15496   L 133.27201,107.87779   L 133.76018,108.6397   L 134.2093,109.42114   L 134.61937,110.22211   L 134.99038,111.04262   L 135.32234,111.88267   L 135.61525,112.74226   L 135.84957,113.64091   L 136.06437,114.53957   L 136.24011,115.45776   L 136.35728,116.37595   L 136.41586,117.33322   L 136.45491,118.27094  z   " id="path75"/>
			<path style="fill:#f7f9fc;fill-rule:evenodd;fill-opacity:1;stroke:none;" d="  M 141.10235,118.27094   L 141.06329,117.07925   L 140.96566,115.90709   L 140.82897,114.73493   L 140.61417,113.60184   L 140.36032,112.46875   L 140.04789,111.37474   L 139.67687,110.28072   L 139.2668,109.22578   L 138.79816,108.2099   L 138.29045,107.19403   L 137.72417,106.21723   L 137.11883,105.2795   L 136.47444,104.38085   L 135.79099,103.50173   L 135.04897,102.64214   L 134.28741,101.84117   L 133.4868,101.07926   L 132.62761,100.3369   L 131.7489,99.653136   L 130.85065,99.008448   L 129.91336,98.402832   L 128.937,97.836288   L 127.9216,97.328352   L 126.90619,96.859488   L 125.85173,96.449232   L 124.75822,96.078048   L 123.6647,95.765472   L 122.53214,95.511504   L 121.39957,95.296608   L 120.22795,95.159856   L 119.05632,95.062176   L 117.86518,95.023104   L 116.6545,95.062176   L 115.48288,95.159856   L 114.31126,95.296608   L 113.17869,95.511504   L 112.04612,95.765472   L 110.95261,96.078048   L 109.85909,96.449232   L 108.80463,96.859488   L 107.78923,97.328352   L 106.77382,97.836288   L 105.79747,98.402832   L 104.86017,99.008448   L 103.96193,99.653136   L 103.08321,100.3369   L 102.22402,101.07926   L 101.42341,101.84117   L 100.66186,102.64214   L 99.919832,103.50173   L 99.236385,104.38085   L 98.591993,105.2795   L 97.986655,106.21723   L 97.420371,107.19403   L 96.912668,108.2099   L 96.44402,109.22578   L 96.033952,110.28072   L 95.662938,111.37474   L 95.350506,112.46875   L 95.096654,113.60184   L 94.881857,114.73493   L 94.745168,115.90709   L 94.647532,117.07925   L 94.628005,118.27094   L 94.647532,119.48218   L 94.745168,120.65434   L 94.881857,121.8265   L 95.096654,122.95958   L 95.350506,124.09267   L 95.662938,125.18669   L 96.033952,126.2807   L 96.44402,127.33565   L 96.912668,128.35152   L 97.420371,129.36739   L 97.986655,130.34419   L 98.591993,131.28192   L 99.236385,132.18058   L 99.919832,133.0597   L 100.66186,133.91928   L 101.42341,134.72026   L 102.22402,135.48216   L 103.08321,136.22453   L 103.96193,136.90829   L 104.86017,137.55298   L 105.79747,138.15859   L 106.77382,138.72514   L 107.78923,139.23307   L 108.80463,139.70194   L 109.85909,140.11219   L 110.95261,140.48338   L 112.04612,140.79595   L 113.17869,141.04992   L 114.31126,141.26482   L 115.48288,141.40157   L 116.6545,141.49925   L 117.86518,141.51878   L 119.05632,141.49925   L 120.22795,141.40157   L 121.39957,141.26482   L 122.53214,141.04992   L 123.6647,140.79595   L 124.75822,140.48338   L 125.85173,140.11219   L 126.90619,139.70194   L 127.9216,139.23307   L 128.937,138.72514   L 129.91336,138.15859   L 130.85065,137.55298   L 131.7489,136.90829   L 132.62761,136.22453   L 133.4868,135.48216   L 134.28741,134.72026   L 135.04897,133.91928   L 135.79099,133.0597   L 136.47444,132.18058   L 137.11883,131.28192   L 137.72417,130.34419   L 138.29045,129.36739   L 138.79816,128.35152   L 139.2668,127.33565   L 139.67687,126.2807   L 140.04789,125.18669   L 140.36032,124.09267   L 140.61417,122.95958   L 140.82897,121.8265   L 140.96566,120.65434   L 141.06329,119.48218   L 141.10235,118.27094  z    M 131.80748,118.27094   L 131.78795,118.99378   L 131.72937,119.69707   L 131.63173,120.40037   L 131.51457,121.08413   L 131.35836,121.76789   L 131.16309,122.43211   L 130.94829,123.0768   L 130.69444,123.70195   L 130.42106,124.3271   L 130.10863,124.93272   L 129.77667,125.5188   L 129.42518,126.08534   L 129.03464,126.63235   L 128.60504,127.15982   L 128.17545,127.66776   L 127.7068,128.13662   L 127.23815,128.60549   L 126.73045,129.03528   L 126.20322,129.46507   L 125.65646,129.85579   L 125.09018,130.20744   L 124.50437,130.53955   L 123.89903,130.85213   L 123.27416,131.12563   L 122.6493,131.3796   L 122.00491,131.5945   L 121.34099,131.78986   L 120.65754,131.94614   L 119.9741,132.06336   L 119.27112,132.16104   L 118.56815,132.21965   L 117.86518,132.21965   L 117.14268,132.21965   L 116.4397,132.16104   L 115.73673,132.06336   L 115.05328,131.94614   L 114.36984,131.78986   L 113.70592,131.5945   L 113.06153,131.3796   L 112.43666,131.12563   L 111.8118,130.85213   L 111.20646,130.53955   L 110.62065,130.20744   L 110.05436,129.85579   L 109.50761,129.46507   L 108.98038,129.03528   L 108.47267,128.60549   L 108.00402,128.13662   L 107.53537,127.66776   L 107.10578,127.15982   L 106.67619,126.63235   L 106.28564,126.08534   L 105.93416,125.5188   L 105.6022,124.93272   L 105.28977,124.3271   L 105.01639,123.70195   L 104.76254,123.0768   L 104.54774,122.43211   L 104.35247,121.76789   L 104.19625,121.08413   L 104.07909,120.40037   L 103.98145,119.69707   L 103.92287,118.99378   L 103.92287,118.27094   L 103.92287,117.56765   L 103.98145,116.86435   L 104.07909,116.16106   L 104.19625,115.4773   L 104.35247,114.79354   L 104.54774,114.12931   L 104.76254,113.48462   L 105.01639,112.85947   L 105.28977,112.23432   L 105.6022,111.6287   L 105.93416,111.04262   L 106.28564,110.47608   L 106.67619,109.92907   L 107.10578,109.4016   L 107.53537,108.89366   L 108.00402,108.4248   L 108.47267,107.95594   L 108.98038,107.52614   L 109.50761,107.09635   L 110.05436,106.70563   L 110.62065,106.35398   L 111.20646,106.02187   L 111.8118,105.7093   L 112.43666,105.43579   L 113.06153,105.18182   L 113.70592,104.96693   L 114.36984,104.77157   L 115.05328,104.61528   L 115.73673,104.49806   L 116.4397,104.40038   L 117.14268,104.34178   L 117.86518,104.32224   L 118.56815,104.34178   L 119.27112,104.40038   L 119.9741,104.49806   L 120.65754,104.61528   L 121.34099,104.77157   L 122.00491,104.96693   L 122.6493,105.18182   L 123.27416,105.43579   L 123.89903,105.7093   L 124.50437,106.02187   L 125.09018,106.35398   L 125.65646,106.70563   L 126.20322,107.09635   L 126.73045,107.52614   L 127.23815,107.95594   L 127.7068,108.4248   L 128.17545,108.89366   L 128.60504,109.4016   L 129.03464,109.92907   L 129.42518,110.47608   L 129.77667,111.04262   L 130.10863,111.6287   L 130.42106,112.23432   L 130.69444,112.85947   L 130.94829,113.48462   L 131.16309,114.12931   L 131.35836,114.79354   L 131.51457,115.4773   L 131.63173,116.16106   L 131.72937,116.86435   L 131.78795,117.56765   L 131.80748,118.27094  z   " id="path77"/>
			<path style="fill:#fafbfd;fill-rule:evenodd;fill-opacity:1;stroke:none;" d="  M 136.45491,118.27094   L 136.41586,117.33322   L 136.35728,116.37595   L 136.24011,115.45776   L 136.06437,114.53957   L 135.8691,113.64091   L 135.61525,112.74226   L 135.32234,111.88267   L 134.99038,111.04262   L 134.61937,110.22211   L 134.2093,109.42114   L 133.76018,108.6397   L 133.27201,107.87779   L 132.74478,107.15496   L 132.19802,106.45166   L 131.61221,105.7679   L 131.00687,105.12322   L 130.36248,104.5176   L 129.67903,103.93152   L 128.97606,103.38451   L 128.25356,102.85704   L 127.492,102.36864   L 126.71092,101.91931   L 125.91031,101.50906   L 125.09018,101.13787   L 124.25052,100.80576   L 123.39133,100.51272   L 122.49308,100.25875   L 121.59484,100.06339   L 120.67707,99.887568   L 119.7593,99.770352   L 118.80247,99.711744   L 117.86518,99.672672   L 116.90835,99.711744   L 115.95153,99.770352   L 115.03376,99.887568   L 114.11599,100.06339   L 113.21774,100.25875   L 112.3195,100.51272   L 111.46031,100.80576   L 110.62065,101.13787   L 109.80051,101.50906   L 108.9999,101.91931   L 108.21882,102.36864   L 107.45727,102.85704   L 106.73477,103.38451   L 106.03179,103.93152   L 105.34835,104.5176   L 104.70395,105.12322   L 104.09862,105.7679   L 103.51281,106.45166   L 102.96605,107.15496   L 102.43882,107.87779   L 101.95064,108.6397   L 101.50152,109.42114   L 101.09145,110.22211   L 100.72044,111.04262   L 100.38848,111.88267   L 100.09557,112.74226   L 99.841723,113.64091   L 99.646453,114.53957   L 99.47071,115.45776   L 99.353548,116.37595   L 99.294966,117.33322   L 99.275439,118.27094   L 99.294966,119.22821   L 99.353548,120.18547   L 99.47071,121.10366   L 99.646453,122.02186   L 99.841723,122.92051   L 100.09557,123.81917   L 100.38848,124.67875   L 100.72044,125.5188   L 101.09145,126.33931   L 101.50152,127.14029   L 101.95064,127.92173   L 102.43882,128.68363   L 102.96605,129.40646   L 103.51281,130.10976   L 104.09862,130.79352   L 104.70395,131.43821   L 105.34835,132.04382   L 106.03179,132.6299   L 106.73477,133.17691   L 107.45727,133.70438   L 108.21882,134.19278   L 108.9999,134.64211   L 109.80051,135.05237   L 110.62065,135.42355   L 111.46031,135.75566   L 112.3195,136.0487   L 113.21774,136.30267   L 114.11599,136.49803   L 115.03376,136.67386   L 115.95153,136.79107   L 116.90835,136.84968   L 117.86518,136.86922   L 118.80247,136.84968   L 119.7593,136.79107   L 120.67707,136.67386   L 121.59484,136.49803   L 122.49308,136.30267   L 123.39133,136.0487   L 124.25052,135.75566   L 125.09018,135.42355   L 125.91031,135.05237   L 126.71092,134.64211   L 127.492,134.19278   L 128.25356,133.70438   L 128.97606,133.17691   L 129.67903,132.6299   L 130.36248,132.04382   L 131.00687,131.43821   L 131.61221,130.79352   L 132.19802,130.10976   L 132.74478,129.40646   L 133.27201,128.68363   L 133.76018,127.92173   L 134.2093,127.14029   L 134.61937,126.33931   L 134.99038,125.5188   L 135.32234,124.67875   L 135.61525,123.81917   L 135.8691,122.92051   L 136.06437,122.02186   L 136.24011,121.10366   L 136.35728,120.18547   L 136.41586,119.22821   L 136.45491,118.27094  z    M 127.16004,118.27094   L 127.14052,118.75934   L 127.10146,119.22821   L 127.04288,119.69707   L 126.96477,120.1464   L 126.84761,120.59573   L 126.73045,121.04506   L 126.59376,121.47485   L 126.41802,121.90464   L 126.24227,122.3149   L 126.02748,122.70562   L 125.81268,123.09634   L 125.55883,123.48706   L 125.30498,123.8387   L 125.0316,124.19035   L 124.73869,124.542   L 124.42626,124.85458   L 124.11383,125.16715   L 123.76234,125.46019   L 123.41085,125.7337   L 123.05937,125.98766   L 122.66883,126.24163   L 122.27829,126.45653   L 121.88774,126.67142   L 121.47768,126.84725   L 121.04808,127.02307   L 120.61849,127.15982   L 120.16937,127.29658   L 119.72024,127.39426   L 119.27112,127.4724   L 118.80247,127.53101   L 118.33382,127.57008   L 117.86518,127.57008   L 117.377,127.57008   L 116.90835,127.53101   L 116.4397,127.4724   L 115.99058,127.39426   L 115.54146,127.29658   L 115.09234,127.15982   L 114.66274,127.02307   L 114.23315,126.84725   L 113.82308,126.67142   L 113.43254,126.45653   L 113.042,126.24163   L 112.65146,125.98766   L 112.29997,125.7337   L 111.94848,125.46019   L 111.597,125.16715   L 111.28457,124.85458   L 110.97213,124.542   L 110.67923,124.19035   L 110.40585,123.8387   L 110.152,123.48706   L 109.89815,123.09634   L 109.68335,122.70562   L 109.46855,122.3149   L 109.29281,121.90464   L 109.11706,121.47485   L 108.98038,121.04506   L 108.84369,120.59573   L 108.74605,120.1464   L 108.66794,119.69707   L 108.60936,119.22821   L 108.57031,118.75934   L 108.57031,118.27094   L 108.57031,117.80208   L 108.60936,117.33322   L 108.66794,116.86435   L 108.74605,116.41502   L 108.84369,115.9657   L 108.98038,115.51637   L 109.11706,115.08658   L 109.29281,114.65678   L 109.46855,114.24653   L 109.68335,113.85581   L 109.89815,113.46509   L 110.152,113.07437   L 110.40585,112.72272   L 110.67923,112.37107   L 110.97213,112.01942   L 111.28457,111.70685   L 111.597,111.39427   L 111.94848,111.10123   L 112.29997,110.82773   L 112.65146,110.57376   L 113.042,110.31979   L 113.43254,110.1049   L 113.82308,109.89   L 114.23315,109.71418   L 114.66274,109.53835   L 115.09234,109.4016   L 115.54146,109.28438   L 115.99058,109.16717   L 116.4397,109.08902   L 116.90835,109.03042   L 117.377,108.99134   L 117.86518,108.97181   L 118.33382,108.99134   L 118.80247,109.03042   L 119.27112,109.08902   L 119.72024,109.16717   L 120.16937,109.28438   L 120.61849,109.4016   L 121.04808,109.53835   L 121.47768,109.71418   L 121.88774,109.89   L 122.27829,110.1049   L 122.66883,110.31979   L 123.05937,110.57376   L 123.41085,110.82773   L 123.76234,111.10123   L 124.11383,111.39427   L 124.42626,111.70685   L 124.73869,112.01942   L 125.0316,112.37107   L 125.30498,112.72272   L 125.55883,113.07437   L 125.81268,113.46509   L 126.02748,113.85581   L 126.24227,114.24653   L 126.41802,114.65678   L 126.59376,115.08658   L 126.73045,115.51637   L 126.84761,115.9657   L 126.96477,116.41502   L 127.04288,116.86435   L 127.10146,117.33322   L 127.14052,117.80208   L 127.16004,118.27094  z   " id="path79"/>
			<path style="fill:#fbfcfd;fill-rule:evenodd;fill-opacity:1;stroke:none;" d="  M 131.80748,118.27094   L 131.78795,117.56765   L 131.72937,116.86435   L 131.63173,116.16106   L 131.51457,115.4773   L 131.35836,114.79354   L 131.16309,114.12931   L 130.94829,113.48462   L 130.69444,112.85947   L 130.42106,112.23432   L 130.10863,111.6287   L 129.77667,111.04262   L 129.42518,110.47608   L 129.03464,109.92907   L 128.60504,109.4016   L 128.17545,108.89366   L 127.7068,108.4248   L 127.23815,107.95594   L 126.73045,107.52614   L 126.20322,107.09635   L 125.65646,106.70563   L 125.09018,106.35398   L 124.50437,106.02187   L 123.89903,105.7093   L 123.27416,105.43579   L 122.6493,105.18182   L 122.00491,104.96693   L 121.34099,104.77157   L 120.65754,104.61528   L 119.9741,104.49806   L 119.27112,104.40038   L 118.56815,104.34178   L 117.86518,104.32224   L 117.14268,104.34178   L 116.4397,104.40038   L 115.73673,104.49806   L 115.05328,104.61528   L 114.36984,104.77157   L 113.70592,104.96693   L 113.06153,105.18182   L 112.43666,105.43579   L 111.8118,105.7093   L 111.20646,106.02187   L 110.62065,106.35398   L 110.05436,106.70563   L 109.50761,107.09635   L 108.98038,107.52614   L 108.47267,107.95594   L 108.00402,108.4248   L 107.53537,108.89366   L 107.10578,109.4016   L 106.67619,109.92907   L 106.28564,110.47608   L 105.93416,111.04262   L 105.6022,111.6287   L 105.28977,112.23432   L 105.01639,112.85947   L 104.76254,113.48462   L 104.54774,114.12931   L 104.35247,114.79354   L 104.19625,115.4773   L 104.07909,116.16106   L 103.98145,116.86435   L 103.92287,117.56765   L 103.92287,118.27094   L 103.92287,118.99378   L 103.98145,119.69707   L 104.07909,120.40037   L 104.19625,121.08413   L 104.35247,121.76789   L 104.54774,122.43211   L 104.76254,123.0768   L 105.01639,123.70195   L 105.28977,124.3271   L 105.6022,124.93272   L 105.93416,125.5188   L 106.28564,126.08534   L 106.67619,126.63235   L 107.10578,127.15982   L 107.53537,127.66776   L 108.00402,128.13662   L 108.47267,128.60549   L 108.98038,129.03528   L 109.50761,129.46507   L 110.05436,129.85579   L 110.62065,130.20744   L 111.20646,130.53955   L 111.8118,130.85213   L 112.43666,131.12563   L 113.06153,131.3796   L 113.70592,131.5945   L 114.36984,131.78986   L 115.05328,131.94614   L 115.73673,132.06336   L 116.4397,132.16104   L 117.14268,132.21965   L 117.86518,132.21965   L 118.56815,132.21965   L 119.27112,132.16104   L 119.9741,132.06336   L 120.65754,131.94614   L 121.34099,131.78986   L 122.00491,131.5945   L 122.6493,131.3796   L 123.27416,131.12563   L 123.89903,130.85213   L 124.50437,130.53955   L 125.09018,130.20744   L 125.65646,129.85579   L 126.20322,129.46507   L 126.73045,129.03528   L 127.23815,128.60549   L 127.7068,128.13662   L 128.17545,127.66776   L 128.60504,127.15982   L 129.03464,126.63235   L 129.42518,126.08534   L 129.77667,125.5188   L 130.10863,124.93272   L 130.42106,124.3271   L 130.69444,123.70195   L 130.94829,123.0768   L 131.16309,122.43211   L 131.35836,121.76789   L 131.51457,121.08413   L 131.63173,120.40037   L 131.72937,119.69707   L 131.78795,118.99378   L 131.80748,118.27094  z " id="path81"/>
			<path style="fill:#fcfdfe;fill-rule:evenodd;fill-opacity:1;stroke:none;" d="  M 127.16004,118.27094   L 127.14052,117.80208   L 127.10146,117.33322   L 127.04288,116.86435   L 126.96477,116.41502   L 126.84761,115.9657   L 126.73045,115.51637   L 126.59376,115.08658   L 126.41802,114.65678   L 126.24227,114.24653   L 126.02748,113.85581   L 125.81268,113.46509   L 125.55883,113.07437   L 125.30498,112.72272   L 125.0316,112.37107   L 124.73869,112.01942   L 124.42626,111.70685   L 124.11383,111.39427   L 123.76234,111.10123   L 123.41085,110.82773   L 123.05937,110.57376   L 122.66883,110.31979   L 122.27829,110.1049   L 121.88774,109.89   L 121.47768,109.71418   L 121.04808,109.53835   L 120.61849,109.4016   L 120.16937,109.28438   L 119.72024,109.16717   L 119.27112,109.08902   L 118.80247,109.03042   L 118.33382,108.99134   L 117.86518,108.97181   L 117.377,108.99134   L 116.90835,109.03042   L 116.4397,109.08902   L 115.99058,109.16717   L 115.54146,109.28438   L 115.09234,109.4016   L 114.66274,109.53835   L 114.23315,109.71418   L 113.82308,109.89   L 113.43254,110.1049   L 113.042,110.31979   L 112.65146,110.57376   L 112.29997,110.82773   L 111.94848,111.10123   L 111.597,111.39427   L 111.28457,111.70685   L 110.97213,112.01942   L 110.67923,112.37107   L 110.40585,112.72272   L 110.152,113.07437   L 109.89815,113.46509   L 109.68335,113.85581   L 109.46855,114.24653   L 109.29281,114.65678   L 109.11706,115.08658   L 108.98038,115.51637   L 108.84369,115.9657   L 108.74605,116.41502   L 108.66794,116.86435   L 108.60936,117.33322   L 108.57031,117.80208   L 108.57031,118.27094   L 108.57031,118.75934   L 108.60936,119.22821   L 108.66794,119.69707   L 108.74605,120.1464   L 108.84369,120.59573   L 108.98038,121.04506   L 109.11706,121.47485   L 109.29281,121.90464   L 109.46855,122.3149   L 109.68335,122.70562   L 109.89815,123.09634   L 110.152,123.48706   L 110.40585,123.8387   L 110.67923,124.19035   L 110.97213,124.542   L 111.28457,124.85458   L 111.597,125.16715   L 111.94848,125.46019   L 112.29997,125.7337   L 112.65146,125.98766   L 113.042,126.24163   L 113.43254,126.45653   L 113.82308,126.67142   L 114.23315,126.84725   L 114.66274,127.02307   L 115.09234,127.15982   L 115.54146,127.29658   L 115.99058,127.39426   L 116.4397,127.4724   L 116.90835,127.53101   L 117.377,127.57008   L 117.86518,127.57008   L 118.33382,127.57008   L 118.80247,127.53101   L 119.27112,127.4724   L 119.72024,127.39426   L 120.16937,127.29658   L 120.61849,127.15982   L 121.04808,127.02307   L 121.47768,126.84725   L 121.88774,126.67142   L 122.27829,126.45653   L 122.66883,126.24163   L 123.05937,125.98766   L 123.41085,125.7337   L 123.76234,125.46019   L 124.11383,125.16715   L 124.42626,124.85458   L 124.73869,124.542   L 125.0316,124.19035   L 125.30498,123.8387   L 125.55883,123.48706   L 125.81268,123.09634   L 126.02748,122.70562   L 126.24227,122.3149   L 126.41802,121.90464   L 126.59376,121.47485   L 126.73045,121.04506   L 126.84761,120.59573   L 126.96477,120.1464   L 127.04288,119.69707   L 127.10146,119.22821   L 127.14052,118.75934   L 127.16004,118.27094  z " id="path83"/>
			<path style="fill:#ffffff;fill-rule:evenodd;fill-opacity:1;stroke:none;" d="  M 122.51261,118.27094   L 122.49308,118.03651   L 122.47356,117.80208   L 122.45403,117.56765   L 122.41497,117.35275   L 122.35639,117.11832   L 122.29781,116.90342   L 122.2197,116.68853   L 122.1416,116.47363   L 122.04396,116.25874   L 121.94633,116.06338   L 121.82916,115.86802   L 121.712,115.67266   L 121.57531,115.49683   L 121.43862,115.32101   L 121.30193,115.14518   L 121.14572,114.9889   L 120.9895,114.83261   L 120.81376,114.69586   L 120.63801,114.5591   L 120.46227,114.42235   L 120.267,114.30514   L 120.07173,114.18792   L 119.87646,114.09024   L 119.66166,113.99256   L 119.44687,113.91442   L 119.23207,113.83627   L 119.01727,113.77766   L 118.78295,113.71906   L 118.56815,113.67998   L 118.33382,113.66045   L 118.0995,113.64091   L 117.86518,113.62138   L 117.61132,113.64091   L 117.377,113.66045   L 117.14268,113.67998   L 116.92788,113.71906   L 116.69355,113.77766   L 116.47876,113.83627   L 116.26396,113.91442   L 116.04916,113.99256   L 115.83436,114.09024   L 115.63909,114.18792   L 115.44382,114.30514   L 115.24855,114.42235   L 115.07281,114.5591   L 114.89707,114.69586   L 114.74085,114.83261   L 114.56511,114.9889   L 114.40889,115.14518   L 114.2722,115.32101   L 114.13551,115.49683   L 113.99882,115.67266   L 113.88166,115.86802   L 113.7645,116.06338   L 113.66686,116.25874   L 113.56923,116.47363   L 113.49112,116.68853   L 113.41301,116.90342   L 113.35443,117.11832   L 113.29585,117.35275   L 113.2568,117.56765   L 113.23727,117.80208   L 113.21774,118.03651   L 113.21774,118.27094   L 113.21774,118.52491   L 113.23727,118.75934   L 113.2568,118.99378   L 113.29585,119.20867   L 113.35443,119.4431   L 113.41301,119.658   L 113.49112,119.8729   L 113.56923,120.08779   L 113.66686,120.30269   L 113.7645,120.49805   L 113.88166,120.69341   L 113.99882,120.88877   L 114.13551,121.06459   L 114.2722,121.24042   L 114.40889,121.41624   L 114.56511,121.57253   L 114.74085,121.72882   L 114.89707,121.86557   L 115.07281,122.00232   L 115.24855,122.13907   L 115.44382,122.25629   L 115.63909,122.3735   L 115.83436,122.47118   L 116.04916,122.56886   L 116.26396,122.64701   L 116.47876,122.72515   L 116.69355,122.78376   L 116.92788,122.84237   L 117.14268,122.88144   L 117.377,122.90098   L 117.61132,122.92051   L 117.86518,122.92051   L 118.0995,122.92051   L 118.33382,122.90098   L 118.56815,122.88144   L 118.78295,122.84237   L 119.01727,122.78376   L 119.23207,122.72515   L 119.44687,122.64701   L 119.66166,122.56886   L 119.87646,122.47118   L 120.07173,122.3735   L 120.267,122.25629   L 120.46227,122.13907   L 120.63801,122.00232   L 120.81376,121.86557   L 120.9895,121.72882   L 121.14572,121.57253   L 121.30193,121.41624   L 121.43862,121.24042   L 121.57531,121.06459   L 121.712,120.88877   L 121.82916,120.69341   L 121.94633,120.49805   L 122.04396,120.30269   L 122.1416,120.08779   L 122.2197,119.8729   L 122.29781,119.658   L 122.35639,119.4431   L 122.41497,119.20867   L 122.45403,118.99378   L 122.47356,118.75934   L 122.49308,118.52491   L 122.51261,118.27094  z " id="path85"/>
			<path style="fill:#004086;fill-rule:nonzero;fill-opacity:1;stroke:none;" d="  M 215.46129,271.7653   L 214.15298,272.82024   L 212.82514,273.81658   L 211.43872,274.79338   L 210.01325,275.7311   L 208.56825,276.6493   L 207.06467,277.50888   L 205.54156,278.34893   L 203.95987,279.1499   L 202.35865,279.91181   L 200.71838,280.65418   L 199.05858,281.33794   L 197.3402,282.00216   L 195.6023,282.62731   L 193.84486,283.21339   L 192.02885,283.77994   L 190.21284,284.28787   L 188.33824,284.77627   L 186.44412,285.2256   L 184.53047,285.63586   L 182.59729,286.00704   L 180.60553,286.35869   L 178.61378,286.65173   L 176.58297,286.92523   L 174.55215,287.15966   L 172.46276,287.35502   L 170.37337,287.53085   L 168.26445,287.64806   L 166.11648,287.74574   L 163.94898,287.78482   L 161.78147,287.80435   L 159.57492,287.78482   L 157.34884,287.72621   L 157.44647,285.34282   L 159.61397,285.38189   L 161.74242,285.40142   L 163.87087,285.38189   L 165.97979,285.34282   L 168.06918,285.24514   L 170.13904,285.12792   L 172.16986,284.97163   L 174.20067,284.77627   L 176.19243,284.56138   L 178.16466,284.30741   L 180.11736,284.01437   L 182.03101,283.68226   L 183.92513,283.31107   L 185.7802,282.92035   L 187.63527,282.49056   L 189.43175,282.0217   L 191.20871,281.51376   L 192.96615,280.98629   L 194.68453,280.40021   L 196.38338,279.81413   L 198.02365,279.16944   L 199.66392,278.50522   L 201.24561,277.78238   L 202.80777,277.05955   L 204.33088,276.27811   L 205.81494,275.47714   L 207.25994,274.63709   L 208.66588,273.75797   L 210.0523,272.83978   L 211.38014,271.90205   L 212.66892,270.92525   L 213.93818,269.92891   L 215.46129,271.7653  z    M 157.34884,287.72621   L 155.18134,287.64806   L 152.99431,287.53085   L 150.78775,287.37456   L 148.56167,287.1792   L 146.31606,286.94477   L 144.07045,286.6908   L 141.80532,286.39776   L 139.54018,286.06565   L 137.23599,285.69446   L 134.95133,285.30374   L 132.62761,284.87395   L 130.3039,284.40509   L 127.98018,283.89715   L 125.63693,283.35014   L 123.29369,282.7836   L 120.93092,282.17798   L 118.56815,281.5333   L 116.20538,280.84954   L 113.82308,280.1267   L 111.46031,279.38434   L 109.05848,278.6029   L 106.67619,277.78238   L 104.29389,276.9228   L 101.89206,276.02414   L 99.509764,275.10595   L 97.107939,274.12915   L 94.725641,273.13282   L 92.323815,272.09741   L 89.92199,271.02293   L 87.539692,269.92891   L 85.157394,268.77629   L 82.775096,267.60413   L 83.849083,265.4747   L 86.192327,266.62733   L 88.555098,267.76042   L 90.917869,268.85443   L 93.28064,269.90938   L 95.643411,270.92525   L 98.006182,271.92158   L 100.36895,272.85931   L 102.73172,273.7775   L 105.0945,274.65662   L 107.43774,275.49667   L 109.80051,276.31718   L 112.14375,277.09862   L 114.50653,277.82146   L 116.84977,278.54429   L 119.17349,279.20851   L 121.51673,279.83366   L 123.84045,280.43928   L 126.14464,281.00582   L 128.46835,281.5333   L 130.75302,282.04123   L 133.05721,282.5101   L 135.32234,282.93989   L 137.60701,283.33061   L 139.85262,283.68226   L 142.09822,284.01437   L 144.34383,284.30741   L 146.55039,284.56138   L 148.75694,284.77627   L 150.9635,284.97163   L 153.131,285.12792   L 155.2985,285.24514   L 157.44647,285.34282   L 157.34884,287.72621  z    M 82.775096,267.60413   L 80.373271,266.37336   L 78.030027,265.12306   L 75.686783,263.83368   L 73.40212,262.5443   L 71.117457,261.21586   L 68.871848,259.86787   L 66.665293,258.50035   L 64.478265,257.1133   L 62.310765,255.68717   L 60.182318,254.26104   L 58.092925,252.81538   L 56.02306,251.35018   L 53.972721,249.86544   L 51.980964,248.36117   L 50.008733,246.83736   L 48.05603,245.29402   L 46.142381,243.73114   L 44.267785,242.16826   L 42.432244,240.58584   L 40.61623,238.98389   L 38.83927,237.38194   L 37.101364,235.76045   L 35.402512,234.11942   L 33.723187,232.4784   L 32.102443,230.81784   L 30.501227,229.13774   L 28.939064,227.45765   L 27.415955,225.77755   L 25.912374,224.07792   L 24.467373,222.37829   L 23.061427,220.65912   L 21.675007,218.93995   L 23.56913,217.47475   L 24.936022,219.17438   L 26.322441,220.85448   L 27.747915,222.53458   L 29.212442,224.21467   L 30.735551,225.87523   L 32.25866,227.53579   L 33.840349,229.17682   L 35.461093,230.7983   L 37.101364,232.43933   L 38.780689,234.04128   L 40.499068,235.64323   L 42.256501,237.22565   L 44.033461,238.80806   L 45.849475,240.37094   L 47.704543,241.91429   L 49.598666,243.45763   L 51.512315,244.9619   L 53.445491,246.46618   L 55.437249,247.95091   L 57.448533,249.41611   L 59.479345,250.86178   L 61.54921,252.30744   L 63.65813,253.71403   L 65.786577,255.10109   L 67.93455,256.46861   L 70.141105,257.83613   L 72.34766,259.16458   L 74.593269,260.47349   L 76.858405,261.74333   L 79.162595,263.01317   L 81.486312,264.24394   L 83.849083,265.4747   L 82.775096,267.60413  z    M 21.675007,218.93995   L 20.308115,217.16218   L 18.980277,215.3844   L 17.691493,213.60662   L 16.441762,211.82885   L 15.231086,210.03154   L 14.078991,208.23422   L 12.946423,206.43691   L 11.872436,204.6396   L 10.837504,202.82275   L 9.861152,201.02544   L 8.9043274,199.20859   L 8.0060838,197.41128   L 7.1468943,195.61397   L 6.346286,193.79712   L 5.5847316,191.99981   L 4.8817584,190.2025   L 4.1983122,188.40518   L 3.5929742,186.62741   L 3.0071632,184.8301   L 2.4799333,183.05232   L 2.0112845,181.27454   L 1.5816897,179.5163   L 1.2106761,177.75806   L 0.87871652,175.99982   L 0.60533805,174.24158   L 0.39054067,172.52242   L 0.21479737,170.78371   L 0.078108135,169.06454   L 0.019527034,167.36491   L 0,165.66528   L 0.039054067,163.98518   L 0.1171622,162.32462   L 2.5189873,162.48091   L 2.4408792,164.1024   L 2.4018251,165.72389   L 2.4213522,167.36491   L 2.4994603,169.00594   L 2.6166225,170.6665   L 2.7923658,172.34659   L 3.0071632,174.02669   L 3.2805417,175.70678   L 3.5929742,177.40642   L 3.9639878,179.12558   L 4.3740556,180.82522   L 4.8427044,182.56392   L 5.3504072,184.28309   L 5.9166912,186.02179   L 6.5220293,187.7605   L 7.1664214,189.4992   L 7.8693946,191.2379   L 8.6114219,192.99614   L 9.3925032,194.75438   L 10.232166,196.49309   L 11.110882,198.25133   L 12.028653,200.00957   L 13.005004,201.76781   L 14.000883,203.52605   L 15.055343,205.28429   L 16.148857,207.02299   L 17.281425,208.78123   L 18.453047,210.51994   L 19.68325,212.27818   L 20.93298,214.01688   L 22.241291,215.73605   L 23.56913,217.47475   L 21.675007,218.93995  z    M 260.33441,196.45402   L 260.19772,197.17685   L 260.04151,197.88014   L 259.86576,198.60298   L 259.67049,199.30627   L 259.4557,200.00957   L 259.22137,200.7324   L 258.98705,201.4357   L 258.7332,202.13899   L 256.48759,201.29894   L 256.72191,200.65426   L 256.93671,199.99003   L 257.15151,199.34534   L 257.34678,198.68112   L 257.52252,198.0169   L 257.67874,197.37221   L 257.83495,196.70798   L 257.95212,196.04376   L 260.33441,196.45402  z    M 258.7332,202.13899   L 258.45982,202.82275   L 258.18644,203.50651   L 257.91306,204.19027   L 257.60063,204.87403   L 257.30772,205.55779   L 256.97576,206.22202   L 256.66333,206.90578   L 256.33137,207.57   L 254.1834,206.49552   L 254.49583,205.87037   L 254.80826,205.22568   L 255.10117,204.58099   L 255.39407,203.9363   L 255.68698,203.27208   L 255.96036,202.62739   L 256.23374,201.96317   L 256.48759,201.29894   L 258.7332,202.13899  z    M 256.33137,207.57   L 255.4136,209.32824   L 254.41772,211.02787   L 253.36326,212.68843   L 252.23069,214.30992   L 251.03955,215.8728   L 249.77029,217.37707   L 248.46198,218.84227   L 247.07556,220.2684   L 245.63056,221.63592   L 244.10745,222.94483   L 242.54529,224.21467   L 240.92454,225.4259   L 239.24522,226.59806   L 237.50731,227.71162   L 235.73035,228.7861   L 233.87528,229.80197   L 231.98116,230.75923   L 230.04798,231.67742   L 228.05623,232.55654   L 226.00589,233.35752   L 223.93602,234.13896   L 221.78805,234.84226   L 219.62055,235.50648   L 217.39447,236.13163   L 215.12933,236.69818   L 212.82514,237.20611   L 210.4819,237.65544   L 208.0996,238.08523   L 205.67825,238.43688   L 203.23737,238.74946   L 200.73791,239.00342   L 198.21892,239.21832   L 198.04318,236.81539   L 200.50358,236.62003   L 202.90541,236.36606   L 205.28771,236.07302   L 207.63095,235.72138   L 209.93514,235.33066   L 212.20028,234.88133   L 214.42636,234.39293   L 216.61338,233.84592   L 218.76136,233.25984   L 220.87028,232.61515   L 222.94014,231.93139   L 224.95143,231.18902   L 226.92366,230.40758   L 228.85684,229.58707   L 230.73143,228.70795   L 232.56697,227.77022   L 234.34393,226.79342   L 236.06231,225.77755   L 237.74164,224.70307   L 239.36238,223.58952   L 240.92454,222.4369   L 242.42812,221.22566   L 243.89265,219.95582   L 245.27907,218.64691   L 246.60691,217.29893   L 247.89569,215.89234   L 249.10637,214.44667   L 250.23894,212.9424   L 251.33245,211.39906   L 252.34786,209.81664   L 253.30468,208.17562   L 254.1834,206.49552   L 256.33137,207.57  z    M 198.21892,239.21832   L 195.6804,239.37461   L 193.10284,239.47229   L 190.50574,239.5309   L 187.86959,239.5309   L 185.21391,239.49182   L 182.51918,239.39414   L 179.80493,239.23786   L 177.07114,239.0425   L 174.31783,238.78853   L 171.54499,238.47595   L 168.7331,238.1243   L 165.92121,237.71405   L 163.07026,237.26472   L 160.21931,236.75678   L 157.34884,236.19024   L 154.47836,235.56509   L 151.56884,234.90086   L 148.65931,234.19757   L 145.74978,233.41613   L 142.82072,232.59562   L 139.87214,231.73603   L 136.94309,230.7983   L 133.97498,229.8215   L 131.0264,228.7861   L 128.07781,227.71162   L 125.1097,226.57853   L 122.1416,225.38683   L 119.19301,224.15606   L 116.2249,222.86669   L 113.2568,221.5187   L 110.30821,220.11211   L 107.35963,218.66645   L 108.43362,216.51749   L 111.34315,217.96315   L 114.2722,219.33067   L 117.18173,220.65912   L 120.11078,221.9485   L 123.03984,223.15973   L 125.94937,224.33189   L 128.87842,225.46498   L 131.78795,226.51992   L 134.71701,227.53579   L 137.62653,228.51259   L 140.53606,229.41125   L 143.42606,230.29037   L 146.31606,231.09134   L 149.18654,231.85325   L 152.05701,232.55654   L 154.92749,233.22077   L 157.75891,233.82638   L 160.59033,234.37339   L 163.40222,234.88133   L 166.21411,235.33066   L 168.98695,235.74091   L 171.74026,236.09256   L 174.49357,236.3856   L 177.20783,236.63957   L 179.90256,236.83493   L 182.57777,236.97168   L 185.23344,237.06936   L 187.85006,237.12797   L 190.44716,237.12797   L 193.0052,237.06936   L 195.54372,236.97168   L 198.04318,236.81539   L 198.21892,239.21832  z    M 107.35963,218.66645   L 106.81287,218.39294   L 107.35963,218.66645   L 107.90639,217.59197   L 107.35963,218.66645  z    M 107.35963,218.66645   L 104.43058,217.14264   L 101.5601,215.5993   L 98.728682,214.01688   L 95.91679,212.39539   L 93.163478,210.75437   L 90.44922,209.07427   L 87.793544,207.3551   L 85.157394,205.6164   L 82.579826,203.85816   L 80.041311,202.06085   L 77.541851,200.244   L 75.100972,198.38808   L 72.699147,196.53216   L 70.355902,194.63717   L 68.051712,192.72264   L 65.786577,190.78858   L 63.580022,188.83498   L 61.432048,186.86184   L 59.323128,184.86917   L 57.27279,182.85696   L 55.261505,180.84475   L 53.308802,178.81301   L 51.41468,176.74219   L 49.579139,174.69091   L 47.782651,172.60056   L 46.064273,170.51021   L 44.384948,168.41986   L 42.764204,166.30997   L 41.182514,164.20008   L 39.678933,162.07066   L 38.233932,159.94123   L 36.847513,157.81181   L 38.878324,156.5029   L 40.245216,158.61278   L 41.690217,160.72267   L 43.174272,162.81302   L 44.716907,164.88384   L 46.298597,166.97419   L 47.958395,169.04501   L 49.676774,171.09629   L 51.434207,173.14757   L 53.250221,175.17931   L 55.124816,177.21106   L 57.038465,179.22326   L 59.010696,181.21594   L 61.041507,183.18907   L 63.1309,185.16221   L 65.259347,187.09627   L 67.426847,189.03034   L 69.652929,190.92533   L 71.918065,192.82032   L 74.241782,194.67624   L 76.62408,196.53216   L 79.025905,198.34901   L 81.486312,200.14632   L 83.985772,201.90456   L 86.543813,203.64326   L 89.140909,205.36243   L 91.777058,207.06206   L 94.452262,208.70309   L 97.16652,210.34411   L 99.919832,211.92653   L 102.73172,213.48941   L 105.56314,215.03275   L 108.45315,216.51749   L 107.35963,218.66645  z    M 36.847513,157.81181   L 35.519674,155.66285   L 34.23089,153.51389   L 33.020214,151.34539   L 31.868119,149.19643   L 30.794132,147.04747   L 29.759199,144.87898   L 28.802375,142.73002   L 27.904131,140.58106   L 27.064469,138.4321   L 26.302914,136.28314   L 25.599941,134.15371   L 24.975076,132.00475   L 24.408792,129.89486   L 23.920616,127.76544   L 23.491022,125.65555   L 23.120008,123.5652   L 22.846629,121.47485   L 22.631832,119.40403   L 22.475616,117.35275   L 22.417035,115.30147   L 22.417035,113.26973   L 22.495143,111.25752   L 22.631832,109.26485   L 22.866156,107.27218   L 23.159062,105.31858   L 23.530076,103.38451   L 23.998724,101.46998   L 24.525954,99.574992   L 25.131292,97.699536   L 25.814739,95.843616   L 26.576293,94.026768   L 27.435482,92.229456   L 29.583456,93.303936   L 28.763321,95.023104   L 28.04082,96.761808   L 27.376901,98.539584   L 26.79109,100.3369   L 26.302914,102.15374   L 25.87332,103.99013   L 25.502306,105.84605   L 25.228928,107.74104   L 25.01413,109.63603   L 24.877441,111.55056   L 24.81886,113.48462   L 24.81886,115.43822   L 24.896968,117.41136   L 25.033657,119.40403   L 25.248455,121.3967   L 25.54136,123.40891   L 25.892847,125.42112   L 26.302914,127.4724   L 26.79109,129.50414   L 27.357374,131.55542   L 27.962712,133.6067   L 28.646158,135.67752   L 29.388186,137.74834   L 30.208321,139.83869   L 31.067511,141.9095   L 32.004808,143.99986   L 33.000687,146.09021   L 34.055147,148.16102   L 35.168188,150.25138   L 36.359337,152.34173   L 37.58954,154.43208   L 38.878324,156.5029   L 36.847513,157.81181  z    M 27.435482,92.229456   L 27.747915,91.604304   L 28.099402,90.979152   L 28.470415,90.334464   L 28.860956,89.689776   L 29.290551,89.025552   L 29.720145,88.361328   L 30.169267,87.697104   L 30.637916,87.03288   L 32.610146,88.4004   L 32.161025,89.045088   L 31.73143,89.689776   L 31.321362,90.314928   L 30.911294,90.94008   L 30.540281,91.545696   L 30.188794,92.151312   L 29.876362,92.737392   L 29.583456,93.303936   L 27.435482,92.229456  z    M 30.637916,87.03288   L 31.223727,86.212368   L 31.829065,85.411392   L 32.434403,84.610416   L 33.039741,83.828976   L 33.625552,83.067072   L 34.23089,82.34424   L 34.797174,81.640944   L 35.363458,80.97672   L 37.179472,82.5396   L 36.652242,83.184288   L 36.085958,83.848512   L 35.519674,84.551808   L 34.933863,85.294176   L 34.348052,86.05608   L 33.762241,86.817984   L 33.17643,87.599424   L 32.610146,88.4004   L 30.637916,87.03288  z    M 254.4763,125.0304   L 254.73015,126.04627   L 254.94495,127.06214   L 255.14022,128.07802   L 255.33549,129.09389   L 255.49171,130.09022   L 255.6284,131.08656   L 255.74556,132.0829   L 255.86272,133.0597   L 255.94083,134.0365   L 255.99941,135.0133   L 256.03847,135.9901   L 256.03847,136.94736   L 256.03847,137.90462   L 256.01894,138.86189   L 255.97988,139.79962   L 255.90178,140.73734   L 253.49995,140.54198   L 253.57806,139.66286   L 253.61711,138.76421   L 253.63664,137.84602   L 253.63664,136.94736   L 253.61711,136.02917   L 253.57806,135.11098   L 253.51948,134.17325   L 253.4609,133.25506   L 253.36326,132.31733   L 253.2461,131.3796   L 253.10941,130.42234   L 252.95319,129.46507   L 252.77745,128.50781   L 252.58218,127.55054   L 252.38691,126.57374   L 252.15259,125.59694   L 254.4763,125.0304  z    M 255.90178,140.73734   L 255.82367,141.65554   L 255.70651,142.57373   L 255.58934,143.47238   L 255.43313,144.37104   L 255.27691,145.2697   L 255.08164,146.16835   L 254.86684,147.04747   L 254.63252,147.92659   L 254.37867,148.80571   L 254.10529,149.6653   L 253.81238,150.52488   L 253.49995,151.38446   L 253.16799,152.22451   L 252.79698,153.0841   L 252.42596,153.90461   L 252.0159,154.74466   L 249.86792,153.67018   L 250.23894,152.88874   L 250.60995,152.1073   L 250.94191,151.32586   L 251.25434,150.52488   L 251.54725,149.74344   L 251.82063,148.92293   L 252.07448,148.12195   L 252.32833,147.30144   L 252.54313,146.48093   L 252.7384,145.64088   L 252.91414,144.80083   L 253.07036,143.96078   L 253.20705,143.12074   L 253.32421,142.26115   L 253.42184,141.4211   L 253.49995,140.54198   L 255.90178,140.73734  z    M 252.0159,154.74466   L 251.2934,156.13171   L 250.49279,157.4797   L 249.65313,158.76907   L 248.75488,160.03891   L 247.81758,161.26968   L 246.82171,162.46138   L 245.76725,163.614   L 244.67373,164.72755   L 243.52164,165.80203   L 242.35002,166.8179   L 241.10029,167.81424   L 239.83103,168.7715   L 238.50319,169.6897   L 237.1363,170.56882   L 235.73035,171.38933   L 234.28535,172.1903   L 232.78177,172.95221   L 231.25866,173.67504   L 229.67697,174.33926   L 228.07575,174.98395   L 226.43548,175.57003   L 224.75616,176.13658   L 223.03778,176.64451   L 221.29987,177.13291   L 219.52291,177.5627   L 217.7069,177.97296   L 215.87136,178.32461   L 213.99676,178.63718   L 212.10264,178.91069   L 210.16946,179.14512   L 208.21676,179.34048   L 206.225,179.49677   L 206.04926,177.09384   L 207.96291,176.95709   L 209.8375,176.76173   L 211.69257,176.54683   L 213.52811,176.27333   L 215.30507,175.98029   L 217.08203,175.62864   L 218.81994,175.25746   L 220.51879,174.8472   L 222.19812,174.39787   L 223.83839,173.90947   L 225.45913,173.382   L 227.02129,172.81546   L 228.56393,172.20984   L 230.06751,171.56515   L 231.53204,170.88139   L 232.95751,170.1781   L 234.34393,169.41619   L 235.6913,168.63475   L 236.99961,167.7947   L 238.26887,166.93512   L 239.49907,166.03646   L 240.67069,165.09874   L 241.80326,164.12194   L 242.89677,163.10606   L 243.93171,162.05112   L 244.92758,160.9571   L 245.88441,159.84355   L 246.78265,158.67139   L 247.62231,157.4797   L 248.42292,156.24893   L 249.18448,154.97909   L 249.86792,153.67018   L 252.0159,154.74466  z    M 206.225,179.49677   L 204.23325,179.61398   L 202.22196,179.69213   L 200.19115,179.71166   L 198.14081,179.71166   L 196.05142,179.67259   L 193.9425,179.57491   L 191.83358,179.4577   L 189.68561,179.28187   L 187.53763,179.08651   L 185.37013,178.83254   L 183.1831,178.5395   L 180.97655,178.20739   L 178.75047,177.83621   L 176.52438,177.42595   L 174.27878,176.97662   L 172.03317,176.48822   L 169.76803,175.96075   L 167.48337,175.39421   L 165.19871,174.76906   L 162.91404,174.12437   L 160.62938,173.42107   L 158.32519,172.6787   L 156.021,171.89726   L 153.69728,171.07675   L 151.39309,170.21717   L 149.06938,169.31851   L 146.76519,168.38078   L 144.44147,167.38445   L 142.11775,166.36858   L 139.81356,165.2941   L 137.50937,164.18054   L 135.18565,163.02792   L 136.27917,160.8985   L 138.5443,162.03158   L 140.80944,163.1256   L 143.0941,164.18054   L 145.35924,165.17688   L 147.6439,166.15368   L 149.92856,167.09141   L 152.1937,167.97053   L 154.47836,168.81058   L 156.7435,169.63109   L 159.00864,170.39299   L 161.27377,171.11582   L 163.53891,171.79958   L 165.78452,172.44427   L 168.03013,173.04989   L 170.25621,173.61643   L 172.48229,174.12437   L 174.68884,174.61277   L 176.8954,175.0621   L 179.08243,175.47235   L 181.26945,175.824   L 183.43695,176.15611   L 185.58493,176.42962   L 187.71338,176.68358   L 189.82229,176.87894   L 191.93121,177.05477   L 194.02061,177.17198   L 196.07095,177.26966   L 198.12128,177.30874   L 200.13257,177.30874   L 202.12433,177.2892   L 204.11608,177.21106   L 206.04926,177.09384   L 206.225,179.49677  z    M 135.18565,163.02792   L 132.90099,161.85576   L 130.63586,160.64453   L 128.40977,159.41376   L 126.20322,158.16346   L 124.03572,156.87408   L 121.88774,155.56517   L 119.79835,154.23672   L 117.72849,152.88874   L 115.69767,151.50168   L 113.68639,150.11462   L 111.73369,148.6885   L 109.80051,147.26237   L 107.90639,145.79717   L 106.07085,144.31243   L 104.25483,142.8277   L 102.47787,141.32342   L 100.73997,139.79962   L 99.041115,138.25627   L 97.381317,136.69339   L 95.760573,135.13051   L 94.178884,133.5481   L 92.636248,131.96568   L 91.152193,130.36373   L 89.687666,128.74224   L 88.281719,127.12075   L 86.914827,125.49926   L 85.606516,123.85824   L 84.317732,122.19768   L 83.087528,120.55666   L 81.896379,118.8961   L 80.763811,117.23554   L 79.670298,115.55544   L 81.701109,114.26606   L 82.775096,115.90709   L 83.888137,117.52858   L 85.059759,119.1696   L 86.270435,120.79109   L 87.520165,122.41258   L 88.828476,124.01453   L 90.156315,125.61648   L 91.542734,127.21843   L 92.968208,128.80085   L 94.452262,130.36373   L 95.955844,131.92661   L 97.498479,133.48949   L 99.099696,135.0133   L 100.72044,136.55664   L 102.39976,138.06091   L 104.09862,139.56518   L 105.85605,141.03038   L 107.63301,142.51512   L 109.44902,143.96078   L 111.30409,145.38691   L 113.19821,146.7935   L 115.13139,148.2001   L 117.10362,149.56762   L 119.09538,150.9156   L 121.12619,152.24405   L 123.19606,153.55296   L 125.30498,154.84234   L 127.43342,156.11218   L 129.60092,157.34294   L 131.78795,158.55418   L 134.01403,159.74587   L 136.27917,160.8985   L 135.18565,163.02792  z    M 79.670298,115.55544   L 78.615838,113.87534   L 77.600432,112.19525   L 76.643607,110.51515   L 75.745364,108.83506   L 74.886174,107.13542   L 74.085566,105.45533   L 73.324012,103.77523   L 72.621038,102.0756   L 71.957119,100.3955   L 71.351781,98.715408   L 70.805024,97.054848   L 70.316848,95.374752   L 69.867727,93.714192   L 69.477186,92.053632   L 69.145226,90.412608   L 68.852321,88.752048   L 68.637523,87.13056   L 68.46178,85.509072   L 68.364145,83.887584   L 68.305564,82.285632   L 68.305564,80.703216   L 68.364145,79.1208   L 68.481307,77.55792   L 68.676578,75.99504   L 68.910902,74.471232   L 69.203807,72.947424   L 69.574821,71.443152   L 69.984889,69.958416   L 70.473065,68.493216   L 71.019822,67.047552   L 71.62516,65.601888   L 72.308606,64.195296   L 74.45658,65.269776   L 73.812187,66.598224   L 73.245903,67.946208   L 72.718674,69.333264   L 72.269552,70.72032   L 71.879011,72.126912   L 71.547052,73.55304   L 71.254146,74.998704   L 71.039349,76.463904   L 70.863605,77.929104   L 70.76597,79.41384   L 70.707389,80.918112   L 70.707389,82.44192   L 70.76597,83.965728   L 70.883132,85.489536   L 71.058876,87.052416   L 71.273673,88.615296   L 71.547052,90.178176   L 71.879011,91.741056   L 72.250025,93.323472   L 72.679619,94.925424   L 73.167795,96.527376   L 73.695025,98.129328   L 74.280836,99.73128   L 74.925228,101.33323   L 75.589148,102.95472   L 76.331175,104.55667   L 77.112256,106.17816   L 77.932392,107.79965   L 78.811108,109.42114   L 79.728879,111.04262   L 80.685703,112.64458   L 81.701109,114.26606   L 79.670298,115.55544  z    M 72.308606,64.195296   L 72.718674,63.374784   L 73.167795,62.573808   L 73.636444,61.792368   L 74.105093,61.010928   L 74.612796,60.249024   L 75.120499,59.48712   L 75.667256,58.764288   L 76.214013,58.02192   L 76.799824,57.318624   L 77.385635,56.615328   L 77.990973,55.931568   L 78.635365,55.247808   L 79.279757,54.60312   L 79.924149,53.958432   L 80.607595,53.313744   L 81.310568,52.688592   L 82.892258,54.50544   L 82.247866,55.071984   L 81.603474,55.6776   L 80.978609,56.283216   L 80.373271,56.908368   L 79.78746,57.53352   L 79.221176,58.178208   L 78.654892,58.822896   L 78.127662,59.506656   L 77.600432,60.17088   L 77.092729,60.874176   L 76.604553,61.577472   L 76.135904,62.280768   L 75.686783,63.023136   L 75.257188,63.745968   L 74.84712,64.507872   L 74.45658,65.269776   L 72.308606,64.195296  z    M 81.310568,52.688592   L 82.033069,52.06344   L 82.794623,51.457824   L 83.556177,50.871744   L 84.337259,50.285664   L 85.137867,49.71912   L 85.958002,49.172112   L 86.778138,48.625104   L 87.637327,48.097632   L 88.496517,47.589696   L 89.375233,47.101296   L 90.25395,46.612896   L 91.17172,46.144032   L 92.089491,45.694704   L 93.026789,45.264912   L 93.964086,44.83512   L 94.940438,44.424864   L 95.838681,46.651968   L 94.920911,47.042688   L 94.022667,47.452944   L 93.124424,47.8632   L 92.265234,48.292992   L 91.386518,48.74232   L 90.546855,49.191648   L 89.707193,49.660512   L 88.887057,50.148912   L 88.086449,50.637312   L 87.305368,51.145248   L 86.524286,51.67272   L 85.762732,52.219728   L 85.020705,52.766736   L 84.298205,53.33328   L 83.595231,53.899824   L 82.892258,54.50544   L 81.310568,52.688592  z    M 186.32696,60.639744   L 187.28378,61.128144   L 188.20155,61.63608   L 189.11932,62.144016   L 190.03709,62.671488   L 190.91581,63.218496   L 191.79453,63.745968   L 192.65371,64.312512   L 193.5129,64.85952   L 194.35257,65.4456   L 195.1727,66.03168   L 195.97331,66.61776   L 196.77392,67.20384   L 197.53547,67.809456   L 198.29703,68.434608   L 199.03905,69.040224   L 199.78108,69.665376   L 200.48406,70.310064   L 201.18703,70.954752   L 201.87047,71.59944   L 202.53439,72.244128   L 203.17879,72.908352   L 203.82318,73.55304   L 204.42852,74.217264   L 205.03385,74.901024   L 205.61966,75.565248   L 206.16642,76.249008   L 206.71318,76.932768   L 207.24041,77.616528   L 207.74811,78.300288   L 208.23629,78.984048   L 208.70494,79.667808   L 209.17359,80.371104   L 207.12325,81.66048   L 206.69365,80.996256   L 206.24453,80.351568   L 205.77588,79.687344   L 205.28771,79.02312   L 204.79953,78.378432   L 204.2723,77.733744   L 203.72554,77.06952   L 203.17879,76.424832   L 202.6125,75.79968   L 202.00716,75.154992   L 201.40183,74.52984   L 200.79649,73.904688   L 200.1521,73.279536   L 199.48818,72.654384   L 198.82426,72.048768   L 198.14081,71.443152   L 197.43784,70.837536   L 196.73486,70.251456   L 195.99284,69.665376   L 195.25081,69.079296   L 194.48926,68.512752   L 193.7277,67.946208   L 192.92709,67.379664   L 192.12648,66.832656   L 191.30635,66.305184   L 190.48621,65.758176   L 189.64655,65.25024   L 188.78736,64.722768   L 187.90865,64.234368   L 187.02993,63.745968   L 186.15121,63.257568   L 185.23344,62.788704   L 186.32696,60.639744  z    M 209.17359,80.371104   L 209.60318,81.0744   L 210.03277,81.797232   L 210.44284,82.500528   L 210.81386,83.22336   L 211.18487,83.926656   L 211.51683,84.649488   L 211.82926,85.352784   L 212.14169,86.075616   L 212.41507,86.778912   L 212.66892,87.501744   L 212.90325,88.20504   L 213.11805,88.908336   L 213.29379,89.611632   L 213.46953,90.314928   L 213.60622,91.018224   L 213.72338,91.72152   L 213.82102,92.40528   L 213.89913,93.08904   L 213.93818,93.7728   L 213.97724,94.45656   L 213.97724,95.14032   L 213.93818,95.804544   L 213.89913,96.468768   L 213.82102,97.132992   L 213.72338,97.77768   L 213.60622,98.422368   L 213.45001,99.067056   L 213.29379,99.692208   L 213.07899,100.31736   L 212.86419,100.92298   L 212.61034,101.52859   L 212.33696,102.13421   L 210.16946,101.07926   L 210.40379,100.55179   L 210.61859,100.02432   L 210.81386,99.477312   L 210.9896,98.930304   L 211.14582,98.383296   L 211.26298,97.816752   L 211.36061,97.250208   L 211.45825,96.683664   L 211.51683,96.097584   L 211.53636,95.511504   L 211.55588,94.905888   L 211.55588,94.319808   L 211.51683,93.714192   L 211.47778,93.108576   L 211.39967,92.483424   L 211.30203,91.877808   L 211.18487,91.252656   L 211.06771,90.627504   L 210.91149,90.002352   L 210.73575,89.357664   L 210.54048,88.732512   L 210.32568,88.087824   L 210.09136,87.462672   L 209.8375,86.817984   L 209.56413,86.173296   L 209.27122,85.528608   L 208.95879,84.88392   L 208.62683,84.239232   L 208.27534,83.594544   L 207.92385,82.949856   L 207.53331,82.305168   L 207.12325,81.66048   L 209.17359,80.371104  z    M 212.33696,102.13421   L 212.37602,102.01699   L 212.31744,102.15374   L 211.24345,101.60674   L 212.33696,102.13421  z    M 212.31744,102.15374   L 212.00501,102.72029   L 211.67305,103.30637   L 211.32156,103.85338   L 210.93102,104.38085   L 210.54048,104.90832   L 210.11088,105.41626   L 209.66176,105.88512   L 209.21264,106.35398   L 208.72446,106.82285   L 208.23629,107.25264   L 207.70906,107.6629   L 207.1623,108.07315   L 206.61554,108.46387   L 206.04926,108.81552   L 205.44392,109.16717   L 204.83858,109.49928   L 204.21372,109.83139   L 203.58885,110.12443   L 202.92493,110.41747   L 202.26102,110.67144   L 201.55804,110.92541   L 200.8746,111.15984   L 200.1521,111.37474   L 199.4296,111.5701   L 198.68757,111.76546   L 197.92601,111.92174   L 197.16446,112.07803   L 196.38338,112.19525   L 195.58277,112.31246   L 194.78216,112.41014   L 193.96203,112.48829   L 193.14189,112.5469   L 193.0052,110.1635   L 193.74723,110.1049   L 194.48926,110.02675   L 195.21176,109.94861   L 195.91473,109.83139   L 196.6177,109.73371   L 197.32068,109.59696   L 198.00412,109.44067   L 198.66804,109.28438   L 199.31243,109.10856   L 199.95683,108.93274   L 200.60122,108.71784   L 201.20656,108.50294   L 201.81189,108.26851   L 202.3977,108.01454   L 202.98352,107.76058   L 203.53027,107.48707   L 204.07703,107.19403   L 204.60426,106.88146   L 205.11196,106.54934   L 205.61966,106.21723   L 206.08831,105.86558   L 206.55696,105.51394   L 207.00608,105.12322   L 207.43568,104.7325   L 207.84575,104.32224   L 208.23629,103.89245   L 208.6073,103.46266   L 208.95879,103.01333   L 209.29075,102.54446   L 209.60318,102.05606   L 209.89609,101.56766   L 210.16946,101.05973   L 212.31744,102.15374  z    M 193.14189,112.5469   L 192.32176,112.6055   L 191.50162,112.62504   L 190.66196,112.64458   L 189.82229,112.62504   L 188.98263,112.6055   L 188.10392,112.56643   L 187.24473,112.52736   L 186.36601,112.44922   L 185.48729,112.35154   L 184.58905,112.25386   L 183.69081,112.13664   L 182.79256,111.99989   L 181.89432,111.8436   L 180.97655,111.66778   L 180.05878,111.47242   L 179.14101,111.27706   L 178.20371,111.04262   L 177.28594,110.80819   L 176.34864,110.55422   L 175.41134,110.28072   L 174.47405,109.98768   L 173.53675,109.69464   L 172.59945,109.36253   L 171.64263,109.03042   L 170.70533,108.65923   L 169.7485,108.28805   L 168.81121,107.89733   L 167.87391,107.48707   L 166.91708,107.05728   L 165.97979,106.62749   L 165.04249,106.15862   L 164.08566,105.68976   L 165.19871,103.5408   L 166.09695,104.00966   L 166.99519,104.45899   L 167.91296,104.86925   L 168.81121,105.2795   L 169.72898,105.67022   L 170.62722,106.06094   L 171.54499,106.41259   L 172.44323,106.76424   L 173.34148,107.07682   L 174.25925,107.38939   L 175.15749,107.68243   L 176.05574,107.97547   L 176.95398,108.22944   L 177.8327,108.48341   L 178.73094,108.6983   L 179.60966,108.9132   L 180.5079,109.10856   L 181.38662,109.30392   L 182.24581,109.46021   L 183.12452,109.6165   L 183.98371,109.75325   L 184.8429,109.85093   L 185.68256,109.96814   L 186.54175,110.04629   L 187.38142,110.12443   L 188.20155,110.1635   L 189.02169,110.20258   L 189.84182,110.22211   L 190.64243,110.24165   L 191.44304,110.22211   L 192.22412,110.20258   L 193.0052,110.1635   L 193.14189,112.5469  z    M 165.17918,103.5408   L 165.33539,103.61894   L 165.19871,103.5408   L 164.65195,104.61528   L 165.17918,103.5408  z    M 164.10519,105.68976   L 163.16789,105.2209   L 162.2306,104.71296   L 161.31283,104.22456   L 160.39505,103.69709   L 159.51634,103.16962   L 158.63762,102.64214   L 157.75891,102.09514   L 156.91924,101.54813   L 156.07958,100.98158   L 155.25945,100.3955   L 154.43931,99.82896   L 153.65823,99.24288   L 152.87715,98.637264   L 152.11559,98.031648   L 151.37357,97.426032   L 150.63154,96.80088   L 149.92856,96.175728   L 149.22559,95.550576   L 148.54215,94.905888   L 147.87823,94.2612   L 147.23383,93.616512   L 146.58944,92.952288   L 145.9841,92.3076   L 145.37877,91.643376   L 144.81248,90.979152   L 144.2462,90.295392   L 143.69944,89.631168   L 143.17221,88.947408   L 142.66451,88.263648   L 142.17633,87.579888   L 141.70768,86.896128   L 141.25856,86.212368   L 143.3089,84.922992   L 143.71897,85.587216   L 144.16809,86.231904   L 144.63674,86.876592   L 145.12491,87.540816   L 145.63262,88.185504   L 146.14032,88.830192   L 146.68708,89.455344   L 147.23383,90.100032   L 147.80012,90.725184   L 148.38593,91.369872   L 148.99127,91.995024   L 149.61613,92.60064   L 150.26052,93.225792   L 150.90492,93.831408   L 151.56884,94.437024   L 152.27181,95.023104   L 152.95526,95.62872   L 153.67776,96.2148   L 154.40026,96.781344   L 155.16181,97.367424   L 155.92336,97.914432   L 156.68492,98.480976   L 157.48553,99.027984   L 158.28614,99.574992   L 159.08674,100.10246   L 159.92641,100.6104   L 160.76607,101.13787   L 161.62526,101.62627   L 162.50397,102.13421   L 163.38269,102.60307   L 164.28093,103.09147   L 165.17918,103.5408   L 164.10519,105.68976  z    M 141.25856,86.212368   L 140.82897,85.509072   L 140.39937,84.805776   L 140.00883,84.10248   L 139.63782,83.399184   L 139.2668,82.695888   L 138.93484,81.992592   L 138.62241,81.289296   L 138.32951,80.566464   L 138.05613,79.863168   L 137.80228,79.159872   L 137.58748,78.456576   L 137.37268,77.772816   L 137.19694,77.06952   L 137.04072,76.366224   L 136.90403,75.682464   L 136.78687,74.979168   L 136.70876,74.295408   L 136.63065,73.611648   L 136.5916,72.927888   L 136.57207,72.263664   L 136.5916,71.59944   L 136.61113,70.935216   L 136.66971,70.270992   L 136.74782,69.606768   L 136.86498,68.96208   L 136.98214,68.317392   L 137.13836,67.69224   L 137.33363,67.067088   L 137.54843,66.441936   L 137.78275,65.816784   L 138.0366,65.211168   L 138.32951,64.625088   L 140.47748,65.699568   L 140.22363,66.22704   L 139.9893,66.754512   L 139.79403,67.30152   L 139.61829,67.828992   L 139.46207,68.395536   L 139.32539,68.942544   L 139.20822,69.509088   L 139.13012,70.075632   L 139.05201,70.661712   L 139.01295,71.247792   L 138.99343,71.833872   L 138.99343,72.419952   L 139.01295,73.025568   L 139.05201,73.631184   L 139.13012,74.2368   L 139.20822,74.842416   L 139.32539,75.448032   L 139.44255,76.073184   L 139.59876,76.698336   L 139.75498,77.323488   L 139.95025,77.94864   L 140.16505,78.573792   L 140.37985,79.198944   L 140.6337,79.843632   L 140.90708,80.468784   L 141.18045,81.113472   L 141.49289,81.738624   L 141.82485,82.383312   L 142.15681,83.008464   L 142.52782,83.653152   L 142.89883,84.29784   L 143.3089,84.922992   L 141.25856,86.212368  z    M 140.47748,65.699568   L 140.53606,65.582352   L 140.47748,65.699568   L 139.40349,65.172096   L 140.47748,65.699568  z    M 138.30998,64.625088   L 138.62241,64.039008   L 138.95437,63.472464   L 139.28633,62.925456   L 139.65735,62.378448   L 140.04789,61.870512   L 140.45795,61.362576   L 140.88755,60.874176   L 141.3562,60.405312   L 141.82485,59.955984   L 142.31302,59.506656   L 142.82072,59.0964   L 143.34795,58.686144   L 143.89471,58.295424   L 144.461,57.92424   L 145.04681,57.572592   L 145.63262,57.220944   L 146.25748,56.908368   L 146.88235,56.595792   L 147.52674,56.302752   L 148.19066,56.029248   L 148.87411,55.77528   L 149.57708,55.540848   L 150.28005,55.306416   L 151.00255,55.111056   L 151.72505,54.915696   L 152.48661,54.739872   L 153.24816,54.60312   L 154.00971,54.446832   L 154.81032,54.329616   L 155.61093,54.231936   L 156.41154,54.153792   L 157.23168,54.075648   L 157.40742,56.478576   L 156.66539,56.537184   L 155.92336,56.615328   L 155.22039,56.713008   L 154.49789,56.810688   L 153.81444,56.927904   L 153.11147,57.064656   L 152.44755,57.220944   L 151.78363,57.396768   L 151.13924,57.572592   L 150.49485,57.767952   L 149.86998,57.982848   L 149.26465,58.197744   L 148.67883,58.432176   L 148.09302,58.686144   L 147.52674,58.959648   L 146.97998,59.233152   L 146.43323,59.526192   L 145.92552,59.838768   L 145.41782,60.17088   L 144.92964,60.502992   L 144.461,60.874176   L 144.01187,61.225824   L 143.56275,61.616544   L 143.15268,62.007264   L 142.74262,62.41752   L 142.3716,62.847312   L 142.00059,63.29664   L 141.66863,63.745968   L 141.33667,64.214832   L 141.02424,64.683696   L 140.75086,65.191632   L 140.47748,65.699568   L 138.30998,64.625088  z    M 157.23168,54.075648   L 158.05181,54.01704   L 158.87195,53.977968   L 159.69208,53.977968   L 160.53174,53.958432   L 161.37141,53.977968   L 162.2306,54.01704   L 163.10931,54.056112   L 163.9685,54.11472   L 164.84722,54.192864   L 165.74546,54.290544   L 166.64371,54.40776   L 167.54195,54.544512   L 168.44019,54.681264   L 169.35796,54.837552   L 170.27573,55.032912   L 171.1935,55.228272   L 172.1308,55.423632   L 173.04857,55.658064   L 173.98587,55.912032   L 174.92317,56.166   L 175.87999,56.45904   L 176.81729,56.75208   L 177.75459,57.064656   L 178.71141,57.396768   L 179.66824,57.72888   L 180.60553,58.100064   L 181.56236,58.490784   L 182.51918,58.881504   L 183.47601,59.29176   L 184.41331,59.721552   L 185.37013,60.17088   L 186.32696,60.639744   L 185.25297,62.788704   L 184.3352,62.339376   L 183.41743,61.909584   L 182.51918,61.499328   L 181.60141,61.089072   L 180.68364,60.717888   L 179.76587,60.346704   L 178.86763,59.995056   L 177.94986,59.662944   L 177.03209,59.350368   L 176.13384,59.037792   L 175.2356,58.764288   L 174.31783,58.490784   L 173.41959,58.236816   L 172.52134,58.002384   L 171.64263,57.787488   L 170.74438,57.572592   L 169.86567,57.396768   L 168.98695,57.220944   L 168.10823,57.064656   L 167.24904,56.927904   L 166.38985,56.791152   L 165.53066,56.693472   L 164.691,56.595792   L 163.85134,56.517648   L 163.01168,56.45904   L 162.17201,56.419968   L 161.35188,56.380896   L 160.55127,56.380896   L 159.75066,56.380896   L 158.95005,56.400432   L 158.16897,56.419968   L 157.40742,56.478576   L 157.23168,54.075648  z    M 186.32696,60.639744   L 186.56128,60.75696   L 186.32696,60.639744   L 185.7802,61.714224   L 186.32696,60.639744  z    M 217.51163,74.119584   L 216.69149,73.982832   L 215.85183,73.865616   L 214.97311,73.787472   L 214.07487,73.709328   L 213.1571,73.631184   L 212.2198,73.592112   L 211.24345,73.55304   L 210.2671,73.533504   L 209.27122,73.533504   L 208.25581,73.55304   L 207.22088,73.572576   L 206.18595,73.611648   L 205.13149,73.65072   L 204.0575,73.709328   L 202.98352,73.787472   L 201.90953,73.865616   L 201.71426,71.462688   L 202.8273,71.384544   L 203.94034,71.3064   L 205.03385,71.247792   L 206.12737,71.20872   L 207.20135,71.169648   L 208.27534,71.150112   L 209.3298,71.130576   L 210.36473,71.130576   L 211.38014,71.150112   L 212.37602,71.189184   L 213.35237,71.247792   L 214.30919,71.3064   L 215.24649,71.384544   L 216.16426,71.482224   L 217.06251,71.59944   L 217.9217,71.736192   L 217.51163,74.119584  z    M 201.90953,73.865616   L 200.48406,73.982832   L 199.03905,74.119584   L 197.61358,74.275872   L 196.16858,74.43216   L 194.72358,74.62752   L 193.29811,74.803344   L 191.87263,75.01824   L 190.44716,75.2136   L 189.04121,75.448032   L 187.65479,75.662928   L 186.26837,75.89736   L 184.92101,76.131792   L 183.59317,76.38576   L 182.28486,76.620192   L 181.0156,76.87416   L 179.76587,77.128128   L 179.2777,74.764272   L 180.54695,74.510304   L 181.83574,74.256336   L 183.16358,74.021904   L 184.51094,73.767936   L 185.87783,73.533504   L 187.26425,73.299072   L 188.68973,73.06464   L 190.1152,72.830208   L 191.54067,72.615312   L 193.0052,72.419952   L 194.4502,72.224592   L 195.91473,72.048768   L 197.35973,71.872944   L 198.82426,71.716656   L 200.26926,71.579904   L 201.71426,71.462688   L 201.90953,73.865616  z    M 179.76587,77.128128   L 175.86047,77.968176   L 171.99411,78.905904   L 168.16681,79.90224   L 164.37857,80.97672   L 160.60985,82.129344   L 156.89972,83.340576   L 153.22863,84.629952   L 149.59661,85.997472   L 146.02316,87.4236   L 142.48877,88.908336   L 138.99343,90.471216   L 135.53714,92.092704   L 132.13944,93.7728   L 128.78079,95.53104   L 125.48072,97.347888   L 122.2197,99.223344   L 119.01727,101.15741   L 115.87342,103.15008   L 112.76862,105.18182   L 109.7224,107.29171   L 106.73477,109.46021   L 103.80571,111.66778   L 100.91571,113.93395   L 98.103817,116.25874   L 95.330979,118.62259   L 92.636248,121.04506   L 89.980571,123.52613   L 87.403003,126.02674   L 84.884016,128.60549   L 82.423609,131.20378   L 80.021784,133.86067   L 77.698067,136.55664   L 75.842999,135.0133   L 78.20577,132.27826   L 80.627122,129.58229   L 83.126583,126.94493   L 85.684624,124.34664   L 88.301246,121.78742   L 90.97645,119.28682   L 93.729762,116.84482   L 96.522128,114.42235   L 99.392602,112.07803   L 102.30213,109.79232   L 105.28977,107.54568   L 108.31646,105.35765   L 111.40173,103.20869   L 114.54558,101.13787   L 117.72849,99.125664   L 120.96997,97.152528   L 124.27004,95.257536   L 127.62869,93.421152   L 131.0264,91.643376   L 134.46315,89.943744   L 137.95849,88.30272   L 141.49289,86.720304   L 145.08586,85.196496   L 148.71789,83.750832   L 152.38897,82.383312   L 156.11863,81.0744   L 159.86783,79.843632   L 163.6756,78.671472   L 167.52242,77.577456   L 171.4083,76.561584   L 175.33324,75.623856   L 179.2777,74.764272   L 179.76587,77.128128  z    M 77.698067,136.55664   L 75.413404,139.29168   L 73.226376,142.06579   L 71.078403,144.89851   L 69.028064,147.75077   L 67.01678,150.6421   L 65.10313,153.59203   L 63.228535,156.5615   L 61.451575,159.55051   L 59.733196,162.59813   L 58.092925,165.66528   L 56.530763,168.7715   L 55.046708,171.89726   L 53.640762,175.0621   L 52.293396,178.266   L 51.043666,181.4699   L 49.852517,184.71288   L 48.759003,187.99493   L 47.743597,191.27698   L 46.8063,194.5981   L 45.94711,197.93875   L 45.166029,201.29894   L 44.482583,204.67867   L 43.877245,208.0584   L 43.369542,211.4772   L 42.939947,214.91554   L 42.588461,218.35387   L 42.334609,221.81174   L 42.178393,225.28915   L 42.100285,228.76656   L 42.119812,232.2635   L 42.236974,235.77998   L 42.432244,239.29646   L 40.030419,239.45275   L 39.815622,235.87766   L 39.717987,232.30258   L 39.69846,228.74702   L 39.776568,225.21101   L 39.932784,221.67499   L 40.186635,218.15851   L 40.538122,214.66157   L 40.967717,211.16462   L 41.494947,207.68722   L 42.119812,204.24888   L 42.803258,200.81054   L 43.603866,197.39174   L 44.463056,193.99248   L 45.41988,190.63229   L 46.454813,187.2721   L 47.567854,183.95098   L 48.759003,180.64939   L 50.047787,177.38688   L 51.395153,174.1439   L 52.840153,170.92046   L 54.343735,167.7361   L 55.944952,164.5908   L 57.604749,161.46504   L 59.342655,158.37835   L 61.15867,155.33074   L 63.052792,152.30266   L 65.005495,149.33318   L 67.036307,146.38325   L 69.125699,143.47238   L 71.2932,140.62013   L 73.538809,137.78741   L 75.842999,135.0133   L 77.698067,136.55664  z    M 42.432244,239.29646   L 42.490825,240.13651   L 42.549406,240.9961   L 42.627515,241.83614   L 42.686096,242.71526   L 42.764204,243.57485   L 42.842312,244.45397   L 42.92042,245.33309   L 43.018055,246.23174   L 43.096163,247.11086   L 43.193799,248.00952   L 43.310961,248.92771   L 43.428123,249.82637   L 43.545285,250.74456   L 43.681974,251.66275   L 43.838191,252.60048   L 43.994407,253.53821   L 41.612109,253.92893   L 41.455893,252.9912   L 41.299676,252.03394   L 41.162987,251.09621   L 41.045825,250.15848   L 40.928663,249.24029   L 40.8115,248.3221   L 40.713865,247.4039   L 40.61623,246.48571   L 40.518595,245.58706   L 40.440487,244.6884   L 40.362379,243.80928   L 40.303798,242.93016   L 40.225689,242.05104   L 40.167108,241.17192   L 40.089,240.31234   L 40.030419,239.45275   L 42.432244,239.29646  z    M 43.994407,253.53821   L 44.150623,254.47594   L 44.326367,255.41366   L 44.521637,256.35139   L 44.716907,257.30866   L 44.931705,258.26592   L 45.166029,259.22318   L 45.400353,260.18045   L 45.673732,261.15725   L 45.94711,262.13405   L 46.240016,263.11085   L 46.552448,264.10718   L 46.884408,265.08398   L 47.235895,266.08032   L 47.587381,267.07666   L 47.977922,268.09253   L 48.38799,269.1084   L 46.161908,270.00706   L 45.732313,268.97165   L 45.341772,267.9167   L 44.970759,266.8813   L 44.599745,265.84589   L 44.267785,264.83002   L 43.935826,263.81414   L 43.64292,262.79827   L 43.350015,261.7824   L 43.076636,260.78606   L 42.822785,259.78973   L 42.588461,258.79339   L 42.373663,257.81659   L 42.158866,256.83979   L 41.963595,255.86299   L 41.787852,254.90573   L 41.612109,253.92893   L 43.994407,253.53821  z    M 160.51222,42.510336   L 161.15661,43.135488   L 161.801,43.799712   L 162.46492,44.503008   L 163.10931,45.22584   L 163.77323,45.987744   L 164.43715,46.78872   L 165.08154,47.609232   L 165.74546,48.44928   L 166.40938,49.3284   L 167.05377,50.227056   L 167.69817,51.145248   L 168.34256,52.082976   L 168.98695,53.04024   L 169.63134,53.997504   L 170.25621,54.99384   L 170.9006,55.990176   L 168.85026,57.260016   L 168.24492,56.283216   L 167.63958,55.345488   L 167.03425,54.40776   L 166.40938,53.489568   L 165.78452,52.571376   L 165.15965,51.692256   L 164.53479,50.832672   L 163.90992,49.992624   L 163.26553,49.172112   L 162.64066,48.390672   L 162.0158,47.628768   L 161.37141,46.8864   L 160.74654,46.183104   L 160.10215,45.51888   L 159.47728,44.874192   L 158.85242,44.268576   L 160.51222,42.510336  z    M 170.9006,55.990176   L 171.60357,57.162336   L 172.30655,58.354032   L 173.00952,59.545728   L 173.69296,60.75696   L 174.35688,61.968192   L 175.0208,63.19896   L 175.6652,64.410192   L 176.29006,65.621424   L 176.8954,66.852192   L 177.50074,68.043888   L 178.06702,69.25512   L 178.6333,70.446816   L 179.16053,71.618976   L 179.66824,72.791136   L 180.17594,73.924224   L 180.64459,75.057312   L 178.41851,75.975504   L 177.94986,74.861952   L 177.46168,73.728864   L 176.95398,72.57624   L 176.42675,71.423616   L 175.87999,70.251456   L 175.31371,69.05976   L 174.7279,67.8876   L 174.14209,66.676368   L 173.51722,65.484672   L 172.89236,64.292976   L 172.24796,63.10128   L 171.58405,61.909584   L 170.92013,60.737424   L 170.23668,59.565264   L 169.55323,58.393104   L 168.85026,57.260016   L 170.9006,55.990176  z    M 178.43803,76.014576   L 178.45756,76.073184   L 178.41851,75.975504   L 179.53155,75.50664   L 178.43803,76.014576  z    M 180.62506,74.998704   L 182.30439,78.710544   L 183.88608,82.402848   L 185.38966,86.134224   L 186.81513,89.8656   L 188.1625,93.616512   L 189.41223,97.38696   L 190.58385,101.15741   L 191.67736,104.92786   L 192.69277,108.6983   L 193.61054,112.48829   L 194.46973,116.27827   L 195.23128,120.06826   L 195.91473,123.85824   L 196.52007,127.64822   L 197.0473,131.43821   L 197.49642,135.20866   L 197.86743,138.9791   L 198.14081,142.74955   L 198.35561,146.52   L 198.4923,150.27091   L 198.55088,154.02182   L 198.51182,157.73366   L 198.41419,161.46504   L 198.23845,165.15734   L 197.98459,168.84965   L 197.65264,172.50288   L 197.24257,176.15611   L 196.75439,179.78981   L 196.20763,183.38443   L 195.56324,186.97906   L 194.86027,190.53461   L 194.07919,194.05109   L 191.73594,193.52362   L 192.51703,190.02667   L 193.22,186.52973   L 193.84486,182.99371   L 194.39162,179.43816   L 194.86027,175.86307   L 195.27034,172.26845   L 195.58277,168.63475   L 195.83662,165.00106   L 196.01236,161.34782   L 196.11,157.69459   L 196.14905,154.00229   L 196.09047,150.30998   L 195.95378,146.61768   L 195.75851,142.90584   L 195.46561,139.17446   L 195.09459,135.46262   L 194.665,131.73125   L 194.13777,127.98034   L 193.55196,124.24896   L 192.86851,120.49805   L 192.10696,116.76667   L 191.2673,113.0353   L 190.34952,109.28438   L 189.35365,105.55301   L 188.27966,101.84117   L 187.12756,98.109792   L 185.87783,94.397952   L 184.55,90.705648   L 183.14405,87.013344   L 181.65999,83.340576   L 180.09783,79.667808   L 178.43803,76.014576   L 180.62506,74.998704  z    M 194.07919,194.05109   L 193.22,197.56757   L 192.2827,201.06451   L 191.28682,204.52238   L 190.21284,207.94118   L 189.06074,211.34045   L 187.83054,214.70064   L 186.52223,218.02176   L 185.15533,221.30381   L 183.72986,224.54678   L 182.20675,227.75069   L 180.62506,230.91552   L 178.96526,234.04128   L 177.24689,237.10843   L 175.4504,240.13651   L 173.59533,243.12552   L 171.66215,246.05592   L 169.6704,248.94725   L 167.60053,251.76043   L 165.45256,254.55408   L 163.246,257.26958   L 160.98087,259.94602   L 158.63762,262.56384   L 156.2358,265.10352   L 153.75586,267.60413   L 151.21735,270.04613   L 148.62025,272.40998   L 145.94505,274.71523   L 143.21127,276.96187   L 140.4189,279.13037   L 137.54843,281.24026   L 134.61937,283.272   L 131.63173,285.2256   L 130.34295,283.19386   L 133.27201,281.25979   L 136.16201,279.26712   L 138.9739,277.1963   L 141.72721,275.04734   L 144.42194,272.85931   L 147.03856,270.59314   L 149.59661,268.24882   L 152.09607,265.86542   L 154.51742,263.40389   L 156.89972,260.90328   L 159.18438,258.32453   L 161.42999,255.7067   L 163.59749,253.03027   L 165.68688,250.29523   L 167.73722,247.50158   L 169.68992,244.66886   L 171.60357,241.77754   L 173.41959,238.84714   L 175.19655,235.87766   L 176.8954,232.84958   L 178.51614,229.78243   L 180.0783,226.65667   L 181.56236,223.51138   L 182.96831,220.30747   L 184.31567,217.08403   L 185.58493,213.82152   L 186.7956,210.51994   L 187.92817,207.17928   L 189.00216,203.79955   L 189.97851,200.40029   L 190.89628,196.98149   L 191.73594,193.52362   L 194.07919,194.05109  z    M 131.63173,285.2256   L 131.827,285.10838   L 131.61221,285.24514   L 130.98734,284.20973   L 131.63173,285.2256  z    M 131.61221,285.24514   L 130.12815,286.14379   L 128.58552,287.06198   L 126.9843,287.98018   L 125.34403,288.89837   L 123.6647,289.81656   L 121.9268,290.73475   L 120.14984,291.63341   L 118.3143,292.51253   L 117.27936,290.36357   L 119.07585,289.48445   L 120.81376,288.60533   L 122.51261,287.70667   L 124.19193,286.78848   L 125.79315,285.88982   L 127.37484,284.97163   L 128.89795,284.07298   L 130.36248,283.19386   L 131.61221,285.24514  z    M 118.3143,292.51253   L 117.377,292.96186   L 116.4397,293.39165   L 115.48288,293.82144   L 114.50653,294.2317   L 113.53017,294.66149   L 112.55382,295.05221   L 111.55794,295.46246   L 110.54254,295.83365   L 109.52713,296.22437   L 108.51173,296.57602   L 107.47679,296.9472   L 106.42233,297.27931   L 105.36787,297.61142   L 104.31341,297.94354   L 103.23943,298.23658   L 102.16544,298.52962   L 101.5601,296.20483   L 102.61456,295.91179   L 103.66902,295.61875   L 104.70395,295.30618   L 105.71936,294.97406   L 106.73477,294.64195   L 107.75017,294.2903   L 108.74605,293.93866   L 109.74193,293.56747   L 110.71828,293.19629   L 111.69463,292.80557   L 112.65146,292.41485   L 113.58876,292.02413   L 114.52605,291.61387   L 115.46335,291.20362   L 116.38112,290.77382   L 117.27936,290.36357   L 118.3143,292.51253  z    M 258.8113,191.80445   L 259.00658,189.87038   L 259.16279,187.91678   L 259.26043,185.96318   L 259.29948,184.00958   L 259.27995,182.03645   L 259.22137,180.06331   L 259.10421,178.07064   L 258.92847,176.07797   L 258.71367,174.0853   L 258.44029,172.09262   L 258.10833,170.08042   L 257.73732,168.06821   L 257.30772,166.056   L 256.83907,164.04379   L 256.31184,162.03158   L 255.72603,160.01938   L 255.10117,158.00717   L 254.43725,155.99496   L 253.71475,153.98275   L 252.95319,151.97054   L 252.13306,149.95834   L 251.27387,147.96566   L 250.3561,145.97299   L 249.4188,143.96078   L 248.4034,141.98765   L 247.36846,139.99498   L 246.27495,138.02184   L 245.14238,136.0487   L 243.95123,134.07557   L 242.74056,132.12197   L 241.4713,130.1879   L 240.16299,128.25384   L 242.15475,126.90586   L 243.48258,128.87899   L 244.79089,130.87166   L 246.04062,132.86434   L 247.23177,134.87654   L 248.4034,136.88875   L 249.51644,138.9205   L 250.59042,140.95224   L 251.60583,142.98398   L 252.58218,145.03526   L 253.51948,147.08654   L 254.3982,149.13782   L 255.23786,151.1891   L 256.01894,153.25992   L 256.76097,155.3112   L 257.44441,157.38202   L 258.06928,159.45283   L 258.65509,161.50411   L 259.20185,163.57493   L 259.69002,165.64574   L 260.11962,167.69702   L 260.51016,169.76784   L 260.84212,171.81912   L 261.11549,173.8704   L 261.34982,175.92168   L 261.50604,177.97296   L 261.64272,180.0047   L 261.70131,182.03645   L 261.72083,184.06819   L 261.66225,186.0804   L 261.56462,188.09261   L 261.4084,190.08528   L 261.21313,192.07795   L 258.8113,191.80445  z    M 240.16299,128.25384   L 238.81562,126.35885   L 237.44873,124.46386   L 236.02326,122.5884   L 234.55873,120.73248   L 233.07467,118.87656   L 231.53204,117.04018   L 229.95035,115.22333   L 228.32961,113.40648   L 226.68933,111.60917   L 224.99048,109.83139   L 223.25258,108.07315   L 221.49514,106.33445   L 219.67913,104.61528   L 217.84359,102.91565   L 215.96899,101.23555   L 214.03582,99.555456   L 212.08311,97.914432   L 210.11088,96.292944   L 208.08007,94.690992   L 206.02973,93.108576   L 203.94034,91.565232   L 201.81189,90.021888   L 199.64439,88.517616   L 197.45736,87.03288   L 195.23128,85.56768   L 192.98567,84.141552   L 190.68148,82.73496   L 188.37729,81.36744   L 186.01452,80.019456   L 183.63223,78.691008   L 181.21087,77.401632   L 178.76999,76.151328   L 179.86351,74.021904   L 182.32391,75.291744   L 184.78432,76.600656   L 187.20567,77.929104   L 189.58797,79.296624   L 191.95074,80.703216   L 194.25493,82.129344   L 196.55912,83.575008   L 198.80473,85.059744   L 201.03081,86.564016   L 203.21784,88.087824   L 205.38534,89.650704   L 207.49426,91.23312   L 209.58365,92.835072   L 211.63399,94.45656   L 213.6648,96.097584   L 215.63703,97.77768   L 217.58974,99.457776   L 219.48386,101.17694   L 221.35845,102.89611   L 223.194,104.65435   L 224.99048,106.41259   L 226.74792,108.2099   L 228.46629,110.00722   L 230.14562,111.82406   L 231.78589,113.66045   L 233.38711,115.51637   L 234.94927,117.37229   L 236.47238,119.26728   L 237.95643,121.16227   L 239.38191,123.05726   L 240.78785,124.97179   L 242.15475,126.90586   L 240.16299,128.25384  z    M 178.76999,76.151328   L 176.30959,74.92056   L 173.84918,73.7484   L 171.36925,72.615312   L 168.86979,71.521296   L 166.37033,70.485888   L 163.89039,69.489552   L 161.37141,68.512752   L 158.87195,67.614096   L 156.35296,66.734976   L 153.8535,65.894928   L 151.33451,65.113488   L 148.81552,64.37112   L 146.29654,63.667824   L 143.79708,63.023136   L 141.27809,62.397984   L 138.77863,61.83144   L 136.25964,61.303968   L 133.76018,60.815568   L 131.26072,60.36624   L 128.78079,59.955984   L 126.30085,59.604336   L 123.82092,59.272224   L 121.36051,58.99872   L 118.90011,58.764288   L 116.4397,58.568928   L 113.99882,58.41264   L 111.57747,58.295424   L 109.17565,58.236816   L 106.77382,58.197744   L 104.372,58.21728   L 102.00922,58.256352   L 99.646453,58.354032   L 99.548818,55.951104   L 101.93112,55.853424   L 104.35247,55.814352   L 106.77382,55.794816   L 109.2147,55.833888   L 111.65558,55.892496   L 114.11599,56.009712   L 116.59592,56.166   L 119.07585,56.36136   L 121.57531,56.615328   L 124.07477,56.888832   L 126.59376,57.220944   L 129.11275,57.572592   L 131.63173,57.982848   L 134.17025,58.451712   L 136.70876,58.940112   L 139.24728,59.467584   L 141.80532,60.053664   L 144.34383,60.678816   L 146.90187,61.34304   L 149.45992,62.065872   L 151.99843,62.80824   L 154.55647,63.609216   L 157.11451,64.449264   L 159.65303,65.34792   L 162.19154,66.266112   L 164.73006,67.242912   L 167.26857,68.258784   L 169.80709,69.313728   L 172.32607,70.42728   L 174.84506,71.579904   L 177.36405,72.7716   L 179.86351,74.021904   L 178.76999,76.151328  z    M 99.646453,58.354032   L 97.283682,58.490784   L 94.920911,58.666608   L 92.597194,58.881504   L 90.273477,59.155008   L 87.988814,59.448048   L 85.723678,59.799696   L 83.458542,60.17088   L 81.23246,60.600672   L 79.045432,61.069536   L 76.858405,61.577472   L 74.710431,62.12448   L 72.581984,62.71056   L 70.473065,63.335712   L 68.403199,63.999936   L 66.372388,64.722768   L 64.361103,65.465136   L 62.369346,66.266112   L 60.416642,67.086624   L 58.502993,67.965744   L 56.628398,68.8644   L 54.77333,69.821664   L 52.957315,70.798464   L 51.180355,71.833872   L 49.422922,72.888816   L 47.72407,74.002368   L 46.064273,75.154992   L 44.424002,76.327152   L 42.842312,77.55792   L 41.299676,78.82776   L 39.796095,80.117136   L 38.331567,81.46512   L 36.906094,82.83264   L 35.207242,81.113472   L 36.671769,79.70688   L 38.175351,78.319824   L 39.717987,76.991376   L 41.299676,75.702   L 42.939947,74.43216   L 44.619272,73.220928   L 46.318124,72.048768   L 48.075557,70.896144   L 49.872044,69.802128   L 51.688058,68.747184   L 53.562653,67.731312   L 55.456776,66.754512   L 57.389952,65.816784   L 59.362182,64.918128   L 61.35394,64.07808   L 63.384751,63.257568   L 65.454617,62.495664   L 67.54401,61.753296   L 69.672456,61.069536   L 71.82043,60.424848   L 74.007458,59.819232   L 76.194486,59.252688   L 78.440094,58.744752   L 80.685703,58.256352   L 82.970366,57.82656   L 85.274556,57.43584   L 87.598273,57.084192   L 89.961044,56.771616   L 92.323815,56.498112   L 94.706114,56.283216   L 97.127466,56.087856   L 99.548818,55.951104   L 99.646453,58.354032  z    M 189.35365,55.443168   L 186.36601,53.997504   L 183.35885,52.610448   L 180.33216,51.321072   L 177.30547,50.10984   L 174.23972,48.996288   L 171.17398,47.941344   L 168.08871,46.98408   L 165.00343,46.10496   L 161.89864,45.303984   L 158.79384,44.581152   L 155.68904,43.956   L 152.56471,43.389456   L 149.44039,42.901056   L 146.29654,42.510336   L 143.17221,42.178224   L 140.04789,41.924256   L 136.90403,41.767968   L 133.77971,41.670288   L 130.65538,41.650752   L 127.55058,41.70936   L 124.42626,41.846112   L 121.32146,42.061008   L 118.23619,42.334512   L 115.15092,42.68616   L 112.08517,43.115952   L 109.01943,43.623888   L 105.97321,44.209968   L 102.94652,44.854656   L 99.939359,45.577488   L 96.951722,46.358928   L 93.983613,47.218512   L 91.035031,48.15624   L 90.273477,45.870528   L 93.261113,44.913264   L 96.287803,44.05368   L 99.33402,43.233168   L 102.39976,42.510336   L 105.48504,41.846112   L 108.58983,41.260032   L 111.71416,40.752096   L 114.83849,40.302768   L 117.98234,39.95112   L 121.12619,39.65808   L 124.28957,39.443184   L 127.45295,39.306432   L 130.63586,39.247824   L 133.81876,39.26736   L 137.00167,39.36504   L 140.18458,39.540864   L 143.38701,39.794832   L 146.56992,40.107408   L 149.75282,40.5372   L 152.93573,41.0256   L 156.11863,41.592144   L 159.30154,42.236832   L 162.46492,42.9792   L 165.6283,43.799712   L 168.77215,44.678832   L 171.916,45.675168   L 175.04033,46.730112   L 178.14513,47.882736   L 181.24993,49.113504   L 184.31567,50.422416   L 187.38142,51.829008   L 190.42763,53.313744   L 189.35365,55.443168  z    M 91.035031,48.15624   L 88.105976,49.172112   L 85.196448,50.227056   L 82.306447,51.37968   L 79.475027,52.590912   L 76.643607,53.860752   L 73.851242,55.208736   L 71.078403,56.634864   L 68.364145,58.100064   L 65.669414,59.662944   L 63.013738,61.264896   L 60.377588,62.944992   L 57.80002,64.683696   L 55.241978,66.500544   L 52.742518,68.376   L 50.282112,70.310064   L 47.86076,72.302736   L 45.497989,74.354016   L 43.174272,76.48344   L 40.889609,78.671472   L 38.663527,80.918112   L 36.476499,83.22336   L 34.348052,85.587216   L 32.25866,88.00968   L 30.247375,90.510288   L 28.275145,93.049968   L 26.381023,95.648256   L 24.525954,98.324688   L 22.729467,101.04019   L 21.011088,103.8143   L 19.331763,106.64702   L 17.730547,109.53835   L 16.207438,112.48829   L 14.059464,111.41381   L 15.621627,108.40526   L 17.242371,105.47486   L 18.941223,102.58354   L 20.718183,99.750816   L 22.534197,96.976704   L 24.408792,94.2612   L 26.361496,91.604304   L 28.37278,89.006016   L 30.423119,86.485872   L 32.532038,84.0048   L 34.699539,81.601872   L 36.925621,79.238016   L 39.190757,76.952304   L 41.514474,74.7252   L 43.896772,72.556704   L 46.318124,70.466352   L 48.77853,68.434608   L 51.277991,66.461472   L 53.836032,64.546944   L 56.433127,62.71056   L 59.069277,60.932784   L 61.724954,59.213616   L 64.439211,57.572592   L 67.192523,56.009712   L 69.965362,54.50544   L 72.777255,53.059776   L 75.628202,51.692256   L 78.498676,50.383344   L 81.388677,49.152576   L 84.337259,47.980416   L 87.285841,46.8864   L 90.273477,45.870528   L 91.035031,48.15624  z    M 16.207438,112.48829   L 14.74291,115.4773   L 13.376018,118.48584   L 12.067707,121.51392   L 10.876558,124.56154   L 9.7439898,127.62869   L 8.709057,130.69584   L 7.7327054,133.78253   L 6.8539888,136.86922   L 6.0533805,139.97544   L 5.3504072,143.1012   L 4.7060151,146.22696   L 4.1397311,149.35272   L 3.6710823,152.47848   L 3.2610146,155.62378   L 2.9485821,158.74954   L 2.6947307,161.89483   L 2.5385144,165.02059   L 2.4408792,168.16589   L 2.4408792,171.29165   L 2.4994603,174.41741   L 2.6361496,177.52363   L 2.8509469,180.62986   L 3.1243254,183.73608   L 3.495339,186.82277   L 3.9249338,189.90946   L 4.4326367,192.97661   L 5.0184477,196.02422   L 5.6628398,199.0523   L 6.38534,202.06085   L 7.1859484,205.04986   L 8.0451379,208.03886   L 8.9824355,210.9888   L 6.6977726,211.7507   L 5.7409479,208.74216   L 4.8622314,205.71408   L 4.061623,202.66646   L 3.3195957,199.57978   L 2.6556766,196.49309   L 2.0698656,193.38686   L 1.5426357,190.28064   L 1.0935139,187.13534   L 0.74202728,183.99005   L 0.44912178,180.84475   L 0.2343244,177.67992   L 0.078108135,174.49555   L 0.019527034,171.31118   L 0.039054067,168.12682   L 0.13668924,164.94245   L 0.29290551,161.73854   L 0.54675694,158.55418   L 0.87871652,155.35027   L 1.2887842,152.1659   L 1.7769601,148.962   L 2.343244,145.77763   L 2.9876362,142.59326   L 3.7296634,139.42843   L 4.5302718,136.2636   L 5.4285154,133.1183   L 6.4048671,129.97301   L 7.4788539,126.82771   L 8.6114219,123.72149   L 9.841625,120.61526   L 11.169463,117.52858   L 12.57541,114.46142   L 14.059464,111.41381   L 16.207438,112.48829  z    M 8.9824355,210.9888   L 9.9978413,213.9192   L 11.071828,216.83006   L 12.223923,219.72139   L 13.434599,222.57365   L 14.723383,225.40637   L 16.070749,228.20002   L 17.496222,230.97413   L 18.980277,233.70917   L 20.542439,236.40514   L 22.163183,239.08157   L 23.842508,241.69939   L 25.580414,244.29768   L 27.396428,246.83736   L 29.271024,249.3575   L 31.223727,251.81904   L 33.215484,254.2415   L 35.28535,256.6249   L 37.413797,258.94968   L 39.600824,261.23539   L 41.86596,263.48203   L 44.17015,265.67006   L 46.552448,267.79949   L 48.973801,269.8703   L 51.473261,271.90205   L 54.011775,273.85565   L 56.628398,275.77018   L 59.303601,277.6261   L 62.017859,279.42341   L 64.810225,281.14258   L 67.641645,282.80314   L 70.531646,284.40509   L 73.480228,285.94843   L 72.406241,288.07786   L 69.399078,286.51498   L 66.450496,284.89349   L 63.560495,283.19386   L 60.729075,281.43562   L 57.956236,279.59923   L 55.222451,277.72378   L 52.566775,275.77018   L 49.969679,273.7775   L 47.431165,271.70669   L 44.951232,269.5968   L 42.529879,267.4283   L 40.186635,265.2012   L 37.882445,262.91549   L 35.656364,260.5907   L 33.488863,258.22685   L 31.379943,255.80438   L 29.349132,253.32331   L 27.357374,250.8227   L 25.443725,248.26349   L 23.608184,245.6652   L 21.811697,243.02784   L 20.112845,240.35141   L 18.453047,237.6359   L 16.871357,234.88133   L 15.367776,232.10722   L 13.922775,229.2745   L 12.536356,226.42224   L 11.228044,223.55045   L 9.9978413,220.63958   L 8.8262192,217.70918   L 7.7327054,214.73971   L 6.6977726,211.7507   L 8.9824355,210.9888  z    M 73.480228,285.94843   L 76.467864,287.41363   L 79.475027,288.78115   L 82.501717,290.07053   L 85.547935,291.28176   L 88.594152,292.41485   L 91.659896,293.45026   L 94.745168,294.40752   L 97.830439,295.30618   L 100.93524,296.10715   L 104.05956,296.81045   L 107.16436,297.45514   L 110.28869,298.02168   L 113.41301,298.49054   L 116.55686,298.9008   L 119.68119,299.21338   L 122.82504,299.46734   L 125.94937,299.64317   L 129.07369,299.72131   L 132.19802,299.74085   L 135.32234,299.68224   L 138.42714,299.54549   L 141.53194,299.33059   L 144.63674,299.05709   L 147.72201,298.6859   L 150.78775,298.25611   L 153.8535,297.74818   L 156.89972,297.18163   L 159.92641,296.51741   L 162.93357,295.79458   L 165.92121,295.01314   L 168.90884,294.13402   L 171.85742,293.19629   L 172.61898,295.482   L 169.61181,296.43926   L 166.58512,297.31838   L 163.53891,298.1389   L 160.47316,298.86173   L 157.38789,299.52595   L 154.28309,300.13157   L 151.15877,300.6395   L 148.03444,301.08883   L 144.89059,301.44048   L 141.74674,301.73352   L 138.58336,301.94842   L 135.40045,302.08517   L 132.23707,302.14378   L 129.05417,302.14378   L 125.85173,302.0461   L 122.66883,301.87027   L 119.48592,301.6163   L 116.28349,301.28419   L 113.10058,300.87394   L 109.91767,300.38554   L 106.73477,299.81899   L 103.55186,299.15477   L 100.38848,298.43194   L 97.225101,297.61142   L 94.061721,296.71277   L 90.937396,295.73597   L 87.813071,294.68102   L 84.688745,293.5284   L 81.603474,292.29763   L 78.518203,290.96918   L 75.452458,289.58213   L 72.406241,288.07786   L 73.480228,285.94843  z    M 171.85742,293.19629   L 174.78648,292.19995   L 177.67648,291.12547   L 180.56648,289.97285   L 183.3979,288.76162   L 186.22932,287.47224   L 189.02169,286.12426   L 191.775,284.71766   L 194.50878,283.23293   L 197.20351,281.67005   L 199.85919,280.0681   L 202.47581,278.36846   L 205.05338,276.62976   L 207.61142,274.81291   L 210.11088,272.93746   L 212.57129,271.00339   L 214.99264,268.99118   L 217.35541,266.9399   L 219.67913,264.81048   L 221.96379,262.60291   L 224.18987,260.35627   L 226.3769,258.05102   L 228.50535,255.66763   L 230.57521,253.24517   L 232.5865,250.74456   L 234.55873,248.18534   L 236.47238,245.58706   L 238.30792,242.91062   L 240.10441,240.17558   L 241.82279,237.40147   L 243.50211,234.54922   L 245.10333,231.65789   L 246.62644,228.70795   L 248.77441,229.7629   L 247.21225,232.79098   L 245.5915,235.74091   L 243.89265,238.63224   L 242.13522,241.46496   L 240.29968,244.25861   L 238.42508,246.97411   L 236.47238,249.63101   L 234.48062,252.2293   L 232.43028,254.76898   L 230.30184,257.25005   L 228.13433,259.67251   L 225.92778,262.03637   L 223.64312,264.32208   L 221.3194,266.54918   L 218.95663,268.71768   L 216.53528,270.82757   L 214.07487,272.87885   L 211.57541,274.85198   L 209.01737,276.76651   L 206.4398,278.6029   L 203.80365,280.38067   L 201.12845,282.09984   L 198.43372,283.74086   L 195.6804,285.32328   L 192.90757,286.84709   L 190.09567,288.29275   L 187.24473,289.66027   L 184.37425,290.96918   L 181.48425,292.19995   L 178.5552,293.37211   L 175.58709,294.46613   L 172.61898,295.482   L 171.85742,293.19629  z    M 246.62644,228.70795   L 248.09096,225.71894   L 249.45786,222.7104   L 250.76617,219.70186   L 251.97684,216.65424   L 253.08988,213.60662   L 254.14434,210.53947   L 255.10117,207.47232   L 255.97988,204.38563   L 256.78049,201.27941   L 257.48347,198.17318   L 258.12786,195.04742   L 258.69414,191.92166   L 259.16279,188.7959   L 259.57286,185.67014   L 259.88529,182.54438   L 260.13914,179.41862   L 260.29536,176.27333   L 260.39299,173.14757   L 260.39299,170.02181   L 260.33441,166.91558   L 260.19772,163.78982   L 259.98293,160.6836   L 259.70955,157.59691   L 259.33853,154.51022   L 258.90894,151.44307   L 258.40124,148.37592   L 257.81543,145.3283   L 257.17103,142.30022   L 256.44853,139.29168   L 255.64793,136.30267   L 254.76921,133.3332   L 253.83191,130.36373   L 256.1361,129.62136   L 257.09293,132.61037   L 257.97164,135.63845   L 258.77225,138.68606   L 259.51428,141.75322   L 260.1782,144.8399   L 260.76401,147.94613   L 261.29124,151.07189   L 261.74036,154.19765   L 262.09185,157.34294   L 262.38475,160.48824   L 262.59955,163.65307   L 262.75577,166.8179   L 262.81435,170.00227   L 262.79482,173.18664   L 262.69718,176.37101   L 262.54097,179.55538   L 262.28712,182.75928   L 261.95516,185.94365   L 261.54509,189.12802   L 261.05691,192.31238   L 260.49063,195.49675   L 259.84624,198.66158   L 259.10421,201.82642   L 258.3036,204.99125   L 257.40536,208.13654   L 256.42901,211.28184   L 255.35502,214.4076   L 254.22245,217.51382   L 252.99225,220.60051   L 251.66441,223.66766   L 250.27799,226.73482   L 248.77441,229.7629   L 246.62644,228.70795  z    M 253.83191,130.36373   L 252.83603,127.43333   L 251.76205,124.52246   L 250.60995,121.65067   L 249.37975,118.79842   L 248.11049,115.9657   L 246.7436,113.17205   L 245.33765,110.39794   L 243.8536,107.6629   L 242.29143,104.96693   L 240.67069,102.31003   L 238.99137,99.672672   L 237.23393,97.09392   L 235.43745,94.534704   L 233.54332,92.034096   L 231.61015,89.57256   L 229.59886,87.150096   L 227.54852,84.766704   L 225.42008,82.44192   L 223.21352,80.156208   L 220.96791,77.929104   L 218.66372,75.741072   L 216.28143,73.611648   L 213.86007,71.521296   L 211.36061,69.509088   L 208.80257,67.535952   L 206.20548,65.621424   L 203.53027,63.78504   L 200.81601,61.987728   L 198.02365,60.249024   L 195.19223,58.588464   L 192.30223,56.986512   L 189.35365,55.443168   L 190.42763,53.313744   L 193.4348,54.876624   L 196.38338,56.517648   L 199.27338,58.21728   L 202.1048,59.97552   L 204.87764,61.792368   L 207.5919,63.68736   L 210.2671,65.621424   L 212.86419,67.633632   L 215.40271,69.684912   L 217.88264,71.814336   L 220.28447,73.982832   L 222.64724,76.209936   L 224.95143,78.476112   L 227.17751,80.800896   L 229.34501,83.184288   L 231.45393,85.606752   L 233.48474,88.068288   L 235.45697,90.568896   L 237.37062,93.128112   L 239.22569,95.7264   L 241.00265,98.36376   L 242.72103,101.04019   L 244.38083,103.7557   L 245.96252,106.49074   L 247.4661,109.28438   L 248.9111,112.09757   L 250.29752,114.94982   L 251.60583,117.82162   L 252.83603,120.73248   L 254.00765,123.66288   L 255.10117,126.63235   L 256.1361,129.62136   L 253.83191,130.36373  z   " id="path87"/>
			<path style="fill:#c5254d;fill-rule:evenodd;fill-opacity:1;stroke:none;" d="  M 79.924149,104.53714   L 78.186243,104.65435   L 76.506918,104.7325   L 74.886174,104.81064   L 73.304485,104.84971   L 71.742322,104.88878   L 70.23874,104.88878   L 68.735159,104.86925   L 67.251104,104.84971   L 65.747523,104.7911   L 64.263468,104.7325   L 62.740359,104.63482   L 61.197724,104.53714   L 59.616034,104.41992   L 57.99529,104.28317   L 56.315965,104.14642   L 54.558532,103.97059   L 56.960357,108.75691   L 59.479345,113.44555   L 62.115494,118.07558   L 64.849279,122.62747   L 67.661172,127.10122   L 70.590227,131.51635   L 73.577863,135.83381   L 76.682661,140.11219   L 79.826514,144.2929   L 83.068001,148.41499   L 86.36807,152.45894   L 89.72672,156.44429   L 93.143951,160.37102   L 96.600236,164.21962   L 100.09557,168.0096   L 103.64949,171.74098   L 107.22294,175.39421   L 110.83544,178.98883   L 114.46747,182.52485   L 118.11903,186.00226   L 121.77058,189.42106   L 125.44166,192.78125   L 129.11275,196.08283   L 132.78383,199.32581   L 136.43538,202.51018   L 140.06741,205.63594   L 143.69944,208.72262   L 147.29242,211.73117   L 150.86586,214.70064   L 154.40026,217.63104   L 157.89559,220.50283   L 161.33235,223.31602   L 160.49269,223.84349   L 159.55539,224.37096   L 158.52046,224.91797   L 157.40742,225.48451   L 156.21627,226.05106   L 154.92749,226.6176   L 153.59965,227.20368   L 152.1937,227.77022   L 150.7487,228.3563   L 149.26465,228.94238   L 147.74154,229.50893   L 146.1989,230.07547   L 144.61721,230.64202   L 143.03552,231.20856   L 141.43431,231.75557   L 139.85262,232.28304   L 136.70876,233.31845   L 133.66255,234.27571   L 130.75302,235.15483   L 128.07781,235.95581   L 125.65646,236.62003   L 123.5866,237.16704   L 122.68835,237.38194   L 121.88774,237.5773   L 121.22383,237.71405   L 120.65754,237.83126   L 125.26592,241.38682   L 129.89383,244.84469   L 134.56079,248.16581   L 139.24728,251.40878   L 143.97282,254.51501   L 148.71789,257.54309   L 153.50201,260.47349   L 158.30566,263.28667   L 163.12884,266.04125   L 167.97154,268.69814   L 172.83378,271.25736   L 177.71553,273.75797   L 182.61682,276.1609   L 187.5181,278.50522   L 192.43892,280.79093   L 197.37926,282.9985   L 202.3196,285.14746   L 207.25994,287.23781   L 212.2198,289.28909   L 217.17967,291.26222   L 222.13954,293.21582   L 227.0994,295.11082   L 232.05927,296.96674   L 236.99961,298.80312   L 241.93995,300.60043   L 246.89981,302.35867   L 251.82063,304.09738   L 256.74144,305.83608   L 266.54401,309.21581   L 276.288,312.576   L 270.21509,309.60653   L 264.0055,306.55891   L 260.84212,304.99603   L 257.67874,303.41362   L 254.49583,301.81166   L 251.2934,300.19018   L 248.09096,298.54915   L 244.869,296.86906   L 241.64704,295.18896   L 238.42508,293.46979   L 235.22265,291.75062   L 232.02021,289.99238   L 228.83731,288.23414   L 225.6544,286.45637   L 222.51055,284.63952   L 219.38622,282.82267   L 216.30095,280.96675   L 213.23521,279.11083   L 210.20852,277.23538   L 207.22088,275.34038   L 204.29183,273.42586   L 201.40183,271.49179   L 198.57041,269.53819   L 195.79757,267.56506   L 193.08331,265.59192   L 190.44716,263.59925   L 187.86959,261.5675   L 185.37013,259.5553   L 182.92925,257.50402   L 180.58601,255.4332   L 182.07006,255.10109   L 183.51506,254.74944   L 184.96006,254.39779   L 186.36601,254.02661   L 187.75243,253.65542   L 189.13885,253.2647   L 190.50574,252.87398   L 191.85311,252.46373   L 193.18094,252.03394   L 194.50878,251.60414   L 195.81709,251.15482   L 197.10588,250.70549   L 198.39466,250.23662   L 199.68345,249.74822   L 200.9527,249.24029   L 202.24149,248.73235   L 203.49122,248.18534   L 204.76048,247.63834   L 206.02973,247.07179   L 207.27946,246.48571   L 208.54872,245.89963   L 209.81798,245.27448   L 211.08723,244.62979   L 212.35649,243.96557   L 213.62575,243.30134   L 214.91453,242.59805   L 216.20332,241.87522   L 217.4921,241.13285   L 218.80041,240.37094   L 220.12825,239.5895   L 221.45609,238.76899   L 222.80345,237.94848   L 218.37082,235.8972   L 213.93818,233.7287   L 209.50554,231.48206   L 205.07291,229.11821   L 200.64027,226.67621   L 196.20763,224.15606   L 191.775,221.53824   L 187.36189,218.84227   L 182.94878,216.06816   L 178.5552,213.23544   L 174.18114,210.32458   L 169.82661,207.3551   L 165.49161,204.32702   L 161.17614,201.2208   L 156.88019,198.09504   L 152.6233,194.89114   L 148.38593,191.6677   L 144.18762,188.38565   L 140.02836,185.06453   L 135.90815,181.72387   L 131.827,178.36368   L 127.80444,174.96442   L 123.80139,171.54562   L 119.85693,168.10728   L 115.97105,164.64941   L 112.12423,161.19154   L 108.35551,157.73366   L 104.62585,154.25626   L 100.97429,150.79838   L 97.36179,147.34051   L 93.827397,143.90218   L 90.371112,140.46384   L 94.120302,140.3857   L 97.55706,140.30755   L 100.73997,140.19034   L 103.68855,140.07312   L 105.11402,139.99498   L 106.48091,139.91683   L 107.82828,139.81915   L 109.13659,139.72147   L 110.4449,139.62379   L 111.71416,139.50658   L 112.98342,139.36982   L 114.25267,139.23307   L 115.52193,139.07678   L 116.81072,138.90096   L 118.07997,138.72514   L 119.38828,138.52978   L 120.71612,138.31488   L 122.08301,138.08045   L 123.48896,137.84602   L 124.91443,137.57251   L 127.9216,136.98643   L 131.18261,136.32221   L 134.69748,135.57984   L 138.52478,134.73979   L 134.26788,132.04382   L 130.06957,129.25018   L 125.94937,126.33931   L 121.88774,123.33077   L 117.90423,120.20501   L 113.95977,116.96203   L 110.09342,113.62138   L 106.26612,110.1635   L 102.4974,106.60795   L 98.767737,102.95472   L 95.077127,99.203808   L 91.425572,95.355216   L 87.793544,91.408944   L 84.220096,87.345456   L 80.646649,83.203824   L 77.112256,78.984048   L 73.59739,74.647056   L 70.102051,70.251456   L 66.606712,65.73864   L 63.1309,61.14768   L 59.635561,56.478576   L 56.159749,51.731328   L 52.683937,46.905936   L 49.188598,41.982864   L 45.693259,37.001184   L 42.178393,31.921824   L 38.663527,26.783856   L 35.109607,21.567744   L 31.516632,16.273488   L 27.923658,10.920624   L 24.272103,5.489616   L 20.601021,0   L 22.124129,3.067152   L 24.135414,7.150176   L 26.59582,12.131856   L 29.446767,17.894976   L 31.028457,21.040272   L 32.688254,24.32232   L 34.42616,27.74112   L 36.222648,31.277136   L 38.11677,34.930368   L 40.049946,38.661744   L 42.061231,42.471264   L 44.111569,46.358928   L 46.220489,50.266128   L 48.368463,54.231936   L 50.55549,58.197744   L 52.762045,62.163552   L 55.007654,66.12936   L 57.27279,70.056096   L 59.557453,73.94376   L 61.842116,77.772816   L 64.146306,81.523728   L 66.450496,85.196496   L 68.735159,88.752048   L 71.019822,92.20992   L 73.284958,95.53104   L 75.530566,98.695872   L 77.737121,101.70442   L 79.924149,104.53714  z " id="path89"/>
			<path style="fill:#ffffff;fill-rule:nonzero;fill-opacity:1;stroke:none;" d="  M 17.164263,135.26726   L 45.205083,135.26726   L 49.30576,135.26726   L 49.30576,139.36982   L 49.30576,213.41126   L 49.30576,217.53336   L 45.205083,217.53336   L 17.164263,217.53336   L 13.044059,217.53336   L 13.044059,213.41126   L 13.044059,139.36982   L 13.044059,135.26726   L 17.164263,135.26726  z " id="path91"/>
			<path style="fill:#ffffff;fill-rule:nonzero;fill-opacity:1;stroke:none;" d="  M 83.243745,213.41126   L 83.243745,156.67872   L 61.432048,156.67872   L 57.311844,156.67872   L 57.311844,152.57616   L 57.311844,139.36982   L 57.311844,135.26726   L 61.432048,135.26726   L 139.57924,135.26726   L 143.69944,135.26726   L 143.69944,139.36982   L 143.69944,152.57616   L 143.69944,156.67872   L 139.57924,156.67872   L 119.50545,156.67872   L 119.50545,213.41126   L 119.50545,217.53336   L 115.40477,217.53336   L 87.363949,217.53336   L 83.243745,217.53336   L 83.243745,213.41126  z " id="path93"/>
			<path style="fill:#ffffff;fill-rule:nonzero;fill-opacity:1;stroke:none;" d="  M 164.94485,210.75437   L 164.22235,210.18782   L 163.53891,209.60174   L 162.85546,209.01566   L 162.21107,208.39051   L 161.5862,207.76536   L 160.98087,207.10114   L 160.39505,206.43691   L 159.8483,205.75315   L 159.30154,205.04986   L 158.79384,204.32702   L 158.30566,203.60419   L 157.83701,202.86182   L 157.38789,202.09992   L 156.9583,201.33802   L 156.54823,200.55658   L 156.17722,199.7556   L 155.8062,198.91555   L 155.45472,198.0755   L 155.12276,197.21592   L 154.82985,196.3368   L 154.55647,195.45768   L 154.30262,194.57856   L 154.0683,193.6799   L 153.87303,192.78125   L 153.69728,191.88259   L 153.54107,190.9644   L 153.40438,190.04621   L 153.30674,189.12802   L 153.22863,188.20982   L 153.17005,187.29163   L 153.131,186.3539   L 153.131,185.43571   L 153.131,139.36982   L 153.131,135.26726   L 157.23168,135.26726   L 182.83162,135.26726   L 186.95182,135.26726   L 186.95182,139.36982   L 186.97135,185.39664   L 186.97135,185.8655   L 187.0104,186.31483   L 187.04946,186.76416   L 187.12756,187.19395   L 187.20567,187.62374   L 187.32283,188.05354   L 187.44,188.46379   L 187.57669,188.85451   L 187.7329,189.24523   L 187.90865,189.61642   L 188.10392,189.96806   L 188.29919,190.33925   L 188.51398,190.67136   L 188.74831,191.00347   L 189.00216,191.33558   L 189.25601,191.64816   L 189.54892,191.9412   L 189.82229,192.23424   L 190.13473,192.52728   L 190.42763,192.78125   L 190.75959,193.05475   L 191.09155,193.28918   L 191.44304,193.54315   L 191.79453,193.75805   L 192.14601,193.99248   L 192.51703,194.18784   L 192.90757,194.3832   L 193.29811,194.57856   L 193.68865,194.75438   L 194.09872,194.91067   L 194.48926,195.06696   L 194.91885,195.20371   L 195.64135,195.43814   L 196.40291,195.6335   L 197.16446,195.78979   L 197.92601,195.92654   L 198.7071,196.02422   L 199.5077,196.10237   L 200.28878,196.16098   L 201.08939,196.16098   L 201.89,196.16098   L 202.69061,196.10237   L 203.47169,196.02422   L 204.25277,195.92654   L 205.03385,195.78979   L 205.79541,195.6335   L 206.53744,195.43814   L 207.27946,195.20371   L 207.68953,195.06696   L 208.0996,194.91067   L 208.50967,194.75438   L 208.90021,194.57856   L 209.29075,194.3832   L 209.68129,194.18784   L 210.0523,193.97294   L 210.40379,193.75805   L 210.75527,193.54315   L 211.10676,193.28918   L 211.43872,193.05475   L 211.77068,192.78125   L 212.08311,192.50774   L 212.37602,192.23424   L 212.66892,191.9412   L 212.9423,191.64816   L 213.19615,191.33558   L 213.45001,191.00347   L 213.68433,190.67136   L 213.89913,190.31971   L 214.11392,189.96806   L 214.28967,189.61642   L 214.46541,189.2257   L 214.62163,188.85451   L 214.75832,188.44426   L 214.89501,188.05354   L 214.99264,187.62374   L 215.09028,187.19395   L 215.14886,186.76416   L 215.20744,186.31483   L 215.22697,185.8655   L 215.24649,185.39664   L 215.16838,139.4089   L 215.16838,135.2868   L 219.28859,135.2868   L 244.88853,135.2868   L 248.98921,135.2868   L 248.98921,139.4089   L 248.98921,185.39664   L 248.98921,186.31483   L 248.95015,187.25256   L 248.89157,188.19029   L 248.81346,189.10848   L 248.6963,190.02667   L 248.55961,190.9644   L 248.4034,191.86306   L 248.22765,192.78125   L 248.03238,193.6799   L 247.79806,194.57856   L 247.54421,195.47722   L 247.27083,196.35634   L 246.97792,197.23546   L 246.64596,198.09504   L 246.29448,198.95462   L 245.92346,199.79467   L 245.55245,200.57611   L 245.14238,201.35755   L 244.73231,202.13899   L 244.28319,202.9009   L 243.81454,203.64326   L 243.32637,204.3661   L 242.79914,205.08893   L 242.27191,205.79222   L 241.70562,206.47598   L 241.13934,207.14021   L 240.534,207.80443   L 239.90914,208.42958   L 239.26474,209.05474   L 238.5813,209.64082   L 237.89785,210.2269   L 237.17535,210.79344   L 236.39427,211.35998   L 235.59366,211.90699   L 234.754,212.43446   L 233.87528,212.9424   L 232.95751,213.4308   L 232.03974,213.9192   L 231.06339,214.36853   L 230.08704,214.79832   L 229.05211,215.22811   L 228.01717,215.63837   L 226.96271,216.00955   L 225.8692,216.38074   L 224.75616,216.73238   L 223.62359,217.0645   L 222.4715,217.37707   L 221.3194,217.67011   L 220.12825,217.96315   L 218.91757,218.21712   L 217.7069,218.45155   L 216.4767,218.68598   L 215.24649,218.88134   L 213.99676,219.0767   L 212.72751,219.23299   L 211.45825,219.38928   L 210.16946,219.52603   L 208.88068,219.64325   L 207.5919,219.74093   L 206.30311,219.81907   L 204.9948,219.87768   L 203.68649,219.93629   L 202.37818,219.95582   L 201.06987,219.95582   L 199.76155,219.95582   L 198.45324,219.91675   L 197.16446,219.87768   L 195.85615,219.81907   L 194.54784,219.74093   L 193.25905,219.64325   L 191.97027,219.52603   L 190.68148,219.38928   L 189.41223,219.23299   L 188.14297,219.05717   L 186.89324,218.86181   L 185.66304,218.66645   L 184.43283,218.43202   L 183.20263,218.19758   L 182.01148,217.92408   L 180.82033,217.65058   L 179.64871,217.35754   L 178.49662,217.04496   L 177.36405,216.71285   L 176.27053,216.3612   L 175.17702,215.99002   L 174.10303,215.5993   L 173.0681,215.18904   L 172.05269,214.77878   L 171.05682,214.32946   L 170.09999,213.88013   L 169.16269,213.39173   L 168.24492,212.90333   L 167.36621,212.39539   L 166.52654,211.86792   L 165.72594,211.32091   L 164.94485,210.75437  z " id="path95"/>
			<path style="fill:#004086;fill-rule:evenodd;fill-opacity:1;stroke:none;" d="  M 167.42479,207.47232   L 166.78039,206.98392   L 166.17506,206.45645   L 165.58925,205.92898   L 165.00343,205.38197   L 164.45668,204.81542   L 163.92945,204.24888   L 163.42175,203.64326   L 162.93357,203.03765   L 162.46492,202.4125   L 162.0158,201.78734   L 161.5862,201.12312   L 161.17614,200.4589   L 160.7856,199.79467   L 160.41458,199.11091   L 160.08262,198.40762   L 159.75066,197.70432   L 159.43823,196.98149   L 159.14532,196.25866   L 158.89147,195.51629   L 158.63762,194.77392   L 158.42282,194.03155   L 158.20803,193.26965   L 158.01276,192.50774   L 157.85654,191.74584   L 157.70032,190.9644   L 157.58316,190.18296   L 157.466,189.40152   L 157.38789,188.62008   L 157.30978,187.8191   L 157.27073,187.01813   L 157.2512,186.23669   L 157.23168,185.43571   L 157.23168,139.36982   L 182.83162,139.36982   L 182.85114,185.39664   L 182.94878,187.19395   L 183.26121,188.87405   L 183.74939,190.45646   L 184.41331,191.90213   L 185.25297,193.25011   L 186.22932,194.46134   L 187.32283,195.5749   L 188.55304,196.57123   L 189.88088,197.43082   L 191.32588,198.19272   L 192.82946,198.83741   L 194.41115,199.34534   L 196.03189,199.7556   L 197.69169,200.04864   L 199.39054,200.22446   L 201.10892,200.28307   L 202.80777,200.22446   L 204.50662,200.04864   L 206.16642,199.7556   L 207.80669,199.34534   L 209.38838,198.81787   L 210.89196,198.19272   L 212.31744,197.43082   L 213.64528,196.5517   L 214.87548,195.5749   L 215.98852,194.46134   L 216.96487,193.23058   L 217.78501,191.90213   L 218.44893,190.45646   L 218.9371,188.87405   L 219.24953,187.19395   L 219.34717,185.39664   L 219.28859,139.4089   L 244.88853,139.4089   L 244.88853,185.39664   L 244.869,186.19762   L 244.84948,186.99859   L 244.79089,187.78003   L 244.73231,188.58101   L 244.63468,189.38198   L 244.53704,190.16342   L 244.40035,190.94486   L 244.26366,191.7263   L 244.08792,192.50774   L 243.89265,193.26965   L 243.69738,194.03155   L 243.46306,194.77392   L 243.22873,195.53582   L 242.95535,196.25866   L 242.66245,197.00102   L 242.36954,197.72386   L 242.03758,198.42715   L 241.6861,199.13045   L 241.31508,199.81421   L 240.92454,200.49797   L 240.534,201.16219   L 240.10441,201.80688   L 239.65528,202.45157   L 239.18664,203.07672   L 238.69846,203.68234   L 238.19076,204.28795   L 237.66353,204.8545   L 237.09724,205.42104   L 236.53096,205.96805   L 235.94515,206.49552   L 235.33981,207.02299   L 234.69542,207.51139   L 233.25042,208.52726   L 231.68826,209.46499   L 229.9894,210.34411   L 228.19292,211.16462   L 226.27927,211.90699   L 224.28751,212.59075   L 222.19812,213.2159   L 220.05014,213.78245   L 217.82406,214.27085   L 215.5394,214.6811   L 213.19615,215.03275   L 210.81386,215.32579   L 208.41203,215.56022   L 205.97115,215.71651   L 203.51075,215.81419   L 201.05034,215.85326   L 198.58993,215.81419   L 196.14905,215.71651   L 193.70817,215.56022   L 191.28682,215.32579   L 188.92405,215.03275   L 186.58081,214.66157   L 184.29614,214.23178   L 182.07006,213.74338   L 179.92209,213.19637   L 177.8327,212.57122   L 175.84094,211.88746   L 173.92729,211.12555   L 172.1308,210.30504   L 170.43195,209.42592   L 168.86979,208.48819   L 167.42479,207.47232  z    M 87.363949,152.57616   L 87.363949,213.41126   L 115.40477,213.41126   L 115.40477,152.57616   L 139.57924,152.57616   L 139.57924,139.36982   L 61.432048,139.36982   L 61.432048,152.57616   L 87.363949,152.57616  z    M 17.164263,139.36982   L 45.205083,139.36982   L 45.205083,213.41126   L 17.164263,213.41126   L 17.164263,139.36982  z   " id="path97"/>
		</svg>
	</xsl:variable>
	
	<!-- convert YYYY-MM-DD to (MM/YYYY) -->
	<xsl:template name="formatDate">
		<xsl:param name="date"/>
		<xsl:variable name="year" select="substring($date, 1, 4)"/>
		<xsl:variable name="month" select="substring($date, 6, 2)"/>
		<xsl:if test="$month != '' and $year != ''">
			<xsl:value-of select="$LRM"/><xsl:text>(</xsl:text><xsl:value-of select="$month"/>/<xsl:value-of select="$year"/><xsl:text>)</xsl:text><xsl:value-of select="$LRM"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="formatMeetingDate">
		<xsl:param name="date"/>
		<xsl:variable name="year" select="substring($date, 1, 4)"/>
		<xsl:variable name="month" select="substring($date, 6, 2)"/>
		<xsl:variable name="day" select="substring($date, 9)"/>
		
		<xsl:variable name="monthStr">
			<xsl:choose>
				<xsl:when test="$month = '01'">Jan</xsl:when>
				<xsl:when test="$month = '02'">Feb</xsl:when>
				<xsl:when test="$month = '03'">Mar</xsl:when>
				<xsl:when test="$month = '04'">Apr</xsl:when>
				<xsl:when test="$month = '05'">May</xsl:when>
				<xsl:when test="$month = '06'">Jun</xsl:when>
				<xsl:when test="$month = '07'">Jul</xsl:when>
				<xsl:when test="$month = '08'">Aug</xsl:when>
				<xsl:when test="$month = '09'">Sep</xsl:when>
				<xsl:when test="$month = '10'">Oct</xsl:when>
				<xsl:when test="$month = '11'">Nov</xsl:when>
				<xsl:when test="$month = '12'">Dec</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:value-of select="$day"/><xsl:text> </xsl:text><xsl:value-of select="$monthStr"/><xsl:text> </xsl:text><xsl:value-of select="$year"/>
		
	</xsl:template>
	

	<xsl:template name="addLetterSpacing">
		<xsl:param name="text"/>
		<xsl:if test="string-length($text) &gt; 0">
			<xsl:variable name="char" select="substring($text, 1, 1)"/>
			<xsl:value-of select="$char"/><fo:inline font-size="15pt"><xsl:value-of select="' '"/></fo:inline>
			<xsl:call-template name="addLetterSpacing">
				<xsl:with-param name="text" select="substring($text, 2)"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
<xsl:param name="svg_images"/><xsl:variable name="images" select="document($svg_images)"/><xsl:param name="basepath"/><xsl:param name="external_index"/><xsl:param name="syntax-highlight">false</xsl:param><xsl:param name="add_math_as_text">true</xsl:param><xsl:param name="table_if">false</xsl:param><xsl:param name="table_widths"/><xsl:variable name="table_widths_from_if" select="xalan:nodeset($table_widths)"/><xsl:variable name="table_widths_from_if_calculated_">
		<xsl:for-each select="$table_widths_from_if//table">
			<xsl:copy>
				<xsl:copy-of select="@*"/>
				<xsl:call-template name="calculate-column-widths-autolayout-algorithm"/>
			</xsl:copy>
		</xsl:for-each>
	</xsl:variable><xsl:variable name="table_widths_from_if_calculated" select="xalan:nodeset($table_widths_from_if_calculated_)"/><xsl:param name="table_if_debug">false</xsl:param><xsl:variable name="isGenerateTableIF_">
		false
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
		20
	</xsl:variable><xsl:variable name="marginLeftRight1" select="normalize-space($marginLeftRight1_)"/><xsl:variable name="marginLeftRight2_">
		20
	</xsl:variable><xsl:variable name="marginLeftRight2" select="normalize-space($marginLeftRight2_)"/><xsl:variable name="marginTop_">
		20
	</xsl:variable><xsl:variable name="marginTop" select="normalize-space($marginTop_)"/><xsl:variable name="marginBottom_">
		20
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
			
			
			
		</title-part>
		<title-part lang="fr">
			
			
			
		</title-part>
		<title-part lang="ru">
			
			
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
		
		
		
		
		
		
		
		
		
		
			<xsl:attribute name="font-family">Times New Roman, STIX Two Math, <xsl:value-of select="$font_noto_serif"/></xsl:attribute>
			<xsl:attribute name="font-family-generic">Serif</xsl:attribute>
			<xsl:attribute name="font-size">12pt</xsl:attribute>
		
		
		
		
		
		
		
		
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
			<xsl:attribute name="margin-top">6pt</xsl:attribute>
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="license-statement-p-style">
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="legal-statement-style">
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="legal-statement-title-style">
		<xsl:attribute name="keep-with-next">always</xsl:attribute>
		
			<xsl:attribute name="text-align">center</xsl:attribute>
			<xsl:attribute name="margin-top">6pt</xsl:attribute>
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="legal-statement-p-style">
		
	</xsl:attribute-set><xsl:attribute-set name="feedback-statement-style">
		
		
	</xsl:attribute-set><xsl:attribute-set name="feedback-statement-title-style">
		<xsl:attribute name="keep-with-next">always</xsl:attribute>
		
	</xsl:attribute-set><xsl:attribute-set name="feedback-statement-p-style">
		
		
	</xsl:attribute-set><xsl:attribute-set name="link-style">
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="sourcecode-container-style">
		
	</xsl:attribute-set><xsl:attribute-set name="sourcecode-style">
		<xsl:attribute name="white-space">pre</xsl:attribute>
		<xsl:attribute name="wrap-option">wrap</xsl:attribute>
		<xsl:attribute name="role">Code</xsl:attribute>
		
		
		
		
		
		
		
		
		
		
			<xsl:attribute name="font-family">Courier New, <xsl:value-of select="$font_noto_sans_mono"/></xsl:attribute>			
			<xsl:attribute name="margin-top">6pt</xsl:attribute>
			<xsl:attribute name="margin-bottom">6pt</xsl:attribute>
		
		
				
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="permission-style">
		
	</xsl:attribute-set><xsl:attribute-set name="permission-name-style">
		
	</xsl:attribute-set><xsl:attribute-set name="permission-label-style">
		
	</xsl:attribute-set><xsl:attribute-set name="requirement-style">
		
		
	</xsl:attribute-set><xsl:attribute-set name="requirement-name-style">
		<xsl:attribute name="keep-with-next">always</xsl:attribute>
		
		
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
		
		
		
		
		
		
		

	</xsl:attribute-set><xsl:attribute-set name="example-style">
		
		
		
		
		
		
		
			<xsl:attribute name="font-size">10pt</xsl:attribute>
			<xsl:attribute name="margin-top">12pt</xsl:attribute>			
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="example-body-style">
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="example-name-style">
		
		
		
		
		
		
		
		
			<xsl:attribute name="keep-with-next">always</xsl:attribute>
			<xsl:attribute name="font-weight">bold</xsl:attribute>
		
		
		
		
		
		
				
				
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="example-p-style">
		
		
		
		
		
		
		
		
			<xsl:attribute name="font-size">10pt</xsl:attribute>
			<xsl:attribute name="margin-top">12pt</xsl:attribute>
			<xsl:attribute name="margin-bottom">12pt</xsl:attribute>
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="termexample-name-style">
		
		
		
		
				
				
	</xsl:attribute-set><xsl:variable name="table-border_">
		
		
	</xsl:variable><xsl:variable name="table-border" select="normalize-space($table-border_)"/><xsl:attribute-set name="table-container-style">
		<xsl:attribute name="margin-left">0mm</xsl:attribute>
		<xsl:attribute name="margin-right">0mm</xsl:attribute>
		
		
		
		
		
		
		
		
		
		
		
			<xsl:attribute name="font-size">10pt</xsl:attribute>
			<xsl:attribute name="space-after">18pt</xsl:attribute>
		
		
		
		
		
		
		
		
		
					
		
		
	</xsl:attribute-set><xsl:attribute-set name="table-style">
		<xsl:attribute name="table-omit-footer-at-break">true</xsl:attribute>
		<xsl:attribute name="table-layout">fixed</xsl:attribute>
		<xsl:attribute name="margin-left">0mm</xsl:attribute>
		<xsl:attribute name="margin-right">0mm</xsl:attribute>
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="table-name-style">
		<xsl:attribute name="keep-with-next">always</xsl:attribute>
			
		
			<xsl:attribute name="font-weight">bold</xsl:attribute>
			<xsl:attribute name="text-align">center</xsl:attribute>
			<xsl:attribute name="margin-bottom">6pt</xsl:attribute>
		
		
		
				
		
				
		
		
		
				
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="table-row-style">
		<xsl:attribute name="min-height">4mm</xsl:attribute>
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="table-header-row-style" use-attribute-sets="table-row-style">
		<xsl:attribute name="font-weight">bold</xsl:attribute>
		
		
		
		
		
		
		
				
		
	</xsl:attribute-set><xsl:attribute-set name="table-footer-row-style" use-attribute-sets="table-row-style">
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="table-body-row-style" use-attribute-sets="table-row-style">

	</xsl:attribute-set><xsl:attribute-set name="table-header-cell-style">
		<xsl:attribute name="font-weight">bold</xsl:attribute>
		<xsl:attribute name="border">solid black 1pt</xsl:attribute>
		<xsl:attribute name="padding-left">1mm</xsl:attribute>
		<xsl:attribute name="padding-right">1mm</xsl:attribute>
		<xsl:attribute name="display-align">center</xsl:attribute>
		
		
		
		
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="table-cell-style">
		<xsl:attribute name="display-align">center</xsl:attribute>
		<xsl:attribute name="border">solid black 1pt</xsl:attribute>
		<xsl:attribute name="padding-left">1mm</xsl:attribute>
		<xsl:attribute name="padding-right">1mm</xsl:attribute>
		
		
		
		
		
		
		
		
			<xsl:attribute name="display-align">before</xsl:attribute>
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="table-footer-cell-style">
		<xsl:attribute name="border">solid black 1pt</xsl:attribute>
		<xsl:attribute name="padding-left">1mm</xsl:attribute>
		<xsl:attribute name="padding-right">1mm</xsl:attribute>
		<xsl:attribute name="padding-top">1mm</xsl:attribute>
		
		
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="table-note-style">
		<xsl:attribute name="font-size">10pt</xsl:attribute>
		<xsl:attribute name="margin-bottom">12pt</xsl:attribute>
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="table-fn-style">
		<xsl:attribute name="margin-bottom">12pt</xsl:attribute>
		
		
		
		
		
		
		
		
			<xsl:attribute name="margin-bottom">2pt</xsl:attribute>
			<xsl:attribute name="line-height-shift-adjustment">disregard-shifts</xsl:attribute>
			<xsl:attribute name="text-indent">-5mm</xsl:attribute>
			<xsl:attribute name="start-indent">5mm</xsl:attribute>
		
	</xsl:attribute-set><xsl:attribute-set name="table-fn-number-style">
		<xsl:attribute name="font-size">80%</xsl:attribute>
		<xsl:attribute name="padding-right">5mm</xsl:attribute>
		
		
		
		
		
		
		
		
		
			<xsl:attribute name="vertical-align">super</xsl:attribute>
			<xsl:attribute name="padding-right">3mm</xsl:attribute>
			<xsl:attribute name="font-size">70%</xsl:attribute>
		
		
		
		
		
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
		
		
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="dl-name-style">
		<xsl:attribute name="keep-with-next">always</xsl:attribute>
		<xsl:attribute name="margin-bottom">6pt</xsl:attribute>
			
		
			<xsl:attribute name="font-weight">bold</xsl:attribute>
		
		
		
		
		
				
		
		
		
				
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="dd-cell-style">
		<xsl:attribute name="padding-left">2mm</xsl:attribute>
	</xsl:attribute-set><xsl:attribute-set name="appendix-style">
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="appendix-example-style">
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="xref-style">
		
		
		
			<xsl:attribute name="color">blue</xsl:attribute>
			<xsl:attribute name="text-decoration">underline</xsl:attribute>
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="eref-style">
		
		
		
			<xsl:attribute name="color">blue</xsl:attribute>
			<xsl:attribute name="text-decoration">underline</xsl:attribute>
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="note-style">
		
		
		
		
				
				
		
		
		
			<xsl:attribute name="font-size">11pt</xsl:attribute>
			<xsl:attribute name="space-before">4pt</xsl:attribute>
			<xsl:attribute name="text-align">justify</xsl:attribute>		
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:variable name="note-body-indent">10mm</xsl:variable><xsl:variable name="note-body-indent-table">5mm</xsl:variable><xsl:attribute-set name="note-name-style">
		
		
		
		
		
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="table-note-name-style">
		<xsl:attribute name="padding-right">2mm</xsl:attribute>
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="note-p-style">
		
		
		
		
		
		
		
					
			<xsl:attribute name="space-before">4pt</xsl:attribute>			
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="termnote-style">
		
		
				
		
		
					
			<xsl:attribute name="margin-top">4pt</xsl:attribute>			
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="termnote-name-style">
		
				
		
		
	</xsl:attribute-set><xsl:attribute-set name="termnote-p-style">
		
	</xsl:attribute-set><xsl:attribute-set name="quote-style">
		<xsl:attribute name="margin-left">12mm</xsl:attribute>
		<xsl:attribute name="margin-right">12mm</xsl:attribute>
		
		
		
		
		
		
			<xsl:attribute name="margin-top">6pt</xsl:attribute>
		
		
	</xsl:attribute-set><xsl:attribute-set name="quote-source-style">		
		<xsl:attribute name="text-align">right</xsl:attribute>
		
				
	</xsl:attribute-set><xsl:attribute-set name="termsource-style">
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="termsource-text-style">
		
		
	</xsl:attribute-set><xsl:attribute-set name="origin-style">
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="term-style">
		
	</xsl:attribute-set><xsl:attribute-set name="term-name-style">
		<xsl:attribute name="keep-with-next">always</xsl:attribute>
		<xsl:attribute name="font-weight">bold</xsl:attribute>
	</xsl:attribute-set><xsl:attribute-set name="figure-style">
		
	</xsl:attribute-set><xsl:attribute-set name="figure-name-style">
		
		
		
				
		
		
		
		
		
		
					
			<xsl:attribute name="font-weight">bold</xsl:attribute>
			<xsl:attribute name="text-align">center</xsl:attribute>
			<xsl:attribute name="margin-top">6pt</xsl:attribute>
			<xsl:attribute name="margin-bottom">6pt</xsl:attribute>
			<xsl:attribute name="keep-with-previous">always</xsl:attribute>
		
		
		
		
		
		

		
		
		
			
	</xsl:attribute-set><xsl:attribute-set name="formula-style">
		<xsl:attribute name="margin-top">6pt</xsl:attribute>
		<xsl:attribute name="margin-bottom">12pt</xsl:attribute>
		
		
		
			<xsl:attribute name="margin-bottom">6pt</xsl:attribute>
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="formula-stem-block-style">
		<xsl:attribute name="text-align">center</xsl:attribute>
		
		
		
		
		
		
		
			<xsl:attribute name="margin-left">0mm</xsl:attribute>
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="formula-stem-number-style">
		<xsl:attribute name="text-align">right</xsl:attribute>
		
		
		
			<xsl:attribute name="margin-left">0mm</xsl:attribute>
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="image-style">
		<xsl:attribute name="text-align">center</xsl:attribute>
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="figure-pseudocode-p-style">
		
			<xsl:attribute name="font-size">10pt</xsl:attribute>
			<xsl:attribute name="margin-top">6pt</xsl:attribute>
			<xsl:attribute name="margin-bottom">6pt</xsl:attribute>
		
	</xsl:attribute-set><xsl:attribute-set name="image-graphic-style">
		<xsl:attribute name="width">100%</xsl:attribute>
		<xsl:attribute name="content-height">100%</xsl:attribute>
		<xsl:attribute name="scaling">uniform</xsl:attribute>			
		
		
		
		
		
			<xsl:attribute name="width">75%</xsl:attribute>
			<xsl:attribute name="content-width">scale-to-fit</xsl:attribute>
		
	</xsl:attribute-set><xsl:attribute-set name="tt-style">
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="sourcecode-name-style">
		<xsl:attribute name="font-size">11pt</xsl:attribute>
		<xsl:attribute name="font-weight">bold</xsl:attribute>
		<xsl:attribute name="text-align">center</xsl:attribute>
		<xsl:attribute name="margin-bottom">12pt</xsl:attribute>
		<xsl:attribute name="keep-with-previous">always</xsl:attribute>
		
	</xsl:attribute-set><xsl:attribute-set name="preferred-block-style">
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="preferred-term-style">
		<xsl:attribute name="keep-with-next">always</xsl:attribute>
		<xsl:attribute name="font-weight">bold</xsl:attribute>
		
		
	</xsl:attribute-set><xsl:attribute-set name="domain-style">
				
	</xsl:attribute-set><xsl:attribute-set name="admitted-style">
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="deprecates-style">
		
		
	</xsl:attribute-set><xsl:attribute-set name="definition-style">
		
		
		
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
		
		
			<xsl:attribute name="font-size">11pt</xsl:attribute>
		
	</xsl:attribute-set><xsl:attribute-set name="list-style">
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="list-name-style">
		<xsl:attribute name="keep-with-next">always</xsl:attribute>
			
		
			<xsl:attribute name="font-weight">bold</xsl:attribute>
		
		
		
		
				
		
		
		
				
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="list-item-style">
		
		
	</xsl:attribute-set><xsl:attribute-set name="list-item-label-style">
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="list-item-body-style">
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="toc-style">
		<xsl:attribute name="line-height">135%</xsl:attribute>
	</xsl:attribute-set><xsl:attribute-set name="fn-reference-style">
		<xsl:attribute name="font-size">80%</xsl:attribute>
		<xsl:attribute name="keep-with-previous.within-line">always</xsl:attribute>
		
		
		
			<xsl:attribute name="vertical-align">super</xsl:attribute>
			<xsl:attribute name="color">blue</xsl:attribute>
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="fn-style">
		<xsl:attribute name="keep-with-previous.within-line">always</xsl:attribute>
	</xsl:attribute-set><xsl:attribute-set name="fn-num-style">
		<xsl:attribute name="keep-with-previous.within-line">always</xsl:attribute>
		
		
		
		
		
		
		
		
		
		
			<xsl:attribute name="font-size">60%</xsl:attribute>
			<xsl:attribute name="vertical-align">super</xsl:attribute>
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="fn-body-style">
		<xsl:attribute name="font-weight">normal</xsl:attribute>
		<xsl:attribute name="font-style">normal</xsl:attribute>
		<xsl:attribute name="text-indent">0</xsl:attribute>
		<xsl:attribute name="start-indent">0</xsl:attribute>
		
		
		
		
		
		
		
		
		
		
			<xsl:attribute name="font-size">11pt</xsl:attribute>
			<xsl:attribute name="margin-bottom">12pt</xsl:attribute>
			<xsl:attribute name="text-align">justify</xsl:attribute>
		
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="fn-body-num-style">
		<xsl:attribute name="keep-with-next.within-line">always</xsl:attribute>
		
		
		
		
		
		
		
		
		
		
			<xsl:attribute name="font-size">85%</xsl:attribute>
			<xsl:attribute name="padding-right">2mm</xsl:attribute>
			<xsl:attribute name="baseline-shift">30%</xsl:attribute>
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="admonition-style">
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="admonition-container-style">
		<xsl:attribute name="margin-left">0mm</xsl:attribute>
		<xsl:attribute name="margin-right">0mm</xsl:attribute>
		
		
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="admonition-name-style">
		<xsl:attribute name="keep-with-next">always</xsl:attribute>
		
		
		
		
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="admonition-p-style">
		
		
		
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="bibitem-normative-style">
		
		
		
		
		
		
		
		
		
			<xsl:attribute name="margin-top">6pt</xsl:attribute>
			<xsl:attribute name="margin-left">14mm</xsl:attribute>
			<xsl:attribute name="text-indent">-14mm</xsl:attribute>
		
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="bibitem-normative-list-style">
		<xsl:attribute name="provisional-distance-between-starts">12mm</xsl:attribute>
		<xsl:attribute name="margin-bottom">12pt</xsl:attribute>
		
		
		
		
		<!-- <xsl:if test="$namespace = 'ieee'">
			<xsl:attribute name="margin-bottom">6pt</xsl:attribute>
			<xsl:attribute name="provisional-distance-between-starts">9.5mm</xsl:attribute>
		</xsl:if> -->
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="bibitem-non-normative-style">
		
		
		
			<xsl:attribute name="margin-top">6pt</xsl:attribute>
			<xsl:attribute name="margin-left">14mm</xsl:attribute>
			<xsl:attribute name="text-indent">-14mm</xsl:attribute>
		
		
	</xsl:attribute-set><xsl:attribute-set name="bibitem-non-normative-list-style">
		<xsl:attribute name="provisional-distance-between-starts">12mm</xsl:attribute>
		<xsl:attribute name="margin-bottom">12pt</xsl:attribute>
		
		
		
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="bibitem-normative-list-body-style">
		
		
		
			<xsl:attribute name="margin-top">6pt</xsl:attribute>
			<xsl:attribute name="margin-left">14mm</xsl:attribute>
			<xsl:attribute name="text-indent">-14mm</xsl:attribute>
		
	</xsl:attribute-set><xsl:attribute-set name="bibitem-non-normative-list-body-style">
		
		
		
			<xsl:attribute name="margin-top">6pt</xsl:attribute>
			<xsl:attribute name="margin-left">14mm</xsl:attribute>
			<xsl:attribute name="text-indent">-14mm</xsl:attribute>
		
		
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
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="indexsect-clause-title-style">
		<xsl:attribute name="keep-with-next">always</xsl:attribute>
		
		
		
		
		
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
		
				<xsl:variable name="regex_standard_reference">([A-Z]{2,}(/[A-Z]{2,})* \d+(-\d+)*(:\d{4})?)</xsl:variable>
				<xsl:variable name="text" select="java:replaceAll(java:java.lang.String.new(.),$regex_standard_reference,concat($tag_fo_inline_keep-together_within-line_open,'$1',$tag_fo_inline_keep-together_within-line_close))"/>
				<xsl:call-template name="replace_fo_inline_tags">
					<xsl:with-param name="tag_open" select="$tag_fo_inline_keep-together_within-line_open"/>
					<xsl:with-param name="tag_close" select="$tag_fo_inline_keep-together_within-line_close"/>
					<xsl:with-param name="text" select="$text"/>
				</xsl:call-template>
			
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
		
				<!-- process in the template 'paragraph' -->
				<xsl:call-template name="paragraph"/>
			
	</xsl:template><xsl:template match="*[local-name()='legal-statement']">
		<fo:block xsl:use-attribute-sets="legal-statement-style">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template><xsl:template match="*[local-name()='legal-statement']//*[local-name()='title']">
		
				<!-- ogc-white-paper rsd -->
				<xsl:variable name="level">
					<xsl:call-template name="getLevel"/>
				</xsl:variable>
				<fo:block role="H{$level}" xsl:use-attribute-sets="legal-statement-title-style">
					<xsl:apply-templates/>
				</fo:block>
			
	
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
			
				<xsl:if test="$doctype != 'service-publication'">
					<fo:block space-before="18pt"> </fo:block>
				</xsl:if>
			
			
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
			
					<xsl:apply-templates select="*[local-name()='name']"/> <!-- table's title rendered before table -->
				
			
			
					<xsl:call-template name="table_name_fn_display"/>
				
			
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
			
				
			
				
			
				
			
				
				
				
				
				
					<xsl:if test="$doctype = 'service-publication' and $lang != 'ar'">
						<xsl:attribute name="font-family">Calibri</xsl:attribute>
					</xsl:if>
				
			
				
				
				
				
				
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
						
						
						
						
						
						
						
						
						
						
						
						
							<xsl:if test="$doctype = 'service-publication'">
								<xsl:attribute name="border">1pt solid rgb(211,211,211)</xsl:attribute>
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
		
				<xsl:call-template name="calculate-column-widths-proportional">
					<xsl:with-param name="cols-count" select="$cols-count"/>
					<xsl:with-param name="table" select="$table"/>
				</xsl:call-template>
			
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
					
					
						<xsl:if test="$doctype = 'service-publication'">
							<xsl:attribute name="border">none</xsl:attribute>
							<xsl:attribute name="font-family">Arial</xsl:attribute>
							<xsl:attribute name="font-size">8pt</xsl:attribute>
						</xsl:if>
					
					
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
								
								

								
									<xsl:if test="ancestor::*[local-name()='preface']">
										<xsl:if test="$doctype != 'service-publication'">
											<xsl:attribute name="border">solid black 0pt</xsl:attribute>
										</xsl:if>
									</xsl:if>
									<xsl:if test="$doctype = 'service-publication'">
										<xsl:attribute name="border">none</xsl:attribute>
									</xsl:if>
								
								
								<!-- fn will be processed inside 'note' processing -->
								
								
								
								
								
									<xsl:if test="$doctype = 'service-publication'">
										<fo:block margin-top="7pt" margin-bottom="2pt"><fo:inline>____________</fo:inline></fo:block>
									</xsl:if>
								
								
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
		
		
		
		<xsl:apply-templates select="../*[local-name()='thead']">
			<xsl:with-param name="cols-count" select="$cols-count"/>
		</xsl:apply-templates>
		
		<xsl:call-template name="insertTableFooter">
			<xsl:with-param name="cols-count" select="$cols-count"/>
		</xsl:call-template>
		
		<fo:table-body>
			

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
		
			
			
			


			

			
				<xsl:if test="$doctype = 'service-publication'">
					<xsl:attribute name="border-bottom">1.1pt solid black</xsl:attribute>
				</xsl:if>
			
			
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
	
		
	
		

		
			<xsl:if test="$doctype = 'service-publication'">
				<xsl:attribute name="min-height">5mm</xsl:attribute>
			</xsl:if>
		
		
		
	</xsl:template><xsl:template match="*[local-name()='th']">
		<fo:table-cell xsl:use-attribute-sets="table-header-cell-style"> <!-- text-align="{@align}" -->
			<xsl:call-template name="setTextAlignment">
				<xsl:with-param name="default">center</xsl:with-param>
			</xsl:call-template>
			
			
			
			

			
			
				<xsl:if test="ancestor::*[local-name()='preface']">
					<xsl:if test="$doctype != 'service-publication'">
						<xsl:attribute name="border">solid black 0pt</xsl:attribute>
					</xsl:if>
				</xsl:if>
				<xsl:if test="$doctype = 'service-publication'">
					<xsl:attribute name="border">1pt solid rgb(211,211,211)</xsl:attribute>
					<xsl:attribute name="border-bottom">1pt solid black</xsl:attribute>
					<xsl:attribute name="padding-top">1mm</xsl:attribute>
				</xsl:if>
			
			
			
			
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
			
			
			
			
			
			
			
			
			
			
				<xsl:if test="ancestor::*[local-name()='preface']">
					<xsl:attribute name="border">solid black 0pt</xsl:attribute>
				</xsl:if>
				<xsl:if test="$doctype = 'service-publication'">
					<xsl:attribute name="border">1pt solid rgb(211,211,211)</xsl:attribute>
					<xsl:attribute name="padding-top">1mm</xsl:attribute>
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
								
								
								
									<xsl:if test="$doctype = 'service-publication'">
										<xsl:attribute name="font-size">10pt</xsl:attribute>
									</xsl:if>
								
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
						
						
						
						
						
						
							<xsl:text>)</xsl:text>
						
						
					</fo:inline>
					<fo:inline xsl:use-attribute-sets="table-fn-body-style">
						<xsl:copy-of select="./node()"/>
					</fo:inline>
				</fo:block>
			</xsl:if>
		</xsl:for-each>
	</xsl:template><xsl:template name="create_fn">
		<fn reference="{@reference}" id="{@reference}_{ancestor::*[@id][1]/@id}">
			
				<xsl:if test="ancestor::*[local-name()='preface']">
					<xsl:attribute name="preface">true</xsl:attribute>
				</xsl:if>
			
			
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
					 <!-- and  (not(../@class) or ../@class !='pseudocode') -->
				</xsl:variable>
				
				<xsl:variable name="onlyOneComponent" select="normalize-space($parent = 'formula' and count(*[local-name()='dt']) = 1)"/>
				
				<xsl:choose>
					<xsl:when test="$onlyOneComponent = 'true'"> <!-- only one component -->
						
								<fo:block margin-bottom="12pt" text-align="left">
									
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
							<xsl:value-of select="$title-where"/>:
						</fo:block>
					</xsl:when>  <!-- END: a few components -->
					<xsl:when test="$parent = 'figure' and  (not(../@class) or ../@class !='pseudocode')"> <!-- definition list in a figure -->
						<fo:block font-weight="bold" text-align="left" margin-bottom="12pt" keep-with-next="always">
							
							
							
							
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
						
						
							<xsl:if test="$parent = 'figure' or $parent = 'formula'">
								<xsl:attribute name="margin-left">7.4mm</xsl:attribute>
							</xsl:if>
						
						
						
						
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
											false
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
			
			
				<xsl:if test="ancestor::*[1][local-name() = 'dl']/preceding-sibling::*[1][local-name() = 'formula']">						
					<xsl:attribute name="padding-right">3mm</xsl:attribute>
				</xsl:if>
			
			<fo:block xsl:use-attribute-sets="dt-block-style">
				<xsl:copy-of select="@id"/>
				
				<xsl:if test="normalize-space($key_iso) = 'true'">
					<xsl:attribute name="margin-top">0</xsl:attribute>
				</xsl:if>
				
				
					<xsl:if test="ancestor::*[1][local-name() = 'dl']/preceding-sibling::*[1][local-name() = 'formula']">
						<xsl:attribute name="text-align">right</xsl:attribute>							
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
			
				
					<xsl:attribute name="text-align">justify</xsl:attribute>
				

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
				
				
				
				
				
				 <!-- 10 -->
				
				
				
				
				
				
				
				
				
						
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
							
							
						
							
								<xsl:if test="ancestor::itu:figure">
									<xsl:attribute name="keep-with-previous">always</xsl:attribute>
								</xsl:if>
							
							
							
							
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
					
					
									
						<xsl:text> – </xsl:text>
					
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
					
					
									
						<xsl:text> – </xsl:text>
					
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
					<image xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="{$src}" style="overflow:visible;"/>
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
					<image xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="{$src}" style="overflow:visible;"/>
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
					<image xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="{@src}" height="{$height}" width="{$width}" style="overflow:visible;"/>
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
						
												
						
						
						
						<!-- 9 -->
						
						
						<!-- <xsl:if test="$namespace = 'ieee'">							
							<xsl:if test="$doctype = 'standard' and $stage = 'published'">8</xsl:if>
						</xsl:if> -->
						10
								
						
						
						
												
						
								
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
				block
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
					<xsl:when test="$depth = 5">7</xsl:when>
					<xsl:when test="$depth = 4">10</xsl:when>
					<xsl:when test="$depth = 3">6</xsl:when>
					<xsl:when test="$depth = 2">9</xsl:when>
					<xsl:otherwise>12</xsl:otherwise>
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
			
			
			
			
			
				<xsl:if test="*[1][@class='supertitle']">
					<xsl:attribute name="space-before">36pt</xsl:attribute>
				</xsl:if>
				<xsl:if test="@inline-header='true'">
					<xsl:attribute name="text-align">justify</xsl:attribute>
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
			
			
			
				<xsl:if test="@inline-header='true'">
					<xsl:attribute name="text-align">justify</xsl:attribute>
				</xsl:if>
			
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
		
				<label level="1">–</label>
				<label level="2">•</label>
				<label level="3" font-size="75%">o</label> <!-- white circle -->
			
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
		
		
				<fo:block id="{@id}" xsl:use-attribute-sets="bibitem-non-normative-style">
					<xsl:call-template name="processBibitem"/>
				</fo:block>
			
		
	</xsl:template><xsl:template name="processBibitem">
		
		
			
				<!-- Example: [ITU-T A.23]	ITU-T A.23, Recommendation ITU-T A.23, Annex A (2014), Guide for ITU-T and ISO/IEC JTC 1 cooperation. -->
				<xsl:if test="$doctype = 'implementers-guide'">
					<xsl:attribute name="margin-left">0mm</xsl:attribute>
					<xsl:attribute name="text-indent">0mm</xsl:attribute>
				</xsl:if>
				
				<xsl:variable name="bibitem_label">
					<xsl:value-of select="itu:docidentifier[@type = 'metanorma']"/>
					<xsl:if test="not(itu:docidentifier[@type = 'metanorma'])">
						<fo:inline padding-right="5mm">
							<xsl:text>[</xsl:text>
								<xsl:value-of select="itu:docidentifier[not(@type = 'metanorma-ordinal')]"/>
							<xsl:text>] </xsl:text>
						</fo:inline>
					</xsl:if>
				</xsl:variable>
				
				<xsl:variable name="bibitem_body">
					<xsl:text> </xsl:text>
					<xsl:choose>
						<xsl:when test="itu:docidentifier[@type = 'metanorma']">
							<xsl:value-of select="itu:docidentifier[not(@type) or not(@type = 'metanorma' or @type = 'metanorma-ordinal')]"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="itu:docidentifier[not(@type = 'metanorma-ordinal')]"/>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:if test="itu:formattedref and not(itu:docidentifier[@type = 'metanorma'])">, </xsl:if>
					<xsl:apply-templates select="itu:formattedref"/>
				</xsl:variable>
				
				<xsl:choose>
					<xsl:when test="$doctype = 'implementers-guide'">
						<fo:table width="100%" table-layout="fixed">
							<fo:table-column column-width="20%"/>
							<fo:table-column column-width="80%"/>
							<fo:table-body>
								<fo:table-row>
									<fo:table-cell><fo:block><xsl:copy-of select="$bibitem_label"/></fo:block></fo:table-cell>
									<fo:table-cell><fo:block><xsl:copy-of select="$bibitem_body"/></fo:block></fo:table-cell>
								</fo:table-row>
							</fo:table-body>
						</fo:table>
					</xsl:when> <!-- $doctype = 'implementers-guide' -->
					<xsl:otherwise>
						<xsl:copy-of select="$bibitem_label"/>
						<xsl:copy-of select="$bibitem_body"/>
					</xsl:otherwise>
				</xsl:choose>
			
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
				2
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
					<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" xml:space="preserve" viewBox="0 0 2 2">
						<rect x="0" y="0" width="2" height="2" fill="black"/>
					</svg>
				</fo:instream-foreign-object>	
		</fo:inline>
	</xsl:template><xsl:template match="@language">
		<xsl:copy-of select="."/>
	</xsl:template><xsl:template match="*[local-name() = 'p'][@type = 'floating-title' or @type = 'section-title']" priority="4">
		<xsl:call-template name="title"/>
	</xsl:template><xsl:template match="*[local-name() = 'admonition']">
		
		
		
		
		
		 <!-- text in the box -->
				<fo:block-container id="{@id}" xsl:use-attribute-sets="admonition-style">
					
					
					
					
				
					
					
							<fo:block-container xsl:use-attribute-sets="admonition-container-style">
							
								
							
								
										<fo:block xsl:use-attribute-sets="admonition-name-style">
											<xsl:call-template name="displayAdmonitionName"/>
										</fo:block>
										<fo:block xsl:use-attribute-sets="admonition-p-style">
											<xsl:apply-templates select="node()[not(local-name() = 'name')]"/>
										</fo:block>
									
							</fo:block-container>
						
				</fo:block-container>
			
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
		
				<fo:block xsl:use-attribute-sets="admonition-p-style">
				
					
					
					<xsl:apply-templates/>
				</fo:block>
			
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
	</xsl:template><xsl:template match="@*|node()" mode="update_xml_enclose_keep-together_within-line">
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
					<xsl:copy-of select="."/>
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
		<pdf:catalog xmlns:pdf="http://xmlgraphics.apache.org/fop/extensions/pdf">
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
								
										<xsl:value-of select="*[local-name() = 'title'][@type='main']"/>
									
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
			
			
			
			
			
				<xsl:value-of select="document('')//*/namespace::itu"/>
			
			
			
			
			
			
			
			
						
			
			
			
			
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