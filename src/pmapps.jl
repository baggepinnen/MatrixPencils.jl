"""
    pmkstruct(P; CF1, grade=l, fast = false, atol::Real = 0, rtol::Real = atol>0 ? 0 : n*ϵ) -> KRInfo
  
Determine the Kronecker-structure information of the polynomial matrix `P(λ)` and return an `KRInfo` object. 
The computation of the Kronecker-structure employs strong linearizations of `P(λ)`in either 
the first companion form, if `CF1 = true`, or the second companion form, if `CF1 = false`. 
The effective grade `l` to be used for linearization can be specified via the keyword argument `grade` as 
`grade = l`, where `l` must be chosen equal to or greater than the degree of `P(λ)`.

`P(λ)` can be specified as a grade `k` polynomial matrix of the form `P(λ) = P_1 + λ P_2 + ... + λ**k P_(k+1)`, 
for which the coefficient matrices `P_i`, `i = 1, ..., k+1`, are stored in the 3-dimensional matrix `P`, 
where `P[:,:,i] contains the `i`-th coefficient matrix `P_i` (multiplying `λ**(i-1)`). 

`P(λ)` can also be specified as a matrix, vector or scalar of elements of the `Polynomial` type 
provided by the [Polynomials](https://github.com/JuliaMath/Polynomials.jl) package.   

The right Kronecker indices `rki`, left Kronecker indices `lki`, infinite elementary divisors `id` and the
number of finite eigenvalues `nf` can be obtained from `KRInfo` as `KRInfo.rki`, `KRInfo.lki`, `KRInfo.id` 
and `KRInfo.nf`, respectively.  
The determination of the Kronecker-structure information is performed by building a companion 
form linearization `M-λN` of `P(λ)` and reducing the pencil `M-λN` to an 
appropriate Kronecker-like form (KLF) exhibiting all structural elements of the pencil `M-λN`.
The Kronecker-structure information on `P(λ)` are recovered from the Kronecker-structure information
on `M-λN` using the results of [1].

The right Kronecker indices are provided in the integer vector `rki`, where each `i`-th element `rki[i]` is 
the column dimension `k` of an elementary Kronecker block of size `(k-1) x k`. 
The number of elements of `rki` is the dimension of the right nullspace of the polynomial matrix `P(λ)` 
and their sum is the least degree of a right polynomial nullspace basis. 

The left Kronecker indices are provided in the integer vector `lki`, where each `i`-th element `lki[i]` is 
the row dimension `k` of an elementary Kronecker block of size `k x (k-1)`. 
The number of elements of `lki` is the dimension of the left nullspace of the polynomial matrix `P(λ)` 
and their sum is the least degree of a left polynomial nullspace basis. 

The multiplicities of infinite eigenvalues are provided in the integer vector `id`, 
where each `i`-th element `id[i]` is the order of an infinite elementary divisor 
(i.e., the multiplicity of an infinite eigenvalue).   

The reduction is performed using orthogonal similarity transformations and involves rank decisions based 
on rank reevealing QR-decompositions with column pivoting, if `fast = true`, or, the more reliable, 
SVD-decompositions, if `fast = false`. 

The keyword arguments `atol`  and `rtol` specify the absolute and relative tolerances for the nonzero 
coefficients of `P(λ)`,  respectively. 
The default relative tolerance is `n*ϵ`, where `n` is the size of the smallest dimension of `P(λ)`, and `ϵ` is the 
machine epsilon of the element type of coefficients of `P(λ)`. 

[1] F. De Terán, F. M. Dopico, D. S. Mackey, Spectral equivalence of polynomial matrices and
the Index Sum Theorem, Linear Algebra and Its Applications, vol. 459, pp. 264-333, 2014.
"""
function pmkstruct(P::AbstractArray{T,3}; CF1::Bool = size(P,1) <= size(P,2) ? false : true, 
                   grade::Int = pmdeg(P), fast::Bool = false, atol::Real = zero(real(T)), 
                   rtol::Real = (min(size(P)...)*eps(real(float(one(T)))))*iszero(atol)) where T
   if CF1
      M, N = pm2lpCF1(P, grade = grade)
      val, kinfo = peigvals(M, N, fast = fast, atol1 = atol, atol2 = atol, rtol = rtol) 
      kinfo.rki == [] || (grade > 1 && (kinfo.rki .-= grade-1))
   else
      M, N = pm2lpCF2(P, grade = grade)
      val, kinfo = peigvals(M, N, fast = fast, atol1 = atol, atol2 = atol, rtol = rtol) 
      kinfo.lki == [] || (grade > 1 && (kinfo.lki .-= grade-1))
   end
   return kinfo
end 
pmkstruct(P::Union{AbstractVecOrMat{Polynomial{T}},Polynomial{T},Number}; kwargs...) where {T} =
          pmkstruct(poly2pm(P); kwargs...)
"""
    pmeigvals(P; CF1, grade = l, fast = false, atol::Real = 0, rtol::Real = atol>0 ? 0 : n*ϵ) -> (val, KRInfo)

Return the finite and infinite eigenvalues of the polynomial matrix `P(λ)` in `val`, 
and  the information on the complete Kronecker-structure of `P(λ)` in the `KRInfo` object. 
The computation of eigenvalues and Kronecker-structure employs strong linearizations of `P(λ)`in either 
the first companion form, if `CF1 = true`, or the second companion form, if `CF1 = false`. 
The effective grade `l` to be used for linearization can be specified via the keyword argument `grade` as 
`grade = l`, where `l` must be chosen equal to or greater than the degree of `P(λ)`.

`P(λ)` can be specified as a grade `k` polynomial matrix of the form `P(λ) = P_1 + λ P_2 + ... + λ**k P_(k+1)`, 
for which the coefficient matrices `P_i`, `i = 1, ..., k+1`, are stored in the 3-dimensional matrix `P`, 
where `P[:,:,i] contains the `i`-th coefficient matrix `P_i` (multiplying `λ**(i-1)`). 

`P(λ)` can also be specified as a matrix, vector or scalar of elements of the `Polynomial` type 
provided by the [Polynomials](https://github.com/JuliaMath/Polynomials.jl) package.   

The information on the complete Kronecker-structure consists of the right Kronecker indices `rki`, 
left Kronecker indices `lki`, infinite elementary divisors `id` and the
number of finite eigenvalues `nf`, and can be obtained from `KRInfo` as `KRInfo.rki`, `KRInfo.lki`, `KRInfo.id` 
and `KRInfo.nf`, respectively. For more details, see  [`pkstruct`](@ref). 

The computation of the eigenvalues is performed by building the companion form based linearization `M-λN` 
of the polynomial matrix `P(λ)` and then reducing the pencil `M-λN` to an appropriate Kronecker-like form (KLF) 
exhibiting its full Kronecker structure (i.e., number of finite eigenvalues, multiplicities of the infinite eigenvalues, 
left and right Kronecker indices). 
The left and right Kronecker indices of `P(λ)` are returned in `KRInfo.rki` and `KRInfo.rki`, respectively, and 
their values are recovered from the left and right Kronecker indices of `M-λN` using the results of [1].
The multiplicities of the infinite eigenvalues of `P(λ)` is returned in `KRInfo.id`. 
The number of finite eigenvalues in `val` is equal to the number of finite eigenvalues of `M-λN` (returned in `KRInfo.nf`), 
while the number of infinite eigenvalues in `val` is the sum of multiplicites returned in `KRInfo.id`. 

The reduction of `M-λN` to the KLF is performed using orthonal similarity transformations and involves rank decisions based on rank reevealing QR-decompositions with column pivoting, 
if `fast = true`, or, the more reliable, SVD-decompositions, if `fast = false`. For efficiency purposes, the reduction is only
partially performed, without accumulating the performed orthogonal transformations.

The keyword arguments `atol`  and `rtol` specify the absolute and relative tolerances for the nonzero 
coefficients of `P(λ)`,  respectively. 
The default relative tolerance is `n*ϵ`, where `n` is the size of the smallest dimension of `P(λ)`, and `ϵ` is the 
machine epsilon of the element type of coefficients of `P(λ)`. 

[1] F. De Terán, F. M. Dopico, D. S. Mackey, Spectral equivalence of polynomial matrices and
the Index Sum Theorem, Linear Algebra and Its Applications, vol. 459, pp. 264-333, 2014.
"""
function pmeigvals(P::AbstractArray{T,3}; CF1::Bool = size(P,1) <= size(P,2) ? false : true, 
                   grade::Int = pmdeg(P), fast::Bool = false, atol::Real = zero(real(T)), 
                   rtol::Real = (min(size(P)...)*eps(real(float(one(T)))))*iszero(atol)) where T 
   if CF1
      M, N = pm2lpCF1(P, grade = grade)
      val, kinfo = peigvals(M, N, fast = fast, atol1 = atol, atol2 = atol, rtol = rtol) 
      kinfo.rki == [] || (grade > 1 && (kinfo.rki .-= grade-1))
   else
      M, N = pm2lpCF2(P, grade = grade)
      val, kinfo = peigvals(M, N, fast = fast, atol1 = atol, atol2 = atol, rtol = rtol) 
      kinfo.lki == [] || (grade > 1 && (kinfo.lki .-= grade-1))
   end
   return val, kinfo
end
pmeigvals(P::Union{AbstractVecOrMat{Polynomial{T}},Polynomial{T},Number}; kwargs...) where {T} =
          pmeigvals(poly2pm(P); kwargs...)
"""
    pmzeros(P; CF1, fast = false, atol::Real = 0, rtol::Real = atol>0 ? 0 : n*ϵ) -> (val, iz, KRInfo)

Return the finite and infinite zeros of the polynomial matrix `P(λ)` in `val`, 
the multiplicities of infinite zeros in `iz` and  the 
information on the complete Kronecker-structure of `P(λ)` in the `KRInfo` object. 
The computation of zeros and Kronecker-structure employs strong linearizations of `P(λ)` in either 
the first companion form, if `CF1 = true`, or the second companion form, if `CF1 = false`. 

`P(λ)` can be specified as a grade `k` polynomial matrix of the form `P(λ) = P_1 + λ P_2 + ... + λ**k P_(k+1)`, 
for which the coefficient matrices `P_i`, `i = 1, ..., k+1`, are stored in the 3-dimensional matrix `P`, 
where `P[:,:,i] contains the `i`-th coefficient matrix `P_i` (multiplying `λ**(i-1)`). 

`P(λ)` can also be specified as a matrix, vector or scalar of elements of the `Polynomial` type 
provided by the [Polynomials](https://github.com/JuliaMath/Polynomials.jl) package.   

The information on the complete Kronecker-structure consists of the right Kronecker indices `rki`, left Kronecker indices `lki`, 
infinite elementary divisors `id` and the
number of finite eigenvalues `nf`, and can be obtained from `KRInfo` as `KRInfo.rki`, `KRInfo.lki`, `KRInfo.id` 
and `KRInfo.nf`, respectively. For more details, see  [`pkstruct`](@ref). 

The computation of the zeros is performed by building the companion form based linearization `M-λN` 
of the polynomial matrix `P(λ)` and then reducing the pencil `M-λN` to an appropriate Kronecker-like form (KLF) 
exhibiting its full Kronecker structure (i.e., number of finite eigenvalues, multiplicities of the infinite eigenvalues, 
left and right Kronecker indices). 
The left and right Kronecker indices of `P(λ)` are returned in `KRInfo.rki` and `KRInfo.rki`, respectively, and 
their values are recovered from the left and right Kronecker indices of `M-λN` using the results of [1].
The multiplicities of the infinite zeros of `P(λ)` returned in `iz` are the positive differences between the multiplicities of 
the infinite eigenvalues of `M-λN` and the degree of `P(λ)` [2]. 
The number of finite zeros in `val` is equal to the number of finite eigenvalues of `M-λN` (returned in `KRInfo.nf`), 
while the number of infinite zeros in `val` is the sum of multiplicites in `iz`. 

The reduction of `M-λN` to the KLF is performed using orthonal similarity transformations and involves rank decisions based on rank reevealing QR-decompositions with column pivoting, 
if `fast = true`, or, the more reliable, SVD-decompositions, if `fast = false`. For efficiency purposes, the reduction is only
partially performed, without accumulating the performed orthogonal transformations.

The keyword arguments `atol`  and `rtol` specify the absolute and relative tolerances for the nonzero 
coefficients of `P(λ)`,  respectively. 
The default relative tolerance is `n*ϵ`, where `n` is the size of the smallest dimension of `P(λ)`, and `ϵ` is the 
machine epsilon of the element type of coefficients of `P(λ)`. 

[1] F. De Terán, F. M. Dopico, D. S. Mackey, Spectral equivalence of polynomial matrices and
the Index Sum Theorem, Linear Algebra and Its Applications, vol. 459, pp. 264-333, 2014.

[2] P. Van Dooren, Private communications, April 2020.
"""
function pmzeros(P::AbstractArray{T,3}; CF1::Bool = size(P,1) <= size(P,2) ? false : true, 
                 fast = false, atol::Real = zero(real(T)), 
                 rtol::Real = (min(size(P)...)*eps(real(float(one(T)))))*iszero(atol)) where T 
   d = pmdeg(P)
   if CF1
      M, N = pm2lpCF1(P)
      val, iz, kinfo = pzeros(M, N, fast = fast, atol1 = atol, atol2 = atol, rtol = rtol) 
      kinfo.rki == [] || d <= 1 || (kinfo.rki .-= d-1)
   else
      M, N = pm2lpCF2(P)
      val, iz, kinfo = pzeros(M, N, fast = fast, atol1 = atol, atol2 = atol, rtol = rtol) 
      kinfo.lki == [] || d <= 1 || (kinfo.lki .-= d-1)
   end
   if iz !== [] && d > 1 
      iz = iz[iz.>d] .- (d-1)
      val = [val[1:kinfo.nf]; Inf*ones(real(T),sum(iz))]
   end 
   return val, iz, kinfo
end
pmzeros(P::Union{AbstractVecOrMat{Polynomial{T}},Polynomial{T},Number}; kwargs...) where {T} =
       pmzeros(poly2pm(P); kwargs...)
"""
    pmpoles(P; CF1, fast = false, atol::Real = 0, rtol::Real = atol>0 ? 0 : n*ϵ) -> (val, ip, KRInfo)
   
Return the finite and infinite poles of the polynomial matrix `P(λ)` in `val`, 
the multiplicities of infinite poles in `ip` and  the information on the complete Kronecker-structure 
of `Q(λ) = [P(λ) I; I 0]` in the `KRInfo` object. 
The computation of poles and Kronecker-structure employs strong linearizations of `Q(λ)` in either 
the first companion form, if `CF1 = true`, or the second companion form, if `CF1 = false`. 

`P(λ)` can be specified as a grade `k` polynomial matrix of the form `P(λ) = P_1 + λ P_2 + ... + λ**k P_(k+1)`, 
for which the coefficient matrices `P_i`, `i = 1, ..., k+1`, are stored in the 3-dimensional matrix `P`, 
where `P[:,:,i] contains the `i`-th coefficient matrix `P_i` (multiplying `λ**(i-1)`). 

`P(λ)` can also be specified as a matrix, vector or scalar of elements of the `Polynomial` type 
provided by the [Polynomials](https://github.com/JuliaMath/Polynomials.jl) package.   

The information on the complete Kronecker-structure consists of the right Kronecker indices `rki`, left Kronecker indices `lki`, 
infinite elementary divisors `id` and the number of finite eigenvalues `nf`, and can be obtained 
from `KRInfo` as `KRInfo.rki`, `KRInfo.lki`, `KRInfo.id` and `KRInfo.nf`, respectively. 
For more details, see  [`pkstruct`](@ref). 

The computation of the poles is performed by building the companion form based linearization `M-λN` 
of the extended polynomial matrix `Q(λ) = [P(λ) I; I 0]` (see [1]) and then reducing the pencil `M-λN` to an appropriate 
Kronecker-like form (KLF) exhibiting its full Kronecker structure (i.e., number of finite eigenvalues, 
multiplicities of the infinite eigenvalues, left and right Kronecker indices). Since `Q(λ)` is regular, 
`M-λN` has no left or right Kronecker indices.
The multiplicities of the infinite poles of `P(λ)` returned in `ip` are the positive differences between the multiplicities of 
the infinite eigenvalues of `M-λN` and the degree of `P(λ)` [2]. 
The number of finite poles in `val` is equal to the number of finite eigenvalues of `M-λN` (returned in `KRInfo.nf`), 
while the number of infinite poles in `val` is the sum of multiplicites in `ip`. 

The reduction of `M-λN` to the KLF is performed using orthonal similarity transformations and involves rank decisions 
based on rank reevealing QR-decompositions with column pivoting, 
if `fast = true`, or, the more reliable, SVD-decompositions, if `fast = false`. For efficiency purposes, the reduction is only
partially performed, without accumulating the performed orthogonal transformations.

The keyword arguments `atol`  and `rtol` specify the absolute and relative tolerances for the nonzero 
coefficients of `P(λ)`,  respectively. 
The default relative tolerance is `n*ϵ`, where `n` is the size of the smallest dimension of `P(λ)`, and `ϵ` is the 
machine epsilon of the element type of coefficients of `P(λ)`. 

[1] F. De Terán, F. M. Dopico, D. S. Mackey, Spectral equivalence of polynomial matrices and
the Index Sum Theorem, Linear Algebra and Its Applications, vol. 459, pp. 264-333, 2014.

[2] P. Van Dooren, Private communications, April 2020.
"""
function pmpoles(P::AbstractArray{T,3}; kwargs...) where T 
   p, m, k1 = size(P)
   Ptilde = zeros(T,p+m,p+m,k1);
   Ptilde[1:p,1:m,:] = P; 
   Ptilde[1:p,m+1:m+p,1] = Matrix{T}(I,p,p);
   Ptilde[p+1:p+m,1:m,1] = Matrix{T}(I,m,m);
   return pmzeros(Ptilde; kwargs...) 
end
pmpoles(P::Union{AbstractVecOrMat{Polynomial{T}},Polynomial{T},Number}; kwargs...) where {T} =
       pmpoles(poly2pm(P); kwargs...)
"""
    pmzeros1(P; fast = false, atol::Real = 0, rtol::Real = atol>0 ? 0 : n*ϵ) -> (val, iz, KRInfo)

Return the finite and infinite zeros of the polynomial matrix `P(λ)` in `val`, 
the multiplicities of infinite zeros in `iz` and the information on the complete 
Kronecker-structure of the underlying strongly irreducible linear pencil based linearization of `P(λ)`
in the `KRInfo` object. 
The information on the complete Kronecker-structure of the underlying linearization consists of 
the right Kronecker indices `rki`, left Kronecker indices `lki`, infinite elementary divisors `id` 
and the number of finite eigenvalues `nf`, and can be obtained from `KRInfo` as `KRInfo.rki`, `KRInfo.lki`, `KRInfo.id` 
and `KRInfo.nf`, respectively. For more details, see  [`pkstruct`](@ref). 

`P(λ)` can be specified as a grade `k` polynomial matrix of the form `P(λ) = P_1 + λ P_2 + ... + λ**k P_(k+1)`, 
for which the coefficient matrices `P_i`, `i = 1, ..., k+1`, are stored in the 3-dimensional matrix `P`, 
where `P[:,:,i] contains the `i`-th coefficient matrix `P_i` (multiplying `λ**(i-1)`). 

`P(λ)` can also be specified as a matrix, vector or scalar of elements of the `Polynomial` type 
provided by the [Polynomials](https://github.com/JuliaMath/Polynomials.jl) package.   

The computation of the zeros is performed by first building a strongly irreducible linear pencil based 
linearization of `P(λ)` [1] as a structured linear pencil 

              | A-λE | B-λF | 
     M - λN = |------|------| ,
              | C-λG | D-λH |  
      
such that `P(λ) = (C-λG)*inv(λE-A)*(B-λF)+D-λH`, and then reducing the pencil `M-λN` to an 
appropriate Kronecker-like form (KLF) exhibiting its full Kronecker structure 
(i.e., number of finite eigenvalues, multiplicities of the infinite eigenvalues, 
left and right Kronecker indices). 
The left and right Kronecker indices of `M-λN` and `P(λ)` are the same [2] and are 
returned in `KRInfo.rki` and `KRInfo.rki`, respectively.
The multiplicities of the infinite zeros of `M-λN` and of `P(λ)` are the same [2] and are returned in `iz`.
The number of finite zeros in `val` is equal to the number of finite eigenvalues of `M-λN` 
(returned in `KRInfo.nf`), while the number of infinite zeros in `val` is the sum of multiplicites in `iz`. 

The reduction of `M-λN` to the KLF is performed using orthonal similarity transformations and involves rank decisions based on rank reevealing QR-decompositions with column pivoting, 
if `fast = true`, or, the more reliable, SVD-decompositions, if `fast = false`. For efficiency purposes, the reduction is only
partially performed, without accumulating the performed orthogonal transformations.

The keyword arguments `atol`  and `rtol` specify the absolute and relative tolerances for the nonzero 
coefficients of `P(λ)`,  respectively. 
The default relative tolerance is `n*ϵ`, where `n` is the size of the smallest dimension of `P(λ)`, and `ϵ` is the 
machine epsilon of the element type of coefficients of `P(λ)`. 

[1] F. Dopico, M. C. Quintana, and P. Van Dooren, Linear system matrices of rational transfer tunctions, (submitted 2020).

[2] G. Verghese, Comments on ‘Properties of the system matrix of a generalized state-space system’,
Int. J. Control, Vol.31(5) (1980) 1007–1009.
"""
function pmzeros1(P::AbstractArray{T,3}; fast = false, atol::Real = zero(real(T)), 
                  rtol::Real = (min(size(P)...)*eps(real(float(one(T)))))*iszero(atol)) where T 
   if size(P,1) <= size(P,2)
      A, E, B, F, C, G, D, H, = lpsminreal(pm2lps(P; obs = true)...; fast = fast, 
                                           atol1 = atol, atol2 = atol, rtol = rtol, obs = false) 
   else              
      A, E, B, F, C, G, D, H, = lpsminreal(pm2lps(P; contr = true)...; fast = fast, 
                                           atol1 = atol, atol2 = atol, rtol = rtol, contr = false) 
   end             
   return pzeros([A B; C D], [E F; G H]; fast = fast, atol1 = atol, atol2 = atol, rtol = rtol)
end
pmzeros1(P::Union{AbstractVecOrMat{Polynomial{T}},Polynomial{T},Number}; kwargs...) where {T} =
       pmzeros1(poly2pm(P); kwargs...)
"""
    pmpoles1(P; fast = false, atol::Real = 0, rtol::Real = atol>0 ? 0 : n*ϵ) -> (val, ip, KRInfo)
   
Return the finite and infinite poles of the polynomial matrix `P(λ)` in `val`, 
the multiplicities of infinite poles in `ip` and  the information on the complete 
Kronecker-structure of the underlying strongly irreducible linear pencil based linearization of 
`Q(λ) := [P(λ) I; I 0]` in the `KRInfo` object. 
The information on the complete Kronecker-structure of the underlying linearization consists of  
the right Kronecker indices `rki`, left Kronecker indices `lki`, infinite elementary divisors `id` 
and the number of finite eigenvalues `nf`, and can be obtained from `KRInfo` as `KRInfo.rki`, `KRInfo.lki`, `KRInfo.id` 
and `KRInfo.nf`, respectively. For more details, see  [`pkstruct`](@ref). 

`P(λ)` can be specified as a grade `k` polynomial matrix of the form `P(λ) = P_1 + λ P_2 + ... + λ**k P_(k+1)`, 
for which the coefficient matrices `P_i`, `i = 1, ..., k+1`, are stored in the 3-dimensional matrix `P`, 
where `P[:,:,i] contains the `i`-th coefficient matrix `P_i` (multiplying `λ**(i-1)`). 

`P(λ)` can also be specified as a matrix, vector or scalar of elements of the `Polynomial` type 
provided by the [Polynomials](https://github.com/JuliaMath/Polynomials.jl) package.   

The computation of the poles is performed by first building a strongly irreducible linear pencil based 
linearization of `Q(λ) := [P(λ) I; I 0]` [1] as a structured linear pencil 

              | A-λE | B-λF | 
     M - λN = |------|------| ,
              | C-λG | D-λH |  
      
such that `P(λ) = (C-λG)*inv(λE-A)*(B-λF)+D-λH`, and then reducing the pencil `M-λN` to an 
appropriate Kronecker-like form (KLF) exhibiting its full Kronecker structure 
(i.e., number of finite eigenvalues, multiplicities of the infinite eigenvalues, 
left and right Kronecker indices). 
The left and right Kronecker indices of `M-λN` and `P(λ)` are the same [2] and are 
returned in `KRInfo.rki` and `KRInfo.rki`, respectively.
The multiplicities of the infinite poles of `M-λN` and of `P(λ)` are the same [2] and are returned in `ip`.
The number of finite zeros in `val` is equal to the number of finite eigenvalues of `M-λN` 
(returned in `KRInfo.nf`), while the number of infinite zeros in `val` is the sum of multiplicites in `ip`. 

The reduction of `M-λN` to the KLF is performed using orthonal similarity transformations and involves rank decisions 
based on rank reevealing QR-decompositions with column pivoting, 
if `fast = true`, or, the more reliable, SVD-decompositions, if `fast = false`. For efficiency purposes, the reduction is only
partially performed, without accumulating the performed orthogonal transformations.

The keyword arguments `atol`  and `rtol` specify the absolute and relative tolerances for the nonzero 
coefficients of `P(λ)`,  respectively. 
The default relative tolerance is `n*ϵ`, where `n` is the size of the smallest dimension of `P(λ)`, and `ϵ` is the 
machine epsilon of the element type of coefficients of `P(λ)`. 

[1] F. Dopico, M. C. Quintana, and P. Van Dooren, Linear system matrices of rational transfer tunctions, (submitted 2020).

[2] G. Verghese, Comments on ‘Properties of the system matrix of a generalized state-space system’,
Int. J. Control, Vol.31(5) (1980) 1007–1009.
"""
function pmpoles1(P::AbstractArray{T,3}; fast = false, atol::Real = zero(real(T)), 
                  rtol::Real = (min(size(P)...)*eps(real(float(one(T)))))*iszero(atol)) where T 
   p = size(P,1)
   m = size(P,2)               
   if p <= m
      A, E, B, F, C, G, D, H, = lpsminreal(pm2lps(P; obs = true)...; fast = fast, 
                                           atol1 = atol, atol2 = atol, rtol = rtol, obs = false) 
   else              
      A, E, B, F, C, G, D, H, = lpsminreal(pm2lps(P; contr = true)...; fast = fast, 
                                           atol1 = atol, atol2 = atol, rtol = rtol, contr = false) 
   end     
   n = size(A,1)       
   M = [A zeros(T,n,p+m); zeros(T,p,n+m) I; zeros(T,m,n) I zeros(T,m,p)]
   N = [E F zeros(T,n,p); G H zeros(T,p,p); zeros(T,m,n+m+p)]
   return pzeros(M, N; fast = fast, atol1 = atol, atol2 = atol, rtol = rtol)
end
pmpoles1(P::Union{AbstractVecOrMat{Polynomial{T}},Polynomial{T},Number}; kwargs...) where {T} =
       pmpoles1(poly2pm(P); kwargs...)
"""
      pmzeros2(P; fast = false, atol::Real = 0, rtol::Real = atol>0 ? 0 : n*ϵ) -> (val, iz, KRInfo)
   
Return the finite and infinite zeros of the polynomial matrix `P(λ)` in `val`, 
the multiplicities of infinite zeros in `iz` and the information on the complete 
Kronecker-structure of the underlying irreducible descriptor system based linearization of `P(λ)`
in the `KRInfo` object. 
The information on the complete Kronecker-structure of the underlying linearization consists of 
the right Kronecker indices `rki`, left Kronecker indices `lki`, infinite elementary divisors `id` 
and the number of finite eigenvalues `nf`, and can be obtained from `KRInfo` as `KRInfo.rki`, `KRInfo.lki`, `KRInfo.id` 
and `KRInfo.nf`, respectively. For more details, see  [`pkstruct`](@ref). 

`P(λ)` can be specified as a grade `k` polynomial matrix of the form `P(λ) = P_1 + λ P_2 + ... + λ**k P_(k+1)`, 
for which the coefficient matrices `P_i`, `i = 1, ..., k+1`, are stored in the 3-dimensional matrix `P`, 
where `P[:,:,i] contains the `i`-th coefficient matrix `P_i` (multiplying `λ**(i-1)`). 

`P(λ)` can also be specified as a matrix, vector or scalar of elements of the `Polynomial` type 
provided by the [Polynomials](https://github.com/JuliaMath/Polynomials.jl) package.   

The computation of the zeros is performed by first building an irreducible descriptor system based 
linearization of `P(λ)` [1] as a structured linear pencil 

              | A-λE | B | 
     M - λN = |------|---| ,
              |  C   | D |  
      
such that `P(λ) = C*inv(λE-A)*B+D`, and then reducing the pencil `M-λN` to an 
appropriate Kronecker-like form (KLF) exhibiting its full Kronecker structure 
(i.e., number of finite eigenvalues, multiplicities of the infinite eigenvalues, 
left and right Kronecker indices). 
The left and right Kronecker indices of `M-λN` and `P(λ)` are the same [2] and are 
returned in `KRInfo.rki` and `KRInfo.rki`, respectively.
The multiplicities of the infinite zeros of `M-λN` and of `P(λ)` are the same [2] and are returned in `iz`.
The number of finite zeros in `val` is equal to the number of finite eigenvalues of `M-λN` 
(returned in `KRInfo.nf`), while the number of infinite zeros in `val` is the sum of multiplicites in `iz`. 

The reduction of `M-λN` to the KLF is performed using orthonal similarity transformations and involves rank decisions based on rank reevealing QR-decompositions with column pivoting, 
if `fast = true`, or, the more reliable, SVD-decompositions, if `fast = false`. For efficiency purposes, the reduction is only
partially performed, without accumulating the performed orthogonal transformations.

The keyword arguments `atol`  and `rtol` specify the absolute and relative tolerances for the nonzero 
coefficients of `P(λ)`,  respectively. 
The default relative tolerance is `n*ϵ`, where `n` is the size of the smallest dimension of `P(λ)`, and `ϵ` is the 
machine epsilon of the element type of coefficients of `P(λ)`. 

[1] G. Verghese, B. Levy, and T. Kailath, Generalized state-space systems, IEEE Trans. Automat. Control,
26:811-831 (1981).

[2] G. Verghese, Comments on ‘Properties of the system matrix of a generalized state-space system’,
Int. J. Control, Vol.31(5) (1980) 1007–1009.
"""
function pmzeros2(P::AbstractArray{T,3}; fast = false, atol::Real = zero(real(T)), 
                  rtol::Real = (min(size(P)...)*eps(real(float(one(T)))))*iszero(atol)) where T 
   sys = pm2ls(P; contr = true, obs = true, fast = fast, atol = atol, rtol = rtol)  
   return spzeros(sys...; fast = fast, atol1 = atol, atol2 = atol, rtol = rtol)
end
pmzeros2(P::Union{AbstractVecOrMat{Polynomial{T}},Polynomial{T},Number}; kwargs...) where {T} =
       pmzeros2(poly2pm(P); kwargs...)
"""
    pmpoles2(P; fast = false, atol::Real = 0, rtol::Real = atol>0 ? 0 : n*ϵ) -> (val, ip, KRInfo)
   
Return the finite and infinite poles of the polynomial matrix `P(λ)` in `val`, 
the multiplicities of infinite poles in `ip` and  the information on the complete 
Kronecker-structure of the underlying strongly irreducible linear pencil based linearization of 
`Q(λ) := [P(λ) I; I 0]` in the `KRInfo` object. 
The information on the complete Kronecker-structure of the underlying linearization consists of  
the right Kronecker indices `rki`, left Kronecker indices `lki`, infinite elementary divisors `id` 
and the number of finite eigenvalues `nf`, and can be obtained from `KRInfo` as `KRInfo.rki`, `KRInfo.lki`, `KRInfo.id` 
and `KRInfo.nf`, respectively. For more details, see  [`pkstruct`](@ref). 

`P(λ)` can be specified as a grade `k` polynomial matrix of the form `P(λ) = P_1 + λ P_2 + ... + λ**k P_(k+1)`, 
for which the coefficient matrices `P_i`, `i = 1, ..., k+1`, are stored in the 3-dimensional matrix `P`, 
where `P[:,:,i] contains the `i`-th coefficient matrix `P_i` (multiplying `λ**(i-1)`). 

`P(λ)` can also be specified as a matrix, vector or scalar of elements of the `Polynomial` type 
provided by the [Polynomials](https://github.com/JuliaMath/Polynomials.jl) package.   

The computation of the poles is performed by first building an irreducible  
linearization of `Q(λ) := [P(λ) I; I 0]` [1] as a structured linear pencil 

              | A-λE | B | 
     M - λN = |------|---| ,
              |  C   | D |  
      
such that `P(λ) = C*inv(λE-A)*B+D`, and then reducing the pencil `M-λN` to an 
appropriate Kronecker-like form (KLF) exhibiting its full Kronecker structure 
(i.e., number of finite eigenvalues, multiplicities of the infinite eigenvalues, 
left and right Kronecker indices). 
The left and right Kronecker indices of `M-λN` and `P(λ)` are the same [2] and are 
returned in `KRInfo.rki` and `KRInfo.rki`, respectively.
The multiplicities of the infinite poles of `M-λN` and of `P(λ)` are the same [2] and are returned in `ip`.
The number of finite zeros in `val` is equal to the number of finite eigenvalues of `M-λN` 
(returned in `KRInfo.nf`), while the number of infinite zeros in `val` is the sum of multiplicites in `ip`. 

The reduction of `M-λN` to the KLF is performed using orthonal similarity transformations and involves rank decisions 
based on rank reevealing QR-decompositions with column pivoting, 
if `fast = true`, or, the more reliable, SVD-decompositions, if `fast = false`. For efficiency purposes, the reduction is only
partially performed, without accumulating the performed orthogonal transformations.

The keyword arguments `atol`  and `rtol` specify the absolute and relative tolerances for the nonzero 
coefficients of `P(λ)`,  respectively. 
The default relative tolerance is `n*ϵ`, where `n` is the size of the smallest dimension of `P(λ)`, and `ϵ` is the 
machine epsilon of the element type of coefficients of `P(λ)`. 

[1] G. Verghese, B. Levy, and T. Kailath, Generalized state-space systems, IEEE Trans. Automat. Control,
26:811-831 (1981).

[2] G. Verghese, Comments on ‘Properties of the system matrix of a generalized state-space system’,
Int. J. Control, Vol.31(5) (1980) 1007–1009.
"""
function pmpoles2(P::AbstractArray{T,3}; fast = false, atol::Real = zero(real(T)), 
                  rtol::Real = (min(size(P)...)*eps(real(float(one(T)))))*iszero(atol)) where T 
   A, E, = pm2ls(P; contr = true, obs = true, fast = fast, atol = atol, rtol = rtol)  
   return pzeros(A, E; fast = fast, atol1 = atol, atol2 = atol, rtol = rtol)
end
pmpoles2(P::Union{AbstractVecOrMat{Polynomial{T}},Polynomial{T},Number}; kwargs...) where {T} =
       pmpoles2(poly2pm(P); kwargs...)
"""
    pmroots(P; fast = false, atol::Real = 0, rtol::Real = atol>0 ? 0 : n*ϵ) -> val

Compute the roots of the determinant of the regular polynomial matrix `P(λ)` in `val`. 

`P(λ)` can be specified as a grade `k` polynomial matrix of the form `P(λ) = P_1 + λ P_2 + ... + λ**k P_(k+1)`, 
for which the coefficient matrices `P_i`, `i = 1, ..., k+1`, are stored in the 3-dimensional matrix `P`, 
where `P[:,:,i] contains the `i`-th coefficient matrix `P_i` (multiplying `λ**(i-1)`). 

`P(λ)` can also be specified as a matrix, vector or scalar of elements of the `Polynomial` type 
provided by the [Polynomials](https://github.com/JuliaMath/Polynomials.jl) package.   

The roots of `det(P(λ))` are computed as the finite eigenvalues of a companion form linearization `M-λN`of `P(λ)`.
The finite eigenvalues are computed by reducing the pencil `M-λN` to an appropriate Kronecker-like form (KLF) 
exhibiting the spliting of the infinite and finite eigenvalue structures of the pencil `M-λN`. 
The reduction is performed using orthonal similarity transformations and involves rank decisions based on rank reevealing QR-decompositions with column pivoting, 
if `fast = true`, or, the more reliable, SVD-decompositions, if `fast = false`. For efficiency purposes, the reduction is only
partially performed, without accumulating the performed orthogonal transformations.

The keyword arguments `atol`  and `rtol` specify the absolute and relative tolerances for the nonzero 
coefficients of `P(λ)`,  respectively. 
The default relative tolerance is `n*ϵ`, where `n` is the size of the smallest dimension of `P(λ)`, and `ϵ` is the 
machine epsilon of the element type of coefficients of `P(λ)`. 
"""
function pmroots(P::AbstractArray{T,3}; fast = false, atol::Real = zero(real(T)), 
                 rtol::Real = (min(size(P)...)*eps(real(float(one(T)))))*iszero(atol)) where T 
   ispmregular(P,atol = atol, rtol = rtol) || error("The polynomial matrix is not regular")
   val, iz, = pmzeros(P, fast = fast, atol = atol, rtol = rtol)  
   return val[1:end-sum(iz)]
end
pmroots(P::Union{AbstractVecOrMat{Polynomial{T}},Polynomial{T},Number}; kwargs...) where {T} =
        pmroots(poly2pm(P); kwargs...)
"""
       pmrank(P; fastrank = true, atol = 0, rtol = atol > 0 ? 0 : n*ϵ) 
   
Determine the normal rank of a polynomial matrix `P(λ)`. 
   
`P(λ)` is a grade `k` polynomial matrix of the form `P(λ) = P_1 + λ P_2 + ... + λ**k P_(k+1)`, for which 
the coefficient matrices `P_i`, `i = 1, ..., k+1`, are stored in the 3-dimensional matrix `P`, 
where `P[:,:,i] contains the `i`-th coefficient matrix `P_i` (multiplying `λ**(i-1)`). The normal rank of `P(λ)`
is the number of linearly independent rows or columns. 

`P(λ)` can also be specified as a matrix, vector or scalar of elements of the `Polynomial` type 
provided by the [Polynomials](https://github.com/JuliaMath/Polynomials.jl) package.   

If `fastrank = true`, the rank is evaluated by counting how many singular values of `P(γ)` have magnitude greater 
than `max(atol, rtol*σ₁)`, where `σ₁` is the largest singular value of `P(γ)` and `γ` is a randomly generated 
complex value of magnitude equal to one. 
If `fastrank = false`, first a structured linearization of `P(λ)` is built in the form `[A-λE B; C D]` with `A-λE`
an order `n` regular subpencil, and then its normal rank `nr` is determined. The normal rank of `P(λ)` is `nr - n`.  

The keyword arguments `atol` and `rtol`, specify, respectively, the absolute and relative tolerance for the 
nonzero coefficients of `P(λ)`. The default relative tolerance is `n*ϵ`, where `n` is the size of the 
smallest dimension of `P(λ)` and `ϵ` is the machine epsilon of the element type of its coefficients. 
"""
function pmrank(P::AbstractArray{T,3}; fastrank::Bool = true, atol::Real = zero(real(T)), 
                rtol::Real = (min(size(P)...)*eps(real(float(one(T)))))*iszero(atol)) where T
   if fastrank
       return rank(pmeval(P,exp(rand()*im)), atol = atol, rtol = rtol)
   else
       p, m, k = size(P)
       d = pmdeg(P)
       if p < m
          M, N = pm2lpCF2(P)
          r = prank(M, N, atol1 = atol, atol2 = atol, rtol = rtol)
          return d < 2 ? r : r-p*(d-1)
       else
          M, N = pm2lpCF1(P)
          r = prank(M, N, atol1 = atol, atol2 = atol, rtol = rtol)
          return d < 2 ? r : r-m*(d-1)
       end
   end
end
pmrank(P::Union{AbstractVecOrMat{Polynomial{T}},Polynomial{T},Number}; kwargs...) where {T} =
       pmrank(poly2pm(P); kwargs...)
"""
    ispmregular(P; fastrank = true, atol::Real = 0, rtol::Real = atol>0 ? 0 : n*ϵ) -> Bool

Test whether the polynomial matrix `P(λ)` is regular (i.e., `P(λ)` is square and `det(P(λ)) !== 0`). 
The underlying computational procedure checks that the normal rank of the square `P(λ)` is equal to its order.

`P(λ)` is a grade `k` polynomial matrix of the form `P(λ) = P_1 + λ P_2 + ... + λ**k P_(k+1)`, for which 
the coefficient matrices `P_i`, `i = 1, ..., k+1`, are stored in the 3-dimensional matrix `P`, 
where `P[:,:,i] contains the `i`-th coefficient matrix `P_i` (multiplying `λ**(i-1)`). 

`P(λ)` can also be specified as a matrix, vector or scalar of elements of the `Polynomial` type 
provided by the [Polynomials](https://github.com/JuliaMath/Polynomials.jl) package.   
f
If `fastrank = true`, the rank is evaluated by counting how many singular values of `P(γ)` have magnitude greater 
than `max(atol, rtol*σ₁)`, where `σ₁` is the largest singular value of `P(γ)` and `γ` is a randomly generated 
complex value of magnitude equal to one. 
If `fastrank = false`, first a linearization of `P(λ)` is built in a companion form `M-λN` of order `n` 
and then its normal rank `nr` is determined. `P(λ)` is regular if `nr = n`.  

The keyword arguments `atol` and `rtol`, specify, respectively, the absolute and relative tolerance for the 
nonzero coefficients of `P(λ)`. The default relative tolerance is `n*ϵ`, where `n` is the size of the 
smallest dimension of `P(λ)` and `ϵ` is the machine epsilon of the element type of its coefficients. 
"""
function ispmregular(P::AbstractArray{T,3}; fastrank = true, atol::Real = zero(real(T)), 
                     rtol::Real = (min(size(P)...)*eps(real(float(one(T)))))*iszero(atol)) where T 
   p, m, = size(P)
   m == p || (return false)
   if fastrank                
      return rank(pmeval(P,exp(rand()*im)), atol = atol, rtol = rtol) == m
   else 
      p <= m ? MN = pm2lpCF1(P) : MN = pm2lpCF2(P)
      return isregular(MN..., atol1 = atol, atol2 = atol, rtol = rtol)
   end
end
ispmregular(P::Union{AbstractVecOrMat{Polynomial{T}},Polynomial{T},Number}; kwargs...) where {T} =
       ispmregular(poly2pm(P); kwargs...)
"""
    ispmunimodular(P; fastrank = true, atol::Real = 0, rtol::Real = atol>0 ? 0 : n*ϵ) -> Bool

Test whether the polynomial matrix `P(λ)` is unimodular (i.e., `P(λ)` is square, regular and `det(P(λ)) == constant`). 

The underlying computational procedure checks that `P(λ)` is square and its first companion form linearization 
is regular and has no finite eigenvalues.

`P(λ)` is a grade `k` polynomial matrix of the form `P(λ) = P_1 + λ P_2 + ... + λ**k P_(k+1)`, for which 
the coefficient matrices `P_i`, `i = 1, ..., k+1`, are stored in the 3-dimensional matrix `P`, 
where `P[:,:,i] contains the `i`-th coefficient matrix `P_i` (multiplying `λ**(i-1)`). 

`P(λ)` can also be specified as a matrix, vector or scalar of elements of the `Polynomial` type 
provided by the [Polynomials](https://github.com/JuliaMath/Polynomials.jl) package.   

The keyword arguments `atol` and `rtol`, specify, respectively, the absolute and relative tolerance for the 
nonzero coefficients of `P(λ)`. The default relative tolerance is `n*ϵ`, where `n` is the size of the 
smallest dimension of `P(λ)` and `ϵ` is the machine epsilon of the element type of its coefficients. 
"""
function ispmunimodular(P::AbstractArray{T,3}; atol::Real = zero(real(T)), 
                        rtol::Real = (min(size(P)...)*eps(real(float(one(T)))))*iszero(atol)) where T 
   p, m, = size(P)
   m == p || (return false)
   return isunimodular(pm2lpCF1(P)..., atol1 = atol, atol2 = atol, rtol = rtol)
end
ispmunimodular(P::Union{AbstractVecOrMat{Polynomial{T}},Polynomial{T},Number}; kwargs...) where {T} =
               ispmunimodular(poly2pm(P); kwargs...)



