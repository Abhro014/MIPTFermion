include("src/FermionMIPT.jl")

using .FermionMIPT



# cliffords = FermionMIPT.create_clifford_cache()

# gates = cliffords.gates

# parity_cliffords = FermionMIPT.create_parity_preserving_cache(gates)

gates = FermionMIPT.load_cache("two_qubit_parity_preserving.jls").gates

# number_cliffords = FermionMIPT.create_number_conserving_cache(gates)

matchgate_cliffords = FermionMIPT.create_matchgate_cache(
    gates; 
    filename="two_qubit_matchgates.jls"
)

number_conserving_matchgate_cliffords = FermionMIPT.create_number_conserving_matchgate_cache(
    matchgate_cliffords.gates
)