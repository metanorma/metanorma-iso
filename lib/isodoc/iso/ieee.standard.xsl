<?xml version="1.0" encoding="UTF-8"?><xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:ieee="https://www.metanorma.org/ns/ieee" xmlns:mathml="http://www.w3.org/1998/Math/MathML" xmlns:xalan="http://xml.apache.org/xalan" xmlns:fox="http://xmlgraphics.apache.org/fop/extensions" xmlns:pdf="http://xmlgraphics.apache.org/fop/extensions/pdf" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:java="http://xml.apache.org/xalan/java" xmlns:barcode="http://barcode4j.krysalis.org/ns" exclude-result-prefixes="java" version="1.0">

	<xsl:output method="xml" encoding="UTF-8" indent="no"/>
		
	

	<!-- mandatory 'key' -->
	<xsl:key name="kfn" match="*[local-name() = 'fn'][not(ancestor::*[(local-name() = 'table' or local-name() = 'figure') and not(ancestor::*[local-name() = 'name'])])]" use="@reference"/>
	
	<!-- mandatory variable -->
	
	
	<!-- mandatory variable -->
	<xsl:variable name="namespace_full">https://www.metanorma.org/ns/ieee</xsl:variable>
	
	<!-- mandatory variable -->
	<xsl:variable name="debug">false</xsl:variable>
	
	<!-- mandatory variable -->
	<xsl:variable name="contents_">
		<xsl:variable name="bundle" select="count(//ieee:ieee-standard) &gt; 1"/>
		<xsl:for-each select="//ieee:ieee-standard">
			<xsl:variable name="num"><xsl:number level="any" count="ieee:ieee-standard"/></xsl:variable>
			<xsl:variable name="docnumber"><xsl:value-of select="ieee:bibdata/ieee:docidentifier[@type = 'IEEE']"/></xsl:variable>
			<!-- <xsl:variable name="current_document">
				<xsl:copy-of select="."/>
			</xsl:variable> -->
			<xsl:for-each select="."> <!-- xalan:nodeset($current_document) -->
				<doc num="{$num}" firstpage_id="firstpage_id_{$num}" title-part="{$docnumber}" bundle="{$bundle}"> <!-- 'bundle' means several different documents (not language versions) in one xml -->
					<contents>
						<xsl:call-template name="processPrefaceSectionsDefault_Contents"/>
						<xsl:call-template name="processMainSectionsDefault_Contents"/>
						<xsl:apply-templates select="//ieee:indexsect" mode="contents"/>
						
						<xsl:call-template name="processTablesFigures_Contents"/>
					</contents>
				</doc>
			</xsl:for-each>
		</xsl:for-each>
	</xsl:variable>
	<xsl:variable name="contents" select="xalan:nodeset($contents_)"/>
	
	<!-- mandatory variable -->
	<xsl:variable name="ids">
		<xsl:for-each select="//*[@id]">
			<id><xsl:value-of select="@id"/></id>
		</xsl:for-each>
	</xsl:variable>

	<xsl:variable name="doctype" select="(//ieee:ieee-standard)[1]/ieee:bibdata/ieee:ext/ieee:doctype[normalize-space(@language) = '']"/>
	
	<xsl:variable name="stage_" select="normalize-space((//ieee:ieee-standard)[1]/ieee:bibdata/ieee:status/ieee:stage)"/>
	
	<xsl:variable name="stage">
		<xsl:choose>
			<xsl:when test="translate($stage_,'0123456789','') != ''"><xsl:value-of select="$stage_"/></xsl:when> <!-- 'draft' or 'published' -->
			<xsl:otherwise> <!-- stage in digits form -->
				<xsl:choose>
					<xsl:when test="number($stage_) &lt; 60">draft</xsl:when>
					<xsl:otherwise>published</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:variable name="color_blue">
		<xsl:choose>
			<xsl:when test="$doctype = 'standard' and $stage = 'published'">rgb(57,82,164)</xsl:when>
			<xsl:otherwise>rgb(0,176,240)</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:variable name="line-height">1.8</xsl:variable>
	
	<xsl:template match="/">
		<fo:root xml:lang="{$lang}">
			<xsl:variable name="root-style">
				<root-style xsl:use-attribute-sets="root-style">
					<xsl:if test="$doctype = 'whitepaper' or $doctype = 'icap-whitepaper' or $doctype = 'industry-connection-report'">
						<xsl:attribute name="font-family">Calibri, STIX Two Math, <xsl:value-of select="$font_noto_serif"/></xsl:attribute>
						<xsl:attribute name="font-size">11pt</xsl:attribute>
					</xsl:if>
				</root-style>
			</xsl:variable>
			<xsl:call-template name="insertRootStyle">
				<xsl:with-param name="root-style" select="$root-style"/>
			</xsl:call-template>
			
			<xsl:if test="$stage = 'draft'"> <!-- //ieee:ieee-standard/ieee:bibdata[ieee:ext/ieee:doctype = 'international-standard' and ieee:version/ieee:draft] -->
				<xsl:processing-instruction name="add_line_numbers">true</xsl:processing-instruction>
			</xsl:if>
			
			<fo:layout-master-set>
			
				<!-- IEEE template for:
					- draft documents
					- non standard documents (whitepaper, ICAP whitepaper, industry connection report)
					- standard documents
				-->
			
				<!-- ======================== -->
				<!-- IEEE pages -->
				<!-- ======================== -->
				<!-- IEEE cover page -->
				
				<!-- IEEE standard cover page -->
				<fo:simple-page-master master-name="cover-and-back-page-standard" page-width="{$pageWidth}mm" page-height="{$pageHeight}mm">
					<fo:region-body margin-top="62mm" margin-bottom="25mm" margin-left="21.2mm" margin-right="25mm"/>
					<fo:region-before region-name="header" extent="62mm" precedence="true"/>
					<fo:region-after region-name="footer" extent="25mm"/>
					<fo:region-start region-name="left-region" extent="21.2mm"/>
					<fo:region-end region-name="right-region" extent="25mm"/>
				</fo:simple-page-master>
				
				<!-- IEEE industry connection report cover page -->
				<fo:simple-page-master master-name="cover-and-back-page-industry-connection-report" page-width="{$pageWidth}mm" page-height="{$pageHeight}mm">
					<fo:region-body margin-top="116mm" margin-bottom="15mm" margin-left="62mm" margin-right="35mm"/>
					<fo:region-before region-name="header" extent="116mm"/>
					<fo:region-after region-name="footer" extent="15mm"/>
					<fo:region-start region-name="left-region" extent="62mm" precedence="true"/>
					<fo:region-end region-name="right-region" extent="35mm"/>
				</fo:simple-page-master>
				
				<!-- ================== -->
				<!-- IEEE whitepaper, ICAP whitepaper, connection-report -->
				<!-- ================== -->
				<fo:simple-page-master master-name="cover-page-nonstandard" page-width="{$pageWidth}mm" page-height="{$pageHeight}mm">
					<fo:region-body margin-top="115mm" margin-bottom="15mm" margin-left="64mm" margin-right="35mm"/>
					<fo:region-before region-name="header" extent="115mm"/>
					<fo:region-after region-name="footer" extent="15mm"/>
					<fo:region-start region-name="left-region" extent="64mm" precedence="true"/>
					<fo:region-end region-name="right-region" extent="35mm"/>
				</fo:simple-page-master>
				
				<fo:simple-page-master master-name="document-nonstandard" page-width="{$pageWidth}mm" page-height="{$pageHeight}mm">
					<fo:region-body margin-top="25.4mm" margin-bottom="25.4mm" margin-left="19mm" margin-right="19mm"/>
					<fo:region-before region-name="header" extent="25.4mm"/>
					<fo:region-after region-name="footer" extent="25.4mm"/>
					<fo:region-start region-name="left-region" extent="19mm"/>
					<fo:region-end region-name="right-region" extent="19mm"/>
				</fo:simple-page-master>
				
				<!-- landscape -->
				<fo:simple-page-master master-name="document-nonstandard-landscape" page-width="{$pageHeight}mm" page-height="{$pageWidth}mm">
					<fo:region-body margin-top="19mm" margin-bottom="19mm" margin-left="25.4mm" margin-right="25.4mm"/>
					<fo:region-before region-name="header" extent="19mm" precedence="true"/>
					<fo:region-after region-name="footer" extent="19mm" precedence="true"/>
					<fo:region-start region-name="left-region-landscape" extent="25.4mm"/>
					<fo:region-end region-name="right-region-landscape" extent="25.4mm"/>
				</fo:simple-page-master>
				
				<fo:simple-page-master master-name="back-page-nonstandard" page-width="{$pageWidth}mm" page-height="{$pageHeight}mm">
					<fo:region-body margin-top="73mm" margin-bottom="15mm" margin-left="63.5mm" margin-right="35mm"/>
					<fo:region-before region-name="header" extent="73mm"/>
					<fo:region-after region-name="footer" extent="15mm"/>
					<fo:region-start region-name="left-region" extent="63.5mm" precedence="true"/>
					<fo:region-end region-name="right-region" extent="35mm"/>
				</fo:simple-page-master>
				<!-- ================== -->
				<!-- End: IEEE whitepaper -->
				<!-- ================== -->
				
				
				<!-- ToC for non-standards (whitepaper, icap-whitepaper, industry-connection-report) -->
				<fo:simple-page-master master-name="page-toc-first" page-width="{$pageWidth}mm" page-height="{$pageHeight}mm">
					<fo:region-body margin-top="{$marginTop}mm" margin-bottom="{$marginBottom}mm" margin-left="19mm" margin-right="19mm"/>
					<fo:region-before region-name="header" extent="{$marginTop}mm" precedence="true"/>
					<fo:region-after region-name="footer_empty" extent="{$marginBottom}mm"/> <!-- empty footer for 1st ToC page -->
					<fo:region-start region-name="left-region" extent="19mm"/>
					<fo:region-end region-name="right-region" extent="19mm"/>
				</fo:simple-page-master>
				<fo:simple-page-master master-name="page-toc-any" page-width="{$pageWidth}mm" page-height="{$pageHeight}mm">
					<fo:region-body margin-top="{$marginTop}mm" margin-bottom="{$marginBottom}mm" margin-left="19mm" margin-right="19mm"/>
					<fo:region-before region-name="header" extent="{$marginTop}mm" precedence="true"/>
					<fo:region-after region-name="footer" extent="{$marginBottom}mm"/>
					<fo:region-start region-name="left-region" extent="19mm"/>
					<fo:region-end region-name="right-region" extent="19mm"/>
				</fo:simple-page-master>
				<fo:page-sequence-master master-name="page-toc">
					<fo:repeatable-page-master-alternatives>
						<fo:conditional-page-master-reference page-position="first" master-reference="page-toc-first"/>
						<fo:conditional-page-master-reference page-position="any" master-reference="page-toc-any"/>
					</fo:repeatable-page-master-alternatives>
				</fo:page-sequence-master>

				
				<!-- =================== -->
				<!-- Drafts pages -->
				<!-- =================== -->
				<fo:simple-page-master master-name="document-draft" page-width="{$pageWidth}mm" page-height="{$pageHeight}mm">
					<fo:region-body margin-top="{$marginTop}mm" margin-bottom="{$marginBottom}mm" margin-left="{$marginLeftRight1}mm" margin-right="{$marginLeftRight2}mm"/>
					<fo:region-before region-name="header" extent="{$marginTop}mm"/>
					<fo:region-after region-name="footer" extent="{$marginBottom}mm"/>
					<fo:region-start region-name="left-region" extent="{$marginLeftRight1}mm"/>
					<fo:region-end region-name="right-region" extent="{$marginLeftRight2}mm"/>
				</fo:simple-page-master>
				
				<!-- landscape -->
				<fo:simple-page-master master-name="document-draft-landscape" page-width="{$pageHeight}mm" page-height="{$pageWidth}mm">
					<fo:region-body margin-top="{$marginLeftRight1}mm" margin-bottom="{$marginLeftRight2}mm" margin-left="{$marginBottom}mm" margin-right="{$marginTop}mm"/>
					<fo:region-before region-name="header" extent="{$marginLeftRight1}mm" precedence="true"/>
					<fo:region-after region-name="footer" extent="{$marginLeftRight2}mm" precedence="true"/>
					<fo:region-start region-name="left-region-landscape" extent="{$marginBottom}mm"/>
					<fo:region-end region-name="right-region-landscape" extent="{$marginTop}mm"/>
				</fo:simple-page-master>
				<!-- =================== -->
				<!-- =================== -->
				
				<!-- ======================= -->
				<!-- Standard document pages -->
				<!-- ======================= -->
				<fo:simple-page-master master-name="document-standard-first" page-width="{$pageWidth}mm" page-height="{$pageHeight}mm">
					<fo:region-body margin-top="{$marginTop}mm" margin-bottom="{$marginBottom}mm" margin-left="{$marginLeftRight1}mm" margin-right="{$marginLeftRight2}mm"/>
					<fo:region-before region-name="header_empty" extent="{$marginTop}mm"/>
					<fo:region-after region-name="footer" extent="{$marginBottom}mm"/>
					<fo:region-start region-name="left-region" extent="{$marginLeftRight1}mm"/>
					<fo:region-end region-name="right-region" extent="{$marginLeftRight2}mm"/>
				</fo:simple-page-master>
				<fo:page-sequence-master master-name="document-standard">
					<fo:repeatable-page-master-alternatives>
						<fo:conditional-page-master-reference page-position="first" master-reference="document-standard-first"/>
						<fo:conditional-page-master-reference page-position="any" master-reference="document-draft"/>
					</fo:repeatable-page-master-alternatives>
				</fo:page-sequence-master>
				
				<!-- landscape -->
				<fo:simple-page-master master-name="document-standard-landscape" page-width="{$pageHeight}mm" page-height="{$pageWidth}mm">
					<fo:region-body margin-top="{$marginLeftRight1}mm" margin-bottom="{$marginLeftRight2}mm" margin-left="{$marginBottom}mm" margin-right="{$marginTop}mm"/>
					<fo:region-before region-name="header" extent="{$marginLeftRight1}mm" precedence="true"/>
					<fo:region-after region-name="footer" extent="{$marginLeftRight2}mm" precedence="true"/>
					<fo:region-start region-name="left-region-landscape" extent="{$marginBottom}mm"/>
					<fo:region-end region-name="right-region-landscape" extent="{$marginTop}mm"/>
				</fo:simple-page-master>
				<!-- ======================= -->
				<!-- ======================= -->
				
				<!-- Index pages -->
				<fo:simple-page-master master-name="page-index" page-width="{$pageWidth}mm" page-height="{$pageHeight}mm">
					<fo:region-body margin-top="{$marginTop}mm" margin-bottom="{$marginBottom}mm" margin-left="{$marginLeftRight1}mm" margin-right="{$marginLeftRight2}mm" column-count="2" column-gap="10mm"/>
					<fo:region-before region-name="header" extent="{$marginTop}mm"/>
					<fo:region-after region-name="footer" extent="{$marginBottom}mm"/>
					<fo:region-start region-name="left-region" extent="{$marginLeftRight1}mm"/>
					<fo:region-end region-name="right-region" extent="{$marginLeftRight2}mm"/>
				</fo:simple-page-master>
				
				
				<!-- ======================== -->
				<!-- END IEEE pages -->
				<!-- ======================== -->
			
			</fo:layout-master-set>
			
			<fo:declarations>
				<xsl:call-template name="addPDFUAmeta"/>
			</fo:declarations>

			<xsl:call-template name="addBookmarks">
				<xsl:with-param name="contents" select="$contents"/>
			</xsl:call-template>
			
			<xsl:variable name="updated_xml_step1">
				<xsl:apply-templates mode="update_xml_step1"/>
			</xsl:variable>
			<!-- DEBUG: updated_xml_step1=<xsl:copy-of select="$updated_xml_step1"/> -->
			
			<xsl:variable name="updated_xml_step2">
				<xsl:apply-templates select="xalan:nodeset($updated_xml_step1)" mode="update_xml_step2"/>
			</xsl:variable>
			<!-- DEBUG: updated_xml_step2=<xsl:copy-of select="$updated_xml_step2"/> -->
			
			<xsl:for-each select="xalan:nodeset($updated_xml_step2)//ieee:ieee-standard">
				<xsl:variable name="num"><xsl:number level="any" count="ieee:ieee-standard"/></xsl:variable>
				
				
				<xsl:for-each select=".">
				
					<!-- IEEE Std 802.1X™-2020 -->
					<xsl:variable name="standard_number">IEEE Std <xsl:value-of select="/ieee:ieee-standard/ieee:bibdata/ieee:docidentifier[@type = 'IEEE']"/>-<xsl:value-of select="substring(/ieee:ieee-standard/ieee:bibdata/ieee:date[@type = 'published'],1,4)"/></xsl:variable>
				
					<xsl:variable name="designation" select="/ieee:ieee-standard/ieee:bibdata/ieee:docnumber"/>
					<xsl:variable name="draft_number" select="/ieee:ieee-standard/ieee:bibdata/ieee:version/ieee:draft"/>
					<xsl:variable name="revision_month" select="/ieee:ieee-standard/ieee:bibdata/ieee:version/ieee:revision-date"/>
					<xsl:variable name="draft_month">
						<xsl:call-template name="getMonthLocalizedByNum">
							<xsl:with-param name="num" select="substring($revision_month, 6, 2)"/>
						</xsl:call-template>
					</xsl:variable>
					<xsl:variable name="draft_year" select="substring($revision_month, 1, 4)"/>
					
					<xsl:variable name="doctype_localized" select="/ieee:ieee-standard/ieee:bibdata/ieee:ext/ieee:doctype[@language = $lang]"/>
					
					<xsl:variable name="title_intro">
						<!-- Example Local and Metropolitan Area Networks— -->
						<xsl:apply-templates select="/ieee:ieee-standard/ieee:bibdata/ieee:title[@language = 'intro' or @language = 'intro-en']/node()"/>
						<xsl:if test="/ieee:ieee-standard/ieee:bibdata/ieee:title[@language = 'intro' or @language = 'intro-en']">—</xsl:if>
					</xsl:variable>
					
					<xsl:variable name="title_main">
						<!-- Example: Port-Based Network Access Control -->
						<xsl:apply-templates select="/ieee:ieee-standard/ieee:bibdata/ieee:title[@language = 'main' or @language = 'main-en']/node()"/>
					</xsl:variable>
					
					<xsl:variable name="title">
						<xsl:choose>
							<xsl:when test="$doctype = 'standard' and $stage = 'published'">
								<xsl:copy-of select="$title_intro"/>
								<xsl:copy-of select="$title_main"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="/ieee:ieee-standard/ieee:bibdata/ieee:title[1]/node()"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="copyright_year" select="/ieee:ieee-standard/ieee:bibdata/ieee:copyright/ieee:from"/>
					<xsl:variable name="copyright_holder" select="/ieee:ieee-standard/ieee:bibdata/ieee:copyright/ieee:owner/ieee:organization/ieee:abbreviation"/>
					
					<xsl:variable name="document_id">
						<xsl:choose>
							<xsl:when test="$doctype = 'standard' and $stage = 'draft'">
								<xsl:text>P</xsl:text>
								<xsl:value-of select="$designation"/>
								<xsl:text>/D</xsl:text>
								<xsl:value-of select="$draft_number"/>
								<xsl:text>, </xsl:text>
								<xsl:value-of select="$draft_month"/>
								<xsl:text> </xsl:text>
								<xsl:value-of select="$draft_year"/>
							</xsl:when>
							<xsl:when test="$doctype = 'standard' and $stage = 'published'">
								<xsl:value-of select="$standard_number"/>
							</xsl:when>
						</xsl:choose>
					</xsl:variable>
					
					<xsl:variable name="title_prefix">
						<xsl:choose>
							<xsl:when test="$doctype = 'standard' and $stage = 'draft'">
								<xsl:text>Draft </xsl:text>
								<xsl:value-of select="$doctype_localized"/>
								<xsl:if test="normalize-space($doctype_localized) = ''">
									<xsl:choose>
										<xsl:when test="$doctype = 'standard'">Standard</xsl:when>
									</xsl:choose>
								</xsl:if>
								<xsl:text> for </xsl:text>
							</xsl:when>
							<xsl:when test="$doctype = 'standard' and $stage = 'published'">
								<xsl:text>IEEE </xsl:text>
								<xsl:value-of select="$doctype_localized"/>
								<xsl:if test="normalize-space($doctype_localized) = ''">
									<xsl:choose>
										<xsl:when test="$doctype = 'standard'">Standard</xsl:when>
									</xsl:choose>
								</xsl:if>
								<xsl:text> for </xsl:text>
							</xsl:when>
						</xsl:choose>
						<!-- <xsl:copy-of select="$title"/> -->
					</xsl:variable>
					
					
					
					
					
					<xsl:variable name="society" select="/ieee:ieee-standard/ieee:bibdata/ieee:ext/ieee:editorialgroup/ieee:society"/> 
					
					<xsl:variable name="committee" select="/ieee:ieee-standard/ieee:bibdata/ieee:ext/ieee:editorialgroup/ieee:committee"/>
					
					<xsl:variable name="approved_by">IEEE SA Standards Board</xsl:variable>
					<xsl:variable name="approved_date">
						<xsl:call-template name="convertDate">
							<xsl:with-param name="date" select="/ieee:ieee-standard/ieee:bibdata/ieee:date[@type = 'confirmed']"/>
							<xsl:with-param name="format" select="'ddMMyyyy'"/>
						</xsl:call-template>
					</xsl:variable>
					
					
					<!-- Example: Revision of IEEE Std 802.1X™-2010
						Incorporating IEEE Std 802.1Xbx™-2014
						and IEEE Std 802.1Xck™-2018 -->
					<xsl:variable name="history_">
						<xsl:for-each select="/ieee:ieee-standard/ieee:bibdata/ieee:relation[@type = 'updates']">
							<revision_of><xsl:value-of select="ieee:bibitem/ieee:docidentifier"/></revision_of>
						</xsl:for-each>
						<xsl:for-each select="/ieee:ieee-standard/ieee:bibdata/ieee:relation[@type = 'merges']">
							<incorporating><xsl:value-of select="ieee:bibitem/ieee:docidentifier"/></incorporating>
						</xsl:for-each>
					</xsl:variable>
					<xsl:variable name="history" select="xalan:nodeset($history_)"/>
					
					<xsl:variable name="history_text">
						<xsl:if test="string-length($history) != 0">(</xsl:if>
						<xsl:for-each select="$history/*[normalize-space() != '']">
							
							<xsl:if test="local-name() = 'revision_of' and not(preceding-sibling::*[local-name() = 'revision_of'])">Revision of </xsl:if>
							
							<xsl:if test="local-name() = 'incorporating' and not(preceding-sibling::*[local-name() = 'incorporating'])">Incorporating </xsl:if>
							
							<xsl:variable name="curr" select="local-name()"/>
							<xsl:if test="preceding-sibling::*[local-name() = $curr] and not(following-sibling::*[local-name() = $curr])">and </xsl:if>
							
							<xsl:value-of select="."/>
							
							<xsl:if test="position() != last()"><xsl:value-of select="$linebreak"/></xsl:if>
						</xsl:for-each>
						
						<xsl:if test="string-length($history) != 0">)</xsl:if>
					</xsl:variable>
					
					<!-- ======================= -->
					<!-- Cover page -->
					<!-- ======================= -->
					<xsl:choose>
					
						<xsl:when test="$stage = 'draft' and $doctype = 'standard'">
							<!-- 'Draft' first page -->
							<fo:page-sequence master-reference="document-draft" force-page-count="no-force">
								
								<xsl:call-template name="insertFootnoteSeparator"/>
								
								<xsl:call-template name="insertHeaderFooter">
									<xsl:with-param name="document_id" select="$document_id"/>
									<xsl:with-param name="title_prefix" select="$title_prefix"/>
									<xsl:with-param name="title" select="$title"/>
									<xsl:with-param name="doctype" select="$doctype"/>
									
									<xsl:with-param name="copyright_year" select="$copyright_year"/>
									<xsl:with-param name="copyright_holder" select="$copyright_holder"/>
									<xsl:with-param name="hideFooter">true</xsl:with-param>
								</xsl:call-template>
								
								<fo:flow flow-name="xsl-region-body">
									<fo:block-container margin-top="18mm" id="firstpage_id_{$num}">
										<fo:block font-family="Arial">
											<fo:block font-size="23pt" font-weight="bold" margin-top="50pt" margin-bottom="36pt">
												<xsl:text>P</xsl:text>
												<xsl:value-of select="$designation"/>
												<xsl:text>™/D</xsl:text>
												<xsl:value-of select="$draft_number"/>
												<xsl:value-of select="$linebreak"/>
												<xsl:copy-of select="$title_prefix"/>
												<xsl:copy-of select="$title"/>
												<!-- <xsl:copy-of select="$draft_title_part"/> -->
											</fo:block>
											<fo:block>Developed by the</fo:block>
											<fo:block> </fo:block>
											<fo:block font-size="11pt" font-weight="bold">
												<!-- <Committee Name> -->
												<xsl:value-of select="$committee"/> 
											</fo:block>
											<fo:block>of the</fo:block>
											<fo:block font-size="11pt" font-weight="bold">
												 <!-- IEEE <Society Name> -->
												<xsl:text>IEEE </xsl:text><xsl:value-of select="$society"/>
											</fo:block>
											<fo:block> </fo:block>
											<fo:block> </fo:block>
											<fo:block>
												<!-- Approved <Date Approved> -->
												<xsl:text>Approved </xsl:text>
												<xsl:value-of select="$approved_date"/>
											</fo:block>
											<fo:block> </fo:block>
											<!-- Example: IEEE SA Standards Board -->
											<fo:block font-size="11pt" font-weight="bold"><xsl:value-of select="$approved_by"/></fo:block>
										</fo:block>
										
										<xsl:apply-templates select="/ieee:ieee-standard/ieee:boilerplate/ieee:copyright-statement"/>
										
										<xsl:apply-templates select="/ieee:ieee-standard/ieee:boilerplate/ieee:license-statement"/>
									
									
										<fo:block break-after="page"/>
										
										
										<fo:block font-family="Arial" text-align="justify">
											<fo:block>
												<fo:inline font-weight="bold">
													<xsl:call-template name="getLocalizedString">
														<xsl:with-param name="key">abstract</xsl:with-param>
													</xsl:call-template>
													<xsl:text>: </xsl:text>
												</fo:inline>
												<xsl:apply-templates select="/ieee:ieee-standard/ieee:preface/ieee:abstract/node()[not(self::ieee:title)] | /ieee:ieee-standard/ieee:preface/ieee:clause[@id = '_abstract' or ieee:title = 'Abstract']/node()[not(self::ieee:title)]"/>
											</fo:block>
											<fo:block> </fo:block>
											<fo:block>
												<fo:inline font-weight="bold">Keywords: </fo:inline> <xsl:value-of select="/ieee:ieee-standard/ieee:bibdata/ieee:keyword"/>
											</fo:block>
										</fo:block>
										
										<!-- Example:
										The Institute of Electrical and Electronics Engineers, Inc.
										3 Park Avenue, New York, NY 10016-5997, USA
										...
										PDF: ISBN 978-0-XXXX-XXXX-X STDXXXXX
										Print: ISBN 978-0-XXXX-XXXX-X STDPDXXXXX
										-->
										<xsl:apply-templates select="/ieee:ieee-standard/ieee:boilerplate/ieee:feedback-statement"/>
										
									</fo:block-container>
								</fo:flow>
							</fo:page-sequence> <!-- End: 'Draft' first page -->
						</xsl:when>
					
						<xsl:when test="$stage = 'published' and $doctype = 'standard'"><!--  $doctype = 'international-standard' and $isDraft = 'false' -->
							<xsl:call-template name="insertCoverPage_Standard">
								<xsl:with-param name="title_intro" select="$title_intro"/>
								<xsl:with-param name="title_main" select="$title_main"/>
								<xsl:with-param name="society" select="$society"/>
								<xsl:with-param name="committee" select="$committee"/>
								<xsl:with-param name="standard_number" select="$standard_number"/>
								<xsl:with-param name="history" select="$history_text"/>
							</xsl:call-template>
						</xsl:when>
						
						<!-- <xsl:when test="$doctype = 'industry-connection-report'">
							<xsl:call-template name="insertCoverPage_IndustryConnectionReport"/>
						</xsl:when> -->
						
						<xsl:when test="$doctype = 'whitepaper' or $doctype = 'icap-whitepaper' or $doctype = 'industry-connection-report'">
							<xsl:call-template name="insertCoverPage_NonStandard">
								<xsl:with-param name="title" select="$title"/>
							</xsl:call-template>
						</xsl:when>
						
					</xsl:choose>
					<!-- ======================= -->
					<!-- END Cover page -->
					<!-- ======================= -->
					
					
					<!-- =================== -->
					<!-- Second page(s) -->
					<!-- =================== -->
					<xsl:choose>
					
						<xsl:when test="$stage = 'draft' and $doctype = 'standard'"><!-- $doctype = 'international-standard' and $isDraft = 'true' -->
							<!-- Legal statement -->
							<fo:page-sequence master-reference="document-draft" force-page-count="no-force" format="1">
								<xsl:call-template name="insertFootnoteSeparator"/>
								
								<xsl:call-template name="insertHeaderFooter">
									<xsl:with-param name="document_id" select="$document_id"/>
									<xsl:with-param name="title_prefix" select="$title_prefix"/>
									<xsl:with-param name="title" select="$title"/>
									<xsl:with-param name="doctype" select="$doctype"/>
									<xsl:with-param name="copyright_year" select="$copyright_year"/>
									<xsl:with-param name="copyright_holder" select="$copyright_holder"/>
								</xsl:call-template>
								
								<fo:flow flow-name="xsl-region-body">
									<fo:block>
										<!-- Example:
										Important Notices and Disclaimers Concerning IEEE Standards Documents
										IEEE Standards documents are made available for use subject to important notices and legal disclaimers. These notices and disclaimers, or a reference to this page (https://standards.ieee.org/ipr/disclaimers.html), appear in all standards and may be found under the heading “Important Notices and Disclaimers Concerning IEEE Standards Documents.”
										...
										-->
										<xsl:apply-templates select="/ieee:ieee-standard/ieee:boilerplate/ieee:legal-statement"/>
									</fo:block>
								</fo:flow>
								
							</fo:page-sequence> <!-- End: Legal statement -->
						
						</xsl:when> <!-- $stage = 'draft' -->
					
					
						<xsl:when test="$stage = 'published' and $doctype = 'standard'"><!-- $doctype = 'international-standard' and $isDraft = 'false' -->
							<!-- Second, third page -->
							<fo:page-sequence master-reference="document-draft" force-page-count="no-force" font-family="Arial" initial-page-number="1">
							
								<xsl:call-template name="insertFootnoteSeparator"/>
								
								<xsl:call-template name="insertHeaderFooter">
									<xsl:with-param name="doctype" select="$doctype"/>
									<xsl:with-param name="copyright_year" select="$copyright_year"/>
									<xsl:with-param name="copyright_holder" select="$copyright_holder"/>
									<xsl:with-param name="hideHeader">true</xsl:with-param>
								</xsl:call-template>
								
								<fo:flow flow-name="xsl-region-body">
									<fo:block text-align="right" margin-top="2mm">
										<fo:block font-size="12pt" font-weight="bold"><xsl:value-of select="$standard_number"/></fo:block>
										<fo:block font-size="9pt"><xsl:value-of select="$history_text"/></fo:block>
									</fo:block>
									
									<fo:block font-weight="bold" space-before="13mm">
										<fo:block font-size="18pt">IEEE Standard for</fo:block>
										<fo:block font-size="18pt">
											<!-- Example Local and Metropolitan Area Networks— -->
											<xsl:text>    </xsl:text>
											<xsl:copy-of select="$title_intro"/>
										</fo:block>
										<fo:block font-size="24pt" space-before="12pt">
											<!-- Example: Port-Based Network Access Control -->
											<xsl:copy-of select="$title_main"/>
										</fo:block>
									</fo:block>
									
									<fo:block font-size="10pt" space-before="9mm" space-after="4pt">Developed by the</fo:block>
									<fo:block font-size="11pt" font-weight="bold">
										<!-- Example: LAN/MAN Standards Committee -->
										<xsl:value-of select="$committee"/> 
										<xsl:value-of select="$linebreak"/>
										<xsl:text>of the</xsl:text>
										<xsl:value-of select="$linebreak"/>
										<!-- Example: IEEE Computer Society -->
										<xsl:value-of select="$society"/> 
										<xsl:value-of select="$linebreak"/>
									</fo:block>

									<fo:block font-size="10pt" space-before="8mm" space-after="4pt">Approved <xsl:value-of select="$approved_date"/></fo:block>
									<!-- Example: IEEE SA Standards Board -->
									<fo:block font-size="11pt" font-weight="bold"><xsl:value-of select="$approved_by"/></fo:block>

									<fo:block break-after="page"/>
							
									<fo:block font-family="Arial" text-align="justify">
										<fo:block>
											<fo:inline font-weight="bold">
												<xsl:call-template name="getLocalizedString">
													<xsl:with-param name="key">abstract</xsl:with-param>
												</xsl:call-template>
												<xsl:text>: </xsl:text>
											</fo:inline>
											<xsl:apply-templates select="/ieee:ieee-standard/ieee:preface/ieee:abstract/node()[not(self::ieee:title)] | /ieee:ieee-standard/ieee:preface/ieee:clause[@id = '_abstract' or ieee:title = 'Abstract']/node()[not(self::ieee:title)]"/>
										</fo:block>
										<fo:block> </fo:block>
										<fo:block>
											<fo:inline font-weight="bold">Keywords: </fo:inline> <xsl:value-of select="/ieee:ieee-standard/ieee:bibdata/ieee:keyword"/>
										</fo:block>
									</fo:block>
										
									<!-- Example:
									The Institute of Electrical and Electronics Engineers, Inc.
									3 Park Avenue, New York, NY 10016-5997, USA
									...
									PDF: ISBN 978-0-XXXX-XXXX-X STDXXXXX
									Print: ISBN 978-0-XXXX-XXXX-X STDPDXXXXX
									-->
									<xsl:apply-templates select="/ieee:ieee-standard/ieee:boilerplate/ieee:feedback-statement"/>
									
								</fo:flow>
							</fo:page-sequence>
							
							<fo:page-sequence master-reference="document-draft" force-page-count="no-force">
								<xsl:call-template name="insertFootnoteSeparator"/>
								<xsl:call-template name="insertHeaderFooter">
									<xsl:with-param name="document_id" select="$document_id"/>
									<xsl:with-param name="title_prefix" select="$title_prefix"/>
									<xsl:with-param name="title" select="$title"/>
									<xsl:with-param name="doctype" select="$doctype"/>
									<xsl:with-param name="copyright_year" select="$copyright_year"/>
									<xsl:with-param name="copyright_holder" select="$copyright_holder"/>
								</xsl:call-template>
								
								<fo:flow flow-name="xsl-region-body">
									<fo:block>
										<!-- Example:
										Important Notices and Disclaimers Concerning IEEE Standards Documents
										IEEE Standards documents are made available for use subject to important notices and legal disclaimers. These notices and disclaimers, or a reference to this page (https://standards.ieee.org/ipr/disclaimers.html), appear in all standards and may be found under the heading “Important Notices and Disclaimers Concerning IEEE Standards Documents.”
										...
										-->
										<xsl:apply-templates select="/ieee:ieee-standard/ieee:boilerplate/ieee:legal-statement"/>
									</fo:block>
								</fo:flow>
							</fo:page-sequence>
						</xsl:when> <!-- $stage = 'published' -->
						
						
						<xsl:when test="$doctype = 'whitepaper' or $doctype = 'icap-whitepaper' or $doctype = 'industry-connection-report'">
							<fo:page-sequence master-reference="document-nonstandard" force-page-count="no-force" font-family="Calibri Light">
							
								<xsl:call-template name="insertHeaderFooter">
									<xsl:with-param name="doctype" select="$doctype"/>
									<xsl:with-param name="copyright_year" select="$copyright_year"/>
									<xsl:with-param name="copyright_holder" select="$copyright_holder"/>
									<xsl:with-param name="hideHeader">true</xsl:with-param>
								</xsl:call-template>
								
								<fo:flow flow-name="xsl-region-body">
									<fo:block-container>
										<fo:block font-family="Arial Black" font-size="13pt">TRADEMARKS AND DISCLAIMERS</fo:block>
										<fo:block font-size="10pt" margin-top="12pt" margin-bottom="12pt" text-align="justify" line-height="{$line-height}">IEEE believes the information in this publication is accurate as of its publication date; such information is subject to change without notice. IEEE is not responsible for any inadvertent errors.</fo:block>
										<fo:block font-size="10pt" margin-top="12pt" margin-bottom="12pt" text-align="justify" line-height="{$line-height}">The ideas and proposals in this specification are the respective author’s views and do not represent the views of the affiliated organization.</fo:block>
										<fo:block font-family="Arial Black" font-size="13pt">ACKNOWLEDGEMENTS</fo:block>
										<fo:block font-family="Calibri">
											<fo:block margin-top="12pt" margin-bottom="12pt" line-height="{$line-height}">Special thanks are given to the following reviewers of this paper:</fo:block>
											<fo:block font-size="10pt">
												<fo:block margin-bottom="6pt">Firstname Lastname</fo:block>
												<fo:block margin-bottom="6pt">Firstname Lastname</fo:block>
												<fo:block margin-bottom="6pt">Firstname Lastname</fo:block>
												<fo:block margin-bottom="6pt">Firstname Lastname</fo:block>
												<fo:block margin-bottom="6pt">Firstname Lastname</fo:block>
												<fo:block margin-bottom="6pt">Firstname Lastname</fo:block>
												<fo:block margin-bottom="6pt">Firstname Lastname</fo:block>
												<fo:block margin-bottom="6pt">Firstname Lastname</fo:block>
											</fo:block>
										</fo:block>
										
										<!-- Example:
										The Institute of Electrical and Electronics Engineers, Inc. 3 Park Avenue, New York, NY 10016-5997, USA
										...
										PDF: STDXXXXX ISBN 978-0-XXXX-XXXX-X 
										-->
										<fo:block font-style="italic">
											<xsl:apply-templates select="/ieee:ieee-standard/ieee:boilerplate/ieee:feedback-statement"/>
										</fo:block>
										
										<!-- NOTICE AND DISCLAIMER OF LIABILITY CONCERNING THE USE OF IEEE SA DOCUMENTS -->
										<xsl:apply-templates select="/ieee:ieee-standard/ieee:boilerplate/ieee:legal-statement"/>
										
									</fo:block-container>
								</fo:flow>
								
							</fo:page-sequence>
						
						</xsl:when> <!-- $doctype = 'whitepaper' or $doctype = 'icap-whitepaper' or $doctype = 'industry-connection-report' -->
						
					</xsl:choose>
					<!-- =================== -->
					<!-- End Second page(s) -->
					<!-- =================== -->
					
					
					
					
				
					<!-- ================================ -->
					<!-- PREFACE pages (Introduction, Contents -->
					<!-- ================================ -->
					
					<xsl:variable name="structured_xml_preface">
						<xsl:apply-templates select="/*/*[local-name()='preface']/*[local-name() = 'introduction']" mode="flatxml"/>
					</xsl:variable>
					
					<!-- structured_xml_preface=<xsl:copy-of select="$structured_xml_preface"/> -->
					
					<xsl:variable name="paged_xml_preface">
						<xsl:call-template name="makePagedXML">
							<xsl:with-param name="structured_xml" select="$structured_xml_preface"/>
						</xsl:call-template>
					</xsl:variable>
					
					<xsl:if test="$debug = 'true'">
						<xsl:text disable-output-escaping="yes">&lt;!--</xsl:text>
							DEBUG
							contents=<xsl:copy-of select="$contents"/>
						<xsl:text disable-output-escaping="yes">--&gt;</xsl:text>
					</xsl:if>
					
					
					<xsl:choose>
					
						<xsl:when test="($stage = 'draft' or $stage = 'published') and $doctype = 'standard'"><!-- $doctype = 'international-standard' and $isDraft = 'true' -->
							<fo:page-sequence master-reference="document-draft" id="prefaceSequence"> <!-- format="i" initial-page-number="1" -->
						
								<xsl:call-template name="insertFootnoteSeparator"/>
								
								<xsl:call-template name="insertHeaderFooter">
									<xsl:with-param name="document_id" select="$document_id"/>
									<xsl:with-param name="title_prefix" select="$title_prefix"/>
									<xsl:with-param name="title" select="$title"/>
									<xsl:with-param name="doctype" select="$doctype"/>
									<xsl:with-param name="copyright_year" select="$copyright_year"/>
									<xsl:with-param name="copyright_holder" select="$copyright_holder"/>
								</xsl:call-template>
								
								<fo:flow flow-name="xsl-region-body">
									
									<fo:block>
										<xsl:for-each select="xalan:nodeset($paged_xml_preface)/*[local-name()='page']">
											<xsl:apply-templates select="*" mode="page"/>
											<fo:block break-after="page"/>
										</xsl:for-each>
									</fo:block>
										
									<fo:block font-family="Arial" font-size="12pt" role="H1" font-weight="bold" margin-top="12pt" margin-bottom="24pt">
										<xsl:if test="$stage = 'published'">
											<xsl:attribute name="margin-bottom">12pt</xsl:attribute>
										</xsl:if>
										<!-- Contents -->
										<xsl:call-template name="getLocalizedString">
											<xsl:with-param name="key">table_of_contents</xsl:with-param>
										</xsl:call-template>
									</fo:block>
								
									<fo:block role="TOC">
										<xsl:if test="$contents/doc[@num = $num]//item[@display = 'true']">
											
											<xsl:choose>
												<xsl:when test="$stage = 'draft'">
												
													<xsl:variable name="margin-left">4</xsl:variable>
													
													<xsl:for-each select="$contents/doc[@num = $num]//item[@display = 'true']">
														<fo:block role="TOCI">
															<xsl:if test="@level = 1">
																<xsl:attribute name="margin-top">12pt</xsl:attribute>
															</xsl:if>
															
															<fo:block text-align-last="justify">
																<xsl:attribute name="margin-left"><xsl:value-of select="$margin-left * (@level - 1)"/>mm</xsl:attribute>
																<xsl:if test="@type = 'annex'">
																	<xsl:attribute name="font-weight">normal</xsl:attribute>
																</xsl:if>
																
																<fo:basic-link internal-destination="{@id}" fox:alt-text="{title}">
																
																	<xsl:value-of select="@section"/>
																	<!-- <xsl:if test="normalize-space(@section) != '' and @level = 1">.</xsl:if> -->
																	<xsl:if test="normalize-space(@section) != ''"><xsl:text> </xsl:text></xsl:if>
																	
																	<xsl:apply-templates select="title"/>
																
																	<fo:inline keep-together.within-line="always">
																		<fo:leader font-size="9pt" font-weight="normal" leader-pattern="dots"/>
																		<fo:inline>
																			<fo:page-number-citation ref-id="{@id}"/>
																		</fo:inline>
																	</fo:inline>
																
																</fo:basic-link>
															</fo:block>
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
											
												</xsl:when> <!-- $stage = 'draft' -->
												
												<xsl:when test="$stage = 'published'">
												
													<xsl:variable name="provisional-distance-between-starts">10</xsl:variable>
													
													<xsl:for-each select="$contents/doc[@num = $num]//item[@display = 'true']">
													
														<fo:list-block provisional-distance-between-starts="{$provisional-distance-between-starts}mm" role="TOCI">
														
															<xsl:if test="@level = 1">
																<xsl:attribute name="margin-top">12pt</xsl:attribute>
																<xsl:attribute name="margin-bottom">6pt</xsl:attribute>
															</xsl:if>
															
															<xsl:attribute name="margin-left"><xsl:value-of select="$provisional-distance-between-starts * (@level - 1)"/>mm</xsl:attribute>
					
															<fo:list-item>
																<fo:list-item-label end-indent="label-end()">
																	<fo:block>
																		<xsl:value-of select="@section"/>
																	</fo:block>
																</fo:list-item-label>
																<fo:list-item-body start-indent="body-start()">
																	<fo:block text-align-last="justify">
																
																		<xsl:if test="@type = 'annex'">
																			<xsl:attribute name="font-weight">normal</xsl:attribute>
																			<xsl:if test="@level = 1">
																				<xsl:attribute name="margin-left">-<xsl:value-of select="$provisional-distance-between-starts"/>mm</xsl:attribute>
																			</xsl:if>
																		</xsl:if>
																		
																		<fo:basic-link internal-destination="{@id}" fox:alt-text="{title}">
																			
																			<xsl:apply-templates select="title"/>
																		
																			<fo:inline keep-together.within-line="always">
																				<fo:leader font-size="9pt" font-weight="normal" leader-pattern="dots"/>
																				<fo:inline>
																					<fo:page-number-citation ref-id="{@id}"/>
																				</fo:inline>
																			</fo:inline>
																		
																		</fo:basic-link>
																	</fo:block>
																</fo:list-item-body>
															</fo:list-item>
													
														</fo:list-block>
													</xsl:for-each>
													
													<!-- List of Figures -->
													<xsl:if test="$contents//figures/figure">
														<fo:block break-after="page"/>
														<xsl:call-template name="insertListOf_Title">
															<xsl:with-param name="title" select="'Figures'"/>
														</xsl:call-template>
														<xsl:for-each select="$contents//figures/figure">
															<xsl:call-template name="insertListOf_Item"/>
														</xsl:for-each>
													</xsl:if>
													
													<!-- List of Tables -->
													<xsl:if test="$contents//tables/table">
														<fo:block break-after="page"/>
														<xsl:call-template name="insertListOf_Title">
															<xsl:with-param name="title" select="'Tables'"/>
														</xsl:call-template>
														<xsl:for-each select="$contents//tables/table">
															<xsl:call-template name="insertListOf_Item"/>
														</xsl:for-each>
													</xsl:if>
													
													
												</xsl:when> <!-- $stage = 'published' -->
											</xsl:choose>
											
										</xsl:if>
										
									</fo:block>
									
								</fo:flow>
							</fo:page-sequence>
						</xsl:when> <!-- $stage = 'draft' -->
					
					
						<xsl:when test="$doctype = 'whitepaper' or $doctype = 'icap-whitepaper' or $doctype = 'industry-connection-report'">
							<!-- TRADEMARKS AND DISCLAIMERS -->
							<!-- ACKNOWLEDGEMENTS -->
							<!-- NOTICE AND DISCLAIMER OF LIABILITY CONCERNING THE USE OF IEEE SA INDUSTRY CONNECTIONS DOCUMENTS -->
							
							<!-- ToC -->
							<fo:page-sequence master-reference="page-toc" force-page-count="no-force">
							
								<xsl:call-template name="insertHeaderFooter">
									<xsl:with-param name="doctype" select="$doctype"/>
									<xsl:with-param name="copyright_year" select="$copyright_year"/>
									<xsl:with-param name="copyright_holder" select="$copyright_holder"/>
									<xsl:with-param name="hideHeader">true</xsl:with-param>
								</xsl:call-template>
							
								<fo:static-content flow-name="header" role="artifact">
									<fo:block-container position="absolute" left="0mm" top="0mm" width="54mm" height="{$pageHeight}mm" background-color="rgb(35,31,32)">
										<fo:block> </fo:block>
									</fo:block-container>
									
									<fo:block-container position="absolute" left="0.5mm" top="252mm">
										<fo:block font-size="1">
											<fo:instream-foreign-object content-width="38mm" content-height="2.5mm" scaling="non-uniform" fox:alt-text="Image Box">
												<xsl:call-template name="insertImageBoxSVG">
													<xsl:with-param name="color"><xsl:value-of select="$color_blue"/></xsl:with-param>
												</xsl:call-template>
											</fo:instream-foreign-object>
										</fo:block>
									</fo:block-container>
									
								</fo:static-content>
								<fo:static-content flow-name="left-region" role="artifact">
									<fo:block-container font-family="Arial Black" font-weight="normal" reference-orientation="90" font-size="48pt" text-align="left" color="white">
										<fo:block margin-left="31.4mm" margin-top="20mm">TABLE OF CONTENTS</fo:block>
									</fo:block-container>
								</fo:static-content>
								<fo:flow flow-name="xsl-region-body">
								
									<fo:block-container margin-left="47mm" margin-top="10mm"> <!-- margin-top="27mm" -->
									
										<fo:block-container margin-left="0mm">
											<fo:block role="TOC" font-size="10pt">
												<xsl:if test="$contents/doc[@num = $num]//item[@display = 'true']">
													
													<xsl:variable name="margin-left">
														<xsl:choose>
															<xsl:when test="@level = 2">4.5mm</xsl:when>
															<xsl:when test="@level &gt;= 3">7.5mm</xsl:when>
															<xsl:otherwise>0mm</xsl:otherwise>
														</xsl:choose>
													</xsl:variable>
													
													<xsl:for-each select="$contents/doc[@num = $num]//item[@display = 'true'][@level &lt;= $toc_level or @type = 'figure' or @type = 'table']">
														<fo:block role="TOCI">
															<xsl:if test="@level = 1">
																<xsl:attribute name="margin-top">12pt</xsl:attribute>
																<xsl:attribute name="margin-bottom">6pt</xsl:attribute>
															</xsl:if>
															
															<xsl:if test="@type = 'figure' or @type = 'table' and preceding-sibling::item[1][@type = 'figure' or @type = 'table']">
																<xsl:attribute name="margin-top">0pt</xsl:attribute>
																<xsl:attribute name="margin-bottom">0pt</xsl:attribute>
															</xsl:if>
															
															<fo:block text-align-last="justify">
																<xsl:attribute name="margin-left"><xsl:value-of select="$margin-left"/>mm</xsl:attribute>
																<xsl:if test="@type = 'annex'">
																	<xsl:attribute name="font-weight">normal</xsl:attribute>
																</xsl:if>
																
																<fo:basic-link internal-destination="{@id}" fox:alt-text="{title}">
																
																	<xsl:value-of select="@section"/>
																	<xsl:if test="normalize-space(@section) != ''"><xsl:text> </xsl:text></xsl:if>
																	
																	<xsl:variable name="title">
																		<xsl:apply-templates select="title"/>
																	</xsl:variable>
																	
																	<!-- DEBUG=<xsl:copy-of select="$title"/> -->
																	
																	<xsl:choose>
																		<xsl:when test="@level = 1">
																			<xsl:apply-templates select="xalan:nodeset($title)" mode="uppercase"/>
																		</xsl:when>
																		<xsl:otherwise>
																			<xsl:apply-templates select="xalan:nodeset($title)" mode="smallcaps"/>
																		</xsl:otherwise>
																	</xsl:choose>
																	
																	<fo:inline keep-together.within-line="always">
																		<fo:leader font-weight="normal" leader-pattern="dots"/>
																		<fo:inline>
																			<fo:page-number-citation ref-id="{@id}"/>
																		</fo:inline>
																	</fo:inline>
																
																</fo:basic-link>
															</fo:block>
														</fo:block>
													</xsl:for-each>
													
												</xsl:if>
												
											</fo:block>
										</fo:block-container>
									</fo:block-container>
								</fo:flow>
							</fo:page-sequence> <!-- page-toc -->
						
						</xsl:when> <!-- $doctype = 'whitepaper' or $doctype = 'icap-whitepaper' or $doctype = 'industry-connection-report' -->
					</xsl:choose>
					
					
					<!-- ================================ -->
					<!-- END: PREFACE pages (Table of Contents, Foreword -->
					<!-- ================================ -->

					
					<!-- item - page sequence -->
					<xsl:variable name="structured_xml_">
						
						<xsl:choose>
						
							<xsl:when test="$doctype = 'whitepaper' or $doctype = 'icap-whitepaper' or $doctype = 'industry-connection-report'">
								<!-- ($stage = 'published' and $doctype = 'standard') or -->
								<item>
									<xsl:apply-templates select="/ieee:ieee-standard/ieee:preface/ieee:abstract" mode="flatxml"/>
								</item>
							
								<xsl:for-each select="/*/*[local-name()='sections']/*"> <!-- each section starts with a new page -->
									<item>
										<xsl:apply-templates select="." mode="flatxml"/>
									</item>
								</xsl:for-each>
							</xsl:when> <!-- $doctype = 'whitepaper' or $doctype = 'icap-whitepaper' or $doctype = 'industry-connection-report' -->
							
							<xsl:when test="$doctype = 'standard' and $stage = 'published'">
								<xsl:for-each select="/*/*[local-name()='sections']/*"> <!-- each section starts with a new page -->
									<item>
										<xsl:apply-templates select="." mode="flatxml"/>
									</item>
								</xsl:for-each>
							</xsl:when> <!-- $doctype = 'standard' and $stage = 'published' -->
							
							<xsl:otherwise>
								<item>
									<xsl:apply-templates select="/*/*[local-name()='sections']/*" mode="flatxml"/>
								</item>	
							</xsl:otherwise>
						</xsl:choose>
						
						<!-- Annexes -->
						<xsl:for-each select="/*/*[local-name()='annex']">
							<item>
								<xsl:apply-templates select="." mode="flatxml"/>
							</item>
						</xsl:for-each>
						
						<!-- Bibliography -->
						<xsl:for-each select="/*/*[local-name()='bibliography']/*">
							<item><xsl:apply-templates select="." mode="flatxml"/></item>
						</xsl:for-each>
						
						<item>
							<xsl:copy-of select="//ieee:indexsect"/>
						</item>
						
					</xsl:variable>
					
					<!-- page break before each section -->
					<xsl:variable name="structured_xml">
						<xsl:for-each select="xalan:nodeset($structured_xml_)/item[*]">
							<xsl:element name="pagebreak" namespace="https://www.metanorma.org/ns/ieee"/>
							<xsl:copy-of select="./*"/>
						</xsl:for-each>
					</xsl:variable>
					
					<!-- structured_xml=<xsl:copy-of select="$structured_xml" />=end structured_xml -->
					
					<xsl:variable name="paged_xml">
						<xsl:call-template name="makePagedXML">
							<xsl:with-param name="structured_xml" select="$structured_xml"/>
						</xsl:call-template>
					</xsl:variable>
					
					<!-- paged_xml=<xsl:copy-of select="$paged_xml"/> -->
			
					
					<xsl:for-each select="xalan:nodeset($paged_xml)/*[local-name()='page'][*]">
						<fo:page-sequence master-reference="document-draft" force-page-count="no-force">
						
							<xsl:if test="@orientation = 'landscape'">
								<xsl:attribute name="master-reference">document-draft-<xsl:value-of select="@orientation"/></xsl:attribute>
							</xsl:if>
						
							<xsl:if test="$doctype = 'whitepaper' or $doctype = 'icap-whitepaper' or $doctype = 'industry-connection-report'">
								<xsl:attribute name="master-reference">document-nonstandard</xsl:attribute>
								<xsl:if test="@orientation = 'landscape'">
									<xsl:attribute name="master-reference">document-nonstandard<xsl:value-of select="@orientation"/></xsl:attribute>
								</xsl:if>
							</xsl:if>
						
							<xsl:if test="$doctype = 'standard' and $stage = 'published'">
								<xsl:attribute name="master-reference">document-standard</xsl:attribute>
								<xsl:if test="@orientation = 'landscape'">
									<xsl:attribute name="master-reference">document-standard<xsl:value-of select="@orientation"/></xsl:attribute>
								</xsl:if>
							</xsl:if>
						
							<!-- <xsl:if test="position() = 1">
								<xsl:attribute name="initial-page-number">1</xsl:attribute>
							</xsl:if> -->
							<xsl:if test=".//ieee:indexsect">
								<xsl:attribute name="master-reference">page-index</xsl:attribute>
							</xsl:if>
							
							<xsl:call-template name="insertFootnoteSeparator"/>
							
							<xsl:choose>
								<xsl:when test="($stage = 'draft' or $stage = 'published') and $doctype = 'standard'">
									<xsl:call-template name="insertHeaderFooter">
										<xsl:with-param name="document_id" select="$document_id"/>
										<xsl:with-param name="title_prefix" select="$title_prefix"/>
										<xsl:with-param name="title" select="$title"/>
										<xsl:with-param name="doctype" select="$doctype"/>
										<xsl:with-param name="copyright_year" select="$copyright_year"/>
										<xsl:with-param name="copyright_holder" select="$copyright_holder"/>
										<xsl:with-param name="orientation">@orientation</xsl:with-param>
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise> <!-- ($doctype = 'international-standard' and $isDraft = 'false') or $doctype = 'whitepaper' or $doctype = 'icap-whitepaper' or $doctype = 'industry-connection-report' -->
									<xsl:call-template name="insertHeaderFooter">
										<xsl:with-param name="doctype" select="$doctype"/>
										<xsl:with-param name="copyright_year" select="$copyright_year"/>
										<xsl:with-param name="copyright_holder" select="$copyright_holder"/>
										<xsl:with-param name="hideHeader">true</xsl:with-param>
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>
							
							

							<fo:flow flow-name="xsl-region-body">
								<!-- debugpage=<xsl:copy-of select="."/> -->
								
								<xsl:if test="position() = 1">
									
									<xsl:choose>
										<xsl:when test="$stage = 'draft' and $doctype = 'standard'">
											<fo:block font-family="Arial" font-size="23pt" font-weight="bold" margin-top="70pt" margin-bottom="48pt">
												<xsl:copy-of select="$title_prefix"/>
												<xsl:copy-of select="$title"/>
												<!-- <xsl:copy-of select="$draft_title_part"/> -->
											</fo:block>
										</xsl:when>
										
										<xsl:when test="$stage = 'published' and $doctype = 'standard'">
											<fo:block font-family="Arial" font-weight="bold" margin-top="13mm" space-after="12pt">
												<fo:block font-size="18pt">IEEE Standard for</fo:block>
												<fo:block font-size="18pt">
													<!-- Example Local and Metropolitan Area Networks— -->
													<xsl:text>    </xsl:text>
													<xsl:copy-of select="$title_intro"/>
												</fo:block>
												<fo:block font-size="24pt" space-before="12pt">
													<!-- Example: Port-Based Network Access Control -->
													<xsl:copy-of select="$title_main"/>
												</fo:block>
											</fo:block>
										</xsl:when>
										
										<xsl:otherwise> <!-- ($doctype = 'international-standard' and $isDraft = 'false') or $doctype = 'whitepaper' or $doctype = 'icap-whitepaper' or $doctype = 'industry-connection-report' -->
										
											<xsl:attribute name="font-family">Calibri Light</xsl:attribute>
											<xsl:attribute name="font-size">12pt</xsl:attribute>
											
											<fo:block font-family="Arial Black" font-size="20pt" margin-top="18pt">
												<xsl:copy-of select="$title"/>
												<!-- <xsl:copy-of select="$draft_title_part"/> -->
											</fo:block>
											<xsl:call-template name="addBlueBox"/>
											<!-- <fo:block font-size="1" margin-top="3mm">
												<fo:instream-foreign-object content-width="57mm" content-height="3mm" scaling="non-uniform" fox:alt-text="Image Box">
													<xsl:call-template name="insertImageBoxSVG">
														<xsl:with-param name="color"><xsl:value-of select="$color_blue"/></xsl:with-param>
													</xsl:call-template>
												</fo:instream-foreign-object>
											</fo:block>
											<fo:block margin-top="12pt" margin-bottom="12pt">&#xa0;</fo:block> -->
											<fo:block margin-bottom="12pt"> </fo:block>
										</xsl:otherwise>
									</xsl:choose>
									
								</xsl:if>
								
								<xsl:apply-templates select="*" mode="page"/>
								<xsl:if test="position() = last()"><fo:block id="lastBlockMain"/></xsl:if>
							</fo:flow>
						</fo:page-sequence>
					</xsl:for-each>
					<!-- ===================== -->
					<!-- End IEEE pages -->
					<!-- ===================== -->
						
						
					<!-- ======================= -->
					<!-- Back page -->
					<!-- ======================= -->
					<xsl:choose>
						<xsl:when test="$doctype = 'standard' and $stage = 'published'">
							<xsl:call-template name="insertBackPage_Standard"/>
						</xsl:when>
						<!-- <xsl:when test="$doctype = 'industry-connection-report'">
							<xsl:call-template name="insertBackPage_IndustryConnectionReport"/>
						</xsl:when> -->
						<xsl:when test="$doctype = 'whitepaper' or $doctype = 'icap-whitepaper' or $doctype = 'industry-connection-report'">
							<xsl:call-template name="insertBackPage_NonStandard"/>
						</xsl:when>
					</xsl:choose>
					<!-- ======================= -->
					<!-- END Back page -->
					<!-- ======================= -->
					<xsl:if test="not(xalan:nodeset($paged_xml)/*[local-name()='page'][*])">
						<fo:page-sequence master-reference="document-nonstandard" force-page-count="no-force">
							<fo:flow flow-name="xsl-region-body">
								<fo:block><!-- prevent fop error for empty document --></fo:block>
							</fo:flow>
						</fo:page-sequence>
					</xsl:if>
				
				</xsl:for-each>
			</xsl:for-each> <!-- END of //ieee-standard iteration -->
			
			<xsl:if test="not(//ieee:ieee-standard)">
				<fo:page-sequence master-reference="document-nonstandard" force-page-count="no-force">
					<fo:flow flow-name="xsl-region-body">
						<fo:block><!-- prevent fop error for empty document --></fo:block>
					</fo:flow>
				</fo:page-sequence>
			</xsl:if>
			
			
		</fo:root>
	</xsl:template>
	
	
	<xsl:template match="ieee:boilerplate/ieee:copyright-statement//ieee:p" priority="2">
		<fo:block margin-top="6pt" margin-bottom="6pt" text-align="justify">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	
	<xsl:template match="ieee:boilerplate/ieee:license-statement//ieee:p" priority="2">
		<fo:block margin-top="6pt" margin-bottom="6pt" text-align="justify">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	
	<xsl:template match="ieee:boilerplate/ieee:feedback-statement" priority="2">
		<fo:block>
			<fo:footnote>
				<fo:inline/>
				<fo:footnote-body font-family="Arial" font-size="7pt">
				
					<xsl:if test="$doctype = 'whitepaper' or $doctype = 'icap-whitepaper' or $doctype = 'industry-connection-report'">
						<xsl:attribute name="font-family">Calibri Light</xsl:attribute>
						<xsl:attribute name="font-size">9pt</xsl:attribute>
						<xsl:attribute name="line-height">1.2</xsl:attribute>
					</xsl:if>
					
					<xsl:if test="$doctype = 'standard' and $stage = 'published'">
						<xsl:attribute name="font-size">8pt</xsl:attribute>
					</xsl:if>
				
					<fo:block>
						<fo:inline font-size="1pt" id="footnote_footer_{generate-id()}"><xsl:value-of select="$hair_space"/></fo:inline>
						<xsl:apply-templates/>
					</fo:block>
				</fo:footnote-body>
			</fo:footnote>
		</fo:block>
	</xsl:template>
	
	<xsl:template match="ieee:boilerplate/ieee:feedback-statement//ieee:p" priority="2">
		<fo:block margin-bottom="6pt">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	
	<xsl:template match="ieee:boilerplate/ieee:legal-statement" priority="2">
		<fo:block break-after="page"/>
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="ieee:boilerplate/ieee:legal-statement/ieee:clause[@id = 'boilerplate-participants' or ieee:title = 'Participants']" priority="2">
		<fo:block break-after="page"/>
		<fo:block id="{@id}">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	
	<!-- Example: Important Notices and Disclaimers Concerning IEEE Standards Documents -->
	<xsl:template match="ieee:boilerplate/ieee:legal-statement//ieee:title" priority="3">
		<xsl:variable name="level">
			<xsl:call-template name="getLevel"/>
		</xsl:variable>
		<fo:block font-family="Arial" font-weight="bold" margin-bottom="12pt" space-before="18pt" keep-with-next="always" keep-together.within-column="always" role="H{$level}">
			<xsl:attribute name="font-size">
				<xsl:choose>
					<xsl:when test="$level = '1'">12pt</xsl:when>
					<xsl:otherwise>11pt</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			
			<xsl:if test="$doctype = 'whitepaper' or $doctype = 'icap-whitepaper' or $doctype = 'industry-connection-report'">
				<xsl:attribute name="font-family">Arial Black</xsl:attribute>
				<xsl:attribute name="font-size">13pt</xsl:attribute>
			</xsl:if>
			
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	
	<xsl:template match="ieee:boilerplate/ieee:legal-statement//ieee:p" priority="2">
		<xsl:choose>
			<xsl:when test="@type = 'officemember' and not(preceding-sibling::*[1][self::ieee:p][@type = 'officemember'])"> <!-- special case -->
			
				<xsl:variable name="officemembers_">
					<officemember><xsl:copy-of select="node()"/></officemember>
					<xsl:variable name="pos_curr" select="count(preceding-sibling::*) + 1"/>
					<xsl:variable name="pos_end" select="count(following-sibling::*[not(@type = 'officemember')][1]/preceding-sibling::*)"/>
					<xsl:variable name="p_count" select="$pos_end - $pos_curr"/>
					<xsl:for-each select="following-sibling::ieee:p[position() &lt;= $p_count]">
						<officemember><xsl:copy-of select="node()"/></officemember>
					</xsl:for-each>
				</xsl:variable>
				<xsl:variable name="officemembers" select="xalan:nodeset($officemembers_)"/>
				
				<xsl:variable name="officemembers_count" select="count($officemembers/officemember)"/>
				
				<xsl:variable name="mod" select="$officemembers_count mod 3"/>
				<xsl:variable name="floor" select="floor($officemembers_count div 3)"/>
				
				<xsl:variable name="max">
					<xsl:choose>
						<xsl:when test="$mod = 0"><xsl:value-of select="$officemembers_count div 3"/></xsl:when>
						<xsl:otherwise><xsl:value-of select="$floor + 1"/></xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				
				<!-- <fo:block>officemembers_count=<xsl:value-of select="$officemembers_count"/></fo:block>
				<fo:block>mod=<xsl:value-of select="$mod"/></fo:block>
				<fo:block>floor=<xsl:value-of select="$floor"/></fo:block>
				<fo:block>max=<xsl:value-of select="$max"/></fo:block> -->
				
				<fo:block font-size="9pt">
					<fo:block> </fo:block>
					<fo:table width="100%" table-layout="fixed">
						<fo:table-column column-width="proportional-column-width(55)"/>
						<fo:table-column column-width="proportional-column-width(55)"/>
						<fo:table-column column-width="proportional-column-width(42)"/>
						<fo:table-body>
							<xsl:for-each select="$officemembers/officemember[position() &lt;= $max]">
								<fo:table-row>
									<fo:table-cell>
										<fo:block>
											<xsl:apply-templates/>
										</fo:block>
									</fo:table-cell>
									<fo:table-cell>
										<fo:block>
											<xsl:apply-templates select="following-sibling::*[number($max)]/node()"/>
										</fo:block>
									</fo:table-cell>
									<fo:table-cell>
										<fo:block>
											<xsl:apply-templates select="following-sibling::*[number($max) * 2]/node()"/>
										</fo:block>
									</fo:table-cell>
								</fo:table-row>
							</xsl:for-each>
						</fo:table-body>
					</fo:table>
				</fo:block>
				
				<xsl:if test="following-sibling::*[not(@type = 'officemember' or @type = 'emeritus_sign')]">
					<fo:block font-size="10pt" space-after="12pt"> </fo:block>
				</xsl:if>
			</xsl:when> <!-- @type = 'officemember' -->
			
			<xsl:when test="@type = 'officemember' and preceding-sibling::*[1][self::ieee:p][@type = 'officemember']"><!-- skip --></xsl:when>
			
			<xsl:when test="@type = 'emeritus_sign'">
				<fo:block font-size="9pt" margin-left="9.4mm">
					<xsl:apply-templates/>
				</fo:block>
			</xsl:when>
			
			<xsl:otherwise>
				<fo:block space-after="12pt">
					<xsl:if test="@align = 'center' and ancestor::ieee:clause[@id = 'boilerplate-participants' or ieee:title = 'Participants'] and following-sibling::*[1][self::ieee:p and @align = 'center']">
						<xsl:attribute name="space-after">0</xsl:attribute>
					</xsl:if>
					<xsl:call-template name="setTextAlignment">
						<xsl:with-param name="default">justify</xsl:with-param>
					</xsl:call-template>
					
					<xsl:if test="$doctype = 'whitepaper' or $doctype = 'icap-whitepaper' or $doctype = 'industry-connection-report'">
						<xsl:attribute name="font-size">10pt</xsl:attribute>
						<xsl:attribute name="font-family">Calibri Light</xsl:attribute>
						<xsl:attribute name="line-height"><xsl:value-of select="$line-height"/></xsl:attribute>
					</xsl:if>
					
					<xsl:if test="$doctype = 'standard' and $stage = 'published'">
						<xsl:attribute name="font-size">9pt</xsl:attribute>
						<xsl:attribute name="font-family">Times New Roman</xsl:attribute>
						<xsl:attribute name="space-after">6pt</xsl:attribute>
					</xsl:if>
					
					<xsl:apply-templates/>
				</fo:block>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="ieee:abstract">
		<fo:block>
			<xsl:call-template name="setId"/>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	
	<!-- for 'draft' -->
	<xsl:template match="ieee:preface/ieee:abstract/ieee:p[1] | /ieee:ieee-standard/ieee:preface/ieee:clause[@id = '_abstract' or ieee:title = 'Abstract']/ieee:p[1]" priority="2">
		<fo:inline><xsl:apply-templates/></fo:inline>
	</xsl:template>
	
	<xsl:template match="text()" priority="2" mode="uppercase">
		<xsl:value-of select="java:toUpperCase(java:java.lang.String.new(.))"/>
	</xsl:template>
	<xsl:template match="node()" mode="uppercase">
		<xsl:copy>
			<xsl:apply-templates select="node()" mode="uppercase"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="text()" priority="2" mode="smallcaps">
		<xsl:call-template name="tocSmallCaps">
			<xsl:with-param name="text" select="."/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="node()" mode="uppercase">
		<xsl:copy>
			<xsl:apply-templates select="node()" mode="smallcaps"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template name="tocSmallCaps">
		<xsl:param name="text"/>
		<xsl:param name="font-size">9pt</xsl:param>
		<xsl:variable name="char" select="substring($text,1,1)"/>
		<xsl:variable name="upperCase" select="java:toUpperCase(java:java.lang.String.new($char))"/>
		<xsl:choose>
			<xsl:when test="$char = ' '">
				<xsl:value-of select="$char"/>
			</xsl:when>
			<xsl:when test="$char != $upperCase">
				<fo:inline font-size="{$font-size}">
					<xsl:value-of select="$upperCase"/>
				</fo:inline>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$upperCase"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="string-length($text) &gt; 1">
			<xsl:call-template name="tocSmallCaps">
				<xsl:with-param name="text" select="substring($text,2)"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>


	<xsl:template match="*[local-name() = 'br']" priority="2" mode="contents_item">
		<xsl:text> </xsl:text>
	</xsl:template>

	<xsl:template match="*[local-name() = 'strong']" priority="2" mode="contents_item">
		<xsl:copy>
			<xsl:apply-templates mode="contents_item"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template name="makePagedXML">
		<xsl:param name="structured_xml"/>
		<xsl:choose>
			<xsl:when test="not(xalan:nodeset($structured_xml)/*[local-name()='pagebreak'])">
				<xsl:element name="page" namespace="https://www.metanorma.org/ns/ieee">
					<xsl:copy-of select="xalan:nodeset($structured_xml)"/>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="xalan:nodeset($structured_xml)/*[local-name()='pagebreak']">
			
					<xsl:variable name="pagebreak_id" select="generate-id()"/>
					<!-- <xsl:variable name="pagebreak_previous_orientation" select="normalize-space(preceding-sibling::ieee:pagebreak[1]/@orientation)"/> -->
					
					<!-- copy elements before pagebreak -->
					<xsl:element name="page" namespace="https://www.metanorma.org/ns/ieee">
						<xsl:if test="not(preceding-sibling::ieee:pagebreak)">
							<xsl:copy-of select="../@*"/>
						</xsl:if>
						<!-- copy previous pagebreak orientation -->
						<xsl:copy-of select="preceding-sibling::ieee:pagebreak[1]/@orientation"/>
						<!-- <xsl:if test="$pagebreak_previous_orientation != ''">
							<xsl:attribute name="orientation"><xsl:value-of select="$pagebreak_previous_orientation"/></xsl:attribute>
						</xsl:if> -->
						<xsl:copy-of select="preceding-sibling::node()[following-sibling::ieee:pagebreak[1][generate-id(.) = $pagebreak_id]][not(local-name() = 'pagebreak')]"/>
					</xsl:element>
					
					<!-- copy elements after last page break -->
					<xsl:if test="position() = last() and following-sibling::node()">
						<xsl:element name="page" namespace="https://www.metanorma.org/ns/ieee">
							<xsl:copy-of select="@orientation"/>
							<xsl:copy-of select="following-sibling::node()"/>
						</xsl:element>
					</xsl:if>
	
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="node()">		
		<xsl:apply-templates/>			
	</xsl:template>


	<!-- ============================= -->
	<!-- CONTENTS                      -->
	<!-- ============================= -->
	
	<!-- element with title -->
	<xsl:template match="*[ieee:title]" mode="contents">
	
		<xsl:variable name="level">
			<xsl:call-template name="getLevel">
				<xsl:with-param name="depth" select="ieee:title/@depth"/>
			</xsl:call-template>
		</xsl:variable>
		
		<!-- if previous clause contains section-title as latest element (section-title may contain  note's, admonition's, etc.),
		and if @depth of current clause equals to section-title @depth,
		then put section-title before current clause -->
		<xsl:if test="local-name() = 'clause'">
			<xsl:apply-templates select="preceding-sibling::*[1][local-name() = 'clause']//*[local-name() = 'p' and @type = 'section-title'     and @depth = $level      and not(following-sibling::*[local-name()='clause'])]" mode="contents_in_clause"/>
		</xsl:if>
		
		<xsl:variable name="section">
			<xsl:call-template name="getSection"/>
		</xsl:variable>
		
		<xsl:variable name="type">
			<xsl:choose>
				<xsl:when test="local-name() = 'indexsect'">index</xsl:when>
				<xsl:when test="(ancestor-or-self::ieee:bibliography and local-name() = 'clause' and not(.//*[local-name() = 'references' and @normative='true'])) or self::ieee:references[not(@normative) or @normative='false']">bibliography</xsl:when>
				<xsl:otherwise><xsl:value-of select="local-name()"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
			
		<xsl:variable name="display">
			<xsl:choose>
				<xsl:when test="normalize-space(@id) = ''">false</xsl:when>
				
				<!-- <xsl:when test="ancestor-or-self::ieee:annex and $level &gt;= 2">false</xsl:when> -->
				<xsl:when test="$type = 'bibliography' and $level &gt;= 2">false</xsl:when>
				<xsl:when test="$type = 'bibliography'">true</xsl:when>
				<xsl:when test="$type = 'references' and $level &gt;= 2">false</xsl:when>
				<xsl:when test="$section = '' and $type = 'clause' and $level = 1 and ancestor::ieee:preface">true</xsl:when>
				<xsl:when test="$section = '' and $type = 'clause'">false</xsl:when>
				<xsl:when test="$level &lt;= $toc_level">true</xsl:when>
				<xsl:otherwise>false</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="skip">
			<xsl:choose>
				<xsl:when test="($stage = 'draft' or $stage = 'published') and $doctype = 'standard' and ancestor-or-self::ieee:preface">true</xsl:when> <!-- no need render preface sections in ToC -->
				<xsl:when test="ancestor-or-self::ieee:bibitem">true</xsl:when>
				<xsl:when test="ancestor-or-self::ieee:term">true</xsl:when>				
				<xsl:when test="@type = 'corrigenda'">true</xsl:when>
				<xsl:otherwise>false</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		
		<xsl:if test="$skip = 'false'">		
		
			<xsl:variable name="title">
				<xsl:call-template name="getName"/>
			</xsl:variable>
			
			<xsl:variable name="root">
				<xsl:if test="ancestor-or-self::ieee:preface">preface</xsl:if>
				<xsl:if test="ancestor-or-self::ieee:annex">annex</xsl:if>
			</xsl:variable>
			
			<item id="{@id}" level="{$level}" section="{$section}" type="{$type}" root="{$root}" display="{$display}">
				<xsl:if test="$type = 'index'">
					<xsl:attribute name="level">1</xsl:attribute>
				</xsl:if>
				<title>
					<xsl:apply-templates select="xalan:nodeset($title)" mode="contents_item">
						<xsl:with-param name="mode">contents</xsl:with-param>
					</xsl:apply-templates>
				</title>
				<xsl:if test="$type != 'index'">
					<xsl:apply-templates mode="contents"/>
				</xsl:if>
			</item>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="ieee:figure[ieee:name] | ieee:table[ieee:name and not(@unnumbered = 'true' and java:endsWith(java:java.lang.String.new(ieee:name),'Key'))]" priority="2" mode="contents">		
		<xsl:if test="$doctype = 'whitepaper' or $doctype = 'icap-whitepaper' or $doctype = 'industry-connection-report'">
			<xsl:variable name="level">
				<xsl:for-each select="ancestor::ieee:clause[1] | ancestor::ieee:annex[1]">
					<xsl:call-template name="getLevel">
						<xsl:with-param name="depth" select="ieee:title/@depth"/>
					</xsl:call-template>
				</xsl:for-each>
			</xsl:variable>
			<item id="{@id}" level="{$level}" section="" type="{local-name()}" root="" display="true">
				<xsl:variable name="name">
					<xsl:apply-templates select="ieee:name" mode="contents_item">
						<xsl:with-param name="mode">contents</xsl:with-param>
					</xsl:apply-templates>
				</xsl:variable>
				<xsl:if test="not(contains(normalize-space($name), '—'))">
					<xsl:attribute name="display">false</xsl:attribute>
				</xsl:if>
				<title>
					<xsl:copy-of select="$name"/>
				</title>
			</item>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*[local-name()='add'][parent::*[local-name() = 'name'] and ancestor::*[local-name() = 'figure'] and normalize-space(following-sibling::node()) = '']" mode="contents_item" priority="2"/>

	<xsl:template match="text()" mode="contents_item">
		<xsl:choose>
			<xsl:when test="contains(., $non_breaking_hyphen)">
				<xsl:call-template name="replaceChar">
					<xsl:with-param name="text" select="."/>
					<xsl:with-param name="replace" select="$non_breaking_hyphen"/>
					<xsl:with-param name="by" select="'-'"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	
	<xsl:template name="insertListOf_Title">
		<xsl:param name="title"/>
		<fo:block role="TOCI" space-before="12pt" keep-with-next="always">
			<xsl:if test="$doctype = 'standard' and $stage = 'published'">
				<xsl:attribute name="font-size">12pt</xsl:attribute>
				<xsl:attribute name="font-weight">bold</xsl:attribute>
				<xsl:attribute name="font-family">Arial</xsl:attribute>
				<xsl:attribute name="margin-bottom">12pt</xsl:attribute>
			</xsl:if>
			<xsl:value-of select="$title"/>
		</fo:block>
	</xsl:template>
	
	<xsl:template name="insertListOf_Item">
	
		<xsl:choose>
			<xsl:when test="$doctype = 'standard' and $stage = 'published'">
				<fo:list-block provisional-distance-between-starts="22.5mm" font-weight="normal" role="TOCI" margin-left="2mm">
					
					<fo:list-item>
						<fo:list-item-label end-indent="label-end()">
							<fo:block>
								<fo:basic-link internal-destination="{@id}">
									<xsl:value-of select="substring-before(.,'—')"/>
								</fo:basic-link>
							</fo:block>
						</fo:list-item-label>
						<fo:list-item-body start-indent="body-start()">
							<fo:block text-align-last="justify">
								<fo:basic-link internal-destination="{@id}">
									<xsl:call-template name="setAltText">
										<xsl:with-param name="value" select="@alt-text"/>
									</xsl:call-template>
									<xsl:apply-templates select="." mode="contents"/>
									<fo:inline keep-together.within-line="always">
										<fo:leader font-weight="normal" leader-pattern="dots"/>
										<fo:inline><fo:page-number-citation ref-id="{@id}"/></fo:inline>
									</fo:inline>
								</fo:basic-link>
							</fo:block>
						</fo:list-item-body>
					</fo:list-item>
				</fo:list-block>
			
			</xsl:when>
			<xsl:otherwise>
				<fo:block role="TOCI" font-weight="normal" text-align-last="justify" margin-left="12mm">
					<fo:basic-link internal-destination="{@id}">
						<xsl:call-template name="setAltText">
							<xsl:with-param name="value" select="@alt-text"/>
						</xsl:call-template>
						<xsl:apply-templates select="." mode="contents"/>
						<fo:inline keep-together.within-line="always">
							<fo:leader font-weight="normal" leader-pattern="dots"/>
							<fo:inline><fo:page-number-citation ref-id="{@id}"/></fo:inline>
						</fo:inline>
					</fo:basic-link>
				</fo:block>		
			</xsl:otherwise>

		</xsl:choose>
		
	</xsl:template>
	
	<xsl:template match="*[local-name() = 'figures']/*[local-name() = 'figure']/*[local-name() = 'name']/text()[1] |         *[local-name() = 'tables']/*[local-name() = 'table']/*[local-name() = 'name']/text()[1]" mode="contents" priority="3">
		<xsl:choose>
			<xsl:when test="($doctype = 'standard' and $stage = 'published') and contains(.,'—')"><xsl:value-of select="substring-after(.,'—')"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- disable bold in ToC -->
	<xsl:template match="*[local-name() = 'item']/*[local-name() = 'title']/*[local-name() = 'strong']" priority="2">
		<xsl:apply-templates/>
	</xsl:template>
	
	
	<!-- ============================= -->
	<!-- ============================= -->
	
	
	<!-- ==================== -->
	<!-- display titles       -->
	<!-- ==================== -->
	<xsl:template match="ieee:bibdata/ieee:title[@type = 'title-intro']">
		<xsl:apply-templates/>
		<xsl:text>—</xsl:text>
	</xsl:template>

	<xsl:template match="ieee:bibdata/ieee:title[@type = 'title-main']">
		<xsl:apply-templates/>
	</xsl:template>
	
	<!-- ==================== -->
	<!-- display titles       -->
	<!-- ==================== -->
	
	<!-- ================================= -->
	<!-- XML Flattening -->
	<!-- ================================= -->
	<xsl:template match="@*|node()" mode="flatxml">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="flatxml"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="processing-instruction()" mode="flatxml">
		<xsl:copy-of select="."/>
	</xsl:template>
	
	<xsl:template match="ieee:preface//ieee:clause[@type = 'front_notes']" mode="flatxml" priority="2">
		<!-- ignore processing (source STS is front/notes) -->
	</xsl:template>
	
	<xsl:template match="ieee:foreword |            ieee:foreword//ieee:clause |            ieee:preface//ieee:clause[not(@type = 'corrigenda') and not(@type = 'related-refs')] |            ieee:introduction |            ieee:introduction//ieee:clause |            ieee:sections//ieee:clause |             ieee:annex |             ieee:annex//ieee:clause |             ieee:references |            ieee:bibliography/ieee:clause |             *[local-name()='sections']//*[local-name()='terms'] |             *[local-name()='sections']//*[local-name()='definitions'] |            *[local-name()='annex']//*[local-name()='definitions']" mode="flatxml" name="clause">
		<!-- From:
		<clause>
			<title>...</title>
			<p>...</p>
		</clause>
		To:
			<clause/>
			<title>...</title>
			<p>...</p>
		-->
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="flatxml"/>
			<xsl:attribute name="keep-with-next">always</xsl:attribute>
			<xsl:if test="local-name() = 'foreword' or local-name() = 'introduction' or    local-name(..) = 'preface' or local-name(..) = 'sections' or     (local-name() = 'references' and parent::*[local-name() = 'bibliography']) or    (local-name() = 'clause' and parent::*[local-name() = 'bibliography']) or    local-name() = 'annex' or     local-name(..) = 'annex'">
				<xsl:attribute name="mainsection">true</xsl:attribute>
			</xsl:if>
			
		</xsl:copy>
		<xsl:apply-templates mode="flatxml"/>
		
	</xsl:template>
	
	<xsl:template match="ieee:term" mode="flatxml" priority="2">
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="flatxml"/>
			<xsl:attribute name="keep-with-next">always</xsl:attribute>
			<xsl:variable name="level">
				<xsl:call-template name="getLevel"/>
			</xsl:variable>
			<xsl:attribute name="depth"><xsl:value-of select="$level"/></xsl:attribute>
			<xsl:attribute name="ancestor">sections</xsl:attribute>
			<xsl:apply-templates select="node()[not(self::ieee:term)]" mode="flatxml"/>
		</xsl:copy>
		<xsl:apply-templates select="ieee:term" mode="flatxml"/>
	</xsl:template>
	
	<xsl:template match="ieee:introduction//ieee:title | ieee:foreword//ieee:title | ieee:sections//ieee:title | ieee:annex//ieee:title | ieee:bibliography/ieee:clause/ieee:title | ieee:references/ieee:title" mode="flatxml" priority="2"> <!-- | ieee:term -->
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="flatxml"/>
			<xsl:attribute name="keep-with-next">always</xsl:attribute>
			<xsl:variable name="level">
				<xsl:call-template name="getLevel"/>
			</xsl:variable>
			<xsl:attribute name="depth"><xsl:value-of select="$level"/></xsl:attribute>
			<xsl:if test="parent::ieee:annex">
				<xsl:attribute name="depth">1</xsl:attribute>
			</xsl:if>
			<xsl:if test="../@inline-header = 'true'">
				<xsl:copy-of select="../@inline-header"/>
			</xsl:if>
			<xsl:attribute name="ancestor">
				<xsl:choose>
					<xsl:when test="ancestor::ieee:foreword">foreword</xsl:when>
					<xsl:when test="ancestor::ieee:introduction">introduction</xsl:when>
					<xsl:when test="ancestor::ieee:sections">sections</xsl:when>
					<xsl:when test="ancestor::ieee:annex">annex</xsl:when>
					<xsl:when test="ancestor::ieee:bibliography">bibliography</xsl:when>
				</xsl:choose>
			</xsl:attribute>
			
			<xsl:apply-templates mode="flatxml"/>
		</xsl:copy>
	</xsl:template>
	
	<!-- recalculate table width -->
	<!-- 210 - (15+22+20) = 153 -->
	<xsl:variable name="max_table_width_mm" select="$pageWidth - ($marginLeftRight1 + $marginLeftRight2)"/> 
	<!-- 153 / 25.4 * 96 dpi = 578px-->
	<xsl:variable name="max_table_width_px" select="round($max_table_width_mm div 25.4 * 96)"/> 
	<!-- landscape table -->
	<xsl:variable name="max_table_landscape_width_mm" select="$pageHeight - ($marginTop + $marginBottom)"/> 
	<xsl:variable name="max_table_landscape_width_px" select="round($max_table_landscape_width_mm div 25.4 * 96)"/> 
	
	<xsl:template match="ieee:table/@width[contains(., 'px')]" mode="flatxml">
		<xsl:variable name="width" select="number(substring-before(., 'px'))"/>
		<xsl:variable name="isLandscapeTable" select="../preceding-sibling::*[local-name() != 'table'][1]/@orientation = 'landscape'"/>
		<xsl:attribute name="width">
			<xsl:choose>
				<xsl:when test="normalize-space($isLandscapeTable) = 'true' and $width &gt; $max_table_landscape_width_px"><xsl:value-of select="$max_table_landscape_width_px"/>px</xsl:when>
				<xsl:when test="normalize-space($isLandscapeTable) = 'false' and $width &gt; $max_table_width_px"><xsl:value-of select="$max_table_width_px"/>px</xsl:when>
				<xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
	</xsl:template>
	
	<!-- add @to = figure, table, clause -->
	<!-- add @depth = from  -->
	<xsl:template match="ieee:xref" mode="flatxml">
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="flatxml"/>
			<xsl:variable name="target" select="@target"/>
			<xsl:attribute name="to">
				<xsl:value-of select="local-name(//*[@id = current()/@target][1])"/>
			</xsl:attribute>
			<xsl:attribute name="depth">
				<xsl:value-of select="//*[@id = current()/@target][1]/ieee:title/@depth"/>
			</xsl:attribute>
			<xsl:apply-templates select="node()" mode="flatxml"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="text()" mode="flatxml">
		<xsl:choose>
			<xsl:when test="contains(., $non_breaking_hyphen)">
				<xsl:call-template name="replaceChar">
					<xsl:with-param name="text" select="."/>
					<xsl:with-param name="replace" select="$non_breaking_hyphen"/>
					<xsl:with-param name="by" select="'-'"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	
	
	<!-- remove newlines chars (0xd 0xa, 0xa, 0xd) in p, em, strong (except in sourcecode). -->
	<xsl:template match="*[not(ancestor::ieee:sourcecode)]/*[self::ieee:p or self::ieee:strong or self::ieee:em]/text()" mode="flatxml">
		<xsl:choose>
			<xsl:when test=". = '&#13;' or . = '&#10;' or . = '&#13;&#10;'"/>
			<xsl:when test="contains(., $non_breaking_hyphen)">
				<xsl:call-template name="replaceChar">
					<xsl:with-param name="text" select="."/>
					<xsl:with-param name="replace" select="$non_breaking_hyphen"/>
					<xsl:with-param name="by" select="'-'"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- change @reference to actual value, and add skip_footnote_body="true" for repeatable (2nd, 3rd, ...) -->
	<!--
	<fn reference="1">
			<p id="_8e5cf917-f75a-4a49-b0aa-1714cb6cf954">Formerly denoted as 15 % (m/m).</p>
		</fn>
	-->
	
	<xsl:template match="*[local-name() = 'fn'][not(ancestor::*[(local-name() = 'table' or local-name() = 'figure') and not(ancestor::*[local-name() = 'name'])])]" mode="flatxml">
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
		<xsl:variable name="current_fn_number" select="count($p_fn//fn[@reference = $reference]/preceding-sibling::fn) + 1"/>
		
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="flatxml"/>
			<!-- put actual reference number -->
			<xsl:attribute name="current_fn_number">
				<xsl:value-of select="$current_fn_number"/>
			</xsl:attribute>
			<xsl:attribute name="skip_footnote_body"> <!-- false for repeatable footnote -->
				<xsl:value-of select="not($p_fn//fn[@gen_id = $gen_id] and (1 = 1))"/>
			</xsl:attribute>
			<xsl:apply-templates select="node()" mode="flatxml"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*[local-name() = 'bibitem']/*[local-name() = 'note']" mode="flatxml">
		<xsl:variable name="p_fn_">
			<xsl:call-template name="get_fn_list"/>
		</xsl:variable>
		<xsl:variable name="p_fn" select="xalan:nodeset($p_fn_)"/>
		<xsl:variable name="gen_id" select="generate-id(.)"/>
		<xsl:variable name="lang" select="ancestor::*[contains(local-name(), '-standard')]/*[local-name()='bibdata']//*[local-name()='language'][@current = 'true']"/>
		<xsl:variable name="reference" select="@reference"/> <!-- @reference added to bibitem/note in step 'update_xml_step2' -->
		<!-- fn sequence number in document -->
		<xsl:variable name="current_fn_number" select="count($p_fn//fn[@reference = $reference]/preceding-sibling::fn) + 1"/>
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="flatxml"/>
			<!-- put actual reference number -->
			<xsl:attribute name="current_fn_number">
				<xsl:value-of select="$current_fn_number"/>
			</xsl:attribute>
			<xsl:apply-templates select="node()" mode="flatxml"/>
		</xsl:copy>
	</xsl:template>
	
	
	<xsl:template match="ieee:p[@type = 'section-title']" priority="3" mode="flatxml">
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="flatxml"/>
			<xsl:if test="@depth = '1'">
				<xsl:attribute name="mainsection">true</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates select="node()" mode="flatxml"/>
		</xsl:copy>
	</xsl:template>
	
	<!-- ================================= -->
	<!-- END of XML Flattening -->
	<!-- ================================= -->
	
	
	<xsl:template match="*" priority="3" mode="page">
		<xsl:call-template name="elementProcessing"/>
	</xsl:template>
	
	<xsl:template match="ieee:clauses_union/*" priority="3" mode="clauses_union">
		<xsl:call-template name="elementProcessing"/>
	</xsl:template>
	
	<xsl:template name="elementProcessing">
		<xsl:choose>
			<xsl:when test="local-name() = 'p' and count(node()) = count(processing-instruction())"><!-- skip --></xsl:when> <!-- empty paragraph with processing-instruction -->
			<xsl:when test="@hidden = 'true'"><!-- skip --></xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="local-name() = 'title' or local-name() = 'term'">
						<xsl:apply-templates select="."/>
					</xsl:when>
					<!-- <xsl:when test="not(node()) and @mainsection = 'true'"> -->
					<xsl:when test="@mainsection = 'true'">
						<fo:block>
							<xsl:attribute name="keep-with-next">always</xsl:attribute>
							<xsl:apply-templates select="."/>
						</fo:block>
					</xsl:when>
					<xsl:when test="local-name() = 'indexsect'">
						<xsl:apply-templates select="." mode="index"/>
					</xsl:when>
					<xsl:otherwise>
							<fo:block-container>
								<xsl:if test="not(node())">
									<xsl:attribute name="keep-with-next">always</xsl:attribute>
								</xsl:if>
								<fo:block>
									<xsl:apply-templates select="."/>
								</fo:block>
							</fo:block-container>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	

	<xsl:template match="/*/ieee:bibdata/ieee:docidentifier[@type = 'ISBN']">
		<fo:block space-after="6pt">
			<fo:inline>
				<xsl:attribute name="font-weight">bold</xsl:attribute>
				<xsl:text>ISBN </xsl:text>
			</fo:inline>
			<xsl:value-of select="."/>
		</fo:block>
	</xsl:template>

					
	<xsl:template match="*[local-name() = 'introduction'] | *[local-name() = 'foreword']">
		<fo:block>
			<xsl:call-template name="setId"/>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>


	<!-- ====== -->
	<!-- title      -->
	<!-- ====== -->
	
	<!-- <xsl:template match="ieee:annex/ieee:title">
		<fo:block font-size="16pt" text-align="center" margin-bottom="48pt" keep-with-next="always">
			<xsl:apply-templates />
		</fo:block>
	</xsl:template> -->
	
	<!-- Bibliography -->
	<xsl:template match="ieee:references[not(@normative='true')]/ieee:title">
		<fo:block font-size="16pt" font-weight="bold" margin-top="6pt" margin-bottom="36pt" keep-with-next="always" role="H1">
				<xsl:apply-templates/>
			</fo:block>
	</xsl:template>
	
	
	<xsl:template match="ieee:title[@inline-header = 'true'][following-sibling::*[1][local-name() = 'p'] or following-sibling::*[1][local-name() = 'clause'] or not(following-sibling::*)]" priority="3">
		<fo:block>
			<xsl:attribute name="space-before">
				<xsl:call-template name="getTitleMarginTop"/>
			</xsl:attribute>
			<xsl:attribute name="margin-bottom">
				<xsl:call-template name="getTitleMarginBottom"/>
			</xsl:attribute>
			<xsl:call-template name="title"/>
			<xsl:apply-templates select="following-sibling::*[1][local-name() = 'p']">
				<xsl:with-param name="inline-header">true</xsl:with-param>
			</xsl:apply-templates>
		</fo:block>
	</xsl:template>
	
	<xsl:template match="ieee:clauses_union" priority="4">
		<fo:block-container margin-left="-1.5mm" margin-right="-0.5mm">
			<fo:block-container margin="0mm" padding-left="0.5mm" padding-top="0.1mm" padding-bottom="2.5mm">
				<xsl:apply-templates mode="clauses_union"/>
			</fo:block-container>
		</fo:block-container>
	</xsl:template>
	
	<xsl:template name="getTitleMarginTop">
		<xsl:variable name="level">
			<xsl:call-template name="getLevel"/>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$doctype = 'whitepaper' or $doctype = 'icap-whitepaper' or $doctype = 'industry-connection-report'">
				<xsl:choose>
					<xsl:when test="$level = 2">22.4pt</xsl:when>
					<xsl:when test="$level = 3">4.6pt</xsl:when>
					<xsl:otherwise>0mm</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$doctype = 'standard' and $stage = 'published'">
				<xsl:choose>
					<xsl:when test="$level = 1">12pt</xsl:when>
					<xsl:when test="$level = 2">12pt</xsl:when>
					<xsl:when test="$level &gt;= 3">12pt</xsl:when>
					<xsl:otherwise>0mm</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$level = 1">18pt</xsl:when>
					<xsl:when test="$level = 2">18pt</xsl:when>
					<xsl:when test="$level &gt;= 3">12pt</xsl:when>
					<xsl:otherwise>0mm</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="getTitleMarginBottom">
		<xsl:choose>
			<xsl:when test="$doctype = 'whitepaper' or $doctype = 'icap-whitepaper' or $doctype = 'industry-connection-report'">
				<xsl:choose>
					<xsl:when test="ancestor::ieee:abstract">6pt</xsl:when>
					<xsl:otherwise>12pt</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>12pt</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="ieee:title" priority="2" name="title">
	
		<xsl:variable name="level">
			<xsl:call-template name="getLevel"/>
		</xsl:variable>
		
		<xsl:variable name="font-family">
			<xsl:choose>
				<xsl:when test="$doctype = 'whitepaper' or $doctype = 'icap-whitepaper' or $doctype = 'industry-connection-report'">Arial Black</xsl:when>
				<xsl:otherwise>Arial</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="font-size">
			<xsl:choose>
				<xsl:when test="$doctype = 'whitepaper' or $doctype = 'icap-whitepaper' or $doctype = 'industry-connection-report'">
					<xsl:choose>
						<xsl:when test="ancestor::ieee:abstract">13pt</xsl:when>
						<xsl:when test="$level = 1">20pt</xsl:when>
						<xsl:when test="$level = 2">16pt</xsl:when>
						<xsl:when test="$level = 3">13pt</xsl:when>
						<xsl:otherwise>11pt</xsl:otherwise> <!-- 4th, ... levels -->
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="@type = 'section-title'">12pt</xsl:when>
						<xsl:when test="$level = 1">12pt</xsl:when>
						<xsl:when test="$level = 2">11pt</xsl:when>
						<xsl:otherwise>10pt</xsl:otherwise> <!-- 3rd, 4th, ... levels -->
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="font-weight">
			<xsl:choose>
				<xsl:when test="$doctype = 'whitepaper' or $doctype = 'icap-whitepaper' or $doctype = 'industry-connection-report'">normal</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="@ancestor = 'annex' and $level = 1">normal</xsl:when>
						<xsl:otherwise>bold</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="margin-top">
			<xsl:call-template name="getTitleMarginTop"/>
		</xsl:variable>
		
		<xsl:variable name="margin-bottom">
			<xsl:call-template name="getTitleMarginBottom"/>
		</xsl:variable>
			<!-- <xsl:choose>
				<xsl:when test="$level = 1">12pt</xsl:when>
				<xsl:otherwise>12pt</xsl:otherwise>
			</xsl:choose>
		</xsl:variable> -->
		
		<xsl:variable name="element-name">
			<xsl:choose>
				<xsl:when test="@inline-header = 'true'">fo:inline</xsl:when>
				<xsl:otherwise>fo:block</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="attributes_">
			<attributes>
				<xsl:attribute name="font-family"><xsl:value-of select="$font-family"/></xsl:attribute>
				<xsl:attribute name="font-size"><xsl:value-of select="$font-size"/></xsl:attribute>
				<xsl:attribute name="font-weight"><xsl:value-of select="$font-weight"/></xsl:attribute>
				<xsl:attribute name="space-before"><xsl:value-of select="$margin-top"/></xsl:attribute>
				<xsl:attribute name="margin-bottom"><xsl:value-of select="$margin-bottom"/></xsl:attribute>
				<xsl:attribute name="keep-with-next">always</xsl:attribute>
				<xsl:attribute name="keep-together.within-column">always</xsl:attribute>
				
				<xsl:attribute name="role">H<xsl:value-of select="$level"/></xsl:attribute>
				
				<xsl:if test="@type = 'floating-title' or @type = 'section-title'">
					<xsl:copy-of select="@id"/>
				</xsl:if>
			</attributes>
		</xsl:variable>
		<xsl:variable name="attributes" select="xalan:nodeset($attributes_)"/>
		
		<xsl:variable name="section">
			<xsl:call-template name="extractSection"/>
		</xsl:variable>
		
		
		<xsl:choose>
			<xsl:when test="string-length($section) != 0 and $element-name = 'fo:block' and ($doctype = 'whitepaper' or $doctype = 'icap-whitepaper' or $doctype = 'industry-connection-report')">
				
				<xsl:variable name="provisional-distance-between-starts">
					<xsl:choose>
						<xsl:when test="$level = 1 and string-length($section) = 2">8.5mm</xsl:when>
						<xsl:when test="$level = 1 and string-length($section) = 3">13mm</xsl:when>
						<xsl:when test="$level &gt;= 2">17.8mm</xsl:when>
						<xsl:otherwise>10mm</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<fo:list-block provisional-distance-between-starts="{$provisional-distance-between-starts}">
				
					<xsl:copy-of select="$attributes/attributes/@*"/>
				
					<xsl:if test="$level = 1">
						<xsl:attribute name="line-height">20pt</xsl:attribute>
					</xsl:if>
				
					<fo:list-item>
						<fo:list-item-label end-indent="label-end()">
							<fo:block>
								<xsl:if test="$level = 1">
									<xsl:attribute name="color"><xsl:value-of select="$color_blue"/></xsl:attribute>
								</xsl:if>
								<xsl:value-of select="$section"/>
							</fo:block>
						</fo:list-item-label>
						<fo:list-item-body start-indent="body-start()">
							<fo:block>
							
								<!-- if first and last childs are `add` ace-tag, then move start ace-tag before title -->
								<xsl:if test="*[local-name() = 'tab'][1]/following-sibling::node()[last()][local-name() = 'add'][starts-with(text(), $ace_tag)]">
									<xsl:apply-templates select="*[local-name() = 'tab'][1]/following-sibling::node()[1][local-name() = 'add'][starts-with(text(), $ace_tag)]">
										<xsl:with-param name="skip">false</xsl:with-param>
									</xsl:apply-templates> 
								</xsl:if>
							
								<xsl:call-template name="extractTitle"/>
								
								<xsl:apply-templates select="following-sibling::*[1][local-name() = 'variant-title'][@type = 'sub']" mode="subtitle"/>
							</fo:block>
						</fo:list-item-body>
					</fo:list-item>
				</fo:list-block>
			
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="{$element-name}">
					
					<xsl:copy-of select="$attributes/attributes/@*"/>
					
					<!-- if first and last childs are `add` ace-tag, then move start ace-tag before title -->
					<xsl:if test="*[local-name() = 'tab'][1]/following-sibling::node()[last()][local-name() = 'add'][starts-with(text(), $ace_tag)]">
						<xsl:apply-templates select="*[local-name() = 'tab'][1]/following-sibling::node()[1][local-name() = 'add'][starts-with(text(), $ace_tag)]">
							<xsl:with-param name="skip">false</xsl:with-param>
						</xsl:apply-templates> 
					</xsl:if>
					
					<xsl:apply-templates/>
					<xsl:apply-templates select="following-sibling::*[1][local-name() = 'variant-title'][@type = 'sub']" mode="subtitle"/>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
			
			
		<xsl:if test="($doctype = 'whitepaper' or $doctype = 'icap-whitepaper' or $doctype = 'industry-connection-report') and preceding-sibling::*[1][self::ieee:references[@normative = 'false']]">
			<xsl:call-template name="addBlueBox"/>
		</xsl:if>
			
	</xsl:template>
	
	
	<xsl:template name="addBlueBox">
		<xsl:param name="width">57mm</xsl:param>
		<xsl:param name="height">3mm</xsl:param>
		<fo:block font-size="1" margin-top="3mm" margin-bottom="3mm">
			<fo:instream-foreign-object content-width="57mm" content-height="3mm" scaling="non-uniform" fox:alt-text="Image Box">
				<xsl:call-template name="insertImageBoxSVG">
					<xsl:with-param name="color"><xsl:value-of select="$color_blue"/></xsl:with-param>
				</xsl:call-template>
			</fo:instream-foreign-object>
		</fo:block>
	</xsl:template>
	
	<!-- add blue box after first break in Annex title -->
	<xsl:template match="*[local-name()='br'][not(preceding-sibling::ieee:br)][ancestor::ieee:title[preceding-sibling::*[1][self::ieee:annex]]]" priority="2">
		<xsl:choose>
			<xsl:when test="($doctype = 'whitepaper' or $doctype = 'icap-whitepaper' or $doctype = 'industry-connection-report') ">
				<xsl:call-template name="addBlueBox"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$linebreak"/>
			</xsl:otherwise>
			
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="ieee:term" priority="2">
	
		<xsl:variable name="level">
			<xsl:call-template name="getLevel"/>
		</xsl:variable>
		<!-- <fo:block>$level=<xsl:value-of select="$level"/></fo:block>
		<fo:block>@ancestor=<xsl:value-of select="@ancestor"/></fo:block> -->
		<xsl:variable name="font-size">
			<xsl:choose>
				<xsl:when test="@ancestor = 'sections' and $level = '2'">11pt</xsl:when>
				<xsl:when test="@ancestor = 'sections' and $level &gt; 2">11pt</xsl:when>
				<xsl:otherwise>11.5pt</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		
		<xsl:variable name="element-name">
			<xsl:choose>
				<xsl:when test="../@inline-header = 'true'">fo:inline</xsl:when>
				<xsl:otherwise>fo:block</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<fo:block margin-bottom="16pt">
			<xsl:if test="@ancestor = 'sections' and $level &gt; 2">
				<xsl:attribute name="margin-bottom">6pt</xsl:attribute>
			</xsl:if>
			<xsl:copy-of select="@id"/>
			<fo:block font-size="{$font-size}" font-weight="bold" margin-bottom="6pt" keep-with-next="always" role="H{$level}">
					<xsl:if test="@ancestor = 'sections' and $level &gt; 2">
						<xsl:attribute name="margin-bottom">2pt</xsl:attribute>
					</xsl:if>
					<!-- term/name -->
					<xsl:apply-templates select="ieee:name"/>
					<xsl:text> </xsl:text>
					<xsl:apply-templates select="ieee:preferred"/>
					<xsl:for-each select="ieee:admitted">
						<xsl:if test="position() = 1"><xsl:text> (</xsl:text></xsl:if>
						<xsl:apply-templates/>
						<xsl:if test="position() != last()"><xsl:text>, </xsl:text></xsl:if>
						<xsl:if test="position() = last()"><xsl:text>)</xsl:text></xsl:if>
					</xsl:for-each>
				</fo:block>
				<xsl:apply-templates select="*[not(self::ieee:preferred) and not(self::ieee:admitted) and not(self::ieee:name)]"/> <!-- further processing child elements -->
		</fo:block>
		
	</xsl:template>
	
	<xsl:template match="ieee:preferred" priority="2">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="*[local-name() = 'term']/*[local-name() = 'definition']" priority="2">
		<fo:block xsl:use-attribute-sets="definition-style">
			<xsl:apply-templates/>
		</fo:block>
		<!-- change termsource order - show after definition before termnote -->
		<xsl:for-each select="ancestor::ieee:term[1]/ieee:termsource">
			<xsl:call-template name="termsource"/>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="*[local-name() = 'term']/*[local-name() = 'termsource']" priority="2">
		<xsl:call-template name="termsource"/>
	</xsl:template>
	
	
	<xsl:template name="titleAmendment">
		<fo:block font-size="11pt" font-style="italic" margin-bottom="12pt" keep-with-next="always">
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	
	<!-- ====== -->
	<!-- ====== -->


	<xsl:template match="*[local-name() = 'annex']" priority="2">
		<fo:block id="{@id}">
		</fo:block>
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="ieee:p" name="paragraph">
		<xsl:param name="inline-header">false</xsl:param>
		<xsl:param name="split_keep-within-line"/>
	
		<xsl:choose>
		
			<xsl:when test="preceding-sibling::*[1][self::ieee:title]/@inline-header = 'true' and $inline-header = 'false'"/> <!-- paragraph displayed in title template -->
			
			<xsl:otherwise>
			
				<xsl:variable name="previous-element" select="local-name(preceding-sibling::*[1])"/>
				<xsl:variable name="element-name">fo:block</xsl:variable>
					<!-- <xsl:choose>
						<xsl:when test="$inline = 'true'">fo:inline</xsl:when> -->
						<!-- <xsl:when test="preceding-sibling::*[1]/@inline-header = 'true' and $previous-element = 'title'">fo:inline</xsl:when> --> <!-- first paragraph after inline title -->
						<!-- <xsl:when test="local-name(..) = 'admonition'">fo:inline</xsl:when> -->
					<!-- 	<xsl:otherwise>fo:block</xsl:otherwise>
					</xsl:choose>
				</xsl:variable> -->
				<xsl:element name="{$element-name}">
					<xsl:call-template name="setTextAlignment">
						<xsl:with-param name="default">justify</xsl:with-param>
					</xsl:call-template>
					<xsl:attribute name="margin-bottom">6pt</xsl:attribute><!-- 8pt -->
					<xsl:if test="($doctype = 'whitepaper' or $doctype = 'icap-whitepaper' or $doctype = 'industry-connection-report') and (ancestor::ieee:sections or ancestor::ieee:annex)">
						<xsl:attribute name="margin-bottom">12pt</xsl:attribute>
					</xsl:if>
					<xsl:if test="../following-sibling::*[1][self::ieee:note or self::ieee:termnote or self::ieee:ul or self::ieee:ol] or following-sibling::*[1][self::ieee:ul or self::ieee:ol]">
						<xsl:attribute name="margin-bottom">4pt</xsl:attribute>
					</xsl:if>
					<xsl:if test="parent::ieee:li">
						<xsl:attribute name="margin-bottom">6pt</xsl:attribute>
						<xsl:if test="ancestor::ieee:feedback-statement">
							<xsl:attribute name="margin-bottom">0pt</xsl:attribute>
						</xsl:if>
					</xsl:if>
					<xsl:if test="parent::ieee:li and (ancestor::ieee:note or ancestor::ieee:termnote)">
						<xsl:attribute name="margin-bottom">4pt</xsl:attribute>
					</xsl:if>
					<xsl:if test="(following-sibling::*[1][self::ieee:clause or self::ieee:terms or self::ieee:references])">
						<xsl:attribute name="margin-bottom">8pt</xsl:attribute>
					</xsl:if>
					<xsl:if test="@id">
						<xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
					</xsl:if>
					<xsl:attribute name="line-height">1.2</xsl:attribute>
					<!-- bookmarks only in paragraph -->
					<xsl:if test="count(ieee:bookmark) != 0 and count(*) = count(ieee:bookmark) and normalize-space() = ''">
						<xsl:attribute name="font-size">0</xsl:attribute>
						<xsl:attribute name="margin-bottom">0pt</xsl:attribute>
						<xsl:attribute name="line-height">0</xsl:attribute>
					</xsl:if>
					
					<xsl:if test="($doctype = 'whitepaper' or $doctype = 'icap-whitepaper' or $doctype = 'industry-connection-report') and not(parent::ieee:li)">
						<xsl:attribute name="line-height"><xsl:value-of select="$line-height"/></xsl:attribute>
						<xsl:attribute name="margin-bottom">12pt</xsl:attribute>
					</xsl:if>
					
					<xsl:if test="($doctype = 'whitepaper' or $doctype = 'icap-whitepaper' or $doctype = 'industry-connection-report') and parent::ieee:li">
						<xsl:attribute name="line-height">inherit</xsl:attribute>
						<xsl:attribute name="margin-bottom">6pt</xsl:attribute>
					</xsl:if>
				
					
					<xsl:apply-templates>
						<xsl:with-param name="split_keep-within-line" select="$split_keep-within-line"/>
					</xsl:apply-templates>
					
				</xsl:element>
				<xsl:if test="$element-name = 'fo:inline' and not(local-name(..) = 'admonition')"> <!-- and not($inline = 'true')  -->
					<fo:block margin-bottom="12pt">
						 <xsl:if test="ancestor::ieee:annex or following-sibling::ieee:table">
							<xsl:attribute name="margin-bottom">0</xsl:attribute>
						 </xsl:if>
						<xsl:value-of select="$linebreak"/>
					</fo:block>
				</xsl:if>
		
			</xsl:otherwise>
		</xsl:choose>
			
	</xsl:template>
			
	<xsl:template match="ieee:li//ieee:p//text()">
		<xsl:choose>
			<xsl:when test="contains(., '&#9;')">
				<fo:inline white-space="pre"><xsl:value-of select="."/></fo:inline>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="*[local-name() = 'fn'][not(ancestor::*[(local-name() = 'table' or local-name() = 'figure') and not(ancestor::*[local-name() = 'name'])])]" priority="3">
		<xsl:call-template name="fn"/>
	</xsl:template>
	

	<xsl:template match="ieee:p/ieee:fn/ieee:p" priority="2">
		<xsl:choose>
			<xsl:when test="preceding-sibling::ieee:p"> <!-- for multi-paragraphs footnotes -->
				<fo:block>
					<fo:inline padding-right="4mm"> </fo:inline>
					<xsl:apply-templates/>
				</fo:block>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	
	
	<xsl:template match="ieee:ul | ieee:ol" mode="list" priority="2">
		<fo:list-block xsl:use-attribute-sets="list-style">
			
			<xsl:if test="parent::ieee:admonition[@type = 'commentary']">
				<xsl:attribute name="margin-left">7mm</xsl:attribute>
			</xsl:if>
			<xsl:if test="preceding-sibling::*[1][self::ieee:p]">
				<xsl:attribute name="margin-top">6pt</xsl:attribute>
			</xsl:if>
			
			<xsl:if test="ancestor::ieee:note or ancestor::ieee:termnote">
				<xsl:attribute name="provisional-distance-between-starts">4mm</xsl:attribute>
			</xsl:if>
			
			<xsl:variable name="processing_instruction_type" select="normalize-space(preceding-sibling::*[1]/processing-instruction('list-type'))"/>
			<xsl:if test="self::ieee:ul and normalize-space($processing_instruction_type) = 'simple'">
				<xsl:attribute name="provisional-distance-between-starts">0mm</xsl:attribute>
			</xsl:if>
			
			<xsl:if test="$doctype = 'whitepaper' or $doctype = 'icap-whitepaper' or $doctype = 'industry-connection-report'">
				<xsl:attribute name="line-height">1.3</xsl:attribute>
				<xsl:attribute name="margin-left">6.2mm</xsl:attribute>
				<xsl:attribute name="provisional-distance-between-starts">6.5mm</xsl:attribute>
			</xsl:if>
			
			<xsl:apply-templates select="node()[not(local-name() = 'note')]"/>
		</fo:list-block>
		<xsl:apply-templates select="./ieee:note"/>
	</xsl:template>
	

	<!-- <xsl:template match="*[local-name() = 'figure']/*[local-name() = 'name']/text()[1] |
								*[local-name() = 'image']/*[local-name() = 'name']/text()[1] |
								*[local-name() = 'table']/*[local-name() = 'name']/text()[1]" priority="2">
		<xsl:choose>
			<xsl:when test="($doctype = 'whitepaper' or $doctype = 'icap-whitepaper' or $doctype = 'industry-connection-report') and contains(., ' — ')">
				<fo:inline color="{$color_blue}"><xsl:value-of select="java:toUpperCase(java:java.lang.String.new(substring-before(., ' — ')))"/></fo:inline> 
				<xsl:text>&#xa0;&#xa0;</xsl:text>
				<xsl:value-of select="substring-after(., ' — ')"/>			
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template> -->


	<xsl:template match="*[local-name()='table' or local-name()='figure' or local-name() = 'image']/*[local-name() = 'name']/node()[1][self::text()]" priority="2">
		<xsl:choose>
			<xsl:when test="contains(., '—')">
				<xsl:variable name="substring_after" select="substring-after(., '—')"/>
				<xsl:choose>
					<xsl:when test="ancestor::ieee:table/@unnumbered = 'true' and normalize-space($substring_after) = 'Key'"><!-- no display Table - --></xsl:when>
					<xsl:otherwise>
						<fo:inline font-weight="bold" font-style="normal">
							<xsl:choose>
								<xsl:when test="$doctype = 'whitepaper' or $doctype = 'icap-whitepaper' or $doctype = 'industry-connection-report'">
									<!-- Figure N in blue color -->
									<xsl:attribute name="color"><xsl:value-of select="$color_blue"/></xsl:attribute>
									<xsl:value-of select="java:toUpperCase(java:java.lang.String.new(substring-before(., '—')))"/> <!-- 'FIgure' 1 to 'FIGURE A' -->
									<xsl:text>  </xsl:text>
									<xsl:if test="ancestor::*[local-name()='table']">
										<xsl:text>   </xsl:text>
									</xsl:if>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="substring-before(., '—')"/>
								</xsl:otherwise>
							</xsl:choose>
						</fo:inline>
						<xsl:if test="not($doctype = 'whitepaper' or $doctype = 'icap-whitepaper' or $doctype = 'industry-connection-report')">
							<xsl:text>—</xsl:text>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:value-of select="$substring_after"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*[local-name() = 'inlineChar']">
		<fo:inline><xsl:value-of select="."/></fo:inline>
	</xsl:template>

	

<!--
	<xsl:variable name="example_name_width">25</xsl:variable>
	<xsl:template match="ieee:termexample" priority="2">
		<fo:block id="{@id}" xsl:use-attribute-sets="termexample-style">
		
			<fo:list-block provisional-distance-between-starts="{$example_name_width}mm">						
				<fo:list-item>
					<fo:list-item-label end-indent="label-end()">
						<fo:block><xsl:apply-templates select="*[local-name()='name']" /></fo:block>
					</fo:list-item-label>
					<fo:list-item-body start-indent="body-start()">
						<fo:block>
							<xsl:apply-templates select="node()[not(local-name() = 'name')]" />
						</fo:block>
					</fo:list-item-body>
				</fo:list-item>
			</fo:list-block>
		</fo:block>
	</xsl:template>
	
	<xsl:template match="ieee:example" priority="2">
		<fo:block id="{@id}" xsl:use-attribute-sets="example-style">
		
			<fo:list-block provisional-distance-between-starts="{$example_name_width}mm">						
				<fo:list-item>
					<fo:list-item-label end-indent="label-end()">
						<fo:block>
							<xsl:apply-templates select="*[local-name()='name']"/>
						</fo:block>
					</fo:list-item-label>
					<fo:list-item-body start-indent="body-start()">
						<fo:block>
							<xsl:apply-templates select="node()[not(local-name()='name')]"/>
						</fo:block>
					</fo:list-item-body>
				</fo:list-item>
			</fo:list-block>
		
		</fo:block>
	</xsl:template> -->

	<!-- remove space after 'NOTE' without number -->
	<xsl:template match="*[local-name() = 'note' or local-name() = 'termnote']/*[local-name() = 'name']/text()" priority="2">
		<xsl:value-of select="normalize-space()"/>
	</xsl:template>

	<xsl:template match="*[local-name() = 'bibitem'][preceding-sibling::*[local-name() = 'references'][1][not(@normative='true')]]" priority="3">
		<xsl:call-template name="bibitem_non_normative"/>
	</xsl:template>

	<!-- =================== -->
	<!-- Index processing -->
	<!-- =================== -->
	
	<xsl:template match="ieee:indexsect"/>
	<xsl:template match="ieee:indexsect" mode="index">
		<fo:block id="{@id}" span="all">
			<xsl:apply-templates select="ieee:title"/>
		</fo:block>
		<fo:block role="Index">
			<xsl:apply-templates select="*[not(local-name() = 'title')]"/>
		</fo:block>
	</xsl:template>
	
	
	<xsl:template match="ieee:xref" priority="2">
		<xsl:if test="@target and @target != ''">
			<fo:basic-link internal-destination="{@target}" fox:alt-text="{@target}" xsl:use-attribute-sets="xref-style">
				
				<!-- no highlight term's names -->
				<xsl:if test="normalize-space() != '' and string-length(normalize-space()) = string-length(translate(normalize-space(), '0123456789', '')) and not(contains(normalize-space(), 'Annex'))">
					<xsl:attribute name="color">inherit</xsl:attribute>
					<xsl:attribute name="text-decoration">none</xsl:attribute>
				</xsl:if>
				
				<xsl:if test="not(xalan:nodeset($ids)/id = current()/@target)"> <!-- if reference can't be resolved -->
					<xsl:attribute name="color">inherit</xsl:attribute>
					<xsl:attribute name="text-decoration">none</xsl:attribute>
				</xsl:if>
				
				<xsl:if test="($doctype = 'standard' and $stage = 'published') or $doctype = 'whitepaper' or $doctype = 'icap-whitepaper' or $doctype = 'industry-connection-report'">
					<xsl:attribute name="color"><xsl:value-of select="$color_blue"/></xsl:attribute>
					<xsl:attribute name="text-decoration">none</xsl:attribute>
				</xsl:if>
				
				<xsl:if test="parent::ieee:add">
					<xsl:call-template name="append_add-style"/>
				</xsl:if>
				
				<xsl:choose>
					<xsl:when test="@pagenumber='true' and not(ancestor::ieee:indexsect)">
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
		</xsl:if>
	</xsl:template>
	
	<!-- Figure 1 to Figure&#xA0;<bold>1</bold> -->
	<xsl:template match="ieee:xref[@to = 'figure' or @to = 'table']/text()" priority="2">
		<xsl:value-of select="."/>
	</xsl:template>
	
	<xsl:template match="ieee:td/ieee:xref/ieee:strong" priority="2">
		<xsl:apply-templates/>
	</xsl:template>

	
	<!-- =================== -->
	<!-- End of Index processing -->
	<!-- =================== -->
	
	<xsl:template match="*[local-name() = 'origin']" priority="3">
		<xsl:variable name="current_bibitemid" select="@bibitemid"/>
		<xsl:variable name="bibitemid">
			<xsl:choose>
				<!-- <xsl:when test="key('bibitems', $current_bibitemid)/*[local-name() = 'uri'][@type = 'citation']"></xsl:when> --><!-- external hyperlink -->
				<xsl:when test="$bibitems/*[local-name() ='bibitem'][@id = $current_bibitemid]/*[local-name() = 'uri'][@type = 'citation']"/><!-- external hyperlink -->
				<xsl:otherwise><xsl:value-of select="@bibitemid"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="normalize-space($bibitemid) != '' and not($bibitems_hidden/*[local-name() ='bibitem'][@id = $current_bibitemid])">
				<fo:basic-link internal-destination="{@bibitemid}" fox:alt-text="{@citeas}">
					<xsl:if test="normalize-space(@citeas) = ''">
						<xsl:attribute name="fox:alt-text"><xsl:value-of select="@bibitemid"/></xsl:attribute>
					</xsl:if>
					<!-- <fo:inline>
						<xsl:value-of select="$localized.source"/>
						<xsl:text>: </xsl:text>
					</fo:inline> -->
					<fo:inline xsl:use-attribute-sets="origin-style">
						<xsl:apply-templates/>
					</fo:inline>
				</fo:basic-link>
			</xsl:when>
			<xsl:otherwise>
				<fo:inline><xsl:apply-templates/></fo:inline>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>
	

	<xsl:template match="ieee:pagebreak[ancestor::ieee:table]" priority="2">
		<fo:block break-after="page"/>
	</xsl:template>

	
	<xsl:template name="insertFootnoteSeparator">
		<fo:static-content flow-name="xsl-footnote-separator">
			<fo:block>
				<fo:leader leader-pattern="rule" rule-thickness="0.5pt" leader-length="35%">
					<xsl:if test="$doctype = 'whitepaper' or $doctype = 'icap-whitepaper' or $doctype = 'industry-connection-report'">
						<xsl:attribute name="rule-thickness">1pt</xsl:attribute>
						<xsl:attribute name="leader-length">51mm</xsl:attribute>
					</xsl:if>
				</fo:leader>
			</fo:block>
		</fo:static-content>
	</xsl:template>
	
	
	<xsl:template name="insertHeaderFooter">
		<xsl:param name="doctype"/>
		<xsl:param name="document_id"/>
		<xsl:param name="title_prefix"/>
		<xsl:param name="title"/>
		
		<xsl:param name="copyright_year"/>
		<xsl:param name="copyright_holder"/>
	
		<xsl:param name="hideHeader" select="'false'"/>
		<xsl:param name="hideFooter" select="'false'"/>
		
		<xsl:param name="copyright_year"/>
		<xsl:param name="copyright_holder"/>
		<xsl:param name="orientation"/>
		
		
		<xsl:variable name="header">
			<fo:block font-family="Arial" font-size="8pt" text-align="center">
				<!-- P<designation>/D<draft_number>, <draft_month> <draft_year>
				Draft<opt_Trial-Use><Gde./Rec. Prac./Std.> for <Complete Title Matching PAR>
				 -->
				<fo:block>
					<xsl:value-of select="$document_id"/>
				</fo:block>
				<fo:block>
					<xsl:copy-of select="$title_prefix"/>
					<xsl:copy-of select="$title"/>
				</fo:block>
			</fo:block>
		</xsl:variable>
		
		<xsl:variable name="copyrightText">
			<xsl:text>Copyright © </xsl:text>
			<xsl:value-of select="$copyright_year"/>
			<xsl:text> </xsl:text>
			<xsl:value-of select="$copyright_holder"/>
			<xsl:text>. </xsl:text>
			<xsl:variable name="all_rights_reserved">
				<xsl:call-template name="getLocalizedString">
					<xsl:with-param name="key">all_rights_reserved</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>
			<xsl:value-of select="$all_rights_reserved"/>
			<xsl:text>.</xsl:text>
		</xsl:variable>
		
		<xsl:variable name="footer">
			<xsl:choose>
				<xsl:when test="$doctype = 'whitepaper' or $doctype = 'icap-whitepaper' or $doctype = 'industry-connection-report'">
					<fo:block margin-bottom="8mm">
						<xsl:if test="$doctype = 'whitepaper' or $doctype = 'icap-whitepaper' or $doctype = 'industry-connection-report'">
							<xsl:attribute name="margin-bottom">10.5mm</xsl:attribute>
						</xsl:if>
						<fo:table width="100%" table-layout="fixed" font-size="7pt">
							<fo:table-body>
								<fo:table-row>
									<fo:table-cell>
										<fo:block font-weight="bold" font-family="Calibri"><fo:inline font-size="10pt"><fo:page-number/></fo:inline>
											<xsl:text>   IEEE </xsl:text>
											<xsl:choose>
												<xsl:when test="$doctype = 'icap-whitepaper'">CONFORMITY ASSESSMENT PROGRAM (ICAP)</xsl:when>
												<xsl:otherwise>SA</xsl:otherwise>
											</xsl:choose>
											</fo:block> <!--  INDUSTRY CONNECTIONS -->
									</fo:table-cell>
									<fo:table-cell text-align="right" font-family="Calibri Light">
										<xsl:if test="$doctype = 'whitepaper' or $doctype = 'icap-whitepaper' or $doctype = 'industry-connection-report'">
											<xsl:attribute name="font-family">Arial</xsl:attribute>
										</xsl:if>
										<fo:block>
											<xsl:value-of select="$copyrightText"/>
										</fo:block>
									</fo:table-cell>
								</fo:table-row>
							</fo:table-body>
						</fo:table>
					</fo:block>
				</xsl:when>
				<xsl:otherwise>
					<fo:block text-align="center" margin-bottom="12.7mm">
						<xsl:if test="$doctype = 'standard' and $stage = 'published'">
							<xsl:attribute name="margin-bottom">8.5mm</xsl:attribute>
						</xsl:if>
						<fo:block> <!-- font-weight="bold" -->
							<xsl:if test="$doctype = 'standard' and $stage = 'published'">
								<xsl:attribute name="font-family">Times New Roman</xsl:attribute>
								<xsl:attribute name="font-weight">normal</xsl:attribute>
							</xsl:if>
							<fo:page-number/>
						</fo:block>
						<!-- Copyright © 2022 IEEE. All rights reserved. -->
						<fo:block font-family="Arial" font-size="8pt">
							<fo:block>
								<xsl:value-of select="$copyrightText"/>
							</fo:block>
							<xsl:choose>
								<xsl:when test="$doctype = 'standard' and $stage = 'published'"/>
								<xsl:otherwise>
									<fo:block>This is an unapproved IEEE Standards Draft, subject to change.</fo:block>
								</xsl:otherwise>
							</xsl:choose>
						</fo:block>
					</fo:block>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="$orientation = 'landscape'">
				<xsl:if test="$hideHeader = 'false'">
					<fo:static-content flow-name="right-region-landscape" role="artifact">
						<fo:block-container reference-orientation="270" margin-left="13mm">
							<xsl:copy-of select="$header"/>
						</fo:block-container>
					</fo:static-content>
				</xsl:if>
				<xsl:if test="$hideFooter = 'false'">
					<fo:static-content flow-name="left-region-landspace" role="artifact">
						<fo:block-container reference-orientation="270" margin-left="13mm">
							<xsl:copy-of select="$footer"/>
						</fo:block-container>
					</fo:static-content>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="$hideHeader = 'false'">
					<fo:static-content flow-name="header" role="artifact">
						<fo:block-container margin-top="12.7mm">
							<xsl:copy-of select="$header"/>
						</fo:block-container>
					</fo:static-content>
				</xsl:if>
				<xsl:if test="$hideFooter = 'false'">
					<fo:static-content flow-name="footer" role="artifact">
						<fo:block-container display-align="after" height="100%">
							<xsl:copy-of select="$footer"/>
						</fo:block-container>
					</fo:static-content>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	
	<xsl:variable name="Image-IEEE-Logo-white-svg">
		<svg xmlns="http://www.w3.org/2000/svg" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:cc="http://creativecommons.org/ns#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:svg="http://www.w3.org/2000/svg" id="svg20" height="28.959999mm" width="100.58mm" version="1.0">
			<defs id="defs6">
				<clipPath id="clipEmfPath1" clipPathUnits="userSpaceOnUse">
					<path id="path2" d="  M 0,0   L 0,0   L 0,111.18683   L 381.87252,111.18683   L 381.87252,0 "/>
				</clipPath>
				<pattern y="0" x="0" height="6" width="6" patternUnits="userSpaceOnUse" id="EMFhbasepattern"/>
			</defs>
			<path id="path8" d="  M 127.12414,13.810785   L 127.12414,13.810785   L 150.42857,13.810785   L 150.42857,98.076589   L 127.12414,98.076589   L 127.12414,13.810785   z " clip-path="url(#clipEmfPath1)" style="fill:#ffffff;fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path10" d="  M 162.63088,98.076589   L 162.63088,98.076589   L 162.63088,13.810785   L 226.84308,13.810785   L 226.84308,30.123524   L 186.03533,30.123524   L 186.03533,47.537122   L 223.54245,47.537122   L 223.54245,63.849861   L 186.03533,63.849861   L 186.03533,81.76385   L 226.84308,81.76385   L 226.84308,98.076589   L 162.63088,98.076589   z " clip-path="url(#clipEmfPath1)" style="fill:#ffffff;fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path12" d="  M 239.84555,98.076589   L 239.84555,98.076589   L 239.84555,13.810785   L 304.05774,13.810785   L 304.05774,30.123524   L 263.24999,30.123524   L 263.24999,47.537122   L 300.75711,47.537122   L 300.75711,63.849861   L 263.24999,63.849861   L 263.24999,81.76385   L 304.05774,81.76385   L 304.05774,98.076589   L 239.84555,98.076589   z " clip-path="url(#clipEmfPath1)" style="fill:#ffffff;fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path14" d="  M 317.06021,13.810785   L 317.06021,13.810785   L 317.06021,98.076589   L 381.2724,98.076589   L 381.2724,81.76385   L 340.46465,81.76385   L 340.46465,63.849861   L 377.97178,63.849861   L 377.97178,47.537122   L 340.46465,47.537122   L 340.46465,30.123524   L 381.2724,30.123524   L 381.2724,13.810785   L 317.06021,13.810785   z " clip-path="url(#clipEmfPath1)" style="fill:#ffffff;fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path16" d="  M 53.210105,64.45033   L 53.210105,64.45033   C 52.810029,70.354941 52.810029,75.859239 52.309934,81.863928   C 54.71039,82.064085 57.310883,82.264241 59.811358,81.863928   L 59.111225,65.250955   L 59.011206,64.45033   C 57.110845,64.550408 55.210485,64.650486 53.210105,64.45033   z  M 38.507313,47.737279   L 38.507313,47.737279   C 35.606762,49.138373 31.305945,51.340092 31.80604,55.343218   C 32.406154,57.544937 34.706591,58.946032 36.606952,59.846735   C 46.908908,64.350252 60.511491,64.45033 71.413561,61.147751   C 74.114074,60.046891 77.614739,58.545719 78.114834,55.343218   C 78.114834,52.54103 75.214283,50.839701 73.213903,49.83892   L 73.213903,49.738842   C 73.914036,49.438607 74.714188,49.138373 75.51434,49.038295   L 75.51434,49.038295   C 71.813637,48.337747 68.312973,47.437044 64.812308,46.436263   C 65.512441,48.037513 66.012536,49.638763 66.512631,51.240014   C 67.61284,50.939779 68.713049,50.639545 69.813258,50.539467   C 71.713618,51.240014 74.314112,52.240795 74.614169,54.542593   C 74.814207,56.744312 72.413751,57.845172 70.913467,58.745875   C 63.011966,61.648142 54.010257,61.848298 45.70868,59.646579   C 43.408243,58.946032 40.107616,58.045328 39.807559,55.143062   C 41.507882,51.240014 45.70868,50.439389 49.209345,49.538685   C 47.409003,48.337747 45.508642,47.336966 43.808319,46.03595   C 41.907958,46.136028 40.207635,46.936653 38.507313,47.737279   z  M 56.010636,24.519147   L 56.010636,24.519147   L 55.010447,27.821726   L 49.809459,42.633293   C 51.109706,42.733371 52.71001,42.633293 54.010257,42.733371   L 54.010257,42.833449   L 53.310124,59.646579   L 53.410143,59.846735   C 55.010447,59.946813 57.110845,60.046891 58.811168,59.746657   L 58.811168,59.5465   L 58.111035,43.233762   L 58.211054,42.733371   L 62.811928,42.633293   C 60.511491,36.628604 58.311073,30.523836 56.210674,24.519147   L 56.010636,24.519147   z  M 53.610181,17.013286   L 53.610181,17.013286   C 57.410902,14.511332 60.911567,18.114146 63.812118,20.115709   C 75.214283,29.322899 85.916316,39.831105 94.117873,51.740405   C 95.218082,53.241577 95.618158,55.643453 94.717987,57.344781   C 92.617588,60.847516 89.717037,64.150095 87.016525,67.352596   L 87.016525,67.552753   C 80.215233,74.75838 73.113884,82.164163 65.312403,88.26893   C 61.6117,90.570728 58.111035,95.574635 53.310124,92.472213   C 42.208015,84.46596 31.606002,74.358067 22.604293,63.549627   C 21.104008,61.247829 18.703552,59.246266 17.703362,56.544156   C 16.203077,52.941342 19.503704,50.33931 21.304046,47.537122   C 30.505793,36.328369 41.807939,25.219694 53.610181,17.013286   z  M 63.212004,6.3049236   L 63.212004,6.3049236   L 59.011206,0.30023446   C 58.511111,0 57.810978,-0.40031261 57.210864,-0.60046891   C 56.010636,-1.1008597 54.71039,-0.50039076 53.610181,0.2001563   L 46.008737,10.107893   C 33.80642,25.319772 19.303666,39.430792 3.6006838,50.239232   C 2.3004369,51.240014 0.50009497,52.140717 0.10001899,53.842046   C -0.20003799,55.24314 0.40007597,56.444078 1.3002469,57.344781   C 13.90264,66.05158 26.004938,76.35963 36.80699,88.168852   C 38.707351,90.170415 40.207635,92.171978 42.107996,94.073463   C 45.208585,98.276745 48.909288,102.48003 51.809839,106.98354   C 52.71001,107.88425 52.910048,109.4855 54.310314,109.98589   C 55.410523,110.28612 56.810788,110.58636 57.910997,109.98589   L 58.911187,108.88503   C 72.013675,90.370571 88.616828,73.65752 107.12034,60.247048   C 109.0207,58.645797 112.52137,57.94525 112.52137,54.942905   C 112.42135,53.441733 111.6212,52.040639 110.42097,51.340092   L 110.12091,51.240014   C 100.51909,44.734934 91.617398,37.429229 83.315822,29.122742   L 74.014055,19.415162   C 70.313353,15.311957 66.61265,10.708362 63.212004,6.3049236   z  M 52.309934,14.811567   L 52.309934,14.811567   C 56.010636,11.9093 60.711529,14.311176 63.812118,16.913208   C 67.112745,19.415162 70.513391,22.317428 73.51396,25.219694   L 74.014055,25.519929   C 82.315632,33.225946 90.017094,41.732589 96.41831,50.839701   C 97.4185,52.440952 98.318671,54.14228 97.718557,56.243921   C 95.618158,61.548064 91.317341,65.751346 87.616638,70.354941   C 79.5151,79.06174 70.913467,87.568383 61.311643,94.273619   C 59.411282,95.674713 56.810788,96.975729 54.410333,95.87487   C 47.409003,92.171978 41.507882,86.067211 35.306705,80.562912   C 28.105337,73.957754 20.90397,66.251737 15.502944,58.145406   C 14.702792,57.044547 14.502754,55.643453 14.502754,54.14228   C 15.202887,51.340092 17.103248,49.038295 18.90359,46.636419   C 25.304805,38.530089 33.206306,30.723993 41.107806,23.618444   C 41.307844,23.418288 41.607901,23.118053 41.907958,22.917897   C 45.308604,19.915552 48.70925,17.31352 52.309934,14.811567   z " clip-path="url(#clipEmfPath1)" style="fill:#ffffff;fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path18" d="  M 75.214283,101.97964   L 75.214283,101.97964   L 74.414131,101.97964   L 74.414131,100.97886   L 75.114264,100.97886   C 75.414321,100.97886 75.914416,100.97886 75.914416,101.47925   C 75.914416,101.87956 75.714378,101.97964 75.214283,101.97964   z  M 76.814587,101.47925   L 76.814587,101.47925   C 76.814587,100.57854 76.214473,100.27831 75.114264,100.27831   L 73.51396,100.27831   L 73.51396,104.48159   L 74.414131,104.48159   L 74.414131,102.68018   L 74.914226,102.68018   L 75.814397,104.48159   L 76.914606,104.48159   L 75.814397,102.58011   C 76.414511,102.58011 76.814587,102.27987 76.814587,101.47925   z  M 75.114264,105.38229   L 75.114264,105.38229   L 75.114264,105.38229   C 73.51396,105.38229 72.313732,104.18136 72.313732,102.37995   C 72.313732,100.57854 73.51396,99.377605 75.114264,99.377605   C 76.614549,99.377605 77.914796,100.57854 77.914796,102.37995   C 77.914796,104.18136 76.614549,105.38229 75.114264,105.38229   z  M 75.114264,98.476902   L 75.114264,98.476902   C 73.013865,98.476902 71.213524,99.877996 71.213524,102.37995   C 71.213524,104.8819 73.013865,106.283 75.114264,106.283   C 77.214663,106.283 79.015005,104.8819 79.015005,102.37995   C 79.015005,99.877996 77.214663,98.476902 75.114264,98.476902   z " clip-path="url(#clipEmfPath1)" style="fill:#ffffff;fill-rule:evenodd;fill-opacity:1;stroke:none;"/>
		</svg>
	</xsl:variable>
	
	<xsl:variable name="Image-IEEE-Logo-black-svg">
		<svg xmlns="http://www.w3.org/2000/svg" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:cc="http://creativecommons.org/ns#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:svg="http://www.w3.org/2000/svg" id="svg25" height="10.93mm" width="38.099998mm" version="1.0">
			<defs id="defs9">
				<clipPath id="clipEmfPath1" clipPathUnits="userSpaceOnUse">
					<path id="path2" d="  M 0,0   L 0,0   L 0,43.035379   L 145.74211,43.035379   L 145.74211,0 "/>
				</clipPath>
				<clipPath id="clipEmfPath2" clipPathUnits="userSpaceOnUse">
					<path id="path5" d="  M 0,0   L 0,0   L 0,43.035379   L 145.44203,43.035379   L 145.44203,0 "/>
				</clipPath>
				<pattern y="0" x="0" height="6" width="6" patternUnits="userSpaceOnUse" id="EMFhbasepattern"/>
			</defs>
			<path id="path11" d="  M 41.411966,19.716208   L 41.411966,19.716208   C 39.911533,18.214974 35.110145,15.112424 31.00896,11.109133   C 27.007804,7.0057594 23.906908,2.2018101 22.406475,0.70057594   C 21.406186,-0.30024683 20.806012,-0.30024683 19.705694,0.70057594   C 18.305289,2.2018101 15.104365,7.1058416 11.103208,11.109133   C 7.1020522,15.112424 2.3006648,18.415139 0.70020233,19.716208   C -0.20005781,20.717031 -0.20005781,21.317525 0.70020233,22.41843   C 2.3006648,23.819582 7.1020522,27.022215 11.103208,31.025506   C 15.104365,34.928714 18.305289,39.832746 19.705694,41.434062   C 20.806012,42.434885 21.406186,42.434885 22.406475,41.434062   C 23.806879,39.832746 27.007804,35.028797 31.00896,31.025506   C 35.110145,26.922132 39.911533,23.7195 41.411966,22.41843   C 42.512284,21.317525 42.512284,20.717031 41.411966,19.716208   z  M 36.610579,22.118183   L 36.610579,22.118183   C 34.509972,24.920487 32.209307,27.622708 29.808613,30.124765   C 27.40792,32.426658 24.907197,34.628468 22.206417,36.630113   C 21.506214,37.130525 20.605954,37.130525 19.905752,36.630113   C 17.204972,34.528385 14.60422,32.326575 12.203526,29.924601   C 9.8028326,27.522626 7.6021967,25.020569 5.6016186,22.318348   C 5.1014741,21.617772 5.1014741,20.616949 5.6016186,19.916373   C 7.6021967,17.214152 9.8028326,14.612012 12.203526,12.210038   C 14.60422,9.8080631 17.204972,7.606253 19.905752,5.5045252   C 20.605954,5.0041138 21.606243,5.0041138 22.306446,5.5045252   C 25.007226,7.606253 27.507949,9.8080631 29.908642,12.210038   C 32.309336,14.612012 34.610001,17.214152 36.610579,20.016455   C 37.110723,20.616949 37.110723,21.517689 36.610579,22.118183   L 36.610579,22.118183   z " clip-path="url(#clipEmfPath2)" style="fill:#000000;fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path13" d="  M 35.510261,20.116538   L 35.510261,20.116538   C 33.609712,17.514398 31.509105,15.112424 29.308469,12.810531   C 27.107833,10.608721 24.707139,8.5069935 22.206417,6.6054302   C 21.506214,6.2051011 20.605954,6.2051011 20.005781,6.6054302   C 17.505058,8.5069935 15.104365,10.608721 12.903729,12.810531   C 10.603064,15.112424 8.6024858,17.414316 6.7019366,20.016455   C 6.2017921,20.616949 6.2017921,21.517689 6.7019366,22.218265   C 8.6024858,24.720322 10.603064,27.022215 12.8037,29.324107   C 15.104365,31.525917 17.505058,33.527563 20.005781,35.429126   C 20.605954,35.929537 21.506214,35.929537 22.206417,35.429126   C 24.60711,33.627645 27.007804,31.625999 29.20844,29.424189   C 31.409076,27.122297 33.609712,24.62024 35.510261,22.018101   C 36.010406,21.517689 36.010406,20.616949 35.510261,20.116538   z  M 21.00607,9.9081454   L 21.00607,9.9081454   L 23.406764,16.613658   L 21.806301,16.613658   L 22.106388,23.018924   C 21.406186,23.119006 20.705983,23.119006 20.005781,23.018924   L 20.305868,16.613658   L 18.705405,16.613658   L 21.00607,9.9081454   L 21.00607,9.9081454   z  M 19.705694,31.325753   L 19.705694,31.325753   L 20.005781,24.720322   C 20.705983,24.820405 21.506214,24.820405 22.206417,24.720322   L 22.506503,31.425835   C 21.606243,31.525917 20.605954,31.525917 19.705694,31.325753   z  M 20.705983,24.319993   L 20.705983,24.319993   C 15.904596,24.319993 11.90344,22.818759 11.90344,20.917196   C 11.90344,19.516044 13.70396,18.415139 16.504769,17.814645   L 18.605376,19.215797   C 16.40474,19.616126 14.904307,20.316702 14.904307,21.217443   C 14.904307,22.518512 17.905174,23.619417 21.506214,23.619417   C 24.60711,23.619417 28.108122,22.518512 28.108122,21.217443   C 28.108122,20.416784 27.207862,20.016455 26.307602,19.516044   L 25.107255,19.816291   L 24.407053,18.01481   L 28.408209,18.91555   L 27.507949,19.215797   C 27.507949,19.215797 29.108411,20.016455 29.408498,20.917196   C 30.008671,22.818759 25.907486,24.319993 20.705983,24.319993   z " clip-path="url(#clipEmfPath1)" style="fill:#000000;fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path15" d="  M 28.30818,37.530854   L 28.30818,37.530854   C 27.507949,37.530854 26.807746,38.131347 26.807746,39.032088   C 26.807746,39.832746 27.507949,40.43324 28.30818,40.43324   C 29.108411,40.43324 29.808613,39.832746 29.808613,39.032088   L 29.808613,38.932006   C 29.808613,38.23143 29.20844,37.530854 28.408209,37.530854   C 28.408209,37.530854 28.30818,37.530854 28.30818,37.530854   z  M 28.30818,40.132993   L 28.30818,40.132993   L 28.30818,40.132993   C 27.708006,40.132993 27.107833,39.732664 27.107833,39.032088   C 27.007804,38.431594 27.507949,37.931183 28.108122,37.8311   C 28.808324,37.8311 29.308469,38.23143 29.408498,38.932006   C 29.408498,38.932006 29.408498,38.932006 29.408498,38.932006   C 29.408498,39.532499 29.008382,40.032911 28.408209,40.132993   C 28.30818,40.132993 28.30818,40.132993 28.30818,40.132993   z  M 29.008382,38.631759   L 29.008382,38.631759   C 29.008382,38.331512 28.708296,38.23143 28.30818,38.23143   L 27.708006,38.23143   L 27.708006,39.732664   L 28.108122,39.732664   L 28.108122,39.13217   L 28.208151,39.13217   L 28.608267,39.732664   L 29.008382,39.732664   L 28.608267,39.13217   C 28.808324,39.13217 29.008382,38.932006 29.008382,38.731841   C 29.008382,38.731841 29.008382,38.731841 29.008382,38.631759   z  M 28.408209,38.831923   L 28.408209,38.831923   L 28.108122,38.831923   L 28.108122,38.531676   L 28.30818,38.531676   C 28.408209,38.531676 28.608267,38.531676 28.608267,38.631759   C 28.608267,38.831923 28.508238,38.831923 28.408209,38.831923   z " clip-path="url(#clipEmfPath1)" style="fill:#000000;fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path17" d="  M 48.113903,5.5045252   L 48.113903,5.5045252   L 57.016475,5.5045252   L 57.016475,37.430771   L 48.113903,37.430771   L 48.113903,5.5045252   z " clip-path="url(#clipEmfPath1)" style="fill:#000000;fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path19" d="  M 61.617805,37.430771   L 61.617805,37.430771   L 61.617805,5.5045252   L 86.024858,5.5045252   L 86.024858,11.709626   L 70.520377,11.709626   L 70.520377,18.315057   L 84.724482,18.315057   L 84.724482,24.420075   L 70.520377,24.420075   L 70.520377,31.22567   L 86.024858,31.22567   L 86.024858,37.430771   L 61.617805,37.430771   z " clip-path="url(#clipEmfPath1)" style="fill:#000000;fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path21" d="  M 90.926274,37.430771   L 90.926274,37.430771   L 90.926274,5.5045252   L 115.33333,5.5045252   L 115.33333,11.709626   L 99.828846,11.709626   L 99.828846,18.315057   L 114.03295,18.315057   L 114.03295,24.420075   L 99.828846,24.420075   L 99.828846,31.22567   L 115.33333,31.22567   L 115.33333,37.430771   L 90.926274,37.430771   z " clip-path="url(#clipEmfPath1)" style="fill:#000000;fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path23" d="  M 120.23474,5.5045252   L 120.23474,5.5045252   L 120.23474,37.430771   L 144.6418,37.430771   L 144.6418,31.22567   L 129.13732,31.22567   L 129.13732,24.420075   L 143.34142,24.420075   L 143.34142,18.315057   L 129.13732,18.315057   L 129.13732,11.709626   L 144.6418,11.709626   L 144.6418,5.5045252   L 120.23474,5.5045252   z " clip-path="url(#clipEmfPath1)" style="fill:#000000;fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
		</svg>
	</xsl:variable>
	
	<!-- <xsl:variable name="Image-IEEE2-Logo">
		<xsl:text>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AAAAAFAFISQAAAAAAABUQQgJAAAAAAAAVRBCAgAAAAAAQBWEkAAAAAAAAFAFISQAAAAAAABUQQgJAAAAAAAAVRBCAgAAAAAAQBWEkAAAAAAAAFAFISQAAAAAAABUQQgJAAAAAAAAVRBCAgAAAAAAQBWEkAAAAAAAAFAFISQAAAAAAABUQQgJAAAAAAAAVRBCAgAAAAAAQBWEkAAAAAAAAFAFISQAAAAAAABUQQgJAAAAAAAAVRBCAgAAAAAAQBWEkAAAAAAAAFAFISQAAAAAAABUQQgJAAAAAAAAVRBCAgAAAAAAQBWEkAAAAAAAAFAFISQAAAAAAABUQQgJAAAAAAAAVRBCAgAAAAAAQBWEkAAAAAAAAFAFISQAAAAAAABUQQgJAAAAAAAAVRBCAgAAAAAAQBWEkAAAAAAAAFAFISQAAAAAAABUQQgJAAAAAAAAVRBCAgAAAAAAQBWEkAAAAAAAAFAFISQAAAAAAABUQQgJAAAAAAAAVRBCAgAAAAAAQBWEkAAAAAAAAFAFISQAAAAAAABUQQgJAAAAAAAAVRBCAgAAAAAAQBWEkAAAAAAAAFAFISQAAAAAAABUQQgJAAAAAAAAVRBCAgAAAAAAQBWEkAAAAAAAAFAFISQAAAAAAABUQQgJAAAAAAAAVRBCAgAAAAAAQBWEkAAAAAAAAFAFISQAAAAAAABUQQgJAAAAAAAAVRBCAgAAAAAAQBWEkAAAAAAAAFAFISQAAAAAAABUQQgJAAAAAAAAY+1MhwAAIABJREFUVRBCAgAAAAAAQBWEkAAAAAAAAFAFISQAAAAAAABUQQgJAAAAAAAAVRBCAgAAAAAAQBWEkAAAAAAAAFAFISQAAAAAAABUQQgJAAAAAAAAVRBCAgAAAAAAQBWEkAAAAAAAAFAFISQAAAAAAABUQQgJAAAAAAAAVRBCAgAAAAAAQBWEkAAAAAAAAFAFISQAAAAAAABUQQgJAAAAAAAAVRBCAgAAAAAAQBWEkAAAAAAAAFAFISQAAAAAAABUQQgJAAAAAAAAVRBCAgAAAAAAQBWEkAAAAAAAAFAFISQAAAAAAABUQQgJAAAAAAAAVRBCAgAAAAAAQBWEkAAAAAAAAFAFISQAAAAAAABUQQgJAAAAAAAAVRBCAgAAAAAAQBWEkAAAAAAAAFAFISQAAAAAAABUQQgJAAAAAAAAVRBCAgAAAAAAQBWEkAAAAAAAAFAFISQAAAAAAABUQQgJAAAAAAAAVRBCAgAAAAAAQBWEkAAAAAAAAFAFISQAAAAAAABUQQgJAAAAAAAAVRBCAgAAAAAAQBWEkAAAAAAAAFAFISQAAAAAAABUQQgJAAAAAAAAVRBCAgAAAAAAQBUppVRgAvdvT2s3ryNLin9ZG857YRBqeHQsbDedCRdRYftah8sHJmxHtKh82Qcx70U75Bwey7r5jnQ6/IN4XTqXC+fTKbHecM3aE48HJnzcD/ucE+2kUuHykhXbR/Y/CER/xPKeN45AntxA8q0Q7edEn+XiKdG+MeEyng6Xkl2ILOP5YZu2wtgQ7RjRB88vv32MkeuVLdmy84EpPx6MCUxxU8vHlbW6+HTP93Wxs9HninVZMf7Fw0Zr90LlGJBPldtKibEtX5ZcXisb7j42cP3Unud2DS1fe2Dda/R83y1jrLXitYcvzVq56bRbl1jG2MiGNpGFC3/xPc8dCuR4NlaZ8J9ahcsYawstpTzPL44nK7aPFhsl0ge5fXT5nVz2QVVYRjLGiLdYu3WkfM8rdxyp1KIJAvd+eZ4Xvt7I6wofD3I5Uzzs+H7K8311lErHB2OMFesK3y8Tea9l/6O7apn+B4EJiruk7/u+6I8V41K+NZW6V+nxqi/NWHmot7o4TjxPvhdWfqzIncp9z2GtdZtda+17buwpt8211u5waqzKRR73XYuR7hfXa6x120pprYvLezocHtbaXPEw7nk6Vdye1ob9j+yPpZtHbIfimLRKGxW24/YjrbQf7tZWHuvC/UspY9xHktaeJ5YvPqqUDtxzxceN1kbse/JjKHIYl+OtuCVs9ONbblBfvHS5q1XaxeSYiXwARJqXf5FtyvEp1hs51Mj2xcdxcbtppdLiuzTru22osmI7uDHmadWSFvtRUL59uUN6KjxtkFsi+lEojhVie45ly59ylByWRTvi41J+PMn3WnxUKRsukxNtplLygMJ3jQAAIMSZAQAAAAAAAKoghAQAAAAAAIAqtLU2F4R3SvvhXdCRu/Fl1oNMyPJF4lg25+6ItkNDQ/k5Y+3ul18qPmwPHxwozCp7YP9+99yDBw4UF7EHBwbc42Ojo25e3qHd2tJS7KU3f8FJboFTTjuj8LhSS049wy3f0Rom1snb63NB1t0QHtgw72ffq6+5xw/uf12VUzHLQ9yp7okEKLndorfdh3ewR/KxAplgKO60F3eky8yUnLgtPsjlXJd8seE6u7pcgsZJCxemUoX5tLhrPZqN4on5cPuYIEy6eeXVvS6/b3hw0BZv+Be5VvltJbIywnUZtylsNAnLzWcyrS6pau6J81PFIdfe3u6SLzxPyfbdcz3PU6rM2xQd20G4XhumTIxms26LHti/P5ct5GmODI+4pAZjwgQWKxJVjHjvUqm0y4ObPWduOlMYujNmdKZdYoK2qpgnqLXMQhHbTb4QsZm8aBaSTLpxj5swB0jt3/f68PBwfn54ZDgovneR5CyRmJPOpFPFnMRMW0c6U9iVOrq63Lwf5r2plDiIWJGcJZNxDh85PDIyUujD0Eh2rLBtx8ZGw93EyByU8EXLJB1rw/aVVS4JKJrGpj2RaBYmCmnP7Z6+77tEEs/33bhqaWlJtxReY1tHZ2t7h3s8U3ztMtEp36PC455XNeXORl9hpUOKDZMxw4W90iS4MMnLkwlNYiy59oeHhkeKh+jBocHBwcFiO5FksXB9kcRJ5YaiMSYIwjxi1+XWtvaOGTPz8+0dHV0zulyb7oClo7m00dRGOebFaxfvddg1kchjjHEJVsMjw4eKHyVjY2Ojw4XXq62KJHuKw0ZO5hp7LrFUR3YlkR8dLlwp1ViHYy+dybR3FMZPKp3q6OjMz3u+n860uif6YSKVTO4L92uvJFEuMvjcsUj8XWtd3LONsrlcof9juZzbPrlcbujI4eILNLni/qjk+BHNWqVyRuZNh/tmLhuOBy3HcLkkR611+BGmtV88HmqtveJnk+95XcXt5qdSM2fNKcz7flt7e/gaIy85nA/KfoxqJY8nOtxFPJfUaZXKBXJDhq9X5trL3TAwYSJkJN/ZzRhzYN/rxY6Z/a+96vpwqHgKZIyRp0MHDh507QwNDrn5MbGdXc6cp3VX14zig3pJ9ymF7ni6+7TwdOjEBQvcfIvI648m/YUpzulyCbkAAKBppVTpZYwoThG5Ryk8f4qck6XCEJIoxGCGiteoQWD27CmcJxlrX9uzuzBv7N49rxSXt6++utfNv/76Ptfm8Mhw2L4IZ3S0txUf1Gecfmqx67qtrdM9ftKiU9zy7e2t4hWGr1deM4xlw8f37Qv7sOfll8MaJbImTqSeTvmiErIekAwryHkrzs988dwgOyYeF2EmGUISxRGyos2sfK64yJh34onulH3uiSe60+WUHc/lbjgfmPD6fv/+fdlivYbDAwOuPosMY4krRyUvcHK5nDiVF+EksUxXW4e7rEq3trW2Fd761tbWMIRUGmIrF3aJXq47kXo0YvlsNueG+sH9+0ZHCtHMocEj7jLMmLDPgQnCcGQu60IJLW1tbptrz28vXjp2dLSn067bsuhGeOnoeX75mjheeNEUvXYq/y7KmjgHDx4cLF4uHjlyOFu8FDFBGIawgXHvS3trW7oYtuucOauluP39TMYNb98rX2NIbvFcELhLrCOHDw8NHsnPHzp0ZHi4EE4aGR5y4SRjjIhcy3BYWALIiG1ubbi8teH49LTnFTdSNjvmQma+77taRX467eqMpNJpt7t1dHW1Fg81ndmgs7jeLu17xXJvnlK+C1lqHdYVkjuqrJXjRcK1FeofGbHveNG3NazdUxJFcu2IsIv2PLdPhYessdERFz44ODDgovbGmPDQJEIV0XBGeI0e5LJu/MgdrGvGzNnFfSSwtnNG8bAsDuNald8fjyHcDlqV74+1o8X398jQ8IEDhW8pRoZHDh8qfjNhlQ7rv4S1pYyxYVnASMGksKfWWrd9bLR+U9kPUc/z3LEr09I6a/bswnymxXpuvGU6/IzrjSdCZq4/OhKqEEdHrcXHojg+RA4F2hVVskHgts/oyIgLT2THRg8Wv9ExgRkrfuxaa7MuxCwOqzb6cRMe94wJv/URdZ1U9PDriRBS2pVN9HQm0xI+XgzRplL+ibNmF7dVOt1S2B9Tfqqlrd217svjT+STWYSuRK07uXmCIDxu+Kp8zSz5ESM/vqP1zsINZMLjksoVT6VygdpX/BbN5HIv7y6cDllj9rz8cn4+MMGeV/a4zrtTEWvVwOFDbk2jsvSkH27PucUx5nmeC+dp7XUVQ29a69knnhQ+Ny3DkSIcFr5GSwgJAABIJLIBAAAAAACgCkJIAAAAAAAAqCKlRPEFpVTkF2fLFYZQSnnFjA9r7d49hTuugyB45aWdxSeal4v1j4wxL75YnLfmtddeKz5XztvX3d3ayh4+csSty91Fn1/OzWZcDSatB4vLax354XmZZ3bKqae5ZZac0u0e90Wi2aCowfTUz37qboB//rnnyqZcyDvkZU0iVe6OfaVUUOGXksdEUYlMOuXqgASi2EHKL5/IZvMPKKWiv/BtRe2MrPhV4LPOOtMlJS3sPsX1NOOH6W4ya0bWMJLb88iRIy4p5ufPPufyFvfs3u3qImVzgauF4fkp2aqby+WyLisjkvgmtk9XW7vL71uqva4ZhVoPXTNmuLpI0WIl4WuXmQv5zJPirCTL6YTv3pHBI2PFZIFfvvDC4cOF5K/XXn11tJhslcvmRCJVmNiSzWZdEkdLS4tLuPuVRYs6ivU7Tj399K5ivZgTFyxoKyaIKe2pSApUWIMmktAkEiVEMlTJe1cwOjIyNlYYTq+8tMslR+x9de9gsb5GLpsLwkS28MfsZ3V1tbUW8kAXLjrZ1SLxUmGNpLSvXU6rFn2TNWKyuSCbK/Rh/779AwcL9T5e3vXywf/L3nt9SZJbaZ64AEy4Ch0ZkZFZmSWyqljN2t4W26fV6Z2Xnb96zzzPmT3DbjbJJlk6RWjl2t0UgH1wuxcXUe4dxWkxLBLfQxXC09wMBmXAdft+QHPHdDohRhI3eVnrvIHLWs5e4eXv09z0xwrCMjOd1poZDL1ZTGtN5pRut0u8lU6vR3XU7/eyvP28l2c58pL6W9tbOzur9GAwIPaNDE1hm/yGAcvGm7YgaA2ODGuME8S8roExk3mtZtMpteGr8/Ori9Y4c3N3f3vb8lnqpqmrtv9KJTkaLyCY4XWbpiGzjHOO6mV//+C9999fpY+Pj7ud1qDUyfMu8qRAMPgca9tOOKJLbbS6+UutWEjtH42x1H7G93dnb9tH0v39/bs3b6ms/BAKQAYly8yPzvkhyDlHYBsXlK3jnu4Q3OVNlJqMbEmyhf09TdPBoOVDZVlKY5pOkj62mSzvPDk5aT/XyaDfw/xYui4AKGYKYx7qoMk0ZGBszBLLZzIeE6ZwMZu9/vbbtgybhlCGzrJ7ZA8ex7k/TghMO+do/Hc8G449ngLjFCQMp+j7IwCNLVqrfSwfpZPDoyft50r1sTyllFSeSicnL17gCeUO9kc+zkNgQuTAv+BHNc8FY31NBI914G2mIvOmMWenOO0x5uK89exba968eYMnN5dn6Ot37t4b1uwN9kfn7LX39Tsy/D4QcYsA4PL6GtNyic8vKaXB3wulBHp+AcDLV6/o+N2dbTqnVvH3xaioqKioqKj10uIBRyaACDC8Lg8A4FrFGjO8b+c3pjGvv/mm/dza7777jk5yfoGhImuv/NzI3dxSCElQWjixYPyjAOPNOKZ+rimgqkpMi60tmi+KbQQoCCH6OL8UQrx4+YLSkjGGCobufvfuHa1Rvnv9mi2f1sBHhBBZmqz9nK+BTIBY9qGrovGhoixNWejHf55o7UkYnNO5jmkqhJCe4ioWZUn57w/6GTImlsslhWCM9SyJEGrDWELs08WyIKbM+dnZHENI7968pohV3RjKUqI1Z3PQeeqmpvupao82V8rzXAbdnEJI73/4ARVj0zR+2RkybmlaDwF2d/2ClIfGjPXAj+WyKLApXl5eTpClcnZ2ViAXqa5rv3RkFVPVtTUUQkopSluWZa/Xhh66nQ6dZ2t3j7geIRnchxsespYp3MNubFN0oiorword3d5eXbWR37enpxSxreuGloWGhZD2t7e6GELSSUqhw529vQq7VSdPQGAXCAEx9IcxhsIT08nkHtkr5+dnd3dtejIZL5YUQvJFa621/n79DVtWq9ZZng64MIKdB/OfMP5Re5wQQgilNNVXt9vN8N7zPCcUerfXo7DaVq/bR17Sk+On1D6V0hRCEgyyDw/4LEG1fi83Yb/jyHbn2DnDuC87oSPs8WKxpB0Mrq4u3mF45fr27gqH37qqSww1KiXVOgYKz3zTNJ6lxUJ48/mCQgOJlE+fnlApUAgpYBmxPyEMNv8QYBJvY7Q8nk2nN7icvrq8fP36u+9/A0SIHudNl3O2OZIcj7fWek6QYN91/vw8hJQkCWGhtdaDfsuHStN0d5dCSxnxkgZb273t9nGW5/lg0B5vHRjGvaIacs6tLTnrHG100VhXYFhhuZjf4eN4Mh6/eduGNpqmmc3mdM5gFwgfVuMhJAfG903+mBYsbMp/QeHtlm0pAJJ1EuLvKKVGPjykR8hvUlLSY10ptXdwsEpnWdbDkFOSpLu7NA0Av9WDcIrhohmqz/GuR2XorAP+Kw7/ZYiFfWu8x7qqbxHvaJrmmy+/bNOmefcOf2mz9vra47QpjG6dpbHRWnt56TGRBT5nBQA9x4UQJe6IAiCIFQgAkoXkKJQGADu7bVoC7B21XCQQgoeQJMQQUlRUVFRUVNR6xVlCVFRUVFRUVFRUVFRUVFRUVNQjiiGkqKioqKioqKioqKioqKioqKhHpIVgNoDQAkOvxYMQNZr8nXP3aM6v6uqLf/lVmy7r//bf/t9V2jp34439rljS7rNuim/IC+fIAeGEUOzN8Dzxb2hzhaYtr+VsQfn/6utv2L34ANnJsd/F1gU78vpjqvmMjBjfffsNGRO+++41uy5j7rA38xOtqPiM8QYuEIG1wF+XsaUaZhhUzEXGHQT8eJ6JTeYsAKBLl6ahg06Oj2jj5OVymWatGUf0eyyDG0EtVCbj4R1V33fffDubt9X63ZvXtCk783MELIkHLh6q+aZunDeAAJkgsiwlLslnf/K5Z+vUNZmS9CbHC9uJ+oHFy7d6AM/uAY9nqcqiROPA1dUVmQu+e/OWvJZlUVGzBPDV3TBTnk4Tqr6LyyuFxg1jHRl8eoMtagSDQZ/MHc5a4dAYpT1PCoTjtcT2p+a3zkygxpDB8P7+/vq6NS69Oz0boUGvKKoGDRHCeCPY9GCf+Cw7u3tZp20zZVmSmfEhXArrBaSvYG78mc2mw2HLQjo/P79Cs8ZoNF4skcPC2UDcvRZcjhN6+B0Hf6wd4qT0vY1/V0pJwwLnJSmlyDaUaE0muK1Bn8yJL54/f44clpcvPyAuzNbWoI/GpQdGrUDercryHt4KOxa4Gcw3COc9yE1jKqz325vrd2jm+uKLL77+5utV+n44IiNhYxpqJ0pKpdv7ddYZ7s9dx6Li2S6XSzJ/NWW5t9eaifb293u9thyUgtSbg7gVL/CQrb95ZlAFIahjSGct+pEXk/HtVduuzk9P6X6d5XwxUNzIxi/B64K77DyzKRii3br+KNgjQEogpJ2SKk/9ZvZUznmWPXnSsn4O9vZpfBtsbZExUGvVyTOWHdaG2RPSWTI3SYWmJCmsxTZZFeUYH9O3d3dv375bpeu6HiMW0IXDiEfUOW/gAuEkOuU4lwqEEIzNZNfVIwigc0LYTWnMlACnxFkDmWZtWkpJbDKtNBnWOp0OMdc6eaeDHC6p1PYW9UHBTV5UzgDgWDv305Lwc2Bthgx6dWNOX7dmwLJY/I///t9X6aau/ukf/4lKYYw8MuFc5Z+VbrHw/n3+DE2Y2VazaQC1JSeEtIodQ/clrtAoJwF++atf0T3SeC6lfN9jIsGd+GkSJMzkGxUVFRUVFRXFFM4SHs7xcO0nXGOIE2nv71qAQlVVbzC8Upblz3GOYq0bIitXCNAC5zfOEesUQHSRUyuE8ExNEIrxNfmamK9h+Nx9iWtOIQSxKgFAMr7sEKEP4kEISfhr1ew85xcXNOU9OzsLkMkoHkLiuGuaF4pwLcG5oTy0ZBktlx8fMJWC6TXnpHCgCF+a+nTFaDl3H73KcflRlSXHLW0IHHkZT5sVs9m0Qo7Pxfk58XTevnlb4RIOgrCXLzlrfXgiyzNaAjVNwyi3Pjc69yGk+/t7YtDUdcMbLF/xreUHcQUt3a0vw7KqSuSG3N0P7xD7dX51NceQ2WKxMBhdVex+TWOo+pIs9UXhPB3o+OiIQgwvP3qV94grlGtNmHBLSxfpDHg+BQ/Drb3F1ddxGd+YBkMDk/FkPG55Ilc3N3cYGlssFjVycByrI2MNcVuGozGxWuqqovzbYPHqMwAsf411hJudLZYTXErd3txeXrRspvvRiOj4PGS5qR7Dq62789V5cImotCLGh2NIXWsd1ZdUMojYMrFwgMdvb+9uE6emKAoKk6U67Q8Qk6xkD8tQOIaOdoKYVpsqkgdpAqivs2Idr8Q5R9VhjCGM+ng0usTdD07Pz77DkMFoOLy7uaPjqU6VUhQ+M8aj0FmkNCgHHrY2TZMiDjlNkmtkbymtiFWUpYlgy/iQlUZ8mQ3hszAMF/DSEY23nE1H2Gdvbm7evnlH5UN9VkrJuy3H7Ts+ovhxSbA+yBDaAHwHgCD6xJhB1AeVkgn2cetsheGefr//HBHaR4eHz997b5Xe3ds7fq8NTeZZ1usRkjwQKyzrPHLbUYhKOuFou4OimGL4eDwcXmK4ra6qW4ZwDmLtas29g/MhpLaMUJKFOXwmxQN5htR6/CLrv0KIhnGgOhi61VofHOyv0r1O9/j4aJXudjqEi9Za97qeE+THWHaTHNsvwpBNEEL1n0ON916V1e11286X8/nXX3/Vfl5V//zzf6ZrlaVHNyZ+Owg/bQAQWZbRpYJpAwsn8TEKDAeC+/DWDf5UAABL/DlESvXi2TNMw2I6oWMs270E1nHioqKioqKioqJENLJFRUVFRUVFRUVFRUVFRUVFRT2qGEKKioqKioqKioqKioqKioqKinpEWjBTmARw3JVAb+ZbsVziLuZV+cWv/2WVLsvyl//SppummRGTSDjn3zx3FYcpaO9cGOAOsiDgEN9CF0Kk7M1t7yATomEGtIo5sC4vLig9XSzo/NzLork5LnAu+MO48aqsKjIgWGMYO4PZFcLNrelPCd6IwQ1l/A3+xjThBvbue4cEnBHu5pBKrvVhhQYBf93aGvaivqHqBobvkAAhbgmPF95EUFYVpYfDYYmexGK5pM2GTd2QSUQHLklv/2hYeZq68UYYdrRtvEnNVn4z6bIs6YX8sijIpKNT7ZkaoQEwdLh9/9OAwmIYY0WxMpHMpOOsIw+jNdZSeTLrCzCOhjVG4DHc8HV9fU3fff7tNzUaHKT0GzB3Ohl5JK0VzpE5JbgBbrQRzABCd6aUJAaTUkqjyQicEAbbT2PIyABOEBTKNA11N2Osv3fnu7mzzG4VIGWCclZ0XfClBQCKtia3fhNxZy03oAVeNjJFCrsJ5ebrC0CqNd7PkOPjiIsEzjnvUfWHKOVNW856V+divqiRIZWenZdo8FzMF0M0CX7w6qMPXn2ySu/u7m6xzbMDMxqzrPF+EYw5nM8SeAapEfgNua21VHfj0egCjWw3N7e3mLdisbCYf96ehXO+Kp1Qazf5ts4J4uCAxLyVy4LYYd1u5+3r16u0lPK9D17hOTt5ltI9cm1wJ272pdLjxvkxDZwgHpNz3qi4AiwJ/w++3Fjxs7YBgjabBwHcs8waHzcnMrNzSOfyQ5F1xBGzrL7qqiZjqTHmZ//4s1V6f28/Q27d1vZ2/n/+2SqttcozzkWiCwBgX3OcNwTepKkk0HUlALNTC8794dwoPnwJdr/rfcEAxprvHw9CsLMHlR10cWLMCUEPPMfP75xBY6CzbjptDbBVWf0CPfV5lmfIS+p0Osnf//0qrZPk+OlTui8yJwJ4Mx0I4GMp56aRqc1ae3vdGgAX8/nPf9bW17JYfott3hjjpyt8WuVExYxjMkGzoZRPjlojHkg42PdTowBvx9ozmUyFE0t8jjjnyrpaczwvZ4CE0JMAOvKPoqKioqKion6AtGDzEuOchxc4R2sbK9wS4wXL+fz1t9+u0mVZfo1p6+x8Mafz8pl+hbAAAMaGlLI/GGASXr58QV8k0IMQomZzLD7fKpYF5XOMXF4n3BhBKoKFkJwI+ErESBLhkp6vT6qytH4J7UMeScJXc/67Te3nykmiRRBMWKO6quicksMO2OGc9xSwSCFZi901nEfD5ouNMXSUMYb9E1umMuyxCL7r00VZ0fJyMplQ2KgoCuIi2aahab1kaxoJbIllDIUGDNT0uWYxJ9M0dIxj7NyyLKkpVlVF/IhOqv0ShYVUwghewPWgz1lQUEgnWOlI5ZdeAYOGhxcpZAbaH8Xvt2oa35ZY+Oz2/p64MGfv3lGx7x4cKOR0ZFkqU43Xqum6SvLlDV/6rm9wnPmilaJwADjncJnnGmMrVneea+NR3I0x1GUYGisIx4BYHwOQ0uOoOX9ESsYeYstCzswCAKU844M+f3AMlYmUUgDlBwRH9nJEN96LZO9jOl4m7PxSEN5HGONDsfO5FYhXd9ZNkfFUVtVi4dHgvX473Cmt+tsYQnoYA3qM/RRCgDy2/EEsw4cvLfF3ptPJLSLh7kYjClWIxghsw9YYYuhY6wTjznDstK93axlOHiyWc7FcjkctZ6fT6ZxjlL87GCzxMZFoKcQAz7mBBMXLJ4iRsNA5Aya5sMczAJsP+zI0nHDWORaf8DEeFhJlXUFIKTnGWAVcd8wDCBq7JMNOB7flXEPjhgTA8EFdN4Q2L8qKhsTD/eHRk8NV+uDwyQeffLpKJ2nquTmODWUg6WYgGOsc1SOw30we/NTBfgHyjxIbgpFkwEVi9xaEWX3bWP/YZfwjAKD75WEaybonCOFDXSwMZ6yhfrdQ6iucluRZNkBeUrfb++Szz1bpNEmf4FYGwgkteRGtC5UCADUO8OGYpmlG2I9msynxj8qyfPvuFO/FshBSwDbi/KOc0OBa7x8etJlR8uOPXtHxlsYlxlQSQlh6/gp3S9Mh664ZArIklhnrbCCAfloAAKliCCkqKioqKirqcUUjW1RUVFRUVFRUVFRUVFRUVFTUI4ohpKioqKioqKioqKioqKioqKioR6SF8LsUSwZScUJU5F5pmntm+H/z5s0qXdX1cNy6FZxzIZ7Fp3v99g1tKeUz3LFYSfnZJ5/Q568++hC/KTudnL7Ld53npqr5jExzTjI3waXfjVjs7u3hOUWKIAkA0TDDlxL+7fq00yUzwscfvaIX7HtZ7nkoHBi0Ds4iVuwbys/1NZkCxpMJGQF0kgSeKsa4sMNZAAAgAElEQVSPoM+V1nTew4MD4ozs7u2R8Ye/FW+ZAc2yzeMty/PLFy+ztP1Kp9Mh7FRgIuHGBympTO5vrqk6Tt++JSZRUZYlfu6EINaD1pqawf7+vkbjQ1nXdM7RcEiGjtCs51uT1p5ztFwuJ5N2E+Lx/b1WeC/Z01wi08GJ9Syq8BYZUoP/i6MK0EqS+SJN0yxNKT+02bmUkjN02HWpulZcoTadJSnlaDqdkRnh22+/HaHxZ3t3lzZW7/U6CRpVJMhgd/d1N7PJ/8SV6ISYF1opMuYobtzjTChm3pF853LmpQO2ubtwbm2pA/i2kSRpigwOpTSZYkBJScYK58hEI5UMTGqofqeTYr10ux0y9WRpSqYYK7xBSXpcj3DWO5oky/FisSiwXsaj8XQ2pX9qPEdMUBuwrPyL5dLShvFwMSNfLePRLBYLMoz0B/1+r7+msITnWEkRYN3WVzHjrzk2htTGkOF0Op1Rfsqi8BvbM86LkonG8SHRSYJprTXVV8PYWHVV0TgAkpkfrSWT5ny5vBu15prD0ahE01+V59SOAQLOS3Bfaz8PKVD+PFICsYqUJqsWSMk82p7nBZIhgJj5VEhJ5qZO3tlFdlWe57vIKQPwjwPL2qoQgbGOTG11U8/mrbGxKIobfFQ55xgzyBvuymVxfdNuym6MfYfGqKqqx6PRKt3tdrfQD87ZdoJ7G51vNA4klYnUmhCBOvFjgrWWYwH5o5y80lJK5ccQTZ50rdSg37ZnkNJjDTlrzzk+1DN+kx/WjDETNKaZurm/vKJDPLuNj+5OULk568bj9hmx0PrXX3xBZfXql79cpTt5vvfkCO9FHR563hD3cXOom/IZhbJszdRlWVxftibN6XR6en6+StdNQ2M7MD4A77wgYXevbUtKqfdfvmzTUn366U/avCn58v33fX5YufGpkWP8o3001jnnCD0phFhgvwOQe/tolJNS4fjJcVjc8LvZVRsVFRUVFRX1RyotWpxzK79AcYJYxXVdDe9aU/18NnuH86Sm8eAGIUTCjPQesgPQ6bYhJKXUJ68+atNS/tVf/9UqLUF++Mob/jnTsan8PMmwVcMM2ZnO2ScMxf327Jwd77+Q5hmlOQOVL8iyrmcwff7Tn9IUandri+ZWfG7tOZRCcFz3Yr6g7xZVaXBqO5yMaDmRsHuExnh2CcubYtzWJ4cHFM745OOP6Z96/T4tTTlnxzKOaZJmdP73X7xHKOVer5tlCZXD2iWcY4vr0d0dsRvOLy6I87IsyyoIISGuVStKHxzs0/K+qioKz02ns4bhmdl1xaYQ0gxDSJPhkMIER0cHBouUz3flRsYKR9sG+Gf6XEkfXkmTJEP0r1bKh5DAI2mD8yjORfI5SLSmpdRkMqEyfzN4d4cMixfvv0xwWn/87HlvsIU58/QSCHpq0CzZLXLuj19vaa0zbLqJVtRtlZSKFxYLm2pGwfclJfyyEDjrimGeOUKYo3zTJKH2oJTySyyppGceCUGhJRZSBCkp6j3YGvT7bbc92D/Y2WrLajAYdLotA8UwJovSyqO7WfnwOrq+vhoO2yX6G+cWhIo3DYU7E+3DXtL5prtcFDPTDk3zxVxjCEBrnSDvRifJDka3AY77yEgKMM88LMgaJYuOYrGg+FBGp2nqhkI2i/l8iiGkoigaZKNokNSGtZLUtvO8Q9H8LMu6yGopGNJ+PvfhNh72Nc4WVfv5fLm4w/IcTyaEsev2PAfNBUAv9vgIo5brw0yC9XkAQch2KYHCkcqHThhySlgWauHtE1g59Af9Z8+fr9Lbg8EHuKRXSmY47DtnG4bqoww54Sz2gPl8foXt4e7+forhJGOaEsvTCh8KWS4WxPcxjSEUugCgMZCzupxw/l7YfTnwrCInBJWJVIoQgUprjfw1Y6xcP544+lRKRWNUlmUHBweYTt+jX4mU3iHmFwBnaRHDCKRH7DvnUfpVVb49PWvLYbkY3dzi/fKIX/ALgUEkvHNisfS7akynbVkN+oOvfDip98nnf7pKJzrZ38dfm4Sj3Rg4gh0AFI5XztglQ+ZfXbXhrelkQnVkjC3w+SgA6OcHwbqvBNja3qI8/Dki0pVSn33+0/YYKQ+OT+i7QX/n+DPCijt3e3u9SlvrCNtvnRti2FFKODpGXDdIzUJIlpWnpACac/yXtqioqKioqKioaGSLioqKioqKioqKioqKioqKinpEMYQUFRUVFRUVFRUVFRUVFRUVFfWItHjAgvE8E0dOpbqq7vAN/PliQZALa4xiO/UGLgO2I/I2gRK0/uiDlnmklPro1cd0zJOjJ5gB8IY4EDUzsnHCSrmL7gnnet6A5ga79Ea6mBEvCcTWFgEjIHxL32/eTM4XIcRP/uSndAtHT54EBhOU5kY27Y1s49GYXjJ//fY1GbVOz0+JrmAZjwmYD4ObuaTw/3B0+ISwR5/99HNKb29vgTcI+HM2DJQgA0PcE+LdDAYDMiNwjk+4Q7P/7vD+jgwsp6enc2weRVmSicOx3cWTLCMzyMnJU6qmpq7pNs+vrsmkVpYlfS613y/bWUuUj/F4TCaI66sri+aF5y/eo82J0zSh7/INmjfvk84O4mY69gWltHpsw2MIzUeksLV5YpUxhtrJbD4nw+P11RUxRA4On1BVPnlykJOZImTHBPayB1miA/BfkkQT40YprTTxYoBuOeQ6MZ8Qa2YA3kAHjMXDr+s4F8ZZPixoMjwqpbxhzXcBx/IgnD+/UpqMdVtbW4e4AfaL5y+eHLUGjZ293QEZxICZlTjkRcBaX9TZ6ek9bobtVhgmIYQQ4/GEjEWC7S3unKMykQBkFBJOkDHnbjikjcZ1ktIG3qZptnd228+1SqkcBCtOlk2G/cH84f/95uvO0Zgzn04nQ9wkfrGg4dQay4rW0R+dPN8atCybwWCLuD9ZmnYwz+PJ+B6NaY01buJzQ0ZdVnOirmviwhRlRemmqth9PQ5c4f2LyzG3pGNb1YNU7KTAHm3r+4iUAFj+OtF53pr4tra3COG3t7f3k59+vkonWvn+6KxjBii6rHUe4TeZTDpv367SaZa9u2g912VRLj3az/u4nXP8UTVHc9Z0Or25avk7VbFToMlOKaVSNkaxfuSEzxu/ccn6IDOlgh+kggbn2NcdPfo7Wfb85Gmb7nQ+/eRTvJHk6LB9rIOEhFhUQlhm+qPrOuFq/Lwsyi00pU4nkxFyo5qmuaG+6URj/Hm4vzPBxzEflqqq+uqrr1fpbrfz9W9+3eY577x4/wXeLmRoOAXhB1Zg/b2x9pbQkIv52WnLqJov5uT9t86y50XAyaL7lVIeIZMoTdOffPZZW25KffjhR5h/6G0Te2sDsdAJ0/jHfR+nOs7aTq9HObi7Q0wkCJqSCYA0zfz9Bucn53BEIUVFRUVFRUUFWoWQeDjDM0eX83ZeWxTL25trTBcExDHGcl6Prdl8zq8z5S4CEbTWf/bnf75KS6X+9C//Lzo+VX6akjJOEA8hAQtX8fS09MfMJp59e/X2O0rTmlmEjCEnvP2fhaLEX/3dP1A6mKeyuaBigAOlffrq7Iym7z/7n/9f47kPEnCJFYaK/B+Gn5/N3E5OTmhJ89f/8F/yThvt2n9ySFNSzZhWVbkgbERd+fxnaUJnHQwGxBlxpvZLSsfWrNKvh+5u75bzlqXy9vyciOZlUTAGk0cUZ7kPIb18+f7eXrtUbhofOvnlb35N0bSqaQThigF8GML6oNZ4PKEl6M31panbpjibztK8LROltaeebwiuPFhKsX9gBwnPi1ZKUYhKiJAbxfDMIc7WZ8FXjLW0nLONMYwJVZbtvVzj+kQIcXR0RFirQb+X5Rh6sIayKuXD2T9dl9+lv5ckSQM0OLJRGBLbCfugLPAmWeOAIBpLZRJE5CyrPWsc3ouSkq6rlFIsauzbkrPOhyR8ZjLpl9m7uzvPnz1bpT/7/POPcPm6d/R0d79FpGVpQkNKXdcU1lHK496N9cvj11/85gYRudY5CiG9Fe8WRcvxsdZYHzKwDsMESinCOVvnTNN+fnN7N0Esd5qmOTKGer3ei1ftrgK9PCP8bcCyCTHzIQ8FE9bSkNI0lnZCmE8nFEJaLBY18omsMVSPzgoj23xmeUa7EDw5OHz2rA2dpFnewbZ3eXFusF6W5ZIan7U+PmqFo35d1vXS44fLCvtvXdfUNNTmGNK6iNnqcpY+9GFH4YifJSQICk+w0LYTfowChpcWAFTXSZJ2e+14srO9/SHu9nB0cvKX//B/t2WVpgPkcEl2Bed8czXGlVgXN9fXg902bKHT9DdffYnfhXs8RjI2mQvI8TBHdtKsM7sm5k5dL5EtlSa6k9GWAh5ZbYVwjtB4lg9MfFsA5ZHPQOFsjsAXzpe5kooeN3meffD+y1V6azD467/7+7Z8suzlh6/w/MDzZtiOEyzE7JbYv5bL5Xtf/naVvr68fIs7eBRFOUGel7W2mJR0Ho72zxIM7Qkfxq2r6suv2xBSr9f79ssvKf23/+UfqBzyzE8DOAGIeqFpDIWY5/PZ2XnLbCrKkqZGzjrF8OGErgfw6Ekl5cnxcVtWafaXf/U37TFKUkhLhJg24daEooQQFStPYL/6fFAQZtteX1zQ50sciwAEMekgPL9Yx8OKioqKioqKihLRyBYVFRUVFRUVFRUVFRUVFRUV9ahiCCkqKioqKioqKioqKioqKioq6hFpwZ0CwA03okL3QVUsyUhflOV80QJxnLWhyZ/vCEsQFqAN7xOtu7hDuZQycMFYviOyfxObc3y4H4g7GhIGUumjQ0QIYRHEIIQA2qEWQPK3wUHSyRLtLWWg/bUSnbiQRoJ502RY4Pfe73fp8E6WNWwDeItHSX4LnK/k3VLeNSCEyLOsg0a2Qb/fRcZBnmj6tpKMF5NqMgFlSUL50fKBncsbOtw645LxfghRLBfE46jrukITWWMadh7PjsmyLMHb2d7d3dlrjUXGeiZOnuf08v9czcn/6NhG6Txf8/m8xuve3t4RF2k2m+RUJp2MNqcPDIOhUYblmfWAME2YJKX8xufcWsMNd6Aky6pvZMDyH2xKDaDQdFBXFRkuzi4uCON1eHBQI+fi4MlRt99yatLEc142UmSYk00qBZx74jc+9wY3bvZ5wL9g3hd/PAjB+FnGc6zCb1PXAKmUbOtLSam9iQYkO6fvU0I4X2fePMgNd2mSUL/odjtdNBZ18ixB81oihcLuLxUYLHPg4xWDRe3u71OeP/joQ0pLqVK81t3dHfGAJIBkIyeZ2rjpzJgGPSVivliORsNVejqZLBdtXWdKQoebSvyYs76GQ38blWFVLqbT1uxze3199u7dKj0cDmnorqqKmqLU3sTU7Xb3ECd3cHh48qzl7CRJSty0xWLevW8fB2mS+PYgPXAIWFuy1jZo1KrrusTHSl1XZPIVEqRes3F4YOIL5QuFwY0AQPm25MdDeOBdFfD9z8EJ6w1BloxaSitibyWJ7qDxJ0m0pr7tHD1iXHviVZmAwMdflvq2SjA7EY6ZEBr0vCGuaYg9N53NbtDrap2b4ab1nU7ex/YP7aNNCCEk44tJAPJHK9bvFEgyXikpfX980PDIw8qMVErKFE1qaZ53kaWVplniuUJAg6NjZi4R1os3VUnYPWg5QaDkJ5+2BtX5fLEo2jZcVhWVCc+bAMGNct4I5rwvvtLl/W1r8CyLcoEGbaV1H58jAMDNXDX267ppFthnZ7PZDU6N6rphfdYFLmLu9ydfrxBZluONpx2cGinJGHYPEUWsXljPUMFB/h9yxtXa2dmmz7uZ991384zSbETkPVg8zEVUVFRUVFTUH7e0EAFiluY3TrgS52rFcnmL5v+qrmYII3Ah1CBl4Q9JoBaAhIWQBshnBan4usuugyOI0PDPl+KGhYEytvbIej6EtNN7TumyXPovW38tpSVNj5TzEzZtGS+JL20k/2MNlEQIsUWsSiG6edYYYkwECExY913Oaarqiqah3U7e67YskoP9nRyxTQr4usixpYtfogiWdpaXsw+wgJSeN2sp0iUaHxkQ8/l8jlPnoiwLXBPbpvFLC+VnoZ08TxFBdXh4eIjcB2MMVXGv26FQlFKKlk8Nu7BkBTSdTqmIbm5vqIlOxpNOry327Z1topvzMBxIwVadPnzmIJiy+5WIlMKHD6RiUUUqKpCMB+QYotj5JQQIv8S1jOsEfqUmlsslff7u9Owqa+n1R0dPjGmXPR989IqWVVp1KDzHzx/whgHAh2+kwjJRWhPXCaRkkRTfBIK1Iy8fHi4Bj5F21hEyLFE+vCWl71NKSooIK6UoWqqk5BFYjtymAnJsVJAAtNxN06SPzJpBf7C11Q4v3V43w+VTKqwiFoxUQlN4kZ2U3e/R0+N9wgAL8fSkZS3lnQ5R+X9lzN1wSMdQfoyzhDMDrSgE2TSGEMLT2ez2vg0/DUejBQ6nvTzjYZFguRjEJn2T5jsM0LXKshxjiOf66vL0lEJI9wvE21VFSUOBlJraUq/XPX5yuEo/f/7s1ac/oZNT3c1mU8J1JYwHBwEbyxettabCe6/qqkDeTVmUNYaPRaITNozzRwDdL4RwFo9hdj74yUMhUgJnnvt2Fe77QClrLQthO2ISJUpRKCRLki7+SqGk8EOCE4JCPwBUL1IChZ96nZz4SlmacFqxwrpzwtGj0K2uIYQQomkaCgtqrS+vriifC+TaWNPs7ra8OaWk9uXpfDaNH6EVu66SQCFdzbsj8EeWY4FxR6E6JVWKYYi8m28h8y5NEgrjgvO/4sBqtwQUH6JV0j7jEpM+fYl8pf2Dv120z5rR8H46Ha/S0/niHYZHg4eo87tJAEBKu144QRwuCXB7105pirKkPqi1Bv7LE9sWoMZ6qepmhmU+nkyucKcRhiMTzjnBQoGC4R0NY1QRVj/LMj81CvlHwB9hnIPGWrEOhk9/vE58Oef7fqcRw7CVHMXNqXp8uhUjSFFRUVFRUVFc0cgWFRUVFRUVFRUVFRUVFRUVFfWIYggpKioqKioqKioqKioqKioqKuoR6eCvwP/uyOngrLUs7XcvFo5BE4K9pul4aWWJO0k7a6cjBIgoSTtDSxDkPIINHvyHOBDH2EYPboFlw98nM9k5uQZMgJcmt4xkm5QH8BvO/Vl7LWOdwJf2q8Y05NFjRrngq8ALPTDx0Z+NcxVzhqh13CLHT+vREw/2qWfGQGHXokYc+H3b57NpY9o/lovFco5+QON5RsJ6jFKaplRT/X6P2Ba9fr+HjAnm5RK7u7tkkBkiXEYIYRpDL/ADc6BVdS1xg+TpfME/J0MEs2OFjgC+NfyGyguan/P3KKWS0puwKA3OGwfA+gtonXgTGbuSaBrOOuFZoLoolkviH11eXZEp48WLbyze+3vvf7C13bItEu2xYgHviYGgJAiFwAxQijaPl0pL6hrS1zu4IH/eoAFAfCLn/PECQFG3YlwhfvdSegMaQGia22CgCzKwjo3lnDeGGGsaLDdwlswdIMDHyuV6SwaAL38lgVBou/v75J86ub6scCg7v7q8H7bGk6Yo6xINWcaJdaY8wYwttmlqNNQsZvPhfctkyfPONnKIpHA6aKIbnCTMiEf5n89mIxxmr66uTnEz79F4UmFbstZSoUshifmSpekOGmr29vb29jA/Emiz8EG/n6J/TXFjr/NGGOucQHaMM9Zhu62KkjZEz7N8NGpNSb1eN8Nzhg8At9a7A7DeZwPghzgAkH6jesk9ntJ/EfiY4A2bbAN7howTzjkyKkqQHH3jN1PfwG+y1pKByBrDxhlmTgxNtZ6bY22NdVcsl7fI39E6KZbtmKwYXhAgsOsBd815I6qkcQCU8tkBXugOArOk50zxQhE+n4LqXUir/HUF2W1ByqDueN5QWsocDWjQdc9Onq7S/V7nPeRzjcaTwdYWlc90MvPnZOVgA+92m2iMKdBEqatiPG7bYZKkZdXgSbw331rHGVI0JlvmAgv4R04wE66w7Bjf3JxbIlvQGDO8aw1xEmT35Oj75cPHqNXF2QFrxgeQwFGAwXDKH4v0LGgz6y/8/XNGRUVFRUVFRYlVCGltAMNZR/Naa43BeZgxhkMlQoQ2fhc8I8lKSfALk5jRfbt+kFJZnGtaIfIOY2q4dasDxwMAPBLigCOKWX4cm7kpxuywDB1jOBdJ+ss5lpbhXCrklTzIpRBCWNPQPxRNTchY61eRQrNJnGX3ZcN5P12rskLhbYK1kqpG8QCaX1YBC6Tw4uT34qw/iENVWERIjMcTyv90Ol8s2mm6bSwtFcD6NVaSprSM2d7eIW7I9u4OhTw4W/T4+GkPuU5nZxeU1XJROAxdQeJjDGVZUmGPp5MKZ/BlWbJQneVc6+DG/KcSPH/Es5mkp/Gulv34uVIUalFKETdktaakw0kqSYg3JBgDyy4LR6wT1pUcQ4zPZ3P6wrvTUwoHPD06puVip9vVuMTq9To83OCXLo6FCME3OKWlwmWDSrRKKHor+fKGL4eoRTgAi0tlKzzIWILSGE1wwNuhlwSZ8CXu+mUtUAjG8diStYR/Zit6YYWosU/VpiHUurAm8XGCTe9augBbi5eSICikcvLs5OjkZJUulvMUmSYX15cjxBiPhyPqIyAcGCo335HAGIo3mKouEGs9mc5ukKXS6fX3j9ulcqZAYW3wEKrgRcow0tY5CqXNZtM75LycXVx897blxcxn87JABH7dKLbjAfWFTtYhFtLTo6Nn7z2nPNAx7777ppO3DBetNAvmM0y1ZVhxY01tsAyL66vrVTpJs7vbNm3MHo0PKojrMB4Na5POAWHpIIgngaUSkgoIGw9A+QEA5cc9HoXznC8Q/nhr/K4R1vCfBJyW/vws1MJRyqy6jG2wfZrGAHuMWtxNAkDSOMN/EnDW0rYDs8XyAllISqoloqA144sJ538BEgDC91lJacHCx1JJakwOgH7VADYpcMJxfCE9Xa11AQSIODsM3b26hv9qsMtBGOXHFKHHO3m++/nnq/RoNLq7ulylr66u/+c//3yVrptmPJnSaTyu2wVobeojStdznJYILQmNn6ZpgeEhzlwTQhBbCsDvNFKXZTBOsnIA35YeoNxJjrCSWVbTfSmljp/6EJKUvK3ynUD8efjr5HwKRBw9IYRiv6LxLyvJfl3jHSmc9YioqKioqKioKFQ0skVFRUVFRUVFRUVFRUVFRUVFPaIYQoqKioqKioqKioqKioqKioqKekRaPNhBGRMAkGbtm+TWuUG/3c26rqoUATfWBjAdw96y5q9BeyNb05ydnq7SUqp3r7+laz17/pyOz3NvOgtMZCzJ3zDnBjeehfXuj+AuQ2NX+Lb5eqDFH5ICepW/3bppqCjuLi+IwTGdTpZFa8Cxlpm/lPcr9Hs9Mknt7+52u+0m1r1uN0fzC9+ce29nh6qy3+/RS/jL2TzcvNzhdX0+m8aQgagqy4qamfHNMkBo8fbAuT8C3LraBpAP9hGnc4JcY4Thbanb6xEvJssSMveNhiPaWLosSzJZyAe71uOp5vMF3ePrN6+nuCn73v4B3c7J8+e9fu/7eYDA3SaFNy5J+icp/SboINmm7JaZcTaaGP7d3A3/sdgN536nCwBjgTlmRkuzvI/sld3d/cP9g1Xa1k25wI3qq4rqFIRnq3HGljG2Ylyb2bQ14CzmswLZKCpLsyxZfy9BXvFjVhemacjwOF8sprgBebksibHlnCVji5JSoTFTaZ2kGd5vlmUdvJBz+HuDTpIkTfB4xY0zvHtSW3LWGdO24cVicXPdmtfyPJ8igybLMjLpWCFoQAE2EDt2m7DRnLhBIWPIy4ngoReY+3ya9x3CP/EsONbGnAiHVjKCgc/2A7QfMCMnM46x+mWGLGet94Bby5hNfPd3fokfvwsJ70Ar1UHjc6/f39vdXaXLsrzrtG3VWUesMfGgqLGInHUVmgqTUs9mrSk1z/IaeWcSJLCpCOPKyV6v337oxC6yw+qmub68xs+Z3RbCXsu8uVM0shVVdXl+hveo94+OKPNbWwP6KrOtyyz1BjRvEXzQroLn1/pHw6bGEWCUfvwtKCoqKioqKurfUVoIwdfqHErSHbTrJan14WELyCiKIs99CImvGfh5CEbghFjM5vihev3Nt5Q+QciIlDLvDfCysL27Q+dJ2aSJRSqEVszALxjsYF0eMCOU9GmOg20YNAGk+sOfNbGJIS+3qiqpWs9O35YYmhmOR0tcmhpjiE2jE01T0p3tbQqdvPf8+RYuube2d/qDPl7W18vTk5NtPOa3v/0iQS7P+G5oCafFpuOGha7qutJYxcViQUyQxhhPald8JbUevA6CMaFCnLncFELyPKyA8Usn3d7aInz49tYgxft6bd180XYH3nkcuzQAUYnFcDik6yZa98/aZcbx0RExMvrb2xmG6hQPjTFQGUjpyfeMfa+lTDCUoJWicJIFGwZj10RyHxLu6V7Wcnw3K1yi+wuAED8okPvYFZwQYm1IMcgDPxE7yjnKQ3cw2MGw0bPnz6umXYLWRTlHlK+1tkZmjWOsIsfANk3TUFR9Pp+N7ls08mx/bz5pl7Lp9hbgMMvzj39TPrGsnG/QVVUvsC9MJuO7uxbXbY01GI5UUiocQrXWCTKekiTpYLvt9Ho97LPGWoNhizTPCZOvtAYWKrKOwmeCwlLG+TKZTKfvsA3rJBnethyoPMsaDDNpKYk7I3i/CEK9blPFM6YVrG3z7bcxRSEYJX1oWDI8PA+5CikJ0S0Z0weEsOHPF+3ZgXN/wLOHwrU94fmdcHQexwBm4JzA8bBpGsPTWKccUyjA8YFvfdxR+MJyP6Sj/u8T5U5pNdhpw0aNtc+etuywxXJ5eUVcrabC55QAFsoMsejUB5WEMQ6zZZ4vkVOmtZJyi/JAo7XSagex90maHmO4pyzLL774ki5Av6g5DmVkbCNj7R3i5NM0efv6NZ5fbx8c4MHSPPO/rmUZIsZBgvYh5g0uNg8AACAASURBVMxzKB1vWpLT7lm982nPA3o9u99NU6moqKioqKioP3bFmUFUVFRUVFRUVFRUVFRUVFRU1COKIaSoqKioqKioqKioqKioqKioqEekRWh05yykjJwUzu3g2+PLoiAXAxEZVpL8bWd2UtqNWEl1dnHeHizlL3/xC0rPFwv65g4a2UDKw/09ys/xCe0wLXL8XAhh2IvYHMwRvpu//m1tLn68+yMjAbAdqUW5XDZYs5fn50usmslkUiBjwjEDo7GWvtzJc2o22zu7OzvtRt3dbpeaDS/N7e1t2og6TdMEm4oAxhAJHAj+BJaZa5bFco5ciaosyEyXyHRt9f0Q1hVIKde/wA8bmwqZnjodwoc9OTigDaqbpl6gyeLq6nqBZorJZEJmHyGcQAuUTwmxWC4NbtR9fn5O5ba1u0t5ONjfy/FakgFyWAkKrVWq/WbkbKN0bqIJ7pfd+bpP/xWgxg8DsfwANMcPOcnG765lYwHjzjw4fG028jzvIgOlPxiQSTPPc41GRZCSI6TcOgOaMYY4LMtiOUXz2mI+J4ZR0+2IHyBm6mxK3Ey9WCyW87bPGsY1E8KbXAAkGWqSNO0hR6bbyan9JDphNB1v6JNKkeFUK0WGNSuMM96QSKYz57xPdlkUw1FrGtob70yQhbSzu2upzQebozMT3wauGdfGJuAxR4GtK6z/jeekclMb8/CAt+WdRcG5AiaOd9J6ExyAYJvBS2+mAzLQJUnS7VJ9daj8pZTc9Mfuc317/jE+1kCqDpp2q7Lc2m6fL0opGg+Bmc4AOCjIm8gEiAa5YFWtx9gH67quynZMtiaAkVFpKaUGeF2dJLvIYyqKgvCRzloyxIWWYsbDEmKObLuy1F9+9RWeXzs8Rko4Oj+ne+n3+/i5PEZ8pAT57NkJnZ+efUIE7S1srczJyfoDBEP9j7B9REVFRUVFRf2nSAs+rxLCg0ic6OB6SSfp8xcvV+n5bNZDnqUxPHojaI4r2BzOClHgXAoAvvr6mzYtgdjAAHCKLEkAoDkZAHz84UftyaVMkpy+u8dCSBVjGOVs/rRpzsTn044BLDiiu2bnVHwS+iPUWly6eAi48f8ym0yIS/L6228pund7d1eW7dLXWktfJ962EKLf7/WxeTx79mx3f3+V3t4a5B2sPnbdo+Nj4it1uzlN6wVji1jrM86z3BhDeODZeDzCZdV8Nk+SNlzVyRKxgby7doLMy0pppThyiy1LQq6Kx9/SFHx7e+vwoMWHffzq1fZ2G244ODykMNwvfvVLWrqUZVmxYvR8Chb7GQ1HFCH9+rtvJ9P2u9t7u8RGydJUIQ5ZO+Hp2AyPnWqd4VJHsb7vrFuL5hUhmvdBFEb861obRHkoCJYu/OiNcb71Ua214XDHCtE5tyH/rI+EFyaeTq8/sLJtD4dPniwRff2m912Gw46Sil/LX4il67peLttl6nQ6u7trWUj3w+GS0Nf9bhj/w7YnpUe5O0fDbFGWM0TOTSfjCWtXFsOOwvm6Uwyd3snzHVwSb21tDQZt6DPv5NQ6rBCAQ0SSqIzCTEmiPLfIGQwh8XbrnGcwzabTApH8/V7v9qbl1+zs7FD7tAJ8CCB8UTZACG1oep5rJsLY5Lo+GybXI6hBCCB2jPRcJGDsMyEcYx75fsciwEFozAng5PsG+52UHuEPUlLZAniOUpalO1ttfQ0GAwoZ6ERTu3X0n/BeHojyIAVsCiltCLP6s/5nhhqU8iwkIcQJspCGw1GKiPcagJ5fAMAf6x4v7RyNwwLgFvtgJ+8Q0j5JkuDO8A+t1DHyiRbz+cuX7dRoNp12u22/MMYOhxa/Bwn454gP4woYDkf04c9/2f6ipqS8H7b5kQAHiKEEgP29PSwH+QlOn5RU9JwVQgj2zNLsBvgkxlmOfeTlsybUFRUVFRUVFRX1QHGWEBUVFRUVFRUVFRUVFRUVFRX1iGIIKSoqKioqKioqKioqKioqKirqEenwz8AekjC4wBYz/x/iW9NN0/T7rWvJOcFgLt4g5gSQywYACAQD7O1xACAXDwggZ4cEkN49BLs7yEgCKfBNbAnQYW+2b+Eu1EKIHuOJcP5F4G9jO9cCA99IgE3v7//oxHA3P0hlUZChbDKdkpGtLMuq9FXM97mmDzt57jkd/V4XNwhXiu8i7C0WaZZTOtGJZptes82YLcOh+GuZpmnwmNFoTJeYjIb03V6vI8NL/+v6YQCIx4+RUtFGyN1+fxubrhW+qe9fnGvcmPny6kot2+OtsWvNI46RkcbTKR1xwbhIu/sHad6Wf6/b4SwVqjApFZk7JEhvqAHvP5XCb3AOGy1D/wYHyyao0g/66g+hMPEjNt7BWn2v8LEcpKRyVlJKzyvxbVVKEFRu1t+ls34Ics4bBpumKavWUFNXVYNDJd9RWwCsbZbOeSLZfDq9v7lZpYf396NRa5CpqorfPA13Uicpssl6ve4+eod3BgNiIekk8ccD0P2mSUrHdBjzqyyWrjGUt7WDjrWuQVNbXTe0sXpZVfSYkEII+Yh32AnmQAvMib9j2wj9W3RK6yyZoeqmIdPiYr6YjFuToJSyk2r6pjcMWkv1aBqzxHsc3d+RcW86HtM4YIwlo5zjhllhBVLmkiShx1m/1zs8aB/B+3t7PXzkdbo9CYzBtM66/e8zuv1vFY1pUmka87XW1M4BvEEPAGzgyfUmxwbbatOYknCNSjV+KhKI4/86fmrhaGyXSu/ttkazxjQ0jRFCgKdGgj8POMf6+2w6ozxfXFxSfieTKX1+f3tL+dQKzbNK7uy0RmkJcmefjG+CDNRCiK2BT2vNzGs/wMAYuUhRUVFRUVFRXFoIwai7gnvhO8hFNiY5fv5ilV4uFp+8+niVLsvyy6++XqWtczc37fzG8UW/c3XNOCC4thFC3N8PKc3hBcSMBAmzKc2fZI4MVwEwwfOAgBc/+dSf58kRpXPMvwgxqJLNjQxeV4QspwC68SNXOBeUj36+mM2IgH59ezubt1Pb6WRa4/LPWY9o5Syt7cFgG6ONu3v7e4dPVmml/BSfN7jBYEBclTzLSuJ6aE0cIutqQbRZFuar6pqa2eXl5Rzz+dHlBS0D9g/2Ezwnm7wH9bsBhhLIOcfWZBsCcpyjpFSi2+seHBweI+708PkLOmo6m97f36/Sr9++mSEOvLYV3RcPfVprqaSvrq7v8LuHB/uLRcvFOHxynHfasF2W6CTBkBwIiaWulcdpa6U0NXvnI78gFbDQUrhE/91W6Rv12LIENhTzD76qjz5T87bWcq6QPzSA41jBGgp9rpQibLZSCcMYe6Q0cFYOo92AdFS21vkQQ1mVM2SaFMslhW6tZWidDXdrnCDs/fDu7uzN61X69PT04upqlZ7N55Qf6yxFpnSie70WS3ywv//hy3Z4f/bsZEAhiTwnJBYAaCyKPM+3t9qw0e72Du14MJ5MqoJw+5aWx5yIba0hBH5ZFrQ8ns/ntKSXAI6RW9bi23gYjoeknXCeJQS8S/LuGzK0Gc+ImoExhkI8y7KksFGed68vL1bpJEn7GCJ31pi6vXdTNyXynkr23fF49O6716v07c01MeDKqqJhzVpHj0LppMKs5YxXdbh/8OnHn6zSewcHB0ft2JJlWYD2oigkSN6E1nc7HkoDzib7vfghhUVUHfVBnSQJcd+09iFvhh4XzpnG/4IFyJZyzlUYupVSUl2AAELaW2N4U+FR3W2P0s+ePntvld6azz58v+UilVX17vSU8lAvCso/CyFBU9P0w12cndP5L88vKE1bOvBf0ZRS9bJkB2DoX8r3kM0EAM+e0Q4kkH7wIZ2z3+9SOvxFbf39Kv2HMx2KioqKioqK+rcrzgyioqKioqKioqKioqKioqKioh5RDCFFRUVFRUVFRUVFRUVFRUVFRT0i/fghQkgQfkd2IZ6gWayqyuOjNm2sJVeCEGLWtO4MgGCnWBGY5vxb0+SSEADkgBAWRqNx+7GEr775ho6n3XAFwHDuYQE//elP6fOd7QEdP2CMJMc2WubGpc27F/+4QQA/BHZgmc+jWC5L3PC4aRoymFhmHpGsUvn5kzQjY1qadTLkrQCwfeKZaS7rdmXVGkayLM+zAvMmPFsksNl520pd1RZNMfejETFlxqNRgmaHpmno3fzfNVzqLNtMPXjdP7B3hJt8tx9aY8iQwmEc3W5XJa3BbW//gKxOW4MBmSmmk0mNZeKcJXOBs86AxXuvqC7G4wkZ0+6ur8gH2u11FJr4HEjpOVOK7kcxIxtIb1Kzzq0trn8Dwij4Bm8z/8m9i1s1mOkJfF0zCx08+OZavkx4EPGDgDnZnAi/SxvYW2c4/4g2fd8wFnEGUFM3xHAZD4cXF6355e7ubog+X4INtVnD72qddLutmWV7MDjcP1ild3d2O93WnJXnOTMz+sadZfkAuSo729vEUTKNmegRppsKTXlCAI0ujlW9ta5Gs1hZlgUy12QnF1nKbpnqZb02j2+C+anXnyekTPk2YK2lPlgsl3fIoBFCXLx9s0ponTCvd1Ohea0uq+m0Na8tl8Vw2Pq1Z7MZGQzv7++Xy7ZqqBCEECBB4wbwWisaP/u93pODto729/b3caP3nd1dOiZNEsq/BHh0wNu0azs8/Ov3wsvWCsBjFp3laX8Ir1UA6o+OP/gDlJY1eIxhRtcHfRCYMZb+QYEc7BAmUj85Ol6li7J4gnVkjLmtr/FioqZ+AYFBb613HgQo/zlQmzSyub5t2WcS5K9/+1vK2xW2MQCYfzrGr8pOp0ufdzpkdhNywxQo8o+ioqKioqKiNmnFQmLzBvZvnk8p5Q7Ok5pe70//4i9W6bIobpAPWpXV1XWbts4tcT4tHnBnbDDV8/lQPphlPSBAnL5rgQIA4vr6hj5PfWwCPnn3hk6o/DoBaD4nhBgMfDjJsbmRYtc1LG/hfO7HPZf6ISEkTnAejUYFVl9RlhROMo0hrkSS8jCEpKrs9XpbyInob291B4T5tGtjBoPtHYMhkp3tLcGWBLSyUjrxDBT2/eVyQenT8zMKG52fndHUvChLih2GS3j3aKU651gRPUAaE8/Cf8SR1XVTl2W7RDQ+FiYOjp/2sCmO7m4m43aK/6tf/YKWCqfGzEUbga2r2gpE8xrjl7jOETr3/OJiisiwZyffUBfrDbaSrF02aK01gVWUIiStVprKTYLn+DjniNfj3INV9/r0DxJDKoWR5X+LfofzOMb4kFIKFiIMwj08PsoBM8QGEo4BZvyS0jl2fgUAxGSxdFLnfNcz1hBfrDGNH4qdC/Ljz+9xJWVVET/r7PTdV19+uUq/efv29OxslS6Kkr5gjaX+2+nkhxiSeHby7LPP/49V+ujo+OCgXfomWSp5lAHzs7Oze4z8l+l0Np8vqBTu79pQS7F0FN7loRytNQ2t1poFho3m0/novsUPu52dLcIAB33wQbUwRvT63RIcDwfwgIBk4wnv11R3dV1TSHc0Hn/3pn3EjCeTDBH4UqkUWWM1q4tiubwftpyy+bKgXSOWy+IW+WV108zxeCd8+UgpiV+WphnhkPf39j7/k8/a9P7BT376+Srd6fX6+OsIZz854TZFiHinDcLfa4FJv2ebSjjnDPYX0zQ+vB7mk7YycE4YthcDHyksIc+trXHKUScN8cWkZ2ALEeIUHY5dOkmevXx/la7K4i/+8i9X6eVySejrqq6nyMNy1tUL5AkKwVhIQmvP/6J+6sAp6Vl11GYA4GvEUAqAr3EKJAB6nRb1LaW8x+mZlGoPQ71SyuNnz+haMuPthOH89A/6fTEqKioqKirqj1DRyBYVFRUVFRUVFRUVFRUVFRUV9YhiCCkqKioqKioqKioqKioqKioq6hE9fFeZvw/O+QL05r9WcrDVmtryPD86erpK13X1/nutu8E6R2/jCydG6NZxThTM4GYbb/DhG2zzF+0dg1mQswmEYBvjivv7If4h3rx5Sxm+ePeWTtTtdih98OSJv0cRvKzO9OM2r21S8MI/K+j5dEpmivFoVCxbg0nTNMYbmvx3pZTUJLa3d2jj4X6vTywVKZU3kmxg6ICUEl+ez/M8z9tqSpIkJY5P0Cw5ysbDaYqiaNDgUJQlIWCsYTgUkLCuugEet2vwjeE5EudBK6E/rbHEkGqa2vMvHHkgRG8woOOPnhyTGXA8GVO5Tc3MsM3LvRjbpSgKMgddX1+R4eLJ02dJ1nKpdvb2cjQ4aK01ds9gE3rmZXGb3K3/iXIcSvTvJ1h3P8753gAA63yKQrBNrx39J0isNpvHYyQzUm0GyjxautynxZlN1hoy4CyKYrZozY/LoiiRmWKNofqVSiqHBsZE58gs63R7/a12s/Cs21NobFRS+kcAYyElWdojs+pgi8xWnU5Ha/puzTzLAWzFm/iMLcqW5VQUyzmaMdMkpftSEgIGze/iqwp9p5vLPzAMemMUGTmLshxPWiOStZZMbUrKBM0+xhjaJL4sS3rklWU1mbbmo6oqK2RXWWOpzyqlPT8uTWjD+DRNdrbbR+3e7t7Rcfuo3dvb7aFBOMszMm1BMET/EJTNhiN+/yA4oeFujVzIKeNJKucHHLNN5/T9RUL4tGQuXP+hoDYgXLaNZrFOt3tycrJK13VNHnxr7R2aGZ11ozEiHZ2g56wQwnpDa+Cv54NUTccDSOwvAGIpfP6vbm4xLb/55mvMPXgjG8CzFy/o9HyaFLlIUVFRUVFRUZukhQh4iob5/2ktJITQfl2hP/zk1SrdNA2t240xWzjfNU3zz7/4OX3+P/6xTTtnyxJDSE5UDCNK6xYhhPCQFL+EcUIscC4uQp4RwXqEAAJVAMDB3p4/ns2HdpFzKTasJ8UfagBJcH5ngFO9vbqkqjx7926BHJCyLCtajlpLy8I0SWhq/uK99zIM9xw+PdneaZejjL7DuLYhVEJKRbkY7OwKPGev26Vl5LJY+myzOX1TN9Q+RqMxsXXGkymhgsu69pwRFgYSYSxp7QzZOUfnBwDJ2T3rFqQ8zFQ1DTXLZVEURRuSc7am0zx7/py4Hn/3t38zRBbMZDIh/kVRlsTK4fggy+BV4+Fohl3jN7/94vz8fJXe2tml/OedrNdvQ3tpnuUY5lNKSbaU8qhjZ4Nb/PdYQgAEyzbe9QLcDx3/b7iWc4IhUFgeBGx685IjU9hqkYFyTGMajznfcBJHjBUL4FlCLgzOe3S3WIv0DsKmDxhcmKWqaojXcz8cXt227Wc0GROXR0qgDgZSQdKmu50OsVEOj46evv/RKt3v5Tn2HWsNLWulVKCxbw62km7L31kuFoSFvrm57WKYsqkqYiGBlD78ykJsZVVNZ23YaDQa315e0u0eHrcYu1Qr+jXCWivZEnoDSsv/g3uIgl5ToAC+PHnerPP33jS+nNM0PUdsuZRSY/gA2KOkqiviQ5nGeCaaMRRCUkpTiLzX6z592t7v9vb2n3z6k1W62+08PWnDRv3B4IOPPl6lO93us/eet3kA8Nwf64ypqBTW4pn5zQdhlIestzVyGyNx/+FPy6BDShpD+E4FPujtODBMCPp5g58HAIJ+R0c4IXF7AQkyDKPwPR385x3EMmZp+tGnLa+qqascpzR1XW3v7mG6+c1vft0eY5rffPEl5XmKYUrnXMMf02yalKZ+mlRgWxJCSI+uF9NmQvf1a98Hgb4rpaTdRaSUWa9H333Zf0lpw86p+fQsKioqKioq6o9e0cgWFRUVFRUVFRUVFRUVFRUVFfWIYggpKioqKioqKioqKioqKioqKuoRPWQhQWAyCvZHZmk8AEQfwQ3WmCN0HzRNc3yFadMcIXvIcXuJE8v5nE5pGQiAGdOE4W+kszfzuY2Eu0IIWgEArxFa4QQ8e/GeP3/hz686mb938QeqDQAR/pb+ZDQk1NTdcFigcaOuvVdRiPWGJqWUZkyQBs8zmUwbrD4tTLAhN6YXtd9zuVguC1Y13GSxNv8AIJhBhvhYTdOQ+a6uKuLCqEyLTRtdPyag/zwiNFNYSyYLax3xLIwxhADTSmnsYnv7+2QWONjfJw7LeDolb2ld1dRNeFZMY+i6s9nUmLa+bm9vtq9aU+H2wT6oto6qqvZ+VWbo4A4uqdRals2PUSHniHG5AmOih6lA4FPxX/6e04e3aPqIG20gPNgzfajMldbEUtHKb3gffNf5S1nn21JZFjSEVmVJ/dRaZvN1jKvCZK2t6tYIsyyK6aRl99imchb7u7OCOFwgyWRaGVs17efz2ZyPFdyIx8vBm4mYacgYQ/19Pp/do5Ez6+Qlstggz9NU03ko/4E5cQPL7Htj1YZmHABv1h9Kh1hjaXwTADRmBgbbxhvWnLXMDw4SDapKSo2GqSxNiXm0u7NLj9Fur0v8o7zb7aL5qJN3gvbM7pfOL5gPPbD8PWiSP0IxM5r0jwbuPgXB64M3G04vo+mNlDJB/7tOEkV9UMrQuPfAUErnbxNSiAzNYlrLnd127G2a5uRZazys65rauWlqz0VyLmX4yPligWlXM8OaCFhs7GPGH1DYrgCAxgQAuEVkpJTyzVtERkr4GPMjAMx7fpokHzM2RkVFRUVFRf3RSgshHGMdB2EjNmeyLI7AuTbvf/gBpU/ef3+VME2zd7i/Sjd1o9M2TGON/RqZjs65u7s7TIsxIbeFu7i49Ndi8yelfcBLcsakn1e5716/oax7hrGAJ08O6PA/+5u/p3See7S2CheOlP7xT6UC3C+leXju9M1r4n18+923S8RRzxcLv2TiDYWdNc+yDuJgy6KY4RT28vwsQU6EdoaKkTO2iqqhP+/uhwtcEjsWMXSMV8IhN4zovWKOtp8vlsspooWn01kXOUGZ3qLlQbhu/Fd4WLQ+CFYobsMShWStJZZKVVUlNuOyKIiNMuh2NC6tP//zv6DjT8/OLpC3Ml0saOk+vh9SXSgBdPN1WdZlm5/T8pRu5+nTpyUiflWazuZt/c4mEwofAAAtOZTy/BQJzvn02uJZ8Xp+F941Y0XBwyUfO2rttRiG2TkO+3ZhdHtNtTrh2Sgg16+MnEdLCScsi1qGPB0W1gwZUrTs9GECCGE0fqnJGDppmvaQRZJ1Okp5XomPjEvGqLKGQqLT0ej+9nqVns1m1GebxlD+nXUUUpRKUSinbpoZ8npGw+EF8rM6edrFqLoEUEBlLijW2xhb1u3we3V5ORy1SOBlUVB4y7HhWoIkvox1zti2nZdlOUSccLfT+ebr9tFgGvPsebuU3dnd2drqYx4cqyQn17dLYN0ZqDVx1g+PMDgXNDhW78GY6TDPdW0pvMvZRjxUxNubkkprH9bx4UKtUwwZbw8Gn37c4gWfHB39w//zX1fpTqd7jEhmEI5+NwHWJQOiGACVs2N4Zin85+131ilkJPmP/wOI9v/rkjxMxjh6koU8JACFyAGExuOdcNaHRP24p5Xq9ds21s07FMrXScK2MqAIvBAPkYKezbSDaHkhxCGGkKxzJ69aRlJVlft77edVXXeQHWaNOUcWmHP2/n5E6cvrto8L56aTKZ7e8XHZIpZeANC2CUKIBYWihPjtV1+1h0jp+6aEj5G9JQE++ZPP6fg8jfyjqKioqKioqPWKRraoqKioqKioqKioqKioqKioqEcUQ0hRUVFRUVFRUVFRUVFRUVFRUY/oIQuJK9jXm7/azo4hagiHX0gle/3BKt0Yc3zybJW21hbszf88b9+4ds7RDsfOuekMGUnOjdAl0V5jbSa8AyVwFZWlN8EN2XmKYrn2RPDYru1/AAp4IsxSNp/PC3zpfb5YLrGIrPUOHym9m8sa69DiMJ5MCsRXnZ6e5nlrhKnrUiHfIWH+EmstGY4q470pV9dXZKarqtowPJbXJusUMzcZ09Ro9inKoli2zcls9QwaeaTcAFDhFwh2d9+k4BjGgvHnsc6SmUhwxgTzY0kAh66M3d3dCn2j+/v7ZJkol4VBjhIYC25Nf3DswtPp9PbmdpU+Pzur8ZyO7RhvrV1rbLFsY+zfyawmRLA5/e+DQADf8Nt/DuCHOGAmpjDz9BcAcLOMWHvQps3RmR8OAMgwqNnm7kmSgCKjH3NOMrNVXTcV9rXlYj4mE9myqNDkaIwJboAZbUhVVU1mrSnm6ub6iy9+s0rnic4zNNOB0CwLzMjmiIV0f39/c32zSg/HQzJsmsaIdf2CO8esscQsmy8Xo1HLahmP9yo0e9ZVHfoIvdHscf5RmOZ8KCbnGBtr7VNOa0WPKqU8N6dumgXWozGGEHsgwEniXrHLgT+tDI1UGY6ZWZ6TuSnNMmDQP0beCm7TGx7DdueNfv+rALjfT/FyCP+BA6KovUHAM2LYRGbgVWQqTNKETH9KqrCbrx/THlC52OdU1yJN2nNKp/f2yONfP3/mp0bKmxBdN2vbgHGWTHPWOuovzrmmRs6REJJ5/NmAFXQS/kCaTNu+L6UcDu8x99KzvaKRLSoqKioqKmqztHjA/WH/5pxfw3OUtQyYQX5OltCcVer3P/kYTyJOPvh0lbbOjYdDTNuLdy23yFr7i3/62SptjCn8WtcuKNzjRIWwjwf55CxJDsi4vaO5kfj69Wv6fIQMJiGEefk+pXk47UePP9ogXo9N48vt+vJyjvygy6vLOXJSjPXkK83mqWVZ0pT69Zu3xFgZzaZ0WNbJaMmXaUVpHhtybHnz7t0pLYPn0ykd5pzz33WOMM9SKUIjW+txyPPlMp23/KPR/X2Cy4O97QE1D534/AQsnRBy4fHG/BjOTIH/n703f7Ikt+79cABk5r239urqfZsZzq4hRYmkKEt6frZ/sJ8jHO8/9gtZkkOWqIXirlm6p2fvpfaqu2QmAP9wEwdf3MlkVbNnyCF5vjERg87KRGJfzs3zgQJOjU+7VB9CxGnX9WIemy4pz/wjgncX1hrThd/87vfuRnPevG6fPuu26H83nbm4hXCLOjjmzqQe3LSOtxyPPvnkacS1ns1n29sdg+PqtWvM32naprccnHNsfUnQ8AAAIABJREFUrvoN7EGEZrLeG1S2pUcOy+p9vUoWCbROhNC3zSOdiDEeHvAu8bOIiNsG4rQ9xElEzLXRWsNQE1zgZoOMngC7uZQZYwwzcSaT8dZWVy/r6+vcd2xR5LvXLqLFfHoUsbhffPbpow8fLsPP9p+exJME5vN5yLbK3MVSjCcnJ200ax4cHz34uMPrFkYXvIUmZWJeAiDwfFCMyZ9OZ6eRXzY9Pz85Pokl4nLUfWIk8ba8ruujo2O+h4dxrc1JnCa486qcnxWCDwHNK1x3IXGpMk4NUoOAq6Wgb4eEr0Jz4Xg0vrK7uwyXVbm50f06MpvNkQO13xyoLyvgFJm6hda6iqbD8Wi0d6WL/+rVvas3b3Ayk8mDAvKPdCqHNB4qTfxZ8Qpa++IOjB3ymwf/C9D2KDHakhU9QH2RQhM2juggIi7/UVVtxlNBxqNRUXZcP2stTnnB4bESPaYipQKanAj64PakMxGGcfnnP/hBTFl4+zt/2uXLh/2nT2LYfRpx123T/Nu//ssy3NTN3/7D38dyCLM4R5BSjJxXSjWR26VCNtWS53vcw4+6pZfW+v3IICOtz86YtaTW1xJT6Q93QSQSiUQikeg30R/U75MikUgkEolEIpFIJBKJRKKvQ2JCEolEIpFIJBKJRCKRSCQSXaBVFlK4RPgSCkYnx/7CRq8BH0ZVZB6psLm5Ea/7vb29Zdg7d+v69fisn/Ep7yEcRg8OpdQ585KUcg18YQ7nzocIkghBoZP/HBzivA+IHOkVnpucsVQww/CwhzPfCU6DDwi/GfgyPIdc9IMYnFJNOjQa0o/3Z4+mT/mDSt4Ns0XDziDzRc3oKO88f/2PPKysPQBKqG0b7Ttb5PT8nB0oWnCSqk1y7/FQWB5KZDFfNInnAmlAPJGidFZ6SFWsgTOymM/ZEe/05JjZTPP5nP1iKqsBEQJ1qnWWZfaCQA8FguIF9hD6ymSH0PvgQ+JZpOwD1ASILGo8GvELNjY2mAuzub4+i13m/OSUDxRX3qmUzOR819TNQnfPnpycJKYV0XlkYZyenk4jf8o5lzXv5Nii8GJyGnpeh5dVp7YUTwAnmhRMvon5PatDE3CO0iHc6WEfcgRY9oJOq2wsrlOtgTMV+LBwj4e4YyOGLp551aGjjU6H3Be24PZZVWVVdWFjdJbH+I/ZbH563Dl/HR4e7j/rWFfT6YwdwYIPynP6CZ0uuX5b5xbRKdLM5tp07cFqzY6WGtKsoMyd90xbmteLesbcojqw8yk4df46xfQ457g9102ziONA6xwzmPRKi4O2kdooEfXVo8o6efav0BeP1poZVePJeGt7qwuPx1e2d7q8LxajWF+n5+dtdPxs2mY2ncWXgjNjCMC18a3j+9tZLMPpdMZTW2FNEblIX0JvAXtL95e07+3L2Kpw/MlfAL59mVMqNuiMsRW4jyRmlkvNUBF6hyoMDzaT3jsyXGFQPpahdx6cEwM2FOCdpbLKWFTWVjwvlGUR691Yi6WVs73w+kCqe8crGJ8DqSKyAoMP7FzsvdvZ6dpY69zeFWYntbdv3oz3eA+OzPOzKaesOU9LIwI/cfTo4+oOirjfEel5bIcr3Uj82EQikUgkEqGWKxhcT6fFAjIEaNDkAdcBFjACiMAIVmIb4x0O37p2Jb40XLvahb1zt25c68Le/+LnP+fwP/7zj1RM7nvvfxDDYXqYUNkezCXzuEcipc7A5PTs6VMOt7CuKpD3RAjaSNdxXW50//oM947aEPnEBAk9O5fcPKFAuHX3jiLjYNq0FIt63RhAMgO4AeNsExDBac34oScHh7wEPzg8ms26ZWi7aFwdcVSwZm9XLFTxn2dnZ/yXk7i/VUqNRyM097B0grOopm64UOaLOW/LrbXctFp4uDQJcdrUNS+ji6rk+/efPjuLJpJHH3xwFjG9N65f5yX1uKqM6bcd8jbD+wSCCqt7ryTAjactqPeeWTNt69qmS2frErkrhAQB8tAebly/ytV38uyN48Ory/CnHz/a2Oy2Ge8+eDiP7JswnYfYNrQmFcv89Pj4NNbGbDovIh51c2ODt8eta3lbO5vOXMSQqZCwWcigyUx4qJDvq/qsSwG20IgqD1rz1pCINDN0PJYKsWnSK0rbVB8SM8s7pbipO7Agawe4mMRdAoR2tmHyLr03KIrvda1vorW6rhtGtjvn2HSlvGczCgHWl6zlerFFUUaz0cbGxvWr3XB3de/a7pWurieTCSfBheBiOp8+efLo4YNl+Je//NVP4/B4fHzCOOcWTDlE1tjuvT4kZtN0Pj+LpsPj42PL/CBNyJpBNhCXm2tbRvkG4PWEELj/aqOhnRDygNBsypj52Wx2GK8fnZ4ennUss8lsvohFW2jFYKQQFG7XUzpVMgVSSGbEEALj/wNw0zgupRSRYY5VVVVbiR22953vdsyaK9vbb77x1jJcL+bnkf306KOP/vnHP+7Sf3z84OGHXeTeh9infFBcL4qUjuV/en7+xeOnMS36848/XobX1tbXXrrPqYS8KO7vRBqHU+SCJdMbGBI0qbxtx7pWYBpORbO0JaXrPMkRpWeRIh28WkTEXtC+ST+lqKLfhBTwhTwgBpXOetBgjQkAfvPOsxl00TRt7OTOeQXzDo/DRGRNN0WS1pOISJ+MRlevdMuS0Wi8tdVxkbQ2Dn5OsPCrWBYnjIfepyUQm6iUUi0YVBHvVdj07M7OFofv3r8f8+KYveW9v//yS12Erv2Xf/3XWA7uX//jJ13avD/78BHHU0JdMopbKaVimwnaHx4ex/zS0QHjI+nW3Xsp70okEolEIpEoSRzZRCKRSCQSiUQikUgkEolEF0hMSCKRSCQSiUQikUgkEolEogv0JRYSOHRkJ9Til+S9kIUVp7bMZav/fhAxBCQEv7m5xQ/uXukYSc77nehZ4L3nr8FDhsqBL+3B0YyIPDiaNU3N4baFr7uLdAj983JeqBd8sOrcMxDnEHUgx7OAwwUBxyd/pDd6eG/Tthzl+ckROy7VdQ0fuicHqxX2CLiOpL9Y+GIf24yxlp0d0OEFPaFMYfl6RSMOe2DK0ApsBotUryRQKaXqpmZ3zLOzszI6cNWLRRO5DyH4LKI+ESHPop94gQ5uIShiZxkVmMGRcZFC8nkMCupUkYJnOdaqqsaT9WV4e2trseiclSaTCfNiFnXLThxEurc5ONeqWL3zxZw5LM47TqdP2JnMKQ8zvNLdLhZhI6a8dfdqyNsTKx6dX5LnbQDuSQgwZoE3CmUtV2eYsMBlmPIeIJl1U0/jQdrT6flZZI7Udd0mZ6V0sHdQKQ0e2UBERfTzLYpiFHk3RVnyIeKUDRbE+WqbZhYdoOazGYfruk4OffBe5B8pGBI16cSFUWQSAyiNLQQeRJT5JtpU5iGVm/eBeh0VVY6A620/ITHCvPfsKId8Lr/q5nvBuEcwTGW8pNxzFdheKax1chArbDEZT5bhyfr6xlY3DTV1zY5R22fnO1vdtOXalscc17qanQpVgHlUueiMVrfNSXRKLcvqIPpZt/VicfPGMmw0lckBKmSMm4zl1JOvQUF+sxJZqR9w5gVHOYVjWupHwcOYFthhrX9U6h6H/g7XezlcrffnJ53j1fT8bBqdrxfzOfdB51xOIeuZ0ylnIY1i/Y6qivug1gOUKUgbEV1ieZNxoHDkuzB+RTSedM7LIfid3d1luG3bK7ud779r2/W1db6Hp+OgVAM+7HmCUvphaUQtIyPhOpGS3xpFIpFIJBKhrFoxE8CeCp35WUSqBny1Bsd+ZAMxZEflJozeOJVSV/eucngnAkFCCLdefo0jZJCEa92DDz/kFO9//kV6F6yJ2SyllFrUyWx0dpzYSeenJxzeXrsO2UR2Zv8aMb+e8kJfWoTzA712pswMAbcji8o579j0kL2sf22X7b2hhk9PT5gx8ej9dxmleXh8xJRxHxKONGcYw14UAByj8Zi3NBUwiVAry3pWBfEYY/nRk9NTF5e/rl6wEcA5n/gysE1FE+HBwSHjih999OjgoEMOf/s732H8bbu7XcR70KSV79yBIhJw+wTmp2wrlUwbbdPWCQ3e8vbeNQ1bLYOzQXfbFaMT3rtuHSO9bty5txvr6PtHh0yUn87nX8St5ueNO8/4O10anE8mobPzc07n8fExt1cNZdjCfsMYw3knQIyhOWzFwKn6RCr1Da2JfNq65Oj47v8e2EbKB3UZ81PisARml7gMPEYazK/YgVPQOx76grYU24bzwUd09P7+wdPHj5fhRx999GEcgvYPDs4ivr1tWm57HtLgnPNxi2utXYvbwu3t7es3b3fhK1cmk24rW1qTLGA+cN8/Pj56/MXny/Dnjz//+NNPuzQ75wCyZSxzWxSbC621vD0uRlXJwyOYfkhrYIEldpKCMkfMdgjJVNq0bZ1MtIliHIAPpVTWX7gCnPNc703TzKadeW4+n7eJieN9apOhF8mcmc+0xl8RMuL2qm28u87Dmi2KcWTlbG1uvvTKK8vw9es3v/39H3bl41wT+VM3PvyAMczvvvfeZ4+7KWkxX7Q89UDjCypMI7pYHx798t13l+Gr+/vbWx37Zm/v2u7Vbkoaj6q9vSsxt0TA5UH+EZpLTM8wnB1fsGLZ6/m9KL4hhdIRBz6hwYPHyg6RExScwb6WzVRgXvc8K6J5kTLmWuyCaj6ff/ygwyAeHx9/8dlny/D5+fQ8mnSdczgd2CL9TgZHGahxNN1OJpM7t+8sw0VZra11fVCrlSEiJb8A1KNDDCKaWvB0C+xHUBAZVw5/veOAMS+/9i2+fu/V1+JL3Vb8da1pmsOTjv3n2vajjz7i+KZniNbGGk79oo6/qGmtz89O+TqeQDK2aSklEolEIpFIJD8uiUQikUgkEolEIpFIJBKJLpCYkEQikUgkEolEIpFIJBKJRBdo8LTWIa/+la/l8z/1R3RhnCp3oEM4BTOPvNFl2X1N7UybHOIgPStp8AOONgHYKAOJ/u3qEtwlGvLiuVT0GjhBDTuMHB0d1ZGts1gsmLMz9A5rLF8fj8dMitja2OQP8kejEYGTCycbHdAyUAXwJoy1+Fp2wPHHnjkXAZyzclYXcazBB0eO81VER4a2bZk/8ty1ntVR9l7sDuiogowYBw4gAXgxQ6/iLmCt5cROJuvMqthYXz+PHJz9spgx/8Inx5NVp8u+130JbZauA9fpEnpOdlj2qEolivwaRYGdQTymI1ycKALXHHSmU+grkz1AYE9Pbamu68WiK/PT46PDg/1l+PDg4Oio84edLeZ8OL2HcUxrYtfVoJIzizGah7WyLMqqc4CytgAfrJS04FP7b5u2qdlBMjkTZfUewOtPp3BVVaPoKDcaVVV05NFB6QQeowD9t3cI1Yp0TJ/3nn2W67qZRWfYpnXs1ObBzzQnmSVOFsGfvHfzyLiZz6azyJ9SZVFNRvwwNJoer7TVd6n+JjPUakkhZ40UOHJCHSXHt6Iox4mnMxpVMZ0+6HTAfPAxEThrOe+53M6n5wfRWdXacnZ21r0LoV2QbGTZaN3/gxDmcZDuM6hLPBCUD3Gs9v2MuVVmULqukROEftPJUc6HaSyf09Ozw6OufE6OT44jQ2o+T3y34Fwak1eTwQkgE53RrLFldEK0hU2e9jTg4HwJEWW+1Tkl8mJ20mC0MaCVYjYWqbRM0kQ6JjvkLZ7naFr+sbsn8ybO0ya/L4pEIpFIJOqXVUoR8lb71nAqX/cUwD/KUNY+Y6mke+B9CMXIYAeJ5awMxL93ZYcj34u8JOfcWtz/hBC0hndBGhjus7yPg4jQRmYTyvvffJ235Iumf6VtQxZO8cO6HokvK8v9ZFnTWgPjo5evlMEgoC6ODvYZVfuLn/2Uty5fPHnMOG3vPS8fkaeztrHO771/5zZzVV55+WVbdEvw7e0tvqcFdHfGf/UIRklptjaxkD589OFi0W1Bf/rzX/A2cnp+7iPzxVqbtgrQlhb1gmN9tr9/et5tw05PTuYz5j0pFZvN8PoeUaypmjJjkk5Y1ozN5NK2f1HXi8WcywQYIokQTCohV43WzO7Z2Fjnen/jrbcY5/z0ydMbTzouz9Gz/Xksq/lsxgwpo00y0Pl8R81sKd/ydaNNYqyoxBX60pZwwHwDCNj+GwZaKwFtl3TiT5FOiHEPfKicx4TbKoyfiLheAtuEPHCsMpMfGUaXBEXMZ3ny5NnBs46l9fOf/fTRww+X4Z/+/GcPHj1ahuvZjJk43nvK+DsJaESx2Y9Go63Njnezu7t77ebNZXh7a6uwuM3rtFgsTs+6ej8+Ojo8jDys6ZTb87Jclv+3xnCXN8Zw+7x2/dqd25G7tLW1c6Vj6xTGlAnBS2DmSCYPjJ9UYiHVdc2m5+OTk/2YtoOj4yex3FxdL5jTpKD8sdtSwszPZvPPIuPGGHvr0cNleGt7e3y3S78hyob9ZH4KfERAWP11AaBBfaYxNKeSpsIWMQ2aTbfBNVandm5G3Ri4u7d796WXluHpbHrn1q2uTI6OTo5PYto8m9UIsOWLuv4kMq1OTk44abdv3HzjrTeX4e2dnZt37y7DSLoPwAvz3ufmbMg7sIeGbOE9o0P3BAyJqb6yguVjCpq6xhMIMvOZh36H05zpYRWFEGoe0xY197vjw4Of/PjHy/Dp6enPfv6LZbh17vz0lOPBKS9NhaQomvy0MevrHYJ6bX39CvcFa0tgJyngiyEXzBAYmmBqwym7aWYpPdFEpVRq50ophWhIXG5lcUKkmi+aK1evLcN1Xe9GzHbTNEVEueOIT0S4bFtE/pHB9Qn87KEUGduPrRSJRCKRSCSSH5pEIpFIJBKJRCKRSCQSiUQXSExIIpFIJBKJRCKRSCQSiUSiCzTIQlLLg9iVUsuToeOXz0rrBHpYYfQM4ZMG4l9xCIJoMs+iFOhzlFmFLMDfkA2BYQtfaA/yI/Jov16t8EHSZfSGozBYkBdFD+GmrpvoyDadzmbz7mP7pmnZwS2sOHok/tGInWI2Nzb4w/iNzc0qfqi/ubnJDiaubZPzi9acteATF8mDI5Ixmqtvc329LrsmN6pK9pGs5/OWnR1U3jz65L1nxzfnHDu5ePBUDGoVmXGxQu8/Upvx4LjhvUNHkpwJkhzlemPXlNxMbVFU8SD29Y2Neay7jY2NaeQiubZN3TY/kBsPzIb4NXt5BfC7+m0ywoIK6MCS/S05KhI5cCpUGB6Ito+9olRvMagA1+f1gp06Tw73D/afLsNHBwfHzD+az9lREQ8Rz/tseq8tLFHXX0ZVxX641Whkbdd3tMk8R0Lkyyzms7PIfJlOp+wM5bxnJ5e8VWVjIPfTUVWtr60tw+sbG1ubW8twaQwTYEJQPvXNgGMO+CelUbapm3l04gukmfnVtO5s2h0oPldqMZ1xmXBdExE4kaUcNG07jQe0n5+dTSMPaFSVmfcj5vd5muuvuTX1Fx9CX9pWHubWp7UdjbppcW1tbWujc1R0bTuKdd2C058KeMo9OIM7x/7X09n02dNn8bo/jW2gsGZ9fS1LBf7v1yqbW1d7xcVlCCyhrMhNdEaz1rJjmtaGB1lNyfsuKGxX+cDHDrbOncd6n85mz54+WYZPjg6Pj46X4bPZedMmLthQ8tMUr4m5Y1VVTSIXbG0yKaJTNgOSVhSg6EJQNTs2+tDGuYlIj+L4rFRCKa0sZ5Dg15/i/PKKV+Ey4FfHGeidKdzvyLmykGB2ktY6OWWr3+L6RyQSiUQi0e+brFpyYaLYlBNCOD3t1nDeh8O4j9JaX7vVASmIaDxCcxKYYwCt4Hy67hMUQ1WwZSoAFoCLrKZlTmdiHoWgEKeNbCMLDv/lQHhre4fDk7W0Fs+Q3sjBSSnLFl/9pq4VKiWszHG7m6/tfH84i36F4YJF3ZM4jL8B9sL+02e8Bf3g4QM2Pew/22ccqWsTH4es4Yju3b3L26S/+csfrk26onv59Te4+iYbmzryJtq6TnyWskTMdsoXtAfvHf/h5u1bjPp+8mz/JHIuHi1qvu7aNhmCfH+5zedzxl2dnZ7xVnxRN6P4tlIDW2SFkQL2Bq49HxIzIvhk/tBQAW3T1LGJ1nVT1zHNzrUxqaQUs4q+tFdPvBg2ru7sbHNyvveDH56f8xZr8Thykf7pRz968qTbbtWLBZsFjTGpPSP7DK577z0gwAOkYZCxwgG0YQzuZVMugw/MBGlbx10YccVEGQ2M32u0NnFbqClxeYiIVFfmPiguZ5OZKnArpXkb76ACPvv0s/1Ynr/82c8/+fijZfg/3333o08/WYaPDo8Z5au853aitc6wtTEDWxsbG5sde+X+3btvvPF6F77/0u5exzEprUkoXNe0vqu7J59+/PDDLg0ff/To88dd2mazGZuHnHdtm1DxnJdqNNqM3KV7d+7+4Ps/WIav3rhx89797r1a8xbae5+YL7DtV5oQN0ZsKmoa5uCcnpwwYvyD99/71bvvLsOffPLJ0f5Bl7YQMsxwrOHWuRDjOTw6fPf99zmP21ubXfrv37/38stdPMB7UiobqxNrBtDOAfos2vZCUMjJYvOr8x5wzskM7b3j8UQT6fgZ78bG+v1XX1uGq/GI2+TDBw/YbHR4dPTs4CClOLWT1Ians9lHn3Rt7Hw6/fu/+9tleG/vKqPQNze33vmz7345HrVirWDMH97j+3+lyM3NySQR4B4iMokfl/oUEa1Fk9ZkfX1ta3sZttam4TnglEQOcHga+mYbH5hN5w/ee28ZPjk6+n/+/u+W4bOzsx/9+N+X4bZtDyN6XMHSQhNZsAQx08dae+PmjWV4bTL5kz/5ky7Nk8nmVmdOJZ2ZI9EupYEP+OSLrg96H87OunHAGHvn5W918ShVIf9IJR6T1iltrhfFGJRJs65ykJ4WTNWJDacSst1onczKpHEobpq0TOKvz0MIo1Fn9iLSkzinKyIVWkiTcJFEIpFIJBIliSObSCQSiUQikUgkEolEIpHoAokJSSQSiUQikUgkEolEIpFIdIGsGkAghBCSx5D3ZycdgIBIj+LXzqQzTxM8NdbCJ9ToKIdf0TvwaEifXFM6gVgpNZ/xadluxsAX54DT1A9PUeA2Q4p0Omk7S6fGT8Z/V1qBslx4z/MLGRNt4kfkxZg5bfF7UyRVVTHrYbK2wc4Lo/GYDxIejUZc1K3W7FRiygppDSwPHg3IJ5qMx0V0VJmMx+ykUxYFO5L41qXT2lc8CdPV5GjWNnVdd5yRum6YZVMUhi5TvIjiAihIL40HHUNUQNbPpbAtvalB55GyqrgeNzY2zmfdoe/j0YjZKz7ng/RjjgAxlqWZlP467csB3K1WDvmGpIWBMDjgOM8OGk3T8JC1mM8XkdFjwSMOGVVBp/c2ruU2dnp4cBQdjg4P9g/jQfXn5+fstOWcw3JMTpoqla+xhv1tR1W1HofNyWQyWeuc2spRpdEJi1knzrmYr9l0ehYdOaezOTtGteBwqkJytDFas/NOURTcZ6tRxc5Qo/GYuVqFMWVMp1eh9T2NhkhzIVJIPUyb5HznJi0zYkaTyShyZ6yxiYkGzpsq7zqcF+f8Ipbzoq4XkQ2UeeIggUz1C/0gKbsxpBdTCpOiywzF0EfgjHtPJjrwlmU1SQfGr02i8++sqpKDFRF6L2esJc/jVXsSfcmranQS26HWxDw7IjJcLzkT6jITBr43p+sMCIc9cBJcLGJ9LRbMrrLWjuO8QKSsYe+pFd/t2Oa9Xyy6Kj4/Oz3Y7zhQx8fH7CA5nU65jbk2OT5TSMwjUoqdvDRpLvOyLDdivUwmk3H0YR9Pxowh08MTAb/LhcCsLh/CSUybNnbzuFsmGa3Vxjrn3WSoxxRn4oJBXyAi7IIO/pHGLu+nkTXWNs2cx4Sm6eWyqbw74MXEPwIHQCLSJL8vikQikUgk6pdVasXswnsq9/lnny7DbdP8LAIISNOV6x1QwGhz/1uvdteJrl67Hu9Ro9GY42wV8I+KBAKYxXWnUgrBFq1j0Iz/MEIxvPcPP+jgCM77w2jSWoFDIh6boT+KFDKbrly9xuH1uKdS2d4GQBJKkYG11HMyJrPUEfVaggykGUEhK+BN3q8gjhTNbaQBDoImPJ9WkyfHx7wlOz+fnk8700Pbti5uoW1hE/oaAD/37txhZsSf/cUPt3Y6hsuN61dx6Znynu0TUrZywyOmM92/NRk1keD+8IOHx3ELfXx0dBYZQPvP9kPcSjVNk5gdOmG526blDDx79oxJ6ndeesJN/frV3coUX05DCJ6zYEhD0yLYdmaIWZZzjk1UbdsCxjuZHjzYkxA7o2ArSyGZgQyRimm4e/8uF+miaY6OOx7H0eHBZkT5fvLJJ6dxO9fUjWOei2sR702+e5fzjsuwLArYHyNmGBgxIaR4VL9WzEAZQ4rNi4B8xv6L5aahTr33bJo8n06P4tb6yeePx3HYWcxmx/F6UZQ2DjvOe05z09ZsNjo7OZnFLdn7v/rV559/vgz/9Oc/+/BRxyGanp+fn3f9RcMWi4zmegnes2V8bTRaX+uGl5dfuv/6q91Q+cZbb735J+8sw1euXeMhkYBvcnJ6enrUmbHee/fdn/z0Z8vwgw8//PjTblg+OztvIvbbWFPEeKqqYmbZ9WtX7925swy/+uqrb0T+y+7e1es3by7DVlORmFxpCvAhcF6ICIcpbqoe8ruom9m867NFUdQR935ydJS2+poMMdIuw70zi+3k5IQx/5roxrWry/Bkfd1FzpkOqatS9lsGsTkgYI8EhhcRMOoVJSu0xl8aCNsqmDmwzTtlmLNj1uLYUt69s7W7twxvb28fH+wvw48+/vjRxx3nyHm/YP6X8y5OVW2T+sv+wcE//+u/LsPXr12bRNPwjRu37r/65jJclOXW1kYsh2CIxxPCroQYZu47wafxDftU8P2mB6LEICNNbP6om/qTyAg7Pj558J+/6MqkKI/3unLQWm9sbHJykC01A1PIwbPObHRamu/eAAAgAElEQVRyfPyjf/rHLnx69g8/+lF3f+sOonlXK4XzDv/k4EOYL7o5riyrnZ0OfTiZjP/LX//1Mjwejb/93T/ryrAoqnFarmRTMDCh6jhWzGfzRx8+XIabpnnv3f/s8msss5mMtS+/9haX1eZ2rCOiyVpacsAPKCGRvIPiuVgp1brEJEIO4EcPPuA0MK/NuZbndJVXpS3TL2fJxKb1RjRnk6bda2lpVMEvbSKRSCQSiUQo+aFJJBKJRCKRSCQSiUQikUh0gcSEJBKJRCKRSCQSiUQikUgkukBW5af24t/4Y38fwjR+HU2a3OPu1HBjDEM9tDF8ii0RhS0+cZbakAxVDr6mdk1yZDPw6nn0tPI+HB52X617544iaMB7z6eVK6XwhHt0nGEgCCkq4b3szfTr9Xwea/jgsFdP+hucPL96+4WQj/B8aZsvFuykMJ/P2ZEtwGHk+VHgmOR0AjbBYerWWgsMhX52j4LD1PM4AfwA9xNx9VlrVfzYvqxGo+iwY61FdkNvfvG6B2eZ+Xwxnc5ieD6PzjLocIdpeF6t5JGdBXxIh4Jnh4v/Ju9IHBa+VlRVFQ9mXl/f4EPcx5NxEx3BXJu4V4geIg0OPp4C1NfFUJAXErS8gN0WXYxS2tCRTYGzyWKxOI9cksPDg9E4cmdms8kxD03aJOem9IambblepmenPOwcHByenJzE+Gt0bGHnIJ23ek6/Ngl7UlXVODrITMbjNWavjEZl5BBZkxx7VZ5BRv8sFjXzj5qmSfwyn7lqJYdHrYvoFFOUJTu1jUYjdhi01qJjl+oTEqr0MJ+Lnci01jr6/Bqj+foALmxQISQnR+c959d5zxy0oFU6aBzHkKHfRKDRhuQHDCPUSgaBmeWDB5ZZ7pjcJ6JUDkVZsg91VY64LlrX1uygBB0yqwtwFG2d4yl4Oj0/jtPiaDxem3Rxaq1tccHYmGcx47XBTJD38D4iWQjJSco5P40OnqTo8RdfdHkvinnEF2qtJ7FvBsiXD75h5yzXsiPY2dkZc6DOpueJf+d9yljO7MNEl3EpUhbFJPXBCYdHk0lRRhaYtchlAxxc0ko/YyfluqmPjiL/yJgnT7qlkbVmY3O7u241u5iv1AuPP0qp5Mi2RK1FJX98pdjpz7UNM9rapjljNhM4I4cQ8teBU1t0etXgRExaG5uWSZdp6iKRSCQSif44ZZVSrU+YUm26dZUPyvHee1H//Fe/Woad859EUIjW+v7t28uwseaHP/iLZZiI7t1/ieNcJOqlYoarUsqDk38bzUkhhP2nTzn8k//4cXez9/8UwRAhhP1n+/xsAeahWbQRKKV2r3QQBFJ0PwJBlFI7e1dTfgf4R9kiesCmgGusFUQ04KsTK8QDVhnI0Srg1tGhOQNMXSElw/lkDlAGzWfp9pQTpR598D4zXz54//1F5ETMFwtennrnkyWxe98ynYi4Hq1HhPbu3pWd3Y6FZADjqnHDoRLgB68rKGcF/CajEwNod2eHTS2vvv76Wdyi/PRnP+El78H+Ya1i06VsZ8FL52axcNHa+PDDh0+fdU3r5p27vCW7dmUbrJ9Du68exvDqH8A2VDcNJ2mxWLB5om2aALjTxJ0BKgYB5hkx5xn3Slk2Z9x7+WUGyzaz2eF+l8f/8X//j8dxS/Of7713wJwObVSEyOsVQ0gLzCNuby1wnZxzsds657iOKATexIWQqmPFnAfb8gBb0LZNrCjIIyWuTVEUbAZybcNY6w8fPfr8827L+u7777MJqaqqIm6HGtcyZ8day2ZQ7L9N3TBz5OTklM1S89mMzTeaNKORg0/9pQ3BxeqbTMZsNnrl/r2X799fht94880/eefby/DNO3dv3b0HpRKrXhtN3dbu+PTsiycdF+bRRx998LBjrzzb3z+JlnTnvGEeE5gsx+Px3t6VZfj+nbvf/nb33m+99vrte116yrKwsWb0KqpMxfLBEwlgkx4gjEyosmAe09p4vBbLqrCWrfyU78upzwbWNA2fnHB2fn4Y83sEHLTxaDyCqQS2zVmTg7HXZ2ZKbGZp7DKpTp3jPjufz3msWCwWCrlL2HsAPc5mnWs3brwd6300WX8WTT9Hx8fvxjoNyinE4cWx2ivF4/bx0fFPftExhr54+nTvajeFbe/sfPcHP1yGq/HoxvVrMQ0qk091l8wxbqVfJ1MdHkjggYfFeQ9OLepo+jlu//0//mMZtoV9970OWaiJeKwOwGBCESkdrajeezSVfvb4MV/n8V8pVYCZA3+H4bwYY3bj3DSZjP/8u3+6DI8nkz//4V8uw2VZvvzKK18uqwD8L5WfEIJ46Wf73fLj7PT0b//ff+D8bv77v3Ma3oiYSGuLH/xPfxnfRZvbOxwPmqctmpB4OgiBlzQhhMePu6WXa9sf/dP/twy3zv/bj3/M90yBhYRxcvkQ0bXIF9PG3Lt7O17XzI1SSnmflmdKCxdJJBKJRCJRkjiyiUQikUgkEolEIpFIJBKJLpCYkEQikUgkEolEIpFIJBKJRBfIKjgAPjvJOIT0Zbtz/EW98569n7TWZ/GraWMMn65NWm9uHvA7Gv5Ym5SFr9DxSFs+vTsodRw9F4L3fIq2D34BUADf91W8UkqDY9cYTuodQRi/7h7SizBxnldhIEyZUxiCKC7m0SBwZzad8kfss9mMHdm89xfmkT2JlFJaG3YC0s8JR8jKExzffs0DKiK0TFHwgcTW2lR9UECkCJ1uWMgeWtSNjY4SM2BCofPgkDyWOcBUglrBrHBIgdOi9+CYAOWA2SVwJBxkPPViy4j43G1VVtVo3B0aPR5PmMNSFCU7ZXg4pFyBH+VKnXy99Iu80fe2w6F+EaDQvUusnKZtaZGGiHTducTWcQ4d2bge27plR7YWeUPAzVEEh9BD+VtjTHT0GI3Ha/HQ7sl4AnUxZj6LtYn8FgJUd0jOUN45dr5rXYtMK/b1CyE1yqBIxTxqrRmxZIuiiO81tsBD61WfSA+2vd7rIYTMaZGdwrTmTGoNLKqMBzdMdYMCwrqrY58tjGHfLPNrWuqF48zqDals2ZnIeZ/SAOPql4hBPenQWjNzpxpV3B+ns1kqUnRcVSHr49weQuA2sFjUzOqyRcHjudbETliklDXP+/vQc813KZ3ep6UCLX39YrbSNA3jHvLIiEhr7mvgyNa2/GzwHtOGLRGXLjwvWGvX1zsO2ng8Go9Tfyyrri8UtuB4hqayzEsRmq0HpzzvPc+tmmg+X8Q0mLPIcrKFPT466t6ldeZv7hOfToNPNzoFT2dxCeT9UXRGdq49j86eHnhh2XilUpMkRUZbzi8vjYwxVTWOacscM58PYCYSiUQikeiPSVYpVdrEmp1HbnFb16dx3XN+dvY0Ov+3bfvBg4f8/IcfPloGjNbM0dSk792+xfdoQMY2DjHY2R66S0MIh8mEFB599IjT9ii+SymlYX0zmkw4nMxGpL733e/y9b/+m//C4d1r175UDkop1QKjh/d7q7qEXSnfoqe1J2VL3nQ/m8/UimkMAAQt8FzapkmPjKqEu4Y0LKZzNmH84sf/Povo6J/+/GdzNqOAaUkDldwHz8vQ7e0dtsptbK6vR1SztQa2iD3wEaWUyfcwwPfpX5ti3skWfNP123c5zVevXS/jluzd995Lj5AyGtFRjPFa8HsfPnrEJPV7919ipszbb7+5vb3V5QVMZh62r23bMt7YATck+HQPmuTquubd5nw2Y9zsYlFnJHguuqCJeIsF+yUoXDQ3oAmjMtrr7pG3v/OnXAXz2fTxZx074+x8aqMJaX9/n7HiAbeviFf3qZYQuxtgO61gK4VpRhMPKngfYFsI7JVUnliGDrhLxhjm6GIazk5P+f5n+yqxt4xRaA0B0wYPO8gzapoWu2HCSGvNZhcftNYpHu4XV/b2tmL7uXfnzp2IXbt79+69yB66fefOvZc79oq1RqvUbvlT0IXzdRPZN2fnTw86K/zjp88+j/U4m06ZjWKM5jbfNi2X4XhU3bp5Yxm+c+fOK6+/uQxfu3FjHFlRFLxiBJ42ZHqs6rgtXxZY9z/gxRDwh0kRI/arqlrf7MpkY2NzNzJWZvP52ekpx5PGScS6A6K7aZrjeP/+/v5HH7y/DF/Z29uM8XtDBdQ1sYkQTBs4toSgMi4PmDb42XqxOGWc8/k5/1Iym83ZlFNoUgScZDbPBUWx729ubb329p905bC1yRyi/3z/gwcff7QMt3Xjp5ErFAKzkMhoa8uYnvrzLzo20MnpGU+jN69fZy7S5tbWxtbmMmyt3YjcOpVbBhG3zOXgvMtMNmzl67ewKR9CWyd84XmsI6XUZ+rTZUBrzdNoCPirxsrMH3lwIbBZX0FdKKUIjlCwMEQzC6wsy3v37i7D4/H4+9///jI8qqrvfr9DNJZV9frb73TxKFVSypvBd6kUP+MRAxD82qadR1ba9PTsSTxdJITA47zW+tHDbrliC/ss9mUiYqy+Wk61XxIpYEipMJuln3w++exTftfHn3zCYTYtKaWqOD8SqbIoOdLNza5tGGP+61//Dafzne/+OaetLFN/L+QLdZFIJBKJRAOSZYJIJBKJRCKRSCQSiUQikegCiQlJJBKJRCKRSCQSiUQikUh0gXL/hRDSJ+akEjhDp5Ob0bNDqfRle1ChiU5wWutpdNRXitjjI+TOYr2ObApgCsHDCbtBISyggK/Z0duiiNAcTTQeJae2KkIoVt8LIq17Dx5+UaUzoBEvQMw7MMaA4xtxmWa8G4zoEhwiPDS9rmt2wsLDmxU61mlN4OzD7yrLkqvP2oIZK/lZ8P0pWqGD9HoAZveQViE5yHCZaGO46o027B9HBK2V0BMhiUijA046VB74RJdhQq0IHRKxOwDHBJzOVhwW+qtvKAH9jJUhaU3sgVYWZRkPPh+NRsBFKoypY0bg1UTIymFnopWD2L8ShQGgF0HTIkwPvJuyilfJJwz7F0ETRV4PdkIijtMYrUJyluFnTfLXVFprftYW1oDTFg814/FkAiwqHnaKsqRUnlm/5lJw3jXRka2pF3Xss957hQ1d95SD1jpA/+V+aqw1cXjMPIMIQWJZpeJI1Hd5WBCP1pp9QovC8rDctK0GFhX4l2UjI3ZnHseC9y04kyZsn9eqt60OSBOFzMmRnR81FHNeJuj8lRzfMioPCtswMHoKdsItiyIdGO8Ctw3ttTbgdJklIiWGHZDrup5HVk5Vlewk+2IgG+giKnMwTGFsJ8g8gpIjcJIlUj5kkaY3cf9SKht/wHmN60sTpTlIURnLtqhK6HcjDldVVcQxsKxKcFDN2tslSgSncSgHTdieOWygPwYf2BGbKL2PKPHylEocMSKysZ0HpZBdyPWeOYGqtDQiUiaVW1oaERH7+GutebwirZmVlo9LdKkuLxKJRCKR6I9SVimlArMwKZlmimItMoaCDxx2rduOEIoQAnM9vVcfPHjA8T74IIUzBCmuusEk1GaMpLR/QEjBVmRkKlJrk7UYVKN4nUh966WXYpj+9//2f/KzP/yv/2vKM/JuAOldgCkKwSgGrmdbiwG7Q7YU05p8NMEYw6uyEnG8RYqfQRhqtazS9sa5lhkxKlSptHxKz2J6zuaSRx89mkWL3uMnTxYR+alCwhVVpuJnq8mEs/D6q68yz+LOnbubW13VF0XCkQYCqoRGllBKv8d/KFz76rSFDj5t6SnRrja2dkbrXbHs7u7w6t8WBW8zrLFcQN45rhpbFJyX+XzOy+7j42Pe1k7Pz9nEpo3JrGMc8J63rMjBKcuSeRzIAyrLipfvbdvWbBUNnjG3GUcJsN85/8gDx8dy0jyYwzQFJgqTNT7G/8obb1+/fa/Le90+edoxO/7xn/758ZMuPD07Yzp+VVl+MQE/FvlBBJspxFGjcJuU9ZEQ2JTmvWMuDMKxirLgrY4rElJXZ9t1gm1S2s55xJwTcRq0SphY3HpZY3nrhZjnoiy57rTWaXtvDG8Rt7a2NjY6Lti9O3fu3O04LN96/fWX33h7Gd7Z2d6K/JHCEBdu8AGLhYvq+ODgydOny/DDhw8fPPhgGT47P+f8lkXpR7FMCPKVSkdtb23fvHlzGb59+/b1O10b2NxY4+GdVAATJ3HvDIANIthFkgps3lWkeYhGa55SaUs8Wl/fu3a9S8Odu2+82rFgnjx7yvXetm3TwAkJgJQGsDDNIx/n5OTks08+ign1tyJnalxVozJOB5TQ3Wgm0ERFkUwPOppvCA0IOrUrRcSo47Zt2QQwX9SJGaQppOEuhDgmE2k2DxVFweybYjTyfL+17z7spsjTo+MPI3eJSOvY9rz3izbyqiA959Ppx59+tgxPZ7N/+ZcfLcN7V/Z2964sw5PJ+sYGT4sZCimFoC+QQtMGFXzqRQgWzTo29RdEdxNMkWBSz/DMzqV2hfdgzx5Fdo/WesyIQ1IqjmmaqLSpbG9d75hf4/HoL/7iL7tIJuPv/c//2zJsjL156zq/twL0ulFpqvUw3WuTEIRg4lGljXNlYUZVZxquq3o79nHvg1VpLmBzZ9s0//Jv/5biRFwglBue6gCssewXsiFj11ZkYBHROKaNSDGDTGv9/T/rmEdG6//l//hvfP8b77yT8p7/MpTe+xX9ciASiUQikegPQ+LIJhKJRCKRSCQSiUQikUgkukBiQhKJRCKRSCQSiUQikUgkEl2g5TfS/Z8pa8MQBzsedY5OTeuqCBfwwbNHDwXVpA/Dh9zok8O/IhWGHMEGwumLbqIxsI3WJtGxHxz+iXQBJ9r+rmS09vGjfa211uwMBSfQW/DbwIfBic8Yk9gQ2Rv68xbQMSpnuxh2RgDegYF4isIyNqUsS3Zks0VhoAowBRdSE4iG3P6SNJHvu4k0sTOg1pqd7wxgubROnn4EHjjGGk6q8em61skZR0FZIdcJk0Jw6Lg2hh1ejLXoGsIhY1N9YTqHOFyX0fCz6HGUbrJF4uCUZVkBh6WMTny1tczGMgBfQfaHtTY5dpnEotJ4EPtl+ljO2uD60jo5Hxlt2Hc1ZCdtp4dJJS8LQie7IUc29AKFZ421VvfY0KuqxPwmvgn0wbXJhIed8XjMw1FZVtayI5W+sLaxjXnn2EHVudYnxx+C9mbY71Wr3IssBo3RBtKfDpt/7nHwN+ehGJ3SmY0htuDrQanEZSM1kBeTvLCI+H7vXeKaDZ08D70B+6xSyfeXwBmQiPDweIUOjMRjDr7o+cpTU3IcLopiFMtkURZcPoooIZZIGcXOd+ndRqOznuYyca5NzlNtw8WiVb8nUs700dDOk6OuCioAuydxf5b5if/QGZcHHNl0GmMp46zhPal+cTwfj0d8naITmSZdsZOgLSbcB0fjKi5RqtGIy8faxDLL1xVDK5RL1amNS4uyrHjJEXxgh2Wl1MJ1DphBZcjI7M0XToqh36OM8jCP54ponJZDip0oNSyZtNbISPpS3CKRSCQSiUQXyCqlAoHzfwQukDY37nUQjaau/6///t+X4bqpr/zjP3bX2/afo5O/9/7RJ59wPInvqFSRFm/BIesnIG8ITCpRRMoytILo3v2XYuT0g+/9gG/6/ve+zY/cvHOXw/defT3lE/hHwEPITTmwVoP9Rgb1CcB10nBPA7hk75NJYnd7m7eFm9sbTBOfjCe8ZBuPx5yiFqAMo6ri67dvXKsi48AoUswTCYrNK5iv2fkJ45yK8biNW6Cr1683ka/hEMqgE23m5rVrXFx/9Vd/yUyKV994cxwRVEVZ8UZMX2bpeRkmM+CNUZPxiLeLV65cKWJT2dnd4a0Fac2vWF9b46pxziXeB5iHNjfW1yddebbOnZ91SFqyFW+/Q0g4qvFkvFZ324Nr165O1rsyOT+f8haOMjNcwduha1d3d5ghVZq67fgvXqkAW1NS0bQH7Q0RyJkJJgTeeoWQWFTIf7l5565L/KZwdnq6DNfN/IsvPl+GP3j00fFphzMzxrBZrawq7gJXtrfW4nbu1o2rN67tcRlOojVZa82ppsC7TuXArOOCcrGIqqpcj1uv3Z0d3nrN6wVns20TC8lYY6Crhj5OE0pr4rzowjKrpbAFm3gm43EVt17rk8kobrE21tcnsc1vbWysrXdtfmNjc22t48uM4P7tra2d7a5+J+vro4jyzW2QKc0eEdohtDGPh8eHT7/oGDcHT744fNbxqmxhr97q2EbeeeCgJbYUmlBv3b1z6053/7Ub13d3tru8g/0jLNMEqYuBZOZQ+T1KJQ5OOnYATHUqBB3Ts7e7M7KvduknKqtuy/3g4UNTdXVxdn5+dHzcRW0tY32N1jbybsqiYFNCIPVkf7+Lc7K2f3i0DG9tbm5G7o9ziTtWluXebseCOTo+unr96pfzXhTFKKKFQ25KZvbT3pXdvc2uTjfXxiHy24MKaEZJQCkVqK98xpPxrTilEoXFouMfffH5YzaFTOfzp8+edfdoMoBFn4xTOrlflGX5JN5fN+17//nuMrxzZe/mS135F0avj9IUz9OZ1Xo9mhjmGxtXI0dpNp+fR4RzCCGNbwR9SpNljljG9yFkkhdgqmA+FGnN140xjFm01l7du8rhvb1unCmsubq7Ea8Xu/EeY+3e1Wtdeoy5EsPG6J3dK5zdjO8DR0komL4Hh1mc4uNPZKYo3/mz7y7D9WJB8ZbFYvGjuBxq2vanv/hF91Lvzw/4dJHslzPkIuFygmCZUdeJOVXFfkSKGNVvtHnzrW6po7X+qx/+MIbpzbe/HfNE127eiGF9515aJjHjSeVlpQATKRKJRCKRSIQSRzaRSCQSiUQikUgkEolEItEFEhOSSCQSiUQikUgkEolEIpHoAtnBvxAxlMQbUySAReCvqbXWI+Yiec9f2iulEmgmc2TLvtzGL7rRSwWccZIHBBGl95JmeIQmYuYRkTI2fbH/ItyZFxGRYttcUVhOxqgasSNbNRql62WZeD3wNXtVlokJYhOHiJDjMyBN2rNTUlG0katSlSU7WHl0yoNCr8rSJpZEyU4lWhvdx475uqWJ2KHMWssHk1dlyc5ERMkRr6oq9k/0zrEjFVBGVFEUnC8DB7dn79XJKcOYxAOqyrKOzBFXOnD0SM+iI1tZFNx9jAam1dfQPlfoNVxbyIIpy7KMXKRRVdV1dEYzqa0WZcUOTVVZlnBIOTvX4IH3lwFpDDG5isJyd67KilFr1prkyGasQT4LM61oyJEtXdeFZYeUoihsaj9Fld5bYpjTU1aprMqyZGccaxNnylhzYVVivQxxwZARY20acktIm/feOXAoY0c2GK6LElhOOrFg0CltiKf2VbXJvK4t+yOXRSrztm25/xprOb9aG05/WRQlc2eKgh2gLLTVPMkaGVvstGiLgtsVPmNtwdOKCsmPOwCDpirTGGitfX6kFLwV+EpF4umUFUyjPKUSMsKMTekPwTl2ZCugb1puA2awHhN7iICJUxQW2xgfWp87siWHL03awFzAjsZEipsTEaV2iGGtuT0YrSvgZAEzK40JhTHcB4213AeNtRqYR5CvHqf4r1KkNbDJ2AEz+MB50VozPjL4UI9rfjqA0yjO4zi34tQMgwVVwMxi9pPWmtuG0WlpRFDORMkpkkhduH4QiUQikUgk+jWySiXog1KqBCbRjRvXl4Hg/dp6hE207bXrDOZwb7/1Vhf2/tPPO8CKCmEGXEkL+yWdIXKTcEuVsNlKAR6bbt66zeHX3n6Hw2++81Z61iQTkh7YMg2vrnuYuyrHtWL6kVsUKJXbJAImlFJ/9v0fMDfk+o0bnFHmcao8v4j5RBPbK996jbfcG5ub/IgZsOmsb23x43/9V/+ljfyjt157jVkq1tqEHAYAyvb2Dkd7+/YdE5eh165f5zQYpRLvw3y969FRobkg3nzrrfm04xatbWwsIrMjwyrrhNAuioJr1eq01b927UYZl93Xb95iHofRiUOxvrHOW9x3vv2d+azjWbz08sv1otsSBO8T48Z7rj00P13Zu8Lvuv+tV7e2Oz5LVZXcHrxnK5kagjBje0DKKsGmFh8tjeJY79y527TMbFInkUFzfHQ0j2XoQ3pDgC65ubE+itvsK1evMQ/oyt7VcWzqRVEAghdYTpC6qkommFt37m5udYyeyXid03N2erKIQ4dBM5DWvH11znGfImTxgDQizI1RmrfiCc9clhWnZzKZMFtkbW1tHPM4WV8fR7ZRVRYWrNWpvqC0NJhOQkhtQ4GpKwArigCns7m51V6/EdNPVyPbZdnbOGuwBU0GHyJiFNrO7i5zYa5cvVZZNlnC8IIALQpqYBjBJgcmG+q9H3HUZVWtb3Z8qLsvvTze6MKvvPLqn37nO8vwoq657Sng7CBWmcA0VpUls3s2trYnsU1W1vAUVlqjI7vq9u1bbd296+79+2+/+cYyrLXBYwESDg/aP5Fim/T6xhpzZDY2t7mdkFLMm8MtuoIeEIClbK3ZXN9chot7L1WRwXR2cvzm6292ZbKYHx4cqJhQTpuxdrQ24WSq2P6D9y6as6uq2t3pGEBrGxsmlgkelWCNZm5Uaa2Pc8F89tL1G10em6Y9jv0xKxSVOEqIc9aU8O1BBeQNAZ5cJROGTiddGKOZHWatXY9jgjFmY2uH8379+l58lsoynaQxRMhGM9+KgVH1KZ920/VsWRLHN2v0t97o6st5v7nbsZnapn7ltde6cNs8/OCDZdh7/2T/gOPJfkWDMA2kDZccCbuuFJv5tKa333mHb773SsfAItJ3X3qJ70dUIoYR75iTvtNNYnASiUQikUiEkrWBSCQSiUQikUgkEolEIpHoAokJSSQSiUQikUgkEolEIpFIdIGGWUi5wKOEGCbilGJn++B9ctQPeC65MiF9/a6BU5D7jSUXAo5fUXL+J6UKy6cCEzCDBj5Z/92JAHZSWAvcipJ94rjclvdwWVDIvyWP/zTW4KG/F8po7eJH8kWRHkSHI+R6EHzaXljLH89ra0xyKoE8Xj4pX6mMSQtUugQAACAASURBVE4oRVEkhyY8EdmkzNii4KZrwTHKWMtOeYCByjwg0HnKmMRnKazl9o3OSsEHrnd0MMzeBWdeh99i0yWtiSI3x5jElCls4SPLA9wqsBnawiYWjEnt8EXAWERZ2SL3hx098KB6bQywdYyPfUrpfqoHaWCjWMsOLAbqtMjZOjzsaGuTAxGyloYAIisAKshkL/RohYuUnB+hbK21RfJ1JX41gV8tQZckIsbfWFvw8IhOkRjO2tsL8I+G2ElEyP3RJo05xsa69iG0PrGcFDjK8RilKbkMFkVhU30h+2bAAwj6LHJ2iDQj8wgc2QKMt6SSI5u1if9lwGm3j592WRE4WlpteDpwzhWQTkrMHcvTX1BBxfYfgudqLYrEy7PmYu9inEa1MTZhBCkxdFQ2FmD5cCPSmjQ7BoYQYPrW0ECBxUPIveI+qK3F9GjssxzNN2y615TYUsjwUorYedk5V5WJw8W8LTXgKLr8V3pFnyMbkWJMpIGy1eD8+LtiQYpEIpFIJPqDF4UQFNh7GI6glAq4/YAtOm99g1KLuuHrDiAIWifjlPfpnpwfiTaR/rVUBiZAZhNAASwslhE0gA9nDKbnXFrlwIL+tCEvCbeas0UNl1N+sayQP+XzDEOaU7gCjlIuSCdcZZa2Usp5xeYPWyTTVdM0/IICzFs6pHRa3Kpl0OaveakK5dC2jv/hoN1qMMNlVaGSiaet28QlMcBLQrsOZCXlXClFmt/mnOM4sV8Y5ONAmSzqxidWS8Jsh+ADbKETzwjLGfsCJCe3NHrVZ1ZYgXpgY+KbPCBxPHCdCLZ/zruQcLkpk4UxOm37+xPnfWrRWifkeSL6KOVC4G4bQkiobGBX5WNCQB4QXucwmh6wLjx2MGwnpIAMTn3NIVPojyYz02T7Q3wY7vEhMIo4QAf2ARk0KS9EyTrpg/eup8sTDJXG6AK293m7gUxeAr81NGxeeI/3HoZlcphf+OWApwbC/phHxOnXBIbiEBKXTRNzr3zwbeR/KSIPmOfMEtH3ruC9axNGWsd3adKZ5TT1l4F4Mhw1DZGewQztHVQ7DwXe+xbjAWYTmvgZGkcrJwSEvK1/KRyUqlvgK7nEGmNzHuXN28QXhBAawAKiMovbwE8g2c9NqCyZ/ZZQFE79mbX0EtM9Li3w/raBfGXLobS8cb6fJYTTLuImsc9imvG9WHk4fOF7TbacwHhSKiyUufc4HPnee7JhDcvzeX6+EolEIpFI9AcvcWQTiUQikUgkEolEIpFIJBJdIDEhiUQikUgkEolEIpFIJBKJLtALmZDoS//s/ss/HaeB/37z9/7++Pj34w0ud/9l/3JhnEPldYly/EPiKejndLgbzvvzlsklyvk5Y/xtir7m1H11XJ4XefFv/q5fwwN6gfj7nx0ar1cH3IvT8FX1hd+eBlgxLzaVvMCzX4sGeFU0yOH6GnIwBL3LvMMu8ejAsy+UtK/onhdLxAu9YelGfMF/fcuky6wlvgn9VCQSiUQi0R+8KISQOeoP8IO8QzJM/zoRly9+wJE+d/7vXxbjKiiLB9KDAIVLWQYuAfLIb0emiRu4nu5HGEGGDM85LL3xYPqbJnGjkEk0BE1AiAMqM5dA1Xm8H8sTMmOGwAfQBlqfeEC2KL/WlWto2wSZ0BoYwnATAiyAl2SNSX8ZgLZ4ZBtpxCdDOcOrEmBFKWsTunsFTJMBdRKnKQcU9ST/S+AS4JXALekmrUJKAzB0NK1Yf2I8eWXx/chCstYSpBkZSdSXHuc8Ny0N92C4ly2tOk5TgH9h2mLSIS9w8xLvg2nriZ9C2otdqp328YOX8UNdZOyzPJ09z2ZtL0sccqlSOeOjmpBkRdmwnBhSGCWWeeJtEWnEtH1VO/yLh9CcwZRR5HXKe4axg0g09h1EJ0GSodxSPIR9WSnkCiGy3QxR4Qfy1VtWYRXbB1juoflpAKeVNblsiF55YbwHrhFfDwDHp8SHUivzBbalIaZVjhhL709RkRpC5QygDHNy4ECbzOL5zX8FGVK2pIEmkOPMVG8Y+2ALU7axA+eTDEzfmYauDw2beYJSNAOP5vWLj/aMJyt6kZMTRCKRSCQS/eFJVgYikUgkEolEIpFIJBKJRKILJCYkkUgkEolEIpFIJBKJRCLRBRITkujS+j3ELHwdDnZDnimZ18w3jknxTUvPkL4aFtIL8ZsuUY+Xqd/n9Vi5jGPZC7W9IZbNb7OtDnF2hm7Pwr8vbfiboMvAip4zxm/cmCYSiUQikUgk+h2IQggIKbiMP/4QD+h5l5hDEA0HkAIEEwwxlfQlEr3CLknBS6Q5hzj0s6JyYfmk+xG+gNAE5DqpMABNyKAYkB7VB6pQqm1aDlsLTCWXruvsOoAhsMwH84h19/VuLYZ4WFk7gbZRNw2XelnYi1k83nN2tDGcHYcAC4Vl8pzQiiEQxgBwJBOwclAItnBN4yKuq7SFNpqjREYPRtqfHkwzsFSI+m0PmGIfPLwrPYHPBg9MJRW4SD1kfuVZTE9vOofuya779Iah8h8o/V//rsjfycuzt0AvxcDK40/lrwdbyvBQzG0g41hdxno1pKHi7U2zWmXcXFxNl3kXMo/UQL5y5svFuL1e9NVQPWb355yy3hZKK3avYRxYSgDncbVZpn6RDUE4xUCfhaEyiykEbPaXKKveBIfAw2/G3noxbg7Wu2tbjn8QzzcUD4QvtyzpZwC5HG/H0iZN3xkCD0dKmKabgSH3Mu1/SPisye5HtGUPd0wN98ehfifWQ5FIJBKJRCj5CkkkEolEIpFIJBKJRCKRSHSBxIQkEolEIpFIJBKJRCKRSCS6QGJCEv3R6wV4N1+7LpOG3xXX5ivSpbhCl4nna07Di7z3xdrS8z37TWi3Q15szx3PNyAvvyv9MeddJBKJRCKRSPSNFYWQo3gQjpA58Pc/3zZ177MFcHYGMagDOB3vhxzyB54dgou8wBLcD3B2UBmLB7ZMyO7JIA4ZtKIfdoCQC4yfLhH/0JbjeVlCeD/CIIaAFGaIDfQVyQ2whNo2pd9a25v7MFDmeqCd5DAIjAnhI/3gjEF4RMbBydsqs1Qy9o0eYs30vtd5z/wXo03vs3lyBsph4F3BB+7aBJSYHKQC15GJg2UCpRIGuuzQde89J0lr05tq74OPVaNJc1cKzwkcee6tex5PxtOBMul91LVtul9rHXk0ObNJAXcp+D5EV86+yVMUo3LeZ2yXeL8mZS/Br7kMw2jwWQ54QO8RhYGuATwsjQyX3mIMQXG9r3B5uHxCCM4ndo/RiRWFL9VQX8j60cgJGuhK1FuGv4YPBcwjHFDyekzsJ+7jhOWjqLd8Qsjxf8Ap60lkT6oRtxefVcpchm81FOfA9YuTtFKGQ1P8V4RiHNLgkD4YPzw7MEWGbKmTvey50oY8piFO1lBZ4TLgeZlTIpFIJBKJ/jglXyGJRCKRSCQSiUQikUgkEokukJiQRCKRSCQSiUQikUgkEolEF0hMSCKRSCQSiUQikUgkEolEogtEIYSMETPgtD/E/bkMfwdBBkNO/kNO+G3TcNgWia+Us1oABHAJZ/7nZaAgcweLB9/VQDoLSGceTwvxUO/1sqp6r1+GeTSUr5yLAu+FNGP8vTCO5cNwPV3+mlFIWfqHOD7IysE86gHIi3OO7zfG9DJrAvJ3BtrVZeqCcvAEN1dtbAKH5OCMdPkSbXWFxMNBLBNjLfVdH+L1DHKdQN45fp3WOuM6Ad+nv2zhHj3AfrqkOB7vPQ87xhiu+gAYrBW2Wm/x5ggsUn3t6pIJ6y3S5+2/iijrhSorRk7zYLQpEByXg0rsJMphdb39aCiplymT8Gs4SgPXMwaQT5wjBWXYez+WA/KMtNa9Q0HWVvM48R7gEK2geF6g3ebvuPB+6u1fK+WQRTnQnQfu6X3Xapr7poOM45YzuS6jrwxJ9pzvyodl5Iv1860uUybD3Kv++4c0mHd8F6TTw3Vj7YXpvExecMlnB+IUiUQikUj0xyn5Ckn0h6DnZaN+M/TbS3Nmxv0D0opZ6sJ7LnN95abfKF1fpS6VzEtF9LzvvQwz+Ostn68q/t/P8UEkEolEIpFIJPrGSUxIIpFIJBKJRCKRSCQSiUSiCyQmJJFIJBKJRCKRSCQSiUQi0QWiEIIacAZZZYKkexSEgUOUUyLwJRhR/7uenzOSwoOGsIthEM8r5CIZ0/9efNcQI8lnfCjde30YWNB/DyJNaAhQ9JxeMZgEj9fh9sF3fQ3C8tEDUJWsXQGQwiEbSBt+Oni8f6DMfWD2hCasd4RCZfXYy1HyAB7DeBBssUJJQd5Q4qFgmvuLIceO5dHnLJX0bP/1FZwWvgyZOL0cGQh7ZMpQyotWgQirD7NzAXOHiHp9lDAvChk6vbEs89v7h+H+wlXgVcLJGdPP3PE++MC8mIz9xE1a69SiB6pO4XDdX+JLNo3ieyAqrRXBPVld63SduTbPyai6zLMrfKiUF4DwrbRDTvMK/AgZSbp3egqhdwrzwTso8zQQEPVWdggq9E0fKwypoabCbT4old5LmocmUgphV1l3HpoOhqZjhXWKrCIoT54+sntUap8royC21UFuVE+dqmGU3vMi5HzAZ+H+gWHwMiyhQeXoOg5nw/5g9Cl+HAdan+Ihuvh3u6EpfujFNPBeFOZlED0J+EXhH4lEIpFIJBqSfIUkEl2s8CLcIuGwXFq99qNfe//vpmxx7/oi8r9NRlX4BvOwvsF1/ZXpm5B+bAMvkJ7f+7oQiUQikUgkEv2mEhOSSCQSiUQikUgkEolEIpHoAokJSSQSiUQikUgkEolEIpFIdIFWSSJtZPcQkfmqnOEBBJAxjAAK0ALsoKljGpSqRmW6Hxz1EVsxCwkqYYDiYMD5qEBAgO+HNdAA22jok/2gklNAL+BDKWVMKkP0ISCM1ad8tQA7MMA9qNv0sPfpBW3bckxYXwjRCAA+aOqaHx6PRsx9MFA+ZZHCQ7APdOxqffoHxqMVljMwjDAqKB/MVz98R6n5fBFicyKidKNOb/PecfzOpfdaY5hegvWC5A9T2Iz9wfwjZDBpnSgowXO9kknPuiwvqbFinZKCRh9SmkkDqIISzcY574C5k9IZPFe3c96lotapnCFO17ZcHQY6jDGay9MC06cJmlkkkHNlKTGMgve9HJwQUvoz/o5O6R/ilnjvmB1jTXpzfn8awShAq0Q2UwgqxhMIb0npdD54bldac5qbtvUudk/g12B+XULNKAJEFylo51oHbnvWMh6LKFnxjU4tkZArlLO3UlciDYwecvFVzgNxK2PW4LM4TpLmZ0NoEy+MdGw2VgfDrRjSpgjaoSKvUt6RRcWjl6Y0LBOloZgolVVQyqVnNU8T3vt5nJ6MNsxz0cqT765rrbn7BKW4vwSlPPoeItMnpllr4uGLKNUjxoNTzApjKGOH8VgUQspLUDwakVLIeLJxXPAhtE0dr+shDk4qWw0cK6W8g/qF9k84VaXoiNth8N7x9Kq1tQW/MrWZrE1SYdOQwlMhBWVwwIYybLgPKtWkYZm4R+oMXUcB+pHum3o0UXovUYF8n6yu07uyaUVD2uAPXP6aqLBpaZGxjVqYg3DMgWF2FpcxWlEFZVU3abrH6Qn7rI33k1IVTMdpLFLK4nJFY11AHnEug2cREZjfA+0EhwhYoiibkI6zJi3tnAfqGj4LyQxDPEWdatjCdQ3t1kDtYTQZowryNYQ4dG3L3cfishDaz6J18HAiTXnXqjQ8QhnicgKyVaq6qxAzUiKRSCQS/QFp0Ej0TYAdPG8Kfvcp/q0ox+sO3BPy9VaGTPZ8z/NSzL8avRCDI7P/cZBCyLZY6Ra43QeVtg1hBYbLD/JV/zU0KEjCsELoNasgyQbjweLMaDdZI/AKtpq9GQsh/E6aw5BWrLK9abvUMHWpaszMyjnKtwtgxaG1KoSEGTZE/JcADYyGMjCUmkvlK8UZBtr/CvEYM0kDz7L88DkFeaypT0EY4vH+ws9dwwr6Oouf03MJXtIg6fh3r+eezgbG50EuW4ZRf75iCMNt5ivRSnuGd0H9KtUPeR6Qf+7x6hKtI/S3t6FyCAHmkZU5N3vvpRL35Xh+j5Y0YSB8qWd/i/l83pXt0Okxl3r2GzwciUQikUj0IhJHNpFIJBKJRCKRSCQSiUQi0QUSE5JIJBKJRCKRSCQSiUQikegCrbKQLqOMHwSfkg9db8CvnD8998798mc/6S56/+D992IkalEv+P4CHO8RJoRwhNPZlMOTUfQ5J7p54yYn5+1vf4fv2d27wmEDDvAIAkAu0tCnyDWk0wLsAKEJ6J/hnIP7kwvhWZ3e++C9X/l4269+/jN+ZP/pEy7e45MzDmfMIyiTtq5TQsFOWBQl++OMRmOuptt37nCSXnntdVt0xf7ya68XZYejKqBOiTx/rq6V4b84l9Af1qTrTV2zk4UtSn6vB6+Mk7Mps28++MXPm0VXvB9/+kkT+RTHR8dtZDqcnZ62sXy898DIwPLHz9CTDwiykK5tbZax+q7fvj2KTej+62+ub24sw7u7e0XRPWKIEv8oxa4I2xLkC/lBzvvEfAE2kLUWyiQwF8NDFr747PPp+fkyfLT/rJ535fPs6GC+mC/DJ8fHTaz6s/NpE/kmzjk+P14DJ2V9MuF8be/sjMZd3tfX18uqq/fdnb3xaLwM7127sbax3pWDTgCYwiJVaUXMMIK+4H3iyMCDOmtjGEnm55HyAtyiIa9MF1STWDbpnuPjo+m0GzoOnz4+Pz1dhmfT6WLelefZ6elseg7h2TLctE0by9av+Fgx0gTSYExi96xvbKzHMty7duPq9RvL8O7Vq3sxPK7KKvY7DQQngrqbzxfzWNdffPLJs8dfLMOnpycnp2fds0Q6DmXY3oL3zH4yQVEsn9HaWrXepW1rZ+dKTM/mxsbu9maKE4e4FCD23SNAobmQ2EYafJc0cIhUCGl41zrE+M/Pp0dHR8vw/tMnX3z6SZf32fz05JjL1sY2jOUTsrQBn8g57iPee2bElGW1ubm1DO/sXvnW299ehquq3N1a53wlB0DvmcuGnKz5YnFy3KXt+OiY0zydTg+ePuV0GmY8KdUC04fjJyKje1y7ggqcGR9WHHMAzAPdQcOzDtonU14CEfCtgCND1MuNKopiY2t7GZ5Mxq+99UZ3vSz3dtP0ymk7Pz9/95e/5PL5NJaJUqntIRsrKNX6xGDykbljjNnY2oxpKG/ev8fhu/fvdpnVVMKyAYcU1bcs0aQopKk58aFCaFuuF6VhymBemHdu/9mzZdg598Vnn8br/tnTxxx+/PlnHOfB4RGHuf+SIg1LAh2HRK31lSu7MQ36/ksvcUbWNrq5yWh65aVX42XageUN8o9wfLbA5KvrdE9ZJvQkssM0cIgWgGX81S9/weEH773Hza9dwPIDliiLxSL1Q6iW3atXubm++c6f8pB149ZNRn3p4Lk5IYcLoldN03AaqlHCDzngLNoB5OX+wSGjqT768IGLRff0yRNekk2nU04DLkEddMI7919mKuX3/vw7o1GllCKCdaxIJBKJRL//+oqA2b+RHOz/azB5ME5brTAR0UQF1Jd6ASYn2Ma3gN/2z+nE/lsWZ8y1CSFc1zVbtRZ1w1mo6wWvWPz/z957PUlyXOmeLkKkzlJd1dVdrYCGVsSQMyTn3tm59+6azb6t2f6Pu2b7stfs7tpwuTbqzsxySJBQBNAN0ehGa1E6KzNDuNqHDD/neCIT1SDYJAfm3wPgnRUZ4eHh8mR8P6cTKFI+qq5JDGMx54WLIMQDp9LaIDYYVytL6EHLcchfu8kFwcq51Q/clzEGwh9KqcpXiUrV8FjLuoZ5nrU4vwxDePT6ZE4sDJRDVVfONQ2hVgrmf9ZomEYHEITvUJf4t+REWLIOpmEgrY3STZlopWBJXNd1rbCslE8bY0L0rw9DJAkgn+q6huWTUgqiqEYbqIfGGiiT5TGjZ6tvDaRYwhZxDhHatL5praBslaohfFnVdemjxlprA2UbIqhoTJ2g7jGElNZ56p+X0gpCosbiSuQpKwk8U2sNtAutNESQuRDCIKsIu1NnoS4Z64S/AZnWEu5LGygfWubfhVtCeVtPxWJzDvpDa+g91lDnTSLJzgac9kcURwUPwxgD7cJaoz3emHMBn2uj4brftr5xsvy2VtN6BcOcEMJCyJiEJBgnSHXODRnO4E4cCYVTpDcLAkgM2GecIodciHjDj7Gjd2zuGWP4lYa529BGdIqYf7u4rJxzEO43WkM5M8Y4+QqGtBwj5e+shrpq8bucw9reSg1Ztk9RQekh1n07BtOcSDuyRmN/AvXKGFNjfbMlma7QaY8gu44IxLrzqoI6w6FfYpzD2OesgLmB+MO+V05/FYN+kpFdWRgLYjyK/OpGpZWGVmtJOVA9zY+dy5rq0/xOaq2Frxuj4VEqpaCaqbrG5kDqGYGNM610JCBFRUVFRX3vFY1sUVFRUVFRUVFRUVFRUVFRUVGnKIaQoqKioqKioqKioqKioqKioqJOUcKWM4yofgdkEqhGN5ADKIBW+je/+uUsbZT+f/7u75pjmAPXEucBCykjsAD6JvykLCDdznNIv/jcc/483BK4w1/+p/8Cx7Ra5B32uV27vRa7VEJwQMAhUgbeiBYJHqPIiT55/wN4Af7+vQeQ/vSTT7R/kfv9D96Hl//v3r8PZqLx+ASc/YJuHE4eHjVzaQJ64Jy42sjNPHf5MrCQ/stf/3W705mlpZTtTneW3tk5Lz2DIEsEh/gjeaNbckGcGHh+kaZQpEWFprlrv/1t6bkzjx8/ghfgr12/XnnWz7Xr14uiOeZ4dKz9G+ZFMQ2ZOP5axP3hHOWGOHoM2PLyPAVexvPPXen6e//pT366cWZjln7rh3+xutGk++08AV4GBY6E7Qj+wImhSRAoixOCoZlOGf/cHz54WHq818N794B/dO/uXWD37O7tQbk9fPy4KJomsH94CJ9XVQX1xxF3CidEoDzLoLg21tc7noW0sbbe9emzm1v9XsPd6A/6Wd58vn3uXH/YsGPWt7YGwEbpdoCfRR0izmC7kEJIYPRQ55FBM5eQAkrRGDSdSSGlwO8i48ahgahWSvv2cnh0NJ74cnt4//hwv/l8f/9kNJqlDw4PgYV0eHQ09mW+v79/7I+pygo8s1JiHrRzwPqx1gBTRgo0rxlj4Fl0u922L9uLFy5cutAwXK6+8MIrr742S589v3MRuSdMYFNDTta0qkejJs+3bt789Nons/SdO3fveiaLsw49vISbY4yGdpRKmXnOy/rGxtlz52bpC5cuvgImMq1X/LOWgrOg2/Gnp6Yqjs2NcwFlxVngAyWsouBT+Mfh4dGdm1/O0p9/ev3dd9+dpcfjyd7Bvs+PpE3+6yef5Y0a4sBY5JyF8ux1O5tnNmfpSxcv9VYbpsxwMFztN32gEDhIcM65H56MtZU3JR0dj+7duztLP7x/7z2f58ODgxs3bzZ5sA7NhlImWe7PSYZgkueZCxEvjHfGSbueMxWjKQzqJOccMXzOKV8HgusG5cZgPBKMw9132p0XXnhhll5dWdk61zCz8nZndXXDf9cZb+I7ODz6+KMGfXh0dPSLX/0KjgmwfcTIVhMfOgxzWZZd2Dk/S7c73f/oj2+32xvbzedC8AzYWPPVANNBIToyXKKxkYOpWWt188aNWdpodds/R63N3bt3Zmlr9INHDf/IGPPV7duQfuDrg7PuZDyGa0H5sxClBzAgwfnKyoq/L3H54kXI29bmGf+5fPH55/3xbOfiJX8W8eJrDc+LC77luWaMsYqYznIyjaEFFMyGCF7QEi7Sjc8/h/R/+7/+byjsE98vMcacNfAMCj82sQZf2Gjn3DaMSf/h/gO4/b/5X/5XmAFubKxBNjQxu0ky9APDcV7kYVOfI60bx0fH4A389JNPoIv45TvvwGxzf/8AmiHlKhhSPn/9V3/VaTdTiNdefznJW4yxNDrboqKioqK+X/pDs5AMQlUQiKC1poCAiswpbUZAD8RUTyECFfkuHalrEmaiXKTvwvJ4Gi015JO0VgrCHzUJqdSqBr5AWVVgwi/LEpmOkyksz2SAIsZ5jJQIzKytQdQ04bMS0jcr6yoleUgU8IAM5McFd7B4TvRNcBOKofX5V0pB2Kiuag18jbquVfNYy6qCR1wUJczziqKAvEkp4fxSImLZkfCNsYgAlxLx1c5qCHuVVZX45bSqK+StWGQJPYv6Q6m4hpR5XddAl69IOdRVBU2gripoPmVZYgippCEkLAj6jKyxEOaoyhKqU1VXECar67pWeC2sV4RLRTlNc/yp03k3TyHn7KlB7DnmETwvbawhXC1kRVVVULb+Hsu6xvKsKijPsiihzBMpAXWsmcUQErlWmiZ4DGFXCYlh1qqqgMqvaixPysFder+kHRmNzJ1aKeCnOOfIc8FwqjYan51MbOLrm8I2qJWGsLU1p5f/dxLBNlNZZ0lbQJZQVWP950JI0bRZB/+ZnRPCKBbDMcYYqM/OORhW0kRim1IK7j3gQDm3jP3myDHwXa117X8Roc/FGAP9HpcyJVmGaLh1DlkzJIREQ8BzWeFLQkgUpY/P1FkIIzIeYqfJvWgSfhLYx0oYvpXSFkOowdiHfCJrdcC2w/JXdPgGNpNzQQiJI5sP2m9S41ipSXjaud/Pu9WO7IXhGHKXtNJQT4zW0IcYg0hHY3BKY4wu/c8hzrqShFGWhpB8HRCCw3mEEBVJU64W9CGCc9ou4HFwFzzc79KW6XcNeUZ0FxSapruU0KmaIWGgqqqh6tZ1BUOSJc3WPgVh6LuMNdZZiLZrrXFaQvGCdUWKlPzKyIMQpE49+upZzzWjoqKioqL+SIpGtqioqKioqKioqKioqKioqKioUxRDSFFRUVFRUVFRUVFRUVFRUVFRp+ibjGzL+EdP87awI1CD0pv/jdafvPNvs7TW+v3fNJAIY+2De/fhc+kTuQAAIABJREFUu/RleEne7lY1GtMIkoIZkh2aZ4VmNw4QAcbZD37yUzimlW/gtTh9CZ/eO5aSIQYTCuAgvn4mJDmevO987UPkH/0f//v/BsaWr27cBDPFwdEx3MLJeIzGE/LGeKfVgvT8k0DWCTJlMpLPhIAPlFaQt4cPHsJjfeeddwDzdPHceWDcnN86k7bbzXUJS4jGIVWNprwky8D0USs03fzbP//T1LNpfvazn40nTfV4+GQXbnN0MoYX3V2t4b5UWcL522nG/d3QOqm1IWYWpEUlQb3Ffa6VNvDwbn51Bxg9rXZ7ZWUwS2+e25H+sXY728IzMjhlLVkLaepKoAZMJgQAgsqqhs2wb3x6beybyX//x3/c29ubpb/48sbIM3qU0sTwiEZIp5C/Uyss/1RIePRKaTT9CYmPzlowfB3u7R97A8Wj+1gfkiSBqt5utRLPGdna3Oz3G0bSa6++uuOb2HMvvnTGc0mGg34LuEhCcLLROGjOe4NNmDRByYXgwG3Bjdu1Mcg/0haMIY8fPDg5PpylP/j1r+/eabgkt+/cfrLblG1RFmCosRbRHEop43koSivY3VlwnnswhzVGa2/GIflJuMiAa0PuK5UyAX6T0tNxw1q6ffv2k8cNP6WaFm1fzqngZ30Z5lmSZd6oRXhPzjkoI6UU8LCOj48fP3nSlA/ZQJ3Tvd0tGsRkIhMBbC/R8dyrlZNx6Y1XSmntrysE5oET6JfgiEdjxARk0UvHhEAuEiNth3POfZtS1imft9Fo9PjRo1n61u3bH1+/3pRVrYARJrkA8yk17nGSOWrktIQPxUnXUReV86abbt468W0w50yS88AQwLmAZu4cmlaKotz3nKYHDx/dutOwco6Oj+7cf4DlQ32XwEoTXOK94DPijIP5kTMOfVTw5aCroUglwqUKsXGB72zJsA4nElK0fP8vGEL1OGPYrol5kHMObBoh0Pg2LcpdX7bW2olvC5ywtJxzYMzknHNfP1utVrvbgGZ63Wri+0zrnPJtNknkUqSj8VMILoTAYZoeLmWT57quP792bZYuppN/9LjGsix//f77cN2xz79z9uh4BPkHcxlzjBFPfUK85NzbzR1zaEBjXHqkI7ducnQMh398eAQ57na7/nj2i1/+Er57dmvL34j4H//Tf4b0X/1Pf+O/yi95dhJjzNCpyxJYlA3YQ5j/wrdBxthD304ZY4cHh3hO0hFqMn2iw+LhIdwjmxYF+Ba3z1/MfBX6j3/zPwPGK6VTLzJOEPs+cxavJYnRzC1qd2zm2fdd/cnJGMxrDx4+gmFi98muIcMrdn2kPY4ODnTVPBqndNMvxN9qo6KioqK+X3r2LCSHsQNrLYR1lEYoiTGGmuoD6gZJUoQ2DS1ZsXiuQ47nlIvknrFDnc5f6a1opQAFNS0KmE4V0wKm8mVRwO1rpTASR86/EFrRXGzRnzj8Z4ZNXYQUMFpjuKfG0JJWyvpH40iIhLnFZIJlYUc3W8QxxhirqrqqGh5EURZTv/SdFlNYBhQllkliMc/O4Xno8i/ggxCsCme0TPjC7DkCvdBaGdtM92qlgGNijDaLWD9z4J8gfVqk1RHMitYamkZRFIXHaU+m04lHaBuN4RKtNSyDhcXlqLOO3KPji6eu5HPyHI021kdRKfdKKcUh/GEtLAunRQFz+rJCBpPSS9kop2p5y1xSzkG0OmADQTiyKsvKl+d0Wkx9uihKxK6RYtMaw22UNzT3QB1JYA2bj45Rmgr5ri8WrXQlgL9DWEgaw4JP01tRlLWxyNIy2gDvhubNWksYJQ6w55owray1jvB0QN+t+1zSccwd5C9hrYVQstYKwgpaKSgrxyWGxmgIiTGst+QBO4qmJn2IJWG1gO1lg4Npn4zlSfJM8xCcUxvIc1BPCCJdCAH3QllInHNhoQ8nYRpHmirBZjOOS3fLHN1NQpL8uyXNE0Nvc+g0ytU6XY4tWrrPoc3p0E9DSBrDZ0xg/cR+2BBAF72Rp8vaU1ViQGvXtQYUdFmWMGZZ5wo/lllrIYzLGCPhPyfor2I0hMRIMhjrSV0l361ImaQJ8r+s78a4ENC/SSFLnzcphCYhuae596cRHSaMQdSgXoRCZyH/KNiBRFMuUgU5VKqm/d+37Hi+3eHhqI5N2ITdAlRL8hiZdNi9O2vJI3O/t7KOioqKior6U1L8cSQqKioqKioqKioqKioqKioq6hTFEFJUVFRUVFRUVFRUVFRUVFRU1ClK2PIXm78V82jZdx3jk1FjdC+L8oP33pultTGff3EDTlMjt4jVFZjOXEbYPQlhDKELgzMLKJvQo7X7ZBdyc/fuXXJ+sotwwFHCNA2tGeJ6kOQLRmv4RkIBE+S7199/F4ro73/+c+1f5P7FO+/gJseTAhlGDq39FSmTjc0zUKRXLl0CNs36+hpwKLI0RX4NMfqZqoLzT+sKbvPx3h68rf35lzfA93d4eChwV10Dd5xkWZI2j8M5A8XuKFsnzSAPRaXgRfcP3/lVVTYv+f/93/3dxPOPPrn+6XTafF5VuGMufRgFcc6cO3c29TyaC+fPtzwzot/r4k7AhAOVpimYWZTWYJQ4OhnBy/MPd5/Unvny8PGj0vMdDg8PgVc1GY9V5U0Kc5t8g4hrg5P6oBmHTd8f3b1bemParS8+P/Gco1//5jeHRw3n4rMvvhiNms+n0ykadohJjRqsEnKPg0E/9UazzTNnup2GGyIIuOFkjKCH3d29ybS530qpcBNxf37BoWHVdQ3Xmkyn0nOR9g4PB56L9PJnn53f3p6lr7708tlzTfrs2e3+sGFLJQG1AgtRCEGLDj1kQgIPxTkGZpbdh4+Pjhruxr07dw72D2bpL7+8sbvbNP9bN2/uejbQZDIFc4ex1i4yixljweiUpqnE6zpa5rmvb612C/hHnU677VFltC8qihIML+PJFMq8LAtITyZT2AxbERMrc45YdRlwuJJEgpEwkRLqv+QCN0G3VnszprOWcJ3whC5JwMlpEAnFLONQpbmUiW93UuDXHbOk+xXhYOAZOpw+UkYNO+TJczAljY5Hjx89nKXv3Lp56+bNWXr3ye4xsGbIvVhugV1F2UyMMQaGRHrdAIaCjhXB+RRMmpPJsef1tLKk8EOGFCLNEMAGZzJaT8ZNmx2fjI4Pmzo5OjoajZo8T6YTpZB3A9kUnBM+jrPe4GyshX6Jcw59MmeOgI7Is3C4yTrnHIYAx5ilTCi4XyESYoYK2yN5Rv7jxCW5beq5tRauZY0ByJZgXJDny/1gKAUHJlqeppmvS5px4E9Z51SJQzM1kEKlTKXkxKgIw64UpC0ITtk3tLumbmdnsW6Uvg5XZfHbd341S08nk3/4p39qPq/r9z78cJY21u7v7UOeK8yzw/IXApGFnGe9Bo4jhNg8c6ZJc7Hl0845wnWydz0a0jl3cIhcIUvqeVkfwedJlsIdln6c5VyUf/uzpnykhCkTF6L2pjzO+YuvvgrFk3IHnycJTiFoeRokBzJOhmbJ0Z1pNeUJaNreIEn7R2q//ur2Hfj85z//OaC7VjbOpH768faf/zngh6hVTNAeaMncjpq7EzIKJUJyf8eCc8AFWK3hsaqq1oBESBKsTnkKlxNCQLUUQgRVMSoqKioq6vuiZ89CIuEea3Tt59Baa5hPOxdM6ynPKGCpBJklAAiS/hpWmTHGGEeoAVsOgPi2ehqrfV3XcLmiLAHFWpQlZMkphcsbMu0xIYMD5lJZKwfkaqfThc/zPIcpTZqkyLiZTpEuXUhYHud5jiEDxuF2tDVQ0o6sLSh7yJnFd8+DUBryWWrCyimKYlo06aqqADuqtQ44JjCHI0t3KSWELVrtVtuHkLrdLiwhjEGcdprliMsly/JKI0slS1KMSBL+iLEGPncEO/00LC3ncJlnSVXRCvHGlHk0JcyjoiwLvwygGGxGwouWhJBEkiDaVggIJWRZlvvykTIBAj3lggkp4AE7wmShqGZjhYDaYXDdXCslSN2GOllMpxN/X3Vdwv1q0q6DsiLpAK29pJgdomCY0hrm9FVZFhCOIeVZlmXh61tdE94Q5TyTbFiyzHYJWYrQdQhpj1JK6ZdbaZLmJOoNt6O0lro5RgTsNgRtWMJyogrgSkjEnoUhOPnLgm/QsJe1FrtWTnJBulBH+CY8PFWYowX5dEv4X7QtPI0MeaZKaeCj6YBPFDDRwpUpuf2A5QQHzQWRsF07yjDyZWVJSNEte2/X0fMYKGdjMO2sI10HKatgrRugX4KMknAnApM4WcU7B/2VENxxXGPTO0e0NslzcCvLmt4cg4ycNbgBL845qasM6hLFnHN6HtLuGsoTHINhKZKHMJPwYPi3X7QjB81YYB5Ny3IK4fWqBs6RsRa7UOfIrh14IkFQ8TMWepMkYTshRNvjySmm3RgL4cIQrEPrs6PTA+EkHKFqCDMxYDZJISAthFB+zOWcB3VS4liwuKS+vSz9xYUMnZx0g/RzirycFgXQ9xX5Jcw6K37fb9Bzjt0pJ+Q6ElCda+ZuUU8TYM4449+q64uKioqKivr3ovgLSVRUVFRUVFRUVFRUVFRUVFTUKYohpKioqKioqKioqKioqKioqKioU/S7GNkWvl3PGBOEv0MPfvzk8SxdFsUNb3S3zp6Mm7fEGWewUzhjjO5AfPbsWThmbWXFn5M9evwYrnDoASiMMeHP45izZEfkKdltd+pBPLPjQOEO6HQXXmoMwSNoninLqSpr+PJH7/4GdoH95//vX8FEIxiHTXm1UsAioW93D1fa8I+33ngdXoD/8V/+B+BxnNvZEZ6jkeQZNQgga8M6cBSMRsdgBrl966b2L88Phn24hV63SwAEG+3+cJZWjnOf/zxNcUNr8qa6JQaT3UeP4aX0f/2Xfxl7Vshvr12boskI2UxZkoLlwmjkGQ3WV6FqvfXWW8NBw9N57fXXe92GMbG6vpEGXA805hC2VAVVazw6hnu/+fkNqB5f3vwS0pd2zrfaDc9i48yZbq83S0tKUKCUF2r+MpieVErppog+fP/dfc/o+cUv/m3fcy4ePHpUTMH8VYO5KREi9dCHqqrBXLO+tgaGqTObm61OY4jY2d7udpt87ly8OPBllSQpPNPDg4Oq9Dymr7469tylvYMDMBs+2n0y9mwOpg1s5E73Q9dKM+8VvX//AdS9e/fvwbP4H/7yL1/3rI0/+/GPe31owhaaFeecmD7m9hD3ZhYhoeVNpwXk84vr1+7fbbqU37z73p17DfJsb/9g5DlTdVkZYo4AU4lImIDd7MlV87yVerZIv9/rtBueVJalwJnqdjrAPFpbXRv6rqnTbrdazbNgDs2Po/HJxHd3u/t7B557VVYlGGd2Llxc3WjYKL3V1cxzrJIEM0dLJ5ECeCV5nnf8dVt53sqbumG1Bp6OcA49PmTTdyE4uEVSKTMPHEmzNPOm0TRNwfnGQysnmpV4AD3igbsMzYDEFIZGJ2vRGrv3+NFnn3w8S3/x+efXrl9vPt/fpxvVQ51M8qzj+4FOu73qn0Wt6sJz1qZFcbC/7+9XoCHXMYeGU6d93zguy5u3b8/Sk7ravHlulu71BzuXLvlywNsSUrZ83eh1e8C40XW9v/f8LF2W1daZjea61mnPWROck43ekQmljYF6rrUGY6ZS6sjXH845cK+YAzsTE8TQyoTgvj5LKTvePJVl6frKKpwnAbiMY5A3+kyTJBkOm7Gg0+k8/8LVWXplZXU4bMo8S1OoS5SjJIUEbl0ryyCtCSzGcUcHYKxLnMMzklxAG8ySJPf3lWdo1BWhc8gAA4hz4c22zjkwS9Z1/cn1z2bp48PD//pf/89Zuiyr37z/ARxfAUKRuhk573U78A8oQynl1uYZKLcXXn7Jf55cuXylyaeU2+fOwfknJ2OfYX3js0992lz/7DM4Zs/XYefY8fEx5KIkDCmOnjb26NFjXyb8v/3t3zZpIaAv4hLriRD8jbf/DM5D3YmUeURskYyadru+XrEQW6lcDd27pP0D6cqEZMSXip9/dO0a/OPnP/tbmAINV1cTf+krV69CEyBMMeYsve6SiS7po7Ist0lTVdrtNhRLK8uhn6LVO6V+SSGhuLhMmEd9MSGDGUJUVFRUVNT3Rc+cheSYA+iPUhr4xNZaxFQ7RtmNBEzIkxRzCMxa5xzAFNkS3z5nPOQrUUP+74eFREWvZSzQk1lZlYBkmk6nmmAmF3rk6WeC41Kn1Wplfuo8HA4zPwUfrqzCtDjJU1wikrBO4sgSVEq4/YODfQhp9Tqdys972u0WLrNlInBJEJAoyLKQWbx9CzehtYKlSFEUwJIoS+QiOYt8H84p7hTXH1JK4atHp9OBUM5gOOz1GoTzcHUVInqCcEaMMTBNrOoa1r5SCmBkDgZ9CHl0Ox0o87yVt/ImTJBICeWwnG5AS8cFy2NgBhUllMN4MjnxYZpiOgVejyPPjomQEU+YUJDnPM9hWdjt9gYeWb0yHA78ki9JUwg1Wmuqopl/93p9yNukmFLmFCXiB7e2CEusakSnG2Okb57T6bT096uVJkyTZXKEzUQ/xc+NsbAsVHUFmPZpMR1PCAvJp2cPYJbkJHwwD/qBbkciryRJ0gyWqXkObKlOuw1l3uv3Vlaacm63MbRkLYZLuEB20qSYAlrbcWxUaZpK4KRIScIxYcAGETocGSucQ/RZiPBzehZsXovrMMVRC3LOP4DgJo0xsONBVVWwdIfOak6US5WkCTwjxlntUeJCImjXsaVsJqhylvBudK0gvL40DyTkIQSHJXSaZlAfGGNQZ6yxSvmlO+cSl9zIKtLaWKw/IvF5MMvGL8oYImzjoG5IxE6nadoC9DvnaQL9g9Mah2MI36dJCvlvt1q5/26WZyQMgV+kvQbnjOZN0KAotPf5XoF/PcU5Roj4/P0u+CLV3DwBxgJrTOXHo6osoA+pqmoc/NqEp5U4/cAQHucYIpFCwHidJAn+/CCT4WoTbhNCDoYQUnepL0NjTN9vTWCMgTHIOQv1yjEHdX4OXhV0y74Oc8bhFzshBCD8heBQt38Xag/5Cg/S5JglCO2vnWnB30o/JjLGptMJ3H5V4S9PIQp+yXWfQlwIiHoLsiOBINVMcA5kejbXtdK+NfKPoqKioqK+74q/kERFRUVFRUVFRUVFRUVFRUVFnaIYQoqKioqKioqKioqKioqKioqKOkUJW76B69O8jruQf8QYQ/eKVmDaL8uyqtHIpmoElFTezM+FGA4aV4iU4oc/+EHzOePnd87P0s66X/76V803HTt4sgsZVsGG5dJ/l4FzhDF2/949SF96/iqk+1008ztNzAJP8VayTBEKUB2dgBnh8eMnwEKajCfgg9Aa0B9MEGNCkuSQ3t7ahBf+337t9cwbB37w9g/BrDFYXUETRyLhiWmliI1AwAXO2fN4/osXwN936fJlMJ05siHx8y+9DKa5vNUCZod26JVLOIN8Gof+QVVXsOHxeDIZjf2m9UU59YwSaoHLkgSq3LA/BLPAK6++0vY8mh/98Eeraw2/46VXX+95g0C73SIsDELTIRuBUxNTMZ2Cke3ihUvgr3zl1qulN0Z1e73U+ygvXrkCpgNwkM3OD2kuBDFDoY3jwd07wBX65JNPnng02N3794+OmqZRVxWYHKXEO6irGsqz0+mACeWtN9/c3tycpd/8wVtnthpk2Oraau6ND8PVlTz3xhmHG5NXFbKWfvCjH0IzfHj/PuTzX//lnx963NiD+w+Oj0dNflRtcGN1fKmfbrLuhIWn+ujRY4RHZPnxYYMtu3T1xa3zO7N0Lnnqn511xHMqBPNuAku4OU8ePzrY35ulr127duurW7P0rdu3Hzx4MEsbbeALjnMGJhFr4ZEJIcDgMxwMu72Gp3NxZ2d7a2uWvrBz4fyFJp/d/gCYO1mWwbNotdHUI9MsTZquQBBHQ1lWle+CRsfH0CXWVQGmreHKKtTtjc0t2LidOwcmGssclI91DDZuT7MMNghPsxzqrRAC/EGCcw7dNdnPnTvkmwjOswSMSxKeneAOvbEUkkJMZI5sQu/IBu1CiMB1jKg7dLwopSa+T3h4//5nnzb8o69u37l9p2Fd6VpBv8QJ363b6Zzdbp7X9tmzb7/ZDBnHo+Nd39bu3Lt/6PlBzlqlYeNzdEZZ52rTtIXD46Pfeh7T/uHBxlbDMNrcOnv24mUokxQYPYIPfP3Js/PAILty9eoLL77Y5N8YNA0xzogjBjdrtxbMd0VR7O4+afKzt3/d83EODw+PRyMoT/TWuWCkAmBblmUrG+uz9GDQf/PV12fpXr//xptvNvciZLuNhjvK1EMzHRfACEuzbLi+Aecfrq76MuGkR2fG92nWWoDXpFmWe086J/g/4Tj1VzroWql7jTF0GAmeePO1TBLC+eJ0QsOJARks3bVSX926OUuPRif/+P/+fJaeTKc3bjafG4Mma+acISZ0ZvGciS+3NE1f8cyjLM1++tOf+s+TH/zozyHPG1vbkLGO550x52CsdM6+9FJTZ6yxb//gbV+G5tNrTbtQSv39P/+zP97d9YjJ2YkhlZNpycT37ZyLX737rs+PeOWllyH96ltvw/GdNk5FBMUdksLNCAuJph2pBJSPRn2OVI74QyUZXmuFiMmPP/0MhvjL//0fU//ou71e5tFv53fOw9gpZYpTIE57ILwuratcYCVLshSePfX2aq0BocWlhOqatDL0zlurPbJQaz3rauicISoqKioq6nugZzKwOcpMtQ5iKNoYusYI5pqw3iCcIyFl16/ZOOcwL7fWIfDCBWALyjniEud5lkx8FJmXGDohCu8B00EI6fRwm3W4PtNaA7bZGANLd0NDD+ScFNGaJgks4bq9LmB6e/0+LFnbrRwuTacpmuTZkPkTRYY7LuExFeMtawBZhWG4TrcLUzoaIpnjVsxRAZqktVAOxlhAQVtr4XHzueJEFo8APkin3e56ZGm/3+v3m2rQ7Q+gerQyZA7Tx2VJlROE7yM4obaLFKpoMZlACKnVyiEKmectCBlwHr67txDFxRkg0rWqAWlcliWgT+taQVU01oSRXL+stc5aDHkAc6Tb6Qw8Nnhzc2v7fBMZ7A+HMJXvdLvAhzJGQ9NotQ3ce7fXx6ro7HjULDMG/f7IL1OTJCGza0I4wUjjrMnDMtgBF1dpDfdbFtOp54woVVOCNi06LAeHy0sS1WRKKQi7lGWF5VnVVYVcD7IcJf0DOb9jGJqhbKlOuz30PKn1zTNntxvkbX9lpQt4cpnAs0jSBMpZSgntRXIJ5VZVNYQt0rzV9vW2KktVN/lvtVrApsmylCDG2UKFXDKBLJ4ljBjHQkgJpYkEUR0MH4RXxpjc00TVaX1g8pQvOIu7H6i6Bv5RRdKWLulJDoRAxHK71V5ZW4M/Tf2yuZXnGO4MygCHD0f4OFobwJyXZQl5UKoOceC4UoaQd5ZmlH1jSRuBIY9zAeEPx3Epa4yu/XWn0wm2O+c6PlQxmWQkz9ju5p8KPEeCFMyybMWzeIbD4bYP4wopAcPPGZM+jOicg3GBEaaSlEkHf+mRcHwQAyJ9Ah2mBcfV+jyri36X/Cu4sYCFBJ8trWALfwlzzkGorq7KiWceTafTqiTMqcV0O5xmcCHg0pwLYEXlWXbGI9XTNNn0u4IILlZ9OI8xlpIdOSBE5RzyBK0x2ufTGLP3uAkp1nUNYWJng/KhQzO9d+XPz5kFNLsUEuq5ENwsCRUte1l9GSvNwX/mjl/Y/YQHB8M3mc5VZQmXG08mUHS6riisP+QwfRsm0Rw+bNF5nHMwdFoMSDK3BP9kw3ocFRUVFRX1vVE0skVFRUVFRUVFRUVFRUVFRUVFnaIYQoqKioqKioqKioqKioqKioqKOkUJ+902c10kcCJYa0eHh7N0XVV3vvyiSdc1QECcdRzf6udDv/s4F+L5S5dmaSnlm2++BcdcvHJlljbGfPDBu/48Nnjzmbw3LMEFw9gRwCMYu/XlDUi/+Nob4JPvdy/hdxN8wzwQfZudfKyJMa0qCzBEHI1GwKrgBNOTUDwIOY9IAK/Bev0+mGWGq+st/5J8f9ADs1Ii0SJCgQVpksCJU04MR9ZAekBgB+0rl6kpAz7PsgwIG5Izx5BvAocJZvEmLDJoivEJmIwmkzFwdhxjuAk0eRVeKQWvfWd5Dve4sbE5XG2qx+b2eWBwdDptMA1prZHnQswFgvAvnHVkA/UMrpumGeS/130NXp53Do/vtDsJ+iKxGnDOiWEEn+nDBw8AB/bRe+8dHOzP0p9++unuboPuOhkdq6oxKSSJTFOEKVi/Cf1wOACT1MWd82A2ef2tH1x+/oVZ+sorL21uNqYJiZsRs4Swn4zkwLLJeYablzsOzzfvdMDDWFQFcGR+9YtfPn7SGCju3r8PXCSlFPCb6KbdUgjwoj549Gj/oOEfJWly4utAuzfoDhrDER90gbvBuZBJ811tkfPy5MnjE9+EP/jNO/fuNuyPj699fPd+wz86PDrSqjk+kZI+DlCapsLXq16/D/yX5y5f2jnXGNauXn3h8nPPzdLbO+e3z1+YpbMsScCwQ/pMEWxYLoJW5PuBTtaFz4e9Tg2mFWvBSJhIAcbVLE0TXw6cOHkc4R852t0JIbzxUyYJuDy4FMQ7bK2/riA3wAUai4TgyD+SAj6XhGckOBOBwRCMgYxijsD4SQ2PnHMwh1KnjNYKTGej0TFwi07GJ4Xf2JsT3yt3LPHnaeXZqh8+tjY3X3qtYf0c7u32Ok2fOZ1Oe547o7WuuDfHOWRLMeeAjzaZjMF4KKW45xlbPElrj8nLJE9yP0w4wl3hHEAt6SAFxhZzTlssK9rdQnkaa6FNTadT2Bg+lfLu7a9m6aqqoC+ylgGQjPrGOHMCQC1Sdlqendft7JxrWDyra2tXPadJCJ5TXAuxlzkyrJCRgXPPtRGCg2lXCBzjnGMazGtJAky9JG+lvg0aY9EZ5By0Bc4tWQeJAAAgAElEQVQ5HOMYMwzMg8SpxLnweRZJgvmRgtZDarYtvSFxOpnc8+W5t7///ocf+vyYyhu7HPpxGWc89cAdRx6eEAKeb7vV+vMf/miWTvP89R83LCQp5NmzW1BwgrCZmMX+M8mg/B1fX4U8tHp9yJvxbbyu64+/+Lz5XJu7X92G84OZl3Ge5vhMYWDgnI9GJ5CZjzzzi3Pxlzc+h/t9/pVX4btpigwjTqdYSUbSCXXGYprMzyhPwJJ6Rc+JxkkyT2CMHR0fw5l+8957cDtXLl0CrMHa2lrmcV19aHdhV0MrccBC4gJ+UZXgEmQsSRIJXYEQ1jc9GAsYY85o5/FYCeepz3aWyDRZjH+KioqKior6d63fJwuJ2r5hLq60Kv2crFY1rAnnPOIwV+BCwLpOCtnvN/Mnznm3j3MpnEPPxb+WWM81mZfAPJIxpgnHkc4zJDX5L4LUzClgNFqcdmut6SXIaQJmRPAx8iClJMvCgLeCIRhyTjrV5zSraNq3Dmd0sM5njMkWYamStTedYzny3SDsGGAr8B/W4JJVEw4UlSAAAueQRSKEgKVImqWAX03zPPO4aMEFgRHg+kk4Bqxd51jAOgkYmRDOw/z0einkXykFzzGRYmFIYpnqqoKlyHQynngG0LQopkiaJ6hvhihxiqaWEuegeasFTKjeYNj3eO9ur0fKBNeynMzehUA2E2U5CSYhhNTpdIGFsba+ASGnfq9/ctIsOdIkwWDCfOgZzo9okrqqoCsoyL1XVQXtwpL7paGoGUqiOU9ZQUhuPBlDKGoyLQosT42cGrc4RMs5h+eYJjL3y9Rup7PiwxCra6tr6014a2VltddvwnaJpOiPb0Bc+OdoHKxJKEeMcZ5ALXPYxAQBugjBIQTwNWDYkvuCwwVhIS3trwhCLsQwc5KgzJ3wyvislxUEBdVAu3ZBBCBY3kNbMKTPNMYiC4wFuGUSJhbQRtIs7fgld1UUbR82yrIUQmOWhFbD7GM9NMYCo0opBRhsrRXi9ghbbSlPSnAI51nnBIancTnNBQ431jIpPS/PmtwPhVmeA6srkZIULWoexkKOgfW2FLLl19utPGv7EJvgPCXDQfhLydyj/1qKMWPJp0t+kIJ+QwjBSTiDMLYIgzkYYsIAAO12TuPezGUdGHzamNLj7auynHo2kCX8PmdJXJDUPVrnOUcGlkzkYKXpQ9I8H6w2fYjgIiPMI8r3IffOyPDCKVK6zRP4Yhe2dKjKTqcJkWilBIaV8WcP7oKyomkYi62zkwJYSAIYc5xzt6xl0+Kn84+n+CmSnnMZbTL4nPyB4swnkwl048VkAkOM0dr4qZGzbhmqieQnFHahgnZfiCTjYZHCF0hUkVKU+FNR46KioqKiov79KRrZoqKioqKioqKioqKioqKioqJOUQwhRUVFRUVFRUVFRUVFRUVFRUWdooSFRirrFry1znlgVufU3U5ev4bN47VWH378ySxd1dUHnzRpY4xVaGQzPi2kzLxDR0r5+htvQPqVV15pLspY4t06Wmsm/ZvhwjnyBn7CCcMIGBeMTccTyP6HH3wIh/zwR38B7x2/8MILhPFBdre1WBTUnE83rU9IHijThwnBBG6QjIYdsku5kGhyMdbCq8+TspD+u0fjUakbTs2kUsrH/tpZim9NMwP5TJggcA7ixhfk1qhBJogl4r0Lgd812qDphhr8A2cBnkhrA/5BQ4xszlqH/At8Oz1NJGfNeVVVO++OODo81P7l//0nj7Xn9awN+8AjSIVc6HugBjfGaU7JC//k5qn5K5UCnEhcCNw62ZHnTnwYlrCWvvryq4PDhgH0q3/75ZPdhiV0fHRMeR/Ai7EW0RDUZDcYDjrejPPmG69fvNBweV57+QXYKLrfaSf0DsBwQQpCckHMYqQ1kxKRXEA9ePX118HIc3x0tHan2Yj64e6u3t+Hr4AXMnAiGAfmo8oYuMTDx0+Uv/edK8+vn2s2FG+3sk7P+yg5GkolF9zf2JOHD+/evTtL//pX73xxo8GZnZyMwchmtIbylKFZCeptq523vGfzyuWLwD967dXXXn7lpVl68+z25nbDi8laLegTrEOva+Bpm/cq+OtK4sog5ZxIYemzsO5rhzBO/u0cGkAE7qvOUsEzMNEIjl5gUn+oqZAREx9jDKBonDlBeEYOjhGEJ8UldAp0NKBGJM7QWco5C82JeH7j79dYpnx6b/fgzs1bs/Tu473xSdNdV2WFvZRArlmapa2WZ8OtDje3m+e4fmar7Y1s1mijGwPa9uPH533bORmPnzxpeGRaKV179o211npuHefAQiqL4sCj/YbD1coboLjLbEYNStiuBRLqOB1SBQEmEa4WwwMkOmUEF6pu8lDXdeU3d9faBF0crT/ouOHQoRjGnB8CHBe1H3YrZWrPqkukTAkajwwNdORHQxxjQTebSGhr9A+kZyVMOi6Q+SU4t2hydBLBMVyToYHwg5A15jgn3nMn/f0Kx4AxxDiHfrtW+v69hmk1ORl9dbPhBx0dH08nhc+DVd60yKipijOA/HHOwTicpellj2jstFsvvtpMV2SSrvU7cLxd5GfinHFJpitkWpUyHAyADeeYuLDT1HOt6tdfblh4dV2//8FZn2H38OEjOA+w4djcCA/V0LI93xa4EB+/9z7kefPic/7WeW9zBb5KGUbAX5sVBRRXIqBHYZrg0jhhKvV6baj6VVlBWVtiWHPE/G6sgvTjJ7vw3fc/+gj8/tvnd8Cb/MOf/Bj8gAmZr1gyveEM/bwi4dxCWgrrkW3Wgf+RC0lnPlA7EiHg6dXOVYifY1FRUVFRUd9LPRULyYWwjKUDIxjyHRt7uEBVVZCmMZeAw+ocMFaFlIPhoEkLMRj04fTG4JoHrsVDVCIPggRwfGCkP8FwEoN1cnPaRVO9ZVCAgGFEPrcOWUicuuEpVnaJ498xB1NJQ+CTSuvEh2O0tZIwNcj56TmDUgnzvJAx8S0nOxRqsuwQcsM0fEYvR6sWQn0Zsw4ZKEoji6Sua5jiU6gEDxEFJJskbCcWRpkCBWwNAmtZgnsK5MjNTMtiMmmq/ejkZORR0Fppcm2S64CFi3VGSgkslcFgsHGmwWb3+j1AUKeJXPIkgo9DLsaio8mH/X6PsYYBNBiuDIYNBV8mMkSQ+oTDy5GIBw3gsUopQCNXZQXobm0Mftd97REwxhhTdQ2hopPx+OjoGD43BK9GABbhvfuEEAJCLe12Gyj+6+ur6xsNpn11bbXb9ShWIeFUlAXrgissbwhL2oigXz4N2DF/SpLA+wpCh9wFR9HsQDjsG1Y3tAxPa+PzY8PiY2g0k6DcESukVF2WzfOtVa0JbjzMPyQEhBuSNM1zZAbB85VpmvkwU9bKYTuCStWcIo1pG+eAbebOryetsVpD+EZBaJv+zECHNs4CnFx453hM8NhJx0T7BGhrFPsd9uFLFQKE8EOoxc7iOeeRgktOMxcrXvjpku/OZYfUz3D8hiQNsz5NC1nc9EkFtdbBOFLVdQGIxqoKft5Y1DJceLMYOk9Ep9PUvU673fXhSyGT7DSOsnNL2z4dsAnInrV9n6+k6HtGW11VqedbOeeCuucwhBRwxKCsGKt9Pyw4B2Yf51xryi5c3FvMgYHIaTGyvGyaRHlPXJDfbjgJIdEul3y5qmq41sl4Ar8cTCdjrZoQkjVWLnoCQX4E3hqnWSBReBf8ELCM0IXFa8lPcDGCFBUVFRX1fVU0skVFRUVFRUVFRUVFRUVFRUVFnaIYQoqKioqKioqKioqKioqKioqKOkUJ+9rbyJC2pnnDmQvh0CUR8I9AjrGxd+7UZXH/7p1Zuqrqu3fu+INcWaJxLPdQEiFElsGO9cnWufM+LQd+d23G2GTafFcolbWaN7etc3mewTF1hSAD3FGbsarC6z56/BjS+3t7X78XxsKNz8ntWuuYI1QQL0neSE+TBMzzeZYD98E4Cy/Mp+Qda9jBmjEmycX29vbB8HLttx9BEZ3ZOAMshisvvgQvhA8HfXA0UWOC0YYwmxLINXUAcgII0JowlVJJDEr0ePp6N35O37pvtVrwlUG/D0dJuhk2cQjUNcIOiqIADNOXX97M/CNeGwyHKw2XgVvb7TfGgXM7F1IPQei0MjCzOIZ7oztiDKH5NKQgEhG+me/Tljn6xjukLaOuAdwe/fjo+GC/qVqj0fHxcWNkq+rahP47KIeFOwoPB4O1taYJbJ3d3txumsbqxmbf+z2pI+BZqN3pdPvNtdrtVtdvBF4UpVYE4ESMbFDftDHAztBKVappnpPJyZEvn+nGWq0bQ1kuEyjDSinlWR7j8cn4pCnDoixhQ26jjTXIPZn3hM4S1kKZ97rd9fWG63T58pU33357ln7u6vPnLl6epVt5JrD+cGqoocWyCHP0B1WwwTQnkKQ5FhLWf77EWkFugFM3ynfLHi0XApUBE1Bxcvxkt6kDt7+88dknH8/Sd+/eBfbQeDI13jiWcC5EU9UHg/7OTsPSunB+56WXXp6lt7e3h75d5ImQvlu7eOHCi88/P0vff/DgYL85f80Y8IA4uWdrnUYjra78McV0erjfsGN63d6KR/gxxhLkRnEyfAQsNunz/w0WF+qCIXavp3oa/Bv+9btq2aWfwl6GRkg3ZzX2dZUTuBc4B7/hWoIj80tKCXWJ8gQ5F9SFpHVTolVdPXl4f5YeHR99dfurWbooS2qGdXbBs+GcJ/66SZKc227YQ1mWv/D81Vm61WoNV9d8fiSYBKmZnTMmqL3qNCbAnAD6wxJ3ZnNrllRKvfBcwy0y1h7sH8C5jwpft5e4AZ1zo9FJk2fBgTEnBN99cNfnmT93fh3zIHC4ocMoNedagnqcGTJnqX4fuQSXLl+Gr9Rkenbr1lfQ5VbkWVADdelNzYyx6599Cuc5u7Ge+tFw59IlwKVdunIZphOU52VJ80ySBGYCWZJA/rM0hWmb1ga8kDkddjm65AVJP2WzjYqKioqK+nenp2MhWQsG+2/AMMBaTilVEtBA4VlIjDBHGZl/CCFgzi2EAGiFFALiAowx6dmi1jmYOzJrKfI5WA2R6RnlmMD6kzGm6vrbDfLOnn4M5/TWkMBNuZJ0rUt5H4RzUVc1HDaZjOu6eVjjk1GObKAqIVMrx/ExgUwQK3oKiMbSewywHst4OoQkjtjUNEmA6UNBA3QObZ2Ffxokd7NpUQCvYTweS//oJ5MJPPqqVtxPrx2FwdJ5rQ0XZfSOEdwQLqFPoyc550joBNkNSqnK51lpDfm3lLVBynAxuYqxJEky3wSyPIeoa5alSUpQrM9SUspEAqZaIrbs6eoS8lashaputNYedWyshjKxzsFpjbFk7q4Bb2yMgbACLU++ZJ3kCP9CSpl7bki321tZbZZGvf6w7bHlgoTw7KL1JPvGbvCPrj/ZjM1JG1N7/lFZTMeTcZOuSuBkGYN1g/Y5SZJ0/DDR6XYBmdfpdjO/tDNZBm2n1W73/TGt/Ryoa3w5Fh26QeswBGmM0b7vNblaXPeCSsgXN26+PHzwuyro3f69VIJvK1LOIgiVcgwNzD9H37cYU5fIYpv6uldVFcUyBiwkqCc0jCV4C9lbWc+HRfK8BdMVEQCJHA1pfRfBWMO5wF/gpOz1Gi6S0VouIgC55exC+AWLcz4tppDG0OrvUJlIIdKQnJSI7et2u9DVZyQcI6TkJPpGuHoL8swYG4/HUCyj0TGEkGAKyuYokUumXpwL6VntggtBq5Z/mpYOZ+Sxfl9bW1RUVFRU1DJFI1tUVFRUVFRUVFRUVFRUVFRU1CmKIaSoqKioqKioqKioqKioqKioqFOUsLldTgNgAd35GL8TGJ28k8hZN/WGtWIyPfIwC6UU7MbNGUuJ6QySXIi2ZxslSbKyutocIIQ2aHzj3sEkWbJ97twsba1d3/BGfcce3L8PxxuST7p5Luy2zhgbn5xAutKG+02dW2RHXmrroqwiToxp9G3t4coKvCC9vbWlTfPSdX/Yhxewi6KEt6sTmQS7hfuynozH8PGnn30OlxZcwi62t258IbzJaG1tFfyAg+EQ3r4+e34HzEdnz1+AzbCzLIOnLYmhg8uUVAnCeyJvyNM3t7UiOwfLFPwE3cEg8y/b97o9NBMJAUYSIZG1RDfYrrWCqrj7ZBfeKv/tR79t+XPu7e1D+sLFi3Ctfq8rfd3q9Xpwv9vndmCT782tM2BysQ0mhjHGHImpusBkh2a3RBLuDzmmrpX2BqtK17VGIxsYc+iW0dSA6Zhlvs5o4p7K87zrDVb94cpg/UyThyxbaIp8Fspb7Y43SgwGg9WVhlvkDL7V74yjBj2QI23EWAP1f1qUI99FTE9OptOmi5CdTpI2xaJJ1zGZFhPfvWiDbC+3vPuCbFBmSrvd7vt7WVtf3/TdSH9llXR3gQ+D1E8GacEcp/f7RzMOBegun5rfa9unw43VqWMzSAZoJHKahUatpxE1imK3PB6Ndh89mqW/vHHjw48/mqWPjo5HnnullALjqpQC8tbtdC9euDBLX7p06cqVhgUzGA5baXN8wnLJmqFka2vr0sVL/rrjljczWrpzOX2OHDdHr2u155F57Ty/+9XNWXp9fWNza7O5lpSt3Bt1Gaf1J3TMYpsNethF/e2clpb6aU/DMeyv5o79fXvp5kVRXcSEFRjQvn5wkzfiYCLjLBqcqefMOTyeM+I8sk55/tp0On14/94sfTw6vnf/wSxtjMZ+jAWGLzLcc4umJ77mpyh5K7/0XMPYytKs0+37+2LUCbXU/U4fKvWzU7MVeUhwTifF5vmGBaaUunDxIqQzb3B2zpE8B1MXavrD6Rln9x40ZSKEKKaThVmm0z/q15NkOONL8p9nGTzmyxcuwgi42u/CLed5Dpf46NqncAuHh4dwqizLoDcryHTuw48/gSxd+Id/yHwzz7I2+Je3L5yD60ohsUmS+sQFFwGOChGKiOJ6xgjCqKioqKioP2V90yi4bGlK5xCcAXeWGR9KsFprAMEoBSEGzlmW5fQCs/8LziUO6oIABThlKOIaz7m2Z/pa63I8pwvXkIsnyNRIr5QiCFWLzAI681/CtmSkiGg+swRDQu12C6JgSZKQeXLp6JSanBHzqZC1MR6PYfp4cHAAaM8+CZFoVcP8SWkNYZrByipMd7Qxzp8nJdwlRpY0LszG12+WsfmyhXwKxuCcSZIgqzJNUp9Pehq6nHBCUCYOcpEI1GA0GpUevbl/sA9LwVannXs+RTmdwDyvrmsItw1X1iDT1tIwBIenPYeMCNYokGeyAHTwH8YsZfQYygByxiPAXLDmJ+XvkG5ug9CnSJNmSZCmyHaRy+vk711CSqg/WZLCEkVKidwiwqxgASSdfEiWgpaE1ZTWxodZKXvIWmQhGYPhJ0vPTkNylFtLSpouXxMpIf9ZnuedJpyUJAmp3u507PSfmsKl+GKMa9ju3Knxg2cQF6N1QGtVeyzddDoBrO+0mBIWkgnWcshCkl0fCuz3e/1hE9Zsd9qws4FLJGD481ar2+s26TxDVh0XS0KxJExsLTB0q6qCpXXV7RofgZpnCZOzkLq0eF0dcrV+d8rWdwklP+NQUiA63lHGkFue/0XR6aWaq9jQpVhjAINYFiWETqy1JMQ5dwUModJeB/rhPMu7vSZslKYp9JOc/w6PYxkQb4EEY51uU/+VUpAHVdf4Y5ALqmIgutuGgekQL/xQKwSHn76+4UaCP4Wthzs6RPpsS2zLvX4fmuGZMxtwqo3VVRgB0zTB6B7pOoTEsDf9Bet4NIJf0fYPDiBsVEynWA3IGMyDyujgl9J5rB5twTSq/qc8IkRFRUVFRT1LRSNbVFRUVFRUVFRUVFRUVFRUVNQpiiGkqKioqKioqKioqKioqKioqKhTNM9Coi/kB+/fE2M/feG8rLzjQOv7t2/N0lVZ7u4fwOcM3xInQAHO8gx3pd1cb3hGSZLADs2c8xQ3gUUDvxHsyqUGbGGMvXK5STvr7t1DFhJhMPGE5FkQps9oNIKXkQ/29uCo8x6SMqdlJn9GzEfdbhvsOJeeew7MOK+9+ioYH357/Zr1pqdyMoVTVVUNxSWlhMudjJDZ9Mn16/AG9bXPPofP0yyBz9fX1+Et8bffeiv3L96//Rc/hs2AN7fPw4v3vV4HrtXr9+Uigx5zaPDh8B/GZIK7y1NjV6/fh3t//rnnpn7T7tt374091+bx4ydgWtFMwxvstJwFMRU+frIL97W3fwDexuzDD6F65HkG6Z1z58Ds9uYbbwwGjeFl7/nn235T8O76WuLNTWfWN8CkkErCbMJSYM5q8HIKmUAJlVVVgeGlrirP4GAcORE22DQa35aXUgDzRWncyFwIAS//p2kKcAcu+BIDzu9frXa71x/M0mvraxNv5CmmJZjLyqJU2t8vQ1cb3RHZaA3lM56MDw72Z+nR8dHJqGHftLO87e9xOpkcHzW8pKPj42N/jDYaz2mRLmWtDT2STUIIAcdnadZpN/W/3Wp3vB82SZMFHV94HsYcdS6gEZX9EbXAaPlNR1OG1OJDCKeGUR8PDzyYwTBxyqWd4843IMfRsFmVJTzfg4PDJ3u7s3Rd1ZU3qwohwIjKBeYty7L1tWbIWF1bGw6bISNLUygKKXieNt/tdjrQ9judDvQJukbmGuPhUIjtUR0dH/vzZ9evXZ+lj8+PLly60py/1221t/xpqHg4ZCwoH86Dh4H0HfosgofxDQShRecn/m7OOWX0UBzWs1bYS51+QcEW1THKRSJm56WOLeK710odHjTTkpOTE2CrOdInU7cU5+ij54wyEV3X9xutVnvgTZRJknAyXgQPyefuG7rqYON5Qb+76NaE6Hkjp1Z6MFyZpVVdZ6ln/Dkn5ZLfCEPMH1ypJEY2tqicZ8eRJO0TCCaS+joJj8loA9/Osgz85ldfehm66KTdhqs92j+AKcTh0TGkrTFQIxKCrRyPkd/0y3ffg9u/dOlK23f7w9Vh6pv/YNCHrAqRQFVJkxQet6BNhrQ9MK0zxlKW0q6SRUVFRUVFfd+VsG/gCxAAgaBzGoAXENCAMQYgEWVZwhpAa03JJWROxmGOLqRoAU5byhSBAvSyhJUgRM+b/62xfZ9mzlJmJCCuHXMUd81wysFqH79gjNVlsRAZS9k0y3gWlDcuyaSmPxhYP+9ZX1nRnomTpqkRnuRKaOXGGsRsE15jXdeQJXV4hJ+TcEOSSDimUgqKd2f3HIRFRkdHEELqDVcSH/1J0hTKuuecw2Kk2Jk5KiiEORJyDB6fppnw9zgYDICF1O/3IPSzu7fPfRgiQNwEaZyWQViQMXZCcOP0eeV5DveSJglUrYO9feMR12tra8pHP3krTz0zRWuNxS7FwuiMcxaKwjkHU2drtPH3YowxZOqM5wnm4sg94VxQEANdxpA5LicE7j/cPFUmSepDbHmeY1NNE1gD8ODOAhYMPDvrHLQFpRTwZbRSiBsn+Hyt8XNVV5CeA1YFeF2okzzAmYWhuoTkH7sackISYFmyWHdhQIV9H/V7C03O7cbgE9qYuoKQa10UzfLVaA2hyTRJRQrdPvKJBOfQj+VZDiFyEeYZ16VpCn1gkpB6K8IQD80ohNGtVXVT96qqPPGo78nJoPbDXJZnUEFcuHvDXMVhX5MLwHvL9P2pY9+5WmFoI0D4nxZSt9bCtKSua8A1OrY4tOccwnHmum3oN6RMAN0ok2TZS92/9x6CMwY/ezDGoW4ziri2cyFvtiQNZchh/LIiZIQtizd/Qy+4aMizzkE0TQoJs7Xh6gpMCbbVebj0cNCHSA0XHJiFTgeRPrhyXddwuYPDQ/jL8eFBVTZRv7KssGk7sn8GZ8C+p786NH/6mk4NnUdFRUVFRX2PFY1sUVFRUVFRUVFRUVFRUVFRUVGnKIaQoqKioqKioqKioqKioqKioqJOUcIWmDgaBYZ2YjBx4Nyxdvfxo1m6LMvfvv/eLF2r+snuE/9FC8Z+zpCjJITY3t6epaUQr738SpOWstdpdl8m5h7GiEmBM7a9dbY5v7NbZ33aWk5eP07xTe9A9L4ePnoE6Ttf3oA3nLd3LkCxZOT9dLrpeAAssIuDcRcuP++8oelHP/4JmPl3Dw5hM91PP/0cNy93xuHus8QaRMo/NBWSl8nJG/mT8RiK4oOPP4a3sh8+egQmjq2zZxP/Qv6bP0Be0ht/9iMwiWxsrCVg+uCCmNfw/XRLeDS43T1jvV4XXvZ++fU3VN2YCEYnY/CjOWunRcOkePDoMZqbiEHPEugAfb5SCPQbMZTTGgrryZMnkP+6quGF/99+/AkwI7bOnc29ke3NN94EZsrVl17u9T1jJc/AGMhlgkAXxFywqixLf1/TYloAa8MSetgcSwuYSkJAfUuShHoGKUsCNyOfe9P+WSrNcmAw9fv9oeci5VmeEq8l1GEh0E7E0a7KlFJF2fxhPBkfHTYcnJOTk8ozOJTS2p9ncnJy7I85PDo6PGr8m1WN5lNOL8AQKsO5hEy08laaNV1Br9sdrjTcEIBhMRZuwi04sRYtdivwPzTx4vSrua8l/L8JLykArtAk5R8RDJmvk09palvI53LOGd9eiqIcnTT+0/3dXRgmJtMJHXqgX6LMryzJgF3V7XZhU/NWpwOGXD53U/6faZZ2PDuGspDKJCVPmhijgl3PTTFt2vWhOPriy5uztFJ670mTf63VuQsX8IbpMLqonVITluDIDmNcuIXPmhhaOfyHMf419JI/P6MwQ/JdTrGGlIsUDv0LsvC0WuhonauGYBCjfK6w3BiZNoT1kJh/Sf7DLCAfDTJhtZ76PrkoS0syRPtYyg8KCEBwLSFgt/gsy9K0SUtiJGfhsCWWMYmoFpno526NTj8kTMMEB1ObMQbGdyEshV2FPtw5T/rsGAeFJYjpmI7pbI55JJZUFIqXIh9rreDx1aoWpjlVq9MG//hOdwBfefHFF8HIduv2VzDE3PnqDkyrrLHoXyZtbTtiwTUAACAASURBVDQawXl+88H7MFRdvHwZev5X33479dOAPM8Zzk6lkEDt/Fojm31MypQLUhUFhyb/rDGFUVFRUVFRfywlpx/CGAtDS7C8ss5BLKAqi8PDhlWplAKwhbN2yTjKu53OLCWl3Diz2aSFhNAPXzg7Zoxx3u8DC8l0/HmcdfRadN5mSAiGnnVK2TqjEYz91jouAO1MQ2wUcHP6vHB1fRVmp+fP7wBWaXVlCIGOJEkYmZ5iUMIsjiME113ix1cEE0uhAM5amGYprWG6ef7c2VarmVcVk7HFaT1eQXBGCg/DItaGU38vGsI7s7WlPGfhwsWLpQ8bDT7qQ0QsSRJ4TFprOKMloTHJkYPDlyx1rEGscjGd4hKOc7jfuq5h2Wm4bfkQ0rmz28YzMorpNG81VSvJHEGiBrNoSBmDDBetML0UmuAYnJSTSb7giB+eHYYX+2PMSAXnQKBP0yzLPAspkbiEIEtQ5yi+F0vIWQvPtyYsJKUUYOaNMXAererahx2rqobjrSXhbFJujjGyvOSItpUC1g9pmsLyD4AmUShawb5DbaN1wDmMhiulKt/2q7KEYSJE5lF2GOl/hEiRZ5TCslkQjHFzva+JC5mk5LsYojq9D7fWQVuuqnp00uxsMD4ZF/5eOnV37vbnb+Qbzu8cZN85xxaGkJbp2z6iP9KS9hto78HUYkm50VARX1RFl4WQaIjKOnyOWmM/w+ZGL76kLpGPkbElJQnrE8ji78DKearmtiDMRxnPgmP83gVE8qe4Pj09DxDmS7+yJM8LnymbhcD8kGeMgT+kaQIhpHZvFY5fXVuH3r7fw905pBDGn9Y4MrUjA3NVwfYObP/gEH5JOj4+gl+zlFLwlbzdgjQNCS0VmQ7RqQiNzEZFRUVFRX1fFY1sUVFRUVFRUVFRUVFRUVFRUVGnKIaQoqKioqKioqKioqKioqKioqJO0byVgy99i5s4VmCXbuuODvZn6el0euvOnVnaGDv2wAvHEDTAGWfwrrfg22c9C0nKqy+92nwseM/DVpovLcrOymrztrOzdmVt3eeHmuaCnZLJ7uPBO8aPPMyCMfbll1+CoeDtwwN4Qb17dhOOsQvLhDFDPpck3fcADsbYpeevwh9+8uOfas9CamUteFv7/oMHYHZ78mQXXgI/OjyEz+uqpi+c4/vmzsLdVVUJRacogKCsINeHR0dQXHVdge9MStntNb4Mq3/U8uCAra0zUIyMsDY4l6TUqeEOkmwwHMIm989dfQHeJP/J3h4wg3bOn6895ubugwewifve3j6k66oCHoQ1Gh4HfaiCc3j4SqGhD2A6jLETwop6tPcYnnUxng589bPWbW42j37n+att/yj73TaUg9UavI1VWZYlMp7o5tOQZ06amHPUs2g5g92LBTkGm48NWCGEa/OsX5sn7hEpBfWHAreLOUff5A8MJv5zYwzXzT+0Vko1RgOjtbFoZIONpetaASOprqvSG9mo2W2O7UKbBVxYCpkkaMQD5hcXHMxxJktcRkwiyKbhyB/hT9E9/gHlQgdO6Pyhhy36wvIME4NM6M5YeCFyzDKzknMO+Fb7e7t3v7o1S3/55Y1bt7+apQ8Oj4jxB+tbkiTAKVtbXd3ZOT9LX7x4cXP73Cw9XF0njygQfJ6kWbvbeJ/7w8Gq52HVdQ3mOGct5NPR8cM5qCfMOXCpjMYnk8lklu71+6Rokd3DOCf7zgcsKuKhCwvuW/mfnu5gaqr6g9ZUgvfhp1ZQwuqiBlUW8pKoWZWy4TjhJdF+kjD1DDIHrSGsIgdgHU7MzowxGKN5cDNB/in4RlKz25Lf55bhJufwYQs/F8Ex+CGCgZwlJnQLBmHGuUwoGnKB0Wyu/bpl/Ztbcgw5BR2opJTBqX2yrmso6ul0Ct7SzbUtuNpLr7wKw9+Xn3+BLKTbt2GYODkZwzBEy0eQ3D189Bj88u+/+x4gEbcvXMjzBvt4+YUXZQL+Vsl93rIsg6kL9fcFY8E8L4nP/T8qKioqKup7pm9PA3GOspBKv8Yri2I0aiAR1lqAmJBQA3M4nWacs55fk8skWdvc8p8jG3L2wcJcAA/VWgcxDgrBYSyYtC6jAgBfkzE2Gh3DV+qy5MGa+BQtm8nD+ocxtraxAfd/6coVmA8dHx4CM1JrBfOV6XQKx5ycjLjF0AOELUQ4F4f5jdEYyjGEHQPPizE2mU6hePv9HszhdnefFNMmhDQZj3DafWYDV0bOwU0LgdP6ZeWQZvhQ186c0T4kdOXKFUBQSylr/3lZlUXZVKHxeAJLBa01Yz4/Gqf+c5NxyIi1lobPYFJZkOc7GmMIbHN9HfBe+3u7qQ89rJ7dln7eadst6dcKxlrIg9baBPwj5LlguI1US4qPnZuJE0S6o1N8GkH6I4Uw+KkYby4IsCQIuZBwmLVQzw3BsVtrAONqDaYNWf7Nsbcw3BYATinBHPMshSAIJE7Oic+R5t+SK/HwZoIw7p+SnpJ8/QfLt2MOlrV1VZwcN5Hck9EIuEJVVQXf8VkTQgAkpdXKV1ca1H1/MOh6HF7eakOoSMxjziHcIBLffrOs1fLbBaRpCnXDMcYJcg77EOeQ0cY5ZLWuldJNf0XZbXNh4oXhDB5AfThbiDd+BvoGJtEfRU9ZBYP2Tr9Oe33CZaNfhPgCZXI5awnrZ0l/Ev4KFWabxizpnIPm7Zvu6HdTOBNZzBui4wX87MQc45xMq9zi89CP3Lfs34I8MPw+/UWBiuIdjUIUWiIRsbe2cQZOu3nmDET00iQJz7jo8Vm8yclkDLexf7CfpU2XMhmPLRmGcH5KeIdSShpVDJBtJPEnNghERUVFRUU9W0UjW1RUVFRUVFRUVFRUVFRUVFTUKYohpKioqKioqKioqKioqKioqKioU5SwuV1XSZpsXE4gI5wb/2a4tm40Gs3Sk+n0aHTcnMQ6cCQxxgBEwhgDkAoXQsObzMYUk7E/vxgdnyy6MrPkZWEpU38tOzlBAx3dWHfZ2+8IN2HsZDyB9P2HDyE9mYyRZ2EtvIlN3752hHMhCSCGnl9wfF++neOb5FdffAmyNxgMIX12ews8aKvDIXjQPv/iCzC77e7tgQmImrO0UnAxoXHHXAJ9CGABnDF4LXt3dw8MHb9+970sa7Katlq9bmNqSxLZ7jSb3G+cOSN9UVuHxrE5WAy+GE4exsrKChjxXvvBnwHnaGvnIhhDVtfPgOfu+rVPCp9++OgRHH98PAJ2iVGKmGVqeIGf+lqSFG2b1qBFib5nf/feg0f+rfVOp7sybIwztTHrZxqv5dVXXukPG15SKiX3xqg8b1uEMggCQQlMT5RhgRyfubpKjDxQtSQxWDnqDnjGLrbQgGZgY2xjLBh8WIAbI1AMch4hBByTpSkwifIsTz2ngwsBz0UmSeb9qnmW51mTloLUJspPIYZBS4xaZVkAa2xaTIFfY43JcJN4iUwT0nVwzkP3IJhcuAN2lXsKp+uzUYDjwI3tsZ4QFNVyWw494bwn42lu7JRjlFKTSeMXfvzo8Y0vvpilb9+5fe/Bg1m6KAroppxz1vdesiU7vs/ptjv9XmNea+d54Z9jIuXhsR8+nOV+k2/qoBlPJoeHjYGurmvwSmdZlvs6phUaUY1z0IdQLg9njI4FYz/8nfR6Y3+PWZr02rk/PmSWLWLZcMrYImZkRocwax3JDzHAkj6WuSVdQeCAhbbsCDdHMrfMJLVUT8PVosYgwiyjLtPAB7boVNQVFVjO6HATwGjQuOoctgshBNip6yRZaF7jPOAuWWKUhokFZxzL0FiOY9/CMpjX03QWxFS7/Ec+HOMsvTbl6IXe21NzRk9OyoQa90KuliNTHSklGVIZsPHo1Mg5rGZ1VcFjmhbTRBI0mD/r1tktePTPPfccTIFeuPo8YJ6uf/Y5DEOTyZQa6OBaqsbp6J17/z9779UuyY2da8KFSe+2r23KF9lkt1o688zNXMwvnmcu5j/M0XE6I3OkbrqqYpld26V3YQDMRQbWWkhmdrEltaTmg++CxM6KjAAQAAJYGd+LdzB1+fb3v6s7DELabCn3iCm11q56qZHNaAOPv0gK9KRv+4J/8nj693pCBAUFBQUF/Wn081hIfoyJ4rQBDJFl2drBa6y1yHFkTAkajMJ5JMw/jLAQF+AENsEYg3UaY0yTNZByiCGjNXKXjKGgFs+cv2vuzhhDTipjszka5vM8h3mGP/fC83hobRJwo3lmZI4VKaztw2NEdHccDpwxZq2GqptNRhAiubu/h3nSfLnAqS3hOBhjcKotLEz7rN4qw47ZDKyrGWM3tzfAH7m7uVk1gIs0w2sdHHghNichSD3TcBupq1q9BumkjrjxZrdXFA5farEZTMejhUNWrdbrzDWzLM9hPpdxjNzlRWGx9eHcTnAkRxltmN1RJ9PJBLL66eZmuaque393D6zN9TqrNauiRULBEkVFShYKTwfTSG/aTRf9P8Hr/OQgzpkgmNh/l4motYRVpDUuZa3ZuQzzv+xBkgn+VkIbE1KQ8A2eRBBukVIKuFSMCy+ss8Xg2CQMM279Co2EMZbnOWC8jTHKrQ0ERZj77XYnEs2S0NW/W/yI1tUWCmzXMX/8Bf7YWNJuGWMBk7+Yz0fj0SY9mU7hF4iyQDQ+MwbGN8E5DJtRHAH7VimFiP0iX2VuGDdaWLjdHPrmerWGkHShNfzSQNsh/XmA+0OWJ+gL1mauLeV5AfkRfoMgbB3v090np9dhOxo2zcDPF4m4UjLTv+SU/tk/V5ytsnA6wu3ise8b6fbeFBr69MNV9BCK3/ZZcpiiNYTbNfhFxKmLNd5A/68tawynIB7v39z//aDa7vTPutieP372efbcNe9DOC/dFaHIcwthGjKLazZwejAYHEAPPRwMYGoUvY4FIO1mM7g1kVJQNfQRMJ3O4PyT4TB3IaTZbB7FmcuDxlvPaUTSAJ7Pa4o0gvQnaAZBQUFBQUH/0RSMbEFBQUFBQUFBQUFBQUFBQUFBn1EIIQUFBQUFBQUFBQUFBQUFBQUFfUaKMfICOEPXDGPMEtAJbHHKrB0NHzbJ9Wp9f3fr0qvMuQnobuUUb2AZQ3iKZT+8fb1JCiH+n//7/3IXYk1ndLKMaWpJwrxxQBNYa7//voJrMGNhR/atslCDVUGNV2Q3ZcpFKovCCMgqNfzjOTV5Y5ma2iS5FjO7jV2KHCNiNLhdXF2haYi8Nd3q9oCLdHd7C6ath/sHOO33P3wP1fvu3TswxHGLTIqC3lOaf2JxuH8Ywpvb//Nv/xZ4MedXl+12xQY6Pj2Tjl9D69YTea2d1hs9nBocGo0G5OHi6TN4+dxamzkTytWTp5kzxYyGD1Cch4cH4Ci9efM2y6rj7+/uC+dVLLWGWymFgCZtiIPFkGr5cH19+3C/SXf7/f77d1U+W+3l/KSqk8srgCnUGy3hDJb1Wr2WVp8rJcEUqclm0pzQa+hL8dpYZPpYNFMYbYDVYiU3jJgy/pRmqrIsixw2Ms9z183LstTeEIGMGOz+xFgaRRFspt5o1FvtiifVbDVT1+WTNI0dkKLWaLTcvW42G8DkiiOFflVjLXdMEMqWItFxa3HYWa3W43HFxFnMZ+Bj1QmyUSh7hQuEtWy59jgDg+HOavu30Q7zDmNoymOUs0NMQ9t8HyfruVH+RTY4UJ7ni3mFqxuNhnd3VZ+azeYZ+IiNBf+X4Rzaf1EUMCxL9fDdD99v0tc3n966/hhHca3ecDk2TAMLCe9NWeoVjhvDd++q787nczDGlmUBY6xlXIJ7xWMPMXDQrNbr29u7TVpwefvh/SbdaLUa6SP3OZOEs0N/s9HIu+FyTz1T5hduTs8oG2j7G64e0Njl5d9aa6kJGka+PW6pf6FIM4R7ITyjGTUA7a4FTv3vlA3k8Y/YPkMZQTaJ1Bkhi6IU1CBGHs3Uz0guRa+FvnulJHB2rLLwzOKcTJn2G5D3GYH3IpAoUgDcWxr5dCVhUDJr9/n6ScH2egaFlwfP6bczz0pK631OrItkSgMfF2WBXd4w466mBPE7k2s9ffUKpj2/+cv/hFOdD9elroo/m07hc+on1Uj9YtPpDKr3v/7N34CPVUsFU50orcO3F6sVeOqllElaPZ4EIUR5qC/B/SE0UJCCgoKCgn6B8lhIf8DETRiNZuW4odl6BZCa9XqNa/498EXOmCZo59FkAid/8+Y1fB4nmCtNuSSCTnMxpHV78wk+hTgC288EoQxIOq/KcmQw6bJkMMVE+hOjuG6taTEJR2P/hBFzT+Zngiwg+geHkDZCwRQ/bjQhVDQejWBC9OHNa1j2TCZjKP7H62ssmkbuA9f0jqCD3xIG+JxwkT4RLtJoOIKvllpjafZGkHbzWfaBmWACxxgbHB1jjrgoHXNkcHoGYZSH4QM0uTdvXkMEczKdLZZVEUbjceGOMXkBdRjFGELSRuOlSIudTKYw17y9uwPk1nh4X29UiN+yLBiv0ipOEnfOOI4ihyQXXNClOza/fcsEci+sxXCStQbyb41h+yJ3/9oyuoRwZFmWsIQ2hkzMfRyvh7uGpaMU0vGMoihOXYgtjpPIhY2iKIKlXZykHk7bpaWUBCtOrkvWo1uQKUStlwWEF/M8h76jNdbt/kk/clLomuE/mv618vWvhEJiWpeFq/PVkjwysgz6MqcIcPLdkqDuFsvVcDTcpOeLxQxw2grXftYaCAfQO6SNhXDzbD6/H1bnybMMxkyjNfQ8LkgIgMri0r3U5XxeYbznjfnSpaXgHoaZkgAx8okPDGEs2xdDwsvSP3Y/qO3+uwRjGv2m2bXI/xNpmwO1K7T0ByYgHtp5HzL8cxfnnMsI2Wrer2Xwu4FlBKO+l7tExw1A9RuD950zxhROUf5F/WePDAkLYh728+l2F8d6GH76L7t5Ulvn8chLWwPGjsg7nXppra3AKqJDK/woxcn07+D4BNKPnz6HUFGn2ykdQlEIQTczIb/Q4IfrbA3/cv3pE8zEPl1/hEdM7+AIPi/yHDFnZEcItivUuH3l/6CPiKCgoKCgoH+pgpEtKCgoKCgoKCgoKCgoKCgoKOgzCiGkoKCgoKCgoKCgoKCgoKCgoKDPSDFGLN2MG2+DdgwwFe714CIv33z7+006W6+/+6biEBVladCkZhXlENG0e0ucG/twe+suy5cOlsEYU/t2sfXM7fjmee5cEtYyXZTkcPKmOjmNpC9ce29WI7jo9u4eir8qSkgnpE4U2ReYchys3QVoYIy+9ywJg4nR+iHH99st+CMmmxCvjo/hmINOB16qLzPcsDxNEjBwvXn9piyBGTSEl95ppRhNNiknGxjfPwzh9lHu0nqdx2mVlor6HGmxsB4oK4qajLjFF+OpmaMWI5vm+HAAhr5epw3exrOzU3ibfdDrgkEpsgbMMt1GY+nwWO/ff4CNvcuiQNMB8ZrwUiNzxBjgPrx7//7mrjLLfP3113FSpZ88fiLa1TG1WgqfyyQRzjRhOcFHWIuGKSMs8RDgm/+kFo01eH/LEgx9No38VkY9lXBO34Cw23noY8s8+1eVWK+zxaqqz+F4fP9QodCyLIOX+Y2xGhk0HN72p21eKRVFlbmvUa+1W9WGzY1areFMf0oKMOil9Xrdded2u9NttjbpWEVQV4aYOJRQyL8g7BgjsEvqskQ2Vp5ZZ5LiNgXTIqfVaSkxjN4Zazge//lN0amp0/8X3MDeB6DQzcXJafbwYoQQUsFB5CKcdj1wiFjmma2oUYiYEBkwvCTnFjhBQuAx5FqWFFMbg8ax8fTuUzXUT0aTuWMbZVnmmVzQycIU9B1mof/mRbEA81qE5jUhhCCoPo9lQ804rkryHM+jtS6cAZZzDiZKyyx6qK3FL0scHNfr9Y/v30PeXr+uOE3Hx8eXT59V+ZQiAu+zb+yFh5zg+AS2FpF51tLnCzOknsGD9pOdxXd1YHIiS5lKxjIOefPb3o4qZIxz73K7rsXhP5Cl6nNL25jA++K1c+wCnPl2c1IWJ8E4/CnIr2Gc9FPObOTaUpzEjWY15hhjGs2GK6wBEyLjlKHDEeHH8b7oslw4L7/W+vb6Y3X+OH789DGph90Gri1SE0kSz/5+cziccOH6RVmUxaoax4osB7aXtXvMxYTCxxmO1YwzAP1wIeD5xTmnvzXudKu5krimRVhIhnixjYZWzExRMne7M60BXiD2ENgkqavHz59BN/+r3/wGjGYfrj+At/3m7h6HghKnhUYbqJa7uwdI/9M//S5yeMdeHw1ui8UCplJaa0RMKpyw0LIzxoCnaI3ZTF2A3RkUFBQUFPTL0CaEBLKUPUTm0wwc5kWph/cVD3W9Xt+59aTWGtaTdjO9c+I7l0/WTscT+Gvs4BSM4fqB+WEgOrHIc8o8wn8RHr6XPLbJ/IyGkMjUjhljYPYymy9guZWXVgjHJIrJFJa4/2nYaN9y0p/ue7GWnZ/X3XyOMdZIME1jB416HeZJ8+kE5k/L9RLSd/cPuZtjyckEAOWcUgNKTab7ODWcz+aQ7eVikbpslKXGpsIlXbnjObdmm7tFoijkECVwaZq0GvB5u4lpQ+otTVMIIWXzGYSQstViuaym2uPxGHIx19rPKmSHhtLwgNFoDIGmyWS6mFVLDl0WcJiKFC4LleIKmzGySIzdubTjkrRKQ/ijBkNOxmhjYCqMS1m6VNgXyaCECK/DG0tCeLiUpXGHsiyBR7NcLeeLOXzu435dSE5KjuEVHFCEEBAdVlGcOgx5EkWx+1xICaGcKE6SWsWZqtdqdZeWUjJsb7g848J6AA5gmlhucA2DawCrSwPoNEM7MPPqk8aTkCnD964fUHvDRqCd7F72EzYNhXrsjCJxzmA9RsMlli6/yVDpnd6SIYhzGg6QO8Nk1lgIAdCwBeH7GGMBe7dereeuvyzJrgtlqXcOiVwI4fqa1hpwxev1Gs4plYxd2JEzDnE+YwyEyzlHLLEQArm5xgBGnXKyIqWkO6e1zLjzMBrdJjc+LwrA+SVJApymtFYrXZsUAu+LV0aK+7UM2493X/YHHki3gw//EJwLxnYSYrOEU7bVQHdHiqz1m+WO5m234tM7y7V9LehTWzFsDHFi2Mv6UwsvxzREjn0WQiRRpFIX4s/iJHFpY8xqQcdSzAL99auAEKoxuQvlc8FnU2wDpOBs+55hsXbEGrzyknAh2wx3tJTu/DAFKooCfjnTRVEW5Bmxu9qtN62CX3o4Vy7Ez4Xg7rrb7cpnTJK8mZ2f00eJtQYe+IbsblFqbXe33t3N++TsFNLPXzyDIb3z1/8Z0GafhkPtqlcwv8+45HQ6gz9ub++gqnPyq2G2XkOX0cbAtEdxDyS6U5ZVaKr9PTMoKCgoKOjPUsHIFhQUFBQUFBQUFBQUFBQUFBT0GYUQUlBQUFBQUFBQUFBQUFBQUFDQZ6SY/6axIG4IfMPcstI5obL1+t2Pb106++hAANZYcrylr1Br6owg7h7lXANs+4V8msNdcIet85A3vTXymJj+GSYRaiRZr9Zw6Y/vfoQXp2+v34PpoP7sKXzubR+7ZwN7CjWQQpKX9tElARAZRsyDWyei+eRCQAlqjSZ8fvniFWw4zZWCzdfvboeZM2483N1blzYGjUhcoPuFXsuQrZ8tMUEIgTvvUg4FfR3ds7H5ZYHrCoHAJGqSMMYQY8vuOqHhz16vCwaWV1//GvgmtVpj7ZgRD8PheDLdpJeLN5l7453eo1gpLAs1WWjN0RiFFWQJs0OgB4hFkYqJHxO6gJSSgUHA4pWtMYYYW+Be5FkGprzpeDy8u9uk62mqohjrZJdhwa9/ZKB4u1kTw6AgJiYCBGF5lgGP5uHh4cblYblYEtMEUw4k4bOcGGFOcel4PbU0bbbaVbreAFObFELr6pxpvSYd76ZWq4EJRRJnkBACDIOGMQvtnzFq9AN0WlbkUJbJZAr1GcdxrdFw5+RwCWsMbjwvBOme2P6tvyM126k9EJkt/hE5hHJn0JiztUs3cVhYwtDxkTXI0MERy1pDh30vn9DmjdHOOGmM8f3IOxgr1I+1XC4nzuN8/fHD+zdvNunhwwOyjfIcTT3CqwrA6gkhaq5t0MJbzyOFBkbBVJRSFx/0VHQdKymAj2MtMrys/8hADg7zzIzW5S1bZw+ujFKID46LJLhYuT5r46iW4GOOEf4U4TQx7Kw+9seSMYekielyv3mN5Ji2EwNpQ01thEnE9zdjvsfExPc8pgmSa1829+Xa+4z6LNF752UG7y95lDEuBJizklpt0D/YpCMV9Xv9Tbooi8loDOfXere5DPuRscCDS5Nk5Hz9SZqulpWZWggRN2rkPJ+f3nA6rDFsG7SY8Iyz1s4mVZ7LPL/7dF2VpSiADWetpThCeo+gnXPGIjfGcs7PTk/h4JozDv8h+T5Ku/tfyHSLNN2iLKFoeZFLl21jLPj7pN+uoInSKd/51RMY+n7769+Ake1uNILqWhYjGGq0gafxhg1XXWIyncIQtM4yyNt0OoVxkzOmFPEV7qkKhrdP0FsQFBQUFBT0i5Fi/rOPzpsNAggsMH2LPB86blGWZaPRCI4nawlvEQOTfc44wcV48wAactpGhO76nM6rkgjn6DnhJmoXR2Bbax48pRe+ASgjY2w8GsIlZuOxoMsJDCFRWAaWxYNB+KElDD+R69JQFJ2gUHlUA5KM0xTSpxeX8C9xownZ+7v/8T8BI62UAkaSYciPEASRW5I6tKTcxlrKOxDeEgjK+PkJ024I0VbozWDIgxO+N/cXLiDgpDLGas0mXCKpNYCR9Nd//Z9pPqGYnCHWWsQKwgeU9WONRogDBcD6a1nIkSLcH0u7mOBQb1Ybr5sg+wOroihLYMcsl8ulwwAXpbaMBrtQu7sJXd97aNvdnAv6aUkQ1IvFcuLCcLooYTnNSTREW8MIkty4cgkuoG6jKIIlSlJLIxceYqQ7xHEcxVVG0iQGlo2/LiKhImMg9CClIH0Nl99loaE+16vVYjZ1c++BZQAAIABJREFU6UHpvhtxSfo4gV+QNd4WqRxvsMdHY/9s+dAZ7KfW0nu6HW8g193FoCF/W0uGa8pt9g5FnpEXwibL9R1XYIwxlq9Xc8eImY5HD8NqyT1fzIFDRJH2kktCxEZ0sZKIYBeCYxvTBtaKnHHoeZIwj4zF9kD7qRAigmO04RzCZBoeAYLjtbZCcvBHkeelC3fW0nQyrpb0nXYHdnhQdAFJBnFOOETWCyRguNAyxnbdo+179dkgkmXQBw0NIWmDnDXh3dCfMYr/mwqGKc5wzb+dxz1cJwj7KhU321XY2ljbco+MLM8ozMmfupDTk5Dx3OG3i6JcLICLV2L7EZxxEoIxO87zk+x/PjCI91GbfL1yeSim02ocK4uCTtu2LoDngWcf5ziucj7odiGTgKv/+W3Bi/BC2h/J4J/KUkMUXpclNm8vyyTP3twDh+LDkzMY3l++fAGP9f/3v/83wEWthIR7QK9Ff4lcrVZQgpXjJzLGsjyDaDtnfM8Mx+6up/9g/SgoKCgoKOhfS8HIFhQUFBQUFBQUFBQUFBQUFBT0GYUQUlBQUFBQUFBQUFBQUFBQUFDQZ6TY/pdtcYdma2fjypUwm07ATZPlObwqzL23iy2CLTgHyAgX4vLifJMWnPd6PfguNdDtMzrR3XA9hgh59Xk8m8FZfnAADsYYuG+2RM+DOz0z9vr1a3hj+dP1B+AU/Oq3v5WEH4QnIklKYKJvZZeavomNn/tlR4MbI+Y4j19D2VXk/LGCrLFupwOHNRsNYNBIKWHn2pILyCAAaJj/9riSFEeAhhpTFoDHsjLyPGgeEsvl0zMBIefF43DRDcU5x9JzZGFQ1x9naL6j9akI4KDZasVur2WlIjQ1RAoYEL5Z0gALQxsN2VNcUTMj+BDpJuu03mpp0nAew3qt1mhUpoaywLfotfF4LrR+ID1fLKDqbq6va+6crU6PieqethupkmBGoKYPZg1hA5FCYpo6ksgG51prqOn1erV2bBdNOFZaG+3agIoi3PjcYHGklNLlM05izH+70+sPNulGo4kbV3MBmTWMw+bWaa3WdMNILU2Bj5NnGfKYOLdyBzRFRUq4/CxXq7uHil3y7Xffg9Hpy+k0y7NN+vDkpNevOCmWc9zcWqLBjfJlNv9Y/c/ztDH6h/2cU8MarH/fK+ZjiHbJsp1eNMY4x2HKePydne2WEwMX54Lk32O1YLvljNYJZGE2md5ef9ikf/juu3/83T9t0sPhENheRVHAtYQQkI5UBPujN5uNvntMpHHcdOYjaqYz1mpSb9CWjDHgUxZCwBBKa3C5XI6dAW06m3386NB+5P5yzsFfTCF/xhqdV20vL4rVqjKvZes18NcUbTPMcuYNg64SyUmJa86S/GutkVtExwpaoK2mgR5H5GQZYwkrx5Cxmv0cUebX5/lfjCEobpvrhJ537/yIrvK7BscEfIX65S0xWRsm6FmhxqNIHRwdbdJJmhwfVOPPcrUWAkzH1licBoA4J05LxoCplybZh/cf3DnTh9vbTVoqBdMbxpiiz+k9P9tZiiCkUwWFPn3AAlptbq4r/lGeZd99/131RWNyN45Zi550zj2iIIM+Lni/X+VTcPH82TM4/uDwCAq/O8f+P3mPeMat4xkJf5oEj6eSsJC0Noym3TFK7q4sespOpw3N4PLqsXb8o6eXV+B1zRcr+NzM5xQrBucpioL0JO+xCH8IIWiv9TynRD7GLpjZgoKCgoJ+gVKM7X3GgflcG7NaurDRegVgnbwoAJLCOE8iBJqQtQoHXo+U4vzs0SYtBL+6uoLDU7dmYIyx7Smyy09JWKeEGVTkyDC6/vQJ0zc3kB5PJjvPSec3JWEh3d7ewnHD4ZByMSATas/UysNC0/yTOaLABbc3V6Y48F38Jcb8uSYn81rJgcLJmvUGfJ6mdUAyCSHgK1to3p1QEyGFF5IgIQaNyCQFlerNg+ka28cGc7LsxDx44RiGN0ps5ZPO22DpTkNReKFavR7FVdOSEuHdNJTGSGjSkriO1sgNiTnWmyVsEU64QvQmJVGUuhBVFEcQxrLWIgaLM2/ySVbrUPRsvZ67047Hk6FDt87ns1q7s0mnSSwlwhrwfNYwby5LL4RrVkaW4sjD0lq77pbneZ4Bgp2gso2BJYpSCm8xx6WgkMgTjVQEfI16rdbqVPlPaineCyYIhwizGUVxWquGkTiKY0fi12WJiFmKW6Z4XYEdI8syWJZ/ur2F9tDqdnuDw0261mh2HGqXeTxUPKc2yJGh4YwtVpH74k+4JLtkyFKfE07czwLTeDsY0HAk89rnrhCSdwnOIVT0xy99OHT49Wo5dpi8u7u7Dx+rZfZqtc7c48NoA3XLOYcQTxxHEHLtdTrnDvHbajaPj483aaVk4vp1YUwGGHVOMOcGUdlSiNgxlYwxsJ4cPjy8Awy24LA7BCMYeCmldOtvY01JWDPAvimKIiuqPpLleemW8UUeU0zWHnKUL4rtR/Q1Dfd8/iReeGU71LLzPD8vhgRHU5aTtX8oisQY88cWutvGzwpd7UXUkyJYS9DsZvs4xhhjUspO14VLhOg67o9SC0HCjruwyMz6IZLlvJoOlUUxdO08TWtz9wuWipShHYjvK+fuzymOMJIEx0644uNxdd08yz+50BVtk8x6ePjI24UA+p1oN1vw4eXllfucQ4j/Z2oLtc4x8LJvqqPJsGmMwccQ39Us9rUwxO0zdnRyChHS89NTqIo3P7wp3C8Nq/UKrlWWOOXTBfn1jtwX+PmN+fhta43XPnYFhIOCgoKCgn6pCka2oKCgoKCgoKCgoKCgoKCgoKDPKISQgoKCgoKCgoKCgoKCgoKCgoI+I8W23i4mbz6XzslSFPn1ux836eViOZvDzuIF7LjMGDXe41vHgst6HYxs6qkz2wshXn7xRXU8YwnZ1ZuGtTyzFQUEkLeyYZduxmzLvalurf2nb7+FY66v0eDm7wuPf6DDiLEJMb5NpxOyYTnd195wfEke33bWDF/Qn01nnmHefbndbkHRiKeNCc4JIAdfiDYGOUT7dv+lr39zYqGzdst0A9+lIANJNo3G72qtOSOGBXdMHEUpuWWwqTblQ+miAG/BOssgdyqK4NK0/TDCufANWXSLYLyWIK+b76PFGKNLd1tLrcEnWJLN2oVFnwE19EklBXMcHLKhuM/poCYmzOZgcAB8jSdXj1uNiuHyw+vXC7chtLVWu6qWQkLVGcJ7ms3m66wyxbx5+2Y2r4wS7cFB4bpnop5I5UwZAo08nBHjklelnskF8lyWGkw61+8/wIb3b1+/+ei4G6vVinA6LJieNMmzsXCLWL1eA/Pa4WBwelzxNQ4OD1udKs9RFNN96qEdCoa8lU63c3R8sklfXlwUbqj5eH0NRpJsncHnUggLhiyNN4bnOZibbm5voT7jNIX6X62WwEXqdHstZxiMlFXQHjzDF6fNnhjZGMoyg22bQSPN8rx0PlzKu5FKRc4XHCmhFAWZkCv5KKtNwhjk+FjjGaAoE4cCQdAEZHxODelLmDeBZkPG8aDSmMIZxNbZGvBzs/lsNoVN0Auof2MMtCUlJSDhWq3W5XmFzDs8OHjx/MUm3Wy3jo/AyKbAHKqtLQwafxipByiXUjKKquON1uBwubv5JAmP6dPtHeRz6ZhNnDHMszUUaScdsI1vMGeMMcbyLJ9NZ/B5XoKZjitvQ3cPmoWfEW8yMtcMmtooc8pSa7XFZ4cQAo1Elj5J6OPFejd4xyHbHjLf+8x3HuN/YQfCz5L74jnZLD7jrGVkILekfuxOc5+xxLTIxNZDoPpciI4zZ0kpTxwXaZRM4tQZjY0BoyXzHqmcDu8aGHMF/+T88mmafvpQmSKjOL58/nKTFpz3WnXMjfEezZCWFFYEac5L7Mv2YejMa3n29s1bl87HozHUFBh7GWNRpNzn3MMOkns3ABaS4OdXj+G6qTML/0xHq2dks97TcKd3Mssz+vjARxXBotH6oSw2Q0zOFBPZ6XShmF9++St4HHz/wxvgIo0nE9JNJDY5afERSetKYqfVZIoohOc19h6u6K/kn/V4BgUFBQUF/Tlqg9Mmy35cV+DzssiLh7tqbr1crYCHqnVJICa2wFAOUwpDKqljISmlHj+FEBJ//uVXeAxhIVGGotg1n2b+fGXl2KXWspoz9htj2u0WHPMTBCmkyZyYMHEAasAYWyyXMKcxBmfF1mj4AkGXUOIzWywWMA2i3KVmqwV/SOvlje+astG5FK0Tukz1eUk0/GTo1A35QTSExDnwkuhkk3I96dJFKqlweoprFHrOkrCE1us1fDthHLHWypKpIWFYeGtXUi7C8TF7Ymm0+rTWQAo3lC1iNC4DKPOSFFJIKci8luK9kA9FOU2kkjvdnnIY1Mvz80a9WkJ8+PhxTkJIkB8lFVxLk8+Xy6VYO5z27d3KLW8+XX9K3TmPT06aLszBOdI/JcOlqdeoKJeEY1PJSwy3jYYPk+HDJn1/d3vvun+WZ2Qpi9VOy0KbWpIktXrFquh1O0du2dbt9RvNdlV2Gkb08Sbwab3V7rv1wNnZaeG4M7P5bObqM88wPMQ4k64eKGOIMctdk74fDvmoOqY/GACqOa01Ele3nIukBukIhjtOmjrne9YJe1hjhKLOiqIEtFxZlKVrq0mSGmxjEYSuvNP7oSuL9U+5M7gcorh0ay0MU5YEaS0jdWU9NDteyO5+e9VapgHBnuXLVfWYWK5Wi8Xcld16ISTSZmBMaDTqjxz/6PT09Itf/WqTbrZag6MqjKiiKHGPFWNtafGchNGGTUhFcZpUx5dFma+rR0az2cxd/a+yrN2q2sBqvYbQrTUGHj3aGhhPOEGtM/K4LMsCdpyI4xjC1tZyDDl57WU3O8WSUKAhkB5j6BqVRp9I1MinyXjhwt0sJO93FforhvcrhRey3H3MPu1jM+08htGfBxj3hudd3/Vw2lsoJCchBfDXBOeDgwMoVezCtcZoihf0f4nBPgXAnZLxoQvfpGk6fKjGzChOFouqjQkhuiSERAu8LyTBSBpClsaYqftlK8vWt3cVF68siukMdwuh5wSGNmesINwf/FmIsU4bWEji5PwCjol3hq19+SFFlBfltDvqkDFWEJy2MQaqXQiMzltD80zDkfTXRLxus4VTvhevvoBu+1//y3/JXYT3d+Ib2LOEE7aRIFMmf2qECO0iy6EIcSLpL0k+DInEeIOCgoKCgn6JCka2oKCgoKCgoKCgoKCgoKCgoKDPKISQgoKCgoKCgoKCgoKCgoKCgoI+o40XCWE98AauNmbkjPer5eL16x826XWWjSfVm9uG7GzNGBMS4SAAQJFS9rsAPYlOnUOBC9Hv9+G7cYRvTUfEFUbZEXTDe3RYcFZvVhvYW2Nz53Bh1vTcW+ubbOCJyBvL9Pzedr4kuVqt4M3qdbaWpTNcpDH5Lh4/GY3gr9e//yfYAB6cTYyxOEmhujot5CJRk1pJ/Wf0Apa8/a7QBqcLdHCsFgsozmw2A69fURSwka3WGi6gtSavcROUlUJSU5rE4DeUggMHirppsryA89zc3JSOOTJ6eACDSavble4l+cOTM/Ax1Wsp3X8cpEm75KSJSsu4gxh5hjtyzGQyybDsZekMCJZwgqzxjHhoXsO94Fmn3YIm3Wo2W62qyUkp4aV6+vb74fExsH6ePn/Rc7ye73/4HvyMd7d31HQA9aaUokZCKNpwNFq6svz4449gqOl0umCAajZbgJdKk1iBYVAKNMppwhAxCAq6v79bOlPY3//t/3fzqeIfffPtt3fOoDGfzcFcw4WIYAN1u2Xsqs7Z6/WAtXFxfnH15OkmfXAwqNcSyBsOI6TOBeFM9fr9yLW9p8+ep2lljptOZ2DEuxF3JdYn3TjccyhAvyvLEur/w8frLK+Gjsl0dn1dbUL/7Nmzy6snm3S33+/2qrIkSRy57iwjJRwKjbKcKLCNmhOzLMuzyjw1ur+fTSfwXTDI1JutujP69XvduNty+Zdbe2e74hoYZ6xBmhbdfJ1zjsOLIJ8T5IsxFtqSNnq3eYr87mCMLVyeV8vVyPGPJqPRxPGAVus1blJOGocQSDOTQoD3uVGvw2Pi7Pzi1G00nqZpxw3pUirpjufcM2qBQZVRdxYXcLw1tnTmyjJbzZx5Z7XObhzXZjgerdaVka0simUO5lMmcWN1BvnXZQnspPlsfuf6TlkWp9OqTpI4SjptlyHqdvGtYrv4VtaDy1jkr3FG7iMjdcuB8cQ5pwZG7zzM6xqYjX3eOvjuzyO8+GVBpg8xTpJjOBqcq6L95Dycc2pko7nc51/DZxnnieP7mHoNTLUqis5OK4NkURQz14attXlGTIskz7oEs6eeOc97nuf/8A//sElHcXxwUrXhKIqatb90eRBxShmCzr3FWEkKA6c3xtx8rMaiUpv/9bd/s0lnef792zebtNa6II9+Q0xe9DYhdpCzujPnCil6bkwTnLfabag0Ts6x77ZvNwI8DluQEMLzJDrRZ1+R51ZS/yx8YfdvnHQ6R/OQpshDOD49g+H08ZOn4H3+5rtvAIX28DBE/y9prJaWhbR6IQT8IbjvfydeYOO1xcBCCgoKCgr6BUoxCjWg6y5j5rNqbbNaLj99qnDUeVFM3drAELgGozxIjvMVpWS/Czza6NAxcYXg3S7MpxnljKo98wNvxkiSdTKvKcjaqd3G81MWI6OMRjrHJRANiuVZZzksBrPVGkIezVq6c3Ywm04hqx8/vIepUkJ4T6dXj2FJ02g0YaakyJyJos33ocQjhnVUktDAfLGApfViPgeGTlmW2uE26Ryu1BoxxkrCVFFJNPwncQzUc7psYwyPyYsS5k+T4RDmatcfP0C6n2WwXEyb7RhQWVEMyx6LaCaPLSXI3JRbUnhSV5osPpazGbJmCE57c4LqWmTZz4XA5YrAGW+r2ay5sEW71WzUIYRE5pTkvvQPDqFrPHn2bOC6zN/8j/8G1T4ejVcrRLdiGQWGCfIihzxPJpO5Y6zc3n6CYy5ubmJ3X7TWEF5hrAlhL8u4dMFATVDKxnKokcloBKyN16/ffHBLl3cfPjw8DDfpIs+R3yQkYYR5YTiIKnbardPjCoF8fnFx9bgKx/QODqE7SKahv3l0FsKcanW7jVbVnRfPnsFS5+OHD2sXjpkt5rCc0wTVbL3lEIZRtDFrFya4ubuduKV+XhRzh9m2xkBMS5cFlLHeaNZqrt3qxKFUmGHIlhLScrwWorLn88XC5fP+/n78cA/5hPvSynLApadJ1O00XQkM5zsYJZZhlJlyYdgW5AZD1bhGp8tCYw20Ty/USEJggnMAkBhroZ5Xq9VsXIVKp7MZML/yPIcQkhACwgScI/9FEIZuLU2PXQjp5OzskQvhSSlihWEREiJhEB611loaQkIuLxlOOYfrGl1CH8zy9c1tFUISSl07tLa1Fvog54jVt2QI1FrDOLNYLYeOIyakBCy9bdQZhpC8Neq+pTIJlxjCtKKHkAiMnxYkhERR6yS06l1qZwb2yto/em28M4xlLdw7I3ym2M4QklcnuzlK/sfer02xe3bbNOkfHm7SQqpTF05ardev37ypjjFWu5A9Z1wovEckRmAXbneRLMtfv327SSdJ/O7N6006juMXX1RobS5EmzCGYA6gvVkJg7h+qfXwAZlHr7//fpPOi+KD2yHEGlNS/hctO5lKIZKfsxrscCJktwMcPQ48OMaYAEQ9nXb9gWayZ3pGb6qHSiQsJF2W9FciWoKdl/LR3XixOEIE5/HpCfzLk6dPcfrR68MPjaPRWOOjHwOqnDw0jLU08kWbohdB8qYTn8l/UFBQUFDQn7uCkS0oKCgoKCgoKCgoKCgoKCgo6DMKIaSgoKCgoKCgoKCgoKCgoKCgoM9IMVY5glj1Jjy8jquH99Xb+Iv5/N3Hj5t0WeIu1B74gxh5uOAd98a+Uur4sHpLPIqieqMBxyhi/OEG91n1uD/4bjEH1zrh1WyyjW+w1x3kwlrbH/Qh3WrhG9pz5ypijIGri20xU4ixbrlaQdHub66Be9Ju1qG6IqU8vozL6of3H4xji9wPR3DMdD4HI8aT58/BWNFo1MFYIiW+lW3pTr3E9SAlbjY/HY3hbfiP734E48a7D++B81IUhUYeEIpuyt5Im1D8q8uLyL1sf3r2qNur+D5xFEuSDfQzCgEvb6+zdeaMQt99+93KbaQt5Lfwxav378BsdXJ6Co6gOI2pSQo2OJfobWKUClPmOfjdVqslmGt+97vfAQfq5uZmAkYnrUkbQmOFJu6+bqsFhrurR+cd58c8OzsDE0ScxKQi8W12KQDTxPoHh6nbJP7J48cNl55OpmDqWS2WaPahBkbLgJ2kNbJpPl5/mjkDhbWm949V3g6PjuH8nU4ncRuZK4lde7lYwFv9eVFAO7m5vV05nss33357d18ZKGbTaZFnUETwmRptgAkilYQ20+v36s7kdX726MnV46reLi6Ozh5t0s1mU5AGSFFIcN+1QTaQ5AIYRr1+H1gYT54+gXLBLuyMsfEYTX/MMgPMGmMsc/XMBRozGacGw8L1F2vMZFyZ+w5f/9DvDzbpNE3AFLPZhtpdCocRIdEUySz429hisYA2OZtOZs7w1Wm3u66NyShudwdYKbtEN0c3Bjeb1xpNc8aiGY36lHecrMqmhZ2wjS6BX2YMZaWhIU5rDSbZh7vb928r886Hd+8+Oq7QbL6AfuSP3Rwsp1JKOEapqO7acJqmcYzMI6hPKbggQzRWrmdbZNQdg1A3YuxKkrjdqx4Tvcnk0G30Pl8uE8dVMWSs4IIY2aw1zoBpSg0spNFo/O2331Vlny0eP3++SZdF+9iZOhlpJ9v0IxiLrIXHU6k1jNvGaLyPHtsIhyIr8V775kRN08RQxjztgd/QayHghtTnlm+HGvHKkrQryAPhbTHKe+I4C+CMUdBMSctS7jBdbiGbSBdEw2OkVMfdd6XUq5evNun5fP72xx836aIs5zPHwPJ831wRDhcW1hhgaalI/d3f/12Vloo7fCEXAqYlnLHEmbgZQT1aa2EHeqP1999XbUmX+u//V8VaMsZAe7PW81BT/zuMn5yLesPxj4T46tUXLs0vHz+Gzyka0vP+k7tNPvQ85sajGpCvIEXKaz95UcC5ijw38FixViBuj/QMtttHx8nHlAMlJWIiz84vAMv46sULZCHdPxQODTkcjmDaoJTyrXLQVbFYWms04klBTW2I/XJDtA8aCwoKCgoK+rOXYj7jENdC1o4d2GI+m167uZExhi7VvLCLm6RLKdutiv+qlDo7OYF0w81jKMyCMWY1GO+1JY9bOrcmSUPDKHSdQEJIpu84kdZauC5jbOHmhcznAe3m1DK2Wq1hijZ+GMJSVj99DDMDym8yZGp+e3cLy7Dv3ryGKVdRZMhXynPpztnt9SEfSZLC+Q3JJ42fUfz23e0NhK5++P47wOJe39zAnKksSuPxgHbUQ5ImUMbnT54AA+j0/BzwUnEcY2jDD73BZGq9zjK3vHz/4f3CTXmX6zXUz2w+jx3idD4ZAx+n3W5BeKU0ZFkuJMwq6Qw3W6+QwTQaw3L697//Bpa498PhwoUVdKnhFtPqoFCJNE0Bz3l5eXnqmvHp2fngCKKiNISE4hwjXIOjw3ZRNcXnz58D5f3N27dwj9arFdwjQulkUikCjNCMV7fp9vZuNK6o9nmWQdjo9PgGlt+Dfr/mliicIdBhMp3mLkSyytawDJvMZmv3+Y/v3987hHaR5TD/TpIEum2ZF5DnmqwhHr7dAkTrxfn502fPqvTl1dlFhS5WQkiccyNBlZPSW6Oh2UvFIWzU7ffrzWp4efrsec3do9F4BOVaZ9l86UJIBF2sS20E4sCBa8YsdoHRaDxxTKiyKCcOr3t/3+u59h9FESwjDW0BXl8QNNwA/7Ber2AIXa5WwOI5PT6CJVCrNyDD4OeXH9ZgCNgYo0n6j4LcWGNpiAGWoNaYndnQuoQw8XQ8unG/NNze3t7eVyyhxXJBMXl4LfKXEALR70qltWrMiZMEw0/MChzqd4dd2L7KspaELK2BUEIct91uD51+/8CFeB7Gk9iNRWWec8IVotRdiIGVWi+WLkQu5Nv376v6sXbi+qn3vPMWwx7HF9efGtu/LpHjZgzhIjESNtpqhiSiAvfUkD5lNP7UQeFZngiOfTvbhD+FYZqtO0wR77vDWJTx5MXC6LqdhIGwnWtjvLAaxhF2dkfv+a6k7A+qEG290fj1b36zSY/Ho791oZ88z96+rcJJ3A/NYPiYTBWMMTe3t9X5lfrecYukktxxhbjgh+7nB84FTFcYY4UbEyxjWZZDXb159646v9bfv34N5Vq69rZ1j2iahJBs3fUpKcWvv/rVJi2EuHr6zB3DaX0JsWOKtXWHabPRu+YVbAczyJWXhJDKskA8n7FWwK2nZdmDsCS3mE5jVITY8pPzC5j2fP2rX8GOIn/3D3+fuWq/v3+Ap3+kFNltY3e5aH6EQRykF8vcx3gPCgoKCgr6M1cwsgUFBQUFBQUFBQUFBQUFBQUFfUYhhBQUFBQUFBQUFBQUFBQUFBQU9BkpRt4KNsauHbBmvVqNhtVO3ov5fOL4QZa8Fc8Y2Wyec9z1WYhev3KyREodn55t0lLKmGxs7718TY1g7pVmzoUPG0DDmm+6R0iBJLs4d5xDwVjbd+ADxtj93QO5Fp7Jg/sYA76AT7e3UEXv3/0Il/jy66/AR5bEWC7K5ZnNZsBu+HRzCy/D53kO55wvV5A+ODgUxMgGb4CXRbnTMEU/u7+/g1vw/uMHMA7c3d/DLSt1iS9gExdEvVGHF/JPj48j96L+1dXjeqPCSB2dnMLG6kIIgqYib5uXyOzIMzSyDUcjYPfcDx+gTmazOWw2/HD/ANftEiMbs5y+GQ63LCK7I5dFAeW6u7sDwMGn2zswN80maOCyWgOARwoJodRGswkv8J8Fu4MgAAAgAElEQVQ/etR2CK3Hj5+cOCNbfzDotDsuDwragDEIQaBGy1gpcN8dn5ykjhP04vmLgTNTpEk6d/UznUzAIGa09t0dVWq1WmZZdYkba8FYMRqNYmf8aTQa8LlSEsq1XK3gjf11lkE6KwpoJ/PpTDsehzWGo7kMGSu1Wg38ob1eDza5f3p1dXBQmTUuLi8PXb01Wk0wrwlmOPWYuLxR94S3GzQZLpSUzHkUegcD6CNPntxEzhQZxRF4aWez2cqZPooSOSwe2MVgtzBMw7UmkylwkSbTSeK4XUJKMGdZOo4xLBal/lCQR14UYAzURkNfSJNkMDh0X7BpUhlPoigGVtrWbtbEvKYL5MKUxLhkScEMuDkMMX9xzrkzSGqjC9ceSpJPYzQ6O0jVFUW5WFSPhrubmzduU/Prm+v7h+rxkTmn3iYLwMRREfKPkiRpur7WaDYTZ56N45h7JhpI+YOh618c/rP1FUIxsdZqMnZFjoeV1GpNN77V6rXU3etcKTR8URoKMVsZY8DQxxjjt5XvO4mjyWgEZYHOLDkXu7zYzCI0yxijNdY/MScSsBYBrzDa9oiZURtDxn9sb9TwKD3j2F7jJP0nyqnxN3T3RmvIJprXyrLcxUKiJjVGH82cA1jOWkZZSNA3S6WwHqxXAk76J6IehQAOkVTy9Px8k260Wi+c8Xa9Xg8dB81o8+CMvcyy0l2XUf6OxbQx5s4ZOTkXuWsbnPPG23cuzVLCQqJedXBXGWsn0ynUD3DZrLX5GrsVnSaBGZxx1nHGW8b5S1cuIfjTZ88hPwfH1fgsONvJPPJaA+f0VtP7pY2HXYMzUSttqUv4fL1eE492SZsN7dvYCqgPlFk4LUVqSjqNJHnrtFtw/MXVFTTFJ1dXMCUYT6b4KFxnOL2hmTE4bArSAYwxaNbThjxiWGAhBQUFBQX9IqW2/gbO63KxnE0qiMN8sQA4CGOWIqjp3FfgXM0OHAxFqejEMXSFlMBOZltTE2q8xwewYULuPN7nJhCTPENua6fbg88P3FqdMfa9/GH3eYgoEwe4woyxTx8/QghpvVoDv0MbCwvGoihg/jGbz2HJ9PH6unTL8vv7B5hVzOZzSJ8cD2FpkSYJlDnPi535pPPO2/t7mDZ9/PgRlw2lhqmhj27F8zQaKUzRzk5PU4dhfvHFl023FD+9fFxznB1hEdlLw39lWQJ/ociz3E2Fh+Px1KGs37z9EfgvD70HCBWNx+Moqm5fr92B6aAQktRDbjGEhJygsizh8w8fPwI+fDqdAYtKaw3zSDrXFAojlY1mA8JYjy+voNk8f/nq0HFSDo6Oao4rwSyScEh0i0mBlRtH0rLqciePztuuWX796/HUdSurDbCNtC4XLpxUWAshOYIzYsvFEpZMC4KHFwIRzrV6jSzRYwh5ZHkObWO5XCKDic7RyVzZ72u4ZE3TOoRUTo+Pui5i++rFi9NHVZe/evr00EWQ640mLAUFw6FDCOl1f3ItaKyUDyUEV64+j05OIKy5XMx7PRfai6J2u+KSfPh4PXTL+NVyhcszg+3BGIwhWbIWKotyOoUQoQHeh1QS0TYE1uKRcsjKjuJ6yrKE4UVJCe2/3+tjiNOyOIUQUrR3BUIw8MiaoaEiitYu8Ri6BhOEo6u1hrzRfO4DneR5vnJ8sfv7+/cfP2zSN7d3wNLi1tK1FpRRyhQihkkSQ8iv2WgAC0lGMSxG+SbjVZqEciiv9w+Ao9w/GMss7t7Aob+ntTqEkOr1OvzaochWCZwxChaHk+oS6zkvcuC+1Wo1YCHVG3VKr8YIkv8IotsyeFwqwjOyJBy2i3DNjDHwDNpCaJPnQkn6OEX42311+EethC0JS3ntk2CwjdbIfjJ+YSAcYzmwAq31mEp0WwAyE9nKM8kSKQig9OMounxShVdm0+lXv6o4QcvF8s6FQYsiX65gFxEzL3I8I+FSQdvmjN/e3sF1b29uIR0RFDcNIdFcwtYTjNmypKElDF3hmMMY/jLHOUyxOOeHhxUeXgjx1ZcOoc3Fiy++hGNOTk/xyoCkZJa5MXaLfkT/8kJI3s4kWC30GDqtWq8zuDVliaEln3pJi4vXLfcMRxQ3VvghJEhfPn0BU5SXz5/DLfvu9evcNafVeg3dRAmcHhjyaJCC1oOGajHWQISX7ngQFBQUFBT0S1IwsgUFBQUFBQUFBQUFBQUFBQUFfUYhhBQUFBQUFBQUFBQUFBQUFBQU9Bl5RjZj9N11tStzlmWw83SWZbirMbNgAuJorGGcMene0I6iCFwtSqmm28VcSHwlWHC+ww+wEdnNd8/ex1v2fPwcXQ+cdZ0LyVp2SIxsEneJZmTHaEbQJRsmS/Vnnudw6bvbG8DcLKZTONXAwV8YY4IL484khYQdaqVUW5agTWK9XMGFH+7u0bzDqfl/N6vCEtLAYr4AFoNgHJwSVm4ZkapkmiZwopOTE2ASXV09rjkTzcmj81q9sUlHkRIc8iA4MZigQcDiBuqcZFVw3OA8Uso4EwF9M3w6m8GL6EWWC499wOB44l/xrY0utVwi64cZQ/PA4V4Q81Ga4ob0548e1WuVWe/y8ZPDo+q2Dg4Puj3Ee22bJar8eH8QaAI2y06vl7jzXz19tnQmoMViORlPoShg+ru/u1855oWxaJRT0mrXyCTtAKRbGW00q97GX9sMwRNkM2/OOHRnS6AV1Dy4+Ud3XWQqHR8d9btV13589WRwUHWxZy9fHjq+Rv/ouO26f5IkaDQghghrLTPYbUkVcmQACWxlUuDgUas3pKqMSGcXl3VnROIygi7ZqDfAi3pzezt2PJFsvQbDo2DcAtvImp19TQgJed47fO1xr9H+KzjWuVQS0pFSKXB5okhJ5a67O9BvrfUMTdTwBcwpIfBaXBg0BCG3RUUKTaOez5UMFl57x7LrsgQezXK5nM3mm/Q6zyw9GvLDBRht0jRtO1ZLv9s7O6mMooeHh/VmxUWq1ZHRxrkVcCKOditLrFfbmDzyF/GdEGYQucVJkjSd4aVeR5NmpJRQWD+AzKP3lDEOYz4XnNwyDu6YsijRnEWziLfOM41ywp2xW5YelwcurHJGPM7po5PDmCa3+GLUdEnS9Jid49vP0U98brS/2B3HESaUld7jmCNXDo/ZeiaiMXP/7ulYdV4ZiQ9ScDBQNxu1py9ebdLL1eoGjGx5DlS6sizfvnkDJ1/M0EecEJ8+cfsz/8JYAODNMcqWIi4wRhsrMcExMixwzhWY1xhrd6o+JYV4+fwFHPzlV7+u0pz3D2G6wmnV0Xa7I/PMM40yto0tgpQUAv3mjk/H/OGFkpe0NpwTHAE2S7yCpvkkj1cq+pngYucw3u52wFv35Nlz8EI+/uYbMLVNxhMAB1CWVqSwLJzwniwnIxPDaTHnwp+lBAUFBQUF/ULkhZC01g83FQc0L3JYu2ZZRuYWlnJkJHlAAlQijuJ+f+A+VB23luOce3EBOk8i2eAwwSbrHLY9fdwK9+A3IN0/PHYfMmr49+ZhlIlD8kDPSQEEt/f3MCdYzKYKphR0Oi4ETCiElALN89LC1chcZzlfQGFWyyVMQMqyhKNonW+FkCBNoQOCFMGSmZU1sNJhSRJDlV6cnQEb4otffdVwCO3zJ8+BSxJFEXxXCkKnsXhOaxFTzQnuQ5BlgFIRYWRgnifjCfKhJlNCeSdkVcG9UAjUrcRAii6Ri8EMTgAFCRtJwjqu1VJYujy+vOq5aOOXX33dPzzapE/OL1oN4EAZrFHhtWFvAY7LZsxzf9DX7rtJs5Xn1RIiipKZ4yLl6/VwWHFk1qsVZZdARRhrpYsMUpIQwY8wozEUojNNoqsUhMuAkaStBoaOUthVKRklUgq4OY9OT67OLzbpL776GpC0JxdXvYOKwZGmCSwhYgIgtQbr0FjEmfnLWrxHnFF2EoP+Va/XgM+VNBpFUdXV4OR0OqqWf91e78P793B+itOGUCMXWE4aQjIe68Qy0g090ZgE+dTjSVk8BBCwSkgIFcUqAgZZFMWKhHX2rpd2reAsXYMJAeexwgpDxgTSdySG6uj4TFBr1nAP/1z9X2tdFBBCWkDoM8syyojhpP8qXl0rrdU6Lrx4MBhcXFxu0qdnZ02Hq09rdfKrAxOIVcalr2Vck7yR3xOQb8U5fXwQaB9nECuNk6TVqX75aDQaGEKKIojCCCGgrjYNBesD16uCLu+hfoqyAK4Z5x7l2dIFKBlM6U2lTQzZQMZyhettEr7H/ivE7kbLyZKe9rs/IL8dkkfwru9y+hjdCj0QwSPYWgt9wTLLyQMZ+jsNhzHCidME9743BGYtHflojpPIhXFl46v/9L9v0tl6BQ/g9WoF58/W67EbW7TWa/czANv8SOYKYAqcNpC253G7ChdC4pw84klIfSufdOpCWWwYRhSi5369k1L+1W//EjL2v/0f/ydc6+AAdxcxBsNYkqIn/dARJknd0ikHbRt0+qT2jZlExhhDugZ5imIvoSEkRR73dIroPavIVIHmoE24SK++/jUgnL755ts8r340/cff/V7DLSC/WiklsXeSqYsR5HlPupLwoslBQUFBQUG/HIXHW1BQUFBQUFBQUFBQUFBQUFDQZxRCSEFBQUFBQUFBQUFBQUFBQUFBn5FijMEmxdqwpeMfFWUp3dvRUVp7/PgKvuPv3ooQE4BcxEoNnANIRqrVqGA6gjNJXjT2AAHU1EZfvOe73jzffit+547grOncWJaxI5cfxtiFc9wwxuqNOpwKjHjMN4vRz1utFr78H8V810vatUYDquXx1WMwzgzHY0iPxxPclH02AwxNqXGjZWrgMtZ7URrzJhV83nD1zBir11KoOpXEkK4lCXy91+7AW9avXr2M3O07e/QodeagRi2OYsdS2evrR7BEHCfwBni7109qVXN6+gy5P3EcAx9kOp1CnazmCzQmlBqNTsTGwQ1mwRCjR5IkcF8ajTqY5qhZL00SMGHVkhQMFJ1uB27xi1evOs4IcHRy3O5VL/zHEToIrNcmsexccGLewbri3sv1+A+NNEncdY9PTzqOC/Py1YvRsDKCxUk8X1R8mdU6K139ZHkBaVvgxtjrLINNoNdZpoEJJQQck6apdIaRWi2NCMIM2kMcxcDGElJAfcaxArPDy5cvT8/ONulHlxeDo8o32u22a2nizinRwkH7PmVFCXQDcn988P0ou8wyZCiIhBCupw56vZprz9PLSezYXsbanmNazWaz1araPFuXGowSZVlCmyyKAsxueV4UmM4AokE3SmfWEvMUOhoipaC9pbU0cZtwNxuNhutrl5eXRycVQ6rb70EdKiXpcGd3OYKSJGk1G67s/dPj6l6sWqulM4tV30ahOUi6e314cHDgmFa9XhfyFsUxVPQ+Tk6r1T45robZer2WuA3LBSO8G2uA3tZpt46cx/nk+PjsUTUsHx4dNx0LKU0TeGRwhkYVzmhb4VBB9HNL3GLUACU4eqQscY5FUqTuvrTb7RO3IboSHBhPQgg4FSe+P0tMbVwIYCedHB3X3bAcJ0nhjKtWikjCkEK8O9bC40yoKEmqdttotQbgDVfR9GLuvkvaG/N8WphPKeNadS/63S6Mb81uB/LJhTB7TGqer44cwHe1pS18FhRLKQWG02ardeDMwkVRELMnMU5WJ6jKBQWL4vgY21ijAcysWg3tvELYPQ+qHcVj24ykJHL1b+NHj6rxLc+yyfAe0vPpeJPW2ty5dmIZA7aatXbhxhbGbLEu4PO14wNYa/NsDVcGwy/nvN3vQhrqjTOeuj7FGEuQMcTh/grOH51WeRZSnrtpmxSiUU/hnHRAsbseVJxz2h52/9LIeeLGVcbYwWAAt/L8AqdYABjaFAGaUUy4Ub1Om1j1qekXryx3TgUZs1yAp1X4Rdjp/1VSwBB0MBiAlf7i8qJwyIKXz5/DrVyvM8iPxzqguRDoRR0c9GsOdyj3eEiDgoKCgoL+3KUYY6VD2eTGLtbVml9rLSPHdpXy1auKMUkBIoyxXCNsou7mN5GKTlyYRkrZbTf3XN1bU2JSql1H+N+k/2DIH2TS0HZsXcbYuQNtMMZePH8G6foNGuPrJARDlZD5Vq/fh0wJFXNgExAQTrvTgeX6X/zlX8B8xRgN4ZVvvvk9TP1/WK0gna9XyNcg5n/KKKHpKI5h+dFsNSEE0O/3AIHR6ffhKydHh7CUvXz0CHDgT58+BVTk01dfxC600aqnQnxmOr4p/CYVxylUVu/wGDggv/3Lv8pddLJWr2cu/frNG5hiflqtYAlR5jmCwglogIIPhMAZo5SIJe52uxAW6XS7wNcY9LrKNemDw4PYpQ+PDpO0Sj97+UW9VTWJ80cXMEUWe1AenJSdM4s8DnoQ+SadBzfruB6Inz0rXdmlEnPHlLl89mS1XG7S98MhYLmmsxmE4dbLBXTJ0WgMdfswHALOjJUltLF6swncq0F/AN221+3Asr/RbAELJq0lCnGzjTiultmPzs87Lhxz+ui8063SMUFue9VGFiWck2a8n8LyWTwL5U/FSgL1onZ4wNzSTsTJ4bBa8h2fngHHZDIeL5dVWHO5XMLuAevlCtrkYj6HOpzP5qtVdS/m8/lyUaXX2Rq6qjYYTqKMoSiOExcS6nW7XcfcOT46PDqqlsRXl1eXV9WS7/DosNl0DDIlgI9GF0WWUJnTFLlCpyfH0E1W6zUsWT0MM2EDSSmUC/R1O51Dx7E6PD5qtqqhO6mlcE7JJVl2Yv33+t2ri4qNNV8s+i5MwLkQomo/xhjrQp+9TufUIbSPjo6fvaweMd1ev+WGbiUF3xOygjjQNrMFohmMw68RPnnfX/6R9gNhu0G/d+GWwbVaLS/dGpWwpYQQwFCz1kL9cIEY+H6vT7hOjSJ3lN5I2QSX0BAi4UxwxzhTKoLwQafdPnU4v1a7DcgXS5DtgqAGOecKQyqcuf7babX7bouAdrsjXP65lJryd+jj2EMU7/6cjnEUIc8d90qpqOXGVWvtyVkVKi3Lsu6mB9ZaQ6YTiNBm3Lr2GSl17MKjtSRpuTafJik+iwU3NAS2C/lst0YdsgVEoly4XCWvvni5SRdFHrvPi6Jotaupgtb6k8NHGmOHo1GVtmY0rsYco83UjT/GmNvbW3eMnSCHiEeu7QkhDlwoWQhxenbq6oQPBgeQbrnwmeC82cH0uQvFci5efv11lRa83cRwD9uN0MZwkmUUx8S8KQCpt7prn4yxY4KbLAyGAssC07TOY8J1Ojw4ALwX4xymT4xjCIY+OmkejLWMNHs8xtqdTw/BGExpTlxbYox98cWXpXukXt98KsoqfT8awa8LhvCPIqVgWEYGFmOnZ6cQ6VOR2vw6yD8/iQoKCgoKCvpzUjCyBQUFBQUFBQUFBQUFBQUFBQV9RiGEFBQUFBQUFBQUFBQUFBQUFBT0GSnGmHtBmylmmXuzWjDbblVvaxtjmIOeMGuzAo39Oe6KzRvO9aOUBFeFkn/6KNUe15Ag4KUGMdMdOocLY8wSfk3awGO8jZDJ7ryHR8hUStIYN062Bjw7jVoCpqGzi0swZN3c3oJRazh8gGM+XH80jl+zFGiZ0tSkQF6EJtQAVqul8PJ2p92G/BwNDjB9cgzFubi8BPPFxcUFpA+PDuG0jVoCZjcu2M4dy3dtJu6Od393u53Clevi8hJMbdPxaO0YEJPxCIxXo4cHOI/WJedu027yerogpsU4iuD98EajDjyjXqcLXImDfj9yhrWj42MwYZ2cPwLuydHBALgMh4eHYOaKI6mcW4P7kIXdPBhOWUhUaD/inHF02pBdipWQrrkeHB40HdcmTROon/79PZiqRsNh5jynk+kUjFdSSDAu5UUOL9jnWQ5v4zfq9Zor46DXA0PEwcFBw3WBVreTuA3mO+0GbDafpikwkrqDQd0d36jVwThDNlNmjMAv9lXbn1qtRh1MNzE3Pbep8+JgsF5VdTWdz8CYNp/P145jMplMVs7sFkUqmlVlL7UGLlKhS+aGRCpLNr2OlIL21mm3jw4rM9Hx8cnZo0eb9MnZo8FxZWBptjvg7BCcWQZ9gaGRViA/JamnDWc66/Z7YHLMizwD8xTnxIiEzVARE2i71er1KpNdp9NJatWQnsQJmPLoZuTWMuBqNZutAze0NpqtemsJVYEGOou9udNqHjl+1uHhAZgim60WlF1KvpP9tO19/Oe2K044XEJK6Pv1RgOMmZbxpetrQggwxnLBcSjmmE/BOYyf7XanVq/qME5i2EDdWmQJcc5hKODWCvd5FIma87qWRbPbqx6pSRKDy8Z6OEJON1AHFpIQAsa3RqPRaVbtv1FvRGAE5p5JbeeYT+lHnG09dhk5jNCT0JHEa3U3nbD20DGwtNaUp2OJoUwJrFswvSqlwGiZJEnbjV1xkigsi2d+3GmG3eud5b4RD3hhUoExsyj1E9e/jNZNZ7o02tx8+lSljWm6cmltPrnf6rQ2C2dMNsbAc5Ayj6QQB47BJ6R4dFJNvbgQp2ePIJ8HfTCKcpiqCcG77rtScMBQbhcXDNdb7jDKP/LGcDSjScInSlPCM+p1oH3kRe5hHEHEHQfGecZYq90W6A9Fv+3PEWfY9ex+9MG+L4O6/T74wR9dXJRuuhKlKQzjugRwKItVBJUXSQk1Oej3Y/Cocq6tYYwpFqBIQUFBQUG/KCnGmHQLLMmZQHM+67s5K2f8kTPnezxIZtdu7coZbzSqOZCS8uiomt+IfwOgIMelOGWFKIUTkZZbnzDGLq+Qi9TpImuWhpCiBDk1i+kU0kenJzBXSNMYprbcljDdbDbwu1/+5jeQoXWewTL+YXgPHMdvvv0WsMdKKWBqUGy5IJOqKFIw96nXER19MBjAEuL80TmEh54/ewzpF19+CTygq+fP4XPpkS0wjfBbf7pJj/bAE2QhcuCgG4yxerMGjBhb5Ot1tUQf3d8u3ZT64/VH45bKWZFxKD29GAE3JEkCYbJOqwXhoaPDA8AVn52dwedXz56njnN59fxV3S2ljnvNRMFyZWc1+H94VUX+4AQMQxqitQZw6ULwnWuaJMZucnF5QU8P57n5+AHCHHefPq2h3m5uly7kkSQJZfRAe1jIFcyP280mkNdPT04PBtWS4+ziqu1Qu73+IHVLvkdnJx0XgeWkyJzGiraCQ17MzFuF/tur1271XHjFnmCbzMsCQiF3d/fT6WSTHo9GwKJ6eLifTKrPo+sYQjZZWWRlNfTlRcYdOdfrI8YA/F0pVXfhmIP+4Moxj84vr66ePN2kD09OT1w4KVYycsOXNSVdhsGYIyMZ8yo/9VYTQjBC8tThdY1G/honS3HGsBkLpSAMlKYpILS73W7dLY+TWg24aUVRQjjYGAOfd3v9C5fPotTAo9VaA/9IKQUMsmazAWjnTqd75H6lSKJIKbqyRdwyYvWZHw4jsrvCuNYyL3pGhlNO7hG0+Va3f3xSsV2arVaCnBqpIsQeI3tIcI4hPwHssDhOWq7vpLXEaIdbNuRWWEO6j4GwdRLJlmu3QrDj0+oRnOd5nfwiAvwaGt7yyiVl2z3OkjgeuDpPa7XY1Ylg3hoXH6jM0jYD45hl+0NILvZgDYPnHRcSmFBRkly49q+16bntAjhFgHMWK8KKImWBX6eiKOq7cImKogjDIhiGq078U22NV6TbasLxwZ+IhDqB8A1j55eXkP/hQ8VWK4v83fffuc/1/W0VTsqL0jgWmNbl1JXXGL10bDXOeds9j6SUZ+5eSylfffFllRb88fOKzSQ4v3j8FIrXb2EYbh92x+4aQ7aPoYwkulUIwZxL0jfrDbzuEeEK1duImGRkBqgLnF4qEkLqDg4g20JIuSd7mE8f/U5+lSG4PXo8adH0GUSKy44vzqF5fzGfaV1ltXP9EX750yXudpLEMVy3FkfQRI/PTiQixoRmlm3m2UFBQUFBQb8gBSNbUFBQUFBQUFBQUFBQUFBQUNBnFEJIQUFBQUFBQUFBQUFBQUFBQUGfkWIMDepSysvLK/g3Td72VwSEUToQA2eMgDYYbGUqhGi3nAnu33Y3U2+vZvJHp92G9JPHTyC9XC3hnfeYmNdkhG9ZZw6YwhhrdTvwJnSr1YILcgpeIhemr2QfHR7BW9C/+epr416Y11kGm8WOJ2M4ptQ73qhnjCmyG26v2wVTxunpCdgGz05PhDM1HB0fIZujN4Cve6abz8EjtsQpLcMawgEhrgdyfC1J4CX507NHABr4i7/4beZ8ka1WB7g/62wNAIJ9oJM4SeByhwcHyD86OIidkW0wwPIeHJ9EjgnSaTfjpDpe/MmbKPHNbNe5/ckRzEM6EABJrdFSUVUuY23h6ipptnKXHvT74DM9Oj4EU1uWZWAk7PV60FXPzs5aznTQGxwCj6PRbidofsG+8GerHTwmIUSkgOPTgGaQRFG3Uw0XnU5n5QyDxweHU+dpHY5HU2dwWy6WwE4yxhhDTRMwVrTBlHRydnbmNuruHxwNDiozTqddT5znQ3LNwXxBTKaW8Z3sm067bd0Y0mw2u8DxMZYeT8ZEPI+QgrtxI44i6Dv1RhM4WUmSQB0KwcGp0Wo14fNamjbd8VprMAkaY4D1Iwl3KUmSmjNUNhrNmuubUiDLxmOH+Swt6pWk2jK57Dxm3/FwWKPZPDqtjHV5nkF9cs5x+N0yaaITR4BRKIqi1BkY0yQFM6OSkmlDzoNngYEgiuJ2pzKdxUlq3B7lWpf9PnKmGAcDHUMWEqk3zjmYByMlW62qvydxIp2ZiBMm4M/BydDjPQCN71qFe50mUa9ftfMiL+AbxhoYxyxjgtwvZE55/C8BbCkpZddxu6SUYB6kUCfr33iv/ZCMUhPfXkzSLgnOUmdyNLEaODOXNQbMpFobnlR5Nkb33dhijB0PK/wfZ6zeAJ6RePzkiSuXAN8953zQx3aYxvhQ+fkZ/mdqT50Ad4kxdnl5BV1pnSE+kk5dDJnSUNNld4B4yv3Tkj+ymJ7HfOmnSvEAAAmJSURBVPch9JQpmfIdHh7AlCyNYxjSrTaQJco/iiIsS7vXhclgJKntLygoKCgo6Jcjbq2lRndLEL9W4jPVlGhil+R5SfCCPvL5/2/vDpLbNs8ADAOgnOxyg6xzoJ6zB8o6N8im0zoEssgY+OAh5/WmjafzPCuOJFM/QBAEX0mf5+v3f/0t+lz//Pic3TP/Av51k3j7G1lzUMLtE9f93GcJXT7PqRJzFPScSTL+7Rg9tDxGKprXXtMcWDDfu87rtn8/ryuxT6N03QYfLHMIwutruPuF2HV7f14DAh5jPM4+9ugcifUc23i7xzdDc47xFnTdHufnnvO9+ryfbT7ul30c27fMN9/DvZuF9C2H8P3a9/W7lXH7OK7r0W3bzs2fx8CyPs7vfd+W6/ZjPdbr4/M7X3t0ezNdYh4zc8nbtoz7XK+34su3zUK61v8dXEHvz2ty+bqdSzrGqvf9eiwe23burrdvQ8YnjjeHz/3Lr8flGAfBvj+PL6NqPx6Px3no7s/rLfr6ODPBftzGfaxjnbeD+8xk6/K4HqP7st8sdT59zvu8H883Z8Zd12WOMb4O4+PtK8B9osk44uZT+5ytsxzXafw2sP16AI7jOFPpum23eS7Hi9POMU6Dx7o9r/tZnudzc10f839pmPunJqSt6zLm8hzbNS76WL4MW1nXdfk0h6Wca1j3K7V89b2+rG1sy7be9vN5DOzL8p/jfP4e54lgW5b5c4/lnAG0rvvcvd8wN2eZs6Vup7g5l+rFtqzL8jEWsc7H/bYTxz7fXz8Wt7WN2/N5sV9nyuvxXZflx8d8TF+f92/PgHWu5/V+eHk8LMuyHNel1I/jJX5eev0xt3Fs4ry9z5lN63Wp9k2zkN6cludlxv25My4/5rZfR9MyrgRvL80/zP9QZV5yjPv519iFP9yOh9frOW7nsevrb5s+tmUfS5hfc4zjYf4U5/Oc/TSO/20+B5/XKXr9+DhXsR/Pq7afH91MQwLg/4o/ZAMAAAAgSEgAAAAAhPX9HygAAAAAwLL4LSQAAAAAkoQEAAAAQJCQAAAAAAgSEgAAAABBQgIAAAAgSEgAAAAABAkJAAAAgCAhAQAAABAkJAAAAACChAQAAABAkJAAAAAACBISAAAAAEFCAgAAACBISAAAAAAECQkAAACAICEBAAAAECQkAAAAAIKEBAAAAECQkAAAAAAIEhIAAAAAQUICAAAAIEhIAAAAAAQJCQAAAIAgIQEAAAAQJCQAAAAAgoQEAAAAQJCQAAAAAAgSEgAAAABBQgIAAAAgSEgAAAAABAkJAAAAgCAhAQAAABAkJAAAAACChAQAAABAkJAAAAAACBISAAAAAEFCAgAAACBISAAAAAAECQkAAACAICEBAAAAECQkAAAAAIKEBAAAAECQkAAAAAAIEhIAAAAAQUICAAAAIEhIAAAAAAQJCQAAAIAgIQEAAAAQJCQAAAAAgoQEAAAAQJCQAAAAAAgSEgAAAABBQgIAAAAgSEgAAAAABAkJAAAAgCAhAQAAABAkJAAAAACChAQAAABAkJAAAAAACBISAAAAAEFCAgAAACBISAAAAAAECQkAAACAICEBAAAAECQkAAAAAIKEBAAAAECQkAAAAAAIEhIAAAAAQUICAAAAIEhIAAAAAAQJCQAAAIAgIQEAAAAQJCQAAAAAgoQEAAAAQJCQAAAAAAgSEgAAAABBQgIAAAAgSEgAAAAABAkJAAAAgCAhAQAAABAkJAAAAACChAQAAABAkJAAAAAACBISAAAAAEFCAgAAACBISAAAAAAECQkAAACAICEBAAAAECQkAAAAAIKEBAAAAECQkAAAAAAIEhIAAAAAQUICAAAAIEhIAAAAAAQJCQAAAIAgIQEAAAAQJCQAAAAAgoQEAAAAQJCQAAAAAAgSEgAAAABBQgIAAAAgSEgAAAAABAkJAAAAgCAhAQAAABAkJAAAAACChAQAAABAkJAAAAAACBISAAAAAEFCAgAAACBISAAAAAAECQkAAACAICEBAAAAECQkAAAAAIKEBAAAAECQkAAAAAAIEhIAAAAAQUICAAAAIEhIAAAAAAQJCQAAAIAgIQEAAAAQJCQAAAAAwsd56/fP+9+4DgAAAAC+Ez99+vq3jtbjOP669cs/f/ufrwcAAACA786v//j5q4/4QzYAAAAAgoQEAAAAQJCQAAAAAAgSEgAAAABBQgIAAAAgSEgAAAAABAkJAAAAgCAhAQAAABAkJAAAAACChAQAAABAkJAAAAAACBISAAAAAEFCAgAAACBISAAAAAAECQkAAACAICEBAAAAECQkAAAAAIKEBAAAAECQkAAAAAAIEhIAAAAAQUICAAAAIEhIAAAAAAQJCQAAAIAgIQEAAAAQJCQAAAAAgoQEAAAAQJCQAAAAAAgSEgAAAABBQgIAAAAgSEgAAAAABAkJAAAAgCAhAQAAABAkJAAAAACChAQAAABAkJAAAAAACBISAAAAAEFCAgAAACBISAAAAAAECQkAAACAICEBAAAAECQkAAAAAIKEBAAAAECQkAAAAAAIEhIAAAAAQUICAAAAIEhIAAAAAAQJCQAAAIAgIQEAAAAQJCQAAAAAgoQEAAAAQJCQAAAAAAgSEgAAAABBQgIAAAAgSEgAAAAABAkJAAAAgCAhAQAAABAkJAAAAACChAQAAABAkJAAAAAACBISAAAAAEFCAgAAACBISAAAAAAECQkAAACAICEBAAAAECQkAAAAAIKEBAAAAECQkAAAAAAIEhIAAAAAQUICAAAAIEhIAAAAAAQJCQAAAIAgIQEAAAAQJCQAAAAAgoQEAAAAQJCQAAAAAAgSEgAAAABBQgIAAAAgSEgAAAAABAkJAAAAgCAhAQAAABAkJAAAAACChAQAAABAkJAAAAAACBISAAAAAEFCAgAAACBISAAAAAAECQkAAACAICEBAAAAECQkAAAAAIKEBAAAAECQkAAAAAAIEhIAAAAAQUICAAAAIEhIAAAAAAQJCQAAAIAgIQEAAAAQJCQAAAAAgoQEAAAAQJCQAAAAAAgSEgAAAABBQgIAAAAgSEgAAAAABAkJAAAAgCAhAQAAABAkJAAAAACChAQAAABAkJAAAAAACBISAAAAAEFCAgAAACBISAAAAAAECQkAAACAICEBAAAAECQkAAAAAIKEBAAAAECQkAAAAAAIEhIAAAAAQUICAAAAIEhIAAAAAAQJCQAAAIAgIQEAAAAQ1uM4/rr1++f9710KAAAAAN+Dnz59/VtHfwK9MV3xT1B/HwAAAABJRU5ErkJggg==</xsl:text>
	</xsl:variable>
	 -->
	<xsl:template name="insert_Image-IEEE2-Logo-svg">
		<xsl:param name="color">000000</xsl:param>
		<svg xmlns="http://www.w3.org/2000/svg" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:cc="http://creativecommons.org/ns#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:svg="http://www.w3.org/2000/svg" id="svg65" height="63.240002mm" width="110.48mm" version="1.0">
			<defs id="defs9">
				<clipPath id="clipEmfPath1" clipPathUnits="userSpaceOnUse">
					<path id="path2" d="  M 0,0   L 0,0   L 0,240.77024   L 419.3077,240.77024   L 419.3077,0 "/>
				</clipPath>
				<clipPath id="clipEmfPath2" clipPathUnits="userSpaceOnUse">
					<path id="path5" d="  M 0,1.100321   L 0,1.100321   L 0,240.67021   L 418.40768,240.67021   L 418.40768,1.100321 "/>
				</clipPath>
				<pattern y="0" x="0" height="6" width="6" patternUnits="userSpaceOnUse" id="EMFhbasepattern"/>
			</defs>
			<path id="path11" d="  M 0,207.46052   L 0,207.46052   L 416.20764,207.46052   L 416.20764,239.86997   L 0,239.86997   L 0,207.46052   z " clip-path="url(#clipEmfPath2)" style="fill:#00adee;fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path13" d="  M 2.2000404,137.54012   L 2.2000404,137.54012   C 2.4000441,135.63957 2.5000459,134.23916 2.5000459,132.43863   L 2.9000533,132.23858   C 4.4000808,133.3389 6.4001175,134.53925 9.9001818,134.53925   C 13.000239,134.53925 14.800272,133.23887 14.800272,131.53837   C 14.800272,129.83788 13.000239,128.83758 10.000184,127.73726   L 8.4001543,127.13709   C 6.2001139,126.23683 2.3000422,124.53633 2.3000422,120.13505   C 2.3000422,115.63373 5.7001047,112.4328 12.600231,112.4328   C 16.300299,112.4328 18.50034,113.03297 20.200371,113.73318   L 20.400375,113.93324   C 20.300373,115.63373 20.100369,116.93411 20.100369,118.73464   L 19.700362,118.9347   C 17.000312,117.03414 14.400264,116.83408 13.500248,116.83408   C 10.800198,116.83408 9.4001726,118.03443 9.4001726,119.33481   C 9.4001726,121.13534 11.200206,121.73551 13.700252,122.63578   L 15.700288,123.33598   C 19.400356,124.63636 21.8004,126.837 21.8004,130.9382   C 21.8004,135.83963 17.700325,139.14059 10.800198,139.14059   C 6.4001175,139.14059 4.300079,138.44039 2.5000459,137.84021   L 2.2000404,137.54012   z " clip-path="url(#clipEmfPath1)" style="fill:#{$color};fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path15" d="  M 37.900696,138.64044   L 37.900696,138.64044   L 36.50067,138.64044   C 34.30063,138.64044 32.800602,138.64044 30.600562,138.74047   L 30.400558,138.54041   C 30.600562,132.43863 30.700564,128.13738 30.700564,122.0356   C 30.700564,120.43513 30.600562,118.53458 30.600562,117.63432   C 28.600525,117.63432 26.500487,117.73435 24.000441,117.83437   L 23.800437,117.63432   C 23.900439,115.93382 24.000441,114.73347 24.100443,113.133   L 24.400448,112.93294   L 37.700692,112.93294   C 40.200738,112.93294 42.000771,112.93294 44.500817,112.83292   L 44.700821,113.03297   C 44.600819,114.73347 44.500817,115.93382 44.400815,117.53429   L 44.200812,117.73435   C 41.90077,117.63432 40.200738,117.63432 37.900696,117.63432   C 37.800694,119.6349 37.800694,121.03531 37.800694,123.03589   C 37.800694,124.93645 37.900696,137.03998 38.1007,138.34036   L 37.900696,138.64044   z " clip-path="url(#clipEmfPath1)" style="fill:#{$color};fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path17" d="  M 55.301016,116.93411   L 55.301016,116.93411   C 54.801007,118.53458 54.400999,119.6349 51.900953,127.33715   C 52.900972,127.43718 54.000992,127.43718 55.00101,127.43718   C 56.001029,127.43718 57.001047,127.43718 58.101067,127.33715   C 58.101067,127.33715 56.001029,119.33481 55.301016,116.93411   L 55.301016,116.93411   z  M 68.401256,138.64044   L 68.401256,138.64044   L 67.101232,138.64044   C 64.901192,138.64044 63.401164,138.64044 61.301126,138.74047   L 61.00112,138.54041   C 60.401109,135.93966 59.9011,134.23916 59.201087,131.73843   C 58.401073,131.73843 56.301034,131.73843 54.901008,131.73843   C 53.400981,131.73843 51.300942,131.73843 50.400926,131.73843   C 49.700913,134.23916 49.100902,135.93966 48.400889,138.34036   L 48.200885,138.64044   L 41.800768,138.64044   L 41.600764,138.34036   C 45.300832,129.03764 47.800878,122.53575 51.100939,113.133   L 51.400944,112.93294   L 53.200977,112.93294   C 55.901027,112.93294 57.801062,112.93294 60.501111,112.83292   L 60.701115,113.03297   C 63.301163,122.0356 65.301199,128.33744 68.201253,137.34006   L 68.60126,138.34036   L 68.401256,138.64044   z " clip-path="url(#clipEmfPath1)" style="fill:#{$color};fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path19" d="  M 95.601756,138.64044   L 95.601756,138.64044   L 93.201712,138.64044   C 92.201693,138.64044 91.301677,138.64044 90.301659,138.74047   L 90.001653,138.54041   C 85.001561,131.83846 78.701445,124.03618 77.001414,121.13534   C 77.101416,122.63578 77.501423,134.63928 77.801429,138.34036   L 77.501423,138.64044   L 74.801374,138.64044   C 73.701354,138.64044 72.701335,138.64044 71.601315,138.74047   L 71.401311,138.54041   C 71.501313,135.7396 71.501313,133.03881 71.501313,130.33802   C 71.501313,124.63636 71.501313,118.83467 71.201308,113.133   L 71.401311,112.93294   L 73.701354,112.93294   C 74.801374,112.93294 77.001414,112.83292 78.101434,112.83292   L 78.40144,113.03297   C 79.101453,114.33335 86.801594,123.93615 90.301659,129.03764   C 90.101655,124.13621 89.801649,114.33335 89.701648,113.133   L 89.901651,112.93294   L 92.201693,112.93294   C 92.801704,112.93294 95.601756,112.83292 95.601756,112.83292   L 95.901761,113.03297   C 95.80176,117.2342 95.80176,121.53545 95.80176,125.73668   C 95.80176,127.5372 95.80176,134.13913 95.901761,138.44039   L 95.601756,138.64044   z " clip-path="url(#clipEmfPath1)" style="fill:#{$color};fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path21" d="  M 116.60214,132.03852   L 116.60214,132.03852   C 118.90218,129.83788 118.90218,125.83671 118.90218,125.23653   C 118.90218,122.7358 118.50218,120.53516 116.90215,119.13475   C 115.30212,117.53429 112.90207,117.53429 112.00206,117.53429   C 111.00204,117.53429 110.00202,117.53429 109.102,117.63432   C 109.002,119.53487 109.002,121.53545 109.002,123.53604   C 109.002,126.837 109.20201,131.33831 109.20201,133.93907   C 112.30206,133.93907 114.6021,133.83904 116.60214,132.03852   L 116.60214,132.03852   z  M 101.90187,138.44039   L 101.90187,138.44039   C 101.90187,135.33948 102.00187,131.6384 102.00187,129.03764   C 102.00187,123.7361 102.00187,118.43455 101.70187,113.133   L 101.90187,112.93294   C 106.30195,112.83292 108.60199,112.73289 112.60207,112.73289   C 116.50214,112.73289 119.8022,112.93294 122.70225,115.5337   C 125.80231,118.13446 126.40232,121.53545 126.40232,125.03648   C 126.40232,128.13738 125.90231,131.23828 123.90228,133.83904   C 120.80222,138.1403 115.60212,138.64044 109.90202,138.64044   L 102.10188,138.64044   L 101.90187,138.44039   z " clip-path="url(#clipEmfPath1)" style="fill:#{$color};fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path23" d="  M 140.20258,116.93411   L 140.20258,116.93411   C 139.70257,118.53458 139.30256,119.6349 136.70251,127.33715   C 137.80253,127.43718 138.90255,127.43718 139.90257,127.43718   C 140.90259,127.43718 141.90261,127.43718 142.90262,127.33715   C 142.90262,127.33715 140.90259,119.33481 140.20258,116.93411   L 140.20258,116.93411   z  M 153.20281,138.64044   L 153.20281,138.64044   L 151.90279,138.64044   C 149.80275,138.64044 148.30272,138.64044 146.20269,138.74047   L 145.90268,138.54041   C 145.30267,135.93966 144.80266,134.23916 144.10265,131.73843   C 143.30263,131.73843 141.20259,131.73843 139.80257,131.73843   C 138.30254,131.73843 136.1025,131.73843 135.30249,131.73843   C 134.50247,134.23916 134.00246,135.93966 133.30245,138.34036   L 133.00244,138.64044   L 126.70233,138.64044   L 126.50232,138.34036   C 130.20239,129.03764 132.70244,122.53575 136.0025,113.133   L 136.3025,112.93294   L 138.10254,112.93294   C 140.80259,112.93294 142.70262,112.93294 145.30267,112.83292   L 145.60267,113.03297   C 148.20272,122.0356 150.20276,128.33744 153.10281,137.34006   L 153.40282,138.34036   L 153.20281,138.64044   z " clip-path="url(#clipEmfPath1)" style="fill:#{$color};fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path25" d="  M 163.303,124.4363   L 163.303,124.4363   L 164.00301,124.4363   C 166.60306,124.4363 169.80312,123.83613 169.80312,120.53516   C 169.80312,117.33423 166.90307,117.2342 165.00303,117.2342   C 164.40302,117.2342 164.00301,117.2342 163.403,117.33423   C 163.303,118.9347 163.303,120.03502 163.303,121.53545   L 163.303,124.4363   L 163.303,124.4363   z  M 163.403,138.64044   L 163.403,138.64044   L 161.80297,138.64044   C 159.80294,138.64044 158.40291,138.64044 156.50287,138.74047   L 156.20287,138.54041   C 156.30287,134.93936 156.40287,132.63869 156.40287,130.43805   C 156.40287,124.03618 156.30287,119.53487 156.00287,113.133   L 156.30287,112.93294   L 158.50291,112.93294   C 160.60295,112.93294 164.60302,112.83292 167.50308,112.83292   C 169.50311,112.83292 177.00325,113.03297 177.00325,120.13505   C 177.00325,122.23566 176.40324,124.53633 173.40318,126.33685   C 172.60317,126.837 171.70315,127.03706 171.40315,127.23712   C 173.00318,129.53779 177.30326,135.7396 179.30329,138.1403   L 179.10329,138.54041   C 176.30324,138.54041 174.3032,138.64044 171.50315,138.74047   L 171.20314,138.64044   C 170.80314,137.84021 168.20309,132.93878 165.70304,129.2377   L 165.30304,128.63753   C 164.50302,128.63753 163.70301,128.63753 163.303,128.63753   L 163.303,130.33802   C 163.303,133.23887 163.403,135.43951 163.70301,138.34036   L 163.403,138.64044   z " clip-path="url(#clipEmfPath1)" style="fill:#{$color};fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path27" d="  M 197.30362,132.03852   L 197.30362,132.03852   C 199.50366,129.83788 199.50366,125.83671 199.50366,125.23653   C 199.50366,122.7358 199.10366,120.53516 197.60363,119.13475   C 195.9036,117.53429 193.60356,117.53429 192.60354,117.53429   C 191.60352,117.53429 190.7035,117.53429 189.70348,117.63432   C 189.70348,119.53487 189.70348,121.53545 189.70348,123.53604   C 189.70348,126.837 189.80349,131.33831 189.80349,133.93907   C 192.90354,133.93907 195.30359,133.83904 197.30362,132.03852   L 197.30362,132.03852   z  M 182.50335,138.44039   L 182.50335,138.44039   C 182.50335,135.33948 182.60335,131.6384 182.60335,129.03764   C 182.60335,123.7361 182.60335,118.43455 182.30335,113.133   L 182.60335,112.93294   C 186.90343,112.83292 189.20348,112.73289 193.30355,112.73289   C 197.20362,112.73289 200.40368,112.93294 203.40374,115.5337   C 206.40379,118.13446 207.0038,121.53545 207.0038,125.03648   C 207.0038,128.13738 206.50379,131.23828 204.60376,133.83904   C 201.4037,138.1403 196.2036,138.64044 190.5035,138.64044   L 182.80336,138.64044   L 182.50335,138.44039   z " clip-path="url(#clipEmfPath1)" style="fill:#{$color};fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path29" d="  M 210.60387,137.54012   L 210.60387,137.54012   C 210.70387,135.63957 210.80387,134.23916 210.90387,132.43863   L 211.20388,132.23858   C 212.80391,133.3389 214.80395,134.53925 218.30401,134.53925   C 221.30406,134.53925 223.1041,133.23887 223.1041,131.53837   C 223.1041,129.83788 221.30406,128.83758 218.30401,127.73726   L 216.80398,127.13709   C 214.60394,126.23683 210.70387,124.53633 210.70387,120.13505   C 210.70387,115.63373 214.00393,112.4328 220.90406,112.4328   C 224.70413,112.4328 226.80417,113.03297 228.6042,113.73318   L 228.8042,113.93324   C 228.6042,115.63373 228.5042,116.93411 228.40419,118.73464   L 228.10419,118.9347   C 225.40414,117.03414 222.80409,116.83408 221.80407,116.83408   C 219.20403,116.83408 217.804,118.03443 217.804,119.33481   C 217.804,121.13534 219.60403,121.73551 222.10408,122.63578   L 224.10412,123.33598   C 227.70418,124.63636 230.20423,126.837 230.20423,130.9382   C 230.20423,135.83963 226.10415,139.14059 219.20403,139.14059   C 214.80395,139.14059 212.70391,138.44039 210.80387,137.84021   L 210.60387,137.54012   z " clip-path="url(#clipEmfPath1)" style="fill:#{$color};fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path31" d="  M 14.400264,151.44418   L 14.400264,151.44418   C 13.900255,153.04465 13.500248,154.04494 10.9002,161.84721   C 12.00022,161.84721 13.000239,161.84721 14.100259,161.84721   C 15.100277,161.84721 16.100296,161.84721 17.200316,161.84721   C 17.200316,161.84721 15.100277,153.84488 14.400264,151.44418   L 14.400264,151.44418   z  M 27.700509,173.05048   L 27.700509,173.05048   L 26.300483,173.05048   C 24.100443,173.05048 22.700417,173.05048 20.500377,173.15051   L 20.200371,172.95045   C 19.500358,170.44972 19.100351,168.74923 18.400338,166.2485   C 17.500321,166.2485 15.400283,166.14847 14.000257,166.14847   C 12.50023,166.14847 10.300189,166.2485 9.4001726,166.2485   C 8.600158,168.6492 8.1001488,170.34969 7.4001359,172.85042   L 7.1001304,173.05048   L 0.60001102,173.05048   L 0.50000918,172.85042   C 4.2000771,163.54771 6.8001249,157.04581 10.100186,147.64307   L 10.400191,147.44301   L 12.300226,147.44301   C 15.000276,147.44301 16.90031,147.34298 19.60036,147.34298   L 19.900366,147.54304   C 22.600415,156.44564 24.600452,162.74748 27.600507,171.7501   L 27.900512,172.75039   L 27.700509,173.05048   z " clip-path="url(#clipEmfPath1)" style="fill:#{$color};fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path33" d="  M 29.900549,171.95016   L 29.900549,171.95016   C 30.100553,170.04961 30.200555,168.74923 30.200555,166.84867   L 30.600562,166.74864   C 32.200591,167.74894 34.200628,168.94929 37.800694,168.94929   C 40.900751,168.94929 42.700784,167.74894 42.700784,165.94841   C 42.700784,164.34794 40.900751,163.34765 37.800694,162.1473   L 36.300667,161.54713   C 34.000624,160.74689 30.000551,159.0464 30.000551,154.54508   C 30.000551,150.04377 33.400613,146.84284 40.500744,146.84284   C 44.300814,146.84284 46.500854,147.54304 48.300887,148.24325   L 48.500891,148.4433   C 48.300887,150.1438 48.200885,151.44418 48.100883,153.2447   L 47.700876,153.34473   C 45.000827,151.54421 42.300777,151.34415 41.40076,151.34415   C 38.700711,151.34415 37.200683,152.44447 37.200683,153.84488   C 37.200683,155.54538 39.100718,156.24558 41.700766,157.14584   L 43.600801,157.84605   C 47.400871,159.14643 49.900917,161.34707 49.900917,165.34824   C 49.900917,170.34969 45.700839,173.65066 38.700711,173.65066   C 34.200628,173.65066 32.10059,172.85042 30.200555,172.25025   L 29.900549,171.95016   z " clip-path="url(#clipEmfPath1)" style="fill:#{$color};fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path35" d="  M 53.200977,171.95016   L 53.200977,171.95016   C 53.400981,170.04961 53.500983,168.74923 53.500983,166.84867   L 53.90099,166.74864   C 55.501019,167.74894 57.501056,168.94929 61.101122,168.94929   C 64.201179,168.94929 66.001212,167.74894 66.001212,165.94841   C 66.001212,164.34794 64.201179,163.34765 61.101122,162.1473   L 59.601095,161.54713   C 57.301052,160.74689 53.400981,159.0464 53.400981,154.54508   C 53.400981,150.04377 56.801043,146.84284 63.801172,146.84284   C 67.601242,146.84284 69.801282,147.54304 71.601315,148.24325   L 71.801319,148.4433   C 71.601315,150.1438 71.501313,151.44418 71.401311,153.2447   L 71.001304,153.34473   C 68.301254,151.54421 65.601205,151.34415 64.701188,151.34415   C 62.001139,151.34415 60.501111,152.44447 60.501111,153.84488   C 60.501111,155.54538 62.401146,156.24558 65.001194,157.14584   L 67.001231,157.84605   C 70.701299,159.14643 73.201344,161.34707 73.201344,165.34824   C 73.201344,170.34969 69.001267,173.65066 62.001139,173.65066   C 57.501056,173.65066 55.401018,172.85042 53.500983,172.25025   L 53.200977,171.95016   z " clip-path="url(#clipEmfPath1)" style="fill:#{$color};fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path37" d="  M 89.001635,151.34415   L 89.001635,151.34415   C 84.501552,151.34415 82.901523,155.14526 82.901523,159.7466   C 82.901523,162.54742 83.101526,168.94929 89.001635,168.94929   C 95.101747,168.94929 95.101747,162.94753 95.101747,160.04669   C 95.101747,158.04611 95.001745,151.34415 89.001635,151.34415   L 89.001635,151.34415   z  M 89.001635,173.65066   L 89.001635,173.65066   C 80.201473,173.65066 75.201381,168.74923 75.201381,160.34678   C 75.201381,152.64453 79.701464,146.84284 89.201638,146.84284   C 99.301824,146.84284 102.80189,152.94462 102.80189,160.14672   C 102.80189,165.54829 100.40184,173.65066 89.001635,173.65066   z " clip-path="url(#clipEmfPath1)" style="fill:#{$color};fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path39" d="  M 127.10233,172.35028   L 127.10233,172.35028   C 125.70231,172.85042 123.30226,173.65066 119.9022,173.65066   C 110.60203,173.65066 105.10193,168.04902 105.10193,160.34678   C 105.10193,152.84459 110.10202,146.84284 119.50219,146.84284   C 123.20226,146.84284 125.70231,147.64307 127.20234,148.14322   L 127.40234,148.34327   C 127.20234,150.24383 127.10233,151.54421 127.00233,153.34473   L 126.70233,153.44476   C 125.50231,152.64453 123.60227,151.64424 120.80222,151.64424   C 114.70211,151.64424 112.80207,156.34561 112.80207,160.24675   C 112.80207,166.54859 117.40216,168.54917 120.90222,168.54917   C 124.30228,168.54917 126.70233,166.9487 127.30234,166.54859   L 127.60234,166.74864   C 127.50234,168.74923 127.40234,170.14964 127.30234,172.15022   L 127.10233,172.35028   z " clip-path="url(#clipEmfPath1)" style="fill:#{$color};fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path41" d="  M 139.40256,173.05048   L 139.40256,173.05048   L 136.0025,173.05048   C 135.30249,173.05048 132.10243,173.15051 132.10243,173.15051   L 131.90242,172.95045   C 132.00242,169.54946 132.10243,166.2485 132.10243,162.84751   L 132.10243,160.34678   C 132.10243,156.04552 132.00242,151.8443 131.70242,147.64307   L 131.90242,147.44301   L 134.80248,147.44301   C 136.1025,147.44301 138.50254,147.34298 139.40256,147.34298   L 139.60256,147.54304   C 139.40256,152.44447 139.40256,157.54596 139.40256,162.54742   C 139.40256,165.94841 139.40256,169.44943 139.70257,172.85042   L 139.40256,173.05048   z " clip-path="url(#clipEmfPath1)" style="fill:#{$color};fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path43" d="  M 156.20287,151.44418   L 156.20287,151.44418   C 155.70286,153.04465 155.30285,154.04494 152.7028,161.84721   C 153.80282,161.84721 154.80284,161.84721 155.90286,161.84721   C 156.90288,161.84721 157.9029,161.84721 159.00292,161.84721   C 159.00292,161.84721 156.90288,153.84488 156.20287,151.44418   L 156.20287,151.44418   z  M 169.50311,173.05048   L 169.50311,173.05048   L 168.20309,173.05048   C 166.00305,173.05048 164.50302,173.05048 162.30298,173.15051   L 162.00298,172.95045   C 161.30296,170.44972 160.90296,168.74923 160.20294,166.2485   C 159.30293,166.2485 157.20289,166.14847 155.80286,166.14847   C 154.30283,166.14847 152.10279,166.2485 151.20278,166.2485   C 150.40276,168.6492 149.90275,170.34969 149.20274,172.85042   L 148.90273,173.05048   L 142.40262,173.05048   L 142.30261,172.85042   C 146.00268,163.54771 148.60273,157.04581 151.90279,147.64307   L 152.2028,147.44301   L 154.10283,147.44301   C 156.80288,147.44301 158.70291,147.34298 161.40296,147.34298   L 161.70297,147.54304   C 164.40302,156.44564 166.40306,162.74748 169.40311,171.7501   L 169.70312,172.75039   L 169.50311,173.05048   z " clip-path="url(#clipEmfPath1)" style="fill:#{$color};fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path45" d="  M 181.70334,173.05048   L 181.70334,173.05048   L 180.30331,173.05048   C 178.10327,173.05048 176.50324,173.05048 174.3032,173.15051   L 174.1032,172.95045   C 174.3032,166.84867 174.4032,162.54742 174.4032,156.44564   C 174.4032,154.84517 174.4032,153.04465 174.4032,152.14438   C 172.30316,152.14438 170.10312,152.24441 167.70308,152.24441   L 167.40307,152.04435   C 167.50308,150.44389 167.70308,149.14351 167.70308,147.64307   L 168.00309,147.34298   L 181.60334,147.34298   C 184.10338,147.34298 186.00342,147.34298 188.50346,147.34298   L 188.70347,147.54304   C 188.60346,149.14351 188.50346,150.34386 188.40346,152.04435   L 188.20346,152.24441   C 185.80341,152.14438 184.10338,152.04435 181.80334,152.04435   C 181.70334,154.04494 181.60334,155.54538 181.60334,157.54596   C 181.60334,159.34648 181.80334,171.55004 181.90334,172.85042   L 181.70334,173.05048   z " clip-path="url(#clipEmfPath1)" style="fill:#{$color};fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path47" d="  M 200.00367,173.05048   L 200.00367,173.05048   L 196.60361,173.05048   C 195.8036,173.05048 192.60354,173.15051 192.60354,173.15051   L 192.40353,172.95045   C 192.50354,169.54946 192.60354,166.2485 192.60354,162.84751   L 192.60354,160.34678   C 192.60354,156.04552 192.50354,151.8443 192.20353,147.64307   L 192.40353,147.44301   L 195.30359,147.44301   C 196.70361,147.44301 199.10366,147.34298 199.90367,147.34298   L 200.10368,147.54304   C 200.00367,152.44447 199.90367,157.54596 199.90367,162.54742   C 199.90367,165.94841 200.00367,169.44943 200.20368,172.85042   L 200.00367,173.05048   z " clip-path="url(#clipEmfPath1)" style="fill:#{$color};fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path49" d="  M 217.50399,151.34415   L 217.50399,151.34415   C 213.00391,151.34415 211.40388,155.14526 211.40388,159.7466   C 211.40388,162.54742 211.50388,168.94929 217.50399,168.94929   C 223.5041,168.94929 223.5041,162.94753 223.5041,160.04669   C 223.5041,158.04611 223.4041,151.34415 217.50399,151.34415   L 217.50399,151.34415   z  M 217.50399,173.65066   L 217.50399,173.65066   C 208.60383,173.65066 203.60374,168.74923 203.60374,160.34678   C 203.60374,152.64453 208.10382,146.84284 217.604,146.84284   C 227.70418,146.84284 231.30425,152.94462 231.30425,160.14672   C 231.30425,165.54829 228.8042,173.65066 217.50399,173.65066   z " clip-path="url(#clipEmfPath1)" style="fill:#{$color};fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path51" d="  M 259.20476,173.05048   L 259.20476,173.05048   L 256.60471,173.05048   C 255.7047,173.05048 254.70468,173.15051 253.70466,173.15051   L 253.40465,172.95045   C 248.30456,166.2485 242.00444,158.44622 240.20441,155.54538   C 240.30441,157.04581 240.70442,169.14934 241.00443,172.85042   L 240.70442,173.05048   L 238.00437,173.05048   C 236.90435,173.05048 235.80433,173.15051 234.70431,173.15051   L 234.50431,172.95045   C 234.60431,170.24967 234.60431,167.54888 234.60431,164.84809   C 234.60431,159.0464 234.60431,153.34473 234.3043,147.64307   L 234.50431,147.44301   L 236.80435,147.44301   C 237.90437,147.44301 240.10441,147.34298 241.30443,147.34298   L 241.60444,147.44301   C 242.40445,148.74339 250.10459,158.34619 253.70466,163.54771   C 253.50466,158.64628 253.20465,148.84342 253.10465,147.64307   L 253.30465,147.44301   L 255.60469,147.44301   C 256.30471,147.44301 259.20476,147.34298 259.20476,147.34298   L 259.40476,147.54304   C 259.40476,151.74427 259.30476,155.94549 259.30476,160.24675   C 259.30476,162.04727 259.30476,168.6492 259.40476,172.85042   L 259.20476,173.05048   z " clip-path="url(#clipEmfPath1)" style="fill:#{$color};fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path53" d="  M 374.30687,25.107324   L 374.30687,25.107324   L 353.30649,79.223111   L 331.40609,79.223111   L 364.10669,2.4007003   L 384.80707,2.4007003   L 417.60767,79.223111   L 395.20726,79.223111   L 374.30687,25.107324   z " clip-path="url(#clipEmfPath1)" style="fill:#{$color};fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path55" d="  M 24.600452,79.123082   L 24.600452,79.123082   L 14.70027,79.123082   C 12.300226,79.123082 3.0000551,79.423169 3.0000551,79.423169   L 2.4000441,78.822994   C 2.8000514,68.720047 3.0000551,58.717129 3.0000551,48.614182   L 3.0000551,41.011964   C 3.0000551,28.408287 2.9000533,15.704581 1.9000349,3.2009338   L 2.5000459,2.5007295   L 10.9002,2.5007295   C 14.900274,2.5007295 21.900402,2.3006711 24.50045,2.200642   L 25.000459,2.8008171   C 24.600452,17.705165 24.400448,32.709542 24.400448,47.61389   C 24.400448,57.916895 24.600452,68.31993 25.200463,78.522907   L 24.600452,79.123082   z " clip-path="url(#clipEmfPath1)" style="fill:#{$color};fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path57" d="  M 94.001726,65.219026   L 94.001726,65.219026   C 93.601719,69.720339 93.401715,74.321681 93.10171,78.522907   L 92.201693,79.123082   C 74.401366,79.123082 56.60104,79.223111 38.700711,79.32314   L 38.1007,78.622936   C 38.600709,68.620018 38.700711,58.6171 38.700711,48.514152   L 38.700711,26.007587   C 38.700711,18.30534 38.600709,10.703122 37.900696,3.2009338   L 38.600709,2.5007295   C 51.800951,2.5007295 83.901541,2.3006711 91.901688,2.3006711   L 92.501699,2.9008462   C 92.201693,7.4021593 91.801686,11.303297 91.701684,15.504523   L 90.90167,16.204727   C 80.501479,16.004669 70.201289,15.804611 59.801098,15.804611   C 59.801098,17.905223 59.701097,20.80607 59.701097,23.906974   C 59.701097,27.307966 59.701097,30.808988 59.801098,33.109659   C 69.70128,33.109659 79.401458,33.00963 89.101636,32.709542   L 89.901651,33.409746   C 89.501644,37.510943 89.201638,41.612139 89.001635,45.713335   L 88.301622,46.313511   C 70.401293,46.213481 59.801098,46.213481 59.801098,46.213481   C 59.801098,52.615349 60.001102,58.917187 60.101104,65.219026   C 71.30131,65.219026 82.301512,65.018967 93.401715,64.518821   L 94.001726,65.219026   z " clip-path="url(#clipEmfPath1)" style="fill:#{$color};fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path59" d="  M 162.30298,65.219026   L 162.30298,65.219026   C 161.90297,69.720339 161.60297,74.321681 161.40296,78.522907   L 160.40295,79.123082   C 142.70262,79.123082 124.80229,79.223111 107.00197,79.32314   L 106.40195,78.622936   C 106.90196,68.620018 107.00197,58.6171 107.00197,48.514152   L 107.00197,26.007587   C 107.00197,18.30534 106.90196,10.703122 106.10195,3.2009338   L 106.90196,2.5007295   C 120.10221,2.5007295 152.2028,2.3006711 160.20294,2.3006711   L 160.80295,2.9008462   C 160.40295,7.4021593 160.10294,11.303297 159.90294,15.504523   L 159.20292,16.204727   C 148.80273,16.004669 138.40254,15.804611 128.10235,15.804611   C 128.10235,17.905223 128.00235,20.80607 128.00235,23.906974   C 128.00235,27.307966 128.00235,30.808988 128.10235,33.109659   C 138.00253,33.109659 147.70271,33.00963 157.40289,32.709542   L 158.1029,33.409746   C 157.8029,37.510943 157.50289,41.612139 157.30289,45.713335   L 156.50287,46.313511   C 138.70255,46.213481 128.10235,46.213481 128.10235,46.213481   C 128.10235,52.615349 128.20235,58.917187 128.40236,65.219026   C 139.50256,65.219026 150.60277,65.018967 161.60297,64.518821   L 162.30298,65.219026   z " clip-path="url(#clipEmfPath1)" style="fill:#{$color};fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path61" d="  M 230.50423,65.219026   L 230.50423,65.219026   C 230.20423,69.720339 229.90422,74.321681 229.70422,78.522907   L 228.7042,79.123082   C 211.00388,79.123082 193.10355,79.223111 175.30322,79.32314   L 174.60321,78.622936   C 175.10322,68.620018 175.30322,58.6171 175.30322,48.514152   L 175.30322,26.007587   C 175.30322,18.30534 175.10322,10.703122 174.4032,3.2009338   L 175.10322,2.5007295   C 188.40346,2.5007295 220.40405,2.3006711 228.5042,2.3006711   L 229.10421,2.9008462   C 228.7042,7.4021593 228.30419,11.303297 228.20419,15.504523   L 227.50418,16.204727   C 217.00399,16.004669 206.7038,15.804611 196.40361,15.804611   C 196.40361,17.905223 196.30361,20.80607 196.30361,23.906974   C 196.30361,27.307966 196.30361,30.808988 196.40361,33.109659   C 206.20379,33.109659 216.00397,33.00963 225.70415,32.709542   L 226.40416,33.409746   C 226.00415,37.510943 225.80415,41.612139 225.50414,45.713335   L 224.80413,46.313511   C 207.0038,46.213481 196.40361,46.213481 196.40361,46.213481   C 196.40361,52.615349 196.50361,58.917187 196.60361,65.219026   C 207.80382,65.219026 218.90402,65.018967 229.90422,64.518821   L 230.50423,65.219026   z " clip-path="url(#clipEmfPath1)" style="fill:#{$color};fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path63" d="  M 275.70506,75.221944   L 275.70506,75.221944   C 276.20507,69.62031 276.40508,65.619142 276.50508,60.117537   L 277.6051,59.717421   C 282.20518,62.818325 288.10529,66.419376 298.50548,66.419376   C 307.50565,66.419376 312.80575,62.618267 312.80575,57.516779   C 312.80575,52.51532 307.50565,49.714503 298.60548,46.213481   L 294.1054,44.512985   C 287.50528,41.912227 276.10507,36.910768 276.10507,23.806945   C 276.10507,10.603093 285.90525,1.100321 306.30563,1.100321   C 317.50583,1.100321 323.80595,3.0008754 329.00604,5.1014882   L 329.60605,5.7016633   C 329.10604,10.803151 328.70604,14.60426 328.50603,19.905807   L 327.40601,20.305924   C 319.60587,14.804319 311.70572,14.304173 309.00568,14.304173   C 301.10553,14.304173 296.90545,17.605136 296.90545,21.606303   C 296.90545,26.707791 302.30555,28.608346 309.80569,31.309133   L 315.6058,33.409746   C 326.40599,37.210855 333.80613,43.812781 333.80613,55.716253   C 333.80613,70.320514 321.60591,80.023344 301.10553,80.023344   C 288.20529,80.023344 282.00518,77.822702 276.40508,76.022177   L 275.70506,75.221944   z " clip-path="url(#clipEmfPath1)" style="fill:#{$color};fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
		</svg>
	</xsl:template>
	
	<xsl:variable name="Image-FB-Logo">
		<xsl:text>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</xsl:text>
	</xsl:variable>
	
	<xsl:variable name="Image-LinkedIn-Logo">
		<xsl:text>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</xsl:text>
	</xsl:variable>
	
	<xsl:variable name="Image-Twitter-Logo">
		<xsl:text>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</xsl:text>
	</xsl:variable>

	<xsl:variable name="Image-Beyond-Logo">
		<xsl:text>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</xsl:text>
	</xsl:variable>
	
	<xsl:variable name="Image-Youtube-Logo">
		<xsl:text>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</xsl:text>
	</xsl:variable>
	
	<xsl:variable name="Image-Blue-Boxes-svg">
		<svg xmlns="http://www.w3.org/2000/svg" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:cc="http://creativecommons.org/ns#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:svg="http://www.w3.org/2000/svg" id="svg59" height="164.32001mm" width="112.51mm" version="1.0">
			<defs id="defs9">
				<clipPath id="clipEmfPath1" clipPathUnits="userSpaceOnUse">
					<path id="path2" d="  M 0,0   L 0,0   L 0,622.80225   L 426.98689,622.80225   L 426.98689,0 "/>
				</clipPath>
				<clipPath id="clipEmfPath2" clipPathUnits="userSpaceOnUse">
					<path id="path5" d="  M 0,0   L 0,0   L 0,622.70225   L 426.98689,622.70225   L 426.98689,0 "/>
				</clipPath>
				<pattern y="0" x="0" height="6" width="6" patternUnits="userSpaceOnUse" id="EMFhbasepattern"/>
			</defs>
			<path id="path11" d="  M 0,-0.20000072   L 0,-0.20000072   L 106.6217,-0.20000072   L 106.6217,17.500063   L 0,17.500063   L 0,-0.20000072   z " clip-path="url(#clipEmfPath2)" style="fill:#63cbd7;fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path13" d="  M 0,88.60032   L 0,88.60032   L 106.6217,88.60032   L 106.6217,230.80083   L 0,230.80083   L 0,88.60032   z " clip-path="url(#clipEmfPath2)" style="fill:#63cbd7;fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path15" d="  M 0,266.40096   L 0,266.40096   L 106.6217,266.40096   L 106.6217,284.20103   L 0,284.20103   L 0,266.40096   z " clip-path="url(#clipEmfPath2)" style="fill:#a1a2a3;fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path17" d="  M 0,408.60148   L 0,408.60148   L 106.6217,408.60148   L 106.6217,426.40154   L 0,426.40154   L 0,408.60148   z " clip-path="url(#clipEmfPath2)" style="fill:#63cbd7;fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path19" d="  M 106.6217,-0.20000072   L 106.6217,-0.20000072   L 213.34341,-0.20000072   L 213.34341,17.500063   L 106.6217,17.500063   L 106.6217,-0.20000072   z " clip-path="url(#clipEmfPath1)" style="fill:#00adee;fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path21" d="  M 106.6217,70.800256   L 106.6217,70.800256   L 213.34341,70.800256   L 213.34341,88.60032   L 106.6217,88.60032   L 106.6217,70.800256   z " clip-path="url(#clipEmfPath2)" style="fill:#63cbd7;fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path23" d="  M 106.6217,88.60032   L 106.6217,88.60032   L 106.6217,284.20103   L 0,284.20103   L 0,373.10135   L 106.6217,373.10135   L 106.6217,337.50122   L 213.34341,337.50122   L 213.34341,88.60032   L 106.6217,88.60032   z " clip-path="url(#clipEmfPath2)" style="fill:#00adee;fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path25" d="  M 106.6217,17.500063   L 106.6217,17.500063   L 213.34341,17.500063   L 213.34341,35.300128   L 106.6217,35.300128   L 106.6217,17.500063   z " clip-path="url(#clipEmfPath2)" style="fill:#0d69a4;fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path27" d="  M 213.34341,53.100192   L 213.34341,53.100192   L 213.34341,35.300128   L 106.6217,35.300128   L 106.6217,17.500063   L 0,17.500063   L 0,53.100192   L 213.34341,53.100192   z " clip-path="url(#clipEmfPath2)" style="fill:#00adee;fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path29" d="  M 106.6217,53.100192   L 106.6217,53.100192   L 213.34341,53.100192   L 213.34341,70.800256   L 106.6217,70.800256   L 106.6217,53.100192   z " clip-path="url(#clipEmfPath1)" style="fill:#a1a2a3;fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path31" d="  M 213.34341,-0.20000072   L 213.34341,-0.20000072   L 319.96511,-0.20000072   L 319.96511,35.300128   L 213.34341,35.300128   L 213.34341,-0.20000072   z " clip-path="url(#clipEmfPath1)" style="fill:#a1a2a3;fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path33" d="  M 213.34341,248.6009   L 213.34341,248.6009   L 319.96511,248.6009   L 319.96511,266.40096   L 213.34341,266.40096   L 213.34341,248.6009   z " clip-path="url(#clipEmfPath1)" style="fill:#a1a2a3;fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path35" d="  M 213.34341,337.50122   L 213.34341,337.50122   L 319.96511,337.50122   L 319.96511,462.00167   L 213.34341,462.00167   L 213.34341,337.50122   z " clip-path="url(#clipEmfPath1)" style="fill:#0d69a4;fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path37" d="  M 213.34341,479.70174   L 213.34341,479.70174   L 319.96511,479.70174   L 319.96511,497.5018   L 213.34341,497.5018   L 213.34341,479.70174   z " clip-path="url(#clipEmfPath1)" style="fill:#a1a2a3;fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path39" d="  M 319.96511,-0.20000072   L 319.96511,-0.20000072   L 426.68683,-0.20000072   L 426.68683,159.70058   L 319.96511,159.70058   L 319.96511,-0.20000072   z " clip-path="url(#clipEmfPath1)" style="fill:#00adee;fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path41" d="  M 319.96511,195.30071   L 319.96511,195.30071   L 319.96511,35.300128   L 213.34341,35.300128   L 213.34341,248.6009   L 319.96511,248.6009   L 319.96511,213.10077   L 426.68683,213.10077   L 426.68683,195.30071   L 319.96511,195.30071   z " clip-path="url(#clipEmfPath1)" style="fill:#0d69a4;fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path43" d="  M 319.96511,213.10077   L 319.96511,213.10077   L 426.68683,213.10077   L 426.68683,230.80083   L 319.96511,230.80083   L 319.96511,213.10077   z " clip-path="url(#clipEmfPath1)" style="fill:#a1a2a3;fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path45" d="  M 319.96511,230.80083   L 319.96511,230.80083   L 426.68683,230.80083   L 426.68683,248.6009   L 319.96511,248.6009   L 319.96511,230.80083   z " clip-path="url(#clipEmfPath1)" style="fill:#00adee;fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path47" d="  M 319.96511,266.40096   L 319.96511,266.40096   L 426.68683,266.40096   L 426.68683,337.50122   L 319.96511,337.50122   L 319.96511,266.40096   z " clip-path="url(#clipEmfPath1)" style="fill:#63cbd7;fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path49" d="  M 213.34341,462.00167   L 213.34341,462.00167   L 213.34341,479.70174   L 319.96511,479.70174   L 319.96511,568.60206   L 426.68683,568.60206   L 426.68683,462.00167   L 213.34341,462.00167   z " clip-path="url(#clipEmfPath1)" style="fill:#00adee;fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path51" d="  M 106.6217,479.70174   L 106.6217,479.70174   L 213.34341,479.70174   L 213.34341,533.10193   L 106.6217,533.10193   L 106.6217,479.70174   z " clip-path="url(#clipEmfPath1)" style="fill:#63cbd7;fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path53" d="  M 106.6217,444.20161   L 106.6217,444.20161   L 213.34341,444.20161   L 213.34341,462.00167   L 106.6217,462.00167   L 106.6217,444.20161   z " clip-path="url(#clipEmfPath2)" style="fill:#a1a2a3;fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path55" d="  M 106.6217,604.20219   L 106.6217,604.20219   L 213.34341,604.20219   L 213.34341,621.90225   L 106.6217,621.90225   L 106.6217,604.20219   z " clip-path="url(#clipEmfPath2)" style="fill:#00adee;fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
			<path id="path57" d="  M 0,53.100192   L 0,53.100192   L 106.6217,53.100192   L 106.6217,88.60032   L 0,88.60032   L 0,53.100192   z " clip-path="url(#clipEmfPath2)" style="fill:#0d69a4;fill-rule:nonzero;fill-opacity:1;stroke:none;"/>
		</svg>
	</xsl:variable>
	
	<xsl:template name="insertImageBoxSVG">
		<xsl:param name="color"/>
		<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100" viewBox="0 0 100 100">
			<rect x="0" y="1" width="100" height="100" fill="{$color}"/>
		</svg>
	</xsl:template>
	
	
	<!-- =============================== -->
	<!-- Cover Pages -->
	<!-- =============================== -->
	<xsl:template name="insertCoverPage_Standard">
		<xsl:param name="title_intro"/>
		<xsl:param name="title_main"/>
		<xsl:param name="society"/>
		<xsl:param name="committee"/>
		<xsl:param name="standard_number"/>
		<xsl:param name="history"/>
		
		<fo:page-sequence master-reference="cover-and-back-page-standard" force-page-count="no-force">
		
			<fo:static-content flow-name="header" role="artifact">
				<fo:block-container position="absolute" left="14mm" top="17.8mm">
					<fo:block font-size="1">
						<fo:instream-foreign-object content-width="32.9mm" content-height="scale-to-fit" scaling="uniform" fox:alt-text="Image IEEE Logo">
							<xsl:call-template name="insert_Image-IEEE2-Logo-svg"/>
						</fo:instream-foreign-object>
					</fo:block>
				</fo:block-container>
				<fo:block-container position="absolute" left="14.6mm" top="259mm">
					<fo:block font-size="1">
						<fo:instream-foreign-object content-width="20.8mm" content-height="scale-to-fit" scaling="uniform" fox:alt-text="Image IEEE Logo">							
							<xsl:copy-of select="$Image-IEEE-Logo-black-svg"/>
						</fo:instream-foreign-object>
					</fo:block>
				</fo:block-container>
				<fo:block-container position="absolute" left="191mm" top="-1mm">
					<fo:block font-size="1">
						<fo:instream-foreign-object content-width="26mm" content-height="scale-to-fit" scaling="uniform" fox:alt-text="Image Boxes">
							<xsl:copy-of select="$Image-Blue-Boxes-svg"/>
						</fo:instream-foreign-object>
					</fo:block>
				</fo:block-container>
			</fo:static-content>
		
			<fo:static-content flow-name="right-region" role="artifact">
				<fo:block-container font-family="Montserrat ExtraBold" font-weight="normal" reference-orientation="90" font-size="45.9pt" text-align="right">
					<fo:block margin-right="-6mm" margin-top="-2mm">
						<fo:instream-foreign-object content-width="2.5mm" content-height="11.9mm" scaling="non-uniform" fox:alt-text="Image Box">
							<xsl:call-template name="insertImageBoxSVG">
								<xsl:with-param name="color">rgb(38,172,226)</xsl:with-param>
							</xsl:call-template>
						</fo:instream-foreign-object>
						
						<fo:inline padding-left="2.5mm">STANDARDS</fo:inline>
						
					</fo:block>
				</fo:block-container>
				
			</fo:static-content>
		
			<fo:flow flow-name="xsl-region-body" font-family="Calibri">
				<fo:block-container height="81mm" display-align="center" font-weight="bold">
					<fo:block font-size="22pt" space-after="2pt">IEEE Standard for</fo:block>
					<fo:block font-size="22pt">
						<xsl:text>  </xsl:text>
						<!-- Example: Local and Metropolitan Area Networks— -->
						<xsl:copy-of select="$title_intro"/>
					</fo:block>
					<fo:block font-size="25pt" space-before="32pt">
						<!-- Example: Port-Based Network Access Control -->
						<xsl:copy-of select="$title_main"/>
					</fo:block>
				</fo:block-container>
				
				<fo:block-container>
					<fo:block font-size="16pt">
						<!-- Example: IEEE Computer Society -->
						<xsl:value-of select="$society"/> 
					</fo:block>
					<fo:block font-size="12pt" space-before="13mm">Developed by the</fo:block>
					<!-- LAN/MAN Standards Committee -->
					<fo:block font-size="12pt"><xsl:value-of select="$committee"/></fo:block>
					<fo:block font-size="12pt" font-weight="bold" space-before="40mm"><xsl:value-of select="$standard_number"/></fo:block>
					<fo:block font-size="10pt"><xsl:value-of select="$history"/></fo:block>
					
				</fo:block-container>
			</fo:flow>
		</fo:page-sequence>
	</xsl:template> <!-- insertCoverPage_Standard -->
	
	
	<xsl:template name="insertCoverPage_IndustryConnectionReport">
		<fo:page-sequence master-reference="cover-and-back-page-industry-connection-report" force-page-count="no-force">
			<fo:static-content flow-name="header" role="artifact">
				
				<fo:block-container position="absolute" left="65.5mm" top="0mm">
					<fo:block font-size="1">
						<fo:instream-foreign-object content-height="93.5mm" content-width="64.1mm" fox:alt-text="Image Boxes">
							<xsl:copy-of select="$Image-Blue-Boxes-svg"/>
						</fo:instream-foreign-object>
					</fo:block>
				</fo:block-container>
			</fo:static-content> <!-- header -->
		
			<fo:static-content flow-name="left-region" role="artifact">
				<fo:block-container position="absolute" left="0mm" top="0mm" width="50mm" height="{$pageHeight}mm" background-color="black">
					<fo:block> </fo:block>
				</fo:block-container>
				
				<fo:block-container position="absolute" left="11mm" top="4.5mm">
					<fo:block font-size="1">
						<fo:instream-foreign-object content-width="27.2mm" content-height="scale-to-fit" scaling="uniform" fox:alt-text="Image IEEE Logo">
							<xsl:call-template name="insert_Image-IEEE2-Logo-svg">
								<xsl:with-param name="color">FFFFFF</xsl:with-param>
							</xsl:call-template>
						</fo:instream-foreign-object>
					</fo:block>
				</fo:block-container>
				
				<fo:block-container position="absolute" left="10.6mm" top="242.8mm">
					<fo:block font-size="1">
						<fo:instream-foreign-object content-width="24.9mm" content-height="scale-to-fit" scaling="uniform" fox:alt-text="Image Logo">
							<xsl:copy-of select="$Image-IEEE-Logo-white-svg"/>
						</fo:instream-foreign-object>
					</fo:block>
				</fo:block-container>
				
				<fo:block-container position="absolute" left="0.5mm" top="217.3mm">
					<fo:block font-size="1">
						<fo:instream-foreign-object content-width="39.8mm" content-height="2.7mm" scaling="non-uniform" fox:alt-text="Image Box">
							<xsl:call-template name="insertImageBoxSVG">
								<xsl:with-param name="color">rgb(80,197,216)</xsl:with-param>
							</xsl:call-template>
						</fo:instream-foreign-object>
					</fo:block>
				</fo:block-container>
				
				<fo:block-container font-family="Montserrat ExtraBold" font-weight="normal" reference-orientation="90" font-size="36pt" line-height="0.93" text-align="left" color="white">
					<fo:block margin-left="70mm" margin-top="13mm">INDUSTRY CONNECTIONS REPORT</fo:block>
				</fo:block-container>
				
			</fo:static-content> <!-- "left-region -->
		
			<fo:flow flow-name="xsl-region-body">
				<fo:block-container font-family="Arial Black" height="100mm" display-align="center">
					<fo:block font-size="12.8pt" line-height="1.4">THE IEEE GLOBAL INITIATIVE ON ETHICS OF EXTENDED REALITY (XR) REPORT</fo:block>
					<fo:block font-size="20pt" space-before="16mm" line-height="1.3">BUSINESS, FINANCE, AND ECONOMICS</fo:block>
				</fo:block-container>
				
				<fo:block-container font-family="Calibri Light" font-weight="normal" font-size="12pt" line-height="1.5">
					<fo:block>Authored by</fo:block>
					<fo:block> </fo:block>
					<fo:block line-height="1.7">
						<fo:block>First Last names</fo:block>
						<fo:block font-style="italic">Chapter Leader</fo:block>
					</fo:block>
				</fo:block-container>
			</fo:flow>
		</fo:page-sequence>
	</xsl:template> <!-- insertCoverPage_IndustryConnectionReport -->
	
	<xsl:template name="insertCoverPage_NonStandard">
		<xsl:param name="title"/>
		<fo:page-sequence master-reference="cover-page-nonstandard" force-page-count="no-force">
			<fo:static-content flow-name="header" role="artifact">
				<fo:block-container position="absolute" left="65mm"> <!-- top="-2.6mm" -->
					<xsl:if test="$doctype = 'industry-connection-report'">
						<xsl:attribute name="left">76.5mm</xsl:attribute>
					</xsl:if>
					<fo:block font-size="1">
						<fo:instream-foreign-object content-height="93.5mm" content-width="64mm" fox:alt-text="Image Boxes">
							<xsl:copy-of select="$Image-Blue-Boxes-svg"/>
						</fo:instream-foreign-object>
					</fo:block>
				</fo:block-container>
				<!-- <fo:block-container position="absolute" left="0mm" top="263mm">
					<fo:block font-size="10pt">3 Park Avenue | New York, NY 10016‐5997 | USA</fo:block>
				</fo:block-container> -->
			</fo:static-content> <!-- header -->
		
			<fo:static-content flow-name="left-region" role="artifact">
				<fo:block-container position="absolute" left="0mm" top="0mm" width="50mm" height="{$pageHeight}mm" background-color="rgb(224,226,224)">
					<xsl:if test="$doctype = 'industry-connection-report'">
						<xsl:attribute name="background-color">black</xsl:attribute>
					</xsl:if>
					<fo:block> </fo:block>
				</fo:block-container>
				
				<fo:block-container position="absolute" left="14.5mm" top="12mm">
					<xsl:if test="$doctype = 'industry-connection-report'">
						<xsl:attribute name="left">12mm</xsl:attribute>
						<xsl:attribute name="top">5mm</xsl:attribute>
					</xsl:if>
					<fo:block font-size="1">
						<fo:instream-foreign-object content-width="27mm" content-height="scale-to-fit" scaling="uniform" fox:alt-text="Image Logo">
							
							<xsl:choose>
								<xsl:when test="$doctype = 'industry-connection-report'">
									<xsl:call-template name="insert_Image-IEEE2-Logo-svg">
										<xsl:with-param name="color">FFFFFF</xsl:with-param>
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:call-template name="insert_Image-IEEE2-Logo-svg"/>
								</xsl:otherwise>
							</xsl:choose>
						</fo:instream-foreign-object>
					</fo:block>
				</fo:block-container>
				
				<fo:block-container position="absolute" left="15.2mm" top="262mm">
					<xsl:if test="$doctype = 'industry-connection-report'">
						<xsl:attribute name="left">14mm</xsl:attribute>
					</xsl:if>
					<fo:block font-size="1">
						<fo:instream-foreign-object content-width="23.5mm" content-height="scale-to-fit" scaling="uniform" fox:alt-text="Image Logo">
							<xsl:choose>
								<xsl:when test="$doctype = 'industry-connection-report'">
									<xsl:attribute name="content-width">25mm</xsl:attribute>
									<xsl:copy-of select="$Image-IEEE-Logo-white-svg"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:copy-of select="$Image-IEEE-Logo-black-svg"/>
								</xsl:otherwise>
							</xsl:choose>
						</fo:instream-foreign-object>
					</fo:block>
				</fo:block-container>
				
				<fo:block-container position="absolute" left="1.5mm" top="217mm">
					<fo:block font-size="1">
						<fo:instream-foreign-object content-width="40mm" content-height="2.6mm" scaling="non-uniform" fox:alt-text="Image Box">
							<xsl:call-template name="insertImageBoxSVG">
								<xsl:with-param name="color">rgb(80,197,216)</xsl:with-param>
							</xsl:call-template>
						</fo:instream-foreign-object>
					</fo:block>
				</fo:block-container>
				
				<fo:block-container font-family="Arial Black" font-weight="normal" reference-orientation="90" font-size="44pt" line-height="0.9" text-align="left">
					<fo:block margin-left="71mm">
						<fo:block margin-top="10.5mm">
							<xsl:choose>
								<xsl:when test="$doctype = 'industry-connection-report'">
									<xsl:attribute name="font-size">36pt</xsl:attribute>
									<xsl:attribute name="font-family">Montserrat ExtraBold</xsl:attribute>
									<xsl:attribute name="color">white</xsl:attribute>
									<xsl:text>INDUSTRY CONNECTIONS REPORT</xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text>IEEE SA</xsl:text>
									<xsl:if test="$doctype = 'icap-whitepaper'">
										<xsl:text> ICAP</xsl:text>
									</xsl:if>
									<fo:block>WHITE PAPER</fo:block>
								</xsl:otherwise>
							</xsl:choose>
						</fo:block>
					</fo:block>
				</fo:block-container>
				
			</fo:static-content> <!-- "left-region -->
		
			<fo:flow flow-name="xsl-region-body">
				<fo:block-container font-family="Arial Black" display-align="center" height="85mm">
					<fo:block font-size="13pt">
						<xsl:choose>
							<xsl:when test="$doctype = 'icap-whitepaper'">
								<xsl:attribute name="margin-right">-10mm</xsl:attribute>
								<xsl:text>IEEE CONFORMITY ASSESSMENT PROGRAM (ICAP)</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								PROGRAM TITLE TO GO HERE
							</xsl:otherwise>
						</xsl:choose>
					</fo:block>
					<fo:block font-size="20pt" space-before="18mm">
						<xsl:copy-of select="$title"/>
					</fo:block>
				</fo:block-container>
				<fo:block-container font-family="Calibri Light" font-size="12pt" line-height="1.7">
					<fo:block space-after="6mm">Authored by</fo:block>
					<fo:block>Firstname Lastname</fo:block>
					<fo:block font-style="italic">Title</fo:block>
					<fo:block>Firstname Lastname</fo:block>
					<fo:block font-style="italic">Title</fo:block>
				</fo:block-container>
			</fo:flow>
		</fo:page-sequence>
	</xsl:template> <!-- insertCoverPage_NonStandard -->
	<!-- =============================== -->
	<!-- End Cover Pages -->
	<!-- =============================== -->
	

	<!-- =============================== -->
	<!-- Back Pages -->
	<!-- =============================== -->
	<xsl:template name="insertBackPage_Standard">
		<fo:page-sequence master-reference="cover-and-back-page-standard" force-page-count="no-force">
		
			<fo:static-content flow-name="header" role="artifact">
				<fo:block-container position="absolute" left="14mm" top="17.8mm">
					<fo:block font-size="1">
						<fo:instream-foreign-object content-width="32.9mm" content-height="scale-to-fit" scaling="uniform" fox:alt-text="Image IEEE Logo">
							<xsl:call-template name="insert_Image-IEEE2-Logo-svg"/>
						</fo:instream-foreign-object>
					</fo:block>
				</fo:block-container>
				<fo:block-container position="absolute" left="21mm" top="256mm">
					<fo:block font-size="1">
						<fo:instream-foreign-object content-width="20.8mm" content-height="scale-to-fit" scaling="uniform" fox:alt-text="Image IEEE Logo">							
							<xsl:copy-of select="$Image-IEEE-Logo-black-svg"/>
						</fo:instream-foreign-object>
					</fo:block>
				</fo:block-container>
				<fo:block-container position="absolute" left="191mm" top="-1mm">
					<fo:block font-size="1">
						<fo:instream-foreign-object content-width="26mm" content-height="scale-to-fit" scaling="uniform" fox:alt-text="Image Boxes">
							<xsl:copy-of select="$Image-Blue-Boxes-svg"/>
						</fo:instream-foreign-object>
					</fo:block>
				</fo:block-container>
			</fo:static-content>
		
			<fo:flow flow-name="xsl-region-body" font-family="Calibri">
			
				<fo:block font-family="Montserrat ExtraBold" font-size="32pt" font-weight="normal" margin-top="44mm" line-height="0.9">
					<fo:block>RAISING THE</fo:block>
					<fo:block>WORLD’S</fo:block>
					<fo:block>STANDARDS</fo:block>
				</fo:block>
				<fo:block font-size="1" space-before="6mm">
					<fo:instream-foreign-object content-width="75mm" content-height="2.6mm" scaling="non-uniform" fox:alt-text="Image Box">
						<xsl:call-template name="insertImageBoxSVG">
							<xsl:with-param name="color">rgb(38,172,226)</xsl:with-param>
						</xsl:call-template>
					</fo:instream-foreign-object>
				</fo:block>
				<fo:block font-size="12pt" font-weight="bold" space-before="1.5mm">Connect with us on:</fo:block>
				<fo:block font-size="10pt" space-before="1mm">
					<fo:table width="100%" table-layout="fixed">
						<fo:table-column column-width="7.6mm"/>
						<fo:table-column column-width="90mm"/>
						<fo:table-body>
							<fo:table-row display-align="center" height="6mm">
								<fo:table-cell>
									<fo:block font-size="1">
										<fo:external-graphic src="{concat('data:image/png;base64,', normalize-space($Image-Twitter-Logo))}" content-width="4.5mm" content-height="scale-to-fit" scaling="uniform" fox:alt-text="Image Boxes"/>
									</fo:block>
								</fo:table-cell>
								<fo:table-cell>
									<fo:block><fo:inline font-weight="bold">Twitter</fo:inline>: twitter.com/ieeesa</fo:block>
								</fo:table-cell>
							</fo:table-row>
							<fo:table-row display-align="center" height="6mm">
								<fo:table-cell>
									<fo:block font-size="1">
										<fo:external-graphic src="{concat('data:image/png;base64,', normalize-space($Image-FB-Logo))}" content-width="5.5mm" content-height="scale-to-fit" scaling="uniform" fox:alt-text="Image Boxes"/>
									</fo:block>
								</fo:table-cell>
								<fo:table-cell>
									<fo:block><fo:inline font-weight="bold">Facebook</fo:inline>: facebook.com/ieeesa</fo:block>
								</fo:table-cell>
							</fo:table-row>
							<fo:table-row display-align="center" height="6mm">
								<fo:table-cell>
									<fo:block font-size="1">
										<fo:external-graphic src="{concat('data:image/png;base64,', normalize-space($Image-LinkedIn-Logo))}" content-width="5.2mm" content-height="scale-to-fit" scaling="uniform" fox:alt-text="Image Boxes"/>
									</fo:block>
								</fo:table-cell>
								<fo:table-cell>
									<fo:block><fo:inline font-weight="bold">LinkedIn</fo:inline>: linkedin.com/groups/1791118</fo:block>
								</fo:table-cell>
							</fo:table-row>
							<fo:table-row display-align="center" height="6mm">
								<fo:table-cell>
									<fo:block font-size="1">
										<fo:external-graphic src="{concat('data:image/png;base64,', normalize-space($Image-Beyond-Logo))}" content-width="5mm" content-height="scale-to-fit" scaling="uniform" fox:alt-text="Image Boxes"/>
									</fo:block>
								</fo:table-cell>
								<fo:table-cell>
									<fo:block><fo:inline font-weight="bold">Beyond Standards blog</fo:inline>: beyondstandards.ieee.org</fo:block>
								</fo:table-cell>
							</fo:table-row>
							<fo:table-row display-align="center" height="6mm">
								<fo:table-cell>
									<fo:block font-size="1">
										<fo:external-graphic src="{concat('data:image/png;base64,', normalize-space($Image-Youtube-Logo))}" content-width="5mm" content-height="scale-to-fit" scaling="uniform" fox:alt-text="Image Boxes"/>
									</fo:block>
								</fo:table-cell>
								<fo:table-cell>
									<fo:block><fo:inline font-weight="bold">YouTube</fo:inline>: youtube.com/ieeesa</fo:block>
								</fo:table-cell>
							</fo:table-row>
						</fo:table-body>
					</fo:table>
				</fo:block>
				<fo:block font-size="10pt" space-before="3mm">
					<fo:block>standards.ieee.org</fo:block>
					<fo:block>Phone: +1 732 981 0060</fo:block>
				</fo:block>

			</fo:flow>
		</fo:page-sequence>
	</xsl:template>
	
	<xsl:template name="insertBackPage_IndustryConnectionReport">
		<fo:page-sequence master-reference="cover-and-back-page-industry-connection-report" force-page-count="no-force">
			<fo:static-content flow-name="left-region" role="artifact">
				<fo:block-container position="absolute" left="0mm" top="0mm" width="50mm" height="{$pageHeight}mm" background-color="black">
					<fo:block> </fo:block>
				</fo:block-container>
			</fo:static-content>
			<fo:flow flow-name="xsl-region-body">
				<fo:block-container margin-top="-61mm">
					<fo:block font-family="Arial Black" font-weight="normal" font-size="20pt" line-height="1.25">
						<fo:block>RAISING THE WORLD’S </fo:block>
						<fo:block>STANDARDS</fo:block>
					</fo:block>
					<fo:block font-size="1" space-before="1mm">
						<fo:instream-foreign-object content-width="56.8mm" content-height="2.7mm" scaling="non-uniform" fox:alt-text="Image Box">
							<xsl:call-template name="insertImageBoxSVG">
								<xsl:with-param name="color"><xsl:value-of select="$color_blue"/></xsl:with-param>
							</xsl:call-template>
						</fo:instream-foreign-object>
					</fo:block>
				</fo:block-container>
				
				<fo:block margin-left="8mm" margin-right="-10mm" margin-top="152mm" font-size="11pt" font-family="Calibri">
					<fo:block>3 Park Avenue, New York, NY 10016‐5997 USA <fo:inline text-decoration="underline" color="rgb(0,169,233)">http://standards.ieee.org</fo:inline></fo:block>
					<fo:block> </fo:block>
					<fo:block>Tel.+1732‐981‐0060 Fax+1732‐562‐1571</fo:block>
				</fo:block>
				
			</fo:flow>
		</fo:page-sequence>
	</xsl:template> <!-- insertBackPage_IndustryConnectionReport -->
	
	<xsl:template name="insertBackPage_NonStandard">
		<fo:page-sequence master-reference="back-page-nonstandard" force-page-count="no-force">
			<fo:static-content flow-name="left-region" role="artifact">
				<fo:block-container position="absolute" left="0mm" top="0mm" width="50mm" height="{$pageHeight}mm" background-color="rgb(224,226,224)">
					<fo:block> </fo:block>
				</fo:block-container>
			</fo:static-content>
			<fo:flow flow-name="xsl-region-body">
				<fo:block-container>
					<fo:block font-family="Arial Black" font-weight="normal" font-size="20pt" line-height="1.25">
						<fo:block>RAISING THE WORLD’S </fo:block>
						<fo:block>STANDARDS</fo:block>
					</fo:block>
					<fo:block font-size="1" space-before="2mm" margin-left="-1.5mm">
						<fo:instream-foreign-object content-width="56.8mm" content-height="2.7mm" scaling="non-uniform" fox:alt-text="Image Box">
							<xsl:call-template name="insertImageBoxSVG">
								<xsl:with-param name="color"><xsl:value-of select="$color_blue"/></xsl:with-param>
							</xsl:call-template>
						</fo:instream-foreign-object>
					</fo:block>
					<fo:block margin-right="-10mm" margin-top="140mm" font-size="11pt" font-family="Calibri">
						<fo:block>3 Park Avenue, New York, NY 10016‐5997 USA <fo:inline padding-left="2mm" text-decoration="underline" color="rgb(0,169,233)">http://standards.ieee.org</fo:inline></fo:block>
						<fo:block> </fo:block>
						<fo:block>Tel.+1732‐981‐0060 Fax+1732‐562‐1571</fo:block>
					</fo:block>
				</fo:block-container>
			</fo:flow>
		</fo:page-sequence>
	</xsl:template> <!-- insertBackPage_NonStandard -->
	<!-- =============================== -->
	<!-- End Back Pages -->
	<!-- =============================== -->
	
	<xsl:template name="replaceChar">
		<xsl:param name="text"/>
		<xsl:param name="replace"/>
		<xsl:param name="by"/>
		<xsl:choose>
			<xsl:when test="$text = '' or $replace = '' or not($replace)">
				<xsl:value-of select="$text"/>
			</xsl:when>
			<xsl:when test="contains($text, $replace)">
				<xsl:value-of select="substring-before($text,$replace)"/>
				<xsl:element name="inlineChar" namespace="https://www.metanorma.org/ns/ieee"><xsl:value-of select="$by"/></xsl:element>
				<xsl:call-template name="replaceChar">
						<xsl:with-param name="text" select="substring-after($text,$replace)"/>
						<xsl:with-param name="replace" select="$replace"/>
						<xsl:with-param name="by" select="$by"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
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
				215.9
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable><xsl:variable name="pageWidth" select="normalize-space($pageWidth_)"/><xsl:variable name="pageHeight_">
		<xsl:choose>
			<xsl:when test="$papersize_height != ''"><xsl:value-of select="$papersize_height"/></xsl:when>
			<xsl:otherwise>
				279.4
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable><xsl:variable name="pageHeight" select="normalize-space($pageHeight_)"/><xsl:variable name="marginLeftRight1_">
		31.7
	</xsl:variable><xsl:variable name="marginLeftRight1" select="normalize-space($marginLeftRight1_)"/><xsl:variable name="marginLeftRight2_">
		31.7
	</xsl:variable><xsl:variable name="marginLeftRight2" select="normalize-space($marginLeftRight2_)"/><xsl:variable name="marginTop_">
		25.4
	</xsl:variable><xsl:variable name="marginTop" select="normalize-space($marginTop_)"/><xsl:variable name="marginBottom_">
		25.4
	</xsl:variable><xsl:variable name="marginBottom" select="normalize-space($marginBottom_)"/><xsl:variable name="titles_">
		
		
		<!-- These titles of Table of contents renders different than determined in localized-strings -->
		<title-toc lang="en">
			
				<xsl:text>Contents</xsl:text>
			
			
			
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
			<xsl:attribute name="font-size">10pt</xsl:attribute>
		
		
		
		
		
		
		
		
		
		
		
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
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="license-statement-p-style">
		
		
		
		
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
			<xsl:attribute name="margin-top">5pt</xsl:attribute>
			<xsl:attribute name="margin-bottom">5pt</xsl:attribute>
		
		
		
		
		
				
		
		
		
		
		
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
		
		
		
		
			<xsl:attribute name="margin-top">8pt</xsl:attribute>
			<xsl:attribute name="margin-bottom">8pt</xsl:attribute>
			<xsl:attribute name="text-align">justify</xsl:attribute>
		
		
		
		

	</xsl:attribute-set><xsl:attribute-set name="example-style">
		
		
		
			<xsl:attribute name="margin-top">8pt</xsl:attribute>
			<xsl:attribute name="margin-bottom">8pt</xsl:attribute>
			<xsl:attribute name="text-align">justify</xsl:attribute>
		
		
		
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="example-body-style">
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="example-name-style">
		
		
		
		
		
		
			<xsl:attribute name="keep-with-next">always</xsl:attribute>
			<xsl:attribute name="padding-right">9mm</xsl:attribute>
			<xsl:attribute name="font-style">italic</xsl:attribute>
		
		
		
		
		
		
		
		
				
				
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="example-p-style">
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="termexample-name-style">
		
		
		
		
			<xsl:attribute name="keep-with-next">always</xsl:attribute>
			<xsl:attribute name="padding-right">9mm</xsl:attribute>
			<xsl:attribute name="font-style">italic</xsl:attribute>
		
				
				
	</xsl:attribute-set><xsl:variable name="table-border_">
		
		1pt solid black
	</xsl:variable><xsl:variable name="table-border" select="normalize-space($table-border_)"/><xsl:attribute-set name="table-container-style">
		<xsl:attribute name="margin-left">0mm</xsl:attribute>
		<xsl:attribute name="margin-right">0mm</xsl:attribute>
		
		
		
		
		
		
		
		
			<xsl:attribute name="font-size">9pt</xsl:attribute>
			<xsl:attribute name="margin-top">12pt</xsl:attribute>
			<xsl:attribute name="margin-bottom">8pt</xsl:attribute>
		
		
		
		
		
		
		
		
		
		
		
		
					
		
		
	</xsl:attribute-set><xsl:attribute-set name="table-style">
		<xsl:attribute name="table-omit-footer-at-break">true</xsl:attribute>
		<xsl:attribute name="table-layout">fixed</xsl:attribute>
		<xsl:attribute name="margin-left">0mm</xsl:attribute>
		<xsl:attribute name="margin-right">0mm</xsl:attribute>
		
		
		
		
		
		
		
		
			<xsl:attribute name="border"><xsl:value-of select="$table-border"/></xsl:attribute>
		
		
		
		
		
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="table-name-style">
		<xsl:attribute name="keep-with-next">always</xsl:attribute>
			
		
		
		
		
			<xsl:attribute name="font-family">Arial</xsl:attribute>
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
		
		
		
		
		
			<xsl:attribute name="padding-top">1mm</xsl:attribute>
			<xsl:attribute name="border">solid black 0.5pt</xsl:attribute>
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="table-cell-style">
		<xsl:attribute name="display-align">center</xsl:attribute>
		<xsl:attribute name="border">solid black 1pt</xsl:attribute>
		<xsl:attribute name="padding-left">1mm</xsl:attribute>
		<xsl:attribute name="padding-right">1mm</xsl:attribute>
		
		
		
		
		
		
			<xsl:attribute name="padding-top">0.5mm</xsl:attribute>
			<xsl:attribute name="border">solid black 0.5pt</xsl:attribute>
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="table-footer-cell-style">
		<xsl:attribute name="border">solid black 1pt</xsl:attribute>
		<xsl:attribute name="padding-left">1mm</xsl:attribute>
		<xsl:attribute name="padding-right">1mm</xsl:attribute>
		<xsl:attribute name="padding-top">1mm</xsl:attribute>
		
		
		
		
		
		
		
		
			<xsl:attribute name="border">solid black 0.5pt</xsl:attribute>
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="table-note-style">
		<xsl:attribute name="font-size">10pt</xsl:attribute>
		<xsl:attribute name="margin-bottom">12pt</xsl:attribute>
		
		
		
		
		
		
			<xsl:attribute name="font-size">inherit</xsl:attribute>
			<xsl:attribute name="margin-bottom">6pt</xsl:attribute>
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="table-fn-style">
		<xsl:attribute name="margin-bottom">12pt</xsl:attribute>
		
		
		
		
		
			<xsl:attribute name="font-size">inherit</xsl:attribute>
			<xsl:attribute name="margin-bottom">6pt</xsl:attribute>
			<xsl:attribute name="text-indent">-3mm</xsl:attribute>
			<xsl:attribute name="margin-left">3mm</xsl:attribute>
		
		
		
			<xsl:attribute name="margin-top">6pt</xsl:attribute>
			<xsl:attribute name="margin-bottom">6pt</xsl:attribute>
		
		
	</xsl:attribute-set><xsl:attribute-set name="table-fn-number-style">
		<xsl:attribute name="font-size">80%</xsl:attribute>
		<xsl:attribute name="padding-right">5mm</xsl:attribute>
		
		
		
		
		
		
		
			<xsl:attribute name="baseline-shift">30%</xsl:attribute>
			<xsl:attribute name="font-size">6.5pt</xsl:attribute>
		
		
		
		
		
		
		
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
		
		
		
		
		
			<xsl:attribute name="margin-left">2mm</xsl:attribute>
			<xsl:attribute name="margin-top">0pt</xsl:attribute>
			<xsl:attribute name="line-height">1.2</xsl:attribute>
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="dl-name-style">
		<xsl:attribute name="keep-with-next">always</xsl:attribute>
		<xsl:attribute name="margin-bottom">6pt</xsl:attribute>
			
		
		
		
		
			<xsl:attribute name="font-famuily">Arial</xsl:attribute>
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
		
		
		
		
				
		
			<xsl:attribute name="font-size">9pt</xsl:attribute>
			<xsl:attribute name="margin-top">12pt</xsl:attribute>
			<xsl:attribute name="margin-bottom">12pt</xsl:attribute>
			<xsl:attribute name="text-align">justify</xsl:attribute>
				
		
		
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:variable name="note-body-indent">10mm</xsl:variable><xsl:variable name="note-body-indent-table">5mm</xsl:variable><xsl:attribute-set name="note-name-style">
		
		
		
		
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="table-note-name-style">
		<xsl:attribute name="padding-right">2mm</xsl:attribute>
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="note-p-style">
		
		
		
		
		
			<xsl:attribute name="text-align">justify</xsl:attribute>
		
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="termnote-style">
		
		
		
			<xsl:attribute name="font-size">9pt</xsl:attribute>
			<xsl:attribute name="margin-top">12pt</xsl:attribute>
			<xsl:attribute name="margin-bottom">12pt</xsl:attribute>
			<xsl:attribute name="text-align">justify</xsl:attribute>
				
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="termnote-name-style">
		
				
		
		
	</xsl:attribute-set><xsl:attribute-set name="termnote-p-style">
		
	</xsl:attribute-set><xsl:attribute-set name="quote-style">
		<xsl:attribute name="margin-left">12mm</xsl:attribute>
		<xsl:attribute name="margin-right">12mm</xsl:attribute>
		
		
		
		
		
		
		
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
		
		
		
		
			<xsl:attribute name="font-family">Arial</xsl:attribute>
			<xsl:attribute name="font-weight">bold</xsl:attribute>
			<xsl:attribute name="text-align">center</xsl:attribute>
			<xsl:attribute name="margin-top">12pt</xsl:attribute>
			<xsl:attribute name="margin-bottom">6pt</xsl:attribute>
			<xsl:attribute name="keep-with-previous">always</xsl:attribute>
				
		
		
		
		
		
		
		
		
		
		
		
		

		
		
		
			
	</xsl:attribute-set><xsl:attribute-set name="formula-style">
		<xsl:attribute name="margin-top">6pt</xsl:attribute>
		<xsl:attribute name="margin-bottom">12pt</xsl:attribute>
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="formula-stem-block-style">
		<xsl:attribute name="text-align">center</xsl:attribute>
		
		
		
		
		
			<xsl:attribute name="text-align">left</xsl:attribute>
			<xsl:attribute name="margin-left">1mm</xsl:attribute>
		
		
		
		
		
		
		
		
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
		
		
	</xsl:attribute-set><xsl:attribute-set name="list-style">
		
		
		
		
		
		
			<xsl:attribute name="provisional-distance-between-starts">8mm</xsl:attribute>
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
		
		
		
		
		
		
		
			<xsl:attribute name="font-size">65%</xsl:attribute>
			<xsl:attribute name="vertical-align">super</xsl:attribute>
		
		
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="fn-body-style">
		<xsl:attribute name="font-weight">normal</xsl:attribute>
		<xsl:attribute name="font-style">normal</xsl:attribute>
		<xsl:attribute name="text-indent">0</xsl:attribute>
		<xsl:attribute name="start-indent">0</xsl:attribute>
		
		
		
		
		
		
		
			<xsl:attribute name="font-size">8pt</xsl:attribute>
			<!-- <xsl:attribute name="margin-bottom">5pt</xsl:attribute> -->
		
		
		
		
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="fn-body-num-style">
		<xsl:attribute name="keep-with-next.within-line">always</xsl:attribute>
		
		
		
		
		
		
		
			<xsl:attribute name="font-size">50%</xsl:attribute>
			<xsl:attribute name="vertical-align">super</xsl:attribute>
			<xsl:attribute name="padding-right">1mm</xsl:attribute>
		
		
		
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="admonition-style">
		
		
		
		
		
		
			<xsl:attribute name="border">0.5pt solid black</xsl:attribute>
			<xsl:attribute name="space-before">12pt</xsl:attribute>
			<xsl:attribute name="text-align">center</xsl:attribute>
			<xsl:attribute name="space-after">12pt</xsl:attribute>
		
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="admonition-container-style">
		<xsl:attribute name="margin-left">0mm</xsl:attribute>
		<xsl:attribute name="margin-right">0mm</xsl:attribute>
		
		
		
		
			<xsl:attribute name="padding">1mm</xsl:attribute>
			<xsl:attribute name="padding-bottom">2mm</xsl:attribute>
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="admonition-name-style">
		<xsl:attribute name="keep-with-next">always</xsl:attribute>
		
		
		
		
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="admonition-p-style">
		
		
		
		
			<xsl:attribute name="text-align">justify</xsl:attribute>
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="bibitem-normative-style">
		
		
		
		
		
		
		
			<xsl:attribute name="margin-top">12pt</xsl:attribute>
			<xsl:attribute name="margin-bottom">12pt</xsl:attribute>
		
		
		
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="bibitem-normative-list-style">
		<xsl:attribute name="provisional-distance-between-starts">12mm</xsl:attribute>
		<xsl:attribute name="margin-bottom">12pt</xsl:attribute>
		
		
		
		
		<!-- <xsl:if test="$namespace = 'ieee'">
			<xsl:attribute name="margin-bottom">6pt</xsl:attribute>
			<xsl:attribute name="provisional-distance-between-starts">9.5mm</xsl:attribute>
		</xsl:if> -->
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="bibitem-non-normative-style">
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="bibitem-non-normative-list-style">
		<xsl:attribute name="provisional-distance-between-starts">12mm</xsl:attribute>
		<xsl:attribute name="margin-bottom">12pt</xsl:attribute>
		
		
		
		
		
			<xsl:attribute name="provisional-distance-between-starts">9.5mm</xsl:attribute>
			<xsl:attribute name="margin-bottom">6pt</xsl:attribute>
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="bibitem-normative-list-body-style">
		
		
			<xsl:attribute name="line-height-shift-adjustment">disregard-shifts</xsl:attribute>
		
		
	</xsl:attribute-set><xsl:attribute-set name="bibitem-non-normative-list-body-style">
		
		
			<xsl:attribute name="line-height-shift-adjustment">disregard-shifts</xsl:attribute>
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="bibitem-note-fn-style">
		<xsl:attribute name="keep-with-previous.within-line">always</xsl:attribute>
		<xsl:attribute name="font-size">65%</xsl:attribute>
		
		
		
		
		
		
		
			<xsl:attribute name="font-size">8pt</xsl:attribute>
			<xsl:attribute name="baseline-shift">30%</xsl:attribute>
		
		
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="bibitem-note-fn-number-style">
		<xsl:attribute name="keep-with-next.within-line">always</xsl:attribute>
		
		
		
		
		
		
		
			<xsl:attribute name="alignment-baseline">hanging</xsl:attribute>
			<xsl:attribute name="padding-right">1mm</xsl:attribute>
		
		
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="bibitem-note-fn-body-style">
		<xsl:attribute name="font-size">10pt</xsl:attribute>
		<xsl:attribute name="margin-bottom">12pt</xsl:attribute>
		<xsl:attribute name="start-indent">0pt</xsl:attribute>
		
		
		
		
		
			<xsl:attribute name="font-size">8pt</xsl:attribute>
			<xsl:attribute name="margin-bottom">5pt</xsl:attribute>
		
		
		
		
		
		
		
		
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
		
				<!-- process in the template 'title' -->
				<xsl:call-template name="title"/>
			
	</xsl:template><xsl:template match="*[local-name()='license-statement']//*[local-name()='p']">
		
				<!-- process in the template 'paragraph' -->
				<xsl:call-template name="paragraph"/>
			
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
			
				
			
				
			
				
			
				
				
				
					<xsl:if test="$doctype = 'whitepaper' or $doctype = 'icap-whitepaper' or $doctype = 'industry-connection-report'">
						<xsl:attribute name="font-size">10pt</xsl:attribute>
					</xsl:if>
					<xsl:if test="ancestor::*[local-name() = 'feedback-statement']">
						<xsl:attribute name="font-size">inherit</xsl:attribute>
						<xsl:attribute name="margin-top">6pt</xsl:attribute>
						<xsl:attribute name="margin-bottom">6pt</xsl:attribute>
					</xsl:if>
				
				
				
			
				
				
				
				
				
				<!-- end table block-container attributes -->
				
				<!-- display table's name before table for PAS inside block-container (2-columnn layout) -->
				
				
				<xsl:variable name="table_width_default">100%</xsl:variable>
				<xsl:variable name="table_width">
					<!-- for centered table always 100% (@width will be set for middle/second cell of outer table) -->
					
							<xsl:choose>
								<xsl:when test="ancestor::*[local-name() = 'feedback-statement']">50%</xsl:when>
								<xsl:when test="@width"><xsl:value-of select="@width"/></xsl:when>
								<xsl:otherwise><xsl:value-of select="$table_width_default"/></xsl:otherwise>
							</xsl:choose>
						
				</xsl:variable>
				
				
				<xsl:variable name="table_attributes">
				
					<xsl:element name="table_attributes" use-attribute-sets="table-style">
						<xsl:attribute name="width"><xsl:value-of select="normalize-space($table_width)"/></xsl:attribute>
						
						
						
						
						
						
						
						
							<xsl:if test="$doctype = 'whitepaper' or $doctype = 'icap-whitepaper' or $doctype = 'industry-connection-report'">
								<xsl:attribute name="border">0.5 solid black</xsl:attribute>
							</xsl:if>
							<xsl:if test="ancestor::*[local-name() = 'feedback-statement']">
								<xsl:attribute name="border">none</xsl:attribute>
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
		
			
					<fo:inline>
				
						<xsl:if test="$doctype = 'whitepaper' or $doctype = 'icap-whitepaper' or $doctype = 'industry-connection-report'">
							<xsl:attribute name="font-size">11pt</xsl:attribute>
							<xsl:attribute name="font-family">Arial Black</xsl:attribute>
						</xsl:if>
				
						<xsl:apply-templates/>
					</fo:inline>
				
			
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
				
				
				
					
						<xsl:if test="$doctype = 'whitepaper' or $doctype = 'icap-whitepaper' or $doctype = 'industry-connection-report'">
							<xsl:attribute name="border-bottom">0.5 solid black</xsl:attribute>
						</xsl:if>
					
						<fo:block xsl:use-attribute-sets="table-name-style">
							<xsl:apply-templates select="ancestor::*[local-name()='table']/*[local-name()='name']">
								<xsl:with-param name="continued">true</xsl:with-param>
							</xsl:apply-templates>
							
							<fo:inline font-weight="normal" font-style="italic">
								<xsl:text> </xsl:text>
								<fo:retrieve-table-marker retrieve-class-name="table_continued"/>
							</fo:inline>
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
								<fo:block/><!-- display fn after table -->
								
								
								<!-- for PAS display Notes after footnotes -->
								
								
							</fo:table-cell>
						</fo:table-row>
					</fo:table-body>
					
				</fo:table>
			</xsl:variable>
			
			<xsl:if test="normalize-space($tableWithNotesAndFootnotes) != ''">
				<xsl:copy-of select="$tableWithNotesAndFootnotes"/>
			</xsl:if>
			
			
				<xsl:call-template name="table_fn_display"/>
			
			
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
		
			
			
			


			
				<xsl:if test="position() = last()">
					<xsl:attribute name="border-bottom"><xsl:value-of select="$table-border"/></xsl:attribute>
				</xsl:if>
				<xsl:if test="$doctype = 'whitepaper' or $doctype = 'icap-whitepaper' or $doctype = 'industry-connection-report'">
					<xsl:attribute name="border-bottom">0.5 solid black</xsl:attribute>
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
		
			
				<xsl:if test="ancestor::*[local-name() = 'feedback-statement']">
					<xsl:attribute name="min-height">0mm</xsl:attribute>
				</xsl:if>
			
		
			
		
			
		
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
			
			
			
			
			
			
				<xsl:if test="ancestor::*[local-name() = 'feedback-statement']">
					<xsl:attribute name="padding-left">0mm</xsl:attribute>
					<xsl:attribute name="padding-top">0mm</xsl:attribute>
					<xsl:attribute name="padding-right">0mm</xsl:attribute>
					<xsl:attribute name="border">none</xsl:attribute>
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
								
								
									<xsl:if test="$doctype = 'whitepaper' or $doctype = 'icap-whitepaper' or $doctype = 'industry-connection-report'">
										<xsl:attribute name="font-size">7pt</xsl:attribute>
										<xsl:attribute name="line-height">1.1</xsl:attribute>
									</xsl:if>
								
								
								<fo:inline id="{$ref_id}" xsl:use-attribute-sets="fn-body-num-style">
									
									
									
										<xsl:if test="$doctype = 'whitepaper' or $doctype = 'icap-whitepaper' or $doctype = 'industry-connection-report'">
											<xsl:attribute name="padding-right">0.5mm</xsl:attribute>
										</xsl:if>
									
									
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
			
			
			
			
				<xsl:if test="$doctype = 'whitepaper' or $doctype = 'icap-whitepaper' or $doctype = 'industry-connection-report'">
					<xsl:attribute name="color"><xsl:value-of select="$color_blue"/></xsl:attribute>
					<xsl:attribute name="text-decoration">none</xsl:attribute>
				</xsl:if>
				<xsl:if test="$doctype = 'standard' and $stage = 'published'">
					<xsl:attribute name="color"><xsl:value-of select="$color_blue"/></xsl:attribute>
					<xsl:attribute name="text-decoration">none</xsl:attribute>
					<xsl:if test="ancestor::*[local-name() = 'feedback-statement']">
						<xsl:attribute name="text-decoration">underline</xsl:attribute>
					</xsl:if>
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
			
				

				
					<xsl:attribute name="padding-right">0mm</xsl:attribute>
				
				
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
					
						<xsl:text>—</xsl:text>
					
					
					
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
					
						<xsl:text>—</xsl:text>
					
					
					
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
				
				
				
				
					<xsl:if test="$doctype = 'whitepaper' or $doctype = 'icap-whitepaper' or $doctype = 'industry-connection-report'">
						<xsl:attribute name="font-size">inherit</xsl:attribute>
						<xsl:attribute name="font-family">Arial Black</xsl:attribute>
					</xsl:if>
				
				
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
				<xsl:apply-templates/>: 
			</fo:inline>
		</xsl:if>
	</xsl:template><xsl:template match="*[local-name() = 'termexample']/*[local-name() = 'p']">
		<xsl:variable name="element">inline
			
			block
		</xsl:variable>		
		<xsl:choose>			
			<xsl:when test="contains($element, 'block')">
				<fo:block xsl:use-attribute-sets="example-p-style">
				
					
						<xsl:if test="not(preceding-sibling::*[local-name() = 'p'])">
							<xsl:attribute name="margin-top">6pt</xsl:attribute>
						</xsl:if>
					
						
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
					<xsl:apply-templates/>: 
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
						
							<xsl:if test="not(preceding-sibling::*[local-name() = 'p'])">
								<xsl:attribute name="margin-top">6pt</xsl:attribute>
							</xsl:if>
						
						
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
					
					
					
					
						<xsl:if test="$doctype = 'whitepaper' or $doctype = 'icap-whitepaper' or $doctype = 'industry-connection-report'">
							<xsl:attribute name="color"><xsl:value-of select="$color_blue"/></xsl:attribute>
							<xsl:attribute name="text-decoration">none</xsl:attribute>
						</xsl:if>
					
					
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
			
			
			
			
			
			
			1
			
			
			
			
			
			
			
			
			
			
			
			
			
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
		
				<xsl:choose>
					<xsl:when test="$doctype = 'whitepaper' or $doctype = 'icap-whitepaper' or $doctype = 'industry-connection-report'">
						<label level="1" font-size="14pt" color="rgb(128,128,128)">▪</label> <!-- Black small square 25AA  18pt  line-height="1.5" -->
						<label level="2">—</label><!-- em dash --> 
					</xsl:when>
					<xsl:otherwise>
						<label level="1">–</label>
						<label level="2">•</label>
						<label level="3" font-size="75%">o</label> <!-- white circle -->
					</xsl:otherwise>
				</xsl:choose>
			
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
				
					
				
					
						<xsl:if test="$doctype = 'whitepaper' or $doctype = 'icap-whitepaper' or $doctype = 'industry-connection-report'">
							<xsl:attribute name="color">rgb(128,128,128)</xsl:attribute>
							<xsl:attribute name="line-height">1.1</xsl:attribute>
							<xsl:if test=".//ieee:fn">
								<xsl:attribute name="line-height">1.4</xsl:attribute>
							</xsl:if>
							
						</xsl:if>
					
				
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
									
											<xsl:value-of select="*[local-name() = 'docidentifier'][@type = 'metanorma-ordinal']"/>
											<xsl:if test="not(*[local-name() = 'docidentifier'][@type = 'metanorma-ordinal'])">
												<xsl:choose>
													<xsl:when test="($doctype = 'whitepaper' or $doctype = 'icap-whitepaper' or $doctype = 'industry-connection-report')">
														<fo:inline color="{$color_blue}">
															<xsl:text>[ </xsl:text>
															<xsl:number format="1" count="*[local-name()='bibitem'][not(@hidden = 'true')]"/>
															<xsl:text> ]</xsl:text>
														</fo:inline>
													</xsl:when>
													<xsl:otherwise>
														<xsl:text>[B</xsl:text>
														<xsl:number format="1" count="*[local-name()='bibitem'][not(@hidden = 'true')]"/>
														<xsl:text>]</xsl:text>
													</xsl:otherwise>
												</xsl:choose>
											</xsl:if>
										 <!-- ieee -->
										
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
				
						<xsl:choose>
							<xsl:when test="$doctype = 'whitepaper' or $doctype = 'icap-whitepaper' or $doctype = 'industry-connection-report'">3</xsl:when>
							<xsl:otherwise>2</xsl:otherwise>
						</xsl:choose>
					
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
		
		
		
		
		
		 <!-- text in the box -->
				<fo:block-container id="{@id}" xsl:use-attribute-sets="admonition-style">
					
					
						<xsl:if test="@type = 'editorial'">
							<xsl:attribute name="border">none</xsl:attribute>
							<!-- 	<xsl:attribute name="font-weight">bold</xsl:attribute>
							<xsl:attribute name="font-style">italic</xsl:attribute> -->
							<xsl:attribute name="color">green</xsl:attribute>
							<xsl:attribute name="font-weight">normal</xsl:attribute>
							<xsl:attribute name="margin-top">12pt</xsl:attribute>
							<xsl:attribute name="margin-bottom">12pt</xsl:attribute>
							<xsl:attribute name="text-align">left</xsl:attribute>
						</xsl:if>
						<xsl:if test="not(@type)">
							<xsl:attribute name="font-size">9pt</xsl:attribute>
							<xsl:attribute name="text-align">left</xsl:attribute>
						</xsl:if>
					
					
					
				
					
					
							<fo:block-container xsl:use-attribute-sets="admonition-container-style">
							
								
									<xsl:if test="@type = 'editorial' or not(@type)">
										<xsl:attribute name="padding">0mm</xsl:attribute>
									</xsl:if>
									<xsl:if test="not(@type)">
										<xsl:attribute name="padding">1mm</xsl:attribute>
										<xsl:attribute name="padding-bottom">0.5mm</xsl:attribute>
									</xsl:if>
								
							
								
										<fo:block-container margin-left="0mm" margin-right="0mm">
											<fo:block xsl:use-attribute-sets="admonition-p-style">
												<fo:inline>
													<xsl:call-template name="displayAdmonitionName">
														<xsl:with-param name="sep">: </xsl:with-param>
													</xsl:call-template>
												</fo:inline>
												<xsl:apply-templates select="node()[not(local-name() = 'name')]"/>
											</fo:block>
										</fo:block-container>
									
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
		
				<xsl:choose>
					<xsl:when test="ancestor::*[local-name() = 'admonition'][@type = 'editorial']">
						<xsl:apply-templates/>
					</xsl:when>
					<xsl:otherwise>
						<fo:block xsl:use-attribute-sets="admonition-p-style">
							<xsl:apply-templates/>
						</fo:block>
					</xsl:otherwise>
				</xsl:choose>
			
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
								
										<!-- <xsl:variable name="full_title">
											<item>
												<xsl:value-of select="*[local-name() = 'title'][@language = 'intro-en']"/>
											</item>
											<item>
												<xsl:value-of select="*[local-name() = 'title'][@language = 'main-en']"/>
											</item>
											<item>
												<xsl:value-of select="*[local-name() = 'title'][@language = 'part-en']"/>
											</item>
										</xsl:variable>
										<xsl:for-each select="xalan:nodeset($full_title)/item[normalize-space() != '']">
											<xsl:value-of select="."/>
											<xsl:if test="position() != last()"> - </xsl:if>
										</xsl:for-each> -->
										<xsl:value-of select="*[local-name() = 'title']"/>
									
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
							
									<xsl:value-of select="ieee:ext/ieee:editorialgroup/ieee:committee"/>
								
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
			
			
			
			
				<xsl:value-of select="document('')//*/namespace::ieee"/>
			
			
			
			
			
			
			
			
			
						
			
			
			
			
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