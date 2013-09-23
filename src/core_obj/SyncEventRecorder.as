package core_obj
{
	import flash.utils.ByteArray;	
		
	/**
	 * 这个类主要包含以下功能
	 * 1)下标的容器(_uint32_values)
	 * 2)记录对下标操作的记录
	 * 3)对象更新的打包
	 * 3)事件(下标监听/原子操作)添加监听及响应 
	 * @author linbc
	 * 
	 */
	public class SyncEventRecorder extends SyncEvent
	{
		/**
		 * 事件记录器的模式 
		 */		
		protected var _mode:int = 0;
		
		/**
		 * 用于监听下标变化 
		 */		
		private var _events_value:EventDispatcher = new EventDispatcher();
		
		/**
		 * 用于监听字符下标变化
		 */		
		private var _events_str_values:EventDispatcher = new EventDispatcher();
		
		/**
		 * 用于事件回调
		 */		
		private var _events_callback:EventDispatcher = new EventDispatcher();
		
		/**
		 * 记录着所有的操作 
		 */		
		private var _binlogs:Vector.<BinLogStru> = new Vector.<BinLogStru>;
		
		/**
		 * 当记录器是主模式下时，主要记录的是变化的下标 
		 */		
		private var _mask:UpdateMask;
		
		/**
		 * 记录字符下标的变化 
		 */		
		private var _mask_string:UpdateMask;
		
		//将所有
		protected var _uint32_values:ByteArray = new ByteArray;
		
		//字符串下标值
		protected var _str_values:Vector.<String> = new Vector.<String>();
		
		//对象的唯一ID
		protected var _guid:String = "";		
		
		public function SyncEventRecorder(mode:int)
		{
			_mode = mode;
			//主模式下有一个binlog用于UpdateMask
			if(_mode == SYNC_MASTER){
				_mask = new UpdateMask;
				_mask_string = new UpdateMask;
				
				//
				var binlog:BinLogStru = new BinLogStru;				
				binlog.opt = OPT_UPDATE;
				_binlogs.push(binlog);
			}else{
				_mask = null;
				_mask_string = null;
			}
			super();
		}
		
		public function Reset():void
		{
			_events_value.Clear();
			_events_str_values.Clear();
			_events_callback.Clear();
			
			if(_mask) 
				_mask.Clear();
			if(_mask_string)
				_mask_string.Clear();
			
			_str_values.length = 0;
			_uint32_values.length = 0;			
			
			//主模式下永远保存着第一个binlog为OPT_UPDATE
			if(_mode == SYNC_MASTER){
				_binlogs.length = 1;
				_binlogs[0].Clear();
			}
			else _binlogs.length = 0;
		}
		
//		
//		public function OnEventNew(k:String):void
//		{		
//			if(k.length == 0)
//				throw new Error("OnEventNew but k.length == 0");
//			_guid = k;
//			var binlog:BinLogStru = new BinLogStru;
//			binlog.opt = OPT_NEW;
//			_binlogs.push(binlog);
//		}
//		
//		public function OnEventDelete(k:String):void
//		{	
//			if(k.length == 0)
//				throw new Error("OnEventDelete but k.length == 0");
//			_guid = k;
//			var binlod:BinLogStru = new BinLogStru;
//			binlod.opt = OPT_DELETE;
//			_binlogs.push(binlod);
//		}

		protected function OnEventUInt32(opt:int,index:int,value:uint):void
		{
			//从模式下记录下标操作记录
			//主模式下记录哪些下标发生变化,直接覆盖式更新即可
			if(_mode == SYNC_SLAVE){
				var binlog:BinLogStru = new BinLogStru();
				binlog.opt = opt;
				binlog.index = index;			
				binlog.uint32 = value;
				_binlogs.push(binlog);	
			}else if(_mode == SYNC_MASTER){
				_mask.SetBit(index);
			}
		}
		
		protected function OnEvent(opt:int,index:int,offset:int,value:int,typ:int):void
		{
			//从模式下记录下标操作记录
			//主模式下记录哪些下标发生变化,直接覆盖式更新即可
			if(_mode == SYNC_SLAVE){
				var binlog:BinLogStru = new BinLogStru();
				binlog.opt = opt;
				binlog.index = index;			
				switch(typ)
				{
					case TYPE_UINT32:
						binlog.uint32 = value;
						break;
					case TYPE_INT32:
						binlog.int32 = value;
						break;
					case TYPE_UINT16:
						binlog.uint16 = value;
						binlog.offset = offset;
						break;
					case TYPE_UINT8:
						binlog.uint8 = value;
						binlog.offset = offset;
						break;				
					case TYPE_INT16:
						binlog.int16 = value;
						binlog.offset = offset;
						break;
					case TYPE_INT8:
						binlog.int8 = value;
						binlog.offset = offset;
						break;
				}
				_binlogs.push(binlog);
			}else if(_mode == SYNC_MASTER){
				_mask.SetBit(index);
			}
		}
		
		protected function OnEventStr(opt:int,index:int,val:String):void
		{
			//从模式下记录下标操作记录
			//主模式下记录哪些下标发生变化,直接覆盖式更新即可
			if(_mode == SYNC_SLAVE){
				var binlog:BinLogStru = new BinLogStru;
				binlog.opt = opt;
				binlog.index = index;
				binlog.str = val;
				_binlogs.push(binlog);
			}else if(_mode == SYNC_MASTER){
				_mask_string.SetBit(index);	
			}
		}
		
		private function OnEventSyncBinLog(binlog:BinLogStru):void
		{
			//如果是主模式
			if(_mode == SYNC_MASTER){
				//如果是原子操作,进入binlog列表后直接返回
				if(binlog.atomic_opt){
					_binlogs.push(binlog);
					return;
				}
				
				//不是原子操作，主模式下设置更新标志				
				if(binlog.typ == TYPE_STRING)
					_mask_string.SetBit(binlog.index);
				else
					_mask.SetBit(binlog.index);
				
			}else if(_mode == SYNC_SLAVE){
				//如果是从模式的原子操作则触发回调
				if(binlog.atomic_opt){
					_events_callback.DispatchInt(binlog.callback_idx,binlog);
					return;
				}

				//从模式下收到的主模式更新是一个binlog,里面带了一个UpdateMask
				if(binlog.typ == TYPE_STRING){					
					_events_str_values.Dispatch(binlog,function(index:int,param:BinLogStru):Boolean{
						return param._value_mask.GetBit(index);
					});
				}else{
					_events_value.Dispatch(binlog,function(index:int,param:BinLogStru):Boolean{
						return param._value_mask.GetBit(index);
					});
				}
			}			
		}
		
		public function AddListen(index:int,callback:Function):void
		{
			_events_value.AddListenInt(index,callback);
		}
		
		public function AddListenString(index:int,callback:Function):void
		{
			_events_str_values.AddListenInt(index,callback);
		}
		
		public function AtomicSetInt32(index:int,val:int,callback:Function):void
		{
			var binlog:BinLogStru = new BinLogStru;
			binlog.opt = OPT_SET;
			binlog.typ = TYPE_INT32;
			binlog.atomic_opt = ATOMIC_OPT_RESULT_TRY;
			binlog.index = index;
			binlog.int32 = val;
			binlog.old_int32 = 0;	//TODO:这里不用设置为当前值?
			binlog.callback_idx = _events_callback.AddCallback(callback);
			_binlogs.push(binlog);
		}
		
		public function AtomicSetString(index:int,val:String,callback:Function):void
		{
			var binlog:BinLogStru = new BinLogStru;
			binlog.opt = OPT_SET;
			binlog.typ = TYPE_INT32;
			binlog.atomic_opt = ATOMIC_OPT_RESULT_TRY;
			binlog.index = index;
			binlog.str = val;
			binlog.old_str = "";	//TODO:这里不用设置为当前值?
			binlog.callback_idx = _events_callback.AddCallback(callback);
			_binlogs.push(binlog);
		}
		
		///////////////////////////////////////////////////////////////////////////////////////////
		//以下为对象传输相关
		
		private function ReadValues(mask:UpdateMask,bytes:ByteArray):Boolean
		{
			var length:int = mask.GetCount();
			for(var i:int = 0; i < length;i++){
				if(mask.GetBit(i)){
					_uint32_values.position = (i << 2);
					_uint32_values.writeUnsignedInt(bytes.readUnsignedInt());
				}
			}
			return true;
		}
		
		private function ReadStringValues(mask:UpdateMask,bytes:ByteArray):Boolean
		{
			var length:int = mask.GetCount();			
			for(var i:int = 0; i < length; i++){
				if(mask.GetBit(i)){
					//这样的性能并不好，但是可以节约内存，而且字符下标的用途比较少
					if(i >= _str_values.length)
						_str_values.length = i+1;
					_str_values[i] = bytes.readUTF();
				}
			}
			return true;
		}
		
		/**
		 * 数字下标创建包掩码
		 *  
		 * @param mask
		 * 
		 */		
		private function GetCreateMask(mask:UpdateMask):void
		{
			mask.Clear();
			var len:int = _uint32_values.length >> 2;
			for(var i:int = 0; i < len; i++){
				//如果该下标不等于0则需要下发
				_uint32_values.position = i << 2;
				var v:uint = _uint32_values.readUnsignedInt();
				if(v) 
					mask.SetBit(i);					
			}
		}
		
		/**
		 * 字符串创建包掩码 
		 * 
		 * @param mask
		 * 
		 */		
		private function GetCreateStringMask(mask:UpdateMask):void
		{
			mask.Clear();
			var len:int = _str_values.length;
			for(var i:int = 0; i < len; i++){
				if(_str_values[i] && _str_values[i].length > 0)
					mask.SetBit(i);
			}
		}
		
		/**
		 * 根据掩码写入整数下标的值
		 *  
		 * @param mask
		 * @param bytes
		 * 
		 */		
		private function WriteValues(mask:UpdateMask,bytes:ByteArray):void
		{
			var i:int;
			var len:int = mask.GetCount();
			for(i = 0; i<len; i++){
				if(mask.GetBit(i))
					bytes.writeBytes(_uint32_values,i << 2, 4);				
			}
		}
		
		private function WriteStringValues(mask:UpdateMask,bytes:ByteArray):void
		{
			var i:int;
			var len:int = mask.GetCount();
			for(i = 0; i < len; i++){
				if(mask.GetBit(i))
					bytes.writeUTF(_str_values[i]);
			}
		}

		private function ApplyAtomicBinLog(binlog:BinLogStru):void
		{
			//字符串分支
			if(binlog._typ == TYPE_STRING){
				//如果越界了就扩张
				if(binlog._index >= _str_values.length){
					_str_values.length = binlog._index + 1;
				}
				//如果不等就操作失败
				if(binlog._old_value_str != _str_values[binlog._index]){
					binlog._old_value_str = binlog._value_str;
					binlog._value_str = _str_values[binlog._index];
					binlog._atomic_opt = ATOMIC_OPT_RESULT_FAILED;
				}else{
					binlog._atomic_opt = ATOMIC_OPT_RESULT_OK;
					
					//应用完后记录一下准备回去了
					ApplyBinLog(binlog);
				}
				return ;
			}
			
			//其他类型,目前仅仅支持uint32/int32类型
			if(binlog._index >= (_uint32_values.length >> 2)){
				_uint32_values.length = (binlog._index+1) << 2;
			}
			//读取u32进行比较
			_uint32_values.position = binlog._index << 2;
			var cur_val:uint = _uint32_values.readUnsignedInt();
			if(binlog._old_value_u32 != cur_val){
				binlog._old_value_u32 = binlog._value_u32;
				binlog._value_u32 = cur_val;
				binlog._atomic_opt = ATOMIC_OPT_RESULT_FAILED;
			}else{
				binlog._atomic_opt = ATOMIC_OPT_RESULT_OK;
				
				//应用完后记录一下准备回去了
				ApplyBinLog(binlog);
			}
		}
		
		private function ApplyBinLog(binlog:BinLogStru):void
		{
			//字符串直接处理掉了
			if(binlog._typ == TYPE_STRING){
				if(binlog._index >= _str_values.length)
					_str_values.length = binlog._index + 1;
				_str_values[binlog._index] = binlog._value_str;
				return ;
			}
			
			switch(binlog._opt){
				case OPT_SET:
					switch(binlog._typ){
						case TYPE_UINT32:
							break;
						case TYPE_INT32:
							break;
						case TYPE_UINT16:
							break;
						case TYPE_INT16:
							break;
						case TYPE_INT8:
							break;
						case TYPE_BIT:
							break;
					}
					break;
				case OPT_UNSET:
					break;
				case OPT_ADD:
					switch(binlog._typ){
						case TYPE_UINT32:
							break;
						case TYPE_INT32:
							break;
						case TYPE_UINT16:
							break;
						case TYPE_INT16:
							break;
						case TYPE_INT8:
							break;							
					}
					break;
				case OPT_SUB:
					switch(binlog._typ){
						case TYPE_UINT32:
							break;
						case TYPE_INT32:
							break;
						case TYPE_UINT16:
							break;
						case TYPE_INT16:
							break;
						case TYPE_INT8:
							break;							
					}
					break;					
			}
		}
	
		public function ReadFrom(flags:int,bytes:ByteArray):Boolean
		{
			var binlog:BinLogStru = new BinLogStru();
			var mask:UpdateMask = new UpdateMask();

			if(flags & OPT_NEW || flags & OPT_UPDATE){
				//创建包需要将所有的值清空
				if(flags & OPT_NEW){					
					Reset();
				}
				//用于更新时使用的掩码
				mask.ReadFrom(bytes);
				//读取整数
				ReadValues(mask,bytes);
				
				//触发一下事件
				binlog.Clear();
				binlog._opt = flags;
				binlog._typ = TYPE_UINT32;
				binlog._value_mask = mask;
				OnEventSyncBinLog(binlog);
				
				//读取字符串
				mask.ReadFrom(bytes);
				ReadStringValues(mask,bytes);
				
				binlog.Clear();
				binlog._opt = flags;
				binlog._typ = TYPE_STRING;
				binlog._value_mask = mask;
				OnEventSyncBinLog(binlog);							
			} else if(flags & OPT_DELETE) {
				//do nothing
			} else {
				binlog.ReadFrom(flags,bytes);
				if(binlog._atomic_opt){
					ApplyAtomicBinLog(binlog);	//原子操作
				} else {
					ApplyBinLog(binlog);
				}
				OnEventSyncBinLog(binlog);
			}
			return true;
		}
		
		/**
		 * 写入创建块 
		 * @param bytes
		 * 
		 */		
		public function WriteCreateBlock(bytes:ByteArray):void
		{
			//写入标志
			bytes.writeUTF(_guid);
			bytes.writeShort(1);
			bytes.writeByte(OPT_NEW);			
			
			var mask:UpdateMask = new UpdateMask;
			//先写入整形下标
			GetCreateMask(mask);
			mask.WriteTo(bytes);
			WriteValues(mask,bytes);
			
			//写入字符下标
			GetCreateStringMask(mask);
			mask.WriteTo(bytes);
			WriteStringValues(mask,bytes);
		}
		
		/**
		 * 写入离开视野包 
		 * @param bytes
		 * 
		 */		
		public function WriteReleaseBlock(bytes:ByteArray):void
		{
			bytes.writeUTF(_guid);
			bytes.writeShort(1);
			bytes.writeByte(OPT_DELETE);			
		}
		
		/**
		 * 写入更新包 
		 * @param bytes
		 * @return 
		 * 
		 */		
		public function WriteUpdateBlock(bytes:ByteArray):Boolean
		{
			if(!_binlogs.length)
				return false;

			bytes.writeUTF(_guid);
			var len:int = _binlogs.length;
			bytes.writeShort(len);
			
			for(var i:int = 0; i < len; i++){
				//写入更新标志
				bytes.writeByte(_binlogs[i].opt);
				
				if(_binlogs[i].opt & OPT_NEW){
					var mask:UpdateMask = new UpdateMask;
					//先写入整形下标
					GetCreateMask(mask);
					WriteValues(mask,bytes);
					
					//写入字符下标
					GetCreateStringMask(mask);
					WriteStringValues(mask,bytes);
				}else if(_binlogs[i].opt & OPT_UPDATE){
					//先写入整形下标变化
					_mask.WriteTo(bytes);
					WriteValues(_mask,bytes);
					
					//写入字符串
					_mask_string.WriteTo(bytes);
					WriteStringValues(_mask_string,bytes);					
				}else if(!(_binlogs[i].opt & OPT_DELETE)){
					//普通的binlog直接写入即可
					_binlogs[i].WriteTo(bytes);
				}
			}
			return false;
		}
		
		public function Equals(o:SyncEventRecorder):Boolean
		{			
			if(_uint32_values.length != o._uint32_values.length)
				return false;

			//比较整数下标
			var i:int = 0;
			var len:int = _uint32_values.length >> 2;
			
			for(i=0; i < len; i++){
				_uint32_values.position = i << 2;
				o._uint32_values.position = i << 2;
				
				if(_uint32_values.readInt() != o._uint32_values.readInt())
					return false;
			}
			
			//判断这个字符数组是否为空
			var isEmpty:Function = function(strs:Vector.<String>,i:int):Boolean{
				if(i >= strs.length)
					return true;
				if(!strs[i] || strs[i].length == 0)
					return true;
				return false;
			};
			
			len = _str_values.length;
			
			for(i = 0; i < len; i++){
				//如果两边都为空则相等
				if(isEmpty(_str_values,i) != isEmpty(o._str_values,i))
					return false;
				if(_str_values[i] != o._str_values[i])
					return false;
			}
			
			return true;			
		}
	}
}
