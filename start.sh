#!/bin/sh
set -e

func_init(){
    func_check_env
}

func_set_service_nodes(){
    mm=`echo $DEPEND_SERVICE | sed "s/,/ /g"`
    SERVICE_NODE=""
    if [[ "$PLUGIN_MOEL" == "net-plugin:up" ]];then
        SERVICE_NODE=$SERVICE_NAME
    fi 
    for nn in $mm 
    do 
        ALIAS=`echo $nn | awk -F ":" '{print $1}'`
        if [[ "$SERVICE_NODE" == "" ]];then
            SERVICE_NODE=$ALIAS
            continue
        fi
        SERVICE_NODE=$SERVICE_NODE"_"$ALIAS
    done
    echo $SERVICE_NODE
}

func_modify_conf(){
cat <<EOF>> $CONFIGPATH
{
  "listeners": [],
  "lds": {
    "cluster": "lds",
    "refresh_delay_ms": 3000
  },
  "admin": {
    "access_log_path": "/dev/null", 
    "address": "tcp://0.0.0.0:65534"
  },  
  "cluster_manager": {
    "sds": {
      "cluster": {
        "name": "sds", 
        "connect_timeout_ms": 250, 
        "type": "strict_dns", 
        "lb_type": "round_robin", 
        "hosts": [
          {
            "url": "tcp://${DISCOVERSERVER}:${DISCOVERPORT}"
          }
        ]
      }, 
      "refresh_delay_ms": 3000
    }, 
    "cds": {
      "cluster": {
        "name": "cds", 
        "connect_timeout_ms": 250, 
        "type": "strict_dns", 
        "lb_type": "round_robin", 
        "hosts": [
          {
            "url": "tcp://${DISCOVERSERVER}:${DISCOVERPORT}"
          }
        ]
      }, 
      "refresh_delay_ms": 3000
    }, 
    "clusters": [
      {
        "name": "lds", 
        "connect_timeout_ms": 250, 
        "type": "strict_dns", 
        "lb_type": "round_robin", 
        "hosts": [
          {
            "url": "tcp://${DISCOVERSERVER}:${DISCOVERPORT}"
          }
        ]
      }
    ]
  }
}
EOF
}

func_update_conf(){
    sed -i 's/DISCOVERSERVER/${DISCOVERSERVER}/g' $CONFIGPATH
    if [[ $? != 0 ]];then
        exit 8
    fi
    sed -i 's/DISCOVERPORT/$DISCOVERPORT/g' $CONFIGPATH
    if [[ $? != 0 ]];then
        exit 8
    fi
}

func_main(){
    func_init
    func_set_service_nodes
    func_modify_conf
    $ENVOY_BINARY -c $CONFIGPATH --service-cluster $TENANT_ID"_"$PLUGIN_ID"_"$SERVICE_NAME --service-node $SERVICE_NODE
}

func_check_env(){
    #@ DISCOVERSERVER DISCOVERPORT TENANT_ID DEPEND_SERVICE
    if [[ -z $DISCOVER_URL ]];then
        export DISCOVER_URL="http://172.30.42.1:6100/" 
    fi
    DISCOVERSERVER=`echo $DISCOVER_URL | awk -F "/" '{print $3}' | awk -F ":" '{print $1}'`
    DISCOVERPORT=`echo $DISCOVER_URL | awk -F "/" '{print $3}' | awk -F ":" '{print $2}'`
    if [[ -z $DISCOVERSERVER ]];then
        DISCOVERSERVER="127.0.0.1" 
        echo "env DISCOVERSERVER set to default localhost."
    fi
    if [[ -z $DISCOVERPORT ]];then
        DISCOVERPORT=6100 
        echo "env DISCOVERPORT set to default 6100"
    fi
    if [[ -z $CONFIGPATH ]];then
       CONFIGPATH="/root/envoy_config.json"
    fi
    if [[ -z $ENVOY_BINARY ]];then
        ENVOY_BINARY="/usr/local/bin/envoy"
    fi
    if [[ -z $TENANT_ID ]];then
        echo "need env TENANT_ID"
        exit 9
    fi
    if [[ -z $PLUGIN_ID ]];then
        echo "need env PLUGIN_ID"
        exit 9
    fi
}

func_test(){
    export DEPEND_SERVICE=gr6adef3:9a1576b6a4a8e3185646cdae916adef3,gr123123:678906781923123sdfssdfsgsgs,gr44444:adsfadfafadfasdfasdfasdf
    #DEPEND_SERVICE=gr6adef3:9a1576b6a4a8e3185646cdae916adef3
    export TENANT_ID=1b05123123124tenantid
    export SERVICE_NAME=grtest12
    export PLUGIN_ID=envoy123123123123
}

if [[ $1 == "test" ]];then
    func_test
fi

func_main
