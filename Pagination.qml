import QtQuick 2.0

Rectangle {
    id: root
    property int total: 50
    property int pageIndex: 10
    
    anchors.verticalCenter: parent.verticalCenter
    width: pagination.width; height: 50
    color: "lightblue"
    
    property int itemWidth: 40
    property int itemHeight: 40
    property int itemSpacing: 10
    property int itemRadius: 5
    
    property Component menu: 
    Rectangle {
        id: menuRoot
        property alias text: indication.text
        signal clicked()
        
        width: root.itemWidth
        height: root.itemHeight
        radius: root.itemRadius
        border.color: mouseArea.hover ? "#1890ff" : "#d9d9d9"
        border.width: 1
        
      //  Image {
      //      anchors.centerIn: parent
      //      sourceSize: Qt.size(30, 30)
      //      antialiasing: true
      //      source: "data:image/svg+xml;base64,PHN2ZyB2aWV3Qm94PSI2NCA2NCA\
      //      4OTYgODk2IiBmb2N1c2FibGU9ImZhbHNlIiBkYXRhLWljb249InJpZ2h0IiB3a\
      //      WR0aD0iMWVtIiBoZWlnaHQ9IjFlbSIgZmlsbD0iY3VycmVudENvbG9yIiBhcml\
      //      hLWhpZGRlbj0idHJ1ZSI+PHBhdGggZD0iTTc2NS43IDQ4Ni44TDMxNC45IDEzN\
      //      C43QTcuOTcgNy45NyAwIDAwMzAyIDE0MXY3Ny4zYzAgNC45IDIuMyA5LjYgNi4\
      //      xIDEyLjZsMzYwIDI4MS4xLTM2MCAyODEuMWMtMy45IDMtNi4xIDcuNy02LjEgM\
      //      TIuNlY4ODNjMCA2LjcgNy43IDEwLjQgMTIuOSA2LjNsNDUwLjgtMzUyLjFhMzE\
      //      uOTYgMzEuOTYgMCAwMDAtNTAuNHoiPjwvcGF0aD48L3N2Zz4="
      //  }
        
        Text {
            id: indication
            anchors.centerIn: parent
            text: "<"
            color: mouseArea.hover ? parent.border.color : "black"
        }
        
        MouseArea {
            id: mouseArea
            property bool hover: false
            anchors.fill: parent
            hoverEnabled: true
            onEntered: hover = true
            onExited: hover = false
            onClicked: menuRoot.clicked()
        }
    }
    
    property Component item:
    Rectangle {
        id: rootItem
        property string text: ""
        property bool isSelected: false
    
        signal numberClicked(int number)
        signal leftMoreClicked()
        signal rightMoreClicked()
        
        width: root.itemWidth
        height: root.itemHeight
        radius: root.itemRadius
        border.color: rootItem.isSelected || mouseArea.hover ? "#1890ff" : "#d9d9d9"
        border.width: 1
        
        Text {
            id: itemText
            anchors.centerIn: parent
            color: rootItem.isSelected || mouseArea.hover ? parent.border.color : "black"
            text: isNumber(rootItem.text) ? rootItem.text : 
                                            (mouseArea.hover ? rootItem.text : "...")

            function isNumber(val) {
                return parseFloat(val).toString() != "NaN"
            }
        }
        
        MouseArea {
            id: mouseArea
            property bool hover: false
            anchors.fill: parent
            hoverEnabled: true
            onEntered: hover = true
            onExited: hover = false
            onClicked: {
                if (text === ">>") {
                    rootItem.rightMoreClicked()
                }
                else if (text == "<<") {
                    rootItem.leftMoreClicked()
                }
                else {
                    rootItem.numberClicked(text)
                }
            }
        }
    }
    
    property Component selection:
    Row {
        property variant listModel
        signal numberClicked(int number)
        signal leftMoreClicked()
        signal rightMoreClicked()
        
        spacing: root.itemSpacing
        Repeater {
            id: repeater
            model: listModel
            
            Loader {
                sourceComponent: root.item
                Component.onCompleted: {
                    item.text = Qt.binding(function() { return index })
                    item.isSelected = Qt.binding(function() { return root.pageIndex === Number(index) })
                    
                    item.rightMoreClicked.connect(rightMoreClicked)
                    item.leftMoreClicked.connect(leftMoreClicked)
                    item.numberClicked.connect(numberClicked)
                }
            }
        }
    }
    
    ListModel {
        id: listModel
        
        function createOne(index, isCurrentIndex=false) {
            listModel.append({"index": String(index)})
        }
        
        function update(total, currentIndex) {
            listModel.clear()
            if (total <= 6) {
                for (var i = 1; i <= 6; i++) {
                    createOne(i)
                }
                
                return
            }
            
            // do something
            if (currentIndex <= 5) {
                for (var i = 1; i <= 5; i++) {
                    createOne(i)
                }
                createOne(">>")
                createOne(String(total))
            }
            else if (currentIndex >= total - 5) {
                createOne(String(1))
                createOne("<<")
                for (var i = total - 5; i <= total; i++) {
                    createOne(i)
                }
            }
            else {
                createOne(String(1))
                createOne("<<")
                for (var i = -2; i < 3; i++) {
                    createOne(currentIndex + i)
                }
                createOne(">>")
                createOne(String(total))
            }
        }
    }
    
    Row {
        id: pagination
        height: root.height
        spacing: root.itemSpacing
        
        Loader {
            anchors.verticalCenter: parent.verticalCenter
            sourceComponent: menu
            Component.onCompleted: {
                item.text = "<"
                item.clicked.connect(function() { 
                    if (root.pageIndex <= 1)
                        return
                        
                    listModel.update(total, root.pageIndex - 1)
                    root.pageIndex -= 1 
                })
            }
        }
        
        Loader {
            id: content
            anchors.verticalCenter: parent.verticalCenter
            sourceComponent: selection
            Component.onCompleted: {
                listModel.update(total, pageIndex)
                item.listModel = Qt.binding(function() { return listModel })
                item.rightMoreClicked.connect(function() {
                    listModel.update(total, root.pageIndex + 3)
                    root.pageIndex += 3 
                })
                
                item.leftMoreClicked.connect(function() {
                    listModel.update(total, root.pageIndex - 3)
                    root.pageIndex -= 3 
                }) 
                
                item.numberClicked.connect(function(number) {
                    listModel.update(total, number)
                    root.pageIndex = number
                })  
            }
        }
        
        Loader {
            id: rightIndication
            anchors.verticalCenter: parent.verticalCenter
            sourceComponent: menu
            Component.onCompleted: {
                rightIndication.item.text = ">"
                item.clicked.connect(function() { 
                    if (root.pageIndex >= total)
                        return
                        
                    listModel.update(total, root.pageIndex + 1)
                    root.pageIndex += 1 
                })
                
            }
        }
    }
}