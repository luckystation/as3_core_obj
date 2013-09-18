package core_obj
{
	import flash.utils.ByteArray;

	public class UpdateMask
	{
		private var _bytes:ByteArray = new ByteArray();
		
		public function UpdateMask()
		{
		}
		
		public function Clear():void
		{
			_bytes.position = 0;
			_bytes.length = 0;
		}
		
		public function GetBit(i:int):Boolean
		{			
			if((i>>3) < _bytes.length) 
				return _bytes[i>>3] & (1<<(i&0x7));
			return false;	
		}
		
		public function SetBit(i:int):void
		{
			if(i>>3 >= _bytes.length)
				_bytes.length = (i>>3+1);
			_bytes[i>>3] |= (1<<(i&0x7));
		}
		
		public function WriteTo(bytes:ByteArray):Boolean
		{
			_bytes.position = 0;
			bytes.writeShort(_bytes.length);
			bytes.writeBytes(_bytes);
			return true;
		}
		
		public function ReadFrom(bytes:ByteArray):Boolean
		{
			//先读取uint8的字节数量
			var count:int = bytes.readUnsignedShort();
			_bytes.length = count;
			bytes.readBytes(_bytes, 0, count);
			return true;
		}
		
		public function GetCount():int
		{
			return _bytes.length << 3;		
		}
		
		public function SetCount(val:int):void
		{
			_bytes.length = (val+7)>>3;
		}
	}
}
