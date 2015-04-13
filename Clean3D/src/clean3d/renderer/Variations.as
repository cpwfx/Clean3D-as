/**
 * Created by lighter on 2015/4/13.
 */
package clean3d.renderer {
public class Variations {

    public static const geometryVSVariations:Vector.<String> = new <String>[
        "",
        "SKINNED ",
        "INSTANCED ",
        "BILLBOARD "
    ];
    public static const lightVSVariations:Vector.<String> = new <String>[
        "PERPIXEL DIRLIGHT ",
        "PERPIXEL SPOTLIGHT ",
        "PERPIXEL POINTLIGHT ",
        "PERPIXEL DIRLIGHT SHADOW ",
        "PERPIXEL SPOTLIGHT SHADOW ",
        "PERPIXEL POINTLIGHT SHADOW ",
    ];

    public static const lightPSVariations:Vector.<String> = new <String>[
        "PERPIXEL DIRLIGHT ",
        "PERPIXEL SPOTLIGHT ",
        "PERPIXEL POINTLIGHT ",
        "PERPIXEL POINTLIGHT CUBEMASK ",
        "PERPIXEL DIRLIGHT SPECULAR ",
        "PERPIXEL SPOTLIGHT SPECULAR ",
        "PERPIXEL POINTLIGHT SPECULAR ",
        "PERPIXEL POINTLIGHT CUBEMASK SPECULAR ",
        "PERPIXEL DIRLIGHT SHADOW ",
        "PERPIXEL SPOTLIGHT SHADOW ",
        "PERPIXEL POINTLIGHT SHADOW ",
        "PERPIXEL POINTLIGHT CUBEMASK SHADOW ",
        "PERPIXEL DIRLIGHT SPECULAR SHADOW ",
        "PERPIXEL SPOTLIGHT SPECULAR SHADOW ",
        "PERPIXEL POINTLIGHT SPECULAR SHADOW ",
        "PERPIXEL POINTLIGHT CUBEMASK SPECULAR SHADOW "
    ];

    public static const vertexLightVSVariations:Vector.<String> = new <String>[
        "",
        "NUMVERTEXLIGHTS=1 ",
        "NUMVERTEXLIGHTS=2 ",
        "NUMVERTEXLIGHTS=3 ",
        "NUMVERTEXLIGHTS=4 ",
    ];

    public static const shadowVariations:Vector.<String> = new <String>[
        "LQSHADOW SHADOWCMP",
        "LQSHADOW",
        "SHADOWCMP",
        ""
    ];

    public static const heightFogVariations:Vector.<String> = new <String>[
        "",
        "HEIGHTFOG "
    ];


    public static const deferredLightVSVariations:Vector.<String> = new <String>[
        "",
        "DIRLIGHT ",
        "ORTHO ",
        "DIRLIGHT ORTHO "
    ];
}
}
