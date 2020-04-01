# SPDX-License-Identifier: LGPL-3.0-only

# Based on https://gist.github.com/tshort/3835660

module TypeParsers

is_valid_type_ex(::QuoteNode) = true
is_valid_type_ex(::Symbol) = true
is_valid_type_ex(::Int) = true
is_valid_type_ex(e::Expr) = (e.head == :curly || e.head == :tuple || e.head == :.) && all(map(is_valid_type_ex, e.args))

function parsetype(s::String)::Type
    try
        parsed = Meta.parse(s)
        if is_valid_type_ex(parsed) 
            evaled = eval(parsed)
            evaled isa Type && return evaled
        end
    catch e
    end
    throw(ArgumentError("'$s' is not a valid type descriptor"))
end

export parsetype

end
