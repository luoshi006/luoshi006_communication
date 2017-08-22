> by luoshi006
> 欢迎交流~ 个人 Gitter 交流平台，点击直达： [![Join the chat at https://gitter.im/luoshi006_communication/Lobby](https://badges.gitter.im/luoshi006_communication/Lobby.svg)](https://gitter.im/luoshi006_communication/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

<br><br>

PX4 官方的 github 库中，悄悄的推出了日志分析 **Matlab 脚本**文件。
**链接：https://github.com/PX4/ecl/tree/master/matlab/analysis**

**[ Matlab 版本需高于2013a ]**

<br>
<center><big>本文只作简单的用法讲解，日志文件的解析之后有时间会跟上~</big></center>
<br>

## 文件目录

包含三个 `.m` 文件：

```cpp
estimatorLogViewerPX4.m	  	//估计分析；
importPX4log.m				//导入PX4log 文件；
usageSamples.m				//以上两个文件的用法示例；
```

## .PX4log 导入 MATLAB

三个 `.m` 文件 与  `.PX4log` 文件放入同一个文件夹，将该路径**添加工作路径**，且为当前路径。

<center>
![这里写图片描述](http://img.blog.csdn.net/20161203171031966)
</center>

文件导入方法如下：【usageSamples.m】

```
fname ='mytest2.px4log';

%% entire log  导入整个 px4log 文件；
wholeLog = importPX4log(fname,{});

%% attitude message 导入 姿态 信息；
attitudeData = importPX4log(fname,{'ATT'});

%% estimator messages  导入 估计 信息；
estimatorData = importPX4log(fname,{'EST0','EST1','EST2','EST3','EST4','EST5','EST6'});

```

导入后为一个结构体，结构如下：
<center>
![这里写图片描述](http://img.blog.csdn.net/20161203171813017)
</center>

```
     ATT: [1x1 struct]
    ATSP: [1x1 struct]
     IMU: [1x1 struct]
    IMU1: [1x1 struct]
    IMU2: [1x1 struct]
    SENS: [1x1 struct]
    AIR1: [1x1 struct]
    LPOS: [1x1 struct]
    LPSP: [1x1 struct]
     GPS: [1x1 struct]
    DGPS: [1x1 struct]
    ATTC: [1x1 struct]
    ATC1: [1x1 struct]
    STAT: [1x1 struct]
    VTOL: [1x1 struct]
     CTS: [1x1 struct]
      RC: [1x1 struct]
    OUT0: [1x1 struct]
    OUT1: [1x1 struct]
    AIRS: [1x1 struct]
    ARSP: [1x1 struct]
    FLOW: [1x1 struct]
    GPOS: [1x1 struct]
    GPSP: [1x1 struct]
     ESC: [1x1 struct]
    GVSP: [1x1 struct]
    BATT: [1x1 struct]
    DIST: [1x1 struct]
    TEL0: [1x1 struct]
    TEL1: [1x1 struct]
    TEL2: [1x1 struct]
    TEL3: [1x1 struct]
    EST0: [1x1 struct]
    EST1: [1x1 struct]
    EST2: [1x1 struct]
    EST3: [1x1 struct]
    EST4: [1x1 struct]
    EST5: [1x1 struct]
    EST6: [1x1 struct]
     PWR: [1x1 struct]
    MOCP: [1x1 struct]
    VISN: [1x1 struct]
    GS0A: [1x1 struct]
    GS0B: [1x1 struct]
    GS1A: [1x1 struct]
    GS1B: [1x1 struct]
    TECS: [1x1 struct]
    WIND: [1x1 struct]
    ENCD: [1x1 struct]
    TSYN: [1x1 struct]
    MACS: [1x1 struct]
    CAMT: [1x1 struct]
    RPL1: [1x1 struct]
    RPL2: [1x1 struct]
    RPL3: [1x1 struct]
    RPL4: [1x1 struct]
    RPL5: [1x1 struct]
    RPL6: [1x1 struct]
    LAND: [1x1 struct]
    LOAD: [1x1 struct]
    TIME: [1x1 struct]
     VER: [1x1 struct]
    PARM: [1x1 struct]
```
<br>

以 `ATT` 为例：

<center>
![这里写图片描述](http://img.blog.csdn.net/20161203172116613)
此处由于 `estimatorData` 导入时未添加 ATT 字段，故值为空。
</center>


## 估计分析

* 注意： `estimatorLogViewerPX4.m` 需重命名为： `estimatorLogViewer.m`。
* 注意： `estimatorLogViewer('ift.mat');` 函数中的 `ift.mat` 必须是名为 `estimatorData` 的结构体。

若执行过程出现以下 `error` ，请参照  注意第二条  。
```
未定义变量 "estimatorData" 或类 "estimatorData.EST0"。
出错 estimatorLogViewer (line 5)
stateFieldNames = [fieldnames(estimatorData.EST0);fieldnames(estimatorData.EST1)]; 
```

###estimatorLogViewer用法

```
%% estimator messages  导入 估计 数据；
estimatorData = importPX4log(fname,{'EST0','EST1','EST2','EST3','EST4','EST5','EST6'});

%% to save 保存为 ift.mat 文件；
save ift estimatorData;

%% to run viewer  运行 viewer；
estimatorLogViewer('ift.mat');
```
<br>

效果如下：

<center>
![这里写图片描述](http://img.blog.csdn.net/20161203173333068)
勾选 `show variance`，显示状态估计的方差信息。
</center>


<br><br><br>
wiki 中日志分析介绍：http://dev.px4.io/flight_log_analysis.html