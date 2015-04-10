package async {

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.MovieClip;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.utils.ByteArray;

import org.osflash.async.Deferred;

import zips.ZipFile;


public class LoaderDeferred extends Deferred {

    private var _loader:Loader;
    private var _success:Boolean;
    private var _inDomain:Boolean;

    private var _data:*;
    private var _url:String;
    private var _contentFormat:String;
    private var _info:*;
    private var _bitmapData:BitmapData
    private var _bitmap:Bitmap

    public function get url():String {
        return _url;
    }

    public function LoaderDeferred() {
        _success = false;
    }

    public function dispose():void {
        if (loader) {
            loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, loadIOErrorHandler);
            loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loaderCompleteHandlerAsync);
            loader.unload();
            loader = null ;
        }
        if (contentFormat == ResFormat.BITMAP && _bitmap) {
            InstManager.instance().disposeOne(_url);
            if(_bitmap.parent){
                _bitmap.parent.removeChild(_bitmap);
            }
            _bitmap = null ;
        }
    }

    //--------------------------------------------------------------------------
    //		Event Handler
    //--------------------------------------------------------------------------
    /**
     * 加载函数
     * @param url 绝对地址
     * @param contentFormat 初始化类型 参考 ResFormat
     * @param loadLv 加载优先级  越小，加载顺序越靠前
     * @param inDomain  是否加载到主域【主要用于加载类库】
     * @return
     *
     */
    public function load(url:String, contentFormat:String, loadLv:uint = LoadLevel.LIB, inDomain:Boolean = true,onlyLoadBitmap:Boolean = false):LoaderDeferred {
        if (_success == false) {
            this._contentFormat = contentFormat
            this._url = url;
            _inDomain = inDomain;
            if (contentFormat == ResFormat.BITMAP) {
                var hasInst:Boolean = InstManager.instance().hasInstData(_url);
                if(hasInst){
                    if(onlyLoadBitmap){
                        //只加载
                        resolve(this);
                        return this;
                    }else{
                        var content:* = InstManager.instance().getInstData(_url);
                        if (content) {
                            data = content;
                            _bitmap = content as Bitmap;
                            _bitmapData = _bitmap .bitmapData;
                            resolve(this);
                            return this;
                        }
                    }
                }
            }
            //加载完成以后会自动调用方法，调用完方法后会移除引用，不需要移除监听
            BinaryManager.instance().rcant::load(url, loadLv, onCompleteHandlerAsync, onProgressHandler, onErrorHandler);
        }
        return this;
    }

    protected function onProgressHandler(event:BinaryEvent):void {
        if (url != event.binaryInfo.url)
            return;
        //更新进度
        progress(event.bytesLoaded / event.bytesTotal);
    }

    protected function onErrorHandler(event:BinaryEvent):void {
//        if (url != event.binaryInfo.url)
//            return;
        reject(new Error("ioErrorHandler" + url))
    }

    private function onCompleteHandlerAsync(e:BinaryEvent):void {
        AsyncCallQuene.instance().asyncCallByTick(onCompleteHandler, [e]);
    }

    protected function onCompleteHandler(event:BinaryEvent):void {
//        if (url != event.binaryInfo.url)
//            return;
        _success = true;
        var ba:ByteArray = event.binaryInfo.ba;
        if(ba==null)return;
        ba.position = 0;
        switch (_contentFormat) {
            case ResFormat.BINARY :
                data = ba;
                break;
            case ResFormat.ZIP :
                data = new ZipFile(ba);
                break;
            case ResFormat.TEXT :
                var text:String = ba.readUTFBytes(ba.bytesAvailable);
                data = text;
                break;
            case ResFormat.XML :
                var str:String = ba.readUTFBytes(ba.bytesAvailable);
                var xml:XML = new XML(str);
                data = xml;
                break;
            case ResFormat.LOADER:
            case ResFormat.BITMAP:
                loader = new Loader();
                loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderCompleteHandlerAsync);
                loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadIOErrorHandler);
                var lc:LoaderContext = new LoaderContext();
                if (_inDomain)
                    lc.applicationDomain = ApplicationDomain.currentDomain;
                lc.allowCodeImport = true;
                loader.loadBytes(ba, lc);
                return;
                break;
            default :
                break;
        }
        resolve(this);
    }

    override public function resolve(outcome:* = null):void {
        //延时调用
//        CallLater.callLaterNextFrame(super.resolve,[outcome]);
        super.resolve(outcome);
    }

    protected function loadIOErrorHandler(event:IOErrorEvent):void {
        loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, loadIOErrorHandler);
        loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loaderCompleteHandlerAsync);
    }

    private function loaderCompleteHandlerAsync(event:Event):void {
        loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, loadIOErrorHandler);
        loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loaderCompleteHandlerAsync);
        AsyncCallQuene.instance().asyncCallByTick(loaderCompleteHandler, [event]);
    }

    private function loaderCompleteHandler(event:Event):void {
        if (!_loader || !_loader.content)
            return;
        if (ResFormat.BITMAP == contentFormat) {

            if (_loader.content is Bitmap) {
//                if (_bitmapData == null)_bitmapData = Bitmap(_loader.content).bitmapData;
                _bitmap = InstManager.instance().initData(_url, Bitmap(_loader.content).bitmapData, ResFormat.BITMAP);
                _bitmapData = _bitmap.bitmapData;
            }
            else if (_loader.content is MovieClip) {
                if (_bitmapData == null) {
                    var mc:MovieClip = MovieClip(_loader.content);
                    var bitmapData:BitmapData = new BitmapData(mc.width, mc.height, true, 0);
                    bitmapData.draw(mc, null, null, null, null, false);
                    _bitmapData = bitmapData;
                }
            }

        } else if (ResFormat.LOADER == contentFormat) {
            data = _loader.content
        }

        resolve(this)
    }

    public function set loader(value:Loader):void {
        _loader = value;
    }

    public function get loader():Loader {
        return _loader;
    }

    public function get bitmapData():BitmapData {
        return _bitmapData;
    }

    public function set bitmapData(value:BitmapData):void {
        _bitmapData = value;
    }

    public function get data():* {
        return _data;
    }

    public function set data(value:*):void {
        _data = value;
    }

    public function get contentFormat():String {
        return _contentFormat;
    }

    public function set contentFormat(value:String):void {
        _contentFormat = value;
    }

    public function get info():* {
        return _info;
    }

    public function set info(value:*):void {
        _info = value;
    }


    public function get bitmap():Bitmap {
        return _bitmap;
    }
}
}
