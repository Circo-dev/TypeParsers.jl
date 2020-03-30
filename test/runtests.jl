using Test
using TypeParsers


@testset "TypeParsers" begin
    strictparser = TypeParser(strict)
    arraytype = parsetype(strictparser, "Array")
    @test arraytype === Array
    @test_throws ArgumentError parsetype(strictparser, "Array{Int}")

    parametricparser = TypeParser(parametric)
    arraytype = parsetype(parametricparser, "Array{Int,1}")
    @test arraytype === Array{Int64,1}
    @test_throws ArgumentError parsetype(parametricparser, "Array{()}")

    looseparser = TypeParser(loose)
    @test parsetype(looseparser, "Val{()}") === Val{()}
    @test parsetype(looseparser, "Val{(1,)}") === Val{(1,)}
    @test parsetype(looseparser, "Val{(1,:a)}") === Val{(1,:a)}
    @test parsetype(looseparser, "Val{(1,:a,pi)}") === Val{(1,:a,pi)}
    @test_throws ArgumentError parsetype(looseparser, "f=42")
end