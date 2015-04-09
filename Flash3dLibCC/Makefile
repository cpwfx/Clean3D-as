
all: check
	@echo "-------- Flash3dLibCC --------"
	@echo "-> Generate SWIG wrappers around the functions in the library"
	"$(FLASCC)/usr/bin/swig" -as3 -module Flash3dLib -outdir . -includeall -ignoremissing -o Flash3dLib_wrapper.c swig.i

	@echo "-> Compile the SWIG wrapper to ABC"
	$(AS3COMPILERARGS) -abcfuture -AS3 -import $(call nativepath,$(FLASCC)/usr/lib/builtin.abc) -import $(call nativepath,$(FLASCC)/usr/lib/playerglobal.abc) Flash3dLib.as
	# rename the output so the compiler doesn't accidentally use both this .as file along with the .abc file we just produced
	mv Flash3dLib.as Flash3dLib.as3

	@echo "-> Compile the library into a SWC"
	"$(FLASCC)/usr/bin/gcc" $(BASE_CFLAGS) Flash3dLib.abc Flash3dLib_wrapper.c flash3dlibmain.c flash3dlib.c -emit-swc=clean3D.Flash3dLib -o Flash3dLib.swc

include Makefile.common

clean:
	rm -f *_wrapper.c *.swf *.swc *.as3 *.abc
