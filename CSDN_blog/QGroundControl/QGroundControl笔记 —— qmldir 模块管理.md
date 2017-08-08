> `by luoshi006`
> 欢迎交流~ 个人 Gitter 交流平台，点击直达： [![Join the chat at https://gitter.im/luoshi006_communication/Lobby](https://badges.gitter.im/luoshi006_communication/Lobby.svg)](https://gitter.im/luoshi006_communication/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

<hr>

> 参考：http://blog.csdn.net/qyvlik/article/details/44758509、http://blog.csdn.net/king523103/article/details/45198589



qmldir文件，用于qml模块化管理。

这里的模块化包括

- c++扩展的模块
- 纯qml拓展的模块

本章以 `\src\FlightMap\qmldir` 为例，讲解 qmldir 的使用方法。

首先是模块的调用：
```
//\src\FlightDisplay\FlightDisplayView.qml
import QGroundControl.FlightMap     1.0
```

qmldir 文件需要在生成可执行文件时，拷贝到程序相同目录中，在生成文件中未找到对应 FlightMap 的 qmldir 文件，疑似通过资源文件整合。

**qmldir 文件源码：**

```shell
Module QGroundControl.FlightMap
# module 后面的那个单词就是模块名，一般与qmldir文件所处文件夹同名  


# Main view controls
FlightMap               1.0 FlightMap.qml
QGCVideoBackground      1.0 QGCVideoBackground.qml
# 说明一个自定义控件的名字，再指定版本号，最后指定对应的qml文件  

# Widgets
InstrumentSwipeView             1.0 InstrumentSwipeView.qml
MapScale                        1.0 MapScale.qml
QGCArtificialHorizon            1.0 QGCArtificialHorizon.qml
QGCAttitudeHUD                  1.0 QGCAttitudeHUD.qml
QGCAttitudeWidget               1.0 QGCAttitudeWidget.qml
QGCCompassWidget                1.0 QGCCompassWidget.qml
QGCInstrumentWidget             1.0 QGCInstrumentWidget.qml
QGCInstrumentWidgetAlternate    1.0 QGCInstrumentWidgetAlternate.qml
QGCPitchIndicator               1.0 QGCPitchIndicator.qml
QGCSlider                       1.0 QGCSlider.qml
ValuesWidget                    1.0 ValuesWidget.qml
VibrationWidget                 1.0 VibrationWidget.qml

# Map items
MissionItemIndicator    1.0 MissionItemIndicator.qml
MissionItemView         1.0 MissionItemView.qml
MissionLineView         1.0 MissionLineView.qml
VehicleMapItem          1.0 VehicleMapItem.qml
```

同时支持一下信息添加：

- 导入描述信息
      `typeinfo mymodule.qmltypes`

- 依赖文件
      `depend MyOtherModule 1.0`


更多信息请访问，Qt help ： `Module Definition qmldir Files`