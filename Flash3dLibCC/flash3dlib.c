// Copyright (c) 2013 Adobe Systems Inc

// Permission is hereby granted, free of charge, to adualQuat->qn.y person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF AdualQuat->qn.y KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR AdualQuat->qn.y CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#include "flash3dlib.h"
#include "mathdefine.h"
#include <stdlib.h>
#include <string.h>
#include <math.h>

int examineBytes(const unsigned char* buffer, int bufferSize){
	int i;
	int stupidSum = 0;
	
	for (i = 0; i < bufferSize; i++){
		stupidSum += *buffer;
		buffer++;
	}
	return stupidSum;
}
void poseLocalToWorld(const unsigned char* localPose,const unsigned char* worldPose,const unsigned char* parentIndices,unsigned int numJoints)
{
	unsigned int i;
	unsigned char parentIndex;
	pq * parentPose;
    pq * pose;
	pq * world_Pose;

	float x1, y1, z1, w1;
    float x2, y2, z2, w2;
    float x3, y3, z3;

	for (i = 0; i < numJoints; ++i) {
		parentIndex = parentIndices[i];
		pose = (pq*)localPose + i;
		world_Pose = (pq*)worldPose + i;
		if(parentIndex == (unsigned char)-1){
			*world_Pose = *pose;
		}else{
			parentPose = (pq*)worldPose + parentIndex;

            // rotate point
			x2 = parentPose->q.x;
            y2 = parentPose->q.y;
            z2 = parentPose->q.z;
            w2 = parentPose->q.w;
            x3 = pose->p.x;
            y3 = pose->p.y;
            z3 = pose->p.z;

            w1 = -x2*x3 - y2*y3 - z2*z3;
            x1 = w2*x3 + y2*z3 - z2*y3;
            y1 = w2*y3 - x2*z3 + z2*x3;
            z1 = w2*z3 + x2*y3 - y2*x3;

            // append parent translation
            world_Pose->p.x = -w1*x2 + x1*w2 - y1*z2 + z1*y2 + parentPose->p.x;
            world_Pose->p.y = -w1*y2 + x1*z2 + y1*w2 - z1*x2 + parentPose->p.y;
            world_Pose->p.z = -w1*z2 - x1*y2 + y1*x2 + z1*w2 + parentPose->p.z;

            // append parent orientation
            x1 = parentPose->q.x;
            y1 = parentPose->q.y;
            z1 = parentPose->q.z;
            w1 = parentPose->q.w;
            x2 = pose->q.x;
            y2 = pose->q.y;
            z2 = pose->q.z;
            w2 = pose->q.w;

			world_Pose->q.w = w1*w2 - x1*x2 - y1*y2 - z1*z2;
            world_Pose->q.x = w1*x2 + x1*w2 + y1*z2 - z1*y2;
            world_Pose->q.y = w1*y2 - x1*z2 + y1*w2 + z1*x2;
            world_Pose->q.z = w1*z2 + x1*y2 - y1*x2 + z1*w2;
		}
	}
}

void writeGlobalMatrices(float matrix[12],unsigned char* globalMatrices)
{
	memcpy(globalMatrices,matrix,sizeof(float)*12);
}
void writeGlobalDualQuat(float matrix[12],unsigned char* globalMatrices)
{
	dual_quat * dualQuat = (dual_quat *)globalMatrices;

    float mTrace = matrix[0] + matrix[5] + matrix[10];
    float s	= 0.0f;

    if (mTrace > 0.f)
    {
        s = 2.0f * sqrtf(mTrace + 1.0f);
        dualQuat->qn.w = 0.25f * s;
        dualQuat->qn.x = (matrix[9] - matrix[6]) / s;
        dualQuat->qn.y = (matrix[2] - matrix[8]) / s;
        dualQuat->qn.z = (matrix[4] - matrix[1]) / s;
    }
    else if (matrix[0] > matrix[5] && matrix[0] > matrix[10])
    {
        s = 2.0f * sqrtf(1.0f + matrix[0] - matrix[5] - matrix[10]);

        dualQuat->qn.w = (matrix[9] - matrix[6]) / s;
        dualQuat->qn.x = 0.25f * s;
        dualQuat->qn.y = (matrix[1] + matrix[4]) / s;
        dualQuat->qn.z = (matrix[2] + matrix[8]) / s;
    }
    else if (matrix[5] > matrix[10])
    {
        s = 2.0f * sqrtf(1.0 + matrix[5] - matrix[0] - matrix[10]);

        dualQuat->qn.w = (matrix[2] - matrix[8]) / s;
        dualQuat->qn.x = (matrix[1] + matrix[4]) / s;
        dualQuat->qn.y = 0.25f * s;
        dualQuat->qn.z = (matrix[6] + matrix[9]) / s;
    }
    else
    {
        s = 2.0f * sqrtf(1.0 + matrix[10] - matrix[0] - matrix[5]);

        dualQuat->qn.w = (matrix[4] - matrix[1]) / s;
        dualQuat->qn.x = (matrix[2] + matrix[8]) / s;
        dualQuat->qn.y = (matrix[6] + matrix[9]) / s;
        dualQuat->qn.z = 0.25f * s;
    }
	dualQuat->qd.x = ( 0.5f * ( matrix[3] * dualQuat->qn.w + matrix[7] * dualQuat->qn.z - matrix[11] * dualQuat->qn.y) );
    dualQuat->qd.y = ( 0.5f * (-matrix[3] * dualQuat->qn.z + matrix[7] * dualQuat->qn.w + matrix[11] * dualQuat->qn.x) );
    dualQuat->qd.z = ( 0.5f * ( matrix[3] * dualQuat->qn.y - matrix[7] * dualQuat->qn.x + matrix[11] * dualQuat->qn.w) );
    dualQuat->qd.w = (-0.5f * ( matrix[3] * dualQuat->qn.x + matrix[7] * dualQuat->qn.y + matrix[11] * dualQuat->qn.z) );
}

float tempMatrix[12];

void updateGlobalProperties(const unsigned char* worldPose,const unsigned char* inverseBindPose,unsigned char* globalMatrices,unsigned int numJoints,Boolean useDualQuat)
{
	unsigned int i;
	pq * world_Pose;

	float ox, oy, oz, ow;
    float xy2, xz2, xw2;
    float yz2, yw2, zw2;
    float n11, n12, n13;
    float n21, n22, n23;
    float n31, n32, n33;
    matrix12trans * inverseBind;
	float t;

	for (i = 0; i < numJoints; ++i) {
		world_Pose = (pq*)worldPose + i;

		ox = world_Pose->q.x;
        oy = world_Pose->q.y;
        oz = world_Pose->q.z;
        ow = world_Pose->q.w;

        xy2 = (t = 2.0f*ox)*oy;
        xz2 = t*oz;
        xw2 = t*ow;
        yz2 = (t = 2.0f*oy)*oz;
        yw2 = t*ow;
        zw2 = 2.0f*oz*ow;

        yz2 = 2.0f*oy*oz;
        yw2 = 2.0f*oy*ow;
        zw2 = 2.0f*oz*ow;
        ox *= ox;
        oy *= oy;
        oz *= oz;
        ow *= ow;

        n11 = (t = ox - oy) - oz + ow;
        n12 = xy2 - zw2;
        n13 = xz2 + yw2;
        n21 = xy2 + zw2;
        n22 = -t - oz + ow;
        n23 = yz2 - xw2;
        n31 = xz2 - yw2;
        n32 = yz2 + xw2;
        n33 = -ox - oy + oz + ow;

		// prepend inverse bind pose
		inverseBind = (matrix12trans *)inverseBindPose + i;

		tempMatrix[0] = (n11*inverseBind->m11 + n12*inverseBind->m21 + n13*inverseBind->m31);
        tempMatrix[1] = (n11*inverseBind->m12 + n12*inverseBind->m22 + n13*inverseBind->m32);
        tempMatrix[2] = (n11*inverseBind->m13 + n12*inverseBind->m23 + n13*inverseBind->m33);
		tempMatrix[3] = (n11*inverseBind->m14 + n12*inverseBind->m24 + n13*inverseBind->m34 + world_Pose->p.x);
        tempMatrix[4] = (n21*inverseBind->m11 + n22*inverseBind->m21 + n23*inverseBind->m31);
        tempMatrix[5] = (n21*inverseBind->m12 + n22*inverseBind->m22 + n23*inverseBind->m32);
        tempMatrix[6] = (n21*inverseBind->m13 + n22*inverseBind->m23 + n23*inverseBind->m33);
        tempMatrix[7] = (n21*inverseBind->m14 + n22*inverseBind->m24 + n23*inverseBind->m34 + world_Pose->p.y);
        tempMatrix[8] = (n31*inverseBind->m11 + n32*inverseBind->m21 + n33*inverseBind->m31);
        tempMatrix[9] = (n31*inverseBind->m12 + n32*inverseBind->m22 + n33*inverseBind->m32);
        tempMatrix[10] = (n31*inverseBind->m13 + n32*inverseBind->m23 + n33*inverseBind->m33);
        tempMatrix[11] = (n31*inverseBind->m14 + n32*inverseBind->m24 + n33*inverseBind->m34 + world_Pose->p.z);

		if(useDualQuat){
			writeGlobalDualQuat(tempMatrix,globalMatrices + i * sizeof(dual_quat));		
		}else{
			writeGlobalMatrices(tempMatrix,globalMatrices + i * sizeof(matrix12));		
		}
	}
}



void quat_multiply(quat * qa, quat * qb, quat * qr)
{
	qr->w = qa->w*qb->w - qa->x*qb->x - qa->y*qb->y - qa->z*qb->z;
	qr->x = qa->w*qb->x + qa->x*qb->w + qa->y*qb->z - qa->z*qb->y;
	qr->y = qa->w*qb->y - qa->x*qb->z + qa->y*qb->w + qa->z*qb->x;
	qr->z = qa->w*qb->z + qa->x*qb->y - qa->y*qb->x + qa->z*qb->w;
}
void quat_lerp(quat * q1, quat * q2, float t,quat * q)
{
	float len;
	// shortest direction
	if (q1->w*q2->w + q1->x*q2->x + q1->y*q2->y + q1->z*q2->z < 0) {
		q2->w = -q2->w;
		q2->x = -q2->x;
		q2->y = -q2->y;
		q2->z = -q2->z;
	}
			
	q->w = q1->w + t*(q2->w - q1->w);
	q->x = q1->x + t*(q2->x - q1->x);
	q->y = q1->y + t*(q2->y - q1->y);
	q->z = q1->z + t*(q2->z - q1->z);
			
	len = 1.0f/sqrtf(q->w*q->w + q->x*q->x + q->y*q->y + q->z*q->z);
	q->w *= len;
	q->x *= len;
	q->y *= len;
	q->z *= len;
}

void quat_slerp(quat * q1, quat * q2, float t,quat * q){
	float dot,len,angle,s1,s2,s;
		
	dot	= q1->w*q2->w + q1->x*q2->x + q1->y*q2->y + q1->z*q2->z;
			
	// shortest direction
	if (dot < 0) {
		dot = -dot;
		q2->w = -q2->w;
		q2->x = -q2->x;
		q2->y = -q2->y;
		q2->z = -q2->z;
	}
			
	if (dot < 0.95) {
		// interpolate angle linearly
		angle = acosf(dot);
		s = 1.f/sinf(angle);
		s1 = sinf(angle*(1.f - t))*s;
		s2 = sinf(angle*t)*s;
		q->w = q1->w*s1 + q2->w*s2;
		q->x = q1->x*s1 + q2->x*s2;
		q->y = q1->y*s1 + q2->y*s2;
		q->z = q1->z*s1 + q2->z*s2;
	} else {
		// nearly identical angle, interpolate linearly
		q->w = q1->w + t*(q2->w - q1->w);
		q->x = q1->x + t*(q2->x - q1->x);
		q->y = q1->y + t*(q2->y - q1->y);
		q->z = q1->z + t*(q2->z - q1->z);
		len = 1.0f/sqrtf(q->w*q->w + q->x*q->x + q->y*q->y + q->z*q->z);
		q->w *= len;
		q->x *= len;
		q->y *= len;
		q->z *= len;
	}
}

void differencePose(const unsigned char* currentPose,const unsigned char* nextPose,const unsigned char* targetPose,unsigned int numJoints,float blendWeight,Boolean highQuality)
{
    pq * pose1,*pose2,*endPose;
	quat _tempQuat;
	unsigned int i;

    for (i = 0; i < numJoints; ++i) {
        pose1 = (pq*)currentPose + i;
		pose2 = (pq*)nextPose + i;
		endPose = (pq*)targetPose + i;

		quat_multiply(&pose2->q, &pose1->q,&_tempQuat);
        if (highQuality)
            quat_slerp(&pose1->q, &_tempQuat, blendWeight,&endPose->q);
        else
            quat_lerp(&pose1->q, &_tempQuat, blendWeight,&endPose->q);

        if (i > 0) {
			endPose->p.x = pose1->p.x + blendWeight*(pose2->p.x - pose1->p.x);
            endPose->p.y = pose1->p.y + blendWeight*(pose2->p.y - pose1->p.y);
            endPose->p.z = pose1->p.z + blendWeight*(pose2->p.z - pose1->p.z);
        }
    }
}
void slerpPose(const unsigned char* currentPose,const unsigned char* nextPose,const unsigned char* targetPose,unsigned int numJoints,float blendWeight,Boolean highQuality)
{
    pq * pose1,*pose2,*endPose;
	unsigned int i;

    for (i = 0; i < numJoints; ++i) {
        pose1 = (pq*)currentPose + i;
		pose2 = (pq*)nextPose + i;
		endPose = (pq*)targetPose + i;

        if (highQuality)
            quat_slerp(&pose1->q, &pose2->q, blendWeight,&endPose->q);
        else
            quat_lerp(&pose1->q, &pose2->q, blendWeight,&endPose->q);

        if (i > 0) {
			endPose->p.x = pose1->p.x + blendWeight*(pose2->p.x - pose1->p.x);
            endPose->p.y = pose1->p.y + blendWeight*(pose2->p.y - pose1->p.y);
            endPose->p.z = pose1->p.z + blendWeight*(pose2->p.z - pose1->p.z);
        }
    }
}

// use 4*3 matrix for calc
void transformVector(const unsigned char* jointPose,float position[3],float target[3])
{
	vec3 * vector = (vec3 *)position;
	vec3 * result = (vec3 *)target;

	pq * jpose = (pq * )jointPose;
	float xy2 = 2.0f*jpose->q.x*jpose->q.y, xz2 = 2.0f*jpose->q.x*jpose->q.z, xw2 = 2.0f*jpose->q.x*jpose->q.w;
	float yz2 = 2.0f*jpose->q.y*jpose->q.z, yw2 = 2.0f*jpose->q.y*jpose->q.w, zw2 = 2.0f*jpose->q.z*jpose->q.w;
	float xx = jpose->q.x*jpose->q.x, yy = jpose->q.y*jpose->q.y, zz = jpose->q.z*jpose->q.z, ww = jpose->q.w*jpose->q.w;
			
	float a = xx - yy - zz + ww;
	float e = xy2 + zw2;
	float i = xz2 - yw2;
	float b = xy2 - zw2;
	float f = -xx + yy - zz + ww;
	float j = yz2 + xw2;
	float c = xz2 + yw2;
	float g = yz2 - xw2;
	float k = -xx - yy + zz + ww;
	float d = jpose->p.x;
	float h = jpose->p.y;
	float l = jpose->p.z;

	result->x = a * vector->x + b * vector->y + c * vector->z + d;
	result->y = e * vector->x + f * vector->y + g * vector->z + h;
	result->z = i * vector->x + j * vector->y + k * vector->z + l;
}
// to 4x4 Matrix
void jointPoseToMatrix(const unsigned char* jointPose,float mat[16])
{
	pq * jpose = (pq * )jointPose;
	float xy2 = 2.0f*jpose->q.x*jpose->q.y, xz2 = 2.0f*jpose->q.x*jpose->q.z, xw2 = 2.0f*jpose->q.x*jpose->q.w;
	float yz2 = 2.0f*jpose->q.y*jpose->q.z, yw2 = 2.0f*jpose->q.y*jpose->q.w, zw2 = 2.0f*jpose->q.z*jpose->q.w;
	float xx = jpose->q.x*jpose->q.x, yy = jpose->q.y*jpose->q.y, zz = jpose->q.z*jpose->q.z, ww = jpose->q.w*jpose->q.w;
			
	mat[0] = xx - yy - zz + ww;
	mat[1] = xy2 + zw2;
	mat[2] = xz2 - yw2;
	
	mat[4] = xy2 - zw2;
	mat[5] = -xx + yy - zz + ww;
	mat[6] = yz2 + xw2;
	
	mat[8] = xz2 + yw2;
	mat[9] = yz2 - xw2;
	mat[10] = -xx - yy + zz + ww;
	
	mat[12] = jpose->p.x;
	mat[13] = jpose->p.y;
	mat[14] = jpose->p.z;

	mat[3] = 0.0f;
	mat[7] = 0.0f;
	mat[11] = 0.0f;
	mat[15] = 1.f;
}
void transformVectors(const unsigned char* pose,const unsigned char* particleJoints,unsigned int numParticles,unsigned char* dv)
{
	pq * jpose;
	particle_joint * p;
	vec3 * dp;
	unsigned int i;
    for (i = 0; i < numParticles; ++i) {
		p = (particle_joint*)particleJoints + i;
		if(p->boneIdx != (unsigned char)-1){
			jpose = (pq*)pose + p->boneIdx;
			dp = (vec3*)dv + i;
			transformVector((const unsigned char*)jpose,(float*)&p->p,(float*)dp);
		}else{
			*dp = p->p; 
		}
	}
}
void generateDifferencePose(const unsigned char* sourcePose,const unsigned char* reference,const unsigned char* differencePose,unsigned int numJoints)
{
    pq * srcPose,*refPose,*diffPose;
    matrix mtx,tempMtx;
	unsigned int i;

    for (i = 0; i < numJoints; ++i) {
		srcPose = (pq*)sourcePose + i;
		refPose = (pq*)reference + i;
		diffPose = (pq*)differencePose + i;

        jointPoseToMatrix((const unsigned char*)refPose,(float*)&mtx);
		jointPoseToMatrix((const unsigned char*)srcPose,(float*)&tempMtx);
        
		/*mtx.invert();
        mtx.append(srcPose.toMatrix3D(tempMtx));
		vec = mtx.decompose(Orientation3D.QUATERNION);

		diffPose.translation.copyFrom(vec[0]);
        diffPose.orientation.x = vec[1].x;
        diffPose.orientation.y = vec[1].y;
        diffPose.orientation.z = vec[1].z;
        diffPose.orientation.w = vec[1].w;*/
    }
}
void updateJointsBindInfo(const unsigned char* pose,const unsigned char* bindParams,unsigned char* bindResults,unsigned int bindCount)
{
	unsigned int i;
	pq * world_Pose;
	joint_bind_param * bind_params;
	joint_bind_result * bind_results;

	float ox, oy, oz, ow;
    float xy2, xz2, xw2;
    float yz2, yw2, zw2;
    float n11, n12, n13;
    float n21, n22, n23;
    float n31, n32, n33;
    matrix * inverseBind;
	float t;

	for (i = 0; i < bindCount; ++i) {
		// 输入参数
		bind_params = (joint_bind_param *)bindParams + i;
		// 输出参数
		bind_results = (joint_bind_result *)bindResults + i;

		// prepend inverse bind pose
		inverseBind = &bind_params->m;

		if(bind_params->joint >= 0){
			// 全局 pose
			world_Pose = (pq*)pose + bind_params->joint;

			// 全局 pose 矩阵
			ox = world_Pose->q.x;
			oy = world_Pose->q.y;
			oz = world_Pose->q.z;
			ow = world_Pose->q.w;

			xy2 = (t = 2.0f*ox)*oy;
			xz2 = t*oz;
			xw2 = t*ow;
			yz2 = (t = 2.0f*oy)*oz;
			yw2 = t*ow;
			zw2 = 2.0f*oz*ow;

			yz2 = 2.0f*oy*oz;
			yw2 = 2.0f*oy*ow;
			zw2 = 2.0f*oz*ow;
			ox *= ox;
			oy *= oy;
			oz *= oz;
			ow *= ow;

			n11 = (t = ox - oy) - oz + ow;
			n12 = xy2 - zw2;
			n13 = xz2 + yw2;
			n21 = xy2 + zw2;
			n22 = -t - oz + ow;
			n23 = yz2 - xw2;
			n31 = xz2 - yw2;
			n32 = yz2 + xw2;
			n33 = -ox - oy + oz + ow;

			bind_results->m.m11 = (n11*inverseBind->m11 + n12*inverseBind->m12 + n13*inverseBind->m13);
			bind_results->m.m12 = (n11*inverseBind->m21 + n12*inverseBind->m22 + n13*inverseBind->m23);
			bind_results->m.m13 = (n11*inverseBind->m31 + n12*inverseBind->m32 + n13*inverseBind->m33);
			bind_results->m.m14 = (n11*inverseBind->m41 + n12*inverseBind->m42 + n13*inverseBind->m43 + world_Pose->p.x);
			bind_results->m.m21 = (n21*inverseBind->m11 + n22*inverseBind->m12 + n23*inverseBind->m13);
			bind_results->m.m22 = (n21*inverseBind->m21 + n22*inverseBind->m22 + n23*inverseBind->m23);
			bind_results->m.m23 = (n21*inverseBind->m31 + n22*inverseBind->m32 + n23*inverseBind->m33);
			bind_results->m.m24 = (n21*inverseBind->m41 + n22*inverseBind->m42 + n23*inverseBind->m43 + world_Pose->p.y);
			bind_results->m.m31 = (n31*inverseBind->m11 + n32*inverseBind->m12 + n33*inverseBind->m13);
			bind_results->m.m32 = (n31*inverseBind->m21 + n32*inverseBind->m22 + n33*inverseBind->m23);
			bind_results->m.m33 = (n31*inverseBind->m31 + n32*inverseBind->m32 + n33*inverseBind->m33);
			bind_results->m.m34 = (n31*inverseBind->m41 + n32*inverseBind->m42 + n33*inverseBind->m43 + world_Pose->p.z);
		}else{
			bind_results->m.m11 = bind_params->s.x;
			bind_results->m.m12 = 0;
			bind_results->m.m13 = 0;
			bind_results->m.m14 = 0;
			bind_results->m.m21 = 0;
			bind_results->m.m22 = bind_params->s.y;
			bind_results->m.m23 = 0;
			bind_results->m.m24 = 0;
			bind_results->m.m31 = 0;
			bind_results->m.m32 = 0;
			bind_results->m.m33 = bind_params->s.z;
			bind_results->m.m34 = 0;
		}

		bind_results->s.x = bind_params->s.x;
		bind_results->s.y = bind_params->s.y;
		bind_results->s.z = bind_params->s.z;
	}
}
int getParticleJointSize()
{
	return sizeof(particle_joint);
}


//===========================================================

void pose2Matrix12(const pq * pose,matrix12 * m)
{
	float ox, oy, oz, ow;
    float xy2, xz2, xw2;
    float yz2, yw2, zw2;
	float t;

	// 全局 pose 矩阵
	ox = pose->q.x;
	oy = pose->q.y;
	oz = pose->q.z;
	ow = pose->q.w;

	xy2 = (t = 2.0f*ox)*oy;
	xz2 = t*oz;
	xw2 = t*ow;
	yz2 = (t = 2.0f*oy)*oz;
	yw2 = t*ow;
	zw2 = 2.0f*oz*ow;

	yz2 = 2.0f*oy*oz;
	yw2 = 2.0f*oy*ow;
	zw2 = 2.0f*oz*ow;
	ox *= ox;
	oy *= oy;
	oz *= oz;
	ow *= ow;

	m->m11 = (t = ox - oy) - oz + ow;
	m->m12 = xy2 - zw2;
	m->m13 = xz2 + yw2;
	m->m21 = xy2 + zw2;
	m->m22 = -t - oz + ow;
	m->m23 = yz2 - xw2;
	m->m31 = xz2 - yw2;
	m->m32 = yz2 + xw2;
	m->m33 = -ox - oy + oz + ow;

	m->m14 = pose->p.x;
	m->m24 = pose->p.y;
	m->m34 = pose->p.z;
}

void matrix12Muilty(const matrix12 * m1,const matrix12 * m2,matrix12 * dst)
{
	dst->m11 = m1->m11 * m2->m11 + m1->m12 * m2->m21 + m1->m13 * m2->m31/* + m1->m14 * m2->m41*/;
	dst->m12 = m1->m11 * m2->m12 + m1->m12 * m2->m22 + m1->m13 * m2->m32/* + m1->m14 * m2->m42*/;
	dst->m13 = m1->m11 * m2->m13 + m1->m12 * m2->m23 + m1->m13 * m2->m33/* + m1->m14 * m2->m43*/;
	dst->m14 = m1->m11 * m2->m14 + m1->m12 * m2->m24 + m1->m13 * m2->m34 + m1->m14/* * m2->44*/;

	dst->m21 = m1->m21 * m2->m11 + m1->m22 * m2->m21 + m1->m23 * m2->m31/* + m1->m24 * m2->m41*/;
	dst->m22 = m1->m21 * m2->m12 + m1->m22 * m2->m22 + m1->m23 * m2->m32/* + m1->m24 * m2->m42*/;
	dst->m23 = m1->m21 * m2->m13 + m1->m22 * m2->m23 + m1->m23 * m2->m33/* + m1->m24 * m2->m43*/;
	dst->m24 = m1->m21 * m2->m14 + m1->m22 * m2->m24 + m1->m23 * m2->m34 + m1->m24/* * m2->44*/;

	dst->m31 = m1->m31 * m2->m11 + m1->m32 * m2->m21 + m1->m33 * m2->m31/* + m1->m34 * m2->m41*/;
	dst->m32 = m1->m31 * m2->m12 + m1->m32 * m2->m22 + m1->m33 * m2->m32/* + m1->m34 * m2->m42*/;
	dst->m33 = m1->m31 * m2->m13 + m1->m32 * m2->m23 + m1->m33 * m2->m33/* + m1->m34 * m2->m43*/;
	dst->m34 = m1->m31 * m2->m14 + m1->m32 * m2->m24 + m1->m33 * m2->m34 + m1->m34/* * m2->44*/;
}
void matrix12MuiltyMatrix12Trans(const matrix12 * m1,const matrix12trans * m2,matrix12 * dst)
{
	dst->m11 = m1->m11 * m2->m11 + m1->m12 * m2->m21 + m1->m13 * m2->m31/* + m1->m14 * m2->m41*/;
	dst->m12 = m1->m11 * m2->m12 + m1->m12 * m2->m22 + m1->m13 * m2->m32/* + m1->m14 * m2->m42*/;
	dst->m13 = m1->m11 * m2->m13 + m1->m12 * m2->m23 + m1->m13 * m2->m33/* + m1->m14 * m2->m43*/;
	dst->m14 = m1->m11 * m2->m14 + m1->m12 * m2->m24 + m1->m13 * m2->m34 + m1->m14/* * m2->44*/;

	dst->m21 = m1->m21 * m2->m11 + m1->m22 * m2->m21 + m1->m23 * m2->m31/* + m1->m24 * m2->m41*/;
	dst->m22 = m1->m21 * m2->m12 + m1->m22 * m2->m22 + m1->m23 * m2->m32/* + m1->m24 * m2->m42*/;
	dst->m23 = m1->m21 * m2->m13 + m1->m22 * m2->m23 + m1->m23 * m2->m33/* + m1->m24 * m2->m43*/;
	dst->m24 = m1->m21 * m2->m14 + m1->m22 * m2->m24 + m1->m23 * m2->m34 + m1->m24/* * m2->44*/;

	dst->m31 = m1->m31 * m2->m11 + m1->m32 * m2->m21 + m1->m33 * m2->m31/* + m1->m34 * m2->m41*/;
	dst->m32 = m1->m31 * m2->m12 + m1->m32 * m2->m22 + m1->m33 * m2->m32/* + m1->m34 * m2->m42*/;
	dst->m33 = m1->m31 * m2->m13 + m1->m32 * m2->m23 + m1->m33 * m2->m33/* + m1->m34 * m2->m43*/;
	dst->m34 = m1->m31 * m2->m14 + m1->m32 * m2->m24 + m1->m33 * m2->m34 + m1->m34/* * m2->44*/;
}


void poseLocalToMatrixWorld(const unsigned char* localPose,unsigned char* worldPose,const unsigned char* parentIndices,unsigned int numJoints)
{
	unsigned int i;
	unsigned char parentIndex;
    pq * pose;
	matrix12 * parentPose;
	matrix12 * world_Pose;
	static matrix12 * temp_Pose;

	for (i = 0; i < numJoints; ++i) {
		parentIndex = parentIndices[i];
		pose = (pq*)localPose + i;
		world_Pose = (matrix12*)worldPose + i;
		if(parentIndex == (unsigned char)-1){
			pose2Matrix12(pose,world_Pose);
		}else{
			parentPose = (matrix12*)worldPose + parentIndex;
			pose2Matrix12(pose,temp_Pose);
			matrix12Muilty(parentPose,temp_Pose,world_Pose);
		}
	}
}
void jointsMatrixData(const unsigned char* worldPose,const unsigned char* inverseBindPose,unsigned char* matrices,unsigned int numJoints)
{
	unsigned int i;
	matrix12 * pose;
	matrix12 * dst;
    matrix12trans * inv_bind;

	for (i = 0; i < numJoints; ++i) {
		pose = (matrix12*)worldPose + i;
		inv_bind = (matrix12trans *)inverseBindPose + i;
		dst = (matrix12*)matrices + i;
		matrix12MuiltyMatrix12Trans(pose,inv_bind,dst);
	}
}
void jointsDualQuatData(const unsigned char* worldPose,const unsigned char* inverseBindPose,unsigned char* dualQuat,unsigned int numJoints)
{
	unsigned int i;
	matrix12 * pose;
	static matrix12 * dst;
    matrix12trans * inv_bind;

	for (i = 0; i < numJoints; ++i) {
		pose = (matrix12*)worldPose + i;
		inv_bind = (matrix12trans *)inverseBindPose + i;
		matrix12MuiltyMatrix12Trans(pose,inv_bind,dst);
		writeGlobalDualQuat((float*)dst,dualQuat + i * sizeof(dual_quat));
	}
}

void updatePoseMatricesAndSkinDatas(
	unsigned char* jointPoseMatrices,
	unsigned char* jointSkinDatas,

	const unsigned char* animationPoses,
	const unsigned char* parentIndices,
	const unsigned char* inverseBindPose,

	unsigned int frame,
	unsigned int numJoints,
	Boolean useDualQuat
	)
{
	const unsigned char * localPose = animationPoses + frame * numJoints * JOINT_POSE_LEN;
	poseLocalToMatrixWorld(localPose,jointPoseMatrices,parentIndices,numJoints);
	if(useDualQuat){
		jointsDualQuatData(jointPoseMatrices,inverseBindPose,jointSkinDatas,numJoints);
	}else{
		jointsMatrixData(jointPoseMatrices,inverseBindPose,jointSkinDatas,numJoints);
	}
}

void matrixWorldToJointsData(const unsigned char* worldPose,const unsigned char* inverseBindPose,unsigned char* jointsData,unsigned int numJoints,Boolean useDualQuat)
{
	if(useDualQuat){
		jointsDualQuatData(worldPose,inverseBindPose,jointsData,numJoints);
	}else{
		jointsMatrixData(worldPose,inverseBindPose,jointsData,numJoints);
	}
}

void getCondensedSkinDatas(
	unsigned char* condensedSkinDatas,

	const unsigned char* jointSkinDatas,
	const unsigned char* jointsMap,

	unsigned int numJointsMap,
	Boolean useDualQuat
	)
{
	unsigned int i;

	dual_quat * srcDualQuat;
	dual_quat * dstDualQuat;
	matrix12 * srcMaterices;
	matrix12 * dstMaterices;

	if(useDualQuat){
		srcDualQuat = (dual_quat *)jointSkinDatas;
		dstDualQuat = (dual_quat *)condensedSkinDatas;
		for (i = 0; i < numJointsMap; ++i) {
			dstDualQuat[i] = srcDualQuat[jointsMap[i]];
		}
	}else{
		srcMaterices = (matrix12 *)jointSkinDatas;
		dstMaterices = (matrix12 *)condensedSkinDatas;
		for (i = 0; i < numJointsMap; ++i) {
			dstMaterices[i] = srcMaterices[jointsMap[i]];
		}
	}
}

void getCondensedPoseMatrices(
	unsigned char* condensedPoseMatrices,
	
	const unsigned char* jointPoseMatrices,
	const unsigned char* jointsMap,
	unsigned int numJointsMap
	)
{
	unsigned int i;

	matrix12 * srcPose = (matrix12 *)jointPoseMatrices;
	matrix12 * dstPose = (matrix12 *)condensedPoseMatrices;
	for (i = 0; i < numJointsMap; ++i) {
		dstPose[i] = srcPose[jointsMap[i]];
	}
}
void copyFrame(unsigned char* dst_matrices,unsigned char* dst_poses,unsigned char* src_matrices,unsigned char* src_poses,unsigned int matricesLen,unsigned int posesLen)
{
	memcpy(dst_matrices,src_matrices,matricesLen);
	memcpy(dst_poses,src_poses,posesLen);
}