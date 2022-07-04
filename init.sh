#!/usr/bin/env bash

set -eu

# 脚本所在目录
CWD=$(dirname $(readlink -f "$0"))
# 数据目录
DIR_DATA=${CWD}/data
DIR_LOGS=${CWD}/logs
DIR_SERVICES=${CWD}/services

# 输出
message() {
    if [[ $# -lt 1 ]]; then
        return
    fi

    echo -e "# $1"
}

# 初始化 docker-compose.yml 和 .env 文件
init_startup_files() {
    message "进入 ${CWD}"
    cd $CWD

    message "正在初始化 docker-compose.yml"
    if [[ -f docker-compose.yml ]]; then
        message "docker-compose.yml 文件已存在"
    else
        cp docker-compose.yml.example docker-compose.yml
        message "docker-compose.yml 初始化成功"
    fi

    message "正在初始化 .env"
    if [[ -f .env ]]; then
        message ".env 文件已存在"
    else
        cp .env.example .env
        message ".env 初始化成功"
    fi
}

# 初始化 DIR_DATA
init_data() {
    if [[ $# -lt 1 ]]; then
        return
    fi

    if [[ ! -d $1 ]]; then
        message "${1} 不是有效的目录"
        return
    fi

    message "遍历目录 ${1}"
    for file in `ls -A ${1}`
    do
        local item=$1/$file
        if [[ -d $item ]]; then
            message "处理目录 ${item}"
            chmod 777 $item
            init_data $item
        fi
    done
}

# 初始化 DIR_LOGS
init_logs() {
    if [[ $# -lt 1 ]]; then
        return
    fi

    if [[ ! -d $1 ]]; then
        message "${1} 不是有效的目录"
        return
    fi

    message "遍历目录 ${1}"
    for file in `ls -A ${1}`
    do
        local item=$1/$file
        if [[ -d $item ]]; then
            message "处理目录 ${item}"
            chmod 777 $item
            init_logs $item
        fi
    done
}

# 初始化 DIR_SERVICES
init_services() {
    if [[ $# -lt 1 ]]; then
        return
    fi

    if [[ ! -d $1 ]]; then
        message "${1} 不是有效的目录"
        return
    fi

    message "遍历目录 ${1}"
    for file in `ls -A ${1}`
    do
        local item=$1/$file
        if [[ -d $item ]]; then
            message "处理目录 ${item}"
            chmod 777 $item
            init_services $item
        elif [[ -f $item ]]; then
            message "处理文件 ${item}"
            chmod 644 $item
        fi
    done
}

message "##############################################"
message "正在初始化文件"
message "##############################################"
init_startup_files

message "##############################################"
message "正在初始化 ${DIR_DATA}"
message "##############################################"
init_data $DIR_DATA

message "##############################################"
message "正在初始化 ${DIR_LOGS}"
message "##############################################"
init_logs $DIR_LOGS

message "##############################################"
message "正在初始化 ${DIR_SERVICES}"
message "##############################################"
init_services $DIR_SERVICES

message "##############################################"
message "处理完毕"
message "##############################################"