
#Learning GitHub

**GitHub学习过程记录。。。。**
**请点击目录以查看全文大纲，该文章仅支持入门使用，高级操作请自行Google~**

> by luoshi006
> 欢迎交流~ 个人 Gitter 交流平台，点击直达： [![Join the chat at https://gitter.im/luoshi006_communication/Lobby](https://badges.gitter.im/luoshi006_communication/Lobby.svg)](https://gitter.im/luoshi006_communication/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)


# 第一章 Git历史

  Linus torvalds 在1991年时发布了 Linux **开源** 操作系统

  Linux 系统的 contributor 来自全球各个地方，最初通过邮件向 Linus 发送源代码，然后以手工的方式进行代码合并。

  直到。。。。
  
 Linux 2.4
 
  商业公司 BitMover 将其**BitKeeper**分布式版本控制系统授权给 Linux 开发社区来免费使用。

  又直到。。。。
  
 2005年时，那位曾经开发 Samba 服务程序的 Andrew 因为试图破解 BitKeeper 软件协议而激怒了 BitMover 公司，
 当即决定不再向 Linux 社区提供免费的软件授权了
 
  于是 Linus 便用C语言花了2周创建了 Git 分布式版本控制系统，并上传了 Linux 系统的源代码。:):):):):):)


----------

##Tips~
<center>
![这里写图片描述](http://img.blog.csdn.net/20160521203028530)
Octocat（章鱼猫）＝ Octopus（章鱼）+ Cat（猫）
***presumably under the notion that it can represent how complex code combines to create peculiar things, much like the octopuss...*** 
</center>
更多章鱼猫，请访问 https://octodex.github.com/



#第二章 横向对比


##SVN(Subversion)
开源版本控制系统，支持大部分常见的操作系统。
<center>
<img src="http://img.blog.csdn.net/20160521200844371" width = "240" height = "160" alt="不" />
</center>
**集中式**代码管理的核心是**服务器**，所有开发者在开始新一天的工作之前必须从服务器获取代码，然后开发，最后解决冲突，提交。所有的版本信息都放在服务器上。如果脱离了服务器，开发者基本上可以说是无法工作的。

###常见的SVN工作方式是：
  1、从服务器下载最新代码；
  2、进入自己的分支，coding，每隔一段时间提交一次代码。
  3、下班之前，将自己的分支合并到服务器主分支上。

###缺点：
 对服务器压力大；
 不适合开源开发【开源项目一般人数极多，需要进行分层管理】

##Git

<center>
<img src="http://img.blog.csdn.net/20160521204454521" width = "240" height = "200" alt="不" />
> 图片来自廖雪峰的博客，特此说明！
</center>

分布式代码管理，具有及其强大的分支管理机制，将代码的版本库都保存在本地，能够实现分支间的快速切换，提交版本时不需要与服务器连接，在本地分支实现本地提交。
###常见的Git工作方式：

<center>
<img src="http://img.blog.csdn.net/20160521205613856" width = "400" height = "240" alt="不" />
</center>

详情参见 [git flow]( http://danielkummer.github.io/git-flow-cheatsheet/index.zh_CN.html)。

#第三章 简单操作

本章介绍 git 本地操作的基本命令。

##**git init**   
创建一个空的 Git 版本库或重新初始化一个已存在的版本库

```
$ git init
Reinitialized existing Git repository in E:/works/git/Hello_world/.git/

```

##**git clone**     
将 **repository** 下载到本地文件夹中。

   ![这里写图片描述](http://img.blog.csdn.net/20160521201159804)
   
```
///所下载的项目地址由上图中的https处获取；
$ git clone https://github.com/****/Hello_world.git
Cloning into 'Hello_world'...
remote: Counting objects: 9, done.
remote: Total 9 (delta 0), reused 0 (delta 0), pack-reused 9
Unpacking objects: 100% (9/9), done.
Checking connectivity... done.

```

##**git pull**      

获取更新，将服务器端的更新下载到本地。
  
```
$ git pull
remote: Counting objects: 3, done.
remote: Total 3 (delta 0), reused 0 (delta 0), pack-reused 3
Unpacking objects: 100% (3/3), done.
From https://github.com/****/Hello_world
   9b8e8fb..30bdafc  master     -> origin/master
Updating 9b8e8fb..30bdafc
Fast-forward
 helloworld.c | 8 ++++++++
 1 file changed, 8 insertions(+)
 create mode 100644 helloworld.c
``` 
```
$ git pull
Already up-to-date.

```
   
##**git status**    

显示工作区状态

```
$ git status
On branch master
Your branch is up-to-date with 'origin/master'.
Untracked files:
  (use "git add <file>..." to include in what will be committed)

        Hello_world/
        helloworld_2.c

nothing added to commit but untracked files present (use "git add" to track)

```
      
##**git add**         

添加文件内容至索引

```
$ git add helloworld_2.c

//或者 使用 “.” 添加所有改动的文件。
$ git add .
```

##**git commit**    

将变更提交到 **本地版本库** （版本库内容见 第五章）

```
$ git commit -m "for my gitbook"
[master aa19bec] for my gitbook
 1 file changed, 8 insertions(+)
 create mode 100644 helloworld_2.c

```

##**git push**      

将 **本地版本库** 的内容推送到服务器端。
   
```
$ git push
Counting objects: 2, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (2/2), done.
Writing objects: 100% (2/2), 244 bytes | 0 bytes/s, done.
Total 2 (delta 1), reused 0 (delta 0)
To https://github.com/****/Hello_world.git
   30bdafc..aa19bec  master -> master

```

##**git log**       

显示提交日志
   
```
$ git log
commit aa19bec1a87eb5b15fdad2be49094d0fcf7ae1a4
Author: **** <****@126.com>
Date:   Sat Mar 19 21:42:27 2016 +0800

    for my gitbook

```

##**git reset**     

重置当前 **HEAD** 到指定状态

```
$ git reset --hard  aa19bec1a87eb5b15fdad2be49094d0fcf7ae1a4
HEAD is now at aa19bec for my gitbook

```
默认的HEAD版本指针会指向到最近的一次提交版本记录。

| 指针 | 内容 |
| -- | -- |
| HEAD^  | 上一个提交版本 |
| HEAD^^ | 上上一个提交版本 |
| HEAD~5 | 往上数第五个提交版本 |

#第四章 分支操作

常见的分支操作模式：
<center>
<img src="http://img.blog.csdn.net/20160521202056233" width = "270" height = "360" alt="不" /> 
</center>

 | 命令 | 作用 |
 | -- | -- |
 | git branch | 查看分支 |
 | git branch *name* | 创建分支 |
 | git checkout *name* | 切换分支 |
 | git checkout -b *name* | 创建并切换分支 |
 | git merge *name* | 合并*name*分支到当前分支 |
 | git branch -d *name* | 删除分支 |


----------

##  git checkout -b new_branch

表示 **创建** 并 **切换** 到new_branch分支；

```
//相当于以下两条命令；
$ git branch new_branch
$ git checkout new_branch
```

```
$ git checkout -b new_branch
Switched to a new branch 'new_branch'
```

##git branch

查看当前分支：

```
$ git branch
  master
* new_branch
//星号表示当前所在分支；
```

 在新分支新建文档，并提交：

```
luoshi006@luoshi006-PC MINGW64 /e/works/git/Hello_world (new_branch)
$ vi newbranch_file

luoshi006@luoshi006-PC MINGW64 /e/works/git/Hello_world (new_branch)
$ git add newbranch_file

luoshi006@luoshi006-PC MINGW64 /e/works/git/Hello_world (new_branch)
$ git commit
[new_branch 3a34441] commit for the new branch
 1 file changed, 1 insertion(+)
 create mode 100644 newbranch_file

```

## git checkout *name*

切换到 *name* 分支

```
$ git checkout master
Switched to branch 'master'
Your branch is up-to-date with 'origin/master'.

```

## git merge new_branch
把new_branch分支的工作成果合并到当前分支上

```
$ git merge new_branch
Updating aa19bec..3a34441
Fast-forward
 newbranch_file | 1 +
 1 file changed, 1 insertion(+)
 create mode 100644 newbranch_file

```

## git branch -d new_branch

删除new_branch分支

```
$ git branch -d new_branch
Deleted branch new_branch (was 3a34441).
//3a34441对应该次删除操作的commit hash码；

```

# 第五章 工作区、暂存区

##	工作区（Working Directory）
就是电脑中项目存放的目录；[ Hello_world ]的工作区，如下图：
<center>
<img src="http://img.blog.csdn.net/20160521210627057" width = "240" height = "240" alt="不" />
</center>

##	版本库（Repository） 
工作区有一个隐藏目录[**.git**]，这个就是Git的版本库。
<center>
<img src="http://img.blog.csdn.net/20160521210840156" width = "360" height = "200" alt="不" />
</center>

<center>
<img src="http://img.blog.csdn.net/20160521211010656" width = "330" height = "330" alt="不" />
> 图片源： http://documentup.com/skwp/git-workflows-book
</center>
##	暂存区过程

1. **git add ####**
将文件从工作区添加到暂存区

1. **git commit**
提交更改，将暂存区的内容同步到当前分支 [HEAD]

-	相关命令
1.	**git reset --mixed**
此为默认方式，不带任何参数的git reset，即时这种方式，它回退到某个版本，只保留源码，回退commit和index信息

2.	**git reset --soft**
回退到某个版本，只回退了commit的信息，不会恢复到index file一级。如果还要提交，直接commit即可

3.	**git reset --hard**
彻底回退到某个版本，本地的源码也会变为上一个版本的内容，commit、index、工作区都被重置，此命令慎用！

4.	**git checkout -- readme.txt**
把readme.txt文件在工作区的修改全部撤销，撤销修改就回到添加到暂存区后的状态。
就是让这个文件回到最近一次git commit或git add时的状态。

```
  注意：
  git checkout -- file命令中的 -- 很重要，没有 -- ，就变成了“切换到另一个分支”的命令
```

该部分内容参考：[廖雪峰论坛相关内容](http://www.liaoxuefeng.com/wiki/0013739516305929606dd18361248578c67b8067c8c017b000)

# 第六章 pull request

详细讲解请参考：[Pull Request工作流](http://blog.jobbole.com/76854/)

此处只讲解简单的pull request操作。

## fork
协同开发第一步，在github上看到喜欢的repository，点击![这里写图片描述](http://img.blog.csdn.net/20160522112501166)，就会把该项目添加到自己的 **Your repositories**，然后就可以随心所欲的clone、push，还可以邀请小伙伴一起修改。

## 更新

最常见的问题就是 **fork** 以后，源项目又有大量更新，此时就需要将源项目的更新拉到本地。

这种从一个账户的 **repository** 到另一个 **repository** 的操作，都要使用 **pull request** 。

点击 **New pull request**，出现以下界面：

![这里写图片描述](http://img.blog.csdn.net/20160522113413693)

设置 **base fork: ** 为自己的项目， **head fork:** 为含有更新的repository（通常为源项目）。

点击 **Create pull request** （绿色按钮）：

![这里写图片描述](http://img.blog.csdn.net/20160522113849719)

填写 title ：“合并源作者更新”；内容：“RT.”（内容随意）。

点击 **Create pull request** （绿色按钮）：

![这里写图片描述](http://img.blog.csdn.net/20160522114927759)
【**→_→**打码水平一流~】

点击 **Merge pull request** ：

![这里写图片描述](http://img.blog.csdn.net/20160522115317178)

点击 **Confirm merge** ，完成更新。

## contribute
实在不知道怎么起标题了。。。。

就是在自己的 repository 中修改代码以后，测试完成，满意后，将自己的代码推送给源 repository。
如果对方接受你的代码，则你就成了该项目的contributor。

嗯。。。。。

其实这个操作和上一个基本一致，只需在以下选择是反过来就可以：

![这里写图片描述](http://img.blog.csdn.net/20160522113413693)

打码太痛苦，沿用上面的图片，将这里的 **head fork:** 设为自己的 repository。

之后的操作就一样了。

成为 **contributor** 以后，对应的 **repository** 会出现在主页：

![这里写图片描述](http://img.blog.csdn.net/20160522151606480)



#The End

推荐一些经典的git教程：

1.	[GitHub Training](https://training.github.com/)
2.	[猴子都能看懂的GIT入门](http://backlogtool.com/git-guide/cn/)
3.	[Pro Git](https://git-scm.com/book/zh/v1)
4.	[Tutorials](https://www.atlassian.com/git/tutorials/comparing-workflows)


<center>
<img src="https://octodex.github.com/images/motherhubbertocat.png" width = "120" height = "120" alt="不" />
<img src="https://octodex.github.com/images/minertocat.png" width = "120" height = "120" alt="不" />
<img src="https://octodex.github.com/images/mountietocat.png" width = "120" height = "120" alt="不" />
</center>

[toc]