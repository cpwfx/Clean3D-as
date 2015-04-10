package async
{	
/**
 * 定义资源文件加载完毕后需要转换的格式 
 * @author zhangyu
 * 
 */
public class ResFormat
{
	/**
	 * 文本格式 
	 */	
	public static const TEXT:String = "text";
	
	/**
	 * 二进制数组 
	 */	
	public static const BINARY:String = "binary";
	
	/**
	 * XML
	 */
	public static const XML:String = "xml";
	
	/**
	 * ZIP
	 */
	public static const ZIP:String = "zip";
	
	/**
	 * flash.display.Loader
	 * 这个格式化类型主要是为了少写几个字的代码
	 */
	public static const LOADER:String = "loader";
	
	/**
	 * 位图 
	 */	
	public static const BITMAP:String = "bitmap";

	
	/**
	 * 声音格式文件 
	 */	
	public static const SOUND:String = "sound";
}
}