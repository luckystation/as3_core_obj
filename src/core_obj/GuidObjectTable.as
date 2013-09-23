package core_obj
{
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	public class GuidObjectTable extends SyncEvent
	{		
		protected var _objs:Dictionary = new Dictionary;
		
		//库的主从模式
		protected var _mode:int = SYNC_MASTER;
		
		//发包函数
		protected var _send_msg:Function;
		
		public function GuidObjectTable(m:int,f:Function)
		{
			//对象更新只可以有从表，或者主表类型
			if(m != 0 && m != SYNC_MASTER && m != SYNC_SLAVE)
				throw new Error("m != 0 && m != SYNC_MASTER && m != SYNC_SLAVE");
			_mode = m;
			_send_msg = f;
		}
		
		public function Get(k:String):GuidObject
		{
			return _objs[k];
		}
				
		/**
		 * 创建对象
		 * @param k
		 * @return 
		 * 
		 */		
		public function CreateObject(k:String):GuidObject
		{
			var p:GuidObject = _objs[k];
			if(!p){
				p = new GuidObject(_mode);
				p.add_ref(1);
				_objs[k] = p;
			}
			p.add_ref(1);
			return p;
		}
		
		/**
		 * 释放对象,防止从库不同订阅相同对象所以引入引用计数
		 * @param o
		 * 
		 */		
		public function ReleaseObject(o:GuidObject):void
		{
			var k:String = o.GetGuid();
			var p:GuidObject = _objs[k];
			if(!p)
				return;
			p.add_ref(-1);
			if(p.ref <= 0){
				delete _objs[k];
			}
		}
		
		public function ReleaseKey(k:String):void
		{
			var p:GuidObject = _objs[k];
			if(!p)
				return;
			p.add_ref(-1);
			if(p.ref <= 0)
				delete _objs[k];
		}
				
		/**
		 * 对象表心跳，用于驱动对象更新主动下发 
		 * @param diff
		 * 
		 */		
		public function Update(diff:int):void
		{
			
		}
		
		/**
		 * 从流中读取对象更新 
		 * @param bytes
		 * @return 
		 * 
		 */		
		public function ReadFrom(bytes:ByteArray):Boolean
		{			
			var guid:String = bytes.readUTF();
			var count:int = bytes.readUnsignedShort();
			
			var cur_obj:GuidObject = Get(guid);
			if(!cur_obj){
				cur_obj = CreateObject(guid);
			}
			
			for(var i:int = 0; i < count; i++){
				//事件标志
				var flags:int = bytes.readUnsignedByte();	
				cur_obj.ReadFrom(flags,bytes);
				
				//触发事件
				if(flags &OPT_NEW)
					DispatchNewObject(cur_obj);
				else if(flags & OPT_DELETE){
					DispatchCloseObject(cur_obj);
					ReleaseKey(guid);
				}
			}
			return true;
		}
		
		/**
		 * 应用对象更新数据包 
		 * @param bytes
		 * @return 
		 * 
		 */		
		public function ApplyBlock(bytes:ByteArray):Boolean
		{
			return true;
		}
		
		//触发新对象事件
		protected function DispatchNewObject(obj:GuidObject):void
		{
			
		}
		protected function DispatchCloseObject(obj:GuidObject):void
		{
			
		}
	}
}
