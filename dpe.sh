#!/usr/bin/env bash

set -eu

# 脚本所在目录
CWD=$(dirname $(readlink -f "$0"))
# 相关目录
DIR_DATA=${CWD}/data
DIR_LOGS=${CWD}/logs
DIR_SERVICES=${CWD}/services
# 数据子目录
DATA_DIRS=(
    composer
    elasticsearch
    mongodb
    mysql5
    mysql8
    rabbitmq
    redis
)
# 日志子目录
LOGS_DIRS=(
    mongodb
    mysql/5
    mysql/8
    nginx
    php/73/log
    php/73/supervisor
    php/74/log
    php/74/supervisor
    php/80/log
    php/80/supervisor
    php/81/log
    php/81/supervisor
    php/82/log
    php/82/supervisor
    php/83/log
    php/83/supervisor
    rabbitmq
)

# 输出
message() {
    if [[ $# -lt 1 ]]; then
        return
    fi

    echo -e "# $1"
}

# 初始化 docker-compose.yml 和 .env 文件
init_startup_files() {
    local compose_file_example=$CWD/docker-compose.yml.example
    local compose_file=$CWD/docker-compose.yml
    local env_file_example=$CWD/.env.example
    local env_file=$CWD/.env

    message "正在初始化 docker-compose.yml"
    if [[ -f $compose_file ]]; then
        message "${compose_file} 文件已存在"
    else
        cp $compose_file_example $compose_file
        message "${compose_file} 初始化成功"
    fi

    message "正在初始化 .env"
    if [[ -f $env_file ]]; then
        message "${env_file} 文件已存在"
    else
        cp $env_file_example $env_file
        message "${env_file} 初始化成功"
    fi
}

# 初始化 DIR_DATA
init_data() {
    for d in ${DATA_DIRS[@]}
    do
        local item=$DIR_DATA/$d
        if [[ -d $item ]]; then
            message "处理目录 chmod 777 ${item}"
            chmod 777 $item
        fi
    done
}

# 初始化 DIR_LOGS
init_logs() {
    for d in ${LOGS_DIRS[@]}
    do
        local item=$DIR_LOGS/$d
        if [[ -d $item ]]; then
            message "处理目录 chmod 777 ${item}"
            chmod 777 $item
        fi
    done
}

# 初始化 DIR_SERVICES
init_services() {
    if [[ $# -lt 1 ]]; then
        local p=$DIR_SERVICES
    else
        local p=$1
    fi

    if [[ ! -d $p ]]; then
        message "${p} 不是有效的目录"
        return
    fi

    message "遍历目录 ${p}"
    for file in `ls -A ${p}`
    do
        local item=$p/$file
        if [[ -d $item ]]; then
            message "处理目录 chmod 777 ${item}"
            chmod 777 $item
            init_services $item
        elif [[ -f $item ]]; then
            message "处理文件 chmod 644 ${item}"
            chmod 644 $item
        fi
    done
}

# 清空数据
clean_data() {
    for d in ${DATA_DIRS[@]}
    do
        local item=$DIR_DATA/$d
        local item_ignore=$item/.gitignore
        if [[ -d $item && -f $item_ignore  ]]; then
            message "正在遍历 ${item}"
            for file in `ls -A ${item}`
            do
                if [[ ".gitignore" != "$file" ]]; then
                    message "正在删除 rm -rf ${item}/${file}"
                    rm -rf "${item}/${file}"
                fi
            done
        fi
    done
}

# 清空数据
clean_logs() {
    for d in ${LOGS_DIRS[@]}
    do
        local item=$DIR_LOGS/$d
        local item_ignore=$item/.gitignore
        if [[ -d $item && -f $item_ignore  ]]; then
            message "正在遍历 ${item}"
            for file in `ls -A ${item}`
            do
                if [[ ".gitignore" != "$file" ]]; then
                    message "正在删除 rm -rf ${item}/${file}"
                    rm -rf "${item}/${file}"
                fi
            done
        fi
    done
}

init() {
    message "---------------------------------------------"
    message "正在初始化文件"
    message "---------------------------------------------"
    init_startup_files

    message "---------------------------------------------"
    message "正在初始化 ${DIR_DATA}"
    message "---------------------------------------------"
    init_data

    message "---------------------------------------------"
    message "正在初始化 ${DIR_LOGS}"
    message "---------------------------------------------"
    init_logs

    message "---------------------------------------------"
    message "正在初始化 ${DIR_SERVICES}"
    message "---------------------------------------------"
    init_services

    message "---------------------------------------------"
    message "初始化完成"
    message "---------------------------------------------"
}

clean() {
    message "---------------------------------------------"
    message "正在清空 ${DIR_DATA}"
    message "---------------------------------------------"
    clean_data

    message "---------------------------------------------"
    message "正在清空 ${DIR_LOGS}"
    message "---------------------------------------------"
    clean_logs
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