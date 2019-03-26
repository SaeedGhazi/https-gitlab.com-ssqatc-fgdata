pragma Singleton
import QtQml 2.4

QtObject {
    property string searchTerm: ""
    readonly property bool isActive: searchTerm != ""
}

