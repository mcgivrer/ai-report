<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="html" encoding="UTF-8" indent="yes" doctype-system="about:legacy-compat"/>
  <xsl:strip-space elements="*"/>

  <xsl:param name="theme-css" select="/report/meta/theme/@css"/>

  <xsl:template match="/">
    <xsl:apply-templates select="report"/>
  </xsl:template>

  <xsl:template match="report">
    <html lang="{(@lang|meta/lang)[1]}">
      <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <title><xsl:value-of select="meta/title"/></title>
        <link rel="stylesheet" href="{$theme-css}"/>
      </head>
      <body>
        <div class="newspaper">
          <xsl:apply-templates select="masthead"/>
          <xsl:apply-templates select="sections/section"/>
          <xsl:apply-templates select="footer"/>
        </div>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="masthead">
    <header class="masthead">
      <div class="masthead-meta">
        <span><xsl:value-of select="metaLeft"/></span>
        <span><xsl:value-of select="metaCenter"/></span>
        <span><xsl:value-of select="metaRight"/></span>
      </div>
      <h1><xsl:value-of select="title"/></h1>
      <div class="masthead-rule"></div>
      <div class="masthead-subtitle"><xsl:value-of select="subtitle"/></div>
      <xsl:apply-templates select="heroImage" mode="masthead"/>
      <div class="masthead-double"></div>
    </header>
  </xsl:template>

  <xsl:template match="heroImage" mode="masthead">
    <figure class="masthead-figure">
      <img src="{@src}" alt="{@alt}"/>
      <xsl:if test="@caption">
        <figcaption>
          <xsl:value-of select="@caption"/>
          <xsl:if test="@licenseUrl">
            <xsl:text> </xsl:text>
            <a class="license-link" href="{@licenseUrl}">
              <xsl:choose>
                <xsl:when test="@licenseLabel"><xsl:value-of select="@licenseLabel"/></xsl:when>
                <xsl:otherwise>Détails licence</xsl:otherwise>
              </xsl:choose>
            </a>
          </xsl:if>
        </figcaption>
      </xsl:if>
    </figure>
  </xsl:template>

  <xsl:template match="section">
    <xsl:choose>
      <xsl:when test="@header='break'">
        <div class="section-break">
          <div class="line"></div>
          <div class="label">
            <xsl:value-of select="concat(@title-fr, ' — ', @title-en)"/>
          </div>
          <div class="line"></div>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <div class="section-title">
          <xsl:value-of select="concat(@title-fr, ' — ', @title-en)"/>
        </div>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:apply-templates select="*" mode="block"/>
  </xsl:template>

  <xsl:template match="bilingual" mode="block">
    <div class="bilingual">
      <xsl:apply-templates select="column" mode="lang-column"/>
    </div>
  </xsl:template>

  <xsl:template match="column" mode="lang-column">
    <div class="lang-col">
      <xsl:if test="@label">
        <div class="lang-label"><xsl:value-of select="@label"/></div>
      </xsl:if>
      <xsl:apply-templates select="*" mode="inline-content"/>
    </div>
  </xsl:template>

  <xsl:template match="columns" mode="block">
    <div class="columns">
      <xsl:apply-templates select="column" mode="news-column"/>
    </div>
  </xsl:template>

  <xsl:template match="column" mode="news-column">
    <div>
      <xsl:attribute name="class">
        <xsl:text>col </xsl:text>
        <xsl:choose>
          <xsl:when test="@span='2'">col-2</xsl:when>
          <xsl:otherwise>col-1</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:apply-templates select="*" mode="inline-content"/>
    </div>
  </xsl:template>

  <xsl:template match="article" mode="inline-content">
    <xsl:if test="kicker"><div class="kicker"><xsl:value-of select="kicker"/></div></xsl:if>
    <xsl:if test="headline">
      <div>
        <xsl:attribute name="class">
          <xsl:text>article-title</xsl:text>
          <xsl:if test="@large='true'">
            <xsl:text> large</xsl:text>
          </xsl:if>
        </xsl:attribute>
        <xsl:value-of select="headline"/>
      </div>
    </xsl:if>
    <xsl:if test="byline"><div class="article-byline"><xsl:value-of select="byline"/></div></xsl:if>
    <xsl:apply-templates select="*" mode="article-content"/>
  </xsl:template>

  <xsl:template match="paragraph" mode="inline-content">
    <p>
      <xsl:if test="@dropcap='true'">
        <xsl:attribute name="class">dropcap</xsl:attribute>
      </xsl:if>
      <xsl:value-of select="."/>
    </p>
  </xsl:template>

  <xsl:template match="article/paragraph" mode="article-content">
    <p><xsl:value-of select="."/></p>
  </xsl:template>

  <xsl:template match="fr-en" mode="article-content">
    <p><strong>FR :</strong><xsl:text> </xsl:text><xsl:value-of select="fr"/></p>
    <p><strong>EN :</strong><xsl:text> </xsl:text><xsl:value-of select="en"/></p>
  </xsl:template>

  <xsl:template match="source" mode="article-content">
    <p>
      <em>Source :</em>
      <xsl:text> </xsl:text>
      <a href="{@href}"><xsl:value-of select="@label"/></a>
    </p>
  </xsl:template>

  <xsl:template match="sourceLine" mode="article-content">
    <p>
      <em><xsl:value-of select="@prefix"/> :</em>
      <xsl:text> </xsl:text>
      <xsl:for-each select="link">
        <a href="{@href}"><xsl:value-of select="@label"/></a>
        <xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
      </xsl:for-each>
    </p>
  </xsl:template>

  <xsl:template match="list" mode="article-content">
    <ul>
      <xsl:for-each select="item">
        <li>
          <xsl:choose>
            <xsl:when test="@href">
              <a href="{@href}"><xsl:value-of select="@title"/></a>
              <xsl:if test="string(.) != ''">
                <xsl:text> — </xsl:text>
                <xsl:value-of select="."/>
              </xsl:if>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="."/>
            </xsl:otherwise>
          </xsl:choose>
        </li>
      </xsl:for-each>
    </ul>
  </xsl:template>

  <xsl:template match="bilingualList" mode="article-content">
    <div class="bilingual" style="margin-top:10px;">
      <div class="lang-col">
        <xsl:if test="@label-fr"><div class="lang-label"><xsl:value-of select="@label-fr"/></div></xsl:if>
        <ul>
          <xsl:for-each select="item">
            <li><xsl:value-of select="fr"/></li>
          </xsl:for-each>
        </ul>
      </div>
      <div class="lang-col">
        <xsl:if test="@label-en"><div class="lang-label"><xsl:value-of select="@label-en"/></div></xsl:if>
        <ul>
          <xsl:for-each select="item">
            <li><xsl:value-of select="en"/></li>
          </xsl:for-each>
        </ul>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="image" mode="article-content">
    <figure>
      <xsl:attribute name="class">
        <xsl:text>article-figure</xsl:text>
        <xsl:if test="@align">
          <xsl:text> align-</xsl:text>
          <xsl:value-of select="@align"/>
        </xsl:if>
      </xsl:attribute>
      <img src="{@src}" alt="{@alt}"/>
      <xsl:if test="@caption">
        <figcaption>
          <xsl:value-of select="@caption"/>
          <xsl:if test="@licenseUrl">
            <xsl:text> </xsl:text>
            <a class="license-link" href="{@licenseUrl}">
              <xsl:choose>
                <xsl:when test="@licenseLabel"><xsl:value-of select="@licenseLabel"/></xsl:when>
                <xsl:otherwise>Détails licence</xsl:otherwise>
              </xsl:choose>
            </a>
          </xsl:if>
        </figcaption>
      </xsl:if>
    </figure>
  </xsl:template>

  <xsl:template match="image" mode="inline-content">
    <figure>
      <xsl:attribute name="class">
        <xsl:text>article-figure</xsl:text>
        <xsl:if test="@align">
          <xsl:text> align-</xsl:text>
          <xsl:value-of select="@align"/>
        </xsl:if>
      </xsl:attribute>
      <img src="{@src}" alt="{@alt}"/>
      <xsl:if test="@caption">
        <figcaption>
          <xsl:value-of select="@caption"/>
          <xsl:if test="@licenseUrl">
            <xsl:text> </xsl:text>
            <a class="license-link" href="{@licenseUrl}">
              <xsl:choose>
                <xsl:when test="@licenseLabel"><xsl:value-of select="@licenseLabel"/></xsl:when>
                <xsl:otherwise>Détails licence</xsl:otherwise>
              </xsl:choose>
            </a>
          </xsl:if>
        </figcaption>
      </xsl:if>
    </figure>
  </xsl:template>

  <xsl:template match="quote" mode="article-content">
    <div class="pull-quote">« <xsl:value-of select="."/> »</div>
  </xsl:template>

  <xsl:template match="box" mode="article-content">
    <div class="encadre">
      <div class="encadre-title"><xsl:value-of select="concat(@title-fr, ' / ', @title-en)"/></div>
      <xsl:if test="fr-en">
        <p><strong>FR :</strong> <xsl:value-of select="fr-en/fr"/></p>
        <p><strong>EN :</strong> <xsl:value-of select="fr-en/en"/></p>
      </xsl:if>
      <xsl:if test="source">
        <p><em>Source :</em> <a href="{source/@href}"><xsl:value-of select="source/@label"/></a></p>
      </xsl:if>
    </div>
  </xsl:template>

  <xsl:template match="resourceSplit" mode="block">
    <div class="hr"></div>
    <div class="bilingual">
      <xsl:for-each select="side">
        <div class="lang-col">
          <div class="lang-label"><xsl:value-of select="@label"/></div>
          <ul>
            <xsl:for-each select="item">
              <li>
                <a href="{@href}"><xsl:value-of select="@title"/></a>
                <xsl:text> — </xsl:text>
                <xsl:value-of select="."/>
              </li>
            </xsl:for-each>
          </ul>
        </div>
      </xsl:for-each>
    </div>
  </xsl:template>

  <xsl:template match="list" mode="inline-content">
    <ul>
      <xsl:for-each select="item">
        <li>
          <xsl:choose>
            <xsl:when test="@href">
              <a href="{@href}"><xsl:value-of select="@title"/></a>
              <xsl:if test="string(.) != ''">
                <xsl:text> — </xsl:text>
                <xsl:value-of select="."/>
              </xsl:if>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="."/>
            </xsl:otherwise>
          </xsl:choose>
        </li>
      </xsl:for-each>
    </ul>
  </xsl:template>

  <xsl:template match="bilingualList" mode="inline-content">
    <div class="bilingual" style="margin-top:10px;">
      <div class="lang-col">
        <xsl:if test="@label-fr"><div class="lang-label"><xsl:value-of select="@label-fr"/></div></xsl:if>
        <ul>
          <xsl:for-each select="item">
            <li><xsl:value-of select="fr"/></li>
          </xsl:for-each>
        </ul>
      </div>
      <div class="lang-col">
        <xsl:if test="@label-en"><div class="lang-label"><xsl:value-of select="@label-en"/></div></xsl:if>
        <ul>
          <xsl:for-each select="item">
            <li><xsl:value-of select="en"/></li>
          </xsl:for-each>
        </ul>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="hr" mode="block">
    <div class="hr"></div>
  </xsl:template>

  <xsl:template match="glossary" mode="block">
    <div class="glossary">
      <div class="glossary-header">
        <div class="glossary-term">Terme / Term</div>
        <div class="glossary-defs">
          <div class="glossary-def">Définition FR</div>
          <div class="glossary-def">Definition EN</div>
        </div>
      </div>
      <xsl:for-each select="entry">
        <div class="glossary-row">
          <div class="glossary-term"><xsl:value-of select="term"/></div>
          <div class="glossary-defs">
            <div class="glossary-def"><xsl:value-of select="fr"/></div>
            <div class="glossary-def"><xsl:value-of select="en"/></div>
          </div>
        </div>
      </xsl:for-each>
    </div>
  </xsl:template>

  <xsl:template match="footer">
    <div class="newspaper-footer">
      <p><strong><xsl:value-of select="line1/strong"/></strong> — <xsl:value-of select="line1/text()"/></p>
      <p style="margin-top:8px;font-size:0.78rem;"><xsl:value-of select="line2"/></p>
    </div>
  </xsl:template>

  <xsl:template match="text()" mode="inline-content"/>
  <xsl:template match="text()" mode="article-content"/>
  <xsl:template match="text()" mode="block"/>

</xsl:stylesheet>
