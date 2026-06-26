#!/bin/bash
user=$HOME
sqldir=telemetry/sql
pydir=telemetry/py
db=$user/telemetry/sql/telemetry_factory.db
conf=$user/telemetry/conf.json
nodered=$user/.node-red/flows.json

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
  cat << 'EOR' >> "$pydir/requests_local.py"
from sqlalchemy import create_engine, Column, Integer, Float, DateTime
from sqlalchemy.orm import declarative_base, sessionmaker
from datetime import datetime
import requests
import json

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

def getTelemetry():
    #statements
    tb_local = session.query(Telemetrylocal)\
        .filter(Telemetrylocal.sent == 0)\
        .order_by(Telemetrylocal.create_at.desc())\
        .first()
    tb_meter = session.query(Telemetrymeter)\
        .filter(Telemetrymeter.id == tb_local.id)\
        .first()
    tb_work = session.query(Telemetrywork)\
        .filter(Telemetrywork.id == tb_local.id)\
        .first()
    jsonData = {
            'filesystem': {
                date:tb_local.date_data,
                time: tb_local.time_data, 
                
                }

    }
    return (

config = "/home/orangepi/telemetry/conf.json"

try:
    print(getTelemetry())
except Exception as e:
    print(f"!!!Error: {e}")

EOR
  echo "Create Python Directory..."
else
  echo "Already has Python Directory..."
fi

if [ ! -f "$conf" ]; then
  touch "$conf"
  code=$(cat $HOME/loom/influxdb/device.txt)
  source_=$(cat $HOME/loom/source.txt)
  cat << EOY >> "$conf"
  {
    "code": "$code",
    "source": "$source_",
    "circumferance": 0,
    "gear-ratio": 0
  }
EOY
fi 

#node-red-flow
#rm -rf "$nodered"
#cat << 'EON' > "$nodered"
#  \
#EON
