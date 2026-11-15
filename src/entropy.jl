
# Abstract interface for entropy measures
abstract type AbstractEntropyMeasure end


struct VonNeumannEntropy <: AbstractEntropyMeasure
    algorithm::Symbol

    function VonNeumannEntropy(algorithm::Symbol=:rref)
        algorithm in (:clip, :graph, :rref) ||
            throw(ArgumentError("Unsupported entropy algorithm."))

        new(algorithm)
    end
end


# Calculate entropy for a specified subsystem
function calculate_entropy(
    state,
    subsystem::AbstractVector{Int},
    measure::VonNeumannEntropy
)
    return QuantumClifford.entanglement_entropy(
        state,
        subsystem,
        Val(measure.algorithm)
    )
end


# Convenience method for the half-chain bipartition
function half_chain_entropy(
    state,
    measure::VonNeumannEntropy=VonNeumannEntropy()
)
    n = QuantumClifford.nqubits(state)

    iseven(n) ||
        throw(ArgumentError("Half-chain entropy requires an even number of qubits."))

    subsystem = collect(1:(n÷2))

    return calculate_entropy(state, subsystem, measure)
end
