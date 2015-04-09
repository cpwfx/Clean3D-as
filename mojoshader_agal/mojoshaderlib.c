#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>
#include <assert.h>

#include "mojoshader.h"
#include "mojoshaderlib.h"

int includeOpen(MOJOSHADER_includeType inctype,
	const char *fname, const char *parent,
	const char **outdata, unsigned int *outbytes,
	MOJOSHADER_malloc m, MOJOSHADER_free f, void *d)
{
	*outbytes = 5;
	char * context = (char *)m((*outbytes) + 1, d);
	strcpy(context, "1234");

	*outdata = context;

	return 1;
}
void includeClose(const char *data,
	MOJOSHADER_malloc m, MOJOSHADER_free f, void *d)
{
	f((void *)data, d);
}

preprocess_data preprocess(const char *filename, const char *source, unsigned int sourcelen)
{
	preprocess_data result;
	const MOJOSHADER_preprocessData * data =
		MOJOSHADER_preprocess(filename, source, sourcelen, NULL, 0,
		includeOpen, includeClose, NULL, NULL, NULL);
	result.error_count = data->error_count;
	if (data->error_count > 0){
		result.errors = data->errors[0].error;
	}
	else{
		result.errors = 0;
	}
	result.output = data->output;
	result.handle = (int)data;
	return result;
}
void freePreprocessData(preprocess_data result)
{
	const MOJOSHADER_preprocessData * data = (const MOJOSHADER_preprocessData *)result.handle;
	MOJOSHADER_freePreprocessData(data);
}