# TypeParsers

Parse strings to types securely or insecurely.

## Motivation

Retrieving a type from a serialized string is a recurring task. Sometimes it is enough to store everything in a dict, but if we want more flexibility, we need a parser. Unfortunately, the expressive type system of Julia makes it hard to parse type declarations. For example, the following are valid types:
- `Val{(1,:a)}` [(from a discourse)](https://discourse.julialang.org/t/parse-string-to-datatype/7118) 
- `TestLayer{RedirectLayer{BasicAuthLayer{MessageLayer{RetryLayer{ExceptionLayer{ConnectionPoolLayer{StreamLayer{Union{}}}}}}}}}` [(in HTTP.jl)](https://github.com/JuliaWeb/HTTP.jl/blob/master/test/insert_layers.jl)

We want to read types like these from disk and send them over the network and we cannot always use Julia serialization because of compatibility issues. `eval()` solves the problem, but it has a huge cost: it is inherently insecure as it allows arbitrary code execution ([ACE on wikipedia](https://en.wikipedia.org/wiki/Arbitrary_code_execution)).

TypeParsers takes the easy route (for now) and internally uses `eval()`. To mitigate the security issue we validate the string before evaluation. Regex based validators are available to balance between security and flexibility, or you can write your own.

## Usage

```julia
julia> parser = TypeParser(parametric)
TypeParser{RegexValidator}(RegexValidator("Parametric", r"^[\w][a-zA-Z0-9_{},]*$"))

julia> parsedtype = parsetype(parser, "Array{Int,1}")
Array{Int64,1}

julia> array = parsedtype()
0-element Array{Int64,1}
```

Optionally provide the name of a module:

```julia
julia> parsedtype = parsetype(parser, "RegexValidator", "TypeParsers")
RegexValidator

julia> parsedtype("My validator", r"^MyPrefix_[a-zA-Z0-9_{}]*$")
RegexValidator("My validator", r"^MyPrefix_[a-zA-Z0-9_{}]*$")
```

Module names are also validated using the regex `r"^([\w]+.)*[\w]+$"`.


## Selecting the validator for your need

### The `strict` validator
The `strict` validator allows only simple nonparametric type names, like `MyStruct`. It is safe to use when parsing untrusted input. Its regex is `r"^[\w][a-zA-Z0-9_]*$"`

```julia
julia> parsetype(TypeParser(strict), "Int")
Int64
```

### The `parametric` validator
 Allows to parse parametric types like `Array{Int,1}` and union types like `Union{Nothing, Int}`. *The `parametric` validator is probably safe to use for untrusted inputs, but no extensive work was done to disprove this statement.* Its regex is `r"^[\w][a-zA-Z0-9_{},]*$")`

```julia
julia> parsetype(TypeParser(parametric), "Array{Int}")
Array{Int64,N} where N
```

### The `loose` validator
 Allows to parse examples provided in https://discourse.julialang.org/t/parse-string-to-datatype/7118. *Probably insecure, do not use it for untrusted input!*

### The `evil` validator
 Accepts any input. *WARNING! Parsing untrusted input using the evil validator leads to arbitrary code execution attacks. Never do it!*

 The evil validator prints a security warning at the first parse. To suppress it, use:

```julia
 parser = TypeParser(EvilTypeValidator(;suppresswarning=true))
 ```

 ## Writing your own validator

Either use `RegexValidator`:

```julia
 strict = RegexValidator("Strict", r"^[\w][a-zA-Z0-9_]*$")
 ```

 or implement the simple validator interface. See `RegexValidator` as an example:

```julia
struct RegexValidator
    name::String
    regex::Regex
end
validate(validator::RegexValidator, str::AbstractString) = occursin(validator.regex, str)
```

# Contributing

Contributions are welcome!

For security issues please use the `security` label, share  your findings without the sensitive details and request to get in to contact! Thank you very much!