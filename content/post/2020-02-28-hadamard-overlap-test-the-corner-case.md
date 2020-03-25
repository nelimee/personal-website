+++
title = "Hadamard-Overlap test – the corner case"
author = ["Adrien Suau"]
date = 2020-02-28
draft = true
toc = true
+++

_This post follows a [previous post]({{< ref "/post/2020-02-05-understanding-the-hadamard-overlap-test.md" >}})_
_on this blog. I will assume that you read the first post and refer to it without re-introducing thoroughly the_
_notions. You are warned._

{{% toc %}}

I introduced in a
[previous post]({{< ref "/post/2020-02-05-understanding-the-hadamard-overlap-test.md" >}})
my explanation of the Hadamard-Overlap test, a modification of the well known
[Hadamard-test](<https://en.wikipedia.org/wiki/Hadamard%5Ftest%5F(quantum%5Fcomputation)>) that has been
introduced in the scientific paper
[Variational Quantum Linear Solver: A Hybrid Algorithm for Linear Systems](<http://arxiv.org/abs/1909.05820v1>).

The Hadamard-Overlap test is useful to estimate the quantity

\begin{equation\*}
c = \langle 0 \vert V\_2^\dagger U\_1 V\_1 \vert 0 \rangle \langle 0 \vert V\_1^\dagger
U\_2 V\_2 \vert 0 \rangle,
\end{equation\*}

with \\(U\_1\\), \\(U\_2\\), \\(V\_1\\) and \\(V\_2\\) being unitary matrices.

{{< figure
library="true"
src="hadamard-overlap-test.png"
title="Quantum circuit implementing the Hadamard-Overlap test."
lightbox="true" >}}

The motivation behind the theoretical development in
[Understanding the Hadamard-Overlap test]({{< ref "/post/2020-02-05-understanding-the-hadamard-overlap-test.md" >}})
was to be able to implement the algorithm, with the final goal
of being able to run the Variational Quantul Linear System (VQLS) algorithm on a
quantum simulator, and then on real quantum hardware.


## A first test-case {#a-first-test-case}

Once the implementation of the Hadamard-Overlap test and VQLS done, the next step was to test it
on a simple example. I chose the example given in the original paper
[Variational Quantum Linear Solver: A Hybrid Algorithm for Linear Systems](<http://arxiv.org/abs/1909.05820v1>):

\begin{equation\*} Ax = b \end{equation\*}

with

\begin{equation\*} A = 1\\!\\!1 + 0.2 X\_1Z\_2 + 0.2 X\_1 \end{equation\*}

and

\begin{equation\*} b = H\_1 H\_3 H\_4 H\_5 \vert 0 \rangle^{\otimes 5}. \end{equation\*}

{{< figure
library="true"
src="hadamard-overlap-test-bug.png"
title="One of the quantum circuits obtained when applying the VQLS algorithm on the linear system described in this section."
lightbox="true" >}}

This test-case turned out to be a very good test-case as it exhibited a situation I did not think
about at first glance: what if \\(U\_1\\), \\(U\_2\\), \\(V\_1\\) and \\(V\_2\\) are such that the outcome \\(o\_a\\) of the
measurement on the ancilla qubit is always \\(\vert 0 \rangle\\)? And what about an outcome that is always
\\(\vert 1 \rangle\\)? It turned out that this first test-case raised this issue.

If you remember, one step of the Hadamard-Overlap test as presented in the previous post was to estimate
the probabilities \\(P\_{\textcolor{blue}{\vert 0 \rangle}}(\textcolor{red}{0})\\) and
\\(P\_{\textcolor{blue}{\vert 1 \rangle}}(\textcolor{red}{0})\\), representing the chance of success of the
destructive SWAP-test when the ancilla qubit has been measured in the state
\\(\textcolor{blue}{\vert 0 \rangle}\\) or \\(\textcolor{blue}{\vert 1 \rangle}\\). This means that if we do not
have any measurement showing the ancilla qubit in one of the two states, we will not be able to estimate
either \\(P\_{\textcolor{blue}{\vert 0 \rangle}}(\textcolor{red}{0})\\) or \\(P\_{\textcolor{blue}{\vert 1 \rangle}}(\textcolor{red}{0})\\).
In other words, the algorithm described in the previous post fails.


## Analysis of the problem {#analysis-of-the-problem}

We now know why the algorithm fail in some circumstances: the output of the Hadamard-test at the beginning of the
algorithm is deterministically \\(\vert 0 \rangle\\) or \\(\vert 1 \rangle\\). But what are the unitary matrices \\(U\_1\\), \\(U\_2\\),
\\(V\_1\\) and \\(V\_2\\) such that the Hadamard-test is deterministic?

The outcome on the ancilla qubit of the Hadamard-test is used to estimate the quantity
\\(\Re \left( s \langle 0 \vert V^\dagger U V \vert 0 \rangle \right)\\) where

\begin{equation\*}
s = \left\\{\begin{split}
-i & \quad \text{if } S^\dagger \text{ gate applied in the Hadamard-test} \\\\\\
1 & \quad \text{otherwise}
\end{split}\right. .
\end{equation\*}

In this post, it will be easier to write down \\(s\\) as a complex exponential of angle \\(\theta\_s\\): \\(s = e^{i\theta\_s}\\)
with

\begin{equation\*}
\theta\_s = \left\\{\begin{split}
-\frac{\pi}{2} & \quad \text{if } S^\dagger \text{ gate applied in the Hadamard-test} \\\\\\
0 & \quad \text{otherwise}
\end{split}\right. .
\end{equation\*}

If the output of the ancilla qubit is deterministically \\(\vert 0 \rangle\\) (resp \\(\vert 1 \rangle\\)),
this means that \\(U\\) and \\(V\\) satisfies

\begin{equation}
\label{eq:1}
\Re \left( s \langle 0 \vert V^\dagger U V \vert 0 \rangle \right) = 1 \text{ (resp. }-1\text{ )}.
\end{equation}

{{% alert note %}}
As in the previous post, I will use the \\(\textcolor{mediumseagreen}{\pm}\\) and
\\(\textcolor{mediumseagreen}{\mp}\\) notations.
In this case, the only-\\(\vert 0 \rangle\\) output will be represented by the upper sign whereas
the lower sign will represent the only-\\(\vert 1 \rangle\\) output.

For example, if you see the equation \\(e = \textcolor{mediumseagreen}{\mp} 1\\), this means that the value of
\\(e\\) is \\(-1\\) if we measured an only-\\(\vert 0 \rangle\\) output and \\(1\\) if we measured an only-\\(\vert 1 \rangle\\)
output.
{{% /alert %}}

Reformulating equation \eqref{eq:1} with the \\(\textcolor{mediumseagreen}{\pm}\\) notation, \\(U\\) and \\(V\\) should satisfy

\begin{equation\*}
\Re \left( s \langle 0 \vert V^\dagger U V \vert 0 \rangle \right) = \textcolor{mediumseagreen}{\pm}1 .
\end{equation\*}

In our specific case, we also have \\(U = U\_1 \otimes U\_2\\) and \\(V = V\_1 \otimes V\_2\\), which
leads to

\begin{equation\*}
\Re \left( s \langle 0 \vert V\_1^\dagger U\_1 V\_1 \vert 0 \rangle \langle 0 \vert V\_2^\dagger U\_2 V\_2 \vert 0 \rangle \right) = \textcolor{mediumseagreen}{\pm}1 .
\end{equation\*}

Re-introducing the quantum states \\(\vert S\_1 \rangle = V\_1 \vert 0 \rangle\\) and \\(\vert S\_2 \rangle = V\_2 \vert 0 \rangle\\), we
obtain the equation

\begin{equation}
\label{eq:2}
\Re \left( s \langle S\_1 \vert U\_1 \vert S\_1 \rangle \langle S\_2 \vert U\_2 \vert S\_2 \rangle \right) = \textcolor{mediumseagreen}{\pm}1 .
\end{equation}

The values \\(\langle S\_j \vert U\_j \vert S\_j \rangle\\) for \\(i = 1,2\\) are complex numbers. Let

\begin{equation}
\label{eq:3}
\alpha\_j = r\_j e^{i \theta\_j} = \langle S\_j \vert U\_j \vert S\_j \rangle , \qquad \forall i \in \left\\{ 1, 2 \right\\}.
\end{equation}

As the \\(\vert S\_j \rangle\\) are quantum states and the \\(U\_j\\) are unitary matrices, we have the following inequalities:

\begin{equation}
\label{eq:4}
0 \leqslant \left\vert\alpha\_j\right\vert = r\_j = \left\vert\langle S\_j \vert U\_j \vert S\_j \rangle\right\vert \leqslant 1 , \qquad \forall i \in \left\\{ 1, 2 \right\\}.
\end{equation}

Inserting equation \eqref{eq:3} into equation \eqref{eq:2} and using the equality \\(s = e^{i\theta\_s}\\) gives us

\begin{equation}
\label{eq:5}
\Re \left( r\_1 r\_2 e^{i\left( \theta\_s + \theta\_1 + \theta\_2 \right)} \right) = r\_1 r\_2 \cos\left( \theta\_s + \theta\_1 + \theta\_2 \right) = \textcolor{mediumseagreen}{\pm}1 .
\end{equation}

Using equations \eqref{eq:4} and \eqref{eq:5} it is easy to show that \\(r\_1 = r\_2 = 1\\). Moreover, depending on the value of the ancilla qubit of the Hadamard-test, we have

\begin{equation}
\label{eq:6}
\theta\_s + \theta\_1 + \theta\_2 = \left\\{
\begin{split}
0 & \text{ if all-}\vert 0 \rangle\text{ output} \\\\\\
\pi & \text{ if all-}\vert 1 \rangle\text{ output}
\end{split}
\right.
\end{equation}

Using the fact that \\(r\_j = 1\\) and equation \eqref{eq:3} we have \\(\vert\langle S\_j \vert U\_j \vert S\_j \rangle\vert = 1\\), which implies that

\begin{equation}
\label{eq:7}
U\_j \vert S\_j \rangle = e^{i\theta\_j} \vert S\_j \rangle.
\end{equation}

So here is the answer! The Hadamard-Overlap post-processing described in
[Understanding the Hadamard-Overlap test]({{< ref "/post/2020-02-05-understanding-the-hadamard-overlap-test.md" >}})
is not valid when the state prepared by \\(V\_1\\) (resp. \\(V\_2\\)) is an eigenstate of \\(U\_1\\) (resp. \\(U\_2\\)).


## Adapting the Hadamard-Overlap algorithm {#adapting-the-hadamard-overlap-algorithm}

Now that we understood the problem, it should be fixed. The first step will be to re-do the computations of
[Understanding the Hadamard-Overlap test]({{< ref "/post/2020-02-05-understanding-the-hadamard-overlap-test.md" >}})
in order to
