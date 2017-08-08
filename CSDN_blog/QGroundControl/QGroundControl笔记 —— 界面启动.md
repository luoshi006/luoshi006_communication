>`by luoshi006`
> 欢迎交流~ 个人 Gitter 交流平台，点击直达： [![Join the chat at https://gitter.im/luoshi006_communication/Lobby](https://badges.gitter.im/luoshi006_communication/Lobby.svg)](https://gitter.im/luoshi006_communication/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)


# 界面启动描述

QGroundControl 的启动由 `main()` 函数开始，调用 `QGCApplication::_initForNormalAppBoot()` 再由 `MainWindow::_create()` 调用 `MainWindow()` 构造函数，完成界面的启动。

界面的启动由主界面读入 QML 源文档开始：`"qrc:qml/MainWindowHybrid.qml"`

# 主要相关文件

`\src\ui\MainWindowHybrid.qml`
`\src\ui\MainWindowInner.qml`
`\src\MissionEditor\MissionEditor.qml`
`\src\VehicleSetup\SetupView.qml`
`\src\ui\MainWindowLeftPanel.qml`
`\src\FlightDisplay\FlightDisplayView.qml`
`\src\ui\toolbar\MainToolBar.qml`
`\src\ui\toolbar\MainToolBarIndicators.qml`


# MainWindowHybrid.qml

首先，载入目标界面文件：

```ruby
    Loader {
        id:             mainWindowInner
        anchors.fill:   parent
        source:         "MainWindowInner.qml"

        Connections {
            target: mainWindowInner.item

            onReallyClose: controller.reallyClose()
        }
    }
```

执行界面显示：

```
    function showFlyView() 
    function showPlanView() 
    function showSetupView() 
    function attemptWindowClose() 

    // The following are use for unit testing only

    function showSetupFirmware() 
    function showSetupParameters() 
    function showSetupSummary() 
    function showSetupVehicleComponent(vehicleComponent)
    function showMessage(message)
```

# MainWindowInner.qml

这里的内容较为驳杂，只介绍界面显示相关的内容。

建议阅读 `QML` 文档之前，首先了解 `Qt Quick` 的相关内容，或者有 `JavaScript` 开发经验。

首先，定义了几个主界面的源文档位置：

```
    readonly property string _planViewSource:       "MissionEditor.qml"
    readonly property string _setupViewSource:      "SetupView.qml"
    readonly property string _preferencesSource:    "MainWindowLeftPanel.qml"
```

`currentPopUp` 是主界面中的临时界面，如消息提示框等，再刷新界面时，自动消失。

几大界面的切换函数（以显示飞行界面为例）：

```
        preferencesPanel.visible    = false
        flightView.visible          = true
        setupViewLoader.visible     = false
        planViewLoader.visible      = false
        toolBar.checkFlyButton()
```

其中，飞行界面（flightView）定义于 `\src\FlightDisplay\FlightDisplayView.qml`

# MainToolBar

<center>![这里写图片描述](http://img.blog.csdn.net/20160912110258977)</center>

工具栏采用 横向排列（Row） 布局。

```josn
    Row {
        id:                     viewRow
        height:                 mainWindow.tbCellHeight
        spacing:                mainWindow.tbSpacing
        anchors.left:           parent.left
        anchors.bottomMargin:   1
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom

        ExclusiveGroup { id: mainActionGroup }

        QGCToolBarButton {
            id:                 preferencesButton
            width:              mainWindow.tbButtonWidth
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            exclusiveGroup:     mainActionGroup
            source:             "/res/QGCLogoWhite"
            logo:               true
            onClicked:          toolBar.showPreferences()
        }

        QGCToolBarButton {
            id:                 setupButton
            width:              mainWindow.tbButtonWidth
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            exclusiveGroup:     mainActionGroup
            source:             "/qmlimages/Gears.svg"
            onClicked:          toolBar.showSetupView()
        }

        QGCToolBarButton {
            id:                 planButton
            width:              mainWindow.tbButtonWidth
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            exclusiveGroup:     mainActionGroup
            source:             "/qmlimages/Plan.svg"
            onClicked:          toolBar.showPlanView()
        }

        QGCToolBarButton {
            id:                 flyButton
            width:              mainWindow.tbButtonWidth
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            exclusiveGroup:     mainActionGroup
            source:             "/qmlimages/PaperPlane.svg"
            onClicked:          toolBar.showFlyView()
        }
    }
```

工具栏右侧分别是：GPS 信息、RC 、数传、电池、飞行模式；这些指示符显示，定义于文件：`MainToolBarIndicators.qml`

那条长长的进度条。。。。

```
    Rectangle {
        id:             progressBar
        anchors.bottom: parent.bottom
        height:         toolBar.height * 0.05
        width:          parent.width * _controller.progressBarValue
        color:          colorGreen
    }
```

