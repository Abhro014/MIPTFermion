
using CSV
using DataFrames
using LinearAlgebra
using Statistics
using LsqFit
using Plots


const DATA_DIR = joinpath(@__DIR__, "results", "simulations")

const PLOT_DIR = joinpath(@__DIR__, "results", "fits")




"""
    load_simulation_data(pool_type, measurement_rate)

Load simulation data for a given pool type and measurement rate.
"""
function load_simulation_data(pool_type, measurement_rate)
    prefix = "entropy_growth_in_$(pool_type)_with_"
    suffix = "_at_$(measurement_rate)_measurement_rate.csv"

    files = filter(readdir(DATA_DIR)) do file
        startswith(file, prefix) && endswith(file, suffix)
    end

    isempty(files) && error(
        "No files found for pool=$pool_type, measurement_rate=$measurement_rate"
    )

    return [CSV.read(joinpath(DATA_DIR, file), DataFrame) for file in files]
end


"""
    steady_state_average(df; fraction=0.20)

extracts average value of steady state entropy
The simulations are ran for 10*nqubits depth while
5*nqubits depth is enough to reach a steady state
However, we need to be careful as a larger window may 
contain values outside of steady state and cause errors
"""
function steady_state_average(df; fraction=0.20)
    
    nrows = nrow(df)

    nrows > 0 || error("Empty CSV file")
    0 < fraction <= 1 || throw(ArgumentError("fraction must be in (0, 1]"))

    start_index = max(1, floor(Int, (1 - fraction) * nrows) + 1)

    tail = df[start_index:end, :]

    entropy = mean(tail.mean_entropy)

    qubit_values = unique(df.nqubits)
    length(qubit_values) == 1 ||
        error("Expected one system size per CSV file")

    return (
        nqubits=only(qubit_values),
        mean_entropy=entropy
    )
end

# process a simulation output for a given pool of
# gates at a fixed measurement rate
function process_measurement_rate(pool_type, measurement_rate; fraction=0.25)
    dfs = load_simulation_data(pool_type, measurement_rate)

    results = [
        steady_state_average(df; fraction=fraction)
        for df in dfs
    ]

    data = DataFrame(results)

    sort!(data, :nqubits)

    return data
end


# fit functions
function linear_fit(x, y)
    X = hcat(ones(length(x)), x)
    
    coefficients = X \ y
    
    y_fit = X * coefficients
    
    ss_res = sum((y .- y_fit) .^ 2)
    ss_tot = sum((y .- mean(y)) .^ 2)
    
    r2 = ss_tot == 0 ? NaN : 1 - ss_res / ss_tot
    
    return (
        intercept=coefficients[1],
        slope=coefficients[2],
        r2=r2,
        fitted_values=y_fit
        )
end
    
function fit_entropy(data)
    N = Float64.(data.nqubits)
    S = Float64.(data.mean_entropy)

    all(N .> 0) || error("System sizes must be positive")
    all(S .> 0) || error("Power-law fitting requires positive entropy")

    # Power-law fit: log(S) = log(A) + alpha*log(N)
    power_fit = linear_fit(log.(N), log.(S))
    
    A = exp(power_fit.intercept)
    alpha = power_fit.slope
    
    # Logarithmic fit: S = a*log(N) + b
    log_fit = linear_fit(log.(N), S)

    return (
        A=A,
        alpha=alpha,
        power_r2=power_fit.r2,
        power_values=A .* N .^ alpha,
        a=log_fit.slope,
        b=log_fit.intercept,
        log_r2=log_fit.r2,
        log_values=log_fit.fitted_values
        )
end
    


# plotting function
function plot_entropy_scaling(data, measurement_rate, fit, pool_type; path)
    p = plot(
        data.nqubits,
        data.mean_entropy;
        marker=:circle,
        linewidth=2,
        xlabel="Number of qubits (N)",
        ylabel="Mean entropy",
        title="Gate Pool = $(pool_type)\nMeasurement rate = $(measurement_rate)",
        label="$(fit.alpha)",
        legend=:topleft
    )
    
    x = data.nqubits
    y = fit.A * x.^fit.alpha
    plot!(p, x, y)

    if path !== nothing
        filename = "entropy_scaling_in_$(pool_type)_for_$(measurement_rate)_rate_of_measurements.png"
        savepath = joinpath(path, filename)
        mkpath(dirname(abspath(savepath)))
        savefig(p, savepath)
        println("Plot is saved to: ", savepath)
    end

    return p
end


pools = ["MatchgateCliffordPool", "ParityCliffordPool"]

for pool_type in pools
    lalphas = []
    mrate = 0.0:0.05:0.3
    for m in mrate  

        data = process_measurement_rate(pool_type, m)

        fit = fit_entropy(data)
        push!(lalphas, fit.alpha)
        println("Power-law fit:")
        println("A = ", fit.A)
        println("alpha = ", fit.alpha)
        println("R² = ", fit.power_r2)
        
        println("\nLogarithmic fit:")
        println("a = ", fit.a)
        println("b = ", fit.b)
        println("R² = ", fit.log_r2)
        
        p=plot_entropy_scaling(data, m, fit=fit, pool_type; path=PLOT_DIR)
        display(p)

    end

    p=plot(mrate, lalphas; marker=:circle,
        linewidth=2,
        xlabel="Measurement rate",
        ylabel="Power law coefficient",
        title="Entanglement scaling in $(pool_type) Circuit"
        )

end