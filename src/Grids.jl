module Grids
#    using DataTypes

    export StaggeredGrid2D, getExtrapolatedValue

    abstract Grid

    type StaggeredGrid2D <: Grid
        nx::Int
        ny::Int
        nu::Int
        nghost::Int
        np::Int
        dx::Real
        dy::Real
        sizes::Dict

        u_left::Vector{Real}
        u_bottom::Vector{Real}
        u_right::Vector{Real}
        u_top::Vector{Real}
        v_left::Vector{Real}
        v_bottom::Vector{Real}
        v_right::Vector{Real}
        v_top::Vector{Real}

        x::Vector{Real}
        y::Vector{Real}

        configure::Function
        init::Function
        createGrid::Function
        getLengths::Function
        getSizes::Function

        function StaggeredGrid2D()
            this = new()
            thisnghost = 1     # using 1 element for the ghost region in each direction

            this.configure = function(config_options_grid)
                this.nx = config_options_grid["nx"]
                this.ny = config_options_grid["ny"]
                this.x = linspace(0,config_options_grid["length"],this.nx+1)
                this.y = linspace(0,config_options_grid["height"],this.ny+1)
                this.dx = 1/this.nx
                this.dy = 1/this.ny
                this.sizes = Dict()
                this.sizes = ["u" => [this.nx-1,this.ny], "v" => [this.nx,this.ny-1], "p" => [this.nx,this.ny]]
            end #fun config

            this.init = function()
                this.nu = this.sizes["u"][1] * this.sizes["u"][2] + this.sizes["v"][1] * this.sizes["v"][2]
                this.np = this.sizes["p"][1] * this.sizes["p"][2]
                this.u_left     = ones(1,this.ny)
                this.u_bottom   = ones(1,this.nx-1)
                this.u_right    = ones(1,this.ny)
                this.u_top      = ones(1,this.nx-1)
                this.v_left     = ones(1,this.ny-1)
                this.v_bottom   = ones(1,this.nx)
                this.v_right    = ones(1,this.ny-1)
                this.v_top      = ones(1,this.nx)
            end #fun init

            this.getLengths = function()
                return this.nu, this.np
            end #fun getLengths

            this.getSizes = function()
                return this.sizes
            end #fun getSizes
            return this
        end
    end #type

    # linear extrapolation of value inside grid to next point in ghost region
    function getExtrapolatedValue(ubc,u)
        return 2.0*ubc-u
    end #fun

end #module
