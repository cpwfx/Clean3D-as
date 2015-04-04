package clean3d.render_pipeline
{
	import flash.display3D.IndexBuffer3D;

	// 确实需要动态vb吗？用途？
	
	public class StreamData
	{
		private var vertexBuffers:Vector.<VertexStream>;
		private var vertexLayout:VertexLayout;
		private var vertices:uint;

		private var indexBuffer:IndexBuffer3D;
		private var indices:uint;
		private var primitiveType:uint;
		
		public function StreamData()
		{
		}
	}
}