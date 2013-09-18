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
				p = new GuidObject();
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
			//是否无效对象
			var invalid_obj:Boolean = false;
			var is_new_event:Boolean = false;
			
			var guid:String = bytes.readUTF();
			var count:int = bytes.readUnsignedShort();
			
			var cur_obj:GuidObject = Get(guid);
			if(!cur_obj){
				cur_obj = CreateObject(guid);
			}
			
			var binlog:BinLogStru = new BinLogStru();
			var mask:UpdateMask = new UpdateMask();
			
			for(var i:int = 0; i < count; i++){
				//事件标志
				var flags:int = bytes.readUnsignedByte();
				if(flags & OPT_NEW || flags & OPT_UPDATE){
					//创建包需要将所有的值清空
					if(flags & OPT_NEW){
						is_new_event = true;
						invalid_obj = false;
						cur_obj.Reset(guid);
					}
					//用于更新时使用的掩码
					mask.ReadFrom(bytes);
					//读取整数
					cur_obj.ReadValues(mask,bytes);
					
					//触发一下事件
					binlog.Clear();
					binlog._opt = flags;
					binlog._typ = TYPE_UINT32;
					binlog._value_mask = mask;
					cur_obj.OnEventSyncBinLog(binlog);
					
					//读取字符串
					mask.ReadFrom(bytes);
					cur_obj.ReadStringValues(mask,bytes);
					
					binlog.Clear();
					binlog._opt = flags;
					binlog._typ = TYPE_STRING;
					binlog._value_mask = mask;
					cur_obj.OnEventSyncBinLog(binlog);
					
					//触发创建对象事件
					if(is_new_event && !invalid_obj)
						DispatchNewObject(cur_obj);
				} else if(flags & OPT_DELETE) {
					DispatchCloseObject(cur_obj);
					ReleaseKey(guid);					
				} else {
					binlog.ReadFrom(flags,bytes);
					if(binlog._atomic_opt){
						cur_obj.ApplyAtomicBinLog(binlog);	//原子操作
					} else {
						cur_obj.ApplyBinLog(binlog);
					}
					cur_obj.OnEventSyncBinLog(binlog);
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
