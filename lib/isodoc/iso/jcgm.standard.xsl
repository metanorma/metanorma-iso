<?xml version="1.0" encoding="UTF-8"?><xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:jcgm="https://www.metanorma.org/ns/bipm" xmlns:bipm="https://www.metanorma.org/ns/bipm" xmlns:mathml="http://www.w3.org/1998/Math/MathML" xmlns:xalan="http://xml.apache.org/xalan" xmlns:fox="http://xmlgraphics.apache.org/fop/extensions" xmlns:java="http://xml.apache.org/xalan/java" exclude-result-prefixes="java" version="1.0">

	<xsl:output method="xml" encoding="UTF-8" indent="no"/>
	
	<xsl:param name="align-cross-elements"/>
	
	

	<xsl:key name="kfn" match="*[local-name() = 'fn'][not(ancestor::*[(local-name() = 'table' or local-name() = 'figure') and not(ancestor::*[local-name() = 'name'])])]" use="@reference"/>
	
	
	
	<xsl:variable name="align_cross_elements_default">clause</xsl:variable>
	<xsl:variable name="align_cross_elements_doc">
		<xsl:choose>
			<xsl:when test="normalize-space($align-cross-elements) != ''"><xsl:value-of select="$align-cross-elements"/></xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="normalize-space((//jcgm:bipm-standard)[1]/jcgm:bibdata/jcgm:ext/jcgm:parallel-align-element)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="align_cross_elements_">
		<xsl:choose>
			<xsl:when test="$align_cross_elements_doc != ''">
				<xsl:value-of select="$align_cross_elements_doc"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$align_cross_elements_default"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="align_cross_elements">
		<xsl:text>#</xsl:text><xsl:value-of select="translate(normalize-space($align_cross_elements_), ' ', '#')"/><xsl:text>#</xsl:text>
	</xsl:variable>
	
	<xsl:variable name="doc_first">
		<xsl:if test="*[local-name()='metanorma-collection']">
			<xsl:variable name="doc_first_step1">
				<xsl:apply-templates select="(/*[local-name()='metanorma-collection']//*[contains(local-name(), '-standard')])[1]" mode="flatxml_step1">
					<xsl:with-param name="num" select="'first'"/>
				</xsl:apply-templates>
			</xsl:variable>
			<xsl:variable name="doc_first_step2">
				<xsl:apply-templates select="xalan:nodeset($doc_first_step1)" mode="flatxml_step2"/>
			</xsl:variable>
			<xsl:copy-of select="$doc_first_step2"/>
		</xsl:if>
	</xsl:variable>
	<xsl:variable name="docs_slave">
		<xsl:if test="*[local-name()='metanorma-collection']">
			<xsl:for-each select="(/*[local-name()='metanorma-collection']//*[contains(local-name(), '-standard')])[position() &gt; 1]">
				<xsl:variable name="doc_first_step1">
					<xsl:apply-templates select="." mode="flatxml_step1">
					<xsl:with-param name="num" select="'slave'"/>
					</xsl:apply-templates>
				</xsl:variable>
				<xsl:variable name="doc_first_step2">
					<xsl:apply-templates select="xalan:nodeset($doc_first_step1)" mode="flatxml_step2"/>
				</xsl:variable>
				<xsl:copy-of select="$doc_first_step2"/>
			</xsl:for-each>
		</xsl:if>
	</xsl:variable>

	<xsl:variable name="page_width">172</xsl:variable>
	<xsl:variable name="column_gap">8</xsl:variable>
	<xsl:variable name="docs_count">
		<xsl:choose>
			<xsl:when test="/*[local-name()='metanorma-collection']">
				<xsl:value-of select="count(/*[local-name()='metanorma-collection']//*[contains(local-name(), '-standard')])"/>
			</xsl:when>
			<xsl:otherwise>1</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<!-- (page_width - column_gap)/n_columns = column_width -->
	<!-- example: for two-column layout: 82mm 8mm 82mm -->
	<xsl:variable name="column_width" select="($page_width - $column_gap) div $docs_count"/>
	
	<xsl:variable name="debug">false</xsl:variable>
	
	<xsl:variable name="all_rights_reserved">
		<xsl:call-template name="getLocalizedString">
			<xsl:with-param name="key">all_rights_reserved</xsl:with-param>
		</xsl:call-template>
	</xsl:variable>
	
	<xsl:variable name="copyrightText" select="concat('© ', (//jcgm:bipm-standard)[1]/jcgm:bibdata/jcgm:ext/jcgm:editorialgroup/jcgm:committee/@acronym, ' ', (//jcgm:bipm-standard)[1]/jcgm:bibdata/jcgm:copyright/jcgm:from, ' — ', $all_rights_reserved)"/>
  
	
	<!-- Example:
		<item level="1" id="Foreword" display="true">Foreword</item>
		<item id="term-script" display="false">3.2</item>
	-->
	<xsl:variable name="contents_">
	
		<xsl:for-each select="//*[contains(local-name(), '-standard')]">
			<xsl:variable name="lang" select="*[local-name()='bibdata']/*[local-name()='language'][@current = 'true']"/>
			<xsl:variable name="current_document">
				<xsl:copy-of select="."/>
			</xsl:variable>				
			<xsl:for-each select="xalan:nodeset($current_document)">
				<xsl:variable name="docid">
					<xsl:call-template name="getDocumentId"/>
				</xsl:variable>
				<doc id="{$docid}" lang="{$lang}">
					<contents>
						<xsl:call-template name="processPrefaceSectionsDefault_Contents"/>
						<xsl:call-template name="processMainSectionsDefault_Contents"/>
						<!-- Index -->
						<!-- <xsl:apply-templates select="//jcgm:clause[@type = 'index']" mode="contents"/> -->
						<xsl:apply-templates select="//jcgm:indexsect" mode="contents"/>
						
						<xsl:call-template name="processTablesFigures_Contents"/>
					</contents>
				</doc>
			</xsl:for-each>				
		</xsl:for-each>
	</xsl:variable>
	<xsl:variable name="contents" select="xalan:nodeset($contents_)"/>
	
	
	<xsl:variable name="indexes">
		<xsl:for-each select="//jcgm:bipm-standard">
			
			<xsl:variable name="current_document">
				<xsl:copy-of select="."/>
			</xsl:variable>
			
			<xsl:for-each select="xalan:nodeset($current_document)">
			
				<xsl:variable name="docid">
					<xsl:call-template name="getDocumentId"/>
				</xsl:variable>

				<!-- add id to xref and split xref with @to into two xref -->
				<xsl:variable name="current_document_index_id">
					<!-- <xsl:apply-templates select=".//jcgm:clause[@type = 'index']" mode="index_add_id"/> -->
					<xsl:apply-templates select=".//jcgm:indexsect" mode="index_add_id"/>
				</xsl:variable>
				
				<xsl:variable name="current_document_index">
					<xsl:apply-templates select="xalan:nodeset($current_document_index_id)" mode="index_update"/>
				</xsl:variable>
				
				<xsl:for-each select="xalan:nodeset($current_document_index)">
					<doc id="{$docid}">
						<xsl:copy-of select="."/>
					</doc>
				</xsl:for-each>
				
			</xsl:for-each>
			
		</xsl:for-each>
	</xsl:variable>

	
	<xsl:template match="/">
		<fo:root xml:lang="{$lang}">
			<xsl:variable name="root-style">
				<root-style xsl:use-attribute-sets="root-style"/>
			</xsl:variable>
			<xsl:call-template name="insertRootStyle">
				<xsl:with-param name="root-style" select="$root-style"/>
			</xsl:call-template>
			<fo:layout-master-set>
				<!-- cover page -->
				<fo:simple-page-master master-name="cover-page-jcgm" page-width="{$pageWidth}mm" page-height="{$pageHeight}mm">
					<fo:region-body margin-top="85mm" margin-bottom="30mm" margin-left="100mm" margin-right="19mm"/>
					<fo:region-before extent="85mm"/>
					<fo:region-after region-name="cover-page-jcgm-footer" extent="30mm"/>
					<fo:region-start extent="100mm"/>
					<fo:region-end extent="19mm"/>
				</fo:simple-page-master>
				<!-- internal cover page -->
				<fo:simple-page-master master-name="internal-cover-page-jcgm" page-width="{$pageWidth}mm" page-height="{$pageHeight}mm">
					<fo:region-body margin-top="11mm" margin-bottom="21mm" margin-left="25mm" margin-right="19mm"/>
					<fo:region-before region-name="header" extent="11mm"/>
					<fo:region-after region-name="internal-cover-page-jcgm-footer" extent="21mm"/>
					<fo:region-start extent="25mm"/>
					<fo:region-end extent="19mm"/>
				</fo:simple-page-master>
				
				<!-- blank page -->
				<fo:simple-page-master master-name="blankpage" page-width="{$pageWidth}mm" page-height="{$pageHeight}mm">
					<fo:region-body margin-top="{$marginTop}mm" margin-bottom="{$marginBottom}mm" margin-left="{$marginLeftRight1}mm" margin-right="{$marginLeftRight2}mm"/>
					<fo:region-before region-name="header-blank" extent="{$marginTop}mm"/> 
					<fo:region-after region-name="footer-blank" extent="{$marginBottom}mm"/>
					<fo:region-start region-name="left-region" extent="17mm"/>
					<fo:region-end region-name="right-region" extent="26.5mm"/>
				</fo:simple-page-master>
				
				<fo:simple-page-master master-name="odd-jcgm" page-width="{$pageWidth}mm" page-height="{$pageHeight}mm">
					<fo:region-body margin-top="{$marginTop}mm" margin-bottom="{$marginBottom}mm" margin-left="{$marginLeftRight1}mm" margin-right="{$marginLeftRight2}mm"/>
					<fo:region-before region-name="header-odd-jcgm" extent="{$marginTop}mm"/> <!--   display-align="center" -->
					<fo:region-after region-name="footer-odd-jcgm" extent="{$marginBottom}mm"/>
					<fo:region-start region-name="left-region" extent="{$marginLeftRight1}mm"/>
					<fo:region-end region-name="right-region" extent="{$marginLeftRight2}mm"/>
				</fo:simple-page-master>
				<fo:simple-page-master master-name="even-jcgm" page-width="{$pageWidth}mm" page-height="{$pageHeight}mm">
					<fo:region-body margin-top="{$marginTop}mm" margin-bottom="{$marginBottom}mm" margin-left="{$marginLeftRight2}mm" margin-right="{$marginLeftRight1}mm"/>
					<fo:region-before region-name="header-even-jcgm" extent="{$marginTop}mm"/> <!--   display-align="center" -->
					<fo:region-after region-name="footer-even-jcgm" extent="{$marginBottom}mm"/>
					<fo:region-start region-name="left-region" extent="{$marginLeftRight2}mm"/>
					<fo:region-end region-name="right-region" extent="{$marginLeftRight1}mm"/>
				</fo:simple-page-master>
				<fo:page-sequence-master master-name="document-jcgm">
					<fo:repeatable-page-master-alternatives>
						<fo:conditional-page-master-reference master-reference="blankpage" blank-or-not-blank="blank"/>
						<fo:conditional-page-master-reference odd-or-even="even" master-reference="even-jcgm"/>
						<fo:conditional-page-master-reference odd-or-even="odd" master-reference="odd-jcgm"/>
					</fo:repeatable-page-master-alternatives>
				</fo:page-sequence-master>
			</fo:layout-master-set>
			
			<fo:declarations>
				<xsl:call-template name="addPDFUAmeta"/>
			</fo:declarations>
				
			<xsl:call-template name="addBookmarks">
				<xsl:with-param name="contents" select="$contents"/>
			</xsl:call-template>
			
			<fo:page-sequence master-reference="cover-page-jcgm" font-family="Arial" font-size="10.5pt" force-page-count="no-force">
				<fo:static-content flow-name="cover-page-jcgm-footer" font-size="10pt">
					<fo:block font-size="10pt" border-bottom="0.5pt solid black" padding-bottom="2.5mm" margin-left="-1mm" space-after="4mm">
						<!-- Example: First edition  July 2009 -->
						<xsl:call-template name="printEdition"/>
						<xsl:text>   </xsl:text>
						<xsl:call-template name="convertDate">
							<xsl:with-param name="date" select="(//jcgm:bipm-standard)[1]/jcgm:bibdata/jcgm:date[@type = 'published']/jcgm:on"/>
						</xsl:call-template>
					</fo:block>
					<!-- Example © JCGM 2009 -->
					<fo:block font-size="11pt">
						<fo:inline font-family="Times New Roman" font-size="12pt"><xsl:text>© </xsl:text></fo:inline>
						<xsl:value-of select="(//jcgm:bipm-standard)[1]/jcgm:bibdata/jcgm:ext/jcgm:editorialgroup/jcgm:committee/@acronym"/>
						<xsl:text> </xsl:text>
						<xsl:value-of select="(//jcgm:bipm-standard)[1]/jcgm:bibdata/jcgm:copyright/jcgm:from"/>
					</fo:block>
				</fo:static-content>
				<fo:flow flow-name="xsl-region-body">
					<xsl:call-template name="insert_Logo-BIPM-Metro"/>
					<xsl:call-template name="insertDraftWatermark"/>
					<fo:block-container font-weight="bold">
						<fo:block font-size="16.5pt">
							<xsl:value-of select="(//jcgm:bipm-standard)[1]/jcgm:bibdata/jcgm:ext/jcgm:editorialgroup/jcgm:committee/@acronym"/>
							<xsl:text> </xsl:text>
							<xsl:value-of select="(//jcgm:bipm-standard)[1]/jcgm:bibdata/jcgm:docnumber"/>
							<fo:inline font-weight="normal">:</fo:inline>
							<xsl:value-of select="(//jcgm:bipm-standard)[1]/jcgm:bibdata/jcgm:copyright/jcgm:from"/>
						</fo:block>
						<fo:block font-size="13pt" font-weight="normal" space-after="19.5mm">
							<xsl:value-of select="(//jcgm:bipm-standard)[1]/jcgm:bibdata/jcgm:title[@type = 'provenance']"/>
						</fo:block>
						<fo:block border-bottom="1pt solid black"> </fo:block>
						<fo:block font-size="16.5pt" margin-left="-0.5mm" padding-top="3.5mm" space-after="7mm" margin-right="7mm" line-height="105%" role="H1">
							<xsl:apply-templates select="(//jcgm:bipm-standard)[1]/jcgm:bibdata/jcgm:title[@language = $lang and @type = 'main']" mode="title"/>
							<xsl:variable name="title_part">
								<xsl:apply-templates select="(//jcgm:bipm-standard)[1]/jcgm:bibdata/jcgm:title[@language = $lang and @type = 'part']" mode="title"/>
							</xsl:variable>
							<xsl:if test="normalize-space($title_part) != ''">
								<xsl:text> — </xsl:text>
								<xsl:copy-of select="$title_part"/>
							</xsl:if>
						</fo:block>
						<fo:block font-size="12pt" font-style="italic" line-height="140%" role="H1">
							<xsl:variable name="secondLang" select="(//jcgm:bipm-standard)[1]/jcgm:bibdata/jcgm:title/@language[. != $lang]"/>
							<xsl:apply-templates select="(//jcgm:bipm-standard)[1]/jcgm:bibdata/jcgm:title[@language = $secondLang and @type = 'main']" mode="title"/>
							<xsl:variable name="title_part">
								<xsl:apply-templates select="(//jcgm:bipm-standard)[1]/jcgm:bibdata/jcgm:title[@language = $secondLang and @type = 'part']" mode="title"/>
							</xsl:variable>
							<xsl:if test="normalize-space($title_part) != ''">
								<xsl:text> — </xsl:text>
								<xsl:copy-of select="$title_part"/>
							</xsl:if>
						</fo:block>
					</fo:block-container>
				</fo:flow>
			</fo:page-sequence>
			
			<fo:page-sequence master-reference="internal-cover-page-jcgm" force-page-count="no-force">
				<fo:static-content flow-name="internal-cover-page-jcgm-footer" font-size="9pt">
					<!-- example: (c) JCGM 2009— All rights reserved -->
					<fo:block text-align="right">
						<xsl:value-of select="$copyrightText"/>
					</fo:block>
				</fo:static-content>
				<fo:flow flow-name="xsl-region-body">
					<xsl:call-template name="insertDraftWatermark"/>
					<fo:table table-layout="fixed" width="100%" font-size="13pt">
						<fo:table-column column-width="134mm"/>
						<fo:table-column column-width="30mm"/>
						<fo:table-body>
							<fo:table-row>
								<fo:table-cell>
									<fo:block><xsl:value-of select="(//jcgm:bipm-standard)[1]/jcgm:bibdata/jcgm:ext/jcgm:editorialgroup/jcgm:committee"/></fo:block>
								</fo:table-cell>
								<fo:table-cell line-height="140%">
									<fo:block><xsl:value-of select="(//jcgm:bipm-standard)[1]/jcgm:bibdata/jcgm:ext/jcgm:editorialgroup/jcgm:committee/@acronym"/></fo:block>
									<fo:block><xsl:value-of select="(//jcgm:bipm-standard)[1]/jcgm:bibdata/jcgm:docnumber"/></fo:block>
									<fo:block><xsl:value-of select="(//jcgm:bipm-standard)[1]/jcgm:bibdata/jcgm:copyright/jcgm:from"/></fo:block>
								</fo:table-cell>
							</fo:table-row>
						</fo:table-body>
					</fo:table>
					<fo:block font-size="18pt" space-before="70mm" role="H1">
						<xsl:apply-templates select="(//jcgm:bipm-standard)[1]/jcgm:bibdata/jcgm:title[@language = $lang and @type = 'main']" mode="title"/>
						<xsl:variable name="title_part">
							<xsl:apply-templates select="(//jcgm:bipm-standard)[1]/jcgm:bibdata/jcgm:title[@language = $lang and @type = 'part']" mode="title"/>
						</xsl:variable>
						<xsl:if test="normalize-space($title_part) != ''">
							<xsl:text> — </xsl:text>
							<xsl:copy-of select="$title_part"/>
						</xsl:if>
					</fo:block>
					<fo:block font-size="13pt" space-before="35mm" role="H1">
						<xsl:variable name="secondLang" select="(//jcgm:bipm-standard)[1]/jcgm:bibdata/jcgm:title/@language[. != $lang]"/>
						<xsl:apply-templates select="(//jcgm:bipm-standard)[1]/jcgm:bibdata/jcgm:title[@language = $secondLang and @type = 'main']" mode="title"/>
						<xsl:variable name="title_part">
							<xsl:apply-templates select="(//jcgm:bipm-standard)[1]/jcgm:bibdata/jcgm:title[@language = $secondLang and @type = 'part']" mode="title"/>
						</xsl:variable>
						<xsl:if test="normalize-space($title_part) != ''">
							<xsl:text> — </xsl:text>
							<xsl:copy-of select="$title_part"/>
						</xsl:if>
					</fo:block>
				</fo:flow>
			</fo:page-sequence>
			
			
			<fo:page-sequence master-reference="document-jcgm" format="i" initial-page-number="2" force-page-count="odd">
				<fo:static-content flow-name="xsl-footnote-separator">
					<fo:block>
						<fo:leader leader-pattern="rule" leader-length="30%"/>
					</fo:block>
				</fo:static-content>
        
				<xsl:call-template name="insertHeaderFooter"/>
					
				<fo:flow flow-name="xsl-region-body" line-height="115%">
				
					<!-- Copyright -->
					<xsl:for-each select="//*[contains(local-name(), '-standard')]">
						<xsl:apply-templates select="./*[local-name()='boilerplate']/*"/>
						<fo:block break-after="page"/>
					</xsl:for-each>
				
					<xsl:for-each select="//*[contains(local-name(), '-standard')]">
						<xsl:variable name="current_document">
							<xsl:copy-of select="."/>
						</xsl:variable>				
						<xsl:for-each select="xalan:nodeset($current_document)">
							<xsl:variable name="docid">
								<xsl:call-template name="getDocumentId"/>
							</xsl:variable>
							
							<!-- Table of Contents -->
							<fo:block-container>
								<fo:block role="TOC">
									<fo:block text-align-last="justify">
										<fo:inline font-size="15pt" font-weight="bold" role="H1">
											<xsl:call-template name="getLocalizedString">
												<xsl:with-param name="key">table_of_contents</xsl:with-param>
											</xsl:call-template>
										</fo:inline>
										<fo:inline keep-together.within-line="always">
											<fo:leader leader-pattern="space"/>
											<xsl:call-template name="getLocalizedString">
												<xsl:with-param name="key">Page.sg</xsl:with-param>
											</xsl:call-template>
										</fo:inline>
									</fo:block>
									
									<xsl:if test="$debug = 'true'">
										<xsl:text disable-output-escaping="yes">&lt;!--</xsl:text>
											DEBUG
											contents=<xsl:copy-of select="$contents"/>
										<xsl:text disable-output-escaping="yes">--&gt;</xsl:text>
									</xsl:if>
									
									<xsl:variable name="annexes_title">
										<xsl:call-template name="getLocalizedString">
											<xsl:with-param name="key">Annex.pl</xsl:with-param>
										</xsl:call-template>
									</xsl:variable>
									
									<xsl:for-each select="$contents/doc[@id=$docid]//item[@display = 'true']"> <!-- and not (@type = 'annex') and not (@type = 'references') -->
										<xsl:if test="@type = 'annex' and not(preceding-sibling::item[@display = 'true' and @type = 'annex'])">
											<fo:block font-size="12pt" space-before="16pt" font-weight="bold" role="TOCI">
												<xsl:value-of select="$annexes_title"/>
											</fo:block>
										</xsl:if>
										<xsl:call-template name="print_JCGN_toc_item"/>
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

						</xsl:for-each>
						
						<xsl:if test="position() != last()">
							<fo:block break-after="page"/>
						</xsl:if>
					</xsl:for-each>
					
					
					<!-- Foreword, Introduction -->					
					<!-- <xsl:call-template name="processPrefaceSectionsDefault"/> -->
					<xsl:for-each select="//*[contains(local-name(), '-standard')]">
						<fo:block break-after="page"/>
						<xsl:apply-templates select="./*[local-name()='preface']/*[local-name()='abstract']"/>
					</xsl:for-each>
					<xsl:for-each select="//*[contains(local-name(), '-standard')]">
						<fo:block break-after="page"/>
						<xsl:apply-templates select="./*[local-name()='preface']/*[local-name()='foreword']"/>
					</xsl:for-each>
					<xsl:for-each select="//*[contains(local-name(), '-standard')]">
						<fo:block break-after="page"/>
						<xsl:apply-templates select="./*[local-name()='preface']/*[local-name()='introduction']"/>
					</xsl:for-each>
					<xsl:for-each select="//*[contains(local-name(), '-standard')]">
						<fo:block break-after="page"/>
						<xsl:apply-templates select="./*[local-name()='preface']/*[local-name() != 'abstract' and local-name() != 'foreword' and local-name() != 'introduction' and local-name() != 'acknowledgements' and local-name() != 'note' and local-name() != 'admonition']"/>
					</xsl:for-each>
					<xsl:for-each select="//*[contains(local-name(), '-standard')]">
						<fo:block break-after="page"/>
						<xsl:apply-templates select="./*[local-name()='preface']/*[local-name()='acknowledgements']"/>
					</xsl:for-each>

				</fo:flow>
			</fo:page-sequence>
			
			
			<!-- JCGM BODY -->
			<fo:page-sequence master-reference="document-jcgm" initial-page-number="1" force-page-count="no-force">
				<fo:static-content flow-name="xsl-footnote-separator">
					<fo:block>
						<fo:leader leader-pattern="rule" leader-length="30%"/>
					</fo:block>
				</fo:static-content>
				<xsl:call-template name="insertHeaderFooter"/>
				
				<fo:flow flow-name="xsl-region-body" line-height="115%">
					
					<fo:block-container>
						<!-- Show title -->
						<!-- Example: Evaluation of measurement data — An introduction to the `Guide to the expression of uncertainty in measurement' and related documents -->
						
						<xsl:for-each select="//*[contains(local-name(), '-standard')]">
							<fo:block font-size="20pt" font-weight="bold" margin-bottom="20pt" space-before="36pt" line-height="1.1">
								<xsl:variable name="curr_lang" select="*[local-name()='bibdata']/*[local-name()='language'][@current = 'true']"/>
								
								<xsl:variable name="title-main">
									<xsl:apply-templates select="./*[local-name() = 'bibdata']/*[local-name() = 'title'][@language = $curr_lang and @type = 'main']" mode="title"/>
								</xsl:variable>

								<xsl:variable name="title-part">
									<xsl:apply-templates select="./*[local-name() = 'bibdata']/*[local-name() = 'title'][@language = $curr_lang and @type = 'part']" mode="title"/>
								</xsl:variable>
								
								<fo:block role="H1">
									<xsl:copy-of select="$title-main"/>
									<xsl:if test="normalize-space($title-main) != '' and normalize-space($title-part) != ''">
										<xsl:text> — </xsl:text>
									</xsl:if>
									<xsl:copy-of select="$title-part"/>
								</fo:block>
								
								<xsl:variable name="edition">
									<xsl:apply-templates select="./*[local-name() = 'bibdata']/*[local-name() = 'edition'][normalize-space(@language) = '']">
										<xsl:with-param name="curr_lang" select="$curr_lang"/>
									</xsl:apply-templates>
								</xsl:variable>
								<xsl:if test="normalize-space($edition) != ''">
									<fo:block margin-top="12pt"><xsl:copy-of select="$edition"/></fo:block>
								</xsl:if>
								
							</fo:block>
						</xsl:for-each>
					
					</fo:block-container>
					<!-- Clause(s) -->
					<fo:block>
						<xsl:choose>
							<xsl:when test="count(//*[contains(local-name(), '-standard')]) = 1 ">
								<xsl:call-template name="processMainSectionsDefault"/>
							</xsl:when>
							<xsl:otherwise>
								<!-- output each clause pair in two-column table -->
						
								<!-- <xsl:variable name="flatxml">
									<xsl:apply-templates select="." mode="flatxml"/>
								</xsl:variable> -->
						
								<!-- doc_first=<xsl:copy-of select="$doc_first"/>
								docs_slave=<xsl:copy-of select="$docs_slave"/> -->
						
								<!-- <xsl:apply-templates select="xalan:nodeset($doc_first)/*/*[local-name()='sections']/*[local-name()='clause'][@type='scope']" mode="multi_columns"/> -->
								<xsl:apply-templates select="xalan:nodeset($doc_first)/*/*[local-name()='sections']/*[local-name()='section_scope']/*" mode="multi_columns"/>
								
								<!-- Normative references  -->
								<xsl:apply-templates select="xalan:nodeset($doc_first)/*/*[local-name()='bibliography']/*[local-name()='references'][@normative='true']" mode="multi_columns"/>
								<!-- Terms and definitions -->
								<xsl:apply-templates select="xalan:nodeset($doc_first)/*/*[local-name()='sections']/*[local-name()='section_terms']/*" mode="multi_columns"/>
																												
								<!-- <xsl:apply-templates select="xalan:nodeset($doc_first)/*/*[local-name()='sections']/*[local-name()='terms'] | 
																												xalan:nodeset($doc_first)/*/*[local-name()='sections']/*[local-name()='clause'][.//*[local-name()='terms']] |
																												xalan:nodeset($doc_first)/*/*[local-name()='sections']/*[local-name()='definitions'] | 
																												xalan:nodeset($doc_first)/*/*[local-name()='sections']/*[local-name()='clause'][.//*[local-name()='definitions']]" mode="multi_columns"/> -->
																												
								<!-- Another main sections -->
								<!-- <xsl:apply-templates select="xalan:nodeset($doc_first)/*/*[local-name()='sections']/*[local-name() != 'terms' and 
																																																				local-name() != 'definitions' and 
																																																				not(@type='scope') and
																																																				not(local-name() = 'clause' and .//*[local-name()='terms']) and
																																																				not(local-name() = 'clause' and .//*[local-name()='definitions'])]" mode="multi_columns"/> -->
								<xsl:apply-templates select="xalan:nodeset($doc_first)/*/*[local-name()='sections']/*[local-name() != 'section_terms' and                                                     local-name() != 'section_scope']" mode="multi_columns"/>																																											
                                                                                                        
								<xsl:apply-templates select="xalan:nodeset($doc_first)/*/*[local-name()='annex']" mode="multi_columns"/>
								<!-- Bibliography -->
								<xsl:apply-templates select="xalan:nodeset($doc_first)/*/*[local-name()='bibliography']/*[local-name()='references'][not(@normative='true')]" mode="multi_columns"/>
								
							
							</xsl:otherwise>
						</xsl:choose>
						<!--  -->
						
						
						
					</fo:block>
				</fo:flow>
			</fo:page-sequence>

				<!-- indexes=<xsl:copy-of select="$indexes"/> -->
			<!-- Index -->
			<!-- <xsl:apply-templates select="xalan:nodeset($indexes)/doc//jcgm:clause[@type = 'index']" mode="index" /> -->
			<xsl:apply-templates select="xalan:nodeset($indexes)/doc//jcgm:indexsect" mode="index"/>
			
		</fo:root>
	</xsl:template>

	<xsl:template name="insertListOf_Title">
		<xsl:param name="title"/>
		<fo:block font-weight="bold" margin-top="12pt" keep-with-next="always">
			<xsl:value-of select="$title"/>
		</fo:block>
	</xsl:template>
	
	<xsl:template name="insertListOf_Item">
		<fo:block margin-left="5mm" role="TOCI">
			<fo:block text-align-last="justify" margin-left="12mm" text-indent="-12mm">
				<fo:basic-link internal-destination="{@id}">
					<xsl:call-template name="setAltText">
						<xsl:with-param name="value" select="@alt-text"/>
					</xsl:call-template>
					<fo:inline>
						<xsl:apply-templates select="." mode="contents"/>
					</fo:inline>
					<xsl:text> </xsl:text>
					<fo:inline keep-together.within-line="always" font-weight="normal">
						<fo:leader font-size="9pt" leader-pattern="dots"/>
						<fo:inline><fo:page-number-citation ref-id="{@id}"/></fo:inline>
					</fo:inline>
				</fo:basic-link>
			</fo:block>
		</fo:block>
	</xsl:template>

	<xsl:template match="node()">		
		<xsl:apply-templates/>			
	</xsl:template>
	
	
	<!-- ============================= -->
	<!-- CONTENTS                                       -->
	<!-- ============================= -->

	<!-- element with title -->
	<xsl:template match="*[*[local-name()='title']]" mode="contents">
		<xsl:variable name="level">
			<xsl:call-template name="getLevel">
				<xsl:with-param name="depth" select="*[local-name()='title']/@depth"/>
			</xsl:call-template>
		</xsl:variable>
		
		<xsl:variable name="section">
			<xsl:call-template name="getSection"/>
		</xsl:variable>
		
		<xsl:variable name="type">
			<xsl:choose>
				<xsl:when test="@type = 'index'">index</xsl:when>
				<xsl:when test="local-name() = 'indexsect'">index</xsl:when>
				<xsl:otherwise><xsl:value-of select="local-name()"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
			
		<xsl:variable name="display">
			<xsl:choose>				
				<xsl:when test="ancestor-or-self::*[local-name()='annex'] and $level &gt;= 2">false</xsl:when>
				<xsl:when test="$section = '' and $type = 'clause'">false</xsl:when>
				<xsl:when test="$level &lt;= $toc_level">true</xsl:when>
				<xsl:otherwise>false</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="skip">
			<xsl:choose>
				<xsl:when test="ancestor-or-self::*[local-name()='bibitem']">true</xsl:when>
				<xsl:when test="ancestor-or-self::*[local-name()='term']">true</xsl:when>				
				<xsl:otherwise>false</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		
		<xsl:if test="$skip = 'false'">		
		
			<xsl:variable name="title">
				<xsl:call-template name="getName"/>
			</xsl:variable>
			
			<xsl:variable name="root">
				<xsl:if test="ancestor-or-self::*[local-name()='preface']">preface</xsl:if>
				<xsl:if test="ancestor-or-self::*[local-name()='annex']">annex</xsl:if>
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
	

	<xsl:template name="setListItemLabel">
		<xsl:attribute name="label">
			<xsl:call-template name="getListItemFormat"/>
		</xsl:attribute>
		<xsl:attribute name="list_type">
			<xsl:value-of select="local-name(..)"/>
		</xsl:attribute>
	</xsl:template>

	
	<!-- ============================= -->
	<!-- ============================= -->
	
	

	<xsl:template match="*[local-name()='p']" name="paragraph">
		<xsl:param name="inline" select="'false'"/>
		<xsl:param name="split_keep-within-line"/>
		<xsl:variable name="previous-element" select="local-name(preceding-sibling::*[1])"/>
		<xsl:variable name="element-name">
			<xsl:choose>
				<xsl:when test="$inline = 'true'">fo:inline</xsl:when>
				<xsl:when test="../@inline-header = 'true' and $previous-element = 'title'">fo:inline</xsl:when> <!-- first paragraph after inline title -->
				<xsl:when test="preceding-sibling::*[1]/@inline-header = 'true' and $previous-element = 'title'">fo:inline</xsl:when> <!-- first paragraph after inline title, for two columns layout -->
				<xsl:when test="local-name(..) = 'admonition'">fo:inline</xsl:when>
				<xsl:otherwise>fo:block</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:element name="{$element-name}">
			<xsl:attribute name="text-align">
				<xsl:choose>
					<xsl:when test="@align"><xsl:value-of select="@align"/></xsl:when>
					<xsl:when test="ancestor::*[local-name()='td']/@align"><xsl:value-of select="ancestor::*[local-name()='td']/@align"/></xsl:when>
					<xsl:when test="ancestor::*[local-name()='th']/@align"><xsl:value-of select="ancestor::*[local-name()='th']/@align"/></xsl:when>
					<xsl:otherwise>justify</xsl:otherwise><!-- left -->
				</xsl:choose>
			</xsl:attribute>
			<xsl:attribute name="margin-bottom">12pt</xsl:attribute>
			<xsl:if test="ancestor::*[@first or @slave]">
				<!-- JCGM two column layout -->
				<xsl:attribute name="widows">1</xsl:attribute>
				<xsl:attribute name="orphans">1</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates>
				<xsl:with-param name="split_keep-within-line" select="$split_keep-within-line"/>
			</xsl:apply-templates>
		</xsl:element>
		<xsl:if test="$element-name = 'fo:inline' and not($inline = 'true') and not(local-name(..) = 'admonition')">
			<fo:block margin-bottom="12pt">
				 <xsl:if test="ancestor::*[local-name()='annex'] or following-sibling::*[local-name()='table']">
					<xsl:attribute name="margin-bottom">0</xsl:attribute>
				 </xsl:if>
				<xsl:value-of select="$linebreak"/>
			</fo:block>
		</xsl:if>
		<xsl:if test="$inline = 'true'">
			<fo:block> </fo:block>
		</xsl:if>
	</xsl:template>
	

	<xsl:template match="*[local-name()='p']/*[local-name()='fn']/*[local-name()='p']">
		<xsl:apply-templates/>
	</xsl:template>
	
	
 
	<xsl:template match="jcgm:fn/jcgm:p">
		<fo:block>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	
	
	
	<!-- for two-columns layout -->
	
	<xsl:template match="*[local-name()='ul'][not(*)] | *[local-name()='ol'][not(*)]" priority="2"/>
	
	<xsl:template match="*[local-name()='li'][not(parent::*[local-name()='ul'] or parent::*[local-name()='ol'])]">
		<fo:list-block provisional-distance-between-starts="7mm" margin-top="8pt">
			<fo:list-item id="{@id}">
				<fo:list-item-label end-indent="label-end()">
					<fo:block>
						<xsl:value-of select="@label"/>
						<!-- <xsl:call-template name="getListItemFormat"/> -->
					</fo:block>
				</fo:list-item-label>
				<fo:list-item-body start-indent="body-start()">
					<fo:block>
						<xsl:apply-templates select="node()[not(local-name() = 'note')]"/>
						<xsl:apply-templates select=".//*[local-name()='note']"/>
					</fo:block>
				</fo:list-item-body>
			</fo:list-item>
		</fo:list-block>
	</xsl:template>
	
	
	<xsl:template match="*[local-name()='preferred'][not(parent::*[local-name()='term'])]" priority="2">		
		<xsl:variable name="levelTerm">
			<xsl:call-template name="getLevelTermName"/>
		</xsl:variable>
		<fo:block role="H{$levelTerm}" xsl:use-attribute-sets="preferred-block-style">
			<fo:block xsl:use-attribute-sets="term-name-style">
				<xsl:apply-templates select="preceding-sibling::*[local-name()='term_name'][1]" mode="presentation"/>				
			</fo:block>
			<fo:block xsl:use-attribute-sets="preferred-term-style">
				<xsl:call-template name="setStyle_preferred"/>
				<xsl:apply-templates/>
			</fo:block>
		</fo:block>
	</xsl:template>
	
	<xsl:template match="*[local-name() = 'term_name']"/>
	<xsl:template match="*[local-name() = 'term_name']" mode="presentation">
		<xsl:if test="normalize-space() != ''">
			<fo:inline>
				<xsl:apply-templates/>
			</fo:inline>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*[local-name() = 'domain'][not(parent::*[local-name()='term'])]" priority="2">
		<fo:block xsl:use-attribute-sets="domain-style">
			<fo:inline>
				<xsl:text>&lt;</xsl:text>
				<xsl:apply-templates/>
				<xsl:text>&gt;</xsl:text>
			</fo:inline>
		</fo:block>
	</xsl:template>

	<xsl:template match="*[local-name() = 'definition']/*[local-name() = 'p']" priority="2">
		<fo:block widows="1" orphans="1"><xsl:apply-templates/></fo:block>
	</xsl:template>

	
	<!-- for chemical expressions, when prefix superscripted -->
	<xsl:template match="mathml:msup[count(*) = 2 and count(mathml:mrow) = 2]/mathml:mrow[1][count(*) = 1 and mathml:mtext and (mathml:mtext/text() = '' or not(mathml:mtext/text()))]/mathml:mtext" mode="mathml" priority="2">
		<mathml:mspace height="1ex"/>
	</xsl:template>
	<xsl:template match="mathml:msup[count(*) = 2 and count(mathml:mrow) = 2]/mathml:mrow[1][count(*) = 1 and mathml:mtext and (mathml:mtext/text() = ' ' or mathml:mtext/text() = ' ')]/mathml:mtext" mode="mathml" priority="2">
		<mathml:mspace width="1ex" height="1ex"/>
	</xsl:template>

	<!-- set height for sup -->
	<!-- <xsl:template match="mathml:msup[count(*) = 2 and count(mathml:mrow) = 2]/mathml:mrow[1][count(*) = 1 and mathml:mtext and (mathml:mtext/text() != '' and mathml:mtext/text() != ' ' and mathml:mtext/text() != '&#xa0;')]/mathml:mtext" mode="mtext"> -->
	<xsl:template match="mathml:msup[count(*) = 2 and count(mathml:mrow) = 2]/mathml:mrow[1][count(*) = 1]/*" mode="mathml" priority="2">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="mathml"/>
		</xsl:copy>
		<!-- <xsl:copy-of select="."/> -->
		<mathml:mspace height="1.47ex"/>
	</xsl:template>

	<!-- set script minimal font-size -->
	<xsl:template match="mathml:math" mode="mathml" priority="2">
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="mathml"/>
			<mathml:mstyle scriptminsize="6pt">
				<xsl:apply-templates select="node()" mode="mathml"/>
			</mathml:mstyle>
		</xsl:copy>
	</xsl:template>

	<!-- issue 'over bar above equation with sub' fixing -->
	<xsl:template match="mathml:msub/mathml:mrow[1][mathml:mover and count(following-sibling::*) = 1 and following-sibling::mathml:mrow]" mode="mathml" priority="2">
		<mathml:mstyle>
			<xsl:copy-of select="."/>
		</mathml:mstyle>
	</xsl:template>

	<!-- Decrease space between ()
	from: 
	<mfenced open="(" close=")">
		<mrow>
			<mtext>Cu</mtext>
		</mrow>
	</mfenced>
		to: 
		<mrow>
			<mtext>(Cu)</mtext>
		</mrow> -->
	<xsl:template match="mathml:mfenced[count(*) = 1 and *[count(*) = 1] and */*[count(*) = 0]] |                  mathml:mfenced[count(*) = 1 and *[count(*) = 1] and */*[count(*) = 1] and */*/*[count(*) = 0]]" mode="mathml" priority="2">
		<xsl:apply-templates mode="mathml"/>
	</xsl:template>
		
	<xsl:template match="mathml:mfenced[count(*) = 1]/*[count(*) = 1]/*[count(*) = 0] |                  mathml:mfenced[count(*) = 1]/*[count(*) = 1]/*[count(*) = 1]/*[count(*) = 0]" mode="mathml" priority="2"> <!-- [not(following-sibling::*) and not(preceding-sibling::*)] -->
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="mathml"/>
			<xsl:value-of select="ancestor::mathml:mfenced/@open"/>
			<xsl:value-of select="."/>
			<xsl:value-of select="ancestor::mathml:mfenced/@close"/>
		</xsl:copy>
	</xsl:template>

	<!-- Decrease height of / and | -->
	<xsl:template match="mathml:mo[normalize-space(text()) = '/' or normalize-space(text()) = '|']" mode="mathml" priority="2">
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="mathml"/>
				<xsl:if test="not(@stretchy)">
					<xsl:attribute name="stretchy">false</xsl:attribute>
				</xsl:if>
			<xsl:apply-templates mode="mathml"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="mathml:mi[string-length(normalize-space()) &gt; 1]" mode="mathml" priority="2">
		<xsl:if test="preceding-sibling::* and preceding-sibling::*[1][not(local-name() = 'mfenced' or local-name() = 'mo')]">
			<mathml:mspace width="0.3em"/>
		</xsl:if>
		<xsl:copy-of select="."/>
		<xsl:if test="following-sibling::* and following-sibling::*[1][not(local-name() = 'mfenced' or local-name() = 'mo')]">
			<mathml:mspace width="0.3em"/>
		</xsl:if>
	</xsl:template>
	
	
	<xsl:template match="*[local-name()='td' or local-name()='th']/*[local-name()='formula']/*[local-name()='stem']" priority="2">
		<fo:block>
			<xsl:if test="ancestor::*[local-name()='td' or local-name()='th'][1][@align]">
				<xsl:attribute name="text-align">
					<xsl:value-of select="ancestor::*[local-name()='td' or local-name()='th'][1]/@align"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
  
	
	<!-- ================ -->
	<!-- JCGM specific templates -->
	<!-- ================ -->
	
	<xsl:template name="print_JCGN_toc_item">
		<xsl:variable name="margin-left">5</xsl:variable>
		<fo:block>
			<xsl:if test="@level = 1">
				<xsl:attribute name="margin-top">12pt</xsl:attribute>
			</xsl:if>
			<fo:list-block>
				<xsl:attribute name="margin-left"><xsl:value-of select="$margin-left * (@level - 1)"/>mm</xsl:attribute>
				<xsl:attribute name="provisional-distance-between-starts">
					<xsl:choose>
						<!-- skip 0 section without subsections -->
						<xsl:when test="@level = 2"><xsl:value-of select="$margin-left * 1.6"/>mm</xsl:when>
						<xsl:when test="@level &gt;= 3"><xsl:value-of select="$margin-left * 1.8"/>mm</xsl:when>
						<xsl:when test="@level = 1 and @type = 'annex' and @section != ''"><xsl:value-of select="$margin-left + string-length(@section) * 1.7"/>mm</xsl:when>
						<xsl:when test="@section != ''"><xsl:value-of select="$margin-left"/>mm</xsl:when>
						<xsl:otherwise>0mm</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<fo:list-item>
					<fo:list-item-label end-indent="label-end()">
						<fo:block font-weight="bold">														
								<xsl:value-of select="@section"/>
						</fo:block>
					</fo:list-item-label>
					<fo:list-item-body start-indent="body-start()">
						<fo:block text-align-last="justify" margin-left="12mm" text-indent="-12mm">
							<fo:basic-link internal-destination="{@id}" fox:alt-text="{title}">
								<fo:inline>
									<xsl:if test="@level = 1">
										<xsl:attribute name="font-weight">bold</xsl:attribute>
									</xsl:if>
									<xsl:apply-templates select="title"/>
								</fo:inline>
								<xsl:text> </xsl:text>
								<fo:inline keep-together.within-line="always" font-weight="normal">
									<fo:leader font-size="9pt" leader-pattern="dots"/>
									<fo:inline><fo:page-number-citation ref-id="{@id}"/></fo:inline>
								</fo:inline>
							</fo:basic-link>
						</fo:block>
					</fo:list-item-body>
				</fo:list-item>
			</fo:list-block>
		</fo:block>
	</xsl:template>

	
	<xsl:variable name="header_text">
		<xsl:value-of select="(//jcgm:bipm-standard)[1]/jcgm:bibdata/jcgm:ext/jcgm:editorialgroup/jcgm:committee/@acronym"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="(//jcgm:bipm-standard)[1]/jcgm:bibdata/jcgm:docnumber"/>
		<xsl:text>:</xsl:text>
		<xsl:value-of select="(//jcgm:bipm-standard)[1]/jcgm:bibdata/jcgm:copyright/jcgm:from"/>
	</xsl:variable>
	
	<xsl:template name="insertHeaderFooter">
		<xsl:param name="isDraft"/>
		<fo:static-content flow-name="header-even-jcgm" role="artifact">
			<xsl:call-template name="insertDraftWatermark">
				<xsl:with-param name="isDraft" select="$isDraft"/>
			</xsl:call-template>
			<fo:block-container height="98%">
				<fo:block font-size="13pt" font-weight="bold" padding-top="12mm">
					<xsl:value-of select="$header_text"/>
				</fo:block>
			</fo:block-container>
		</fo:static-content>
		<fo:static-content flow-name="footer-even-jcgm" role="artifact">
			<fo:block-container height="98%">
				<fo:block text-align-last="justify">
					<fo:inline font-size="12pt" font-weight="bold"><fo:page-number/></fo:inline>
					<fo:inline keep-together.within-line="always">
						<fo:leader leader-pattern="space"/>
						<fo:inline font-size="10pt"><xsl:value-of select="$copyrightText"/></fo:inline>
					</fo:inline>
				</fo:block>
			</fo:block-container>
		</fo:static-content>
		<fo:static-content flow-name="header-odd-jcgm" role="artifact">
			<xsl:call-template name="insertDraftWatermark">
				<xsl:with-param name="isDraft" select="$isDraft"/>
			</xsl:call-template>
			<fo:block-container height="98%">
				<fo:block font-size="13pt" font-weight="bold" text-align="right" padding-top="12mm">
					<xsl:value-of select="$header_text"/>
				</fo:block>
			</fo:block-container>
		</fo:static-content>
		<fo:static-content flow-name="footer-odd-jcgm" role="artifact">
			<fo:block-container height="98%">
				<fo:block text-align-last="justify">
					<fo:inline font-size="10pt"><xsl:value-of select="$copyrightText"/></fo:inline>
					<fo:inline keep-together.within-line="always">
						<fo:leader leader-pattern="space"/>
						<fo:inline font-size="12pt" font-weight="bold"><fo:page-number/></fo:inline>
					</fo:inline>
				</fo:block>
			</fo:block-container>
		</fo:static-content>
		<fo:static-content flow-name="header-blank" role="artifact">
			<xsl:call-template name="insertDraftWatermark">
				<xsl:with-param name="isDraft" select="$isDraft"/>
			</xsl:call-template>
			<fo:block/>
		</fo:static-content>
	</xsl:template>
	
	<xsl:template name="insertDraftWatermark">
		<xsl:param name="isDraft"/>
		<xsl:if test="$isDraft = 'true' or normalize-space(//jcgm:bipm-standard/jcgm:bibdata/jcgm:version/jcgm:draft or   contains(//jcgm:bipm-standard/jcgm:bibdata/jcgm:status/jcgm:stage, 'draft') or   contains(//jcgm:bipm-standard/jcgm:bibdata/jcgm:status/jcgm:stage, 'projet')) = 'true'">
			<!-- DRAFT -->
			<xsl:variable name="draft_label">
				<xsl:call-template name="getLocalizedString">
					<xsl:with-param name="key">draft_label</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>
			<fo:block-container absolute-position="fixed" left="0mm" top="30mm">
				<fo:block line-height="0">
					<fo:instream-foreign-object fox:alt-text="DRAFT">
							<svg:svg xmlns:svg="http://www.w3.org/2000/svg" width="200mm" height="250mm">
								<svg:g transform="rotate(-45) scale(0.6, 1)">
									<xsl:variable name="font-size">
										<xsl:choose>
											<xsl:when test="string-length($draft_label) &gt; 5">150</xsl:when>
											<xsl:otherwise>260</xsl:otherwise>
										</xsl:choose>
									</xsl:variable>
										<svg:text x="-175mm" y="205mm" style="font-family:Arial;font-size:{$font-size}pt;font-weight:normal;fill:rgb(223, 223, 223);">
											<xsl:if test="string-length($draft_label) &gt; 5">
												<xsl:attribute name="x">-175mm</xsl:attribute>
												<xsl:attribute name="y">180mm</xsl:attribute>
											</xsl:if>
											<xsl:value-of select="java:toUpperCase(java:java.lang.String.new($draft_label))"/>
										</svg:text>
								</svg:g>
							</svg:svg>
					</fo:instream-foreign-object>
				</fo:block>
			</fo:block-container>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="jcgm:title" name="title">
	
		<xsl:variable name="level">
			<xsl:call-template name="getLevel"/>
		</xsl:variable>
		
		<xsl:variable name="font-size">
			<xsl:choose>
				<xsl:when test="ancestor::jcgm:preface">15pt</xsl:when>
				<xsl:when test="parent::jcgm:annex">15pt</xsl:when>
				<xsl:when test="../@inline-header = 'true'  or @inline-header = 'true'">10.5pt</xsl:when>
				<xsl:when test="$level = 2">11.5pt</xsl:when>
				<xsl:when test="$level &gt;= 3">10.5pt</xsl:when>
				<xsl:otherwise>13pt</xsl:otherwise><!-- level 1 -->
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="element-name">
			<xsl:choose>
				<xsl:when test="../@inline-header = 'true' or @inline-header = 'true'">fo:inline</xsl:when>
				<xsl:otherwise>fo:block</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
			<xsl:element name="{$element-name}">
				<xsl:attribute name="font-size"><xsl:value-of select="$font-size"/></xsl:attribute>
				<xsl:attribute name="font-weight">bold</xsl:attribute>
				<xsl:attribute name="space-before"> <!-- margin-top -->
					<xsl:choose>
						
						<xsl:when test="$level = 1 and parent::jcgm:annex">0pt</xsl:when>
						<xsl:when test="$level = 1">36pt</xsl:when>
						<xsl:when test="$level = 2">18pt</xsl:when>
						<xsl:when test="$level &gt;= 3">3pt</xsl:when>
						<xsl:when test="$level = ''">6pt</xsl:when><!-- 13.5pt -->
						<xsl:otherwise>12pt</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:attribute name="space-after">
					<xsl:choose>
						<xsl:when test="ancestor::jcgm:preface">12pt</xsl:when>
						<xsl:when test="parent::jcgm:annex">30pt</xsl:when>
						<xsl:when test="following-sibling::*[1][local-name() = 'admitted']">0pt</xsl:when>
						<!-- <xsl:otherwise>12pt</xsl:otherwise> -->
						<xsl:otherwise>12pt</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:attribute name="keep-with-next">always</xsl:attribute>		
				<xsl:if test="$element-name = 'fo:inline'">
					<xsl:attribute name="padding-right">
						<xsl:choose>
							<xsl:when test="$level = 3">6.5mm</xsl:when>
							<xsl:otherwise>4mm</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
				</xsl:if>
				<xsl:if test="parent::jcgm:annex">
					<xsl:attribute name="text-align">center</xsl:attribute>
					<xsl:attribute name="line-height">130%</xsl:attribute>
				</xsl:if>
				<xsl:attribute name="role">H<xsl:value-of select="$level"/></xsl:attribute>
				<xsl:apply-templates/>
				<xsl:apply-templates select="following-sibling::*[1][local-name() = 'variant-title'][@type = 'sub']" mode="subtitle"/>
			</xsl:element>
			
			<xsl:if test="$element-name = 'fo:inline' and not(following-sibling::jcgm:p)">
				<fo:block> <!-- margin-bottom="12pt" -->
					<xsl:value-of select="$linebreak"/>
				</fo:block>
			</xsl:if>
			
		
	</xsl:template>

	<xsl:template match="jcgm:bipm-standard/jcgm:bibdata/jcgm:edition">
		<xsl:param name="font-size" select="'65%'"/>
		<xsl:param name="baseline-shift" select="'30%'"/>
		<xsl:param name="curr_lang" select="'fr'"/>
		<xsl:if test="normalize-space (.) != '1'"> <!-- no need to show '1st edition' --> 
			<fo:inline>
				<xsl:value-of select="."/>
				<fo:inline font-size="{$font-size}" baseline-shift="{$baseline-shift}">
					<xsl:if test="$curr_lang = 'en'">
						<xsl:attribute name="baseline-shift">0%</xsl:attribute>
						<xsl:attribute name="font-size">100%</xsl:attribute>
					</xsl:if>
					<xsl:call-template name="number-to-ordinal">
						<xsl:with-param name="number" select="."/>
						<xsl:with-param name="curr_lang" select="$curr_lang"/>
					</xsl:call-template>
				</fo:inline>
				<xsl:text> </xsl:text>			
				<xsl:call-template name="getLocalizedString">
					<xsl:with-param name="key">edition</xsl:with-param>
				</xsl:call-template>
				<xsl:text/>
			</fo:inline>
		</xsl:if>
	</xsl:template>


	<!-- =================== -->
	<!-- Index processing -->
	<!-- =================== -->
	
	<!-- <xsl:template match="jcgm:clause[@type = 'index']" />
	<xsl:template match="jcgm:clause[@type = 'index']" mode="index"> -->
	<xsl:template match="jcgm:indexsect"/>
	<xsl:template match="jcgm:indexsect" mode="index">
	
		<fo:page-sequence master-reference="document-jcgm" force-page-count="no-force">
			<xsl:variable name="header-title">
				<xsl:choose>
					<xsl:when test="./jcgm:title[1]/*[local-name() = 'tab']">
						<xsl:apply-templates select="./jcgm:title[1]/*[local-name() = 'tab'][1]/following-sibling::node()" mode="header"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="./jcgm:title[1]" mode="header"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<xsl:call-template name="insertHeaderFooter"/>
			
			<fo:flow flow-name="xsl-region-body">
				<fo:block id="{@id}" span="all">
					<xsl:apply-templates select="jcgm:title"/>
				</fo:block>
				<fo:block role="Index">
					<xsl:apply-templates select="*[not(local-name() = 'title')]"/>
				</fo:block>
			</fo:flow>
		</fo:page-sequence>
	</xsl:template>
	
	
	<!-- =================== -->
	<!-- End of Index processing -->
	<!-- =================== -->
	
	
	<xsl:template match="jcgm:xref" priority="2">
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
					<fo:inline><xsl:apply-templates/></fo:inline>
				</xsl:otherwise>
			</xsl:choose>
		</fo:basic-link>
	</xsl:template>

	<!-- =================== -->
	<!-- Two columns layout -->
	<!-- =================== -->
	
	<!-- <xsl:template match="*[@first]/*[local-name()='sections']//*[not(@cross-align) or not(@cross-align='true')]" mode="multi_columns"/> -->
	
	<xsl:template match="*[@first]/*[local-name()='sections']//*[local-name() = 'cross-align'] | *[@first]/*[local-name()='annex']//*[local-name() = 'cross-align']" mode="multi_columns">
		<xsl:variable name="element-number" select="@element-number"/>
		<fo:block>
				<xsl:copy-of select="@keep-with-next"/>
			<fo:table table-layout="fixed" width="100%">
				<fo:table-column column-width="{$column_width}mm"/>
				<xsl:for-each select="xalan:nodeset($docs_slave)/*">
					<fo:table-column column-width="{$column_gap}mm"/>
					<fo:table-column column-width="{$column_width}mm"/>
				</xsl:for-each>
				<fo:table-body>
					<fo:table-row>
						<fo:table-cell>
							<fo:block font-size="1pt" keep-with-next="always"/>
							<fo:block>
								<xsl:copy-of select="@keep-with-next"/>
								<xsl:apply-templates select="."/>
							</fo:block>
							<fo:block font-size="1pt"/>
						</fo:table-cell>
						<xsl:variable name="keep-with-next" select="@keep-with-next"/>
						<xsl:for-each select="xalan:nodeset($docs_slave)/*">
							<fo:table-cell>
								<fo:block/>
							</fo:table-cell>
							<fo:table-cell>
								<fo:block font-size="1pt" keep-with-next="always"/>
								<fo:block>
									<xsl:if test="$keep-with-next != ''">
										<xsl:attribute name="keep-with-next"><xsl:value-of select="$keep-with-next"/></xsl:attribute>
									</xsl:if>
									<xsl:apply-templates select=".//*[local-name() = 'cross-align' and @element-number=$element-number]"/>
								</fo:block>
								<fo:block font-size="1pt"/>
							</fo:table-cell>
						</xsl:for-each>
					</fo:table-row>
				</fo:table-body>
			</fo:table>
		</fo:block>
	</xsl:template>
	
	<xsl:template match="*[local-name() = 'cross-align']" priority="3">
		<xsl:apply-templates/>
	</xsl:template>
	
	<!-- no display table/figure from slave documents if @multilingual-rendering="common" or @multilingual-rendering = 'all-columns' -->
	<xsl:template match="*[@slave]//*[local-name()='table'][@multilingual-rendering= 'common']" priority="2"/>
	<xsl:template match="*[@slave]//*[local-name()='table'][@multilingual-rendering = 'all-columns']" priority="2"/>
	<xsl:template match="*[@slave]//*[local-name()='figure'][@multilingual-rendering = 'common']" priority="2"/>
	<xsl:template match="*[@slave]//*[local-name()='figure'][@multilingual-rendering = 'all-columns']" priority="2"/>
	
	<!-- for table and figure with @multilingual-rendering="common" -->
	<!-- display only element from first document -->
	<xsl:template match="*[@first]//*[local-name() = 'cross-align'][@multilingual-rendering = 'common']" mode="multi_columns">
		<fo:block>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	
	<!-- for table and figure with @multilingual-rendering = 'all-columns' -->
	<!-- display element from first document, then (after) from 2nd one, then 3rd, etc. -->
	<xsl:template match="*[@first]//*[local-name() = 'cross-align'][@multilingual-rendering = 'all-columns']" mode="multi_columns">
		<xsl:variable name="element-number" select="@element-number"/>
		<fo:block>
			<xsl:apply-templates/>
			<fo:block> </fo:block>
			<xsl:choose>
				<xsl:when test="local-name(*[@multilingual-rendering = 'all-columns']) = 'table'">
					<xsl:for-each select="xalan:nodeset($docs_slave)/*">
						<xsl:for-each select=".//*[local-name() = 'table' and @element-number=$element-number]">
							<xsl:call-template name="table"/>
						</xsl:for-each>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="local-name(*[@multilingual-rendering = 'all-columns']) = 'figure'">
					<xsl:for-each select="xalan:nodeset($docs_slave)/*">
						<xsl:for-each select=".//*[local-name() = 'figure' and @element-number=$element-number]">
							<xsl:call-template name="figure"/>
						</xsl:for-each>
					</xsl:for-each>
				</xsl:when>
			</xsl:choose>
		</fo:block>
	</xsl:template>
	
	<!-- =========== -->
	<!-- References -->
	<xsl:template match="*[@first]//*[local-name()='references'][@normative='true']" mode="multi_columns">
		<fo:block font-size="1pt" keep-with-next="always">
			<fo:inline id="{@id}"/> 
			<xsl:for-each select="xalan:nodeset($docs_slave)/*">
				<fo:inline id="{.//*[local-name()='references'][@normative='true']/@id}"/>
			</xsl:for-each>
		</fo:block>
    <xsl:apply-templates mode="multi_columns"/>
	</xsl:template>
	
	<xsl:template match="*[@first]//*[local-name()='references'][@normative='true']/*" mode="multi_columns">
		<xsl:variable name="number_"><xsl:number count="*"/></xsl:variable>
		<xsl:variable name="number" select="number(normalize-space($number_))"/>
		<fo:block>
			<fo:table table-layout="fixed" width="100%">
				<fo:table-column column-width="{$column_width}mm"/>
				<xsl:for-each select="xalan:nodeset($docs_slave)/*">
					<fo:table-column column-width="{$column_gap}mm"/>
					<fo:table-column column-width="{$column_width}mm"/>
				</xsl:for-each>
				<fo:table-body>
					<fo:table-row>
						<fo:table-cell>
							<fo:block font-size="1pt"/>
							<xsl:apply-templates select="."/>
							<fo:block font-size="1pt"/>
						</fo:table-cell>
						
						<xsl:for-each select="xalan:nodeset($docs_slave)/*">
							<fo:table-cell>
								<fo:block/>
							</fo:table-cell>
							<fo:table-cell>
								<fo:block>
									<fo:block font-size="1pt"/>
									<xsl:apply-templates select="(.//*[local-name()='references'][@normative='true']/*)[$number]"/>
									<fo:block font-size="1pt"/>
								</fo:block>
							</fo:table-cell>
						</xsl:for-each>
					</fo:table-row>
				</fo:table-body>
			</fo:table>
		</fo:block>
	</xsl:template>
	
  <xsl:template match="*[@first]//*[local-name()='references'][not(@normative='true')]" mode="multi_columns">
		<fo:block break-after="page"/>
		<fo:block font-size="1pt"><fo:inline id="{@id}"/>
			<xsl:for-each select="xalan:nodeset($docs_slave)/*">
				<fo:inline id="{.//*[local-name()='references'][not(@normative='true')]/@id}"/>
			</xsl:for-each>
		</fo:block>
    <xsl:apply-templates mode="multi_columns"/>
	</xsl:template>
  
  <xsl:template match="*[@first]//*[local-name()='references'][not(@normative='true')]/*" mode="multi_columns">
    <xsl:variable name="number_"><xsl:number count="*"/></xsl:variable>
		<xsl:variable name="number" select="number(normalize-space($number_))"/>
		<fo:block>
			<fo:table table-layout="fixed" width="100%">
				<fo:table-column column-width="{$column_width}mm"/>
				<xsl:for-each select="xalan:nodeset($docs_slave)/*">
					<fo:table-column column-width="{$column_gap}mm"/>
					<fo:table-column column-width="{$column_width}mm"/>
				</xsl:for-each>
				<fo:table-body>
					<fo:table-row>
						<fo:table-cell>
							<xsl:apply-templates select="."/>
							<fo:block font-size="1pt"/>
						</fo:table-cell>
						
						<xsl:for-each select="xalan:nodeset($docs_slave)/*">
							<fo:table-cell>
								<fo:block/>
							</fo:table-cell>
							<fo:table-cell>
								<fo:block>
									<xsl:apply-templates select="(.//*[local-name()='references'][not(@normative='true')]/*)[$number]"/>
									<fo:block font-size="1pt"/>
								</fo:block>
							</fo:table-cell>
						</xsl:for-each>
					</fo:table-row>
				</fo:table-body>
			</fo:table>
		</fo:block>
	</xsl:template>
	<!-- End of References -->

	<xsl:template match="*[@first]//*[local-name()='annex']" mode="multi_columns">
    <xsl:variable name="number_"><xsl:number/></xsl:variable>
		<xsl:variable name="number" select="number(normalize-space($number_))"/>
    <fo:block break-after="page"/>
		<fo:block font-size="1pt"><fo:inline id="{@id}"/>
			<xsl:for-each select="xalan:nodeset($docs_slave)/*">
				<fo:inline id="{(.//*[local-name()='annex'])[$number]/@id}"/>
			</xsl:for-each>
		</fo:block>
    <xsl:apply-templates mode="multi_columns"/>
  </xsl:template>
	
	<!-- =================== -->
	<!-- End Two columns layout -->
	<!-- =================== -->


	<!-- ================================= -->
	<!-- Flattening xml for two columns -->
	<!-- ================================= -->	
	
	<!-- ================================= -->	
	<!-- First step -->
	<!-- ================================= -->	
	<xsl:template match="@*|node()" mode="flatxml_step1">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="flatxml_step1"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="*[contains(local-name(), '-standard')]" mode="flatxml_step1">
		<xsl:param name="num"/>
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="flatxml_step1"/>
			<xsl:attribute name="{$num}"/>
			<xsl:apply-templates select="node()" mode="flatxml_step1"/>
		</xsl:copy>
	</xsl:template>
	
	<!-- enclose clause[@type='scope'] into scope -->
	<xsl:template match="*[local-name()='sections']/*[local-name()='clause'][@type='scope']" mode="flatxml_step1" priority="2">
		<!-- <section_scope>
			<clause @type=scope>...
		</section_scope> -->
		<xsl:element name="section_scope" namespace="https://www.metanorma.org/ns/bipm">
			<xsl:call-template name="clause"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="jcgm:sections//jcgm:clause | jcgm:annex//jcgm:clause" mode="flatxml_step1" name="clause">
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
			<xsl:apply-templates select="@*" mode="flatxml_step1"/>
			<xsl:call-template name="setCrossAlignAttributes"/>
		</xsl:copy>
		<xsl:apply-templates mode="flatxml_step1"/>
	</xsl:template>
	
	<!-- allow cross-align for element title -->
	<xsl:template match="jcgm:sections//jcgm:title | jcgm:annex//jcgm:title" mode="flatxml_step1">
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="flatxml_step1"/>
			<xsl:call-template name="setCrossAlignAttributes"/>
			<xsl:attribute name="keep-with-next">always</xsl:attribute>
			<xsl:if test="parent::jcgm:annex">
				<xsl:attribute name="depth">1</xsl:attribute>
			</xsl:if>
			<xsl:if test="../@inline-header = 'true'">
				<xsl:copy-of select="../@inline-header"/>
			</xsl:if>
			<xsl:apply-templates mode="flatxml_step1"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="*[local-name()='annex']" mode="flatxml_step1">
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="flatxml_step1"/>
			<!-- create empty element for case if first element isn't cross-align -->
			<xsl:element name="empty" namespace="https://www.metanorma.org/ns/bipm">
				<xsl:attribute name="cross-align">true</xsl:attribute>
				<xsl:attribute name="element-number">empty_annex<xsl:number/></xsl:attribute>
			</xsl:element>
			<xsl:apply-templates mode="flatxml_step1"/>
		</xsl:copy>
	</xsl:template>
	
	
	<xsl:template match="*[local-name()='sections']//*[local-name()='terms']" mode="flatxml_step1" priority="2">
		<!-- From:
		<terms>
			<term>...</term>
			<term>...</term>
		</terms>
		To:
		<section_terms>
			<terms>...</terms>
		</section_terms> -->
		<xsl:element name="section_terms" namespace="https://www.metanorma.org/ns/bipm">
			<!-- create empty element for case if first element isn't cross-align -->
			<xsl:element name="empty" namespace="https://www.metanorma.org/ns/bipm">
				<xsl:attribute name="cross-align">true</xsl:attribute>
				<xsl:attribute name="element-number">empty_terms_<xsl:number/></xsl:attribute>
			</xsl:element>
			<xsl:call-template name="terms"/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="*[local-name()='sections']//*[local-name()='definitions']" mode="flatxml_step1" priority="2">
		<xsl:element name="section_terms" namespace="https://www.metanorma.org/ns/bipm">
			<xsl:call-template name="terms"/>
		</xsl:element>
	</xsl:template>
	
	
	<!-- From:
	<terms>
		<term>...</term>
		<term>...</term>
	</terms>
	To:
	<terms/>
	<term>...</term>
	<term>...</term>-->
	<!-- And
	From:
	<term>
		<name>...</name>
		<preferred>...</preferred>
		<definition>...</definition>
		<termsource>...</termsource>
	</term>
	To:
	<term/>
	<term_name>...</term_name>
	<preferred>...</preferred>
	<definition>...</definition>
	<termsource>...</termsource>
	-->
	<xsl:template match="jcgm:sections//jcgm:terms | jcgm:annex//jcgm:terms |                   jcgm:sections//jcgm:term | jcgm:annex//jcgm:term" mode="flatxml_step1" name="terms">
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="flatxml_step1"/>
			<xsl:attribute name="keep-with-next">always</xsl:attribute>
			<xsl:call-template name="setCrossAlignAttributes"/>
		</xsl:copy>
		<xsl:apply-templates mode="flatxml_step1"/>
	</xsl:template>
	
	<!-- From:
	<term><name>...</name></term>
	To:
	<term><term_name>...</term_name></term> -->
	<xsl:template match="jcgm:term/jcgm:name" mode="flatxml_step1">
		<xsl:element name="term_name" namespace="https://www.metanorma.org/ns/bipm">
			<xsl:apply-templates select="@*" mode="flatxml_step1"/>
			<xsl:call-template name="setCrossAlignAttributes"/>
			<xsl:apply-templates mode="flatxml_step1"/>
		</xsl:element>
	</xsl:template>
	
	<!-- From:
	<ul>
	 <li>...</li>
	 <li>...</li>
	</ul>
	To:
	<ul/
	<li>...</li>
	<li>...</li> -->
	<xsl:template match="jcgm:sections//jcgm:ul | jcgm:annex//jcgm:ul | jcgm:sections//jcgm:ol | jcgm:annex//jcgm:ol" mode="flatxml_step1">
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="flatxml_step1"/>
			<xsl:attribute name="keep-with-next">always</xsl:attribute>
			<xsl:call-template name="setCrossAlignAttributes"/>
		</xsl:copy>
		<xsl:apply-templates mode="flatxml_step1"/>
	</xsl:template>
	
	
	<!-- allow cross-align for element p, note, termsource, table, figure,  li (and set label)  -->
	<xsl:template match="jcgm:sections//jcgm:p |                   jcgm:sections//jcgm:note |                   jcgm:sections//jcgm:termsource |                  jcgm:sections//jcgm:li |                  jcgm:table |                  jcgm:figure |                  jcgm:annex//jcgm:p |                   jcgm:annex//jcgm:note |                  jcgm:annex//jcgm:termsource |                  jcgm:annex//jcgm:li" mode="flatxml_step1">
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="flatxml_step1"/>
			<xsl:call-template name="setCrossAlignAttributes"/>
			<xsl:if test="local-name() = 'li'">
				<xsl:call-template name="setListItemLabel"/>
			</xsl:if>
			<xsl:apply-templates mode="flatxml_step1"/>
		</xsl:copy>
	</xsl:template>
	
	
	<xsl:template name="setCrossAlignAttributes">
		<xsl:variable name="is_cross_aligned">
			<xsl:call-template name="isCrossAligned"/>
		</xsl:variable>
		<xsl:if test="normalize-space($is_cross_aligned) = 'true'">
			<xsl:attribute name="cross-align">true</xsl:attribute>
			<!-- <xsl:attribute name="keep-with-next">always</xsl:attribute> -->
		</xsl:if>
		<xsl:call-template name="setElementNumber"/>
	</xsl:template>
	
	<!--
		Elements that should be aligned:
			- name of element presents in field align-cross-elements="clause note"
			- marked with attribute name
			- table/figure with attribute @multilingual-rendering = 'common' or @multilingual-rendering = 'all-columns'
			- marked with attribute cross-align
  -->
	<xsl:template name="isCrossAligned">
		<xsl:variable name="element_name" select="local-name()"/>
		<xsl:choose>
			<!-- if element`s name is presents in array align_cross_elements -->
			<xsl:when test="contains($align_cross_elements, concat('#',$element_name,'#'))">true</xsl:when>
			<!-- if element has attribute name/bookmark -->
			<xsl:when test="normalize-space(@name) != '' and @multilingual-rendering = 'name'">true</xsl:when>
			<xsl:when test="($element_name = 'table' or $element_name = 'figure') and (@multilingual-rendering = 'common' or @multilingual-rendering = 'all-columns')">true</xsl:when>
			<!-- element marked as cross-align -->
			<xsl:when test="@multilingual-rendering='parallel'">true</xsl:when>
			<xsl:otherwise>false</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- calculate element number in tree to find a match between documents -->
	<xsl:template name="setElementNumber">
		<xsl:variable name="element-number">
			<xsl:choose>
				<!-- if name set, then use it -->
				<xsl:when test="@name and @multilingual-rendering = 'name'"><xsl:value-of select="@name"/></xsl:when>
				<xsl:otherwise>
					<xsl:for-each select="ancestor-or-self::*[ancestor-or-self::*[local-name() = 'sections' or local-name() = 'annex']]">
						<xsl:value-of select="local-name()"/>
						<xsl:choose>
							<xsl:when test="local-name() = 'terms'"/>
							<xsl:when test="local-name() = 'sections'"/>
							<xsl:otherwise><xsl:number/></xsl:otherwise>
						</xsl:choose>
						<xsl:text>_</xsl:text>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:attribute name="element-number">
			<xsl:value-of select="normalize-space($element-number)"/>
		</xsl:attribute>
	</xsl:template>
	<!-- ================================= -->	
	<!-- End First step -->
	<!-- ================================= -->	
	
	<!-- ================================= -->	
	<!-- Second step -->
	<!-- ================================= -->	
	<xsl:template match="@*|node()" mode="flatxml_step2">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="flatxml_step2"/>
		</xsl:copy>
	</xsl:template>
	
	<!-- enclose elements after table/figure with @multilingual-rendering = 'common' and @multilingual-rendering = 'all-columns' in a separate element cross-align -->
	<xsl:template match="*[@multilingual-rendering = 'common' or @multilingual-rendering = 'all-columns']" mode="flatxml_step2" priority="2">
		<xsl:variable name="curr_id" select="generate-id()"/>
		<xsl:element name="cross-align" namespace="https://www.metanorma.org/ns/bipm">
			<xsl:copy-of select="@element-number"/>
			<xsl:copy-of select="@multilingual-rendering"/>
			<xsl:copy-of select="."/>
		</xsl:element>
		<xsl:if test="following-sibling::*[(not(@cross-align) or not(@cross-align='true')) and preceding-sibling::*[@cross-align='true'][1][generate-id() = $curr_id]]">
			<xsl:element name="cross-align" namespace="https://www.metanorma.org/ns/bipm">
				<!-- <xsl:copy-of select="following-sibling::*[(not(@cross-align) or not(@cross-align='true')) and preceding-sibling::*[@cross-align='true'][1][generate-id() = $curr_id]][1]/@element-number"/> -->
				<xsl:for-each select="following-sibling::*[(not(@cross-align) or not(@cross-align='true')) and preceding-sibling::*[@cross-align='true'][1][generate-id() = $curr_id]]">
					<xsl:if test="position() = 1">
						<xsl:copy-of select="@element-number"/>
					</xsl:if>
					<xsl:copy-of select="."/>
				</xsl:for-each>
			</xsl:element>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="*[@cross-align='true']" mode="flatxml_step2">
		<xsl:variable name="curr_id" select="generate-id()"/>
		<xsl:element name="cross-align" namespace="https://www.metanorma.org/ns/bipm">
			<xsl:copy-of select="@element-number"/>
			<xsl:if test="local-name() = 'clause'">
				<xsl:copy-of select="@keep-with-next"/>
			</xsl:if>
			<xsl:if test="local-name() = 'title'">
				<xsl:copy-of select="@keep-with-next"/>
			</xsl:if>
			<xsl:copy-of select="@multilingual-rendering"/>
			<xsl:copy-of select="."/>
			
			<!-- copy next elements until next element with cross-align=true -->
			<xsl:for-each select="following-sibling::*[(not(@cross-align) or not(@cross-align='true')) and preceding-sibling::*[@cross-align='true'][1][generate-id() = $curr_id]]">
				<xsl:copy-of select="."/>
			</xsl:for-each>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="*[preceding-sibling::*[@cross-align='true']][not(@cross-align) or not(@cross-align='true')]" mode="flatxml_step2"/>
	
	<!-- ================================= -->	
	<!-- End Second step -->
	<!-- ================================= -->		
	<!-- ================================= -->
	<!-- End Flattening xml for two columns -->
	<!-- ================================= -->	
	
	<xsl:template name="insert_Logo-BIPM-Metro">
		<fo:block-container absolute-position="fixed" left="21mm" top="52mm">
			<fo:block>
				<fo:instream-foreign-object content-width="170mm" fox:alt-text="Image Logo">								
					<svg xmlns="http://www.w3.org/2000/svg" height="547.66" width="547.66" version="1.0">
						<path id="path4" d="m543.54 276.94a276.23 276.23 0 1 1 -552.47 0 276.23 276.23 0 1 1 552.47 0z" transform="matrix(.95831 0 0 .95831 17.669 8.4373)" fill="#fff"/>
						 <path id="path6" d="m382 55.094c-2.56 0-7.13 3.091-7.91 5.344-1.88 5.447-2.31 5.759-1.81 1.312 0.32-2.85 0.14-4.688-0.47-4.688-2.15 0-6.03 2.346-6.03 3.657 0 0.988-0.64 1.191-2.22 0.687-4.12-1.314-5.15-0.987-5.47 1.75-0.16 1.461 0.23 3.597 0.85 4.75 0.92 1.723 0.79 2.38-0.69 3.5-0.99 0.75-2.98 1.358-4.44 1.375-3.34 0.04-4.08 1.18-2.28 3.563 1.98 2.616 1.81 4.344-0.44 4.344-1.05 0-2.17 0.416-2.5 0.937-0.36 0.596-33.67 0.916-90.06 0.844-82.35-0.106-89.47-0.26-89.47-1.75 0-1.939-1.85-3.969-3.62-3.969-0.71 0-1.31 0.772-1.32 1.719 0 0.947-0.37 2.298-0.84 3.031-0.49 0.774-0.64-1.666-0.34-5.812 0.5-6.969 0.47-7.112-1.63-6.563-1.78 0.467-2.29 0.077-2.78-2.375-1.05-5.272-5.15-4.555-5.19 0.906-0.01 2.427-1.12 2.744-4.03 1.188-1.33-0.711-2.52-0.695-3.93 0.062l-2.04 1.063 1.97 3.312c2.08 3.518 1.88 4.438-1 4.438-2.27 0-2.32 1.74-0.09 4.281 1.61 1.837 1.61 1.92 0.03 1.344-1.57-0.571-4.73 1.495-4.69 3.062 0.01 0.367 1.42 1.65 3.13 2.844l3.12 2.156-2.59 0.969c-2.98 1.134-4.92 4.21-4.06 6.437 0.76 1.988 5.9 2.038 6.65 0.063 0.81-2.113 2.25-1.806 2.88 0.594 0.4 1.561 1.05 1.891 2.59 1.411 1.47-0.47 2.03-0.24 2.03 0.87 0 0.85 0.59 1.56 1.31 1.56 2.14 0 4.64-3.438 5.26-7.216 0.71-4.436 3.15-5.477 5.62-2.438 1.02 1.251 2.55 3.165 3.44 4.25 0.88 1.085 2.71 2.704 4.09 3.594 3 1.93 4.29 6.75 6.38 23.94 0.79 6.5 2.47 14.74 3.71 18.34 2.3 6.64 7.35 15.6 8.79 15.6 0.43 0 0.75 0.48 0.75 1.09s0.79 1.84 1.75 2.72c2.04 1.88 7.53 9.13 7.71 10.19 0.07 0.4 0.27 5.06 0.41 10.34l0.25 9.59 0.72-7.12c0.85-8.07 1.56-10.46 2.81-9.69 0.48 0.29 1.2 1.98 1.6 3.75 1.61 7.17 2.93 36.36 1.43 31.75-0.52-1.62-0.85-4.58-0.75-6.59 0.11-2.02-0.12-3.97-0.5-4.35-1.93-1.93-0.29 22.53 1.94 28.85 0.48 1.35 0.35 1.49-0.56 0.65-0.66-0.6-1.81-6.12-2.59-12.28-2.86-22.5-2.99-23.12-3.85-21.19-0.48 1.08 0.02 7.74 1.19 16.22 1.09 7.93 1.83 14.58 1.66 14.78-0.18 0.2-2.01 0.05-4.07-0.37-3.7-0.77-3.71-0.81-0.9-1.38l2.81-0.56-4.28-4.66c-5.51-5.94-10.39-8-16.75-7.12l-4.78 0.66v-4.04c0-2.21 0.4-4.03 0.9-4.03s2.31-1.2 4.03-2.65c2.79-2.35 3.09-3.05 2.63-6.5-0.35-2.57-1.6-4.97-3.69-7.13l-3.12-3.28 3.06-3.91c3.29-4.15 3.83-6.44 1.84-7.71-2.35-1.51-8.11-3.24-10.84-3.25-3.68-0.02-7.98 4.18-7.1 6.96 0.58 1.8 0.42 1.95-1.34 1-2.83-1.51-6.21-1.31-8.81 0.5-2.11 1.48-2.41 1.41-4.81-1-1.4-1.4-3.51-2.53-4.72-2.53-8.22 0-17.78 11.67-10.32 12.6 1.35 0.17 4.34 1.01 6.66 1.87 4.2 1.56 4.22 1.57 2.34 3.63-3 3.3-4.29 6.47-3.65 9 0.81 3.21 6.27 9.28 8.37 9.28 1.57 0 4.94 2.84 4.94 4.15 0 0.31-1.2 0.86-2.69 1.22-4.9 1.21-11.85 6.72-13.75 10.88-0.98 2.16-3.11 6.27-4.72 9.12-2.38 4.25-3.36 5.14-5.37 5-2.59-0.17-5.55 0.81-7.66 2.54-0.69 0.56-1.84 1.49-2.53 2.03-0.68 0.54-2.64 2.28-4.34 3.84l-3.1 2.81-6.09-5.28c-4.892-4.24-6.849-6.83-9.842-13.16-2.583-5.45-4.963-8.9-7.719-11.15-2.288-1.87-3.969-4.1-3.969-5.25 0-1.19-0.819-2.22-2-2.53-1.382-0.36-1.825-1.06-1.438-2.28 0.308-0.97 0.127-2.06-0.437-2.41-0.599-0.37-0.815-2.15-0.469-4.31 0.402-2.52 0.143-4.21-0.781-5.16-0.87-0.89-1.324-3.59-1.313-7.5 0.022-7.2-1.811-9.49-6.937-8.62-2.025 0.34-3.481 0.05-4.281-0.91-1.067-1.29-1.505-1.31-3.594 0.06-1.303 0.86-2.375 2.4-2.375 3.41s-1.116 2.55-2.469 3.44c-1.612 1.05-2.425 2.52-2.406 4.21 0.036 3.2 4.833 8.68 8.375 9.57 1.719 0.43 3.11 1.76 4.031 3.97 0.768 1.83 2.635 4.13 4.156 5.06 1.522 0.93 2.587 2.18 2.376 2.81-0.212 0.63 0.247 1.75 1.031 2.47 1.028 0.95 1.3 2.72 0.937 6.28-0.425 4.18-0.11 5.6 2.188 9.41 1.494 2.47 3.954 5.32 5.468 6.34 1.68 1.13 3.554 3.92 4.782 7.13 2.146 5.6 4.968 10.29 4.968 8.25 0.001-0.68-1.116-3.49-2.5-6.22-1.383-2.73-2.312-5.46-2.093-6.1 0.337-0.97 4.593 7.05 4.593 8.66 0.001 0.31 0.943 2.55 2.094 5 2.328 4.95 1.909 7.13-0.531 2.75l-1.563-2.81 0.25 3.93c0.205 3.26-0.134 4.1-1.968 4.91-1.218 0.54-2.219 1.34-2.219 1.75s-0.684 0.72-1.531 0.72c-2.435 0-7.956 4.71-9.282 7.91-1.519 3.66-0.294 5.42 4.469 6.31 3.207 0.6 4.862 2.52 2.188 2.53-1.81 0.01-5.807 6.32-5.125 8.09 0.679 1.77 4.408 3.3 8.656 3.57 1.268 0.08 1.676 0.79 1.469 2.37-0.335 2.56 3.4 9.09 5.687 9.97 1.669 0.64-0.08 2.88-7.718 10.13-4.699 4.45-5.423 7.06-6.25 21.84-0.39 6.96-1.275 13.29-2.032 14.75-0.729 1.41-4.971 7-9.437 12.47-6.854 8.38-10.685 12.09-17.969 17.34-0.541 0.39-2.246 1.85-3.812 3.22-1.567 1.37-2.966 2.47-3.094 2.47-0.063 0-0.337-0.44-0.75-1.22l0.531 7.94 4.937 2.87c-0.651-1.08 0.805-1.44 5-1.44 4.263 0 6.007-0.53 8.876-2.71 1.958-1.5 3.562-3.13 3.562-3.63s1.116-2.1 2.469-3.56c1.352-1.46 2.437-3.19 2.437-3.84 0-0.66 1.468-2.56 3.219-4.19l3.156-2.94 1.188 2.25c1.015 1.94 0.694 3.19-2.188 9.06-1.842 3.75-3.358 7.8-3.375 9-0.019 1.43-1.049 2.74-3 3.75-3.26 1.69-5.038 5.05-4.25 8.07 0.437 1.67 0.104 1.85-2.75 1.46-2.273-0.31-2.996-0.12-2.312 0.6 0.541 0.57 3.181 1.17 5.844 1.34 2.762 0.18 4.987 0.83 5.218 1.53 0.223 0.68-0.334 1.25-1.281 1.25s-1.434 0.29-1.063 0.66c0.967 0.97 9.794 0.39 10.907-0.72 0.587-0.58-0.241-0.94-2.219-0.94-1.731 0-3.156-0.38-3.156-0.87 0-0.5 3.12-0.84 6.906-0.75 3.786 0.08 6.874 0.5 6.875 0.9 0.001 0.41 1.949 0.72 4.313 0.72 5.443 0 20.842 2.68 23.432 4.06 2.75 1.48 17.39 1.13 27.35-0.62 4.6-0.81 10.13-1.47 12.31-1.47s5.03-0.72 6.31-1.62l2.35-1.66-0.6 3.63c-0.7 4.31-0.01 4.46 7.28 1.59 3.16-1.24 6.15-1.8 7.82-1.44 2.52 0.55 2.6 0.8 1.59 3.47-1.49 3.96-0.34 4.6 5.03 2.78 3.75-1.27 6.93-1.45 16.91-0.9 6.76 0.37 13.05 0.32 13.94-0.1 0.88-0.42 2.89-0.78 4.43-0.75 1.55 0.03 4.79 0.07 7.22 0.06 7.22-0.01 23.66 4.03 20.25 4.82l4.94 4.93 8.34-5.9c-0.23-0.08-0.37-0.13-0.28-0.22 0.85-0.84 5.83-1.52 14.75-1.97 7.42-0.37 17.25-0.99 21.85-1.34 4.63-0.36 10.21-0.2 12.53 0.34 2.44 0.57 4.43 0.61 4.75 0.09 0.3-0.48 2.2-0.87 4.25-0.87 2.24 0 5.8-1.15 8.9-2.85 4.65-2.53 5.94-2.8 13.07-2.56 5.77 0.2 9.37-0.22 13.34-1.59 6.9-2.37 10.77-2.37 12.84 0 1.82 2.07 9 3.56 9 1.87 0-0.67 0.53-0.6 1.44 0.16 2.03 1.69 18.25-0.15 18.25-2.06 0-0.47 1.66-0.85 3.66-0.85 3.94 0 3.48-1.44-0.72-2.31-1.35-0.28-0.7-0.34 1.47-0.12 5.01 0.5 7.91 1.04 12.69 2.28 2.23 0.58 5.93 0.67 8.87 0.22 2.77-0.43 8.02-0.66 11.69-0.5 4.31 0.18 7.93-0.21 10.22-1.16 2.5-1.05 3.84-1.18 4.59-0.44 1.29 1.3 6.53 1.4 6.53 0.13 0-0.51-1.43-1.13-3.19-1.35l-3.18-0.37 3.53-0.16c2.89-0.13 3.71 0.27 4.62 2.28 1.11 2.43 1.35 2.47 12.88 2.47 6.43 0 13.04 0.27 14.68 0.6l2.76 0.59 7.21-2.59 5.13-17.63c-2.18 3.66-3.05 3.89-5.78 4.09-6.24 0.48-8.37-3.32-11.5-20.46-0.94-5.14-2.33-11.35-3.06-13.78-1.2-3.95-2.51-11.38-3.85-21.63-0.66-5.08-2.05-11.56-3.94-18.22-0.91-3.24-2.07-8.53-2.56-11.78s-1.35-7.91-1.87-10.34c-0.53-2.44-0.95-8.45-0.97-13.35-0.03-4.89-0.45-9.33-0.91-9.84-0.76-0.85-2.08-5.49-3.53-12.44-0.87-4.17 0.46-10.41 3-13.87 2.99-4.08 3.76-5.83 5.81-13.13 1.36-4.82 2.69-6.96 6.47-10.62 3.7-3.59 4.87-5.49 5.35-8.69 1.49-9.97-0.81-15.22-5.6-12.66-8.57 4.58-10.26 5.94-12.09 9.75-1.08 2.24-2.87 4.34-3.97 4.63-4.51 1.17-11.34 9.84-11.34 14.4-0.01 1.79-2.28 4.16-3.16 3.29-0.3-0.3-2.08 1.04-3.94 2.96-2.45 2.53-3.72 5.06-4.62 9.16-1.94 8.75-2.09 8.88-9.63 9.34-3.89 0.24-9.34 1.44-13.12 2.91-5.51 2.14-7.21 2.38-11.6 1.69-2.83-0.45-5.92-1.05-6.84-1.35-2.21-0.71-8.22-13.57-8.81-18.84l-0.47-4.13 3.78-0.53c2.09-0.3 6.93-0.86 10.72-1.21 3.78-0.36 7.33-0.96 7.87-1.35s2.74-1.22 4.91-1.84c2.16-0.63 5.18-2.14 6.72-3.38 2.47-1.99 2.91-3.24 3.78-10.62 0.54-4.59 0.68-14.75 0.34-22.6-0.57-13.08-0.84-14.77-3.5-20.34-5.49-11.5-20.47-24.43-25.9-22.34-1.57 0.6-1.57 0.76 0 2.5 0.91 1.01 2.18 1.84 2.84 1.84s1.73 0.6 2.34 1.34c0.86 1.03 0.72 1.68-0.5 2.69-1.26 1.05-1.45 2.38-0.97 6.5 0.73 6.2-0.04 7.8-6.81 14.41-6.03 5.89-13.39 10.69-18.78 12.25-5.68 1.64-5.63 1.67-4.94-3.41 0.52-3.76 0.18-5.52-1.97-9.91-1.43-2.92-3.97-6.32-5.65-7.56-3.93-2.9-10.69-5.5-14.28-5.5-4.8 0-12.93 3.17-16.19 6.32-2.96 2.85-2.97 3-0.94 3.31 1.17 0.18 2.36 1.01 2.69 1.87 0.68 1.77-2.01 5.22-4.06 5.22-0.75 0-1.6 0.66-1.91 1.47-0.76 1.97-2.31 1.89-2.31-0.13 0-1.93 2.76-4.2 5.15-4.24 0.95-0.02 1.72-0.52 1.72-1.1 0-0.59-0.82-0.77-1.87-0.44-1.32 0.42-2.02 0.05-2.28-1.18-0.3-1.4-0.8-1.04-2.5 1.68-1.47 2.35-2.19 5.03-2.19 8.38 0 5.38 3.29 15.28 5.5 16.53 2.08 1.18 1.66 3.62-0.97 5.69-1.8 1.41-2.41 3.02-2.75 7.09-0.3 3.64-1.12 6.01-2.59 7.59-1.18 1.27-2.16 3.02-2.16 3.88s-0.58 2.43-1.31 3.5-2.78 5.71-4.53 10.31-3.54 9.13-4.03 10.07c-0.5 0.93-0.96 2.71-1 3.93-0.04 1.23-0.93 3.57-1.97 5.19s-2.74 4.71-3.78 6.88c-1.6 3.3-1.91 3.56-1.97 1.59-0.04-1.29 0.82-3.83 1.94-5.63 1.81-2.93 1.97-4.36 1.53-14.12-0.53-11.61 0.39-16.32 3.31-17.25 3.39-1.08 6.74-7.7 9.22-18.22 3.95-16.74 4.56-22.39 4.56-40.78v-17.47l6-6.09c6.7-6.86 8.44-10.16 11.69-22.22 2.75-10.21 3.97-17.17 4.59-25.57 0.47-6.3 0.59-6.45 6.1-11.53 3.07-2.828 5.88-5.144 6.24-5.152 0.37-0.009 0.98-2.577 1.38-5.688 0.65-5.09 0.8-5.393 1.5-2.812 1.07 3.911 4.81 6.298 4.81 3.062 0-1.654 2.5-2.02 3.44-0.5 0.33 0.541 1.48 0.969 2.53 0.969 2.66 0 2.48-3.649-0.31-6.688l-2.22-2.406 2.22 1.344c1.22 0.742 2.22 1.665 2.22 2.062 0 0.825 5.3 3.719 6.81 3.719 0.55 0 1.5-0.934 2.12-2.094 0.98-1.828 0.69-2.519-2.03-5.062-2.4-2.249-3.01-3.457-2.56-5.25 0.45-1.783 0.2-2.344-1.09-2.344-1.32 0-1.42-0.238-0.5-1.156 0.65-0.649 1.18-2.026 1.18-3.063 0-1.513 0.42-1.767 2.19-1.187 1.22 0.397 3.57 0.803 5.19 0.875 2.78 0.122 2.94-0.083 2.94-3.594 0-2.175 0.58-4.115 1.4-4.625 2.04-1.257-0.4-3.969-3.56-3.969-1.96 0-2.29-0.367-1.78-1.969 0.45-1.429 0.19-1.968-1-1.968zm-2.31 2.156c0.8-0.108 0.85 1.148-0.5 3.219-0.9 1.369-2.04 2.5-2.57 2.5-1.42 0-1.16-1.206 0.94-3.938 0.9-1.169 1.64-1.716 2.13-1.781zm-10.94 2.781c0.54 0 0.98 0.543 0.97 1.219s-0.45 1.907-0.97 2.719c-0.74 1.15-0.96 0.858-0.97-1.25-0.01-1.488 0.43-2.688 0.97-2.688zm15.69 1.344c0.29-0.018 0.54-0.015 0.75 0.063 0.84 0.324 1.33 0.79 1.09 1.031-1.16 1.164-7.72 3.367-7.72 2.593 0-1.319 3.84-3.56 5.88-3.687zm-23.66 1.719c0.44-0.019 1.21 0.547 2.34 1.687 1.88 1.877 1.96 2.323 0.69 3.125-2.24 1.426-2.65 1.184-3.22-1.75-0.39-2.053-0.37-3.038 0.19-3.062zm-204.72 3.281c0.07-0.016 0.11-0.016 0.19 0.031 0.54 0.335 1 2.598 1 5 0 2.403-0.46 4.344-1 4.344s-0.97-2.232-0.97-4.969c0-2.684 0.3-4.294 0.78-4.406zm225.66 0.719c1.32-0.047 2.75 0.724 2.75 1.75 0 1.227-1.95 1.316-3.78 0.156-0.98-0.617-1.05-1.05-0.22-1.562 0.35-0.218 0.81-0.329 1.25-0.344zm-12.97 2.844c0.81-0.03 2.13 0.381 2.94 0.906 1.8 1.162 0.23 1.162-2.47 0-1.3-0.558-1.44-0.871-0.47-0.906zm-221.22 0.937c0.57 0.001 1.66 0.356 3.28 1.094 1.38 0.628 2.5 1.973 2.5 2.969 0 2.4-0.31 2.299-4.09-1.157-2.1-1.915-2.63-2.908-1.69-2.906zm13.13 1.5c0.36-0.043 0.52 1.09 0.53 3.625 0.01 2.57-0.13 4.688-0.31 4.688-1.77 0-2.26-5.45-0.69-7.876 0.17-0.266 0.34-0.423 0.47-0.437zm195.28 1.406c2.58 0 6.99 2.538 5.78 3.313-0.2 0.127-1.12 0.806-2.06 1.531-0.95 0.725-1.75 0.948-1.75 0.469s-0.95-1.341-2.13-1.875c-3.46-1.562-3.38-3.438 0.16-3.438zm13.22 0c0.23 0 0.72 0.459 1.06 1 0.33 0.541 0.13 0.969-0.44 0.969s-1.03-0.428-1.03-0.969 0.17-1 0.41-1zm2.03 3.969c1.96 0.016 1.96 0.054 0 1.219-2.56 1.512-6.38 2.031-6.38 0.875 0-1.005 3.36-2.119 6.38-2.094zm-223.63 1.125c0.33-0.012 0.67-0.006 1.06 0.031 1.76 0.17 3.22 0.74 3.22 1.282 0 1.1-3.29 1.604-5.18 0.812-2.15-0.897-1.4-2.043 0.9-2.125zm18.03 2.437c0.33 0.009 0.56 0.835 0.91 2.688 0.7 3.744 1.43 4.289 3.25 2.469 0.6-0.602 1.61-0.768 2.25-0.375 0.78 0.481 0.47 1.091-1.03 1.844-2.45 1.23-4.07 4.241-1.78 3.312 4.83-1.964 5.29-1.89 2.81 0.312-2.3 2.044-2.32 2.125-0.31 1.5 1.99-0.619 2.07-0.507 1 1.813-0.64 1.372-1.41 2.527-1.72 2.531-1.05 0.015-5.96-8.222-6.5-10.906-0.3-1.47-0.09-3.438 0.44-4.375 0.29-0.53 0.49-0.818 0.68-0.813zm207.72 0.844c0.09-0.012 0.18-0.004 0.28 0 0.23 0.011 0.5 0.076 0.82 0.188 2.18 0.775 5.15 3.288 5.15 4.375 0 1.281-2.23 0.897-4.68-0.813-2.19-1.521-2.81-3.562-1.57-3.75zm-221.53 0.719c3.12-0.082 5.7 0.327 6.28 1.031 0.76 0.914-0.27 1.188-4.4 1.188-7.32 0-9.03-2.031-1.88-2.219zm31.13 0.75c3.19 0 3.84 0.336 3.84 1.969 0 1.729-0.65 1.968-5.41 1.968-3.96 0-5.4-0.369-5.4-1.374 0-1.77 2.16-2.563 6.97-2.563zm103.59 0c5.33 0 7.42 0.364 7.81 1.375 0.29 0.759 0.26 1.645-0.06 1.969-0.32 0.323-3.84 0.593-7.81 0.593-6.56 0-7.22-0.18-7.22-1.968 0-1.79 0.66-1.969 7.28-1.969zm64.28 0c1.22-0.008 2.22 0.459 2.22 1 0 1.232-1.03 1.232-2.94 0-1.19-0.771-1.07-0.988 0.72-1zm-85.03 0.125c0.9-0.008 2.04 0.029 3.5 0.094 5.28 0.233 6.58 0.604 6.84 2 0.29 1.515-0.52 1.718-7 1.718-6.92 0-7.37-0.108-6.87-2 0.35-1.355 0.84-1.788 3.53-1.812zm-73.78 0.438c0.15-0.016 0.3-0.006 0.47 0 11.3 0.361 12.03 0.477 12.03 1.843 0 1.951-0.55 2.052-8.19 1.719-5.7-0.248-6.62-0.545-6.34-1.969 0.17-0.884 0.95-1.487 2.03-1.593zm23.72 0.437c5.37 0 7.42 0.346 7.81 1.375 0.29 0.767-0.15 1.653-0.97 1.969-0.82 0.315-4.34 0.562-7.81 0.562-5.66 0-6.31-0.174-6.31-1.937 0-1.79 0.66-1.969 7.28-1.969zm18.28 0c5.46 0 6.91 0.298 6.91 1.469s-1.45 1.468-6.91 1.468c-5.47 0-6.88-0.297-6.88-1.468s1.41-1.469 6.88-1.469zm16.72 0c5.46 0 6.9 0.298 6.9 1.469s-1.44 1.468-6.9 1.468c-5.47 0-6.88-0.297-6.88-1.468s1.41-1.469 6.88-1.469zm74.84 0c4.55 0 7.78 0.396 7.78 0.969 0 0.579-3.45 1-8.4 1-5.37 0-8.2-0.374-7.82-1 0.34-0.541 4.14-0.969 8.44-0.969zm14.75 0c2.41 0 3.74 0.375 3.38 0.969-0.34 0.541-2.14 1-4 1-1.87 0-3.38-0.459-3.38-1s1.81-0.969 4-0.969zm25.81 0.375c0.36-0.067 1.08 0.515 2.38 1.812 1.46 1.46 2.43 2.882 2.15 3.157-0.9 0.901-4.84-2.475-4.84-4.157 0-0.482 0.1-0.772 0.31-0.812zm-60.5 0.062c4.08-0.069 8.12 0.264 8.32 1.032 0.14 0.584-3.3 1.08-8.47 1.25-6.77 0.222-8.58 0.018-8.25-0.969 0.26-0.775 4.33-1.243 8.4-1.313zm49.82 0c0.47 0.033 0.53 0.614 0.53 1.969 0 4.746-4.95 12.24-9.91 14.939-5.56 3.02-6.77 5.42-7.78 15.59-1.5 15.08-6.35 32.05-8.75 30.56-0.44-0.27-2.07 0.92-3.59 2.63-1.72 1.93-2.32 3.26-1.6 3.5 0.75 0.25 0.23 1.67-1.47 4-2.96 4.09-8.22 8.68-8.22 7.19 0.01-0.55 1.35-1.97 2.97-3.13 1.63-1.15 2.94-2.51 2.94-3.03s-1.29 0.02-2.91 1.22c-3.28 2.43-3.92 2.23-3.96-1.22-0.07-5.98 1.51-10.52 4.65-13.16 1.76-1.47 3.22-3.29 3.22-4.06 0-0.76 0.46-1.37 1.03-1.37 0.58 0 0.8-0.45 0.47-0.97-0.32-0.53-1.88 0.48-3.47 2.22-3.95 4.35-3.7 1.83 0.72-6.53 3.65-6.92 4.52-8.28 6.91-10.94 0.67-0.76 1.22-1.77 1.22-2.28 0-0.52 0.68-1.52 1.53-2.22 0.84-0.7 2.22-2.52 3-4.03 1.24-2.41 1.22-2.67-0.03-2.19-1.22 0.47-1.25 0.07-0.25-2.72 1.5-4.2 3.19-6.04 8.15-8.87 5.07-2.905 10.22-7.264 10.22-8.629 0-0.576-0.92-1.062-2.03-1.062-1.22 0-1.74-0.414-1.34-1.063 0.36-0.593 1.94-0.916 3.5-0.687s2.84 0.098 2.84-0.313c0-1.242-3.77-2.058-6.12-1.312-1.97 0.622-2.1 0.563-0.91-0.875 0.74-0.89 2.23-1.625 3.28-1.625s2.77-0.471 3.81-1.032c0.62-0.33 1.06-0.519 1.35-0.5zm-211.29 0.532c1.07 0 2.77 0.589 3.76 1.312 2.85 2.089 1.38 3.506-1.69 1.625-3.86-2.364-4.27-2.937-2.07-2.937zm218.54 0.406c0.06 0.011 0.11 0.051 0.18 0.094 0.54 0.334 0.97 1.45 0.97 2.5s-0.43 1.906-0.97 1.906-1-1.115-1-2.5c0-1.071 0.27-1.815 0.63-1.969 0.06-0.025 0.13-0.042 0.19-0.031zm-208.13 0.594c2.43 0.011 2.84 0.245 1.72 0.968-1.93 1.25-4.91 1.25-4.91 0 0-0.541 1.43-0.977 3.19-0.968zm149.47 6.031c31.7-0.018 35.18 0.524 32.44 2.219-0.47 0.289-0.68 1.576-0.44 2.812 0.28 1.459-0.47 3.244-2.12 5.154-1.41 1.62-2.8 4.06-3.1 5.41s-0.98 3.64-1.53 5.09c-0.55 1.46-0.69 3.19-0.28 3.85 0.42 0.68 0.33 0.96-0.22 0.62-0.53-0.32-2.24 1.92-3.78 5-1.55 3.08-3.03 5.82-3.35 6.1-0.31 0.27-1.8 2.93-3.28 5.9-3.21 6.47-11.09 13.68-19.56 17.91-3.26 1.63-6.18 3.59-6.47 4.34-0.3 0.79-1.91 1.35-3.84 1.35-1.84-0.01-3.35 0.45-3.35 1 0.01 1.39-7.2 1.23-8.62-0.19-0.65-0.65-1.22-2.02-1.22-3.07 0-2.35 5.43-13.25 7.97-16 2.56-2.77 2.39-4.85-1.06-11.93-1.91-3.91-3.77-6.31-5.19-6.75-1.21-0.38-3.44-1.72-4.97-3s-3.19-2.35-3.69-2.35-1.82-0.88-2.9-1.97c-1.48-1.47-1.86-2.88-1.53-5.53 0.81-6.52-2.44-8.801-8.29-5.78-2.87 1.49-3.02 2.16-1.59 8.38 0.23 0.98-4.12 5.87-5.22 5.87-1.75 0-7.89 4.33-7.9 5.56-0.01 0.62-0.72 1.41-1.53 1.72-0.82 0.32-1.47 1.36-1.47 2.38 0 1.01-0.68 3.28-1.53 5-2.6 5.2 0.43 16.84 4.37 16.84 0.98 0 2.34 1.05 3.03 2.35 1.04 1.94 1.01 3.1-0.16 6.59-0.77 2.33-1.7 3.77-2.06 3.19s-2.44-1.37-4.65-1.72c-2.45-0.39-6.08-2.16-9.22-4.53-2.85-2.15-5.71-3.91-6.35-3.91-0.63 0-1.93-0.43-2.87-0.94-0.94-0.5-2.38-1.15-3.19-1.47-0.81-0.31-2.64-1.34-4.06-2.28s-3.98-2.61-5.69-3.68c-1.72-1.08-3.32-3.08-3.59-4.44s-0.92-3.81-1.44-5.47-0.96-3.63-0.97-4.41c-0.01-2.37-11.79-24.93-13.87-26.56-1.49-1.16-1.82-2.173-1.32-4.186 0.37-1.463 1.12-2.903 1.63-3.219s34.73-0.812 76.09-1.063c17.66-0.106 31.37-0.181 41.94-0.187zm-156.12 0.094c0.07-0.001 0.15 0.03 0.18 0.062 0.29 0.287-0.4 1.436-1.53 2.563-1.74 1.746-6 2.924-6 1.656 0-0.752 6.15-4.271 7.35-4.281zm193.59 0c0.72 0.037 1.48 0.418 2.19 1.125 2 2.008 1.92 2.23-1.63 4-3.92 1.955-3.66 2.031-3.56-1.406 0.07-2.372 1.42-3.801 3-3.719zm-184.28 0.25c0.71-0.117 1.03 0.479 1.03 1.812 0 2.856-2.38 6.289-3.31 4.781-0.97-1.571 0.31-5.875 1.93-6.5 0.12-0.045 0.25-0.077 0.35-0.093zm21.72 1c0.98-0.125 2.93 1.434 2.93 2.562 0 0.475-0.88 0.875-1.96 0.875-1.9 0-2.66-1.903-1.32-3.25 0.1-0.093 0.21-0.169 0.35-0.187zm-27.07 1.469c0.82 0 1.47 0.253 1.47 0.562s-0.65 1.22-1.47 2.031c-1.31 1.312-1.46 1.249-1.46-0.562-0.01-1.156 0.63-2.031 1.46-2.031zm26.57 6.002 2.43 0.56c3.38 0.79 6.72 4.75 8 9.56 1.03 3.85 2.84 8.29 6.88 16.75 2.28 4.77 2.44 7.89 0.37 7.1-0.9-0.35-1.47-0.01-1.47 0.87 0 0.8 0.43 1.44 0.94 1.44s1.65 1.23 2.53 2.72c0.89 1.49 3.35 3.94 5.47 5.47 3.98 2.85 5.07 5.59 2.25 5.59-1.21 0-1.32 0.29-0.5 1.28 0.6 0.72 0.91 3.49 0.72 6.16-0.19 2.66 0.08 5.68 0.59 6.65 2.14 4.08-0.02 3-5.31-2.59-3.1-3.28-5.91-5.68-6.22-5.38-0.3 0.31 0.98 2.25 2.88 4.32s3.25 3.97 2.97 4.25c-0.87 0.87-7.26-7.23-6.78-8.6 0.25-0.71-1.09-2.94-2.97-4.93-1.89-1.99-3.4-4.11-3.41-4.72 0-0.61-0.66-1.63-1.4-2.25-1.68-1.39-2.38-4.56-4.07-17.78-1.23-9.65-2.05-14.21-3.87-20.97-0.71-2.64-0.65-2.72 2.06-2.06l2.81 0.65-2.47-2.03-2.43-2.06zm79.87 1.87c2.07 0.04 3.43 1.87 2.81 3.81-0.76 2.41-3.29 2.77-4.12 0.6-0.65-1.68 0.16-4.43 1.31-4.41zm0.06 9.81c0.74-0.03 2.31 0.58 4.25 1.72 3.04 1.8 3.83 4.19 1.38 4.19-0.81 0-1.47 0.52-1.47 1.13 0 0.66-1.05 0.87-2.66 0.56-1.46-0.28-3.61-0.14-4.81 0.31-1.97 0.75-2.17 0.55-2.03-2.22 0.09-1.68 0.7-3.24 1.38-3.47 0.76-0.25 1.04 0.19 0.68 1.13-0.49 1.28-0.23 1.34 1.88 0.34 1.83-0.86 2.2-1.51 1.44-2.43-0.67-0.81-0.61-1.22-0.04-1.26zm0.69 4.41c-0.69 0-1.44 0.45-1.44 1.09 0 0.24 0.69 0.41 1.53 0.41 0.85 0 1.25-0.45 0.91-1-0.21-0.34-0.58-0.5-1-0.5zm-12.34 2.31c0.7-0.11 1.55 0.87 3.43 3.6 2.15 3.1 3.74 4.46 5.35 4.47 1.39 0 2.12 0.47 1.87 1.21-0.24 0.74-2.14 1.22-4.75 1.22-3.21 0-4.54 0.45-5.06 1.72-0.77 1.89-3.23 2.31-4.22 0.72-0.34-0.55-0.35-2.33 0-3.94 0.51-2.3 1.2-2.9 3.16-2.9h2.47l-2.28-1.85c-1.98-1.59-2.09-2.11-0.94-3.5 0.37-0.44 0.65-0.7 0.97-0.75zm20.22 1.32c0.88-0.05 2.05 0.28 4.15 0.93 5.03 1.57 6.83 3.85 3.03 3.85-1.29 0-2.85 0.43-3.5 0.97-0.85 0.71-0.93 0.67-0.21-0.19 1.54-1.86 1.14-3.47-1-4.03-1.99-0.52-2.37 0.14-2 3.59 0.1 1.02-0.38 2.26-1.1 2.72-2.42 1.53-5.75 0.51-5.75-1.78 0-1.01-0.62-1.34-1.91-1-1.05 0.28-2.71-0.18-3.68-0.97-1.64-1.33-1.57-1.39 0.87-0.87 1.46 0.3 2.9 0.17 3.22-0.35s1.25-0.72 2.06-0.41c0.82 0.32 2.37-0.21 3.44-1.18 0.9-0.81 1.49-1.24 2.38-1.28zm6.31 7.72c0.84-0.09 2.04 0.45 2.4 1.4 0.31 0.8 1.35 1.18 2.41 0.91 1.02-0.27 2.39 0.21 3.09 1.06 1.18 1.41 0.18 2.3-1.12 1-0.31-0.31-1.18-0.73-1.91-0.91-3.68-0.88-5.75-1.81-5.75-2.59 0-0.53 0.37-0.82 0.88-0.87zm-33.56 1.71c0.68 0.03 1.42 0.79 2.12 2.25 0.78 1.61 1.78 2.91 2.22 2.91s0.78 0.69 0.78 1.5c0 0.82-0.87 1.47-1.97 1.47-1.15 0-1.93-0.66-1.93-1.6 0-1.12-0.61-1.44-2.07-1.06-1.81 0.48-1.98 0.22-1.4-2.09 0.57-2.27 1.37-3.41 2.25-3.38zm20.18 0.85c1.95-0.19 4.45 1.08 6.32 3.34 0.85 1.03 1.19 1.11 1.22 0.25 0.04-1.8 2.46-1.48 4.31 0.56 2.71 3 1.2 14.29-2.66 19.72-3.39 4.78-6.39 6.33-10.19 5.38-1.63-0.41-2.31-0.25-1.9 0.4 0.34 0.56 1.85 1.22 3.34 1.47 1.5 0.26 3.59 0.84 4.63 1.28 1.33 0.57 1.66 0.44 1.15-0.37-0.39-0.63-0.26-1.16 0.32-1.16 0.57 0 1.03 0.71 1.03 1.53 0 0.83 1.11 1.98 2.47 2.6 2.36 1.07 3.35 2.78 1.62 2.78-0.46 0-2.54 1.69-4.66 3.75-4.47 4.35-7.36 4.44-10.96 0.34-3.59-4.06-5.19-8.73-5.19-15.31 0-3.98-0.52-6.85-1.57-8.34-0.91-1.32-1.64-4.35-1.68-7.22-0.07-4.25 0.34-5.29 2.65-7.28 1.49-1.28 3.57-2.35 4.66-2.35s2.84-0.44 3.87-1c0.38-0.2 0.78-0.33 1.22-0.37zm15.44 2.34c0.54 0 1 0.46 1 1s-0.46 0.97-1 0.97-0.97-0.43-0.97-0.97 0.43-1 0.97-1zm-6.28 2.97c-3.67 0-6.17 3.28-5.22 6.91 0.4 1.5-0.18 2.84-1.97 4.5l-2.53 2.37h3.1c2.87 0 3.06-0.27 3.06-3.44 0-3.38 2.34-5.8 5-5.18 0.62 0.14 1.26-0.98 1.44-2.47 0.29-2.47 0.04-2.69-2.88-2.69zm-14.59 0.16c-2.06 0.1-2.6 1.32-2.07 4.03 0.47 2.38 1 2.68 4.25 2.68 2.98 0 3.84-0.43 4.29-2.15 0.76-2.92 0.17-3.55-3.88-4.31-1.04-0.2-1.91-0.29-2.59-0.25zm-16.13 1.15c0.32-0.06 1 0.41 1.6 1.13 0.77 0.93 0.83 1.5 0.18 1.5-1.19 0-2.55-1.88-1.87-2.57 0.03-0.03 0.05-0.05 0.09-0.06zm70.13 11.56c0.29 0.01 0.31 2.27 0 5.32-0.33 3.24-0.93 11.34-1.29 17.97-0.35 6.62-1 12.03-1.46 12.03-0.47 0-0.76 3-0.66 6.65l0.16 6.63 0.37-5.66c0.2-3.11 0.8-5.65 1.31-5.65 0.52 0 0.91-1.98 0.91-4.41 0-2.6 0.45-4.44 1.09-4.44 0.69 0 0.9 1.04 0.54 2.72-0.32 1.49-0.89 10.2-1.26 19.41-0.57 14.49-0.43 17.19 0.97 19.9 2.01 3.89 2.03 5.19 0.13 5.19-0.81 0-1.48-0.11-1.5-0.25-0.02-0.13-0.31-2.03-0.63-4.19-0.31-2.16-1.15-4.8-1.9-5.87-1.22-1.74-1.36-1.27-1.35 4.44 0.02 7.38 0.74 10.76 2.32 10.81 0.61 0.02 1.89 0.66 2.87 1.4 0.98 0.75 1.44 1.53 1 1.76-1.59 0.8-5.2-1.72-6.31-4.41-1.62-3.92-1.8-16.21-0.25-18.25 1.77-2.34 1.63-10.14-0.28-13.97-1.59-3.19-1.59-9.11 0.06-30.5 0.32-4.22 3.74-15.32 5.09-16.59 0.03-0.02 0.05-0.04 0.07-0.04zm-95.53 0.63c0.07-0.01 0.14 0 0.21 0 0.35 0.02 0.64 0.25 0.72 0.75 0.09 0.54-0.03 0.59-0.28 0.12-0.24-0.46-0.86-0.23-1.37 0.5-0.64 0.91-0.84 0.96-0.63 0.13 0.22-0.84 0.81-1.4 1.35-1.5zm51.06 1.47c-2.16-0.07-5.38 1.09-5.38 2.34 0 1.67 1.18 1.8 2.66 0.32 0.77-0.78 1.27-0.78 1.75 0 0.37 0.59-0.05 1.06-0.91 1.06-1.83 0-2.05 1.61-0.31 2.31 2.27 0.92 2.75 0.66 3.75-1.97 0.62-1.63 0.67-2.96 0.09-3.53-0.33-0.33-0.93-0.51-1.65-0.53zm-44.75 1.37c0.47-0.02 1.13 0.03 2 0.16 2.78 0.41 4.78 2 8.43 6.63 1.44 1.82 1.53 1.81 0.97 0.09-0.5-1.58-0.37-1.65 0.91-0.59 0.83 0.68 2.92 1.52 4.62 1.87 3.62 0.74 4.24 2.76 2.16 6.94-0.92 1.84-1.96 2.69-2.87 2.34-0.79-0.3-1.44 0.03-1.44 0.72s-0.27 0.95-0.59 0.63c-0.33-0.33 0.13-2.02 1-3.76 1.96-3.93 2-3.66-0.91-3.5-2.26 0.14-2.44 0.56-2.44 4.85 0 2.57-0.46 4.65-1 4.65-1.08 0-1.22-0.51-1.09-3.43 0.05-1.08-0.18-1.46-0.47-0.81-0.29 0.64-1.16 0.95-1.94 0.65-0.9-0.35-1.42 0.11-1.47 1.28-0.04 1.09-0.61 0.43-1.4-1.62-1.62-4.21-1.81-6.22-0.5-5.41 1.55 0.96 1.16-1.12-0.47-2.47-0.91-0.75-1.23-2.08-0.88-3.5 0.42-1.65-0.04-2.63-1.53-3.56-2.16-1.35-2.51-2.09-1.09-2.16zm-3.91 0.38c0.53 0 1.24 1.23 1.6 2.72 0.35 1.49 0.95 3.14 1.31 3.69 0.36 0.54 0.57 3.47 0.5 6.56-0.07 3.08 0.27 5.4 0.72 5.12 0.44-0.27 0.82-1.7 0.87-3.15l0.1-2.63 0.84 2.75c1.77 5.9 2.78 23.44 2.16 37.56-0.66 14.76-0.66 14.77-1.32 6.41-0.36-4.6-0.73-13.78-0.78-20.41-0.06-7.31-0.5-12.06-1.09-12.06-0.97 0-1.15 4.45-1.47 33.44-0.16 14.42-0.84 19.25-3.19 21.91-0.83 0.94-1.81 1.71-2.15 1.71-1.02 0-3.01-2.24-2.97-3.37 0.04-1.33 4.87-4.92 4.87-3.63 0 0.54-0.43 1.26-0.97 1.6-1.19 0.73-1.31 3.43-0.15 3.43 1.19 0.01 3.19-6.7 3.37-11.31 0.5-12.61-0.38-43.78-1.25-43.78-0.62 0-1.06 7.9-1.16 21.41l-0.15 21.37-0.69-13.75c-0.38-7.57-1.03-21.1-1.44-30.03-0.4-8.93-0.93-16.55-1.18-16.97s-0.14-2.19 0.25-3.94c0.61-2.77 0.82-2.94 1.5-1.21 0.67 1.71 0.78 1.63 0.84-0.72 0.04-1.49 0.5-2.72 1.03-2.72zm85.97 0c0.91 0 0.46 11.8-0.47 12.37-0.48 0.3-0.9 1.8-0.9 3.35-0.01 1.54-0.45 2.96-1.04 3.15-0.58 0.2-1.41 2.79-1.84 5.75s-0.87 4.13-0.94 2.57c-0.06-1.57-0.73-3.34-1.5-3.94-1.06-0.83-1.22-2.23-0.65-5.81 0.77-4.88-0.26-7.31-1.47-3.47-0.38 1.2-1.34 2.83-2.13 3.62-1.23 1.23-1.55 1.23-2.34 0.03-0.51-0.76-0.76-2.6-0.56-4.09 0.22-1.71-0.12-2.72-0.91-2.72-2.51 0-2.41-1.99 0.16-2.97 1.78-0.68 3.03-0.67 3.84 0 0.87 0.72 1.51 0.32 2.31-1.43 0.73-1.59 1.65-2.23 2.63-1.85 0.96 0.37 1.5 0.02 1.5-0.97 0-1.33 2.7-3.59 4.31-3.59zm-53.78 1.41c0.14-0.1 0.05 0.88-0.22 3.03-0.27 2.16-0.52 5.15-0.5 6.65 0.03 2.86-4.01 7.6-6.5 7.6-0.73 0-1.34 0.48-1.34 1.03 0 0.56 1 0.7 2.31 0.37 3.23-0.81 3.97 1.73 1.84 6.25-0.94 2-2.49 3.79-3.44 3.97-1.49 0.29-1.71-0.5-1.71-5.9 0-5.04 0.48-6.96 2.47-9.88 1.35-1.99 2.43-3.92 2.43-4.31s0.64-1.4 1.38-2.25c0.74-0.86 1.83-2.91 2.43-4.53 0.47-1.26 0.74-1.96 0.85-2.03zm79.94 2.81c0.02 0 0.03 0.04 0.03 0.06 0 0.19-0.89 1.15-1.97 2.13-1.08 0.97-1.97 1.36-1.97 0.87s0.89-1.48 1.97-2.16c0.95-0.59 1.75-0.95 1.94-0.9zm-17.79 4.25c0.39 0.06 0.54 2.48 0.35 5.62-0.54 9.12-1 9.91-1.13 1.97-0.06-3.89 0.25-7.29 0.69-7.56 0.03-0.02 0.07-0.04 0.09-0.03zm-39.84 0.68c0.27-0.07 0.66 0.43 0.94 1.16 0.66 1.73 0.09 2.01-0.88 0.44-0.35-0.58-0.44-1.27-0.18-1.53 0.03-0.03 0.08-0.05 0.12-0.07zm26.69 1.35c-0.2 0.17-0.48 2.01-0.81 5.5-0.25 2.57-0.07 4.65 0.4 4.65 0.48 0 0.86-2.54 0.82-5.65-0.05-3.17-0.21-4.67-0.41-4.5zm-17.09 0.41c0.91-0.12 2.34 0.66 4.09 2.28 1.95 1.8 2.45 3 2.06 5.12-0.28 1.53-1.04 3.12-1.69 3.53-2.58 1.65-3.62 0.74-3.62-3.15 0-2.17-0.46-3.94-1-3.94s-0.97-0.89-0.97-1.97c0-1.16 0.41-1.79 1.13-1.87zm40.87 0.5c0.17-0.04 0.28-0.02 0.28 0.09 0 1.44-5.46 7.26-6.15 6.56-1.23-1.22-0.79-2.05 2.71-4.72 1.42-1.08 2.64-1.82 3.16-1.93zm84.53 2.37c0.85 0 11.19 10.66 11.19 11.53 0 0.26 0.94 1.79 2.09 3.41 1.15 1.61 2.49 4.51 3 6.5 1.24 4.84 1.89 32.64 0.82 35.12-0.83 1.92-0.84 1.93-0.91 0.07-0.09-2.52-1.61-0.9-2.44 2.62-0.63 2.67 0.73 3.88 1.69 1.5 0.27-0.68 0.55-0.28 0.59 0.91 0.08 2.28-5.06 6.95-8.4 7.62-1.01 0.2-3.08 0.83-4.57 1.41-1.69 0.65-2.72 0.69-2.72 0.09 0-0.53-0.45-0.94-1.03-0.94-0.57 0-0.77 0.43-0.43 0.97 0.33 0.54-0.55 1.43-1.97 1.97-3.56 1.35-4.45 1.23-3.78-0.5 0.46-1.21-0.49-1.47-5.25-1.47-6.02 0-8.19-1.08-8.19-4.12 0-0.98-0.43-1.78-0.97-1.78s-1-0.37-1-0.85c0-0.47 1.97-1.36 4.38-1.97 5.31-1.34 6.43-1.37 4.5-0.12-2.09 1.35 2.93 1.32 6.5-0.03 1.97-0.75 2.86-0.71 3.4 0.15 0.54 0.88 1.16 0.75 2.38-0.46 2.08-2.09 3.36-2.06 5.09 0.09 1.24 1.55 1.35 1.4 0.81-1.38-0.36-1.86 0.02-4.55 0.94-6.75 0.84-2 1.32-3.96 1.06-4.37-0.25-0.41 0.41-1.58 1.5-2.56 1.09-0.99 1.75-2.37 1.47-3.1-0.49-1.29-0.19-2.17 2.35-7.03 0.74-1.42 0.8-2.06 0.15-1.66-1.29 0.8-1.35-0.4-0.12-2.34 0.49-0.78 0.58-1.9 0.21-2.47-1.16-1.79-0.79-5.47 0.54-5.47 2.44 0 1.26-2.73-1.72-3.96-1.65-0.69-3.68-2.55-4.5-4.13-1.16-2.24-2.07-2.8-4.06-2.56-1.42 0.17-2.74-0.23-2.97-0.91s0.27-1.25 1.09-1.25 1.8-0.5 2.19-1.12c0.48-0.78-0.12-0.98-1.94-0.63-2.61 0.5-2.61 0.49-1-1.97 1.49-2.27 1.49-2.43 0.03-1.87-2.1 0.8-2.04-0.26 0.1-1.82 1.42-1.04 1.45-1.47 0.34-2.81-0.72-0.87-0.9-1.56-0.44-1.56zm-138.5 0.25c-0.6 0.09-1.26 0.62-1.56 1.53-0.22 0.64 0.3 1.16 1.16 1.16 0.85 0 1.53-0.71 1.53-1.57s-0.52-1.21-1.13-1.12zm-61.5 2.12c0.44 0.02 1.52 0.85 2.63 2.04 1.26 1.35 1.89 2.46 1.34 2.46-1.26 0-4.75-3.78-4.09-4.43 0.03-0.04 0.06-0.07 0.12-0.07zm71.06 0.13c0.3-0.02 0.54 0 0.69 0.09 1.52 0.92 0.64 1.98-3.03 3.6-4.61 2.03-6.18 2.09-5.47 0.25 0.51-1.34 5.72-3.82 7.81-3.94zm-27.12 1.44c0.53 0 1.74 1.2 2.69 2.69 0.94 1.48 2 2.94 2.34 3.21s1.14 1.47 1.78 2.69 1.93 2.22 2.91 2.22c0.97 0 2.27 1.09 2.87 2.41 0.97 2.13 0.81 2.48-1.4 3.21l-2.47 0.85 2.06 1.84c1.81 1.64 2.03 1.63 2.03 0.19 0-1.89 1.51-2.14 2.56-0.44 0.4 0.65 0.18 1.35-0.47 1.56-0.64 0.22-1.76 1.02-2.53 1.79-0.76 0.76-1.6 1.06-1.84 0.65s-2.35-4.29-4.66-8.62c-2.3-4.33-4.76-8.59-5.5-9.44-1.54-1.8-1.78-4.81-0.37-4.81zm-13.44 1.72c1.22-0.17 1.64 2.13 1.1 6.71-0.48 3.99-0.28 5.36 1.09 6.72 1.64 1.64 2.82 1.65 6.59 0.1 1.26-0.52 1.99 0.01 2.91 2.03 0.98 2.16 1 2.8 0.03 3.12-0.67 0.23-1.22 1.25-1.22 2.25 0 1.01-0.46 2.08-1 2.41-1.24 0.77-1.28 2.47-0.06 2.47 0.96 0 2.59-3.83 2.22-5.22-0.12-0.45 0.22-0.53 0.78-0.19 1.25 0.78 1.34 3.72 0.12 4.97-0.5 0.52-1.22 2.71-1.62 4.88-0.62 3.34-0.54 3.73 0.66 2.75 1.18-0.98 1.37-0.54 1.06 2.71-0.68 7.14 1.41 3.97 2.62-3.96 1.35-8.83 0.44-14.51-2.9-17.85-2.1-2.09-1.86-3.25 1-4.78 1.52-0.82 2.18-0.26 4.22 3.69 11.7 22.64 14.52 28.48 14.53 29.97 0 0.94 0.45 1.72 0.97 1.72 0.51 0 1.2 1.53 1.56 3.43 0.35 1.9 1.05 3.71 1.53 4 0.48 0.3 0.87 1.65 0.87 2.97s0.35 2.38 0.78 2.38c0.44 0 1.64 1.89 2.63 4.19 0.99 2.29 2.51 4.9 3.37 5.78 0.87 0.88 2.34 2.48 3.22 3.56 0.89 1.08 2.2 2.21 2.94 2.47s1.11 0.73 0.81 1.06c-0.71 0.79-8.84-3.2-8.84-4.34 0-0.49-0.83-1.74-1.84-2.75-2.07-2.07-7.05-12.31-8.91-18.32-0.67-2.16-2.07-5.8-3.12-8.06-1.06-2.26-2.17-5.34-2.44-6.87-0.28-1.53-0.9-2.93-1.38-3.1-0.47-0.17-1.63-2.6-2.56-5.4s-2.4-6.28-3.28-7.72c-1.53-2.52-1.59-2.11-1.56 9.03 0.01 6.39 0.12 11.5 0.25 11.37s0.88-1.94 1.62-4.06l1.35-3.87 1.03 8.34 1.06 8.38-0.25-6.66c-0.23-6.94 0.32-8.13 2.03-4.41 3.87 8.46 6.32 14.62 7.28 18.44 0.61 2.43 1.4 4.64 1.75 4.91s1.41 2.15 2.34 4.18c1.59 3.43 1.6 3.69 0.07 3.69-1.43 0-1.41 0.21 0.25 1.53 1.66 1.33 1.47 1.3-1.35-0.06-1.77-0.86-2.99-1.91-2.71-2.34 0.6-0.98-2.94-10.89-4.41-12.35-0.77-0.75-0.79-0.28-0.06 1.66 0.56 1.48 0.77 3.35 0.47 4.15-0.31 0.81 0.13 2.14 1 3 0.86 0.87 1.56 2.05 1.56 2.6 0 1.86-2.44 0.2-3.78-2.56-1.12-2.29-1.1-2.89 0-3.57 0.72-0.44 0.95-1.14 0.53-1.56s-1.18-0.12-1.66 0.66c-0.71 1.14-1.34 0.86-3.37-1.5-3.17-3.68-3.33-1.96-0.19 1.97 1.9 2.38 2.07 3.11 1.03 4.15-1.8 1.8-2.72 1.6-5.72-1.19-1.45-1.34-2.96-2.34-3.34-2.24-1.77 0.44-6.99-1.44-7.47-2.69-0.3-0.77-1.16-1.18-1.94-0.88-0.8 0.31-2.07-0.43-2.97-1.72-1.54-2.2-1.59-2.21-1.59-0.18 0 3.1-3.63 3.69-5.47 0.87-1.13-1.72-1.35-3.89-0.91-9.03 0.94-10.76 3.56-26.32 4.66-27.69 0.56-0.69 0.69-1.56 0.31-1.94-0.37-0.37-1.09-0.01-1.59 0.79-0.64 1-0.9-0.1-0.91-3.6-0.01-3.3 0.48-5.48 1.44-6.28 0.81-0.67 1.47-1.68 1.47-2.22 0-0.55-0.65-0.43-1.47 0.25-2.18 1.82-1.76-0.3 0.66-3.37 0.87-1.12 1.57-1.71 2.12-1.78zm-63.56 1.53c0.75-0.02 1.65 0.08 2.69 0.25 8.14 1.34 10.2 4.34 3 4.34-2.44 0-4.41-0.43-4.41-0.97s-0.43-0.97-0.94-0.97-1.05 1.66-1.22 3.69l-0.31 3.69-1.31-3.72c-1.5-4.23-0.78-6.22 2.5-6.31zm69.16 0.68c-0.55 0-1 0.43-1 0.97s0.45 1 1 1c0.54 0 0.96-0.46 0.96-1s-0.42-0.97-0.96-0.97zm34.9 0.13c1.23-0.03 1.47 0.62 1.47 1.91 0 1.78 0.39 2 2.72 1.37 5.37-1.46 9.09-1.26 9.09 0.47 0 2.01 3.8 12.94 5 14.41 0.92 1.11 3.13 31.96 2.35 32.75-0.25 0.24-0.47-0.64-0.47-1.97 0-1.34-0.49-2.96-1.1-3.57-1.52-1.52-2.77-9.01-1.62-9.71 0.51-0.32 0.64-1.3 0.28-2.19s-0.86-2.51-1.09-3.6c-1.78-8.18-2.18-8.73-1.82-2.46 0.98 16.78 2.11 26.18 3.53 28.84 0.53 0.97 0.83 2.95 0.66 4.41-0.24 2.11-0.49 2.36-1.25 1.18-0.91-1.4-1.52-4.7-3.37-18.34-0.45-3.31-1.18-6.59-1.63-7.31-0.44-0.72-0.91-3.65-1.06-6.53-0.51-9.51-2-9.04-2.63 0.84-0.55 8.75-2.14 14.61-4 14.63-0.47 0-0.54-1.01-0.15-2.22 1.44-4.56 1.64-7.42 0.59-8.07-0.65-0.4-1.06 0.15-1.06 1.41 0 1.3-0.43 1.84-1.13 1.41-1.12-0.7-0.79-6.02 1.07-18.13 0.45-2.97 0.51-5.76 0.12-6.19-0.39-0.42-0.78-0.19-0.87 0.5-0.8 6.08-1.4 9.38-1.88 10.63-0.31 0.81-0.46 2.45-0.34 3.66 0.35 3.61-0.9 4.5-2.97 2.12-1.19-1.37-1.81-3.48-1.72-5.72 0.12-2.97 0.19-3.08 0.53-0.81 0.74 4.89 2.39 2.88 2.09-2.56-0.21-3.97-0.65-5.23-1.78-5.16-0.82 0.05-1.78 0.75-2.15 1.56-0.49 1.07-0.67 0.88-0.72-0.72-0.04-1.21-0.58-2.21-1.16-2.21-0.57 0-0.75-0.46-0.43-0.97 0.31-0.52 1.33-0.66 2.21-0.32 1.18 0.46 1.43 0.22 1-0.9-0.32-0.85 0.08-2.45 0.88-3.6 0.8-1.14 1.04-2.09 0.53-2.09s-1.64 1.12-2.53 2.47-2.26 2.44-3.06 2.44c-2.02 0-1.83-0.98 0.75-3.72l2.22-2.31-2.97 0.65c-1.63 0.39-3.17 0.73-3.44 0.72-3.99-0.08-3.88-1.4 0.25-3.13 6.27-2.61 9.48-3.83 11.06-3.87zm43.56 1.84c1.12 0 0.52 20.14-0.81 27.53-0.63 3.52-1.63 6.72-2.25 7.13-0.82 0.54-0.78 0.97 0.19 1.59 1.36 0.88 0.99 5.24-0.81 9.47-0.46 1.08-1.08 2.74-1.38 3.69s-0.94 1.72-1.4 1.72c-1.19 0-0.15-6.23 1.18-7.1 0.71-0.46 0.23-1.28-1.31-2.37l-2.34-1.69 2.12-0.75c2.06-0.76 2.12-1.32 2.19-17.31 0.04-9.08 0.44-17.39 0.9-18.47 0.73-1.68 0.85-1.72 0.91-0.25 0.11 2.71 2.03 2 2.03-0.75 0-1.35 0.37-2.44 0.78-2.44zm-173.81 1.94c3.47 0 4.21 1.23 3.41 5.5-0.68 3.63-2.5 4.65-2.5 1.41 0-2.98-5.95-3.12-9.22-0.22-1.85 1.64-1.86 1.59-0.78-0.47 1.72-3.28 6.03-6.22 9.09-6.22zm202.03 1.97c2.18 0 1.85 1.73-0.47 2.47-1.08 0.34-1.97 1.21-1.97 1.94 0 0.72-1.31 1.77-2.93 2.34-1.63 0.57-2.97 1.49-2.97 2.06s-0.77 1.02-1.72 1c-1.36-0.03-1.14-0.5 1-2.25 1.49-1.22 2.69-2.72 2.69-3.31 0-1.35 4.35-4.25 6.37-4.25zm-186.37 1.09c1.17-0.09 1.97 0.15 1.97 0.88 0 0.54-0.89 1-1.97 1-3.75 0-1.96 1.87 2.43 2.53 4.68 0.7 5.16 2.36 0.69 2.38-1.45 0-4.63 0.65-7.06 1.4-2.43 0.76-5.32 1.66-6.41 2.03-1.66 0.58-1.58 0.41 0.41-1.22 1.63-1.33 1.97-2.12 1.16-2.62-0.89-0.55-0.89-1.06-0.03-2.09 1.79-2.17 6.22-4.08 8.81-4.29zm156.4 0.88c-0.54 0-1 0.92-1 2.03s0.46 1.77 1 1.44c0.54-0.34 0.97-1.25 0.97-2.03s-0.43-1.44-0.97-1.44zm19.32 0c0.81 0 1.17 0.46 0.84 1s-1.28 0.97-2.09 0.97c-0.82 0-1.18-0.43-0.85-0.97 0.34-0.54 1.28-1 2.1-1zm17.47 0.09c0.66 0 1.24 0.19 1.68 0.63 0.46 0.45-0.36 0.91-1.81 1.03-3.21 0.26-5.51 2.16-2.66 2.19 1.57 0.01 1.65 0.22 0.47 0.97-2.14 1.35-0.54 2.33 1.78 1.09 2.5-1.34 5.37-1.4 4.57-0.09-0.34 0.54-1.68 1-3 1s-2.41 0.42-2.41 0.96 0.54 1 1.22 1c0.82 0.01 0.76 0.34-0.22 0.97-2.77 1.79-6.91 0.16-6.91-2.75 0-3.25 4.39-6.98 7.29-7zm-180 2.22c0.35-0.06 0.56 0.17 0.56 0.6 0 0.57-0.43 1.03-0.97 1.03s-0.97-0.17-0.97-0.41 0.43-0.73 0.97-1.06c0.13-0.09 0.29-0.14 0.41-0.16zm-33.85 0.66c0.54 0 0.97 0.43 0.97 0.97s-0.43 1-0.97 1-1-0.46-1-1 0.46-0.97 1-0.97zm263.72 0c2.69 0 2.78 1.14 0.5 6.37-0.71 1.63-1.91 4.38-2.66 6.13-1.27 3-3.54 4.86-4.62 3.78-0.27-0.27 0.08-1.19 0.78-2.03s1.05-1.77 0.75-2.07c-0.3-0.29-1.96 1.52-3.69 4.04-4.26 6.19-13.5 15.15-16.37 15.87-1.29 0.32-2.97 0.33-3.75 0.03s-1.61-0.02-1.88 0.63c-0.37 0.9-0.47 0.91-0.53 0-0.04-0.65 1.53-1.94 3.5-2.88 3.16-1.49 11.86-7.51 14.6-10.06 0.54-0.5 2.08-2.34 3.43-4.06 1.36-1.73 3.36-4.15 4.44-5.41 3.95-4.6 5.41-6.85 5.41-8.31 0-1.8-7.8 5.71-7.85 7.56-0.02 0.68-0.46 1.22-1 1.22s-1 0.5-1 1.13c0 1.83-7.31 8.01-12.97 10.93-6.04 3.12-7.49 3.37-5.59 1.03 1.16-1.42 1.14-1.55-0.13-1.09-5.02 1.84-5.87 1.91-5.31 0.44 0.31-0.82 1.98-1.77 3.69-2.13 1.71-0.35 5.03-1.78 7.38-3.12 2.34-1.35 4.41-2.27 4.62-2.06 0.21 0.2-1.59 1.46-4 2.78-3.72 2.03-5.62 3.9-3.94 3.9 2.04 0 13.32-7.65 13.32-9.03-0.01-0.61-0.71-0.51-1.72 0.28-0.95 0.74 1.73-2.06 5.96-6.25 4.24-4.19 8.13-7.62 8.63-7.62zm-176.53 1.84c0.14-0.11 0.15 1.36 0.22 4.78 0.07 3.38-0.01 6.16-0.22 6.16-0.94 0-1.24-3.89-0.6-7.91 0.31-1.9 0.49-2.94 0.6-3.03zm-84.25 0.13c0.54 0 1 0.2 1 0.43 0 0.24-0.46 0.7-1 1.04-0.54 0.33-0.97 0.13-0.97-0.44 0-0.58 0.43-1.03 0.97-1.03zm268.72 0.53c0.09 0 0.19 0 0.28 0.03 2.94 1.13 2.03 13.28-1.72 23.53-0.79 2.17-1.71 5.8-2.09 8.06-0.75 4.45-1.84 5.06-10.32 5.69-2.09 0.16-4.27 0.57-4.87 0.94s-1.13 0.4-1.13 0.09c0-1.11 2.48-4.98 3.69-5.75 0.68-0.43 1.25-1.43 1.25-2.22 0-0.78 0.37-1.4 0.84-1.4 0.48 0 1.44-1.43 2.1-3.19s1.98-4.76 2.97-6.66c2.01-3.86 4.94-11.5 5.25-13.75 0.34-2.48 2.11-5.08 3.47-5.34 0.09-0.02 0.18-0.04 0.28-0.03zm-344.19 1.53c0.28 0.04 0.677 0.45 1.312 1.31 0.773 1.05 1.376 2.71 1.376 3.69-0.001 0.98-0.447 1.78-0.969 1.78-1.496 0-3.173-3.93-2.469-5.75 0.288-0.74 0.47-1.07 0.75-1.03zm248.59 0.87c-1.1 0-1.3 3.26-0.28 4.28 1.09 1.09 1.28 0.77 1.28-1.81 0-1.35-0.46-2.47-1-2.47zm-161.31 1c0.54 0 0.97 0.17 0.97 0.41s-0.43 0.73-0.97 1.06c-0.54 0.34-1 0.14-1-0.43 0-0.58 0.46-1.04 1-1.04zm134.38 0c-1.58 0-3.77 2.4-2.94 3.22 0.87 0.87 3.11-0.22 3.72-1.81 0.3-0.78-0.04-1.41-0.78-1.41zm-216.47 0.32c0.152 0.02 0.338 0.15 0.562 0.37 1.215 1.22-0.372 7.48-2.562 10.13-0.673 0.81-1.483 2.12-1.782 2.93-0.357 0.97-0.542 1.06-0.594 0.22-0.042-0.7 0.793-3 1.876-5.12 1.082-2.12 1.968-5.08 1.968-6.57 0-1.23 0.126-1.83 0.406-1.93 0.043-0.02 0.075-0.04 0.126-0.03zm288.22 0.12c1.71-0.13 2.4 0.52 2.4 2.06 0 1.69-2.65 1.8-5.37 0.22-1.85-1.07-1.79-1.15 0.9-1.87 0.81-0.22 1.49-0.36 2.07-0.41zm-17.88 0.75c2.02-0.04 3.69 0.16 4.03 0.72 0.35 0.57 1.4 1.03 2.32 1.03 0.91 0 3.62 1.67 6 3.72 3.71 3.2 4.15 4.03 3.24 5.72-0.95 1.78-0.42 5.47 2.54 17.37 0.1 0.41 0.18 1.47 0.18 2.35 0 1.22 0.65 1.46 2.72 1.03 1.49-0.31 4.15-0.85 5.91-1.22 2.57-0.53 3.19-0.38 3.19 0.91 0 0.88-0.49 1.51-1.1 1.37-0.61-0.13-1.3 0.25-1.53 0.88-0.23 0.62 1.54 1.89 3.94 2.81 4.78 1.82 7.8 6.01 5.41 7.53-2.05 1.29-2.8 1-5.72-2.13-1.52-1.62-3.48-2.96-4.35-2.96-2.22 0-1.98 0.87 1.07 3.68l2.68 2.47-3.62 3.31c-3.82 3.5-7.51 4.25-9.78 1.97-0.75-0.74-2.71-2.04-4.38-2.9s-3.31-2.3-3.66-3.19c-0.34-0.91-1.25-1.37-2.06-1.06-0.79 0.3-1.71 0.14-2.03-0.38-0.32-0.51-1.53-0.89-2.72-0.84-1.84 0.07-1.73 0.24 0.85 1.37 3.26 1.44 7.04 5.01 4.09 3.88-1.13-0.43-1.51-0.05-1.41 1.37 0.12 1.54 1.08 2.1 4.38 2.6 4.49 0.67 4.87 2.47 0.53 2.47-1.41 0-2.26 0.33-1.87 0.71 0.38 0.39 2.48 0.57 4.62 0.41 2.3-0.16 3.88 0.16 3.88 0.78 0 0.6-1.93 1.07-4.41 1.07-3.39-0.01-4.63-0.46-5.44-1.97-0.58-1.09-1.47-1.97-2-1.97s-1.7 0.88-2.62 1.97c-1.99 2.32-6.19 2.66-6.19 0.5 0-0.82-0.46-1.5-1-1.5s-0.97 0.42-0.97 0.93 0.43 1.2 0.97 1.54c0.54 0.33 1 1.02 1 1.53 0 1.87-1.68 0.84-2.91-1.79-1.18-2.53-1.31-2.56-2.06-0.71-0.99 2.45-1.19-6.06-0.28-11.57 0.71-4.29 5.18-9.2 9.22-10.09 1.91-0.42 2.87-1.38 3.28-3.25 0.34-1.6 2.14-3.74 4.53-5.41 2.18-1.52 3.94-3.21 3.94-3.75 0-0.53-1.51 0.2-3.38 1.63-2.5 1.91-3.99 2.4-5.65 1.87-6.86-2.17-12.59-9.92-12.57-16.96 0.01-2.55 0.37-5.25 0.85-6 0.66-1.05 4.98-1.79 8.34-1.85zm-78.69 0.41c0.3 0.02 0.51 0.22 0.72 0.56 0.94 1.52 0.19 2.75-1.65 2.75-0.78 0-1.41 0.46-1.41 1s0.66 0.97 1.47 0.97 1.47-0.43 1.47-0.97 0.46-1 1-1 0.97 0.66 0.97 1.47-0.38 1.5-0.88 1.5-1.59 0.22-2.41 0.53c-0.9 0.35-1.9-0.24-2.59-1.53-0.95-1.78-0.77-2.41 1.09-4.03 1.04-0.9 1.72-1.29 2.22-1.25zm-104.87 0.44c2.05 0.05 1.66 0.34-1.75 1.28-2.44 0.66-6.41 2.46-8.84 4-2.44 1.54-4.73 3.31-5.13 3.9-0.52 0.78-0.74 0.78-0.75-0.03-0.05-3.49 10.39-9.31 16.47-9.15zm-98.658 0.28c0.209-0.01 0.492 0.18 0.907 0.53 0.753 0.62 1.597 2.03 1.875 3.09 0.278 1.07 0.153 2.13-0.25 2.38-1.246 0.77-3-1.68-3-4.19 0-1.2 0.121-1.8 0.468-1.81zm115.53 0.62c0.58 0 1.07 0.46 1.07 1s-0.2 0.97-0.44 0.97-0.7-0.43-1.03-0.97c-0.34-0.54-0.17-1 0.4-1zm99.82 0.19c-0.21 0.07-0.32 0.6-0.28 1.37 0.04 1.15 0.24 1.38 0.56 0.6 0.28-0.71 0.26-1.55-0.06-1.88-0.09-0.08-0.16-0.12-0.22-0.09zm-219.13 0.09c0.256-0.12 0.328 0.46 0.344 1.88 0.03 2.64 1.638 4.85 4.75 6.59 2.331 1.31 1.163 1.88-1.406 0.69-3.151-1.46-5.619-6.09-4.375-8.22 0.325-0.56 0.534-0.86 0.687-0.94zm178.59 0.38c-0.92 0.08-0.93 0.56-0.56 1.75 0.35 1.11 1.03 2.19 1.5 2.37s0.85 1.36 0.85 2.63c0 3.1 2.58 15.47 4.56 21.97 1.1 3.61 1.89 4.89 2.59 4.18 0.7-0.7 0.56-2.33-0.53-5.25-0.86-2.32-1.85-5.99-2.15-8.15-0.46-3.18 0.05-2.43 2.65 3.94 1.77 4.32 3.59 8.48 4.06 9.21 0.56 0.86 0.37 1.64-0.5 2.19-0.74 0.47-0.88 0.88-0.34 0.88 2.95 0 3.1-1.64 0.69-6.88-2.6-5.64-3.96-10.08-4.82-15.47-0.27-1.75-0.88-2.97-1.34-2.69-1.1 0.69-2.28-5.75-1.5-8.21 0.52-1.65 0.1-1.97-2.84-2.32-0.79-0.09-1.39-0.14-1.85-0.15-0.17-0.01-0.33-0.01-0.47 0zm-66.21 0.68-2.6 2.26c-2.15 1.85-2.55 2.95-2.31 6.28 0.16 2.21-0.26 4.65-0.91 5.43-0.93 1.13-0.91 1.4 0.16 1.41 1.1 0.01 1.09 0.21-0.06 0.94-1.17 0.74-1.19 1.15-0.13 2.44 1.42 1.7 5.97 2.13 5.97 0.56 0-0.54-0.54-0.96-1.22-0.97-0.82-0.01-0.73-0.35 0.25-1 1.06-0.7 1.13-1.19 0.32-1.72-0.63-0.41-1.29-2.29-1.47-4.19-0.31-3.12-0.08-3.47 2.37-3.75 3.25-0.37 3.63-2.09 0.5-2.25-1.59-0.08-1.73-0.24-0.53-0.56 0.92-0.24 1.95-1.3 2.28-2.34 1.07-3.39 2.19-2.03 2.88 3.46 0.76 6.09-0.54 9.71-5.38 15.04-1.6 1.75-3.01 3.18-3.15 3.12-0.15-0.05-1.77-0.47-3.6-0.9-7.12-1.69-11.27-7.03-11.37-14.66-0.06-3.82 0.29-4.51 2.93-6 1.65-0.93 5.71-1.92 9.04-2.16l6.03-0.44zm160.75 0.97c0.22-0.04 0.41 0.01 0.53 0.13 0.26 0.26-0.58 2.03-1.88 3.94-2.64 3.88-3.84 4.36-3.84 1.56 0-1.63 3.64-5.35 5.19-5.63zm15.84 0.66c-4.78 0-8.29 3.24-4.56 4.22 2.93 0.76 3.2 0.72 5.68-0.91 2.85-1.86 2.35-3.31-1.12-3.31zm15.53 0.06c0.92-0.04 1.95 0.37 2.28 0.91 0.7 1.13 0.67 1.13-1.97 0-1.6-0.69-1.66-0.85-0.31-0.91zm-180.81 0.1c0.07-0.03 0.17 0.01 0.25 0.09 0.33 0.33 0.35 1.16 0.06 1.88-0.31 0.78-0.55 0.58-0.59-0.57-0.03-0.78 0.08-1.33 0.28-1.4zm135.03 0.18c-0.44-0.09-0.6 0.72-0.56 2.66 0.06 3.19 0.14 3.23 1.15 1.13 0.8-1.67 0.79-2.53-0.06-3.38-0.22-0.22-0.38-0.37-0.53-0.41zm-33.84 1.07c-0.07 0-0.15 0.02-0.22 0.06-0.54 0.33-1 1.71-1 3.06 0 1.39 0.44 2.19 1 1.84 0.54-0.33 0.97-1.7 0.97-3.06 0-1.21-0.3-1.96-0.75-1.9zm-57.1 1.75c0.2-0.08 0.53 0.12 0.97 0.56 0.64 0.64 0.94 1.38 0.66 1.65-0.28 0.28-0.77 0.24-1.13-0.12s-0.69-1.13-0.69-1.69c0-0.23 0.07-0.36 0.19-0.4zm75.13 0.34c0.05-0.11 0.12 0.24 0.18 1.13 0.2 2.82 0.2 7.68 0 10.81-0.19 3.13-0.37 0.82-0.37-5.13 0-4.09 0.08-6.57 0.19-6.81zm-142.5 0.41c-2.56 0-4.63 0.48-4.63 1.06 0 0.61 1.62 0.87 3.94 0.66 5.63-0.53 6.11-1.72 0.69-1.72zm179.15 0c-0.99-0.01-1.81 0.81-1.81 2.46 0 1.98 0.51 2.47 2.5 2.47 1.75 0 2.75 0.75 3.41 2.47 1.07 2.81 2.2 3.1 3.93 1 1.01-1.21 0.77-1.65-1.37-2.47-1.42-0.54-3.07-2.07-3.69-3.43-0.75-1.66-1.97-2.5-2.97-2.5zm-68.21 0.12c0.91 0 1.59 1.25 2.68 4.06 0.89 2.3 2.51 6.43 3.6 9.19l1.96 5.06-2.87-0.12c-3.44-0.12-3.75-1.29-0.69-2.59 2.05-0.88 2.03-0.91-0.62-0.69-3.38 0.28-4.77-2.1-1.69-2.91 2.11-0.55 2.61-1.45 1.44-2.62-0.36-0.37-1.44 0.05-2.38 0.9-2.45 2.22-3.23 0.12-0.93-2.53 2.28-2.63 1.77-3.94-1.54-3.94-2.75 0-2.94-0.52-0.96-2.5 0.81-0.82 1.45-1.31 2-1.31zm-35.94 1.41c-0.44 0.03-0.92 1-1.13 2.4-0.34 2.34-0.16 2.68 0.88 1.82 1.49-1.24 1.72-3.4 0.43-4.19-0.06-0.04-0.12-0.04-0.18-0.03zm164.09 0.65c1.56-0.2-5.23 9.87-10.03 14.32-4.29 3.96-6.47 5.09-6.47 3.4 0-0.42 3.12-3.6 6.91-7.09 3.78-3.49 6.87-6.85 6.87-7.47s0.66-1.7 1.47-2.38c0.59-0.49 1.03-0.75 1.25-0.78zm-237.34 0.13c-0.57-0.1-1.66 0.25-3.1 1.03l-2.78 1.5 2.63 0.06c1.45 0.02 2.98-0.45 3.34-1.03 0.57-0.93 0.48-1.46-0.09-1.56zm170.12 0.06c0.47-0.01 0.57 1.09 0.57 4.03 0 4.1 0.43 5.19 2.71 7.06 3.39 2.77 2.43 3.03-1.06 0.29-3.38-2.67-5.12-8.69-3.09-10.72 0.4-0.41 0.66-0.65 0.87-0.66zm69.13 1.72c0.21-0.04 0.27 0.3 0.28 0.97 0.02 0.88-0.66 2.14-1.47 2.81-1.89 1.57-1.91-0.01-0.03-2.5 0.61-0.8 1-1.24 1.22-1.28zm-173.41 0.34 0.5 9.85c0.3 5.41 0.28 17.13-0.06 26.06s-0.9 24.66-1.25 34.94-1.05 21.54-1.56 25.06c-1.94 13.24-1.9 15.68 0.25 17.19 1.19 0.83 1.73 2.01 1.37 2.93-0.32 0.85-0.17 1.54 0.31 1.54 0.49 0 1.02-1.23 1.19-2.72 0.57-4.97 7.69-3.53 7.69 1.56 0 1.08-0.47 2.11-1.06 2.31-0.6 0.2-1.1 2.04-1.1 4.07 0 2.55-0.55 3.98-1.81 4.65-2.54 1.36-3.02 1.2-3.59-1-0.28-1.06-1.25-2.18-2.16-2.47s-1.73-1.45-1.81-2.59c-0.09-1.14-0.85-2.82-1.69-3.75-2.07-2.28-2.11-28.15-0.06-42.72 0.81-5.78 1.51-14.14 1.56-18.59 0.05-4.46 0.74-14.3 1.5-21.88 0.76-7.57 1.46-18.41 1.56-24.09l0.22-10.35zm-77.28 0.57c0.28-0.06 0.52-0.01 0.72 0.18 0.25 0.25 0.18 1.18-0.16 2.07-0.76 1.99-2.37 2.14-2.37 0.21 0-1.1 0.98-2.28 1.81-2.46zm88.13 0.09c-0.4 0.13-1.09 1.74-2.19 5.16-1.21 3.74-2.19 7.6-2.19 8.59 0 3.04 0.85 2.05 1.97-2.34 0.58-2.3 1.53-5.12 2.09-6.25 0.57-1.14 0.89-3.14 0.69-4.44-0.08-0.54-0.2-0.78-0.37-0.72zm-164.29 0.28c0.065 0.01 0.142 0.09 0.218 0.28 0.273 0.68 0.273 1.79 0 2.47-0.272 0.68-0.499 0.14-0.5-1.22 0-0.84 0.087-1.38 0.219-1.5 0.02-0.01 0.041-0.03 0.063-0.03zm-3 2.38c0.294 0.01 0.781 0.65 1.25 1.65 0.635 1.36 0.734 2.41 0.218 2.41-1.093 0-2.169-2.48-1.687-3.88 0.047-0.13 0.121-0.19 0.219-0.18zm278.29 1.34c-1.22-0.03-4.22 1.72-4.22 2.66 0 1.07 3.78 0.16 4.56-1.1 0.32-0.51 0.34-1.16 0.06-1.43-0.08-0.09-0.23-0.13-0.4-0.13zm-13.66 0.09c0.35-0.06 1 0.58 1.53 1.57 1.29 2.4 0.83 2.69-0.94 0.56-0.68-0.83-1.02-1.76-0.72-2.06 0.04-0.04 0.08-0.06 0.13-0.07zm-258.6 1.07c0.1-0.03 0.206-0.02 0.281 0.06 0.303 0.3 0.016 1.11-0.656 1.78-0.972 0.96-1.096 0.84-0.562-0.56 0.277-0.73 0.637-1.21 0.937-1.28zm291.88 0c0.45-0.1 0.75 0.49 0.75 1.43 0 1.09-0.43 2.26-0.97 2.6-0.54 0.33-1-0.26-1-1.35 0-1.08 0.46-2.26 1-2.59 0.07-0.04 0.16-0.08 0.22-0.09zm-115.31 0.59c-0.54 0-1 0.89-1 1.97s0.46 1.97 1 1.97 0.97-0.89 0.97-1.97-0.43-1.97-0.97-1.97zm143.19 0.25c0.28-0.02 0.11 0.44-0.47 1.53-0.6 1.12-1.57 2.32-2.16 2.69-0.77 0.48-0.78 0.11 0-1.35 0.6-1.11 1.6-2.32 2.19-2.68 0.19-0.12 0.34-0.18 0.44-0.19zm-48.38 2.06c-0.12 0.02-0.24 0.04-0.38 0.13-0.54 0.33-1 0.82-1 1.06s0.46 0.44 1 0.44c0.55 0 0.97-0.49 0.97-1.06 0-0.43-0.24-0.63-0.59-0.57zm67.88 0c-0.12 0.02-0.24 0.04-0.38 0.13-0.54 0.33-1 0.82-1 1.06s0.46 0.44 1 0.44 0.97-0.49 0.97-1.06c0-0.43-0.24-0.63-0.59-0.57zm65 0.16 0.78 5.25c0.83 5.77-1.18 11.94-3.88 11.94-1.19 0-1.13-0.28 0.19-1.6 0.87-0.87 1.29-1.86 0.97-2.18-0.33-0.33-0.99 0.07-1.5 0.87-0.82 1.27-1.07 1.26-1.97-0.03-0.85-1.23-0.99-1.14-0.75 0.47 0.19 1.29-0.37 2.02-1.69 2.25-1.62 0.27-1.71 0.15-0.5-0.69 1-0.69 1.08-1.05 0.25-1.06-0.69-0.01-1.22-1.21-1.22-2.75 0-1.52 0.54-3.34 1.22-4.06 1.01-1.09 0.94-1.25-0.47-0.76-2.47 0.88-2.23-1.93 0.28-3.28 1.12-0.59 2.55-0.92 3.16-0.72 0.61 0.21 2.02-0.54 3.13-1.65l2-2zm-295.41 1.03c0.09-0.02 0.29 0 0.65 0.09 0.73 0.19 1.96 0.35 2.72 0.35 2.56 0 1.43 1.9-1.93 3.31-1.83 0.76-3.64 1.9-4 2.5-0.84 1.35-3.5 1.42-3.5 0.09 0-0.54 0.59-1 1.31-1 1.65 0 6.02-4.53 4.94-5.12-0.23-0.12-0.28-0.2-0.19-0.22zm210.22 2.72c0.07 0.01 0.1 0.09 0.09 0.22-0.02 0.51-0.67 1.79-1.47 2.84-0.79 1.05-1.42 1.48-1.4 0.97 0.01-0.51 0.67-1.76 1.47-2.81 0.59-0.79 1.1-1.26 1.31-1.22zm-4.07 0.19c0.16-0.01 0.26 0.08 0.26 0.28 0 0.51-0.66 1.48-1.47 2.15-0.82 0.68-1.47 0.94-1.47 0.57 0-0.38 0.65-1.38 1.47-2.19 0.5-0.51 0.95-0.8 1.21-0.81zm-230.62 1.9c3.48-0.07 8.56 1.25 8.56 2.53 0 0.52-1.77 0.94-3.94 0.94-2.16 0-3.93-0.43-3.93-0.97s-0.43-0.97-0.97-0.97-1 0.66-1 1.47c0 0.84-0.88 1.47-2.03 1.47-2.95 0-2.02-3.07 1.25-4.16 0.54-0.18 1.26-0.29 2.06-0.31zm28.81 0.57c0.15-0.01 0.28-0.02 0.41 0 0.61 0.06 1 0.36 1 0.87 0 0.5-0.57 1.15-1.25 1.47-0.98 0.46-0.98 0.7 0 1.16 2.16 1 1.33 2.37-1.47 2.4-2.59 0.03-2.61 0.09-0.78 1.47 1.79 1.36 1.68 1.44-1.66 1.44-1.95 0-4.12 0.15-4.84 0.34-2.09 0.55-21.5-1.45-21.5-2.22 0-1.1 8.72-2.94 16.72-3.53 4.04-0.3 8.32-1.21 9.53-2 1.35-0.89 2.82-1.37 3.84-1.4zm152.19 0.03c0.5 0.03-0.27 1.3-2.53 3.5-2.01 1.95-3.66 3.95-3.66 4.43s-0.44 0.85-1 0.85c-1.49 0 0.71-3.77 3.81-6.5 1.83-1.61 2.99-2.31 3.38-2.28zm-147.69 0.15c0.19-0.08 0.61 0.2 1.31 0.78 0.82 0.68 1.5 1.59 1.5 2.07 0 1.46-1.71 0.96-2.34-0.69-0.52-1.35-0.71-2.05-0.47-2.16zm29 0.78c0.21 0 0.35 1.32 0.35 2.94s-0.34 2.94-0.78 2.94c-0.45 0-0.65-1.32-0.41-2.94s0.63-2.94 0.84-2.94zm54.35 0c0.84-0.04 2.1 1.14 3 3.19 1.85 4.25 7.73 13.35 10.78 16.72 1.34 1.49 3.44 2.72 4.65 2.72 2.31 0 6.29-4.18 6.29-6.59-0.01-0.78 0.42-1.15 0.96-0.82 0.54 0.34 1 0.05 1-0.65 0.01-0.71 0.98-0.13 2.19 1.31 1.22 1.43 2.91 2.81 3.72 3.09 0.95 0.33 0.68 0.55-0.72 0.6-1.24 0.04-2.61-0.78-3.22-1.91-1.41-2.63-3.11-1.5-2.34 1.56 0.45 1.8 0.18 2.41-1 2.41-0.87 0-1.59 0.69-1.59 1.56-0.01 1-0.54 1.39-1.47 1.03-0.89-0.34-1.47-0.01-1.47 0.82 0 2.07-1.59 2.68-2.91 1.09-0.64-0.77-2.46-1.69-4.03-2.03-3.35-0.74-11.3-9.19-13.47-14.28-0.8-1.9-1.86-4.21-2.34-5.16-0.55-1.08-0.5-1.72 0.12-1.72 0.55 0 0.97-0.66 0.97-1.47 0-0.99 0.37-1.44 0.88-1.47zm53.43 0.1c0.57-0.09 0.81 0.29 0.6 0.94-0.24 0.71-1.01 1.48-1.72 1.71-0.74 0.25-1.09-0.1-0.85-0.84 0.24-0.71 1.01-1.51 1.72-1.75 0.1-0.03 0.17-0.05 0.25-0.06zm-138.47 0.87c0.24 0 0.7 0.43 1.04 0.97 0.33 0.54 0.16 1-0.41 1s-1.06-0.46-1.06-1 0.2-0.97 0.43-0.97zm-44.24 1.07c0.36 0.05 0.25 0.49-0.07 1.31-0.58 1.53-5.31 2.78-5.31 1.4 0-0.48 1.14-1.31 2.53-1.84 1.63-0.62 2.48-0.93 2.85-0.87zm91.4 0c-0.22-0.08-0.14 0.31 0.19 1.18 0.37 0.97 0.91 1.52 1.22 1.22 0.3-0.3 0.01-1.11-0.66-1.78-0.36-0.36-0.61-0.58-0.75-0.62zm-24.56 0.28c0.35 0.01 0.59 0.43 0.59 1.06 0 0.84-0.46 1.53-1 1.53s-0.97-0.43-0.97-0.94 0.43-1.19 0.97-1.53c0.14-0.08 0.29-0.13 0.41-0.12zm-63.34 0.62c0.54 0 0.96 0.43 0.96 0.97s-0.42 1-0.96 1c-0.55 0-1-0.46-1-1s0.45-0.97 1-0.97zm-66.818 1.97c0.445-0.09 1.434 0.21 2.844 0.97 2.394 1.28 5.906 7.07 5.906 9.72 0.001 1.15-0.395 2.09-0.906 2.09-1.459 0-4-4.14-4-6.53 0-1.19-1.168-3.1-2.594-4.22-1.5-1.18-1.821-1.92-1.25-2.03zm213.5 0.13c0.14-0.07 0.46 0.28 0.97 1.15 0.58 0.99 0.85 2.03 0.59 2.28-0.25 0.26-0.75-0.24-1.09-1.12-0.53-1.39-0.65-2.23-0.47-2.31zm53.19 0.09c-0.12 0.04-0.19 0.17-0.19 0.41 0 0.55 0.3 1.32 0.66 1.68s0.88 0.41 1.16 0.13c0.27-0.28-0.02-1.02-0.66-1.66-0.44-0.44-0.77-0.63-0.97-0.56zm116.22 0.19c0.23 0.06 0.43 0.74 0.78 2.06 0.9 3.36 0.59 4-1 2.09-0.63-0.75-0.82-2.19-0.44-3.19 0.22-0.57 0.41-0.87 0.57-0.93 0.03-0.02 0.06-0.04 0.09-0.03zm-389.5 0.12c0.079 0.04 0.168 0.25 0.281 0.69 0.409 1.57 1.519 2.16 3.5 1.84 0.406-0.06 0.75 0.34 0.75 0.88s-0.428 0.97-0.969 0.97c-1.75 0-1.06 1.98 0.719 2.06 1.028 0.05 1.235 0.26 0.5 0.56-1.74 0.7-1.52 2.31 0.312 2.31 0.918 0 1.237 0.44 0.813 1.13-0.415 0.67 0.471 2.09 2.125 3.4 1.554 1.24 2.604 2.49 2.344 2.76-0.602 0.6-6.209-4.36-7.156-6.32-0.393-0.81-1.374-2.58-2.157-3.94-0.782-1.35-1.367-3.55-1.312-4.9 0.042-1.04 0.117-1.51 0.25-1.44zm68.281 2.1c1.8-0.12 3.97 1.38 9.53 5.71 5.13 4 13.99 9.37 15.53 9.41 0.67 0.02 2.96 0.86 5.13 1.91 2.16 1.04 4.72 1.92 5.68 1.93 1.35 0.03 1.67 0.68 1.38 2.75-0.35 2.47-0.69 2.71-4.19 2.5-2.11-0.12-5.32 0.02-7.15 0.32-3.13 0.5-3.27 0.61-1.72 2.15 1.28 1.28 3.5 1.66 9.9 1.66 6.99 0 8.41 0.32 9.38 1.87 0.82 1.32 0.86 2.12 0.09 2.88-0.76 0.76-1.06 0.58-1.06-0.66 0-2.47-1.63-1.12-2.19 1.81-0.36 1.9-0.09 2.47 1.25 2.47 0.96 0 1.95-0.54 2.19-1.21 0.24-0.68 0.8-0.89 1.25-0.47s-1.41 3.08-4.16 5.9c-2.74 2.83-5.51 6.12-6.12 7.31-0.77 1.51-1.63 1.96-2.81 1.5-1.61-0.61-1.62-0.49-0.07 1.88 1.33 2.03 1.48 3.31 0.72 6.69-1.03 4.6-3.88 8.32-4.62 6.09-0.3-0.89-0.9-0.56-1.97 0.97-1.12 1.6-1.22 2.31-0.38 2.59 1.44 0.48 1.61 11.66 0.19 12.54-1.16 0.71-1.33 3.43-0.22 3.43 0.42 0 1.49-2.31 2.38-5.15 1.31-4.2 1.65-4.64 1.72-2.32 0.08 3.18-4.02 10.87-6.25 11.72-2.23 0.86-3.88-1.77-2.07-3.28 0.82-0.68 1.48-1.93 1.47-2.81 0-1.03-0.7-0.56-1.97 1.34-1.07 1.63-1.74 3.5-1.5 4.16 0.25 0.66-0.29 1.65-1.21 2.19-1.55 0.9-1.53 0.97 0.15 1 1.5 0.02 1.27 0.5-1.15 2.62-3.14 2.75-17.82 9.65-18.69 8.78-0.29-0.28 1.2-1.23 3.31-2.09 7.46-3.05 14.09-6.34 14.69-7.31 0.84-1.37 0.11-1.23-4.07 0.75-2.68 1.27-3.73 1.41-4.03 0.53-0.41-1.22-0.64-1.14-6.68 1.94-1.63 0.82-4.49 1.79-6.38 2.18-1.89 0.4-3.9 1.09-4.44 1.5-1.06 0.81-8.35 2.5-14.87 3.47-3.01 0.45-5.25 1.73-8.6 4.94-2.49 2.39-4.56 4.49-4.56 4.65 0 0.17 0.91 0.36 2 0.44 1.1 0.08 1.73-0.29 1.41-0.81s-0.04-0.84 0.65-0.69c0.7 0.15 1.29-0.21 1.32-0.84 0.05-1.46 4.86-5.25 6.65-5.25 0.76 0 1.83-0.48 2.41-1.06s2.52-0.93 4.31-0.75c3.23 0.31 3.25 0.35 0.88 1.5-1.32 0.63-3.67 1.42-5.19 1.75-2.88 0.62-14.44 11.2-14.44 13.21 0 0.64-2.89 4.06-6.4 7.6-3.52 3.53-6.379 6.64-6.379 6.94 0 0.29 1.085 0.32 2.438 0.06 1.352-0.26 2.471-0.12 2.471 0.28 0 1.15-4.792 1.79-5.159 0.69-0.18-0.54-2.509 0.61-5.187 2.62-7.641 5.73-8.438 6.47-7.875 7.38 0.29 0.47-0.195 1.11-1.031 1.43-1.02 0.4-1.274 0.23-0.813-0.59 0.527-0.93 0.39-0.97-0.563-0.09-0.683 0.63-1.747 2.17-2.374 3.44-0.628 1.26-2.12 2.45-3.313 2.62-1.571 0.23-2.487 1.39-3.344 4.25-1.009 3.37-1.525 3.87-3.469 3.5-1.253-0.24-2.281-0.06-2.281 0.41 0 0.46 0.428 0.87 0.969 0.87 1.817 0 1.012 1.61-1.469 2.94-1.352 0.72-2.468 1.87-2.469 2.53 0 0.66-1.084 1.4-2.437 1.66-1.649 0.31-2.469 0.02-2.469-0.88 0-0.74-0.427-1.34-0.968-1.34-0.542 0-1 0.88-1 1.97 0 1.08-0.428 1.97-0.969 1.97s-1.015-0.78-1.031-1.72c-0.029-1.64-0.046-1.64-1 0-1.41 2.42-3.836 2.23-3.188-0.25 0.283-1.09 1.127-1.97 1.875-1.97s1.375-0.43 1.375-0.97c0-1.79-2.819-1.04-4.375 1.19-1.696 2.42-2.097 1.65-0.594-1.16 1.346-2.52 15.913-13.09 19.657-14.28 1.442-0.46 1.935-1.2 1.562-2.38-0.361-1.13 0.883-3.28 3.656-6.31 5.035-5.49 5.546-6.12 8.625-10.53 1.322-1.89 5.128-6.1 8.469-9.34 3.341-3.25 7.48-8.54 9.219-11.78 3.161-5.91 11.801-15.26 19.161-20.72 2.14-1.6 4.7-3.69 5.68-4.66 0.99-0.97 2.81-2.17 4-2.69 1.2-0.52 2.82-1.33 3.63-1.81s2.58-1.35 3.93-1.88c1.36-0.52 4.02-1.59 5.91-2.4s7.37-2.07 12.16-2.78c5.51-0.82 9.51-1.95 10.84-3.1l2.06-1.81-2.84 0.66c-2.02 0.46-2.65 0.33-2.16-0.47 0.42-0.67 0.08-1.16-0.87-1.16-1.48 0-1.47-0.12 0-1.59 2.69-2.69 0.65-2.86-2.22-0.19-5.06 4.71-12.02 4.37-10.47-0.53 0.55-1.73 0.46-1.91-0.75-0.91-1.14 0.95-1.94 0.87-3.84-0.43-3.19-2.18-3.83-3.23-3.85-6.29-0.02-3.69 3.41-7.56 7.38-8.31 1.86-0.35 3.12-1.03 2.81-1.53s-2.12-0.64-4.03-0.28c-3.27 0.61-3.36 0.55-2.34-1.34 0.59-1.11 1.52-2.19 2.09-2.38s1.46-3.15 1.94-6.56c1.07-7.58 2.13-9 6.84-9 4.22 0 9.88-1.73 9.88-3.03 0-1.21-4.65-1.13-5.41 0.09-0.8 1.29-4.44 1.26-4.44-0.03 0-0.55-1.24-0.9-2.75-0.78-4.03 0.31-4.99-0.73-5.68-6-0.56-4.22-0.9-4.75-3.04-4.75-1.83 0-2.25 0.37-1.75 1.59 1.78 4.3 1.67 4.94-1.15 5.57-4.63 1.01-5.32 1.35-5.32 2.53 0 0.62 0.85 0.89 1.88 0.62 2.32-0.6 4.78 0.7 3.19 1.69-0.6 0.37-1.13 0.17-1.13-0.44s-2.66 1.46-5.9 4.66c-3.25 3.19-5.88 6.22-5.88 6.68 0 0.47 1.32-0.44 2.94-2 1.62-1.55 2.94-2.39 2.94-1.84s-2.11 2.72-4.72 4.84c-2.62 2.13-4.6 4.46-4.38 5.13 0.4 1.19-2.8 1.76-3.87 0.69-0.69-0.69 2.85-13.74 4.69-17.28 0.79-1.53 2.89-4.22 4.71-6 1.83-1.79 3.66-4.34 4.07-5.69 1.62-5.43 5.75-10.91 10.62-14.06 0.95-0.62 1.65-0.98 2.47-1.03zm52.34 0.34c1.16 0 2.75 0.34 3.97 1 1.04 0.55 2.42 1.98 3.06 3.19 1.06 1.98 1.02 2.06-0.46 0.84-0.9-0.74-1.66-0.99-1.66-0.56s-1.12-0.26-2.47-1.53c-1.97-1.85-2.47-1.99-2.47-0.72 0 0.87 0.46 1.85 1 2.18 0.54 0.34 0.97 1.03 0.97 1.54 0 0.9-2.18 1.31-3 0.56-0.22-0.21-6.41-0.72-13.72-1.1-7.3-0.37-15.71-1.32-18.69-2.15-6.47-1.81-8.99-3.68-3.93-2.91 9.2 1.41 13.66 1.74 21.03 1.56 4.4-0.1 9.71-0.13 11.78-0.06 2.36 0.09 3.52-0.21 3.12-0.84-0.4-0.66 0.32-1 1.47-1zm264.5 0c0.87 0 1.1 0.52 0.69 1.59-0.35 0.91-0.06 2.01 0.63 2.44 1 0.62 0.97 1.03 0 2-0.68 0.67-1.22 1.93-1.22 2.75 0 1.05 0.46 0.81 1.53-0.72 1.83-2.61 4.34-2.87 4.5-0.47 0.06 0.95 0.26 3 0.44 4.53 0.24 2.09-0.05 2.65-1.1 2.25-0.77-0.29-1.75 0.15-2.22 0.97-1.07 1.92-5.32 2.42-7.43 0.88-1.73-1.27-2.17-3.44-0.72-3.44 0.48 0 1.13-0.8 1.47-1.75 0.33-0.95 0.84-2.26 1.15-2.94 0.33-0.69-0.06-1.22-0.9-1.22-0.82 0-1.79 0.89-2.13 1.97s-1.29 1.97-2.12 1.97c-1.06 0-1.31-0.52-0.82-1.72 0.39-0.94 0.95-2.53 1.22-3.47s0.87-1.45 1.35-1.15c0.47 0.29 0.54-0.23 0.18-1.16-0.5-1.31-0.25-1.57 1.07-1.06 0.93 0.36 1.45 0.26 1.15-0.22-0.29-0.48 0.15-1.14 1-1.47 0.99-0.38 1.76-0.56 2.28-0.56zm-242.87 0.97c0.54 0 0.97 0.65 0.97 1.47 0 0.81-0.43 1.46-0.97 1.46s-0.97-0.65-0.97-1.46c0-0.82 0.43-1.47 0.97-1.47zm-66.13 0.28c0.54 0.02 1.63 0.4 3.16 1.19 4.97 2.57 21.54 5.36 32.47 5.5 4.81 0.06 9.5 1.25 14.5 3.62 3.56 1.7 4.39 3.67 1.09 2.63-1.76-0.56-1.98-0.38-1.43 1.15 0.55 1.55 0.36 1.5-1.1-0.28-1.24-1.5-2.3-1.89-3.69-1.37-1.07 0.39-3.5 0.38-5.4-0.07-4.45-1.03-4.94-1.03-4.94 0 0 0.48 1.68 1.12 3.72 1.44 3.98 0.64 13 5.84 13 7.5 0 1.32-1.03 1.24-3.44-0.37-1.87-1.26-11.03-3.98-21.65-6.41-5.08-1.16-21.16-8.6-21.16-9.78 0-0.37-1.34-1.49-3-2.47-2.44-1.44-3.03-2.32-2.13-2.28zm177.63 0.19c0.29-0.04 0.24 0.42-0.03 1.46-0.65 2.47-2.28 3.67-2.28 1.69 0-0.77 0.63-1.95 1.4-2.59 0.43-0.36 0.74-0.54 0.91-0.56zm-102.19 0.81c0.07-0.11 0.47 0.26 1.22 0.94 1.17 1.05 3.49 1.71 6 1.71 3.66 0.01 4.16 0.27 4.69 2.69 1.13 5.18 1.69 5.81 2.44 2.72 0.53-2.21 0.72-1.29 0.81 3.69 0.06 3.65 0 6.62-0.16 6.62-0.96 0-2.65-2.59-2.65-4.09 0-0.97-0.45-1.78-0.97-1.78-1.67 0-7.68-5.84-9.91-9.63-1.08-1.84-1.56-2.74-1.47-2.87zm193.85 0.65c0.33 0.01 0.39 0.32-0.04 1-0.33 0.54-1.56 1.48-2.75 2.1-2.14 1.12-2.14 1.16-0.28-0.94 1.18-1.32 2.5-2.17 3.07-2.16zm-126.16 0.44c0.21 0.02 0.61 0.3 1.22 0.91 0.81 0.81 1.47 1.75 1.47 2.06 0 0.77-1.48 0.71-2.29-0.09-0.36-0.36-0.68-1.3-0.68-2.06 0-0.58 0.06-0.83 0.28-0.82zm30.28 2.72c1.19 0.03 1.25 3.44-0.06 4.25-0.54 0.34-0.97 1.45-0.97 2.47 0 2.96-2.2 6.98-3.53 6.47-0.73-0.28-1.9 1.2-2.88 3.65-1.43 3.57-2.09 6.39-3.94 16.91-0.19 1.08-1.05 5.67-1.93 10.19-1.5 7.67-1.46 10.27 0.15 8.66 0.38-0.38 1.26-4.33 1.94-8.79 1.06-6.89 1.15-7.12 0.66-1.68-0.32 3.51-0.74 10.94-0.88 16.53-0.14 5.58-0.43 10.37-0.68 10.62-0.26 0.26-0.67-2.29-0.91-5.65-0.41-5.65-0.75-6.34-4.22-9.25-3.46-2.91-3.7-3.46-3.22-7.07 0.29-2.15 1.2-5.41 2.03-7.25 0.84-1.83 2.24-5.55 3.13-8.25 0.88-2.69 1.96-5.35 2.4-5.9 0.44-0.56 1.57-3.43 2.47-6.41 1.93-6.35 8.49-18.9 10.19-19.47 0.09-0.03 0.17-0.03 0.25-0.03zm89.91 0.88c0.56-0.03 0.39 0.4-0.44 1.4-1.36 1.64-2.97 1.96-2.97 0.6 0-0.49 0.71-1.18 1.56-1.5 0.9-0.35 1.51-0.49 1.85-0.5zm-86.75 1.9c0.12 0 0.08 6.27-0.1 13.97-0.38 16.47 0.31 22.86 2.38 22.06 1.82-0.7 1.95 6.79 0.15 8.69-0.67 0.71-1.95 2.17-2.84 3.25-0.89 1.09-2.42 2.44-3.37 2.97-2.15 1.2-3.41 12-1.41 12 0.85 0 1.03-1.02 0.59-3.38-0.36-1.95-0.21-3.6 0.38-3.96 0.59-0.37 1 0.42 1 1.93 0 1.47 0.44 2.32 1 1.97 0.54-0.33 0.97-1.71 0.97-3.06 0-1.39 0.44-2.19 1-1.84 0.54 0.33 0.97 2.28 0.97 4.34 0 5.21 1.06 9.91 2.21 9.91 0.56 0 0.74-1.36 0.41-3.19-1.69-9.37-1.55-11.69 0.28-4.69 1.06 4.06 2.13 8.49 2.41 9.85 0.3 1.46 2.52 3.99 5.5 6.21 2.74 2.05 4.72 4.17 4.37 4.72-0.34 0.56-2.35 0.9-4.44 0.75-2.08-0.15-4.08 0.03-4.46 0.41-0.87 0.87-1.34 0.79-3.82-0.63-3.82-2.19-6.04-4.12-8.28-7.18-2.05-2.82-2.28-4.23-2.4-15.44-0.13-11.28 0.02-12.5 1.81-13.81 1.34-0.99 2.18-1.07 2.62-0.35 0.45 0.72 1.13 0.6 2.1-0.37 2.01-2.01 2.8-5.04 1.75-6.72-0.74-1.18-1.35-1.23-3.56-0.22-4.23 1.92-4.87 0.42-3.57-8.41 0.62-4.2 1.42-10.54 1.78-14.06 0.37-3.52 0.73-6.83 0.85-7.37 0.27-1.3 3.42-8.35 3.72-8.35zm-120.85 0.32c0.36-0.07 0.57 0.12 0.57 0.53 0 0.54-0.43 1.26-0.97 1.59s-1 0.2-1-0.34 0.46-1.29 1-1.63c0.13-0.08 0.28-0.13 0.4-0.15zm39.31 0.46c0.29-0.06 0.61 0.01 1.04 0.16 1.69 0.6 1.72 0.72 0.25 1.28-1.14 0.44-1.66 1.79-1.66 4.28 0 4.23 0.9 3.88 1.94-0.78 0.6-2.71 0.86-1.91 1.5 4.88 1.05 11.17 2.74 11.65 1.97 0.56-0.47-6.62-0.34-8.3 0.5-6.97 0.6 0.96 1.37 7.22 1.68 13.91 0.63 13.36 0.74 12.97-5.96 20.22-1.97 2.12-3.59 4.68-3.6 5.65-0.05 4.19-4.44 10.99-11.37 17.66-9.69 9.32-9.61 11.33 0.5 12.47 6.95 0.78 8.51 2.3 7 6.72-1.07 3.1-7.94 8.83-7.94 6.62 0-0.54 1.35-1.7 2.97-2.62 3.36-1.92 3.88-5.09 0.97-5.85-1.09-0.28-1.97-0.82-1.97-1.19s-2.22-1.45-4.94-2.43l-4.97-1.79 0.56-19.34c0.32-10.62 0.8-21.97 1.03-25.22 0.24-3.24 0.74-10.88 1.1-16.97 0.66-11.18 1.9-15.43 1.72-5.9-0.08 4.24-0.02 4.43 0.31 1 0.57-6.04 3.22-4.96 3.22 1.31 0 1.46 0.56 2.38 1.47 2.38 1.29-0.01 1.43 2.71 0.87 21.62-0.47 15.97-0.33 21.66 0.5 21.66 0.81 0 1.1-5.44 1.1-19.19 0-11.2 0.4-19.19 0.93-19.19 0.55 0 0.77 6.24 0.57 15.25-0.2 8.62 0.05 15.5 0.56 15.81 0.53 0.33 0.91-5.69 0.91-14.75 0-9.54 0.35-15.31 0.96-15.31 0.54 0 1.02 2.32 1.07 5.16 0.04 2.84 0.45 7.39 0.87 10.09 0.72 4.59 0.78 4.37 0.91-3.37 0.09-5.95 0.43-8.04 1.19-7.28 0.58 0.58 1.29 2.89 1.59 5.12s0.94 4.03 1.44 4.03c0.49 0 0.83-0.54 0.75-1.22-0.09-0.67-0.12-1.87-0.04-2.69 0.12-1.16 0.38-1.12 1.19 0.29 0.77 1.32 0.66 2.38-0.5 4.15-1.78 2.72-2.02 4.41-0.59 4.41 0.54 0 0.97-0.66 0.97-1.47s0.42-1.5 0.9-1.5c0.49 0 1.15-1.14 1.5-2.56 0.48-1.92-0.03-3.65-2.06-6.66-5.6-8.33-5.89-9.35-4.78-16.44 0.68-4.35 1.03-5.8 1.87-6zm98.97 0.19c-0.54 0-0.97 0.49-0.97 1.06 0 0.58 0.43 0.74 0.97 0.41s1-0.79 1-1.03-0.46-0.44-1-0.44zm45.25 0.13c0.63 0 1.25 0.06 1.72 0.18 0.95 0.25 0.18 0.47-1.72 0.47-1.89 0-2.66-0.22-1.72-0.47 0.48-0.12 1.1-0.18 1.72-0.18zm-16.72 0.87c1.62 0 1.15 3.64-1 7.47-1.1 1.97-1.81 3.78-1.53 4.06 0.76 0.76 3.63-1.81 4.57-4.12 0.77-1.91 0.81-1.88 0.87 0.28 0.04 1.35-1.23 3.42-3.12 5.16-1.75 1.59-2.75 2.93-2.22 3 0.52 0.06 1.62 0.17 2.43 0.24 0.88 0.08 1.63 1.32 1.82 3.07 0.45 4.19 1.9 5.23 2.72 1.97l0.65-2.72 1.28 2.34c1.17 2.17 1 2.36-2.37 3.53-4.81 1.68-4.66 1.76-4.53-2.15 0.07-2.27-0.33-3.44-1.19-3.44-0.72 0-1.3 0.54-1.31 1.22-0.01 0.82-0.27 0.89-0.75 0.18-0.4-0.58-1.52-1.33-2.47-1.68-1.26-0.47-1.72-1.75-1.72-4.69 0-2.22-0.44-4.89-1-5.94-0.85-1.58-0.69-1.9 0.94-1.9 3.26 0 6.97-2.15 6.97-4.07 0-0.99 0.42-1.81 0.96-1.81zm13.72 0.97c0.58 0 1.04 0.46 1.04 1s-0.2 0.97-0.44 0.97-0.7-0.43-1.03-0.97c-0.34-0.54-0.14-1 0.43-1zm75.25 0.31c-0.53 0.09-1.28 1.15-1.68 2.69-0.44 1.67-0.31 1.83 0.84 0.88 0.77-0.64 1.41-1.82 1.41-2.6 0-0.74-0.25-1.02-0.57-0.97zm-371.46 0.72c0.579 0.03 1.413 0.54 2.187 1.47 0.685 0.82 0.942 1.78 0.594 2.12-0.347 0.35-0.625 0.1-0.625-0.53s-0.657-1.12-1.469-1.12c-0.811 0-1.5-0.46-1.5-1 0.001-0.55 0.246-0.83 0.594-0.91 0.073-0.01 0.136-0.03 0.219-0.03zm366.5 1.28c-0.11 0.02-0.23 0.08-0.37 0.16-0.54 0.33-1 0.79-1 1.03s0.46 0.44 1 0.44 0.97-0.46 0.97-1.03c0-0.43-0.24-0.66-0.6-0.6zm-7.15 0.57c0.49-0.09 1.31 0.73 2.53 2.53 3.15 4.63 2.43 6.69-0.88 2.47-1.4-1.8-2.31-3.91-2.03-4.66 0.09-0.23 0.22-0.32 0.38-0.34zm-193.91 0.15c0.5-0.05 1.05 0.98 1.13 3.13 0.23 6.67 1.04 7.84 1.84 2.68 0.61-3.91 0.68-3.53 0.81 3.22 0.09 4.2-0.07 7.63-0.34 7.63s-0.47-1.12-0.47-2.47-0.39-2.47-0.84-2.47c-1.35 0-3.1-4.76-3.1-8.41 0-2.15 0.47-3.26 0.97-3.31zm-36.15 0.13-0.63 4.59c-0.36 2.51-1.08 9.57-1.62 15.69-0.55 6.11-1.43 12.2-1.94 13.56-0.52 1.36-0.97 5.68-0.97 9.62 0 3.95-0.28 9.9-0.63 13.22-0.56 5.42-0.84 6.07-2.81 6.07-1.21 0-2.76 0.65-3.43 1.47-0.68 0.81-1.62 1.5-2.1 1.5-1.12-0.01-1.12-2.33 0-3.54 1.55-1.67 3.99-15.42 4.63-26 0.34-5.68 0.94-10.77 1.28-11.31s0.82-6.27 1.09-12.75l0.5-11.78 3.31-0.19 3.32-0.15zm-95.03 0.15c0.8 0.03 1.34 0.22 1.34 0.6 0 0.55-0.11 1-0.25 1s-1.68 0.43-3.44 0.93c-3 0.86-4.4-0.03-2.19-1.4 1.18-0.73 3.2-1.17 4.54-1.13zm80.21 0.03c0.17-0.05 0.52 0.53 0.91 1.5 0.52 1.3 0.75 2.51 0.53 2.72-0.49 0.5-1.64-2.43-1.56-3.97 0.01-0.15 0.07-0.23 0.12-0.25zm260.29 0.66c0.28-0.1 0.01 0.4-0.66 1.66-1.22 2.29-2.06 2.84-2.06 1.34 0-0.47 0.75-1.44 1.65-2.19 0.56-0.46 0.9-0.75 1.07-0.81zm-377.16 1c0.134 0.05 0.385 0.26 0.75 0.62 0.672 0.67 0.959 1.48 0.656 1.79-0.303 0.3-0.849-0.25-1.219-1.22-0.333-0.88-0.411-1.27-0.187-1.19zm356.31 0.38c0.06-0.01 0.11-0.02 0.16 0 0.2 0.07 0.27 0.47 0.28 1.09 0.01 1.56 0.16 1.62 0.91 0.44 0.5-0.8 1.26-1.11 1.65-0.72s-0.26 1.72-1.44 2.97c-2.14 2.28-2.88 5.59-1.25 5.59 0.49 0 1.15-1.02 1.47-2.31 0.84-3.34 3.53-4.23 3.53-1.16 0 1.3-0.42 2.67-0.96 3-0.55 0.34-1 3.63-1 7.34-0.01 7.13-0.56 9.85-2.1 9.85-0.51 0-0.64-0.46-0.28-1.03 0.86-1.4-0.43-7.82-1.56-7.82-0.49 0-0.83 2.62-0.82 5.82 0.02 3.85-0.55 6.69-1.65 8.37-0.92 1.4-2.05 2.53-2.53 2.53-1.33 0-1.04-1.11 0.78-3.12 1.21-1.34 1.66-3.77 1.72-9.19 0.04-4.5-0.34-7.23-0.94-7.03-0.54 0.18-1.12 1.14-1.31 2.12-0.19 0.99-0.75 2.29-1.25 2.88-0.51 0.59-1.55 1.95-2.32 3.03-1.26 1.79-1.33 1.65-0.5-1.47 0.51-1.89 1.61-6.26 2.44-9.72 1.04-4.31 2.45-7.21 4.47-9.28 1.39-1.42 2.11-2.12 2.5-2.18zm-352.25 1.28c0.427-0.03 1.697 1.08 4.313 3.62 2.756 2.67 5.286 4.56 5.626 4.22s-0.53-1.69-1.94-3c-3.723-3.45-3.18-4.16 0.84-1.09 4.1 3.12 4.28 4.27 1 7.12-1.35 1.18-2.81 2.16-3.21 2.16-0.91 0-5.627-8.47-6.598-11.81-0.224-0.78-0.287-1.21-0.031-1.22zm25.279 0.68c0.88-0.15-4.22 5.72-7.87 9-5.91 5.31-7.07 6.54-7.07 7.38 0 0.48 0.22 0.87 0.5 0.87 0.74 0 7.13-5.78 10.72-9.71 5.16-5.65 5.59-6.04 7.28-6.04 1.15 0 0.56 1-1.9 3.22-2.55 2.3-4.72 6.03-7.72 13.28-2.3 5.56-4.58 10.32-5.03 10.6s-1.3-0.42-1.91-1.56c-0.93-1.74-0.63-2.75 1.69-6.16 4.53-6.65 4.68-7.24 1.13-3.88-3.87 3.66-6.32 4.1-7.22 1.25-0.42-1.3 0.14-2.93 1.62-4.71 2.31-2.8 12.71-11.81 15.5-13.44 0.11-0.07 0.22-0.09 0.28-0.1zm262.91 0.88c0.04-0.01 0.07-0.01 0.12 0 0.14 0.03 0.34 0.18 0.53 0.37 0.78 0.78 0.79 1.58 0.04 2.88-0.93 1.59-1.1 1.48-1.13-1.06-0.01-1.39 0.13-2.1 0.44-2.19zm-115.25 0.03c0.21-0.05 0.56 0.37 1.16 1.16 1.42 1.88 1.43 1.88 1.59-0.07 0.08-1.08 0.51 0.92 0.97 4.44 0.92 7.18 2.89 12.03 3.81 9.41 0.5-1.42 0.78-1.4 2.78 0 1.21 0.84 2.17 2.27 2.16 3.19-0.03 1.45-0.24 1.42-1.5-0.26-1.43-1.89-1.43-1.89-1.44 0-0.01 1.62-0.17 1.69-1.03 0.44-0.84-1.21-0.98-1.12-0.72 0.5 0.23 1.43 1.06 1.98 3.12 2 2.02 0.03 3.12 0.68 3.69 2.22 0.45 1.2 1.23 2.16 1.72 2.16 0.5 0 1.12 0.88 1.41 1.97 0.28 1.08 0.95 1.97 1.53 1.97 1.2 0 0.53-2.14-2-6.38-2.21-3.71-4.75-9.33-4.75-10.47 0-0.47-0.44-0.84-0.97-0.84-1.14 0-3.98-6.43-3.87-8.75 0.04-0.88 0.61-0.25 1.24 1.37 1.2 3.07 3.64 7.09 6.88 11.31 1.75 2.28 1.83 2.29 1.22 0.29-0.64-2.1-0.58-2.12 2.22-0.72 2.49 1.24 2.99 2.16 3.56 6.75 0.36 2.92 0.36 6.9 0 8.84-0.46 2.44-0.31 3.53 0.5 3.53 0.78 0 1 1.06 0.62 3.19l-0.56 3.19 1.47-3.19c2.29-4.99 3.43-3.76 1.66 1.78-1.55 4.86-1.55 5.11 0.69 9.6 2.67 5.36 3.57 7.47 5.03 11.46 0.82 2.27 1.25 2.6 1.93 1.5 0.98-1.58 0.84-1.89 2.91 5.72 0.66 2.43 0.85 6.08 0.47 8.63-0.5 3.34-0.29 4.73 0.81 5.62 1.8 1.46 2.97 4.63 1.72 4.63-0.51 0-1.39-0.89-1.97-1.97s-1.56-1.97-2.19-1.97c-0.85 0-0.84 0.28 0.03 1.16 0.65 0.65 1.19 3.19 1.19 5.65 0 2.69 0.79 5.75 1.94 7.63 1.05 1.72 2.19 4.76 2.56 6.75 0.48 2.52 0.91 3.21 1.5 2.28 0.68-1.07 0.87-1.01 0.88 0.22 0.01 0.84-0.5 2.02-1.13 2.65-0.86 0.87-0.87 2.07-0.03 4.88 0.61 2.05 1.4 6.21 1.75 9.25 0.41 3.46 0.27 5.73-0.37 6.12-1.12 0.69-7.1-5.94-7.1-7.87 0-0.65-0.57-1.8-1.25-2.53-2.33-2.54-12.3-21.26-12.87-24.16-0.19-0.93-0.67-2.42-1.07-3.34-0.39-0.92-0.44-2.15-0.09-2.72s-0.05-1.06-0.87-1.06c-0.99 0-2.05-1.96-3.13-5.66-0.9-3.1-2-6.31-2.41-7.13-0.4-0.81-1.51-4.78-2.46-8.84s-2.01-7.83-2.38-8.37c-1.17-1.74-2.98-8.98-2.97-11.91 0.01-2.19 0.23-2.52 0.97-1.38 0.53 0.82 0.96 2.48 0.97 3.69 0.01 1.22 0.38 2.22 0.81 2.22 0.44 0 1.61 2.93 2.63 6.47 1.01 3.54 2.23 6.67 2.72 6.97 1.76 1.09 1.87-0.57 0.25-4.25-2.32-5.26-3.74-9.14-7.13-19.5-0.88-2.71-2.08-5.22-2.62-5.6-1.31-0.89-1.82-8.68-0.57-8.68 0.54 0 1 0.77 1 1.72 0.03 2.99 5.3 18.51 9.28 27.31 0.74 1.62 2.73 6.06 4.44 9.84 5.95 13.14 9.08 19.19 9.91 19.19 0.46 0-0.65-3-2.47-6.66-5.87-11.74-9.21-19.35-9.81-22.37-0.55-2.74-0.54-2.8 0.53-0.75 0.63 1.22 1.47 2.22 1.84 2.22 0.38 0 1.55 1.89 2.56 4.18 1.02 2.3 2.12 4.39 2.44 4.66 0.33 0.27 1.46 2.05 2.5 3.94 2.76 5 5.34 8.35 5.25 6.78-0.04-0.75-0.93-2.69-1.97-4.31-1.03-1.63-2.45-4.06-3.12-5.41s-1.51-2.67-1.88-2.94c-0.36-0.27-1.75-2.93-3.09-5.9-1.34-2.98-3.15-6.3-4-7.38-1.48-1.87-1.56-1.87-1.59-0.12-0.06 3.23-2.4 0.15-3.82-5-0.72-2.61-1.9-6.07-2.62-7.69-1.49-3.36-4.39-12.95-4.44-14.63-0.02-0.61-0.63-1.91-1.4-2.93-1.28-1.68-1.38-1.5-0.85 1.97 0.33 2.1 0.32 3.57 0 3.28s-0.8-3.15-1.09-6.32c-0.3-3.16-1.22-7.05-2.03-8.68-0.82-1.63-1.5-4.56-1.5-6.47 0-1.84 0.04-2.66 0.31-2.72zm78.5 0.59c0.56-0.02 0.87 0.2 0.87 0.69 0 1.27-3.77 5.22-5 5.22-0.55 0-1.68 0.66-2.5 1.47-0.81 0.81-2.04 1.5-2.75 1.5-0.7 0-1.85-0.69-2.53-1.5-0.84-1.02-0.89-1.47-0.12-1.47 0.6 0 1.13 0.57 1.15 1.25 0.03 0.68 1.49-0.42 3.25-2.41 2.27-2.55 5.94-4.68 7.63-4.75zm-111.78 0.5c-0.17 0.02-0.27 0.76-0.25 1.97 0.02 1.63 0.22 2.15 0.47 1.19s0.23-2.27-0.04-2.94c-0.06-0.16-0.13-0.22-0.18-0.22zm87.18 0c0.36-0.06 0.47 0.53 0.22 1.47-0.6 2.3-1.31 2.6-1.31 0.57 0-0.78 0.42-1.67 0.91-1.97 0.06-0.04 0.13-0.06 0.18-0.07zm35.38 0.57c2.08 0 4.41 1.57 7.75 4.97 2.74 2.77 4.97 5.57 4.97 6.18s1.16 2.3 2.53 3.78c2.16 2.33 3.27 2.69 8.13 2.69 5.82 0 17.52 2.01 21.81 3.72 1.35 0.54 5.78 1.3 9.84 1.69 4.43 0.42 9.41 1.64 12.47 3.06 2.81 1.3 5.65 2.38 6.28 2.38s2.46 1.08 4.06 2.43c2.71 2.28 2.4 2.99-1.06 2.5-0.86-0.12-1.13 0.39-0.75 1.38s0.04 1.56-0.94 1.56c-0.96 0-1.42 0.77-1.31 2.19 0.1 1.21 0.12 2.79 0.06 3.47-0.21 2.45-2.66 1.17-2.62-1.38 0.03-2.02-0.5-2.67-2.41-2.97-1.34-0.21-4.01-1.51-5.93-2.84-1.93-1.34-4.14-2.41-4.88-2.41s-2.16-0.72-3.16-1.62c-1.59-1.45-2.11-1.48-4.4-0.25-3.14 1.68-24.07 1.82-26.1 0.18-0.71-0.57-2.8-1.38-4.65-1.78-3.99-0.85-9.42-3.72-9.44-5-0.02-1.19-3.64-5.31-4.66-5.31-0.44 0-0.33 0.89 0.25 1.97 1.75 3.26 0.1 2.25-5.18-3.19-2.76-2.84-4.69-4.61-4.28-3.93 0.4 0.67 0.29 1.21-0.26 1.21-1.44 0-1.98-1.23-2.18-5-0.24-4.46 0.23-5.97 2.47-8.03 1.19-1.09 2.34-1.66 3.59-1.65zm-73.53 0.62c0.58-0.03 0.69 0.46 0.69 1.66 0 1.18 0.71 3.12 1.56 4.34 1.79 2.56 1.52 4.87-0.34 3-0.67-0.67-1.24-1.68-1.26-2.25-0.01-0.57-0.74-1.92-1.59-3-1.51-1.92-1.53-1.94-0.84 0.34 0.43 1.46 0.35 2.13-0.25 1.76-2.13-1.32-1.91-4.16 0.4-5.26 0.78-0.36 1.28-0.57 1.63-0.59zm-18.47 0.5c0.05 0.04 0.13 0.23 0.19 0.53 0.23 1.22 0.23 3.22 0 4.44-0.24 1.22-0.44 0.22-0.44-2.22 0-1.82 0.1-2.87 0.25-2.75zm120.69 1.53c0.3-0.13 0.68 0.82 1.47 3.16 1.58 4.69 1.26 5.76-1.07 3.44-1.78-1.79-1.84-1.98-0.97-5.25 0.22-0.79 0.38-1.27 0.57-1.35zm-176.38 0.22c0.58 0 1.07 0.46 1.07 1s-0.2 0.97-0.44 0.97-0.73-0.43-1.06-0.97c-0.34-0.54-0.14-1 0.43-1zm63.94 0c0.45 0 1.09 1.23 1.37 2.72 0.58 2.97 0.26 3.91-0.74 2.28-1.08-1.74-1.5-5-0.63-5zm185.78 0c0.42 0 0.86 1.12 0.97 2.47 0.23 2.8-0.25 3.2-1.12 0.91-0.82-2.12-0.77-3.38 0.15-3.38zm-285.25 0.1c1.94-0.06 3.02 0.31 2.66 0.9-0.34 0.54-0.71 0.93-0.82 0.88-0.1-0.06-1.27-0.45-2.62-0.88-2.31-0.74-2.28-0.81 0.78-0.9zm19.25 0.03c0.73-0.07 1.85 0.04 3.59 0.21 8.5 0.85 10.44 5.73 9.54 24.26-0.6 12.18-3.86 25.92-8.04 33.96-0.76 1.47-1.15 3.22-0.9 3.88s-0.25 1.77-1.1 2.47c-1.19 0.99-1.27 1.58-0.37 2.65 0.87 1.05 0.86 1.67 0 2.54-0.63 0.62-1.13 1.74-1.13 2.46 0 0.73-0.83 2.23-1.87 3.35-2.07 2.22-1.73 4.98 0.5 4.12 0.77-0.29 1.37-0.03 1.37 0.57 0 1.96-4.08 1.16-4.62-0.91-0.28-1.08-0.9-1.97-1.38-1.97-1.13 0-1.12 0.7 0.13 3.03 0.78 1.47 0.7 1.88-0.37 1.88-0.77 0-1.73-0.97-2.13-2.19l-0.72-2.22-0.44 2.22c-0.54 2.74-2.28 2.93-2.28 0.25 0-1.09-0.65-1.97-1.47-1.97-0.91 0-1.46 0.91-1.46 2.44 0 1.35-0.46 2.47-1 2.47-2.77 0 0.84-7.21 6.78-13.57 1.65-1.77 3.51-5.09 4.09-7.37 0.58-2.29 1.25-4.74 1.5-5.47s0.68-6.27 0.97-12.28c0.33-6.79 1.26-13.11 2.44-16.69l1.87-5.75-2.44-9.03c-1.33-4.97-2.4-10.08-2.4-11.34 0-1.36 0.12-1.9 1.34-2zm-52.75 1.84c0.11 0-0.06 0.49-0.37 1.47-0.35 1.08-2.24 3.67-4.19 5.75-4.37 4.64-8.97 8.04-8.97 6.62 0-0.57 0.42-1.06 0.91-1.06 0.87 0 8.44-7.52 11.37-11.31 0.76-0.98 1.14-1.47 1.25-1.47zm159.72 0c2.14 0 2.17 0.1 0.97 3.25-0.51 1.34-0.51 2.94-0.03 3.72 0.59 0.96 1.03 0.12 1.5-2.78 0.36-2.28 0.94-3.95 1.31-3.72 0.92 0.57 0.08 7.3-1 7.97-0.48 0.29-0.91 1.61-0.91 2.93 0 1.33-0.46 2.41-1.06 2.41-0.64 0-0.86-0.92-0.53-2.25 0.34-1.37-0.19-3.5-1.34-5.4-2.15-3.54-1.69-6.13 1.09-6.13zm46.31 0c2.28 0 2.21 1.22-0.56 10.84-1.93 6.7-2 10.85-0.22 13.29 1.14 1.55 1.61 1.64 2.88 0.59 0.83-0.7 1.33-1.77 1.09-2.41-0.24-0.63 0.71-1.67 2.09-2.31 2.48-1.15 2.54-1.11 1.88 1.97-0.37 1.72-1.11 3.67-1.66 4.34-1.41 1.76-5.25 1.53-7.22-0.44-2.1-2.1-4.39-7.35-3.68-8.5 0.76-1.24 0.9-9.5 0.15-9.5-0.34 0.01-0.94 1.66-1.34 3.69l-0.75 3.69-1.28-2.94c-2.26-5.12-1.79-7.33 1.97-8.9 1.85-0.78 3.66-1.86 4-2.41s1.54-1 2.65-1zm-133.62 1.19c0.06-0.03 0.17 0.01 0.25 0.09 0.32 0.33 0.34 1.17 0.06 1.88-0.31 0.78-0.52 0.55-0.56-0.6-0.03-0.78 0.05-1.3 0.25-1.37zm-76.28 0.28c0.36 0 0.35 0.46-0.25 1.44-0.36 0.57-1.63 1.54-2.82 2.15-2.05 1.07-2.05 0.97 0.22-1.5 1.28-1.38 2.38-2.09 2.85-2.09zm182.53 0.69c0.06-0.03 0.17 0.01 0.25 0.09 0.32 0.33 0.34 1.16 0.06 1.88-0.31 0.78-0.55 0.55-0.59-0.6-0.04-0.78 0.08-1.3 0.28-1.37zm-85.06 0.81c-0.89 0-1.99 5.88-1.32 6.97 0.94 1.51 1.21 1.03 1.6-3.03 0.2-2.17 0.07-3.94-0.28-3.94zm-71.16 0.47c-0.41 0.12-1.21 0.72-2.5 1.81-1.72 1.45-3.67 2.62-4.38 2.62-0.7 0-1.85 0.66-2.53 1.47-1.58 1.92-0.57 1.86 3.28-0.15 1.71-0.89 3.79-1.9 4.6-2.28 0.81-0.39 1.65-1.52 1.84-2.5 0.15-0.74 0.1-1.1-0.31-0.97zm169.09 0.34c0.02-0.01 0.04-0.01 0.07 0 0.05 0.03 0.09 0.17 0.15 0.41 0.25 0.94 0.25 2.49 0 3.44-0.25 0.94-0.44 0.17-0.44-1.72 0-1.25 0.09-2.02 0.22-2.13zm-72.15 0.72c0.89 0.01 1.55 13.99 1 21.91-0.13 1.8 0.29 3.88 0.9 4.62 0.62 0.74 0.84 2.2 0.5 3.25-0.33 1.05-0.12 4.97 0.47 8.66s0.84 7.59 0.56 8.69c-0.76 3.05-5.5 9.12-5.5 7.06 0-0.94 0.61-1.94 1.35-2.22 1.56-0.6 4.21-7.95 3.22-8.94-1.9-1.9-6.69-0.97-9.75 1.91-4.03 3.78-8.89 4.92-15.57 3.65-2.84-0.53-5.31-1.12-5.5-1.31-0.77-0.78 0.98-3.56 2.25-3.56 0.76 0 1.38-0.49 1.38-1.06 0-0.6 0.84-0.8 1.97-0.44 1.56 0.5 1.83 0.3 1.31-1.06-0.4-1.05-0.28-1.45 0.34-1.07 0.56 0.35 2.03-0.47 3.29-1.81 2.94-3.13 4.08-3.09 2.87 0.09s-1.25 9.29-0.06 9.29c0.49 0 1.09-2.55 1.31-5.66 0.3-4.21 0.01-5.99-1.09-6.91-0.94-0.78-1.03-1.22-0.29-1.22 0.65 0.01 1.16-1.08 1.16-2.4s0.35-2.61 0.78-2.88c0.43-0.26 0.59 1.02 0.38 2.88-0.24 2.05 0.05 3.37 0.72 3.37 0.62 0 1.13-1.97 1.22-4.65 0.1-3.31 0.29-3.81 0.59-1.72 0.85 5.99 2.24 4.81 2.41-2.03 0.09-4.01 0.3-5.29 0.53-3.13 0.21 2.03 0.82 3.69 1.34 3.69 0.56 0 0.73-1.83 0.37-4.44-0.39-2.89-0.25-4.43 0.44-4.43 0.7 0 1.06 3.74 1.06 10.96 0.01 6.05 0.27 10.74 0.6 10.41s0.61-6.03 0.62-12.69c0.02-9.06 0.23-11 0.82-7.68 0.42 2.43 0.8 7.83 0.84 12.03 0.04 4.37 0.5 7.62 1.06 7.62 1.2 0 1.21-0.25 0-21.06-0.64-11.08-0.65-17.04 0-17.69 0.03-0.03 0.07-0.03 0.1-0.03zm192.96 0.59c0.16 0.04 0.42 0.39 0.85 1.13 0.57 0.99 0.85 1.99 0.62 2.22-0.69 0.69-1.75-0.78-1.71-2.44 0.01-0.64 0.09-0.94 0.24-0.91zm-161.18 0.19c0.35 0.02 0.56 0.43 0.56 1.06 0 0.85-0.43 1.53-0.97 1.53s-1-0.39-1-0.9 0.46-1.23 1-1.56c0.14-0.09 0.29-0.13 0.41-0.13zm64.47 0.63c-1.4 0-1.13 1.33 0.78 3.72 1.83 2.29 3.19 2.82 3.19 1.21-0.01-0.54-0.41-1-0.91-1-0.51 0-1.19-0.88-1.53-1.97-0.35-1.08-1.03-1.96-1.53-1.96zm-258.19 0.31c0.07-0.06 0.236 0.03 0.437 0.15 1.037 0.65 9.384 17.59 10.434 21.19 0.4 1.36 1.17 3.03 1.72 3.72s0.78 1.47 0.5 1.75c-0.27 0.28-1.17-0.97-2-2.75s-3.44-7.19-5.78-12.06c-4.448-9.25-5.616-11.75-5.311-12zm67.811 1.09c-0.13 0.06 0.07 0.66 0.47 1.72 0.54 1.45 1.54 3.54 2.22 4.63 0.68 1.08 1.6 1.73 2.03 1.47 1.26-0.78 0.87-1.63-2.28-5.29-1.54-1.78-2.26-2.6-2.44-2.53zm100.5 0.06 0.72 11.82c0.39 6.49 1.13 15.36 1.66 19.68 1.87 15.48 1.96 17.34 0.97 16.72-0.54-0.33-0.97-2.1-0.97-3.93s-0.38-3.56-0.85-3.85c-0.46-0.28-0.65 3.77-0.44 9.03 0.55 13.44 1.29 20 2.26 19.41 0.45-0.28 0.71-1.64 0.56-3.03s0.05-2.16 0.47-1.72c0.41 0.44 0.9 2.9 1.09 5.47 0.37 4.95-0.11 5.66-2.19 3.16-0.7-0.86-2.92-2.41-4.93-3.44-4.1-2.09-5.48-5.59-4.32-11.03 1.48-6.91 4.41-7.04 4.41-0.22 0 2.37 0.43 4.57 0.97 4.9 1.18 0.74 1.19 0.24 0.03-14.75-1.17-15.14-1.22-28.2-0.22-39.34l0.78-8.88zm-125.12 0.5c1.13 0 0.52 1.8-3.85 11.66l-3.62 8.22 1.78 4.06c0.97 2.25 2.71 5.44 3.87 7.06 2.41 3.35 3.65 7.38 2.32 7.38-0.49 0-0.88-0.74-0.88-1.66 0-1.72-4.66-7.22-6.12-7.22-0.46 0 0.04 1.24 1.09 2.72 3.31 4.69 3.42 6.71 0.5 9-3.86 3.04-4.67 2.64-3.94-1.93 0.57-3.52 0.29-4.5-2.44-7.94-2.88-3.64-3.07-4.32-2.59-9.66 0.36-4 1.31-6.89 3.13-9.53 2.56-3.71 2.6-3.73 1.93-0.84-0.37 1.62-1.1 3.73-1.59 4.68-0.55 1.07-0.49 2.39 0.12 3.44 0.9 1.53 0.98 1.51 1-0.4 0.02-1.18 0.73-3.38 1.54-4.91s2.15-4.36 3-6.25c2.59-5.82 3.85-7.88 4.75-7.88zm41.9 0c-0.54 0-0.97 0.46-0.97 1 0 0.55 0.43 0.97 0.97 0.97s1-0.42 1-0.97c0-0.54-0.46-1-1-1zm25.69 0c0.49 0 0.88 0.89 0.88 1.97 0 1.09-0.17 1.97-0.38 1.97s-0.59-0.88-0.88-1.97c-0.28-1.08-0.11-1.97 0.38-1.97zm247.38 2.13c0.28-0.07 0.69 0.42 1 1.22 0.35 0.91 0.42 1.88 0.15 2.15-0.27 0.28-0.8-0.24-1.15-1.15-0.36-0.91-0.37-1.89-0.1-2.16 0.04-0.03 0.05-0.05 0.1-0.06zm-130.82 0.19c-0.32 0.12-0.59 1.8-0.59 4.09 0 2.62 0.18 4.54 0.41 4.31 0.76-0.78 1.01-7.67 0.31-8.37-0.05-0.05-0.08-0.05-0.13-0.03zm-164.94 0.9c-0.34 0.01-0.68 0.09-1 0.28-0.75 0.47-0.68 0.95 0.26 1.54 1.75 1.11 2.78 1.08 2.78-0.07 0-1.02-1-1.76-2.04-1.75zm293.1 1.22 0.06 2.82c0.04 1.61-0.68 3.41-1.66 4.15-2.29 1.74-4.18 1.72-4.18-0.06 0-0.8 0.57-1.21 1.28-0.94 0.75 0.29 1.97-0.86 2.9-2.75l1.6-3.22zm-356 0.1c1.016 0.04 1.64 0.71 2.5 2.37 1.871 3.61 1.851 6.75-0.031 7.47-0.812 0.31-1.469 1.13-1.469 1.75s-1.03 2.21-2.281 3.56c-1.252 1.35-2.743 3.33-3.344 4.41-0.965 1.72-1.125 1.49-1.406-1.97-0.247-3.03-0.699-3.87-1.969-3.66-0.906 0.15-1.938-0.16-2.281-0.71-0.344-0.56-1.91-1.04-3.469-1.04s-3.061-0.35-3.344-0.81c-1.13-1.83 10.041-9.71 15.906-11.22 0.44-0.11 0.849-0.17 1.188-0.15zm19.311 0.31c0.37 0.01 0.43 0.69-0.06 2.28-0.38 1.22-0.93 3.22-1.22 4.44-0.29 1.21-0.9 2.22-1.37 2.22-0.48 0-0.91 0.65-0.91 1.47 0 0.81-0.43 1.46-0.97 1.46-1.46 0-1.22-1.55 1.09-6.93 1.31-3.03 2.82-4.95 3.44-4.94zm181.38 0.06c1.46 0 1.18 3.55-0.38 4.85-0.75 0.61-1.6 2.33-1.91 3.81-0.53 2.59-3.53 7.44-3.59 5.81-0.02-0.44 1.09-3.23 2.44-6.19 1.35-2.95 2.47-6.01 2.47-6.81s0.43-1.47 0.97-1.47zm-35.19 0.5 0.87 3.85c0.91 3.86 0.81 5.08-0.4 3.87-0.36-0.36-0.65-2.25-0.6-4.19l0.13-3.53zm-71.91 0.09c0.07-0.01 0.15-0.01 0.19 0.04 0.34 0.34-0.66 2.48-2.22 4.75-3.2 4.65-5.97 7.27-5.97 5.65 0-0.58 0.67-1.41 1.44-1.84s2.44-2.7 3.75-5c1.14-2.01 2.31-3.48 2.81-3.6zm238.66 0.41c2.74 0.01 3.32 0.26 2.22 0.97-1.94 1.25-5.91 1.25-5.91 0 0-0.54 1.66-0.98 3.69-0.97zm-80 1.35c0.35 0 0.59 0.36 0.59 0.96 0 0.8 0.54 1.63 1.19 1.85 0.92 0.3 0.92 0.55 0 1.12-0.65 0.4-1.19 0.23-1.19-0.37 0-0.61-0.46-0.81-1-0.47-0.54 0.33-0.97-0.06-0.97-0.88 0-0.81 0.43-1.76 0.97-2.09 0.14-0.08 0.29-0.13 0.41-0.12zm92.47 0.12c0.02-0.01 0.04-0.01 0.06 0 0.11 0.05 0.24 0.34 0.34 0.84 0.22 1.01-0.07 2.26-0.59 2.78-0.62 0.62-0.74-0.04-0.37-1.84 0.22-1.12 0.4-1.7 0.56-1.78zm-233.1 0.34c0.35-0.05 0.73 0.47 1.16 1.6 0.8 2.09-2.56 25.12-4.16 28.47-0.75 1.57-1.37 3.46-1.37 4.18 0 0.73-0.46 1.32-1 1.32-1.25 0-1.26-2.43-0.03-4.66 2-3.65 4.17-15.81 4.12-23.09-0.03-4.85 0.52-7.7 1.28-7.82zm70.75 0.25c-0.22-0.08-0.14 0.28 0.19 1.16 0.37 0.97 0.92 1.55 1.22 1.25s0.02-1.11-0.66-1.78c-0.36-0.36-0.61-0.58-0.75-0.63zm-125.5 0.16c-0.32 0-0.61 0.01-0.87 0.03-5.95 0.56-5.74 1.69 0.31 1.69 3.55 0 5.86 0.48 6.63 1.41 0.8 0.96 3.08 1.4 7.09 1.34 3.35-0.05 5.49-0.45 5-0.94-1.31-1.31-13.27-3.57-18.16-3.53zm217.29 0.72c-0.71 0.01-0.58 0.43 0.31 1 1.89 1.22 2.22 1.22 1.47 0-0.34-0.54-1.14-1.01-1.78-1zm-93.94 0.12c-0.17 0.04-0.19 0.55-0.19 1.63 0 1.21 0.44 2.97 0.94 3.9 0.5 0.94 1.14 2.53 1.43 3.47 0.3 0.95 0.79 1.72 1.1 1.72 0.95 0-0.67-7.24-2.1-9.31-0.65-0.95-1.01-1.44-1.18-1.41zm179.62 0.03c0.18 0.01 0.39 0.01 0.6 0.04 1.79 0.25 2.11 1.05 2.37 5.65 0.17 2.95 0.06 6.38-0.25 7.63-0.31 1.24-1.07 2.28-1.66 2.28-0.58 0-0.76-0.7-0.43-1.56 1.46-3.8 1.72-6.32 0.69-6.32-0.6 0-1.09 1.23-1.1 2.72-0.01 2.02-0.26 2.35-0.94 1.28-0.54-0.86-0.52-2.08 0.04-3.12 0.5-0.94 0.87-3.21 0.81-5-0.07-2.07-0.33-2.53-0.63-1.28-0.8 3.32-1.91 3.69-1.44 0.47 0.32-2.13 0.72-2.81 1.94-2.79zm-26.34 0.97c0.44 0 0.88 0.09 1.22 0.22 0.67 0.28 0.13 0.47-1.22 0.47s-1.93-0.19-1.25-0.47c0.34-0.13 0.8-0.22 1.25-0.22zm-93 0.1c0.22-0.23 0.88 1.52 1.5 3.87 3.2 12.2 14.82 29.35 19.84 29.35 0.96 0 3.35 1.11 5.35 2.47l3.62 2.46h-4.44c-2.75 0-4.93-0.58-5.68-1.5-1.57-1.89-4.91-1.91-4.91-0.03 0 2.54 3.18 3.28 14.97 3.44 10.28 0.14 12.23-0.14 18.19-2.44 9.18-3.54 16.95-7.33 20.62-10.06 1.7-1.26 4.04-2.46 5.22-2.69s3.11-0.71 4.28-1.06c1.63-0.48 1.32 0.1-1.31 2.41-1.89 1.65-3.99 2.8-4.69 2.56s-1.55 0.34-1.9 1.28c-0.73 1.9-4.2 5.04-5.6 5.09-0.5 0.02-1.61 0.65-2.47 1.41-2.16 1.91-13.45 7.73-18.78 9.69-2.43 0.89-7.07 2.08-10.28 2.65-7.82 1.4-9.13 1.39-7.63-0.12 2.07-2.06 1.33-2.47-5.71-3.13-5.22-0.48-7.8-1.3-10.75-3.34-2.15-1.48-3.95-3.08-3.97-3.56s-1.08-1.83-2.35-3c-2.51-2.33-4.44-11.38-2.43-11.38 0.59 0 0.84-0.88 0.56-1.97-0.28-1.08-0.15-1.97 0.34-1.97 0.49 0.01 0.91 0.69 0.91 1.54 0 0.84 1.11 3.95 2.47 6.9 1.35 2.96 2.43 5.75 2.43 6.19 0 1 3.47 5.03 4.32 5.03 1.33 0 0.51-2.3-1.82-5.06-1.33-1.59-2.92-4.73-3.53-7-0.6-2.28-1.5-4.65-2-5.25-0.49-0.6-1.32-4.38-1.84-8.38-0.52-3.99-1.39-8.76-1.94-10.62s-0.82-3.56-0.59-3.78zm-153.16 0.31c0.05 0 0.1 0 0.13 0.03 0.26 0.26-0.31 1.22-1.28 2.16-1.7 1.62-1.75 1.6-0.5-0.47 0.62-1.04 1.32-1.73 1.65-1.72zm253.75 0.56c0.36-0.11 0.35 0.31 0.16 1.32-0.2 1.02-0.92 2.02-1.59 2.24-1.76 0.59-1.54-1.22 0.34-2.78 0.51-0.42 0.88-0.71 1.09-0.78zm-282.69 1c-0.83 0.08-1.69 0.94-1.81 2.56-0.11 1.55 0.4 2.22 1.66 2.22 1.28 0 1.78-0.7 1.78-2.5 0-1.61-0.79-2.35-1.63-2.28zm-28.71 0.85c0.4 0 0.24 1.46-0.35 3.21-1.6 4.81-2.66 5.41-1.44 0.82 0.59-2.21 1.39-4.03 1.79-4.03zm249.78 1.09c-0.76 0.01-0.93 0.26-0.63 0.75 0.38 0.61 2.09 1.16 3.82 1.22 1.72 0.05 4.24 0.44 5.59 0.87 3.37 1.08 9.84 1.19 9.84 0.16 0-0.46-3-1.14-6.65-1.5-3.66-0.36-8.14-0.92-9.97-1.25-0.89-0.16-1.55-0.26-2-0.25zm-187.72 0.03c0.48 0 0.17 0.79-0.85 2.19-1.02 1.41-2.24 2.54-2.71 2.56-1.22 0.05 1.76-4.17 3.31-4.69 0.1-0.03 0.18-0.06 0.25-0.06zm177.91 0.13c0.03-0.06 0.56 0.17 1.62 0.68 1.22 0.59 2.22 1.28 2.22 1.54 0 0.75-0.53 0.54-2.53-1.07-0.92-0.73-1.35-1.09-1.31-1.15zm-206.19 0.4c-1.63 0.03-1.88 0.6-0.81 1.66 0.9 0.91 3.51 0.77 5.12-0.25 0.93-0.59 0.25-0.99-2.22-1.28-0.85-0.1-1.55-0.14-2.09-0.13zm-59.5 1.32c1.84 0 4.95 3.68 5.5 6.5 0.48 2.52 0.06 3.59-2.41 6.12-1.65 1.69-3.3 4.66-3.66 6.56-0.35 1.9-1.014 3.44-1.495 3.44s-0.906 1.31-0.906 2.94c0 2.26-0.441 2.97-1.907 2.97-2.482 0-3.336-1.5-3.968-6.91-0.487-4.17-0.687-4.41-3.594-4.5-6.712-0.21-8.173-2.99-3.781-7.16 3.048-2.89 3.216-1.59 0.219 1.66l-2.219 2.38 2.469-0.72c1.352-0.41 3.003-1.17 3.656-1.69 0.652-0.52 1.573-0.72 2.031-0.44 1.313 0.81 7.917-5.8 8.625-8.62 0.35-1.4 1.02-2.53 1.44-2.53zm181.97 0c-0.54 0-0.97 0.42-0.97 0.96s0.43 1 0.97 1 1-0.46 1-1-0.46-0.96-1-0.96zm168.37 0c0.5 0 0.43 0.88-0.15 1.96-0.58 1.09-1.21 1.97-1.41 1.97s-0.13-0.88 0.15-1.97c0.29-1.08 0.91-1.96 1.41-1.96zm-92.69 0.43c1.81 0 3.56 0.65 4.94 2.03 1.28 1.29 1.24 1.48-0.47 1.57-1.06 0.05-0.24 0.48 1.81 0.97 2.06 0.48 6.27 2.07 9.35 3.53l5.59 2.65-5.65 1.69c-4.13 1.22-6.65 1.41-9.35 0.78-4.8-1.11-5.42-1.09-4.68 0.09 0.33 0.55 1.92 1 3.53 1 2.57 0.01 2.86 0.3 2.47 2.47-0.4 2.16-0.11 2.44 2.37 2.44 3.25 0 4.84-1.57 2.25-2.25-1.08-0.28-0.75-0.49 0.94-0.56 1.58-0.07 2.72-0.68 2.72-1.47s1.51-1.58 3.68-1.94c5.67-0.93 20.87-0.72 25.82 0.38 6.79 1.51 7.4 1.82 6.12 3.09-0.82 0.82-1.47 0.83-2.47 0-1.82-1.51-14.68-3.28-19.19-2.62-2 0.29-5.16 0.7-7.03 0.87-4.56 0.43-4.94 2.21-0.56 2.72 2.82 0.33 3.42 0.12 2.97-1.06-0.41-1.07-0.02-0.95 1.44 0.37 1.95 1.77 2 1.76 2.03-0.06 0.03-1.83 0.06-1.83 1.47 0.03 0.79 1.05 1.44 1.33 1.44 0.66 0-0.68 0.52-0.91 1.12-0.53 0.6 0.37 1.47 0.05 1.94-0.69 0.72-1.15 0.86-1.14 0.87 0 0.01 1.04 0.32 1.1 1.38 0.22s1.75-0.78 2.97 0.43c0.87 0.87 1.56 1.08 1.56 0.5 0-0.57 0.66-1.03 1.47-1.03s1.47 0.47 1.47 1.07 0.73 0.83 1.59 0.5 1.97-0.33 2.5 0c1.84 1.13-11.36 7.02-16.19 7.22-1.08 0.04-1.52 0.52-1.09 1.21 0.5 0.82-0.43 0.97-3.41 0.57-3.66-0.49-4-0.39-2.87 0.96 1.11 1.34 0.95 1.43-1.19 0.76-1.35-0.43-3.13-0.99-3.94-1.29-1.26-0.46-1.25-0.33-0.09 1.1 2.61 3.21-4.73 1.96-10.66-1.81-2.95-1.88-5.95-3.41-6.69-3.41-0.73 0-1.04-0.45-0.68-1.03s-0.29-1.96-1.44-3.03-3.44-4.77-5.12-8.22l-3.1-6.28 2.84-2.53c1.55-1.39 3.42-2.06 5.22-2.07zm-240.25 0.22c1.91 0.01 3.25 2.54 3.25 7.09 0 2.56-0.53 5.2-1.18 5.85-1.77 1.76-3.45 1.41-5.16-1.03-1.59-2.28-2.03-7.42-0.78-9.13 1.39-1.89 2.73-2.79 3.87-2.78zm50.66 1.69c-0.07 0.02-0.12 0.05-0.19 0.09-0.54 0.34-1 1.06-1 1.57 0 0.5 0.46 0.9 1 0.9s0.97-0.69 0.97-1.53c0-0.63-0.24-1.02-0.59-1.03-0.06 0-0.12-0.02-0.19 0zm12.87 0.06c0.29-0.12 0.23 0.59-0.03 2.34-0.25 1.71-0.86 3.13-1.34 3.13-1.3 0-1.07-2.34 0.44-4.41 0.45-0.61 0.77-0.99 0.93-1.06zm193.6 0.66c0.34-0.02 0.71 0.04 1.06 0.18 0.79 0.32 0.58 0.55-0.56 0.6-1.04 0.04-1.64-0.17-1.31-0.5 0.16-0.16 0.47-0.27 0.81-0.28zm18.59 1.97c0.63 0 1.25 0.06 1.72 0.18 0.95 0.25 0.18 0.47-1.72 0.47-1.89 0-2.66-0.22-1.72-0.47 0.48-0.12 1.1-0.18 1.72-0.18zm-289.65 0.21c-1.45 0.11-8.41 5.58-8.41 6.76 0 1.09 5.52-2.06 7.63-4.38 0.86-0.95 1.32-1.99 1-2.31-0.05-0.05-0.13-0.07-0.22-0.07zm342.46 0.94c2.02-0.1 4.19 0.61 6.72 2.1 3.23 1.88 4.41 3.24 4.41 4.87 0 3.19-1 3.83-3.09 1.94-2.6-2.35-3.46-0.79-1.44 2.62 1.46 2.48 1.48 2.81 0.19 2.32-0.84-0.33-1.57-0.06-1.57 0.56 0 0.61 0.71 1.37 1.54 1.69 1.1 0.42 1.21 0.9 0.43 1.84-0.75 0.91-0.77 1.46 0 1.94 0.72 0.44 0.78 1.06 0.13 1.84-0.61 0.73-0.63 1.73-0.06 2.63 0.5 0.79 0.9 2.75 0.9 4.37 0 2.71-0.2 2.53-2.56-2.22-1.42-2.84-2.96-5.15-3.44-5.15s-0.35 1 0.28 2.21c2.45 4.73 2.78 5.71 2.78 7.57 0 1.05 0.46 2.19 1 2.53 1.24 0.76 1.32 4.4 0.1 4.4-0.5 0.01-1.5 0.19-2.22 0.41-1.61 0.5-5.58-0.66-8.47-2.47-1.75-1.09-2.77-1.11-5.31-0.15-1.74 0.65-3.29 1.05-3.47 0.87-0.57-0.57 5.01-5.76 7.06-6.56 1.9-0.74 1.93-0.78 0.13-1.5-1.27-0.51-2.26-0.2-3.07 0.9-2.9 3.98-4.43 0.26-4.43-10.84 0-7.14 0.66-8.81 5.75-14.22 2.74-2.91 5.13-4.37 7.71-4.5zm-306.18 0.03c-0.12 0.03-0.27 0.08-0.41 0.16-0.54 0.33-1 1.08-1 1.63 0 0.54 0.46 0.67 1 0.34 0.54-0.34 0.97-1.05 0.97-1.6 0-0.4-0.21-0.59-0.56-0.53zm158.75 0.66c0.43 0 0.77 1.18 0.75 2.63-0.03 1.44-0.68 2.83-1.44 3.09-0.97 0.32-1.21-0.03-0.75-1.22 0.36-0.93 0.66-2.36 0.66-3.13 0-0.76 0.35-1.37 0.78-1.37zm113.75 0.13c0.44 0 0.56 0.29 0.56 0.74 0 0.47-1.9 1.56-4.22 2.44-6.29 2.4-7.83 1.79-2.19-0.87 3.44-1.62 5.1-2.32 5.85-2.31zm-131.32 0.87c-0.57 0-0.77 0.43-0.43 0.97 0.33 0.54 0.79 1 1.03 1s0.44-0.46 0.44-1-0.46-0.97-1.04-0.97zm77.47 0c-3.22-0.03-0.78 1.66 3.5 2.44 2.32 0.42 4.5 0.73 4.91 0.65s0.75 0.28 0.75 0.82 0.25 1 0.56 1c0.32 0 0.42-0.47 0.22-1.07-0.4-1.2-7.14-3.82-9.94-3.84zm43.85 0.13c0.52 0 0.72 0.26 0.72 0.84 0 0.54-1.23 0.97-2.72 0.94-2.4-0.07-2.46-0.19-0.72-0.94 1.34-0.58 2.19-0.84 2.72-0.84zm-11.1 0.96c0.45 0 0.92 0.09 1.25 0.22 0.68 0.28 0.11 0.5-1.25 0.5-1.35 0-1.89-0.22-1.22-0.5 0.34-0.13 0.78-0.22 1.22-0.22zm-117.65 0.07c0.06-0.03 0.13 0.01 0.22 0.09 0.32 0.33 0.34 1.16 0.06 1.88-0.32 0.78-0.52 0.55-0.56-0.6-0.04-0.78 0.08-1.3 0.28-1.37zm141.93 0.15c0.28 0 0.54 0.18 0.76 0.53 0.34 0.57-0.7 1.7-2.32 2.53-3.63 1.89-4.03 1.88-4.03 0.04 0-0.82 0.81-1.47 1.78-1.47 0.98 0 2.26-0.48 2.85-1.07 0.36-0.36 0.69-0.55 0.96-0.56zm-227.34 1.28c0.79 0.02 0.93 2.74 0.63 11-0.23 6.3-0.78 11.93-1.19 12.47-0.42 0.54-1.05 2.37-1.41 4.07-0.36 1.69-1.76 4.12-3.15 5.4-4.08 3.77-7.23 9.39-7.88 14.13-0.65 4.76 0.29 5.62 3.13 2.78 1.38-1.39 2.28-1.48 5.59-0.6 3.21 0.86 4.47 0.73 6.72-0.56 2.86-1.64 5.84-6.71 5.84-9.91 0-2.42 1-2.61 11.1-2.21l8.59 0.34v5.87 5.85l-3.69-0.66c-2.03-0.37-3.91-1.01-4.18-1.4-0.28-0.39-1.52-1.05-2.79-1.44-1.7-0.53-2.79-0.13-4.25 1.44-1.08 1.16-4.35 3.14-7.28 4.43-2.93 1.3-5.34 2.74-5.34 3.22s-1.12 1.47-2.47 2.19-2.47 1.72-2.47 2.19-0.87 1.79-1.94 2.94c-1.06 1.14-2.28 3.88-2.72 6.09-0.61 3.15-1.3 4.09-3.06 4.34-1.23 0.18-2.45 0.95-2.75 1.72-0.68 1.78-1.75 1.7-7.09-0.47-5.02-2.03-7.22-4.5-6.81-7.81 0.22-1.85 1.29-2.68 4.97-3.84 2.56-0.82 4.65-2.07 4.65-2.75 0-0.69 0.5-1.41 1.06-1.6 0.67-0.22 0.49-1.61-0.5-3.97-0.9-2.16-1.32-5.01-1-7.03 0.61-3.84-0.52-5.02-3.97-4.15-1.74 0.43-2.45 1.5-2.93 4.28-0.36 2.03-1.65 4.94-2.91 6.5-2.14 2.65-2.39 2.73-3.28 1-0.66-1.28-0.47-3.45 0.59-6.97 1.72-5.71 4.78-8.04 13.19-10.16 2.57-0.64 4.66-1.58 4.66-2.06s0.69-0.88 1.5-0.88c0.81 0.01 1.47-0.36 1.47-0.84s0.94-1.14 2.06-1.44c1.12-0.29 2.24-1.44 2.53-2.56s1.02-2.03 1.56-2.03 0.72-0.89 0.44-1.97-0.13-1.74 0.31-1.47c1.56 0.97 2.87-5.97 2.47-13.09-0.43-7.66-0.08-9.6 1.84-10.34 0.06-0.03 0.11-0.04 0.16-0.04zm255.63 0.41c-0.48 0.04-1.31 0.38-2.82 1.06-1.37 0.63-2.53 1.48-2.53 1.91 0 0.42 1.35 0.35 2.97-0.22s2.94-1.42 2.94-1.91c0-0.57-0.09-0.88-0.56-0.84zm-126.57 0.56c0.51-0.31 1.23 4.42 1.6 10.88 0.63 11.05 0.38 14.18-0.75 10.43-1.05-3.46-1.74-20.76-0.85-21.31zm138 0.35c-0.2-0.02-0.4 0.06-0.62 0.28-0.33 0.32-0.27 1.12 0.16 1.81 0.61 1 0.85 1 1.18 0 0.36-1.07-0.1-2.03-0.72-2.09zm-36.34 0.5c0.53-0.06 0.88 0.13 0.88 0.53 0 0.52-0.66 0.93-1.47 0.93-0.82 0-1.47-0.16-1.47-0.37s0.65-0.66 1.47-0.97c0.2-0.08 0.41-0.1 0.59-0.12zm-240.31 0.5c0.12 0 0.15 0.31 0.12 0.96-0.03 0.82-0.47 2.39-0.93 3.47-0.85 1.97-0.83 1.97-0.88 0-0.03-1.08 0.35-2.65 0.88-3.47 0.42-0.65 0.68-0.96 0.81-0.96zm-29.07 1.37c-0.15 0.01-0.37 0.08-0.65 0.19-0.78 0.3-1.64 1.17-1.94 1.94-0.82 2.13 1.16 1.68 2.35-0.54 0.62-1.17 0.71-1.62 0.24-1.59zm145.91 0.06c0.03-0.01 0.06 0 0.09 0 0.18 0.03 0.45 0.24 0.88 0.6 0.77 0.64 1.41 1.55 1.41 2.03 0 1.71-1.74 0.79-2.25-1.19-0.24-0.91-0.31-1.36-0.13-1.44zm-170.97 0.19 2.66 2.88c2.26 2.43 2.55 3.41 2.03 6.65-0.57 3.57-2.58 6.19-6.66 8.57-1.35 0.78-1.58 0.67-1.12-0.54 0.49-1.28 0.11-1.25-2.47 0.22-2.01 1.14-2.59 1.86-1.62 2.06 0.8 0.18 1.5 0.63 1.5 1 0 1.26-3.85 3.1-5.32 2.54-0.8-0.31-2.27-0.14-3.25 0.43-1.59 0.93-1.51 1.07 0.66 1.1 2.3 0.03 2.34 0.12 0.72 1.75-0.94 0.94-2.48 1.71-3.41 1.72-0.93 0-1.72 0.68-1.72 1.53 0 1.96-3.11 5.18-4.31 4.43-0.5-0.3-2.17-0.07-3.688 0.5-1.688 0.65-2.31 1.3-1.624 1.72 0.806 0.5 0.616 2.11-0.688 5.82-2.386 6.77-6.636 12.56-10.625 14.46-1.777 0.86-3.366 1.54-3.531 1.54-0.66 0 0.625-21.17 1.312-21.63 0.406-0.27 1.029-1.61 1.375-2.97 0.551-2.15 17.349-20.65 18.749-20.65 0.29 0 2.81-2.15 5.56-4.79 3.26-3.1 6.83-5.4 10.22-6.56l5.25-1.78zm-15.53 0.44c0.53-0.03 1 0.5 1.41 1.56 0.42 1.1-0.38 2.55-2.38 4.38-3.36 3.07-3.98 1.7-1.47-3.16 0.96-1.84 1.76-2.75 2.44-2.78zm44.63 0.22c-0.48 0-1.19 0.37-1.85 1.03-1.73 1.73-0.88 2.12 1.44 0.65 0.8-0.5 1.18-1.19 0.81-1.56-0.09-0.09-0.24-0.12-0.4-0.12zm-48.91 0.09c0.21-0.04 0.34 0.03 0.34 0.22 0 0.5-0.88 1.67-1.97 2.59-1.08 0.93-1.96 1.33-1.96 0.88s0.88-1.65 1.96-2.63c0.68-0.61 1.28-0.98 1.63-1.06zm69.84 0.97c0.25 0.05 0.34 0.76 0.35 2.25 0.01 1.73-0.46 3.42-1 3.75-1.26 0.78-1.26-3.46 0-5.41 0.27-0.42 0.51-0.62 0.65-0.59zm5.63 0.44c0.29 0.11 0.14 3.1-0.56 7.09-0.62 3.49-1.49 6.74-1.94 7.25-1.12 1.28-1.05-2.04 0.12-5.78 0.53-1.66 1.25-4.26 1.57-5.81 0.35-1.75 0.58-2.59 0.75-2.72 0.02-0.02 0.04-0.04 0.06-0.03zm241.4 0.28c0.19 0.03 0.22 0.39 0.22 1.12 0 0.93-0.33 1.69-0.75 1.69-0.69 0-5.54 6.71-9.12 12.63-0.84 1.37-2.12 2.68-2.88 2.93-1.24 0.42 8.2-14.07 11.41-17.5 0.59-0.63 0.94-0.91 1.12-0.87zm-70.96 0.69c0.18-0.02 0.76 0.46 1.75 1.56 1.41 1.57 2.53 3 2.53 3.19 0 0.73-0.72 0.26-2.13-1.38-1.67-1.95-2.45-3.34-2.15-3.37zm-48.6 1.15c0.95 0 1.87 1.91 2.69 5.6 1.22 5.43 1.3 5.51 2.59 3.18 1.47-2.64 1.7-1.74 0.78 2.85-0.33 1.65-1.24 3.26-2.03 3.56-1.01 0.39-1.25 0.03-0.87-1.19 0.61-1.93-1.77-10.64-3.47-12.68-0.85-1.03-0.79-1.32 0.31-1.32zm156.56 0.19c0.07-0.02 0.14 0.01 0.22 0.09 0.33 0.33 0.35 1.17 0.07 1.88-0.32 0.78-0.52 0.55-0.57-0.6-0.03-0.77 0.08-1.3 0.28-1.37zm-120.5 0.78c-1.13 0-1.1 0.71 0.19 3.13 0.59 1.09 1.27 1.8 1.47 1.59 0.67-0.67-0.76-4.72-1.66-4.72zm-183.09 0.09c3.29 0.09 3.41 0.21 1.22 0.91-3.52 1.13-4.94 1.13-4.94 0 0-0.54 1.69-0.96 3.72-0.91zm270.72 0.79c0.35 0-0.47 1.24-2.63 4.15-2.16 2.93-4.67 6.63-5.59 8.25-2.18 3.85-6.08 9.28-8.75 12.13-1.67 1.78-1.84 2.42-0.81 3.06 0.91 0.57 0.98 1 0.22 1.47-0.6 0.37-1.1 0.17-1.1-0.47 0-0.82-0.48-0.77-1.68 0.19-1.6 1.26-1.61 1.18-0.16-1.13 5.33-8.49 5.3-8.46 9.03-13.28 1.26-1.62 3.49-4.94 5-7.37 1.51-2.44 3.91-5.28 5.28-6.32 0.63-0.46 1.03-0.69 1.19-0.68zm-99.31 0.12c-1.39 0-1.25 5.96 0.22 9.13 0.67 1.45 1.57 2.68 2 2.68 0.42 0.01 0.34-0.86-0.22-1.9-0.56-1.05-1.03-3.71-1.03-5.91s-0.43-4-0.97-4zm102.72 1.97c1.3 0 0.4 2.64-1.69 4.91-3.25 3.52-13.92 20.85-16.06 26.06-1.01 2.43-2.22 4.43-2.66 4.44-1.01 0 0.15-3.8 1.94-6.38 0.74-1.07 1.31-2.7 1.31-3.62 0-0.93 0.63-2.26 1.38-3 0.74-0.74 1.59-2.23 1.93-3.32 0.35-1.08 2.63-5.04 5.07-8.75 2.43-3.7 4.4-7.09 4.4-7.53 0-0.76 3.2-2.81 4.38-2.81zm30.43 0.41c0.15-0.04 0.36 0.14 0.63 0.56 0.52 0.81 0.96 2.27 0.97 3.22 0.01 0.94-0.43 1.72-0.97 1.72s-0.98-1.46-0.97-3.22c0.01-1.52 0.1-2.22 0.34-2.28zm-159.75 0.56c0.53 0 0.72 0.66 0.41 1.47s-0.76 1.5-0.97 1.5-0.4-0.69-0.4-1.5c-0.01-0.81 0.44-1.47 0.96-1.47zm141.35 1c-1.69 0-6.57 3.72-6.57 5.03 0.01 0.54 1.78 0 3.94-1.22 3.98-2.23 5.09-3.81 2.63-3.81zm9.19 0c-0.55 0-1 0.46-1 1.03-0.01 0.57 0.45 0.77 1 0.44 0.54-0.34 0.96-0.83 0.96-1.06 0-0.24-0.42-0.41-0.96-0.41zm-177.16 0.97c0.41 0 1.25 1.89 1.84 4.18 0.6 2.3 1.93 6.85 3 10.1 1.08 3.24 2.73 8.53 3.66 11.78 3.13 10.91 12.31 29.52 22.4 45.47 2.92 4.61 13.88 16.19 16.82 17.75 1.82 0.97 1.81 1.03-0.22 2.12-1.76 0.94-2.04 0.88-1.56-0.37 0.31-0.83 0.16-1.5-0.38-1.5-0.53 0-3.11-2.01-5.75-4.44-2.63-2.43-5.11-4.43-5.53-4.44-1.41-0.02 2.19 4.44 5.62 6.91 3.84 2.77 4.43 3.98 1.54 3.22-2.67-0.7-10.68-9.57-17.16-19-4.51-6.57-4.53-6.53-4.53-4.69 0 0.82 1.15 2.74 2.53 4.31 1.38 1.58 3.13 4.29 3.88 6.04 0.74 1.74 4.66 6.52 8.71 10.59 6.04 6.05 7.03 7.41 5.25 7.41-5.77 0-24.32-16.82-34.31-31.1-1.85-2.65-4.69-7.16-6.28-10s-3.25-5.15-3.69-5.16c-0.44 0-0.6 0.35-0.37 0.76 4.48 8.09 9.79 16.67 13.15 21.24 2.34 3.18 4.25 6.11 4.25 6.54 0 1.18 5.01 6.19 8.85 8.84 1.89 1.31 3.66 2.66 3.94 3 0.27 0.34 2.5 1.78 4.93 3.22 2.44 1.44 3.88 2.65 3.19 2.66-0.69 0-2.89-1.03-4.91-2.29-6.28-3.91-8.06-4.2-4.75-0.75 1.59 1.66 3.63 3.04 4.5 3.04 0.88 0 2.45 0.64 3.5 1.43 1.05 0.8 2.8 1.43 3.88 1.44 1.59 0.01 1.67-0.13 0.5-0.87-2.34-1.49-0.75-1.79 1.94-0.38 1.35 0.71 1.89 1.3 1.18 1.31-0.7 0.01-1.02 0.43-0.68 0.97 0.33 0.54 0.07 1-0.57 1-0.86 0-0.85 0.37 0.07 1.47 1.43 1.73 1.28 1.71-1.97-0.09-1.36-0.75-3.21-1.37-4.16-1.38s-1.72-0.46-1.72-1-0.52-0.97-1.12-0.97c-2.05 0-12.11-6.71-18.72-12.47-6.26-5.45-16.43-16.75-21.31-23.72-1.44-2.04-2.17-4.31-1.97-6.15 0.29-2.83 0.44-2.73 4.47 3.25 2.28 3.38 5.17 7.24 6.4 8.59 1.24 1.36 3.94 4.56 6 7.13 2.07 2.56 4.2 4.68 4.75 4.68 0.96 0-1.73-3.85-6.03-8.59-1.09-1.2-2-2.46-2-2.81s-2.2-3.43-4.9-6.88c-2.71-3.44-4.94-6.54-4.94-6.87 0-0.34-0.82-1.78-1.82-3.22-1.95-2.81-3.3-7.05-2.24-7.03 0.35 0 1.51 1.83 2.56 4.03 1.75 3.66 6.44 10.68 6.44 9.66-0.01-0.24-1.53-3.53-3.41-7.32-1.89-3.78-3.43-7.19-3.44-7.56-0.02-0.99 3.89-2.08 7.81-2.19 3.3-0.08 3.58 0.2 7.63 7.78 2.31 4.33 4.53 8.54 4.94 9.35 2.7 5.41 12.61 20.86 15.47 24.12 1.89 2.17 3.45 4.25 3.46 4.66 0.03 0.97 1.97 0.97 1.97 0 0-0.41-0.99-1.84-2.22-3.19-2.08-2.3-4.84-6.07-7.12-9.72-0.55-0.87-1.87-2.87-2.91-4.4-3.26-4.85-5.4-8.78-8.97-16.38-1.9-4.06-4.29-9.15-5.31-11.31-1.01-2.16-2.11-5.71-2.44-7.87l-0.59-3.94 2.44 4.94c1.35 2.7 2.48 5.67 2.5 6.62 0.03 1.63 2 2.59 2 0.97 0-0.42-1.58-4.52-3.5-9.06-1.92-4.55-3.31-9.17-3.1-10.29 0.31-1.6 0.56-1.36 1.16 1.16 0.42 1.76 1.15 3.22 1.63 3.22 1.1 0 1.1-1.51 0-3.69-1.53-3-2.93-6.6-3.44-8.93-0.41-1.88-0.22-2.06 0.94-1.1 1.78 1.48 1.74 1.28-0.54-6.94-1.04-3.78-1.54-6.9-1.12-6.9zm-60.28 3.94c3.13 0 2.95 0.68-1.06 4.59-3.29 3.19-7.44 4.4-7.44 2.19 0-1.94 6.08-6.78 8.5-6.78zm196.22 0c0.9 0-2.94 6.6-5.91 10.15-1.21 1.45-1.24 1.91-0.19 2.56 0.91 0.57 0.98 1.03 0.22 1.5-0.6 0.37-1.14 0.09-1.16-0.62-0.05-2.44-4.87 4.23-4.87 6.75 0 2 0.27 2.3 1.31 1.44 2.37-1.97 2.64 0.05 0.41 3.18-1.2 1.69-2.06 3.72-1.91 4.54 0.25 1.29 0.17 1.3-0.68 0.03-0.7-1.03-0.53-1.95 0.59-3.19 0.87-0.96 1.31-2.06 0.97-2.41-0.79-0.78-4.45 3.69-4.16 5.07 0.12 0.55 0.01 0.68-0.22 0.28-0.67-1.21-3.22-0.87-3.75 0.5-0.27 0.69-1.48 1.35-2.69 1.43l-2.15 0.13 2.22-1.81c1.22-1.01 2.8-2.01 3.47-2.25s0.95-0.69 0.68-0.97c-0.6-0.64-13.13 5.17-13.59 6.31-0.18 0.45-0.98 0.81-1.75 0.81s-3.27 0.87-5.56 1.94c-2.3 1.07-6.1 2.64-8.47 3.47-4.76 1.66-10.25 2.11-6.53 0.53 1.08-0.46 4.19-1.41 6.87-2.09 3.45-0.89 5.84-2.35 8.28-5 1.9-2.07 4.06-3.75 4.75-3.75 0.7 0 1.25-0.41 1.25-0.88s2.62-2 5.82-3.44c6.84-3.07 16.45-11.2 14.97-12.68-0.65-0.65-2.47-0.27-5.44 1.12-2.46 1.16-4.79 2.09-5.16 2.09-1.47 0.01-8.22 3.39-8.22 4.13 0 0.44-1.94 0.81-4.31 0.81s-5.96 0.69-7.97 1.53c-4.02 1.69-11.46 1.57-12.03-0.18-0.23-0.71 2.07-1.38 6.34-1.82 8.65-0.89 20.44-4.21 25.1-7.09 2.02-1.25 4.16-2.28 4.75-2.28s4.04-2.1 7.65-4.63c3.62-2.52 5.99-3.96 5.32-3.21-2.43 2.66-1.16 3.05 1.81 0.56 1.66-1.4 3.43-2.56 3.94-2.56zm-95.13 0.24c0.17 0 0.4 0.15 0.69 0.44 0.59 0.59 0.9 1.8 0.72 2.72-0.44 2.16-1.82 0.79-1.82-1.81 0.01-0.91 0.13-1.33 0.41-1.35zm-18.59 2c-0.07 0-0.12 0.03-0.16 0.07-0.3 0.3 0.39 1.83 1.53 3.43 1.14 1.61 2.07 3.41 2.07 4-0.01 0.6 0.22 1.07 0.5 1.07 0.27 0 0.5-0.54 0.5-1.22-0.01-1.62-3.47-7.2-4.44-7.35zm134.97 0.54c0.14 0.02 0.28 0.12 0.4 0.31 1.39 2.19 0.98 6.12-1.09 10.19-3 5.88-2.56 9.48 1.66 14.18 2.27 2.54 4.44 4 5.9 4 1.27 0 3.09 0.4 4.03 0.88s3.45 1.71 5.6 2.72c2.15 1 4.78 2.62 5.84 3.56s2.62 1.91 3.47 2.19c0.85 0.27 2.28 2.27 3.19 4.43 0.93 2.23 2.31 3.94 3.18 3.94 0.9 0 1.57 0.84 1.57 1.97 0 2.83-2.41 2.4-5.19-0.91-1.7-2.01-2.81-2.58-3.78-1.96-2.19 1.38-2.69 1.12-5.72-3.07-1.58-2.17-3.03-3.38-3.25-2.71-0.22 0.66-4.94-3.36-10.53-8.88l-10.19-10.03 0.56-6.69c0.57-6.74 2.8-13.8 4.22-14.09 0.05-0.01 0.08-0.04 0.13-0.03zm-215.63 0.68 0.63 6.41c0.34 3.51 0.46 6.52 0.25 6.75s-0.38-0.09-0.38-0.72c0-0.78-2.53-1.16-7.87-1.16-7.26 0.01-7.88-0.15-7.88-2 0-2.27 0.77-2.65 6.69-3.31 3.14-0.35 4.82-1.2 6.4-3.22l2.16-2.75zm-15.9 0.85c0.26 0 0.28 0.37 0.03 1.03-0.66 1.7-1.35 2.04-1.35 0.62 0-0.51 0.44-1.2 0.97-1.53 0.14-0.08 0.26-0.12 0.35-0.12zm54.34 0.22c0.02-0.01 0.06 0.02 0.09 0.06 0.45 0.62 0.98 10.23 1.16 21.37 0.18 11.15 0.06 20.28-0.25 20.28-0.32 0-0.6-4.16-0.6-9.21 0-5.06-0.21-14.67-0.53-21.38-0.29-6.29-0.25-11.07 0.13-11.12zm-79.84 0.37c0.33-0.01 0.56 0.23 0.56 0.88 0 0.47-0.61 1.39-1.38 2.03-1.14 0.95-1.28 0.78-0.84-0.88 0.32-1.23 1.1-2.01 1.66-2.03zm134.15 0.13c1.06-0.23 2.15 2.3 1.56 4.18-0.41 1.32-0.22 1.64 0.66 1.1 0.93-0.57 1.07-0.08 0.56 1.93-0.39 1.58-0.31 2.43 0.22 2.1 0.5-0.31 1.16 0.33 1.44 1.4 0.32 1.23 0.04 1.97-0.78 1.97-0.72 0-1.62-1.32-1.97-2.93s-1.13-2.81-1.75-2.69-1.32-0.79-1.5-2c-0.26-1.67 0.05-2.04 1.22-1.59 0.85 0.32 1.53 0.11 1.53-0.44 0-0.56-0.54-1.2-1.22-1.44s-0.87-0.85-0.44-1.31c0.15-0.16 0.32-0.25 0.47-0.28zm-131.91 0.28c0.16-0.1 0.19 0.33 0.22 1.19 0.05 1.13-0.82 2.86-1.9 3.84-1.12 1.01-1.94 1.27-1.94 0.62 0-0.62 0.41-1.12 0.91-1.12 0.49 0 1.33-1.23 1.87-2.72 0.41-1.13 0.69-1.72 0.84-1.81zm93.29 0.15c0.06 0.01 0.11 0.22 0.18 0.69 0.23 1.5 0.24 3.7 0 4.91-0.23 1.21-0.44 0.02-0.43-2.69 0-1.86 0.12-2.92 0.25-2.91zm-18.63 0.19c0.33-0.13 0.75 1.52 0.91 3.69 0.46 6.42 1.74 37.69 1.9 46.53 0.29 15.53-1.75 9.06-2.71-8.66-0.17-2.97-0.43-0.54-0.57 5.41-0.2 8.8-0.44 10.37-1.31 8.38-0.86-1.99-1.14-2.14-1.47-0.79-0.31 1.31-1.1 1.59-3.53 1.16-11.74-2.06-19.38-11.29-19.38-23.41 0-3.87 0.22-4.27 1.97-3.81 2.82 0.74 4.91-1.42 4.91-5.06 0-3.62 3.02-8.13 9.38-14 3.05-2.82 4.4-4.85 4.4-6.63 0-2.08 0.48-2.56 2.47-2.56 1.35 0 2.71-0.11 3.03-0.25zm212.06 1.69c1.15-0.04 1.99 4.83 1.25 7.78-0.5 1.99-0.28 2.59 0.94 2.59 1.88 0 2.1 1.53 0.35 2.35-0.99 0.46-0.99 0.73 0 1.18 0.67 0.32 1.24 0.91 1.24 1.35s-0.57 1.01-1.28 1.28c-2.3 0.89-4.94-15.06-2.72-16.44 0.08-0.05 0.15-0.09 0.22-0.09zm-55.72 0.94c0.1-0.03 0.21-0.02 0.29 0.06 0.3 0.3-0.02 1.11-0.69 1.78-0.97 0.96-1.07 0.84-0.53-0.56 0.27-0.73 0.64-1.21 0.93-1.28zm16.16 0.03c0.04 0 0.03 0.05 0.03 0.12 0.01 0.58-0.64 1.89-1.43 2.94-1.88 2.47-1.91 3.97-0.07 2.44 1.18-0.98 1.56-0.75 2.07 1.28 0.34 1.36 0.41 3.26 0.15 4.25-0.25 0.99-0.54 0.27-0.62-1.63l-0.13-3.43-1.5 2.72c-1.31 2.41-1.65 2.53-2.94 1.24-1.29-1.28-1.11-1.98 1.5-6.15 1.43-2.27 2.66-3.81 2.94-3.78zm31.78 0.72c0.18-0.07 0.44 0.13 0.85 0.53 0.6 0.6 0.92 1.59 0.71 2.22-0.48 1.46-1.81 0.14-1.81-1.82 0-0.55 0.08-0.87 0.25-0.93zm-284.53 0.81c0.54 0 0.97 0.2 0.97 0.44 0 0.23-0.43 0.69-0.97 1.03-0.54 0.33-1 0.13-1-0.44s0.46-1.03 1-1.03zm189.35 2.81-7.88 4.09c-4.33 2.26-8.3 4.48-8.84 4.91-2.1 1.65-8.18 2.44-15.25 1.97l-7.38-0.5-0.28-4.09-0.31-4.13 5.25-0.56c2.87-0.3 11.82-0.78 19.93-1.1l14.76-0.59zm-254.29 2.09c-0.54 0.01-0.97 0.46-0.97 1 0 0.55 0.43 0.97 0.97 0.97s0.97-0.42 0.97-0.97c0-0.54-0.43-1-0.97-1zm46.57 0.1c0.48-0.01 0.43 0.44-0.35 1.37-0.67 0.82-1.9 1.5-2.75 1.5-1.23 0-1.15-0.31 0.38-1.47 1.25-0.94 2.23-1.39 2.72-1.4zm287.4 0.06c0.98-0.09 2.45 0.2 4.44 0.81 2.42 0.75 2.39 0.8-1.22 2.38-4.1 1.8-7.41 2-9.59 0.62-1.17-0.74-1.23-1.18-0.25-2.15 0.92-0.93 1.22-0.93 1.22-0.03 0 0.65 0.88 1.18 1.96 1.18 1.1 0 1.97-0.68 1.97-1.5 0-0.78 0.49-1.22 1.47-1.31zm15.47 0.91c0.06-0.06 0.5 0.31 1.35 1.12 0.97 0.94 1.54 1.93 1.28 2.19s-1.07-0.49-1.78-1.69c-0.63-1.03-0.91-1.56-0.85-1.62zm-66.69 1c0.08-0.01 0.16-0.01 0.22 0 0.29 0.04 0.35 0.33 0.35 0.81 0 0.49-1.42 1.37-3.13 1.97-4.46 1.55-4.68 1.32-1.03-0.91 1.98-1.2 3.04-1.79 3.59-1.87zm-295 0.9c-0.712 0-1.551 0.69-1.875 1.53-0.325 0.85-0.989 1.31-1.438 1.04-0.783-0.49-4.125 2.7-4.125 3.93 0 0.33 0.632 0.12 1.375-0.5 0.743-0.61 2.021-0.84 2.844-0.53 1.001 0.39 1.993-0.45 3-2.47 1.191-2.38 1.244-3 0.219-3zm52.596 0.1c0.81 0-0.25 0.84-2.38 1.9-2.12 1.06-4.36 1.93-4.94 1.91-1.58-0.06 5.61-3.81 7.32-3.81zm303.87 0.12c0.61-0.06 1.27 0.34 2.47 1.13 1.39 0.91 2.53 2.29 2.53 3.09 0 1.65-1.55 1.95-2.47 0.47-0.33-0.54-2-0.97-3.72-0.97h-3.09l2.13-2.12c1.01-1.02 1.55-1.54 2.15-1.6zm-338.87 0.75c-0.24 0-0.44 0.46-0.44 1s0.49 0.97 1.06 0.97c0.58 0 0.77-0.43 0.44-0.97s-0.82-1-1.06-1zm306.31 0c0.12 0 0.13 0.35 0.09 1-0.04 0.81-0.47 2.59-0.9 3.94l-0.75 2.44-0.1-2.44c-0.04-1.35 0.32-3.13 0.85-3.94 0.42-0.65 0.69-1 0.81-1zm-108 0.78c0.01 0 0.05 0.02 0.06 0.04 1.52 1.8 2.86 9.32 2.28 12.9-0.64 4.03-2.23 5.47-2.53 2.28-0.42-4.57-0.27-15.1 0.19-15.22zm97.44 1.69-1.5 3.13c-1.79 3.69-1.88 4.25-0.57 4.25 0.55 0 1.06-0.78 1.1-1.72 0.04-0.95 0.3-1.23 0.56-0.6 0.26 0.64-1.14 3.23-3.06 5.75-1.93 2.52-3.5 3.94-3.5 3.13s0.5-1.67 1.12-1.88c0.99-0.33 1.43-1.82 1.75-6.28 0.05-0.61 0.99-2.16 2.1-3.43l2-2.35zm34.34 0.5c0.54 0 1 0.43 1 0.97s-0.46 1-1 1-0.97-0.46-0.97-1 0.43-0.97 0.97-0.97zm-305.47 0.13c0.5 0 0.43 0.26-0.47 0.84-0.81 0.52-2.12 0.94-2.93 0.91-0.98-0.04-0.8-0.35 0.5-0.91 1.35-0.58 2.4-0.84 2.9-0.84zm241.91 0.93c0.7-0.01 0.59 0.26 0.59 0.79 0 0.93-9.29 5.22-14.75 6.81-6.4 1.87-8.73 2.16-9.31 1.22-0.51-0.83 2.7-2.01 8.84-3.25 1.09-0.22-1.05-0.39-4.75-0.35-5.06 0.06-7-0.29-7.87-1.47-0.63-0.86-1.81-1.86-2.63-2.22-0.81-0.35 0.28-0.38 2.44-0.06 5.63 0.85 16.05 0.59 22.13-0.56 3.14-0.6 4.61-0.89 5.31-0.91zm-238.35 0.03c0.35-0.01 0.74 0.05 1.1 0.19 0.78 0.32 0.55 0.55-0.6 0.6-1.03 0.04-1.6-0.18-1.28-0.5 0.17-0.17 0.44-0.27 0.78-0.29zm-43.682 0.1c-0.224 0.07-0.569 1.04-1.032 2.97-0.385 1.6-0.22 2.72 0.375 2.72 0.552 0 0.969-1.38 0.969-3.1 0-1.79-0.089-2.66-0.312-2.59zm191.34 0c-0.12 0.04-0.19 0.17-0.19 0.4 0 0.56 0.33 1.33 0.69 1.69s0.85 0.41 1.13 0.13-0.02-1.02-0.66-1.66c-0.44-0.44-0.77-0.63-0.97-0.56zm-132.5 0.22c0.33-0.09 0.5 0.51 0.5 1.75 0 2.26-5.29 12.9-8.09 16.28-0.57 0.69-0.8 1.48-0.5 1.78 0.74 0.74 5.62-6.57 5.62-8.41 0-0.91 1.1-0.25 2.91 1.72 1.59 1.75 3.07 3.16 3.28 3.16 1.43 0 6.62-9.18 6.62-11.72 0-1.67 0.43-3.03 0.97-3.03s1.04 1.43 1.07 3.19c0.02 1.75 0.58 4.53 1.28 6.15 1.21 2.82 1.14 3.05-1.94 5.16-1.78 1.22-3.87 2.22-4.62 2.22-1.95 0-4.63 3.24-4.63 5.59 0 1.09 0.82 2.92 1.81 4.06 2.13 2.46 11.4 7.29 13.19 6.88 2.41-0.55 5.46 3.99 7.19 10.69l1.75 6.75-3 6.37c-1.65 3.51-4.03 8.84-5.28 11.81-3.06 7.28-5.25 9.58-12.22 12.91-6.5 3.11-10.28 3.48-14.75 1.44-1.63-0.75-4.94-2.26-7.38-3.38-2.43-1.11-6.21-2.69-8.37-3.47-7.55-2.72-15.25-6.51-15.25-7.5 0-0.54-0.54-0.99-1.22-1-1.4-0.01-10.45-10-12.31-13.59-0.68-1.3-1.22-2.93-1.22-3.59 0-0.67-0.686-2.62-1.534-4.32-2.095-4.2-1.472-7.91 1.754-10.31 2.6-1.93 2.75-1.94 4.68-0.19 1.1 0.99 1.97 2.62 1.97 3.6 0 3.78 8.96 16.59 11.6 16.59 0.52 0 2.02 0.83 3.31 1.85 3.13 2.44 7.51 3.13 24.65 3.9 7.94 0.36 14.73 1 15.13 1.41 1.46 1.47-1.74 8.18-4.94 10.37-5.13 3.52-9.12-0.02-4.62-4.09 2.35-2.13 5.21-2.17 4.4-0.06-0.39 1.03-0.83 1.19-1.28 0.47-0.45-0.73-1.23-0.46-2.37 0.81-2.36 2.6-0.45 3.55 3.28 1.62 3.34-1.72 4.85-5.68 3-7.9-1.57-1.89-2.44-1.86-5.06 0.25-8.8 7.04-10.11 12.15-4 15.56 3.62 2.02 3.73 2.03 8.5 0.28 6.4-2.34 8.26-4.11 6.31-6.06-1.15-1.15-1.78-1.2-3.13-0.22-2.31 1.69-2.08 2.78 0.32 1.5 1.08-0.58 1.96-0.69 1.96-0.25 0 1.11-6.76 4.64-7.5 3.91-0.33-0.34 1-2.45 2.91-4.69 1.92-2.24 3.85-5.69 4.31-7.66 0.76-3.18 1.22-3.57 4.25-3.81 6.71-0.53 7.45-1.71 2.94-4.72-1.62-1.08-2.97-2.5-2.97-3.19 0-0.68-0.5-2.23-1.12-3.43-0.63-1.21-1.46-2.91-1.85-3.72-0.73-1.52-3.14-1.63-10.31-0.57-9.77 1.45-9.77 1.43-10.31-2.59-0.27-2.02-1.25-4.57-2.19-5.66-2.03-2.35-6.85-2.64-8.97-0.53-1.63 1.64-3.62 1.96-3.62 0.6 0-0.49-1.11-1.15-2.5-1.5-1.89-0.48-3.71 0.15-7.07 2.37-2.48 1.64-4.74 2.76-5 2.5-0.25-0.25 0.96-2.34 2.66-4.66 12.92-17.61 15.25-21 22.63-32.59 2.5-3.93 4.03-4.31 2.03-0.5-2.08 3.97-8.17 12.92-10.5 15.44-1.23 1.33-2.25 2.79-2.25 3.25s-0.87 1.74-1.97 2.84c-1.93 1.93-1.84 4.56 0.12 3.35 0.85-0.53 4.41-5.61 7.28-10.47 0.56-0.93 2.86-4.38 5.16-7.66s4.19-6.34 4.19-6.78 0.98-1.63 2.15-2.66c2.47-2.15 2.33-1.92-4 8.44-2.47 4.06-4.86 7.54-5.28 7.72-0.41 0.18-0.75 0.79-0.75 1.34 0 0.56-1.11 2.3-2.47 3.91-1.35 1.61-2.46 3.31-2.46 3.81 0 2.05 1.66 0.66 4.4-3.75 1.6-2.57 3.17-4.88 3.5-5.15s2.19-3.13 4.13-6.38c9.06-15.21 8.87-14.91 8.22-11.97-0.34 1.54-1.74 4.49-3.07 6.6-1.33 2.1-2.4 4.11-2.4 4.47 0 0.35-2.15 3.57-4.78 7.15-4.69 6.38-7.04 10.17-7.04 11.44 0.01 2.51 14.47-19.13 17-25.44 1.6-3.96 2.61-5.95 3.16-6.09zm66.06 0.06 0.69 8.84c0.37 4.87 1.12 11.57 1.66 14.88 0.53 3.31 0.93 7.2 0.93 8.62 0 1.43-0.42 2.57-0.96 2.57s-1-1.52-1-3.38-0.45-3.69-1-4.03c-0.56-0.34-0.92-1.11-0.82-1.75 0.11-0.64-0.11-4.05-0.5-7.56-0.38-3.52-0.31-9.04 0.16-12.28l0.84-5.91zm-83.56 0.62c0.42-0.01 0.02 0.37-1.12 1.29-1.05 0.84-2.56 1.53-3.38 1.53-2.08 0-0.22-1.6 2.81-2.41 0.89-0.23 1.44-0.4 1.69-0.41zm315.75 0.85c0.65-0.01 1.45 0.46 1.78 1 0.76 1.22 0.42 1.22-1.47 0-0.88-0.57-1.01-0.99-0.31-1zm-12.06 1c0.84 0 1.56 0.43 1.56 0.97s-0.43 0.97-0.94 0.97-1.19-0.43-1.53-0.97c-0.33-0.54 0.07-0.97 0.91-0.97zm25.31 0.44c0.08-0.01 0.18 0.01 0.31 0.03 0.53 0.08 1.32 1.86 1.75 3.97 0.44 2.11 0.63 4.51 0.41 5.34-0.36 1.31-0.45 1.32-0.66 0.03-0.12-0.81-0.13-2.06-0.03-2.81 0.13-0.94-0.36-1.16-1.59-0.69-1.44 0.55-1.58 0.4-0.59-0.59 1.35-1.37 1.65-4.36 0.5-5-0.31-0.17-0.33-0.28-0.1-0.28zm-363 0.56c-1.34 0.03-1.32 0.25 0.28 1.47 2.49 1.88 4.1 1.86 2.53-0.03-0.67-0.82-1.93-1.46-2.81-1.44zm157.81 0c0.05 0 0.11 0.1 0.16 0.28 0.33 1.27 1.2 1.69 3.06 1.47 2.21-0.26 2.68 0.11 2.94 2.34 0.24 2.11-0.3 2.97-2.66 4.19-1.63 0.84-3.2 1.53-3.5 1.53-0.29 0-0.5-2.54-0.43-5.66 0.05-2.52 0.23-4.16 0.43-4.15zm164.94 0.31c0.87-0.03 4.86 3.46 11.35 10.13 8.87 9.12 11.77 11.44 18.06 14.47 4.11 1.97 8.43 3.59 9.59 3.59 1.2 0 2.09 0.61 2.09 1.44 0 0.88-0.6 1.25-1.5 0.9-2.07-0.79-1.93 2.94 0.19 5.07 0.92 0.91 2.92 2.12 4.44 2.65 1.72 0.6 2.75 1.65 2.75 2.81 0 1.03-0.2 1.88-0.47 1.88s-0.5-0.43-0.5-0.97-0.47-1-1.03-1c-1.08 0-2.54-1.05-6.44-4.63-1.3-1.19-2.37-1.73-2.37-1.18s-0.54 0.67-1.22 0.25-2.12-0.9-3.19-1.07c-4.52-0.7-16.98-11.34-22.19-18.93-2.84-4.15-3.87-5.46-6.12-7.94-0.95-1.04-1.43-1.91-1.09-1.91 0.33 0-0.15-1.16-1.07-2.56-1.32-2.02-1.74-2.98-1.28-3zm-82 0.03c0.19 0.03 0.39 0.22 0.56 0.5 0.38 0.61 0.14 1.1-0.5 1.1-0.86 0-0.85 0.37 0.07 1.47 0.77 0.93 0.84 1.46 0.18 1.46-1.65 0-2.36-1.8-1.37-3.56 0.31-0.55 0.61-0.85 0.87-0.94 0.07-0.02 0.13-0.04 0.19-0.03zm-116.31 0.03c0.05-0.01 0.1-0.01 0.16 0 0.06 0.02 0.11 0.06 0.18 0.1 0.54 0.33 1 1.25 1 2.03s-0.46 1.41-1 1.41c-0.54-0.01-0.97-0.92-0.97-2.04 0-0.85 0.26-1.42 0.63-1.5zm107.56 0.5v3.5 3.47h-5.66c-6.71-0.02-8.38-0.9-7.93-4.06 0.31-2.18 0.81-2.36 6.97-2.63l6.62-0.28zm14.75 0.57-0.47 5.9c-0.63 8.15-1.57 13.58-2.53 14.78-0.45 0.56-1.68 5.17-2.78 10.22-1.1 5.06-2.42 9.68-2.91 10.28-0.82 1.03-1.31 3.4-2.72 12.69-0.3 2.03-0.98 3.92-1.46 4.22-0.49 0.3-0.88 1.65-0.88 2.97s-0.49 2.41-1.06 2.41c-1.24 0-0.28-7.62 1.59-12.82 0.69-1.89 1.97-6.98 2.88-11.31 0.9-4.33 2.05-8.65 2.56-9.59s0.92-2.91 0.94-4.41c0.02-2.52 2-10.17 5.4-20.91l1.44-4.43zm-212.62 0.47c0.16 0.02 0.17 0.29-0.07 0.78-2.16 4.55-3.3 6.71-3.72 7.12-0.27 0.27-2.12 3.05-4.15 6.16-3.65 5.58-4.69 6.58-4.69 4.65 0-0.54 0.46-0.97 1-0.97s0.97-0.66 0.97-1.43c0-0.78 0.54-1.99 1.22-2.72 1.82-1.98 3.69-5.51 3.69-6.94 0-0.69 1.15-2.42 2.53-3.91 1.64-1.77 2.85-2.8 3.22-2.74zm-35.88 0.21c-0.2 0.08-0.28 0.6-0.25 1.38 0.05 1.14 0.25 1.38 0.56 0.59 0.29-0.71 0.27-1.55-0.06-1.87-0.08-0.08-0.18-0.12-0.25-0.1zm313.97 0.69c0.78 0.14 1.44 2.32 1.44 6.5 0 3.61-0.42 6.41-0.97 6.41-0.6 0-0.95 4.08-0.88 10.56 0.11 9.57 0.23 10.05 0.97 5.16 0.45-2.98 0.57-6.95 0.32-8.85-0.44-3.18-0.37-3.24 0.62-0.97 0.59 1.36 0.94 5.45 0.75 9.1s-0.02 6.62 0.41 6.62c1.27 0 0.85 8.53-0.47 9.6-0.68 0.54-2.58 1.27-4.22 1.62-3.85 0.82-15.12 10.87-13.75 12.25 1.15 1.17 6.4 0.32 6.4-1.03 0.01-0.51 0.47-0.63 1.04-0.28s1.85-0.3 2.84-1.44c1.1-1.26 2.4-1.81 3.38-1.44 1.16 0.45 1.59 0.06 1.59-1.5 0-1.31 0.45-1.88 1.12-1.47 0.61 0.38 1.47 0.06 1.94-0.68 0.69-1.09 0.86-1.04 0.88 0.28 0 0.9-0.48 1.82-1.1 2.03-0.84 0.28-0.81 2.06 0.16 6.94 1.22 6.13 1.17 6.67-0.59 8.62-1.54 1.7-2.69 2.04-6.1 1.66-4.48-0.51-5.96 0.32-3.78 2.12 2.08 1.73 9.58 1.65 13.12-0.12 3.02-1.51 3.19-1.49 3.19 0.19 0 1.01-0.93 2.03-2.19 2.37-2.3 0.62-10.34 0.7-12.06 0.13-0.54-0.18-2.2-0.58-3.68-0.91-2.32-0.51-2.72-1.07-2.72-3.97 0-2.38 0.58-3.73 1.96-4.47 1.28-0.68 1.97-0.7 1.97-0.06 0 0.54 0.72 0.73 1.57 0.41 0.84-0.33 2.57-0.04 3.87 0.65 1.92 1.03 2.67 1.03 3.91 0 2.45-2.03 0.05-3.76-6.19-4.43-11.61-1.26-12.95-1.59-12.94-3.29 0.02-2.27 4.7-20.95 5.44-21.68 0.33-0.33 0.32 1.03-0.06 3.06-0.52 2.77-0.38 3.73 0.62 3.81 11.93 1.01 14.63 0.53 14.63-2.62 0-2.89-2.55-3.17-8.88-0.94-2.3 0.81-4.33 1.5-4.53 1.5-0.75 0-0.35-4.13 0.56-5.84 0.52-0.98 2.11-6.16 3.5-11.5 1.4-5.35 2.95-10.84 3.44-12.19 0.49-1.36 1.08-4.09 1.31-6.07 0.49-4.09 1.38-5.98 2.16-5.84zm-211.75 0.1c0.51-0.01 0.65 1 0.28 2.21-2.66 8.76-3.65 13.54-3.81 18.35l-0.19 5.53 9.59 0.25c5.31 0.15 9.6 0.72 9.6 1.25 0 0.55-4.32 0.94-10.22 0.94-11.54 0-11.38 0.13-11.41-8.72-0.01-4.74 4.67-19.81 6.16-19.81zm249.03 0c0.24-0.01 0.73 0.45 1.06 1 0.34 0.54 0.14 0.96-0.43 0.96-0.58 0-1.07-0.42-1.07-0.96 0-0.55 0.2-1 0.44-1zm-44.06 0.9c0.21 0 0.36 0.17 0.53 0.47 0.6 1.08 0.13 2.84-1.59 5.75-1.38 2.31-3 5.42-3.6 6.91-1.29 3.24-3.28 3.67-2.31 0.5 0.37-1.22 2.02-5.04 3.66-8.47 1.74-3.65 2.67-5.15 3.31-5.16zm-277.81 1.06c0.42 0 0.75 0.35 0.75 0.75-0.01 1.06-4.84 6.82-4.88 5.82-0.05-1.29 3.26-6.57 4.13-6.57zm236.47 0c0.81 0 1.2 0.46 0.87 1s-1.28 0.97-2.09 0.97c-0.82 0-1.18-0.43-0.85-0.97 0.34-0.54 1.25-1 2.07-1zm88.9 0c0.54 0 1 0.46 1 1s-0.46 0.97-1 0.97-0.97-0.43-0.97-0.97 0.43-1 0.97-1zm-245.22 0.1c1.69 0.04 3.48 0.55 4.72 1.5 1.89 1.45 1.85 1.48-0.75 0.84-2.98-0.73-3.86 0.99-0.97 1.91 0.95 0.3 2.35 1.59 3.1 2.81l1.34 2.19-2.41-2.19c-3.8-3.5-4.01-1.4-0.25 2.56 1.87 1.97 3.37 4.6 3.38 5.85 0.01 3.1-1.58 1.9-2.31-1.75-0.33-1.64-1-2.97-1.5-2.97-0.51 0-0.18 2.16 0.71 4.81 0.9 2.65 1.94 4.63 2.35 4.38 0.4-0.26 0.75-0.02 0.75 0.56 0 0.57-1.27 1.06-2.81 1.06-1.55 0-4.75 0.21-7.13 0.47-5.32 0.57-6.78-0.04-6.78-2.78 0-4.18 3.06-16.59 4.41-17.94 0.9-0.9 2.46-1.35 4.15-1.31zm-84.9 1.28c0.35 0.01 0.59 0.36 0.59 0.97 0 0.81-0.43 1.76-0.97 2.09-0.54 0.34-1-0.03-1-0.84s0.46-1.76 1-2.1c0.14-0.08 0.26-0.12 0.38-0.12zm298.03 0c0.28-0.12 1.19 1.3 2.87 4.53 4.39 8.42 5.92 10.84 6.97 10.84 0.48 0 0.44-0.57-0.06-1.25-0.5-0.67-1.44-2.56-2.09-4.18l-1.19-2.94 2.56 2.94c8.12 9.44 11.84 13.28 12.87 13.28 0.65 0 1.32 0.34 1.5 0.75 0.54 1.19 7.45 6.15 8.6 6.15 0.58 0 1.06 0.41 1.06 0.91s1 1.21 2.22 1.59 2.42 0.98 2.69 1.32c0.9 1.11 7.05 4.06 8.47 4.06 2.05 0 1.67 2.3-0.6 3.72-2.2 1.37-2.64 5.33-0.75 6.84 0.68 0.54 2.34 1.28 3.69 1.66 8.11 2.23 10.79 4.77 3.69 3.47-2.82-0.52-5.18-0.35-7.28 0.53-2.68 1.12-3.42 1.08-5.41-0.28-2.16-1.49-2.2-1.48-0.94 0.09 1.72 2.13 0.77 2.11-2.62-0.03-2.63-1.66-2.63-1.65-1 0.25 1.58 1.85 1.51 1.94-1.16 1.94-1.53 0-3.67-0.85-4.81-1.88s-2.09-1.51-2.09-1.06c-0.01 0.45-1.12-0.23-2.47-1.5-3.89-3.65-3.73-1.8 0.28 3.22 3.78 4.74 7.02 5.85 10.93 3.75 0.96-0.51 4.13-1.25 7.07-1.63l5.34-0.69-2.91 2.35c-1.6 1.28-5.34 3.54-8.34 5.03-7.31 3.64-9.25 3.51-11.78-0.78-1.14-1.93-2.06-3.86-2.06-4.31 0-0.46-1.5-3.52-3.35-6.79-1.84-3.26-3.68-6.94-4.06-8.18-0.8-2.64-3.19-8.41-4.53-10.94-0.51-0.97-0.67-2.15-0.38-2.62 0.3-0.48-1-3.54-2.9-6.79-3.83-6.53-4.13-7.49-2.03-6.68 0.95 0.36 1.24 0.04 0.87-0.91-0.3-0.78-1.04-1.4-1.65-1.41-1.2-0.01-4.49-8.33-5.25-13.28-0.11-0.68-0.1-1.04 0.03-1.09zm-225.47 0.5c0.64-0.01 0.89 0.41 0.5 1.34-0.29 0.68-1.05 3.11-1.69 5.41-0.71 2.58-1.73 4.19-2.65 4.19-2.12 0-4.12 2.93-4.16 6.12-0.03 2.34-0.41 2.72-2.97 2.72-2.02 0-2.97-0.48-2.97-1.53 0-0.9-0.43-1.25-1.09-0.85-1.71 1.06-0.14-4.42 2.28-7.96 2.91-4.27 10.45-9.43 12.75-9.44zm144.87 0.09c0.24 0 0.7 0.46 1.03 1 0.34 0.54 0.17 0.97-0.4 0.97s-1.06-0.43-1.06-0.97 0.2-1 0.43-1zm18 0.28c0.61 0.03 0.54 0.23-0.21 0.57-3.45 1.54-8.98 2.43-7.88 1.28 0.54-0.57 2.97-1.29 5.41-1.6 0.75-0.09 1.36-0.18 1.84-0.22 0.36-0.02 0.64-0.04 0.84-0.03zm-111.4 0.57c-0.13 0.11-0.22 0.88-0.22 2.12 0 1.89 0.16 2.67 0.41 1.72 0.24-0.95 0.24-2.49 0-3.44-0.07-0.23-0.08-0.37-0.13-0.4-0.02-0.02-0.04-0.02-0.06 0zm-141.94 1.12c-0.51 0-1.48 0.69-2.16 1.5-0.67 0.81-0.9 1.47-0.53 1.47 0.38 0 1.35-0.66 2.16-1.47s1.04-1.5 0.53-1.5zm9.25 0c0.78 0 1.06 0.99 0.78 2.72-0.24 1.49-0.68 6.23-0.97 10.56-0.28 4.33-0.89 8.76-1.34 9.85-0.45 1.08-1.37 3.41-2.03 5.18-1.78 4.72-2.68 4.72-3.94 0-1.22-4.58-3.45-7.65-5.53-7.65-1.81 0-1.67-1.88 0.19-2.6 0.82-0.31 2.86-3.5 4.56-7.09 3.3-6.98 6.31-10.97 8.28-10.97zm223.31 0.31c1.23-0.17 4.31 0.99 4.31 1.79 0 1.23-3.65 1.07-4.43-0.19-0.36-0.58-0.5-1.23-0.28-1.44 0.08-0.08 0.23-0.13 0.4-0.16zm-243.15 0.69c-0.238 0-0.406 0.43-0.406 0.97s0.458 1 1.031 1 0.772-0.46 0.438-1c-0.335-0.54-0.824-0.97-1.063-0.97zm290.93 0c0.46 0 0.82 5.75 0.82 12.78 0 14.33-0.89 17.54-1.16 4.19-0.1-4.73-0.23-10.48-0.31-12.78-0.09-2.3 0.2-4.19 0.65-4.19zm3.03 0.97c0.41 0 0.75 4.55 0.76 10.09 0 5.55 0.28 11.76 0.62 13.78 0.38 2.33 0.22 3.69-0.44 3.69-0.57 0-1.29-2.34-1.59-5.19-0.73-6.88-0.27-22.37 0.65-22.37zm-74.74 0.03c0.12-0.03 0.28 0.04 0.46 0.19 0.68 0.56 1.22 2.47 1.22 4.25s0.69 6.7 1.5 10.94 1.47 10.29 1.47 13.43c0 3.15 0.46 6.59 1.03 7.66 1.1 2.06 0.89 9.98-0.22 8.28-0.35-0.54-0.97-2.79-1.37-4.94-0.59-3.11-0.86-3.49-1.41-1.93-0.38 1.07-0.48-2.38-0.22-7.66 0.42-8.46 0.29-9.59-1.15-9.59-1.3 0-1.43-0.37-0.63-1.88 0.56-1.05 0.61-2.04 0.13-2.22s-1.03-4.15-1.22-8.84c-0.22-5.47-0.15-7.54 0.41-7.69zm62.06 0.16c0.06-0.03 0.17 0.01 0.25 0.09 0.32 0.33 0.34 1.17 0.06 1.88-0.31 0.78-0.55 0.55-0.59-0.6-0.04-0.78 0.08-1.3 0.28-1.37zm3.4 0.22c0.05 0 0.05 0.03 0.1 0.06 0.59 0.37 1.06 3.8 1.06 7.9 0 10.18-1.52 10.05-1.84-0.15-0.17-5.42 0.06-7.9 0.68-7.81zm-56.37 0.59c0.35-0.01 0.77 0 1.22 0 3.62 0.01 3.69 0.08 3.84 3.97 0.09 2.47 1.01 5.14 2.5 7.12 1.31 1.75 2.71 3.93 3.06 4.88 0.56 1.51-0.06 1.72-5.03 1.72h-5.65l-1.19-5.19c-0.67-2.86-1.22-6.83-1.22-8.84 0-3.13 0.04-3.6 2.47-3.66zm143.34 0c0.41 0 0.75 0.66 0.75 1.47v2.22c0 0.4-0.34 0.83-0.75 0.97-0.4 0.13-0.72-0.87-0.72-2.22 0-1.36 0.32-2.44 0.72-2.44zm-347.75 0.41c0.09 0.03 0.13 0.22 0.13 0.56-0.02 0.81-0.41 2.58-0.85 3.94-0.63 1.97-0.75 2.08-0.78 0.5-0.01-1.09 0.32-2.86 0.78-3.94 0.26-0.6 0.49-0.95 0.63-1.03 0.03-0.02 0.07-0.05 0.09-0.03zm125.5 0.28c-0.09 0.12-0.14 1.13-0.18 2.9-0.07 2.26 0.16 4.84 0.5 5.72 1.14 2.99 1.38 0.84 0.5-4.5-0.5-2.96-0.7-4.28-0.82-4.12zm65 0.9c0.31-0.07 0.95 1.65 1.56 4.19 1.03 4.24 1.03 5.38 0.04 6-0.79 0.49-1 1.75-0.6 3.38 0.66 2.6 0.5 3.08-0.68 1.9-1.05-1.04-0.81-7.03 0.31-7.4 0.68-0.23 0.65-1.39-0.1-3.53-0.6-1.75-0.88-3.69-0.65-4.38 0.03-0.09 0.08-0.15 0.12-0.16zm73.82 0.16c0.39 0.06 0.51 1.82 0.53 5.88 0.01 3.92-0.11 7.12-0.32 7.12-1 0-1.63-10.93-0.71-12.5 0.19-0.33 0.36-0.52 0.5-0.5zm-259.47 0.53c0.21 0.04 0.34 0.23 0.34 0.53 0 0.54-0.43 1.26-0.97 1.6-0.54 0.33-1 0.19-1-0.35s0.46-1.29 1-1.62c0.14-0.09 0.26-0.1 0.38-0.13 0.08-0.01 0.17-0.04 0.25-0.03zm270.28 0.72c0.25-0.11 0.61 0.19 1.03 0.87 0.31 0.51 0.14 1.2-0.41 1.54s-1.03-0.1-1.03-0.94c0-0.87 0.15-1.36 0.41-1.47zm-17.75 0.13c0.06-0.03 0.17 0.01 0.25 0.09 0.32 0.33 0.34 1.16 0.06 1.87-0.31 0.79-0.55 0.56-0.59-0.59-0.04-0.78 0.08-1.3 0.28-1.37zm82.68 0.81c0.24 0 0.73 0.43 1.07 0.97 0.33 0.54 0.13 1-0.44 1s-1.03-0.46-1.03-1 0.17-0.97 0.4-0.97zm-67.96 0.75c0.16-0.21 0.39 1.84 0.78 6.12 0.46 5.14 0.7 9.81 0.53 10.35-0.52 1.59-1.61-9.45-1.47-14.79 0.03-1.02 0.08-1.59 0.16-1.68zm24.28 0.22c0.54 0 0.97 0.2 0.97 0.43 0 0.24-0.43 0.7-0.97 1.03-0.54 0.34-1 0.17-1-0.4s0.46-1.06 1-1.06zm-295.69 0.43c0.06 0.01 0.14 0.13 0.22 0.32 0.27 0.67 0.27 1.76 0 2.43-0.27 0.68-0.47 0.14-0.47-1.22 0-0.84 0.06-1.38 0.19-1.5 0.02-0.01 0.04-0.03 0.06-0.03zm241.84 0.66c0.16 0.03 0.29 0.56 0.47 1.63 0.46 2.59 2.96 2.88 4.66 0.56 1.43-1.96 3.47-0.94 3.47 1.72 0 1.94 0.74 2.22 4.65 1.9 1.85-0.15 2.22 0.34 2.22 2.82 0 3.36 0.94 4.31 2.97 3.06 2.31-1.43 4 0.72 2.75 3.47-1.38 3.03-0.48 5.16 2.34 5.59 1.43 0.22 2.15 0.9 1.91 1.81-1.32 5.04-1.27 5.85 0.5 6.5 2.74 1.01 3.37 2.55 1.59 3.85-1.36 0.99-1.4 1.57-0.31 4.22 0.7 1.68 1.68 2.85 2.16 2.56 0.48-0.3 0.84 0.38 0.84 1.53 0 1.14-0.36 1.83-0.84 1.53-0.49-0.3-1.17 0.15-1.5 1-0.97 2.53-0.69 5.11 0.62 5.66 0.87 0.36 0.65 0.99-0.71 2.09-1.07 0.86-1.99 2.77-2.1 4.25s-0.24 2.98-0.28 3.38c-0.04 0.39-1.46 0.45-3.12 0.12-2.58-0.51-2.97-0.33-2.69 1.22 0.34 1.97-2.93 3.3-4 1.62-0.34-0.52-1.63-1.24-2.85-1.62-1.64-0.52-2.18-0.31-2.18 0.84 0 2.47-2.91 1.78-3.94-0.94-0.77-2.03-1.41-2.35-3.44-1.84-2.16 0.54-2.47 0.28-2.47-1.9 0-2.79-1.57-4.18-4.19-3.76-1.84 0.31-2.37-1.31-0.74-2.31 1.57-0.97-1.69-6.42-3.44-5.75-1.16 0.45-1.47-0.31-1.47-3.53 0-3.15-0.6-4.65-2.59-6.5-2.02-1.86-2.34-2.71-1.47-3.75 0.82-0.99 0.81-2.16 0-4.5-0.61-1.75-0.83-4.92-0.47-7.12 0.39-2.48 0.23-4.53-0.47-5.38-0.91-1.09-0.72-1.34 0.91-1.34 2.58 0 5.04-3.46 4.34-6.13-0.46-1.75-0.21-1.96 1.81-1.47 2.64 0.65 5.03-0.74 6.31-3.72 0.41-0.94 0.59-1.4 0.75-1.37zm58.41 0.31c0.06 0 0.14 0.06 0.25 0.19 0.4 0.47 1.33 2.85 2.03 5.28 0.71 2.44 1.85 6.21 2.56 8.38 0.71 2.16 2.28 7.37 3.47 11.56 1.2 4.19 2.59 7.62 3.13 7.62 1.39 0 3.59 3.12 3.62 5.16 0.02 0.95 0.49 1.72 1.03 1.72 1.37 0 1.32-0.19-1.62-6.59-1.44-3.13-2.55-6.04-2.47-6.44 0.08-0.41-0.25-0.72-0.75-0.72s-1.21-1.46-1.56-3.22c-0.36-1.76-0.86-4.07-1.13-5.16-0.27-1.08 1.1 1.09 3.03 4.85 1.94 3.75 3.5 7.19 3.5 7.62s2.22 5.35 4.91 10.91 5 11.17 5.16 12.5c0.5 4.42-3.76 3.56-5.41-1.1-0.32-0.9-1.82-2.27-3.34-3-3.26-1.55-5.61-5.88-7.53-14.06-0.77-3.24-2.81-11.22-4.57-17.72-3.78-13.99-4.71-17.73-4.31-17.78zm-83.28 0.56c0.54 0.01 1 0.66 1 1.47 0 0.82-0.46 1.5-1 1.5s-0.97-0.68-0.97-1.5c0-0.81 0.43-1.47 0.97-1.47zm130.28 0c0.24 0.01 0.73 0.46 1.06 1 0.34 0.55 0.14 0.97-0.44 0.97-0.57 0-1.06-0.42-1.06-0.97 0-0.54 0.2-1 0.44-1zm-274.88 1.16c1.11-0.03 1.37 2.65 0.41 5.16-0.33 0.85-1.01 1.56-1.53 1.56-1.38 0-0.57-6.18 0.88-6.66 0.08-0.02 0.17-0.06 0.24-0.06zm-73.5 2.13c0.22-0.1 0.57 0.13 1.16 0.62 1.28 1.06 1.3 1.55 0 4.06-1.75 3.4-2.86 3.77-2.03 0.66 0.33-1.22 0.59-3.05 0.59-4.06 0.01-0.76 0.07-1.19 0.28-1.28zm137.16 1.56c0.07-0.01 0.14 0.02 0.22 0.15 1.21 1.93 1.57 26.5 0.41 27.35-0.46 0.33-1.61 2.17-2.57 4.06-0.95 1.89-3.02 5.52-4.62 8.09-1.6 2.58-3.33 6.12-3.81 7.88-0.79 2.84-0.96 3-1.66 1.25-0.44-1.08-1.07-2.21-1.37-2.5-0.31-0.29-2.41-2.49-4.66-4.91-4.06-4.36-4.1-4.47-5.22-15.22-0.62-5.95-1.37-11.92-1.69-13.28l-0.59-2.46 2.59 2.4c1.43 1.31 2.65 3.28 2.69 4.41 0.07 1.98 0.07 1.98 0.81 0.09 0.69-1.75 0.89-1.64 1.85 1 0.86 2.38 1.06 2.49 1.12 0.78 0.11-2.84 4.4-3.9 7.5-1.87 1.66 1.09 2.46 2.78 2.91 6.19 0.34 2.58 0.68 5.32 0.78 6.09s0.8 1.62 1.56 1.87c1.08 0.36 1.25-0.3 0.75-2.9-0.39-2.06-0.28-2.8 0.25-1.97 1.91 2.97 2.71-2.31 2.35-14.97-0.23-7.78-0.08-11.45 0.4-11.53zm146.5 0.34c0.2 0.02 0.3 0.16 0.28 0.41-0.04 0.44-0.44 1.7-0.9 2.78-0.82 1.9-0.84 1.89-0.91-0.19-0.04-1.18 0.37-2.44 0.91-2.78 0.13-0.08 0.29-0.15 0.4-0.19 0.09-0.02 0.15-0.03 0.22-0.03zm30.81 0.22c-0.46-0.03-0.58 0.35-0.31 1.06 0.3 0.79 0.99 1.41 1.47 1.41 1.41 0 0.99-1.72-0.56-2.31-0.24-0.09-0.44-0.15-0.6-0.16zm-333.31 0.5c0.54 0 0.71 0.43 0.38 0.97-0.34 0.54-1.06 1-1.6 1s-0.71-0.46-0.37-1c0.33-0.54 1.05-0.97 1.59-0.97zm295.47 0.22c0.02-0.02 0.01-0.01 0.03 0 0.05 0.04 0.13 0.23 0.19 0.53 0.23 1.22 0.23 3.19 0 4.41-0.24 1.21-0.44 0.21-0.44-2.22 0-1.6 0.1-2.58 0.22-2.72zm-82.91 1.25 0.91 4.44c0.49 2.43 0.77 5.52 0.63 6.87l-0.26 2.47-0.74-2.47c-0.4-1.35-0.68-4.44-0.63-6.87l0.09-4.44zm51 0.41c-2.63 0-5.17 1.16-7.5 3.56-3.11 3.21-3.37 3.91-3.37 9.78 0 3.48 0.42 7.32 0.91 8.56 5.13 13.25 10.04 20.99 15.65 24.63 3.61 2.34 10.33 1.72 13.5-1.25 2.16-2.03 2.41-3.07 2.41-10.28 0-6.16-0.56-9.39-2.41-14.1-5.26-13.41-12.47-20.91-19.19-20.9zm41.07 0.15c0.13 0.03 0.18 0.38 0.18 1.1 0.01 0.91-0.42 1.94-0.97 2.28-1.24 0.77-1.24-0.54 0-2.47 0.42-0.64 0.65-0.93 0.79-0.91zm-275.94 0.25c-0.46 0.03-1.09 0.38-1.72 1.22-0.79 1.04-1.45 2.3-1.47 2.75-0.05 1.28 2.18 0.2 3.31-1.59 0.93-1.48 0.64-2.42-0.12-2.38zm48.75 1.13c0.79-0.04 1.75-0.01 2.87 0.12 5.04 0.6 6.13 1.05 6.13 2.44 0 1.24-10.54 1.19-11.31-0.06-0.93-1.51-0.07-2.38 2.31-2.5zm185.78 0.5c1.39-0.02 2.37 1.1 2.78 3.31 0.34 1.81 0.49 4.58 0.31 6.16l-0.34 2.84-3.66-4.91c-3.3-4.45-3.5-5.04-2.03-6.15 1.11-0.84 2.1-1.24 2.94-1.25zm37.53 1.28c0.08 0.01 0.09 0.18 0.09 0.47 0.03 0.67-1.28 5.94-2.9 11.72-1.62 5.77-3.22 10.74-3.56 11.06s-0.37-0.29-0.07-1.38c0.3-1.08 1.34-5.28 2.29-9.34 1.49-6.43 3.6-12.64 4.15-12.53zm-146.87 0.09c0.05-0.04 0.12 0.24 0.18 0.88 0.22 2.03 0.22 5.34 0 7.37-0.21 2.03-0.37 0.37-0.37-3.68 0-2.79 0.07-4.46 0.19-4.57zm-64.35 0.13-0.65 2.47c-0.37 1.35-1.74 5.15-3.04 8.43-1.29 3.29-2.34 6.54-2.34 7.22s-0.89 1.98-1.97 2.88-2.86 3.4-3.97 5.56c-2.74 5.37-1.29 0.42 2-6.88 1.47-3.24 3.43-7.9 4.35-10.34 0.92-2.43 2.56-5.52 3.65-6.87l1.97-2.47zm36.07 0.5c0.54 0 1.49 1.43 2.12 3.18 1.5 4.21 3.98 18.02 4 22.38 0.02 3.39 1.9 10.15 3.22 11.47 0.37 0.37 0.69 4.59 0.69 9.41 0 10.08 1.47 10.85 2.5 1.28 0.37-3.51 1.08-6.41 1.56-6.41s0.84 2.89 0.84 6.41c0 3.51 0.43 6.37 0.91 6.37 1.06 0 2.06-2.41 2.06-4.94 0-1.01 1.13-3.02 2.47-4.47 1.34-1.44 2.69-4.13 3.03-5.96 0.35-1.84 1.1-3.63 1.66-3.97 1.2-0.75 0.28 6.28-1.47 11.19-1.33 3.7-0.7 4.8 1.97 3.37 1.4-0.75 2.07-2.54 2.56-6.69 0.85-7.19 1.59-10.15 2.56-10.15 0.42 0 0.53 3.66 0.25 8.18-0.32 5.1-0.12 8.49 0.5 8.88 0.66 0.41 1.14-4.26 1.38-13.59 0.23-8.99 0.78-14.66 1.5-15.38 1.15-1.15 1.39-0.06 2.62 11.59 0.34 3.23 0.14 3.98-0.93 3.57-1.03-0.4-1.25 0.2-0.91 2.31 0.25 1.54 0.69 5.21 1 8.19s1.03 6.1 1.59 6.9c1.03 1.48 0.91-1.53-0.53-11.31-0.43-2.91-0.32-3.43 0.38-1.97 0.52 1.08 1.21 4.12 1.56 6.75 0.42 3.22 0.96 4.45 1.62 3.78 0.67-0.66 0.49-2.84-0.5-6.72-1.29-5.09-2.28-13.1-3.03-24-0.13-1.89-0.37-3.86-0.53-4.4-0.15-0.54-0.18-2.32-0.06-3.94 0.2-2.74 0.25-2.68 1 0.97 0.44 2.16 1.12 6.48 1.47 9.59 0.34 3.11 1.1 5.66 1.65 5.66 0.64 0 0.77-1.89 0.38-5.16-0.4-3.27-0.32-4.62 0.25-3.69 0.49 0.82 1.22 4.99 1.59 9.29 0.38 4.29 0.98 8.27 1.35 8.84 0.36 0.57 0.74 2.15 0.81 3.5 0.37 6.91 1.73 14.78 2.59 14.78 0.61 0 0.76-3.06 0.41-8.12-0.32-4.59-0.22-6.8 0.22-5.1 0.89 3.51 4.11 9.28 5.19 9.28 0.4 0 0.49 0.66 0.18 1.47-0.68 1.77 0.76 1.96 2.41 0.32 1.8-1.81 1.39-3.76-0.78-3.76-1.16 0-2.55-1.18-3.44-2.9-1.66-3.22-3.41-13.91-3.41-20.72 0-4.34 0.05-4.25 2.82 3.94 1.55 4.6 3.33 10.27 3.96 12.62 1.55 5.77 2.35 4.5 2.22-3.53l-0.12-6.62 1.9 3.93c1.05 2.17 2.19 5.37 2.54 7.13 0.4 2.05 1.98 4.35 4.43 6.37 2.11 1.74 3.82 3.52 3.82 3.94 0 0.43-1.79 0.75-3.97 0.75-2.19 0-5.15 0.77-6.6 1.72-3.88 2.54-19.99 2.43-24.81-0.16-4.01-2.15-15.38-2.35-19-0.37-2.02 1.11-14.47 1.94-14.47 0.97 0-0.24 1.32-1.94 2.94-3.78 2.05-2.34 2.94-4.34 2.88-6.53l-0.1-3.16-0.9 2.97c-1.15 3.76-7.38 10.77-8.29 9.31-0.85-1.37 0.32-7.61 1.57-8.38 0.52-0.32 0.9 0.59 0.9 2 0 1.42 0.41 2.36 0.88 2.07 0.46-0.29 0.71-4.87 0.53-10.16-0.28-7.95-0.2-8.96 0.62-5.72 0.55 2.16 1.5 4.39 2.1 4.94 0.78 0.72 0.91 0.3 0.47-1.47-0.34-1.35-0.62-3.9-0.63-5.72-0.01-2.63-0.35-3.2-1.62-2.72-1.42 0.55-1.49-0.29-0.94-7.53 0.58-7.71-0.24-16.89-1.85-20.65-0.41-0.99-0.31-1.72 0.26-1.72zm106.43 0.53c5.2-0.03 5.41 0.04 5.13 2.41-0.89 7.3-1.49 10.42-2.16 11.31-0.41 0.54-1.77 5.51-3.03 11.06-1.86 8.22-2.61 10.09-4.06 10.09-1.4 0-1.78-0.78-1.78-3.68-0.01-2.03-0.64-7.67-1.44-12.54-0.8-4.86-1.46-10.74-1.47-13.06-0.02-4.96 0.89-5.55 8.81-5.59zm70.38 1.84c0.03-0.02 0.07 0 0.09 0 0.16 0.05 0.08 0.69-0.22 2.03-0.81 3.62-1.39 4.43-1.37 1.91 0.01-1.04 0.48-2.56 1.03-3.37 0.2-0.31 0.36-0.5 0.47-0.57zm-34.44 0.41c0.05 0.03 0.09 0.17 0.16 0.4 0.24 0.95 0.24 2.5 0 3.44-0.25 0.95-0.44 0.18-0.44-1.72 0-1.42 0.12-2.21 0.28-2.12zm2.91 0.37c0.01-0.02 0.01-0.01 0.03 0 0.05 0.04 0.13 0.23 0.19 0.53 0.23 1.22 0.23 3.23 0 4.44-0.24 1.22-0.44 0.22-0.44-2.22 0-1.59 0.1-2.6 0.22-2.75zm-150.5 0.63-3.19 3.03c-3.28 3.09-3.34 4.34-0.06 1.37 0.99-0.89 2.13-1.3 2.53-0.9 0.86 0.87-4.91 5.85-9.22 7.94-2.96 1.43-6.24 4.43-4.84 4.43 1.47 0 10.03-5.36 13.06-8.18 1.76-1.65 3.18-2.69 3.18-2.32 0 0.94-2.73 3.54-7.37 7.03-2.13 1.61-4.66 3.73-5.63 4.69-2.2 2.21-2.95 2.2-4.34-0.03-1.51-2.41-3.61-12.78-2.94-14.53 0.3-0.77 1.58-1.37 2.82-1.34 1.23 0.02 5.33-0.23 9.12-0.57l6.88-0.62zm-133.72 0.16c0.843 0 1.271 0.42 0.937 0.96s-1.053 1-1.563 1c-0.509 0-0.906-0.46-0.906-1s0.688-0.96 1.532-0.96zm95.282 0c0.87 0 1.57 0.54 1.56 1.21-0.02 1.6-1.92 4.57-1.94 3.03 0-0.63-0.29-1.83-0.62-2.68-0.39-1.02-0.04-1.56 1-1.56zm291.03 0.21c0.12 0.05 0.36 0.74 0.78 2.16 0.9 2.99 0.77 4.02-0.37 2.87-0.36-0.36-0.64-1.78-0.6-3.18 0.04-1.25 0.07-1.89 0.19-1.85zm-372.22 0.91c-0.63-0.05-0.69 0.68-0.25 2.47 0.38 1.54 1.04 2.94 1.5 3.12s0.84 1.09 0.84 2.03c0 0.95 1.36 3.82 3.04 6.35 2.12 3.2 3.67 4.52 5.15 4.47 1.43-0.05 1.66-0.22 0.69-0.6-3.25-1.28-7.47-8.25-8.81-14.5-0.34-1.58-1.19-3.05-1.88-3.28-0.11-0.04-0.19-0.05-0.28-0.06zm243.94 0.09c1.09 0.14 1.29 4.69 1.25 24.6-0.02 11.45-0.25 11.78-5.31 9.03-2.48-1.35-2.69-1.95-2.69-7.28 0-3.2 0.37-6.06 0.84-6.35 0.73-0.44 1.67-4.03 2.69-10.4 0.83-5.2 2.08-9.27 2.97-9.57 0.08-0.02 0.18-0.04 0.25-0.03zm12.31 0.1c0.11-0.07 0.23-0.02 0.41 0.15 0.56 0.54 1.19 3.75 1.37 7.13s-0.03 6.16-0.44 6.15c-0.4 0-0.74-1.06-0.74-2.34-0.01-1.28-0.26-4.48-0.6-7.12-0.32-2.5-0.31-3.77 0-3.97zm-178.69 0.15c0.28 0.04 0.65 0.65 1.16 1.88 0.65 1.58 0.99 3.58 0.78 4.44-0.26 1.06-0.75 0.65-1.56-1.32-0.65-1.58-0.99-3.55-0.78-4.4 0.09-0.4 0.24-0.62 0.4-0.6zm11.5 0.1c0.49-0.16 0.49 2.32-0.37 6.47-0.6 2.88-1.74 8.99-2.5 13.59-0.77 4.6-1.84 9.92-2.38 11.81-0.81 2.89-0.93 2.33-0.59-3.43 0.62-10.57 1.65-18.6 2.5-19.69 0.42-0.54 1.3-2.97 1.97-5.41 0.6-2.21 1.08-3.25 1.37-3.34zm184.53 0.4c0.55 0 0.97 1.09 0.97 2.44s-0.42 2.47-0.97 2.47c-0.54 0-1-1.12-1-2.47s0.46-2.44 1-2.44zm-177.62 0.25c0.1-0.01 0.22 0.04 0.38 0.13 0.55 0.34 1.31 2.48 1.68 4.78 0.38 2.3 1.24 5.5 1.94 7.12 0.7 1.63 1.53 3.75 1.84 4.69 0.35 1.06 0.05 1.72-0.75 1.72-0.81 0-1.92-2.83-3-7.62-0.94-4.2-1.94-8.46-2.21-9.47-0.23-0.83-0.18-1.31 0.12-1.35zm-61.66 0.03c0.68-0.03 1.33 0.42 2.57 1.32 1.88 1.37 2.54 2.73 2.56 5.37 0.04 4.43 2.44 6.85 6.15 6.13 1.49-0.29 2.72-0.91 2.72-1.38s1.01-0.85 2.22-0.81c1.22 0.04 3.85-0.25 5.82-0.63 3.48-0.67 3.57-0.57 4.74 3.13 0.67 2.09 1.73 4.24 2.35 4.78s1.72 1.77 2.47 2.72c1.24 1.58 1 1.72-3.03 1.72-2.41 0-4.68-0.3-5.03-0.66-0.36-0.35-6.24-0.57-13.07-0.47-8.34 0.13-12.9-0.19-13.84-0.96-0.77-0.64-3.54-1.52-6.19-1.94-2.64-0.42-5.78-1.64-6.97-2.69s-3.01-2.62-4.03-3.5c-2.82-2.45-2.22-3.75 3.63-7.81 4.87-3.39 5.55-3.6 6.93-2.22 2.07 2.06 3.9 1.95 7.25-0.53 1.39-1.03 2.07-1.53 2.75-1.57zm220.19 0.35c0.25-0.08 0.28 0.97 0.31 3.53 0.04 2.57-0.11 4.69-0.37 4.69-1.1 0-1.52-4.66-0.63-6.91 0.32-0.8 0.54-1.26 0.69-1.31zm79.09 0.34c-0.05 0.05 0.24 0.47 0.85 1.25 1.28 1.64 2.09 2.16 2.09 1.35 0-0.21-0.77-0.98-1.72-1.72-0.78-0.61-1.16-0.93-1.22-0.88zm-240.03 0.07c0.55-0.07 0.97 0.71 0.97 2.34 0 1.33 0.54 3.54 1.16 4.9 0.87 1.92 0.84 2.81-0.13 3.97-0.68 0.83-1.76 1.45-2.37 1.41-0.7-0.05-0.65-0.22 0.12-0.53 1.93-0.78 1.48-1.92-1.31-3.19-1.82-0.83-2.27-1.49-1.59-2.34 0.52-0.67 1.2-2.42 1.56-3.91 0.4-1.68 1.05-2.59 1.59-2.65zm229.5 2.21c0.03 0.02 0.05 0.09 0.1 0.19 0.23 0.54 1.41 5.4 2.59 10.81 1.19 5.41 2.39 10.5 2.69 11.32 0.3 0.81 0.71 2.58 0.94 3.93 0.47 2.89 2.72 5.62 5.31 6.44 1.13 0.36 1.84 1.5 1.84 2.97 0 2.2-0.36 2.41-4.72 2.41-7.28 0-8.59-1.5-8.34-9.47 0.12-3.66-0.18-7.12-0.66-7.69-0.47-0.57-0.89-2.15-0.93-3.5-0.05-1.35-0.28-4.67-0.53-7.38-0.46-4.84-0.44-4.88 0.59-1.24 0.57 2.02 1.48 3.68 2.03 3.68s0.68-0.77 0.31-1.72c-0.67-1.74-1.67-10.95-1.22-10.75zm-31.34 0.13c0.06 0.01 0.14 0.12 0.22 0.31 0.27 0.68 0.27 1.76 0 2.44s-0.5 0.13-0.5-1.22c0-0.85 0.09-1.38 0.22-1.5 0.02-0.02 0.04-0.03 0.06-0.03zm-80.22 0.62c0.49-0.05 1.09 0.44 1.5 1.5 0.33 0.86 0.56 1.65 0.56 1.78 0 0.14-0.65 0.26-1.47 0.26-0.81-0.01-1.46-0.79-1.46-1.79 0-1.1 0.38-1.7 0.87-1.75zm64.41 0.13c0.06-0.03 0.17-0.02 0.25 0.06 0.32 0.33 0.34 1.17 0.06 1.88-0.31 0.78-0.55 0.58-0.59-0.57-0.04-0.77 0.08-1.3 0.28-1.37zm-15.35 0.22c0.07-0.01 0.15 0.01 0.22 0.06 0.54 0.33 1 2.37 1 4.5s-0.46 3.87-1 3.87-0.97-2.03-0.97-4.5c0-2.39 0.28-3.86 0.75-3.93zm-271.59 0.25c0.154-0.01 0.144 1.16 0.031 3.75-0.17 3.88-0.63 5.11-2.219 5.81-2.286 1.01-4.826 7.47-2.937 7.47 0.623 0 1.65-0.49 2.281-1.13 1.428-1.42 2.516 0.87 2.032 4.28-0.232 1.64-0.989 2.27-2.626 2.29-2.523 0.02-5.997 3.89-6.031 6.68-0.056 4.56-4.873 8.68-7.531 6.47-1.102-0.91-1.7-0.92-2.562-0.06-1.371 1.37-2.75 1.48-2.75 0.22-0.001-1.4 2.955-4 4.531-4 1.006 0 1.375-1.2 1.375-4.31 0-4.39 2.911-12.6 4.875-13.82 0.586-0.36 1.045-2.31 1.062-4.31 0.023-2.7 0.678-4.07 2.469-5.37 2.202-1.61 2.335-1.62 1.75-0.1-0.433 1.13-0.247 1.45 0.531 0.97 0.633-0.39 1.125-1.34 1.125-2.12s0.454-1.41 1.032-1.41c0.602 0 0.795 0.84 0.437 1.97-0.351 1.1-0.168 1.94 0.406 1.94 0.562 0 1.466-1.43 2-3.19 0.398-1.31 0.6-2.03 0.719-2.03zm-16.281 0.37c-0.502 0-1.4 0.45-2.625 1.38-1.871 1.41-1.878 1.47 0.187 1.5 1.16 0.01 2.376-0.66 2.688-1.47 0.359-0.94 0.252-1.4-0.25-1.41zm296 1.1c2.67 0.18 5.87 3.95 5.87 8.56 0 3.78-0.2 4.08-2.71 4.06-1.49-0.01-3.23-0.41-3.91-0.84-1.94-1.23-3.23-6.83-2.19-9.57 0.63-1.64 1.73-2.3 2.94-2.21zm-89.16 0.12c-0.05 0.01-0.08 0.03-0.12 0.06-0.31 0.31 0.03 1.24 0.72 2.07 1.76 2.13 2.25 1.87 0.96-0.54-0.52-0.98-1.2-1.65-1.56-1.59zm-13.72 1.13c0.07 0 0.15 0.12 0.22 0.31 0.28 0.68 0.28 1.76 0 2.44-0.27 0.67-0.5 0.13-0.5-1.22 0-0.85 0.09-1.39 0.22-1.5 0.02-0.02 0.04-0.04 0.06-0.03zm112.32 0.68c1.84 0.13 2.92 3.83 1.22 4.91-2.09 1.32-2.82 1.01-2.82-1.13 0-1.08-0.06-2.28-0.15-2.68-0.1-0.41 0.51-0.9 1.37-1.06 0.13-0.03 0.25-0.04 0.38-0.04zm-284.97 0.54c0.634-0.17 1.062 0.58 1.062 2.28 0 1.02 1.288 4.06 2.87 6.75 2.25 3.81 2.73 5.52 2.16 7.68-0.58 2.18-1.39 2.86-3.78 3.1-2.681 0.26-3.142-0.1-4.031-2.97-2.239-7.23-2.361-9.81-0.625-13.66 0.869-1.93 1.709-3.02 2.344-3.18zm275.93 0.5c-0.25-0.02-0.53 0.03-0.78 0.12-2.09 0.8-2.06 2.68 0.1 5.38 1.99 2.49 3.56 2.33 3.97-0.38 0.35-2.36-1.49-5.01-3.29-5.12zm105.63 0c0.1-0.01 0.16 0.1 0.16 0.31 0 0.54-0.45 1.62-0.97 2.43-0.53 0.82-0.94 1.05-0.94 0.5 0-0.54 0.41-1.65 0.94-2.46 0.33-0.51 0.64-0.78 0.81-0.78zm-233.81 2.28c-0.07-0.02-0.13-0.01-0.19 0.03-1.21 0.75-0.16 16.21 1.22 17.87 1.81 2.18 3.05 1.43 2.34-1.44-0.77-3.11-1.39-6.86-2.12-12.81-0.25-2.02-0.78-3.52-1.25-3.65zm231.62 2.72c0.28 0.02 0.41 0.5 0.41 1.5 0 2.37-0.48 2.74-1.5 1.09-0.36-0.59-0.2-1.56 0.41-2.16 0.3-0.3 0.51-0.45 0.68-0.43zm-114.15 0.71h1.47c4.98 0 6.28 2.33 2.81 5-3.16 2.43-3.53 2.39-5.28-1-1.79-3.46-1.99-3.94 1-4zm-140.66 0.97c0.38 0 0.11 0.69-0.56 1.5-0.68 0.81-1.61 1.47-2.13 1.47-0.51 0-0.28-0.66 0.53-1.47 0.82-0.81 1.78-1.5 2.16-1.5zm-26.63 0.1c0.56-0.12 1.63 0.36 3.44 1.4 1.36 0.78 1.81 1.36 1 1.32-2.76-0.15-4.9-0.97-4.9-1.88 0-0.47 0.13-0.78 0.46-0.84zm189.44 0.09c0.88 0.07 1.32 1.85 1.69 5.69 0.51 5.35-0.07 5.89-3.47 3.06-2.71-2.26-2.77-4.06-0.31-7.09 0.9-1.11 1.57-1.7 2.09-1.66zm-169.78 0.94c0.5 0 0.43 0.26-0.47 0.84-0.81 0.53-2.12 0.94-2.93 0.91-0.98-0.04-0.83-0.35 0.46-0.91 1.36-0.58 2.44-0.84 2.94-0.84zm-29.72 0.84c0.41 0 0.72 2.23 0.72 4.94 0 4.31-0.39 5.33-3.19 7.87-1.75 1.6-3.91 2.89-4.78 2.91-1.23 0.02-0.68-1.7 2.47-7.84 2.22-4.33 4.38-7.87 4.78-7.88zm20.91 2.47c3.95 0 6.65 0.35 6.03 0.75s-3.33 0.69-6.03 0.69c-2.71 0-5.44-0.29-6.06-0.69-0.63-0.4 2.1-0.75 6.06-0.75zm217.25 0.69c0.07-0.03 0.17 0.01 0.25 0.09 0.33 0.33 0.35 1.17 0.06 1.88-0.31 0.78-0.55 0.55-0.59-0.6-0.03-0.78 0.08-1.3 0.28-1.37zm-230.53 0.78c0.54 0 0.97 0.2 0.97 0.44 0 0.23-0.43 0.69-0.97 1.03-0.54 0.33-1 0.16-1-0.41s0.46-1.06 1-1.06zm184.69 1c1.34 0.01 7 5.84 7.65 7.91 0.36 1.11 0.13 2.61-0.47 3.34-0.6 0.72-2.16 1.53-3.47 1.78-2.15 0.41-2.47-0.01-3.4-4.38-1.22-5.67-1.34-8.66-0.31-8.65zm-159.5 0.47 0.18 9.12c0.17 8.21-0.08 10.49-0.97 8.35-0.16-0.41-0.05-4.5 0.25-9.1l0.54-8.37zm-12.29 0.5c1.88 0 2.74 0.41 2.32 1.09-0.37 0.59-1.55 0.81-2.6 0.53-1.19-0.31-1.77-0.03-1.53 0.69 0.47 1.42 2.56 1.57 5 0.37 1.37-0.67 1.73-0.55 1.41 0.44-0.63 1.91-6.11 2.2-7.6 0.41-1.72-2.08-0.47-3.53 3-3.53zm161.19 0c1.53 0 1.97 0.67 1.97 2.97 0 3.49-0.07 3.52-2.25 0.97-2.23-2.61-2.13-3.94 0.28-3.94zm3.34 0.18c0.07-0.02 0.14 0.02 0.22 0.1 0.33 0.33 0.35 1.16 0.07 1.87-0.32 0.79-0.52 0.56-0.57-0.59-0.03-0.78 0.08-1.3 0.28-1.38zm-155.62 0.32c0.59-0.22 0.81 1.32 0.81 5.22 0 3.35-0.18 6.09-0.4 6.09-1.06 0-1.69-10.1-0.69-11.09 0.1-0.1 0.2-0.19 0.28-0.22zm60.03 0.59c0.13 0.02 0.37 0.18 0.72 0.5 0.67 0.62 1.01 2.57 0.78 4.44-0.33 2.7-0.43 2.85-0.56 0.72-0.09-1.45-0.43-3.45-0.78-4.44-0.31-0.86-0.38-1.26-0.16-1.22zm-53.81 0.25c0.24-0.11 0.35 1.4 0.4 4.81 0.06 3.66-0.06 6.63-0.28 6.63-0.82 0-1.2-7.47-0.53-10.28 0.17-0.7 0.3-1.11 0.41-1.16zm4.84 0.63c0.24 0 0.73 0.46 1.06 1 0.34 0.54 0.14 0.97-0.43 0.97-0.58 0-1.07-0.43-1.07-0.97s0.2-1 0.44-1zm-57.4 1c-1.12 0-2.04 0.42-2.04 0.97 0 0.54 0.63 1 1.41 1s1.7-0.46 2.03-1c0.34-0.55-0.29-0.97-1.4-0.97zm206.03 0.53c0.06 0 0.11 0.22 0.19 0.68 0.22 1.5 0.23 3.7 0 4.91-0.24 1.21-0.45 0.02-0.44-2.69 0-1.86 0.12-2.91 0.25-2.9zm105.84 0.31c2.28-0.05 5.32 0.86 7.35 2.59 1.57 1.36 3.75 2.44 4.81 2.44 1.46 0 1.62 0.29 0.75 1.16s-0.75 1.47 0.53 2.4c0.93 0.68 1.37 1.57 0.97 1.97-0.41 0.41-0.75 0.2-0.75-0.43 0-0.79-1.69-1.05-5.38-0.79-4.97 0.36-5.65 0.17-8.37-2.62-1.63-1.67-2.97-3.83-2.97-4.81 0-1.25 1.29-1.87 3.06-1.91zm-370.47 1.13c0.81 0 1.47 0.13 1.47 0.34 0 0.2-0.66 0.95-1.47 1.62-1.21 1.01-1.5 0.94-1.5-0.37 0-0.88 0.69-1.59 1.5-1.59zm181.25 0c0.03-0.02 0.09 0 0.13 0 0.85 0 2.18 2.45 4.5 8.24 1.78 4.48 1.54 5.29-0.85 2.66-1.84-2.04-4.69-10.39-3.78-10.9zm29.16 0c0.21 0 0.66 0.65 0.97 1.46 0.31 0.82 0.12 1.47-0.41 1.47-0.52 0-0.97-0.65-0.97-1.47 0-0.81 0.2-1.46 0.41-1.46zm-121.85 0.96c0.06-0.04 0.12 0.2 0.19 0.75 0.22 1.76 0.22 4.62 0 6.38s-0.37 0.33-0.37-3.19c0-2.42 0.06-3.85 0.18-3.94zm24.6 0c0.05-0.04 0.12 0.2 0.19 0.75 0.21 1.76 0.21 4.62 0 6.38-0.22 1.76-0.38 0.33-0.38-3.19 0-2.42 0.07-3.85 0.19-3.94zm-103.41 0.07c-0.28 0.02-0.4 0.29-0.4 0.78 0 0.46 1 1.32 2.21 1.9 3.2 1.54 3.34 1.42 0.97-0.78-1.42-1.33-2.31-1.94-2.78-1.9zm353.81 1.12c0.53 0.03 1.17 0.39 2.19 1.06 1.32 0.86 2.62 2.48 2.91 3.6 0.48 1.85 0.08 2.03-4.38 2.03-4.61 0-4.81-0.13-4.18-2.22 0.36-1.22 1.24-2.83 1.96-3.59 0.57-0.6 0.98-0.9 1.5-0.88zm-269.15 0.09c0.59-0.14 1.55 1.44 1.65 3.47 0.12 2.32 0.16 2.35 0.54 0.41 0.66-3.46 2.25-2.57 2.25 1.25 0 1.89 0.48 3.44 1.06 3.44 0.61 0 0.79-0.93 0.44-2.22l-0.6-2.22 2.03 2.34c1.11 1.28 2 3.53 2 5.03 0 2.45-0.39 2.82-3.68 3.13-4.99 0.47-11.1-0.13-11.1-1.06 0-0.42 1.12-2.93 2.47-5.6 1.35-2.66 2.47-5.61 2.47-6.59 0-0.87 0.2-1.31 0.47-1.38zm-7.81 0.29c0.05-0.04 0.11 0.19 0.18 0.65 0.23 1.49 0.23 3.92 0 5.41-0.22 1.49-0.4 0.26-0.4-2.72 0-2.05 0.09-3.27 0.22-3.34zm-100 0.06c2.187-0.05 5.444 0.57 10.254 1.84 5.5 1.45 11.57 3.47 13.47 4.47 1.89 1 4.32 2.15 5.4 2.56 1.44 0.56 0.69 0.85-2.87 1.1-2.68 0.18-5.88-0.21-7.13-0.88-1.24-0.66-2.52-0.94-2.84-0.62-1.42 1.42 4.54 2.94 13.47 3.44 9.47 0.52 11.97 1.39 7.5 2.59-1.22 0.32-2.65 0.51-3.19 0.47-3.7-0.32-19.96-3-21.16-3.5-0.81-0.34-2.58-0.78-3.94-1-1.35-0.22-2.86-0.84-3.37-1.35-0.51-0.5-1.739-0.9-2.688-0.9-3.441 0-6.718-2.24-6.718-4.57 0-2.42 1.001-3.59 3.812-3.65zm202.65 0.34c0.49 0 1.21 2.32 1.6 5.16 0.75 5.6 1.97 8.62 3.47 8.62 1.41 0 1.08-3.17-0.57-5.34-3.13-4.14-0.78-4.76 4.07-1.06 3.35 2.56 4.94 3.01 5.5 1.62 0.4-1.01 13.59 0.96 13.59 2.03 0 0.43-1.48 0.78-3.25 0.78-3.35 0-5.96 1.46-10 5.5-3.39 3.39-6.77 3.05-9.81-0.93-3.71-4.86-6.95-16.38-4.6-16.38zm30 0.03c4.33-0.05 13.56 2.36 18.03 5.25 3.57 2.31 4.28 4.05 1.28 3.1-1.5-0.48-2.04-0.05-2.53 1.9-0.66 2.67-0.59 2.67-10.03 1.82-4.02-0.37-5.6-2.23-3.18-3.72 1.53-0.95 1.14-4.44-0.5-4.44-0.82 0-1.47-0.46-1.47-1s-0.89-0.97-1.97-0.97-1.97-0.46-1.97-1c0-0.65 0.9-0.92 2.34-0.94zm-240.22 1.41c1.838-0.22 2.882 1.54 2.594 4.56-0.282 2.95-0.699 3.39-3.438 3.66-3.744 0.36-5.021-1.29-2.875-3.66 0.865-0.95 1.563-2.2 1.563-2.78-0.001-0.57 0.587-1.28 1.312-1.56 0.294-0.11 0.581-0.19 0.844-0.22zm377.57 0.53c0.54 0 0.96 0.4 0.96 0.91s-0.42 1.23-0.96 1.56-1-0.09-1-0.94c0-0.84 0.46-1.53 1-1.53zm-393.32 0.06c0.493-0.09 0.812 0.32 0.812 1.28 0 0.75-0.856 1.61-1.906 1.88-1.657 0.43-1.758 0.27-0.75-1.34 0.682-1.1 1.35-1.72 1.844-1.82zm423.04 0c0.36-0.03 0.81 0 1.34 0.1 1.54 0.3 1.54 0.47 0.16 1.62-1.11 0.92-1.74 0.95-2.22 0.16-0.68-1.09-0.37-1.77 0.72-1.88zm-369.85 0.04c-0.34-0.03-0.1 0.24 0.56 0.96 0.7 0.76 2.68 1.93 4.41 2.57 3.58 1.31 6.28 1.62 5.28 0.62-0.37-0.37-2.09-1.2-3.84-1.84s-4.11-1.49-5.19-1.91c-0.62-0.24-1.01-0.39-1.22-0.4zm229.44 0.12c0.02-0.02 0.01-0.01 0.03 0 0.05 0.04 0.13 0.23 0.19 0.53 0.23 1.22 0.23 3.19 0 4.41-0.24 1.21-0.44 0.21-0.44-2.22 0-1.6 0.1-2.58 0.22-2.72zm-32.06 0.69c0.2-0.02 0.47 0.09 0.71 0.34 0.33 0.33 0.39 1.13 0.16 1.81-0.33 1-0.57 1.01-1.19 0-0.61-0.99-0.3-2.09 0.32-2.15zm-3.91 0.06c0.57 0 1.06 0.46 1.06 1s-0.2 0.97-0.44 0.97c-0.23 0-0.69-0.43-1.03-0.97-0.33-0.54-0.16-1 0.41-1zm-94.97 0.47c0.08-0.07 0.18 0.03 0.28 0.28 0.28 0.68 0.28 1.79 0 2.47-0.27 0.68-0.5 0.1-0.5-1.25 0-0.85 0.09-1.39 0.22-1.5zm-38.37 0.72c0.06-0.03 0.16 0.01 0.25 0.09 0.32 0.33 0.34 1.17 0.06 1.88-0.32 0.78-0.55 0.55-0.59-0.6-0.04-0.78 0.07-1.3 0.28-1.37zm130.56 0.9c0.34-0.01 0.71 0.05 1.06 0.19 0.79 0.32 0.58 0.55-0.56 0.59-1.04 0.05-1.64-0.17-1.31-0.5 0.16-0.16 0.47-0.26 0.81-0.28zm-178.53 1.85c-0.51 0.04-0.64 0.29-0.19 0.75 0.4 0.4 2.16 1.27 3.88 1.9 4.89 1.81 6.39 1.4 2.59-0.68-2.31-1.27-5.17-2.07-6.28-1.97zm82.4 0.19c0.07-0.03 0.17 0.01 0.25 0.09 0.33 0.33 0.35 1.16 0.07 1.87-0.32 0.79-0.55 0.59-0.6-0.56-0.03-0.78 0.08-1.33 0.28-1.4zm-125.37 1.06c0.41 0.01 0.97 0.15 1.687 0.53 1 0.52 2.929 1.44 4.284 2l2.47 1.03-2.972 0.03c-1.624 0.02-3.77-0.62-4.813-1.41-1.431-1.08-1.687-1.97-1.031-2.15 0.098-0.03 0.238-0.04 0.375-0.03zm384.9 1.62c2.36-0.02 4.34-0.02 5.44 0.03 0.68 0.04 1.25 0.95 1.25 2.03 0 1.86-0.66 1.97-11.84 1.97-9.76 0-11.96-0.24-12.44-1.5-0.32-0.83-0.37-1.72-0.15-1.93 0.24-0.24 10.67-0.54 17.74-0.6zm-290.46 1.06c0.38 0 1.5 0.62 2.5 1.35 1.25 0.92 1.47 1.54 0.68 2.03-0.62 0.39-1.15 1.79-1.15 3.12 0 1.7-0.77 2.71-2.53 3.38-3.27 1.24-3.38 1.22-3.38-0.5 0-2.03 3.04-9.38 3.88-9.38zm-100.28 0.1c0.973 0.03 0.829 0.35-0.469 0.9-2.704 1.17-4.267 1.17-2.468 0 0.811-0.52 2.125-0.93 2.937-0.9zm89.845 0.31c2.54 0.03 4.59 0.77 4.59 2.31 0 1.12-0.68 1.32-2.87 0.88-1.66-0.33-4.41 0.05-6.38 0.87-4.85 2.03-5.77 1.81-4-0.9 1.36-2.07 5.39-3.19 8.66-3.16zm42.28 0.59c0.89 0 2.08 0.89 2.66 1.97 0.8 1.51 0.75 1.97-0.25 1.97-0.73 0-1.85-0.54-2.5-1.18-0.92-0.92-1.19-0.59-1.19 1.43 0 1.43-0.46 2.88-1.06 3.25-0.74 0.46-0.91-0.07-0.47-1.65 0.62-2.23 0.57-2.24-1.44 0.34-2.02 2.61-2.44 2.72-11.13 2.69-10.28-0.04-13-1.01-11.4-4 0.57-1.07 1.47-1.63 2.03-1.28 0.56 0.34 4.95 0.6 9.75 0.56 7.69-0.07 8.64 0.08 8.09 1.5-0.41 1.07-0.2 1.35 0.57 0.87 0.63-0.39 1.12-1.27 1.12-1.97 0-1.71 3.24-4.5 5.22-4.5zm103.91 1.26c0.96-0.06 1.81 0.05 2.43 0.4 1.44 0.8 1.3 1.09-0.93 2.28-2.03 1.09-2.91 1.13-4.41 0.19-1.67-1.04-1.86-0.92-1.66 1.03 0.17 1.61-0.36 2.31-1.9 2.53-1.17 0.17-2.35-0.09-2.63-0.53-1.34-2.16 4.92-5.66 9.1-5.9zm69.34 0.18c0.91-0.05 1.56 0.09 1.56 0.5 0 0.55-0.4 1-0.87 1-0.48 0-2.36 0.26-4.19 0.56-2.27 0.39-2.85 0.26-1.84-0.37 1.53-0.95 3.82-1.59 5.34-1.69zm-282.66 0.66c0.35-0.02 0.74 0.04 1.1 0.19 0.78 0.31 0.55 0.51-0.6 0.56-1.03 0.04-1.6-0.14-1.28-0.47 0.17-0.16 0.44-0.27 0.78-0.28zm7.07 0.97c2.03-0.07 3.68 0.33 3.68 0.87 0 1.09-0.17 1.09-4.43 0-2.94-0.74-2.93-0.76 0.75-0.87zm316.06 0.09c-1.93 0.05-2.53 0.41-2.53 1.31 0 1.2 1 1.49 4.62 1.25 6.22-0.4 6.44-2.23 0.31-2.53-0.96-0.04-1.76-0.05-2.4-0.03zm-296.22 0.22c1.97 0.01 3.28 0.13 3.12 0.38-0.3 0.49-4.62 0.99-9.62 1.09s-8.91-0.02-8.66-0.25c0.63-0.55 7.83-1.08 13-1.19 0.78-0.02 1.5-0.03 2.16-0.03zm223.84 0.69c-0.8 0-1.58 0.04-2.18 0.15-1.22 0.24-0.25 0.41 2.18 0.41 2.44 0 3.44-0.17 2.22-0.41-0.61-0.11-1.41-0.15-2.22-0.15zm-268.53 0.84c-5.246 0-8.874 0.42-8.874 1-0.001 0.58 3.628 0.97 8.874 0.97 5.247 0 8.848-0.39 8.848-0.97s-3.601-1-8.848-1zm298.53 1c-2.68 0-3.08 0.92-1.25 2.75 1.43 1.42 12.57 1.59 12.57 0.19 0-0.54-1.98-0.97-4.41-0.97s-4.44-0.46-4.44-1-1.11-0.97-2.47-0.97zm-39.81 0.13c-0.44 0-0.91 0.05-1.25 0.18-0.68 0.28-0.1 0.5 1.25 0.5s1.9-0.22 1.22-0.5c-0.34-0.13-0.77-0.18-1.22-0.18zm-99.5 0.28c1.17-0.05 3.18 0.42 4.78 1.09 3.26 1.36 3.29 1.43 1.75 3.78-0.87 1.33-2.24 2.65-3 2.94-1.94 0.74-2.83-1.12-1.37-2.87 1.84-2.22 0.3-2.88-2.47-1.07-2.29 1.5-2.4 1.5-1.81-0.03 0.42-1.1 0.27-1.38-0.5-0.9-0.64 0.39-1.19 0.21-1.19-0.38 0-0.77-0.56-0.79-1.97-0.03-1.3 0.69-1.97 0.72-1.97 0.06 0-0.9 1-1.25 7.31-2.53 0.13-0.03 0.27-0.06 0.44-0.06zm-159.22 1.56c-1.623 0-2.968 0.32-2.968 0.75s1.345 0.91 2.968 1.03c1.624 0.12 2.938-0.23 2.938-0.78s-1.314-1-2.938-1zm266.72 0c-2.08 0.06-5.36 0.5-6.53 1.03-1.32 0.6-0.37 0.69 2.94 0.28 2.7-0.33 5.12-0.77 5.34-0.97 0.32-0.28-0.5-0.38-1.75-0.34zm-202.69 0.12c-0.34 0.02-0.65 0.09-0.81 0.26-0.33 0.32 0.28 0.54 1.31 0.5 1.15-0.05 1.35-0.28 0.57-0.6-0.36-0.14-0.72-0.17-1.07-0.16zm-11.4 1.85c-1.9 0-3.44 0.43-3.44 0.97s1.54 0.97 3.44 0.97c1.89 0 3.44-0.43 3.44-0.97s-1.55-0.97-3.44-0.97z"/>
						 <rect id="rect8" height="10.014" width="420.03" y="430.82" x="63.422"/>
						 <path id="path10" d="m543.54 276.94a276.23 276.23 0 1 1 -552.47 0 276.23 276.23 0 1 1 552.47 0z" transform="matrix(.95831 0 0 .95831 17.669 8.4373)" stroke="#000" stroke-linecap="round" stroke-miterlimit="2.41" stroke-width="9.7" fill="none"/>
						 <path id="path12" d="m207.05 63.887c0 1.932 0 3.667-0.03 5.205-0.02 1.537-0.08 2.752-0.18 3.646-0.07 0.612-0.19 1.122-0.35 1.532-0.17 0.409-0.45 0.66-0.85 0.753-0.19 0.043-0.41 0.081-0.66 0.114s-0.53 0.05-0.84 0.052c-0.24 0.001-0.42 0.03-0.52 0.088s-0.15 0.14-0.14 0.244c0 0.284 0.28 0.423 0.83 0.416 0.42-0.004 0.88-0.017 1.38-0.042 0.51-0.024 1-0.038 1.48-0.041 0.51-0.02 0.97-0.032 1.39-0.037 0.42-0.004 0.75-0.006 0.98-0.005 0.33 0 0.77 0.011 1.33 0.031 0.56 0.021 1.15 0.052 1.79 0.094 0.62 0.023 1.19 0.049 1.72 0.078 0.53 0.028 0.92 0.044 1.19 0.047 3.8-0.1 6.61-1.054 8.41-2.862s2.7-3.874 2.68-6.196c-0.1-2.428-0.94-4.386-2.5-5.875-1.57-1.488-3.26-2.521-5.06-3.1 1.18-0.89 2.17-1.905 2.98-3.044 0.8-1.139 1.22-2.548 1.26-4.227 0.1-1.224-0.44-2.538-1.61-3.943-1.17-1.404-3.58-2.168-7.24-2.29-0.7 0.005-1.47 0.026-2.3 0.062-0.84 0.037-1.76 0.057-2.77 0.063-0.46-0.006-1.23-0.026-2.31-0.063-1.08-0.036-2.2-0.057-3.34-0.062-0.31-0.003-0.54 0.023-0.69 0.078-0.15 0.054-0.23 0.153-0.23 0.296s0.06 0.241 0.18 0.296c0.13 0.055 0.3 0.08 0.53 0.078 0.3 0 0.6 0.01 0.9 0.031s0.54 0.052 0.72 0.094c0.67 0.137 1.13 0.392 1.38 0.763 0.24 0.371 0.38 0.906 0.41 1.605 0.04 0.554 0.06 1.399 0.07 2.534 0.01 1.136 0.01 3.228 0.01 6.275v7.312zm4.99-16.869c-0.01-0.224 0.02-0.389 0.07-0.493 0.06-0.105 0.16-0.176 0.3-0.213 0.2-0.04 0.41-0.064 0.62-0.073 0.22-0.009 0.47-0.012 0.75-0.01 1.78 0.094 3.09 0.819 3.94 2.176 0.84 1.356 1.26 2.778 1.25 4.264 0 1.02-0.15 1.899-0.44 2.638-0.3 0.74-0.72 1.328-1.26 1.766-0.35 0.306-0.76 0.515-1.25 0.629-0.48 0.113-1.06 0.167-1.74 0.161-0.48 0-0.87-0.011-1.2-0.032-0.32-0.02-0.57-0.051-0.75-0.093-0.09-0.016-0.16-0.056-0.21-0.12-0.05-0.063-0.08-0.175-0.08-0.337v-10.263zm9.51 21.855c-0.09 2.113-0.7 3.539-1.81 4.28-1.12 0.741-2.19 1.087-3.22 1.039-0.47 0.008-0.96-0.018-1.45-0.078-0.5-0.06-1.02-0.2-1.58-0.421-0.64-0.231-1.05-0.62-1.23-1.168-0.17-0.548-0.25-1.488-0.22-2.821v-9.847c0-0.201 0.08-0.298 0.25-0.291 0.3-0.001 0.58 0.001 0.84 0.005 0.27 0.005 0.58 0.017 0.94 0.037 0.8 0.039 1.47 0.137 2.01 0.296 0.53 0.158 1.02 0.392 1.44 0.701 1.55 1.147 2.62 2.478 3.2 3.994s0.86 2.94 0.83 4.274zm14.88-4.986c0 2.032-0.01 3.827-0.03 5.386s-0.08 2.783-0.18 3.672c-0.05 0.604-0.17 1.08-0.34 1.429-0.17 0.348-0.46 0.565-0.87 0.649-0.18 0.043-0.4 0.081-0.65 0.114s-0.53 0.05-0.84 0.052c-0.25 0.001-0.42 0.03-0.52 0.088s-0.15 0.14-0.15 0.244c0.01 0.284 0.29 0.423 0.84 0.416 0.88-0.005 1.84-0.026 2.88-0.062 1.03-0.037 1.82-0.058 2.35-0.063 0.59 0.005 1.47 0.026 2.63 0.063 1.17 0.036 2.45 0.057 3.85 0.062 0.24 0.001 0.42-0.032 0.57-0.099 0.14-0.066 0.22-0.172 0.22-0.317 0.01-0.214-0.21-0.325-0.66-0.332-0.33-0.002-0.69-0.019-1.08-0.052s-0.74-0.071-1.04-0.114c-0.61-0.088-1.03-0.307-1.25-0.66-0.23-0.352-0.37-0.811-0.41-1.376-0.08-0.909-0.13-2.145-0.15-3.708-0.02-1.564-0.02-3.361-0.02-5.392v-7.312c0-3.047 0-5.139 0.01-6.275 0.01-1.135 0.03-1.98 0.07-2.534 0.03-0.722 0.16-1.273 0.38-1.652s0.61-0.618 1.16-0.716c0.24-0.042 0.46-0.073 0.65-0.094 0.2-0.021 0.39-0.031 0.6-0.031 0.21 0.003 0.37-0.024 0.48-0.083 0.12-0.059 0.18-0.17 0.18-0.333 0-0.123-0.08-0.209-0.23-0.259-0.16-0.05-0.37-0.075-0.64-0.073-0.84 0.005-1.75 0.026-2.74 0.062-0.99 0.037-1.76 0.057-2.33 0.063-0.65-0.006-1.51-0.026-2.56-0.063-1.05-0.036-2-0.057-2.84-0.062-0.33-0.002-0.58 0.022-0.75 0.073-0.17 0.05-0.25 0.136-0.25 0.259 0 0.163 0.06 0.274 0.18 0.333 0.11 0.059 0.28 0.086 0.49 0.083 0.25-0.001 0.5 0.011 0.76 0.036s0.5 0.069 0.73 0.13c0.46 0.1 0.79 0.337 1.02 0.712 0.22 0.374 0.36 0.913 0.39 1.615 0.04 0.554 0.07 1.399 0.08 2.534 0.01 1.136 0.01 3.228 0.01 6.275v7.312zm18.74 0c0.01 1.932 0 3.667-0.02 5.205-0.02 1.537-0.08 2.752-0.18 3.646-0.07 0.612-0.19 1.122-0.36 1.532-0.16 0.409-0.45 0.66-0.85 0.753-0.19 0.043-0.4 0.081-0.65 0.114s-0.53 0.05-0.84 0.052c-0.25 0.001-0.42 0.03-0.52 0.088s-0.15 0.14-0.15 0.244c0.01 0.284 0.28 0.423 0.83 0.416 0.89-0.005 1.85-0.026 2.88-0.062 1.04-0.037 1.82-0.058 2.36-0.063 0.57 0.005 1.43 0.026 2.59 0.063 1.17 0.036 2.45 0.057 3.85 0.062 0.23 0.001 0.42-0.032 0.56-0.099 0.15-0.066 0.22-0.172 0.23-0.317 0-0.214-0.22-0.325-0.67-0.332-0.32-0.002-0.68-0.019-1.07-0.052-0.4-0.033-0.74-0.071-1.05-0.114-0.6-0.094-1.01-0.343-1.23-0.748-0.21-0.405-0.34-0.904-0.39-1.496-0.1-0.913-0.16-2.141-0.18-3.682-0.02-1.542-0.03-3.278-0.03-5.21v-16.62c0.01-0.45 0.12-0.713 0.34-0.789 0.19-0.062 0.43-0.105 0.71-0.13 0.29-0.025 0.59-0.037 0.91-0.036 0.5-0.019 1.12 0.08 1.87 0.296 0.75 0.215 1.51 0.657 2.28 1.324 1.12 1.083 1.82 2.21 2.1 3.381s0.4 2.122 0.35 2.852c-0.08 2.139-0.72 3.812-1.91 5.017-1.18 1.205-2.4 1.818-3.65 1.838-0.43-0.001-0.74 0.033-0.91 0.104-0.18 0.071-0.26 0.189-0.26 0.353 0.01 0.141 0.07 0.234 0.17 0.281 0.11 0.047 0.22 0.078 0.33 0.093 0.12 0.02 0.26 0.032 0.44 0.037 0.17 0.004 0.32 0.006 0.43 0.005 3.01-0.05 5.45-0.989 7.33-2.815 1.87-1.827 2.84-4.24 2.9-7.24-0.03-1.115-0.27-2.105-0.7-2.971-0.44-0.866-0.9-1.524-1.38-1.974-0.29-0.371-1.01-0.844-2.17-1.418-1.15-0.573-3.01-0.89-5.56-0.95-0.98 0.005-2.01 0.026-3.09 0.062-1.08 0.037-2.06 0.057-2.94 0.063-0.62-0.006-1.48-0.026-2.6-0.063-1.11-0.036-2.24-0.057-3.38-0.062-0.31-0.003-0.54 0.023-0.69 0.078-0.15 0.054-0.22 0.153-0.22 0.296s0.06 0.241 0.18 0.296 0.29 0.08 0.52 0.078c0.3 0 0.61 0.01 0.91 0.031s0.54 0.052 0.71 0.094c0.67 0.137 1.13 0.392 1.38 0.763s0.39 0.906 0.41 1.605c0.04 0.554 0.06 1.399 0.07 2.534 0.01 1.136 0.02 3.228 0.01 6.275v7.312zm24.61 7.895c-0.08 0.739-0.25 1.432-0.49 2.077-0.24 0.646-0.64 1.048-1.21 1.205-0.3 0.06-0.55 0.096-0.73 0.109-0.19 0.013-0.36 0.019-0.52 0.016-0.21-0.001-0.37 0.022-0.48 0.068-0.12 0.045-0.18 0.12-0.18 0.223 0 0.183 0.08 0.305 0.22 0.369 0.14 0.063 0.31 0.092 0.53 0.088 0.7-0.005 1.45-0.026 2.26-0.062 0.8-0.037 1.42-0.058 1.85-0.063 0.4 0.005 1 0.026 1.81 0.063 0.8 0.036 1.66 0.057 2.55 0.062 0.32 0.004 0.56-0.025 0.74-0.088 0.17-0.064 0.26-0.186 0.26-0.369 0-0.103-0.07-0.178-0.19-0.223-0.12-0.046-0.26-0.069-0.43-0.068-0.21 0.002-0.46-0.012-0.75-0.042-0.29-0.029-0.62-0.084-1-0.166-0.36-0.078-0.65-0.222-0.89-0.431-0.23-0.208-0.35-0.508-0.35-0.898 0-0.326 0.01-0.641 0.03-0.946 0.02-0.304 0.05-0.64 0.09-1.007l2.16-16.537h0.17c0.79 1.693 1.65 3.511 2.56 5.453 0.92 1.943 1.51 3.2 1.76 3.771 0.2 0.447 0.61 1.293 1.24 2.538 0.63 1.244 1.28 2.53 1.97 3.858 0.68 1.327 1.2 2.339 1.57 3.036 0.33 0.632 0.6 1.134 0.83 1.506s0.44 0.563 0.62 0.571c0.17 0.025 0.35-0.118 0.55-0.431 0.2-0.312 0.53-0.944 0.99-1.895l9.06-18.864h0.16l2.5 18.282c0.08 0.578 0.09 1.011 0.05 1.298-0.05 0.288-0.13 0.45-0.26 0.489-0.15 0.06-0.26 0.126-0.34 0.197s-0.12 0.157-0.12 0.26c-0.01 0.123 0.07 0.219 0.25 0.29 0.17 0.071 0.49 0.127 0.96 0.167 0.6 0.042 1.5 0.082 2.69 0.12 1.19 0.037 2.34 0.068 3.46 0.092s1.88 0.036 2.28 0.037c0.3 0.002 0.55-0.033 0.76-0.104 0.2-0.071 0.31-0.189 0.32-0.353 0-0.121-0.07-0.201-0.19-0.239-0.13-0.038-0.28-0.055-0.47-0.052-0.27 0.006-0.62-0.016-1.04-0.067-0.43-0.052-0.94-0.168-1.54-0.348-0.61-0.175-1.06-0.594-1.35-1.257s-0.52-1.643-0.69-2.94l-3.78-25.678c-0.12-0.866-0.37-1.295-0.74-1.288-0.19 0-0.34 0.083-0.48 0.249-0.13 0.166-0.28 0.416-0.44 0.748l-11.3 23.725-11.34-23.434c-0.27-0.526-0.48-0.876-0.64-1.049-0.17-0.173-0.33-0.253-0.49-0.239-0.34 0.007-0.57 0.367-0.7 1.08l-4.12 27.091z"/>
						 <path id="path14" d="m162.68 489.86c-0.34 0.57-0.72 1.09-1.16 1.53-0.43 0.45-0.9 0.64-1.43 0.56-0.27-0.06-0.49-0.11-0.64-0.17-0.16-0.06-0.3-0.11-0.43-0.17-0.18-0.08-0.32-0.12-0.43-0.12-0.11-0.01-0.19 0.03-0.23 0.12-0.06 0.15-0.04 0.28 0.05 0.38s0.23 0.19 0.41 0.27c0.58 0.24 1.21 0.5 1.88 0.76 0.68 0.26 1.2 0.46 1.56 0.61 0.33 0.15 0.82 0.39 1.47 0.71s1.35 0.64 2.09 0.97c0.26 0.12 0.47 0.18 0.64 0.19 0.16 0.01 0.28-0.06 0.35-0.21 0.03-0.09 0.01-0.17-0.08-0.25-0.08-0.08-0.19-0.15-0.33-0.21-0.18-0.08-0.38-0.18-0.61-0.31s-0.48-0.29-0.76-0.49c-0.27-0.2-0.46-0.42-0.58-0.68-0.11-0.26-0.11-0.55 0.03-0.87 0.12-0.27 0.24-0.53 0.37-0.77 0.12-0.25 0.27-0.51 0.44-0.8l7.74-12.88 0.14 0.06c0.04 1.68 0.09 3.49 0.15 5.43 0.06 1.93 0.09 3.18 0.09 3.74 0.01 0.44 0.04 1.29 0.11 2.55 0.07 1.25 0.15 2.55 0.24 3.89 0.09 1.35 0.15 2.37 0.2 3.08 0.05 0.64 0.1 1.15 0.15 1.54 0.06 0.39 0.16 0.63 0.31 0.7 0.13 0.08 0.33 0.03 0.61-0.16 0.27-0.19 0.77-0.59 1.49-1.21l14.29-12.32 0.13 0.06-4.53 16c-0.14 0.51-0.28 0.87-0.42 1.09-0.14 0.23-0.27 0.33-0.39 0.31-0.14 0-0.26 0.01-0.35 0.05-0.09 0.03-0.16 0.08-0.19 0.17-0.06 0.09-0.02 0.2 0.09 0.32 0.12 0.13 0.37 0.29 0.74 0.49 0.48 0.25 1.21 0.61 2.18 1.07s1.91 0.9 2.83 1.32c0.91 0.43 1.54 0.71 1.87 0.85 0.24 0.11 0.46 0.18 0.66 0.19 0.2 0.02 0.33-0.04 0.39-0.17 0.04-0.11 0.02-0.19-0.07-0.27s-0.21-0.15-0.37-0.21c-0.22-0.1-0.5-0.24-0.83-0.43-0.34-0.2-0.72-0.48-1.15-0.85-0.44-0.36-0.66-0.87-0.66-1.52s0.16-1.54 0.49-2.68l6.13-22.57c0.21-0.77 0.16-1.21-0.15-1.34-0.15-0.06-0.31-0.05-0.48 0.04s-0.39 0.24-0.64 0.46l-17.89 15.53-0.92-23.45c-0.03-0.53-0.08-0.9-0.15-1.1s-0.18-0.33-0.31-0.37c-0.29-0.12-0.61 0.09-0.98 0.64l-13.16 20.9zm39.96 8.38c-0.48 1.67-0.93 3.17-1.33 4.49-0.41 1.33-0.77 2.36-1.08 3.11-0.22 0.51-0.45 0.93-0.69 1.24-0.25 0.31-0.56 0.46-0.93 0.44-0.17-0.01-0.37-0.04-0.6-0.07-0.22-0.04-0.47-0.09-0.74-0.17-0.21-0.06-0.37-0.08-0.47-0.05-0.1 0.02-0.16 0.08-0.19 0.17-0.06 0.25 0.14 0.44 0.62 0.57 0.37 0.1 0.77 0.21 1.21 0.31 0.44 0.11 0.87 0.22 1.29 0.34 0.44 0.11 0.85 0.22 1.21 0.32s0.65 0.18 0.85 0.24c0.53 0.16 1.09 0.33 1.69 0.52 0.59 0.2 1.26 0.42 2.02 0.68 0.76 0.25 1.65 0.53 2.66 0.85s2.19 0.68 3.53 1.07c0.65 0.22 1.13 0.31 1.42 0.29s0.56-0.24 0.79-0.66c0.22-0.4 0.52-1.02 0.87-1.86 0.36-0.85 0.61-1.51 0.76-1.99 0.06-0.18 0.09-0.34 0.1-0.47s-0.06-0.22-0.2-0.26c-0.12-0.04-0.22-0.02-0.3 0.04-0.08 0.07-0.16 0.2-0.25 0.38-0.33 0.7-0.68 1.22-1.05 1.56-0.38 0.35-0.82 0.56-1.34 0.63-0.55 0.07-1.15 0.03-1.8-0.11s-1.22-0.29-1.71-0.44c-1.79-0.49-2.9-1.03-3.34-1.6-0.43-0.58-0.46-1.47-0.09-2.68 0.16-0.62 0.42-1.52 0.78-2.72 0.35-1.2 0.64-2.15 0.84-2.85l0.83-2.84c0.03-0.11 0.07-0.2 0.12-0.25 0.05-0.06 0.11-0.07 0.2-0.05 0.55 0.16 1.42 0.42 2.61 0.79 1.2 0.37 2.02 0.64 2.47 0.81 0.63 0.26 1.06 0.56 1.29 0.9s0.34 0.7 0.31 1.09c-0.02 0.25-0.05 0.49-0.1 0.71-0.05 0.23-0.1 0.44-0.13 0.62-0.03 0.09-0.03 0.18 0 0.25 0.03 0.08 0.1 0.13 0.23 0.17 0.15 0.03 0.27-0.02 0.35-0.15 0.07-0.14 0.13-0.28 0.17-0.44 0.05-0.16 0.17-0.5 0.36-1.01 0.18-0.51 0.35-0.96 0.48-1.36 0.34-0.87 0.59-1.49 0.76-1.86 0.17-0.36 0.27-0.59 0.3-0.68 0.03-0.1 0.03-0.19-0.01-0.24-0.03-0.06-0.09-0.1-0.16-0.12-0.09-0.02-0.19-0.01-0.3 0.05s-0.25 0.14-0.41 0.25c-0.21 0.13-0.47 0.19-0.77 0.19-0.31-0.01-0.68-0.06-1.11-0.15-0.33-0.07-0.89-0.22-1.7-0.44-0.81-0.23-1.62-0.46-2.42-0.69s-1.35-0.39-1.66-0.48c-0.1-0.03-0.16-0.08-0.18-0.16-0.01-0.08 0.01-0.18 0.04-0.31l2.66-9.09c0.06-0.25 0.18-0.35 0.35-0.29 0.28 0.08 0.78 0.24 1.51 0.46 0.72 0.23 1.43 0.45 2.14 0.69 0.71 0.23 1.18 0.39 1.42 0.48 0.84 0.36 1.38 0.7 1.64 1.01s0.39 0.64 0.39 0.99c0.02 0.25 0.01 0.51-0.03 0.77-0.05 0.25-0.09 0.45-0.13 0.59-0.05 0.16-0.07 0.29-0.04 0.39 0.02 0.1 0.09 0.17 0.21 0.2 0.13 0.04 0.23 0.02 0.3-0.05 0.08-0.07 0.14-0.15 0.18-0.24 0.11-0.25 0.27-0.64 0.46-1.18 0.19-0.53 0.33-0.91 0.41-1.14 0.29-0.78 0.52-1.33 0.68-1.64 0.16-0.3 0.25-0.51 0.29-0.61 0.03-0.09 0.04-0.17 0.03-0.24-0.02-0.07-0.06-0.12-0.15-0.15-0.09-0.02-0.2-0.03-0.31-0.02h-0.31c-0.16-0.01-0.38-0.03-0.65-0.07-0.28-0.05-0.6-0.1-0.96-0.17-0.31-0.07-1.1-0.3-2.38-0.66-1.29-0.37-2.59-0.75-3.93-1.14-1.33-0.38-2.23-0.65-2.69-0.78-0.25-0.08-0.57-0.18-0.96-0.31-0.39-0.12-0.81-0.27-1.28-0.42-0.45-0.14-0.93-0.28-1.43-0.44l-1.47-0.45c-0.27-0.08-0.48-0.11-0.62-0.1-0.14 0-0.23 0.07-0.27 0.2-0.03 0.12-0.01 0.22 0.08 0.3 0.09 0.07 0.24 0.14 0.44 0.2 0.26 0.07 0.52 0.16 0.77 0.25 0.26 0.1 0.46 0.18 0.6 0.26 0.54 0.29 0.88 0.63 1 1.01 0.12 0.39 0.1 0.88-0.05 1.49-0.11 0.49-0.3 1.23-0.58 2.22-0.28 0.98-0.8 2.79-1.57 5.43l-1.85 6.33zm26.73 6.73c-0.31 1.72-0.6 3.25-0.87 4.61s-0.52 2.43-0.75 3.21c-0.15 0.53-0.33 0.97-0.55 1.3-0.22 0.34-0.51 0.51-0.89 0.53-0.17 0.01-0.37 0.01-0.6-0.01-0.22-0.01-0.48-0.04-0.75-0.09-0.22-0.04-0.38-0.04-0.48 0-0.09 0.03-0.15 0.1-0.17 0.19-0.03 0.25 0.19 0.42 0.67 0.5 0.79 0.14 1.65 0.28 2.57 0.42 0.93 0.13 1.62 0.24 2.1 0.32 0.54 0.1 1.32 0.27 2.35 0.49 1.04 0.22 2.17 0.45 3.41 0.68 0.21 0.04 0.38 0.04 0.52 0 0.14-0.03 0.22-0.11 0.25-0.24 0.04-0.19-0.14-0.33-0.54-0.4-0.28-0.06-0.6-0.13-0.94-0.22-0.34-0.1-0.65-0.19-0.91-0.27-0.52-0.19-0.84-0.47-0.97-0.87-0.13-0.39-0.16-0.85-0.1-1.39 0.06-0.82 0.2-1.92 0.43-3.29s0.51-2.91 0.82-4.63l2.76-15.1 4.62 0.96c1.61 0.35 2.69 0.79 3.25 1.31 0.57 0.53 0.81 1.04 0.73 1.55l-0.04 0.41c-0.04 0.27-0.04 0.47 0 0.59 0.03 0.12 0.12 0.2 0.27 0.22 0.11 0.02 0.2-0.02 0.26-0.12 0.07-0.09 0.13-0.23 0.18-0.41 0.1-0.55 0.26-1.28 0.46-2.2 0.2-0.91 0.34-1.6 0.43-2.05 0.05-0.28 0.07-0.48 0.06-0.61-0.02-0.13-0.09-0.2-0.21-0.22-0.08-0.01-0.19-0.02-0.36-0.01-0.16 0-0.39 0-0.67 0.01-0.28-0.01-0.64-0.03-1.06-0.07s-0.93-0.11-1.52-0.21l-14.59-2.66c-0.62-0.12-1.25-0.25-1.89-0.4s-1.22-0.31-1.76-0.46c-0.44-0.13-0.77-0.28-0.98-0.44s-0.39-0.25-0.52-0.29c-0.11-0.02-0.21 0.02-0.3 0.12-0.08 0.1-0.18 0.27-0.27 0.5-0.06 0.12-0.2 0.48-0.44 1.05-0.23 0.58-0.46 1.17-0.69 1.78s-0.37 1.03-0.42 1.26c-0.04 0.2-0.04 0.36-0.01 0.46 0.03 0.11 0.11 0.17 0.23 0.19 0.11 0.02 0.21 0 0.28-0.06 0.08-0.06 0.15-0.17 0.21-0.31s0.16-0.31 0.3-0.51 0.33-0.42 0.56-0.66c0.33-0.35 0.78-0.55 1.34-0.59 0.57-0.05 1.38 0.01 2.43 0.17l5.52 0.86-2.76 15.1zm20.29 3.06c-0.13 1.74-0.26 3.29-0.38 4.68-0.13 1.38-0.26 2.46-0.41 3.26-0.11 0.54-0.25 1-0.43 1.35-0.17 0.36-0.44 0.57-0.81 0.62-0.17 0.03-0.37 0.05-0.6 0.06s-0.48 0.01-0.76-0.01c-0.22-0.02-0.38 0-0.47 0.04-0.1 0.05-0.15 0.12-0.15 0.21-0.01 0.26 0.23 0.4 0.72 0.43 0.8 0.06 1.66 0.1 2.59 0.14 0.94 0.04 1.64 0.08 2.12 0.11 0.51 0.04 1.29 0.12 2.33 0.23s2.19 0.22 3.45 0.32c0.21 0.02 0.38 0 0.52-0.05 0.13-0.05 0.21-0.14 0.22-0.27 0.02-0.19-0.17-0.31-0.57-0.34-0.3-0.03-0.62-0.07-0.97-0.12-0.35-0.06-0.66-0.12-0.93-0.18-0.53-0.12-0.89-0.37-1.05-0.75-0.17-0.38-0.25-0.84-0.25-1.37-0.03-0.83 0-1.94 0.09-3.33 0.08-1.38 0.2-2.95 0.33-4.68l1.14-14.94c0.04-0.4 0.15-0.63 0.35-0.69 0.18-0.04 0.4-0.06 0.66-0.06 0.25-0.01 0.53 0 0.81 0.03 0.45 0.01 1 0.15 1.67 0.39 0.66 0.25 1.31 0.69 1.95 1.35 0.94 1.05 1.49 2.11 1.66 3.18s0.21 1.93 0.12 2.59c-0.22 1.91-0.91 3.37-2.06 4.38-1.15 1-2.29 1.46-3.41 1.4-0.39-0.03-0.66-0.02-0.83 0.03-0.16 0.05-0.24 0.15-0.25 0.3 0 0.13 0.04 0.21 0.14 0.26 0.09 0.05 0.18 0.09 0.28 0.11s0.23 0.05 0.39 0.06c0.16 0.02 0.29 0.03 0.39 0.04 2.71 0.16 4.97-0.52 6.78-2.03 1.81-1.52 2.84-3.62 3.1-6.31 0.05-1.01-0.09-1.91-0.42-2.72s-0.7-1.43-1.11-1.87c-0.23-0.35-0.85-0.83-1.85-1.42-1-0.6-2.64-1.01-4.93-1.24-0.88-0.06-1.81-0.11-2.78-0.15-0.98-0.04-1.86-0.09-2.65-0.15-0.55-0.04-1.33-0.12-2.33-0.23s-2.01-0.21-3.04-0.29c-0.27-0.02-0.48-0.01-0.62 0.02-0.14 0.04-0.21 0.13-0.22 0.26-0.01 0.12 0.04 0.22 0.14 0.27 0.1 0.06 0.26 0.1 0.47 0.11 0.27 0.02 0.54 0.05 0.81 0.09s0.48 0.08 0.63 0.13c0.6 0.17 0.99 0.43 1.19 0.78s0.28 0.84 0.26 1.47c0 0.5-0.04 1.27-0.11 2.29s-0.21 2.9-0.42 5.64l-0.5 6.57zm18.94-2.51c0.1 2.19 0.73 4.28 1.91 6.25 1.17 1.97 2.88 3.56 5.13 4.76l-2.96 0.13c-0.73 0.03-1.41-0.03-2.04-0.21-0.63-0.17-1.1-0.46-1.42-0.88-0.12-0.16-0.25-0.41-0.39-0.73s-0.26-0.72-0.36-1.18c-0.05-0.21-0.1-0.35-0.16-0.43-0.06-0.09-0.15-0.13-0.28-0.12-0.14 0.01-0.23 0.08-0.25 0.21-0.03 0.13-0.04 0.29-0.02 0.48 0.02 0.33 0.07 0.89 0.16 1.7 0.09 0.8 0.18 1.6 0.29 2.39s0.21 1.33 0.28 1.61c0.13 0.46 0.34 0.74 0.61 0.83 0.28 0.09 0.77 0.11 1.45 0.06 1.5-0.07 3.11-0.15 4.83-0.25s3.03-0.18 3.93-0.24c0.38 0.02 0.6 0.03 0.67 0.04 0.06 0 0.28-0.01 0.64-0.02 0.11-0.01 0.18-0.05 0.21-0.12s0.04-0.17 0.03-0.31l-0.07-1.79c-2.09-1.08-3.76-2.86-4.99-5.33-1.24-2.47-1.93-5.03-2.06-7.68-0.09-1.66 0.11-3.38 0.6-5.15 0.49-1.78 1.42-3.31 2.77-4.59s3.27-2 5.75-2.16c3.51-0.05 6.07 1.06 7.69 3.32 1.63 2.26 2.49 5.07 2.6 8.42 0.12 3.58-0.38 6.33-1.48 8.27-1.11 1.93-2.57 3.47-4.37 4.62l0.07 1.79c0.01 0.14 0.03 0.24 0.06 0.31 0.04 0.07 0.11 0.1 0.22 0.09 0.36-0.01 0.58-0.02 0.64-0.03 0.07-0.01 0.29-0.04 0.67-0.1 0.89-0.01 2.2-0.05 3.93-0.1 1.73-0.04 3.34-0.1 4.83-0.16 0.69-0.01 1.17-0.07 1.44-0.19 0.27-0.11 0.45-0.4 0.54-0.87 0.06-0.32 0.11-0.88 0.15-1.68s0.07-1.6 0.08-2.4c0.02-0.8 0.02-1.35 0.01-1.67 0-0.19-0.02-0.35-0.06-0.47-0.04-0.13-0.13-0.19-0.27-0.19-0.13 0-0.22 0.05-0.27 0.14s-0.09 0.24-0.12 0.44c-0.05 0.47-0.14 0.89-0.26 1.26s-0.27 0.67-0.47 0.91c-0.35 0.42-0.84 0.72-1.48 0.9s-1.36 0.28-2.18 0.31l-2.88 0.12c2.02-1.68 3.62-3.53 4.8-5.53 1.17-2.01 1.72-4.27 1.64-6.78-0.19-3.97-1.54-7.09-4.05-9.36s-6.01-3.34-10.51-3.21c-2.27 0.09-4.59 0.68-6.97 1.77-2.37 1.08-4.36 2.69-5.96 4.81s-2.36 4.78-2.3 7.99zm59.66-16.67c0.36-0.93 0.7-1.68 1.01-2.26s0.66-0.97 1.05-1.17c0.48-0.26 0.9-0.43 1.27-0.5 0.19-0.04 0.32-0.1 0.41-0.18s0.13-0.17 0.11-0.28c-0.03-0.11-0.11-0.18-0.24-0.21-0.12-0.03-0.29-0.02-0.49 0.02-0.7 0.16-1.37 0.32-2.02 0.49-0.65 0.18-1.16 0.31-1.55 0.39-0.37 0.08-0.89 0.17-1.57 0.28-0.67 0.11-1.38 0.25-2.11 0.4-0.52 0.11-0.75 0.27-0.7 0.49 0.03 0.13 0.09 0.21 0.19 0.24s0.2 0.03 0.32 0c0.15-0.04 0.34-0.07 0.56-0.11 0.22-0.03 0.43-0.04 0.63-0.03 0.2 0.02 0.37 0.08 0.51 0.18s0.23 0.21 0.26 0.34c0.03 0.16 0.04 0.37 0.04 0.64-0.01 0.26-0.06 0.55-0.15 0.84-0.13 0.44-0.41 1.23-0.85 2.38-0.43 1.15-0.89 2.34-1.36 3.57-0.48 1.23-0.85 2.18-1.11 2.85-0.99-1.09-2.02-2.22-3.1-3.4-1.08-1.17-2.18-2.4-3.29-3.7-0.15-0.18-0.28-0.36-0.39-0.54s-0.17-0.33-0.2-0.44-0.02-0.23 0.02-0.36c0.05-0.12 0.14-0.23 0.29-0.32s0.31-0.16 0.5-0.23c0.19-0.06 0.34-0.1 0.46-0.13 0.17-0.03 0.3-0.08 0.38-0.15 0.09-0.07 0.12-0.17 0.1-0.3-0.03-0.12-0.1-0.2-0.23-0.22s-0.32-0.01-0.57 0.05c-0.73 0.16-1.48 0.34-2.27 0.54-0.78 0.21-1.33 0.34-1.63 0.41-0.93 0.2-1.97 0.4-3.11 0.61s-1.97 0.37-2.48 0.48c-0.24 0.05-0.41 0.11-0.53 0.18-0.11 0.07-0.16 0.16-0.14 0.27 0.03 0.12 0.08 0.21 0.16 0.25 0.08 0.05 0.18 0.06 0.29 0.03 0.18-0.04 0.42-0.07 0.7-0.08 0.27-0.02 0.57-0.02 0.89 0.01 0.67 0.06 1.3 0.27 1.88 0.62 0.58 0.34 1.16 0.84 1.75 1.47l8.54 9.09-4.85 11.5c-0.42 0.99-0.8 1.74-1.16 2.26-0.35 0.51-0.77 0.89-1.25 1.13-0.27 0.13-0.52 0.24-0.76 0.31-0.24 0.08-0.42 0.13-0.56 0.16-0.15 0.03-0.26 0.09-0.35 0.16-0.08 0.08-0.11 0.17-0.09 0.28 0.05 0.22 0.25 0.29 0.62 0.21l0.62-0.13c0.34-0.08 0.84-0.2 1.49-0.38 0.65-0.17 1.17-0.3 1.56-0.39 0.54-0.11 1.2-0.23 2-0.37s1.29-0.23 1.47-0.26l0.66-0.14c0.24-0.05 0.42-0.11 0.53-0.19 0.11-0.07 0.16-0.17 0.13-0.3-0.03-0.11-0.09-0.18-0.19-0.22-0.1-0.03-0.2-0.04-0.32-0.01-0.15 0.03-0.3 0.05-0.45 0.07-0.16 0.02-0.29 0.03-0.41 0.03-0.18 0-0.34-0.04-0.5-0.11-0.16-0.08-0.27-0.2-0.33-0.36-0.06-0.2-0.07-0.44-0.04-0.72s0.11-0.59 0.23-0.93l3.54-9.91c1.15 1.21 2.4 2.56 3.77 4.07 1.36 1.5 2.74 3.05 4.15 4.65 0.17 0.21 0.26 0.4 0.25 0.55 0 0.16-0.05 0.26-0.14 0.3-0.16 0.07-0.28 0.15-0.35 0.23s-0.1 0.18-0.08 0.29c0.02 0.12 0.13 0.19 0.32 0.2 0.2 0.02 0.53-0.02 1.01-0.1 1.46-0.28 2.8-0.55 4.03-0.8 1.23-0.26 2.09-0.44 2.57-0.55l1.1-0.23c0.21-0.05 0.37-0.11 0.48-0.2 0.12-0.08 0.16-0.19 0.14-0.32-0.03-0.11-0.09-0.17-0.19-0.2-0.1-0.02-0.22-0.02-0.35 0.01-0.16 0.04-0.36 0.07-0.6 0.09-0.23 0.01-0.51 0.01-0.84-0.01-0.5-0.04-0.93-0.15-1.31-0.32s-0.76-0.43-1.14-0.76c-0.48-0.42-1.46-1.41-2.97-2.99-1.51-1.57-3.04-3.18-4.59-4.82-1.55-1.63-2.63-2.75-3.23-3.36l4.15-9.93zm12.65 10.58c0.54 1.65 1.02 3.14 1.43 4.47 0.41 1.32 0.7 2.38 0.86 3.17 0.11 0.55 0.15 1.02 0.13 1.41-0.03 0.4-0.2 0.69-0.52 0.89-0.15 0.09-0.33 0.18-0.53 0.28-0.21 0.09-0.44 0.19-0.71 0.28-0.21 0.07-0.35 0.14-0.42 0.22-0.07 0.07-0.09 0.16-0.06 0.25 0.09 0.24 0.37 0.28 0.83 0.12 0.76-0.25 1.58-0.54 2.46-0.86 0.87-0.32 1.54-0.55 2-0.71 0.48-0.15 1.23-0.38 2.24-0.67 1-0.29 2.11-0.63 3.31-1.02 0.2-0.06 0.35-0.14 0.46-0.24 0.1-0.1 0.14-0.21 0.1-0.33-0.05-0.19-0.27-0.22-0.66-0.1-0.28 0.08-0.59 0.17-0.94 0.25-0.34 0.08-0.65 0.15-0.92 0.19-0.55 0.09-0.97-0.01-1.27-0.29-0.3-0.29-0.55-0.68-0.75-1.18-0.34-0.75-0.73-1.79-1.18-3.1-0.45-1.32-0.94-2.8-1.48-4.46l-4.64-14.24c-0.12-0.39-0.1-0.65 0.07-0.77 0.14-0.11 0.34-0.21 0.57-0.31 0.24-0.11 0.5-0.2 0.77-0.29 0.42-0.15 0.98-0.24 1.69-0.27 0.7-0.02 1.48 0.14 2.32 0.5 1.26 0.62 2.18 1.39 2.74 2.31 0.57 0.93 0.94 1.71 1.1 2.35 0.53 1.86 0.45 3.47-0.24 4.83-0.68 1.37-1.55 2.23-2.62 2.6-0.37 0.12-0.62 0.23-0.75 0.34s-0.17 0.24-0.12 0.38c0.05 0.11 0.13 0.18 0.23 0.19s0.21 0 0.31-0.01c0.1-0.02 0.23-0.05 0.38-0.09 0.15-0.05 0.28-0.09 0.38-0.12 2.56-0.88 4.39-2.37 5.49-4.46 1.09-2.09 1.25-4.42 0.46-7.01-0.34-0.95-0.81-1.73-1.43-2.35-0.61-0.62-1.19-1.06-1.73-1.31-0.35-0.24-1.1-0.44-2.25-0.61s-2.83 0.08-5.04 0.74c-0.84 0.28-1.71 0.58-2.63 0.91-0.91 0.34-1.75 0.63-2.5 0.88-0.53 0.16-1.28 0.39-2.24 0.67-0.97 0.28-1.94 0.58-2.92 0.89-0.27 0.08-0.46 0.17-0.57 0.26s-0.15 0.19-0.11 0.31c0.04 0.13 0.12 0.19 0.24 0.21 0.12 0.01 0.28-0.02 0.47-0.08 0.26-0.09 0.52-0.16 0.79-0.23 0.26-0.06 0.47-0.1 0.64-0.12 0.61-0.07 1.07 0.02 1.39 0.27s0.58 0.67 0.8 1.26c0.19 0.47 0.44 1.18 0.77 2.16 0.32 0.97 0.91 2.76 1.76 5.37l2.04 6.27zm16.57-9.55c0.92 2 2.3 3.69 4.14 5.06 1.84 1.38 4.02 2.2 6.56 2.46l-2.69 1.24c-0.66 0.31-1.32 0.5-1.96 0.58-0.65 0.08-1.2-0.01-1.65-0.27-0.18-0.11-0.4-0.28-0.65-0.53-0.25-0.24-0.51-0.56-0.78-0.96-0.12-0.17-0.22-0.28-0.31-0.33-0.09-0.06-0.19-0.06-0.3 0-0.13 0.06-0.18 0.16-0.16 0.29 0.03 0.12 0.08 0.27 0.17 0.44 0.14 0.3 0.4 0.8 0.79 1.51s0.78 1.41 1.18 2.1 0.69 1.16 0.88 1.39c0.29 0.38 0.58 0.56 0.88 0.53 0.29-0.02 0.74-0.18 1.36-0.49 1.35-0.63 2.81-1.32 4.37-2.07s2.74-1.32 3.54-1.71c0.36-0.13 0.57-0.2 0.63-0.22 0.07-0.02 0.26-0.11 0.59-0.26 0.1-0.05 0.15-0.11 0.15-0.19s-0.03-0.18-0.09-0.3l-0.75-1.63c-2.34-0.2-4.56-1.22-6.64-3.03-2.09-1.82-3.69-3.92-4.82-6.32-0.72-1.5-1.18-3.17-1.4-5s0.05-3.6 0.81-5.29c0.77-1.7 2.27-3.09 4.51-4.19 3.22-1.37 6.01-1.33 8.37 0.15 2.36 1.47 4.23 3.74 5.61 6.8 1.46 3.27 2.05 6 1.76 8.21s-1.05 4.19-2.28 5.94l0.75 1.63c0.05 0.12 0.11 0.21 0.17 0.26s0.14 0.05 0.24 0c0.33-0.15 0.52-0.24 0.58-0.27 0.06-0.04 0.25-0.15 0.58-0.34 0.82-0.36 2.02-0.89 3.6-1.59s3.05-1.36 4.4-1.99c0.64-0.27 1.06-0.51 1.26-0.72 0.21-0.2 0.27-0.54 0.17-1.01-0.06-0.32-0.23-0.86-0.5-1.61-0.26-0.76-0.54-1.51-0.83-2.25-0.29-0.75-0.5-1.26-0.63-1.55-0.08-0.17-0.16-0.31-0.24-0.42-0.08-0.1-0.18-0.12-0.32-0.06-0.11 0.05-0.18 0.12-0.19 0.23-0.02 0.1 0 0.25 0.05 0.45 0.13 0.46 0.21 0.88 0.24 1.27 0.03 0.38 0 0.72-0.09 1.01-0.16 0.52-0.5 0.99-1.03 1.4-0.52 0.4-1.15 0.78-1.89 1.11l-2.62 1.21c1.23-2.32 2.01-4.64 2.33-6.94s-0.03-4.6-1.05-6.9c-1.69-3.59-4.13-5.97-7.31-7.11-3.18-1.15-6.83-0.81-10.94 1.02-2.06 0.95-3.99 2.38-5.77 4.28-1.79 1.91-3.01 4.15-3.69 6.72-0.67 2.57-0.37 5.32 0.91 8.26z"/>
					</svg>
				</fo:instream-foreign-object>
			</fo:block>
		</fo:block-container>
		<!-- grey opacity -->
		<fo:block-container absolute-position="fixed" left="0" top="0">
			<fo:block>
				<fo:instream-foreign-object content-height="{$pageHeight}mm" fox:alt-text="Background color">
					<svg xmlns="http://www.w3.org/2000/svg" version="1.0" width="210mm" height="297mm">
						<rect width="210mm" height="297mm" style="fill:rgb(255,255,255);stroke-width:0;fill-opacity:0.73"/>
						</svg>
					</fo:instream-foreign-object>
				</fo:block>
			</fo:block-container>
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
		25
	</xsl:variable><xsl:variable name="marginLeftRight1" select="normalize-space($marginLeftRight1_)"/><xsl:variable name="marginLeftRight2_">
		15
	</xsl:variable><xsl:variable name="marginLeftRight2" select="normalize-space($marginLeftRight2_)"/><xsl:variable name="marginTop_">
		29.5
	</xsl:variable><xsl:variable name="marginTop" select="normalize-space($marginTop_)"/><xsl:variable name="marginBottom_">
		23.5
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
			<xsl:attribute name="font-size">10.5pt</xsl:attribute>
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
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
			<xsl:attribute name="margin-bottom">12pt</xsl:attribute>
		
				
		
		
		
		
		
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
		
		
		
		
		
			<xsl:attribute name="font-size">10pt</xsl:attribute>
			<xsl:attribute name="margin-top">8pt</xsl:attribute>
			<xsl:attribute name="margin-bottom">8pt</xsl:attribute>
			<xsl:attribute name="text-align">justify</xsl:attribute>
		
		
		

	</xsl:attribute-set><xsl:attribute-set name="example-style">
		
		
		
		
			<xsl:attribute name="font-size">10pt</xsl:attribute>
			<xsl:attribute name="margin-top">8pt</xsl:attribute>
			<xsl:attribute name="margin-bottom">8pt</xsl:attribute>
		
		
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="example-body-style">
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="example-name-style">
		
		
		
			<xsl:attribute name="padding-right">5mm</xsl:attribute>
		
		
		
		
		
		
		
		
		
		
		
				
				
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="example-p-style">
		
		
		
		
			<xsl:attribute name="font-size">10pt</xsl:attribute>
			<xsl:attribute name="margin-top">8pt</xsl:attribute>
			<xsl:attribute name="margin-bottom">8pt</xsl:attribute>
		
		
		
		
		
		
		
		
		
		
		
		
		
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
			<xsl:attribute name="font-style">italic</xsl:attribute>
			<xsl:attribute name="text-align">justify</xsl:attribute>
		
		
		
		
		
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
			<xsl:attribute name="margin-left">25mm</xsl:attribute>
		
		
		
		
		
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
		
		
			<xsl:attribute name="font-weight">bold</xsl:attribute>
		
		
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
		
			<xsl:attribute name="font-size">65%</xsl:attribute>
			<xsl:attribute name="vertical-align">super</xsl:attribute>
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="fn-body-style">
		<xsl:attribute name="font-weight">normal</xsl:attribute>
		<xsl:attribute name="font-style">normal</xsl:attribute>
		<xsl:attribute name="text-indent">0</xsl:attribute>
		<xsl:attribute name="start-indent">0</xsl:attribute>
		
			<xsl:attribute name="font-size">9pt</xsl:attribute>
			<xsl:attribute name="margin-bottom">12pt</xsl:attribute>
			<xsl:attribute name="line-height">124%</xsl:attribute>
			<xsl:attribute name="text-align">justify</xsl:attribute>
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
	</xsl:attribute-set><xsl:attribute-set name="fn-body-num-style">
		<xsl:attribute name="keep-with-next.within-line">always</xsl:attribute>
		
			<xsl:attribute name="font-size">60%</xsl:attribute>
			<xsl:attribute name="vertical-align">super</xsl:attribute>
			<xsl:attribute name="padding-right">1mm</xsl:attribute>
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
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
		
		
		
		
		
			<xsl:attribute name="font-weight">bold</xsl:attribute>
			<xsl:attribute name="span">all</xsl:attribute>
		
	</xsl:attribute-set><xsl:attribute-set name="indexsect-clause-title-style">
		<xsl:attribute name="keep-with-next">always</xsl:attribute>
		
		
		
		
		
			<xsl:attribute name="font-weight">bold</xsl:attribute>
			<xsl:attribute name="margin-left">25mm</xsl:attribute>
		
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
			
			
			
			
			
			
			
			
			
			

			
				<xsl:if test="count(*) = 1 and (local-name(*[1]) = 'stem' or local-name(*[1]) = 'figure')">
					<xsl:attribute name="padding-left">0mm</xsl:attribute>
				</xsl:if>
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
				
				10
				
				
				
				
				
				
				
						
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
					
			
			
			
			
			
				<xsl:if test="local-name(../..) = 'formula' or (local-name(../..) = 'td' and count(../../*) = 1)">
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
						
						9
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
			
			
				<xsl:if test="not(*)">
					<xsl:attribute name="space-after">12pt</xsl:attribute>
				</xsl:if>
			
			<fo:block-container margin-left="0mm">
				<fo:block-container xsl:use-attribute-sets="quote-style">
					
						<xsl:if test="ancestor::*[local-name() = 'boilerplate']">
							<xsl:attribute name="margin-left">7mm</xsl:attribute>
							<xsl:attribute name="margin-right">7mm</xsl:attribute>
							<xsl:attribute name="font-style">normal</xsl:attribute>
						</xsl:if>
					
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
		
				<label level="1">—</label> <!-- em dash -->
				<label level="2">−</label><!-- minus sign -->
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
							1.
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
		
		
				<!-- start JCGM bibitem processing -->
				<xsl:variable name="docidentifier">
					<xsl:choose>
						<xsl:when test="*[local-name()='docidentifier']/@type = 'metanorma'"/>
						<xsl:otherwise><xsl:value-of select="*[local-name()='docidentifier'][not(@type = 'metanorma-ordinal') and not(@type = 'BIPM')]"/></xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:value-of select="$docidentifier"/>
				
				<xsl:if test="*[local-name()='formattedref'] and normalize-space($docidentifier) != ''">, </xsl:if>
				<xsl:apply-templates select="*[local-name()='formattedref']"/>
					
				<!-- end JCGM bibitem processing -->
			
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
					
					
					
					
					
					
						<xsl:call-template name="displayAdmonitionName">
							<xsl:with-param name="sep"> — </xsl:with-param>
						</xsl:call-template>
					
					
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
								
										<xsl:value-of select="*[local-name() = 'title'][@language = $lang and @type = 'part']"/>
									
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
							
									<xsl:value-of select="normalize-space(*[local-name() = 'ext']/*[local-name() = 'editorialgroup']/*[local-name() = 'committee'])"/>
								
						</xsl:for-each>
					</dc:creator>
					<dc:description>
						<xsl:variable name="abstract">
							
									<xsl:value-of select="//*[contains(local-name(), '-standard')]/*[local-name() = 'bibdata']/*[local-name() = 'title'][@language = $lang and @type = 'main']"/>
								
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
			
			
			
			
			
			
			
			
			
			
			
			
						
			
			
			
			
				<xsl:value-of select="document('')//*/namespace::bipm"/>
			
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