#!/bin/bash
user=$HOME
sqldir=telemetry/sql
pydir=telemetry/py
db=$user/telemetry/sql/telemetry_factory.db
conf=$user/telemetry/conf.json
flows=$user/.node-red/flows.json

sudo apt update && sudo apt -y upgrade
echo "[Device] npm install better-sqlite3..."
npm install better-sqlite3 --prefix  ~/.node-red/
echo "[Device] npm install sqlalchemy..."
sudo pip3 install sqlalchemy

if [ ! -d "$sqldir" ]; then
  mkdir -p $sqldir
  echo "Create Sqlite Directory..."
  if [ ! -f "$db" ]; then
    sqlite3 "$db" "
    CREATE TABLE telemetry_local (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      create_at DATETIME DEFAULT (datetime('now', '+7 hours')),
      sent INTEGER DEFAULT 0,
      ts INTEGER NOT NULL,
      date_data TEXT,
      time_data TEXT,
      total_meter REAL,
      total_a REAL,
      total_b REAL,
      nta_meter REAL,
      ntb_meter REAL,
      ota_meter REAL,
      otb_meter REAL,
      total_work INTEGER,
      work_a INTEGER,
      work_b INTEGER,
      speed_main REAL,
      speed_take REAL
      );"

  sqlite3 "$db" "
  CREATE TABLE telemetry_meter (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    create_at DATETIME DEFAULT (datetime('now', '+7 hours')),
    m0 REAL,
    m1 REAL,
    m2 REAL,
    m3 REAL,
    m4 REAL,
    m5 REAL,
    m6 REAL,
    m7 REAL,
    m8 REAL,
    m9 REAL,
    m10 REAL,
    m11 REAL,
    m12 REAL,
    m13 REAL,
    m14 REAL,
    m15 REAL,
    m16 REAL,
    m17 REAL,
    m18 REAL,
    m19 REAL,
    m20 REAL,
    m21 REAL,
    m22 REAL,
    m23 REAL
  );"

  sqlite3 "$db" "
  CREATE TABLE telemetry_work (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    create_at DATETIME DEFAULT (datetime('now', '+7 hours')),
    w0 REAL,
    w1 REAL,
    w2 REAL,
    w3 REAL,
    w4 REAL,
    w5 REAL,
    w6 REAL,
    w7 REAL,
    w8 REAL,
    w9 REAL,
    w10 REAL,
    w11 REAL,
    w12 REAL,
    w13 REAL,
    w14 REAL,
    w15 REAL,
    w16 REAL,
    w17 REAL,
    w18 REAL,
    w19 REAL,
    w20 REAL,
    w21 REAL,
    w22 REAL,
    w23 REAL
  );"

  sqlite3 "$db" "
  CREATE TABLE telemetry_cloud (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    create_at DATETIME DEFAULT (datetime('now', '+7 hours')),
    sent INTEGER DEFAULT 0,
    ts INTEGER NOT NULL,
    total_meter REAL,
    total_a REAL,
    total_b REAL,
    nta_meter REAL,
    ntb_meter REAL,
    ota_meter REAL,
    otb_meter REAL,
    total_work INTEGER,
    work_a INTEGER,
    work_b INTEGER,
    hour_meter REAL,
    speed_main REAL,
    speed_take REAL
  );"
    echo "Create DataBase Succesfully..."
  else
    echo "Already has Database..."
  fi
else
  echo "Already has Sqlite Directory..."
fi

if [ ! -d "$pydir" ]; then
  mkdir -p $pydir
  cat << 'EOR' > "$pydir/requests_local.py"
from sqlalchemy import create_engine, Column, Integer, Float, DateTime, Text
from sqlalchemy.orm import declarative_base, sessionmaker
from datetime import datetime
import requests
import json
import socket

engine = create_engine("sqlite:////home/orangepi/telemetry/sql/telemetry_factory.db")
Session = sessionmaker(bind=engine)
session = Session()

Base = declarative_base()

class Telemetrylocal(Base):
    __tablename__ = "telemetry_local"

    id = Column(Integer, primary_key=True)
    create_at = Column(DateTime)
    sent = Column(Integer)
    ts = Column(Integer)
    date_data = Column(Text)
    time_data = Column(Text)
    total_meter = Column(Float)
    total_a = Column(Float)
    total_b = Column(Float)
    nta_meter = Column(Float)
    ntb_meter = Column(Float)
    ota_meter = Column(Float)
    otb_meter = Column(Float)
    total_work = Column(Integer)
    work_a = Column(Integer)
    work_b = Column(Integer)
    speed_main = Column(Float)
    speed_take = Column(Float)

class Telemetrymeter(Base):
    __tablename__ = "telemetry_meter"

    id = Column(Integer, primary_key=True)
    create_at = Column(DateTime)
    m0 = Column(Float)
    m1 = Column(Float)
    m2 = Column(Float)
    m3 = Column(Float)
    m4 = Column(Float)
    m5 = Column(Float)
    m6 = Column(Float)
    m7 = Column(Float)
    m8 = Column(Float)
    m9 = Column(Float)
    m10 = Column(Float)
    m11 = Column(Float)
    m12 = Column(Float)
    m13 = Column(Float)
    m14 = Column(Float)
    m15 = Column(Float)
    m16 = Column(Float)
    m17 = Column(Float)
    m18 = Column(Float)
    m19 = Column(Float)
    m20 = Column(Float)
    m21 = Column(Float)
    m22 = Column(Float)
    m23 = Column(Float)

class Telemetrywork(Base):
    __tablename__ = "telemetry_work"

    id = Column(Integer, primary_key=True)
    create_at = Column(DateTime)
    w0 = Column(Float)
    w1 = Column(Float)
    w2 = Column(Float)
    w3 = Column(Float)
    w4 = Column(Float)
    w5 = Column(Float)
    w6 = Column(Float)
    w7 = Column(Float)
    w8 = Column(Float)
    w9 = Column(Float)
    w10 = Column(Float)
    w11 = Column(Float)
    w12 = Column(Float)
    w13 = Column(Float)
    w14 = Column(Float)
    w15 = Column(Float)
    w16 = Column(Float)
    w17 = Column(Float)
    w18 = Column(Float)
    w19 = Column(Float)
    w20 = Column(Float)
    w21 = Column(Float)
    w22 = Column(Float)
    w23 = Column(Float)

def jsonRead(key, path):
    with open(path, 'r', encoding='utf-8') as file:
        data = json.load(file)
        return data[key]

def getLocalIP():
    with open('/tmp/localip/ip.json', 'r', encoding='utf-8') as file:
        data = json.load(file)
        return data["ip"]

def getTelemetry():
    #statements
    _ip = getLocalIP()
    
    tb_local = session.query(Telemetrylocal)\
        .filter(Telemetrylocal.sent == 0)\
        .order_by(Telemetrylocal.create_at)\
        .first()
    tb_meter = session.query(Telemetrymeter)\
        .filter(Telemetrymeter.id == tb_local.id)\
        .first()
    tb_work = session.query(Telemetrywork)\
        .filter(Telemetrywork.id == tb_local.id)\
        .first()

    jsonData = {
            'filesystem': {
                'date': tb_local.date_data,
                'time': tb_local.time_data,
                'ip': _ip,
                'date_data': tb_local.date_data,
                'timestamp': tb_local.ts
                },
            'values':{
                'meter':{
                    '0':tb_meter.m0,'1':tb_meter.m1,'2':tb_meter.m2,'3':tb_meter.m3,'4':tb_meter.m4,
                            '5':tb_meter.m5,'6':tb_meter.m6,'7':tb_meter.m7,'8':tb_meter.m8,'9':tb_meter.m9,
                    '10':tb_meter.m10,'11':tb_meter.m11,'12':tb_meter.m12,'13':tb_meter.m13,'14':tb_meter.m14,'15':tb_meter.m15,
                            '16':tb_meter.m16,'17':tb_meter.m17,'18':tb_meter.m18,'19':tb_meter.m19,'20':tb_meter.m20,
                            '21':tb_meter.m21,'22':tb_meter.m22,'23':tb_meter.m23
                    },
                'working':{
                    '0':tb_work.w0,'1':tb_work.w1,'2':tb_work.w2,'3':tb_work.w3,'4':tb_work.w4,
                            '5':tb_work.w5,'6':tb_work.w6,'7':tb_work.w7,'8':tb_work.w8,'9':tb_work.w9,
                    '10':tb_work.w10,'11':tb_work.w11,'12':tb_work.w12,'13':tb_work.w13,'14':tb_work.w14,'15':tb_work.w15,
                            '16':tb_work.w16,'17':tb_work.w17,'18':tb_work.w18,'19':tb_work.w19,'20':tb_work.w20,
                            '21':tb_work.w21,'22':tb_work.w22,'23':tb_work.w23
                    },
            'total':{
                        'meter':{
                    'total':tb_local.total_meter,
                    'totalA':tb_local.total_a,
                    'totalB':tb_local.total_b,
                    'NLA':tb_local.nta_meter,
                            'NLB':tb_local.ntb_meter,
                    'OTA':tb_local.ota_meter,
                                'OTB':tb_local.otb_meter  
                    },
                'working':{
                    'total':tb_local.total_work,
                    'totalA':tb_local.work_a,
                    'totalB':tb_local.work_b
                    }
                },
            'maintake':{
                    'main':{ 'now': tb_local.speed_main
                        },
                    'take':{ 'now': tb_local.speed_take
                        }
                }
            }
        }
    return jsonData

def httpRequests(payload):
    conf = "/home/orangepi/telemetry/conf.json"
    with open(conf, 'r', encoding='utf-8') as file:
        data = json.load(file)
        s = data["source"]
    url = f"http://192.168.0.9:1880/api/product/device-opi-datasource-{s}"
    data = payload
    try:
        response = requests.post(url, json=data, timeout=5)
        
        if  response.ok:
                tb_local = session.query(Telemetrylocal)\
                .filter(Telemetrylocal.sent == 0)\
                .order_by(Telemetrylocal.create_at)\
                .first()
                tb_local.sent = 1
                session.commit()
                print(f"ID: {tb_local.id}")
        else:
            print(response.status_code)
            print(response.json())
        #print(payload)
            
    except requests.exceptions.Timeout:
        print("เซิร์ฟเวอร์ตอบกลับช้าเกินไป (Timeout)")

    except Exception as e:
        print(f"!!!Error: {e}")

httpRequests(getTelemetry())
#print(getTelemetry())
EOR
  cat << 'EOQ' > "$pydir/requests_cloud.py"
from sqlalchemy import create_engine, Column, Integer, Float, DateTime, Text
from sqlalchemy.orm import declarative_base, sessionmaker
from datetime import datetime
import requests
import json

engine = create_engine("sqlite:////home/orangepi/telemetry/sql/telemetry_factory.db")
Session = sessionmaker(bind=engine)
session = Session()

Base = declarative_base()

def getGroup():
    with open('/home/orangepi/telemetry/conf.json', 'r', encoding='utf-8') as file:
        data = json.load(file)
        code = data['code']
        group = code[0]
        return group, code

token = "r8RQWM-MB2GpL5cO2sWZrHAfiAmt2i9SSgHdyZO5SevepE_qS1bQz-YZJemp4FHkmUXh59dX7Wzs7_KfSKw6dQ=="
host = "147.50.230.159"
port = "8088"
org = "ack-org"
bucket = "sql-loom_data"
mearsurement = "productions"
tuPle= getGroup()
code = tuPle[1]
group = tuPle[0]
tags = f"sector=Loom,groups={group},device={code}"
url = "http://" + host + ":" + port + "/api/v2/write"

class Telemetrycloud(Base):
    __tablename__ = "telemetry_cloud"

    id = Column(Integer, primary_key=True)
    create_at = Column(DateTime)
    sent = Column(Integer)
    ts = Column(Integer)
    total_meter = Column(Float)
    total_a = Column(Float)
    total_b = Column(Float)
    nta_meter = Column(Float)
    ntb_meter = Column(Float)
    ota_meter = Column(Float)
    otb_meter = Column(Float)
    total_work = Column(Integer)
    work_a = Column(Integer)
    work_b = Column(Integer)
    hour_meter = Column(Float)
    speed_main = Column(Float)
    speed_take = Column(Float)

def jsonRead(key, path):
    with open(path, 'r', encoding='utf-8') as file:
        data = json.load(file)
        return data[key]

def onelineTelemetry(mearsurement, tags):
    tb_cloud = session.query(Telemetrycloud)\
        .filter(Telemetrycloud.sent == 0)\
        .order_by(Telemetrycloud.create_at)\
        .first()

    if tb_cloud is None:
        return None, None  # ไม่มีข้อมูลรอส่ง

    fields = ",".join([
        f"m_h={tb_cloud.hour_meter}",
        f"total_meter={tb_cloud.total_meter}",
        f"totalA={tb_cloud.total_a}",
        f"totalB={tb_cloud.total_b}",
        f"NTA={tb_cloud.nta_meter}",
        f"NTB={tb_cloud.ntb_meter}",
        f"OTA={tb_cloud.ota_meter}",
        f"OTB={tb_cloud.otb_meter}",
        f"main={tb_cloud.speed_main}",
        f"take={tb_cloud.speed_take}"
    ])

    timestamp = tb_cloud.ts * 1_000_000
    #print(f"{mearsurement},{tags} {fields} {timestamp}", tb_cloud.id)
    return f"{mearsurement},{tags} {fields} {timestamp}", tb_cloud.id 


def httpsRequests(mea, tag):
    headers = {
        "Authorization": f"Token {token}",
        "Content-Type": "text/plain; charset=utf-8"
    }
    params = {
        "org": org,
        "bucket": bucket,
        "precision": "ns"
    }
    try:
        oneline, record_id = onelineTelemetry(mea, tag)

        if oneline is None:
            print("No pending records to send.")
            return

        response = requests.post(url, params=params, headers=headers, data=oneline, timeout=10)
        print(f"response: {response.reason}")

        if response.ok:
            tb_cloud =(
                    session.query(Telemetrycloud)
                    .filter(Telemetrycloud.id == record_id)
                    .first()
                    )
            tb_cloud.sent = 1
            session.commit()
            print(f"ID: {tb_cloud.id}")
        else:
            print(f"Code: {response.status_code}")

    except requests.exceptions.Timeout:
        print("!!!Timeout Err: (Timeout)")
    except Exception as e:
        print(f"!!! http function Error: {e}")

httpsRequests(mearsurement, tags)
EOQ
  echo "Create Python Directory..."
else
  echo "Already has Python Directory..."
fi

if [ ! -f "$conf" ]; then
  touch "$conf"
  code=$(cat $HOME/loom/influxdb/device.txt)
  source_=$(cat $HOME/loom/source.txt)
  cat << EOY > "$conf"
  {
    "code": "$code",
    "source": "$source_",
    "circumferance": 0,
    "gear-ratio": 0
  }
EOY
fi 

#node-red-flow
rm -rf "$flows"
cat << 'EON' > "$flows"
[
    {
        "id": "777823ab3e1fee97",
        "type": "tab",
        "label": "Logging V3.0.1",
        "disabled": false,
        "info": "",
        "env": []
    },
    {
        "id": "df4a94479416f0c4",
        "type": "subflow",
        "name": "Get IP",
        "info": "",
        "category": "Special node",
        "in": [
            {
                "x": 80,
                "y": 80,
                "wires": [
                    {
                        "id": "5198508231fcf8a8"
                    }
                ]
            }
        ],
        "out": [],
        "env": [],
        "meta": {},
        "color": "#ff6100",
        "icon": "node-red/white-globe.svg",
        "status": {
            "x": 480,
            "y": 60,
            "wires": [
                {
                    "id": "f3b472b4726bfeec",
                    "port": 0
                }
            ]
        }
    },
    {
        "id": "a67f25631bef1988",
        "type": "subflow",
        "name": "Global",
        "info": "",
        "category": "Special node",
        "in": [
            {
                "x": 60,
                "y": 80,
                "wires": [
                    {
                        "id": "59eb51568d8158c9"
                    }
                ]
            }
        ],
        "out": [],
        "env": [],
        "meta": {},
        "color": "#046a3b",
        "icon": "font-awesome/fa-globe",
        "status": {
            "x": 360,
            "y": 80,
            "wires": [
                {
                    "id": "23bad38c2d77961c",
                    "port": 0
                }
            ]
        }
    },
    {
        "id": "13f006802899e0be",
        "type": "subflow",
        "name": "Ping",
        "info": "",
        "category": "Special Node",
        "in": [
            {
                "x": 60,
                "y": 80,
                "wires": [
                    {
                        "id": "633e9c4b40e42584"
                    }
                ]
            }
        ],
        "out": [],
        "env": [],
        "meta": {},
        "color": "#ffb900",
        "icon": "font-awesome/fa-chain",
        "status": {
            "x": 560,
            "y": 140,
            "wires": [
                {
                    "id": "346948538b2e924a",
                    "port": 0
                }
            ]
        }
    },
    {
        "id": "31057fe0b0d4c1ec",
        "type": "subflow",
        "name": "Blink",
        "info": "input\r\n - msg.",
        "category": "Lamp",
        "in": [
            {
                "x": 40,
                "y": 40,
                "wires": [
                    {
                        "id": "db6fc316f972fc7a"
                    }
                ]
            }
        ],
        "out": [],
        "env": [],
        "meta": {},
        "color": "#ef42f5",
        "icon": "font-awesome/fa-lightbulb-o"
    },
    {
        "id": "e226ede58ea4b202",
        "type": "subflow",
        "name": "Modbus & Alarm",
        "info": "",
        "category": "Special Node",
        "in": [],
        "out": [],
        "env": [],
        "meta": {},
        "color": "#6229ff",
        "icon": "node-red/alert.svg",
        "status": {
            "x": 380,
            "y": 220,
            "wires": [
                {
                    "id": "c5418b2844d316d7",
                    "port": 0
                }
            ]
        }
    },
    {
        "id": "aa3c99c011a59edd",
        "type": "subflow",
        "name": "conf.Set",
        "info": "input\r\n - Data config to config.txt file",
        "category": "Special Node",
        "in": [
            {
                "x": 50,
                "y": 30,
                "wires": [
                    {
                        "id": "67264d9b0e343db6"
                    }
                ]
            }
        ],
        "out": [],
        "env": [],
        "meta": {},
        "color": "#ff834a",
        "icon": "node-red/cog.svg",
        "status": {
            "x": 760,
            "y": 60,
            "wires": [
                {
                    "id": "4fa647803c42f119",
                    "port": 0
                }
            ]
        }
    },
    {
        "id": "b7d6774c49a75902",
        "type": "subflow",
        "name": "File",
        "info": "",
        "category": "Special Node",
        "in": [
            {
                "x": 60,
                "y": 80,
                "wires": [
                    {
                        "id": "9ac210c7c0b99891"
                    }
                ]
            }
        ],
        "out": [
            {
                "x": 320,
                "y": 80,
                "wires": [
                    {
                        "id": "5730377ef1841b85",
                        "port": 0
                    }
                ]
            }
        ],
        "env": [],
        "meta": {},
        "color": "#FFFFFF",
        "icon": "node-red/file.svg",
        "status": {
            "x": 480,
            "y": 120,
            "wires": [
                {
                    "id": "0d197ce9478787bb",
                    "port": 0
                }
            ]
        }
    },
    {
        "id": "341bdc3e7e68ae46",
        "type": "subflow",
        "name": "conf.Get",
        "info": "input\r\n - msg.\r\noutput\r\n - msg.payload (config.txt)",
        "category": "Special Node",
        "in": [
            {
                "x": 50,
                "y": 130,
                "wires": [
                    {
                        "id": "7dcb29351996d6be"
                    },
                    {
                        "id": "258890b7306744af"
                    },
                    {
                        "id": "8e7c7d80304fe097"
                    },
                    {
                        "id": "d6c523303ab0a091"
                    }
                ]
            }
        ],
        "out": [],
        "env": [],
        "meta": {},
        "color": "#ff834a",
        "icon": "node-red/cog.svg",
        "status": {
            "x": 640,
            "y": 80,
            "wires": [
                {
                    "id": "24e85514de7978d5",
                    "port": 0
                }
            ]
        }
    },
    {
        "id": "424004941bcb3307",
        "type": "subflow",
        "name": "Product.csv",
        "info": "",
        "category": "Special Node",
        "in": [
            {
                "x": 50,
                "y": 30,
                "wires": [
                    {
                        "id": "3925be8bad2bdf74"
                    }
                ]
            }
        ],
        "out": [
            {
                "x": 560,
                "y": 40,
                "wires": [
                    {
                        "id": "0a3028182b518b6e",
                        "port": 0
                    }
                ]
            }
        ],
        "env": [],
        "meta": {},
        "color": "#00c500",
        "icon": "node-red-contrib-filesystem/fs-mkdir.svg"
    },
    {
        "id": "a007640620fd4d52",
        "type": "subflow",
        "name": "Commu",
        "info": "Input\r\n- msg.",
        "category": "Lamp",
        "in": [
            {
                "x": 40,
                "y": 40,
                "wires": [
                    {
                        "id": "6f98bf351570cfd0"
                    }
                ]
            }
        ],
        "out": [],
        "env": [],
        "meta": {},
        "color": "#6C00FF",
        "icon": "node-red/light.svg"
    },
    {
        "id": "77aa6425a6e4878c",
        "type": "subflow",
        "name": "Delete",
        "info": "",
        "category": "Special Node",
        "in": [
            {
                "x": 60,
                "y": 80,
                "wires": [
                    {
                        "id": "9112ab91340ace88"
                    }
                ]
            }
        ],
        "out": [],
        "env": [],
        "meta": {},
        "color": "#1d84ff",
        "icon": "font-awesome/fa-close"
    },
    {
        "id": "a6ecc454e1b3c0c3",
        "type": "subflow",
        "name": "API",
        "info": "",
        "category": "Special Node",
        "in": [],
        "out": [
            {
                "x": 980,
                "y": 60,
                "wires": []
            }
        ],
        "env": [],
        "meta": {},
        "color": "#00e4ff",
        "icon": "font-awesome/fa-cloud-upload",
        "status": {
            "x": 980,
            "y": 120,
            "wires": []
        }
    },
    {
        "id": "7a70a201eaa0a148",
        "type": "subflow",
        "name": "Count",
        "info": "",
        "category": "Special Node",
        "in": [
            {
                "x": 60,
                "y": 80,
                "wires": [
                    {
                        "id": "329b2dc06d31e4a6"
                    }
                ]
            }
        ],
        "out": [],
        "env": [],
        "meta": {},
        "color": "#fca903",
        "icon": "font-awesome/fa-plus-circle",
        "status": {
            "x": 420,
            "y": 80,
            "wires": [
                {
                    "id": "6bf085a9f0b65ea1",
                    "port": 0
                }
            ]
        }
    },
    {
        "id": "f1016d6dfc436da7",
        "type": "subflow",
        "name": "Power.csv",
        "info": "",
        "category": "Special Node",
        "in": [
            {
                "x": 50,
                "y": 30,
                "wires": [
                    {
                        "id": "ef469af3a6dd75f8"
                    }
                ]
            }
        ],
        "out": [
            {
                "x": 380,
                "y": 40,
                "wires": [
                    {
                        "id": "562f9af20391c406",
                        "port": 0
                    }
                ]
            },
            {
                "x": 380,
                "y": 80,
                "wires": [
                    {
                        "id": "580c9972ff966756",
                        "port": 0
                    }
                ]
            }
        ],
        "env": [],
        "meta": {},
        "color": "#f3dd00",
        "icon": "font-awesome/fa-inbox"
    },
    {
        "id": "78457dab5d6c0503",
        "type": "subflow",
        "name": "Device Log",
        "info": "",
        "category": "Special Node",
        "in": [
            {
                "x": 60,
                "y": 120,
                "wires": [
                    {
                        "id": "18936721347779ca"
                    },
                    {
                        "id": "5bd37418f0f1f7c3"
                    }
                ]
            }
        ],
        "out": [],
        "env": [],
        "meta": {},
        "color": "#a1a5ff",
        "icon": "node-red/alert.svg",
        "status": {
            "x": 360,
            "y": 180,
            "wires": [
                {
                    "id": "656d5fdf90f37195",
                    "port": 0
                }
            ]
        }
    },
    {
        "id": "9f979da7e8a5400d",
        "type": "subflow",
        "name": "Dashboard",
        "info": "",
        "category": "Special Node",
        "in": [],
        "out": [],
        "env": [],
        "meta": {},
        "color": "#ff3636",
        "icon": "node-red-contrib-chartjs/pie_chart.png"
    },
    {
        "id": "1406c468fdce7358",
        "type": "subflow",
        "name": "Telegram http",
        "info": "",
        "category": "",
        "in": [
            {
                "x": 60,
                "y": 80,
                "wires": [
                    {
                        "id": "62597ed5138d084d"
                    }
                ]
            }
        ],
        "out": [
            {
                "x": 480,
                "y": 80,
                "wires": [
                    {
                        "id": "fbda616582fab4cb",
                        "port": 0
                    }
                ]
            }
        ],
        "env": [],
        "meta": {},
        "color": "#03befc",
        "icon": "font-awesome/fa-send"
    },
    {
        "id": "c9bf91fd5c385f43",
        "type": "subflow",
        "name": "state upTime",
        "info": "",
        "category": "Special Node",
        "in": [],
        "out": [],
        "env": [],
        "meta": {},
        "color": "#fcba03",
        "icon": "font-awesome/fa-clock-o",
        "status": {
            "x": 380,
            "y": 80,
            "wires": [
                {
                    "id": "d6a67c89385322a2",
                    "port": 0
                }
            ]
        }
    },
    {
        "id": "062d9ee6cb5e367f",
        "type": "subflow",
        "name": "Sensor Check",
        "info": "",
        "category": "Special Node",
        "in": [],
        "out": [],
        "env": [],
        "meta": {},
        "color": "#87A980",
        "status": {
            "x": 370,
            "y": 160,
            "wires": [
                {
                    "id": "2a334b79d30a7edf",
                    "port": 0
                }
            ]
        }
    },
    {
        "id": "0955db65ef90de77",
        "type": "subflow",
        "name": "file.check",
        "info": "",
        "category": "Special Node",
        "in": [
            {
                "x": 80,
                "y": 80,
                "wires": [
                    {
                        "id": "c8bab0630c3face5"
                    }
                ]
            }
        ],
        "out": [
            {
                "x": 340,
                "y": 80,
                "wires": [
                    {
                        "id": "e11a1a6dd2f8c8a8",
                        "port": 0
                    }
                ]
            }
        ],
        "env": [],
        "meta": {},
        "color": "#f54b38",
        "icon": "node-red/alert.svg",
        "status": {
            "x": 520,
            "y": 120,
            "wires": [
                {
                    "id": "7c86c33ac7b08415",
                    "port": 0
                }
            ]
        }
    },
    {
        "id": "a066bed2a8b32b55",
        "type": "subflow",
        "name": "Log data",
        "info": "",
        "category": "Special Node",
        "in": [
            {
                "x": 50,
                "y": 30,
                "wires": [
                    {
                        "id": "6c808f1a218f66a9"
                    }
                ]
            }
        ],
        "out": [
            {
                "x": 400,
                "y": 80,
                "wires": [
                    {
                        "id": "3e114699b2488fb5",
                        "port": 0
                    }
                ]
            },
            {
                "x": 400,
                "y": 120,
                "wires": [
                    {
                        "id": "4cb165e39114d74f",
                        "port": 0
                    }
                ]
            }
        ],
        "env": [],
        "meta": {},
        "color": "#24d6bc",
        "icon": "node-red/file-out.svg"
    },
    {
        "id": "b79372892403a995",
        "type": "subflow",
        "name": "influxdb count record",
        "info": "",
        "category": "Special Node",
        "in": [
            {
                "x": 80,
                "y": 60,
                "wires": [
                    {
                        "id": "1de45ed9d0cc17fc"
                    }
                ]
            }
        ],
        "out": [],
        "env": [],
        "meta": {},
        "color": "#f58d38",
        "icon": "node-red-contrib-filesystem/fs-list.svg",
        "status": {
            "x": 460,
            "y": 80,
            "wires": [
                {
                    "id": "2ac7d1492075c499",
                    "port": 0
                }
            ]
        }
    },
    {
        "id": "8ddcb67ae457f9bd",
        "type": "subflow",
        "name": "",
        "info": "",
        "category": "",
        "in": [],
        "out": [],
        "env": [],
        "meta": {},
        "color": "#DDAA99"
    },
    {
        "id": "e00c4e6a600c30c1",
        "type": "subflow",
        "name": "SQL Local Manage",
        "info": "",
        "category": "Special Node",
        "in": [
            {
                "x": 50,
                "y": 30,
                "wires": [
                    {
                        "id": "7d159003d1750924"
                    }
                ]
            }
        ],
        "out": [
            {
                "x": 260,
                "y": 40,
                "wires": [
                    {
                        "id": "7d159003d1750924",
                        "port": 0
                    }
                ]
            }
        ],
        "env": [],
        "meta": {},
        "color": "#ff4800",
        "icon": "node-red-node-sqlite/sqlite.png",
        "status": {
            "x": 390,
            "y": 100,
            "wires": [
                {
                    "id": "489db06ddb352de2",
                    "port": 0
                }
            ]
        }
    },
    {
        "id": "2f865af03ad61429",
        "type": "subflow",
        "name": "conf",
        "info": "",
        "category": "Special Node",
        "in": [
            {
                "x": 60,
                "y": 80,
                "wires": [
                    {
                        "id": "1e59f464dfa9648d"
                    }
                ]
            }
        ],
        "out": [],
        "env": [],
        "meta": {},
        "color": "#34ebdb",
        "icon": "node-red/cog.svg"
    },
    {
        "id": "451150a92cfdb00f",
        "type": "group",
        "z": "777823ab3e1fee97",
        "name": "System management",
        "style": {
            "stroke": "#ff0000",
            "fill": "#000000",
            "fill-opacity": "0.89",
            "label": true,
            "label-position": "n",
            "color": "#ffC000"
        },
        "nodes": [
            "9827f5270df78aba",
            "cb4e9770746b4c2d",
            "641e370bc218b3e1",
            "e6290a07b12de109",
            "b0abde57f8695277",
            "a241e24d2a8bd154",
            "b57537dcf374507c",
            "8f882b3c1846c4d2",
            "c974acb909bd6616"
        ],
        "x": 34,
        "y": 239,
        "w": 612,
        "h": 149.5
    },
    {
        "id": "6be6c492a2953951",
        "type": "group",
        "z": "777823ab3e1fee97",
        "name": "Modbus management",
        "style": {
            "stroke": "#ff0000",
            "fill": "#000000",
            "fill-opacity": "0.86",
            "label": true,
            "label-position": "n",
            "color": "#ffC000"
        },
        "nodes": [
            "d53e6b2f26983416",
            "0a51b58526c3eac5",
            "1a7e9f67f1527628",
            "0eb02406f8dff0ba",
            "ed51c14eaa7633a7",
            "51f8481c029f9f8d",
            "2b24aa05aa5379ed",
            "f2925150b152ddfd",
            "fd6dded7e0aa82a2",
            "fe159939e00a876e",
            "bf3e0be307587739",
            "f54eda370da4361a",
            "ddb434094e4d4a5d"
        ],
        "x": 34,
        "y": 19,
        "w": 692,
        "h": 202
    },
    {
        "id": "b5c344a321b1b503",
        "type": "group",
        "z": "777823ab3e1fee97",
        "name": "Sql management",
        "style": {
            "stroke": "#ff4800",
            "fill": "#000000",
            "fill-opacity": "1",
            "label": true,
            "label-position": "n",
            "color": "#ffC000"
        },
        "nodes": [
            "ed565787aa8ad39b",
            "86260ad292f188d3",
            "5f4722c77c0dc26f",
            "321c102f9e2881e8",
            "0d7c4fd373df7634",
            "ac29116d0411fcab"
        ],
        "x": 34,
        "y": 399,
        "w": 552,
        "h": 122
    },
    {
        "id": "291667434678740d",
        "type": "modbus-client",
        "name": "",
        "clienttype": "serial",
        "bufferCommands": true,
        "stateLogEnabled": false,
        "queueLogEnabled": false,
        "failureLogEnabled": true,
        "tcpHost": "127.0.0.1",
        "tcpPort": "502",
        "tcpType": "DEFAULT",
        "serialPort": "/dev/ttyUSB0",
        "serialType": "RTU-BUFFERD",
        "serialBaudrate": "9600",
        "serialDatabits": "8",
        "serialStopbits": "1",
        "serialParity": "none",
        "serialConnectionDelay": "100",
        "serialAsciiResponseStartDelimiter": "0x3A",
        "unit_id": 1,
        "commandDelay": 1,
        "clientTimeout": 1000,
        "reconnectOnTimeout": true,
        "reconnectTimeout": 2000,
        "parallelUnitIdsAllowed": true,
        "showWarnings": true,
        "showLogs": true
    },
    {
        "id": "d6f3a7fd07525d85",
        "type": "ui-base",
        "name": "myDashboard",
        "path": "/dashboard",
        "appIcon": "",
        "includeClientData": true,
        "acceptsClientConfig": [
            "ui-notification",
            "ui-control"
        ],
        "showPathInSidebar": false,
        "headerContent": "page",
        "navigationStyle": "default",
        "titleBarStyle": "default",
        "showReconnectNotification": true,
        "notificationDisplayTime": 1,
        "showDisconnectNotification": true,
        "allowInstall": false
    },
    {
        "id": "93042030270d6867",
        "type": "ui-theme",
        "name": "ui_template.themes.defaultTheme",
        "colors": {
            "surface": "#2e2e2e",
            "primary": "#0094ce",
            "bgPage": "#2e2e2e",
            "groupBg": "#2e2e2e",
            "groupOutline": "#2e2e2e"
        },
        "sizes": {
            "density": "default",
            "pagePadding": "12px",
            "groupGap": "12px",
            "groupBorderRadius": "4px",
            "widgetGap": "12px"
        }
    },
    {
        "id": "20308079d89423ea",
        "type": "ui-page",
        "name": "HOME",
        "ui": "d6f3a7fd07525d85",
        "path": "/config",
        "icon": "home",
        "layout": "tabs",
        "theme": "93042030270d6867",
        "breakpoints": [
            {
                "name": "Default",
                "px": "0",
                "cols": "3"
            },
            {
                "name": "Tablet",
                "px": "576",
                "cols": "6"
            },
            {
                "name": "Small Desktop",
                "px": "768",
                "cols": "9"
            },
            {
                "name": "Desktop",
                "px": "1024",
                "cols": "12"
            }
        ],
        "order": 1,
        "className": "",
        "visible": "true",
        "disabled": "false"
    },
    {
        "id": "93ca67d43751815a",
        "type": "ui-page",
        "name": "Data Source",
        "ui": "d6f3a7fd07525d85",
        "path": "/page2",
        "icon": "home",
        "layout": "grid",
        "theme": "93042030270d6867",
        "breakpoints": [
            {
                "name": "Default",
                "px": "0",
                "cols": "3"
            },
            {
                "name": "Tablet",
                "px": "576",
                "cols": "6"
            },
            {
                "name": "Small Desktop",
                "px": "768",
                "cols": "9"
            },
            {
                "name": "Desktop",
                "px": "1024",
                "cols": "12"
            }
        ],
        "order": 2,
        "className": "",
        "visible": "true",
        "disabled": "false"
    },
    {
        "id": "4d19f97e8673be96",
        "type": "ui-group",
        "name": "1",
        "page": "93ca67d43751815a",
        "width": 6,
        "height": 1,
        "order": 1,
        "showTitle": false,
        "className": "",
        "visible": "true",
        "disabled": "false",
        "groupType": "default"
    },
    {
        "id": "d50d0c9f.31e858",
        "type": "tls-config",
        "name": "",
        "cert": "",
        "key": "",
        "ca": "",
        "certname": "",
        "keyname": "",
        "caname": "",
        "servername": "",
        "verifyservercert": false
    },
    {
        "id": "5fafb36921f04d5b",
        "type": "sqlitedb",
        "db": "/home/orangepi/telemetry/sql/telemetry_factory.db",
        "mode": "RW"
    },
    {
        "id": "952156841f214b55",
        "type": "ui-group",
        "name": "Configuration",
        "page": "20308079d89423ea",
        "width": "12",
        "height": 1,
        "order": 1,
        "showTitle": false,
        "className": "",
        "visible": "true",
        "disabled": "false",
        "groupType": "default"
    },
    {
        "id": "d850f97a7e8193d4",
        "type": "ui-group",
        "name": "config",
        "page": "20308079d89423ea",
        "width": "5",
        "height": 1,
        "order": 2,
        "showTitle": true,
        "className": "",
        "visible": "false",
        "disabled": "false",
        "groupType": "dialog"
    },
    {
        "id": "944ab507dd3ee076",
        "type": "ui-group",
        "name": "Local Server Logging",
        "page": "20308079d89423ea",
        "width": "12",
        "height": 1,
        "order": 3,
        "showTitle": true,
        "className": "",
        "visible": "true",
        "disabled": "false",
        "groupType": "default"
    },
    {
        "id": "67124f90455eaec9",
        "type": "ui-group",
        "name": "Cloud Server Logging",
        "page": "20308079d89423ea",
        "width": "12",
        "height": 1,
        "order": 4,
        "showTitle": true,
        "className": "",
        "visible": "true",
        "disabled": "false",
        "groupType": "default"
    },
    {
        "id": "339734e2e645c9d0",
        "type": "ui-group",
        "name": "Meter Table Local Logging",
        "page": "20308079d89423ea",
        "width": 6,
        "height": 1,
        "order": 5,
        "showTitle": true,
        "className": "",
        "visible": "true",
        "disabled": "false",
        "groupType": "default"
    },
    {
        "id": "81b4388472b9bbd6",
        "type": "ui-group",
        "name": "Working Time Local Logging",
        "page": "20308079d89423ea",
        "width": 6,
        "height": 1,
        "order": 6,
        "showTitle": true,
        "className": "",
        "visible": "true",
        "disabled": "false",
        "groupType": "default"
    },
    {
        "id": "e8aecb5c6e078bca",
        "type": "ui-spacer",
        "group": "952156841f214b55",
        "name": "spacer",
        "tooltip": "",
        "order": 5,
        "width": 1,
        "height": 1,
        "className": ""
    },
    {
        "id": "3f1d479249d6e64b",
        "type": "ui-spacer",
        "group": "952156841f214b55",
        "name": "spacer",
        "tooltip": "",
        "order": 2,
        "width": 1,
        "height": 1,
        "className": ""
    },
    {
        "id": "5548435eafd9f892",
        "type": "ui-spacer",
        "group": "952156841f214b55",
        "name": "spacer",
        "tooltip": "",
        "order": 1,
        "width": 1,
        "height": 1,
        "className": ""
    },
    {
        "id": "e031b52fee14c5c0",
        "type": "ui-spacer",
        "group": "952156841f214b55",
        "name": "spacer",
        "tooltip": "",
        "order": 3,
        "width": 1,
        "height": 1,
        "className": ""
    },
    {
        "id": "3ab6626615c341ab",
        "type": "ui-spacer",
        "group": "952156841f214b55",
        "name": "spacer",
        "tooltip": "",
        "order": 4,
        "width": 1,
        "height": 1,
        "className": ""
    },
    {
        "id": "5198508231fcf8a8",
        "type": "exec",
        "z": "df4a94479416f0c4",
        "command": "hostname -I",
        "addpay": false,
        "append": "",
        "useSpawn": "false",
        "timer": "",
        "winHide": false,
        "name": "Fetch IP",
        "x": 200,
        "y": 80,
        "wires": [
            [
                "f3b472b4726bfeec",
                "ce789fc5954b2049"
            ],
            [],
            []
        ]
    },
    {
        "id": "f3b472b4726bfeec",
        "type": "function",
        "z": "df4a94479416f0c4",
        "name": "function 2",
        "func": "let ip = msg.payload.replace(/[\\r\\n\\t ]/g, \"\");\nlet get_ip = global.get(\"config.state.ip\");\n    if((get_ip === undefined && ip) || ip){\n        global.set(\"config.state.ip\", ip);\n    };\nmsg.payload = {\n    fill: \"yellow\",\n    shape: \"ring\",\n    text: `IP:${ip}`\n};\nreturn msg;",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 360,
        "y": 60,
        "wires": [
            []
        ]
    },
    {
        "id": "6b6cdff899b96d18",
        "type": "inject",
        "z": "df4a94479416f0c4",
        "name": "",
        "props": [
            {
                "p": "payload"
            },
            {
                "p": "topic",
                "vt": "str"
            },
            {
                "p": "path",
                "v": "/home/orangepi/loom/data/log.csv",
                "vt": "str"
            }
        ],
        "repeat": "3",
        "crontab": "",
        "once": false,
        "onceDelay": 0.1,
        "topic": "",
        "payload": "",
        "payloadType": "date",
        "x": 95,
        "y": 200,
        "wires": [
            []
        ],
        "l": false
    },
    {
        "id": "1ab2c4d09e12f25f",
        "type": "function",
        "z": "df4a94479416f0c4",
        "name": "function 13",
        "func": "const index = global.get(\"config.state.index\");\nconst ip = msg.payload[index - 1].ip;\n if(!ip){\n    global.set(\"config.state.index\", index + 1);\n }",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 375,
        "y": 200,
        "wires": [
            []
        ],
        "l": false
    },
    {
        "id": "3b8945c733c04fba",
        "type": "file in",
        "z": "df4a94479416f0c4",
        "name": "",
        "filename": "path",
        "filenameType": "msg",
        "format": "utf8",
        "chunk": false,
        "sendError": false,
        "encoding": "none",
        "allProps": false,
        "x": 200,
        "y": 200,
        "wires": [
            [
                "a703196f82a9e5ef"
            ]
        ]
    },
    {
        "id": "a703196f82a9e5ef",
        "type": "csv",
        "z": "df4a94479416f0c4",
        "name": "",
        "sep": ",",
        "hdrin": true,
        "hdrout": "",
        "multi": "mult",
        "ret": "\\r\\n",
        "temp": "",
        "skip": "0",
        "strings": true,
        "include_empty_strings": false,
        "include_null_values": false,
        "x": 315,
        "y": 200,
        "wires": [
            [
                "1ab2c4d09e12f25f"
            ]
        ],
        "l": false
    },
    {
        "id": "ce789fc5954b2049",
        "type": "function",
        "z": "df4a94479416f0c4",
        "name": "function 8",
        "func": "let ip = msg.payload.replace(/[\\r\\n\\t ]/g, \"\");\n\nmsg.payload = {\n    ip:ip\n};\nreturn msg;",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 360,
        "y": 100,
        "wires": [
            [
                "780162e582c1ec43"
            ]
        ]
    },
    {
        "id": "780162e582c1ec43",
        "type": "file",
        "z": "df4a94479416f0c4",
        "name": "",
        "filename": "/tmp/localip/ip.json",
        "filenameType": "str",
        "appendNewline": false,
        "createDir": true,
        "overwriteFile": "true",
        "encoding": "none",
        "x": 550,
        "y": 100,
        "wires": [
            []
        ]
    },
    {
        "id": "59eb51568d8158c9",
        "type": "moment",
        "z": "a67f25631bef1988",
        "name": "",
        "topic": "",
        "input": "",
        "inputType": "date",
        "inTz": "Asia/Bangkok",
        "adjAmount": 0,
        "adjType": "days",
        "adjDir": "add",
        "format": "",
        "locale": "en-US",
        "output": "payload",
        "outputType": "msg",
        "outTz": "Asia/Bangkok",
        "x": 125,
        "y": 80,
        "wires": [
            [
                "23bad38c2d77961c"
            ]
        ],
        "l": false
    },
    {
        "id": "23bad38c2d77961c",
        "type": "function",
        "z": "a67f25631bef1988",
        "name": "function 1",
        "func": "var date = new Date(msg.payload);\nlet previousDate = new Date(date); \n    previousDate.setDate(previousDate.getDate() - 1).toString().padStart(2, 0);\nvar year = date.getFullYear(); \nvar month = (date.getMonth() + 1).toString().padStart(2, '0');\nvar day = date.getDate().toString().padStart(2, '0');\nvar hours = date.getHours().toString().padStart(2, '0');\nvar minutes = date.getMinutes().toString().padStart(2, '0');\nvar seconds = date.getSeconds().toString().padStart(2, '0');\nvar dateMian = `${year}/${month}/${day}`;\nvar time = `${hours}:${minutes}:${seconds}`;\nvar datestamp = global.get(\"config.state.datestamp\");\nlet hoursNum = Number(hours);\n    globalSet();\n////////////////////////////// end function set date ///////////////////////////////////////\nif (hoursNum >= 8 && hoursNum <= 23) {\n    let dateset = filename(date);\n    var datenow = dateNow(date);\n    global.set(\"config.state.date_data\", dateset);\n} else {\n    let dateset = filename(previousDate);\n    var datenow = dateNow(previousDate);\n    global.set(\"config.state.date_data\", dateset);\n}\n\nif (datestamp) {\n    if (datenow != datestamp) {\n        resetValues();\n        // global.set(\"report\", true);\n        // stamp date\n        global.set(\"config.state.datestamp\", datenow);\n    } else {\n        // stamp date\n        global.set(\"config.state.datestamp\", datenow);\n    }\n} else {\n    global.set(\"config.state.datestamp\", datenow);\n}\n    global.set(\"config.state.datenow\", datenow);\n    msg.payload = {\n        fill: \"green\",\n        shape: \"ring\",\n        text: `DATESTAMP:${datestamp} DATE${day}/${month}/${year} TIME:${time}`\n    };\n    return msg;\n\nfunction filename(date){\n    let year = date.getFullYear();\n    let month = (date.getMonth() + 1).toString().padStart(2, '0');\n    let day = date.getDate().toString().padStart(2, '0');\n    return `${year}${month}${day}`;\n}\n\nfunction resetValues(){\n    var meter = new Array(24).fill(0);\n    global.set(\"values.meter\", meter);\n    var working = new Array(24).fill(0);\n    global.set(\"values.working\", working);\n    global.set(\"values.maintake.main.min\", 0);\n    global.set(\"values.maintake.main.min\", 0);\n    global.set(\"values.maintake.take.min\", 0);\n    global.set(\"values.maintake.take.max\", 0);\n    global.set(\"config.state.upt.nla\", 0);\n    global.set(\"config.state.upt.ota\", 0);\n    global.set(\"config.state.upt.totalA\", 0);\n    global.set(\"config.state.upt.nlb\", 0);\n    global.set(\"config.state.upt.otb\", 0);\n    global.set(\"config.state.upt.totalB\", 0);\n}\n\nfunction globalSet(){\n    global.set(\"config.datetime.date\", dateMian);\n    global.set(\"config.datetime.day\", day);\n    global.set(\"config.datetime.month\", month);\n    global.set(\"config.datetime.year\", year);\n    global.set(\"config.datetime.time\", time);\n    global.set(\"config.datetime.hour\", hours);\n    global.set(\"config.datetime.minute\", minutes);\n    global.set(\"config.datetime.second\", seconds);\n}\n\nfunction dateNow(date){\n    let year = date.getFullYear();\n    let month = (date.getMonth() + 1).toString().padStart(2, '0');\n    let day = date.getDate().toString().padStart(2, '0');\n    return `${year}${month}${day}`;\n}",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 240,
        "y": 80,
        "wires": [
            []
        ]
    },
    {
        "id": "633e9c4b40e42584",
        "type": "ping",
        "z": "13f006802899e0be",
        "protocol": "IPv4",
        "mode": "triggered",
        "name": "",
        "host": "",
        "timer": "10",
        "inputs": 1,
        "x": 135,
        "y": 80,
        "wires": [
            [
                "5805fc6c631c073d"
            ]
        ],
        "l": false
    },
    {
        "id": "5805fc6c631c073d",
        "type": "function",
        "z": "13f006802899e0be",
        "name": "function 684",
        "func": "global.set(\"config.state.connected\", (msg.payload) ? true : false);\nmsg.payload = global.get(\"config.state.connected\");\nreturn msg;",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 250,
        "y": 80,
        "wires": [
            [
                "c7fcb9a183a78340",
                "346948538b2e924a"
            ]
        ]
    },
    {
        "id": "346948538b2e924a",
        "type": "function",
        "z": "13f006802899e0be",
        "name": "function 686",
        "func": "var sho2 = `[${global.get(\"config.datetime.time\")}] Connected:${global.get(\"config.state.connected\")}`;\nmsg.payload = {\n    \"fill\": \"blue\",\n    \"shape\": \"dot\",\n    \"text\": sho2\n}\nreturn msg;",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 430,
        "y": 140,
        "wires": [
            []
        ]
    },
    {
        "id": "c7fcb9a183a78340",
        "type": "function",
        "z": "13f006802899e0be",
        "name": "function 687",
        "func": "let c1 = global.get(\"config.state.connected\");\nlet stat = flow.get(\"stat\"); // ใช้ตัวแปรใน flow เพื่อเก็บสถานะ\n// ตรวจสอบว่า payload เปลี่ยนแปลงหรือยัง\nif (stat === undefined) {\n    // ถ้ายังไม่มีสถานะเก็บไว้ (สถานะเริ่มต้น)\n    stat = {\n        payload: 1, // ค่าพื้นฐานของ payload\n        isProcessed: false // กำหนดสถานะให้ทำงานได้ครั้งแรก\n    };\n    flow.set(\"stat\", stat); // เก็บสถานะใน flow\n}\n// ตรวจสอบเงื่อนไขที่กำหนด\nif (c1) {\n    if (stat.payload !== 3) { // ตรวจสอบว่า payload มีการเปลี่ยนแปลงหรือไม่\n        msg.payload = 3;\n        stat.payload = 3; // อัปเดตสถานะ payload\n        stat.isProcessed = true; // ตั้งค่าสถานะว่าได้ทำการประมวลผลแล้ว\n        return msg;\n    }\n} else {\n    if (stat.payload !== 2) { // ตรวจสอบว่า payload มีการเปลี่ยนแปลงหรือไม่\n        msg.payload = 2;\n        stat.payload = 2; // อัปเดตสถานะ payload\n        stat.isProcessed = true; // ตั้งค่าสถานะว่าได้ทำการประมวลผลแล้ว\n        return msg;\n    }\n}\nflow.set(\"stat\", stat); // อัปเดตสถานะใน flow",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 430,
        "y": 80,
        "wires": [
            [
                "54b953cb7c4b2af9"
            ]
        ]
    },
    {
        "id": "54b953cb7c4b2af9",
        "type": "subflow:31057fe0b0d4c1ec",
        "z": "13f006802899e0be",
        "name": "",
        "x": 590,
        "y": 80,
        "wires": []
    },
    {
        "id": "db6fc316f972fc7a",
        "type": "exec",
        "z": "31057fe0b0d4c1ec",
        "command": "./stat_led/blink.sh",
        "addpay": "payload",
        "append": "",
        "useSpawn": "false",
        "timer": "",
        "winHide": false,
        "oldrc": false,
        "name": "WeightScale Ready",
        "x": 115,
        "y": 40,
        "wires": [
            [],
            [],
            []
        ],
        "icon": "node-red/light.svg",
        "l": false
    },
    {
        "id": "698cc965e4a64996",
        "type": "inject",
        "z": "e226ede58ea4b202",
        "name": "",
        "props": [
            {
                "p": "payload"
            },
            {
                "p": "topic",
                "vt": "str"
            }
        ],
        "repeat": "1",
        "crontab": "",
        "once": true,
        "onceDelay": "35",
        "topic": "",
        "payload": "",
        "payloadType": "date",
        "x": 135,
        "y": 160,
        "wires": [
            [
                "d1e4489c3e8ca995",
                "c5418b2844d316d7"
            ]
        ],
        "icon": "font-awesome/fa-info-circle",
        "l": false
    },
    {
        "id": "d1e4489c3e8ca995",
        "type": "function",
        "z": "e226ede58ea4b202",
        "name": "function 6",
        "func": "let time_cal = msg.payload - global.get(\"config.datetime.timestamp\");\nlet count = flow.get(\"count\") || 0;\ntime_cal > 10000 || !global.get(\"config.datetime.timestamp\") ? flow.set(\"count\", count + 1) : flow.set(\"count\", 0); // 3000 millisec\nreturn count > 300 ? msg : undefined;",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 260,
        "y": 160,
        "wires": [
            [
                "ce2564d1100f0cb3"
            ]
        ]
    },
    {
        "id": "c5418b2844d316d7",
        "type": "function",
        "z": "e226ede58ea4b202",
        "name": "function 7",
        "func": "let count = flow.get(\"count\")\nmsg.count = count\nmsg.payload = {\n    fill: count < 1? \"green\" : \"red\",\n    shape: count < 1? \"dot\" : \"ring\",\n    text: count\n}\nreturn msg;",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 260,
        "y": 220,
        "wires": [
            [
                "b20e01c67a28eeb6"
            ]
        ]
    },
    {
        "id": "9eb83d2ca8ce536d",
        "type": "exec",
        "z": "e226ede58ea4b202",
        "command": "reboot",
        "addpay": "",
        "append": "",
        "useSpawn": "false",
        "timer": "",
        "winHide": false,
        "oldrc": false,
        "name": "",
        "x": 650,
        "y": 160,
        "wires": [
            [],
            [],
            []
        ]
    },
    {
        "id": "09af4c1ad37430eb",
        "type": "exec",
        "z": "e226ede58ea4b202",
        "command": "./stat_led/modbus_err.sh",
        "addpay": "",
        "append": "",
        "useSpawn": "false",
        "timer": "",
        "winHide": false,
        "oldrc": false,
        "name": "blink err",
        "x": 560,
        "y": 280,
        "wires": [
            [],
            [],
            []
        ]
    },
    {
        "id": "b20e01c67a28eeb6",
        "type": "switch",
        "z": "e226ede58ea4b202",
        "name": "",
        "property": "count",
        "propertyType": "msg",
        "rules": [
            {
                "t": "gt",
                "v": "0",
                "vt": "num"
            }
        ],
        "checkall": "true",
        "repair": false,
        "outputs": 1,
        "x": 410,
        "y": 280,
        "wires": [
            [
                "09af4c1ad37430eb"
            ]
        ]
    },
    {
        "id": "4bcac64d1b91385f",
        "type": "subflow:1406c468fdce7358",
        "z": "e226ede58ea4b202",
        "name": "",
        "x": 500,
        "y": 160,
        "wires": [
            [
                "9eb83d2ca8ce536d"
            ]
        ]
    },
    {
        "id": "ce2564d1100f0cb3",
        "type": "function",
        "z": "e226ede58ea4b202",
        "name": "function 11",
        "func": "let wot = flow.get(\"wot\");\nif (!wot) {\n    msg.payload = `❗⛓️‍💥 ${global.get(\"config.state.ip\")} > การส่งข้อมูลของ Converter RS485 อาจมีปัญหา...`;\n    node.status({ fill: \"green\", shape: \"ring\", text: global.get(\"time\") });\n    flow.set(\"wot\", true);\n    return msg;\n}",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 375,
        "y": 160,
        "wires": [
            [
                "4bcac64d1b91385f"
            ]
        ],
        "l": false
    },
    {
        "id": "861f956f24a820d1",
        "type": "file",
        "z": "aa3c99c011a59edd",
        "name": "config",
        "filename": "/home/orangepi/loom/config.txt.tmp",
        "filenameType": "str",
        "appendNewline": false,
        "createDir": true,
        "overwriteFile": "true",
        "encoding": "utf8",
        "x": 310,
        "y": 40,
        "wires": [
            [
                "529efc0a45b6c9d8"
            ]
        ],
        "icon": "node-red/redis.svg"
    },
    {
        "id": "67264d9b0e343db6",
        "type": "function",
        "z": "aa3c99c011a59edd",
        "name": "fig value",
        "func": "msg.payload = {\n    \"state\": {\n        \"datestamp\": global.get(\"config.state.datestamp\"),\n        \"hourstamp\": global.get(\"config.state.hourstamp\"),\n        \"changehour\": global.get(\"config.state.changehour\"),\n        \"upt\":{\n            \"nla\": global.get(\"config.state.upt.nla\") || 0,\n            \"ota\": global.get(\"config.state.upt.ota\") || 0,\n            \"totalA\": global.get(\"config.state.upt.totalA\") || 0,\n            \"nlb\": global.get(\"config.state.upt.nlb\") || 0,\n            \"otb\": global.get(\"config.state.upt.otb\") || 0,\n            \"totalB\": global.get(\"config.state.upt.totalB\") || 0,\n            \"total\": global.get(\"config.state.upt.total\") || 0,\n        },\n        \"index\": global.get(\"config.state.index\"),\n        \"ip\": global.get(\"config.state.ip\"),\n        \"version\": global.get(\"version\") || \"-\",\n        \"influxdb\":{\n            \"index\": global.get(\"config.state.influxdb.index\")\n        }\n    },\n    \"values\": {\n        \"maintake\": {\n            \"main\": {\n                \"min\": global.get(\"values.maintake.main.min\"),\n                \"max\": global.get(\"values.maintake.main.max\")\n            },\n            \"take\": {\n                \"min\": global.get(\"values.maintake.take.min\"),\n                \"max\": global.get(\"values.maintake.take.max\")\n            }\n        },\n        \"meter\": global.get(\"values.meter\"),\n        \"working\": global.get(\"values.working\")\n    }\n}\nreturn msg;",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 160,
        "y": 40,
        "wires": [
            [
                "861f956f24a820d1"
            ]
        ]
    },
    {
        "id": "529efc0a45b6c9d8",
        "type": "exec",
        "z": "aa3c99c011a59edd",
        "command": ". $HOME/loom/scriptConfig.sh",
        "addpay": "",
        "append": "",
        "useSpawn": "false",
        "timer": "",
        "winHide": false,
        "oldrc": false,
        "name": "move .tmp",
        "x": 470,
        "y": 60,
        "wires": [
            [
                "4fa647803c42f119"
            ],
            [],
            []
        ]
    },
    {
        "id": "4fa647803c42f119",
        "type": "function",
        "z": "aa3c99c011a59edd",
        "name": "function 689",
        "func": "msg.payload = {\n    'fill': 'blue',\n    'shape': 'dot',\n    'text': `${global.get(\"config.datetime.time\")} : ${msg.filename}` \n}\nreturn msg;",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 650,
        "y": 60,
        "wires": [
            []
        ]
    },
    {
        "id": "5730377ef1841b85",
        "type": "function",
        "z": "b7d6774c49a75902",
        "name": "list",
        "func": "var fileList = msg.payload;\nvar fileno = fileList.length;\n    global.set(\"config.state.file\", fileno)\n    return msg;",
        "outputs": 1,
        "timeout": "",
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 210,
        "y": 80,
        "wires": [
            [
                "0d197ce9478787bb"
            ]
        ]
    },
    {
        "id": "9ac210c7c0b99891",
        "type": "fs-file-lister",
        "z": "b7d6774c49a75902",
        "name": "file list",
        "start": "/home/orangepi/loom/data/",
        "pattern": "*.*",
        "folders": "*",
        "hidden": true,
        "lstype": "files",
        "path": true,
        "single": true,
        "depth": "0",
        "stat": true,
        "showWarnings": false,
        "x": 125,
        "y": 80,
        "wires": [
            [
                "5730377ef1841b85"
            ]
        ],
        "l": false
    },
    {
        "id": "0d197ce9478787bb",
        "type": "function",
        "z": "b7d6774c49a75902",
        "name": "function 6",
        "func": "msg.payload = {\n    fill : \"bule\",\n    shape : \"dot\",\n    text: `file:${global.get(\"config.state.file\")}}`\n}\nreturn msg;",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 360,
        "y": 120,
        "wires": [
            []
        ]
    },
    {
        "id": "581e4659c476b910",
        "type": "file in",
        "z": "341bdc3e7e68ae46",
        "name": "Read",
        "filename": "/home/orangepi/loom/config.txt",
        "filenameType": "str",
        "format": "utf8",
        "chunk": false,
        "sendError": false,
        "encoding": "utf8",
        "allProps": false,
        "x": 310,
        "y": 140,
        "wires": [
            [
                "1af31287089bf3ac",
                "24e85514de7978d5"
            ]
        ],
        "icon": "node-red/sort.svg"
    },
    {
        "id": "1af31287089bf3ac",
        "type": "function",
        "z": "341bdc3e7e68ae46",
        "name": "Set value",
        "func": "const payload = JSON.parse(msg.payload);\n    global.set(\"config.state.ip\", payload.state.ip);\n    global.set(\"config.state.datestamp\", payload.state.datestamp);\n    global.set(\"config.state.index\", payload.state.index);\n    global.set(\"config.state.changehour\", payload.state.changehour);\n    global.set(\"config.state.upt.total\", payload.state.upt.total);\n    global.set(\"config.state.upt.nla\", payload.state.upt.nla);\n    global.set(\"config.state.upt.ota\", payload.state.upt.ota);\n    global.set(\"config.state.upt.totalA\", payload.state.upt.totalA);\n    global.set(\"config.state.upt.nlb\", payload.state.upt.nlb);\n    global.set(\"config.state.upt.otb\", payload.state.upt.otb);\n    global.set(\"config.state.upt.totalB\", payload.state.upt.totalB);\n    global.set(\"version\", payload.state.version || \"-\");\n    global.set(\"config.state.influxdb.index\", payload.state.influxdb.index)\n    let main_min = payload.values.maintake.main.min ;\n    global.set(\"values.maintake.main.min\", main_min);\n    let main_max = payload.values.maintake.main.max ;\n    global.set(\"values.maintake.main.max\", main_max);\n    let take_min = payload.values.maintake.take.min ;\n    global.set(\"values.maintake.take.min\", take_min);\n    let take_max = payload.values.maintake.take.max ;\n    global.set(\"values.maintake.take.max\", take_max);\n    const arr1 = new Array(24).fill(0);\n    const arr2 = new Array(24).fill(0);\n    let meter = payload.values.meter;\n    global.set(\"values.meter\", meter || arr1);\n    let working = payload.values.working;\n    global.set(\"values.working\", working || arr2);\n    ",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 415,
        "y": 140,
        "wires": [
            []
        ],
        "l": false
    },
    {
        "id": "0010ce9b239656e0",
        "type": "catch",
        "z": "341bdc3e7e68ae46",
        "name": "",
        "scope": [
            "581e4659c476b910",
            "1af31287089bf3ac"
        ],
        "uncaught": false,
        "x": 310,
        "y": 180,
        "wires": [
            [
                "4c08362380676e6d"
            ]
        ]
    },
    {
        "id": "403b9f45ce07e19d",
        "type": "function",
        "z": "341bdc3e7e68ae46",
        "name": "function 10",
        "func": "const payload = JSON.parse(msg.payload);\n    global.set(\"config.state.ip\", payload.state.ip);\n    global.set(\"config.state.datestamp\", payload.state.datestamp);\n    global.set(\"config.state.index\", payload.state.index);\n    global.set(\"config.state.changehour\", payload.state.changehour);\n    global.set(\"config.state.upt.total\", payload.state.upt.total);\n    global.set(\"config.state.upt.nla\", payload.state.upt.nla);\n    global.set(\"config.state.upt.ota\", payload.state.upt.ota);\n    global.set(\"config.state.upt.totalA\", payload.state.upt.totalA);\n    global.set(\"config.state.upt.nlb\", payload.state.upt.nlb);\n    global.set(\"config.state.upt.otb\", payload.state.upt.otb);\n    global.set(\"config.state.upt.totalB\", payload.state.upt.totalB);\n    global.set(\"version\", payload.state.version || \"-\");\n    let main_min = payload.values.maintake.main.min ;\n    global.set(\"values.maintake.main.min\", main_min);\n    let main_max = payload.values.maintake.main.max ;\n    global.set(\"values.maintake.main.max\", main_max);\n    let take_min = payload.values.maintake.take.min ;\n    global.set(\"values.maintake.take.min\", take_min);\n    let take_max = payload.values.maintake.take.max ;\n    global.set(\"values.maintake.take.max\", take_max);\n    const arr1 = new Array(24).fill(0);\n    const arr2 = new Array(24).fill(0);\n    let meter = payload.values.meter;\n    global.set(\"values.meter\", meter || arr1);  \n    let working = payload.values.working;\n    global.set(\"values.working\", working || arr2);\n    return msg;",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 545,
        "y": 180,
        "wires": [
            [
                "13e5e83fe8bf9607",
                "28a9aa3fad6e642c"
            ]
        ],
        "l": false
    },
    {
        "id": "24e85514de7978d5",
        "type": "function",
        "z": "341bdc3e7e68ae46",
        "name": "function 11",
        "func": "if(msg.payload){\nmsg.payload = {\n    'fill': 'bule',\n    'shape': 'dot',\n    'text': `ts: ${flow.get(\"ts\")}`\n}\nreturn msg;\n}\n",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 490,
        "y": 80,
        "wires": [
            []
        ]
    },
    {
        "id": "7dcb29351996d6be",
        "type": "delay",
        "z": "341bdc3e7e68ae46",
        "name": "",
        "pauseType": "delay",
        "timeout": "1",
        "timeoutUnits": "seconds",
        "rate": "1",
        "nbRateUnits": "1",
        "rateUnits": "second",
        "randomFirst": "1",
        "randomLast": "5",
        "randomUnits": "seconds",
        "drop": false,
        "allowrate": false,
        "outputs": 1,
        "x": 160,
        "y": 140,
        "wires": [
            [
                "581e4659c476b910"
            ]
        ]
    },
    {
        "id": "258890b7306744af",
        "type": "file in",
        "z": "341bdc3e7e68ae46",
        "name": "",
        "filename": "/home/orangepi/loom/data/log.csv",
        "filenameType": "str",
        "format": "utf8",
        "chunk": false,
        "sendError": false,
        "encoding": "none",
        "allProps": false,
        "x": 115,
        "y": 100,
        "wires": [
            [
                "b8503deb0ae9cab9"
            ]
        ],
        "l": false
    },
    {
        "id": "b8503deb0ae9cab9",
        "type": "csv",
        "z": "341bdc3e7e68ae46",
        "name": "",
        "sep": ",",
        "hdrin": "",
        "hdrout": "none",
        "multi": "mult",
        "ret": "\\n",
        "temp": "",
        "skip": "0",
        "strings": true,
        "include_empty_strings": "",
        "include_null_values": "",
        "x": 175,
        "y": 100,
        "wires": [
            [
                "48a2a0290809c5a0"
            ]
        ],
        "l": false
    },
    {
        "id": "48a2a0290809c5a0",
        "type": "function",
        "z": "341bdc3e7e68ae46",
        "name": "le",
        "func": "var length = msg.payload.length\nlength = length - 1\nglobal.set(\"config.state.row\", length)",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 235,
        "y": 100,
        "wires": [
            []
        ],
        "l": false
    },
    {
        "id": "8e7c7d80304fe097",
        "type": "function",
        "z": "341bdc3e7e68ae46",
        "name": "function 12",
        "func": "const date = new Date(msg.payload);\n\nconst bangkokTime = date.toLocaleString('en-GB', { \n  timeZone: 'Asia/Bangkok',\n  year: 'numeric', month: '2-digit', day: '2-digit',\n  hour: '2-digit', minute: '2-digit', second: '2-digit'\n});\nflow.set(\"ts\", bangkokTime);\nreturn msg;",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 170,
        "y": 180,
        "wires": [
            []
        ]
    },
    {
        "id": "d6c523303ab0a091",
        "type": "file in",
        "z": "341bdc3e7e68ae46",
        "name": "",
        "filename": "/home/orangepi/loom/source.txt",
        "filenameType": "str",
        "format": "utf8",
        "chunk": false,
        "sendError": false,
        "encoding": "none",
        "allProps": false,
        "x": 115,
        "y": 60,
        "wires": [
            [
                "061df98b883d0c2f"
            ]
        ],
        "l": false
    },
    {
        "id": "061df98b883d0c2f",
        "type": "function",
        "z": "341bdc3e7e68ae46",
        "name": "le",
        "func": "var source = Number(msg.payload)\nglobal.set(\"source\", source)",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 175,
        "y": 60,
        "wires": [
            []
        ],
        "l": false
    },
    {
        "id": "4c08362380676e6d",
        "type": "file in",
        "z": "341bdc3e7e68ae46",
        "name": "Read",
        "filename": "/home/orangepi/loom/config.txt.bak",
        "filenameType": "str",
        "format": "utf8",
        "chunk": false,
        "sendError": false,
        "encoding": "utf8",
        "allProps": false,
        "x": 450,
        "y": 180,
        "wires": [
            [
                "403b9f45ce07e19d"
            ]
        ],
        "icon": "node-red/sort.svg"
    },
    {
        "id": "13e5e83fe8bf9607",
        "type": "exec",
        "z": "341bdc3e7e68ae46",
        "command": "cp $HOME/loom/config.txt.bak $HOME/loom/config.txt",
        "addpay": "",
        "append": "",
        "useSpawn": "false",
        "timer": "",
        "winHide": false,
        "oldrc": false,
        "name": "repiar config",
        "x": 650,
        "y": 200,
        "wires": [
            [],
            [],
            []
        ]
    },
    {
        "id": "133f022c804089c9",
        "type": "subflow:1406c468fdce7358",
        "z": "341bdc3e7e68ae46",
        "name": "",
        "x": 740,
        "y": 140,
        "wires": [
            []
        ]
    },
    {
        "id": "28a9aa3fad6e642c",
        "type": "function",
        "z": "341bdc3e7e68ae46",
        "name": "function 690",
        "func": "\nif (1) {\n    msg.payload = `🗂️ ${global.get(\"config.state.ip\")} > Orange Pi เกิดปัญหาในการอ่านไฟล์ Config... Overwrite > config.txt`;\n    node.status({ fill: \"green\", shape: \"ring\", text: global.get(\"time\") });\n    flow.set(\"wot\", true);\n    return msg;\n}",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 615,
        "y": 140,
        "wires": [
            [
                "133f022c804089c9"
            ]
        ],
        "l": false
    },
    {
        "id": "3925be8bad2bdf74",
        "type": "file in",
        "z": "424004941bcb3307",
        "name": "",
        "filename": "path",
        "filenameType": "msg",
        "format": "utf8",
        "chunk": false,
        "sendError": false,
        "encoding": "none",
        "allProps": false,
        "x": 180,
        "y": 40,
        "wires": [
            [
                "8104a50cbc2556ae"
            ]
        ]
    },
    {
        "id": "8104a50cbc2556ae",
        "type": "csv",
        "z": "424004941bcb3307",
        "name": "",
        "sep": ",",
        "hdrin": true,
        "hdrout": "",
        "multi": "mult",
        "ret": "\\r\\n",
        "temp": "",
        "skip": "0",
        "strings": true,
        "include_empty_strings": false,
        "include_null_values": false,
        "x": 295,
        "y": 40,
        "wires": [
            [
                "0a3028182b518b6e"
            ]
        ],
        "l": false
    },
    {
        "id": "0a3028182b518b6e",
        "type": "function",
        "z": "424004941bcb3307",
        "name": "API Power",
        "func": "const index = global.get(\"config.state.index\") || 0;\n\nconst date = msg.payload[index].date;\nconst time = msg.payload[index].time;\nconst date_data = msg.payload[index].date_data;\nconst ip = msg.payload[index].ip;\nconst timestamp = msg.payload[index].timestamp;\n\nconst meter = [\n    msg.payload[index].m_0,\n    msg.payload[index].m_1,\n    msg.payload[index].m_2,\n    msg.payload[index].m_3,\n    msg.payload[index].m_4,\n    msg.payload[index].m_5,\n    msg.payload[index].m_6,\n    msg.payload[index].m_7,\n    msg.payload[index].m_8,\n    msg.payload[index].m_9,\n    msg.payload[index].m_10,\n    msg.payload[index].m_11,\n    msg.payload[index].m_12,\n    msg.payload[index].m_13,\n    msg.payload[index].m_14,\n    msg.payload[index].m_15,\n    msg.payload[index].m_16,\n    msg.payload[index].m_17,\n    msg.payload[index].m_18,\n    msg.payload[index].m_19,\n    msg.payload[index].m_20,\n    msg.payload[index].m_21,\n    msg.payload[index].m_22,\n    msg.payload[index].m_23,\n]\n\nconst working = [\n    msg.payload[index].w_0,\n    msg.payload[index].w_1,\n    msg.payload[index].w_2,\n    msg.payload[index].w_3,\n    msg.payload[index].w_4,\n    msg.payload[index].w_5,\n    msg.payload[index].w_6,\n    msg.payload[index].w_7,\n    msg.payload[index].w_8,\n    msg.payload[index].w_9,\n    msg.payload[index].w_10,\n    msg.payload[index].w_11,\n    msg.payload[index].w_12,\n    msg.payload[index].w_13,\n    msg.payload[index].w_14,\n    msg.payload[index].w_15,\n    msg.payload[index].w_16,\n    msg.payload[index].w_17,\n    msg.payload[index].w_18,\n    msg.payload[index].w_19,\n    msg.payload[index].w_20,\n    msg.payload[index].w_21,\n    msg.payload[index].w_22,\n    msg.payload[index].w_23,\n]\n\nconst API = {\n    'filesystem':{ \n        date: date, \n        time: time, \n        ip: ip, \n        date_data: date_data,\n        timestamp: timestamp,\n        'upTime': {\n            'total': global.get(\"config.state.upt.total\"),\n            'totalA': global.get(\"config.state.upt.totalA\"),\n            'totalB': global.get(\"config.state.upt.totalB\"),\n            'nla': global.get(\"config.state.upt.nla\"),\n            'ota': global.get(\"config.state.upt.ota\"),\n            'nlb': global.get(\"config.state.upt.nlb\"),\n            'otb': global.get(\"config.state.upt.otb\"),\n        }\n    },\n    'values':{\n        'meter': {\n            0: meter[0], 1: meter[1], 2: meter[2], 3: meter[3], 4: meter[4], 5: meter[5],\n            6: meter[6], 7: meter[7], 8: meter[8], 9: meter[9], 10: meter[10], 11: meter[11],\n            12: meter[12], 13: meter[13], 14: meter[14], 15: meter[15], 16: meter[16], 17: meter[17],\n            18: meter[18], 19: meter[19], 20: meter[20], 21: meter[21], 22: meter[22], 23: meter[23]\n        },\n        'working': {\n            0: working[0], 1: working[1], 2: working[2], 3: working[3], 4: working[4], 5: working[5],\n            6: working[6], 7: working[7], 8: working[8], 9: working[9], 10: working[10], 11: working[11],\n            12: working[12], 13: working[13], 14: working[14], 15: working[15], 16: working[16], 17: working[17],\n            18: working[18], 19: working[19], 20: working[20], 21: working[21], 22: working[22], 23: working[23]\n        },\n        'total':{\n            \"meter\":{\n                \"total\": msg.payload[index].total_meter,\n                \"totalA\": msg.payload[index].total_meterA,\n                \"totalB\": msg.payload[index].total_meterB,\n                \"NLA\": msg.payload[index].meterNLA,\n                \"NLB\": msg.payload[index].meterNLB,\n                \"OTA\": msg.payload[index].meterOTA,\n                \"OTB\": msg.payload[index].meterOTB,\n            },\n            \"working\":{\n                \"total\": msg.payload[index].total_working,\n                \"totalA\": msg.payload[index].total_workingA,\n                \"totalB\": msg.payload[index].total_workingB,\n                \"NLA\": msg.payload[index].workingNLA,\n                \"NLB\": msg.payload[index].workingNLB,\n                \"OTA\": msg.payload[index].workingOTA,\n                \"OTB\": msg.payload[index].workingOTB,\n            }\n        },\n        'maintake':{\n            'main':{\n                'now': msg.payload[index].main_now,\n                'min': msg.payload[index].main_min,\n                'max': msg.payload[index].main_max\n            },\n            'take':{\n                'now': msg.payload[index].take_now,\n                'min': msg.payload[index].take_min,\n                'max': msg.payload[index].take_max\n            }\n        }\n    }\n};\nmsg.payload = JSON.stringify(API);\nreturn msg",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 430,
        "y": 40,
        "wires": [
            []
        ]
    },
    {
        "id": "db40ab8bf0220701",
        "type": "catch",
        "z": "424004941bcb3307",
        "name": "",
        "scope": [
            "0a3028182b518b6e"
        ],
        "uncaught": false,
        "x": 90,
        "y": 100,
        "wires": [
            [
                "f5d79e7797a4b637"
            ]
        ]
    },
    {
        "id": "f5d79e7797a4b637",
        "type": "function",
        "z": "424004941bcb3307",
        "name": "function 9",
        "func": "let index = global.get(\"config.state.index\");\nglobal.set(\"config.state.index\", index + 1);",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 240,
        "y": 100,
        "wires": [
            []
        ]
    },
    {
        "id": "4a84a0a8603ab232",
        "type": "exec",
        "z": "a007640620fd4d52",
        "command": "./stat_led/blink11.sh",
        "addpay": "payload",
        "append": "",
        "useSpawn": "false",
        "timer": "",
        "winHide": false,
        "oldrc": false,
        "name": "blink11",
        "x": 360,
        "y": 40,
        "wires": [
            [],
            [],
            []
        ]
    },
    {
        "id": "6f98bf351570cfd0",
        "type": "function",
        "z": "a007640620fd4d52",
        "name": "function 664",
        "func": "msg.payload = 1\nreturn msg;",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 170,
        "y": 40,
        "wires": [
            [
                "4a84a0a8603ab232"
            ]
        ]
    },
    {
        "id": "79406b7c65e62058",
        "type": "exec",
        "z": "77aa6425a6e4878c",
        "command": "",
        "addpay": "remove",
        "append": "",
        "useSpawn": "false",
        "timer": "",
        "winHide": false,
        "oldrc": false,
        "name": "",
        "x": 270,
        "y": 80,
        "wires": [
            [],
            [],
            []
        ]
    },
    {
        "id": "9112ab91340ace88",
        "type": "function",
        "z": "77aa6425a6e4878c",
        "name": "function 3",
        "func": "let index = global.get(\"config.state.index\");\nlet row = global.get(\"config.state.row\");\nif(row > 1000 && index == row){\n    msg.remove = `rm /home/orangepi/loom/data/log.csv`;\n    global.set(\"config.state.index\", 0);\n    return msg;\n}",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 155,
        "y": 80,
        "wires": [
            [
                "79406b7c65e62058"
            ]
        ],
        "icon": "font-awesome/fa-times-circle",
        "l": false
    },
    {
        "id": "933493d52353d337",
        "type": "http in",
        "z": "a6ecc454e1b3c0c3",
        "name": "API",
        "url": "/api/power-data",
        "method": "get",
        "upload": false,
        "swaggerDoc": "",
        "x": 1025,
        "y": 420,
        "wires": [
            []
        ],
        "l": false
    },
    {
        "id": "fb1eb8640f6f4943",
        "type": "http response",
        "z": "a6ecc454e1b3c0c3",
        "name": "API Response",
        "statusCode": "",
        "headers": {},
        "x": 1445,
        "y": 420,
        "wires": [],
        "l": false
    },
    {
        "id": "f6905c9e73692c2d",
        "type": "function",
        "z": "a6ecc454e1b3c0c3",
        "name": "function 645",
        "func": "var index = global.get(\"index.i0\") || 0;\n    index = index + 1;\n    global.set(\"index.i0\", index);\nmsg.payload = {\n    fill: \"blue\",\n    shape: \"dot\",\n    text: `HTTP:[Time:${global.get(\"time\")}]`\n    };\nreturn msg;",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 1405,
        "y": 440,
        "wires": [
            [
                "7420857d31044523"
            ]
        ],
        "icon": "font-awesome/fa-check",
        "l": false
    },
    {
        "id": "7420857d31044523",
        "type": "subflow:77aa6425a6e4878c",
        "z": "a6ecc454e1b3c0c3",
        "name": "",
        "x": 1510,
        "y": 480,
        "wires": []
    },
    {
        "id": "c33b83fa52c22681",
        "type": "subflow:a007640620fd4d52",
        "z": "a6ecc454e1b3c0c3",
        "name": "",
        "x": 1405,
        "y": 400,
        "wires": [],
        "l": false
    },
    {
        "id": "c3b32e2e3482646f",
        "type": "subflow:424004941bcb3307",
        "z": "a6ecc454e1b3c0c3",
        "name": "",
        "x": 1310,
        "y": 420,
        "wires": [
            [
                "c33b83fa52c22681",
                "fb1eb8640f6f4943",
                "f6905c9e73692c2d"
            ]
        ]
    },
    {
        "id": "634c3eb58dd47522",
        "type": "function",
        "z": "a6ecc454e1b3c0c3",
        "name": "Path",
        "func": "var connected = global.get(\"Connect.c0\");\nvar row = global.get(\"row.r0\");\nvar index = global.get(\"index.i0\");\nmsg.path_power = \"/home/orangepi/powermeter/log_power/log.csv\";\nif (connected && (index < row)){\n    node.status({fill:\"green\",shape:\"dot\",text:`index:${global.get(\"index\")} row:${global.get(\"row\")}`});\n    return msg;\n}else{\n    node.status({fill:\"green\",shape:\"dot\",text:`index:${global.get(\"index\")} row:${global.get(\"row\")}`})\n}",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 1150,
        "y": 420,
        "wires": [
            [
                "c3b32e2e3482646f"
            ]
        ]
    },
    {
        "id": "2cfa0e1ee1913505",
        "type": "http request",
        "z": "a6ecc454e1b3c0c3",
        "name": "",
        "method": "use",
        "ret": "txt",
        "paytoqs": "ignore",
        "url": "",
        "tls": "",
        "persist": false,
        "proxy": "",
        "insecureHTTPParser": false,
        "authType": "",
        "senderr": false,
        "headers": [],
        "x": 630,
        "y": 460,
        "wires": [
            [
                "043a074eaca99487"
            ]
        ]
    },
    {
        "id": "0b36a72b6512a560",
        "type": "function",
        "z": "a6ecc454e1b3c0c3",
        "name": "function 14",
        "func": "delete msg.tocloud;\ndelete msg.columns;\nmsg.url = `http://192.168.0.9:1880/api/product/device-opi-datasource-${global.get(\"source\")}`\nmsg.method = \"POST\";\nreturn msg;",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 515,
        "y": 460,
        "wires": [
            [
                "2cfa0e1ee1913505"
            ]
        ],
        "l": false
    },
    {
        "id": "043a074eaca99487",
        "type": "function",
        "z": "a6ecc454e1b3c0c3",
        "name": "function 15",
        "func": "const code = msg.statusCode;\nif(code === 200){\n    var index = global.get(\"config.state.index\") || 0;\n    index = index + 1;\n    global.set(\"config.state.index\", index);\n}\nmsg.payload = {\n    fill: \"blue\",\n    shape: \"dot\",\n    text: `http:[Time:${global.get(\"config.datetime.time\")} State: ${code}] row:${global.get(\"config.state.row\")} index:${global.get(\"config.state.index\")}`\n    };\nreturn msg",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 820,
        "y": 460,
        "wires": [
            [
                "866dc313d77cb598"
            ]
        ]
    },
    {
        "id": "866dc313d77cb598",
        "type": "subflow:77aa6425a6e4878c",
        "z": "a6ecc454e1b3c0c3",
        "name": "",
        "x": 955,
        "y": 500,
        "wires": [],
        "l": false
    },
    {
        "id": "6d9ae71f879ce0a3",
        "type": "subflow:a007640620fd4d52",
        "z": "a6ecc454e1b3c0c3",
        "name": "",
        "x": 465,
        "y": 440,
        "wires": [],
        "l": false
    },
    {
        "id": "fce74f821aaeba36",
        "type": "subflow:424004941bcb3307",
        "z": "a6ecc454e1b3c0c3",
        "name": "",
        "x": 370,
        "y": 460,
        "wires": [
            [
                "6d9ae71f879ce0a3",
                "0b36a72b6512a560"
            ]
        ]
    },
    {
        "id": "1cb42bbca3762b28",
        "type": "function",
        "z": "a6ecc454e1b3c0c3",
        "name": "Path",
        "func": "var connected = global.get(\"config.state.connected\");\nvar row = global.get(\"config.state.row\");\nvar index = global.get(\"config.state.index\") || 0;\nmsg.path = \"/home/orangepi/loom/data/log.csv\";\nif (connected && (index < row)){\n    return msg;\n}",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 210,
        "y": 460,
        "wires": [
            [
                "fce74f821aaeba36"
            ]
        ]
    },
    {
        "id": "485ac7c96e994e5a",
        "type": "inject",
        "z": "a6ecc454e1b3c0c3",
        "name": "",
        "props": [
            {
                "p": "payload"
            },
            {
                "p": "topic",
                "vt": "str"
            }
        ],
        "repeat": "5",
        "crontab": "",
        "once": true,
        "onceDelay": "60",
        "topic": "",
        "payload": "",
        "payloadType": "date",
        "x": 75,
        "y": 60,
        "wires": [
            []
        ],
        "l": false
    },
    {
        "id": "a4dab5d4091589a0",
        "type": "function",
        "z": "a6ecc454e1b3c0c3",
        "name": "function 26",
        "func": "msg.payload = global.get(\"source\") || \"-\";\nreturn msg;",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 530,
        "y": 520,
        "wires": [
            [
                "6bda80ac4b036aac"
            ]
        ]
    },
    {
        "id": "35f043d859b8937c",
        "type": "ui-form",
        "z": "a6ecc454e1b3c0c3",
        "name": "Source",
        "group": "4d19f97e8673be96",
        "label": "",
        "order": 2,
        "width": "4",
        "height": 0,
        "options": [
            {
                "label": "source",
                "key": "source",
                "type": "dropdown",
                "required": true,
                "rows": null
            }
        ],
        "formValue": {
            "source": ""
        },
        "payload": "",
        "submit": "submit",
        "cancel": "",
        "resetOnSubmit": true,
        "topic": "topic",
        "topicType": "msg",
        "splitLayout": "",
        "className": "",
        "passthru": false,
        "dropdownOptions": [
            {
                "dropdown": "source",
                "value": "1",
                "label": "1"
            },
            {
                "dropdown": "source",
                "value": "2",
                "label": "2"
            },
            {
                "dropdown": "source",
                "value": "3",
                "label": "3"
            },
            {
                "dropdown": "source",
                "value": "4",
                "label": "4"
            },
            {
                "dropdown": "source",
                "value": "5",
                "label": "5"
            },
            {
                "dropdown": "source",
                "value": "6",
                "label": "6"
            },
            {
                "dropdown": "source",
                "value": "7",
                "label": "7"
            },
            {
                "dropdown": "source",
                "value": "8",
                "label": "8"
            },
            {
                "dropdown": "source",
                "value": "9",
                "label": "9"
            }
        ],
        "x": 120,
        "y": 560,
        "wires": [
            [
                "388a61be8ad3f3fd"
            ]
        ]
    },
    {
        "id": "6bda80ac4b036aac",
        "type": "ui-text",
        "z": "a6ecc454e1b3c0c3",
        "group": "4d19f97e8673be96",
        "order": 1,
        "width": "2",
        "height": "1",
        "name": "Source",
        "label": "Source : ",
        "format": "{{msg.payload}}",
        "layout": "row-center",
        "style": false,
        "font": "",
        "fontSize": 16,
        "color": "#717171",
        "wrapText": false,
        "className": "",
        "x": 680,
        "y": 520,
        "wires": []
    },
    {
        "id": "07a96f5ffd797c28",
        "type": "inject",
        "z": "a6ecc454e1b3c0c3",
        "name": "",
        "props": [
            {
                "p": "payload"
            },
            {
                "p": "topic",
                "vt": "str"
            }
        ],
        "repeat": "",
        "crontab": "",
        "once": true,
        "onceDelay": "60",
        "topic": "",
        "payload": "",
        "payloadType": "date",
        "x": 425,
        "y": 520,
        "wires": [
            [
                "a4dab5d4091589a0"
            ]
        ],
        "l": false
    },
    {
        "id": "388a61be8ad3f3fd",
        "type": "function",
        "z": "a6ecc454e1b3c0c3",
        "name": "function 28",
        "func": "msg.payload = msg.payload.source;\nvar source = Number(msg.payload)\nglobal.set(\"source\", source)\nreturn msg;",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 290,
        "y": 560,
        "wires": [
            [
                "51dc1c2d2107552d"
            ]
        ]
    },
    {
        "id": "51dc1c2d2107552d",
        "type": "file",
        "z": "a6ecc454e1b3c0c3",
        "name": "",
        "filename": "/home/orangepi/loom/source.txt",
        "filenameType": "str",
        "appendNewline": true,
        "createDir": true,
        "overwriteFile": "true",
        "encoding": "none",
        "x": 415,
        "y": 560,
        "wires": [
            [
                "a4dab5d4091589a0"
            ]
        ],
        "l": false
    },
    {
        "id": "329b2dc06d31e4a6",
        "type": "file",
        "z": "7a70a201eaa0a148",
        "name": "Write",
        "filename": "path",
        "filenameType": "msg",
        "appendNewline": false,
        "createDir": true,
        "overwriteFile": "false",
        "encoding": "utf8",
        "x": 115,
        "y": 80,
        "wires": [
            [
                "b899c4a32f80d2b3"
            ]
        ],
        "l": false
    },
    {
        "id": "7bda5491c4569ef2",
        "type": "file in",
        "z": "7a70a201eaa0a148",
        "name": "",
        "filename": "path",
        "filenameType": "msg",
        "format": "utf8",
        "chunk": false,
        "sendError": false,
        "encoding": "none",
        "allProps": false,
        "x": 235,
        "y": 80,
        "wires": [
            [
                "9ad283424a955e6e"
            ]
        ],
        "l": false
    },
    {
        "id": "b899c4a32f80d2b3",
        "type": "delay",
        "z": "7a70a201eaa0a148",
        "name": "",
        "pauseType": "delay",
        "timeout": "50",
        "timeoutUnits": "milliseconds",
        "rate": "1",
        "nbRateUnits": "1",
        "rateUnits": "second",
        "randomFirst": "1",
        "randomLast": "5",
        "randomUnits": "seconds",
        "drop": false,
        "allowrate": false,
        "outputs": 1,
        "x": 175,
        "y": 80,
        "wires": [
            [
                "7bda5491c4569ef2"
            ]
        ],
        "l": false
    },
    {
        "id": "9ad283424a955e6e",
        "type": "csv",
        "z": "7a70a201eaa0a148",
        "name": "",
        "sep": ",",
        "hdrin": "",
        "hdrout": "none",
        "multi": "mult",
        "ret": "\\n",
        "temp": "",
        "skip": "0",
        "strings": true,
        "include_empty_strings": "",
        "include_null_values": "",
        "x": 295,
        "y": 80,
        "wires": [
            [
                "6bf085a9f0b65ea1"
            ]
        ],
        "l": false
    },
    {
        "id": "6bf085a9f0b65ea1",
        "type": "function",
        "z": "7a70a201eaa0a148",
        "name": "le",
        "func": "var length = msg.payload.length;\nlength = length - 1;\nglobal.set(\"config.state.row\", length);\nif(length <= 1){\n    global.set(\"config.state.index\", 0);\n};\nmsg.payload = {\n    fill: \"blue\",\n    shape: \"dot\",\n    text: `row:${length}`};\nreturn msg;",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 355,
        "y": 80,
        "wires": [
            []
        ],
        "l": false
    },
    {
        "id": "ef469af3a6dd75f8",
        "type": "switch",
        "z": "f1016d6dfc436da7",
        "name": "",
        "property": "file",
        "propertyType": "msg",
        "rules": [
            {
                "t": "eq",
                "v": "0",
                "vt": "str"
            },
            {
                "t": "eq",
                "v": "1",
                "vt": "str"
            }
        ],
        "checkall": "true",
        "repair": false,
        "outputs": 2,
        "x": 125,
        "y": 60,
        "wires": [
            [
                "94b9bf90eedb0722"
            ],
            [
                "b536e3111c63eed1"
            ]
        ],
        "l": false
    },
    {
        "id": "94b9bf90eedb0722",
        "type": "function",
        "z": "f1016d6dfc436da7",
        "name": "data Log",
        "func": "const payload = msg.payload;\nconst date = payload.date;\nconst time = payload.time;\nconst timestamp = payload.timestamp;\nconst ip = payload.ip;\nconst date_data = payload.date_data;\nconst upt = payload.upt;\n\n// values \nconst main = payload.values.maintake.main;\nconst take = payload.values.maintake.take;\nconst meter = payload.values.meter;\nconst working = payload.values.working;\nconst total = payload.values.total;\n\nmsg.payload = {\n    'date': date,\n    'time': time,\n    'timestamp': timestamp,\n    'ip': ip,\n    'date_data': date_data,\n    'total_meter': total.meter.total,\n    'total_meterA': total.meter.totala,\n    'total_meterB': total.meter.totalb,\n    'meterNLA': total.meter.nla,\n    'meterNLB': total.meter.nlb,\n    'meterOTA': total.meter.ota,\n    'meterOTB': total.meter.otb,\n    'm_0': meter[0],\n    'm_1': meter[1],\n    'm_2': meter[2],\n    'm_3': meter[3],\n    'm_4': meter[4],\n    'm_5': meter[5],\n    'm_6': meter[6],\n    'm_7': meter[7],\n    'm_8': meter[8],\n    'm_9': meter[9],\n    'm_10': meter[10],\n    'm_11': meter[11],\n    'm_12': meter[12],\n    'm_13': meter[13],\n    'm_14': meter[14],\n    'm_15': meter[15],\n    'm_16': meter[16],\n    'm_17': meter[17],\n    'm_18': meter[18],\n    'm_19': meter[19],\n    'm_20': meter[20],\n    'm_21': meter[21],\n    'm_22': meter[22],\n    'm_23': meter[23],\n    'total_working': total.working.total,\n    'total_workingA': total.working.totala,\n    'total_workingB': total.working.totalb,\n    'workingNLA': total.working.nla,\n    'workingNLB': total.working.nlb,\n    'workingOTA': total.working.ota,\n    'workingOTB': total.working.otb,\n    'w_0': working[0],\n    'w_1': working[1],\n    'w_2': working[2],\n    'w_3': working[3],\n    'w_4': working[4],\n    'w_5': working[5],\n    'w_6': working[6],\n    'w_7': working[7],\n    'w_8': working[8],\n    'w_9': working[9],\n    'w_10': working[10],\n    'w_11': working[11],\n    'w_12': working[12],\n    'w_13': working[13],\n    'w_14': working[14],\n    'w_15': working[15],\n    'w_16': working[16],\n    'w_17': working[17],\n    'w_18': working[18],\n    'w_19': working[19],\n    'w_20': working[20],\n    'w_21': working[21],\n    'w_22': working[22],\n    'w_23': working[23],\n    'main_now': main.now || 0,\n    'main_min': main.min || 0,\n    'main_max': main.max || 0,\n    'take_now': take.now || 0,\n    'take_min': take.min || 0,\n    'take_max': take.max || 0,\n    'upTimetotal': upt.total,\n    'upTimetotalA': upt.totalA,\n    'upTimetotalB': upt.totalB,\n    'upTimenla': upt.nla,\n    'upTimeota': upt.ota,\n    'upTimenlb': upt.nlb,\n    'upTimeotb': upt.otb,\n}\nreturn msg;",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 220,
        "y": 40,
        "wires": [
            [
                "562f9af20391c406"
            ]
        ]
    },
    {
        "id": "b536e3111c63eed1",
        "type": "function",
        "z": "f1016d6dfc436da7",
        "name": "data Log",
        "func": "const payload = msg.payload;\nconst date = payload.date;\nconst time = payload.time;\nconst timestamp = payload.timestamp;\nconst ip = payload.ip;\nconst date_data = payload.date_data;\nconst upt = payload.upt;\n\n// values \nconst main = payload.values.maintake.main;\nconst take = payload.values.maintake.take;\nconst meter = payload.values.meter;\nconst working = payload.values.working;\nconst total = payload.values.total;\n\nmsg.payload = {\n    'date': date,\n    'time': time,\n    'timestamp': timestamp,\n    'ip': ip,\n    'date_data': date_data,\n    'total_meter': total.meter.total,\n    'total_meterA': total.meter.totala,\n    'total_meterB': total.meter.totalb,\n    'meterNLA': total.meter.nla,\n    'meterNLB': total.meter.nlb,\n    'meterOTA': total.meter.ota,\n    'meterOTB': total.meter.otb,\n    'm_0': meter[0],\n    'm_1': meter[1],\n    'm_2': meter[2],\n    'm_3': meter[3],\n    'm_4': meter[4],\n    'm_5': meter[5],\n    'm_6': meter[6],\n    'm_7': meter[7],\n    'm_8': meter[8],\n    'm_9': meter[9],\n    'm_10': meter[10],\n    'm_11': meter[11],\n    'm_12': meter[12],\n    'm_13': meter[13],\n    'm_14': meter[14],\n    'm_15': meter[15],\n    'm_16': meter[16],\n    'm_17': meter[17],\n    'm_18': meter[18],\n    'm_19': meter[19],\n    'm_20': meter[20],\n    'm_21': meter[21],\n    'm_22': meter[22],\n    'm_23': meter[23],\n    'total_working': total.working.total,\n    'total_workingA': total.working.totala,\n    'total_workingB': total.working.totalb,\n    'workingNLA': total.working.nla,\n    'workingNLB': total.working.nlb,\n    'workingOTA': total.working.ota,\n    'workingOTB': total.working.otb,\n    'w_0': working[0],\n    'w_1': working[1],\n    'w_2': working[2],\n    'w_3': working[3],\n    'w_4': working[4],\n    'w_5': working[5],\n    'w_6': working[6],\n    'w_7': working[7],\n    'w_8': working[8],\n    'w_9': working[9],\n    'w_10': working[10],\n    'w_11': working[11],\n    'w_12': working[12],\n    'w_13': working[13],\n    'w_14': working[14],\n    'w_15': working[15],\n    'w_16': working[16],\n    'w_17': working[17],\n    'w_18': working[18],\n    'w_19': working[19],\n    'w_20': working[20],\n    'w_21': working[21],\n    'w_22': working[22],\n    'w_23': working[23],\n    'main_now': main.now || 0,\n    'main_min': main.min || 0,\n    'main_max': main.max || 0,\n    'take_now': take.now || 0,\n    'take_min': take.min || 0,\n    'take_max': take.max || 0,\n    'upTimetotal': upt.total,\n    'upTimetotalA': upt.totalA,\n    'upTimetotalB': upt.totalB,\n    'upTimenla': upt.nla,\n    'upTimeota': upt.ota,\n    'upTimenlb': upt.nlb,\n    'upTimeotb': upt.otb,\n}\nreturn msg;",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 220,
        "y": 80,
        "wires": [
            [
                "580c9972ff966756"
            ]
        ]
    },
    {
        "id": "562f9af20391c406",
        "type": "csv",
        "z": "f1016d6dfc436da7",
        "name": "",
        "sep": ",",
        "hdrin": "",
        "hdrout": "all",
        "multi": "one",
        "ret": "\\r\\n",
        "temp": "date,time,timestamp,ip,date_data,total_meter,meterNLA,meterOTA,total_meterA,meterNLB,meterOTB,total_meterB,m_0,m_1,m_2,m_3,m_4,m_5,m_6,m_7,m_8,m_9,m_10,m_11,m_12,m_13,m_14,m_15,m_16,m_17,m_18,m_19,m_20,m_21,m_22,m_23,total_working,workingNLA,workingOTA,total_workingA,workingNLB,workingOTB,total_workingB,w_0,w_1,w_2,w_3,w_4,w_5,w_6,w_7,w_8,w_9,w_10,w_11,w_12,w_13,w_14,w_15,w_16,w_17,w_18,w_19,w_20,w_21,w_22,w_23,main_now,main_min,main_max,take_now,take_min,take_max,upTimetotal,upTimetotalA,upTimetotalB,upTimenla,upTimeota,upTimenlb,upTimeotb",
        "skip": "0",
        "strings": true,
        "include_empty_strings": "",
        "include_null_values": "",
        "x": 315,
        "y": 40,
        "wires": [
            []
        ],
        "l": false
    },
    {
        "id": "580c9972ff966756",
        "type": "csv",
        "z": "f1016d6dfc436da7",
        "name": "",
        "sep": ",",
        "hdrin": "",
        "hdrout": "none",
        "multi": "one",
        "ret": "\\r\\n",
        "temp": "date,time,timestamp,ip,date_data,total_meter,meterNLA,meterOTA,total_meterA,meterNLB,meterOTB,total_meterB,m_0,m_1,m_2,m_3,m_4,m_5,m_6,m_7,m_8,m_9,m_10,m_11,m_12,m_13,m_14,m_15,m_16,m_17,m_18,m_19,m_20,m_21,m_22,m_23,total_working,workingNLA,workingOTA,total_workingA,workingNLB,workingOTB,total_workingB,w_0,w_1,w_2,w_3,w_4,w_5,w_6,w_7,w_8,w_9,w_10,w_11,w_12,w_13,w_14,w_15,w_16,w_17,w_18,w_19,w_20,w_21,w_22,w_23,main_now,main_min,main_max,take_now,take_min,take_max,upTimetotal,upTimetotalA,upTimetotalB,upTimenla,upTimeota,upTimenlb,upTimeotb",
        "skip": "0",
        "strings": true,
        "include_empty_strings": "",
        "include_null_values": "",
        "x": 315,
        "y": 80,
        "wires": [
            []
        ],
        "l": false
    },
    {
        "id": "5bd37418f0f1f7c3",
        "type": "function",
        "z": "78457dab5d6c0503",
        "name": "meter",
        "func": "var date = new Date(msg.payload);\nlet previousDate = new Date(date); \n    previousDate.setDate(previousDate.getDate() - 1).toString().padStart(2, 0);\nvar year = date.getFullYear(); \nvar month = (date.getMonth() + 1).toString().padStart(2, '0');\nvar day = date.getDate().toString().padStart(2, '0');\nvar hour = date.getHours().toString().padStart(2, '0');\nlet fs_c = flow.get(\"fs\");\nlet fs = (Number(global.get(\"config.datetime.minute\"))) <= 30 ? \"f\" : \"s\";\nmsg.path = `/home/orangepi/deviceLog/${year}/${month}-${day}/${hour}/${fs}.csv`;\nlet path = `/home/orangepi/deviceLog/${year}/`;\nflow.set(\"path\", path);\nif(fs != fs_c){\n    flow.set(\"fs\", fs);\n    msg.reset = \" \";\n}\nmsg.payload = {\n    'ts': flow.get(\"ts\"),\n    'date': global.get(\"config.datetime.date\"),\n    'time': global.get(\"config.datetime.time\"),\n    'ip': global.get(\"config.state.ip\"),\n    'index': global.get(\"config.state.index\"),\n    'datestamp': global.get(\"config.state.datestamp\"),\n    'datenow': global.get(\"config.state.datenow\"),\n    'main': global.get(\"values.maintake.main.now\"),\n    'm_min': global.get(\"values.maintake.main.min\"),\n    'm_max': global.get(\"values.maintake.main.max\"),\n    'take': global.get(\"values.maintake.take.now\"),\n    't_min': global.get(\"values.maintake.take.min\"),\n    't_max': global.get(\"values.maintake.take.max\"),\n    'take_cal': Number(parseFloat(((global.get(\"values.maintake.main.now\") * 8) / 39.37) / 7.7).toFixed(2)) || 0,\n    'count': global.get(\"hex32\"),\n    'total_m': global.get(\"values.total.meter.total\"),\n};\nnode.status({ fill: \"blue\", shape: \"dot\", text:\"count: \" + global.get(\"hex32\")});\nreturn msg;",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 190,
        "y": 140,
        "wires": [
            [
                "656d5fdf90f37195",
                "11d7e025f0296cd9"
            ]
        ]
    },
    {
        "id": "656d5fdf90f37195",
        "type": "function",
        "z": "78457dab5d6c0503",
        "name": "function 3",
        "func": "msg.payload = {\n    'fill': 'blue',\n    'shape': 'dot',\n    'text': `[C]: ${global.get(\"hex32\")}`\n}\nreturn msg;",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 285,
        "y": 180,
        "wires": [
            []
        ],
        "l": false
    },
    {
        "id": "11d7e025f0296cd9",
        "type": "csv",
        "z": "78457dab5d6c0503",
        "name": "",
        "sep": ",",
        "hdrin": false,
        "hdrout": "once",
        "multi": "one",
        "ret": "\\r\\n",
        "temp": "",
        "skip": "0",
        "strings": true,
        "include_empty_strings": "",
        "include_null_values": "",
        "x": 340,
        "y": 140,
        "wires": [
            [
                "5971486c721e0300"
            ]
        ]
    },
    {
        "id": "5971486c721e0300",
        "type": "file",
        "z": "78457dab5d6c0503",
        "name": "",
        "filename": "path",
        "filenameType": "msg",
        "appendNewline": false,
        "createDir": true,
        "overwriteFile": "false",
        "encoding": "utf8",
        "x": 500,
        "y": 140,
        "wires": [
            []
        ]
    },
    {
        "id": "d1c1aa82c8b72a93",
        "type": "function",
        "z": "78457dab5d6c0503",
        "name": "function 4",
        "func": "let path = flow.get(\"path\");\nmsg.payload = { 'start': path}\nreturn msg;",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 200,
        "y": 300,
        "wires": [
            [
                "d9db9591a4d3b731"
            ]
        ]
    },
    {
        "id": "d9db9591a4d3b731",
        "type": "fs-file-lister",
        "z": "78457dab5d6c0503",
        "name": "",
        "start": "/",
        "pattern": "*.*",
        "folders": "*",
        "hidden": true,
        "lstype": "directories",
        "path": true,
        "single": true,
        "depth": "0",
        "stat": true,
        "showWarnings": false,
        "x": 360,
        "y": 300,
        "wires": [
            [
                "c1dfe81f680e6f01"
            ]
        ]
    },
    {
        "id": "18936721347779ca",
        "type": "function",
        "z": "78457dab5d6c0503",
        "name": "function 7",
        "func": "flow.set(\"speed_main_motor\", msg.main);\nflow.set(\"speed_take_up\", msg.take);\nflow.set(\"take_cal\", msg.take_cal);\nflow.set(\"ts\", msg.payload);",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 200,
        "y": 80,
        "wires": [
            []
        ]
    },
    {
        "id": "c1dfe81f680e6f01",
        "type": "function",
        "z": "78457dab5d6c0503",
        "name": "function 5",
        "func": "let length = msg.payload.length;\nlet delete_file = msg.payload[0].name;\n    if(length > 30){\n        msg.payload = `rm -rf ${delete_file}`\n        return msg;\n    }",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 520,
        "y": 300,
        "wires": [
            [
                "d376633b3de3778a"
            ]
        ]
    },
    {
        "id": "d376633b3de3778a",
        "type": "exec",
        "z": "78457dab5d6c0503",
        "command": "",
        "addpay": "payload",
        "append": "",
        "useSpawn": "false",
        "timer": "",
        "winHide": false,
        "oldrc": false,
        "name": "",
        "x": 730,
        "y": 300,
        "wires": [
            [],
            [],
            []
        ]
    },
    {
        "id": "22b7ddd5b8f324e8",
        "type": "inject",
        "z": "78457dab5d6c0503",
        "name": "",
        "props": [
            {
                "p": "payload"
            },
            {
                "p": "topic",
                "vt": "str"
            }
        ],
        "repeat": "60",
        "crontab": "",
        "once": false,
        "onceDelay": 0.1,
        "topic": "",
        "payload": "",
        "payloadType": "date",
        "x": 85,
        "y": 300,
        "wires": [
            [
                "d1c1aa82c8b72a93"
            ]
        ],
        "l": false
    },
    {
        "id": "5c5791a7e918e097",
        "type": "ui-button",
        "z": "9f979da7e8a5400d",
        "group": "952156841f214b55",
        "name": "",
        "label": "ตั้งค่า PLC Variable",
        "order": 6,
        "width": "2",
        "height": "1",
        "emulateClick": false,
        "tooltip": "",
        "color": "",
        "bgcolor": "",
        "className": "",
        "icon": "",
        "iconPosition": "left",
        "payload": "{\"groups\":{\"show\":[\"config\"]}}",
        "payloadType": "json",
        "topic": "topic",
        "topicType": "msg",
        "buttonColor": "#fcba03",
        "textColor": "#0390fc",
        "iconColor": "#0390fc",
        "enableClick": true,
        "enablePointerdown": false,
        "pointerdownPayload": "",
        "pointerdownPayloadType": "str",
        "enablePointerup": false,
        "pointerupPayload": "",
        "pointerupPayloadType": "str",
        "x": 310,
        "y": 100,
        "wires": [
            [
                "dcfea8d096692be8"
            ]
        ]
    },
    {
        "id": "dcfea8d096692be8",
        "type": "ui-control",
        "z": "9f979da7e8a5400d",
        "name": "",
        "ui": "d6f3a7fd07525d85",
        "events": "change",
        "x": 480,
        "y": 100,
        "wires": [
            [
                "4946e13302ee79ae"
            ]
        ]
    },
    {
        "id": "4946e13302ee79ae",
        "type": "function",
        "z": "9f979da7e8a5400d",
        "name": "function 16",
        "func": "if(msg.payload === \"input\"){\nreturn msg;\n}",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 170,
        "y": 140,
        "wires": [
            [
                "79de3f0fece60746"
            ]
        ]
    },
    {
        "id": "79de3f0fece60746",
        "type": "file in",
        "z": "9f979da7e8a5400d",
        "name": "json",
        "filename": "/home/orangepi/telemetry/conf.json",
        "filenameType": "str",
        "format": "utf8",
        "chunk": false,
        "sendError": false,
        "encoding": "utf8",
        "allProps": false,
        "x": 330,
        "y": 140,
        "wires": [
            [
                "396d0e5d38f1df7e"
            ]
        ]
    },
    {
        "id": "1a0ec2562c8e47a4",
        "type": "function",
        "z": "9f979da7e8a5400d",
        "name": "json",
        "func": "const item = JSON.parse(msg.payload);\nflow.set(\"code\", item.code);\nflow.set(\"source\", item.source);\nflow.set(\"circumferance\", item.circumferance);\nflow.set(\"gearratio\", item.gearratio);\nmsg.gear = item[`gear-ratio`];\nmsg.circumferance = item.circumferance;\nreturn msg;",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 530,
        "y": 140,
        "wires": [
            [
                "efb259636c782777"
            ]
        ]
    },
    {
        "id": "efb259636c782777",
        "type": "function",
        "z": "9f979da7e8a5400d",
        "name": "function 17",
        "func": "msg.payload = {\n    'gearratio': flow.get(\"gearratio\"),\n    'circumferance': flow.get(\"circumferance\"),\n}\nreturn msg;",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 690,
        "y": 140,
        "wires": [
            [
                "9938c77dc51972b2"
            ]
        ]
    },
    {
        "id": "396d0e5d38f1df7e",
        "type": "delay",
        "z": "9f979da7e8a5400d",
        "name": "",
        "pauseType": "delay",
        "timeout": "500",
        "timeoutUnits": "milliseconds",
        "rate": "1",
        "nbRateUnits": "1",
        "rateUnits": "second",
        "randomFirst": "1",
        "randomLast": "5",
        "randomUnits": "seconds",
        "drop": false,
        "allowrate": false,
        "outputs": 1,
        "x": 435,
        "y": 140,
        "wires": [
            [
                "1a0ec2562c8e47a4"
            ]
        ],
        "l": false
    },
    {
        "id": "9938c77dc51972b2",
        "type": "ui-form",
        "z": "9f979da7e8a5400d",
        "name": "",
        "group": "d850f97a7e8193d4",
        "label": "ตั้งค่าตัวแปร",
        "order": 1,
        "width": "4",
        "height": "4",
        "options": [
            {
                "label": "Gear Ratio",
                "key": "gearratio",
                "type": "number",
                "required": false,
                "rows": null
            },
            {
                "label": "Circumferance",
                "key": "circumferance",
                "type": "number",
                "required": false,
                "rows": null
            }
        ],
        "formValue": {
            "gearratio": "",
            "circumferance": ""
        },
        "payload": "",
        "submit": "submit",
        "cancel": "clear",
        "resetOnSubmit": true,
        "topic": "topic",
        "topicType": "msg",
        "splitLayout": "",
        "className": "",
        "passthru": false,
        "dropdownOptions": [],
        "x": 870,
        "y": 140,
        "wires": [
            [
                "65f38fc6cfb7c0bb"
            ]
        ]
    },
    {
        "id": "65f38fc6cfb7c0bb",
        "type": "function",
        "z": "9f979da7e8a5400d",
        "name": "function 18",
        "func": "msg.payload = `{\n    \"code\": \"${flow.get(\"code\")}\",\n    \"source\": \"${flow.get(\"source\")}\",\n    \"circumferance\": ${msg.payload.circumferance},\n    \"gearratio\": ${msg.payload.gearratio}\n}\n`\nreturn msg;",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 1050,
        "y": 140,
        "wires": [
            [
                "9cb047ed2c598281"
            ]
        ]
    },
    {
        "id": "9cb047ed2c598281",
        "type": "file",
        "z": "9f979da7e8a5400d",
        "name": "json",
        "filename": "/home/orangepi/telemetry/conf.json",
        "filenameType": "str",
        "appendNewline": true,
        "createDir": true,
        "overwriteFile": "true",
        "encoding": "utf8",
        "x": 1210,
        "y": 140,
        "wires": [
            []
        ]
    },
    {
        "id": "614c8d9f5fc2027b",
        "type": "exec",
        "z": "9f979da7e8a5400d",
        "command": "reboot",
        "addpay": "",
        "append": "",
        "useSpawn": "false",
        "timer": "",
        "winHide": false,
        "oldrc": false,
        "name": "",
        "x": 285,
        "y": 200,
        "wires": [
            [],
            [],
            []
        ],
        "l": false
    },
    {
        "id": "cf2eeb6effb95c04",
        "type": "ui-button",
        "z": "9f979da7e8a5400d",
        "group": "d850f97a7e8193d4",
        "name": "",
        "label": "Reboot",
        "order": 3,
        "width": "1",
        "height": "1",
        "emulateClick": false,
        "tooltip": "",
        "color": "",
        "bgcolor": "",
        "className": "",
        "icon": "power",
        "iconPosition": "left",
        "payload": "reboot",
        "payloadType": "str",
        "topic": "topic",
        "topicType": "msg",
        "buttonColor": "#eb4034",
        "textColor": "#3434eb",
        "iconColor": "#3434eb",
        "enableClick": true,
        "enablePointerdown": false,
        "pointerdownPayload": "",
        "pointerdownPayloadType": "str",
        "enablePointerup": false,
        "pointerupPayload": "",
        "pointerupPayloadType": "str",
        "x": 160,
        "y": 200,
        "wires": [
            [
                "614c8d9f5fc2027b"
            ]
        ]
    },
    {
        "id": "832b511fc77ba65b",
        "type": "ui-button",
        "z": "9f979da7e8a5400d",
        "group": "d850f97a7e8193d4",
        "name": "",
        "label": "Reset",
        "order": 2,
        "width": "1",
        "height": "1",
        "emulateClick": false,
        "tooltip": "",
        "color": "",
        "bgcolor": "",
        "className": "",
        "icon": "arrow-down-circle",
        "iconPosition": "left",
        "payload": "reboot",
        "payloadType": "str",
        "topic": "topic",
        "topicType": "msg",
        "buttonColor": "#45d428",
        "textColor": "#f0f6ff",
        "iconColor": "#f0f6ff",
        "enableClick": true,
        "enablePointerdown": false,
        "pointerdownPayload": "",
        "pointerdownPayloadType": "str",
        "enablePointerup": false,
        "pointerupPayload": "",
        "pointerupPayloadType": "str",
        "x": 150,
        "y": 260,
        "wires": [
            [
                "ef14953ba7182e68"
            ]
        ]
    },
    {
        "id": "68be1a95753d3c2c",
        "type": "ui-button",
        "z": "9f979da7e8a5400d",
        "group": "d850f97a7e8193d4",
        "name": "",
        "label": "Emtry",
        "order": 4,
        "width": "1",
        "height": "1",
        "emulateClick": false,
        "tooltip": "",
        "color": "",
        "bgcolor": "",
        "className": "",
        "icon": "null",
        "iconPosition": "right",
        "payload": "reboot",
        "payloadType": "str",
        "topic": "topic",
        "topicType": "msg",
        "buttonColor": "#949494",
        "textColor": "#4a4949",
        "iconColor": "#4a4949",
        "enableClick": false,
        "enablePointerdown": false,
        "pointerdownPayload": "",
        "pointerdownPayloadType": "str",
        "enablePointerup": false,
        "pointerupPayload": "",
        "pointerupPayloadType": "str",
        "x": 150,
        "y": 320,
        "wires": [
            []
        ]
    },
    {
        "id": "aef2d50c3ec3c0d8",
        "type": "inject",
        "z": "9f979da7e8a5400d",
        "name": "",
        "props": [
            {
                "p": "payload"
            },
            {
                "p": "topic",
                "vt": "str"
            }
        ],
        "repeat": "60",
        "crontab": "",
        "once": true,
        "onceDelay": "59",
        "topic": "",
        "payload": "",
        "payloadType": "date",
        "x": 170,
        "y": 380,
        "wires": [
            [
                "2155c9bb280942c8",
                "8d08ccb4c02573cb",
                "1e2c80a1110b05a5",
                "79cf397d7f04eec1",
                "76063224b269c468",
                "7d256f0f0faefbc2",
                "6658d815c8420cf3"
            ]
        ]
    },
    {
        "id": "2155c9bb280942c8",
        "type": "function",
        "z": "9f979da7e8a5400d",
        "name": "SELECT Local",
        "func": "const db = context.get(\"db\");\ntry{\n        const item = db.prepare(`\n        SELECT id, create_at, sent, total_meter, total_work, speed_main, speed_take \n        FROM telemetry_local\n        ORDER BY create_at DESC\n        LIMIT 10;\n        `).all();\n        msg.payload = item;\n        return msg;\n    } catch (err) {\n        node.error(err);\n    }",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "// Code added here will be run once\n// whenever the node is started.\n// const Database = require('better-sqlite3');\ncontext.set(\"db\", new Database('/home/orangepi/telemetry/sql/telemetry_factory.db'));",
        "finalize": "// Code added here will be run when the\n// node is being stopped or re-deployed.\nconst db = context.get(\"db\");\nif (db) db.close();",
        "libs": [
            {
                "var": "Database",
                "module": "better-sqlite3"
            }
        ],
        "x": 360,
        "y": 380,
        "wires": [
            [
                "a3a72c1933d9018f"
            ]
        ],
        "icon": "font-awesome/fa-archive"
    },
    {
        "id": "8d08ccb4c02573cb",
        "type": "function",
        "z": "9f979da7e8a5400d",
        "name": "SELECT Cloud",
        "func": "const db = context.get(\"db\");\ntry{\n        const item = db.prepare(`\n        SELECT id, create_at, sent, total_meter, total_work, speed_main, speed_take\n        FROM telemetry_cloud\n        ORDER BY create_at DESC\n        LIMIT 10;\n        `).all();\n        msg.payload = item;\n        return msg;\n    } catch (err) {\n        node.error(err);\n    }",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "// Code added here will be run once\n// whenever the node is started.\n// const Database = require('better-sqlite3');\ncontext.set(\"db\", new Database('/home/orangepi/telemetry/sql/telemetry_factory.db'));",
        "finalize": "// Code added here will be run when the\n// node is being stopped or re-deployed.\nconst db = context.get(\"db\");\nif (db) db.close();",
        "libs": [
            {
                "var": "Database",
                "module": "better-sqlite3"
            }
        ],
        "x": 360,
        "y": 420,
        "wires": [
            [
                "39b7d84689427618"
            ]
        ],
        "icon": "font-awesome/fa-archive"
    },
    {
        "id": "a3a72c1933d9018f",
        "type": "ui-table",
        "z": "9f979da7e8a5400d",
        "group": "952156841f214b55",
        "name": "Local Logging 10",
        "label": "Local Logging",
        "order": 8,
        "width": "6",
        "height": "0",
        "maxrows": 0,
        "passthru": false,
        "autocols": true,
        "showSearch": true,
        "deselect": true,
        "selectionType": "none",
        "columns": [],
        "mobileBreakpoint": "sm",
        "mobileBreakpointType": "defaults",
        "action": "replace",
        "className": "",
        "x": 590,
        "y": 380,
        "wires": [
            []
        ]
    },
    {
        "id": "39b7d84689427618",
        "type": "ui-table",
        "z": "9f979da7e8a5400d",
        "group": "952156841f214b55",
        "name": "Cloud Logging 10",
        "label": "Cloud Logging",
        "order": 7,
        "width": "6",
        "height": "0",
        "maxrows": 0,
        "passthru": false,
        "autocols": true,
        "showSearch": true,
        "deselect": true,
        "selectionType": "none",
        "columns": [],
        "mobileBreakpoint": "sm",
        "mobileBreakpointType": "defaults",
        "action": "replace",
        "className": "",
        "x": 590,
        "y": 420,
        "wires": [
            []
        ]
    },
    {
        "id": "1e2c80a1110b05a5",
        "type": "function",
        "z": "9f979da7e8a5400d",
        "name": "SELECT Local",
        "func": "const db = context.get(\"db\");\ntry{\n        const item = db.prepare(`\n        SELECT * \n        FROM telemetry_local\n        ORDER BY create_at DESC\n        LIMIT 100;\n        `).all();\n        msg.payload = item;\n        return msg;\n    } catch (err) {\n        node.error(err);\n    }",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "// Code added here will be run once\n// whenever the node is started.\n// const Database = require('better-sqlite3');\ncontext.set(\"db\", new Database('/home/orangepi/telemetry/sql/telemetry_factory.db'));",
        "finalize": "// Code added here will be run when the\n// node is being stopped or re-deployed.\nconst db = context.get(\"db\");\nif (db) db.close();",
        "libs": [
            {
                "var": "Database",
                "module": "better-sqlite3"
            }
        ],
        "x": 360,
        "y": 520,
        "wires": [
            [
                "8ffe8c6c00ea7e45"
            ]
        ],
        "icon": "font-awesome/fa-archive"
    },
    {
        "id": "79cf397d7f04eec1",
        "type": "function",
        "z": "9f979da7e8a5400d",
        "name": "SELECT Cloud",
        "func": "const db = context.get(\"db\");\ntry{\n        const item = db.prepare(`\n        SELECT * \n        FROM telemetry_cloud\n        ORDER BY create_at DESC\n        LIMIT 100;\n        `).all();\n        msg.payload = item;\n        return msg;\n    } catch (err) {\n        node.error(err);\n    }",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "// Code added here will be run once\n// whenever the node is started.\n// const Database = require('better-sqlite3');\ncontext.set(\"db\", new Database('/home/orangepi/telemetry/sql/telemetry_factory.db'));",
        "finalize": "// Code added here will be run when the\n// node is being stopped or re-deployed.\nconst db = context.get(\"db\");\nif (db) db.close();",
        "libs": [
            {
                "var": "Database",
                "module": "better-sqlite3"
            }
        ],
        "x": 360,
        "y": 560,
        "wires": [
            [
                "f6f48727fc9485fd"
            ]
        ],
        "icon": "font-awesome/fa-archive"
    },
    {
        "id": "8ffe8c6c00ea7e45",
        "type": "ui-table",
        "z": "9f979da7e8a5400d",
        "group": "944ab507dd3ee076",
        "name": "Local Logging 100",
        "label": "Local Logging",
        "order": 1,
        "width": "0",
        "height": "0",
        "maxrows": 0,
        "passthru": false,
        "autocols": true,
        "showSearch": true,
        "deselect": true,
        "selectionType": "none",
        "columns": [],
        "mobileBreakpoint": "sm",
        "mobileBreakpointType": "defaults",
        "action": "replace",
        "className": "",
        "x": 590,
        "y": 520,
        "wires": [
            []
        ]
    },
    {
        "id": "f6f48727fc9485fd",
        "type": "ui-table",
        "z": "9f979da7e8a5400d",
        "group": "67124f90455eaec9",
        "name": "Cloud Logging 100",
        "label": "Cloud Logging",
        "order": 1,
        "width": "0",
        "height": "0",
        "maxrows": 0,
        "passthru": false,
        "autocols": true,
        "showSearch": true,
        "deselect": true,
        "selectionType": "none",
        "columns": [],
        "mobileBreakpoint": "sm",
        "mobileBreakpointType": "defaults",
        "action": "replace",
        "className": "",
        "x": 590,
        "y": 560,
        "wires": [
            []
        ]
    },
    {
        "id": "76063224b269c468",
        "type": "function",
        "z": "9f979da7e8a5400d",
        "name": "SELECT Meter",
        "func": "const db = context.get(\"db\");\ntry{\n        const item = db.prepare(`\n        SELECT * \n        FROM telemetry_meter\n        ORDER BY create_at DESC\n        LIMIT 100;\n        `).all();\n        msg.payload = item;\n        return msg;\n    } catch (err) {\n        node.error(err);\n    }",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "// Code added here will be run once\n// whenever the node is started.\n// const Database = require('better-sqlite3');\ncontext.set(\"db\", new Database('/home/orangepi/telemetry/sql/telemetry_factory.db'));",
        "finalize": "// Code added here will be run when the\n// node is being stopped or re-deployed.\nconst db = context.get(\"db\");\nif (db) db.close();",
        "libs": [
            {
                "var": "Database",
                "module": "better-sqlite3"
            }
        ],
        "x": 360,
        "y": 600,
        "wires": [
            [
                "c56ab00c50e24a30"
            ]
        ],
        "icon": "font-awesome/fa-archive"
    },
    {
        "id": "c56ab00c50e24a30",
        "type": "ui-table",
        "z": "9f979da7e8a5400d",
        "group": "339734e2e645c9d0",
        "name": "Meter Logging 100",
        "label": "Meter Logging ",
        "order": 1,
        "width": "0",
        "height": "0",
        "maxrows": 0,
        "passthru": false,
        "autocols": true,
        "showSearch": true,
        "deselect": true,
        "selectionType": "none",
        "columns": [],
        "mobileBreakpoint": "sm",
        "mobileBreakpointType": "defaults",
        "action": "replace",
        "className": "",
        "x": 590,
        "y": 600,
        "wires": [
            []
        ]
    },
    {
        "id": "7d256f0f0faefbc2",
        "type": "function",
        "z": "9f979da7e8a5400d",
        "name": "SELECT Work",
        "func": "const db = context.get(\"db\");\ntry{\n        const item = db.prepare(`\n        SELECT * \n        FROM telemetry_work\n        ORDER BY create_at DESC\n        LIMIT 100;\n        `).all();\n        msg.payload = item;\n        return msg;\n    } catch (err) {\n        node.error(err);\n    }",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "// Code added here will be run once\n// whenever the node is started.\n// const Database = require('better-sqlite3');\ncontext.set(\"db\", new Database('/home/orangepi/telemetry/sql/telemetry_factory.db'));",
        "finalize": "// Code added here will be run when the\n// node is being stopped or re-deployed.\nconst db = context.get(\"db\");\nif (db) db.close();",
        "libs": [
            {
                "var": "Database",
                "module": "better-sqlite3"
            }
        ],
        "x": 360,
        "y": 640,
        "wires": [
            [
                "631c0742e2c6407e"
            ]
        ],
        "icon": "font-awesome/fa-archive"
    },
    {
        "id": "631c0742e2c6407e",
        "type": "ui-table",
        "z": "9f979da7e8a5400d",
        "group": "81b4388472b9bbd6",
        "name": "Working Logging 100",
        "label": "Working Logging ",
        "order": 1,
        "width": "0",
        "height": "0",
        "maxrows": 0,
        "passthru": false,
        "autocols": true,
        "showSearch": true,
        "deselect": true,
        "selectionType": "none",
        "columns": [],
        "mobileBreakpoint": "sm",
        "mobileBreakpointType": "defaults",
        "action": "replace",
        "className": "",
        "x": 600,
        "y": 640,
        "wires": [
            []
        ]
    },
    {
        "id": "6658d815c8420cf3",
        "type": "function",
        "z": "9f979da7e8a5400d",
        "name": "SELECT Cloud",
        "func": "const db = context.get(\"db\");\ntry{\n        const item = db.prepare(`\n        SELECT * \n        FROM telemetry_meter\n        ORDER BY create_at DESC\n        LIMIT 1;\n        `).all();\n        msg.payload = item;\n        return msg;\n    } catch (err) {\n        node.error(err);\n    }",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "// Code added here will be run once\n// whenever the node is started.\n// const Database = require('better-sqlite3');\ncontext.set(\"db\", new Database('/home/orangepi/telemetry/sql/telemetry_factory.db'));",
        "finalize": "// Code added here will be run when the\n// node is being stopped or re-deployed.\nconst db = context.get(\"db\");\nif (db) db.close();",
        "libs": [
            {
                "var": "Database",
                "module": "better-sqlite3"
            }
        ],
        "x": 360,
        "y": 460,
        "wires": [
            [
                "bef98c531b9ceeee"
            ]
        ],
        "icon": "font-awesome/fa-archive"
    },
    {
        "id": "bef98c531b9ceeee",
        "type": "ui-table",
        "z": "9f979da7e8a5400d",
        "group": "952156841f214b55",
        "name": "Local Meter Logging 10",
        "label": "Local Meter Logging",
        "order": 9,
        "width": "0",
        "height": "0",
        "maxrows": 0,
        "passthru": false,
        "autocols": true,
        "showSearch": false,
        "deselect": true,
        "selectionType": "none",
        "columns": [],
        "mobileBreakpoint": "sm",
        "mobileBreakpointType": "defaults",
        "action": "replace",
        "className": "",
        "x": 610,
        "y": 460,
        "wires": [
            []
        ]
    },
    {
        "id": "ef14953ba7182e68",
        "type": "function",
        "z": "9f979da7e8a5400d",
        "name": "function 19",
        "func": "global.set(\"config.state.changehour\", \"00\")\nreturn msg;",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 310,
        "y": 260,
        "wires": [
            []
        ]
    },
    {
        "id": "fbda616582fab4cb",
        "type": "http request",
        "z": "1406c468fdce7358",
        "name": "",
        "method": "use",
        "ret": "txt",
        "paytoqs": "ignore",
        "url": "",
        "tls": "",
        "persist": false,
        "proxy": "",
        "insecureHTTPParser": false,
        "authType": "",
        "senderr": false,
        "headers": [],
        "x": 350,
        "y": 80,
        "wires": [
            []
        ]
    },
    {
        "id": "62597ed5138d084d",
        "type": "function",
        "z": "1406c468fdce7358",
        "name": "function 10",
        "func": "let botToken = \"8181762860:AAEDyLgCoHmRrZ4nrSxUPYfe2Xsov_mvH3g\";\nlet chatId = \"-4940675177\";\nlet message = msg.payload;\n\nmsg.url = `https://api.telegram.org/bot${botToken}/sendMessage`;\nmsg.method = \"POST\";\nmsg.payload = {\n    chat_id: chatId,\n    text: message\n};\nreturn msg;",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 180,
        "y": 80,
        "wires": [
            [
                "fbda616582fab4cb"
            ]
        ]
    },
    {
        "id": "4d414fcfa4d1f563",
        "type": "inject",
        "z": "c9bf91fd5c385f43",
        "name": "",
        "props": [
            {
                "p": "payload"
            },
            {
                "p": "topic",
                "vt": "str"
            }
        ],
        "repeat": "1",
        "crontab": "",
        "once": true,
        "onceDelay": "6",
        "topic": "",
        "payload": "",
        "payloadType": "date",
        "x": 145,
        "y": 80,
        "wires": [
            [
                "d6a67c89385322a2"
            ]
        ],
        "l": false
    },
    {
        "id": "d6a67c89385322a2",
        "type": "function",
        "z": "c9bf91fd5c385f43",
        "name": "UPTIME",
        "func": "let upTimenla = global.get(\"config.state.upt.nla\") || 0;\nlet upTimeota = global.get(\"config.state.upt.ota\") || 0;\nlet upTimetotalA = global.get(\"config.state.upt.totalA\") || 0;\nlet upTimenlb = global.get(\"config.state.upt.nlb\") || 0;\nlet upTimeotb = global.get(\"config.state.upt.otb\") || 0;\nlet upTimetotalB = global.get(\"config.state.upt.totalB\") || 0;\n\nlet upTimetotal = global.get(\"config.state.upt.total\") || 0;\nconst sec = 1;\nvar secNow;\nlet hour = global.get(\"config.datetime.hour\");\n    hour = Number(hour);\n    if(hour >= 8 && hour <= 17){\n        global.set(\"config.state.upt.nla\", upTimenla + sec);\n        secNow = upTimenla;\n    }else if(hour >= 18 && hour <= 19){\n        global.set(\"config.state.upt.ota\", upTimeota + sec);\n        secNow = upTimeota;\n    }else if((hour >= 20 && hour <= 23) || ( hour >= 0 && hour <= 5)){\n        global.set(\"config.state.upt.nlb\", upTimenlb + sec); \n        secNow = upTimenlb;\n    }else if(hour >= 6 && hour <= 7){\n        global.set(\"config.state.upt.otb\", upTimeotb + sec);\n        secNow = upTimeotb;\n    }\n    upTimetotalA = upTimenla + upTimeota;\n        global.set(\"config.state.upt.totalA\", upTimetotalA);\n    upTimetotalB = upTimenlb + upTimeotb;\n        global.set(\"config.state.upt.totalB\", upTimetotalB);\n    upTimetotal = upTimetotalA + upTimetotalB;\n        global.set(\"config.state.upt.total\", upTimetotal);\nmsg.payload = {\n    'fill': 'yellow',\n    'shape': 'dot',\n    'text': `Second: ${secNow} total: ${setTime(upTimetotal)}`\n};\nreturn msg;\n\nfunction setTime(second){\n    let hours = Math.floor(second / 3600)\n    let minutes = Math.floor((second % 3600) / 60)\n    let seconds = Math.floor((second % 60) / 1)\n    let format = hours + ':' + minutes + ':' + seconds\n    return format;\n}",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 260,
        "y": 80,
        "wires": [
            []
        ]
    },
    {
        "id": "b876448f3a68636e",
        "type": "inject",
        "z": "062d9ee6cb5e367f",
        "name": "",
        "props": [
            {
                "p": "payload"
            },
            {
                "p": "topic",
                "vt": "str"
            }
        ],
        "repeat": "1",
        "crontab": "",
        "once": true,
        "onceDelay": "40",
        "topic": "",
        "payload": "",
        "payloadType": "date",
        "x": 145,
        "y": 100,
        "wires": [
            [
                "d254c4f3ec67d313",
                "fa505a146959395d",
                "2a334b79d30a7edf"
            ]
        ],
        "l": false
    },
    {
        "id": "d254c4f3ec67d313",
        "type": "function",
        "z": "062d9ee6cb5e367f",
        "name": "take up check",
        "func": "const main = global.get(\"values.maintake.main.now\");\nlet alarmMain = flow.get(\"alarmMain\") || false;\nconst hour = global.get(\"config.datetime.hour\");\nconst otw = context.get(\"otw\") || \"-\" // otw: one time working\nalarmMain = hour == otw ? true : false;\nif(main > 0 && !alarmMain){\n    context.set(\"otw\", hour);\n    return msg; \n}",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 260,
        "y": 80,
        "wires": [
            [
                "cafeef43fd6b7fd0"
            ]
        ]
    },
    {
        "id": "938ff7e5f30f5df6",
        "type": "function",
        "z": "062d9ee6cb5e367f",
        "name": "function 23",
        "func": "const takeUp = global.get(\"values.maintake.take.now\");\nconst main = global.get(\"values.maintake.main.now\");\nif (main > 0 && takeUp == 0) {\n    msg.payload = `${global.get(\"config.state.ip\")} 🔩 > [takeUp: ${takeUp} main: ${main}] เซ็นเซอร์ Take up อาจมีปัญหา...`;\n    return msg;\n}",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 490,
        "y": 80,
        "wires": [
            [
                "3a4ac4dbcb8962f9"
            ]
        ]
    },
    {
        "id": "cafeef43fd6b7fd0",
        "type": "delay",
        "z": "062d9ee6cb5e367f",
        "name": "",
        "pauseType": "delay",
        "timeout": "10",
        "timeoutUnits": "seconds",
        "rate": "1",
        "nbRateUnits": "10",
        "rateUnits": "second",
        "randomFirst": "1",
        "randomLast": "5",
        "randomUnits": "seconds",
        "drop": false,
        "allowrate": false,
        "outputs": 1,
        "x": 375,
        "y": 80,
        "wires": [
            [
                "938ff7e5f30f5df6"
            ]
        ],
        "l": false
    },
    {
        "id": "fa505a146959395d",
        "type": "function",
        "z": "062d9ee6cb5e367f",
        "name": "main check",
        "func": "const takeUp = global.get(\"values.maintake.take.now\");\nlet alarmTake = flow.get(\"alarmTake\") || false;\nconst hour = global.get(\"config.datetime.hour\");\nconst otw = context.get(\"otw\") || \"-\" // otw: one time working\nalarmTake = hour == otw ? true : false;\nif(takeUp > 0 && !alarmTake){\n    context.set(\"otw\", hour);\n    return msg; \n}",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 250,
        "y": 120,
        "wires": [
            [
                "2cf3a1fca4c05388"
            ]
        ]
    },
    {
        "id": "c69c76cd5d3d874f",
        "type": "subflow:1406c468fdce7358",
        "z": "062d9ee6cb5e367f",
        "name": "",
        "x": 680,
        "y": 120,
        "wires": [
            [
                "1eec8d095382c328"
            ]
        ]
    },
    {
        "id": "1eec8d095382c328",
        "type": "function",
        "z": "062d9ee6cb5e367f",
        "name": "function 25",
        "func": "const httpCode = msg.statusCode;\n\nif(httpCode == 200){\n    flow.set(\"alarmTake\", true);    \n}\nreturn msg;",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 805,
        "y": 120,
        "wires": [
            []
        ],
        "l": false
    },
    {
        "id": "3a4ac4dbcb8962f9",
        "type": "subflow:1406c468fdce7358",
        "z": "062d9ee6cb5e367f",
        "name": "",
        "x": 680,
        "y": 80,
        "wires": [
            [
                "029c5ec1b4cd0fb6"
            ]
        ]
    },
    {
        "id": "029c5ec1b4cd0fb6",
        "type": "function",
        "z": "062d9ee6cb5e367f",
        "name": "function 27",
        "func": "const httpCode = msg.statusCode;\n\nif(httpCode == 200){\n    flow.set(\"alarmMain\", true);    \n}\nreturn msg;",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 805,
        "y": 80,
        "wires": [
            []
        ],
        "l": false
    },
    {
        "id": "2a334b79d30a7edf",
        "type": "function",
        "z": "062d9ee6cb5e367f",
        "name": "Status",
        "func": "msg.payload ={\n    'fill': 'green',\n    'shape': 'dot',\n    'text': `${global.get(\"config.datetime.time\")}: Last Time Check`\n}\nreturn msg;",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 230,
        "y": 160,
        "wires": [
            []
        ]
    },
    {
        "id": "2cf3a1fca4c05388",
        "type": "delay",
        "z": "062d9ee6cb5e367f",
        "name": "",
        "pauseType": "delay",
        "timeout": "10",
        "timeoutUnits": "seconds",
        "rate": "1",
        "nbRateUnits": "10",
        "rateUnits": "second",
        "randomFirst": "1",
        "randomLast": "5",
        "randomUnits": "seconds",
        "drop": false,
        "allowrate": false,
        "outputs": 1,
        "x": 375,
        "y": 120,
        "wires": [
            [
                "20ce10615defa2e5"
            ]
        ],
        "l": false
    },
    {
        "id": "20ce10615defa2e5",
        "type": "function",
        "z": "062d9ee6cb5e367f",
        "name": "main check",
        "func": "const takeUp = global.get(\"values.maintake.take.now\");\nconst main = global.get(\"values.maintake.main.now\");\n\nif(takeUp > 0 && main == 0){\n    msg.payload = `${global.get(\"config.state.ip\")} 🔩 > [takeUp: ${takeUp} main: ${main}] เซ็นเซอร์ Main อาจมีปัญหา...`;\n    return msg; \n}",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 490,
        "y": 120,
        "wires": [
            [
                "c69c76cd5d3d874f"
            ]
        ]
    },
    {
        "id": "e11a1a6dd2f8c8a8",
        "type": "function",
        "z": "0955db65ef90de77",
        "name": "list",
        "func": "var fileList = msg.payload;\nvar fileno = fileList.length;\n    global.set(\"config.state.influxdb.logfile\", fileno)\n    return msg;",
        "outputs": 1,
        "timeout": "",
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 230,
        "y": 80,
        "wires": [
            [
                "7c86c33ac7b08415"
            ]
        ]
    },
    {
        "id": "c8bab0630c3face5",
        "type": "fs-file-lister",
        "z": "0955db65ef90de77",
        "name": "file list",
        "start": "/home/orangepi/loom/influxdb/data",
        "pattern": "*.*",
        "folders": "*",
        "hidden": true,
        "lstype": "files",
        "path": true,
        "single": true,
        "depth": "0",
        "stat": true,
        "showWarnings": false,
        "x": 145,
        "y": 80,
        "wires": [
            [
                "e11a1a6dd2f8c8a8"
            ]
        ],
        "l": false
    },
    {
        "id": "7c86c33ac7b08415",
        "type": "function",
        "z": "0955db65ef90de77",
        "name": "function 29",
        "func": "msg.payload = {\n    fill : \"bule\",\n    shape : \"dot\",\n    text: `file:${global.get(\"config.state.influxdb.logfile\")}}`\n}\nreturn msg;",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 390,
        "y": 120,
        "wires": [
            []
        ]
    },
    {
        "id": "6c808f1a218f66a9",
        "type": "switch",
        "z": "a066bed2a8b32b55",
        "name": "",
        "property": "file",
        "propertyType": "msg",
        "rules": [
            {
                "t": "eq",
                "v": "0",
                "vt": "str"
            },
            {
                "t": "eq",
                "v": "1",
                "vt": "str"
            }
        ],
        "checkall": "true",
        "repair": false,
        "outputs": 2,
        "x": 155,
        "y": 100,
        "wires": [
            [
                "e66edd4e2901115e"
            ],
            [
                "ee6c143a78297597"
            ]
        ],
        "l": false
    },
    {
        "id": "e66edd4e2901115e",
        "type": "function",
        "z": "a066bed2a8b32b55",
        "name": "data Log",
        "func": "const payload = msg.payload;\nconst hour = Number(global.get(\"config.datetime.hour\"));\nconst date = payload.date;\nconst time = payload.time;\nconst timestamp = payload.timestamp;\nconst upt = payload.upt;\nconst meter = global.get(\"values.meter\");\n\n// values \nconst main = payload.values.maintake.main;\nconst take = payload.values.maintake.take;\nconst total = payload.values.total;\n\nmsg.payload = {\n    'timestamp': timestamp,\n    'date': date,\n    'time': time,\n    'total_meter': total.meter.total,\n    'total_meterA': total.meter.totala,\n    'total_meterB': total.meter.totalb,\n    'meterNLA': total.meter.nla,\n    'meterNLB': total.meter.nlb,\n    'meterOTA': total.meter.ota,\n    'meterOTB': total.meter.otb,\n    'm_h': meter[hour],\n    'main_now': main.now || 0,\n    'take_now': take.now || 0,\n    'upTimetotal': upt.total,\n    'upTimetotalA': upt.totalA,\n    'upTimetotalB': upt.totalB,\n    'upTimenla': upt.nla,\n    'upTimeota': upt.ota,\n    'upTimenlb': upt.nlb,\n    'upTimeotb': upt.otb,\n}\nreturn msg;",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 250,
        "y": 80,
        "wires": [
            [
                "3e114699b2488fb5"
            ]
        ]
    },
    {
        "id": "ee6c143a78297597",
        "type": "function",
        "z": "a066bed2a8b32b55",
        "name": "data Log",
        "func": "const payload = msg.payload;\nconst hour = Number(global.get(\"config.datetime.hour\"));\nconst date = payload.date;\nconst time = payload.time;\nconst timestamp = payload.timestamp;\nconst upt = payload.upt;\nconst meter = global.get(\"values.meter\");\n\n// values \nconst main = payload.values.maintake.main;\nconst take = payload.values.maintake.take;\nconst total = payload.values.total;\n\nmsg.payload = {\n    'timestamp': timestamp,\n    'date': date,\n    'time': time,\n    'total_meter': total.meter.total,\n    'total_meterA': total.meter.totala,\n    'total_meterB': total.meter.totalb,\n    'meterNLA': total.meter.nla,\n    'meterNLB': total.meter.nlb,\n    'meterOTA': total.meter.ota,\n    'meterOTB': total.meter.otb,\n    'm_h': meter[hour],\n    'main_now': main.now || 0,\n    'take_now': take.now || 0,\n    'upTimetotal': upt.total,\n    'upTimetotalA': upt.totalA,\n    'upTimetotalB': upt.totalB,\n    'upTimenla': upt.nla,\n    'upTimeota': upt.ota,\n    'upTimenlb': upt.nlb,\n    'upTimeotb': upt.otb,\n}\nreturn msg;",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 250,
        "y": 120,
        "wires": [
            [
                "4cb165e39114d74f"
            ]
        ]
    },
    {
        "id": "3e114699b2488fb5",
        "type": "csv",
        "z": "a066bed2a8b32b55",
        "name": "",
        "sep": ",",
        "hdrin": "",
        "hdrout": "all",
        "multi": "one",
        "ret": "\\r\\n",
        "temp": "timestamp,date,time,total_meter,meterNLA,meterOTA,total_meterA,meterNLB,meterOTB,total_meterB,m_h,main_now,take_now,upTimetotal,upTimetotalA,upTimetotalB,upTimenla,upTimeota,upTimenlb,upTimeotb",
        "skip": "0",
        "strings": true,
        "include_empty_strings": "",
        "include_null_values": "",
        "x": 345,
        "y": 80,
        "wires": [
            []
        ],
        "l": false
    },
    {
        "id": "4cb165e39114d74f",
        "type": "csv",
        "z": "a066bed2a8b32b55",
        "name": "",
        "sep": ",",
        "hdrin": "",
        "hdrout": "none",
        "multi": "one",
        "ret": "\\r\\n",
        "temp": "timestamp,date,time,total_meter,meterNLA,meterOTA,total_meterA,meterNLB,meterOTB,total_meterB,m_h,main_now,take_now,upTimetotal,upTimetotalA,upTimetotalB,upTimenla,upTimeota,upTimenlb,upTimeotb",
        "skip": "0",
        "strings": true,
        "include_empty_strings": "",
        "include_null_values": "",
        "x": 345,
        "y": 120,
        "wires": [
            []
        ],
        "l": false
    },
    {
        "id": "1de45ed9d0cc17fc",
        "type": "file",
        "z": "b79372892403a995",
        "name": "Write",
        "filename": "path",
        "filenameType": "msg",
        "appendNewline": false,
        "createDir": true,
        "overwriteFile": "false",
        "encoding": "utf8",
        "x": 145,
        "y": 80,
        "wires": [
            [
                "4fa877db132bd4c9"
            ]
        ],
        "l": false
    },
    {
        "id": "c45a7e292a6ca94a",
        "type": "file in",
        "z": "b79372892403a995",
        "name": "",
        "filename": "path",
        "filenameType": "msg",
        "format": "utf8",
        "chunk": false,
        "sendError": false,
        "encoding": "none",
        "allProps": false,
        "x": 265,
        "y": 80,
        "wires": [
            [
                "421de14b27e14ba7"
            ]
        ],
        "l": false
    },
    {
        "id": "4fa877db132bd4c9",
        "type": "delay",
        "z": "b79372892403a995",
        "name": "",
        "pauseType": "delay",
        "timeout": "50",
        "timeoutUnits": "milliseconds",
        "rate": "1",
        "nbRateUnits": "1",
        "rateUnits": "second",
        "randomFirst": "1",
        "randomLast": "5",
        "randomUnits": "seconds",
        "drop": false,
        "allowrate": false,
        "outputs": 1,
        "x": 205,
        "y": 80,
        "wires": [
            [
                "c45a7e292a6ca94a"
            ]
        ],
        "l": false
    },
    {
        "id": "421de14b27e14ba7",
        "type": "csv",
        "z": "b79372892403a995",
        "name": "",
        "sep": ",",
        "hdrin": "",
        "hdrout": "none",
        "multi": "mult",
        "ret": "\\n",
        "temp": "",
        "skip": "0",
        "strings": true,
        "include_empty_strings": "",
        "include_null_values": "",
        "x": 325,
        "y": 80,
        "wires": [
            [
                "2ac7d1492075c499"
            ]
        ],
        "l": false
    },
    {
        "id": "2ac7d1492075c499",
        "type": "function",
        "z": "b79372892403a995",
        "name": "le",
        "func": "var length = msg.payload.length;\nlength = length - 1;\nglobal.set(\"config.state.influxdb.row\", length);\nif(length <= 1){\n    global.set(\"config.state.influxdb.index\", 0);\n};\nmsg.payload = {\n    fill: \"red\",\n    shape: \"dot\",\n    text: `row:${length}`};\nreturn msg;",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 385,
        "y": 80,
        "wires": [
            []
        ],
        "l": false
    },
    {
        "id": "7d159003d1750924",
        "type": "sqlite",
        "z": "e00c4e6a600c30c1",
        "mydb": "5fafb36921f04d5b",
        "sqlquery": "msg.topic",
        "sql": "",
        "name": "sqlite",
        "x": 150,
        "y": 40,
        "wires": [
            []
        ]
    },
    {
        "id": "4396be7f42f6b67e",
        "type": "function",
        "z": "e00c4e6a600c30c1",
        "name": "SQL",
        "func": "const device = 'M248';\nconst meter = global.get(\"values.meter\") || [];\n\nconst positionNLA = [8, 9, 10, 11, 12, 13, 14, 15, 16, 17];\nconst positionOTA = [18, 19];\nconst positionNLB = [20, 21, 22, 23, 0, 1, 2, 3, 4, 5];\nconst positionOTB = [6, 7];\n\nconst hour = Number(global.get(\"config.datetime.hour\"));\nconst hour_meter = meter?.[hour] || 0;\nconst timestamp = global.get(\"config.datetime.timestamp\");\nconst ts = Number(timestamp) * 1_000; // แนะนำ ms\n\nconst meterNLA = positionNLA.reduce((a, p) => a + (meter[p] || 0), 0);\nconst meterOTA = positionOTA.reduce((a, p) => a + (meter[p] || 0), 0);\nconst meterNLB = positionNLB.reduce((a, p) => a + (meter[p] || 0), 0);\nconst meterOTB = positionOTB.reduce((a, p) => a + (meter[p] || 0), 0);\n\nconst totalA = meterNLA + meterOTA;\nconst totalB = meterNLB + meterOTB;\nconst total_meter = totalA + totalB;\n\nconst speedMain = Number(global.get(\"values.maintake.main.now\")) || 0;\nconst speedTake = Number(global.get(\"values.maintake.take.now\")) || 0;\n\nmsg.topic = `\nINSERT INTO machine_data (\n  ts, machine_code, total_meter,\n  total_a, total_b,\n  nta_meter, ntb_meter,\n  ota_meter, otb_meter,\n  hour_meter, speed_main, speed_take\n) VALUES (\n  ${ts},\n  '${device}',\n  ${total_meter},\n  ${totalA},\n  ${totalB},\n  ${meterNLA},\n  ${meterNLB},\n  ${meterOTA},\n  ${meterOTB},\n  ${hour_meter},\n  ${speedMain},\n  ${speedTake}\n);\n`;\nreturn msg;",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 150,
        "y": 160,
        "wires": [
            []
        ]
    },
    {
        "id": "dcd1a249514e8247",
        "type": "exec",
        "z": "e00c4e6a600c30c1",
        "command": "python3 /home/orangepi/loom/influxdb/sqlite_process.py",
        "addpay": "",
        "append": "",
        "useSpawn": "false",
        "timer": "",
        "winHide": false,
        "oldrc": false,
        "name": "python",
        "x": 150,
        "y": 100,
        "wires": [
            [
                "489db06ddb352de2"
            ],
            [],
            []
        ]
    },
    {
        "id": "50cd048e3e54c12d",
        "type": "inject",
        "z": "e00c4e6a600c30c1",
        "name": "",
        "props": [
            {
                "p": "payload"
            },
            {
                "p": "topic",
                "vt": "str"
            }
        ],
        "repeat": "5",
        "crontab": "",
        "once": false,
        "onceDelay": 0.1,
        "topic": "",
        "payload": "",
        "payloadType": "date",
        "x": 55,
        "y": 100,
        "wires": [
            [
                "dcd1a249514e8247"
            ]
        ],
        "l": false
    },
    {
        "id": "489db06ddb352de2",
        "type": "function",
        "z": "e00c4e6a600c30c1",
        "name": "state",
        "func": "msg.payload = {\n    fill: \"green\",\n    shape: \"ring\",\n    text: `:${msg.payload}`\n};\nreturn msg;",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 290,
        "y": 100,
        "wires": [
            []
        ]
    },
    {
        "id": "1e59f464dfa9648d",
        "type": "file in",
        "z": "2f865af03ad61429",
        "name": "json",
        "filename": "/home/orangepi/telemetry/conf.json",
        "filenameType": "str",
        "format": "utf8",
        "chunk": false,
        "sendError": false,
        "encoding": "utf8",
        "allProps": false,
        "x": 190,
        "y": 80,
        "wires": [
            [
                "8029087b8bbc21d4"
            ]
        ]
    },
    {
        "id": "8029087b8bbc21d4",
        "type": "function",
        "z": "2f865af03ad61429",
        "name": "conf",
        "func": "const item = JSON.parse(msg.payload);\nglobal.set(\"config.state.source\", item.source);\nglobal.set(\"config.state.gearratio\", item.gearratio);\nglobal.set(\"config.state.circumferance\", item.circumferance);",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 310,
        "y": 80,
        "wires": [
            []
        ]
    },
    {
        "id": "9827f5270df78aba",
        "type": "subflow:df4a94479416f0c4",
        "z": "777823ab3e1fee97",
        "g": "451150a92cfdb00f",
        "name": "",
        "x": 390,
        "y": 280,
        "wires": []
    },
    {
        "id": "cb4e9770746b4c2d",
        "type": "subflow:a67f25631bef1988",
        "z": "777823ab3e1fee97",
        "g": "451150a92cfdb00f",
        "name": "",
        "x": 190,
        "y": 340,
        "wires": []
    },
    {
        "id": "641e370bc218b3e1",
        "type": "inject",
        "z": "777823ab3e1fee97",
        "g": "451150a92cfdb00f",
        "name": "",
        "props": [
            {
                "p": "payload"
            },
            {
                "p": "topic",
                "vt": "str"
            }
        ],
        "repeat": "1",
        "crontab": "",
        "once": true,
        "onceDelay": "3",
        "topic": "",
        "payload": "",
        "payloadType": "date",
        "x": 95,
        "y": 340,
        "wires": [
            [
                "cb4e9770746b4c2d"
            ]
        ],
        "icon": "font-awesome/fa-clock-o",
        "l": false
    },
    {
        "id": "e6290a07b12de109",
        "type": "subflow:13f006802899e0be",
        "z": "777823ab3e1fee97",
        "g": "451150a92cfdb00f",
        "name": "",
        "x": 190,
        "y": 280,
        "wires": []
    },
    {
        "id": "b0abde57f8695277",
        "type": "inject",
        "z": "777823ab3e1fee97",
        "g": "451150a92cfdb00f",
        "name": "",
        "props": [
            {
                "p": "payload"
            }
        ],
        "repeat": "10",
        "crontab": "",
        "once": true,
        "onceDelay": "3",
        "topic": "",
        "payload": "192.168.0.9",
        "payloadType": "str",
        "x": 95,
        "y": 280,
        "wires": [
            [
                "e6290a07b12de109"
            ]
        ],
        "icon": "font-awesome/fa-globe",
        "l": false
    },
    {
        "id": "a241e24d2a8bd154",
        "type": "subflow:e226ede58ea4b202",
        "z": "777823ab3e1fee97",
        "g": "451150a92cfdb00f",
        "name": "",
        "x": 540,
        "y": 280,
        "wires": []
    },
    {
        "id": "d53e6b2f26983416",
        "type": "modbus-response",
        "z": "777823ab3e1fee97",
        "g": "6be6c492a2953951",
        "name": "PLC Response",
        "registerShowMax": "1",
        "x": 465,
        "y": 60,
        "wires": [],
        "l": false
    },
    {
        "id": "0a51b58526c3eac5",
        "type": "inject",
        "z": "777823ab3e1fee97",
        "g": "6be6c492a2953951",
        "name": "1 S",
        "props": [
            {
                "p": "payload"
            },
            {
                "p": "topic",
                "vt": "str"
            },
            {
                "p": "timestamp",
                "v": "",
                "vt": "date"
            }
        ],
        "repeat": "1",
        "crontab": "",
        "once": true,
        "onceDelay": "10",
        "topic": "",
        "payload": "",
        "payloadType": "date",
        "x": 95,
        "y": 120,
        "wires": [
            [
                "f54eda370da4361a"
            ]
        ],
        "icon": "node-red/trigger.svg",
        "l": false
    },
    {
        "id": "1a7e9f67f1527628",
        "type": "switch",
        "z": "777823ab3e1fee97",
        "g": "6be6c492a2953951",
        "name": "",
        "property": "modbus_read",
        "propertyType": "msg",
        "rules": [
            {
                "t": "false"
            },
            {
                "t": "true"
            }
        ],
        "checkall": "true",
        "repair": false,
        "outputs": 2,
        "x": 215,
        "y": 120,
        "wires": [
            [
                "ddb434094e4d4a5d"
            ],
            [
                "0eb02406f8dff0ba"
            ]
        ],
        "l": false
    },
    {
        "id": "0eb02406f8dff0ba",
        "type": "modbus-getter",
        "z": "777823ab3e1fee97",
        "g": "6be6c492a2953951",
        "name": "RTU Read",
        "showStatusActivities": false,
        "showErrors": false,
        "showWarnings": true,
        "logIOActivities": false,
        "unitid": "1",
        "dataType": "HoldingRegister",
        "adr": "1",
        "quantity": "11",
        "server": "291667434678740d",
        "useIOFile": false,
        "ioFile": "",
        "useIOForPayload": false,
        "emptyMsgOnFail": false,
        "keepMsgProperties": false,
        "delayOnStart": false,
        "startDelayTime": "",
        "x": 340,
        "y": 160,
        "wires": [
            [
                "ed51c14eaa7633a7",
                "51f8481c029f9f8d"
            ],
            []
        ]
    },
    {
        "id": "ed51c14eaa7633a7",
        "type": "modbus-response",
        "z": "777823ab3e1fee97",
        "g": "6be6c492a2953951",
        "name": "PLC Response",
        "registerShowMax": "1",
        "x": 465,
        "y": 140,
        "wires": [],
        "l": false
    },
    {
        "id": "51f8481c029f9f8d",
        "type": "function",
        "z": "777823ab3e1fee97",
        "g": "6be6c492a2953951",
        "name": "parse()",
        "func": "const p = msg.payload\nconst msp = p[0]\n    minMaxGlobalset('values.maintake', 'main', msp)\nconst tsp = Number(p[1] / 100)\n    minMaxGlobalset('values.maintake', 'take',  tsp)  \nconst m = p[2]\nconst hour = global.get('config.datetime.hour')\nconst mArr = global.get('values.meter')\nconst wArr = global.get('values.working')\nconst w = p[3]\nconst wShow = showTime(w)\nconst pulse_gear = shiftBit(p[4], p[5])\n    mArr.splice(Number(hour), 1, m)\n    wArr.splice(Number(hour), 1, w)\n    node.status({ fill: \"blue\", shape: \"dot\", text: `${global.get(\"config.datetime.time\")}| main: ${msp} take: ${tsp} meter:${m} working: ${wShow}`});\nreturn msg;\n\nfunction minMaxGlobalset(type, group, input) {\n    global.set(`${type}.${group}.now`, input);\n    let input_min = global.get(`${type}.${group}.min`) || 0;\n    let input_max = global.get(`${type}.${group}.max`) || 0;\n\n    if (input > 0 && input < 6000) {\n        if (!input_min || input < input_min) {\n            input_min = input;\n            global.set(`${type}.${group}.min`, input_min);\n        }\n        if (!input_max || input > input_max) {\n            input_max = input;\n            global.set(`${type}.${group}.max`, input_max);\n        };\n    }else{\n            global.set(`${type}.${group}.now`, 0);\n    };\n};\n\nfunction shiftBit(l, h) {\n    return (h << 16) | l; \n}\n\nfunction showTime(sec) {\n    let hours = Math.floor(sec / 3600)\n    let minutes = Math.floor((sec % 3600) / 60)\n    let seconds = Math.floor((sec % 60) / 1)\n    return `${hours}:${minutes}:${seconds}`\n}\n\nfunction globalSet() {\n\n}",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 510,
        "y": 180,
        "wires": [
            [
                "2b24aa05aa5379ed"
            ]
        ]
    },
    {
        "id": "2b24aa05aa5379ed",
        "type": "delay",
        "z": "777823ab3e1fee97",
        "g": "6be6c492a2953951",
        "name": "",
        "pauseType": "rate",
        "timeout": "5",
        "timeoutUnits": "seconds",
        "rate": "1",
        "nbRateUnits": "1",
        "rateUnits": "minute",
        "randomFirst": "1",
        "randomLast": "5",
        "randomUnits": "seconds",
        "drop": true,
        "allowrate": false,
        "outputs": 1,
        "x": 625,
        "y": 180,
        "wires": [
            [
                "f2925150b152ddfd"
            ]
        ],
        "l": false
    },
    {
        "id": "f2925150b152ddfd",
        "type": "link out",
        "z": "777823ab3e1fee97",
        "g": "6be6c492a2953951",
        "name": "link out 6",
        "mode": "link",
        "links": [
            "ed565787aa8ad39b"
        ],
        "x": 685,
        "y": 180,
        "wires": []
    },
    {
        "id": "c974acb909bd6616",
        "type": "inject",
        "z": "777823ab3e1fee97",
        "g": "451150a92cfdb00f",
        "name": "",
        "props": [
            {
                "p": "payload"
            },
            {
                "p": "topic",
                "vt": "str"
            }
        ],
        "repeat": "",
        "crontab": "",
        "once": false,
        "onceDelay": 0.1,
        "topic": "",
        "payload": "",
        "payloadType": "date",
        "x": 345,
        "y": 340,
        "wires": [
            [
                "8f882b3c1846c4d2"
            ]
        ],
        "l": false
    },
    {
        "id": "8f882b3c1846c4d2",
        "type": "exec",
        "z": "777823ab3e1fee97",
        "g": "451150a92cfdb00f",
        "command": "reboot",
        "addpay": "",
        "append": "",
        "useSpawn": "false",
        "timer": "",
        "winHide": false,
        "oldrc": false,
        "name": "",
        "x": 405,
        "y": 340,
        "wires": [
            [],
            [],
            []
        ],
        "l": false
    },
    {
        "id": "b57537dcf374507c",
        "type": "inject",
        "z": "777823ab3e1fee97",
        "g": "451150a92cfdb00f",
        "name": "",
        "props": [
            {
                "p": "payload"
            },
            {
                "p": "topic",
                "vt": "str"
            }
        ],
        "repeat": "10",
        "crontab": "",
        "once": true,
        "onceDelay": "3",
        "topic": "",
        "payload": "",
        "payloadType": "date",
        "x": 295,
        "y": 280,
        "wires": [
            [
                "9827f5270df78aba"
            ]
        ],
        "icon": "node-red/cog.svg",
        "l": false
    },
    {
        "id": "ac29116d0411fcab",
        "type": "subflow:c9bf91fd5c385f43",
        "z": "777823ab3e1fee97",
        "g": "b5c344a321b1b503",
        "name": "",
        "x": 490,
        "y": 440,
        "wires": []
    },
    {
        "id": "fd6dded7e0aa82a2",
        "type": "subflow:062d9ee6cb5e367f",
        "z": "777823ab3e1fee97",
        "d": true,
        "g": "6be6c492a2953951",
        "name": "",
        "x": 630,
        "y": 60,
        "wires": []
    },
    {
        "id": "ed565787aa8ad39b",
        "type": "link in",
        "z": "777823ab3e1fee97",
        "g": "b5c344a321b1b503",
        "name": "link in 4",
        "links": [
            "f2925150b152ddfd"
        ],
        "x": 95,
        "y": 440,
        "wires": [
            [
                "86260ad292f188d3"
            ]
        ]
    },
    {
        "id": "86260ad292f188d3",
        "type": "function",
        "z": "777823ab3e1fee97",
        "g": "b5c344a321b1b503",
        "name": "INSERT",
        "func": "const db = context.get(\"db\");\nif(msg.topic != \"config\" || !msg.topic){\n    const meter = global.get(\"values.meter\");\n    const h = Number(global.get(\"config.datetime.hour\"));\n    const work = global.get(\"values.working\");\n    const ts = global.get(\"config.datetime.timestamp\");\n    const positionNLA = [8, 9, 10, 11, 12, 13, 14, 15, 16, 17];\n    const positionOTA = [18, 19];\n    const positionNLB = [20, 21, 22, 23, 0, 1, 2, 3, 4, 5];\n    const positionOTB = [6, 7];\n    const mspd = global.get(\"values.maintake.main.now\");\n    const tspd = global.get(\"values.maintake.take.now\");\n    const date_data = global.get(\"config.state.date_data\");\n    const time_data = global.get(\"config.datetime.time\");\n    \n    let meterNLA = positionNLA.reduce((acc, pos) => acc + (meter[pos] || 0), 0);\n    global.set(\"values.total.meter.nla\", meterNLA);\n    let meterOTA = positionOTA.reduce((acc, pos) => acc + (meter[pos] || 0), 0);\n    global.set(\"values.total.meter.ota\", meterOTA);\n    let totalA = meterNLA + meterOTA;\n    global.set(\"values.total.meter.totalA\", totalA);\n\n    let meterNLB = positionNLB.reduce((acc, pos) => acc + (meter[pos] || 0), 0);\n    global.set(\"values.total.meter.nlb\", meterNLB);\n    let meterOTB = positionOTB.reduce((acc, pos) => acc + (meter[pos] || 0), 0);\n    global.set(\"values.total.meter.otb\", meterOTB);\n    let totalB = meterNLB + meterOTB;\n    global.set(\"values.total.meter.totalB\", totalB);\n\n    let total_meter = totalA + totalB || 0;\n    global.set(\"values.total.meter.total\", total_meter);\n\n    let workingNLA = positionNLA.reduce((acc, pos) => acc + (work[pos] || 0), 0);\n    global.set(\"values.total.working.nla\", workingNLA);\n    let workingOTA = positionOTA.reduce((acc, pos) => acc + (work[pos] || 0), 0);\n    global.set(\"values.total.working.ota\", workingOTA);\n    let totalwA = workingNLA + workingOTA;\n    global.set(\"values.total.working.totalA\", totalwA);\n\n    let workingNLB = positionNLB.reduce((acc, pos) => acc + (work[pos] || 0), 0);\n    global.set(\"values.total.working.nlb\", workingNLB);\n    let workingOTB = positionOTB.reduce((acc, pos) => acc + (work[pos] || 0), 0);\n    global.set(\"values.total.working.otb\", workingOTB);\n    let totalwB = workingNLB + workingOTB;\n    global.set(\"values.total.working.totalB\", totalwB);\n\n    let total_working = totalwA + totalwB || 0;\n    global.set(\"values.total.working.total\", total_working);\n\n    try{\n    db.exec(`\n    BEGIN;\n    INSERT INTO telemetry_local(\n        ts, date_data, time_data, total_meter, total_a, total_b,\n        nta_meter, ntb_meter, ota_meter, otb_meter,\n        total_work, work_a, work_b, speed_main, speed_take\n    )\n    VALUES (\n        ${ts}, '${date_data}', '${time_data}', ${total_meter}, ${totalA}, ${totalB},\n        ${meterNLA}, ${meterNLB}, ${meterOTA}, ${meterOTB},\n        ${total_working}, ${totalwA}, ${totalwB}, ${mspd}, ${tspd}\n    );\n    INSERT INTO telemetry_meter(\n        m0, m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11,\n        m12, m13, m14, m15, m16, m17, m18, m19, m20, m21, m22, m23\n    )\n    VALUES (\n        ${meter[0]}, ${meter[1]}, ${meter[2]}, ${meter[3]},\n        ${meter[4]}, ${meter[5]}, ${meter[6]}, ${meter[7]},\n        ${meter[8]}, ${meter[9]}, ${meter[10]}, ${meter[11]},\n        ${meter[12]}, ${meter[13]}, ${meter[14]}, ${meter[15]},\n        ${meter[16]}, ${meter[17]}, ${meter[18]}, ${meter[19]},\n        ${meter[20]}, ${meter[21]}, ${meter[22]}, ${meter[23]}\n    );\n    INSERT INTO telemetry_work(\n        w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11,\n        w12, w13, w14, w15, w16, w17, w18, w19, w20, w21, w22, w23\n    )\n    VALUES (\n        ${work[0]}, ${work[1]}, ${work[2]}, ${work[3]},\n        ${work[4]}, ${work[5]}, ${work[6]}, ${work[7]},\n        ${work[8]}, ${work[9]}, ${work[10]}, ${work[11]},\n        ${work[12]}, ${work[13]}, ${work[14]}, ${work[15]},\n        ${work[16]}, ${work[17]}, ${work[18]}, ${work[19]},\n        ${work[20]}, ${work[21]}, ${work[22]}, ${work[23]}\n    );\n    INSERT INTO telemetry_cloud(\n        ts, total_meter, total_a, total_b, \n        nta_meter, ntb_meter, ota_meter, otb_meter,\n        total_work, work_a, work_b, hour_meter, speed_main, speed_take\n    )\n    VALUES (\n        ${ts},${total_meter}, ${totalA}, ${totalB},\n        ${meterNLA}, ${meterNLB}, ${meterOTA}, ${meterOTB},\n        ${total_working}, ${totalwA}, ${totalwB}, ${meter[h]}, ${mspd}, ${tspd}\n    );\n    COMMIT;\n    `);\n    node.status({fill:\"blue\",shape:\"dot\",text: `INSERT INTO: ${global.get(\"config.datetime.time\")}`});\n    // return msg;\n    } catch (err) {\n            try {\n                db.exec(\"ROLLBACK;\");\n            } catch (e) { }\n            node.error(err);\n    node.status({fill:\"blue\",shape:\"dot\",text: `ROLLBACK: ${global.get(\"config.datetime.time\")}`});\n    // return msg;\n    }\n}else{\n    const db = context.get(\"db\");\n    let date = new Date(msg.payload);\n    let h = date.getHours();\n\n    msg.topic = setQuery(h, date);\n    return msg;\n}\n\nfunction setQuery(h, timestamp) {\n    let startDate = new Date(timestamp);\n    let stopDate = new Date(timestamp);\n\n    if (h >= 8) {\n        // วันนี้ 08:00 → พรุ่งนี้ 08:00\n        stopDate.setDate(stopDate.getDate() + 1);\n    } else {\n        // เมื่อวาน 08:00 → วันนี้ 08:00\n        startDate.setDate(startDate.getDate() - 1);\n    }\n\n    let start = `${startDate.getFullYear()}-${(startDate.getMonth()+1).toString().padStart(2,'0')}-${startDate.getDate().toString().padStart(2,'0')} 08:00:00`;\n\n    let stop = `${stopDate.getFullYear()}-${(stopDate.getMonth()+1).toString().padStart(2,'0')}-${stopDate.getDate().toString().padStart(2,'0')} 08:00:00`;\n\n    try{\n        const item = db.prepare(`\n        SELECT * \n        FROM telemetry_local tl\n        LEFT JOIN telemetry_meter tm ON tl.id = tm.id\n        LEFT JOIN telemetry_work tw ON tl.id = tw.id\n        WHERE tl.create_at >= ?\n        AND tl.create_at < ?\n        ORDER BY tl.create_at DESC\n        LIMIT 1;\n        `).get(start, stop);\n        const payload = item;\n        const mArr = new Array(24).fill(0);\n        const wArr = new Array(24).fill(0);\n        if(!item) {\n            global.set(\"values.meter\", mArr)\n            global.set(\"values.working\", wArr)\n\n            node.status({ fill: \"red\", shape: \"dot\", text:\"config fail\"});\n        }else{\n            for(let i = 0; i < 24; i ++){\n                let objM = `m${i}`\n                let objW = `w${i}`\n                mArr[i] = item[objM]\n                wArr[i] = item[objW]\n            }\n            global.set(\"values.meter\", mArr)\n            global.set(\"values.working\", wArr)\n            global.set(\"config.state.changehour\", getHourStamp(item.ts))\n            global.set(\"config.state.datestamp\", getDatestamp(item.ts))\n        node.status({fill:\"green\",shape:\"dot\",text:`config successfuly`});\n        }\n        return payload\n    } catch (err) {\n        node.error(err);\n    }\n}\n\nfunction getHourStamp(ts) {\n    let date = new Date(ts);\n    return Number(date.getHours().toString());\n}\n\nfunction getDatestamp(ts) {\n    let date = new Date(ts);\n    let year = date.getFullYear();\n    let month = (date.getMonth() + 1).toString().padStart(2, '0');\n    let day = date.getDate().toString().padStart(2, '0');\n    return `${year}${month}${day}`;\n}",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "// Code added here will be run once\n// whenever the node is started.\n// const Database = require('better-sqlite3');\ncontext.set(\"db\", new Database('/home/orangepi/telemetry/sql/telemetry_factory.db'));",
        "finalize": "// Code added here will be run when the\n// node is being stopped or re-deployed.\nconst db = context.get(\"db\");\nif (db) db.close();",
        "libs": [
            {
                "var": "Database",
                "module": "better-sqlite3"
            }
        ],
        "x": 210,
        "y": 440,
        "wires": [
            [
                "5f4722c77c0dc26f",
                "0d7c4fd373df7634"
            ]
        ],
        "icon": "font-awesome/fa-archive"
    },
    {
        "id": "fe159939e00a876e",
        "type": "subflow:9f979da7e8a5400d",
        "z": "777823ab3e1fee97",
        "g": "6be6c492a2953951",
        "name": "",
        "x": 120,
        "y": 180,
        "wires": []
    },
    {
        "id": "5f4722c77c0dc26f",
        "type": "debug",
        "z": "777823ab3e1fee97",
        "g": "b5c344a321b1b503",
        "name": "debug 4",
        "active": true,
        "tosidebar": true,
        "console": false,
        "tostatus": false,
        "complete": "true",
        "targetType": "full",
        "statusVal": "",
        "statusType": "auto",
        "x": 315,
        "y": 480,
        "wires": [],
        "icon": "node-red/db.svg",
        "l": false
    },
    {
        "id": "321c102f9e2881e8",
        "type": "inject",
        "z": "777823ab3e1fee97",
        "g": "b5c344a321b1b503",
        "name": "",
        "props": [
            {
                "p": "payload"
            },
            {
                "p": "topic",
                "vt": "str"
            }
        ],
        "repeat": "",
        "crontab": "",
        "once": true,
        "onceDelay": "1",
        "topic": "config",
        "payload": "",
        "payloadType": "date",
        "x": 95,
        "y": 480,
        "wires": [
            [
                "86260ad292f188d3"
            ]
        ],
        "l": false
    },
    {
        "id": "bf3e0be307587739",
        "type": "function",
        "z": "777823ab3e1fee97",
        "g": "6be6c492a2953951",
        "name": "RTU state",
        "func": "const hours = Number(global.get(\"config.datetime.hour\"));\nglobal.set(\"config.state.changehour\", hours);\nnode.status({fill:\"blue\",shape:\"ring\",text:getTime()});\nreturn msg;\n\nfunction getTime() {\n    let date = new Date()\n    let year = date.getFullYear(); \n    let month = (date.getMonth() + 1).toString().padStart(2, '0');\n    let day = date.getDate().toString().padStart(2, '0');\n    let hours = date.getHours().toString().padStart(2, '0');\n    let minutes = date.getMinutes().toString().padStart(2, '0');\n    let seconds = date.getSeconds().toString().padStart(2, '0');\n    return `${year}/${month}/${day} ${hours}:${minutes}:${seconds}`;\n}",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 510,
        "y": 100,
        "wires": [
            []
        ]
    },
    {
        "id": "f54eda370da4361a",
        "type": "function",
        "z": "777823ab3e1fee97",
        "g": "6be6c492a2953951",
        "name": "Write PLC reset",
        "func": "global.set(\"config.datetime.timestamp\", msg.timestamp)\nconst hours = Number(global.get(\"config.datetime.hour\"));\nconst changehour = Number(global.get(\"config.state.changehour\"));\nconst nodestate = context.get(\"nodestate\");\nif(nodestate){\n    if (changehour != undefined && changehour != null) {\n        if (hours != changehour) {\n            msg.payload = { value: 1, 'fc': 6, 'unitid': 1, 'address': 181, 'quantity': 1 }\n            msg.modbus_read = false;\n            node.status({ fill: \"green\", shape: \"dot\", text: `${global.get(\"config.datetime.time\")}: Reset Valuse PLC`});\n            return msg;\n        } else {\n            msg.modbus_read = true;\n            return msg;\n        }\n    }\n}else{\n    msg.modbus_read = false;\n    const payload = [global.get(\"config.state.gearratio\"), parsecircumferance(global.get(\"config.state.circumferance\"))];\n    // const payload = [0, 0];\n    msg.payload = { value: payload, 'fc': 16, 'unitid': 1, 'address': 10, 'quantity': 2 }\n    context.set(\"nodestate\", true);\n    node.status({fill:\"yellow\",shape:\"dot\",text: `${ global.get(\"config.datetime.time\") }: Config PLC success...`});\n    return msg;\n}\n\nfunction parsecircumferance(cir) {\n    return Number(cir * 10);\n}",
        "outputs": 1,
        "timeout": 0,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 155,
        "y": 120,
        "wires": [
            [
                "1a7e9f67f1527628"
            ]
        ],
        "l": false
    },
    {
        "id": "ddb434094e4d4a5d",
        "type": "modbus-flex-write",
        "z": "777823ab3e1fee97",
        "g": "6be6c492a2953951",
        "name": "RTU Write",
        "showStatusActivities": false,
        "showErrors": false,
        "showWarnings": true,
        "server": "291667434678740d",
        "emptyMsgOnFail": false,
        "keepMsgProperties": false,
        "delayOnStart": false,
        "startDelayTime": "",
        "x": 340,
        "y": 80,
        "wires": [
            [
                "d53e6b2f26983416",
                "bf3e0be307587739"
            ],
            []
        ]
    },
    {
        "id": "0d7c4fd373df7634",
        "type": "subflow:2f865af03ad61429",
        "z": "777823ab3e1fee97",
        "g": "b5c344a321b1b503",
        "name": "",
        "x": 350,
        "y": 440,
        "wires": []
    }
]
EON
