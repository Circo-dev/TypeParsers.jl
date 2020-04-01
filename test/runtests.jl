using Test
using TypeParsers

@testset "TypeParsers" begin
    @test_throws ArgumentError parsetype("42")
    @test_throws ArgumentError parsetype("f=42")
    @test_throws ArgumentError parsetype("run(`ls`)")
    @test_throws ArgumentError parsetype("using Base")
    @test_throws ArgumentError parsetype("Something that shouldn't parse")
    @test parsetype("Int64") === Int64
    @test parsetype("Array") === Array
    @test parsetype("Array{Int,1}") === Array{Int64,1}
    @test parsetype("Val{()}") === Val{()}
    @test parsetype("Val{(1,)}") === Val{(1,)}
    @test parsetype("Val{(1,:a)}") === Val{(1,:a)}
    @test parsetype("Val{(1,:a,pi)}") === Val{(1,:a,pi)}
end