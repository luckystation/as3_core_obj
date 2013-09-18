 package core_obj
{
	public class SyncEvent
	{
		public static const OPT_SET 	:int = 0x01;
		public static const OPT_UNSET :int = 0x02;
		public static const OPT_ADD 	:int = 0x04;
		public static const OPT_SUB 	:int = 0x08;		
		public static const OPT_NEW 	:int = 0x10;	//说明这是一个新对象
		public static const OPT_DELETE :int = 0x20;	//对象移除,带字符串guid
		public static const OPT_UPDATE :int = 0x40;	//覆盖式更新
		
		public static const TYPE_UINT32 :int = 0;
		public static const TYPE_UINT16 :int = 1;
		public static const TYPE_UINT8 :int = 2;
		public static const TYPE_BIT :int = 3;
		public static const TYPE_UINT64 :int = 4;
		public static const TYPE_INT32 :int = 5;
		public static const TYPE_STRING :int = 6;
		public static const TYPE_INT16 :int = 7;
		public static const TYPE_INT8 :int = 8;
		
		public static const ATOMIC_OPT_RESULT_NO 	:int = 0;		//不是原子操作
		public static const ATOMIC_OPT_RESULT_TRY 	:int = 1;	//尝试原子操作
		public static const ATOMIC_OPT_RESULT_OK 	:int = 2;		//原子操作成功
		public static const ATOMIC_OPT_RESULT_FAILED:int = -1;	//原子操作失败
				
		public static const SYNC_NONE:int = 0;		//不同步,即不产生同步事件		
		public static const SYNC_MASTER:int = 1;		//对象为主模式，所有的操作产生成 覆盖模式		
		public static const SYNC_SLAVE:int = 2;		//对象为从模式，操作产生 为binlog模式
		
		public function SyncEvent()
		{
		}
		protected static function GetInt32Value(val:uint):int
		{
			return int(val - 0xFFFFFFFF) - 1;
		}		
		protected static function GetUInt16Value(vaule:uint, offset:int):uint
		{
			return (vaule & (0x0000FFFF << (offset << 4))) >> (offset << 4) & 0xFFFF;
		}
		protected static function SetUInt16Value(old:uint, value:uint, offset:int):uint
		{
			return old & (0xFFFFFFFF ^ (0xFFFF << (offset << 4))) | (value << (offset << 4));
		}
		protected static function GetInt16Value(vaule:uint, offset:int):int
		{
			var v:int = (vaule & (0x0000FFFF << (offset << 4))) >> (offset << 4) & 0xFFFF;
			return v > 32768 ? v - 65535 : v;
		}
		protected static function SetInt16Value(old:uint, value:int, offset:int):uint
		{
			if(value < 0) value += 65535;
			return old & (0xFFFFFFFF ^ (0xFFFF << (offset << 4))) | (value << (offset << 4));
		}
		protected static function GetByteValue(value:uint, offset:int):uint
		{
			return (value&(0x000000FF << (offset<<3)))>> (offset<<3) & 0xFF;
		}
		
		
		
		protected static function SetByteValue(old:uint, value:uint, offset:int):uint
		{
			return old & (0xFFFFFFFF ^ (0xFF << (offset << 3))) | (value << (offset << 3));			
		}			
		
		protected static function SetBitValue(old:uint, value:uint, offset:int):uint
		{
			return old & (0xFFFFFFFF ^ (0x1 << offset)) | (value << offset);
		}
	}
}