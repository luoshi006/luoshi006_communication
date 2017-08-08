>`by luoshi006`
> 欢迎交流~ 个人 Gitter 交流平台，点击直达： [![Join the chat at https://gitter.im/luoshi006_communication/Lobby](https://badges.gitter.im/luoshi006_communication/Lobby.svg)](https://gitter.im/luoshi006_communication/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)


#单件模式

`MainWindow` 类是典型的 `singleton` 模式。

```cpp
class MainWindow : public QMainWindow
{
    Q_OBJECT
public:
    /// @brief Returns the MainWindow singleton. Will not create the MainWindow if it has not already
    ///         been created.
    static MainWindow* instance(void);
    static MainWindow* _create();
    
private:
    /// Constructor is private since all creation should be through MainWindow::_create
    MainWindow();
}
```
# _create()

在 `main()` 函数中，`QGCApplication()` 构造函数之后调用`QGCApplication() -> _initForNormalAppBoot(void)`。

`_initForNormalAppBoot(void)` 中，调用 `MainWindow::_create();` 。

`singleton` 模式中，私有的构造函数只能通过静态函数 `_create()` 调用，`new` 之前需要通过 `Q_ASSERT` 检查，防止重复 `new` 。

```cpp
MainWindow* MainWindow::_create()
{
    Q_ASSERT(_instance == NULL);
    new MainWindow();
    // _instance is set in constructor
    Q_ASSERT(_instance);
    return _instance;
}
```

# 构造函数

```cpp
/// @brief Private constructor for MainWindow. MainWindow singleton is only ever created
///         by MainWindow::_create method. Hence no other code should have access to
///         constructor.
MainWindow::MainWindow()
    : _lowPowerMode(false)
    , _showStatusBar(false)
    , _mainQmlWidgetHolder(NULL)
    , _forceClose(false)
{
    Q_ASSERT(_instance == NULL);
    _instance = this;

    //-- Load fonts
    // 载入字体；
    if(QFontDatabase::addApplicationFont(":/fonts/opensans") < 0) {
        qWarning() << "Could not load /fonts/opensans font";
    }
    if(QFontDatabase::addApplicationFont(":/fonts/opensans-demibold") < 0) {
        qWarning() << "Could not load /fonts/opensans-demibold font";
    }

    // Setup user interface
    loadSettings();
    emit initStatusChanged(tr("Setting up user interface"), Qt::AlignLeft | Qt::AlignBottom, QColor(62, 93, 141));

    _ui.setupUi(this);
    
    // Make sure tool bar elements all fit before changing minimum width
    setMinimumWidth(1008);
    configureWindowName();

    // Setup central widget with a layout to hold the views
    _centralLayout = new QVBoxLayout();
    _centralLayout->setContentsMargins(0, 0, 0, 0);
    //对 中心部件 应用布局。
    centralWidget()->setLayout(_centralLayout);

	// 通过 widget 控制 QML 界面；
    _mainQmlWidgetHolder = new QGCQmlWidgetHolder(QString(), NULL, this);
    _centralLayout->addWidget(_mainQmlWidgetHolder);
    _mainQmlWidgetHolder->setVisible(true);

	//设置 ownership 为 CppOwnership
    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
    //setContextPropertyObject 设置 QML 中的 controller 对象；
    _mainQmlWidgetHolder->setContextPropertyObject("controller", this);
    _mainQmlWidgetHolder->setContextPropertyObject("debugMessageModel", AppMessages::getModel());
    // 显示 MainWindowHybrid.qml界面；
    _mainQmlWidgetHolder->setSource(QUrl::fromUserInput("qrc:qml/MainWindowHybrid.qml"));

    // Image provider
    QQuickImageProvider* pImgProvider = dynamic_cast<QQuickImageProvider*>(qgcApp()->toolbox()->imageProvider());
    _mainQmlWidgetHolder->getEngine()->addImageProvider(QLatin1String("QGCImages"), pImgProvider);

	//界面显示属性；
    // Set dock options
    setDockOptions(0);
    // Setup corners
    setCorner(Qt::BottomRightCorner, Qt::BottomDockWidgetArea);

    // Status Bar 状态栏
    setStatusBar(new QStatusBar(this));
    statusBar()->setSizeGripEnabled(true);

    // Create actions
    //创建窗口所需的所有菜单；
    connectCommonActions();
    // Connect user interface devices
#ifdef QGC_MOUSE_ENABLED_WIN 
// 3D 鼠标；
    emit initStatusChanged(tr("Initializing 3D mouse interface"), Qt::AlignLeft | Qt::AlignBottom, QColor(62, 93, 141));
    mouseInput = new Mouse3DInput(this);
    mouse = new Mouse6dofInput(mouseInput);
#endif //QGC_MOUSE_ENABLED_WIN

    // Set low power mode
    enableLowPowerMode(_lowPowerMode);
    emit initStatusChanged(tr("Restoring last view state"), Qt::AlignLeft | Qt::AlignBottom, QColor(62, 93, 141));

    connect(_ui.actionStatusBar,  &QAction::triggered, this, &MainWindow::showStatusBarCallback);

    connect(&windowNameUpdateTimer, &QTimer::timeout, this, &MainWindow::configureWindowName);
    windowNameUpdateTimer.start(15000);
    emit initStatusChanged(tr("Done"), Qt::AlignLeft | Qt::AlignBottom, QColor(62, 93, 141));

    if (!qgcApp()->runningUnitTests()) {
        _ui.actionStatusBar->setChecked(_showStatusBar);
        showStatusBarCallback(_showStatusBar);
        show();//显示 MainWindow；
    }
    //-- Enable message handler display of messages in main window
    //  主窗口中的 消息 显示句柄；
    UASMessageHandler* msgHandler = qgcApp()->toolbox()->uasMessageHandler();
    if(msgHandler) {
        msgHandler->showErrorsInToolbar();
    }
}
```

# instance(void)

单件模式中，通过 `instance（）` 方法，获取当前指针，获取后需判断是否为 `NULL`。
```cpp
MainWindow* MainWindow::instance(void)
{
    return _instance;
}
```

# connectCommonActions();

```cpp
/**
* @brief Create all actions associated to the main window
*
**/
void MainWindow::connectCommonActions()
{
    // Audio output 声音；
    _ui.actionMuteAudioOutput->setChecked(qgcApp()->toolbox()->audioOutput()->isMuted());
    connect(qgcApp()->toolbox()->audioOutput(), &GAudioOutput::mutedChanged, _ui.actionMuteAudioOutput, &QAction::setChecked);
    connect(_ui.actionMuteAudioOutput, &QAction::triggered, qgcApp()->toolbox()->audioOutput(), &GAudioOutput::mute);

    // Application Settings 退出；
    connect(_ui.actionSettings, &QAction::triggered, this, &MainWindow::showSettings);

    // Connect internal actions
    connect(qgcApp()->toolbox()->multiVehicleManager(), &MultiVehicleManager::vehicleAdded, this, &MainWindow::_vehicleAdded);
}
```











[toc]