<?xml version='1.0'?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:str="http://exslt.org/strings"
  extension-element-prefixes="str"
  version="1.0">
        
  <!-- Copyright (c) 2005-2012, J. Greg Davidson.-->
  <!-- A stylesheet to turn xml into SQL tree building code. -->
  <!-- See S7_wicci/wicci-test-index.xml4sql for example html input. -->
  <!-- See S7_wicci/foo.svg and S7_wicci/bar.svg for svg examples. -->
  <!-- See S5_xml/xml-html-code.sql for the constructor functions..  -->
  
  <!--
       Nodes may sport the following pseudo-id-attributes:
       i="hidden node id"	- when there is no id attribute
       c="hidden non-element-child node id" - e.g. for a text node child
       pseudo-id-attributes are stored in TABLE xml_doc_id_nodes,
       rather than in actual attributes of the document.
       -->
  
  <xsl:output method="text" omit-xml-declaration="yes" indent="yes"/>
  
  <xsl:variable name="newline" select="'&#010;'" />
  <xsl:variable name="empty" select="''" />
  <xsl:variable name="space" select="' '" />
  <xsl:variable name="comma" select="','" />
  <xsl:variable name="false" select="0" />
  <xsl:variable name="true" select="1" />
  
  <xsl:variable name="in1" select="$space" />  <!-- indent 1 space -->
  <!-- <xsl:variable name="in1" select="'&#09;'" /> <!- indent 1 tab -->
  <xsl:variable name="ddoc" select="'/'" />  <!-- document delimiter -->
  <xsl:variable name="dpos" select="'.'" />  <!-- path position delim -->
  <xsl:variable name="empty_child" select="'#'" />  <!-- not empty! -->
  <xsl:variable name="q" select='"&apos;"' />  <!-- 1 single quote -->
  <xsl:variable name="qq" select='"&apos;&apos;"' />  <!-- 2 quotes -->
  
  <xsl:variable name="sq" select="concat($space,$q)" />
  <xsl:variable name="cs" select="concat($comma,$space)" />
  <xsl:variable name="qcs" select="concat($q,$cs)" />
  
  <!--	document root -->
  <xsl:template name="doc" match="/*">
    <xsl:param name="indent1" select="concat($newline,$in1)" />
    <xsl:param name="indent2" select="concat($indent1,$in1)" />
    <xsl:param name="doc" select="$empty" />
    <xsl:param name="ns_cnt" select="count(namespace::*)" />
    
    <xsl:text>SELECT COALESCE(</xsl:text>
    <xsl:value-of select="$indent1" />
    <xsl:text>doc_page_from_uri_lang(u, t),</xsl:text>
    <xsl:value-of select="$indent1" />
    <xsl:text>doc_page_from_uri_lang_root(u, t</xsl:text>
    <!-- reprocess node as a regular element -->
    <xsl:call-template name="element">
	    <xsl:with-param name="root" select="$true" />
      <xsl:with-param name="doc" select="$doc" />
      <xsl:with-param name="parent" select="$empty" />
      <xsl:with-param name="next" select="concat($comma, $indent2)" />
      <xsl:with-param name="parent_ns_cnt" select="$ns_cnt" />
    </xsl:call-template>
    <xsl:text> )</xsl:text>
    <xsl:value-of select="$newline" />
    <xsl:text>) FROM get_page_uri(:doc_uri) u, xml_doctype(:doc_type, </xsl:text>
    <xsl:value-of select='concat($q,str:replace(name(), $q, $qq),$q)' />
    <xsl:text>) t;</xsl:text>
    <xsl:value-of select="$newline" />
  </xsl:template>
  
  <!-- any element -->
  <xsl:template name="element" match="*">
    <xsl:param name="root" select="$false" />
    <xsl:param name="doc" select="$empty" />
    <xsl:param name="docd">
      <xsl:choose>
        <xsl:when test="normalize-space($doc) = $empty">
          <xsl:value-of select="$empty" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat($doc, $ddoc)" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <xsl:param name="parent" select="$empty" />
    <xsl:param name="index" select="count(preceding-sibling::*) + 1" />
    <xsl:param name="next_parent">
      <xsl:choose>
        <xsl:when test="@i and @i != $empty">
          <xsl:value-of select="@i" />
        </xsl:when>
        <xsl:when test="@id">
          <xsl:value-of select="@id" />
        </xsl:when>
        <xsl:when test="$parent = $empty">
          <xsl:value-of select="$index" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat($parent, $dpos, $index)" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <xsl:param name="id">
      <xsl:choose>
        <xsl:when test="@i or @id">
          <xsl:value-of select="concat($docd, $next_parent)" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$empty" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <xsl:param name="next_child">
      <xsl:choose>
        <xsl:when test="@c and @c = $empty">
          <xsl:value-of select="$empty_child" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@c" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <xsl:param name="next" select="concat(',', $newline)" />
    <xsl:param name="next_in1" select="concat($next,$in1)" />
    <xsl:param name="next_in2" select="concat($next_in1,$in1)" />

    <xsl:param name="parent_ns_cnt" select="0" />
    <xsl:param name="ns_cnt" select="count(namespace::*)" />
    
    <xsl:value-of select="$next" />
		<xsl:choose>
			<xsl:when test="name() = 'meta' and @name = 'wicci'">
				<xsl:call-template name="meta">
					<xsl:with-param name="next" select="$next" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="normal">
					<xsl:with-param name="root" select="$root" />
					<xsl:with-param name="doc" select="$doc" />
					<xsl:with-param name="parent" select="$parent" />
					<xsl:with-param name="next_parent" select="$next_parent" />
					<xsl:with-param name="id" select="$id" />
					<xsl:with-param name="ns_cnt" select="$ns_cnt" />
					<xsl:with-param name="next_child" select="$next_child" />
					<xsl:with-param name="next" select="$next" />
					<xsl:with-param name="next_in1" select="$next_in1" />
					<xsl:with-param name="next_in2" select="$next_in2" />
					<xsl:with-param name="parent_ns_cnt" select="$parent_ns_cnt" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
  </xsl:template>
  
  <xsl:template name="meta">
   <xsl:text>xml_meta( </xsl:text>
	 <xsl:value-of select="concat($q, str:replace(@content, $q, $qq), $q)" />
   <xsl:text> )</xsl:text>
  </xsl:template>

  <xsl:template name="normal">
	 <xsl:param name="root" />
	 <xsl:param name="doc" />
	 <xsl:param name="id" />
	 <xsl:param name="ns_cnt" />
	 <xsl:param name="parent" />
	 <xsl:param name="next_parent" />
	 <xsl:param name="next_child" />
	 <xsl:param name="next" />
	 <xsl:param name="next_in1" />
	 <xsl:param name="next_in2" />
	 <xsl:param name="parent_ns_cnt" />
   <xsl:text>xml_tree(</xsl:text>
    <!-- <xsl:value-of select="concat($space, $index, $cs)" /> -->
    <xsl:value-of select="concat($sq, str:replace($id, $q, $qq), $q)" />
   	<xsl:value-of  select="$next_in1"/>
    <xsl:choose>
     <xsl:when test="$root = $true">
  	  	<xsl:text>xml_root_kind(t, </xsl:text>
	    </xsl:when>
     <xsl:otherwise>
	    	<xsl:text>xml_kind(t, </xsl:text>
     </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select='concat($q, namespace-uri(), $qcs)' />
    <xsl:value-of select='concat($q, str:replace(name(), $q, $qq), $q)' />
    <!-- process any attributes -->
    <xsl:for-each select="@*">
      <xsl:if
test="name()!='d' and name()!='u' and name()!='t' and name()!='i' and name()!='c'" >
     	<xsl:value-of  select="$next_in2"/>
      <xsl:text>xml_attr( </xsl:text>
	    	<xsl:value-of select='concat($q, namespace-uri(), $q)' />
      	<xsl:value-of
          select="concat($cs, $q, str:replace(name(), $q, $qq), $q)"/>
      	<xsl:value-of
select="concat($cs, $q, str:replace(normalize-space(.), $q, $qq), $q)"
      	/>
      <xsl:text> )</xsl:text>
      </xsl:if>
    </xsl:for-each>
    <xsl:text> )</xsl:text>
    <!-- process any children -->
    <xsl:apply-templates select="*|text()">
	    <xsl:with-param name="root" select="$false" />
      <xsl:with-param name="doc" select="$doc" />
      <xsl:with-param name="parent" select="$next_parent" />
      <xsl:with-param name="child" select="$next_child" />
      <xsl:with-param name="next" select="$next_in1" />
      <xsl:with-param name="parent_ns_cnt" select="$ns_cnt" />
    </xsl:apply-templates>
    <xsl:text> )</xsl:text>
  </xsl:template>

  <!-- any text node -->
  <xsl:template name="text" match="text()">
    <xsl:param name="doc" select="$empty" />
    <xsl:param name="docd">
      <xsl:choose>
        <xsl:when test="normalize-space($doc) = $empty">
          <xsl:value-of select="$empty" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat($doc, $ddoc)" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <xsl:param name="parent" select="$empty" />
    <xsl:param name="child" select="$empty" />
    <xsl:param name="next" select="concat($newline)" />
    <xsl:param name="index" select="count(preceding-sibling::*) + 1" />
    <xsl:if test="normalize-space(.) != $empty">
      <xsl:value-of select="$next" />
      <xsl:text>xml_leaf(</xsl:text>
      <xsl:choose>
        <xsl:when test="$child = $empty">
          <xsl:value-of select="concat($sq, $qcs)" />
        </xsl:when>
        <xsl:when test="$child = $empty_child">
          <xsl:value-of select="concat($sq, str:replace(concat($docd, $parent, $dpos, $index), $q, $qq), $qcs)" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat($sq, str:replace(concat($docd, $child), $q, $qq), $qcs)" />
        </xsl:otherwise>
      </xsl:choose>
      	<xsl:value-of select="concat($q, str:replace(normalize-space(.), $q, $qq), $q)"
      	/>
      <xsl:text> )</xsl:text>
    </xsl:if>
  </xsl:template>
  
</xsl:stylesheet>
