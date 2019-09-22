<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:template match="/">
  <html>
  <body>
  <h2>Convert PUI -> Qt Menu</h2>
  <div>
import QtQuick 2.12<br/>
import QtQuick.Layouts 1.12<br/>
import QtQuick.Controls 2.12<br/><br/>

ApplicationWindow {<br/>
    width: 1024<br/>
    height: 800<br/><br/>
    menuBar: MenuBar<br/>
{<br/>
    <xsl:apply-templates/>
}<br/>
}<br/>
  </div>
  </body>
  </html>
</xsl:template>

<xsl:template match="PropertyList">
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="menu">
    Menu {<br/>
    <xsl:apply-templates/>
    }<br/>
</xsl:template>

<xsl:template match="menu/name">
    title: "<xsl:value-of select="."/>"<br/>
</xsl:template>

<xsl:template match="item">
    MenuItem {<br/>
    <xsl:apply-templates/>
    }<br/>
</xsl:template>

<xsl:template match="item/name">
    id: <xsl:value-of select="translate(.,'-','_')"/><br/>
</xsl:template>

<xsl:template match="item/label">
    text: "<xsl:value-of select="."/>"<br/>
</xsl:template>

<xsl:template match="item/key">
    // shortcut: "<xsl:value-of select="."/>"<br/>
</xsl:template>

<xsl:template match="item/enabled">
    enabled: <xsl:value-of select="."/><br/>
</xsl:template>

<xsl:template match="item/binding">
    onTriggered: {<br/>
    <xsl:apply-templates/>
    }<br/>
</xsl:template>

<xsl:template match="item/binding/script">
    // script -> <xsl:value-of select="."/><br/>
</xsl:template>

<xsl:template match="item/binding/command">
    // command -> <xsl:value-of select="."/><br/>
</xsl:template>

<xsl:template match="item/binding/dialog-name">
    // dialog -> <xsl:value-of select="."/><br/>
</xsl:template>

<xsl:template match="item/binding/property">
    // property -> <xsl:value-of select="."/><br/>
</xsl:template>

<xsl:template match="item/binding/value">
    // value -> <xsl:value-of select="."/><br/>
</xsl:template>

<xsl:template match="item/binding/min">
    // min -> <xsl:value-of select="."/><br/>
</xsl:template>

<xsl:template match="item/binding/max">
    // max -> <xsl:value-of select="."/><br/>
</xsl:template>

<xsl:template match="item/binding/subsystem">
    // subsystem -> <xsl:value-of select="."/><br/>
</xsl:template>

<xsl:template match="item/binding/step">
    // step -> <xsl:value-of select="."/><br/>
</xsl:template>

<xsl:template match="item/binding/path">
    // path -> <xsl:value-of select="."/><br/>
</xsl:template>

<!-- <xsl:template match="item/binding//command[text()='dialog-show']/sibling::dialog-name">
    onTriggered: <xsl:value-of select="."/>.show()<br/>
</xsl:template> -->

</xsl:stylesheet>

