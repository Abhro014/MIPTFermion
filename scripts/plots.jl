
using Plots

function make_plot(
    result::SimulationResult;
    savepath::Union{Nothing,String}=nothing
)

    p = plot(
        result.depths,
        result.mean_entropy;
        ribbon=result.stderr,
        xlabel="Circuit depth (timesteps)",
        ylabel="Half-chain von Neumann entropy (bits)",
        title="Entanglement growth",
        label="Ensemble average",
        linewidth=2,
        legend=:bottomright
    )

    if savepath !== nothing
        mkpath(dirname(abspath(savepath)))
        savefig(p, savepath)
    end

    return p
end
