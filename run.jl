
include("src/FermionMIPT.jl")

using .FermionMIPT
using Plots
using QuantumClifford
# using Dates

include("scripts/plots.jl")
include("scripts/data.jl")


# --------------------------------------------------
# 1. Load the cached gate pool
# --------------------------------------------------
clifford_paritygates = let
    cached = try
        FermionMIPT.load_cache("two_qubit_parity_preserving.jls").gates
    catch
        nothing
    end
    if isnothing(cached) || isempty(cached)
        filter(is_parity_preserving,
            collect(QuantumClifford.enumerate_phases(
                QuantumClifford.enumerate_cliffords(2))))
    else
        cached
    end
end


clifford_matchgates = let
    cached = try
        FermionMIPT.load_cache("two_qubit_matchgates.jls").gates
    catch
        nothing
    end
    if isnothing(cached) || isempty(cached)
        filter(is_matchgate,
            collect(QuantumClifford.enumerate_phases(
                QuantumClifford.enumerate_cliffords(2))))
    else
        cached
    end
end


parity_clifford_pool = FermionMIPT.ParityCliffordPool(clifford_paritygates)
matchgate_clifford_pool = FermionMIPT.MatchgateCliffordPool(clifford_matchgates)


# for pool in [parity_clifford_pool, matchgate_clifford_pool]
    # @show typeof(pool)
    # @show typeof(pool) <: FermionMIPT.AbstractGatePool
    # @show methods(FermionMIPT.ensemble_average)
# end

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

for pool in [parity_clifford_pool, matchgate_clifford_pool]

    for mrate in 0.0:0.02:0.16               # varying rates of measurement

        p = Plots.plot(
            xlabel="Circuit depth (timesteps)",
            ylabel="Half-chain von Neumann entropy (bits)",
            title="Entanglement growth at $(mrate) measurement_rate"
        )

        for N in 5:5:60                     # N qubits in each half

            # simulation parameters
            nqubits = 2 * N
            ntraj = 2000
            max_steps = 10 * nqubits
            seed = 1234 # reproduces the same result for convenience

            # simulation call
            result = FermionMIPT.ensemble_average(
                matchgate_clifford_pool,
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

end