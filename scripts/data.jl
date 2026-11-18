
using CSV
using DataFrames

function save_data_csv(
    result::FermionMIPT.SimulationResult,
    filepath::String
)

    mkpath(dirname(abspath(filepath)))

    metadata = result.metadata
    npoints = length(result.depths)

    df = DataFrame(
        depth=result.depths,
        mean_entropy=result.mean_entropy,
        stderr=result.stderr,
        nqubits=fill(metadata.nqubits, npoints),
        half_chain_size=fill(metadata.half_chain_size, npoints),
        ntraj=fill(metadata.ntraj, npoints),
        seed=fill(metadata.seed, npoints),
        gate_pool=fill(result.pool_type, npoints),
        initial_state=fill(metadata.initial_state, npoints),
        entropy_measure=fill(metadata.entropy_measure, npoints),
        measurement_protocol=fill(metadata.measurement_protocol, npoints),
        completed_steps=fill(metadata.completed_steps, npoints),
        saturated=fill(metadata.saturated, npoints)
    )

    CSV.write(filepath, df)

    println("Simulation data saved to: ", filepath)

    return filepath
end
