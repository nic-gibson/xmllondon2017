<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  exclude-result-prefixes="xd"
  version="1.0">

  <xsl:key name="element-key" match="command" use="@name"/>
  
  <xsl:template match="root">
    <root>
      <xsl:for-each select="*[count(. | key('element-key', @name)[1]) = 1] ">
        <xsl:copy-of select="."/>
      </xsl:for-each>
    </root>
  </xsl:template>
  
  
</xsl:stylesheet>