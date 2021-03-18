# Release Notes

## Version 1.6.2

This patch version alleviates the excessive compilation times arising after updating the package to using the latest version v2.0 of Polynomials.jl.

## Version 1.6.1

This patch version updates the package to using the latest version v2.0 of Polynomials.jl.

## Version 1.6

This minor release includes fixes in several functions to enforce the usage of the most efficient concatenation functions involving matrices, vectors and scalars and minor corrections in the documentation. Also, a new version of the `lps2ls` function is provided, with an additional absolute tolerance parameter. This minor release is also intended to update the package to perform CI with Github Actions instead Travis-CI.

## Version 1.5.1

This patch release includes fixes in two functions for the evaluation of frequency gains for descriptor and pencil based linearizations, a new function to convert a pencil based linearization into a descriptor system based linearization, and enhancements of several functions for structured pencil to work with
both one- and two-dimensional arrays.

## Version 1.5

This minor release includes two new functions for infinite spectrum assignment of a regular pencil, a function for the computation of a Kronecker-like form exhibiting the right and infinite Kronecker structures, two new functions to refine the computed Kronecker-like forms such that the diagonal and supradiagonal blocks have upper triangular forms, and, accordingly, enhancements of several functions to compute Kronecker-like forms with the staircase form having upper triangular blocks. Several bug fixes have also been performed.

## Version 1.4.1

This patch release contains minor enhancements to ensure the upper triangular shape of subpencils with infinite eigenvalues in the computed Kronecker like forms and corrects the handling of null dimensions in the functions for the computation of reduced order linearizations.

## Version 1.4

This minor release includes several new functions which primarily serve for the implementation of the new [DescriptorSystems](https://github.com/andreasvarga/DescriptorSystems.jl) package. The new functions cover the following topics: the block diagonalization of a matrix for various ordering of eigenvalues; the computation of a special finite-infinite eigenvalue splitting ot a regular pencil;  the computation of a special spectrum separation of finite, infinite, stable and unstable eigenvalues of a regular matrix pencil using orthogonal or unitary transformations; the computation of several row partition preserving special Kronecker-like forms of structured (system) pencils; the computation of a Kronecker-like form exhibiting the left and infinite Kronecker structures; the computation of special Kronecker-like forms of structured full row rank pencils (special controllability staircase forms).

## Version 1.3

This minor release includes new functions which implement computational procedures for spectrum separation of a regular matrix pencil. For a given pair of matrices, new functions are available to compute the separation of finite and infinite eigenvalues using orthogonal or unitary transformations, with the resulting pair in generalized Hessenberg form, generalized Schur form or in an ordered generalized Schur form. Furthermore, functions have been implemented for the block diagonalization of matrix pairs for various ordering of finite and infinite eigenvalues.

## Version 1.2

This minor release includes new functions which implement computational procedures to allocate the spectrum of a matrix or of a regular matrix pencil. A new function is available to efficiently compute the eigenvalues of a Schur matrix or of a generalized (Schur, upper triangular) pair (and order-preserving version of `eigvals`). The function `fisplit` has been enhanced to compute the subpencil containing the infinite eigenvalues in an upper triangular form.

## Version 1.1

This minor release includes implementations of computational procedures to manipulate rational matrices specified as ratios of elements of polynomial matrices of numerators and denominators. The
numerator and denominator polynomial matrices can be alternatively specified as matrices, vectors or scalars of elements of the `Polynomial` type
provided by the [Polynomials](https://github.com/JuliaMath/Polynomials.jl) package.  Several linearization functions are available which allow the extension of pencil manipulation techniques to rational matrices. Some straightforward applications are covered such as the computation of finite and infinite poles and zeros, the determination of the normal rank, the determination of Kronecker indices and finite and infinite pole and zero structures. Several lower level functions have been implemented to perform polynomial operations (such as product, exact division, long division) or to compute the greatest common divisor or least common multiple of two polynomials. These function underly the implementation of several linearizations techniques of rational matrices. The user interfaces of functions **pmpoles**, **pmpoles1** and **pmpoles2** have been simplified and a new function has been implemented to perform elementwise long divison of two polynomial matrices.

## Version 1.0.2

Patch release which includes a new definition of the `KRInfo` object by adding information on the normal rank. This led to updated and new functionality in several functions and their documentations. The mathematical background and the computational aspects which underly the implementation of functions for polynomial matrices are presented in [arXiv:2006.06825](https://arxiv.org/pdf/2006.06825).

## Version 1.0.1

Patch release to enhance the coverage and to polish the documentation.

## Version 1.0.0

This release includes implementations of computational procedures to manipulate polynomial matrices specified via their coefficient matrices in a monomial basis. All funtions also support matrix, vector or scalar of elements of the `Polynomial` type
provided by the [Polynomials](https://github.com/JuliaMath/Polynomials.jl) package.  Several linearization functions are available which allow the extension of pencil manipulation techniques to matrix polynomials. Some straightforward applications are covered such as the computation of finite and infinite eigenvalues, zeros and poles, the determination of the normal rank, the determination of Kronecker indices and finite and infinite eigenvalue structure, checks of regularity and unimodularity.  A new function is provided to check the unimodularity of a matrix pencil.

## Version 0.5.0

This release includes implementations of computational procedures to determine least order pencil based linearizations, as those which may arise from the linearization of polynomial and rational matrices. A new function to check the equivalence of two matrix pencil based linearizations is also provided. An enhanced modularization of functions for basic pencil and structured pencil reduction has been performed to eliminate possible modifications of input arguments.

## Version 0.4.0

This release includes implementations of computational procedures to determine least order descriptor system based linerizations, as those which may arise from the linearization of polynomial and rational matrices. The elimination of simple infinite eigenvalues is based on a new function to compute SVD-like forms of regular matrix pencils. A new function to check the equivalence of two linearizations is also provided.

## Version 0.3.0

This release includes implementations of several reductions of structured matrix pencils to various KLFs and covers some straightforward applications such as the computation of finite and infinite eigenvalues and zeros, the determination of the normal rank, the determination of Kronecker indices and infinite eigenvalue structure.

## Version 0.2.0

This release includes a new tool for finite-infinite eigenvalue splitting of a regular pencil and substantial improvements of the modularization and interfaces of implemented basic pencil operations.

## Version 0.1.0

This is the initial release providing prototype implementations of several pencil reduction algorithms to various KLFs and covering some straightforward applications such as the computation of finite and infinite eigenvalues and zeros, the determination of the normal rank, Kronecker indices and infinite eigenvalue structure.