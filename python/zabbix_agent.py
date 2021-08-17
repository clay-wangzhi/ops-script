# ~*~ coding:utf-8 ~*~
from zabbix_api import ZabbixAPI
import sys
import json

ZABBIX_SREVER = "http://192.168.16.126:10080"
USERNAME = "op"
PASSWORD = "opadmin@2018"
HOSTNAME = "h5_web_monitor"
urlname = sys.argv[1]
url = sys.argv[2]

def login(ZABBIX_SREVER, USERNAME, PASSWORD):
    zapi = ZabbixAPI(ZABBIX_SREVER)
    zapi.login(USERNAME, PASSWORD)
    return zapi

def gethostid(auth, HOSTNAME):
    json_obj = ZabbixAPI.json_obj(auth, 'host.get', params={ "filter": {"host":HOSTNAME}})
    request = ZabbixAPI.do_request(auth, json_obj)

    if request['result']:
        return request['result'][0]['hostid']
    else:
        print("找不到该主机")
        sys.exit(1)

def getapplicationid(auth, hostid):
    # try:
    #     json_obj = ZabbixAPI.json_obj(auth, 'application.create', params={"name": "Web监测","hostid": hostid})
    #     ZabbixAPI.do_request(auth, json_obj)
    # except Exception as e:
    #     print(e)
    json_obj = ZabbixAPI.json_obj(auth, 'application.get', params={"hostids": hostid})
    request = ZabbixAPI.do_request(auth, json_obj)
    for num in range(0, len(request['result'])):
        if request['result'][num]['name'] == 'Web':
            return request['result'][num]['applicationid']

def create_web_scenario(auth, urlname, url, hostid, applicationid):
    json_obj = ZabbixAPI.json_obj(auth, 'httptest.get', params={ "filter": {"name": urlname}})
    request = ZabbixAPI.do_request(auth, json_obj)
    if request['result']:
        print('该web监控已经添加过了')
    else:
        try:
            json_obj = ZabbixAPI.json_obj(auth, 'httptest.create',params={"name": urlname,"hostid": hostid,"applicationid": applicationid, "delay": '5m',"retries": '1', "steps": [ { 'name': urlname, 'url': url, 'timeout':'10', 'status_codes':'200', 'no': '1'} ] })
            ZabbixAPI.do_request(auth, json_obj)
        except Exception as e:
            print(e)

def create_trigger(auth, HOSTNAME,urlname):
    expression = "{"+"{0}:web.test.fail[{1}].last(0)".format(HOSTNAME, urlname)+"}"+">0"
    try:
        json_obj = ZabbixAPI.json_obj(auth, 'trigger.create', params={"description": "{0}访问失败".format(urlname),"expression": expression,"priority":5})
        ZabbixAPI.do_request(auth, json_obj)
    except Exception as e:
        print(e)

    expression = "{" + "{0}:web.test.rspcode[{1},{1}].last(0)".format(HOSTNAME, urlname) + "}" + "<>200"
    try:
        json_obj = ZabbixAPI.json_obj(auth, 'trigger.create', params={"description": "{0}访问异常".format(urlname),"expression": expression,"priority":4})
        ZabbixAPI.do_request(auth, json_obj)
    except Exception as e:
        print(e)
auth = login(ZABBIX_SREVER, USERNAME, PASSWORD)
hostid = gethostid(auth, HOSTNAME)
applicationid = getapplicationid(auth, hostid)

create_web_scenario(auth,urlname, url, hostid, applicationid)
create_trigger(auth, HOSTNAME, urlname)