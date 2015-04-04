package clean3d.core
{
	import clean3d.assets.Reference;
	import clean3d.assets.Storage;
	import clean3d.events.EngineEvent;
	
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProfile;
	import flash.display3D.Context3DTriangleFace;
	import flash.errors.IllegalOperationError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.ui.Mouse;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	//import starling.animation.Juggler;

	//import starling.display.Stage;
	
	use namespace clean3d_internal;
	
	public class Clean3D extends EventDispatcher
	{
		/** The version of the Starling framework. */
		public static const VERSION:String = "0.0.1";
		
		/** The key for the shader programs stored in 'contextData' */
		private static const PROGRAM_DATA_NAME:String = "Clean3D.programs"; 
		
		// members
		private var mStage:Stage; 						// Scene3D!
		//private var mJuggler:Juggler;
		//private var mStatsDisplay:StatsDisplay;

		// 3D设备相关
		private var mStage3D:Stage3D;
		private var mAntiAliasing:int;
		private var mContext:Context3D;
		private var mEnableErrorChecking:Boolean;		// 就是mContext中的同名属性。当 mContext为空时暂时由此变量保存。
		private var mProfile:String;					// 指示Context3D的驱动模式
		private var mSupportHighResolutions:Boolean;	// Context3D.configureBackBuffer 中的 wantsBestResolution 函数。当 BackBuffer 重新配置时需要。

		// 引擎当前状态
		private var mStarted:Boolean;					// 指示引擎的 Start,Stop状态
		private var mRendering:Boolean;				// 指示引擎的 Start,Stop中，是否在渲染 (Stop时也有可能在渲染)
		private var mLastFrameTimestamp:Number;		// 时间标签

		// 引擎视窗
		private var mViewPort:Rectangle;
		private var mPreviousViewPort:Rectangle;
		private var mClippedViewPort:Rectangle;
		
		// 原生 flash 的 stage
		private var mNativeStage:flash.display.Stage;
		private var mNativeOverlay:flash.display.Sprite;
		private var mNativeStageContentScaleFactor:Number;
		
		// 资源路径
		private var mAssetPath:String;
		
		private static var sCurrent:Clean3D;
		private static var sHandleLostContext:Boolean;
		private static var sContextData:Dictionary = new Dictionary(true);
		
		public function Clean3D(stage:flash.display.Stage, 
								viewPort:Rectangle=null, stage3D:Stage3D=null,
								renderMode:String="auto", profile:Object=Context3DProfile.STANDARD)
		{
			if (stage == null) throw new ArgumentError("Stage must not be null");
			if (viewPort == null) viewPort = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
			if (stage3D == null) stage3D = stage.stage3Ds[0];
			
			sCurrent = this;
			
			mStage = stage;
			//mJuggler = new Juggler();

			mStage3D = stage3D;
			mSupportHighResolutions = false;
			mAntiAliasing = 0;
			mEnableErrorChecking = false;

			mNativeOverlay = new Sprite();
			mNativeStage = stage;
			mNativeStage.addChild(mNativeOverlay);
			mNativeStageContentScaleFactor = 1.0;

			mLastFrameTimestamp = getTimer() / 1000.0;
			
			mViewPort = viewPort;
			mPreviousViewPort = new Rectangle();
			
			// for context data, we actually reference by stage3D, since it survives a context loss
			sContextData[stage3D] = new Dictionary();
			sContextData[stage3D][PROGRAM_DATA_NAME] = new Dictionary();
			
			// all other modes are problematic in Clean3D, so we force those here
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			// register other event handlers
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
			
			mStage3D.addEventListener(Event.CONTEXT3D_CREATE, onContextCreated, false, 10, true);
			mStage3D.addEventListener(ErrorEvent.ERROR, onStage3DError, false, 10, true);	
			
			
			requestContext3D(stage3D, renderMode, profile);
		}
		
		/** Disposes all children of the stage and the render context; removes all registered
		 *  event listeners. */
		public function dispose():void
		{
			stop(true);
			
			mNativeStage.removeEventListener(Event.ENTER_FRAME, onEnterFrame, false);
			mNativeStage.removeChild(mNativeOverlay);
			
			mStage3D.removeEventListener(Event.CONTEXT3D_CREATE, onContextCreated, false);
			mStage3D.removeEventListener(ErrorEvent.ERROR, onStage3DError, false);
			
			//if (mStage) mStage.dispose();
			if (sCurrent == this) sCurrent = null;
			if (mContext) 
			{
				// Per default, the context is recreated as long as there are listeners on it.
				// Beginning with AIR 3.6, we can avoid that with an additional parameter.
				mContext.dispose(false);
			}
		}		
		
		private function requestContext3D(stage3D:Stage3D, renderMode:String, profile:Object):void
		{
			var profiles:Array;
			var currentProfile:String;
			
			if (profile == "auto")
				profiles = ["baselineExtended", "baseline", "baselineConstrained"];
			else if (profile is String)
				profiles = [profile as String];
			else if (profile is Array)
				profiles = profile as Array;
			else
				throw new ArgumentError("Profile must be of type 'String' or 'Array'");
			
			mStage3D.addEventListener(Event.CONTEXT3D_CREATE, onCreated, false, 100);
			mStage3D.addEventListener(ErrorEvent.ERROR, onError, false, 100);
			
			requestNextProfile();
			
			function requestNextProfile():void
			{
				currentProfile = profiles.shift();
				
				mStage3D.requestContext3D(renderMode, currentProfile);
				
				try { mStage3D.requestContext3D(renderMode, currentProfile); }
				catch (error:Error)
				{
					if (profiles.length != 0) setTimeout(requestNextProfile, 1);
					else throw error;
				}
			}
			
			function onCreated(event:Event):void
			{
				mProfile = currentProfile;
				onFinished();
			}
			
			function onError(event:Event):void
			{
				if (profiles.length != 0)
				{
					event.stopImmediatePropagation();
					setTimeout(requestNextProfile, 1);
				}
				else onFinished();
			}
			
			function onFinished():void
			{
				mStage3D.removeEventListener(Event.CONTEXT3D_CREATE, onCreated);
				mStage3D.removeEventListener(ErrorEvent.ERROR, onError);
			}
		}		
		
		private function onEnterFrame(event:Event):void
		{
			// On mobile, the native display list is only updated on stage3D draw calls. 
			// Thus, we render even when Starling is paused.
			if (mStarted) {
				nextFrame();
			}else if (mRendering){ 
				render();
			}
		}

		private function onStage3DError(event:ErrorEvent):void
		{
			if (event.errorID == 3702)
			{
				var mode:String = Capabilities.playerType == "Desktop" ? "renderMode" : "wmode";
				trace("Context3D not available! Possible reasons: wrong " + mode +
					" or missing device support.");
				
				showFatalError("Context3D not available! Possible reasons: wrong " + mode +
					" or missing device support.");
			}
			else{
				showFatalError("Stage3D error: " + event.text);
				trace("Stage3D error: " + event.text);
			}
		}
		private function onContextCreated(event:Event):void
		{
			if (!handleLostContext && mContext)
			{
				stop();
				event.stopImmediatePropagation();
				showFatalError("Fatal error: The application lost the device context!");
				trace("[Starling] The device context was lost. " + 
					"Enable 'Starling.handleLostContext' to avoid this error.");
			}
			else
			{
				initialize();
			}
		}
		
		
		/** Indicates if the Context3D object is currently valid (i.e. it hasn't been lost or
		 *  disposed). Beware that each call to this method causes a String allocation (due to
		 *  internal code Starling can't avoid), so do not call this method too often. */
		public function get contextValid():Boolean
		{
			return mContext && mContext.driverInfo != "Disposed"
		}
		
		/** Indicates if Starling should automatically recover from a lost device context.
		 *  On some systems, an upcoming screensaver or entering sleep mode may 
		 *  invalidate the render context. This setting indicates if Starling should recover from 
		 *  such incidents. Beware that this has a huge impact on memory consumption!
		 *  It is recommended to enable this setting on Android and Windows, but to deactivate it
		 *  on iOS and Mac OS X. @default false */
		public static function get handleLostContext():Boolean { return sHandleLostContext; }
		public static function set handleLostContext(value:Boolean):void 
		{
			if (sCurrent) throw new IllegalOperationError(
				"'handleLostContext' must be set before Starling instance is created");
			else
				sHandleLostContext = value;
		}
		
		
		/** Calls <code>advanceTime()</code> (with the time that has passed since the last frame)
		 *  and <code>render()</code>. */ 
		public function nextFrame():void
		{
			var now:Number = getTimer() / 1000.0;
			var passedTime:Number = now - mLastFrameTimestamp;
			mLastFrameTimestamp = now;
			
			// to avoid overloading time-based animations, the maximum delta is truncated.
			if (passedTime > 1.0) 
				passedTime = 1.0;
			
			Storage.nextFrame(now);
			advanceTime(passedTime);
			render();
		}
		/** Dispatches ENTER_FRAME events on the display list, advances the Juggler 
		 *  and processes touches. */
		public function advanceTime(passedTime:Number):void
		{
			if (!contextValid)
				return;
			
			//mStage.advanceTime(passedTime);
			//mJuggler.advanceTime(passedTime);
		}
		
		/** Renders the complete display list. Before rendering, the context is cleared; afterwards,
		 *  it is presented. This can be avoided by enabling <code>shareContext</code>.*/ 
		public function render():void
		{
			if (!contextValid)
				return;
			
			updateViewPort();
			updateNativeOverlay();
			
			var scaleX:Number = mViewPort.width  / mStage.stageWidth;
			var scaleY:Number = mViewPort.height / mStage.stageHeight;
			
			mContext.setDepthTest(false, Context3DCompareMode.ALWAYS);
			mContext.setCulling(Context3DTriangleFace.NONE);
			mContext.clear();	// 清除缓存
			// 投射矩阵
			// 渲染内容
			this.dispatchEvent(new EngineEvent(EngineEvent.ENGINE_ENTERFRAME));
			
			mContext.present();// 反转内容
		}
		
		
		private function updateViewPort(forceUpdate:Boolean=false):void
		{
			// the last set viewport is stored in a variable; that way, people can modify the
			// viewPort directly (without a copy) and we still know if it has changed.
			
			if (forceUpdate || mPreviousViewPort.width != mViewPort.width || 
				mPreviousViewPort.height != mViewPort.height ||
				mPreviousViewPort.x != mViewPort.x || mPreviousViewPort.y != mViewPort.y)
			{
				mPreviousViewPort.setTo(mViewPort.x, mViewPort.y, mViewPort.width, mViewPort.height);
				
				// Constrained mode requires that the viewport is within the native stage bounds;
				// thus, we use a clipped viewport when configuring the back buffer. (In baseline
				// mode, that's not necessary, but it does not hurt either.)
				
				mClippedViewPort = mViewPort.intersection(
					new Rectangle(0, 0, mNativeStage.stageWidth, mNativeStage.stageHeight));
				
				// setting x and y might move the context to invalid bounds (since changing
				// the size happens in a separate operation) -- so we have no choice but to
				// set the backbuffer to a very small size first, to be on the safe side.
				
				if (mProfile == "baselineConstrained")
					configureBackBuffer(32, 32, mAntiAliasing, false);
				
				mStage3D.x = mClippedViewPort.x;
				mStage3D.y = mClippedViewPort.y;
				
				configureBackBuffer(mClippedViewPort.width, mClippedViewPort.height,
					mAntiAliasing, false, mSupportHighResolutions);
				
				if (mSupportHighResolutions && "contentsScaleFactor" in mNativeStage)
					mNativeStageContentScaleFactor = mNativeStage["contentsScaleFactor"];
				else
					mNativeStageContentScaleFactor = 1.0;
			}
		}
		
		/** Configures the back buffer while automatically keeping backwards compatibility with
		 *  AIR versions that do not support the "wantsBestResolution" argument. */
		private function configureBackBuffer(width:int, height:int, antiAlias:int, 
											 enableDepthAndStencil:Boolean,
											 wantsBestResolution:Boolean=false):void
		{
			var configureBackBuffer:Function = mContext.configureBackBuffer;
			var methodArgs:Array = [width, height, antiAlias, enableDepthAndStencil];
			if (configureBackBuffer.length > 4) 
				methodArgs.push(wantsBestResolution);
			configureBackBuffer.apply(mContext, methodArgs);
		}
		
		private function updateNativeOverlay():void
		{
			mNativeOverlay.x = mViewPort.x;
			mNativeOverlay.y = mViewPort.y;
			mNativeOverlay.scaleX = mViewPort.width / mStage.stageWidth;
			mNativeOverlay.scaleY = mViewPort.height / mStage.stageHeight;
		}
		
		private function showFatalError(message:String):void
		{
			var textField:TextField = new TextField();
			var textFormat:TextFormat = new TextFormat("Verdana", 12, 0xFFFFFF);
			textFormat.align = TextFormatAlign.CENTER;
			textField.defaultTextFormat = textFormat;
			textField.wordWrap = true;
			textField.width = mStage.stageWidth * 0.75;
			textField.autoSize = TextFieldAutoSize.CENTER;
			textField.text = message;
			textField.x = (mStage.stageWidth  - textField.width)  / 2;
			textField.y = (mStage.stageHeight - textField.height) / 2;
			textField.background = true;
			textField.backgroundColor = 0x440000;
			
			updateNativeOverlay();
			nativeOverlay.addChild(textField);
		}
		
		/** As soon as Starling is started, it will queue input events (keyboard/mouse/touch);   
		 *  furthermore, the method <code>nextFrame</code> will be called once per Flash Player
		 *  frame. (Except when <code>shareContext</code> is enabled: in that case, you have to
		 *  call that method manually.) */
		public function start():void 
		{ 
			mStarted = mRendering = true;
			mLastFrameTimestamp = getTimer() / 1000.0;
		}
		
		/** Stops all logic and input processing, effectively freezing the app in its current state.
		 *  Per default, rendering will continue: that's because the classic display list
		 *  is only updated when stage3D is. (If Starling stopped rendering, conventional Flash
		 *  contents would freeze, as well.)
		 *  
		 *  <p>However, if you don't need classic Flash contents, you can stop rendering, too.
		 *  On some mobile systems (e.g. iOS), you are even required to do so if you have
		 *  activated background code execution.</p>
		 */
		public function stop(suspendRendering:Boolean=false):void
		{ 
			mStarted = false;
			mRendering = !suspendRendering;
		}
		
		
		/** A Flash Sprite placed directly on top of the Starling content. Use it to display native
		 *  Flash components. */ 
		public function get nativeOverlay():Sprite { return mNativeOverlay; }
		
		
		private function initialize():void
		{
			mContext = mStage3D.context3D;
			mContext.enableErrorChecking = mEnableErrorChecking;
			contextData[PROGRAM_DATA_NAME] = new Dictionary();
			
			Reference._context = mContext;
			
			if (mProfile == null)
				mProfile = mContext["profile"];
			
			updateViewPort(true);
			
			trace("[Clean3D] Initialization complete.");
			trace("[Clean3D] Display Driver:", mContext.driverInfo);
			
			dispatchEvent(new EngineEvent(EngineEvent.ENGINE_INITIALIZED));

			mLastFrameTimestamp = getTimer() / 1000.0;
		}
		
		
		/** A dictionary that can be used to save custom data related to the current context. 
		 *  If you need to share data that is bound to a specific stage3D instance
		 *  (e.g. textures), use this dictionary instead of creating a static class variable.
		 *  The Dictionary is actually bound to the stage3D instance, thus it survives a 
		 *  context loss. */
		public function get contextData():Dictionary
		{
			return sContextData[mStage3D] as Dictionary;
		}
		/** Indicates if Stage3D render methods will report errors. Activate only when needed,
		 *  as this has a negative impact on performance. @default false */
		public function get enableErrorChecking():Boolean { return mEnableErrorChecking; }
		public function set enableErrorChecking(value:Boolean):void 
		{ 
			mEnableErrorChecking = value;
			if (mContext) mContext.enableErrorChecking = value; 
		}

		public function get context():Context3D
		{
			return mContext;
		}

		public function get AssetPath():String
		{
			return mAssetPath;
		}

		public function set AssetPath(value:String):void
		{
			mAssetPath = value;
			Reference._path = value;
		}

	}
}