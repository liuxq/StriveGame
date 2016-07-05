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
		包发送模块(与服务端网络部分的名称对应)
		处理网络数据的发送
	*/
    public class PacketSender 
    {
		private byte[] _buffer;

		int _wpos = 0;				// 写入的数据位置
		int _spos = 0;				// 发送完毕的数据位置
		int _sending = 0;
		
		private NetworkInterface _networkInterface = null;
		AsyncCallback _asyncCallback = null;
		
        public PacketSender(NetworkInterface networkInterface)
        {
        	_init(networkInterface);
        }

		~PacketSender()
		{
			Dbg.DEBUG_MSG("PacketSender::~PacketSender(), destroyed!");
		}

		void _init(NetworkInterface networkInterface)
		{
			_networkInterface = networkInterface;
			
            _buffer = new byte[NetworkInterface.SEND_BUFFER_MAX];
			_asyncCallback = new AsyncCallback(_onSent);
			
			_wpos = 0; 
			_spos = 0;
			_sending = 0;
		}

		public NetworkInterface networkInterface()
		{
			return _networkInterface;
		}
		
		public bool send(byte[] datas)
		{
			if(datas.Length <= 0)
				return true;

			bool startSend = false;
			if(Interlocked.CompareExchange(ref _sending, 1, 0) == 0)
			{
				startSend = true;
				if(_wpos == _spos)
				{
					_wpos = 0;
					_spos = 0;
				}
			}

			int t_spos = Interlocked.Add(ref _spos, 0);
			int space = 0;
			int tt_wpos = _wpos % _buffer.Length;
			int tt_spos = t_spos % _buffer.Length;
			
			if(tt_wpos >= tt_spos)
				space = _buffer.Length - tt_wpos + tt_spos - 1;
			else
				space = tt_spos - tt_wpos - 1;

			if (datas.Length > space)
			{
				Dbg.ERROR_MSG("PacketSender::send(): no space, Please adjust 'SEND_BUFFER_MAX'! data(" + datas.Length 
					+ ") > space(" + space + "), wpos=" + _wpos + ", spos=" + t_spos);
				
				return false;
			}

			int expect_total = tt_wpos + datas.Length;
			if(expect_total <= _buffer.Length)
			{
				Array.Copy(datas, 0, _buffer, tt_wpos, datas.Length);
			}
			else
			{
				int remain = _buffer.Length - tt_wpos;
				Array.Copy(datas, 0, _buffer, tt_wpos, remain);
				Array.Copy(datas, remain, _buffer, 0, expect_total - _buffer.Length);
			}

			Interlocked.Add(ref _wpos, datas.Length);

			if(startSend)
			{
				_startSend();
			}

			return true;
		}
		
		void _startSend()
		{
			int sendSize = Interlocked.Add(ref _wpos, 0) - _spos;
			int t_spos = _spos % _buffer.Length;
			if(t_spos == 0)
				t_spos = sendSize;
		
			if(sendSize > _buffer.Length - t_spos)
				sendSize = _buffer.Length - t_spos;

			try
			{
				_networkInterface.sock().BeginSend(_buffer, _spos % _buffer.Length, sendSize, 0,
         		   _asyncCallback, this);
			}
			catch (Exception e) 
			{
				Dbg.ERROR_MSG("PacketSender::startSend(): is err: " + e.ToString());
				Event.fireIn("_closeNetwork", new object[]{_networkInterface});
			}
		}
		
		private static void _onSent(IAsyncResult ar)
		{
			// Retrieve the socket from the state object.
			PacketSender state = (PacketSender) ar.AsyncState;

			try 
			{
				// 由于多线程问题，networkInterface可能已被丢弃了
				// 例如：在连接loginapp之后自动开始连接到baseapp之前会先关闭并丢弃networkInterface
				if(!state.networkInterface().valid())
					return;

				Socket client = state.networkInterface().sock();
				
				// Complete sending the data to the remote device.
				int bytesSent = client.EndSend(ar);
				
				int spos = Interlocked.Add(ref state._spos, bytesSent);

				// 如果数据没有发送完毕需要继续投递发送
				if(spos != Interlocked.Add(ref state._wpos, 0))
				{
					state._startSend();
				}
				else
				{
					// 所有数据发送完毕了
					Interlocked.Exchange(ref state._sending, 0);
				}
			} 
			catch (Exception e) 
			{
				Dbg.ERROR_MSG(string.Format("PacketSender::_processSent(): is error({0})!", e.ToString()));
				Event.fireIn("_closeNetwork", new object[]{state.networkInterface()});
				Interlocked.Exchange(ref state._sending, 0);
			}
		}
	}
} 
