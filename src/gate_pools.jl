# Gate-pool hierarchy
abstract type AbstractGatePool end

struct ParityCliffordPool{G} <: AbstractGatePool
    gates::Vector{G}

    function ParityCliffordPool(gates::Vector{G}) where {G}
        isempty(gates) && throw(ArgumentError("Gate pool cannot be empty."))

        all(is_parity_preserving, gates) ||
            throw(ArgumentError("The pool contains a non-parity-preserving gate."))

        new{G}(gates)
    end
end

struct NumberConservingCliffordPool{G} <: AbstractGatePool
    gates::Vector{G}

    function NumberConservingCliffordPool(gates::Vector{G}) where {G}
        isempty(gates) && throw(ArgumentError("Gate pool cannot be empty."))

        all(is_number_conserving, gates) ||
            throw(ArgumentError("The pool contains a non-number-conserving gate."))

        new{G}(gates)
    end
end


struct MatchgateCliffordPool{G} <: AbstractGatePool
    gates::Vector{G}

    function MatchgateCliffordPool(gates::Vector{G}) where {G}
        isempty(gates) && throw(ArgumentError("Gate pool cannot be empty."))

        all(is_matchgate, gates) ||
            throw(ArgumentError("The pool contains a non-matchgate gate."))

        new{G}(gates)
    end
end