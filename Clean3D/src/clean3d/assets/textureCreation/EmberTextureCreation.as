package clean3d.assets.textureCreation
{
	import clean3d.assets.Creation;
	import clean3d.assets.Reference;
	import clean3d.textures.BitmapTexture;
	
	public class EmberTextureCreation extends Creation
	{
		private var _generateMipmaps:Boolean;
		private var _delayTime:uint;	
		private var _embed:Class;
		
		public function EmberTextureCreation(embed:Class,generateMipmaps:Boolean = true, delayTime:uint = 0)
		{
			super(String(embed));
			_embed = embed;
			_generateMipmaps = generateMipmaps;
			_delayTime = delayTime;			
		}
		override public function Create():Reference
		{
			var tex:BitmapTexture = new BitmapTexture(_key,_generateMipmaps,_delayTime);
			tex.createWithEmber(_embed);
			return tex;
		}	
	}
}