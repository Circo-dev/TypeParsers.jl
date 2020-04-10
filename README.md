# TypeParsers

[![Build Status](https://travis-ci.com/Circo-dev/TypeParsers.jl.svg?branch=master)](https://travis-ci.com/Circo-dev/TypeParsers.jl)

Parse strings to Julia types securely (types only, not typed data!).

## Motivation

Retrieving a type from a serialized string is a recurring task. Sometimes we can use Julia serialization, other times it is enough to store every serialized type in a dict, but if we want more flexibility, we need a parser. `eval()` solves the problem, but it has a huge cost: it is inherently insecure as it allows arbitrary code execution ([ACE on wikipedia](https://en.wikipedia.org/wiki/Arbitrary_code_execution)).

TypeParsers takes the easy route and internally uses `eval()`. To mitigate the security issue we validate the string before evaluation.
Validation is based on Tom Short's work: https://gist.github.com/tshort/3835660 (check the [validation tests](https://github.com/Circo-dev/TypeParsers.jl/blob/master/test/runtests.jl))

## Usage

```julia
julia> parsedtype = parsetype("Array{Int,1}")
Array{Int64,1}

julia> parsedtype === parsetype("Base.Array{Int,1}")
true

julia> array = parsedtype()
0-element Array{Int64,1}
```

You can also pass a module as the second argument.

# Contributing

Contributions are welcome!

For security issues please use the `security` label, share  your findings without the sensitive details and request to get in to contact! Thank you very much!
