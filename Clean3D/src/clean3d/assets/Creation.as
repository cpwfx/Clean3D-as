package clean3d.assets
{
	import clean3d.errors.AbstractMethodError;

	public class Creation
	{
		protected var _key:String;
		
		public function Creation(key:String)
		{
			_key = key;
		}
		public function Create():Reference
		{
			throw new AbstractMethodError();
		}
		
		/**
		 * Splits a url string into base and extension.
		 * @param url The url to be decomposed.
		 */
		protected function getFileExtension(url:String):String
		{
			// Get rid of query string if any and extract suffix
			var base:String = (url.indexOf('?') > 0)? url.split('?')[0] : url;
			var i:int = base.lastIndexOf('.');
			if(i>=0){
				return base.substr(i + 1).toLowerCase();
			}
			return "";
		}

		public function get key():String
		{
			return _key;
		}

	}
}