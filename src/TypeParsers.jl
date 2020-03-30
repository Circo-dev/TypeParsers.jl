module TypeParsers

abstract type AbstractTypeParser end
abstract type AbstractTypeValidator end
name(v::AbstractTypeValidator) = v.name

struct TypeParser{TValidator <: AbstractTypeValidator} <: AbstractTypeParser
    validator::TValidator
end
validator(parser::TypeParser) = parser.validator

struct RegexValidator <: AbstractTypeValidator
    name::String
    regex::Regex
end

const strict = RegexValidator("Strict", r"^[\w][a-zA-Z0-9_]*$")
const parametric = RegexValidator("Parametric", r"^[\w][a-zA-Z0-9_{},]*$")
const loose = RegexValidator("Loose", r"^[\w][a-zA-Z0-9_{},(): ]*$")
const modulenamevalidator = RegexValidator("Modulename", r"^([\w]+.)*[\w]+$")

validate(validator::RegexValidator, str::AbstractString) = occursin(validator.regex, str)

struct EvilTypeValidator <: AbstractTypeValidator
    name::String
end
validate(validator::EvilTypeValidator, str::AbstractString) = true

const evil = EvilTypeValidator("Evil")

function parsetype(parser::TypeParser{TValidator}, str::AbstractString, modulename::Union{AbstractString,Nothing}=nothing)::Type where TValidator
    if !isnothing(modulename) && !validate(modulenamevalidator, modulename)
        throw(ArgumentError("$modulename is not a valid module name"))
    end
    if !validate(parser.validator, str)
        throw(ArgumentError("$str is not a valid type according to the '$(name(parser.validator))' validator"))
    end
    fullname = isnothing(modulename) ? "$str" : "$modulename.$str"
    return eval(Meta.parse(fullname))
end

export AbstractTypeValidator, TypeParser, strict, parametric, loose, evil, RegexValidator, validate, parsetype

end
