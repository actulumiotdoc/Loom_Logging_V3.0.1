#!/bin/bash
user=$HOME
sqldir=telemetry/sql/
pydir=telemetry/py/
db=$user/telemetry/sql/telemetry_factory.db
conf=$user/telemetry/conf.json
nodered=$user/.node-red/flows.json

sudo apt update && sudo apt -y upgrade
echo "[Device] npm install better-sqlite3..."
npm install better-sqlite3 --prefix  ~/.node-red/

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
  echo "Create Python Directory..."
else
  echo "Already has Python Directory..."
fi

if [ ! -f "$conf" ]; then
  touch "$conf"
  code=$(cat $HOME/loom/influxdb/device.txt)
  source_=$(cat $HOME/loom/source.txt)
  cat << EOG >> "$conf"
  {
    "code": "$code",
    "source": "$source_",
    "circumferance": 0,
    "gear-ratio": 0
  }
EOG
fi


#node-red-flow
#rm -rf "$nodered"
#cat << 'EON' > "$nodered"
#  \
#EON
