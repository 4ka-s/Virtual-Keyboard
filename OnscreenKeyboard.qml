import Quickshell
import Quickshell.Io
import QtQuick

ShellRoot {
    PanelWindow {
        id: keyboardWindow
        
        anchors {
            bottom: true
            left: isPinned? false : true
        }

        property int dragOffsetX: (Screen.width/2)-keyboardContainer.width/2
        property int dragOffsetY: 10

        margins {
            bottom: dragOffsetY
            left: dragOffsetX
        }
        
        implicitWidth: keyboardContainer.width
        implicitHeight: keyboardContainer.height+10
        
        exclusionMode: isPinned ? ExclusionMode.Auto : ExclusionMode.Ignore

        property bool isPinned: false
        
        property real keyboardOpacity: 0.95
        
        color: "transparent"
        
        // Centered keyboard container
        Rectangle {
            id: keyboardContainer
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
            }
            
            width: 1232
            height: 400
            color: "#131313"
            opacity: keyboardWindow.keyboardOpacity
            radius: 25
            
            Row {
                id: mainRow
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: parent.top
                    topMargin: 15
                }
                spacing: 0
                
                // Pin button column on far left
                Item {
                    width: 60
                    height: keyboardContainer.height
                    
                    Column {
                        anchors.centerIn: parent
                        spacing: 10
                        
                        // Pin button
                        Rectangle {
                            id: pinButton
                            width: 40
                            height: 40
                            radius: 20
                            color: keyboardWindow.isPinned ? "#D5C1A8" : "#181818"
                            
                            Text {
                                anchors.centerIn: parent
                                text: "📌"
                                font.pixelSize: 20
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    keyboardWindow.isPinned = !keyboardWindow.isPinned
                                    console.log("Pin toggled:", keyboardWindow.isPinned ? "Pinned (pushes windows)" : "Unpinned (overlay)")

                                    keyboardWindow.dragOffsetX= (Screen.width/2)-(keyboardContainer.width/2)
                                    keyboardWindow.dragOffsetY= 10                                
                                }
                            }
                        }
                        
                        // Drag handle button
                        Rectangle {
                            id: dragHandle
                            width: 40
                            height: 40
                            radius: 20
                            color: dragArea.pressed ? "#8C7853" : "#181818"
                            opacity: keyboardWindow.isPinned ? 0.3 : 1.0
                            
                            Text {
                                anchors.centerIn: parent
                                text: "⋮⋮"
                                font.pixelSize: 20
                                color: "#8F8F8F"
                                rotation: 90
                            }
                            
                            MouseArea {
                                id: dragArea
                                anchors.fill: parent
                                cursorShape: keyboardWindow.isPinned ? Qt.ForbiddenCursor : Qt.DragMoveCursor
                                enabled: !keyboardWindow.isPinned
                                
                                property point lastPos: Qt.point(0, 0)
                                
                                onPressed: {
                                    lastPos = Qt.point(mouse.x, mouse.y)
                                }
                                
                                onPositionChanged: {
                                    console.log("Mouse position: x=" + mouse.x + ", y=" + mouse.y)

                                    var dx = mouse.x - lastPos.x
                                    var dy = mouse.y - lastPos.y
                                    keyboardWindow.dragOffsetX += dx
                                    keyboardWindow.dragOffsetY -= dy
                                    lastPos = Qt.point(mouse.x, mouse.y)
                                }
                            }
                        }
                    }
                }
                
                // Separator
                Rectangle {
                    width: 2
                    height: keyboardContainer.height * 0.8
                    color: "#8F8F8F"
                    opacity: 0.5
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: -10
                }
                
                // Main keyboard
                Column {
                    width: 1170
                    height: keyboardContainer.height
                    spacing: 5
                    
                    Item { height: 10 }
                    
                    // Row 1: Numbers (or Function keys when Fn is active)
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 5
                        
                        Key {
                            keyText: "Esc"
                            keyCode: "Escape"
                            keyWidth: 75
                            isSpecial: true
                        }
                        
                        Repeater {
                            model: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "="]
                            Key {
                                keyText: modelData
                                keyCode: modifierState.fnPressed ? getFnKeyCode(modelData) : modelData
                                keyWidth: 75
                                
                                displayOverride: modifierState.fnPressed ? getFnKeyCode(modelData) : ""
                                
                                function getFnKeyCode(num) {
                                    var fnMap = {
                                        "1": "F1", "2": "F2", "3": "F3", "4": "F4", "5": "F5",
                                        "6": "F6", "7": "F7", "8": "F8", "9": "F9", "0": "F10",
                                        "-": "F11", "=": "F12"
                                    }
                                    return fnMap[num] || num
                                }
                            }
                        }
                        
                        Key {
                            keyText: "⌫"
                            keyCode: "BackSpace"
                            keyWidth: 100
                            isSpecial: true
                        }
                    }
                    
                    // Row 2: QWERTY
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 5
                        
                        Key {
                            keyText: "Tab"
                            keyCode: "Tab"
                            keyWidth: 100
                            isSpecial: true
                        }
                        
                        Repeater {
                            model: ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p", "[", "]"]
                            Key {
                                keyText: modelData
                                keyWidth: 75
                            }
                        }
                        
                        Key {
                            keyText: "\\"
                            keyWidth: 75
                        }
                    }
                    
                    // Row 3: ASDFGH
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.horizontalCenterOffset: 62
                        spacing: 5
                        
                        Repeater {
                            model: ["a", "s", "d", "f", "g", "h", "j", "k", "l", ";", "'"]
                            Key {
                                keyText: modelData
                                keyWidth: 75
                            }
                        }
                        
                        Key {
                            keyText: "Enter"
                            keyCode: "Return"
                            keyWidth: 130
                            isSpecial: true
                        }
                    }
                    
                    // Row 4: ZXCVBN
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 5
                        
                        Key {
                            keyText: "Shift"
                            keyCode: "Shift_L"
                            keyWidth: 150
                            isSpecial: true
                            isModifier: true
                        }
                        
                        Repeater {
                            model: ["z", "x", "c", "v", "b", "n", "m", ",", ".", "/"]
                            Key {
                                keyText: modelData
                                keyWidth: 75
                            }
                        }
                        
                        Key {
                            keyText: "Shift"
                            keyCode: "Shift_R"
                            keyWidth: 150
                            isSpecial: true
                            isModifier: true
                        }
                    }
                    
                    // Row 5: Bottom row
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 5
                        
                        Key {
                            keyText: "Fn"
                            keyCode: "Fn"
                            keyWidth: 80
                            isSpecial: true
                            isModifier: true
                        }
                        
                        Key {
                            keyText: "Ctrl"
                            keyCode: "Control_L"
                            keyWidth: 80
                            isSpecial: true
                            isModifier: true
                        }
                        
                        Key {
                            keyText: "Alt"
                            keyCode: "Alt_L"
                            keyWidth: 100
                            isSpecial: true
                            isModifier: true
                        }
                        
                        Key {
                            keyText: "Space"
                            keyCode: "space"
                            keyWidth: 480
                            isSpecial: true
                        }
                        
                        Key {
                            keyText: "Alt"
                            keyCode: "Alt_R"
                            keyWidth: 100
                            isSpecial: true
                            isModifier: true
                        }
                        
                        Key {
                            keyText: "Ctrl"
                            keyCode: "Control_R"
                            keyWidth: 100
                            isSpecial: true
                            isModifier: true
                        }
                    }
                }
            }
        }
    }
    
    // Global state for modifiers
    QtObject {
        id: modifierState
        property bool shiftPressed: false
        property bool ctrlPressed: false
        property bool altPressed: false
        property bool fnPressed: false
        
        function getActiveModifiers() {
            var mods = []
            if (shiftPressed) mods.push("Shift_L")
            if (ctrlPressed) mods.push("Control_L")
            if (altPressed) mods.push("Alt_L")
            return mods
        }
    }
    
    // Reusable Key button
    component Key: Rectangle {
        property string keyText: ""
        property string keyCode: keyText
        property int keyWidth: 80
        property bool isSpecial: false
        property bool isModifier: false
        property string displayOverride: ""
        property bool isActive: {
            if (keyCode === "Shift_L" || keyCode === "Shift_R") return modifierState.shiftPressed
            if (keyCode === "Control_L" || keyCode === "Control_R") return modifierState.ctrlPressed
            if (keyCode === "Alt_L" || keyCode === "Alt_R") return modifierState.altPressed
            if (keyCode === "Fn") return modifierState.fnPressed
            return false
        }
        
        // Get display text based on modifiers
        property string displayText: {
            if (displayOverride !== "") return displayOverride
            
            if (!modifierState.shiftPressed) return keyText
            
            var shiftMap = {
                "`": "~",
                "1": "!", "2": "@", "3": "#", "4": "$", "5": "%",
                "6": "^", "7": "&", "8": "*", "9": "(", "0": ")",
                "-": "_", "=": "+", "[": "{", "]": "}",
                ";": ":", "'": '"', ",": "<", ".": ">", "/": "?",
                "\\": "|",
                "q": "Q", "w": "W", "e": "E", "r": "R", "t": "T",
                "y": "Y", "u": "U", "i": "I", "o": "O", "p": "P",
                "a": "A", "s": "S", "d": "D", "f": "F", "g": "G",
                "h": "H", "j": "J", "k": "K", "l": "L",
                "z": "Z", "x": "X", "c": "C", "v": "V", "b": "B",
                "n": "N", "m": "M"
            }
            
            return shiftMap[keyText] || keyText
        }
        
        width: keyWidth
        height: 70
        radius: 25
        
        color: {
            if (mouseArea.pressed) return "#8C7853"
            if (isActive) return "#D5C1A8"
            return "#181818"
        }
        border.color: isActive ? "#9EF0FC80" : "#4A5551"
        border.width: isActive ? 0 : 0
        
        Text {
            anchors.centerIn: parent
            text: parent.displayText
            color: {
                if (isActive) return "#000000"
                return "#8F8F8F"
            }
            font.pixelSize: isSpecial ? 20 : 20
            font.bold: false
        }
        
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            
            onClicked: {
                if (isModifier) {
                    if (keyCode === "Shift_L" || keyCode === "Shift_R") {
                        modifierState.shiftPressed = !modifierState.shiftPressed
                        keyboardInput.toggleModifier(keyCode, modifierState.shiftPressed)
                    } else if (keyCode === "Control_L" || keyCode === "Control_R") {
                        modifierState.ctrlPressed = !modifierState.ctrlPressed
                        keyboardInput.toggleModifier(keyCode, modifierState.ctrlPressed)
                    } else if (keyCode === "Alt_L" || keyCode === "Alt_R") {
                        modifierState.altPressed = !modifierState.altPressed
                        keyboardInput.toggleModifier(keyCode, modifierState.altPressed)
                    } else if (keyCode === "Fn") {
                        modifierState.fnPressed = !modifierState.fnPressed
                    }
                } else {
                    keyboardInput.sendKey(keyCode)
                }
            }
        }
    }
    
    // Keyboard input handler
    Item {
        id: keyboardInput
        
        function toggleModifier(keyText, pressed) {
            var keyCode = getKeyCode(keyText)
            if (keyCode === undefined) return
            
            console.log("Modifier", keyText, pressed ? "pressed" : "released")
            
            if (pressed) {
                var proc = keyProcess.createObject(keyboardInput)
                proc.command = ["ydotool", "key", keyCode + ":1"]
                proc.running = true
            } else {
                var proc = keyProcess.createObject(keyboardInput)
                proc.command = ["ydotool", "key", keyCode + ":0"]
                proc.running = true
            }
        }
        
        function sendKey(keyText) {
            var keyCode = getKeyCode(keyText)
            if (keyCode === undefined) {
                console.log("Unknown key:", keyText)
                return
            }
            
            var activeModifiers = modifierState.getActiveModifiers()
            console.log("Sending key:", keyText, "with modifiers:", activeModifiers)
            
            var pressProc = keyProcess.createObject(keyboardInput)
            pressProc.command = ["ydotool", "key", keyCode + ":1"]
            pressProc.running = true
            
            var releaseProc = keyProcess.createObject(keyboardInput)
            releaseProc.command = ["sh", "-c", "sleep 0.05 && ydotool key " + keyCode + ":0"]
            releaseProc.running = true
        }
        
        function getKeyCode(keyText) {
            var keyCodeMap = {
                "F1": 59, "F2": 60, "F3": 61, "F4": 62, "F5": 63,
                "F6": 64, "F7": 65, "F8": 66, "F9": 67, "F10": 68,
                "F11": 87, "F12": 88,
                "Print": 99, "Delete": 111,
                "`": 41,
                "1": 2, "2": 3, "3": 4, "4": 5, "5": 6,
                "6": 7, "7": 8, "8": 9, "9": 10, "0": 11,
                "-": 12, "=": 13,
                "q": 16, "w": 17, "e": 18, "r": 19, "t": 20,
                "y": 21, "u": 22, "i": 23, "o": 24, "p": 25,
                "[": 26, "]": 27, "\\": 43,
                "a": 30, "s": 31, "d": 32, "f": 33, "g": 34,
                "h": 35, "j": 36, "k": 37, "l": 38,
                ";": 39, "'": 40,
                "z": 44, "x": 45, "c": 46, "v": 47, "b": 48,
                "n": 49, "m": 50, ",": 51, ".": 52, "/": 53,
                "BackSpace": 14,
                "Return": 28,
                "Control_L": 29,
                "Control_R": 97,
                "Shift_L": 42,
                "Shift_R": 54,
                "Alt_L": 56,
                "Alt_R": 100,
                "space": 57,
                "Escape": 1,
                "Tab": 15,
            }
            
            return keyCodeMap[keyText]
        }
    }
    
    Component {
        id: keyProcess
        Process {
            onExited: function(exitCode) {
                if (exitCode !== 0) {
                    console.log("ydotool error, exit code:", exitCode)
                }
                destroy()
            }
        }
    }
}