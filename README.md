# TypeParsers

Parse strings to types both securely and insecurely.

## Usage

```julia
julia> using TypeParsers
       parser = TypeParser(parametric)

       arraytype = parsetype(parser, "Array{Int,1}")
Array{Int64,1}

julia> array = arraytype()
0-element Array{Int64,1}
```

## Selecting the validator for your need

TypeParsers internally uses `eval()` which is inherently unsecure as it allows arbitrary code execution. (Read [ACE on wikipedia](https://en.wikipedia.org/wiki/Arbitrary_code_execution) for more info and [this discourse](https://discourse.julialang.org/t/parse-string-to-datatype/7118) for context)

To mitigate the issue we validate the string before evaluating. Regex based validators are available, or you can write your own.

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
 Allows to parse examples provided in https://discourse.julialang.org/t/parse-string-to-datatype/7118. *Probably unsecure, do not use it for untrusted input!*

### The `evil` validator
 Accepts any input. *WARNING! Parsing untrusted input using the evil validator leads to arbitrary code execution attacks. Never do it!*

 ## Writing your own validator

Either use `RegexValidator`:

```julia
 const strict = RegexValidator("Strict", r"^[\w][a-zA-Z0-9_]*$")
 ```

 or implement an `AbstractTypeValidator`. See `RegexValidator` as an example:

```julia
struct RegexValidator <: AbstractTypeValidator
    name::String
    regex::Regex
end
validate(validator::RegexValidator, str::AbstractString) = occursin(validator.regex, str)
```

# Contributing

Contributions are welcome!

For security issues please use the `security` label, share  your findings without the sensitive details and a request to get in to contact! Thank you very much!