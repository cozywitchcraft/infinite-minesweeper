local Math = {}

function Math.round(n: number, d: number): number
	return math.floor(n * d) / d
end

function Math.lerp(a: number, b: number, t: number): number
	return t * (b - a) + a
end

function Math.invLerp(a: number, b: number, v: number): number
	return (v - a) / (b - a)
end

function Math.remap(a1: number, b1: number, a2: number, b2: number, v: number): number
	return Math.lerp(a2, b2, Math.invLerp(a1, b1, v))
end

return Math