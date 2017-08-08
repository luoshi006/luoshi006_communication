> <font color=F0aFaF>by luoshi006</font>
> 欢迎交流~ 个人 Gitter 交流平台，点击直达： [![Join the chat at https://gitter.im/luoshi006_communication/Lobby](https://badges.gitter.im/luoshi006_communication/Lobby.svg)](https://gitter.im/luoshi006_communication/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

`QGCToolbox` 用于管理所有的顶层服务、工具。

文件` \qgroundcontrol\src\QGCToolbox.h` 中定义了两个类，分别是 `QGCTool` 和 `QGCToolbox`

`QGCTool` 的作用类似于 抽象类，用于各个工具的继承，主要实现 `setToolbox` 函数。

# 构造函数
 
 在 `QGCApplication` 的构造函数最后调用。

```cpp
QGCToolbox::QGCToolbox(QGCApplication* app)
    : _audioOutput(NULL)
    , _autopilotPluginManager(NULL)
    , _factSystem(NULL)
    , _firmwarePluginManager(NULL)
    , _flightMapSettings(NULL)
    , _homePositionManager(NULL)
    , _imageProvider(NULL)
    , _joystickManager(NULL)
    , _linkManager(NULL)
    , _mavlinkProtocol(NULL)
    , _missionCommands(NULL)
    , _multiVehicleManager(NULL)
    , _mapEngineManager(NULL)
    , _uasMessageHandler(NULL)
    , _followMe(NULL)
    , _qgcPositionManager(NULL)
{
    //讲述人、蜂鸣 输出
    _audioOutput =              new GAudioOutput(app);
    //自驾仪管理（飞控）
    _autopilotPluginManager =   new AutoPilotPluginManager(app);
    //参数系统？？
    _factSystem =               new FactSystem(app);
    //固件管理
    _firmwarePluginManager =    new FirmwarePluginManager(app);
    //地图设置
    _flightMapSettings =        new FlightMapSettings(app);
	//返航点位置管理
    _homePositionManager =      new HomePositionManager(app);
    //图片管理
    _imageProvider =            new QGCImageProvider(app);
    //摇杆管理
    _joystickManager =          new JoystickManager(app);
    //链接管理
    _linkManager =              new LinkManager(app);
    //MAVLink 协议管理
    _mavlinkProtocol =          new MAVLinkProtocol(app);
    // 任务命令信息
    _missionCommands =          new MissionCommands(app);
    //多飞行器管理
    _multiVehicleManager =      new MultiVehicleManager(app);
    //地图引擎
    _mapEngineManager =         new QGCMapEngineManager(app);
    // 飞行器的消息句柄
    _uasMessageHandler =        new UASMessageHandler(app);
    //位置管理
    _qgcPositionManager =       new QGCPositionManager(app);
    // FollowMe 模式
    _followMe =                 new FollowMe(app);

	//###################################################################
	//########通过 setToolbox(this) 函数，实现统一的句柄管理。################
	//###################################################################
    _audioOutput->setToolbox(this);
    _autopilotPluginManager->setToolbox(this);
    _factSystem->setToolbox(this);
    _firmwarePluginManager->setToolbox(this);
    _flightMapSettings->setToolbox(this);
    _homePositionManager->setToolbox(this);
    _imageProvider->setToolbox(this);
    _joystickManager->setToolbox(this);
    _linkManager->setToolbox(this);
    _mavlinkProtocol->setToolbox(this);
    _missionCommands->setToolbox(this);
    _multiVehicleManager->setToolbox(this);
    _mapEngineManager->setToolbox(this);
    _uasMessageHandler->setToolbox(this);
    _followMe->setToolbox(this);
    _qgcPositionManager->setToolbox(this);
}
```
