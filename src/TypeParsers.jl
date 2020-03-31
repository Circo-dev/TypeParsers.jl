# SPDX-License-Identifier: LGPL-3.0-only
module TypeParsers

struct TypeParser{TValidator}
    validator::TValidator
end
validator(parser::TypeParser) = parser.validator
name(validator) = validator.name

struct RegexValidator
    name::String
    regex::Regex
end

const strict = RegexValidator("Strict", r"^[\w][a-zA-Z0-9_]*$")
const parametric = RegexValidator("Parametric", r"^[\w][a-zA-Z0-9_{},]*$")
const loose = RegexValidator("Loose", r"^[\w][a-zA-Z0-9_{},(): ]*$")
const modulenamevalidator = RegexValidator("Modulename", r"^([\w]+.)*[\w]+$")

validate(validator::RegexValidator, str::AbstractString) = occursin(validator.regex, str)

mutable struct EvilTypeValidator
    warned::Bool
    EvilTypeValidator(;suppresswarning=false) = new(suppresswarning)
end
name(::EvilTypeValidator) = "Evil"
function validate(validator::EvilTypeValidator, str::AbstractString)
    if !validator.warned
        @warn "EvilTypeValidator is not secure, do not use it for untrusted input! To suppress this warning, use TypeParser(EvilTypeValidator(true))"
        validator.warned = true
    end
    return true
end

const evil = EvilTypeValidator()

function parsetype(parser::TypeParser{TValidator}, str::AbstractString, modulename::Union{AbstractString,Nothing} = nothing)::Type where TValidator
    isnothing(modulename) || validate(modulenamevalidator, modulename) ||
        throw(ArgumentError("$modulename is not a valid module name"))
    validate(validator(parser), str) ||
        throw(ArgumentError("$str is not a valid type according to the '$(name(validator(parser)))' validator"))

    fullname = isnothing(modulename) ? "$str" : "$modulename.$str"
    return eval(Meta.parse(fullname))
end

export TypeParser, parsetype, strict, parametric, loose, RegexValidator, name, validate, evil, EvilTypeValidator

end
