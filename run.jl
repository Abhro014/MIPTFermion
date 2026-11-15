
include("src/FermionMIPT.jl")

using .FermionMIPT
using Random

include("scripts/plots.jl")
include("scripts/data.jl")


# --------------------------------------------------
# 1. Load the cached parity-preserving gate pool
# --------------------------------------------------

cache_path = joinpath(
    @__DIR__,
    "data",
    "cache",
    "two_qubit_parity_preserving.jls"
)

parity_gates = load_cache(cache_path).gates

pool = ParityCliffordPool(parity_gates)


# --------------------------------------------------
# 2. Define simulation parameters
# --------------------------------------------------

N = 6                     # N qubits in each half
nqubits = 2 * N

ntraj = 100
max_steps = 500
seed = 1234


# --------------------------------------------------
# 3. Run the ensemble simulation
# --------------------------------------------------

result = ensemble_average(
    pool,
    nqubits;
    ntraj=ntraj,
    max_steps=max_steps,
    seed=seed,
    window=10,
    check_saturation=true
)


# --------------------------------------------------
# 4. Plot and save the results
# --------------------------------------------------

plot_path = joinpath(
    @__DIR__,
    "results",
    "plots",
    "entropy_growth.png"
)

csv_path = joinpath(
    @__DIR__,
    "data",
    "simulations",
    "entropy_growth.csv"
)

make_plot(result; savepath=plot_path)
save_data_csv(result, csv_path)

println("Saturation detected: ", result.saturated)
println("Depth reached: ", result.metadata.completed_steps)
