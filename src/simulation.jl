
struct SimulationResult
    depths::Vector{Int}
    mean_entropy::Vector{Float64}
    stderr::Vector{Float64}
    trajectory_entropies::Matrix{Float64}
    saturated::Bool
    metadata::NamedTuple
end


# Test whether an entropy time series has reached a plateau.
#
# window specifies the number of points in each of two
# consecutive windows. We compare their means and estimate
# the slope over the combined interval.

function is_saturated(
    entropies::AbstractVector{<:Real};
    window::Int=10,
    atol::Float64=1e-3,
    rtol::Float64=1e-3
)

    window >= 2 ||
        throw(ArgumentError("window must be at least 2."))

    length(entropies) >= 2 * window || return false

    recent = Float64.(entropies[(end-2window+1):end])

    first_mean = mean(recent[1:window])
    second_mean = mean(recent[(window+1):end])

    x = collect(1:length(recent))
    x_centered = x .- mean(x)
    y_centered = recent .- mean(recent)

    slope = sum(x_centered .* y_centered) /
        sum(x_centered .^ 2)

    tolerance = atol + rtol * max(abs(second_mean), 1.0)

    mean_difference = abs(second_mean - first_mean)
    total_drift = abs(slope) * (length(recent) - 1)

    return mean_difference <= tolerance &&
        total_drift <= tolerance
end


# Evolve one pre-generated circuit from the vacuum state.

function simulate_circuit(
    circuit::BrickWallCircuit;
    measure::VonNeumannEntropy=VonNeumannEntropy()
)

    state = one(QuantumClifford.Stabilizer, circuit.nqubits)

    depths = collect(0:length(circuit.steps))
    entropies = Float64[half_chain_entropy(state, measure)]

    for step in circuit.steps
        apply_timestep!(state, step)
        push!(entropies, half_chain_entropy(state, measure))
    end

    return (
        depths=depths,
        entropies=entropies,
        final_state=state
    )
end


# Run an ensemble of independently generated circuits.
#
# All trajectories begin in the vacuum state.
# Saturation is checked using the ensemble mean.

function ensemble_average(
    pool::ParityCliffordPool,
    nqubits::Int;
    ntraj::Int=100,
    max_steps::Int=1000,
    seed::Int=1234,
    measure::VonNeumannEntropy=VonNeumannEntropy(),
    check_saturation::Bool=true,
    window::Int=10,
    min_steps::Union{Nothing,Int}=nothing,
    atol::Float64=1e-3,
    rtol::Float64=1e-3,
    measurement_protocol=nothing
)

    ntraj >= 1 ||
        throw(ArgumentError("ntraj must be positive."))

    max_steps >= 1 ||
        throw(ArgumentError("max_steps must be positive."))

    # Measurements are deliberately not implemented in this version.
    measurement_protocol === nothing ||
        throw(ArgumentError("Mid-circuit measurements are not implemented yet."))

    rng = MersenneTwister(seed)

    # Generate independent random circuits.
    circuits = [
        generate_brickwall_circuit(
            nqubits,
            max_steps,
            pool;
            rng=rng
        )
        for _ in 1:ntraj
    ]

    # Prepare independent vacuum states.
    states = [
        one(QuantumClifford.Stabilizer, nqubits)
        for _ in 1:ntraj
    ]

    # Column 1 stores depth zero.
    entropy_data = zeros(Float64, ntraj, max_steps + 1)

    for trajectory in 1:ntraj
        entropy_data[trajectory, 1] =
            half_chain_entropy(states[trajectory], measure)
    end

    saturated = false
    completed_steps = max_steps

    required_steps = isnothing(min_steps) ? 2 * window : min_steps

    # Evolve all trajectories synchronously.
    for depth in 1:max_steps

        for trajectory in 1:ntraj

            apply_timestep!(
                states[trajectory],
                circuits[trajectory].steps[depth]
            )

            entropy_data[trajectory, depth+1] =
                half_chain_entropy(states[trajectory], measure)
        end

        # Check the ensemble-averaged entropy.
        if check_saturation && depth >= required_steps

            mean_series = vec(
                mean(view(entropy_data, :, 1:(depth+1)), dims=1)
            )

            if is_saturated(
                mean_series;
                window=window,
                atol=atol,
                rtol=rtol
            )
                saturated = true
                completed_steps = depth
                break
            end
        end
    end

    # Discard unused columns if saturation occurred early.
    final_data = entropy_data[:, 1:(completed_steps+1)]

    mean_entropy = vec(mean(final_data, dims=1))

    stderr = if ntraj > 1
        vec(std(final_data, dims=1)) ./ sqrt(ntraj)
    else
        zeros(Float64, completed_steps + 1)
    end

    metadata = (
        nqubits=nqubits,
        half_chain_size=nqubits ÷ 2,
        ntraj=ntraj,
        seed=seed,
        requested_max_steps=max_steps,
        completed_steps=completed_steps,
        gate_pool="parity_preserving_cliffords",
        initial_state="vacuum",
        entropy_measure="von_neumann",
        measurement_protocol="none",
        saturated=saturated
    )

    return SimulationResult(
        collect(0:completed_steps),
        mean_entropy,
        stderr,
        final_data,
        saturated,
        metadata
    )
end
