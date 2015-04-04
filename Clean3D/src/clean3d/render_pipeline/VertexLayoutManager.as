package clean3d.render_pipeline
{
	import flash.utils.Dictionary;

	public class VertexLayoutManager
	{
		private var vertexLayouts:Dictionary = new Dictionary();
		
		public function VertexLayoutManager()
		{
		}
		
		public function Register(vertexLayout:VertexLayout):VertexLayout
		{
			var key:String = vertexLayout.toString();
			if(!(key in vertexLayouts)){
				vertexLayouts[key] = vertexLayout;
			}
			return vertexLayouts[key];
		}
	}
}