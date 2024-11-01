#!/usr/bin/env bash

set -eu

# 脚本所在目录
CWD=$(dirname $(readlink -f "$0"))
# 相关目录
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

    message "---------------------------------------------"

    message "正在初始化 .env"
    if [[ -f $env_file ]]; then
        message "${env_file} 文件已存在"
    else
        cp $env_file_example $env_file
        message "${env_file} 初始化成功"
    fi
}

# 初始化日志
init_logs() {
    message "正在初始化 ${DIR_LOGS}"
    chmod 777 $DIR_LOGS
    message "$DIR_LOGS 初始化成功"
}

# 初始化 DIR_SERVICES
init_services() {
    if [[ $# -lt 1 ]]; then
        message "正在初始化 ${DIR_SERVICES}"
        local p=$DIR_SERVICES
        chmod 777 $DIR_SERVICES
        message "处理目录 chmod 777 ${DIR_SERVICES}"
    else
        local p=$1
    fi

    if [[ ! -d $p ]]; then
        message "${p} 不是有效的目录"
        return
    fi

    # message "遍历目录 ${p}"
    for file in `ls -A ${p}`
    do
        local item=$p/$file
        if [[ -d $item ]]; then
            message "处理目录 chmod 777 ${item}"
            chmod 777 $item
            init_services $item
        elif [[ -f $item && ".gitignore" != "$file" ]]; then
            message "处理文件 chmod 644 ${item}"
            chmod 644 $item
        fi
    done
}

# 清空数据
clean_data() {
    local compose_file=$CWD/docker-compose.yml
    message "正在清理卷 docker compose -f ${compose_file} down --volumes"
    sudo docker compose -f "${compose_file}" down --volumes
}

# 清空日志
clean_logs() {
    message "正在清理日志 ${DIR_LOGS}"
    for file in `ls -A ${DIR_LOGS}`
    do
        if [[ ".gitignore" != "$file" ]]; then
            message "正在删除 rm -rf ${DIR_LOGS}/${file}"
            rm -rf "${DIR_LOGS}/${file}"
        fi
    done
}

init() {
    message "---------------------------------------------"
    init_startup_files
    message "---------------------------------------------"
    init_logs
    message "---------------------------------------------"
    init_services
    message "---------------------------------------------"
    message "初始化完成"
}

clean() {
    message "---------------------------------------------"
    clean_data
    message "---------------------------------------------"
    clean_logs
    message "---------------------------------------------"
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