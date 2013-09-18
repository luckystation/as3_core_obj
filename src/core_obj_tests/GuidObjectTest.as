package core_obj_tests
{
	import core_obj.GuidObject;
	
	import flexunit.framework.Assert;
	
	import org.flexunit.asserts.assertEquals;
	
	public class GuidObjectTest
	{		
		private var _obj:GuidObject = new GuidObject;
		
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
		public function testGetByte():void
		{
			_obj.SetByte(0,0,0);
			_obj.SetByte(0,1,1);
			_obj.SetByte(0,2,2);
			_obj.SetByte(0,3,3);
			
			assertEquals(_obj.GetByte(0,0),0);
			assertEquals(_obj.GetByte(0,1),1);
			assertEquals(_obj.GetByte(0,2),2);
			assertEquals(_obj.GetByte(0,3),3);
		}
		
		[Test]
		public function testGetInt16():void
		{
			_obj.SetInt16(1,0,1);
			_obj.SetInt16(1,1,-1);
			
			assertEquals(_obj.GetInt16(1,0),1);
			assertEquals(_obj.GetInt16(1,1),-1);
		}
		
		[Test]
		public function testGetInt32():void
		{
			_obj.SetInt32(2,-1);
			assertEquals(_obj.GetInt32(2),-1);
		}
		
		[Test]
		public function testGetStr():void
		{
			_obj.SetStr(2,"abc");
			assertEquals(_obj.GetStr(2),"abc");
		}
		
		[Test]
		public function testGetUInt16():void
		{
			_obj.SetUInt16(11,0,1);
			assertEquals(_obj.GetUInt16(11,0),1);
			
			_obj.SetUInt16(11,1,2);
			assertEquals(_obj.GetUInt16(11,1),2);
			
		}
		
		[Test]
		public function testGetUInt32():void
		{
			_obj.SetUInt32(12,1);
			assertEquals(_obj.GetUInt32(12),1);
		}
		
		[Test]
		public function testApplyBinLog():void
		{
			Assert.fail("Test method Not yet implemented");
		}
		
		[Test]
		public function testReadStringValues():void
		{
			Assert.fail("Test method Not yet implemented");
		}
		
		[Test]
		public function testReadValues():void
		{
			Assert.fail("Test method Not yet implemented");
		}
	}
}