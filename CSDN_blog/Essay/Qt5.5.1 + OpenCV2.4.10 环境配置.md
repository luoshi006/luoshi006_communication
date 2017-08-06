
#Qt5.5.1 + OpenCV2.4.10 环境配置

> by luoshi006
> 欢迎交流~ 个人 Gitter 交流平台，点击直达： [![Join the chat at https://gitter.im/luoshi006_communication/Lobby](https://badges.gitter.im/luoshi006_communication/Lobby.svg)](https://gitter.im/luoshi006_communication/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)



## 配置环境

- PC：Windows 7 x64
- Qt：qt-opensource-windows-x86-msvc2013-5.5.1
- OpenCV：opencv-2.4.10

##配置过程

1. **下载并安装 Qt，并运行 opencv 自解压程序。**
	本文中 opencv 解压路径 `D:\`
	
2. **配置 opencv 环境变量：**
	在系统环境变量中（**PATH**），添加以下路径
	`D:\opencv\build\x86\vc12\bin;
	D:\opencv\build\x86\vc12\lib;`
	其中，**vc12** 表示 vs2013 ，添加路径时，请选择与编译器相对应的版本。
	若使用 mingw 等编译器，需要使用 cmake 编译 opencv 源码。
	
3. **在 Qt 项目中，添加路径和库：**
	在Qt中，新建项目`[Application->Qt Console Application]`（验证环境用，所以选择简单的控制台程序。）
	打开项目文件（.pro），在文件尾增加如下代码：
	

```
# INCLUDEPATH 指定用于搜索头文件的文件夹
INCLUDEPATH += D:/opencv/build/include

# LIBS 包含链接时的库文件列表。使用 -L 指定文件夹路径， -l 指定库的名称

win32:CONFIG(debug, debug | release):{
LIBS +=  -LD:/opencv/build/x86/vc12/lib \
-lopencv_core2410d \
-lopencv_imgproc2410d \
-lopencv_highgui2410d \
-lopencv_ml2410d \
-lopencv_video2410d \
-lopencv_features2d2410d \
-lopencv_calib3d2410d \
-lopencv_objdetect2410d \
-lopencv_contrib2410d \
-lopencv_legacy2410d \
-lopencv_flann2410d \
-lopencv_ml2410d   \
-lopencv_calib3d2410d  \
-lopencv_gpu2410d  \
-lopencv_ts2410d   \
-lopencv_nonfree2410d  \
-lopencv_ocl2410d  \
-lopencv_photo2410d    \
-lopencv_stitching2410d    \
-lopencv_superres2410d     \
-lopencv_superres2410d

} else : win32:CONFIG(release, debug | release):{
LIBS +=  -LD:/opencv/build/x86/vc12/lib \
-lopencv_core2410 \
-lopencv_imgproc2410 \
-lopencv_highgui2410 \
-lopencv_ml2410 \
-lopencv_video2410 \
-lopencv_features2d2410 \
-lopencv_calib3d2410 \
-lopencv_objdetect2410 \
-lopencv_contrib2410 \
-lopencv_legacy2410 \
-lopencv_flann2410  \
-lopencv_ml2410   \
-lopencv_calib3d2410  \
-lopencv_gpu2410  \
-lopencv_ts2410   \
-lopencv_nonfree2410  \
-lopencv_ocl2410  \
-lopencv_photo2410    \
-lopencv_stitching2410    \
-lopencv_superres2410     \
-lopencv_superres2410
}
```
老版本的 Qt 不会自动更新qmake，需要手动执行，`[构建->执行 qmake]` 。

4.**运行示例程序**
	在源文件`[main.cpp]` 中输入一下代码：

```cpp
#include <QCoreApplication>
#include <iostream>
#include <QDebug>
#include <QString>

#include <opencv2/opencv.hpp>

using namespace std;
using namespace cv;

int main(int argc,char * argv[])
{
    cout<<"opencv"<<endl;
    qDebug()<<"app start! "<<endl;
    Mat src;
    QString path;

    if(argc < 2)
    {
            path="C:/lena.jpg";
            qDebug()<<"argc = 1"<<endl;
    }
    else if(argc > 2)
    {
        cout << "only single picture can be supported~"<<endl;
        qDebug()<<"too many argument!"<<endl;
        return 1;
    }
    else
    {
        path = argv[1];
    }

    src = imread(path.toLatin1().data());
    if(!src.data)//读取失败；
    {
        cout<<"read failed!"<<endl;
        return 2;
    }

    namedWindow("test_1");
    imshow("test_1",src);

    waitKey(0);
    qDebug()<<"app exit!"<<endl;
    return 0;
}

```
在 `C:\` 根目录下放入经典的 lena ，或拖拽图片到`.exe`程序上释放，测试程序。

##附图
![这里写图片描述](http://img.blog.csdn.net/20160705105754047)