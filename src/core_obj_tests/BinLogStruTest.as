package core_obj_tests
{
	import flash.utils.ByteArray;
	
	import avmplus.FLASH10_FLAGS;
	
	import core_obj.BinLogStru;	
	
	import org.flexunit.asserts.assertEquals;
	
	public class BinLogStruTest
	{		
		public var _binlog:core_obj.BinLogStru = new core_obj.BinLogStru;
		
		[Before]
		public function setUp():void
		{
		}
		
		[After]
		public function tearDown():void
		{
		}
		
		[BeforeClass]
		public static function setUpBeforeClass():void
		{
		}
		
		[AfterClass]
		public static function tearDownAfterClass():void
		{
		}
		
		[Test]
		public function testGet_offset():void
		{
			_binlog.Clear();
			_binlog.offset = 1;			
			assertEquals(_binlog.offset,1);
			
			_binlog.offset = 0;
			assertEquals(_binlog.offset,0);
		}
		
		[Test]
		public function testGet_int32():void
		{
			_binlog.Clear();
			_binlog.int32 = -1;
			assertEquals(_binlog.int32,-1);
			assertEquals(_binlog._value_u32,uint.MAX_VALUE);			
		}
		
		[Test]
		public function testGet_uint16():void
		{
			_binlog.Clear();
			_binlog.uint16 = 65535;
			assertEquals(_binlog.uint16,65535);
			
			_binlog.uint16 = 23;
			assertEquals(_binlog.uint16,23);
		}
		
		[Test]
		public function testGet_int16():void
		{
			_binlog.Clear();
			_binlog.int16 = -2;
			assertEquals(_binlog.int16,-2);
			
			_binlog.int16 = 23;
			assertEquals(_binlog.int16,23);
		}
		
		[Test]
		public function testGet_int8():void
		{
			_binlog.Clear();
			_binlog.int8 = -1;
			var v:int = _binlog.int8;
			assertEquals(v,-1);
			
			_binlog.int8 = 1;
			assertEquals(_binlog.int8,1);
			
			_binlog.int8 = 128;
			assertEquals(_binlog.int8,128);
		}
		
		[Test]
		public function testReadFrom():void
		{
			//普通、原子、字符串、非uint32 4种情况
			
			
			var assert_binlog:BinLogStru = new BinLogStru;
			var bytes:ByteArray = new ByteArray;
			
			//读取时要先读标志位
			var flags:int = 0;
			
			_binlog.Clear();
			_binlog.int32 = -2;
			bytes.position = 0;
			_binlog.WriteTo(bytes);
			bytes.position = 0;
			flags = bytes.readUnsignedByte();
			assert_binlog.ReadFrom(flags,bytes);
			assertEquals(assert_binlog.int32,-2);
			
			_binlog.Clear();
			_binlog.str = "abc";
			bytes.position = 0;
			_binlog.WriteTo(bytes);
			bytes.position = 0;
			flags = bytes.readUnsignedByte();
			assert_binlog.ReadFrom(flags,bytes);
			assertEquals(assert_binlog.str,"abc");
			
			_binlog.Clear();
			_binlog.int8 = -5;
			_binlog.offset = 3;
			bytes.position = 0;
			_binlog.WriteTo(bytes);
			bytes.position = 0;
			flags = bytes.readUnsignedByte();
			assert_binlog.ReadFrom(flags,bytes);
			assertEquals(_binlog.offset,assert_binlog.offset);
			assertEquals(_binlog.int8,assert_binlog.int8);			
		}
		
		[Test]
		public function testGet_uint32():void
		{
			_binlog.uint32 = uint.MAX_VALUE;
			assertEquals(uint.MAX_VALUE,_binlog.uint32);
		}
		
		[Test]
		public function testGet_uint8():void
		{
			_binlog.Clear();
			_binlog.uint8 = 255;
			assertEquals(_binlog.uint8,255);
			
			_binlog.uint8 = 1;
			assertEquals(_binlog.uint8,1);
			
			_binlog.uint8 = 128;
			assertEquals(_binlog.uint8,128);
		}
	}
}