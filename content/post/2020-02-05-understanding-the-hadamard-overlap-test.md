+++
title = "Understanding the Hadamard-Overlap test"
author = ["Adrien Suau"]
date = 2020-02-05
draft = false
toc = true
+++

The Hadamard test is a quantum algorithm that can approximate the value
of \\(\langle x \vert U \vert x \rangle\\) provided that \\(\vert x \rangle\\) is a
quantum state that can be constructed&nbsp;[^1] and \\(U\\) is a unitary matrix
implemented by a quantum circuit.

But what about the Hadamard-Overlap test? Have you ever heard about it? I
personally did not until reading
[Variational Quantum Linear Solver: A Hybrid Algorithm for Linear Systems](<http://arxiv.org/abs/1909.05820v1>)
[^2].

The goal of the Hadamard-Overlap test is to estimate the quantity

\begin{equation\*}
c = \langle 0 \vert V\_2^\dagger U\_1 V\_1 \vert 0 \rangle \langle 0 \vert V\_1^\dagger
U\_2 V\_2 \vert 0 \rangle,
\end{equation\*}

with \\(U\_1\\), \\(U\_2\\), \\(V\_1\\) and \\(V\_2\\) being unitary matrices.

{{% toc %}}


## The Hadamard-Overlap algorithm {#the-hadamard-overlap-algorithm}


### Presentation of the algorithm {#presentation-of-the-algorithm}

To estimate the quantity

\begin{equation\*}
c = \langle 0 \vert V\_2^\dagger U\_1 V\_1 \vert 0 \rangle \langle 0 \vert V\_1^\dagger
U\_2 V\_2 \vert 0 \rangle,
\end{equation\*}

the Hadamard-Overlap test executes the circuit below and perform a step of
post-processing on the results of the measurements.

{{< figure
library="true"
src="hadamard-overlap-test.png"
title="Hadamard-Overlap test circuit. The circuit boxed in red is the destructive-SWAP test devised in [SWAP test and Hong-Ou-Mandel effect are equivalent](<https://doi.org/10.1103/PhysRevA.87.052330>). The \\(S^\dagger\\) gate in blue should be removed (resp. included) if we want to estimate the real-part \\(\Re( c)\\) (resp. imaginary-part \\(\Im( c)\\)) of \\(c\\)."
lightbox="true" >}}

The above quantum circuit is depicted almost identically in
[Variational Quantum Linear Solver: A Hybrid Algorithm for Linear Systems](<http://arxiv.org/abs/1909.05820v1>)
along with a _short_ explanation of the post-processing needed on the measured values
\\(o\_a\\), \\(\left\\{ o\_i^1 \right\\}\_i\\) and \\(\left\\{ o\_i^2 \right\\}\_i\\) to compute our approximate
of the value \\(c\\).


### Issue with the post-processing step {#issue-with-the-post-processing-step}

But when implementing this Hadamard-Overlap test, I found out that the explanation provided
in the paper was too short and concise to be able to understand clearly what post-processing
one should perform to obtain the expected result: \\(\Re( c)\\) or \\(\Im( c)\\) depending on the inclusion
of the \\(S^\dagger\\) gate.

In this post, I will share the developments that lead me to clarify the post-processing
needed to obtain an estimation of \\(\Re( c)\\) or \\(\Im( c)\\).


## Analysis of the Hadamard-Overlap circuit {#analysis-of-the-hadamard-overlap-circuit}

In order to analyse the Hadamard-Overlap circuit and to devise the correct way of post-processing
the outputs given by the measurements at the end of the circuit, we should first have a good
understanding of the action of the quantum circuit on the quantum state it is applied on. The
best way to understand how the quantum circuit evolves the quantum state
\\(\vert 0 \rangle^{\otimes (2n+1)}\\) that is given as input is to compute the state of the \\(2n+1\\)
qubits at the end of the circuit.

To do so, a little study of the original Hadamard test and of the SWAP-test algorithms is beneficial.


### The Hadamard test {#the-hadamard-test}

The quantum circuit implementing the Hadamard test is:

{{< figure
library="true"
src="hadamard-test-circuit.png"
title="Hadamard test circuit that measures the real (or imaginary if the blue \\(S^\dagger\\) gate is included in the circuit) expected value of a unitary. Note that the \\(S^\dagger\\) gate commutes with the controlled-\\(U\\) gate, which means that they can be swapped without affecting the output of the circuit."
lightbox="true" >}}

It is easy to show that, before the measurement of the ancilla qubit, the \\(n+1\\) qubits are in
the state

\begin{equation\*}
\vert \Psi \rangle = \frac{\textcolor{blue}{\vert 0 \rangle} \left( I + sU \right) \vert \psi \rangle + \textcolor{blue}{\vert 1 \rangle} \left( I - sU \right) \vert \psi \rangle}{2}
\end{equation\*}

where \\(I\\) is the identity operator and

\begin{equation\*}
s = \left\\{\begin{split}
-i & \quad \text{if the } S^\dagger \text{ gate has been applied} \\\\\\
1 & \quad \text{otherwise}
\end{split}\right.
\end{equation\*}

{{% alert note %}}
Note that the state of the ancilla qubit has been colored in \\(\textcolor{blue}{\text{blue}}\\). This coloring is here to
avoid confusing the different ancilla qubits used in this post.
{{% /alert %}}


### The SWAP test {#the-swap-test}

The SWAP test is a quantum algorithm that can be used to estimate how much two quantum states
\\(\vert \psi\_1 \rangle\\) and \\(\vert \psi\_2 \rangle\\) differ from each other.

{{< figure
library="true"
src="swap-test-circuit.png"
title="Original SWAP test circuit that can be used to estimate how much \\(\vert \psi\_1 \rangle\\) and \\(\vert \psi\_2 \rangle\\) differ."
lightbox="true" >}}

It can be shown that the measurement on the ancilla qubit will yield \\(\vert 0 \rangle\\) with a
probability of \\(\frac{1 + \vert \langle \psi\_2 \vert \psi\_1 \rangle \vert^2}{2}\\). By repeating
this measurement a sufficient number of times, it become possible to estimate with a good
precision the value \\(\vert \langle \psi\_2 \vert \psi\_1 \rangle \vert^2\\), which can be seen as
a measure of the overlap between \\(\vert \psi\_1 \rangle\\) and \\(\vert \psi\_2 \rangle\\).

This version of the SWAP test has been studied thoroughly and an **equivalent** quantum circuit
that do not require any ancilla qubit can be found in
[SWAP test and Hong-Ou-Mandel effect are equivalent](<https://doi.org/10.1103/PhysRevA.87.052330>).

{{< figure
library="true"
src="destructive-swap-test-circuit.png"
title="Modified SWAP test circuit that does not require any ancilla qubit. Post-processing of the values \\(\left\\{ o\_i^1 \right\\}\_i\\) and \\(\left\\{ o\_i^2 \right\\}\_i\\) is, on the other hand, required."
lightbox="true" >}}

With this modified version of the SWAP test, the test is successful (equivalent of measuring
the state \\(\vert 0 \rangle\\) with the original circuit) if and only if the bitwise-and of the
bit-strings formed by \\(\left\\{ o\_i^1 \right\\}\_i\\) and \\(\left\\{ o\_i^2 \right\\}\_i\\) has an even
number of ones. Mathematically, the test is successful if

\begin{equation\*}
\sum\_{i=1}^n o\_i^1 \land o\_i^2 \equiv 0 \pmod{2}.
\end{equation\*}

The two test being equivalent in the sense that they provide the same results, they can
be used interchangeably. We will use this equivalence in the next section to make the maths
simpler.


### Back to the Hadamard-Overlap test {#back-to-the-hadamard-overlap-test}

{{% alert warning %}}
In the rest of this post I assume that the ancilla qubit of the Hadamard-test is in
a superposition of \\(\vert 0 \rangle\\) and \\(\vert 1 \rangle\\), i.e. that the coefficients
in front of each outcomes is **not** $0.

This assumption is not verified in some cases. Theses cases will be studied in a following
post


#### Hadamard test {#hadamard-test}

Looking back attentively at the beginning of the Hadamard-Overlap test and noting
that the \\(S^\dagger\\) gate commutes with the controlled-\\(U\\) gate, we can see that the
Hadamard-Overlap test starts with a regular Hadamard test where:

-   The input state \\(\vert \psi \rangle\\) is composed of \\(2n\\) qubits instead of the $n$-qubit state
    in the original Hadamard-test.
-   \\(U = U\_1 \otimes U\_2\\).
-   \\(\vert \psi \rangle = (V\_1 \otimes V\_2) \vert 0 \rangle\\).

In order to avoid confusion with the states dimensions, let use \\(\vert S\_1 \rangle\\) and
\\(\vert S\_2 \rangle\\) for the two $n$-qubit quantum states composing the $2n$-qubit input
state \\(\vert \psi \rangle\\), i.e.
\\(\vert \psi \rangle = \vert S\_1 \rangle \otimes \vert S\_2 \rangle\\).

Replacing \\(U\\) and \\(\vert \psi \rangle\\) in the expression of the output state of the Hadamard test
\\(\vert\Psi\rangle\\) by the values listed above gives us the quantum state

\begin{equation\*}
\begin{split}
\vert &\Psi\_{2n} \rangle = \frac{\textcolor{blue}{\vert 0 \rangle} \otimes \left( I + sU \right) \vert \psi \rangle + \textcolor{blue}{\vert 1 \rangle} \left( I - sU \right) \vert \psi \rangle}{2} \\\\\\
%&= \textcolor{blue}{\vert 0 \rangle} \otimes \frac{\left( I + s(U\_1 \otimes U\_2) \right) \vert S\_1 \rangle \vert S\_2 \rangle}{2} + \textcolor{blue}{\vert 1 \rangle} \otimes \frac{\left( I - s(U\_1 \otimes U\_2) \right) \vert S\_1 \rangle \vert S\_2 \rangle}{2} \\\\\\
&= \textcolor{blue}{\vert 0 \rangle} \frac{ \vert S\_1 \rangle \vert S\_2 \rangle + s U\_1\vert S\_1 \rangle U\_2 \vert S\_2 \rangle}{2} + \textcolor{blue}{\vert 1 \rangle} \frac{ \vert S\_1 \rangle \vert S\_2 \rangle - s U\_1\vert S\_1 \rangle U\_2 \vert S\_2 \rangle}{2} \\\\\\
\end{split}
\end{equation\*}

This means that, by ignoring the destructive SWAP test performed in the red squared part of the circuit,
we have access to the quantum state

\begin{equation\*}
\vert \phi\_{\textcolor{blue}{\vert 0 \rangle}} \rangle = \frac{ \vert S\_1 \rangle \vert S\_2 \rangle + s U\_1\vert S\_1 \rangle U\_2 \vert S\_2 \rangle}{\sqrt{2}}
\end{equation\*}

if we measured the first ancilla qubit in the state \\(\vert 0 \rangle\\) or

\begin{equation\*}
\vert \phi\_{\textcolor{blue}{\vert 1 \rangle}} \rangle = \frac{ \vert S\_1 \rangle \vert S\_2 \rangle - s U\_1\vert S\_1 \rangle U\_2 \vert S\_2 \rangle}{\sqrt{2}}
\end{equation\*}

if the first ancilla qubit has been measured in the state \\(\vert 1 \rangle\\).

{{% alert info %}}
Note the denominator that is now \\(\sqrt{2}\\). This is due to the projective measurement performed on the ancilla qubit.
{{% /alert %}}

Looking back at where we are, we computed the exact state of the qubits **before** applying the
SWAP test. Our next step will be to apply the SWAP test and see how the state evolves.


#### SWAP test {#swap-test}

In the last part, we left our Hadamard-Overlap test circuit halfway computed, stopping before applying
the red boxed part of the circuit. It turns out that this red boxed part is the modified version of the
SWAP test that does not require any additional ancilla qubits (presented in
[SWAP test and Hong-Ou-Mandel effect are equivalent](<https://doi.org/10.1103/PhysRevA.87.052330>)).

To simplify the mathematical expressions, we will use the equivalence between the original SWAP
test algorithm and the modified version used in the Hadamard-Overlap test to change the quantum
circuit in the red box by the original SWAP test.
To do so, we introduce a _virtual_ ancillary qubit, i.e. an ancillary qubit that we will use
during the mathematical analysis but that will not appear on the final quantum circuit diagram.
In order to isolate correctly this _virtual_ ancilla qubit, its state will be colored in
\\(\textcolor{red}{\text{red}}\\).

Finally, in order to avoid re-doing the computation for both \\(\vert \phi\_{\textcolor{blue}{\vert 0 \rangle}} \rangle\\)
and \\(\vert \phi\_{\textcolor{blue}{\vert 1 \rangle}} \rangle\\) we will use a \\(\textcolor{blue}{\pm}\\) sign to account
for both states (and \\(\textcolor{blue}{\mp}\\) if there is a sign negation):

\begin{equation\*}
\vert \phi\_{\textcolor{blue}{\vert i \rangle}} \rangle = \frac{ \vert S\_1 \rangle \vert S\_2 \rangle \textcolor{blue}{\pm} s U\_1\vert S\_1 \rangle U\_2 \vert S\_2 \rangle}{\sqrt{2}}.
\end{equation\*}

{{% alert note %}}
Note that, with the convention we chose for \\(\textcolor{blue}{\pm}\\) and \\(\textcolor{blue}{\mp}\\),
the quantum state \\(\vert \phi\_{\\textcolor{blue}{\vert 0 \rangle}} \rangle\\) can be recovered by taking the sign on the upper-part
of the operator.
Respectively, the quantum state \\(\vert \phi\_{\textcolor{blue}{\vert 1 \rangle}} \rangle\\) can be recovered by taking the sign on
the lower-part of the \\(\textcolor{blue}{\pm}\\) or \\(\textcolor{blue}{\mp}\\) signs.
{{% /alert %}}

Lets start the SWAP test by adding the virtual ancilla to the state:

\begin{equation\*}
\vert \phi\_{\textcolor{blue}{\vert i \rangle}} \rangle = \textcolor{red}{\vert 0 \rangle} \frac{ \vert S\_1 \rangle \vert S\_2 \rangle \textcolor{blue}{\pm} s U\_1\vert S\_1 \rangle U\_2 \vert S\_2 \rangle}{\sqrt{2}}.
\end{equation\*}

Following the algorithm, we apply a \\(H\\) gate to the virtual ancilla:

\begin{equation\*}
\vert \phi\_{\textcolor{blue}{\vert i \rangle}} \rangle = \textcolor{red}{\frac{\vert 0 \rangle + \vert 1 \rangle}{\sqrt{2}}} \frac{ \vert S\_1 \rangle \vert S\_2 \rangle \textcolor{blue}{\pm} s U\_1\vert S\_1 \rangle U\_2 \vert S\_2 \rangle}{\sqrt{2}}.
\end{equation\*}

Performing the controlled-SWAP operation gives us the state

\begin{equation\*}
\begin{split}
\vert \phi\_{\textcolor{blue}{\vert i \rangle}} \rangle =& \frac{ \textcolor{red}{\vert 0 \rangle} \left(\vert S\_1 \rangle \vert S\_2 \rangle \textcolor{blue}{\pm} s U\_1\vert S\_1 \rangle U\_2 \vert S\_2 \rangle \right)}{\sqrt{2} \textcolor{red}{\sqrt{2}}}\\\\\\
+& \frac{\textcolor{red}{\vert 1 \rangle} \left(\vert S\_2 \rangle \vert S\_1 \rangle \textcolor{blue}{\pm} s U\_2\vert S\_2 \rangle U\_1 \vert S\_1 \rangle \right)}{\sqrt{2} \textcolor{red}{\sqrt{2}}},
\end{split}
\end{equation\*}

which will then finally be transformed by another \\(H\\) gate to

\begin{equation\*}
\begin{split}
\vert \phi\_{\textcolor{blue}{\vert i \rangle}} \rangle =& \frac{ \left(\textcolor{red}{\vert 0 \rangle + \vert 1 \rangle}\right) \left(\vert S\_1 \rangle \vert S\_2 \rangle \textcolor{blue}{\pm} s U\_1\vert S\_1 \rangle U\_2 \vert S\_2 \rangle \right)}{\sqrt{2} \times \textcolor{red}{2}} \\\\\\
+& \frac{\left(\textcolor{red}{\vert 0 \rangle - \vert 1 \rangle}\right) \left(\vert S\_2 \rangle \vert S\_1 \rangle \textcolor{blue}{\pm} s U\_2\vert S\_2 \rangle U\_1 \vert S\_1 \rangle \right)}{\sqrt{2} \times \textcolor{red}{2}}
\end{split}
\end{equation\*}

Factorising by the state of the virtual ancilla, we obtain the expression

\begin{equation\*}
\begin{split}
\vert \phi\_{\textcolor{blue}{\vert i \rangle}} \rangle =& \frac{ \textcolor{red}{\vert 0 \rangle} \left(\vert S\_1 \rangle \vert S\_2 \rangle + \vert S\_2 \rangle \vert S\_1 \rangle \textcolor{blue}{\pm} s U\_1\vert S\_1 \rangle U\_2 \vert S\_2 \rangle \textcolor{blue}{\pm} s U\_2\vert S\_2 \rangle U\_1 \vert S\_1 \rangle \right)}{2\sqrt{2}} \\\\\\
+& \frac{\textcolor{red}{\vert 1 \rangle} \left(\vert S\_1 \rangle \vert S\_2 \rangle - \vert S\_2 \rangle \vert S\_1 \rangle \textcolor{blue}{\pm} s U\_1\vert S\_1 \rangle U\_2 \vert S\_2 \rangle \textcolor{blue}{\mp} s U\_2\vert S\_2 \rangle U\_1 \vert S\_1 \rangle \right)}{2\sqrt{2}} \\\\\\
&\\\\\\
=& \frac{\textcolor{red}{\vert 0 \rangle} \vert \Phi\_{\textcolor{blue}{\vert i \rangle}}^\textcolor{red}{0} \rangle + \textcolor{red}{\vert 1 \rangle} \vert \Phi\_{\textcolor{blue}{\vert i \rangle}}^\textcolor{red}{1} \rangle}{2\sqrt{2}}
\end{split}
\end{equation\*}

Because of the introduction of the virtual ancilla qubit, the state
\\(\vert \phi\_{\textcolor{blue}{\vert i \rangle}} \rangle\\) is not exactly the state we would have with the
modified version of the SWAP test.

But wait! We did not performed all this maths for nothing. Thanks to the last expression of
\\(\vert \phi\_{\textcolor{blue}{\vert i \rangle}} \rangle\\), we are now able to compute the probability to have a
successful SWAP test: it is the probability to measure the virtual ancilla introduced in the
state \\(\textcolor{red}{\vert 0 \rangle}\\). And as the original SWAP test and its modified version are equivalent,
their probability of success (and failure) is the same.

Let call \\(P\_{\textcolor{blue}{\vert i \rangle}}(\textcolor{red}{0})\\) the probability of success of the modified SWAP test in the
Hadamard-Overlap circuit when the ancillary qubit was measured in the state \\(\textcolor{blue}{\vert i \rangle}\\).
Conversely, let call \\(P\_{\textcolor{blue}{\vert i \rangle}}(\textcolor{red}{1})\\) the probability of failure of the modified
SWAP test.

We have:

\begin{equation\*}
P\_{\textcolor{blue}{\vert i \rangle}}(\textcolor{red}{j}) = \frac{\langle \Phi\_{\textcolor{blue}{\vert i \rangle}}^\textcolor{red}{j} \vert \Phi\_{\textcolor{blue}{\vert i \rangle}}^\textcolor{red}{j} \rangle}{(2\sqrt{2})^2} = \frac{\langle \Phi\_{\textcolor{blue}{\vert i \rangle}}^\textcolor{red}{j} \vert \Phi\_{\textcolor{blue}{\vert i \rangle}}^\textcolor{red}{j} \rangle}{8}
\end{equation\*}

Computing the exact values of the \\(4\\) possible \\(P\_{\textcolor{blue}{\vert i \rangle}}(\textcolor{red}{j})\\) is quite easy as
long as you are not afraid of **long** formulas and you remember the following identities:

1.  \\(\langle \psi \vert U \vert \phi \rangle \in \mathbb{C}\\),
2.  \\(\left(\langle \psi \vert U \vert \phi \rangle\right)^\* = \langle \phi \vert U^\dagger \vert \psi \rangle\\),
3.  \\(\forall a \in \mathbb{C}, aa^\* = a^\*a = \vert a \vert^2\\),
4.  \\(\forall b \in \mathbb{C}, b + b^\* = 2\times\Re (b)\\),
5.  \\(\forall c \in \mathbb{C}, c - c^\* = 2\times\Im ( c)\\).

Once the computations done, you should find the following equalities:

\begin{equation\*}
\begin{split}
P\_{\textcolor{blue}{\vert 0 \rangle}}(\textcolor{red}{0}) &= \frac{1}{4} \left[ (1 + ss^\*) + \vert \langle S\_1 \vert S\_2 \rangle\vert^2 + ss^\* \vert \langle S\_1 \vert U\_1^\dagger U\_2 \vert S\_2 \rangle\vert^2 + d\_s + e\_s\right]\\\\\\
P\_{\textcolor{blue}{\vert 0 \rangle}}(\textcolor{red}{1}) &= \frac{1}{4} \left[ (1 + ss^\*) - \vert \langle S\_1 \vert S\_2 \rangle\vert^2 - ss^\* \vert \langle S\_1 \vert U\_1^\dagger U\_2 \vert S\_2 \rangle\vert^2 + d\_s - e\_s\right]\\\\\\
P\_{\textcolor{blue}{\vert 1 \rangle}}(\textcolor{red}{0}) &= \frac{1}{4} \left[ (1 + ss^\*) + \vert \langle S\_1 \vert S\_2 \rangle\vert^2 + ss^\* \vert \langle S\_1 \vert U\_1^\dagger U\_2 \vert S\_2 \rangle\vert^2 - d\_s - e\_s\right]\\\\\\
P\_{\textcolor{blue}{\vert 1 \rangle}}(\textcolor{red}{1}) &= \frac{1}{4} \left[ (1 + ss^\*) - \vert \langle S\_1 \vert S\_2 \rangle\vert^2 - ss^\* \vert \langle S\_1 \vert U\_1^\dagger U\_2 \vert S\_2 \rangle\vert^2 - d\_s + e\_s\right]
\end{split}
\end{equation\*}

with

\begin{equation\*}
\begin{split}
d\_s &= s \langle S\_2 \vert U\_2 \vert S\_2 \rangle \langle S\_1 \vert U\_1 \vert S\_1\rangle + \left( s \langle S\_2 \vert U\_2 \vert S\_2 \rangle \langle S\_1 \vert U\_1 \vert S\_1\rangle \right)^\*\\\\\\
&= 2 \times \Re \left( s \langle S\_2 \vert U\_2 \vert S\_2 \rangle \langle S\_1 \vert U\_1 \vert S\_1\rangle \right)
\end{split}
\end{equation\*}

\begin{equation\*}
\begin{split}
e\_s &= s \langle S\_2 \vert U\_1 \vert S\_1 \rangle \langle S\_1 \vert U\_2 \vert S\_2\rangle + \left( s \langle S\_2 \vert U\_1 \vert S\_1 \rangle \langle S\_1 \vert U\_2 \vert S\_2\rangle \right)^\*\\\\\\
&= 2 \times \Re \left( s \langle S\_2 \vert U\_1 \vert S\_1 \rangle \langle S\_1 \vert U\_2 \vert S\_2\rangle \right)
\end{split}
\end{equation\*}

Do you still remember our final goal ? It was to compute

\begin{equation\*}
c = \langle 0 \vert V\_2^\dagger U\_1 V\_1 \vert 0 \rangle \langle 0 \vert V\_1^\dagger
U\_2 V\_2 \vert 0 \rangle.
\end{equation\*}

Remember also that we defined \\(\vert S\_i \rangle = V\_i \vert 0 \rangle\\). Including this in the definition of \\(c\\),
we end up with

\begin{equation\*}
c = \langle S\_2 \vert U\_1 \vert S\_1 \rangle \langle S\_1 \vert U\_2 \vert S\_2 \rangle.
\end{equation\*}

So the quantity \\(e\_s\\) is directly linked to \\(c\\) by the equality

\begin{equation\*}e\_s = 2\times \Re(sc).\end{equation\*}

But remember! \\(s\\) is not any complex, it can only take two values: \\(1\\) when the \\(S^\dagger\\) gate is
not included in the Hadamard-Overlap circuit, \\(-i\\) otherwise. So we can compute the \\(2\\) possible values
for \\(e\_s\\):

\begin{equation\*}e\_1 = 2 \times \Re( c)\end{equation\*}

\begin{equation\*}e\_{-i} = 2 \times \Re(-ic) = 2 \times \Im( c)\end{equation\*}

Nice! This means that if we can estimate the values of \\(e\_1\\) and \\(e\_{-i}\\), we solve our problem!
And looking at the value of each \\(P\_{\textcolor{blue}{\vert i \rangle}}(\textcolor{red}{j})\\),
we solved our problem because

\begin{equation\*}e\_s = \left( P\_{\textcolor{blue}{\vert 0 \rangle}}(\textcolor{red}{0}) - P\_{\textcolor{blue}{\vert 0 \rangle}}(\textcolor{red}{1}) \right) - \left( P\_{\textcolor{blue}{\vert 1 \rangle}}(\textcolor{red}{0}) - P\_{\textcolor{blue}{\vert 1 \rangle}}(\textcolor{red}{1}) \right).\end{equation\*}

Using the identity

\begin{equation\*}P\_{\textcolor{blue}{\vert i \rangle}}(\textcolor{red}{0}) = 1 - P\_{\textcolor{blue}{\vert i \rangle}}(\textcolor{red}{1})\end{equation\*}

we can simplify this expression to

\begin{equation\*}e\_s = 2 \left( P\_{\textcolor{blue}{\vert 0 \rangle}}(\textcolor{red}{0}) - P\_{\textcolor{blue}{\vert 1 \rangle}}(\textcolor{red}{0}) \right).\end{equation\*}

In other words, estimating \\(c\\) boils down to estimating the probabilities of success of the destructive SWAP test performed in
the red squared part of the Hadamard-Overlap circuit for

-   each of the two possible outcomes when measuring the ancilla qubit,
-   and each of the possible values for \\(s\\) (i.e. \\(S^\dagger\\) gate applied and \\(S^\dagger\\) gate not applied).


## Summary of the method and conclusion {#summary-of-the-method-and-conclusion}


### Summary of the method {#summary-of-the-method}

To approximate \begin{equation\*}c = &lang; 0 &vert; V\_2^&dagger; U\_1 V\_1 &vert; 0 &rang; &lang; 0 &vert; V\_1^&dagger; U\_2 V\_2 &vert; 0 &rang;,\end{equation\*} the algorithm works in 2 steps:

1.  Approximate the real-part of \\(c\\).
2.  Approximate the imaginary-part of \\(c\\).

Both steps are exactly the same, except that for the first step you will not include the blue \\(S^\dagger\\) gate in the Hadamard-Overlap quantum circuit whereas
the gate should be included for the second step.

For both steps, you should:

1.  Execute the Hadamard-Overlap test circuit (with or without the blue \\(S^\dagger\\) gate depending on the step you are in). Save all the measurement bit-strings for the post-processing step.
2.  Once you have statistically enough measurement outcomes, separate them in two groups:
    1.  The measurements for which the ancilla qubit was measured in the state \\(\vert 0 \rangle\\).
    2.  The measurements for which the ancilla qubit was measured in the state \\(\vert 1 \rangle\\).
3.  For each group, estimate the probability of succeeding the SWAP test by computing the number of successful SWAP tests over the total number of tests performed.
4.  Subtract the estimated probability for the first group by the estimated probability for the second group. This is an estimation of the value you are searching for.


### Conclusion {#conclusion}

In this post I tried to clarify the post-processing step of the Hadamard-Overlap test because the explanation in the scientific
paper that introduced the algorithm was not sufficient for me to understand correctly the whole algorithm.

This was my first blog post ever. I hope you liked it! If you have **any** suggestion I would be very happy to hear about them, just
contact me :)


## Research articles cited in this post {#research-articles-cited-in-this-post}


### Variational quantum linear solver: A hybrid algorithm for linear systems {#variational-quantum-linear-solver-a-hybrid-algorithm-for-linear-systems}

Carlos Bravo-Prieto, Ryan LaRose, M. Cerezo, Yigit Subasi, Lukasz Cincio, Patrick J. Coles, “Variational quantum linear solver: A hybrid algorithm for linear systems” [arXiv:1909.05820 (2019)](<http://arxiv.org/abs/1909.05820v1>).


### SWAP test and Hong-Ou-Mandel effect are equivalent {#swap-test-and-hong-ou-mandel-effect-are-equivalent}

J. C. Garcia-Escartin and P. Chamorro-Posada, “SWAP test and Hong-Ou-Mandel effect are equivalent” [Phys. Rev. A 87, 052330 (2013)](<http://dx.doi.org/10.1103/PhysRevA.87.052330>).

[^1]: i.e. there exists a quantum circuit \\(C\\) such as \\(C\vert 0 \rangle = \vert x \rangle\\).
[^2]: I am still trying to find a good way to cite with
      [Hugo Academic](<https://sourcethemes.com/academic/>). Maybe an answer to
      [#830](<https://github.com/gcushen/hugo-academic/issues/830>) will make the process
      of citing scientific papers more writer & reader friendly. For the moment, all the
      research articles will be cited in the main text with their title and a link pointing
      to the article and at the end of the post with a format that mimics the usual citation
      format of research articles.
