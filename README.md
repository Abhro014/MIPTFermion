# FermionMIPT
This repository contains the source code for the Julia package **FermionMIPT.jl**. The package is designed to study **Measurement-Induced Phase Transitions (MIPT)** in fermionic systems using Clifford circuits and stabilizer-formalism simulation. The below codes are mostly written in Julia, while a minor fraction of it, for data visualization and processing, might be done in Python. The package is structured to provide a comprehensive framework for simulating and analyzing MIPT phenomena in fermionic systems.
--------
## Directory Structure
```
.
├── LICENSE   
├── Manifest.toml     
├── Project.toml   
├── README.md
├── data
│   └── cache
├── demo.jl
├── results
│   ├── plots
│   └── simulations
├── run.jl
├── scripts
│   ├── data.jl
│   └── plots.jl
├── src
│   ├── FermionMIPT.jl
│   ├── cache.jl
│   ├── circuit.jl
│   ├── entropy.jl
│   ├── gate_pools.jl
│   ├── gates.jl
│   ├── measurement.jl
│   └── simulation.jl
└── test
```

## FermionMIPT.jl
> A Julia package for studying **Measurement-Induced Phase Transitions (MIPT)** in fermionic systems using Clifford circuits and stabilizer-formalism simulation.



`./src` contains the main source code of the package. We define a module named `FermionMIPT` inside `./src/FermionMIPT.jl`. The name of the julia scripts explains the functionality of the structs/functions present therein. The useful contents are described below for a quick reference.

### DataTypes
-----------------
|DataType|Description|
|--------|-----------|
|`AbstractEntropyMeasure`|An absttract datatype for defining various entropy measures.|
|`VonNeumannEntropy`|A concrete datatype for computing the von Neumann entropy.|
|--------|-----------|
|`AbstractGatePool`|An abstract datatype for defining various gate pools.|
|`ParityCliffordPool`| A concrete datatype for defining a pool of parity-preserving Clifford gates.|
|`NumberConservingCliffordPool`| A concrete datatype for defining a pool of number-conserving Clifford gates.|
|`MatchgateCliffordPool`| A concrete datatype for defining a pool of matchgate Clifford gates.|
|--------|-----------|
|`GateApplication`| A concrete datatype for applying a gate to a quantum state.|
|`BrickWallStep`| A concrete datatype for applying a brick-wall step (even + odd) of gates to a quantum state.|
|`BrickWallCircuit`| A concrete datatype for applying a brick-wall circuit of gates to a quantum state. Consists of multiple layers of `BrickWallStep`.|
|--------|-----------|
|`SimulationResult`| A concrete datatype for storing the results of a simulation. Contains the measurement rate, entropy measures, number of qubits, and other relevant informations.|


### Functions
-----------------
|Function|Description|
|--------|-----------|
|`generate_two_qubit_cliffords()`|Generates and returns a tuple of all two-qubit base and phase-expanded Clifford gates.|
|`is_parity_preserving(gate)`|Checks if a given gate is parity-preserving.|
|`is_number_conserving(gate)`|Checks if a given gate is number-conserving.|
|`is_matchgate(gate)`|Checks if a given gate is a matchgate.|
|--------|-----------|
|`save_cache(data, filename)`|Saves the given data to a cache file with the specified filename at `./data/cache`.|
|`load_cache(filename)`|Loads and returns the data from a cache file with the specified filename at `./data/cache`.|
|`create_clifford_cache()`|Creates and saves a cache of all two-qubit Clifford gates at `./src/data/cache/two_qubit_cliffords.jls`.|
|`create_parity_preserving_cache(gates)`| Filters and stored the parity-preserving gates from the given gates to a cache file at `./src/data/cache/two_qubit_parity_preserving_cliffords.jls`.|
|`create_number_conserving_cache(gates)`| Filters and stored the number-conserving gates from the given gates to a cache file at `./src/data/cache/two_qubit_number_conserving_cliffords.jls`.| 
|--------|-----------|
|`calculate_entropy(state, subsystem, measure)`|Calculates and returns the entropy of the given quantum state using the specified entropy measure.|
|`half_chain_entropy(state, measure)`|Calculates and returns the half-chain entropy of the given quantum state using the specified entropy measure.|
|--------|-----------|
|`local_measurement(state, measurement_rate)`| Generates a random number `q` for each qubit in the given state, and performs a Z-basis measurement if `q < measurement_rate`|
|`global_measurement(state, measurement_rate)`| Generates a random number `q` for the entire state and performs a Z-basis measurement on all qubits if `q < measurement_rate`|
|--------|-----------|
|`bond_pairs`| Generates and returns a list of bond pairs for a given number of qubits. (eg. [(1,2), (3,4), (5,6)] for even layer of a brick-wall circuit with 6 qubits and [(2,3), (4,5)] for the odd layer of the same).|
|`generate_brickwall_circuit`| Generates and returns a `BrickWallCircuit` with the specified number of qubits, number of layers, and gate pool.|
|`apply_timestep!`| Applies a single `BrickWallStep` of the circuit to the given quantum state.|
|`simulate_circuit(circuit; measurement_rate, measure)`| Simulates a given `BrickWallCircuit` on the specified number of qubits with the given measurement rate and entropy measure.|
|`ensemble_average(pool, nqubit, ntraj, max_steps, ...)`| Simulates  `ntraj` numbers of circuits with the specified parameters and returns the average entropy measures over the ensemble.|
-------------

The relevant data in csv format are kept in the `./results/simulations` folder, while the plots are stored in the `./results/plots` folder. The `./demo.jl` script can be used to create the cache. The `./run.jl` script can be used to run the simulations and generate the plots. It uses `./scripts/data.jl` and `./scripts/plots.jl` scripts for creating the data files and images.

## plots.jl
The file `./scripts/plots.jl` contains the functions for plotting the results of the simulations. 

It has `save_plot(p::Plots.Plot, savepath::String)` that saves the plot `p` at `savepath`. 

The function `make_plot(result::FermionMIPT.SimulationResult; savepath::Union{Nothing,String}=nothing, p::Plots.Plot)` is made to use in used in two modes. If running for a particular number of qubits with a fixed measurement rate, you do not need to provide `p` parameter, however for plotting different number of qubits under a particular measurement rate, (scaling of entanglement under a given rate of measurement), we should pass the `p` parameter, preferably an empty plot, to the function. The function will then add the data to the plot and return it.  

## TODO:
- [ ] Implement weak-measurement protocols
- [ ] Allow to use gates other than Cliffords, say the generic set of matchgates
- [ ] Use different measures of entanglement, such as Renyi entropies, mutual information, etc. 
- [ ] Modularize the gate loader from `./run.jl` and put them to `./src/gates.jl` or `./src/gate_pools.jl`.
- [ ] Add `./src/states.jl` to define various non-trivial parity-preserving states.
- [ ] Implement definitions of Entanglement Power and Gate Typicality, Gate Criticality
- [ ] Make a list of results: accuracy of result, for which gate what result do we gate, make a case summary for each types of gates. Do we see a transition, what kind of transition, etc.


----------

## Issues
1. `./analysis.jl` shows there is a significant amount of fluctuations in the data points, adding more data points to them may give better fitting.

## Remarks
1. The final plot indeed shows the fragile nature of vloume-law entanglement under matchgate evolution. 