package clean3d.render_pipeline
{
	public class VertexLayout
	{
		public static const MaxNumVertexLayouts:uint = 16;
		
		private var attribs:Vector.<VertexLayoutAttrib> = new Vector.<VertexLayoutAttrib>();		
		
		public function VertexLayout(value:Array) 
		{
			for(var i:uint =0;i<value.length;i++){
				if(value[i] is VertexLayoutAttrib){
					attribs.push(value[i]);
				}
			}
		}
		public function toString():String
		{
			var s:String = "";
			for (var i:uint=0;i<attribs.length;i++){
				s += attribs[i].toString();
				if(i < (attribs.length-1)){
					s += "|"
				}
			}
			return s;
		}
		public function get length():uint{
			return attribs.length;
		}
		public function getAt(index:uint):VertexLayoutAttrib{
			return attribs[index];
		}
	}
}