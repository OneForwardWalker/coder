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
* git init
> 创建一个仓库

* git clone [url]
> 克隆一个仓库


## 提交与修改
* git add
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



