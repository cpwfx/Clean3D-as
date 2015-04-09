/*
** ADOBE SYSTEMS INCORPORATED
** Copyright 2012 Adobe Systems Incorporated
** All Rights Reserved.
**
** NOTICE:  Adobe permits you to use, modify, and distribute this file in accordance with the
** terms of the Adobe license agreement accompanying it.  If you have received this file from a
** source other than Adobe, then your use, modification, or distribution of it requires the prior
** written permission of Adobe.
*/
#define MAX_JOINTS	255
#define JOINT_POSE_LEN	4*7
#define JOINT_BIND_LEN	4*12
#define WORLD_MATRICES_LEN	4*12
#define BLEND_WEIGHTS	0.8f
#define PARTICLE_JOINT_LEN	4*5+1
#define MAX_JOINT_PARTICLES	255	
#define VEC3_LEN	4*3
#define MATRIX_LEN	4*16
#define BIND_PARAM_LEN	4*20
#define BIND_RESULT_LEN	4*16
#define BIND_COUNT_MAX	20

typedef int Boolean;

int examineBytes(const unsigned char* buffer, int bufferSize);

void poseLocalToWorld(const unsigned char* localPose,const unsigned char* worldPose,const unsigned char* parentIndices,unsigned int numJoints);
void updateGlobalProperties(const unsigned char* worldPose,const unsigned char* inverseBindPose,unsigned char* globalMatrices,unsigned int numJoints,Boolean useDualQuat);
void differencePose(const unsigned char* currentPose,const unsigned char* nextPose,const unsigned char* targetPose,unsigned int numJoints,float blendWeight,Boolean highQuality);
void slerpPose(const unsigned char* currentPose,const unsigned char* nextPose,const unsigned char* targetPose,unsigned int numJoints,float blendWeight,Boolean highQuality);
void transformVector(const unsigned char* jointPose,float position[3],float target[3]);
void jointPoseToMatrix(const unsigned char* jointPose,float mat[16]);
void transformVectors(const unsigned char* pose,const unsigned char* particleJoints,unsigned int numParticles,unsigned char* dv);
void generateDifferencePose(const unsigned char* sourcePose,const unsigned char* reference,const unsigned char* differencePose,unsigned int numJoints);
void updateJointsBindInfo(const unsigned char* pose,const unsigned char* bindParams,unsigned char* bindResults,unsigned int bindCount);
int getParticleJointSize();


void updatePoseMatricesAndSkinDatas(
	unsigned char* jointPoseMatrices,
	unsigned char* jointSkinDatas,

	const unsigned char* animationPoses,
	const unsigned char* parentIndices,
	const unsigned char* inverseBindPose,

	unsigned int frame,
	unsigned int numJoints,
	Boolean useDualQuat
	);

void getCondensedSkinDatas(
	unsigned char* condensedSkinDatas,

	const unsigned char* jointSkinDatas,
	const unsigned char* jointsMap,

	unsigned int numJointsMap,
	Boolean useDualQuat
	);

void getCondensedPoseMatrices(
	unsigned char* condensedPoseMatrices,
	
	const unsigned char* jointPoseMatrices,
	const unsigned char* jointsMap,
	unsigned int numJointsMap
	);
void copyFrame(unsigned char* dst_matrices,unsigned char* dst_poses,unsigned char* src_matrices,unsigned char* src_poses,unsigned int matricesLen,unsigned int posesLen);
