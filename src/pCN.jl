# Preconditioned Crank–Nicolson algorithm tools
"""
    pCN!(noise::AbstractNoiseProcess, ρ; reset=true,reverse=false,indx=nothing)

Create a new, but correlated noise process from `noise` and additional entropy with correlation ρ.
This update defines an autoregressive process in the space of Wiener (or noise process) trajectories which can be used as proposal distribution in Metropolis-Hastings algorithms (often called "preconditioned Crank–Nicolson scheme".)

External links
 * [Preconditioned Crank–Nicolson algorithm on Wikipedia](https://en.wikipedia.org/wiki/Preconditioned_Crank–Nicolson_algorithm)
"""
function pCN!(source::AbstractNoiseProcess{T,N,Vector{T2},inplace}, ρ;
              reset=true,reverse=false,indx=nothing) where {T,N,T2,inplace}

  # generate new Wiener process similar to the one in source
  t = source.t
  if typeof(source.W[1]) <: Number
    Wnew = cumsum([zero(source.W[1]);[sqrt.(t[i+1]-ti).*wiener_randn(source.rng,typeof(source.W[i]))
              for (i,ti) in enumerate(t[1:end-1])]])
  else
    Wnew = cumsum([[zero(source.W[1])];[sqrt.(t[i+1]-ti).*wiener_randn(source.rng,source.W[i])
              for (i,ti) in enumerate(t[1:end-1])]])
  end

  source.W = ρ * source.W + sqrt(one(ρ)-ρ^2) * Wnew
  source.W = ρ * source.u + sqrt(one(ρ)-ρ^2) * Wnew
  NoiseWrapper(source,reset=reset,reverse=reverse,indx=indx)
end


"""
    pCN(noise::AbstractNoiseProcess, ρ; reset=true,reverse=false,indx=nothing)

Create a new, but correlated noise process from `noise` and additional entropy with correlation ρ.
"""
function pCN(source::AbstractNoiseProcess{T,N,Vector{T2},inplace}, ρ;
              reset=true,reverse=false,indx=nothing) where {T,N,T2,inplace}

  source′ = deepcopy(source)

  # generate new Wiener process similar to the one in source
  t = source′.t
  if typeof(source′.W[1]) <: Number
    Wnew = cumsum([zero(source′.W[1]);[sqrt.(t[i+1]-ti).*wiener_randn(source′.rng,typeof(source′.W[i]))
              for (i,ti) in enumerate(t[1:end-1])]])
  else
    Wnew = cumsum([[zero(source′.W[1])];[sqrt.(t[i+1]-ti).*wiener_randn(source′.rng,source′.W[i])
              for (i,ti) in enumerate(t[1:end-1])]])
  end

  source′.W = ρ * source′.W + sqrt(one(ρ)-ρ^2) * Wnew
  source′.W = ρ * source′.u + sqrt(one(ρ)-ρ^2) * Wnew
  NoiseWrapper(source′,reset=reset,reverse=reverse,indx=indx)
end
