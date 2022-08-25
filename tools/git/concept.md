# git
[git](https://www.runoob.com/git/git-basic-operations.html)
# git与svn的区别
* git是分布式的，这是跟svn最核心的区别
> git没有单独的服务端软件，svn是有的
* git把内容按元数据的方式存储，而svn使用的是文件
* git的分支和svn的不同，svn的分只是一个目录
* git没有全局的版本号，而svn有
* git的内容完整性要高于svn
# git工作区、暂存区和版本库
![](https://www.runoob.com/wp-content/uploads/2015/02/1352126739_7909.jpg)
* 工作区
就是本地的目录
* 暂存区
英文名叫做index或者stage，一般存放在.git目录下的index文件中，所以把索引区也叫做索引
* 版本库  
工作区有一个隐藏的目录，这个不算工作区，而是git的版本库
关系  
![](https://www.runoob.com/wp-content/uploads/2015/02/1352126739_7909.jpg)
# git基本操作
git clone
git add
git commit
git pull
git checkout
git push
![](https://www.runoob.com/wp-content/uploads/2015/02/git-command.jpg)
说明：
workspace: 工作区  
staging area: 暂存区
local repository: 版本库、本地仓库
remote repository: 远程仓库
## git仓库创建命令
* git init [dir]
> 创建一个仓库
```shell
[root@VM-4-11-centos opt]# git init gitserver
Initialized empty Git repository in /opt/gitserver/.git/
[root@VM-4-11-centos opt]#
[root@VM-4-11-centos opt]# ls
bak_github  clone.log  containerd  data  gitserver  kafka  kafka_2.13-3.2.0  sentinel  software  time.log
[root@VM-4-11-centos opt]# cd gitserver/
[root@VM-4-11-centos gitserver]# ls -a
.  ..  .git
[root@VM-4-11-centos gitserver]#

```
* git clone [url]
> 克隆一个仓库,注意URL，登录的用户需要gitserver这个目录的权限
```shell
[root@VM-4-11-centos gitc]# git clone root@150.158.192.228:/opt/gitserver/
Cloning into 'gitserver'...
root@150.158.192.228's password:
warning: You appear to have cloned an empty repository.
[root@VM-4-11-centos gitc]# ls -a
.  ..  gitserver
[root@VM-4-11-centos gitc]#
```

## 提交与修改
* git add [file1] [file2]
> git status查看添加的内容
```shell
[root@VM-4-11-centos gitserver]# ls -a
.  ..  .git
[root@VM-4-11-centos gitserver]# touch 1.txt
[root@VM-4-11-centos gitserver]# touch 2.txt
[root@VM-4-11-centos gitserver]# git add
1.txt  2.txt
[root@VM-4-11-centos gitserver]# git add 1.txt 2.txt
[root@VM-4-11-centos gitserver]# git status
On branch master

No commits yet

Changes to be committed:
  (use "git rm --cached <file>..." to unstage)
        new file:   1.txt
        new file:   2.txt

[root@VM-4-11-centos gitserver]# touch 3.txt
[root@VM-4-11-centos gitserver]# git status
On branch master

No commits yet

Changes to be committed:
  (use "git rm --cached <file>..." to unstage)
        new file:   1.txt
        new file:   2.txt

Untracked files:
  (use "git add <file>..." to include in what will be committed)
        3.txt

[root@VM-4-11-centos gitserver]#

```

* git add [dir] [dir]
> 添加文件夹包含文件夹里面的文件，可以追加多个
* git add .
> 会递归添加本目录下的文件和文件夹
* git status [-s]
> 用于查看是否在上次提交之后对文件进行了修改。-s用于获取简短的输出
* git diff
> 1. 比较文件在工作区和暂存区的区别,新增文件并且没有add的话不会显示差异
> 2. 显示已写入缓存区和已修改但是没有写入缓存区的文件的差异
应用场景：
1. 工作区和缓存区的差异 git diff [file] [file]
add之后才会比较出差异
2. 显示暂存区和上一次提交的差异 git diff --cached [file] [file]  git diff --staged [file] [file]
3. 显示两次提交之前的差异 git diff [first-branch]...[second-branch]
* git commit -m "xx"
> 提交暂存区到本地仓库中
* git commit [file1] [file2] -m "xx"
> 提交制定的暂存区的文件到仓库中
* git commit -a
> 设置工作区的修改（必须是已经跟踪的文件，新增没有add过的文件不生效）不需要add直接提交到本地的版本库
* git reset [--soft | --mixed | --hard] [HEAD] [file] [file]
> 回退  
> --mixed : 默认的操作，只是把暂存区的修改会退到制定的提交点
> --soft :  
> --hard : 撤销工作区和暂存区的修改，并且删除之前所有的信息提交（指定提交点之后的记录都会被清除）
* git rm
> 1. 从暂存区删除，工作区保留，git rm --cached [file] [file]
> 2. 从工作区和暂存区删除，git rm [file]  强制删除 git rm -f [file]
* git mv [-f] [file] [newfile]
> 重命名或者移动文件

## 提交日志
* git log  git log --oneline
> git log查看提交记录  
> git log --oneline 查看简洁的信息
* git blame <file>
> 以列表形式查看指定文件的历史修改记录
## 远程操作
* git remote
> 用于对远程仓库的操作，
* git fetch
> 拉取远程分支的修改到本地，但是不会体现在工作区(需要git merge来合并)
* git pull
> git fetch + git merge
* git push
> 推动本地版本库到远程仓库
# 分支操作
* git branch xxx
> 创建一个xxx分支
* git checkout xxx
> 切换分支
* git merge  xxx
> 合并到当前分支下面

* git branch
> 列出分支
* git checkout -b xxx
> 创建分支并且切换到这个分支下面
* git branch -d xxx
> 删除分支
# 标签
* git tag
> 查看标签
* git tag -a v1.0
> 打标签，带注释（只是注释了下这个tag是谁打的）
* git tag -a -v2.0 xxx
> 对指定的提交建立tag
* git tag -a -m "发布"
> 打标签，带描述

