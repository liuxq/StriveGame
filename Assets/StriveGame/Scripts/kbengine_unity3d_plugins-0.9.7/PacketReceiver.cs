namespace KBEngine
{
	using System; 
	using System.Net.Sockets; 
	using System.Net; 
	using System.Collections; 
	using System.Collections.Generic;
	using System.Text;
	using System.Text.RegularExpressions;
	using System.Threading;
	
	using MessageID = System.UInt16;
	using MessageLength = System.UInt16;
	
	/*
		包接收模块(与服务端网络部分的名称对应)
		处理网络数据的接收
	*/
    public class PacketReceiver 
    {
		private NetworkInterface _networkInterface = null;
		AsyncCallback _asyncCallback = null;

		private byte[] _buffer;
		
		// socket向缓冲区写的起始位置
		int _wpos = 0;	
		
		// 主线程读取数据的起始位置
		int _rpos = 0;	
		
        public PacketReceiver(NetworkInterface networkInterface)
        {
        	_init(networkInterface);
        }

		~PacketReceiver()
		{
			Dbg.DEBUG_MSG("PacketReceiver::~PacketReceiver(), destroyed!");
		}

		void _init(NetworkInterface networkInterface)
		{
			_networkInterface = networkInterface;
            _buffer = new byte[NetworkInterface.RECV_BUFFER_MAX];
			_asyncCallback = new AsyncCallback(_onRecv);
			
		}
		
		public NetworkInterface networkInterface()
		{
			return _networkInterface;
		}
		
		public void process()
		{
			int t_wpos = Interlocked.Add(ref _wpos, 0);

			if(_rpos < t_wpos)
			{
                LuaFramework.Util.CallMethod("KBEngineLua.MessageReader", "process", new object[] { _buffer, (UInt32)_rpos, (UInt32)(t_wpos - _rpos) });
				//messageReader.process(_buffer, (UInt32)_rpos, (UInt32)(t_wpos - _rpos));
				Interlocked.Exchange(ref _rpos, t_wpos);
			} 
			else if(t_wpos < _rpos)
			{
                LuaFramework.Util.CallMethod("KBEngineLua.MessageReader", "process", new object[] { _buffer, (UInt32)_rpos, (UInt32)(_buffer.Length - _rpos) });
                LuaFramework.Util.CallMethod("KBEngineLua.MessageReader", "process", new object[] { _buffer, (UInt32)0, (UInt32)t_wpos });
				//messageReader.process(_buffer, (UInt32)_rpos, (UInt32)(_buffer.Length - _rpos));
				//messageReader.process(_buffer, (UInt32)0, (UInt32)t_wpos);
				Interlocked.Exchange(ref _rpos, t_wpos);
			}
			else
			{
				// 没有可读数据
			}
		}
		
		int _free()
		{
			int t_rpos = Interlocked.Add(ref _rpos, 0);
			
			if(_wpos == _buffer.Length)
			{
				if(t_rpos == 0)
				{
					return 0;
				}
				
				Interlocked.Exchange(ref _wpos, 0);
			}
			
			if(t_rpos <= _wpos)
			{
				return _buffer.Length - _wpos;
			}

			return t_rpos - _wpos - 1;
		}
		
		public void startRecv()
		{
			// 必须有空间可写，否则我们阻塞在线程中直到有空间为止
			int first = 0;
			int space = _free();
			
			while(space == 0)
			{
				if(first > 0)
				{
					if(first > 1000)
						throw new Exception("PacketReceiver::startRecv(): no space!");
					 
					Dbg.WARNING_MSG("PacketReceiver::startRecv(): waiting for space, Please adjust 'RECV_BUFFER_MAX'! retries=" + first);
					System.Threading.Thread.Sleep(5);
				}
				
				first += 1;
				space = _free();
			}
			
			try
			{
				_networkInterface.sock().BeginReceive(_buffer, _wpos, space, 0,
						_asyncCallback, this);
			}
			catch (Exception e) 
			{
				Dbg.ERROR_MSG("PacketReceiver::startRecv(): call ReceiveAsync() is err: " + e.ToString());
				Event.fireIn("_closeNetwork", new object[]{_networkInterface});
			}
		}
		
		private static void _onRecv(IAsyncResult ar)
		{	
			// Retrieve the socket from the state object.
			PacketReceiver state = (PacketReceiver) ar.AsyncState;
				
			try 
			{
				// 由于多线程问题，networkInterface可能已被丢弃了
				// 例如：在连接loginapp之后自动开始连接到baseapp之前会先关闭并丢弃networkInterface
				if(!state.networkInterface().valid())
					return;
				
				Socket client = state.networkInterface().sock();
				
		        // Read data from the remote device.
		        int bytesRead = client.EndReceive(ar);

		        if (bytesRead > 0) 
		        {
		        	// 更新写位置
		        	Interlocked.Add(ref state._wpos, bytesRead);
		            state.startRecv();
		        }
				else
		        {
		        	if (bytesRead == 0) 
		        	{
		        		Dbg.WARNING_MSG(string.Format("PacketReceiver::_processRecved(): disconnect!"));
		        		Event.fireIn("_closeNetwork", new object[]{state.networkInterface()});
		        		return;
		        	}
		        	else
		        	{
		        		state.startRecv();
		        	}
		        }
			} 
			catch (Exception e) 
			{
				Dbg.ERROR_MSG(string.Format("PacketReceiver::_processRecved(): is error({0})!", e.ToString()));
				Event.fireIn("_closeNetwork", new object[]{state.networkInterface()});
			}
		}
	}
} 
