
# using Plots
function save_plot(
    p::Plots.Plot,
    savepath::String
)
    mkpath(dirname(abspath(savepath)))
    savefig(p, savepath)
    println("Plot is saved to: ", savepath)

end



function make_plot(
    result::FermionMIPT.SimulationResult;
    savepath::Union{Nothing,String}=nothing,
    p::Plots.Plot
)


    if p === nothing
        p = Plots.plot(
            result.depths,
            result.mean_entropy;
            # ribbon=result.stderr,
            xlabel="Circuit depth (timesteps)",
            ylabel="Half-chain von Neumann entropy (bits)",
            title="Entanglement growth at $(result.metadata.measurement_rate) rate of measurements for $(result.metadata.nqubits) qubits",
            label="Ensemble average",
            linewidth=2,
            legend=:bottomright
        )
    else
        Plots.plot!(
            p,
            result.depths,
            result.mean_entropy;
            label="N=$(result.metadata.nqubits)",
            linewidth=2
        )
    end

    if savepath !== nothing
        save_plot(p, savepath)
    end

    return p
end
