
all: check
	@echo "-------- mojoshader_agal --------"
	@echo "-> Generate SWIG wrappers around the functions in the library"
	"$(FLASCC)/usr/bin/swig" -as3 -module mojoshaderlib -outdir . -includeall -ignoremissing -o mojoshaderlib_wrapper.c swig.i

	@echo "-> Compile the SWIG wrapper to ABC"
	$(AS3COMPILERARGS) -abcfuture -AS3 -import $(call nativepath,$(FLASCC)/usr/lib/builtin.abc) -import $(call nativepath,$(FLASCC)/usr/lib/playerglobal.abc) mojoshaderlib.as
	# rename the output so the compiler doesn't accidentally use both this .as file along with the .abc file we just produced
	mv mojoshaderlib.as mojoshaderlib.as3

	@echo "-> Compile the library into a SWC"
	"$(FLASCC)/usr/bin/gcc" $(BASE_CFLAGS) mojoshaderlib.abc mojoshaderlib_wrapper.c mojoshaderlibmain.c mojoshader.c mojoshader_common.c mojoshader_lexer.c mojoshader_preprocessor.c mojoshaderlib.c -emit-swc=clean3D.mojoshaderlib -o mojoshaderlib.swc

include Makefile.common

clean:
	rm -f *_wrapper.c *.swf *.swc *.as3 *.abc
