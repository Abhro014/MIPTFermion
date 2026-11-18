
# A gate together with the two qubits on which it acts
struct GateApplication{G}
    sites::NTuple{2,Int}
    gate::G
end


# One complete timestep: even layer followed by odd layer
struct BrickWallStep{G}
    even::Vector{GateApplication{G}}
    odd::Vector{GateApplication{G}}
end


# Circuit containing a sequence of brick-wall timesteps
struct BrickWallCircuit{G,P<:AbstractGatePool}
    nqubits::Int
    pool::P
    steps::Vector{BrickWallStep{G}}
end


# Generate nearest-neighbour bonds
function bond_pairs(nqubits::Int, layer::Symbol)

    nqubits >= 2 ||
        throw(ArgumentError("At least two qubits are required."))

    if layer == :even
        start = 1
    elseif layer == :odd
        start = 2
    else
        throw(ArgumentError("Layer must be :even or :odd."))
    end

    return [(i, i + 1) for i in start:2:(nqubits-1)]
end


# Independently sample one gate for every bond in a layer
function sample_layer(
    rng::AbstractRNG,
    pool::AbstractGatePool,
    bonds
)
    G = eltype(pool.gates)
    
    return GateApplication{G}[
        GateApplication{G}(bond, rand(rng, pool.gates))
        for bond in bonds
    ]
end


# Generate a complete brick-wall circuit
function generate_brickwall_circuit(
    nqubits::Int,
    nsteps::Int,
    pool::AbstractGatePool;
    rng::Random.AbstractRNG=Random.default_rng()
)
    G = eltype(pool.gates)

    nsteps >= 0 ||
        throw(ArgumentError("Number of timesteps cannot be negative."))

    even_bonds = bond_pairs(nqubits, :even)
    odd_bonds = bond_pairs(nqubits, :odd)

    steps = BrickWallStep{G}[]

    for _ in 1:nsteps

        even_layer = sample_layer(rng, pool, even_bonds)
        odd_layer = sample_layer(rng, pool, odd_bonds)

        push!(
            steps,
            BrickWallStep{G}(even_layer, odd_layer)
        )
    end

    return BrickWallCircuit{G,typeof(pool)}(
        nqubits,
        pool,
        steps
    )
end


# Apply one timestep to a stabilizer state
function apply_timestep!(state, step::BrickWallStep)

    for layer in (step.even, step.odd)
        for application in layer
            QuantumClifford.apply!(
                state,
                collect(application.sites),
                application.gate
            )
        end
    end

    return state
end
