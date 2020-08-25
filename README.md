# -NFS
离线部署nfs

# 离线手动部署 NFS /下方有自动部署教程

### NFS简介

NFS 是 Network FileSystem 的缩写，顾名思义就是网络文件存储系统，它最早是由 Sun 公司发展出来的，也是 FreeBSD 支持的文件系统中的一个，它允许网络中的计算机之间通过 TCP/IP 网络共享资源。通过 NFS，我们本地 NFS 的客户端应用可以透明地读写位于服务端 NFS 服务器上的文件，就像访问本地文件一样方便。简单的理解，NFS 就是可以透过网络，让不同的主机、不同的操作系统可以共享存储的服务。

NFS 在文件传送或信息传送过程中依赖于 RPC（Remote Procedure Call） 协议，即远程过程调用， NFS 的各项功能都必须要向 RPC 来注册，如此一来 RPC 才能了解 NFS 这个服务的各项功能 Port、PID、NFS 在服务器所监听的 IP 等，而客户端才能够透过 RPC 的询问找到正确对应的端口，所以，NFS 必须要有 RPC 存在时才能成功的提供服务，简单的理解二者关系：NFS是 一个文件存储系统，而 RPC 是负责信息的传输。



### 离线安装NFS

通过上边简要的介绍，我们知道 NFS 服务需要依赖 RPC 服务，所以这里 NFS 服务端需要安装 rpcbind 和 nfs-utils，客户端只需要安装 nfs-utils。

1.首先确认服务端系统是否已安装nfs

```
rpm -qa nfs-utils rpcbind
```

2.安装服务
如果计算机可以连接到互联网，则可以通过以下命令进行安装：

```
#服务端
yum install -y nfs-utils rpcbind
#客户端
yum install -y nfs-utils
```

但是，很多时候由于安全的原因不能联网，所以只能离线安装。
下载离线安装包,

```
libtirpc-0.2.4-0.15.el7.x86_64.rpm
rpcbind-0.2.0-47.el7.x86_64.rpm
```

```
#安装路径下的所有rpm包
rpm -Uvh *.rpm --nodeps --force
#安装特定的rpm包
rpm -hvi dejagnu-1.4.2-10.noarch.rpm
```

### 配置

1.在**服务端**创建一个共享目录 /data/share ，作为客户端挂载的远端入口，然后设置权限。

```
mkdir -p /data/share
chmod 755 /data/share
```

2.修改 NFS 配置文件 /etc/exports

```
vim /etc/exports
#配置单个ip
/data/share 192.168.0.130(rw,sync,insecure,no_subtree_check,no_root_squash)
/data/share 192.168.0.131(rw,sync,insecure,no_subtree_check,no_root_squash)
#配置ip段
/data/share 192.168.0.130/139(rw,sync,insecure,no_subtree_check,no_root_squash)
#配置所有ip可以挂载
/data/share *(rw,sync,insecure,no_subtree_check,no_root_squash)
```

说明:
/data/share-共享目录
192.168.0.130-IP地址，可以是特定的ip地址、ip地址段或所有可以访问的ip
rw,sync,insecure,no_subtree_check,no_root_squash-访问控制参数，具体参考下面列表。

| 参数             | 说明                                                         |
| ---------------- | ------------------------------------------------------------ |
| ro               | 只读                                                         |
| rw               | 读写                                                         |
| sync             | 同步共享-所有数据在请求时写入共享                            |
| async            | 异步共享-nfs 在写入数据前可以响应请求                        |
| secure           | nfs 通过 1024 以下的安全 TCP/IP 端口发送                     |
| insecure         | nfs 通过 1024 以上的端口发送                                 |
| wdelay           | 如果多个用户要写入 nfs 目录，则归组写入（默认）              |
| no_wdelay        | 如果多个用户要写入 nfs 目录，则立即写入，当使用 async 时，无需此设置 |
| hide             | 在 nfs 共享目录中不共享其子目录                              |
| no_hide          | 共享 nfs 目录的子目录                                        |
| subtree_check    | 如果共享 /usr/bin 之类的子目录时，强制 nfs 检查父目录的权限（默认） |
| no_subtree_check | 不检查父目录权限                                             |
| all_squash       | 共享文件的 UID 和 GID 映射匿名用户 anonymous，适合公用目录   |
| no_all_squash    | 保留共享文件的 UID 和 GID（默认）                            |
| root_squash      | root 用户的所有请求映射成如 anonymous 用户一样的权限（默认） |
| no_root_squash   | root 用户具有根目录的完全管理访问权限                        |
| anonuid=xxx      | 指定 nfs 服务器 /etc/passwd 文件中匿名用户的 UID             |
| anongid=xxx      | 指定 nfs 服务器 /etc/passwd 文件中匿名用户的 GID             |

### 启动服务并测试



1.启动rpc服务

```
service rpcbind start
#或者使用如下命令
/bin/systemctl start rpcbind.service
# 查看 NFS 服务项 rpc 服务器注册的端口列表
rpcinfo -p localhost 
```

2.启动nfs服务

```
service nfs start
#或者使用如下命令亦可
/bin/systemctl start nfs.service
# 启动 NFS 服务后 rpc 服务已经启用了对 NFS 的端口映射列表
# rpcinfo -p localhost
```

3.在另一台 Linux 上挂载目录
查看配置，showmount -e 192.168.0.130

\#新建目录 mkdir -p /share #挂载共享目录 mount 192.168.0.130:/data/share  /share #如果要卸载目录 umount  /share



# 自动部署教程
解压文件 执行 bash install.sh /<path1>/<path2> 根据需求给出共享目录
