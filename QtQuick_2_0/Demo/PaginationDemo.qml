import QtQuick 2.0
import "../"

Rectangle {
    width: 640
    height: 480

    Pagination {
//        anchors.centerIn: parent
        total: 50
        pageIndex: 20
    }
}
