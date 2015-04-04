package clean3d.textures
{
	import clean3d.core.clean3d_internal;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display3D.textures.Texture;
	import flash.display3D.textures.TextureBase;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	use namespace clean3d_internal;

	public class BitmapTexture extends Texture2DBase
	{
		private static var _mipMaps:Array = [];
		private static var _mipMapUses:Array = [];
		
		private var _bitmapData:BitmapData;
		private var _mipMapHolder:BitmapData;
		private var _generateMipmaps:Boolean;

		public function BitmapTexture(key:String, generateMipmaps:Boolean = true, delayTime:uint = 0)
		{
			super(key, delayTime);
			_generateMipmaps = generateMipmaps;
		}
		public function createWithAsset():void{
			load();
		}
		public function createWithEmber(ember:Class):void{
			var data:* = new ember;
			if (data is Bitmap) {
				if ((data as Bitmap).hasOwnProperty("bitmapData")){ // if (data is BitmapAsset)
					this.onBitmapData(data.bitmapData);
					return;
				}
			}
			this.onDefault();
		}
		
		override protected function uploadContent(texture:TextureBase):void
		{
			if (_generateMipmaps)
				MipmapGenerator.generateMipMaps(_bitmapData, texture, _mipMapHolder, true);
			else
				Texture(texture).uploadFromBitmapData(_bitmapData, 0);
		}
		override clean3d_internal function dispose():void
		{
			super.dispose();
			
			if (_mipMapHolder)
				freeMipMapHolder();
		}
		override clean3d_internal function onData(data:*):void{
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onBitmapComplete, false, 0, true);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onBitmapError, false, 0, true);
			loader.loadBytes(data);
		}
		
		private function onBitmapData(data:BitmapData):void{
			_bitmapData = data;
			_width = _bitmapData.width;
			_height = _bitmapData.height;
			_loaded = true; 
		}
		
		private function onBitmapComplete(e:Event):void{
			var loader:Loader = LoaderInfo(e.target).loader;
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onBitmapComplete);
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onBitmapError);
			
			onBitmapData((e.target.content as Bitmap).bitmapData);
			
			loader.unload();
			loader = null;
		}
		private function onBitmapError(e:IOErrorEvent):void{
			var loader:Loader = LoaderInfo(e.target).loader;
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onBitmapComplete);
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onBitmapError);
			loader.unload();
			loader = null;
			onDefault();
			trace(e.text);
		}
		
		
		override clean3d_internal function onDefault():void{
			onBitmapData(new BitmapData(2,2,false,0xff0000));
		}		
		
		
		private function getMipMapHolder():void
		{
			var newW:uint, newH:uint;
			
			newW = _bitmapData.width;
			newH = _bitmapData.height;
			
			if (_mipMapHolder) {
				if (_mipMapHolder.width == newW && _bitmapData.height == newH)
					return;
				
				freeMipMapHolder();
			}
			
			if (!_mipMaps[newW]) {
				_mipMaps[newW] = [];
				_mipMapUses[newW] = [];
			}
			if (!_mipMaps[newW][newH]) {
				_mipMapHolder = _mipMaps[newW][newH] = new BitmapData(newW, newH, true);
				_mipMapUses[newW][newH] = 1;
			} else {
				_mipMapUses[newW][newH] = _mipMapUses[newW][newH] + 1;
				_mipMapHolder = _mipMaps[newW][newH];
			}
		}
		
		private function freeMipMapHolder():void
		{
			var holderWidth:uint = _mipMapHolder.width;
			var holderHeight:uint = _mipMapHolder.height;
			
			if (--_mipMapUses[holderWidth][holderHeight] == 0) {
				_mipMaps[holderWidth][holderHeight].dispose();
				_mipMaps[holderWidth][holderHeight] = null;
			}
		}
	}
}