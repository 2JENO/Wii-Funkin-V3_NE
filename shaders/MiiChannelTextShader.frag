#pragma header

void main()
{
    vec4 col = flixel_texture2D(bitmap, openfl_TextureCoordv);
    col.r = mix(0.33 * col.a, col.r, col.r);
    col.g = mix(0.43 * col.a, col.g, col.g);
    col.b = mix(0.42 * col.a, col.b, col.b);
    gl_FragColor = col;
}