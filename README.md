# Goal

We want to calculate the environmental impact indicators (see below) of a workload running on a server inside a data center, accounting for all the following assets involved in running that workload:

* Data Center Facility
* Rack
* Server

We do not consider networking equipment/internet connectivity at the moment or external storage systems (tbd).

To do so, we need the different assets along within the infrastructure to report both their defining attributes ('static data') as well as measured values to a **Central Registry** ('Registar'). 
From that registry, data can enriched, aggregated as needed and be queried by the workload itself to determine it's own total environmental impact (or for a given time period).

## Entities

The entities which need to register and report data to the Registrar are the following:

* Data Center Facility
* Rack
* Server

For each entity, there is an API specification which handles the registration. Each entity can pass numerous static parameters with the registration, for most there is default specified (see below). Upon registration each entity receives a InfluxDB-compatible endpoint as well as a list of metrics & labels that the measured data should be reported to. It is then up to the respective entity to collect & forward the data to the endpoint.

## Environmental Impact Indicators

These are the calculated, output metrics generated from the available data for each entity.
Each entity supports a `query` API endpoint to retrieve these metrics either as a total or using `from` and `to` timestamps.
Each of these metrics are `gauge` types that can only increase over time. For example: A Facility's energy consumption, can slow but it can never become zero.


| **Name**                           | **Metric**                            | **Unit** | **Update interval** | **Notes**                                                            |
| ---------------------------------- | ------------------------------------- | -------- | ------------------- | -------------------------------------------------------------------- |
| Re-used energy                     | total_reused_energy                   | kWh      | 15m                 | Amount of energy re-used (e.g. heat)                                 |
| Primary energy use[^1]             | total_primary_energy_use              | kWh      | 15m                 |                                                                      |
| Primary energy use (renewable)[^2] | total_primary_renewable_energy_use    | kWh      | 15m                 |                                                                      |
| Primary energy use (non-renewable) | total_primary_nonrenewable_energy_use | kWh      | 15m                 |                                                                      |
| Climate change potential           | total_climate_change_potential        | CO2-eq   | 15m                 | Combining embodied emissions and operational emissions (e.g. energy) |
| Fresh Water Use                    | total_fresh_water_use                 | m3       | 15m                 |                                                                      |
| Adiabatic Depletion Potential      | total_adiabatic_depletion_potential   | kg Sb-eq | 15m                 | All components within the entity combined[^3]                        |

[^1]: If we we have no measure of power usage in the facility or of the server, we always default to using the design power capacity of the facility as specified. For example, a facility may have a total power capacity of 10MW, which is the value we are going to use to calculate the primary energy use.
[^2]: Unless configured for the Facility (e.g. certificates, on-site renewable power production or PPAs), we assume that none of the energy used is renewable.
[^3]: Depending on the entity (Facility, Server, Rack), the components vary, e.g. they could be electrical and mechanical equipment within a Facility, memory and computing chips within a Server, or PDUs and batteries within a Rack.
  We focus on mineral consumption here. [More information](https://helpcenter.ecochain.com/en/articles/9588517-explained-environmental-impact-categories#h_84e6d8b486). 

## Data Center Facility

| **Name** | Version | **Description** | **Unit** | **Type** | **Used in Indicator** | **Default/Assumption** | **Source** |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Data Center ID | 1 | A unique identifier for the data center | UID | Static |  |  | FACILITY-[COUNTRY_CODE]-ID |
| Grid Emission Factor | 1 | The emission factor of the Grid surrounding the facility (pass-thru via Electricity Map) | CO2-eq (kg) | Dynamic | Primary energy use | 0,406 kg CO2-eq/kWh | [NL 2021 Data from EU](https://data.jrc.ec.europa.eu/dataset/919df040-0252-4e4e-ad82-c054896e1641) |
| Backup Emission Factor | 1 | The emission factor of the backup power generation system (diesel generators) | CO2-eq (kg) | Dynamic | Primary energy use  |
| Electricity Source | 1 | A semi-boolean field that tells what electricity source is currently active | Grid or Backup | Dynamic | Grid |  |
| PUE 1 | 1 | Power usage effectiveness measured from the output of the UPS systems for IT load | Ratio | Static | Primary energy use | 1.46 | [Uptime Average for EU](https://journal.uptimeinstitute.com/datacenter-energy-efficiency-by-region/) |
| PUE 2 | 1 | Power usage effectiveness measured from the output of the PDU systems for IT load | Ratio | Static | Primary energy use | 1.46 | [Uptime Average for EU](https://journal.uptimeinstitute.com/datacenter-energy-efficiency-by-region/) |
| Pump Heat Produced | 1 | Amount of energy produced by a heat pump connected to the data center cooling system | kWh | Dynamic | Re-use energy | 0 |  |
| Heat Pump Power Consumption | 1 | Amount of electricity used by the heat pump to generate heat | kWh | Dynamic | Primary energy use | 0 | Zabbix |
| Office Energy Use | 1 | Amount of electricity used by the office | kWh | Dynamic | Primary energy use | 0 | Zabbix |
| DC Water | 1 | Amount of fresh water used by the DC, for example in chillers for adiabatic cooling. | m3 | Dynamic | Fresh Water Use | 0 | Water meters OR invoice data from water company (manual) |
| Office Water | 2 | Amount of fresh water used by the Office space associated with the facility (if any). | m3 | Dynamic | Fresh Water Use | 0 | Water meters OR invoice data from water company (manual) |
| Embedded GHG Emissions Facility | 1 | The amount of embodied carbon emissions from the construction of the data center | CO2-eq | Static | Climate Change Potential |  | missing assumption |
| Life Time Facility | 1 | The expected lifetime of the facility | Years | Static | Climate Change Potential | 15 | missing source |
| Embedded GHG Emissions Assets | 1 | The sum of all GHG emissions that are embodied in the assets from their manufacturing and transport. | CO2-eq | Static | Climate Change Potential |  | missing data |
| Life Time Assets | 1 | The expected, average lifetime of all assets in the facility | Years | Static | Climate Change Potential | 10 | missing source |
| Amount of cooling fluids | 1 | The amount of cooling fluids used in the cooling systems (chillers, compressors, heat exchangers), grouped by type | kg or m3 | Static | Climate Change Potential |  | missing source, invoices? |
| Types of cooling fluids | 1 | The type for each cooling fluid | Identifier | Static | Climate Change Potential |  | missing, invoices? |
| GHG Emission Factor per Cooling Fluid Type | 1 | The list of GHG Emission Factor values for each type of cooling fluid | GWP (Global Warming Potential) Factor | Static | Climate Change Potential |  | missing, invoices? |
| Grid CO2 Intensity Factor | 1 | The amount of renewable energy available in the grid zone of the data center facility | CO2-eq (gramms) per kWh | Dynamic | Climate Change Potential |  | Electricity Map (missing API Key) |
| GHG Emission Factor for Generator Fuel | 1 | The GHG emission factor of the fuel type used in backup generators (assuming single fuel type) | GWP (Global Warming Potential) Factor | Static | Climate Change Potential | what is a good default for standard diesel fuel? | missing |
| Maintenance Hours of Generator Runtime | 2 | Hours per year that the generators are assumed to run and burn fuel. Maintenance run hour assumes that generators produce 100% of possible electrical energy during the duration. | Hours | Static | Climate Change Potential | how many hours are default planned for diesel generator maintenance? | maintenance manual |
| Adjustment Factor for Ambient Temperature of Generator Fuel | 2 | [@Yana](https://sdiagroup.slack.com/team/U07RRJY1NDQ) to add? |  |  |  |  |  |
| Total Generator Electricity Production | 1 | The total energy output of the generators running | kWh | Dynamic | Primary energy use, Climate Change Potential, Backup Emission Factor |  | Zabbix |
| Total Average Load Factor of Running Generators | 1 | Average load factor of all generators running. We assume they are all the same | % | Dynamic | Primary energy use, Climate Change Potential, Backup Emission Factor |  | Zabbix |
| Fuel Efficiency of Generators at Load | 1 | Static curve of load factor vs. output efficiency or fuel use. Should express liters of fuel used at given load factor. | Efficiency % at Load % | Static | Primary energy use, Climate Change Potential, Backup Emission Factor |  | Documentation of the generator? |
| Energy Content of Generator Fuel | 1 | A static value on the energy content in a liter of fuel | kWh per Liter | Static | Primary energy use, Climate Change Potential, Backup Emission Factor |  | Documentation of the fuel? |
| Total Grid Transformers Energy | 1 | Sum of energy output of all transformers in the data center facility | kWh | Dynamic | Primary energy use |  | Zabbix |
| Total On-Site Renewable Power Generation | 1 | Sum of energy produced of all on-site renewable energy sources (such as solar) | kWh | Dynamic | Primary energy use (renewable) |  | Zabbix |
| IT DC Power Usage (Level 1) | 1 | Sum of all power usage as measured by the total output of the UPS systems connected to the power feeds toward the rack | kWh | Dynamic | Primary energy use |  | Zabbix |
| IT DC Power Usage (Level 2) | 1 | Sum of all power usage as measured by the total output of the PDUs in each rack connected to the power feeds | kWh | Dynamic | Primary energy use |  | Zabbix |
| Renewable Energy Certificates | 2 | Either % or kWh covered by annually matched green energy certificates | kWh or % | Dynamic or Static | Primary energy use (renewable and non-renewable) | 0 | Scholt API |
| Location of the data center | 1 | Geo coordinates of the data center | Lat/Lng | Static | Grid Emission Factor | NL |  |
| Installed (rated) electrical capacity of the data center facility | 1 | Installed/rated power capacity of the data center facility | kWh | Static | Verification |  |  |
| Number of grid power feeds connected to the facility | 1 | How many physical power feeds are connected to the facility? | Number | Static | Verification | 3 |  |
| Design PUE | 1 | What was the PUE that the facility was designed for? | Factor | Static | Verification | 1.4 |  |
| Facility Tier Level | 1 | The certified/rated tier level of the data center facility | Number (1-4) | Static | Verification | 3 |  |
| Number of floors of white space | 1 | If it’s multi-story building, how many floors are used for white space? | Number | Static | Verification | 1 |  |
| Total facility space | 1 | What is the total space of building? | m2 | Static | Verification |  |  |
| Total whitespace in the facility | 1 | How much space of the facility is used for whitespace/to host IT equipment? | m2 | Static | Verification |  |  |

## Rack

| Metric Name | Type | Unit | Default Value | Default Source | Measurement | Required | Description |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Data Center ID | UID | - | - | - | - | Yes |  |
| Cage ID | UID | - | null | - | - | No |  |
| Total available power | number | kW | 5 | Assumption | Static | No |  |
| Total available cooling capacity | number | kW | 5 | Assumption | Static | No |  |
| Number of PDUs | number | - | 2 | Assumption | Static | No |  |
| Power redundancy | number | - | 2 | Assumption | Static | No | No of power feeds used for redudancy (e.g. 2 power feeds = 2 redudancy, each server plugged into two outlets) |
| Product passport | object | - | missing | - | Static | No | LCA |
| PDU energy consumption | array | kWh |  |  | Dynamic | Yes | An array with a power reading for each PDU |
| Inlet temperature sensor | number | C |  |  | Dynamic | No | Measurement of celsius of the inlet cooling temperature (either water or air) |
| Outlet temperature sensor | number | C |  |  | Dynamic | No | Measurement of celsius of the outlet cooling temperature (either water or air) |

## Server

| Metric Name | Type | Unit | Default Value | Default Source | Measurement | Required | Description |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Data Center ID | UID | - | - | - |  | Yes |  |
| Rack ID | UID | - | - | - |  | Yes |  |
| Rated power | number | kW | - | - | Static | No |  |
| Total CPU sockets | number | - | 2 | Assumption | Static | No |  |
| Installed CPUs | array | - | - | - | Static | No | An array of objects with CPUs: Vendor (Intel), Type (Identifier) |
| Number of PSUs | number | - | 2 | Assumption | Static | No |  |
| Total installed memory | number | GB | - | - | Static | No |  |
| Number of memory units installed | number | - | - | - | Static | No | e.g. 2 memory sticks |
| Storage devices array | array | - | - | - | Static | No | An array of objects with storage devices: Vendor (Samsung), Capacity (TB), Type (NVMe, SSD, HDD, Other) |
| Total GPUs installed | number | - | 0 | Assumption | Static | No |  |
| Total FPGA installed | number | - | 0 | Assumption | Static | No |  |
| Installed FPGAs | array | - | - | - | Static | No | An array of objects with FPGAs: Vendor (Intel), Type (Identifier) |
| Installed GPUs | array | - | - | - | Static | No | An array of objects with GPUs: Vendor (Nvidia), Type (Identifier) |
| Product passport | object | - | Boavizta API | Boavizta | Static | No | LCA |
| CPU energy consumption | number | kWh | - | - | Dynamic | No | Total energy consumption of all CPUs measured via RAPL |
| Server energy consumption | number | kWh | - | - | Dynamic | Yes | Total energy consumption of the server measured via IPMI |
| Cooling type | enum | string | air | Assumption | Static | Yes | One off: direct-to-chip, immersion, back-door-liquid, back-door-fan, air |

## Useful Resources

[Data Center Metrics](https://www.notion.so/Data-Center-Metrics-a32c4bb44d8d429c9b8fe6ae25202761?pvs=21) 
