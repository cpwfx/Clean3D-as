package clean3d.assets
{
	import clean3d.events.LoaderEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;

	public class SingleFileLoader extends EventDispatcher
	{
		private var _req:URLRequest;
		private var _fileExtension:String;
		private var _fileName:String;
		private var _loadAsRawData:Boolean;
		private var _data:*;
		
		public function SingleFileLoader()
		{
		}
		
		/**
		 * Load a resource from a file.
		 *
		 * @param urlRequest The URLRequest object containing the URL of the object to be loaded.
		 * @param parser An optional parser object that will translate the loaded data into a usable resource. If not provided, AssetLoader will attempt to auto-detect the file type.
		 */
		public function load(urlRequest:URLRequest, loadAsRawData:Boolean = false):void
		{
			var urlLoader:URLLoader;
			var dataFormat:String;
			
			_loadAsRawData = loadAsRawData;
			_req = urlRequest;
			decomposeFilename(_req.url);
			
			dataFormat = _loadAsRawData?URLLoaderDataFormat.BINARY:URLLoaderDataFormat.TEXT;
			
			urlLoader = new URLLoader();
			urlLoader.dataFormat = dataFormat;
			urlLoader.addEventListener(Event.COMPLETE, handleUrlLoaderComplete);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, handleUrlLoaderError);
			urlLoader.load(urlRequest);
		}
		
		/**
		 * Splits a url string into base and extension.
		 * @param url The url to be decomposed.
		 */
		private function decomposeFilename(url:String):void
		{
			
			// Get rid of query string if any and extract suffix
			var base:String = (url.indexOf('?') > 0)? url.split('?')[0] : url;
			var i:int = base.lastIndexOf('.');
			_fileExtension = base.substr(i + 1).toLowerCase();
			_fileName = base.substr(0, i);
		}
		/**
		 * Called when loading of a file has failed
		 */
		private function handleUrlLoaderError(event:IOErrorEvent):void
		{
			var urlLoader:URLLoader = URLLoader(event.currentTarget);
			urlLoader.removeEventListener(Event.COMPLETE, handleUrlLoaderComplete);
			urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, handleUrlLoaderError);
			
			if (hasEventListener(LoaderEvent.LOAD_ERROR))
				dispatchEvent(new LoaderEvent(LoaderEvent.LOAD_ERROR, _req.url, event.text));
		}
		
		/**
		 * Called when loading of a file is complete
		 */
		private function handleUrlLoaderComplete(event:Event):void
		{
			var urlLoader:URLLoader = URLLoader(event.currentTarget);
			urlLoader.removeEventListener(Event.COMPLETE, handleUrlLoaderComplete);
			urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, handleUrlLoaderError);

			_data = urlLoader.data;
			dispatchEvent(new LoaderEvent(LoaderEvent.RESOURCE_COMPLETE));
		}		

		public function get data():*
		{
			return _data;
		}

	}
}