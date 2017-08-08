>by luoshi006
> 欢迎交流~ 个人 Gitter 交流平台，点击直达： [![Join the chat at https://gitter.im/luoshi006_communication/Lobby](https://badges.gitter.im/luoshi006_communication/Lobby.svg)](https://gitter.im/luoshi006_communication/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

环境：
1. Windows 7 x64
2. Qt 5.5.1  msvc 2013
3. QGroundControl 3.0.0

文件位置： `\qgroundcontrol\src\main.cc`

为使结构清晰，删除冗余代码。

```cpp
/**
 * @file
 *   @brief Main executable
 *   @author Lorenz Meier <mavteam@student.ethz.ch>
 *
 */

#include "QGCMapEngine.h"

/**
 * @brief Starts the application
 *
 * @param argc Number of commandline arguments
 * @param argv Commandline arguments
 * @return exit code, 0 for normal exit and !=0 for error cases
 */

int main(int argc, char *argv[])
{

    // install the message handler
    AppMessages::installHandler();
    //使用自定义的消息处理函数，具体处理函数见：
    //static void msgHandler(QtMsgType type, const QMessageLogContext &context, const QString &msg)


#ifdef Q_OS_WIN
    // Set our own OpenGL buglist
    //q put env()，设置环境变量；此处为 OpenGL 的 bug 列表；
    qputenv("QT_OPENGL_BUGLIST", ":/opengl/resources/opengl/buglist.json");
#endif


    // We statically link our own QtLocation plugin
	// 静态插件，指定链接库；
	// 地图和导航插件，可参考 Qt官方地图文档：
	// http://doc.qt.io/qt-5/qgeoserviceprovider.html#details
	// 以及 Location API 文档：
	// http://blog.chinaunix.net/uid-8210028-id-338244.html
    Q_IMPORT_PLUGIN(QGeoServiceProviderFactoryQGC)
	
	// QGCApplication 由 main 函数启动，提供了地面站的核心管理单元。
	// 构造函数，初始化软件设置，视频流，QGCToolbox；
    QGCApplication* app = new QGCApplication(argc, argv, runUnitTests);
    Q_CHECK_PTR(app);

	// 注册 QML 对象；用于数据交换；
    app->_initCommon();
    
    //-- Initialize Cache System
    // 初始化 地图缓存；
    getQGCMapEngine()->init();

    int exitCode = 0;

    {
    // _initForNormalAppBoot 启动用户界面;
    // 此处调用 MainWindow::_create();
        if (!app->_initForNormalAppBoot()) {
            return -1;
        }
        exitCode = app->exec();
    }

    delete app;
    //-- Shutdown Cache System
    destroyMapEngine();

    qDebug() << "After app delete";

    return exitCode;
}

```
