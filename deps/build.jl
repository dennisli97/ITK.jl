using BinaryProvider

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))

libpath = joinpath(@__DIR__, "usr/ITK")

products = Product[
    LibraryProduct(libpath,["libitk"], :libitk)
    ]

# Download binaries from hosted location
bin_prefix = "https://github.com/cj-mclaughlin/ITK.jl/releases/download/5.0.1-initial"

download_info = Dict(
    Linux(:x86_64)  => ("$bin_prefix/JuliaITKv0.tar.gz", "37c6922f96675d7d577c13e9d5771a3aa159b8103bb8f6d4585b904fb5293f97"),
)

# First, check to see if we're all satisfied
@show satisfied(products[1]; verbose=true)
if any(!satisfied(p; verbose=false) for p in products)
    try
        # Download and install binaries
        url, tarball_hash = choose_download(download_info)
        install(url, tarball_hash; prefix=prefix, force=true, verbose=true)
    catch e
        if typeof(e) <: ArgumentError || typeof(e) <: MethodError
            error("Your platform $(Sys.MACHINE) is not supported by this package!")
        else
            rethrow(e)
        end
    end

    # Finally, write out a deps.jl file
    write_deps_file(joinpath(@__DIR__, "deps.jl"), products)
end
