<?xml version='1.0'?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version='1.0'>
        
  <!-- Copyright (c) 2005-2011, J. Greg Davidson.-->
  <!-- A stylesheet to turn css xml into SQL tree building code. -->

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
  
  <xsl:template match="/css">
    <xsl:param name="indent1" select="$newline" />
    <xsl:text>SELECT COALESCE(css_doc(:doc_uri), css_doc(:doc_uri</xsl:text>
    <xsl:apply-templates select="*">
      <xsl:with-param name="indent1" select="concat($indent1,$in1)" />
    </xsl:apply-templates>
    <xsl:value-of select="$newline" />
    <xsl:text>) );</xsl:text>
  </xsl:template>

  <xsl:template match="media">
    <xsl:param name="indent1" select="" />
    <xsl:apply-templates select="*">
      <xsl:with-param name="indent1" select="concat($indent1,$in1)" />
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="selector">
    <xsl:param name="indent1" select="" />
    <xsl:param name="indent2" select="concat($indent1, $in1)" />
    <xsl:text>,</xsl:text>
    <xsl:value-of select="$indent1" />
    <xsl:text>css_set(</xsl:text>
    <xsl:value-of select="$indent2" />
    <xsl:text>css_path(''</xsl:text>
    <xsl:apply-templates select="simple">
    </xsl:apply-templates>
    <xsl:text>)</xsl:text>
    <!-- put in file name here!!! --> 
    <xsl:apply-templates select="property|name">
      <xsl:with-param name="indent1" select="$indent2" />
    </xsl:apply-templates>
    <xsl:value-of select="$indent1" />
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="simple">
    <xsl:value-of select="concat($comma, $q, ., $q)" />
  </xsl:template>

  <xsl:template match="property">
    <xsl:param name="indent1" select="" />
    <xsl:text>,</xsl:text>
    <xsl:value-of select="$indent1" />
    <xsl:text>css_property(</xsl:text>
    <xsl:apply-templates select="*">
      <xsl:with-param name="indent1" select="concat($indent1,$in1)" />
    </xsl:apply-templates>
    <xsl:text>)</xsl:text>
  </xsl:template>
  
  <xsl:template match="name">
    <xsl:value-of select="concat($q, normalize-space(.), $q)" />
  </xsl:template>

  <xsl:template match="value">
    <xsl:text>, </xsl:text>
    <xsl:value-of select="concat($q, normalize-space(.), $q)" />
  </xsl:template>

</xsl:stylesheet>
