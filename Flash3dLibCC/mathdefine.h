#ifndef __MATH_DEFINE_H_
#define __MATH_DEFINE_H_

typedef struct _vec3 {
	float x;
	float y;
	float z;
} vec3;
typedef struct _quat {
	float x;
	float y;
	float z;
	float w;	
} quat;

typedef struct _pq {
	vec3 p;
	quat q;
} pq;

typedef struct _dual_quat {
	quat qn;
	quat qd;
} dual_quat;

typedef struct _matrix12 {
    float m11, m12, m13, m14;
    float m21, m22, m23, m24;
    float m31, m32, m33, m34;	
} matrix12;

typedef struct _matrix12trans {
    float m11, m21, m31;
    float m12, m22, m32;
    float m13, m23, m33;
	float m14, m24, m34;
} matrix12trans;

typedef struct _matrix {
    float m11, m12, m13, m14;
    float m21, m22, m23, m24;
    float m31, m32, m33, m34;	
	float m41, m42, m43, m44;	
} matrix;

// todo: 1×Ö½Ú¶ÔÆë
#ifndef _WIN32
struct _particle_joint {
	vec3 p;
	float w;
	float h;
	unsigned char boneIdx;
}__attribute__((packed));
typedef struct _particle_joint particle_joint;
#else
#pragma pack(1)
typedef struct _particle_joint {
	vec3 p;
	float w;
	float h;
	unsigned char boneIdx;
}particle_joint;
#pragma pack()
#endif

typedef struct _joint_bind_param {
	matrix m;
	vec3 s;
	int joint;
}joint_bind_param;

typedef struct _joint_bind_result {
	matrix12 m;
	vec3 s;
	float pad;
}joint_bind_result;

#endif