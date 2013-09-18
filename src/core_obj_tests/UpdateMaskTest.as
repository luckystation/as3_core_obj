package core_obj_tests
{
	import flash.utils.ByteArray;
	
	import core_obj.UpdateMask;
	
	import flexunit.framework.Assert;
	
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertTrue;
	
	public class UpdateMaskTest
	{		
		public var _mask:UpdateMask = new UpdateMask();
		
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
		public function testSetCount():void
		{
			_mask.SetCount(100);
			Assert.assertEquals(_mask.GetCount(),((100+7)>>3)<<3);			
		}
		
		[Test]
		public function testClear():void
		{
			_mask.Clear();
			assertEquals(_mask.GetCount(),0);			
		}
		
		[Test]
		public function testWriteTo():void
		{
			_mask.Clear();
			_mask.SetBit(0);
			_mask.SetBit(7);
			_mask.SetBit(8);
			_mask.SetBit(107);
			
			var bytes:ByteArray = new ByteArray();
			_mask.WriteTo(bytes);
			
			//重新读取后验证应该与刚才的一致
			bytes.position = 0;
			_mask.ReadFrom(bytes);
			var len:int = _mask.GetCount();
			assertTrue(len >= 107);
			
			for(var i:int=0; i < len;i++){
				if(i == 0 || i==7 || i==8 || i==107)
					assertTrue(_mask.GetBit(i));
				else
					assertFalse(_mask.GetBit(i));
			}
		}
		
		[Test]
		public function testSetBit():void
		{
			assertFalse(_mask.GetBit(0));
			assertFalse(_mask.GetBit(1));
			_mask.SetBit(3);
			assertTrue(_mask.GetBit(3));
			_mask.SetBit(13);
			assertTrue(_mask.GetBit(13));			
		}		
	}
}