#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>
#include <assert.h>

#include "mojoshader.h"
#include "mojoshaderlib.h"

IncludeOpen openCallback = NULL;
const MOJOSHADER_preprocessData * data = NULL;

int includeOpen(MOJOSHADER_includeType inctype,
	const char *fname, const char *parent,
	const char **outdata, unsigned int *outbytes,
	MOJOSHADER_malloc m, MOJOSHADER_free f, void *d)
{
	if(openCallback){
		const char * string = openCallback(fname,parent);
		if(string != NULL){
			*outbytes = strlen(string);
			char * context = (char *)m((*outbytes) + 1, d);
			strcpy(context, string);
			*outdata = context;
			return 1;
		}
	}
	return 0;
}
void includeClose(const char *data,
	MOJOSHADER_malloc m, MOJOSHADER_free f, void *d)
{
	f((void *)data, d);
}

preprocess_data * preprocess(const char *filename, const char *source, unsigned int sourcelen, preprocess_define * defines, unsigned int define_count,IncludeOpen open)
{
	int i;
	openCallback = open;

	preprocess_data * result = (preprocess_data *)malloc(sizeof(preprocess_data));
	data = MOJOSHADER_preprocess(filename, source, sourcelen, (const MOJOSHADER_preprocessorDefine * )defines, define_count,
		includeOpen, includeClose, NULL, NULL, NULL);
	if(data->error_count == 0){
		result->output = data->output;
		result->outputlen = strlen(data->output);
	}else{
		result->error_count = data->error_count;
		preprocess_error * errors = (preprocess_error *)malloc(sizeof(preprocess_error) * data->error_count);
		for(i=0;i<data->error_count;i++){
			errors[i].error = data->errors[i].error;
			errors[i].errorlen = strlen(data->errors[i].error);
			errors[i].filename = data->errors[i].filename;
			errors[i].filenamelen = strlen(data->errors[i].filename);
			errors[i].error_position = data->errors[i].error_position;
		}
		result->errors = errors;
	}
	return result;
}
void freePreprocessData(preprocess_data * result)
{
	if(result->error_count > 0){
		free((void*)result->errors);
	}
	free(result);
	MOJOSHADER_freePreprocessData(data);
	data = NULL;
	openCallback = NULL;
}