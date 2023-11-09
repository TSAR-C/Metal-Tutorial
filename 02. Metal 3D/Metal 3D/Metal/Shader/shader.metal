//
//  shader.metal
//  Metal Startup
//
//  Created by TSAR Weasley on 2023/10/15.
//

#include <metal_stdlib>
using namespace metal;

struct Vertex {
    float3 position [[attribute(0)]];
    float4 color    [[attribute(1)]];
};

struct Uniform {
    float4x4 view;
    float4x4 projection;
};

struct RasterizerData {
    float4 position [[position]];
    float4 color;
};

[[vertex]] RasterizerData vertexShader(Vertex in [[stage_in]],
                                       constant float4x4& model [[buffer(1)]],
                                       constant Uniform& uniform [[buffer(2)]]) {
    RasterizerData out;
    out.position = uniform.projection * uniform.view * model * float4(in.position, 1.0);
    out.color = in.color;
    return out;
}

[[fragment]] float4 fragmentShader(RasterizerData in [[stage_in]]) {
    return in.color;
}
