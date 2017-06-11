<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:corbas="http://www.corbas.co.uk/ns/xsl/functions"
  xmlns:math="http://www.w3.org/2005/xpath-functions/math"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  exclude-result-prefixes="xs math xd"
  expand-text="yes"
  version="3.0">
  <xd:doc scope="stylesheet">
    <xd:desc> 
      <xd:p><xd:b>Created on:</xd:b> Apr 30, 2017</xd:p>
      <xd:p><xd:b>Author:</xd:b> nicg</xd:p>
      <xd:p>Generate randomised sets of elements for use in testing</xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:param name="max-uniques" as="xs:integer" select="1000"/>
  <xsl:param name="min-uniques" as="xs:integer" select="5"/>
  <xsl:param name="max-dups-percentage" as="xs:integer" select="50"/>
  <xsl:param name="max-dups" as="xs:integer" select="20"/>
  <xsl:param name="variants" as="xs:integer" select="5"/>
  
  <xsl:variable name="uniques" as="element(*)*">
    <xsl:for-each select="1 to $max-uniques">
      <xsl:element name="command">
        <xsl:attribute name="name" select="concat('command', .)"/>
      </xsl:element>
    </xsl:for-each>
  </xsl:variable>
  
  
  <xsl:template name="main">
    
    <xsl:for-each select="$min-uniques to $max-uniques">
      
      <xsl:variable name="current-uniques" select="xs:integer(.)" as="xs:integer"/>
      
      <xsl:if test="$current-uniques lt 100 or $current-uniques mod 10 eq 0">
      
      <xsl:variable name="current-uniques" as="xs:integer" select="."/>
      
        <xsl:call-template name="unique-set">
          <xsl:with-param name="unique-count" select="$current-uniques"/>
          <xsl:with-param name="generator" select="random-number-generator($current-uniques)"/>
        </xsl:call-template>
      
      </xsl:if>
      
    </xsl:for-each>
    
  </xsl:template>
  
  <xsl:template name="unique-set">
    
    <xsl:param name="generator" as="map(xs:string, item())"/>
    <xsl:param name="unique-count" as="xs:integer"/>
    
    <xsl:call-template name="build-doc">
      <xsl:with-param name="generator" select="$generator?next()"/>
      <xsl:with-param name="dup-counts" select="corbas:dup-counts($unique-count, $max-dups-percentage, $max-dups)"/>      
      <xsl:with-param name="unique-count" select="$unique-count"/>
    </xsl:call-template>
    
    
  </xsl:template>
  
  <xsl:template name="build-doc">
    
    <xsl:param name="generator" as="map(xs:string, item())"/>
    <xsl:param name="unique-count" as="xs:integer"/>
    <xsl:param name="dup-counts" as="xs:integer*"/>
    
    <xsl:call-template name="build-doc-variant">
      <xsl:with-param name="unique-count" select="$unique-count"/>
      <xsl:with-param name="generator" select="$generator?next()"/>
      <xsl:with-param name="variant-count" select="$variants"/>
    <xsl:with-param name="dup-counts" select="$dup-counts"/>
     
    </xsl:call-template>
    
    
  </xsl:template>
  
  <xsl:template name="build-doc-variant">
    
    <xsl:param name="generator" as="map(xs:string, item())"/>
    <xsl:param name="unique-count" as="xs:integer"/>
    <xsl:param name="dup-counts" as="xs:integer*"/>
    <xsl:param name="variant-count" as="xs:integer"/>
    
    <xsl:if test="not(empty($dup-counts))">
      
      <xsl:choose>

        <xsl:when test="$variant-count = 0">
          <xsl:call-template name="build-doc-variant">
            <xsl:with-param name="unique-count" select="$unique-count"/>
            <xsl:with-param name="generator" select="$generator?next()"/>
            <xsl:with-param name="variant-count" select="$variants"/>
            <xsl:with-param name="dup-counts" select="tail($dup-counts)"/>
          </xsl:call-template>
          
        </xsl:when>
        
        <xsl:otherwise>
          
          <xsl:message>BUILD-DOC-VARIANT - uniques={$unique-count}, dups={head($dup-counts)}, variant="{$variant-count}"</xsl:message>
          
          
          <xsl:variable name="to-write" select="corbas:random-sequence($unique-count, head($dup-counts), $generator)"/>
          
          <xsl:call-template name="write-sequence">
            <xsl:with-param name="unique-count" select="$unique-count"/>
            <xsl:with-param name="dup-count" select="head($dup-counts)"/>
            <xsl:with-param name="output-sequence" select="$to-write"/>
            <xsl:with-param name="variant" select="$variant-count"/>
          </xsl:call-template>
          
          <xsl:call-template name="build-doc-variant">
            <xsl:with-param name="unique-count" select="$unique-count"/>
            <xsl:with-param name="generator" select="$generator?next()"/>
            <xsl:with-param name="variant-count" select="$variant-count - 1"/>
            <xsl:with-param name="dup-counts" select="$dup-counts"/>
          </xsl:call-template>
          
        </xsl:otherwise>
        

      </xsl:choose>
      
    </xsl:if>
    
    
  </xsl:template>
  
  
  <xsl:template name="write-sequence">
    
    <xsl:param name="output-sequence" as="element(*)*"/>
    <xsl:param name="unique-count" as="xs:integer"/>
    <xsl:param name="dup-count" as="xs:integer"/>
    <xsl:param name="variant" as="xs:integer"/>
    
    <xsl:variable name="href" 
      select="'output/' || format-number($unique-count, '0000') || '/' || format-number($unique-count, '0000') || '-' || format-number($dup-count, '0000') || '-' || format-number($variant, '000') || '.xml'"/>
    
    <xsl:result-document href="{$href}">
      <root>
        <xsl:sequence select="$output-sequence"/>
      </root>
    </xsl:result-document>
    
  </xsl:template>
  
  <xsl:function name="corbas:dup-counts" as="xs:integer*">
    
    <xsl:param name="unique-count"/>
    <xsl:param name="max-dup-percentage"/>
    <xsl:param name="max-dups" as="xs:integer"/>
    
    <!-- if a simple divide up into max-dup-percentage would give too many values then redo -->
    <xsl:choose>
      <xsl:when test="$unique-count * ($max-dup-percentage div 100) gt $max-dups">
        <xsl:variable name="base" select="$unique-count * ($max-dup-percentage div 100)"/>
        <xsl:variable name="increment" select="$base div $max-dups" as="xs:double"/>
        <xsl:message>increment is <xsl:value-of select="$increment"/></xsl:message>
        <xsl:sequence select="distinct-values(for $n in (1 to $max-dups) return xs:integer(floor($n * $increment)))"/>
      </xsl:when>
      
      <xsl:otherwise>
        <xsl:sequence select="1 to xs:integer(floor($unique-count * ($max-dup-percentage div 100)))"></xsl:sequence>
      </xsl:otherwise>
    </xsl:choose>
    
    
  </xsl:function>

  <xsl:function name="corbas:dups" as="element(*)*">
    
    <xsl:param name="unique-count" as="xs:integer"/>
    <xsl:param name="dup-count" as="xs:integer"/>    
    <xsl:param name="generator" as=" map(xs:string, item())"/>
    
    <xsl:sequence select="if ($dup-count = 0) then () else (
      subsequence($uniques, 1, $unique-count)[floor($unique-count * $generator?number) + 1],
      corbas:dups($unique-count,$dup-count - 1, $generator?next()))"/>
     
  </xsl:function>
  
  <xsl:function name="corbas:random-sequence" as="element(*)*">
    
    <xsl:param name="unique-count" as="xs:integer"/>
    <xsl:param name="dup-count" as="xs:integer"/>
    <xsl:param name="generator"  as="map(xs:string, item())"/>
    
    
    <xsl:variable name="dups" select="corbas:dups($unique-count, $dup-count, $generator?next())" as="element(*)*"/>
    <xsl:variable name="current-uniques" select="subsequence($uniques, 1, $unique-count)"/>
    
    <xsl:sequence select="$generator?permute(($dups, $current-uniques))"/>
    
  </xsl:function>
  
</xsl:stylesheet>