package clean3d.assets
{
	import clean3d.assets.textureCreation.AssetTextureCreation;
	import clean3d.assets.textureCreation.EmberTextureCreation;
	import clean3d.textures.TextureProxyBase;

	public class TextureAssets
	{
		static public function createWithAsset(path:String,generateMipmaps:Boolean = true, delayTime:uint = 0):TextureProxyBase
		{
			return Storage.getStorage(Storage.Texture).addReference(new AssetTextureCreation(path,generateMipmaps,delayTime)) as TextureProxyBase;
		}
		static public function createWithEmbed(embed:Class,generateMipmaps:Boolean = true, delayTime:uint = 0):TextureProxyBase
		{
			return Storage.getStorage(Storage.Texture).addReference(new EmberTextureCreation(embed,generateMipmaps,delayTime)) as TextureProxyBase;
		}
		static public function createCubeWithAssets(path1:String,path2:String,path3:String,
			path4:String,path5:String,path6:String,generateMipmaps:Boolean = true, delayTime:uint = 0):TextureProxyBase
		{
			return null;
		}
		static public function createCubeWithEmbeds(embed1:Class,embed2:Class,embed3:Class,
			embed4:Class,embed5:Class,embed6:Class,generateMipmaps:Boolean = true, delayTime:uint = 0):TextureProxyBase
		{
			return null;
		}
		
		static public function deleteRef(tex:TextureProxyBase):void
		{
			Storage.getStorage(Storage.Texture).delReference(tex);
		}
	}
}