<?xml version='1.0'?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version='1.0'>
        
  <!-- Copyright (c) 2005-2011, J. Greg Davidson.-->
  <!-- A stylesheet to turn xml into SQL tree building code. -->
  <!-- See S7_wicci/wicci-test-index.xml4sql for example html input. -->
  <!-- See S7_wicci/foo.svg and S7_wicci/bar.svg for svg examples. -->
  <!-- See S5_xml/xml-html-code.sql for the constructor functions..  -->
  
  <!--
       Nodes may sport the following pseudo-attributes:
       d="document-handle"  - top node only; must be unique!
       u="uri"  	- top node only; must be unique!
       t="document-type"  - top node only; the doc_lang_name
       i="node-id" - must be unique in this document; empty: path
       c="node-id-of-child" - must be unique in this document; empty: path
       In addition, a regular id attribute can substitute for an i attribute.
       -->
  
  <xsl:output method="text" omit-xml-declaration="yes" indent="yes"/>
  
  <xsl:variable name="newline" select="'&#010;'" />
  <xsl:variable name="empty" select="''" />
  <xsl:variable name="space" select="' '" />
  <xsl:variable name="comma" select="','" />
  
  <xsl:variable name="in1" select="$space" />  <!-- indent 1 space -->
  <!--  <xsl:variable name="in1" select="'&#09;'" /> indent 1 tab -->
  <xsl:variable name="ddoc" select="'/'" />  <!-- document delimiter -->
  <xsl:variable name="dpos" select="'.'" />  <!-- path position delim -->
  <xsl:variable name="empty_child" select="'#'" />  <!-- not empty! -->
  <xsl:variable name="q" select='"&apos;"' />  <!-- 1 single quote -->
  <xsl:variable name="qq" select='"&apos;&apos;"' />  <!-- 2 quotes -->
  <xsl:variable name="q2" select="'&#09;'" />  <!-- quote alternative -->
  <!-- kludge: $q2 must match text-code.sql::get_xml_text(text) -->
  
  <xsl:variable name="sq" select="concat($space,$q)" />
  <xsl:variable name="cs" select="concat($comma,$space)" />
  <xsl:variable name="qcs" select="concat($q,$cs)" />
  
  <!--	document root -->
  <xsl:template name="doc" match="/*[@d]|/*[@u]">
    <xsl:param name="indent1" select="concat($newline,$in1)" />
    <xsl:param name="indent2" select="concat($indent1,$in1)" />
    <xsl:param name="doc">
      <xsl:choose>
        <xsl:when test="@d">
          <xsl:value-of select="@d" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@u" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <xsl:param name="ns_cnt" select="count(namespace::*)" />
    
    <xsl:text>SELECT COALESCE(</xsl:text>
    <xsl:value-of select="$indent1" />
    <xsl:value-of select='concat("xml_file_doc(", $q, $doc, $q, "),")' />
    <xsl:value-of select="$indent1" />
    <xsl:value-of select='concat("xml_file_doc(", $q, $doc, $q, "),")' />
    <xsl:text> t, </xsl:text>
    <xsl:value-of select='concat($q, @d, $q)' />
    <!-- reprocess node as a regular element -->
    <xsl:call-template select="." name="element">
      <xsl:with-param name="doc" select="$doc" />
      <xsl:with-param name="parent" select="$empty" />
      <xsl:with-param name="next" select="concat($comma, $indent2)" />
      <xsl:with-param name="parent_ns_cnt" select="$ns_cnt" />
    </xsl:call-template>
    <xsl:if test="@u and @u != $empty">
      <xsl:value-of select='concat($comma, $space, $q, @u, $q, $space)' />
    </xsl:if>
    <xsl:text> ) )</xsl:text>
    <xsl:value-of select="$newline" />
    <xsl:text>FROM</xsl:text>
    <xsl:value-of select="$indent1" />
    <xsl:text>xml_doctype(</xsl:text>		<!-- guess doctype from -->
    <xsl:value-of select="concat($q, @t, $qcs)" />	<!-- t="doctype" if any -->
    <xsl:value-of select="concat($q,name(),$q)" />	<!-- element tag -->
    <xsl:text> ) t, </xsl:text>		<!-- now just use "t"! -->
    <!-- process any namespaces -->
    <xsl:value-of select="$indent1" />
    <xsl:text>xml_namespaces(''</xsl:text>
    <xsl:for-each select="namespace::*">
      <xsl:value-of
        select="concat($cs, $q, name(), '=&quot;', ., '&quot;', $q)" />
    </xsl:for-each>
    <xsl:text>) n;</xsl:text>
    <xsl:value-of select="$newline" />
  </xsl:template>
  
  <!-- any element -->
  <xsl:template name="element" match="*">
    <xsl:param name="doc" select="$empty" />
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
          <xsl:value-of select="concat($doc, $ddoc, $next_parent)" />
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
    <xsl:param name="parent_ns_cnt" select="0" />
    <xsl:param name="ns_cnt" select="count(namespace::*)" />
    
    <xsl:value-of select="$next" />
    <xsl:if test="$ns_cnt > 0 and $ns_cnt != $parent_ns_cnt">
      <xsl:text>( SELECT </xsl:text>
    </xsl:if>
    <xsl:text>xml_tree(</xsl:text>
    <!-- <xsl:value-of select="concat($space, $index, $cs)" /> -->
    <xsl:value-of select="concat($sq, $id, $qcs)" />
    <xsl:text> xml_kind(t, n, </xsl:text>
    <xsl:value-of select='concat($q,name(),$q)' />
    <!-- process any attributes -->
    <xsl:for-each select="@*">
      <xsl:if
        test="name()!='d' and name()!='u' and name()!='t' and name()!='i' and name()!='c' ">
        <xsl:value-of
          select="concat($cs, $q, name(), '=&quot;', translate(normalize-space(.), '&quot;', $q), '&quot;')" />
      </xsl:if>
    </xsl:for-each>
    <xsl:text> )</xsl:text>
    <!-- process any children -->
    <xsl:apply-templates select="*|text()">
      <xsl:with-param name="doc" select="$doc" />
      <xsl:with-param name="parent" select="$next_parent" />
      <xsl:with-param name="child" select="$next_child" />
      <xsl:with-param name="next" select="concat($next,$in1)" />
      <xsl:with-param name="parent_ns_cnt" select="$ns_cnt" />
    </xsl:apply-templates>
    <xsl:text> )</xsl:text>
    <xsl:if test="$ns_cnt > 0 and $ns_cnt != $parent_ns_cnt">
      <xsl:text> FROM xml_namespaces(''</xsl:text>
      <xsl:for-each select="namespace::*">
        <xsl:value-of
          select="concat($cs, $q, name(), '=&quot;', ., '&quot;', $q)" />
      </xsl:for-each>
      <xsl:text>) n )</xsl:text>
    </xsl:if>
  </xsl:template>
  
  <!-- any text node -->
  <xsl:template name="text" match="text()">
    <xsl:param name="doc" select="$empty" />
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
        <xsl:value-of
          select="concat($sq, $doc, $ddoc, $parent, $dpos, $index, $qcs)" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat($sq, $doc, $ddoc, $child, $qcs)" />
      </xsl:otherwise>
    </xsl:choose>
    <!-- XSLT 1.0 doesn't have replace!! Instead of:
    <xsl:value-of
select="concat($q, replace(normalize-space(.), $q, $qq), $q, ';::text_refs')"
      />  we do this kludge:-->
    <xsl:value-of
      select="concat($q, translate(normalize-space(.), $q, $q2), $q)" />
    <xsl:text> )</xsl:text>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>
