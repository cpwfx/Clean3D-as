package clean3d.textures
{
	import clean3d.core.clean3d_internal;
	
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.TextureBase;
	
	use namespace clean3d_internal;

	public class Texture2DBase extends TextureProxyBase
	{
		public function Texture2DBase(key:String, delayTime:uint=0)
		{
			super(key, delayTime);
		}
		override protected function createTexture():TextureBase
		{
			return _context.createTexture(_width, _height, Context3DTextureFormat.BGRA, false);
		}		
	}
}