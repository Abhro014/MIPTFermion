include("src/FermionMIPT.jl")

using .FermionMIPT



cliffords = FermionMIPT.create_clifford_cache()

gates = cliffords.gates

parity_cliffords = FermionMIPT.create_parity_preserving_cache(gates)