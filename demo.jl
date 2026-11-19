include("src/FermionMIPT.jl")
using .FermionMIPT



# cliffords = FermionMIPT.create_clifford_cache()
# clifford_gates = cliffords.gates

# parity_cliffords = FermionMIPT.create_parity_preserving_cache(gates)
parity_gates = FermionMIPT.load_cache("two_qubit_parity_preserving.jls").gates

# matchgate_cliffords = FermionMIPT.create_matchgate_cache(
#     gates; 
#     filename="two_qubit_matchgates.jls"
# )
clifford_matchgates = FermionMIPT.load_cache("two_qubit_matchgates.jls").gates

# number_cliffords = FermionMIPT.create_number_conserving_cache(gates)
number_gates = FermionMIPT.load_cache("two_qubit_number_conserving.jls").gates

# ncons_matchgate_cliffords = FermionMIPT.create_number_conserving_matchgate_cache(clifford_matchgates)
ncons_clifford_matchgates = FermionMIPT.load_cache("two_qubit_number_conserving_matchgates.jls").gates

println("=========================")
println("Number of parity preserving Clifford gates: ", length(parity_gates))
println("====================")
println("Number of matchgate Clifford gates: ", length(clifford_matchgates))
println("====================")
println("Number of number preserving Clifford gates: ", length(number_gates))
println("====================")
println("Number of number preserving matchgate Clifford gates: ", length(ncons_clifford_matchgates))
