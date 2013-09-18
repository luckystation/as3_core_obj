package core_obj
{
	import flash.utils.ByteArray;
	
	public class GuidObject extends SyncEventRecorder
	{
		//将所有
		protected var _uint32_values:ByteArray = new ByteArray;
		
		//字符串下标值
		protected var _str_values:Vector.<String> = new Vector.<String>();
		
		protected var _guid:String = "";
		
		//引用计数
		protected var _ref:int = 0;
		
		/**
		 * 增加引用计数 
		 * @param r 计数变量,1/-1
		 * 
		 */		
		public function add_ref(r:int):void
		{
			_ref = _ref+r;
		}
		
		/**
		 * 当引用计数小于等于0的时候就可以从对象表中被释放了 
		 * @return 
		 * 
		 */		
		public function get ref():int
		{
			return _ref;
		}
		
		public function GetGuid():String
		{
			return _guid;
		}
		
		public function SetGuid(g:String):void
		{
			_guid = g;
		}
		
		public function  Reset(guid:String):void
		{
			_guid = guid;
			_str_values.length = 0;
			_uint32_values.length = 0;
		}
		
		public function GuidObject()
		{
			super();
		}		
		
		/////////////////////////////////////////////////////////////////////
		//以下为下标操作相关
		
		public function GetUInt32(index:int):uint
		{			
			if(_uint32_values.length > (index << 2)){
				_uint32_values.position = (index << 2);
				return _uint32_values.readUnsignedInt();	
			}
			
			return 0;
		}
		
		public function SetUInt32(index:int,value:uint):void
		{
			//记录一下日志
			OnEventUInt32(OPT_SET,index,value);
			
			//如果空间不够就自动增长
			if(_uint32_values.length <= (index << 2)){
				_uint32_values.length = ((index+1) << 2);				
			}
			_uint32_values.position = (index << 2);
			_uint32_values.writeUnsignedInt(value);
		}
		
		public function GetInt32(index:int):int
		{
			if(_uint32_values.length > (index << 2)){
				_uint32_values.position = (index << 2);
				return _uint32_values.readInt();	
			}
			
			return 0;
		}
		
		public function SetInt32(index:int,value:int):void
		{
			OnEvent(OPT_SET,index,0,value,TYPE_INT32);
			
			//如果空间不够就自动增长
			if(_uint32_values.length <= (index << 2)){
				_uint32_values.length = ((index+1) << 2);				
			}
			_uint32_values.position = (index << 2);
			_uint32_values.writeInt(value);
		}
		
		public function GetUInt16(index:int,offset:int):uint
		{
			if(_uint32_values.length > (index << 2)){
				_uint32_values.position = (index << 2) + (offset << 1);
				return _uint32_values.readUnsignedShort();	
			}
			
			return 0;
		}
		
		public function SetUInt16(index:int,offset:int,value:uint):void
		{
			OnEvent(OPT_SET,index,offset,value,TYPE_UINT16);
			
			//如果空间不够就自动增长
			if(_uint32_values.length <= (index << 2)){
				_uint32_values.length = ((index+1) << 2);				
			}
			_uint32_values.position = (index << 2) + (offset << 1);
			_uint32_values.writeShort(value);
		}
		
		public function GetInt16(index:int,offset:int):int
		{
			if(_uint32_values.length > (index << 2)){
				_uint32_values.position = (index << 2) + (offset << 1);
				return _uint32_values.readShort();	
			}
			
			return 0;
		}
		
		public function SetInt16(index:int,offset:int,value:int):void
		{
			OnEvent(OPT_SET,index,offset,value,TYPE_INT16);
			
			//如果空间不够就自动增长
			if(_uint32_values.length <= (index << 2)){
				_uint32_values.length = ((index+1) << 2);				
			}
			_uint32_values.position = (index << 2) + (offset << 1);
			_uint32_values.writeShort(value);
		}
		
		public function GetByte(index:int,offset:int):int
		{
			if(_uint32_values.length > (index << 2) + offset){
				_uint32_values.position = (index << 2) + offset;
				return _uint32_values.readByte();	
			}
			return 0;			
		}
		
		public function SetByte(index:int,offset:int,value:int):void
		{
			OnEvent(OPT_SET,index,offset,value,TYPE_INT8);
			
			//如果空间不够就自动增长
			if(_uint32_values.length <= (index << 2 + offset)){
				_uint32_values.length = (index << 2 + offset);				
			}
			_uint32_values.position = (index << 2) + offset;
			_uint32_values.writeByte(value);
		}
		
		public function GetStr(index:int):String
		{			
			if(index < _str_values.length)
				return _str_values[index];
			return "";
		}
		
		public function SetStr(index:int,val:String):void
		{
			OnEventStr(OPT_SET,index,val);
			
			if(index >= _str_values.length)
				_str_values.length = index + 1;
			_str_values[index] = val;
		}
		
		///////////////////////////////////////////////////////////////////////////////////////////
		//以下为对象传输相关
		
		public function ReadValues(mask:UpdateMask,bytes:ByteArray):Boolean
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
		
		public function ReadStringValues(mask:UpdateMask,bytes:ByteArray):Boolean
		{
			var length:int = mask.GetCount();
			for(var i:int = 0; i < length; i++){
				if(mask.GetBit(i)){
					_str_values[i] = bytes.readUTF();
				}
			}
			return true;
		}
		
		public function WriteUpdateValues(mask:UpdateMask,mask_string:UpdateMask,bytes:ByteArray):void
		{					
			//先写入整形下标变化
			mask.WriteTo(bytes);
			var i:int;
			var len:int = mask.GetCount();
			for(i = 0; i<len; i++){
				if(mask.GetBit(i)){
					bytes
				}
			}
			
			//再写入字符下标变化
			mask_string.WriteTo(bytes);
		}
		
		public function ApplyAtomicBinLog(binlog:BinLogStru):void
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
				
		public function ApplyBinLog(binlog:BinLogStru):void
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
	}
} 
