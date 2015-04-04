package
{
import clean3d.core.Clean3D;
import clean3d.events.EngineEvent;

import com.adobe.utils.AGALMiniAssembler;

import flash.display.Sprite;
import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
import flash.display3D.Context3DVertexBufferFormat;
import flash.display3D.IndexBuffer3D;
import flash.display3D.Program3D;
import flash.display3D.VertexBuffer3D;
import flash.events.Event;
import flash.system.Capabilities;

[SWF(width="1024", height="768", frameRate="60", backgroundColor="#000000")]
public class CleanSample_ColorTriangle extends Sprite
{
    private var mClean3D:Clean3D;
    private var _vb:VertexBuffer3D;
    private var _ib:IndexBuffer3D;
    private var _pm:Program3D;

    public function CleanSample_ColorTriangle()
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
        mClean3D.start();

        // this event is dispatched when stage3D is set up
        mClean3D.addEventListener(EngineEvent.ENGINE_INITIALIZED, onInitlized);
        mClean3D.addEventListener(EngineEvent.ENGINE_ENTERFRAME, onEnterFrame);
    }

    private function onInitlized(e:EngineEvent):void
    {
        trace("onInitlized");
        addTriangle();
    }

    private function onEnterFrame(e:EngineEvent):void
    {
        var context3d:Context3D = mClean3D.context;
        context3d.setVertexBufferAt( 0, this._vb, 0, Context3DVertexBufferFormat.FLOAT_2 );
        context3d.setVertexBufferAt( 1, this._vb, 2, Context3DVertexBufferFormat.FLOAT_3 );
        context3d.setProgram( this._pm );
        context3d.drawTriangles( this._ib );
    }

    private function addTriangle():void
    {
        //三角形顶点数据
        var triangleData:Vector.<Number> = Vector.<Number>([
            //  x, y, r, g, b
            0, 1, 0, 0, 1,
            1, 0, 0, 1, 0,
            0, 0, 1, 0, 0
        ]);
        var context3d:Context3D = mClean3D.context;

        this._vb = context3d.createVertexBuffer( triangleData.length/5, 5 );
        this._vb.uploadFromVector( triangleData,0,triangleData.length/5 );
        //三角形索引数据
        var indexData:Vector.<uint> = Vector.<uint>([
            0, 1, 2
        ]);
        this._ib = context3d.createIndexBuffer( indexData.length );
        this._ib.uploadFromVector( indexData, 0, indexData.length );
        //AGAL
        var vagalcode:String = "mov op, va0\n" +
                "mov vt0, va1\n" +
                "add vt0, vt0, vc0\n" +
                "mov v0, vt0";
        var vagal:AGALMiniAssembler = new AGALMiniAssembler();
        vagal.assemble( Context3DProgramType.VERTEX, vagalcode );
        var fagalcode:String = "mov oc, v0";
        var fagal:AGALMiniAssembler = new AGALMiniAssembler();
        fagal.assemble( Context3DProgramType.FRAGMENT, fagalcode );
        this._pm = context3d.createProgram();
        this._pm.upload( vagal.agalcode, fagal.agalcode );
    }
}
}