package clean3d.assets.textureCreation
{
	import clean3d.assets.Creation;
	import clean3d.assets.Reference;
	import clean3d.core.clean3d_internal;
	import clean3d.textures.BitmapTexture;
	
	use namespace clean3d_internal;

	public class AssetTextureCreation extends Creation
	{
		private var _generateMipmaps:Boolean;
		private var _delayTime:uint;	
		
		public function AssetTextureCreation(key:String,generateMipmaps:Boolean = true, delayTime:uint = 0)
		{
			super(key);
			_generateMipmaps = generateMipmaps;
			_delayTime = delayTime;
		}
		override public function Create():Reference
		{
			var tex:BitmapTexture = new BitmapTexture(_key,_generateMipmaps,_delayTime);
			tex.createWithAsset();
			return tex;
		}		
	}
}