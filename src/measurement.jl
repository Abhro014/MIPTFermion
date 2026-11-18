using QuantumClifford


"""
    local_measurement(
        state::QuantumClifford.Stabilizer,
        measurement_rate::Float64;
        rng = Random.MersenneTwister(1234)
    )

Apply a measurement with specified measurement rate to a stabilizer state.
"""
function local_measurement!(
    state::QuantumClifford.Stabilizer,
    measurement_rate::Float64;
    rng=Random.MersenneTwister(1234)
)
    L = QuantumClifford.nqubits(state)
    measured_qubits=[] # stores indices of measured_qubits
    measurement_outcomes=[] # stores measurement outcomes

    for i in 1:L
        if rand(rng) < measurement_rate
            state, outcome = QuantumClifford.projectZrand!(state, i)
            push!(measured_qubits, i)
            push!(measurement_outcomes, outcome)
        end
    end

    return (state, measured_qubits)

end


function global_measurement!(
    state::QuantumClifford.Stabilizer,
    measurement_rate::Float64;
    rng=Random.MersenneTwister(1234)
)

    L = QuantumClifford.nqubits(state)
    q = rand(rng)
    
    if q < measurement_rate
        for i in 1:L
            state, outcome = QuantumClifford.projectZrand!(state, i)
            push!(measured_qubits, i)
        end
    end

    return state

end