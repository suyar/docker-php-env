本项目是一套用于 PHP 的 Docker 开发环境。

为什么会有这个项目：

1. 开箱即用，首次启动不需要进行构建，启动时间短
2. 所有镜像 `TZ` 环境变量都会生效
3. 限制 `docker logs` 日志大小
4. 等等...

大部分场景下，我们希望开箱即用。当然，凡事都有两面性，不需要构建的代价，就是对镜像的定制化能力变低，看个人取舍。

---

重要的事情说三遍：

**该项目仅适用于本地开发，不能直接用于生产环境**

**该项目仅适用于本地开发，不能直接用于生产环境**

**该项目仅适用于本地开发，不能直接用于生产环境**

---

目前支持开箱即用的服务有：

1. mysql:8.0.37-debian（官方镜像）
2. redis:7.0.15（官方镜像）
3. memcached:1（官方镜像）
4. PHP8.3/PHP8.2/PHP8.1/PHP8.0/PHP7.4/PHP7.3（基于官方的集成镜像 [suyar/php:x.x-integration](https://github.com/suyar/docker-php#%E9%9B%86%E6%88%90%E9%95%9C%E5%83%8F)）
5. nginx:1.26（官方镜像）
6. rabbitmq:3-management（官方镜像）
7. mongo:7.0（官方镜像）
8. elasticsearch:7.17.25（官方镜像）
9. kibana:7.17.25（官方镜像）
10. clickhouse-server:24.8（官方镜像）
11. kafka:3.8.1（bitnami镜像）

# 目录

- [1. 目录结构](#1-目录结构)
- [2. 快速使用](#2-快速使用)
- [3. PHP 扩展](#3-php-扩展)
    - [3.1 PHP 预置扩展](#31-php-预置扩展)
    - [3.2 安装 PHP 扩展](#32-安装-php-扩展)
    - [3.3 在 PHP 容器中执行命令](#33-在-php-容器中执行命令)
    - [3.4 使用 composer](#34-使用-composer)
    - [3.5 快捷操作](#35-快捷操作)
- [4. 常见问题](#4-常见问题)
    - [4.1 如何在其他容器中请求 nginx 配置的域名](#41-如何在其他容器中请求-nginx-配置的域名)
    - [4.2 在 PHP 容器中使用 cron 定时任务](#42-在-php-容器中使用-cron-定时任务)
    - [4.3 在 PHP 容器中使用 supervisor](#43-在-php-容器中使用-supervisor)
    - [4.4 清空服务数据](#44-清空服务数据)
- [License](#license)

## 1. 目录结构

```
/
├── logs                        日志存放目录
├── data                        数据存放目录
├── config
│   ├── clickhouse              ClickHouse 配置目录
│   ├── elasticsearch           Elasticsearch 配置目录
│   ├── mongodb                 MongoDB 配置目录
│   ├── mysql                   Mysql 配置目录
│   ├── nginx                   Nginx 配置目录
│   │   ├── conf.d              Nginx Vhost 配置目录
│   │   └── ssl                 Nginx 证书目录
│   ├── php73                   PHP7.3 配置目录
│   ├── php74                   PHP7.4 配置目录
│   ├── php80                   PHP8.0 配置目录
│   ├── php81                   PHP8.1 配置目录
│   ├── php82                   PHP8.2 配置目录
│   ├── php83                   PHP8.3 配置目录
│   ├── rabbitmq                Rabbitmq 配置目录
│   └── redis                   Redis 配置目录
├── .bash_aliases.example       .bash_aliases 示例配置
├── .env.example                .env 变量示例配置
├── docker-compose.yml.example  docker-compose 示例
├── dpe.sh                      初始化脚本
└── www                         默认项目代码挂载目录
```

## 2. 快速使用

1. 环境要求

    - Windows

        - 安装 [Docker Desktop](https://www.docker.com/products/docker-desktop/)
        - 安装 `wsl2`，建议安装 Ubuntu：`wsl --install -d Ubuntu`
        - 在 `Docker Desktop` 启用 `Use the WSL 2 base engine`
        - 在 `Docker Desktop` 启用 `WSL Integration`
        - 因为 `wsl2` 文件有挂载性能问题，该项目**必须**放在 `wsl2` 系统内，而不能放在 `/mnt/c` 或 `/mnt/d` 这种挂载目录下
        - 项目代码也建议放在 `wsl2` 系统内，使用 `vscode` 或 `phpstorm` 进行编辑开发

    - Linux

        - 安装 [Docker](https://docs.docker.com/engine/install/)
        - 安装 [Docker Compose](https://docs.docker.com/compose/install/)

    - MacOS

        - 未尝试

2. `clone` 项目

    > 建议 [**fork**](https://github.com/suyar/docker-php-env/fork) 本项目，方便针对自己的开发需求做定制。

    ```
    # git clone git@github.com:suyar/docker-php-env.git
    ```

3. 初始化项目

    该操作会初始化目录权限和相关文件：

    ```
    # cd docker-php-env
    # git config core.filemode false
    # sudo chmod +x dpe.sh
    # sudo ./dpe.sh init
    ```

    执行完成后，根据自己的需求，对 `.env` 文件和 `docker-compose.yml` 进行定制。

4. 启动项目

    ```
    # sudo docker-compose up -d
    ```

5. 在浏览器中访问：`http://localhost` 或 `http://127.0.0.1`，初始页面显示 `404`。

## 3. PHP 扩展

### 3.1 PHP 预置扩展

PHP 镜像默认安装了下列扩展，暂不支持重新安装指定版本扩展，可以 fork 本项目后，参照 [docker-php](https://github.com/suyar/docker-php) 自己构建。

```
[PHP Modules]
amqp
apcu
bcmath
bz2
calendar
Core
ctype
curl
date
decimal
dom
enchant
event
exif
fileinfo
filter
ftp
gd
gettext
gmp
hash
iconv
igbinary
imagick
intl
json
libxml
lzf
mbstring
memcached
mongodb
msgpack
mysqli
mysqlnd
openssl
pcntl
pcre
PDO
pdo_mysql
pdo_pgsql
pdo_sqlite
pgsql
Phar
posix
readline
redis
Reflection
session
SimpleXML
sockets
sodium
SPL
sqlite3
standard
swoole
tidy
timezonedb
tokenizer
uuid
xlswriter
xml
xmlreader
xmlwriter
xsl
yac
yaml
Zend OPcache
zip
zlib

[Zend Modules]
Zend OPcache
```

### 3.2 安装 PHP 扩展

除了预置的扩展，如果你还想安装其他扩展，可以直接执行：

```
# sudo docker-compose exec php83 install-php-extensions xxx
```

支持的扩展在这边可以在这边查看：[docker-php-extension-installer](https://github.com/mlocati/docker-php-extension-installer#supported-php-extensions)。

> 通过这种方式安装的扩展，在容器销毁后重新创建，不会保留，需要重新安装。

### 3.3 在 PHP 容器中执行命令

```
# sudo docker-compose exec php83 bash
root@php83:/www# php -v
```

### 3.4 使用 composer

```
# sudo docker-compose exec php83 bash
root@php83:/www# composer install
```

### 3.5 快捷操作

1. 把 [.bash_aliases.example](.bash_aliases.example) 的内容拷贝到 `~/.bash_aliases` 或 `~/.bashrc`
2. 修改 `~/.bash_aliases` 的变量 `DPE_COMPOSE` 和 `DPE_SOURCE`

    ```
    # docker-compose.yml 绝对路径
    DPE_COMPOSE=/home/suyar/repo/docker-php-env/docker-compose.yml
    # 挂载的 DIR_SOURCE 绝对路径
    DPE_SOURCE=/home/suyar/repo

    # 依葫芦画瓢配置其他版本PHP的快捷命令

    ...
    ```

3. 开始使用快捷命令

    ```
    # 进入 php83 容器，自动识别挂载目录中的相对路径
    $ tophp
    # 进入 php83 容器，自动识别挂载目录中的相对路径
    $ tophp83

    # 进入 nginx 容器，自动识别挂载目录中的相对路径
    $ tonginx

    # 进入 mysql 容器
    $ tomysql

    # 在宿主机执行 php 命令，自动识别挂载目录中的相对路径；如果宿主机有安装php，请在`~/.bash_aliases`中修改`php()`别名
    $ php
    $ php83

    # 在宿主机执行 composer 命令，自动识别挂载目录中的相对路径；如果宿主机有安装composer，请在`~/.bash_aliases`中修改`composer()`别名
    $ composer
    $ composer83
    ```

    > 关于 `自动识别挂载目录中的相对路径` 的效果如下：

    ① 假设 `.env` 配置如下：

    ```
    ...
    # 挂载到容器的目录
    DIR_SOURCE=/home/repo
    ...
    ```

    ② 假设 `~/.bash_aliases` 变量配置如下：

    ```
    # docker-php-env 挂载的 DIR_SOURCE 绝对路径
    DPE_SOURCE=/home/repo
    ```

    ③ 假设宿主机中，当前目录为 **`/home/repo/laravel`**

    那么我在宿主机执行 `tophp` 命令后：

    ```
    $ tophp
    root@php83:/www/laravel#
    ```

    可以看到，这时候默认进入到 `laravel` 目录。

    如果我在宿主机执行命令：

    ```
    $ php artisan list
    ```

    那么实际上，会在容器中的 `/www/laravel` 去执行 `php artisan list` 命令。

## 4 常见问题

### 4.1 如何在其他容器中请求 nginx 配置的域名

在 `docker-compose.yml` 文件中，修改 `nginx` 服务的 `aliases` 配置，把 `nginx` 相关的域名配置成别名：

```
  nginx:
    image: nginx:${NGINX_VERSION}
    environment:
      TZ: ${TZ}
    volumes:
      - ${DIR_SERVICES}/nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ${DIR_SERVICES}/nginx/conf.d:/etc/nginx/conf.d:ro
      - ${DIR_SERVICES}/nginx/ssl:/etc/nginx/ssl:ro
      - ${DIR_LOGS}/nginx:/var/log/nginx
      - ${DIR_SOURCE}:/www
    working_dir: /www
    ports:
      - "${NGINX_HTTP_HOST_PORT}:80"
      - "${NGINX_HTTPS_HOST_PORT}:443"
    networks:
      default:
        aliases:
          - example.laravel.local
          - test.biz.me
    restart: unless-stopped
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "1"
```

### 4.2 在 PHP 容器中使用 cron 定时任务

这里以 `php83` 容器举例：

1. 在 `DIR_SOURCE` 所在的目录或项目中，增加一个文件，例如创建 `www/laravel/schedule` 文件，并把定时任务写在里面：

```
* * * * * cd /www/laravel && php artisan schedule:run >> /dev/null 2>&1
```

2. 进入 PHP 容器，添加定时任务：

```
# sudo docker compose exec php83 bash
# crontab /www/laravel/schedule
```

### 4.3 在 PHP 容器中使用 supervisor

这里以 `php83` 容器举例：

1. 修改 `services/php83/supervisor.conf` 的内容
2. 重启 `php83` 容器

### 4.4 清空服务数据

在某些情况下，你可能需要清空各种生成的数据，重新初始化开发环境，

> 该操作是风险操作，会清空所有容器和持久化数据卷！！！

```
# sudo docker-compose down
# sudo ./dpe.sh clean
```

## License

MIT
