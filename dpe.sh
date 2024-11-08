#!/usr/bin/env bash

set -eu

# 脚本所在目录
CWD=$(dirname $(readlink -f "$0"))
# 相关目录
DIR_CONFIG=$CWD/config
DIR_DATA=$CWD/data
DIR_LOGS=$CWD/logs

# 输出
message() {
    if [[ $# -lt 1 ]]; then
        echo -e "> ------------------------------------------------"
        return
    fi

    echo -e "> $1"
}

# 初始化 docker-compose.yml 和 .env
init_startup_files() {
    local compose_file_example=$CWD/docker-compose.yml.example
    local compose_file=$CWD/docker-compose.yml
    local env_file_example=$CWD/.env.example
    local env_file=$CWD/.env

    message "初始化 docker-compose.yml"
    if [[ -f $compose_file ]]; then
        message "${compose_file} 文件已存在"
    else
        cp $compose_file_example $compose_file
        message "${compose_file} 初始化成功"
    fi

    message

    message "初始化 .env"
    if [[ -f $env_file ]]; then
        message "${env_file} 文件已存在"
    else
        cp $env_file_example $env_file
        message "${env_file} 初始化成功"
    fi
}

# 初始化配置
init_config() {
    if [[ $# -lt 1 ]]; then
        message "初始化配置"
        local p=$DIR_CONFIG
    else
        local p=$1
    fi

    if [[ ! -d $p ]]; then
        return
    fi

    for file in `ls -A ${p}`
    do
        local item=$p/$file
        if [[ -d $item ]]; then
            init_config $item
        elif [[ -f $item && ".gitignore" != "$file" ]]; then
            message "处理文件 ${item}"
            chmod 0644 $item
        fi
    done
}

# 初始化服务
init_services() {
    message "初始化 mysql"
    mkdir -p $DIR_DATA/mysql $DIR_LOGS/mysql
    chown 999:999 $DIR_DATA/mysql $DIR_LOGS/mysql
    chmod 1777 $DIR_DATA/mysql $DIR_LOGS/mysql

    message "初始化 redis"
    mkdir -p $DIR_DATA/redis
    chown 999:999 $DIR_DATA/redis
    chmod 1777 $DIR_DATA/redis

    message "初始化 php"
    mkdir -p \
        $DIR_DATA/composer \
        $DIR_LOGS/php83/supervisor \
        $DIR_LOGS/php82/supervisor \
        $DIR_LOGS/php81/supervisor \
        $DIR_LOGS/php80/supervisor \
        $DIR_LOGS/php74/supervisor \
        $DIR_LOGS/php73/supervisor \
        $DIR_LOGS/php83/log \
        $DIR_LOGS/php82/log \
        $DIR_LOGS/php81/log \
        $DIR_LOGS/php80/log \
        $DIR_LOGS/php74/log \
        $DIR_LOGS/php73/log
    chmod 0777 \
        $DIR_DATA/composer \
        $DIR_LOGS/php83/supervisor \
        $DIR_LOGS/php82/supervisor \
        $DIR_LOGS/php81/supervisor \
        $DIR_LOGS/php80/supervisor \
        $DIR_LOGS/php74/supervisor \
        $DIR_LOGS/php73/supervisor \
        $DIR_LOGS/php83/log \
        $DIR_LOGS/php82/log \
        $DIR_LOGS/php81/log \
        $DIR_LOGS/php80/log \
        $DIR_LOGS/php74/log \
        $DIR_LOGS/php73/log

    message "初始化 nginx"
    mkdir -p $DIR_LOGS/nginx
    chown 101:101 $DIR_LOGS/nginx
    chmod 1777 $DIR_LOGS/nginx

    message "初始化 rabbitmq"
    mkdir -p $DIR_DATA/rabbitmq $DIR_LOGS/rabbitmq
    chown 999:999 $DIR_DATA/rabbitmq $DIR_LOGS/rabbitmq
    chmod 1777 $DIR_DATA/rabbitmq $DIR_LOGS/rabbitmq

    message "初始化 mongodb"
    mkdir -p $DIR_DATA/mongodb $DIR_LOGS/mongodb
    chown 999:999 $DIR_DATA/mongodb $DIR_LOGS/mongodb
    chmod 1777 $DIR_DATA/mongodb $DIR_LOGS/mongodb

    message "初始化 elasticsearch"
    mkdir -p $DIR_DATA/elasticsearch $DIR_LOGS/elasticsearch
    chown 1000:1000 $DIR_DATA/elasticsearch $DIR_LOGS/elasticsearch
    chmod 1777 $DIR_DATA/elasticsearch $DIR_LOGS/elasticsearch

    message "初始化 clickhouse"
    mkdir -p $DIR_DATA/clickhouse $DIR_LOGS/clickhouse
    chown 101:101 $DIR_DATA/clickhouse $DIR_LOGS/clickhouse
    chmod ugo+Xrw $DIR_DATA/clickhouse $DIR_LOGS/clickhouse

    message "初始化 kafka"
    mkdir -p $DIR_DATA/kafka
    chown 1001:1001 $DIR_DATA/kafka
    chmod 1777 $DIR_DATA/kafka
}

# 清空数据
clean_data() {
    local compose_file=$CWD/docker-compose.yml
    message "正在停止 docker compose -f ${compose_file} down --volumes"
    docker compose -f "${compose_file}" down --volumes

    message "清理数据 ${DIR_DATA}"
    for file in `ls -A ${DIR_DATA}`
    do
        if [[ ".gitignore" != "$file" ]]; then
            message "删除 ${DIR_DATA}/${file}"
            rm -rf $DIR_DATA/$file
        fi
    done
}

# 清空日志
clean_logs() {
    message "清理日志 ${DIR_LOGS}"
    for file in `ls -A ${DIR_LOGS}`
    do
        if [[ ".gitignore" != "$file" ]]; then
            message "删除 ${DIR_LOGS}/${file}"
            rm -rf $DIR_LOGS/$file
        fi
    done
}

init() {
    message
    init_config
    message
    init_services
    message
    init_startup_files
    message
    message "初始化完成"
}

clean() {
    message
    clean_data
    message
    clean_logs
    message
    message "数据已清空"
}

usage() {
    cat << HELP
Usage: dpe.sh <init|clean>

# dpe.sh init     初始化目录和配置文件权限
# dpe.sh clean    删除现有的数据和日志文件
HELP
}

if [[ $# -ge 1 ]]; then
    case $1 in
        "init")
            init
            ;;
        "clean")
            clean
            ;;
        *)
            message "无效参数 ${1}"
            ;;
    esac
else
    usage
fi