package clean3d.assets
{
	import clean3d.core.clean3d_internal;
	import clean3d.errors.AbstractMethodError;
	import clean3d.events.LoaderEvent;
	
	import flash.display3D.Context3D;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	use namespace clean3d_internal;

	public class Reference
	{
		private var _refernce:uint;
		private var _key:String;
		private var _delayTime:uint;

		clean3d_internal var _deleteTime:uint;
		clean3d_internal var _size:uint;
		
		protected var _loaded:Boolean;
		
		clean3d_internal static var _context:Context3D;
		clean3d_internal static var _path:String;
		
		public function Reference(key:String,delayTime:uint = 0)
		{
			_key = key;
			_delayTime = delayTime;
		}
		clean3d_internal function dispose():void{
			throw new AbstractMethodError();
		}
		clean3d_internal function nextFrame(time:uint):void{
			// can be empty
		}
		clean3d_internal function onData(data:*):void{
			throw new AbstractMethodError();
		}
		clean3d_internal function onDefault():void{
			throw new AbstractMethodError();
		}
		
		clean3d_internal function addReference():void{
			_refernce ++;	
		}
		clean3d_internal function delReference():void{
			_refernce --;
		}
		
		protected function load():void{
			var urlRequest:URLRequest = new URLRequest(_path + "/" + _key);
			var loader:SingleFileLoader = new SingleFileLoader();
			loader.load(urlRequest,true);
			loader.addEventListener(LoaderEvent.RESOURCE_COMPLETE,onLoaded);
			loader.addEventListener(LoaderEvent.LOAD_ERROR,onLoadError);
		}
		private function onLoaded(e:LoaderEvent):void{
			var loader:SingleFileLoader = e.target as SingleFileLoader;
			loader.removeEventListener(LoaderEvent.RESOURCE_COMPLETE,onLoaded);
			loader.removeEventListener(LoaderEvent.LOAD_ERROR,onLoadError);
			onData(loader.data);
			loader = null;
		}
		private function onLoadError(e:LoaderEvent):void{
			var loader:SingleFileLoader = e.target as SingleFileLoader;
			trace(e.message);
			loader.removeEventListener(LoaderEvent.RESOURCE_COMPLETE,onLoaded);
			loader.removeEventListener(LoaderEvent.LOAD_ERROR,onLoadError);
			onDefault();
			loader = null;
		}
		
		public function get refernce():uint
		{
			return _refernce;
		}

		public function get key():String
		{
			return _key;
		}

		public function get delayTime():uint
		{
			return _delayTime;
		}

		public function get deleteTime():uint
		{
			return _deleteTime;
		}

		public function get size():uint
		{
			return _size;
		}

		public function get loaded():Boolean
		{
			return _loaded;
		}

	}
}