package clean3d.events
{
	import flash.events.Event;
	
	public class EngineEvent extends Event
	{
		public static const ENGINE_INITIALIZED:String = "EngineInitialized";
		public static const ENGINE_ENTERFRAME:String = "EngineEnterFrame";
		
		public function EngineEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}