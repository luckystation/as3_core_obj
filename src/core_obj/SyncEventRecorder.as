package core_obj
{
	import flash.utils.ByteArray;	

	public class SyncEventRecorder extends SyncEvent
	{
		/**
		 * 事件记录器的模式 
		 */		
		protected var _mode:int = 0;
		
		/**
		 * 用于监听下标变化 
		 */		
		protected var _events_value:EventDispatcher = new EventDispatcher();
		
		/**
		 * 用于监听字符下标变化
		 */		
		protected var _events_str_values:EventDispatcher = new EventDispatcher();
		
		/**
		 * 用于事件回调
		 */		
		protected var _events_callback:EventDispatcher = new EventDispatcher();
		
		/**
		 * 记录着所有的操作 
		 */		
		protected var _binlogs:Vector.<BinLogStru> = new Vector.<BinLogStru>;
		
		/**
		 * 当记录器是主模式下时，主要记录的是变化的下标 
		 */		
		protected var _mask:UpdateMask = new UpdateMask;
		
		/**
		 * 记录字符下标的变化 
		 */		
		protected var _mask_string:UpdateMask = new UpdateMask;
		
		public function SyncEventRecorder()
		{
			super();
		}
		
		protected function GetObj():GuidObject
		{
			return null;
		}
		
		protected function OnEventUInt32(opt:int,index:int,value:uint):void
		{
			var binlog:BinLogStru = new BinLogStru();
			binlog.opt = opt;
			binlog.index = index;			
			binlog.uint32 = value;
			_binlogs.push(binlog);
		}
		
		protected function OnEvent(opt:int,index:int,offset:int,value:int,typ:int):void
		{
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
		}
		
		protected function OnEventStr(opt:int,index:int,val:String):void
		{
			var binlog:BinLogStru = new BinLogStru;
			binlog.opt = opt;
			binlog.index = index;
			binlog.str = val;
			_binlogs.push(binlog);
		}
		
		public function OnEventSyncBinLog(binlog:BinLogStru):void
		{
			_binlogs.push(binlog);
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
		
		public function WriteTo(bytes:ByteArray):Boolean
		{
			if(!_binlogs.length)
				return false;
			
			var obj:GuidObject = GetObj();
			
			var mask:UpdateMask = new UpdateMask;
			
			for(var binlog:BinLogStru in _binlogs){
				bytes.writeByte(binlog.opt);
				if(binlog.opt & OPT_NEW){
					mask.Clear();
				}else if(binlog.opt & OPT_UPDATE){
					obj.WriteUpdateValues(_mask,_mask_string,bytes);
				}else
					binlog.WriteTo(bytes);	
			}
			return false;
		}
	}
}
