package core_obj
{
	/**
	 * 事件分发器,由于本身事件数量肯定不会多
	 * 所以没有必要使用二分查找算法,直接遍历 
	 * 事件ID与事件回调处于不同的数组，通过相同的数组下标关联
	 * 
	 * @author linbc
	 * 
	 */	
	public class EventDispatcher
	{
		//事件分发器,事件句柄为整形
		public static const KEY_TYPE_INT:int = 0;
		
		//事件分发器的事件句柄为字符串
		public static const KEY_TYPE_STRING:int = 1;		
		
		protected var _event_key_type:int;
		
		protected var _event_id_int:Vector.<int>;
		protected var _event_id_str:Vector.<String>;		
		protected var _event_callback:Vector.<Function>;
		
		protected var _callback_index:int = 0;
		
		//由于事件触发时有可能修改到容器本身的值，所以先将事件放到该容器一起触发
		private var _event_index:Vector.<int>;		
		
		public function EventDispatcher(type:int = 0)
		{	
			_event_key_type = type;
			
			//如果是事件句柄为字符串，初始化不同的数组
			if(type == KEY_TYPE_STRING)
				_event_id_str = new Vector.<String>;
			else
				_event_id_int = new Vector.<int>;
				
			_event_callback = new Vector.<Function>;
			
			_event_index = new Vector.<int>;
		}		
		
		/**
		 * 触发该事件的参数 
		 * @param param
		 * 
		 */		
		private function DispatchIndex(param:Object):void
		{
			//先触发
			var i:int;
			if(_event_key_type == KEY_TYPE_STRING){
				for(i in _event_index){
					_event_callback[i](param);
					_event_callback.splice(i,1);
					_event_id_str.splice(i,1);
				}
				
			}else{
				for(i in _event_index){
					_event_callback[i](param);
					_event_callback.splice(i,1);
					_event_id_int.splice(i,1);
				}
			}			
		}
		
		public function DispatchString(key:String,param:Object):void
		{
			//先清空
			_event_index.length = 0;
			
			var len:int = _event_callback.length;
			for(var i:int=0; i<len; i++){
				//插入最开头部分,便于等下循环删除
				if(key == _event_id_str[i])
					_event_index.unshift(i);
			}
			//大部分是不触发的
			if(_event_index.length)
				DispatchIndex(param);
		}
		
		public function DispatchInt(key:int,param:Object):void
		{
			_event_index.length = 0;
			
			var len:int = _event_callback.length;
			for(var i:int=0; i<len; i++){
				//插入最开头部分,便于等下循环删除
				if(key == _event_id_int[i])
					_event_index.unshift(i);
			}
			
			//大部分是不触发的
			if(_event_index.length)
				DispatchIndex(param);
		}
		
		/**
		 * 根据规则触发整数回调
		 *  
		 * @param param
		 * @param pred 回调格式 pred(index,binlog)->bool
		 * 
		 */
		public function Dispatch(param:Object,pred:Function):void
		{
			_event_index.length = 0;
			
			var len:int = _event_callback.length;
			for(var i:int=0; i<len; i++){
				//传入事件ID/事件参数，由函数指针
				if(pred(_event_id_int[i],param))
					_event_index.unshift(i);
			}
			
			//大部分是不触发的
			if(_event_index.length)
				DispatchIndex(param);
		}
				
		/**
		 * 添加回调监听,监听ID手工指定
		 * @param key	事件ID
		 * @param f		回调函数闭包,可以支持一个参数(Object)
		 * 
		 */		
		public function AddListenInt(key:int,f:Function):void
		{
			if(_event_key_type == KEY_TYPE_STRING)
				throw new Error("AddListenInt but (_event_key_type == KEY_TYPE_STRING)");
			
			_event_id_int.push(key);
			_event_callback.push(f);
		}
		
		public function AddListenString(key:String,f:Function):void
		{
			if(_event_key_type != KEY_TYPE_STRING)
				throw new Error("AddListenString but (_event_key_type != KEY_TYPE_STRING)");
			
			_event_id_str.push(key);
			_event_callback.push(f);
		}
		
		/**
		 *  添加回调监听,事件ID自增后并返回
		 * 
		 * @param f	事件支持一个参数,Object
		 * @return 
		 * 
		 */		
		public function AddCallback(f:Function):int
		{
			if(_event_key_type == KEY_TYPE_STRING)
				throw new Error("AddCallback but (_event_key_type == KEY_TYPE_STRING)");
			
			var new_ev:int = _callback_index + 1;
			do
			{
				new_ev = _callback_index + 1;
				
				//如果回调编号已经存在或者等于0重新来
				for(var i:int in _event_id_int)
					if(new_ev == 0 || new_ev == i )
						continue;
			
				//回调跳号赋值
				_callback_index = new_ev;
			} while (false);
			
			AddListenInt(new_ev,f);
			return new_ev;			
		}
		
		/**
		 * 清空所有已经注册的事件监听 
		 * 
		 */		
		public function Clear():void
		{
			if(_event_callback)
				_event_callback.length = 0;
			if(_event_id_int)
				_event_id_int.length = 0;
			if(_event_id_str)
				_event_id_str.length = 0;
			if(_event_index)
				_event_index.length = 0;
		}
	}
}
