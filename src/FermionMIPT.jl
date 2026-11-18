module FermionMIPT


using Serialization
using LinearAlgebra
using Statistics
using Dates
using Random
using QuantumClifford


include("gates.jl")
include("cache.jl")
include("entropy.jl")
include("measurement.jl")
include("gate_pools.jl")
include("circuit.jl")
include("simulation.jl")


export generate_two_qubit_cliffords
export is_parity_preserving
export is_number_conserving
export is_matchgate
export is_number_conserving_matchgate


export create_clifford_cache
export create_parity_preserving_cache
export create_number_conserving_cache
export create_matchgate_cache
export create_number_conserving_matchgate_cache
export save_cache
export load_cache


export AbstractEntropyMeasure
export VonNeumannEntropy
export calculate_entropy
export half_chain_entropy


export local_measurement!
export global_measurement!


export AbstractGatePool
export ParityCliffordPool
export NumberConservingCliffordPool
export MatchgateCliffordPool

export GateApplication
export BrickWallStep
export BrickWallCircuit
export bond_pairs
export generate_brickwall_circuit
export apply_timestep!


export SimulationResult
export simulate_circuit
export is_saturated
export ensemble_average


end
