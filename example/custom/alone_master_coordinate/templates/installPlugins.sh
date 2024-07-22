#!/usr/bin/env bash

function do_log() {
    cur_time=$(date "+%Y-%m-%d %H:%M:%S")
    #custom log path
    echo  "[$1] "$cur_time" $2" >> /usr/share/elasticsearch/logs/start_script.log
}
do_log INFO "download plugin start....."
function checkPluginStatus ()
{
    local plugins=$(/usr/share/elasticsearch/bin/elasticsearch-plugin list)
    if [ $? != 0 ]; then
      return 1
        fi
        local pluginArray=(${plugins// / })

    for line in `cat /mnt/plugins/plugins-config-map`
    do
      local pluginName=${line%%,*}
      local isExist=0
          for var in ${pluginArray[@]}
          do
        if [ $var = $pluginName ]; then
          do_log INFO "expect install plugin:$pluginName  already install:${var%:*}"
          isExist=1
          break
        fi
      done
      if [ $isExist -eq 0 ]; then
            do_log ERROR "plugin: $pluginName install is fail $isExist"
        return 1
      fi
    done
        do_log INFO "plugin already install end"
}
for line in `cat /mnt/plugins/plugins-config-map`
do
    pluginName=${line%%,*}
    pluginUrl=${line#*,}
    do_log INFO "Install plugin:$pluginName URL:$pluginUrl"
    /usr/share/elasticsearch/bin/elasticsearch-plugin install -b $pluginUrl
    do_log INFO "Install plugin:$pluginName End"
done

# 根据需要安装的插件  检查当前集群是否已经安装
checkPluginStatus
if [ $? != 0 ]; then
  exit 1
fi
do_log INFO "download plugin end....."