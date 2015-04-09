#include <Windows.h>
#include <stdlib.h>

#include "flash3dlib.h"
#include "mathdefine.h"

int main(int argc, char* argv[])
{
	pq _pq = {{0.47577768564224243f,109.45722961425781f,-32.236080169677734f},
		{0.13974523544311523,0.6931604146957397,0.6931604743003845,-0.13974516093730927}};
	vec3 v = {27.835433959960938f,-10.99075984954834f,13.938671112060547};
	vec3 t = {0.f,0.f,0.f};
	transformVector((const unsigned char *)&_pq,(float*)&v,(float*)&t);







	
	/*const unsigned char* localPose = (const unsigned char*)malloc(sizeof(pq)*JOINT_POSE_LEN*MAX_JOINTS);
	const unsigned char* worldPose = (const unsigned char*)malloc(sizeof(pq)*JOINT_POSE_LEN*MAX_JOINTS);
	const unsigned char* parentIndices = (const unsigned char*)malloc(sizeof(unsigned char)*MAX_JOINTS);
	unsigned int numJoints = 111;
	
	poseLocalToWorld(localPose,worldPose,parentIndices,numJoints);*/
	return 0;
}