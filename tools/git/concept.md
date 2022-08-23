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

* git add [dir]
* git add .
* git status
* git diff

* git commit
* git reset
* git rm
* git mv

## 提交日志
* git log
* git blame <file>
## 远程操作
* git remote
* git fetch
* git pull
* git push



