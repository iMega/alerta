#!/usr/bin/env bash

# Copyright © 2024 Dmitry Stoletov <info@imega.ru>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# save_metrics_to_file
#
# creates a sequence of metrics with specified parameters, incrementing
# the counter by a random value within a defined range. The metrics
# are written to a file, one line per metric.
#
# Usage:
# ------
# save_metrics_to_file <metric_name> <labels> <limit> <start_time> <current_time> <filename>
#
# metric_name   The name of the metric in Prometheus format
#               (e.g., http_requests_total).
# labels        Labels in Prometheus format (e.g., method="GET",status="200").
# limit         The maximum random increment for the counter at each step.
# start_time    The starting Unix timestamp (e.g., $(date +%s)).
# current_time  The ending Unix timestamp (e.g., $(date +%s)).
#
# Example:
# --------
# current_time=$(date +%s)
# start_time=$((current_time - 604800)) # 7 days in sec
# save_metrics_to_file "http_requests_total" 'method="GET",status="200"' 50 $start_time $current_time
#
# The function will write the following lines to output.txt:
#
# http_requests_total{method="GET",status="200"} 35 1696099200
# http_requests_total{method="GET",status="200"} 70 1696099260
# http_requests_total{method="GET",status="200"} 105 1696099320
#
save_metrics_to_file() {
    local metric_name=$1
    local labels=$2
    local limit=$3
    local start_time=$4
    local current_time=$5
    local filename=$6

    total=0

    while [ $start_time -lt $current_time ]; do
        increment=$((RANDOM % limit))
        total=$((total + increment))
        BODY="$metric_name{$labels} $total $start_time"

        echo $BODY >> output.txt

        start_time=$((start_time + 60))
    done
}

current_time=$(date +%s)
start_time=$((current_time - 604800)) # 7 days in sec

save_metrics_to_file "payments_initiated_total" "product=\"pro_account\"" 11 $start_time $current_time
save_metrics_to_file "payments_successful_total" "product=\"pro_account\"" 11 $start_time $current_time

# end
echo "# EOF" >> output.txt
