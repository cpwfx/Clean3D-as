package clean3d.render_pipeline
{
	public class VertexLayoutAttrib
	{
		public static const vertPos:String = "vertPos";
		public static const normal:String = "normal";
		public static const tangent:String = "tangent";
		public static const texCoords0:String = "texCoords0";
		public static const texCoords1:String = "texCoords1";
		public static const texCoords2:String = "texCoords2";
		public static const texCoords3:String = "texCoords3";
		public static const texCoords4:String = "texCoords4";
		public static const texCoords5:String = "texCoords5";
		public static const texCoords6:String = "texCoords6";
		public static const texCoords7:String = "texCoords7";
		public static const joints:String = "joints";
		public static const weights:String = "weights";
		
		private var _semanticName:String;	// 顶点成分的语义（用途）
		private var _vbSlot:uint;			// vb索引
		private var _size:uint;			// 长度(几个浮点数)
		private var _offset:uint;			// 在vb中的偏移量
		
		public function VertexLayoutAttrib(semanticName:String,vbSlot:uint,size:uint,offset:uint)
		{
		}

		public function get semanticName():String
		{
			return _semanticName;
		}

		public function get vbSlot():uint
		{
			return _vbSlot;
		}

		public function get size():uint
		{
			return _size;
		}

		public function get offset():uint
		{
			return _offset;
		}
		
		public function toString():String
		{
			return _semanticName + "_" 
				+ _vbSlot.toString() + "_" 
				+ _size.toString() + "_"
				+ _offset.toString();
		}
	}
}