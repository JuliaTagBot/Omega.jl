
## Soft Evaluation
## ===============
Cassette.@context SoftExCtx
Cassette.metadatatype(::Type{<:SoftExCtx}, ::Type{<:Number}) = Omega.SoftBool

soft(::typeof(>)) = softgt
soft(::typeof(>=)) = softgt
soft(::typeof(<)) = softlt
soft(::typeof(<=)) = softlt
soft(::typeof(==)) = softeq

function soften(f, ctx, args...)
  Cassette.tag(f(args...), ctx, soft(f)(args...))
end

function softboolop(f, ctx, args...)
  args_ = Cassette.untag.(args, ctx)
  tags = Cassette.metadata.(args, ctx)
  Cassette.tag(f(args_...), ctx, f(tags...))
end

Cassette.@primitive Base.:>(x, y) where {__CONTEXT__ <: SoftExCtx} = soften(>, __context__, x, y)
Cassette.@primitive Base.:>=(x, y) where {__CONTEXT__ <: SoftExCtx} = soften(>=, __context__, x, y)
Cassette.@primitive Base.:<(x, y) where {__CONTEXT__ <: SoftExCtx} = soften(<, __context__, x, y)
Cassette.@primitive Base.:<=(x, y) where {__CONTEXT__ <: SoftExCtx} = soften(<=, __context__, x, y)
# Cassette.@primitive Base.:(==)(x, y) where {__CONTEXT__ <: SoftExCtx} = soften(==, __context__, x, y)

Cassette.@primitive Base.:!(x::Bool) where {__CONTEXT__ <: SoftExCtx} = soften(!, __context__, x)
Cassette.@primitive Base.:&(x::Cassette.Tagged, y::Cassette.Tagged) where {__CONTEXT__ <: SoftExCtx} = softboolop(&, __context__, x, y)
Cassette.@primitive Base.:|(x, y) where {__CONTEXT__ <: SoftExCtx} = soften(|, __context__, x, y)
Cassette.@primitive Base.:⊻(x, y) where {__CONTEXT__ <: SoftExCtx} = soften(⊻, __context__, x, y)

function softapply(f, args...)
  ctx = Cassette.withtagfor(SoftExCtx(), f)
  res = Cassette.overdub(ctx, f, args...)
  Cassette.metadata(res, ctx)
end