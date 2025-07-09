# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

The Nadiki API is a comprehensive registry system for calculating environmental impact indicators in Kubernetes environments. It provides OpenAPI 3.0.0 specifications for registering and monitoring data center infrastructure to track sustainability metrics.

## Architecture & Data Flow

### Hierarchical Entity Model
```
Data Center Facility
    └── Rack (multiple)
        └── Server (multiple)
```

### Two-Phase Data Collection
1. **Registration Phase**: Entities register static configuration via REST API
2. **Metrics Phase**: Upon successful registration, entities receive:
   - InfluxDB endpoint URL
   - Organization and bucket details  
   - Authentication token
   - List of required metrics with proper tags

### API Structure Pattern
Each entity type follows consistent RESTful endpoints:
- `POST /entities` - Register new entity with static data
- `GET /entities` - List all entities (paginated)
- `GET /entities/{id}` - Get specific entity details
- `PUT /entities/{id}` - Update entity configuration
- `DELETE /entities/{id}` - Remove entity from registry

## Key Files & Specifications

- `/data-center-facility/facility-api.spec.yaml` - Facility-level API (grid emissions, PUE, cooling, generators)
- `/rack/rack-api.spec.yaml` - Rack-level API (PDU consumption, inlet/outlet temperatures)
- `/server/server-api.spec.yaml` - Server-level API (hardware specs, RAPL/IPMI energy data)

## Important Conventions

### ID Format Requirements
- Facility: `FACILITY-[ISO-3166-COUNTRY]-[NUMERIC]` (e.g., `FACILITY-NLD-001`)
- Rack: `RACK-[FACILITY_ID]-[NUMERIC]` (e.g., `RACK-FACILITY-NLD-001-042`)
- Server: `SERVER-[FACILITY_ID]-[RACK_ID]-[NUMERIC]`

### Metric Naming Standards
All dynamic metrics follow strict naming conventions:
- Energy: `*_energy_consumption_joules`
- Temperature: `*_temperature_celsius`
- Water: `*_water_consumption_cubic_meters`
- Power: `*_power_watts`

For multi-component systems, use hierarchical naming:
- `pdu_1_energy_consumption_joules`
- `pdu_2_energy_consumption_joules`

### Time Series Tags
Each metric must include appropriate tags:
- `facility_id` - Always required
- `rack_id` - For rack and server metrics
- `server_id` - For server-specific metrics
- `component` - For multi-component measurements (e.g., pdu_1, cpu_socket_0)

## Environmental Impact Calculations

The system tracks five key indicators:
1. **Re-used Energy** - Heat recovery from cooling systems
2. **Primary Energy Use** - Total facility consumption (renewable/non-renewable split)
3. **Climate Change Potential** - CO2-equivalent emissions (operational + embodied)
4. **Fresh Water Use** - Cooling and office water consumption
5. **Abiotic Depletion Potential** - Mineral resource consumption from hardware

## Recent Architecture Changes

Based on commit history:
- **Migrated from Prometheus to InfluxDB** for time series storage
- **Removed query endpoints** - system now focuses on data collection only
- **Added description fields** to all entities for better documentation
- **Renamed "hard disks" to "storage devices"** for consistency

## Integration Points

### External Data Sources
- **Electricity Map API** - Real-time grid carbon intensity
- **Boavizta API** - Hardware lifecycle assessment data
- **Zabbix** - Infrastructure monitoring metrics
- **Scholt API** - Renewable energy certificates

### Metric Collection Methods
- **RAPL** - CPU energy measurements
- **IPMI** - Server-level power consumption
- **PDU** - Rack power distribution monitoring
- **Environmental sensors** - Temperature and humidity

## Default Values & Assumptions

Key defaults based on Netherlands/EU data:
- Grid emission factor: 0.406 kg CO2-eq/kWh (NL 2021)
- PUE: 1.46 (EU average)
- Renewable energy: 48% (NL 2023)
- Facility lifetime: 15 years
- IT equipment lifetime: 10 years
- Generator maintenance: Annual runtime hours for testing

## Development Status

This is a **specification-only** repository:
- No implementation code exists yet
- No build system, tests, or CI/CD
- Pure OpenAPI 3.0.0 specifications
- Focus on API design and data model definition