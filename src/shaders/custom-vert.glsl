#version 300 es

//This is a vertex shader. While it is called a "shader" due to outdated conventions, this file
//is used to apply matrix transformations to the arrays of vertex data passed to it.
//Since this code is run on your GPU, each vertex is transformed simultaneously.
//If it were run on your CPU, each vertex would have to be processed in a FOR loop, one at a time.
//This simultaneous transformation allows your program to run much faster, especially when rendering
//geometry with millions of vertices.

uniform mat4 u_Model;       // The matrix that defines the transformation of the
                            // object we're rendering. In this assignment,
                            // this will be the result of traversing your scene graph.

uniform mat4 u_ModelInvTr;  // The inverse transpose of the model matrix.
                            // This allows us to transform the object's normals properly
                            // if the object has been non-uniformly scaled.

uniform mat4 u_ViewProj;    // The matrix that defines the camera's transformation.
                            // We've written a static matrix for you to use for HW2,
                            // but in HW3 you'll have to generate one yourself

uniform float u_Time;

in vec4 vs_Pos;             // The array of vertex positions passed to the shader

in vec4 vs_Nor;             // The array of vertex normals passed to the shader

in vec4 vs_Col;             // The array of vertex colors passed to the shader.

out vec4 fs_Nor;            // The array of normals that has been transformed by u_ModelInvTr. This is implicitly passed to the fragment shader.
out vec4 fs_LightVec;       // The direction in which our virtual light lies, relative to each vertex. This is implicitly passed to the fragment shader.
out vec4 fs_Col;            // The color of each vertex. This is implicitly passed to the fragment shader.
out vec4 fs_Pos;

const vec4 lightPos = vec4(5.0, 5.0, 3.0, 1.0); //The position of our virtual light, which is used to compute the shading of
                                        //the geometry in the fragment shader.

mat3 rotateY(float rad) {
    float c = cos(rad);
    float s = sin(rad);
    return mat3(
        c, 0.0, -s,
        0.0, 1.0, 0.0,
        s, 0.0, c
    );
}

mat3 rotateX(float rad) {
    float c = cos(rad);
    float s = sin(rad);
    return mat3(
        1.0, 0.0, 0.0,
        0.0, c, s,
        0.0, -s, c
    );
}

void main()
{
    fs_Col = vs_Col;                         // Pass the vertex colors to the fragment shader for interpolation

    float r = 3.0;
    float t = (cos(u_Time * 0.005) + 1.0) / 2.0;

    vec3 newPos = normalize(vs_Pos.xyz) * r;
    vec3 interpPos = mix(vs_Pos.xyz, newPos, t);

    vec3 newNor = normalize(vs_Pos.xyz);
    vec3 interpNor = normalize(mix(vs_Nor.xyz, newNor, t));

    fs_Pos = vs_Pos;

    mat3 invTranspose = mat3(u_ModelInvTr);
    //fs_Nor = vec4(invTranspose * vec3(vs_Nor), 0.0);          // Pass the vertex normals to the fragment shader for interpolation.
                                                            // Transform the geometry's normals by the inverse transpose of the
                                                            // model matrix. This is necessary to ensure the normals remain
                                                            // perpendicular to the surface after the surface is transformed by
                                                            // the model matrix.

    float angle = u_Time * 0.002;
    mat3 rotMatrix = rotateY(angle) * rotateX(angle * 0.5);

    vec3 rotatedPos = rotMatrix * interpPos;
    vec3 rotatedNor = rotMatrix * interpNor;

    fs_Nor = vec4(invTranspose * rotatedNor, 0.0);

    vec4 finalModelPos = u_Model * vec4(rotatedPos, 1.0);
    fs_LightVec = lightPos - finalModelPos;
    gl_Position = u_ViewProj * finalModelPos;
}



