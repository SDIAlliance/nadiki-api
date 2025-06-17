When creating a server, I would like to transmit a configuration/mapping of metrics. This replaces the logic of us returning fixed metric names and endpoints.

Instead the user can submit a configuration object to us.

The object has the following fields:

* target_metric (example: server_power_consumption)
* input_metric_unit (allowed: Watt, Seconds, Percentage, Fraction, Bytes)
* input_metric_type (limited to: Gauge, Counter)
* input_metric_name (e.g. ipmi_dcmi_power_consumption_watts)
* measurement_interval (in seconds)
* device_name (only used when an array is passed to the target metric)

For each target_metric key it is possible to pass an object or an array, for example:

```
{ 
  "gpu_utilization": [
    { "device_name": "gpu_0", "input_metric_unit": "percentage", "input_metric_type": "gauge", "measurement_interval": 15, "input_metric_name": "gpu_power_consumption_watts" },
    { "device_name": "gpu_0", "input_metric_unit": "percentage", "input_metric_type": "gauge", "measurement_interval": 15, "input_metric_name": "gpu_power_consumption_watts"  }
  ] 
}
```

```
{ 
  "cpu_utilization": { "input_metric_unit": "seconds", "input_metric_type": "counter", "measurement_interval": 15, "input_metric_name": "node_cpu_seconds_total" }
}
```

We have a list of allowed target metrics (underscore them):

* server power consumption
* cpu utilization
* cpu power consumption
* cpu surface temperature
* gpu utilization
* gpu power consumption
* gpu memory utilization
* fpga utilization
* fpga power consumption
* fpga memory utilization
* memory free
* memory available
* memory utilization
* memory power
* server fan speed
* network traffic received bytes
* network traffic transmitted bytes
* network traffic received packets
* network traffic transmitted packets
* storage read bytes
* storage written bytes
* storage read completed
* storage written completed