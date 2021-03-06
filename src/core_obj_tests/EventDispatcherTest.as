package core_obj_tests
{
	import mx.core.mx_internal;
	
	import core_obj.BinLogStru;
	import core_obj.EventDispatcher;
	import core_obj.UpdateMask;
	
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertTrue;
	
	
	public class EventDispatcherTest
	{		
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
		public function testAddListenInt():void
		{
			var evs:EventDispatcher = new EventDispatcher(EventDispatcher.KEY_TYPE_INT);
			var run_result:Boolean = false;
			evs.AddListenInt(13,function():void{
				run_result = true;				
			});
					
			evs.DispatchInt(14,null);
			assertFalse(run_result);
			
			evs.DispatchInt(13,null);
			assertTrue(run_result);
			
			//只触发一次
			run_result = false;
			evs.DispatchInt(13,null);			
			assertFalse(run_result);
		}
		
		[Test]
		public function testAddListenString():void
		{
			var evs:EventDispatcher = new EventDispatcher(EventDispatcher.KEY_TYPE_STRING);
						
			var run_step:int = 0;
			
			//事件反应器又是用于添加监听的
			evs.AddListenString("a",function():void{
				run_step = 1;
				evs.AddListenString("b",function ():void{
					run_step = 2;
				});
			});
			
			//在没有触发a之前，触发b是没有用的
			evs.DispatchString("b",null);
			assertEquals(run_step,0);
			
			evs.DispatchString("a",null);
			assertEquals(run_step,1);
			
			evs.DispatchString("b",null);
			assertEquals(run_step,2);
		}
		
		[Test]
		public function testAddCallback():void
		{
			var evs:EventDispatcher = new EventDispatcher(EventDispatcher.KEY_TYPE_INT);
			
			var total:int = 0;
			var total_callback:int = 0;
			var i:int;
			
			var indexs:Vector.<int> = new Vector.<int>;
			
			//因为回调编号不使用0,所以从1开始循环
			for(i = 0 ; i < 100; i++){
				total += i;
				indexs.push(evs.AddCallback(function():void{
					total_callback += i;
				}));
			}
			
			for(i in indexs){
				evs.DispatchInt(i,null);
			}
			assertEquals(total,total_callback);
		}
	
		[Test]
		public function testDispatch():void
		{
			var evs:EventDispatcher = new EventDispatcher(EventDispatcher.KEY_TYPE_INT);
			
			var ret:Boolean = false;
			evs.AddListenInt(10,function():void{
				ret = true;
			});
			
			var binlog:BinLogStru = new BinLogStru;
			binlog._value_mask = new UpdateMask();
			binlog._value_mask.SetBit(10);
			
			evs.Dispatch(binlog,function(i:int,p:BinLogStru):Boolean{
				return p._value_mask.GetBit(i);			
			});
			
			assertTrue(ret);			
		}
	}
}