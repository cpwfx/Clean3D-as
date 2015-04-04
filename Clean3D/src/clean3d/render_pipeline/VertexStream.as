package clean3d.render_pipeline
{
	import flash.display3D.VertexBuffer3D;
	import flash.utils.ByteArray;

	public class VertexStream
	{
		public static const Static:String = "Static";
		public static const Dynamic:String = "Dynamic";
		public static const System:String = "System";
		
		private var _type:uint;
		private var _vb:VertexBuffer3D;
		private var _data:ByteArray;
		
		public function VertexStream(type:uint,vb:VertexBuffer3D,data:ByteArray)
		{
			_type = type;
			_vb = vb;
			_data = data;
		}
		
		public function get type():uint
		{
			return _type;
		}

		public function get vb():VertexBuffer3D
		{
			return _vb;
		}

		public function get data():ByteArray
		{
			return _data;
		}
	}
}