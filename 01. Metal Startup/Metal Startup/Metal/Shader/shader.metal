//
//  shader.metal
//  Metal Startup
//
//  Created by TSAR Weasley on 2023/10/15.
//

#include <metal_stdlib>
using namespace metal;

struct Vertex {
    float2 position [[attribute(0)]];
    float4 color    [[attribute(1)]];
};

struct RasterizerData {
    float4 position [[position]];
    float4 color;
};

[[vertex]] RasterizerData vertexShader(Vertex in [[stage_in]]) {
    RasterizerData out;
    out.position = float4(in.position.x, in.position.y, 0.0, 1.0);
    out.color = in.color;
    return out;
}

[[fragment]] float4 fragmentShader(RasterizerData in [[stage_in]]) {
    return in.color;
}
