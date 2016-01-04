#IDM.jl
#A separate file for all the IDM stuff

#############
##IDM Model##
#############

immutable IDMParam
	a::Float64 #max  comfy acceleration
	b::Float64 #max comfy brake speed
	T::Float64 #desired safety time headway
	v0::Float64 #desired speed
	s0::Float64 #minimum headway (e.g. if x is less than this then you crashed)
	del::Float64 #'accel exponent'
end #IDMParam
==(a::IDMParam,b::IDMParam) = (a.a==b.a) && (a.b==b.b) &&(a.T == b.T)&&(a.v0==b.v0)&&(a.s0==b.s0)&&(a.del==b.del)
Base.hash(a::IDMParam,h::Uint64=zero(Uint64)) = hash(a.a,hash(a.b,hash(a.T,hash(a.v0,hash(a.s0,hash(a.del,h))))))


IDMParam(a::Float64,b::Float64,T::Float64,v0::Float64,s0::Float64;del::Float64=4.) = IDMParam(a,b,T,v0,s0,del)
function build_cautious_idm(v0::Float64,s0::Float64)
	T = 2.
	a = 1.
	b = 1.
	return IDMParam(a,b,T,v0,s0)
end

function build_aggressive_idm(v0::Float64,s0::Float64)
	T = 0.8
	a = 2.
	b = 2.
	return IDMParam(a,b,T,v0,s0)
end

function build_normal_idm(v0::Float64,s0::Float64)
	T = 1.4
	a = 1.5
	b = 1.5
	return IDMParam(a,b,T,v0,s0)
end

function IDMParam(s::String,v0::Float64,s0::Float64)
	if lowercase(s) == "cautious"
		return build_cautious_idm(v0,s0)
	elseif lowercase(s) == "normal"
		return build_normal_idm(v0,s0)
	elseif lowercase(s) == "aggressive"
		return build_aggressive_idm(v0,s0)
	else
		error("No such idm phenotype: \"$(s)\"")
	end
end

function get_idm_dv(p::IDMParam,dt::Float64,v::Float64,dv::Float64,s::Float64)
	s_ = s0 + max(0.,v*p.T+v*dv/(2*sqrt(p.a*p.b)))
	dvdt = p.a*(1-(v/p.v0)^p.del - (s_/s)^2)
	return dvdt*dt
end #get_idm_dv