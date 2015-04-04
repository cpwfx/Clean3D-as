1.使用effect做shader脚本，而不是使用as3代码去拼凑agal代码。
2.shader和粒子数据是预生成的，不是运行时拼凑的。
3.不需要多个Stage3d.
4.不需要兼容软件蒙皮，软件粒子。
5.更好的显卡资源reference管理。
6.可用effect自由订制渲染流程，forward shading,deferred shading,deferred lighting,ect.
7.更适合游戏的场景组织方式。
8.3dsmax插件，直接作为模型，粒子编辑工具。

ok 如何生成内嵌class的唯一字符串key
ok 必须从 reference派生,包含的方案，调用时不能立即返回可用的相应资源对象，一个未初始化的reference没用处。
	不从reference派生，改从referencedItem派生。改成包含在ref内。
ok 如何从文件data到bitmapData

cubetexture 需要一个装载多个资源的功能
纹理简化成一个类。不同图像数据类型的解析分成多个类。

effect.fx 一步到位 
	ok 语法树的打印
	ok main 函数分别改名为 vs_main ps_main
	ok 两套东西放在一起编译
	ok 腰斩，去掉生成glsl的部分

	测试agal2流程语句
		if else endif 生效
		if 只能在可预计的数量中以复制代码的方式假循环。

	转换成llvm的lr,输出成中间码文件
	编写agal的后端转换
	
	json包装 + hlsl
	增加复杂语义和注释
	增加 tec 和 pass
	增加渲染状态设置

TIntermTyped : public TIntermNode
	TIntermSymbol : public TIntermTyped
	TIntermDeclaration : public TIntermTyped {
	TIntermConstant : public TIntermTyped
	TIntermOperator : public TIntermTyped
		TIntermBinary : public TIntermOperator
		TIntermUnary : public TIntermOperator
		TIntermAggregate : public TIntermOperator	
	TIntermSelection : public TIntermTyped
TIntermLoop : public TIntermNode
TIntermBranch : public TIntermNode


clean3d-x
clean3d-as

练习部分
	.准备 flex bison 工具 和 手册
	.解析 unity3d的材质脚本。
通用部分
	.引入xmdl
		模型格式。
		配置方式
	.把effect作为通用的材质脚本。
		c++版本编译器，转换为as3,gles,webgl,glsl 直接可用的2进制格式。
		2进制格式中，针对不同平台，存在不同版本。也可多个目标平台共存于一个文件中？
	.引入gpu粒子	
		c++版本编译器，转换为fx脚本。
		引入到max中，读取fx文件，作为max对象显示在max窗口。
		在max中编辑粒子文件。并转换成
as3引擎
	.单stage3d.学习starling的初始化方式。
		ok 最新版本的 starling 
		ok 最新版本的 agal asm
		ok 创建设备
		ok 屏幕空间 三角形 彩色，
		ok 屏幕空间 三角形 纹理
		ok 正交矩阵设置

		增加摄像机
		增加标准集合体

		场景中组织：摄像机 灯光 xmdl元素 标准集合体
			摄像机不作为Object3D
			摄像机操作
				Camera.eye & Camera.target 只能确认位置元素。旋转元素要重新计算。
			废弃文件与模型过于依赖的做法。可以通过硬编码来完成xmdl的数据组合。
			
			fx 资源参数块 纹理 骨骼 网格 蒙皮网格 	

			场景物体组织方式 
				使用多种关系的children，等同对待  vs 场景节点和附加节点分开处理
				骨骼作为普通的node处理？ vs 骨骼作为实体被对待
				

		材质的概念，是fx参数块。
			不同的材质之间，按照 纹理，常数，			

		渲染管线
		shader管线
		资源管理器

		引擎不处理键盘,鼠标事件
		只提供根据屏幕坐标挑选接口	
	
	.测试agal 2.0版本新功能和指令
		先暂时使用json格式作为材质脚本。在2进制格式上，兼容通用effect.
	.使用effect的2进制格式
	.显示gpu粒子
	.显示xmdl模型




1.3dsmax到底对fx支持多少。需要测试。
	只能支持到d3d9.
	参数不能支持数组？
	支持多少sas语义。1.03 vs 0.8
2.fx构架到底能灵活到什么程度。
	能彻底与算法分离？
		1.光照
			前向光照限制灯光数量
				1d + 2p + 2s
				引擎来挑选，评估实际的灯光数量。对fx来说，就只是个灯光列表
		2.阴影
			简单的阴影算法只需要一个rt
			级联阴影算法？
		3.雾
			
		4.反射，折射(导致额外的场景遍历)
		5.renderToTexture物体标记，并做后期处理。
3.fxcomposer能模拟多少？
5.fx的编译版本，和运行版本的兼容。
	d3d9支持fx_4_0吗？
	
4.fx编译到2进制码，翻译成agal
	1.一个测试环境。
		c++程序调用swf.
	2.as3只去读编译转换好的agal,设置参数
6.写c++程序解析 fxo 文件


fx
cgfx
unity3d shader

agal
hlsl
glsl
glsl es
webgl

json形式的agal包装 编译成一个2进制文件 fxagal fxb


AGAL无法把纹理作为vs的数组
纹理做参数，因为不支持浮点纹理，映射到 1/256~1.0颜色范围之间不靠谱。


DefineTable				
	_defineTable;				// #define所定义的。类似于宏，内联函数。
		FunctionData容器
			FunctionData 函数定义
	_customTable;				// 同 	_defineTable, 区别在于 _defineTable是系统库，_customTable是在shader中自定义的。	
	_replaceTable;				// #compile each 变量<n> 所定义的	针对已定义的 define做替换
		
FunctionTable
	_customTable;
	_funcTable
		函数对象（FunctionBlock容器，同名不同参。）属性名格式化成 n:t1:..:tn 记录参数类型
			FunctionBlock：
				FunctionData定义 或者 interface (只有接口，没定义)	
					interface 是 AGAL已有的函数
					function 是需要自己写的函数
					包括参数表（参数类型）和返回类型
includeMap
	避免重复包含的头文件列表
MemberManager
	propertyMap
		FunctionData	无参数表
	structMap

	program