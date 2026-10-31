#!/bin/bash

mkdir --parents "$METRICS_DIR"

# Function to run speed test and format output
run_speedtest() {
  echo "Running speed test..."

  # Run speedtest and capture JSON output
  result=$(speedtest --json 2>/dev/null || echo '{"error": "speedtest failed"}')

  if echo "$result" | grep -q '"error"'; then
    echo "Speed test failed"
    return 1
  fi

  # Extract metrics from JSON
  download=$(echo "$result" | jq -r '.download // 0')
  upload=$(echo "$result" | jq -r '.upload // 0')
  ping=$(echo "$result" | jq -r '.ping // 0')
  server_name=$(echo "$result" | jq -r '.server.name // "unknown"' | sed 's/"/\\"/g')
  server_sponsor=$(echo "$result" | jq -r '.server.sponsor // "unknown"' | sed 's/"/\\"/g')

  {
    echo "# HELP speedtest_download_bits_per_second Download speed in bits per second"
    echo "# TYPE speedtest_download_bits_per_second gauge"
    echo "speedtest_download_bits_per_second $download"

    echo "# HELP speedtest_upload_bits_per_second Upload speed in bits per second"
    echo "# TYPE speedtest_upload_bits_per_second gauge"
    echo "speedtest_upload_bits_per_second $upload"

    echo "# HELP speedtest_ping_milliseconds Ping latency in milliseconds"
    echo "# TYPE speedtest_ping_milliseconds gauge"
    echo "speedtest_ping_milliseconds $ping"

    echo "# HELP speedtest_server_info Information about the speedtest server used"
    echo "# TYPE speedtest_server_info gauge"
    echo "speedtest_server_info{name=\"$server_name\",sponsor=\"$server_sponsor\"} 1"

    echo "# HELP speedtest_last_run_timestamp Unix timestamp of last successful speedtest"
    echo "# TYPE speedtest_last_run_timestamp gauge"
    echo "speedtest_last_run_timestamp $(date +%s)"
  } > /var/lib/prometheus-node-exporter-text-files/speedtest.prom.tmp

  # Atomic move
  mv /var/lib/prometheus-node-exporter-text-files/speedtest.prom.tmp \
     /var/lib/prometheus-node-exporter-text-files/speedtest.prom

  echo "Speed test completed successfully"
  return 0
}

# Initialize with empty metrics
{
  echo "# HELP speedtest_download_bits_per_second Download speed in bits per second"
  echo "# TYPE speedtest_download_bits_per_second gauge"
  echo "speedtest_download_bits_per_second 0"

  echo "# HELP speedtest_upload_bits_per_second Upload speed in bits per second"
  echo "# TYPE speedtest_upload_bits_per_second gauge"
  echo "speedtest_upload_bits_per_second 0"

  echo "# HELP speedtest_ping_milliseconds Ping latency in milliseconds"
  echo "# TYPE speedtest_ping_milliseconds gauge"
  echo "speedtest_ping_milliseconds 0"

  echo "# HELP speedtest_last_run_timestamp Unix timestamp of last successful speedtest"
  echo "# TYPE speedtest_last_run_timestamp gauge"
  echo "speedtest_last_run_timestamp 0"
} > "$METRICS_DIR"/speedtest.prom

# Run initial test after a short delay
sleep "$INITIAL_DELAY_SECONDS"
run_speedtest

while true
do
  sleep "$INTERVAL_SECONDS"
  run_speedtest
done
