# ICFP Contest 2026

As I write this, it is 33 hours into the contest. So far, we have been using
an unstructured approach to write out solutions by hand. And we are hitting
a wall with the more complex problems. It seems time to change our strategy.

So far, we have been writing spaghetti (or, perhaps more fittingly, couscous)
code. What happened to structured programming? Where are our building blocks,
subroutines, modules?

The problems sets acutally lead us into the right direction: write components
with a given API for a specific task. We have components for **memory**,
**reversing** a list, **sorting** a list, **plotting lines**.

So one idea towards a more structured approach would be to develop more
of these modules, and/or make the existing ones more flexible (e.g., a memory
module with multiple inputs/outputs), and connect them together to solve
the harder problems.

Even if we were to use a compiler approach, we still would like our source
language to be structured, so it is likely a compiler would also produce
structured littleman code.

## Components

Which components do we need and how should their APIs look like?

Components can also be made up be smaller components, so perhaps
a virtual "meta"-box would be helpful.

TODO

## Connecting components

How do we lay out components so that the pipes are as short as possible?

Pipes may not cross, but it should be possible to have a component
that implements a crossed pipes. (TODO: build one)

## Writing single components

So far, we have not used all available instructions. But they are probably
there for a reason. Looking at the instruction frequency in 7 of the solutions
we have submitted so far (History lesson intentionally omitted), some
instructions are rare or unused:

    s :  164
    + :  142 (includes box corners)
    r :   95
    M :   41
    W :   33
    b :   27
    m :   22
    d :   19
    ] :   13
    X :   11
    a :    9
    N :    8
    x :    5
    H :    4
    S :    3 (only lazyness, could have used s)
    * :    2
    { :    1

Unused so far: q, R, U, Y, %, &, |, ~, }.

(- and the direction instructions >, <, ^, v omitted because of use in pipes and boxes).

It's ok that we have not used **Y** so far, but the absence of **S**, **R**, and **U**
seems suspicious.

**S** could be used to duplicate a pipe, **R** could be used
to join pipes, and so on.