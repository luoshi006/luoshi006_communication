> by luoshi006
> 欢迎交流~ 个人 Gitter 交流平台，点击直达： [![Join the chat at https://gitter.im/luoshi006_communication/Lobby](https://badges.gitter.im/luoshi006_communication/Lobby.svg)](https://gitter.im/luoshi006_communication/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

>参考：［Thuai’s blog］[ http://www.thuai.com ]

QGCApplication 是地面站的核心管理单元。内容较为庞杂，故安装主程序调用的顺序对个别函数进行讲解。

该类使用 单件模式，详细信息请查看 设计模式 。

```cpp
/// @brief Returns the QGCApplication object singleton.
QGCApplication* qgcApp(void);
```

#构造函数

```cpp
/**
 * @brief Constructor for the main application.
 *
 * This constructor initializes and starts the whole application. It takes standard
 * command-line parameters
 *
 * @param argc The number of command-line parameters
 * @param argv The string array of parameters
 **/

QGCApplication::QGCApplication(int &argc, char* argv[], bool unitTesting)
    : QApplication(argc, argv)
    , _runningUnitTests(unitTesting)
    , _styleIsDark(true)
    , _fakeMobile(false)///< 调试用true: Fake ui into displaying mobile interface
    , _settingsUpgraded(false)///< true: Settings format has been upgrade to new version
    , _toolbox(NULL)//用于管理所有顶层服务；
    , _bluetoothAvailable(false)
    , _lastKnownHomePosition(37.803784, -122.462276, 0.0)
    // 地图显示的默认位置，北京市（39.990634, 116.349573）；
{
    Q_ASSERT(_app == NULL);
    _app = this;

    // Setup for network proxy support 网络代理设置；
    QNetworkProxyFactory::setUseSystemConfiguration(true);

    // Parse command line options

    bool fClearSettingsOptions = false; // Clear stored settings
    bool logging = false;               // Turn on logging
    QString loggingOptions;

    // Set up timer for delayed missing fact display
    // 参数丢失显示；
    _missingParamsDelayedDisplayTimer.setSingleShot(true);
    _missingParamsDelayedDisplayTimer.setInterval( _missingParamsDelayedDisplayTimerTimeout);
    connect(&_missingParamsDelayedDisplayTimer, &QTimer::timeout, this, &QGCApplication::_missingParamsDisplay);

    // Set application information
    // 设置软件信息；
    setApplicationName(QGC_APPLICATION_NAME);
    setOrganizationName(QGC_ORG_NAME);
    setOrganizationDomain(QGC_ORG_DOMAIN);
    this->setApplicationVersion(QString(GIT_VERSION));

    // Set settings format 配置文件相关；
    QSettings::setDefaultFormat(QSettings::IniFormat);
    QSettings settings;
    qDebug() << "Settings location" << settings.fileName() << "Is writable?:" << settings.isWritable();
    // The setting will delete all settings on this boot
    fClearSettingsOptions |= settings.contains(_deleteAllSettingsKey);
    if (fClearSettingsOptions) {
        // User requested settings to be cleared on command line
        settings.clear();
        settings.setValue(_settingsVersionKey, QGC_SETTINGS_VERSION);
        // Clear parameter cache
        QDir paramDir(ParameterLoader::parameterCacheDir());
        paramDir.removeRecursively();
        paramDir.mkpath(paramDir.absolutePath());
    } else {
        // Determine if upgrade message for settings version bump is required. Check must happen before toolbox is started since
        // that will write some settings.
        if (settings.contains(_settingsVersionKey)) {
            if (settings.value(_settingsVersionKey).toInt() != QGC_SETTINGS_VERSION) {
                _settingsUpgraded = true;
            }
        } else if (settings.allKeys().count()) {
            // Settings version key is missing and there are settings. This is an upgrade scenario.
            _settingsUpgraded = true;
        } else {
            settings.setValue(_settingsVersionKey, QGC_SETTINGS_VERSION);
        }
    }

    // Set up our logging filters 日志文件相关；
    QGCLoggingCategoryRegister::instance()->setFilterRulesFromSettings(loggingOptions);

    _lastKnownHomePosition.setLatitude(settings.value(_lastKnownHomePositionLatKey, 37.803784).toDouble());
    _lastKnownHomePosition.setLongitude(settings.value(_lastKnownHomePositionLonKey, -122.462276).toDouble());
    _lastKnownHomePosition.setAltitude(settings.value(_lastKnownHomePositionAltKey, 0.0).toDouble());


    // Initialize Video Streaming
    //初始化视频流（GStreamer）；
    initializeVideoStreaming(argc, argv);

	// Toolbox 用于管理所有的顶层服务；
    _toolbox = new QGCToolbox(this);
}
```

# _initCommon(void)

注册 QML 对象；

##创建一个QML扩展的基本步骤：

1. 通过QObject子类定义新的QML类型并使用qmlRegisterType()注册它们。

2. 使用Q_INVOKABLE或Qt槽添加可以调用模式并使用onSignal语法链接到Qt信号。

3. 通过定义NOTIFY信号添加属性绑定。

4. 如果内置类型没有的可以定义自定义属性类型。

5. 使用QDeclarativeListProperty定义列表属性类型。

6. 通过定义一个Qt插件并编写一个qmldir文件创建一个插件库。

##注册C++类

###注册可实例化的类型

如果一个C++类继承自 QObject ，如果需要在 QML 中使用创建对象，则需要注册为可实例化的 QML 类型。

使用** qmlRegisterType() **注册可实例化的 QML 类型， 具体查看 qmlRegisterType() 的文档说明。

```cpp
//Message.cpp  
class Message : public QObject  {
    Q_OBJECT
    Q_PROPERTY(QString author READ author WRITE setAuthor NOTIFY authorChanged)
    Q_PROPERTY(QDateTime creationDate READ creationDate WRITE setCreationDate NOTIFY creationDateChanged)
public:
    // ...
};
 
//main.cpp  
#include <QtQml>  
...  
qmlRegisterType<Message>("com.mycompany.messaging", 1, 0, "Message");  ...   
 
//aQmlFile.qml  
import com.mycompany.messaging 1.0    
Message {
      author: "Amelie"      
      creationDate: new Date()  
      }  
```
###注册不实例化的QML类型

1. **qmlRegisterType()** 不带参数， 这种方式无法使用引用注册的类型，所以无法在QML中创建对象。

2. **qmlRegisterInterface()** 这种方式用于注册C++中的虚基类。

3. **qmlRegisterUncreatableType()**

4. **qmlRegisterSingletonType()** 这种方法可以注册一个能够在 QML 中使用的单例类型。

####附带属性

在QML语法中有一个附带属性的概念。

这里使用C++自定义QML类型的时候，也可以定义附带属性。

核心的亮点就是

`static <AttachedPropertiesType> *qmlAttachedProperties(QObject *object);`

和

`QML_DECLARE_TYPEINFO()` 中声明 `QML_HAS_ATTACHED_PROPERTIES` 标志


```cpp
void QGCApplication::_initCommon(void)
{
    QSettings settings;

    // Register our Qml objects

    qmlRegisterType<QGCPalette>     ("QGroundControl.Palette", 1, 0, "QGCPalette");
    qmlRegisterType<QGCMapPalette>  ("QGroundControl.Palette", 1, 0, "QGCMapPalette");

    qmlRegisterUncreatableType<CoordinateVector>    ("QGroundControl",                  1, 0, "CoordinateVector",       "Reference only");
    qmlRegisterUncreatableType<MissionCommands>     ("QGroundControl",                  1, 0, "MissionCommands",        "Reference only");
    qmlRegisterUncreatableType<QmlObjectListModel>  ("QGroundControl",                  1, 0, "QmlObjectListModel",     "Reference only");
    qmlRegisterUncreatableType<VideoReceiver>       ("QGroundControl",                  1, 0, "VideoReceiver",          "Reference only");
    qmlRegisterUncreatableType<VideoSurface>        ("QGroundControl",                  1, 0, "VideoSurface",           "Reference only");

    qmlRegisterUncreatableType<AutoPilotPlugin>     ("QGroundControl.AutoPilotPlugin",  1, 0, "AutoPilotPlugin",        "Reference only");
    qmlRegisterUncreatableType<VehicleComponent>    ("QGroundControl.AutoPilotPlugin",  1, 0, "VehicleComponent",       "Reference only");
    qmlRegisterUncreatableType<Vehicle>             ("QGroundControl.Vehicle",          1, 0, "Vehicle",                "Reference only");
    qmlRegisterUncreatableType<MissionItem>         ("QGroundControl.Vehicle",          1, 0, "MissionItem",            "Reference only");
    qmlRegisterUncreatableType<MissionManager>      ("QGroundControl.Vehicle",          1, 0, "MissionManager",         "Reference only");
    qmlRegisterUncreatableType<JoystickManager>     ("QGroundControl.JoystickManager",  1, 0, "JoystickManager",        "Reference only");
    qmlRegisterUncreatableType<Joystick>            ("QGroundControl.JoystickManager",  1, 0, "Joystick",               "Reference only");
    qmlRegisterUncreatableType<QGCPositionManager>  ("QGroundControl.QGCPositionManager",  1, 0, "QGCPositionManager",  "Reference only");

    qmlRegisterType<ParameterEditorController>          ("QGroundControl.Controllers", 1, 0, "ParameterEditorController");
    qmlRegisterType<APMFlightModesComponentController>  ("QGroundControl.Controllers", 1, 0, "APMFlightModesComponentController");
    qmlRegisterType<PX4AdvancedFlightModesController>   ("QGroundControl.Controllers", 1, 0, "PX4AdvancedFlightModesController");
    qmlRegisterType<PX4SimpleFlightModesController>     ("QGroundControl.Controllers", 1, 0, "PX4SimpleFlightModesController");
    qmlRegisterType<APMAirframeComponentController>     ("QGroundControl.Controllers", 1, 0, "APMAirframeComponentController");
    qmlRegisterType<AirframeComponentController>        ("QGroundControl.Controllers", 1, 0, "AirframeComponentController");
    qmlRegisterType<APMSensorsComponentController>      ("QGroundControl.Controllers", 1, 0, "APMSensorsComponentController");
    qmlRegisterType<SensorsComponentController>         ("QGroundControl.Controllers", 1, 0, "SensorsComponentController");
    qmlRegisterType<PowerComponentController>           ("QGroundControl.Controllers", 1, 0, "PowerComponentController");
    qmlRegisterType<RadioComponentController>           ("QGroundControl.Controllers", 1, 0, "RadioComponentController");
    qmlRegisterType<ESP8266ComponentController>         ("QGroundControl.Controllers", 1, 0, "ESP8266ComponentController");
    qmlRegisterType<ScreenToolsController>              ("QGroundControl.Controllers", 1, 0, "ScreenToolsController");
    qmlRegisterType<MainToolBarController>              ("QGroundControl.Controllers", 1, 0, "MainToolBarController");
    qmlRegisterType<MissionController>                  ("QGroundControl.Controllers", 1, 0, "MissionController");
    qmlRegisterType<FlightDisplayViewController>        ("QGroundControl.Controllers", 1, 0, "FlightDisplayViewController");
    qmlRegisterType<ValuesWidgetController>             ("QGroundControl.Controllers", 1, 0, "ValuesWidgetController");
    qmlRegisterType<QGCMobileFileDialogController>      ("QGroundControl.Controllers", 1, 0, "QGCMobileFileDialogController");
    qmlRegisterType<RCChannelMonitorController>         ("QGroundControl.Controllers", 1, 0, "RCChannelMonitorController");
    qmlRegisterType<JoystickConfigController>           ("QGroundControl.Controllers", 1, 0, "JoystickConfigController");
#ifndef __mobile__
    qmlRegisterType<ViewWidgetController>           ("QGroundControl.Controllers", 1, 0, "ViewWidgetController");
    qmlRegisterType<CustomCommandWidgetController>  ("QGroundControl.Controllers", 1, 0, "CustomCommandWidgetController");
    qmlRegisterType<FirmwareUpgradeController>      ("QGroundControl.Controllers", 1, 0, "FirmwareUpgradeController");
    qmlRegisterType<LogDownloadController>          ("QGroundControl.Controllers", 1, 0, "LogDownloadController");
#endif

    // Register Qml Singletons
    qmlRegisterSingletonType<QGroundControlQmlGlobal>   ("QGroundControl",                          1, 0, "QGroundControl",         qgroundcontrolQmlGlobalSingletonFactory);
    qmlRegisterSingletonType<ScreenToolsController>     ("QGroundControl.ScreenToolsController",    1, 0, "ScreenToolsController",  screenToolsControllerSingletonFactory);
    qmlRegisterSingletonType<MavlinkQmlSingleton>       ("QGroundControl.Mavlink",                  1, 0, "Mavlink",                mavlinkQmlSingletonFactory);
}
```

#  _initForNormalAppBoot(void)

启动用户界面。


```cpp
bool QGCApplication::_initForNormalAppBoot(void)
{
    QSettings settings;

    _styleIsDark = settings.value(_styleKey, _styleIsDark).toBool();
    _loadCurrentStyle();

    // Exit main application when last window is closed
    connect(this, &QGCApplication::lastWindowClosed, this, QGCApplication::quit);

    // Start the user interface
    //启动用户界面；
    MainWindow* mainWindow = MainWindow::_create();
    Q_CHECK_PTR(mainWindow);

    // Now that main window is up check for lost log files
    connect(this, &QGCApplication::checkForLostLogFiles, toolbox()->mavlinkProtocol(), &MAVLinkProtocol::checkForLostLogFiles);
    emit checkForLostLogFiles();

    // Load known link configurations
    toolbox()->linkManager()->loadLinkConfigurationList();

    settings.sync();

    return true;
}
```

# singleton模式

```cpp
/// @brief Returns the QGCApplication object singleton.
QGCApplication* qgcApp(void)
{
    Q_ASSERT(QGCApplication::_app);
    return QGCApplication::_app;
}
```

```cpp
QObject* QGCApplication::_rootQmlObject(void)
{
    MainWindow * mainWindow = MainWindow::instance();
    if (mainWindow) {
        return mainWindow->rootQmlObject();
    } else {
        qWarning() << "Why is MainWindow missing?";
        return NULL;
    }
}
```

# QMetaObject::invokeMethod

静态方法QMetaObject::invokeMethod() 的定义如下：
```cpp
bool QMetaObject::invokeMethod ( 
		QObject * obj, 
		const char * member,
		Qt::ConnectionType type,  
		QGenericReturnArgument ret, 
		QGenericArgument val0 = QGenericArgument( 0 ), 
		…
		)
```  

`invokeMethod` 的用法为: 尝试调用对象 `obj` 的方法 `member`（注意`member`可以为信号或者是槽)，如果 `member`可以被调用，则返回真，否则返回假。 

`QMetaObject::invokeMethod`可以是异步调用，也可以是同步调用。这取决与它的连接方式`Qt::ConnectionType type`。如果`type`为`Qt::DirectConnection`，则为同步调用，若为`Qt::QueuedConnection`，则为异步调用。

请注意，因为上面所示的参数需要被在构建事件时进行硬拷贝，参数的自定义型别所对应的类需要提供一个共有的构造函数、析构函数以及拷贝构造函数。而且必须使用注册Qt 型别系统所提供的`qRegisterMetaType()` 方法来注册这一自定义型别。

`Q_INVOKABLE` 与 `QMetaObject::invokeMethod` 均由元对象系统唤起。这一机制在Qt C++/QML混合编程，跨线程编程，`Qt Service Framework` 以及 Qt/ HTML5混合编程以及里广泛使用。

```cpp
void QGCApplication::showFlyView(void)
{
    QMetaObject::invokeMethod(_rootQmlObject(), "showFlyView");
}

void QGCApplication::showPlanView(void)
{
    QMetaObject::invokeMethod(_rootQmlObject(), "showPlanView");
}

void QGCApplication::showSetupView(void)
{
    QMetaObject::invokeMethod(_rootQmlObject(), "showSetupView");
}
```

通过元对象系统 ，找到 QML 根对象，调用其对应的方法：
 `\qgroundcontrol\src\ui\MainWindowNative.qml`

```xml
    function showFlyView() {
        mainWindowInner.item.showFlyView()
    }

    function showPlanView() {
        mainWindowInner.item.showPlanView()
    }

    function showSetupView() {
        mainWindowInner.item.showSetupView()
    }
```


[toc]