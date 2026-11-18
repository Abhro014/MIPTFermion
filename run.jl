
include("src/FermionMIPT.jl")

using .FermionMIPT
using Dates

include("scripts/plots.jl")
include("scripts/data.jl")


# --------------------------------------------------
# 1. Load the cached gate pool
# --------------------------------------------------
match_gates = FermionMIPT.load_cache("two_qubit_matchgates.jls").gates 

pool = FermionMIPT.MatchgateCliffordPool(match_gates)


# @show typeof(pool)
# @show typeof(pool) <: FermionMIPT.AbstractGatePool
# @show methods(FermionMIPT.ensemble_average)

# --------------------------------------------------
# 2. Define simulation parameters
# --------------------------------------------------

N = 13                     # N qubits in each half
nqubits = 2 * N

ntraj = 1000
max_steps = 10 * nqubits
seed = 1234


# --------------------------------------------------
# 3. Run the ensemble simulation
# --------------------------------------------------

result = FermionMIPT.ensemble_average(
    pool,
    nqubits;
    ntraj=ntraj,
    max_steps=max_steps,
    seed=seed,
    window=10,
    measurement_rate=0.2
)

timestamp = Dates.format(now(), "yyyymmdd_HHmmss")
pool_type = string(result.pool_type)

# --------------------------------------------------
# 4. Plot and save the results
# --------------------------------------------------

plot_path = joinpath(
    @__DIR__,
    "results",
    "plots",
    "entropy_growth_in_$(pool_type)_$(timestamp)_$(nqubits)qubits_$(ntraj)traj_$(result.metadata.completed_steps)depth.png"
)

csv_path = joinpath(
    @__DIR__,
    "results",
    "simulations",
    "entropy_growth_in_$(pool_type)_$(timestamp)_$(nqubits)qubits_$(ntraj)traj_$(result.metadata.completed_steps)depth.csv"
)

make_plot(result; savepath=plot_path)
save_data_csv(result, csv_path)

# println("Saturation detected: ", result.saturated)
println("Depth reached: ", result.metadata.completed_steps)
