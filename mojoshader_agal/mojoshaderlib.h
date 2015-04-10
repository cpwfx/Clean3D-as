typedef struct preprocess_error
{
    const char *error;
	unsigned int errorlen;
    const char *filename;
	unsigned int filenamelen;
    int error_position;
} preprocess_error;

typedef struct preprocess_data
{
	int error_count;
	const preprocess_error *errors;
	const char *output;
	unsigned int outputlen;
} preprocess_data;

typedef struct preprocess_define
{
    const char *identifier;
    const char *definition;
} preprocess_define;

typedef const char *(*IncludeOpen)(const char *fname, const char *parent);

preprocess_data * preprocess(const char *filename, const char *source, unsigned int sourcelen, preprocess_define * defines, unsigned int define_count, IncludeOpen onIncludeOpen);
void freePreprocessData(preprocess_data * data);