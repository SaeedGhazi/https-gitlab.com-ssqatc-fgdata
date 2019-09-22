<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:template match="/">
  <html>
  <body>
  <h2>Convert PUI -> Qt Dialog</h2>
  <div>
import QtQuick 2.12<br/>
import QtQuick.Layouts 1.12<br/>
import QtQuick.Controls 2.12<br/><br/>
import FlightGear 1.0<br/>
import org.flightgear.UI 1.0<br/>
import org.flightgear.Dialogs 1.0<br/><br/>

Item<br/>
{<br/>
    <xsl:apply-templates/>
}<br/>
  </div>
  </body>
  </html>
</xsl:template>

<xsl:template match="PropertyList">
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="radio">
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="layout[text()='vbox']">
    <br/>&#160;&#160;ColumnLayout {<br/>
    &#160;&#160;&#160;&#160;width: parent.width<br/>
    <!-- <xsl:apply-templates select="./following-sibling::*"/> -->
    &#160;&#160;} // ColumnLayout<br/>
</xsl:template>

<xsl:template match="layout[text()='hbox']">
    <br/>&#160;&#160;RowLayout {<br/>
    &#160;&#160;&#160;&#160;width: parent.width<br/>
    <!-- <xsl:apply-templates select="./following-sibling::*"/> -->
    &#160;&#160;} // RowLayout<br/>
</xsl:template>

<xsl:template match="layout[text()='table']">
    <br/>&#160;&#160;GridLayout {<br/>
    &#160;&#160;&#160;&#160;width: parent.width<br/>
    <!-- <xsl:apply-templates select="./following-sibling::*"/> -->
    &#160;&#160;} // GridLayout<br/>
</xsl:template>

<xsl:template match="x">
    &#160;&#160;x: <xsl:value-of select="."/><br/>
</xsl:template>

<xsl:template match="y">
    &#160;&#160;y: <xsl:value-of select="."/><br/>
</xsl:template>

<xsl:template match="width">
    &#160;&#160;width: <xsl:value-of select="."/><br/>
</xsl:template>

<xsl:template match="height">
    &#160;&#160;height: <xsl:value-of select="."/><br/>
</xsl:template>

<xsl:template match="border">
    &#160;&#160;// border*: <xsl:value-of select="."/><br/>
</xsl:template>

<xsl:template match="color">
    &#160;&#160;color:
    "#<xsl:call-template name="dectoHex"><xsl:with-param name="dec" select="./red * 255"/></xsl:call-template>
    <xsl:call-template name="dectoHex"><xsl:with-param name="dec" select="./green * 255"/></xsl:call-template>
    <xsl:call-template name="dectoHex"><xsl:with-param name="dec" select="./blue * 255"/></xsl:call-template>
    <xsl:call-template name="dectoHex"><xsl:with-param name="dec" select="./alpha * 255"/></xsl:call-template>"<br/>
</xsl:template>

<xsl:template match="font">
    &#160;&#160;// font*: <xsl:value-of select="."/><br/>
</xsl:template>
<xsl:template match="font/name">
    &#160;&#160;// name*: <xsl:value-of select="."/><br/>
</xsl:template>
<xsl:template match="font/size">
    &#160;&#160;// size*: <xsl:value-of select="."/><br/>
</xsl:template>
<xsl:template match="font/slant">
    &#160;&#160;// slant*: <xsl:value-of select="."/><br/>
</xsl:template>

<xsl:template match="legend">
    &#160;&#160;text: qsTr("<xsl:value-of select="."/>")<br/>
</xsl:template>

<xsl:template match="label">
    &#160;&#160;text: qsTr("<xsl:value-of select="."/>")<br/>
</xsl:template>

<xsl:template match="property">
    &#160;&#160;// property*: <xsl:value-of select="."/><br/>
</xsl:template>

<xsl:template match="binding">
    &#160;&#160;// binding*: "<xsl:value-of select="."/>"<br/>
</xsl:template>

<xsl:template match="keynum">
    &#160;&#160;// keynum*: <xsl:value-of select="."/><br/>
</xsl:template>

<xsl:template match="key">
    &#160;&#160;// key*: qsTr("<xsl:value-of select="."/>")<br/>
</xsl:template>

<xsl:template match="default">
    &#160;&#160;// default*: <xsl:value-of select="."/><br/>
</xsl:template>

<xsl:template match="visible">
    &#160;&#160;// visible*: <xsl:value-of select="."/><br/>
</xsl:template>

<xsl:template match="name">
    &#160;&#160;id: <xsl:value-of select="."/><br/>
</xsl:template>

<xsl:template match="modal">
    &#160;&#160;// modal*: <xsl:value-of select="."/><br/>
</xsl:template>

<xsl:template match="draggable">
    &#160;&#160;// draggable*: <xsl:value-of select="."/><br/>
</xsl:template>

<xsl:template match="resizable">
    &#160;&#160;// resizable*: <xsl:value-of select="."/><br/>
</xsl:template>

<xsl:template match="format">
    &#160;&#160;// format*: <xsl:value-of select="."/><br/>
</xsl:template>

<xsl:template match="live">
    &#160;&#160;// live*: <xsl:value-of select="."/><br/>
</xsl:template>

<xsl:template match="enabled">
    &#160;&#160;// enabled*: <xsl:value-of select="."/><br/>
</xsl:template>

<xsl:template match="nasal/open">
    <br/>&#160;&#160;ScriptOpen {<br/>
        <xsl:apply-templates select="child::*"/>
    &#160;&#160;}<br/>
</xsl:template>
<xsl:template match="nasal/close">
    <br/>&#160;&#160;ScriptClose {<br/>
        <xsl:apply-templates select="child::*"/>
    &#160;&#160;}<br/>
</xsl:template>

<xsl:template match="group">
    <br/>&#160;&#160;Item {<br/>
    &#160;&#160;&#160;&#160;Layout.fillWidth: true<br/>
        <xsl:apply-templates select="child::*"/>
    &#160;&#160;}<br/>
</xsl:template>

<xsl:template match="frame">
    <br/>&#160;&#160;GroupBox {<br/>
    &#160;&#160;&#160;&#160;Layout.fillWidth: true<br/>
        <xsl:apply-templates select="child::*"/>
    &#160;&#160;}<br/>
</xsl:template>

<xsl:template match="group-template">
    <br/>&#160;&#160;TableView {<br/>
    &#160;&#160;&#160;&#160;Layout.fillWidth: true<br/>
        <xsl:apply-templates select="child::*"/>
    &#160;&#160;}<br/>
</xsl:template>

<xsl:template match="input">
    <br/>&#160;&#160;TextInput {<br/>
        <xsl:apply-templates select="child::*"/>
    &#160;&#160;}<br/>
</xsl:template>

<xsl:template match="text">
    <br/>&#160;&#160;Label {<br/>
        <xsl:apply-templates select="child::*"/>
    &#160;&#160;}<br/>
</xsl:template>

<xsl:template match="textbox">
    <br/>&#160;&#160;Label {<br/>
        <xsl:apply-templates select="child::*"/>
    &#160;&#160;}<br/>
</xsl:template>

<xsl:template match="checkbox">
    <br/>&#160;&#160;CheckBox {<br/>
        <xsl:apply-templates select="child::*"/>
    &#160;&#160;}<br/>
</xsl:template>

<xsl:template match="button">
    <br/>&#160;&#160;Button {<br/>
        <xsl:apply-templates select="child::*"/>
    &#160;&#160;}<br/>
</xsl:template>

<xsl:template match="combo">
    <br/>&#160;&#160;ComboBox {<br/>
        <xsl:apply-templates/>
    &#160;&#160;}<br/>
</xsl:template>

<xsl:template match="list">
    <br/>&#160;&#160;ListView {<br/>
        <xsl:apply-templates/>
    &#160;&#160;}<br/>
</xsl:template>

<xsl:template match="select">
    <br/>&#160;&#160;ListView {<br/>
        <xsl:apply-templates/>
    &#160;&#160;}<br/>
</xsl:template>

<xsl:template match="slider">
    <br/>&#160;&#160;Slider {<br/>
        <xsl:apply-templates/>
    &#160;&#160;}<br/>
</xsl:template>

<xsl:template match="dial">
    <br/>&#160;&#160;Dial {<br/>
        <xsl:apply-templates/>
    &#160;&#160;}<br/>
</xsl:template>

<xsl:template match="hrule">
    <br/>&#160;&#160;Rectangle {<br/>
        &#160;&#160;&#160;&#160;width: parent.width<br/>
        &#160;&#160;&#160;&#160;height: 2<br/>
        &#160;&#160;&#160;&#160;color: "#DFAC01"<br/>
    &#160;&#160;}<br/>
</xsl:template>

<xsl:template match="vrule">
    <br/>&#160;&#160;Rectangle {<br/>
        width: 2<br/>
        height: parent.height<br/>
        color: "#DFAC01"<br/>
    &#160;&#160;}<br/>
</xsl:template>

<xsl:template match="empty">
    <br/>&#160;&#160;Label {<br/>
        <xsl:apply-templates select="child::*"/>
    &#160;&#160;}<br/>
</xsl:template>

<xsl:template match="pref-width">
    &#160;&#160;width: <xsl:value-of select="."/><br/>
</xsl:template>

<xsl:template match="pref-height">
    &#160;&#160;height: <xsl:value-of select="."/><br/>
</xsl:template>

<xsl:template match="default-padding">
    &#160;&#160;// padding*: <xsl:value-of select="."/><br/>
</xsl:template>

<xsl:template match="padding">
    &#160;&#160;padding: <xsl:value-of select="."/><br/>
</xsl:template>

<xsl:template match="list/value">
    &#160;&#160;currentIndex: <xsl:value-of select="."/><br/>
</xsl:template>

<xsl:template match="select/selection">
    &#160;&#160;model: <xsl:value-of select="."/><br/>
</xsl:template>

<xsl:template match="halign">
<xsl:choose>
    <xsl:when test="text()='left'">&#160;&#160;horizontalAlignment: Text.AlignLeft</xsl:when>
    <xsl:when test="text()='right'">&#160;&#160;horizontalAlignment: Text.AlignRight</xsl:when>
    <xsl:otherwise></xsl:otherwise>
</xsl:choose><br/>
</xsl:template>

<xsl:template match="valign">
<xsl:choose>
    <xsl:when test="text()='left'">&#160;&#160;verticalAlignment: Text.AlignTop</xsl:when>
    <xsl:when test="text()='right'">&#160;&#160;verticalAlignment: Text.AlignBottom</xsl:when>
    <xsl:otherwise></xsl:otherwise>
</xsl:choose><br/>
</xsl:template>

<xsl:template match="stretch">
    &#160;&#160;Layout.fillWidth: true<br/>
</xsl:template>

<xsl:template match="equal">
    &#160;&#160;// equal*: <xsl:value-of select="."/><br/>
</xsl:template>

<xsl:template match="*">
    <br/><font color="red"><xsl:copy/></font><br/>
</xsl:template>

<xsl:template name="dectoHex">
    <xsl:param name="dec"/>
    <xsl:variable name="hex-digits" select="'0123456789ABCDEF'"/>
    <xsl:variable name="low" select="$dec mod 16"/>
    <xsl:variable name="high" select="($dec - $low) div 16"/>
    <xsl:value-of select="substring($hex-digits, $high+1, 1)"/><xsl:value-of select="substring($hex-digits, $low+1, 1)"/>
</xsl:template>

</xsl:stylesheet>

