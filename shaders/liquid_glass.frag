#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 uResolution;
    float uRadius;
    float uBezel;
    float uThickness;
    float uIOR;
    float uSpecular;
    float uTint;
    float uAlpha;
    float uHasBg;
    vec2 uWinOffset;
    vec2 uWinSize;
    float uBlur;
};

layout(binding = 1) uniform sampler2D uBgTex;

float sdRoundedRect(vec2 p, vec2 halfSize, float r) {
    vec2 q = abs(p) - halfSize + r;
    return min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - r;
}

float surfaceHeight(float t) {
    float s = 1.0 - t;
    return pow(max(0.0, 1.0 - s * s * s * s), 0.25);
}

vec3 sampleBgBlurred(vec2 uv, float radius) {
    vec3 sum = vec3(0.0);
    vec2 px = 1.0 / max(uWinSize, vec2(1.0));
    vec2 offsets[16];
    offsets[0]  = vec2(-0.94201, -0.39906);
    offsets[1]  = vec2( 0.94558, -0.76890);
    offsets[2]  = vec2(-0.09418, -0.92938);
    offsets[3]  = vec2( 0.34495,  0.29387);
    offsets[4]  = vec2(-0.91588, -0.45771);
    offsets[5]  = vec2(-0.81544,  0.48568);
    offsets[6]  = vec2(-0.38277, -0.56071);
    offsets[7]  = vec2(-0.12675,  0.84686);
    offsets[8]  = vec2( 0.89642,  0.41254);
    offsets[9]  = vec2( 0.18150, -0.30020);
    offsets[10] = vec2(-0.01445, -0.16001);
    offsets[11] = vec2( 0.59614,  0.71118);
    offsets[12] = vec2( 0.49742, -0.47280);
    offsets[13] = vec2( 0.80685,  0.04588);
    offsets[14] = vec2(-0.32490, -0.03965);
    offsets[15] = vec2(-0.60975,  0.06566);
    for (int i = 0; i < 16; i++) {
        sum += texture(uBgTex, clamp(uv + offsets[i] * radius * px, 0.001, 0.999)).rgb;
    }
    return sum / 16.0;
}

void main() {
    vec2 halfSize = uResolution * 0.5;
    vec2 p = (qt_TexCoord0 - 0.5) * uResolution;
    float r = min(uRadius, min(halfSize.x, halfSize.y));

    float sd = sdRoundedRect(p, halfSize, r);
    if (sd > 0.0) {
        discard;
    }

    float distFromEdge = -sd;
    float bezel = max(2.0, min(uBezel, r - 1.0));
    float t = clamp(distFromEdge / bezel, 0.0, 1.0);

    float h = surfaceHeight(t);
    float dt = 0.001;
    float h2 = surfaceHeight(min(t + dt, 1.0));
    float dh = (h2 - h) / dt;

    float slopeAngle = atan(dh * (uThickness / bezel));
    float sinR = clamp(sin(slopeAngle) / max(1.0, uIOR), -1.0, 1.0);
    float thetaR = asin(sinR);
    float displacement = h * uThickness * (tan(slopeAngle) - tan(thetaR));
    float fresnel = pow(1.0 - cos(slopeAngle - thetaR), 2.2);

    vec2 grad;
    float eps = 0.5;
    grad.x = sdRoundedRect(p + vec2(eps, 0.0), halfSize, r) - sd;
    grad.y = sdRoundedRect(p + vec2(0.0, eps), halfSize, r) - sd;
    float glen = length(grad);
    grad = glen > 0.0001 ? grad / glen : vec2(0.0, 1.0);

    vec2 lightDir = normalize(vec2(0.45, -0.75));
    float rimDot = max(0.0, abs(dot(grad, lightDir)));
    float rimFalloff = 1.0 - smoothstep(0.0, bezel * 0.55, distFromEdge);
    float specHighlight = pow(rimDot * rimFalloff, 1.4) * uSpecular;

    float innerRim = smoothstep(0.0, 1.8, distFromEdge) * (1.0 - smoothstep(1.8, 5.0, distFromEdge));
    float rimGlow = innerRim * 0.28 * uSpecular;

    float edgeMask = smoothstep(0.0, 1.5, distFromEdge);
    float glassAlpha = clamp(uAlpha, 0.02, 0.88);

    if (uHasBg > 0.5 && uWinSize.x > 1.0 && uWinSize.y > 1.0) {
        vec2 worldPx = uWinOffset + qt_TexCoord0 * uResolution;
        vec2 bgUV = worldPx / uWinSize;
        // Subtle convex lens magnification + strong Snell bezel refraction
        vec2 centerPull = (qt_TexCoord0 - 0.5) * uResolution * (-0.035 * h) / uWinSize;
        vec2 offset = -grad * displacement / uWinSize;
        vec2 refractedUV = bgUV + offset + centerPull;

        float blurRad = max(0.5, uBlur);
        // Chromatic aberration near curved glass edges
        float ca = (1.0 - t) * 0.45 + 0.06;
        float rCh = sampleBgBlurred(refractedUV + offset * ca, blurRad).r;
        float gCh = sampleBgBlurred(refractedUV, blurRad).g;
        float bCh = sampleBgBlurred(refractedUV - offset * ca, blurRad).b;
        vec3 color = vec3(rCh, gCh, bCh);

        // Darken/tint glass body according to Opacity setting
        color = mix(color, vec3(0.03, 0.04, 0.06), glassAlpha);
        color += vec3(0.92, 0.96, 1.0) * (specHighlight + rimGlow + fresnel * 0.38);

        float alpha = edgeMask * qt_Opacity;
        fragColor = vec4(color * alpha, alpha);
    } else {
        float sheen = (1.0 - qt_TexCoord0.y) * 0.06;
        vec3 tintColor = mix(vec3(0.03, 0.04, 0.06), vec3(0.95, 0.97, 1.0), uTint * 0.45);
        vec3 highlightColor = vec3(0.92, 0.96, 1.0) * (specHighlight + rimGlow + fresnel * 0.35 + sheen);
        float baseAlpha = glassAlpha + (1.0 - t) * 0.06;
        float outAlpha = clamp(baseAlpha + specHighlight * 0.65 + rimGlow * 0.6 + fresnel * 0.25, 0.0, 0.95) * edgeMask * qt_Opacity;
        vec3 finalRgb = tintColor * baseAlpha + highlightColor;
        fragColor = vec4(finalRgb * edgeMask * qt_Opacity, outAlpha);
    }
}
