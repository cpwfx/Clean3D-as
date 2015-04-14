package
{
import clean3D.mojoshaderlib.CModule;
import clean3D.mojoshaderlib.ram;

import clean3d.assets.TextureAssets;
import clean3d.core.Clean3D;
import clean3d.events.EngineEvent;
import clean3d.math.Matrix3DUtils;
import clean3d.renderer.GeometryType;
import clean3d.renderer.LightVSVariation;
import clean3d.renderer.Variations;
import clean3d.renderer.Variations;
import clean3d.textures.TextureProxyBase;

import com.adobe.glsl2agal.compileShader;
import com.adobe.glsl2agal.vfs.ISpecialFile;

import com.adobe.utils.AGALMiniAssembler;

import flash.display.Sprite;
import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
import flash.display3D.Context3DVertexBufferFormat;
import flash.display3D.IndexBuffer3D;
import flash.display3D.Program3D;
import flash.display3D.VertexBuffer3D;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.geom.Matrix3D;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.system.Capabilities;
import flash.utils.ByteArray;
import flash.utils.ByteArray;
import flash.utils.Endian;

import zips.ZipFile;

[SWF(width="1024", height="768", frameRate="60", backgroundColor="#000000")]
	public class CleanSample_TextureQuad extends Sprite implements com.adobe.glsl2agal.vfs.ISpecialFile
	{
		private var mClean3D:Clean3D;
		private var _vb:VertexBuffer3D;
		private var _ib:IndexBuffer3D;
		private var _pm:Program3D;
		private var _tex:TextureProxyBase;
		private var _matrixProject3D:Matrix3D = new Matrix3D();

        private var _zip:ZipFile;
		
		//floor diffuse map
		[Embed(source="/../embeds/arid.jpg")]
		private var arid:Class;		
		
		public function CleanSample_TextureQuad()
		{
			if (stage) start();
			else addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);			
		}
		private function onAddedToStage(event:Object):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			start();
		}		

		private function start():void
		{
			Clean3D.handleLostContext = true;

			mClean3D = new Clean3D(stage);
			mClean3D.enableErrorChecking = Capabilities.isDebugger;
			mClean3D.AssetPath = "../assets";
			mClean3D.start();
			
			// this event is dispatched when stage3D is set up
			mClean3D.addEventListener(EngineEvent.ENGINE_INITIALIZED, onInitlized);
			mClean3D.addEventListener(EngineEvent.ENGINE_ENTERFRAME, onEnterFrame);


		}
		
		private function onInitlized(e:EngineEvent):void
		{
			trace("onInitlized");

            var urlRequest:URLRequest = new URLRequest("../../CoreData.zip");
            var urlLoader:URLLoader = new URLLoader();
            urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
            urlLoader.addEventListener(Event.COMPLETE, onCoreDataLoaded);
            urlLoader.addEventListener(IOErrorEvent.IO_ERROR,onCoreDataLoadError);
            urlLoader.load(urlRequest);
		}

        private function onCoreDataLoaded(e:Event):void{
            _zip = new ZipFile(URLLoader(e.target).data);

            com.adobe.glsl2agal.CModule.rootSprite = this;
            com.adobe.glsl2agal.CModule.vfs.console = this;
            com.adobe.glsl2agal.CModule.startAsync();

            testMojoShader("CoreData/Shaders/GLSL/LitSolid_vs.glsl");
            addTriangle();
        }

        private function onCoreDataLoadError(e:IOErrorEvent):void{
            trace(e.toString());
        }

        private function testMojoShader(filename:String):void{

            var ba:ByteArray = _zip.getFileBytes(filename);
            ba.endian = Endian.LITTLE_ENDIAN;
            var context:String = ba.readUTFBytes(ba.length);

            for (var j:int = 0; j < GeometryType.MAX_GEOMETRYTYPES * LightVSVariation.MAX_LIGHT_VS_VARIATIONS; ++j)
            {
                var g:int = j / LightVSVariation.MAX_LIGHT_VS_VARIATIONS;
                var l:int = j % LightVSVariation.MAX_LIGHT_VS_VARIATIONS;


                var macro:String;
                macro = Variations.lightVSVariations[l];
                macro += Variations.geometryVSVariations[g];
                macro += "COMPILEVS ";
                macro += "SM3";

                processShader(macro,filename,context);
            }
        }

        private function onOpenInclude(fname:String,parent:String):String{
            var ba:ByteArray = _zip.getFileBytes("CoreData/Shaders/GLSL/" + fname);
            ba.endian = Endian.LITTLE_ENDIAN;
            var context:String = ba.readUTFBytes(ba.length);
            return context;
        }

        private function processShader(macro:String,filename:String,context:String):void{
            var macros:Array = macro.split(" ");

            var defines_ptr:int = CModule.alloca(Preprocess_defineValue.size * macros.length);
            var definition_ptr:int = CModule.mallocString("");
            for(var x:int = 0;x<macros.length;x++){
                var defines:Preprocess_defineValue = new Preprocess_defineValue(ram,defines_ptr + Preprocess_defineValue.size * x);
                defines.identifier = CModule.mallocString(macros[x] as String);
                defines.definition = definition_ptr;
            }

            var result:int = mojoshaderlib.preprocess(filename,context,context.length,defines_ptr,macros.length,onOpenInclude);
            var data:Preprocess_dataValue = new Preprocess_dataValue(ram,result);
            var output:String;
            if(data.error_count == 0){
                output = CModule.readString(data.output,data.outputlen);
                var r:String = com.adobe.glsl2agal.compileShader(output,0,false,false);
                var compiledVertexShader:Object = JSON.parse(r);
                trace(compiledVertexShader);
            }else{
                for(var i:int = 0;i<data.error_count;i++){
                    var error:Preprocess_errorValue = new Preprocess_errorValue(ram, data.errors + Preprocess_errorValue.size * i);
                    var errormsg:String = CModule.readString(error.error,error.errorlen);
                    var filename:String = CModule.readString(error.filename,error.filenamelen);
                    trace(filename + "[" + error.error_position + "]:" + errormsg);
                }
            }
            mojoshaderlib.freePreprocessData(result);
        }
		
		private function onEnterFrame(e:EngineEvent):void
		{
			var context3d:Context3D = mClean3D.context;
			
			if(_tex && _tex.loaded){
				context3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, _matrixProject3D,true);
				
				context3d.setVertexBufferAt( 0, this._vb, 0, Context3DVertexBufferFormat.FLOAT_2 );
				context3d.setVertexBufferAt( 1, this._vb, 2, Context3DVertexBufferFormat.FLOAT_2 );
				context3d.setTextureAt( 0, this._tex.texture );
				context3d.setProgram( this._pm );
				context3d.drawTriangles( this._ib );
			}
		}
		
		private function addTriangle():void
		{
			//三角形顶点数据
			var triangleData:Vector.<Number> = Vector.<Number>([
				//  x, y, u,v
				0,0, 0,1,
				512,0, 1,1,
				512,512, 1,0,
				0,512, 0,0
			]);
			var context3d:Context3D = mClean3D.context;
			
			this._vb = context3d.createVertexBuffer( triangleData.length/4, 4 );
			this._vb.uploadFromVector( triangleData,0,triangleData.length/4 );
			//三角形索引数据
			var indexData:Vector.<uint> = Vector.<uint>([
				0,3,1,
				1,2,3
			]);
			this._ib = context3d.createIndexBuffer( indexData.length );
			this._ib.uploadFromVector( indexData, 0, indexData.length );
			
			//纹理
			_tex =  TextureAssets.createWithAsset("trinket_diffuse.jpg");
			//_tex =  TextureAssets.createWithEmbed(arid);
/*			var texBase:TextureBase = _tex.texture;
			TextureAssets.deleteRef(_tex);*/

			//AGAL
			var vagalcode:String = "m44 op,va0,vc0\n" +
				"mov v0,va1";
			var vagal:AGALMiniAssembler = new AGALMiniAssembler();
			vagal.assemble( Context3DProgramType.VERTEX, vagalcode );
			var fagalcode:String = "tex ft0, v0, fs0 <2d,repeat,linear,nomip>\n" +
				"mov oc,ft0";
			var fagal:AGALMiniAssembler = new AGALMiniAssembler();
			fagal.assemble( Context3DProgramType.FRAGMENT, fagalcode );
			this._pm = context3d.createProgram();
			this._pm.upload( vagal.agalcode, fagal.agalcode );

			_matrixProject3D = Matrix3DUtils.createOrthoMatrixLH(_matrixProject3D,stage.stageWidth,stage.stageHeight,-10000,10000);
		}

    public function read(fileDescriptor:int, bufPtr:int, nbyte:int, errnoPtr:int):int {
        return 0;
    }

    public function write(fileDescriptor:int, bufPtr:int, nbyte:int, errnoPtr:int):int {
        var str:String = CModule.readString(bufPtr, nbyte)
        trace( str )
        return nbyte;
    }

    public function fcntl(fileDescriptor:int, cmd:int, data:int, errnoPtr:int):int {
        return 0;
    }

    public function ioctl(fileDescriptor:int, request:int, data:int, errnoPtr:int):int {
        return 0;
    }
}
}