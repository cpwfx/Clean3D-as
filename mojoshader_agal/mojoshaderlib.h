typedef struct preprocess_data
{
	int error_count;
	const char *errors;
	const char *output;
	int handle;
} preprocess_data;

preprocess_data preprocess(const char *filename, const char *source, unsigned int sourcelen);
void freePreprocessData(preprocess_data data);