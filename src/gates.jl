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


# Local Pauli-Z operators, used to test conservation of total occupation.
const _Z1 = S"ZI"
const _Z2 = S"IZ"

"""
    is_number_conserving(gate)

Check whether a two-qubit Clifford gate conserves total particle number.

For two fermionic modes,

    N = (I - Z₁)/2 + (I - Z₂)/2.

A Clifford gate conserves `N` precisely when conjugation either leaves
`Z₁` and `Z₂` individually unchanged or swaps them, with positive signs.

This function is intended for two-qubit Clifford gates represented by
QuantumClifford objects.
"""
function is_number_conserving(gate)
    transformed_z1 = gate * _Z1
    transformed_z2 = gate * _Z2

    fixes_modes =
        transformed_z1 == _Z1 && transformed_z2 == _Z2

    swaps_modes =
        transformed_z1 == _Z2 && transformed_z2 == _Z1

    return fixes_modes || swaps_modes
end

# Jordan-Wigner Majorana operators for two fermionic modes:
# γ₁ = X₁, γ₂ = Y₁, γ₃ = Z₁X₂, γ₄ = Z₁Y₂.
const _TWO_MODE_MAJORANAS = (P"XI", P"YI", P"ZX", P"ZY")

"""
    is_matchgate(gate)

Check whether a two-qubit Clifford gate is a fermionic Gaussian
(matchgate) Clifford.

For a Clifford gate, conjugation maps each Pauli operator to a signed
Pauli operator. The gate is a two-mode matchgate precisely when its
action maps the four Jordan-Wigner Majorana operators to a signed
permutation of those same four operators, and the resulting
orthogonal transformation has determinant +1.

The determinant condition selects SO(4), rather than O(4).

This function is intended for two-qubit Clifford gates represented by
QuantumClifford objects.
"""
function is_matchgate(gate)
    # A matchgate must preserve fermionic parity.
    is_parity_preserving(gate) || return false

    permutation = Vector{Int}(undef, 4)
    signs = Vector{Int}(undef, 4)

    # Determine the signed permutation induced on the Majorana operators.
    for i in eachindex(_TWO_MODE_MAJORANAS)
        # Wrap the Pauli operator in a one-generator Stabilizer.
        majorana_stab = Stabilizer([_TWO_MODE_MAJORANAS[i]])

        # Apply the Clifford gate and extract the resulting Pauli operator.
        image_stab = gate * majorana_stab
        image = image_stab[1]

        found = false

        for j in eachindex(_TWO_MODE_MAJORANAS)
            if image == _TWO_MODE_MAJORANAS[j]
                permutation[i] = j
                signs[i] = 1
                found = true
                break
            elseif image == -_TWO_MODE_MAJORANAS[j]
                permutation[i] = j
                signs[i] = -1
                found = true
                break
            end
        end

        # The image is not one of the four Majorana operators.
        found || return false
    end

    # Conjugation is invertible, but check explicitly that the map is
    # a permutation (not a many-to-one assignment).
    length(unique(permutation)) == 4 || return false

    # Determinant of a signed permutation matrix:
    # det = permutation_sign * product(signs).
    inversion_count = 0
    for i in 1:3
        for j in (i+1):4
            permutation[i] > permutation[j] &&
                (inversion_count += 1)
        end
    end

    permutation_sign = iseven(inversion_count) ? 1 : -1
    transformation_determinant = permutation_sign * prod(signs)

    return transformation_determinant == 1
end

"""
    is_number_conserving_matchgate(gate)

Check whether a two-qubit Clifford gate is a fermionic Gaussian
(matchgate) Clifford that conserves total particle number.
"""
function is_number_conserving_matchgate(gate)
    return is_matchgate(gate) && is_number_conserving(gate)
end