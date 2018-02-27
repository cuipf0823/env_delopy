# 配置说明
## 版本说明
该配置基于redis4.0.1

## RDB持久化配置
BGSAVE可以在不阻塞主进程的情况下完成数据的备份。可以通过redis.conf中设置多个自动保存条件，只要有一个条件被满足，服务器就会执行BGSAVE命令。

```
# 在900秒之内被修改了1次
save 900 1
# 在300秒之内被修改了10次
save 300 10
# 在60秒之内被修改了10000次
save 60 10000
```

## AOF持久化配置
和AOF持久化相关的配置

```
#AOF 和 RDB 持久化方式可以同时启动并且无冲突。  
#如果AOF开启，启动redis时会加载aof文件，这些文件能够提供更好的保证
appendonly yes

# 只增文件的文件名称。（默认是appendonly.aof）  
# appendfilename appendonly.aof
# redis支持三种不同的写入方式：   
# no:不调用，之等待操作系统来清空缓冲区当操作系统要输出数据时。很快。  
# always: 每次更新数据都写入仅增日志文件。慢，但是最安全。
# everysec: 每秒调用一次。折中。
appendfsync everysec  

# 设置为yes表示rewrite期间对新写操作不fsync,暂时存在内存中,等rewrite完成后再写入.官方文档建议如果你有特殊的情况可以配置为'yes'。但是配置为'no'是最为安全的选择。
no-appendfsync-on-rewrite no  

# 自动重写只增文件。  
# redis可以自动的调用‘BGREWRITEAOF’来重写日志文件，如果日志文件增长了指定的百分比。  
# 当前AOF文件大小是上次日志重写得到AOF文件大小的二倍时，自动启动新的日志重写过程。
auto-aof-rewrite-percentage 100  
# 当前AOF文件启动新的日志重写过程的最小值，避免刚刚启动Reids时由于文件尺寸较小导致频繁的重写。
auto-aof-rewrite-min-size 64mb

```
## 持久化配置总结

持久化方式采用RDB模式和AOF模式相结合方式;

## 主从复制配置
### 环境
* master redis

```
ip : 10.211.55.5
port: 6379
```

* slave redis

```
ip : 10.211.55.6
port: 6379
```

### 命令模式

* master redis正常启动;

```
redis-server /etc/redis/redis.conf
```

* slave redis 启动;

```
redis-server /etc/redis/redis.conf
```

* 分别使用redis-cli 执行**info replication**查看配置是否成功;

**master:**
![master配置成功](http://oaco4iuuu.bkt.clouddn.com/master_redis_info_replication.png)

**slave:**
![slave配置成功](http://oaco4iuuu.bkt.clouddn.com/redis_info_replication.png)

### 配置文件模式
只需要在从数据库的配置文件中添加 **slaveof 10.211.55.5 6379** 即可;

### 注意事项
如果配置完成, 查看配置状态出现 **master\_link\_status:down**; 
可能的原因有以下几个:

1. 主从机器防火墙没有关闭;
2. 主从使用的redis版本不一致;
3. 主设置密码情况下, 主从建立也会失败, 查看日志如下: 

> 解决方式: 在从配置文件加上配置项 **masterauth 123456**即可('123456'为主的auth密码); 
 
![redis日志错误](http://oaco4iuuu.bkt.clouddn.com/%E4%B8%BB%E4%BB%8E%E5%A4%8D%E5%88%B6%E9%94%99%E8%AF%AF.png)


# 修改项
* `bind 192.168.154.128` 修改绑定的IP地址;
* `logfile /var/log/redis/redis.log` 修改日志保存的位置;
* `loglevel debug` 修改日志级别, debug记录更多信息, 用于开发和测试;  
* `daemonize yes` 保证后台运行;
* `appendonly yes` 打开AOF持久化;
* `dir /var/redis/data/`修改RDB持久化文件和AOF持久化文件保存位置;
* `pidfile /var/run/redis.pid` 修改pid文件名;
* `requirepass 123456` 开启密码保护
