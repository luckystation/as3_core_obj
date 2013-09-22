package core_obj
{
	import flash.utils.ByteArray;
	
	public class GuidObject extends SyncEventRecorder
	{
		
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
	}
} 
