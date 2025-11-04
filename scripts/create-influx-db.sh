#!/bin/sh
# Create database for telegraf (InfluxDB 1.x)
# This script runs on the host, or you can run it with docker exec.

# Wait for InfluxDB to be ready then create DB
until curl -sS http://localhost:8086/ping; do
  sleep 1
done

# Create database
curl -s -XPOST 'http://localhost:8086/query' --data-urlencode "q=CREATE DATABASE telegraf"
