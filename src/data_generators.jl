using NPZ
using Distributions
using LinearAlgebra

function generate_gaussian_data(N::Int64, D::Int64, K::Int64,MixtureVar::Number)
	x = randn(Float32,D,N)
	tpi = rand(Dirichlet(ones(K)))
	tzn = rand(Multinomial(N,tpi))
	tz = zeros(Float32,N)

	tmean = zeros(Float32,D,K)
	tcov = zeros(Float32,D,D,K)

	ind = 1
	println(tzn)
	for i=1:length(tzn)
		indices = ind:ind+tzn[i]-1
		tz[indices] .= i
		tmean[:,i] .= rand(MvNormal(zeros(Float32,D), MixtureVar*Matrix{Float32}(I, D, D)))
		tcov[:,:,i] .= rand(InverseWishart(D+2, Matrix{Float32}(I, D, D)))
		d = MvNormal(tmean[:,i], tcov[:,:,i])
		for j=indices
			x[:,j] = rand(d)
		end
		ind += tzn[i]
	end
	x, tz, tmean, tcov
end


function generate_mnmm_data(N::Int64, D::Int64, K::Int64, trials::Int64)
	clusters = zeros(Float64,D,K)
	x = zeros(Float32,D,N)
	labels = rand(1:K,(N,))
	for i=1:K
		alphas = rand(1:20,(D,))
		alphas[i] = rand(30:100)
		clusters[:,i] = rand(Dirichlet(alphas))
	end
	for i=1:N
		x[:,i] = rand(Multinomial(trials,clusters[:,labels[i]]))
	end
	return x, labels, clusters
end
