cmake_minimum_required(VERSION 2.8)

include_directories(../include)
include_directories(../src/mesa)
include_directories(../src/glsl)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-exceptions -fno-rtti -O3 -DNDEBUG -DUNIX")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fno-exceptions -fno-rtti -O3 -DNDEBUG -DUNIX")
option (SDK "Path to the Alchemy2 SDK" "/path/to/alchemy2/sdk")

file(GLOB mesa_sources ../src/mesa/program/*.c)
file(GLOB glsl_sources ../src/glsl/*.cpp ../src/glsl/*.c)
file(GLOB glsl_sources_remove ../src/glsl/main.cpp ../src/glsl/builtin_stubs.cpp ../src/glsl/swc.cpp)
list(REMOVE_ITEM glsl_sources ${glsl_sources_remove})

add_library(glsl2agal ${mesa_sources} ${glsl_sources})

#add_custom_target(agal_optimizer COMMAND cd ../agaloptimiser/src && SDK=${SDK} bash genabc.sh && cd ../../swc && mv ../agaloptimiser/src/agaloptimiser.abc agaloptimiser.abc)

add_custom_target(swc ALL COMMAND g++ -fno-exceptions -fno-rtti -O3 -flto-api=exports.txt -emit-swc=com.adobe.glsl2agal -o glsl2agal.swc swc.cpp libglsl2agal.a -I../include -I../src/mesa -I../src/glsl DEPENDS glsl2agal)

#add_custom_target(glsl2agalopt ALL COMMAND g++ -DCMDLINE=1 -fno-exceptions -fno-rtti --enable-debug -O4 -flto-api=exports.txt -o glsl2agalopt agaloptimiser.abc swc.cpp libglsl2agal.a -I../include -I../src/mesa -I../src/mapi -I../src/glsl DEPENDS glsl2agal agal_optimizer)

