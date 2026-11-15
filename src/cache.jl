using Serialization

const project_root = normpath(joinpath(@__DIR__, ".."))
const cache_dir = joinpath(project_root, "data", "cache")


"""
    save_cache(data, filename)

Save data to a cache file.
"""
function save_cache(data, filename)

    mkpath(cache_dir)

    filepath = joinpath(cache_dir, filename)

    open(filepath, "w") do io
        serialize(io, data)
    end

    println("Cache saved to: ", filepath)
    println("====================================================")

    return filepath
end


"""
    load_cache(filename)

Load data from a cache file.
"""
function load_cache(filename)

    filepath = joinpath(cache_dir, filename)

    isfile(filepath) || error("Cache file not found: $filepath")

    return open(deserialize, filepath)
end


"""
    create_clifford_cache()

Generate and cache all two-qubit Clifford gates.

Stores:
- Clifford representatives
- Complete phase-expanded Clifford set
- Generation metadata

The original QuantumClifford objects are retained.
"""
function create_clifford_cache()

    # Generate Clifford gates
    base_cliffords, all_cliffords = generate_two_qubit_cliffords()

    # Prepare metadata
    data = (
        metadata=(
            number_of_qubits=2,
            representative_count=length(base_cliffords),
            phase_expanded_count=length(all_cliffords),
            pauli_phase_variants_included=true,
            global_unitary_phases_enumerated=false,
            generation_method="QuantumClifford.enumerate_cliffords + enumerate_phases"
        ),
        representatives=base_cliffords,
        gates=all_cliffords
    )

    # Save cache
    cache_path = save_cache(
        data,
        "two_qubit_cliffords.jls"
    )

    println()
    println("Clifford enumeration completed successfully.")
    println("Representatives: ", length(base_cliffords))
    println("Full Clifford set: ", length(all_cliffords))
    # println("Cache saved to: ", cache_path)

    return data
end


"""
    create_parity_preserving_cache(gates)

Filter all two-qubit Clifford gates and save only
the parity-preserving gates.
"""
function create_parity_preserving_cache(gates)

    parity_gates = filter(is_parity_preserving, gates)

    data = (
        metadata=(
            number_of_qubits=2,
            parent_cache="two_qubit_cliffords.jls",
            original_gate_count=length(gates),
            parity_preserving_gate_count=length(parity_gates),
            parity_operator="Z ⊗ Z",
            filtering_condition="[U, Z ⊗ Z] = 0"
        ),
        gates=parity_gates
    )

    # Save filtered cache
    cache_path = save_cache(
        data,
        "two_qubit_parity_preserving.jls"
    )


    println("Total gates: ", length(gates))
    println("Parity-preserving gates: ", length(parity_gates))
    # println("Cache saved to: ", cache_path)

    return data
end


"""
    create_number_conserving_cache(gates;
        filename="two_qubit_number_conserving.jls",
        source_cache="two_qubit_parity_preserving.jls")

Filter a supplied parity-preserving gate vector for number-conserving
two-qubit Clifford gates, then save the result.
"""
function create_number_conserving_cache(
    gates::AbstractVector;
    filename="two_qubit_number_conserving.jls",
    source_cache="two_qubit_parity_preserving.jls"
)
    isempty(gates) && throw(ArgumentError("The input gate pool is empty."))

    # all(is_parity_preserving, gates) ||
    #     throw(ArgumentError(
    #         "create_number_conserving_cache expects a parity-preserving gate pool."
    #     ))

    number_conserving_gates = filter(is_number_conserving, gates)

    data = (
        metadata=(
            number_of_qubits=2,
            source_cache=source_cache,
            source_gate_count=length(gates),
            number_conserving_gate_count=length(number_conserving_gates),
            gate_type=string(typeof(first(gates))),
            filter="is_number_conserving",
            conserved_quantity="N = (I - Z₁)/2 + (I - Z₂)/2",
            filtering_condition="U (Z₁ + Z₂) U† = Z₁ + Z₂"
        ),
        gates=number_conserving_gates
    )

    save_cache(data, filename)

    println("Input parity-preserving gates: ", length(gates))
    println("Number-conserving gates: ", length(number_conserving_gates))

    return data
end


"""
    create_matchgate_cache(gates;
        filename="two_qubit_matchgates.jls",
        source_cache="two_qubit_parity_preserving.jls")

Filter a supplied parity-preserving gate vector for two-mode matchgate
Cliffords, then save the result.
"""
function create_matchgate_cache(
    gates::AbstractVector;
    filename="two_qubit_matchgates.jls",
    source_cache="two_qubit_parity_preserving.jls"
)
    isempty(gates) && throw(ArgumentError("The input gate pool is empty."))

    # all(is_parity_preserving, gates) ||
    #     throw(ArgumentError(
    #         "create_matchgate_cache expects a parity-preserving gate pool."
    #     ))

    matchgate_gates = filter(is_matchgate, gates)

    data = (
        metadata=(
            number_of_qubits=2,
            source_cache=source_cache,
            source_gate_count=length(gates),
            matchgate_gate_count=length(matchgate_gates),
            gate_type=string(typeof(first(gates))),
            filter="is_matchgate",
            majorana_operators=("X₁", "Y₁", "Z₁X₂", "Z₁Y₂"),
            filtering_condition="Majoranas map to a signed permutation with determinant +1"
        ),
        gates=matchgate_gates
    )

    save_cache(data, filename)

    println("Input parity-preserving gates: ", length(gates))
    println("Matchgate Clifford gates: ", length(matchgate_gates))

    return data
end


function create_number_conserving_matchgate_cache(gates::AbstractVector)
    
    isempty(gates) && throw(ArgumentError("The input gate pool is empty."))

    number_conserving_matchgates = filter(is_number_conserving_matchgate, gates)

    data = (
        metadata=(
            number_of_qubits=2,
            source_gate_count=length(gates),
            number_conserving_matchgate_count=length(number_conserving_matchgates),
            gate_type=string(typeof(first(gates))),
            filter="is_number_conserving_matchgate",
            filtering_condition="Number conservation and Gaussianity"
        ),
        gates=number_conserving_matchgates
    )

    saved_file = save_cache(data, "two_qubit_number_conserving_matchgates.jls")

    println("File saved to: ", saved_file)
    println("Filtered gates: ", length(number_conserving_matchgates))

    return data

end