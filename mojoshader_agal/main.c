#define WIN32_LEAN_AND_MEAN
#include <Windows.h>
#include <stdio.h>
#include <tchar.h>
#include <Shlwapi.h>

#include <io.h>
#include <fcntl.h>
#include <sys\stat.h>

#include <string>
#include <fstream>
#include <iostream>
#include <vector>

#include "mojoshader.h"

static const char* geometryVSVariations[] =
{
	"",
	"SKINNED ",
	"INSTANCED ",
	"BILLBOARD "
};

static const char* lightVSVariations[] =
{
	"PERPIXEL DIRLIGHT ",
	"PERPIXEL SPOTLIGHT ",
	"PERPIXEL POINTLIGHT ",
	"PERPIXEL DIRLIGHT SHADOW ",
	"PERPIXEL SPOTLIGHT SHADOW ",
	"PERPIXEL POINTLIGHT SHADOW ",
};

static const char* lightPSVariations[] =
{
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
};

static const char* vertexLightVSVariations[] =
{
	"",
	"NUMVERTEXLIGHTS=1 ",
	"NUMVERTEXLIGHTS=2 ",
	"NUMVERTEXLIGHTS=3 ",
	"NUMVERTEXLIGHTS=4 ",
};

static const char* shadowVariations[] =
{
#ifdef URHO3D_OPENGL
	// No specific hardware shadow compare variation on OpenGL, it is always supported
	"LQSHADOW ",
	"LQSHADOW ",
	"",
	""
#else
	"LQSHADOW SHADOWCMP",
	"LQSHADOW",
	"SHADOWCMP",
	""
#endif
};

static const char* heightFogVariations[] =
{
	"",
	"HEIGHTFOG "
};


static const char* deferredLightVSVariations[] =
{
	"",
	"DIRLIGHT ",
	"ORTHO ",
	"DIRLIGHT ORTHO "
};

/// Light vertex shader variations.
enum LightVSVariation
{
	LVS_DIR = 0,
	LVS_SPOT,
	LVS_POINT,
	LVS_SHADOW,
	LVS_SPOTSHADOW,
	LVS_POINTSHADOW,
	MAX_LIGHT_VS_VARIATIONS
};
/// %Geometry type.
enum GeometryType
{
	GEOM_STATIC = 0,
	GEOM_SKINNED = 1,
	GEOM_INSTANCED = 2,
	GEOM_BILLBOARD = 3,
	GEOM_STATIC_NOINSTANCING = 4,
	MAX_GEOMETRYTYPES = 4,
};

std::string file_path;

//字符串分割函数
std::vector<std::string> split(std::string str, std::string pattern)
{
	std::string::size_type pos;
	std::vector<std::string> result;
	str += pattern;//扩展字符串以方便操作
	int size = str.size();

	for (int i = 0; i<size; i++)
	{
		pos = str.find(pattern, i);
		if (pos<size)
		{
			std::string s = str.substr(i, pos - i);
			result.push_back(s);
			i = pos + pattern.size() - 1;
		}
	}
	return result;
}

int includeOpen(MOJOSHADER_includeType inctype,
	const char *fname, const char *parent,
	const char **outdata, unsigned int *outbytes,
	MOJOSHADER_malloc m, MOJOSHADER_free f, void *d)
{
	std::string file = file_path;
	file += fname;

	std::ifstream ifs_include;
	ifs_include.open(file.c_str());
	if (!ifs_include.is_open()){
		return 0;
	}

	std::string str((std::istreambuf_iterator<char>(ifs_include)),
		std::istreambuf_iterator<char>());
	ifs_include.close();

	*outbytes = str.size();
	char * context = (char *)m((*outbytes) + 1, d);
	strcpy(context, str.c_str());

	*outdata = context;

	return 1;
}
void includeClose(const char *data,
	MOJOSHADER_malloc m, MOJOSHADER_free f, void *d)
{
	f((void *)data, d);
}


int _tmain(int argc, _TCHAR* argv[])
{
	if (argc != 2){
		std::cout << "使用格式:mojoshader_agal 需转换的hlsl文件";
		getchar();
		return 0;
	}

	std::string path(argv[1]);
	int index = path.find_last_of("/");
	if (index < 0){
		std::cout << "无法获取路径";
		getchar();
		return 0;
	}

	path = path.substr(0, index + 1);
	file_path = path;

	std::ifstream ifs(argv[1]);
	if (!ifs.is_open()){
		std::cout << "打开文件 " << argv[1] << " 失败";
		getchar();
		return 0;
	}

	std::string str((std::istreambuf_iterator<char>(ifs)),
		std::istreambuf_iterator<char>());
	ifs.close();

	for (unsigned j = 0; j < MAX_GEOMETRYTYPES * MAX_LIGHT_VS_VARIATIONS; ++j)
	{
		unsigned g = j / MAX_LIGHT_VS_VARIATIONS;
		unsigned l = j % MAX_LIGHT_VS_VARIATIONS;

		std::string macro;
		macro = lightVSVariations[l];
		macro += geometryVSVariations[g];
		macro += "COMPILEVS ";
		macro += "SM3";

		std::vector<std::string> macros = split(macro, " ");

		std::vector<MOJOSHADER_preprocessorDefine> vecDefines;
		for (unsigned int i = 0; i < macros.size(); i++){
			MOJOSHADER_preprocessorDefine def = { macros[i].c_str(), "" };
			vecDefines.push_back(def);
		}
		const MOJOSHADER_preprocessData * data =
			MOJOSHADER_preprocess(argv[1], str.c_str(), str.size(), &vecDefines.front(), vecDefines.size(), 
			includeOpen, includeClose, NULL, NULL, NULL);
		if (data->error_count){
			std::cout << "预处理 " << argv[1] << "错误";
			for (unsigned int i = 0; i < data->error_count; i++){
				std::cout << data->errors[i].error;
			}
			getchar();
			return 0;
		}
		else{
			data->output;
		}
		MOJOSHADER_freePreprocessData(data);

		//const MOJOSHADER_compileData * cdata = 
		//MOJOSHADER_compile(MOJOSHADER_SRC_PROFILE_HLSL_VS_3_0, argv[1], str.c_str(), str.size(), &vecDefines.front(), vecDefines.size(),
		//	includeOpen, includeClose, NULL, NULL, NULL);
		//if (cdata->error_count){
		//	std::cout << "预处理 " << argv[1] << "错误\n";
		//	for (unsigned int i = 0; i < cdata->error_count; i++){
		//		std::cout << "文件[" << cdata->errors[i].filename << "]行[" << cdata->errors[i].error_position << "]" << cdata->errors[i].error << "\n";
		//	}
		//	getchar();
		//	return 0;
		//}
		//else{
		//	cdata->output;
		//}
		//MOJOSHADER_freeCompileData(cdata);
	}
	return 0;
}

