package clean3d.textures
{
	import clean3d.assets.Reference;
	import clean3d.core.clean3d_internal;
	import clean3d.errors.AbstractMethodError;
	
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.TextureBase;
	
	use namespace clean3d_internal;
	
	public class TextureProxyBase extends Reference
	{
		protected var _format:String = Context3DTextureFormat.BGRA;
		protected var _hasMipmaps:Boolean = true;
		
		protected var _texture:TextureBase;
		protected var _dirty:Boolean;
		
		protected var _width:int;
		protected var _height:int;
		
		public function TextureProxyBase(key:String, delayTime:uint = 0)
		{
			super(key, delayTime);
		}
		
		public function get hasMipMaps():Boolean
		{
			return _hasMipmaps;
		}
		
		public function get format():String
		{
			return _format;
		}
		
		public function get width():int
		{
			return _width;
		}
		
		public function get height():int
		{
			return _height;
		}
		
		public function get texture():TextureBase
		{
			if (this.refernce>0 && this._loaded){
				if (!_texture || _dirty) {
					_texture = createTexture();
					_dirty = false;
					uploadContent(_texture);
				}
			}
			return _texture;
		}		
		
		
		protected function uploadContent(texture:TextureBase):void
		{
			throw new AbstractMethodError();
		}
		
		protected function setSize(width:int, height:int):void
		{
			if (_width != width || _height != height)
			{
				if(_texture){
					_texture.dispose();	
				}
				invalidateContent();
			}
			
			_width = width;
			_height = height;
		}
		
		public function invalidateContent():void
		{
			_dirty = true;
		}
		
		protected function createTexture():TextureBase
		{
			throw new AbstractMethodError();
		}
		
		override clean3d_internal function dispose():void{
			if(_texture){
				_texture.dispose();
				_texture = null;
			}
		}
	}
}