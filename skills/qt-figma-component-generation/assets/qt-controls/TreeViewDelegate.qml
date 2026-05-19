// Copyright (C) 2026 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
import QtQuick
import QtQuick.Templates as T
import Qt.Fonts as Fonts

T.TreeViewDelegate {
    id: control

    property int typeVariant: TreeViewDelegateStyle.TypeVariant.Primary
    property int sizeVariant: TreeViewDelegateStyle.SizeVariant.Base

    property TreeViewDelegateStyle.Type _type: {
        switch (control.typeVariant) {
            case TreeViewDelegateStyle.TypeVariant.Primary: return TreeViewDelegateStyle.primary

            default: return TreeViewDelegateStyle.primary
        }
    }

    property TreeViewDelegateStyle.Size _size: {
        switch (control.sizeVariant) {
            case TreeViewDelegateStyle.SizeVariant.Base: return TreeViewDelegateStyle.base

            default: return TreeViewDelegateStyle.base
        }
    }

    property TreeViewDelegateStyle.StateStyle _style: {
        if (control.enabled && !control.highlighted && !control.hovered)
            return control._type.idle
        else if (control.enabled && !control.highlighted && control.hovered)
            return control._type.hover
        else if (control.enabled && control.highlighted && control.hovered)
            return control._type.activeHover
        else if (control.enabled && control.highlighted)
            return control._type.active
        else if (!control.enabled)
            return control._type.disable

        return control._type.idle
    }

    implicitWidth: Math.max(leftMargin + __contentIndent + implicitContentWidth + rightPadding + rightMargin, 200)
    implicitHeight: implicitBackgroundHeight

    indentation: control._size.iconSize + control._size.spacing
    leftMargin: control._size.horizontalPadding
    rightMargin: control._size.horizontalPadding
    spacing: control._size.spacing

    leftPadding: control.leftMargin + control.__contentIndent

    highlighted: control.selected || control.current
               || ((control.treeView.selectionBehavior === TableView.SelectRows
               || control.treeView.selectionBehavior === TableView.SelectionDisabled)
               && control.row === control.treeView.currentRow)

    required property int row
    required property var model
    readonly property real __contentIndent: !isTreeNode ? 0 : (depth * indentation) + (indicator ? indicator.width + spacing : 0)

    indicator: Item {
        x: control.leftMargin + (control.depth * control.indentation)
        y: (control.height - height) / 2

        implicitWidth: control._size.iconSize
        implicitHeight: control._size.iconSize

        Text { // caret icon
            text: Fonts.FontInterface.icons.arrowHead_down_16
            color: control._style.caretIcon

            lineHeightMode: Text.FixedHeight
            lineHeight: control._size.lineHeight

            font {
                family: Fonts.FontInterface.iconFont.font.family
                pixelSize: control._size.iconSize
            }

            rotation: control.expanded ? 0 : -90
        }
    }

    background: Rectangle {
        implicitHeight: control._size.lineHeight + (control._size.verticalPadding * 2)
        color: control._style.background
        border.width: 0
    }

    contentItem: Row {
        height: control.implicitBackgroundHeight
        spacing: control._size.spacing

        Text { // node icon
            text: control.model.decoration
            color: control._style.nodeIcon

            lineHeightMode: Text.FixedHeight
            lineHeight: control._size.lineHeight

            font {
                family: Fonts.FontInterface.iconFont.font.family
                pixelSize: control._size.iconSize
            }
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: control.model.display
            color: control._style.text

            clip: false
            elide: Text.ElideRight
            textFormat: Text.PlainText
            lineHeightMode: Text.FixedHeight
            lineHeight: control._size.lineHeight

            font {
                family: Fonts.FontInterface.interFont.font.family
                pixelSize: control._size.fontSize
                variableAxes: {
                    "wght": control._size.fontWeight
                }
            }

            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
