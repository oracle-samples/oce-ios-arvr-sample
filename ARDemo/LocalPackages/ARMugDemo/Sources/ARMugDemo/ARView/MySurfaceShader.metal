// Copyright (c) 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

#include <metal_stdlib>
#include <RealityKit/RealityKit.h>

using namespace metal;

// Utilized by the Mug demo to remove pixels that fall below at 50% alpha
// Using a transparent image as the decal for a Mug introduced some "filming".
// The net result is that "transparent" areas were, in fact, not truly transparent
// This shader solves that problem by removing pixels that fall below a 50% transparent value
constexpr sampler textureSampler(coord::normalized,
                                  address::repeat,
                                  filter::linear,
                                  mip_filter::nearest);

[[visible]]
void mySurfaceShader(realitykit::surface_parameters params)
{
    float2 uv = params.geometry().uv0();
    uv.y = 1.0 - uv.y; // Flip the coordinates for loaded models.
    auto tex = params.textures();
    
    half4 color = tex.base_color()
                      .sample(textureSampler, uv);
    
    if (color.a < 0.5) {
        discard_fragment();
    }
    
    params.surface().set_base_color(color.rgb);
}

