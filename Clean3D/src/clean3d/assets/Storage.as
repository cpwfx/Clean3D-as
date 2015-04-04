package clean3d.assets
{
	import clean3d.core.clean3d_internal;
	
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	use namespace clean3d_internal;

	public class Storage
	{
		public static const Effect:String = "Effect";
		public static const Texture:String = "Texture";
		public static const Model:String = "Model";
		public static const Font:String = "Font";
		public static const Sound:String = "Sound";
		
		private var _references:Dictionary;
		private var _name:String;
		private var _totalSize:uint;
		private var _dispose:Array;
		
		private static var _storages:Dictionary = new Dictionary();
		
		public static function getStorage(name:String):Storage{
			if(name in _storages)
				return _storages[name] as Storage;
			return new Storage(name);
		}
		public static function nextFrame(time:uint):void{
			for each(var storage:Storage in _storages){
				storage.nextFrame(time);				
			}
		}
		
		public function Storage(name:String)
		{
			if(name in _storages)
				return;
			
			_references = new Dictionary();
			_dispose = new Array();
			_name = name;
			_storages[name] = this;
		}
		
		public function addReference(creation:Creation):Reference{
			var key:String = creation.key; 
			if(!(key in _references)){
				_references[key] = creation.Create();
			}
			var ref:Reference = (_references[key] as Reference);
			ref.addReference();
			return ref;
		}
		public function delReference(ref:Reference):void{
			var key:String = ref.key;
			if(key in _references){
				if(!(_references[key] === ref)){
					throw new Error("delReference:ref not in Storage");
				}
				if(ref.refernce == 0){
					throw new Error("delReference:ref count already is zero");
				}
				ref.delReference();
				if( (ref.refernce == 0) && (ref.delayTime > 0) ){
					ref._deleteTime = getTimer();
				}
			}
		}
		public function getReference(key:String):Reference{
			if(key in _references){
				return (_references[key] as Reference);
			}
			return null;
		}
		
		public function deleteAllReference():void{
			var ref:Reference;
			for each(var key:String in _references){
				ref = _references[key] as Reference;
				ref.dispose();
				_references[key] = null;
			}
			_references = null;
			_references = new Dictionary();
		}
		public function nextFrame(time:uint):void{
			_dispose.length = 0;
			for each(var ref:Reference in _references){
				if((ref.refernce==0) && ((ref.delayTime == 0) || (time >= ref.deleteTime))){
					_dispose.push(ref);
				}else{
					ref.nextFrame(time);
				}
			}
			
			for each(var r:Reference in _dispose){
				delete(_references[r.key]);
				r.dispose();
			}
		}

		public function get name():String
		{
			return _name;
		}

		public function get totalSize():uint
		{
			return _totalSize;
		}
	}
}