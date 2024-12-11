# Monitoring with Prometheus and Grafana

This project is designed to create and monitor custom metrics using **Prometheus** and **Grafana**. It includes tools to generate fake data for testing and provides an easy-to-use setup for local development.

## Features

1. **Prometheus and Grafana Integration**: Pre-configured setup for Prometheus and Grafana.
2. **Fake Data Generator**: A Bash script (`faker.sh`) for creating mock metrics data.
3. **Makefile Commands**: Simplified commands for generating data, running the environment, and stopping services.

## Requirements

-   Docker
-   Make

## Installation

1. Clone the repository

2. Ensure Docker and Make are installed on your system.

## Usage

### 1. Prepare the Fake Data Generator

Before generating fake data, edit the `faker.sh` script if needed. The script includes a function `save_metrics_to_file`, which creates a sequence of metrics and writes them to a file.

#### Function Documentation:

```
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
# save_metrics_to_file "http_requests_total" 'method="GET",status="200"' 50 $start_time $current_time output.txt
#
# The function will write the following lines to output.txt:
#
# http_requests_total{method="GET",status="200"} 35 1696099200
# http_requests_total{method="GET",status="200"} 70 1696099260
# http_requests_total{method="GET",status="200"} 105 1696099320
```

Ensure that `faker.sh` is executable:

```bash
chmod +x faker.sh
```

### 2. Generate Fake Data

To generate fake data using the `faker.sh` script, run:

```bash
make gen
```

This will create mock metrics data in a format compatible with Prometheus.

### 3. Start Prometheus and Grafana

Run the following command to start Prometheus and Grafana in Docker containers:

```bash
make dev
```

-   Grafana URL: [http://127.0.0.1:3000](http://127.0.0.1:3000)
-   Prometheus URL: [http://127.0.0.1:9090](http://127.0.0.1:9090)

### 4. Stop Services

To stop and remove the running Docker containers, execute:

```bash
make stop
```

## Files and Directories

### `faker.sh`

-   A Bash script for generating fake metrics data. Customize it as needed to create specific metrics for testing.

### `Makefile`

-   `make gen`: Runs the `faker.sh` script to generate fake data.
-   `make dev`: Starts Prometheus and Grafana containers.
-   `make stop`: Stops and removes running containers.

## Metrics Monitoring

Once the environment is running, you can:

1. Access **Grafana** at [http://127.0.0.1:3000](http://127.0.0.1:3000):
    - Default credentials:
        - Username: `admin`
        - Password: `admin`
    - Configure Prometheus as the data source in Grafana.
2. Use **Prometheus** at [http://127.0.0.1:9090](http://127.0.0.1:9090) to query metrics directly.

## Dashboard Provisioning in Grafana

To simplify the setup of Grafana dashboards, you can use **dashboard provisioning** to automatically load preconfigured dashboards when Grafana starts.

### Steps for Dashboard Provisioning

1. **Save a Dashboard JSON File**.
   Export your dashboard from Grafana as a JSON file and save it in the `grafana/dashboards/` directory.

    ```
    dashboards/
    └── example-dashboard.json
    ```

2. **Create a Provisioning Configuration File**.
   Create a YAML file in the `provisioning/dashboards` directory to define the provisioning settings:

    ```yaml
    apiVersion: 1

    providers:
        - name: "default"
          folder: ""
          type: file
          disableDeletion: false
          updateIntervalSeconds: 10
          options:
              path: /etc/grafana/dashboards
    ```

3. **Restart Grafana**.
   Restart the Grafana container to apply the provisioning settings:

    ```bash
    make stop dev
    ```

The preloaded dashboards will now appear in Grafana under the specified folder (or the root folder if not specified).

## Alerting Provisioning in Grafana

Grafana allows provisioning of alert rules to automate alert setup. These rules can be loaded at startup using a YAML configuration file.

### Steps for Alerting Provisioning

1. **Define Alerting Rules**.
   Create a YAML file in the `provisioning/alerting/` directory to define alert rules. Example:

    ```yaml
    apiVersion: 1

    groups:
        - name: PaymentAlerts
            interval: 1m
            rules:
                - alert: HighErrorRate
                expr: (sum(rate(payments_failed_total[5m])) / sum(rate(payments_initiated_total[5m]))) > 0.1
                for: 2m
                labels:
                    severity: critical
                annotations:
                    summary: "High payment error rate detected"
                    description: "The error rate for payments has exceeded 10% over the last 5 minutes."

                - alert: LowPaymentInitiationRate
                expr: rate(payments_initiated_total[5m]) < 10
                for: 5m
                labels:
                    severity: warning
                annotations:
                    summary: "Low payment initiation rate"
                    description: "The rate of payment initiations is below 10 per minute."
    ```

2. **Restart Grafana**.
   Restart the Grafana container to apply the alerting settings:

    ```bash
    make stop dev
    ```

3. **Access Preconfigured Alerts**.
   The preloaded alert rules will now appear in Grafana under the Alerting section.

## Troubleshooting

-   Ensure Docker is running and accessible.
-   If ports are in use, modify the `docker-compose.yml` file to use different ports.
-   Verify that `faker.sh` is executable:
    ```bash
    chmod +x faker.sh
    ```

## License

This project is licensed under the Apache-2.0 license.
