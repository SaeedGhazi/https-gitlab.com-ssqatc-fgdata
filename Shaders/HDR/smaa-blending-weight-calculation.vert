/**
 * Adaptation of SMAA (Enhanced Subpixel Morphological Antialiasing)
 * for FlightGear.
 * See http://www.iryoku.com/smaa/ for details.
 * Licensed under the MIT license, see below.
 */

/**
 * Copyright (C) 2013 Jorge Jimenez (jorge@iryoku.com)
 * Copyright (C) 2013 Jose I. Echevarria (joseignacioechevarria@gmail.com)
 * Copyright (C) 2013 Belen Masia (bmasia@unizar.es)
 * Copyright (C) 2013 Fernando Navarro (fernandn@microsoft.com)
 * Copyright (C) 2013 Diego Gutierrez (diegog@unizar.es)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is furnished to
 * do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software. As clarification, there
 * is no requirement that the copyright notice and permission be included in
 * binary distributions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#version 330 core

#define SMAA_MAX_SEARCH_STEPS 16

#define mad(a, b, c) (a * b + c)

layout(location = 0) in vec4 pos;
layout(location = 3) in vec4 multiTexCoord0;

out vec2 texCoord;
out vec2 pixCoord;
out vec4 vOffset[3];

uniform mat4 osg_ModelViewProjectionMatrix;

uniform vec4 fg_Viewport;

#define SMAA_RT_METRICS vec4(1.0 / fg_Viewport.z, 1.0 / fg_Viewport.w, fg_Viewport.z, fg_Viewport.w)

void main()
{
    gl_Position = osg_ModelViewProjectionMatrix * pos;
    texCoord = multiTexCoord0.st;

    pixCoord = texCoord * SMAA_RT_METRICS.zw;

    // We will use these offsets for the searches later on (see @PSEUDO_GATHER4):
    vOffset[0] = mad(SMAA_RT_METRICS.xyxy, vec4(-0.25, -0.125, 1.25, -0.125), texCoord.xyxy);
    vOffset[1] = mad(SMAA_RT_METRICS.xyxy, vec4(-0.125,-0.25, -0.125, 1.25 ), texCoord.xyxy);

    // And these for the searches, they indicate the ends of the loops:
    vOffset[2] = mad(SMAA_RT_METRICS.xxyy,
                     vec4(-2.0, 2.0, -2.0, 2.0) * float(SMAA_MAX_SEARCH_STEPS),
                     vec4(vOffset[0].xz, vOffset[1].yw));
}
