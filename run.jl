
include("src/FermionMIPT.jl")

using .FermionMIPT
using Plots
# using Dates

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

plot_dir = joinpath(
    @__DIR__,
    "results",
    "plots"
)

consolidated_plot_dir = joinpath(
    @__DIR__,
    "results",
    "consolidated_plots"
)

csv_dir = joinpath(
    @__DIR__,
    "results",
    "simulations"
)

for mrate in 0.0:0.01:0.1               # varying rates of measurement

    p = Plots.plot(
        xlabel="Circuit depth (timesteps)",
        ylabel="Half-chain von Neumann entropy (bits)",
        title="Entanglement growth at $(mrate) measurement_rate"
    )

    for N in 5:5:50                     # N qubits in each half

        # simulation parameters
        nqubits = 2 * N
        ntraj = 2000
        max_steps = 10 * nqubits
        seed = 1234 # reproduces the same result for convenience

        # simulation call
        result = FermionMIPT.ensemble_average(
            pool,
            nqubits;
            ntraj=ntraj,
            max_steps=max_steps,
            seed=seed,
            window=10,
            measurement_rate=mrate
        )

        # store results for furthur processing
        global pool_type = string(result.pool_type) # need to put this before inner loop and avoid making a global scope

        plot_path = joinpath(
            plot_dir,
            "entropy_growth_in_$(pool_type)_with_$(nqubits)_qubits_at_$(mrate)_measurement_rate.png"
        )

        csv_path = joinpath(
            csv_dir,
            "entropy_growth_in_$(pool_type)_with_$(nqubits)_qubits_at_$(mrate)_measurement_rate.csv"
        )

        # if a plot is passed then modifies in place, hence avoid saving all
        # plots. But if no plot is passed, then make a new plot and save that
        # by passing the `plot_path` parameter
        # make_plot(result; savepath=plot_path)
        make_plot(result; p=p)
        save_data_csv(result, csv_path)

        # println("Saturation detected: ", result.saturated)
        # println("Depth reached: ", result.metadata.completed_steps)
    end
    display(p)
    savepath = joinpath(
        consolidated_plot_dir,
        "entropy_scaling_in_$(pool_type) at_$(mrate)_measurement_rate.png" # shall throw error if pool_type is not global
    )
    save_plot(p, savepath)
end 