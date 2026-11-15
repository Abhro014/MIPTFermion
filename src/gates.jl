using QuantumClifford


function generate_two_qubit_cliffords()
    println("Enumerating two-qubit Clifford representatives...")

    # Stage 1: Clifford operations modulo Pauli phases
    base_cliffords = collect(QuantumClifford.enumerate_cliffords(2))

    expected_base_count = 720
    @assert length(base_cliffords) == expected_base_count """
    Unexpected number of Clifford representatives:
    expected $expected_base_count, got $(length(base_cliffords))
    """

    println("  Representatives generated: ", length(base_cliffords))

    # Stage 2: Expand all Pauli-sign variants
    println("Expanding Pauli phase variants...")

    all_cliffords = collect(
        QuantumClifford.enumerate_phases(base_cliffords)
    )

    expected_full_count = 11520
    @assert length(all_cliffords) == expected_full_count """
    Unexpected number of phase-expanded Clifford operators:
    expected $expected_full_count, got $(length(all_cliffords))
    """

    println("  Phase-expanded operators: ", length(all_cliffords))

    return base_cliffords, all_cliffords
end


const parity = S"ZZ"
"""
    is_parity_preserving(gate)

Check whether a two-qubit Clifford gate preserves fermionic parity.

A gate is parity preserving if:

    U * (Z ⊗ Z) * U† = Z ⊗ Z

Returns true if parity is preserved, false otherwise.
    """
function is_parity_preserving(gate)
    return gate * parity == parity
end


