package core_obj
{	
	import flash.utils.ByteArray;	

	/**
	 * 用于标识下对象的一步操作(包括对下标的加减设置)
	 * @author linbc
	 * 
	 */	
	public class BinLogStru extends SyncEvent
	{
		//操作类型
		public var _opt:int;
		
		//变量类型
		public var _typ:int;
		
		//下标
		public var _index:int;
		
		//标识原子操作模式 看AtomicOptResult
		public var _atomic_opt:int;
		
		public var _value_u32:uint;
		public var _value_str:String;
		public var _value_mask:UpdateMask = new UpdateMask();		
		
		public var _callback_index:uint;
		
		public var _old_value_u32:uint;
		public var _old_value_str:String;

		public function BinLogStru()
		{
			Clear();
		}
		
		public function get opt():int
		{
			return _opt;
		}
		
		public function set opt(o:int):void
		{
			_opt = o;
		}
		
		public function get index():int
		{
			return _index;
		}
		
		public function set index(i:int):void
		{
			_index = i;
		}
		
		public function get offset():int
		{			
			return GetByteValue(_value_u32,0);
		}
		
		public function set offset(val:int):void
		{
			_value_u32 = SetByteValue(_value_u32,val,0);
		}
		
		public function get typ():int
		{
			return _typ;
		}
		
		public function set typ(t:int):void
		{
			_typ = t;
		}
		
		public function get atomic_opt():int
		{
			return _atomic_opt;
		}
		
		public function set atomic_opt(val:int):void
		{
			_atomic_opt = val;
		}
		
		public function get callback_idx():int
		{
			return _callback_index;
		}
		
		public function set callback_idx(val:int):void
		{
			_callback_index = val;
		}
				
		public function get uint32():uint
		{			
			return _value_u32;
		}
		
		public function set uint32(val:uint):void
		{
			_typ = TYPE_UINT32;
			_value_u32 = val;
		}
		
		public function get int32():int
		{
			if(_typ != TYPE_INT32)
				throw new Error("get int32 but _typ != TYPE_INT32!");
			return int(_value_u32 - 0xFFFFFFFF) - 1;	
		}
		
		public function set int32(val:int):void
		{
			_typ = TYPE_INT32;			
			_value_u32 = uint(0xFFFFFFFF+val)+1;
		}
		
		public function get old_int32():int
		{
			if(_typ != TYPE_INT32)
				throw new Error("get int32 but _typ != TYPE_INT32!");
			return int(_old_value_u32 - 0xFFFFFFFF) - 1;	
		}
		
		public function set old_int32(val:int):void
		{
			if(_typ != TYPE_INT32)
				throw new Error("get int32 but _typ != TYPE_INT32!");			
			_old_value_u32 = uint(0xFFFFFFFF+val)+1;
		}

		public function get uint16():int
		{			
			if(_typ != TYPE_UINT16)
				throw new Error("get uint16 but _typ != TYPE_UINT16!");
			return GetUInt16Value(_value_u32,1);
		}
		
		public function set uint16(val:int):void
		{
			_typ = TYPE_UINT16;			
			_value_u32 = SetUInt16Value(_value_u32,val,1);
		}
		
		public function get int16():int
		{
			if(_typ != TYPE_INT16)
				throw new Error("get int16 but _typ != TYPE_INT16!");
			return GetInt16Value(_value_u32,1);			
		}
		
		public function set int16(val:int):void
		{
			_typ = TYPE_INT16;
			_value_u32 = SetInt16Value(_value_u32,val,1);
		}
		
		public function get uint8():int
		{			
			if(_typ != TYPE_UINT8)
				throw new Error("get uint8 but _typ != TYPE_UINT8!");
			return GetByteValue(_value_u32,2);
		}
		
		public function set uint8(val:int):void
		{
			_typ = TYPE_UINT8;
			_value_u32 = SetByteValue(_value_u32,val,2);	
		}
		
		public function get int8():int
		{
			var v:int = GetByteValue(_value_u32,2);
			return v > 128 ? (v - 256 ):v;			
		}
		
		public function set int8(val:int):void
		{
			val = val < 0 ? 256+val : val;
			_value_u32 = SetByteValue(_value_u32,val,2);
		}
		
		public function get str():String
		{
			if(_typ != TYPE_STRING)
				throw new Error("get str but _typ != TYPE_STRING!");
			return _value_str;
		}
		
		public function set str(v:String):void
		{
			_typ = TYPE_STRING;
			_value_str = v;
		}
		
		public function get old_str():String
		{
			if(_typ != TYPE_STRING)
				throw new Error("get old_str but _typ != TYPE_STRING!");
			return _old_value_str;
		}
		
		public function set old_str(v:String):void
		{
			if(_typ != TYPE_STRING)
				throw new Error("set old_str but _typ != TYPE_STRING!");
			_old_value_str = v;
		}
		
		public function Clear():void
		{
			_opt = 0;
			_typ = 0;
			_index = 0;
			
			_atomic_opt = SyncEvent.ATOMIC_OPT_RESULT_NO;
			
			_value_u32 = 0;
			_value_str = "";
			_value_mask.Clear();
			
			_callback_index = 0;
			_old_value_u32 = 0;
			
			_old_value_str = "";
		}
		
		public function ReadFrom(flags:uint,bytes:ByteArray):Boolean
		{
			_opt = flags;
			_typ = bytes.readUnsignedByte();
			_index = bytes.readUnsignedShort();
			_atomic_opt = bytes.readUnsignedByte();
			
			//除了字符串，其他的都通过无符号整形进行转换
			if(_typ == TYPE_STRING){
				_value_str = bytes.readUTF();
			}else{
				_value_u32 = bytes.readUnsignedInt();
			}
			
			if(_atomic_opt){
				_callback_index = bytes.readUnsignedInt();
				if(_typ == TYPE_STRING){
					_old_value_str = bytes.readUTF();
				}else{
					_old_value_u32 = bytes.readUnsignedInt();
				}
			}
			return true;
		}
		
		public function WriteTo(bytes:ByteArray):void
		{
			if(_opt & OPT_UPDATE || _opt & OPT_NEW)
				throw new Error("BinLogStru.WriteTo (_opt & OPT_UPDATE || _opt & OPT_NEW)");
//			bytes.writeByte(_opt);
			bytes.writeByte(_typ);
			bytes.writeShort(_index);
			bytes.writeByte(_atomic_opt);	//输出非原子操作
			
			//如果是字符串
			if(_typ == TYPE_STRING)
				bytes.writeUTF(_value_str);
			else
				bytes.writeUnsignedInt(_value_u32);
			//如果是原子操作需要加一些成员
			if(_atomic_opt){
				if(_typ == TYPE_STRING)
					bytes.writeUTF(_old_value_str);
				else
					bytes.writeUnsignedInt(_old_value_u32);
			}
		}
	}
}