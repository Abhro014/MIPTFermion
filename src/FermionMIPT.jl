module FermionMIPT

using Serialization

using LinearAlgebra
using Statistics
using Random
using QuantumClifford


include("gates.jl")
include("cache.jl")
include("circuit.jl")
include("entropy.jl")
include("simulation.jl")

export generate_two_qubit_cliffords
export is_parity_preserving
export is_number_conserving
export is_matchgate
export is_number_conserving_matchgate

export AbstractGatePool
export ParityCliffordPool
export GateApplication
export BrickWallStep
export BrickWallCircuit
export bond_pairs
export generate_brickwall_circuit
export apply_timestep!

export AbstractEntropyMeasure
export VonNeumannEntropy
export calculate_entropy
export half_chain_entropy

export SimulationResult
export simulate_circuit
export is_saturated
export ensemble_average

export create_clifford_cache
export create_parity_preserving_cache
export create_number_conserving_cache
export create_matchgate_cache
export create_number_conserving_matchgate_cache

export save_cache
export load_cache

end
