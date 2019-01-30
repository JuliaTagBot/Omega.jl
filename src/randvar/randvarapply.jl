# Random Variable Application

"Post-projection application"
function ppapl end

"Apply function to argument"
function apl end


"Apply if randvar otherwise just return value (treat as constant randvar"
subapl(x, ω) = x
@inline subapl(rv::RandVar, ω) = apl(rv, ω)

"Project ω to `x`"
proj(ω::ΩBase, x::RandVar) = ω[x.id][1] # FIXME, change to ω[x.id, 1]

proj(tω::TaggedΩ, x::RandVar) = tag(proj(tω.taggedω, x), tω.tags)
@spec _res.tags == tω.tags "tags are preserved in projection"

"Project `ω` to `rv` then apply"
@inline apl(rv::RandVar, ω::ΩBase) =  ppapl(rv, proj(ω, rv))

"Reproject back to parent random variable"
@inline apl(rv::RandVar, πω::ΩProj) = apl(rv, parentω(πω))

"Reify arguments (resolve random variables to values)"
@inline reify(ω, args) = map(x -> subapl(x, ω), args)
@spec all([r isa elemtype(a) for (a, r) in zip(args, _res)])

# TODO use generated function to avoid runtime iteration in reify

# "Reify random variable args.. i.e. map(x -> apl(x, ω), args)"
# @generated function reify(ω, args)
#   if any(isa.(args RandVar))
#     map(t -> t isa RandVar, args)
#     quote
#       (apl(x, ))
#     end
#   else
#     quote
#       args
#     end
#   end
# end

@inline apl(rv::RandVar, tω::TaggedΩ{I, T, ΩT}) where {I, T, ΩT <: ΩProj}  =
  rv(TaggedΩ(parentω(tω.taggedω), tω.tags))

# Shell
proj(sω::Space.ShellΩ, rv::RandVar) = shell(proj(sω.ω, rv), sω)
Space.parentω(sπω::Space.ShellΩ{I, <: ΩProj}) where I = shell(parentω(sπω.ω), sπω)
@inline apl(rv::RandVar, sπω::Space.ShellΩ{I, <: ΩProj}) where I = apl(rv, parentω(sπω))
@inline apl(rv::RandVar, sω::Space.ShellΩ{I, <: ΩBase}) where I =  ppapl(rv, proj(sω, rv))
