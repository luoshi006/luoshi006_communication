# GDB 笔记

## 在 CMake 中添加 GDB 支持

```cmake
    SET(CMAKE_BUILD_TYPE  "Debug")

    SET(CMAKE_CXX_FLAGS_DEBUG  "$ENV{CXXFLAGS}  -O0  -Wall  -g  -ggdb")

    SET(CMAKE_CXX_FLAGS_RELEASE  "$ENV{CXXFLAGS}  -O3  -Wall")
```

`CMAKE_CXX_FLAGS_DEBUG` 用于在 `Debug` 模式下设置 `CXXFLAGS` 变量。**[可省略]**

## 运行调试

```
gdb helloworld.exe
```

## GDB 常用命令
```txt
    l:   显示代码  
    b 2: 设置断点在第二行  
    r:   run至断点  
    display var: 显示 var 值  
    n:   step over  
    s:   step into  
    q:   quit
```
----
|命令|示例|备注|
|:---|:---|:---|
|file|(gdb) file helloworld.exe|在 GDB 中，使用 file 加载/切换可执行文件。|
|r|(gdb) r|run/restart, 开始执行程序|
|c|(gdb) c|continue, 继续向下执行|
|b [行号]|(gdb) b 2|breakpoint, 设置断点。<br>b <行号><br>b <函数名称><br>b *<函数名称><br>b *<代码地址(0x####)>|
|info breakpoints|(gdb) info breakpoints |显示所有断点|
|d [标号]|(gdb) d 1 |删除对应 [标号] 的断点|
|s|(gdb) s|Step Into 单步进入|
|n|(gdb) n|Step Over 单步跳过|
|p [变量]|(gdb) p var |Print, 打印当前变量值|
|info variables|(gdb) info variables|显示当前所有变量|
|display [变量]|(gdb) display var|每次（单步）运行后，显示变量值|
|undisplay [标号]|(gdb) undisplay 1|取消对应 [标号] 的显示|
|i/info|(gdb) i|详情查阅 help info|
|q/quit|(gdb) q|退出 gdb|
|help|(gdb) help|help|

>Note:
**gdb 加载可执行文件后，默认不会执行，键入 `r` 后，开始运行。**

----

100个gdb小技巧：
https://github.com/hellogcc/100-gdb-tips/blob/master/src/index.md
